# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# repetition_integration.tcl -- the real counter and the real notice, together.
#
#   xvfb-run -a ./scidCommunity tests/tcl/repetition_integration.tcl
#
# The tclsh harness stubs getRepetitionCount, and the wish harness stubs the
# counter again. This one builds a real threefold repetition with the binary's
# own sc_game and then runs the presentation over it, so the count that decides
# a finished game is the count the notice is shown for.

set fails 0
set checks 0
proc check {label cond {detail ""}} {
    incr ::checks
    if {$cond} {
        puts "  ok   $label"
    } else {
        incr ::fails
        if {$detail eq ""} { puts "  FAIL $label" } else { puts "  FAIL $label -- $detail" }
    }
}
proc checkEq {label got want} {
    check $label [expr {$got eq $want}] "got '$got' want '$want'"
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl windows pgn.tcl]
proc tr {tag args} { return "T:$tag" }
proc ::applyThemeColor_background {w} {}

proc noticeExists {} {
    expr {[winfo exists .repetitionNotice] ||
          [winfo exists .pgnWin.repetitionNotice]}
}

# 1.Nf3 Nf6 2.Ng1 Ng8 returns to the start position, then the same again:
# the start position has now occurred three times.
sc_game new
foreach san {Nf3 Nf6 Ng1 Ng8 Nf3 Nf6 Ng1 Ng8} { sc_move addSan $san }
update

puts "\n== the real counter finds the repetition =="
set count [::pgn::getRepetitionCount]
check "the start position occurs three times" [expr {$count == 3}] $count
checkEq "the threefold text is chosen" [::pgn::repetitionMessage $count] \
    T:RepetitionThreefold

puts "\n== off returns the count and builds nothing =="
set ::pgn::repetitionAlert off
checkEq "CheckRepetition returns the count" [::pgn::CheckRepetition] 3
check "no notice exists" [expr {![noticeExists]}]

puts "\n== the banner is an in-window notice =="
set ::pgn::repetitionAlert banner
checkEq "CheckRepetition returns the count" [::pgn::CheckRepetition] 3
set w $::pgn::repNoticeWidget
check "the notice exists" [winfo exists $w]
check "it is a child of an application window" \
    [expr {[winfo parent $w] eq "." || [winfo parent $w] eq ".pgnWin"}]
check "nothing has a grab" [expr {[grab current] eq ""}]
checkEq "it carries the threefold text" [$w.msg cget -text] T:RepetitionThreefold
::pgn::hideRepetitionNotice
check "it can be dismissed" [expr {![winfo exists $w]}]

puts "\n== the notice is tied to the position it describes =="
::pgn::CheckRepetition
set w $::pgn::repNoticeWidget
::pgn::hideStaleRepetitionNotice
check "a refresh at the same position keeps it" [winfo exists $w]
sc_move back
::pgn::hideStaleRepetitionNotice
check "moving away dismisses it" [expr {![winfo exists $w]}]
sc_move end
update

puts "\n== dialog mode uses the message box =="
rename tk_messageBox ::repetitionTestMessageBox
proc tk_messageBox {args} { set ::testDialog $args; return ok }
set ::pgn::repetitionAlert dialog
checkEq "CheckRepetition returns the count" [::pgn::CheckRepetition] 3
check "the message box was called" [info exists ::testDialog]
checkEq "with the threefold text" \
    [lindex $::testDialog [expr {[lsearch $::testDialog -message] + 1}]] \
    T:RepetitionThreefold
check "no banner was built" [expr {![noticeExists]}]
rename tk_messageBox {}
rename ::repetitionTestMessageBox tk_messageBox
unset ::testDialog

puts "\n== a single occurrence says nothing =="
sc_game new
foreach san {Nf3 Nf6 Ng1 Ng8} { sc_move addSan $san }
update
set ::pgn::repetitionAlert banner
checkEq "the start has occurred twice" [::pgn::getRepetitionCount] 2
checkEq "the second occurrence has its own text" [::pgn::repetitionMessage 2] \
    T:RepetitionTwice

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
