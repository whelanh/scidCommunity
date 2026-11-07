# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# repetition_notice_tk.tcl -- the repetition banner is a notice, not a dialog.
#
#   wish tests/tcl/repetition_notice_tk.tcl
#
# The point of the change is that the reader keeps working: the banner must not
# take a grab or the focus, a second one must replace the first rather than
# stack, and it must schedule its own removal.

package require Tk

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

# start.tcl would provide this; the banner only needs it to paint itself.
proc ::applyThemeColor_background {w} {}

# Keep the root tiny and off to the side; the notice is transient to it, so it
# has to stay mapped for the notice to map too.
wm geometry . 1x1+-10000+-10000
update

proc noticeId {} {
    set ids [after info]
    foreach id $ids {
        if {[string match "*pgn::hideRepetitionNotice*" [after info $id]]} { return $id }
    }
    return ""
}

puts "\n== the notice is a notice, not a dialog =="
::pgn::showRepetitionNotice "2-fold repetition"
update
set w $::pgn::repNoticeWidget

check "the notice exists" [winfo exists $w]
check "the notice is mapped" [winfo ismapped $w]
check "the notice is a child of the window it belongs to" \
    [expr {[winfo parent $w] eq "."}]
checkEq "the notice carries the message" [$w.msg cget -text] "2-fold repetition"
checkEq "nothing has a grab" [grab current] ""
check "nothing took the focus" [expr {[focus] ne $w}]
check "a dismissal is scheduled" [expr {[noticeId] ne ""}]

puts "\n== a second notice replaces the first =="
set first [noticeId]
::pgn::showRepetitionNotice "Draw - 3 Fold Repetition"
update
set w2 $::pgn::repNoticeWidget
check "there is still one notice" [expr {[winfo exists $w2] && $w2 eq $w}]
checkEq "it shows the newer text" [$w2.msg cget -text] "Draw - 3 Fold Repetition"
check "the old dismissal was cancelled" [expr {[noticeId] ne $first}]

puts "\n== a click or the timer removes it =="
event generate $w.msg <Button-1>
update
check "a click on the text dismisses it" [expr {![winfo exists $w]}]
check "its dismissal was cancelled" [expr {[noticeId] eq ""}]

puts "\n$checks checks, $fails failures"
destroy .
exit [expr {$fails > 0}]
