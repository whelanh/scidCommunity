# Book Tuning: Remove Move + Save must delete the move from the book.
#
#   xvfb-run -a ./buildcmake/scidCommunity tests/tcl/book_remove_play.tcl
#
# An app-only harness: it drives the two commands the window drives, so the
# deletion is proven at the book format rather than in the widget code.
# "sc_book moves" loads the position (that is what stores the key movesupdate
# writes) and "sc_book movesupdate" takes the payload save() builds.
#
# Red on the pre-fix window: the removed row travelled as probability -1, which
# the writer turns into an unsigned entry count and rewrites at ~full weight.
# Red on the pre-fix writer too: a shrinking rewrite left the old tail in the
# file, so closing and re-opening the book brought the entry back.
#
# Round 2 adds the degenerate save: removing the *last* entry would truncate the
# file to zero bytes, which both scid_book_open paths read as "not a book", so
# the writer refuses it and the window's save reports the refusal instead of
# deleting the tempfile and refreshing as if the book had been written.

set fails 0
set checks 0
proc check {name cond {detail ""}} {
    global fails checks
    incr checks
    if {![uplevel 1 [list expr $cond]]} {
        incr fails
        if {$detail eq ""} { puts "FAIL $name" } else { puts "FAIL $name -- $detail" }
    } else { puts "ok   $name" }
}
proc checkEq {name got want} {
    global fails checks
    incr checks
    if {$got ne $want} {
        incr fails
        puts "FAIL $name -- got '$got' want '$want'"
    } else { puts "ok   $name" }
}
proc fileEntries {f} {
    file stat $f st
    return [expr {$st(size) / 16}]
}

set dir [file join /tmp bookplay[pid]]
file mkdir $dir
set book [file join $dir t.bin]
# polyglot_open refuses a zero-length file, so the fixture book starts with one
# dummy 16-byte entry; the position under test has no entry yet.
set fh [open $book wb]
puts -nonewline $fh [string repeat \x00 16]
close $fh
# sc_book load returns "" for a read-write book and 1 for a read-only one
checkEq "the fixture book opens read-write" [sc_book load $book 0] ""
set tmp [file join $dir tmp]

# The window loads the position before it can save: "sc_book moves" is what
# stores the key movesupdate writes, so call it in that order here as well.
sc_book moves 0

# seed one move, the way the window saves a fresh entry
sc_book movesupdate {e4} {100} 0 $tmp
set seeded [lindex [sc_book moves 0] 0]
check "the seeded move is in the book" {[string match {*e4*} $seeded]} "moves='$seeded'"

# the pre-fix payload: the removed row still in the lists, as -1
sc_book movesupdate {e4} {-1} 0 $tmp
set afterOld [lindex [sc_book moves 0] 0]
check "a -1 probability leaves the move in the book (the bug)" \
    {[string match {*e4*} $afterOld]} "moves='$afterOld'"

# the post-fix payload: the removed row is left out of both lists
sc_book movesupdate {} {} 0 $tmp
checkEq "an omitted move is gone from the book" [lindex [sc_book moves 0] 0] ""
checkEq "and the file lost its entry" [fileEntries $book] 1

# and it stays gone through a close and a re-open
sc_book close 0
checkEq "the book re-opens read-write" [sc_book load $book 0] ""
sc_book moves 0
checkEq "re-reading the saved book shows no move" [lindex [sc_book moves 0] 0] ""
sc_book close 0

# a move that was added back before saving is kept, not dropped with the rest
sc_book load $book 0
sc_book movesupdate {e4} {100} 0 $tmp
sc_book moves 0
sc_book movesupdate {e4 d4} {60 40} 0 $tmp
set both [lindex [sc_book moves 0] 0]
check "a restored move is saved beside another" \
    {[string match {*e4*} $both] && [string match {*d4*} $both]} "moves='$both'"
sc_book close 0
checkEq "and both entries are on disk" [fileEntries $book] 3

# ---------------------------------------------------------------------------
# Removing the last entry. The rewrite would leave a zero-length file, and both
# scid_book_open paths read that as "not a book" (BookSize == 0 -> -1), so a
# save that emptied the file would leave a book the app can never open again.
# The writer refuses it and the Tcl command raises instead of reporting success.
set one [file join $dir one.bin]
set fh [open $one wb]
puts -nonewline $fh [string repeat \x00 16]
close $fh
checkEq "the one-entry fixture book opens" [sc_book load $one 0] ""
sc_book moves 0
sc_book movesupdate {e4} {100} 0 $tmp
sc_book close 0
# keep the move's own entry alone: the book then holds exactly the entry the
# next save would remove
set fh [open $one rb]
set raw [read $fh]
close $fh
set fh [open $one wb]
puts -nonewline $fh [string range $raw 16 31]
close $fh
checkEq "the one-entry book re-opens" [sc_book load $one 0] ""
sc_book moves 0
# ::book::save writes its tempfile under ::scidUserDir; this harness runs the
# binary in script mode, where the profile variable is not initialised.
set ::scidUserDir $dir
set tmpSaved [file join $::scidUserDir tempfile.[pid]]
file delete -force $tmpSaved
set err [catch {sc_book movesupdate {} {} 0 $tmp} res]
checkEq "emptying the book is refused" $err 1
check "and the refusal says what happened" \
    {[string match {*at least one entry*} $res]} "res='$res'"
check "the book keeps its move" \
    {[string match {*e4*} [lindex [sc_book moves 0] 0]]}
checkEq "and the file still holds its entry" [fileEntries $one] 1
sc_book close 0
checkEq "the book still opens after the refused save" [sc_book load $one 0] ""
sc_book moves 0
check "with the move still in it" \
    {[string match {*e4*} [lindex [sc_book moves 0] 0]]}

# The window's save has to surface that refusal. It called movesupdate for its
# side effect, deleted the tempfile and refreshed as if the book had been
# written, so a refused save looked exactly like a successful one.
# A binary running a script never loads tcl/windows/book.tcl, so load it here:
# the refusal must reach the window, not only the sc_book command.
set root [file normalize [file join [file dirname [info script]] .. ..]]
if {[catch {source [file join $root tcl windows book.tcl]} bookErr]} {
    puts "note: tcl/windows/book.tcl did not load: $bookErr"
}
check "the book window's save is loaded" \
    {[llength [info commands ::book::save]] > 0}
if {[llength [info commands ::book::save]] > 0} {
    set ::book::bookTuningMoves {e4}
    set ::book::bookTuningSlot 0
    set ::book::isReadonly 0
    if {[winfo exists .bookTuningWin]} { destroy .bookTuningWin }
    toplevel .bookTuningWin
    frame .bookTuningWin.f
    pack .bookTuningWin.f
    ttk::spinbox .bookTuningWin.f.sp0 -from 0 -to 100 -width 3
    .bookTuningWin.f.sp0 set -1        ;# the row is removed
    # .bookWin exists so the success path would reach ::book::refresh, and the
    # spy records whether it did; a modal box would hang the harness.
    toplevel .bookWin
    set ::savedEvents {}
    proc tk_messageBox {args} { lappend ::savedEvents msgbox ; return ok }
    rename ::book::refresh ::book::refresh.harness
    proc ::book::refresh {} { lappend ::savedEvents refresh }
    file delete -force $tmpSaved
    ::book::save
    checkEq "a refused save reports itself to the user" \
        [llength [lsearch -all -exact $::savedEvents msgbox]] 1
    check "and the window is not refreshed as if saved" \
        [expr {[lsearch -exact $::savedEvents refresh] < 0}]
    check "and the tempfile is not deleted on failure" [file exists $tmpSaved]
    rename ::book::refresh {}
    rename ::book::refresh.harness ::book::refresh
    destroy .bookWin
    destroy .bookTuningWin
}
sc_book close 0

file delete -force $dir
puts "\n$checks checks, $fails failures"
exit [expr {$fails > 0}]
