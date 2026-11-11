#!/usr/bin/env wish
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# layout_windows.tcl -- a saved layout cannot bring an Analysis window back.
#
#   wish tests/tcl/layout_windows.tcl
#   xvfb-run -a wish tests/tcl/layout_windows.tcl
#
# ::docking::layout_restore hands every window it read from the saved layout to
# ::docking::create_window. That dispatch is the door this test closes: an old
# layout naming .analysisWin1 must draw nothing, while .engineWin still opens
# the Engine Window.

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
source [file join $root tcl utils win.tcl]

# The two ways the restore could recreate a window. The first is the removed
# path; the second proves the Engine Window arm still works.
set ::analysisMade 0
proc ::makeAnalysisWin {args} { incr ::analysisMade }
set ::engineOpened {}
namespace eval enginewin {}
proc ::enginewin::Open {args} { set ::engineOpened $args }

puts "\na saved Analysis window draws nothing"

::docking::create_window .analysisWin1
checkEq "the old window was not created" [winfo exists .analysisWin1] 0
checkEq "and makeAnalysisWin was not called" $::analysisMade 0

::docking::create_window .fdockanalysisWin2
checkEq "the docked spelling is inert too" [winfo exists .fdockanalysisWin2] 0
checkEq "and it did not call makeAnalysisWin either" $::analysisMade 0

puts "\na notebook is not left empty"

checkEq "an Analysis-only notebook leaves no windows" \
    [::docking::layoutRestorableWindows {.analysisWin1 .fdockanalysisWin2}] {}
checkEq "a mixed notebook keeps the rest" \
    [::docking::layoutRestorableWindows {.main .analysisWin1 .engineWin2}] \
    {.main .engineWin2}

# The saved paned window carries a sash position for every boundary. Dropping
# the Analysis notebook removes a pane, so its sash entry must go too or the
# restore applies a stale index to the rebuilt window.
set saved [list \
    [list .pw vertical {120}] \
    [list TNotebook .pw.tb1 {.main}] \
    [list TNotebook .pw.tb2 {.analysisWin1}]]
lassign [::docking::layoutPrune $saved] pruned panes
checkEq "one pane remains" $panes 1
checkEq "the dropped pane's sash is gone" [lindex [lindex $pruned 0] 2] {}
checkEq "the surviving notebook is kept" \
    [join [lindex $pruned 1] "|"] {TNotebook|.pw.tb1|.main}

set nested [list \
    [list .pw horizontal {80}] \
    [list TPanedwindow [list \
        [list .pw.n vertical {40}] \
        [list TNotebook .pw.n.tb {.analysisWin1}]]]]
lassign [::docking::layoutPrune $nested] pruned panes
checkEq "a nested container with no windows is dropped" $panes 0

puts "\nthe Engine Window arm still works"

::docking::create_window .engineWin3
checkEq "the saved Engine Window is opened" $::engineOpened 3

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
