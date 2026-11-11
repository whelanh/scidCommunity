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

puts "\nthe Engine Window arm still works"

::docking::create_window .engineWin3
checkEq "the saved Engine Window is opened" $::engineOpened 3

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
