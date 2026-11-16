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

file delete -force $dir
puts "\n$checks checks, $fails failures"
exit [expr {$fails > 0}]
