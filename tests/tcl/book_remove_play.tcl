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

# ---------------------------------------------------------------------------
# Two slots on one file. The Book window and the Book tuning window are separate
# slots on the same book, each with its own stream and its own entry count: a
# rewrite that only fixed up the editing slot left the reader holding a count
# the file no longer has, and its bounded loops then walked past EOF -- a
# garbage entry, or an abort inside the reader. Every slot on the rewritten
# file has to end up on the new file.
sc_book close 0
set two [file join $dir two.bin]
set fh [open $two wb]
puts -nonewline $fh [string repeat \x00 16]
close $fh
checkEq "the two-slot book opens read-write" [sc_book load $two 0] ""
sc_book moves 0
sc_book movesupdate {e4 d4} {60 40} 0 $tmp
checkEq "it holds both moves" [fileEntries $two] 3
checkEq "the same book opens in a second slot" [sc_book load $two 3] ""
lassign [sc_book moves 3] fromReader
check "the second slot reads both moves" \
    {[string match {*e4*} $fromReader] && [string match {*d4*} $fromReader]} \
    "moves='$fromReader'"
sc_book moves 0
sc_book movesupdate {e4} {100} 0 $tmp
checkEq "the rewrite left one entry per surviving move" [fileEntries $two] 2
lassign [sc_book moves 3] afterRewrite
check "the second slot sees the surviving move" \
    {[string match {*e4*} $afterRewrite]} "moves='$afterRewrite'"
check "and not the one that was removed" \
    {![string match {*d4*} $afterRewrite]} "moves='$afterRewrite'"
sc_book close 3
sc_book close 0

# ---------------------------------------------------------------------------
# A rewrite that cannot be completed leaves the book exactly as it was. The
# writer used to copy the surviving entries into the live file and only then cut
# the tail off: a failure after that copy left the new entries followed by the
# old tail, and the next open read the removed entry again. Here the book's
# directory cannot take the replacement, so the save has to fail -- and the
# original has to survive it byte for byte, still readable.
set roDir [file join $dir ro]
file mkdir $roDir
set roBook [file join $roDir rob.bin]
set fh [open $roBook wb]
puts -nonewline $fh [string repeat \x00 16]
close $fh
checkEq "the book in its own directory opens" [sc_book load $roBook 0] ""
sc_book moves 0
sc_book movesupdate {e4 d4} {60 40} 0 $tmp
sc_book close 0
set fh [open $roBook rb]
set beforeRaw [read $fh]
close $fh
checkEq "the fixture holds three entries" [expr {[string length $beforeRaw] / 16}] 3
checkEq "it re-opens for the failing save" [sc_book load $roBook 0] ""
sc_book moves 0
set roTmp [file join $dir rotmp]
file delete -force $roTmp
exec chmod 555 $roDir
set err [catch {sc_book movesupdate {e4} {100} 0 $roTmp} res]
exec chmod 755 $roDir
checkEq "a rewrite that cannot be completed is refused" $err 1
set fh [open $roBook rb]
set afterRaw [read $fh]
close $fh
check "the original is byte for byte what it was" {[string equal $beforeRaw $afterRaw]}
check "the slot still reads the book it was reopened on" \
    {[string match {*e4*} [lindex [sc_book moves 0] 0]]}
sc_book close 0

# the window block below drives slot 0 on the one-entry book
checkEq "the one-entry book is back in slot 0" [sc_book load $one 0] ""
sc_book moves 0

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
    # the caller's staging file is there before the save: a refused save must
    # leave it alone, not delete it the way a successful one does
    file delete -force $tmpSaved
    set fh [open $tmpSaved w]
    close $fh
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
