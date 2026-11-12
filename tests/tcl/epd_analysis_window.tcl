#!/usr/bin/env tclsh
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# epd_analysis_window.tcl -- Analyze Positions shows its analysis again.
#
#   tclsh tests/tcl/epd_analysis_window.tcl
#
# The pass used to open an Analysis window by itself, so the search was
# visible as soon as Analyze Positions started. It runs headless now, and this
# check holds the replacement: an Engine Window on the pass's preset is raised
# (or opened), while the pass keeps its own connection and keeps working if the
# window is closed. No engine process and no Tk are involved.

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

# The application's surface, as much of it as the pass touches.
proc tr {tag args} { return $tag }
proc sc_info {args} { return 4 }
proc update {args} {}
proc winfo {sub args} { return 1 }
proc sc_epd {sub args} {
    if {$sub eq "size"} { return 0 }
    return ""
}
proc tk_messageBox {args} { return ok }

namespace eval ::epdanalysis {}
set ::opened {}
set ::closed 0
proc ::epdanalysis::open {name} { lappend ::opened $name ; return "" }
proc ::epdanalysis::close {} { incr ::closed }

# The engine windows: ids, their preset, and only the two states the choice
# looks at.
namespace eval ::enginewin {}
array set ::enginewin::engState {}
array set ::enginewin::pgnviewer {}
array set ::enginewin_lastengine {}
array set ::enginewin::locked {}
array set ::enginewin::paused {}
set ::starts {}
set ::visible {}
proc ::enginewin::start {id name} {
    lappend ::starts [list $id $name]
    if {$id eq ""} {
        set id [expr {[llength $::starts] + 10}]
        set ::enginewin::engState($id) follow.run
        set ::enginewin_lastengine($id) $name
    }
    return $id
}
proc ::enginewin::stateLocked {id} {
    return [expr {[info exists ::enginewin::locked($id)] && $::enginewin::locked($id)}]
}
proc ::enginewin::statePaused {id} {
    return [expr {[info exists ::enginewin::paused($id)] && $::enginewin::paused($id)}]
}
namespace eval ::win {}
proc ::win::makeVisible {w} { lappend ::visible $w }

source [file join $root tcl file epd.tcl]

proc reset {} {
    array unset ::enginewin::engState
    array unset ::enginewin::pgnviewer
    array unset ::enginewin_lastengine
    array unset ::enginewin::locked
    array unset ::enginewin::paused
    array set ::enginewin::engState {}
    array set ::enginewin::pgnviewer {}
    array set ::enginewin_lastengine {}
    array set ::enginewin::locked {}
    array set ::enginewin::paused {}
    set ::starts {}
    set ::visible {}
    set ::opened {}
    set ::closed 0
}

puts "\nno engine window: one is opened on the pass's preset"

reset
checkEq "a window is opened and returned" \
    [::epd::showAnalysisWindow Stockfish] 11
checkEq "with the preset the pass is using" [lindex $::starts 0 1] Stockfish
checkEq "in a free slot" [lindex $::starts 0 0] ""
checkEq "and it is brought to the front" $::visible .engineWin11

puts "\na window already on that preset is reused, not duplicated"

reset
set ::enginewin::engState(1) follow.run
set ::enginewin_lastengine(1) Stockfish
checkEq "the existing window is returned" [::epd::showAnalysisWindow Stockfish] 1
checkEq "nothing new is started" $::starts {}
checkEq "it is raised" $::visible .engineWin1

puts "\na paused window is started again"

reset
set ::enginewin::engState(2) paused.idle
set ::enginewin_lastengine(2) Stockfish
set ::enginewin::paused(2) 1
checkEq "the paused window is returned" [::epd::showAnalysisWindow Stockfish] 2
checkEq "and the pass starts it" [lindex $::starts 0 0] 2
checkEq "on the same preset" [lindex $::starts 0 1] Stockfish
checkEq "it is raised" $::visible .engineWin2

puts "\na window on another preset, a locked one or a viewer is left alone"

reset
set ::enginewin::engState(1) follow.run
set ::enginewin_lastengine(1) Komodo
set ::enginewin::engState(2) locked.run
set ::enginewin_lastengine(2) Stockfish
set ::enginewin::locked(2) 1
set ::enginewin::engState(3) follow.run
set ::enginewin_lastengine(3) Stockfish
set ::enginewin::pgnviewer(3) 9
checkEq "a new window opens on the pass's preset" \
    [::epd::showAnalysisWindow Stockfish] 11
checkEq "the other preset was not started" \
    [lsearch -exact $::starts {1 Stockfish}] -1
checkEq "the locked window was not started" \
    [lsearch -exact $::starts {2 Stockfish}] -1
checkEq "the embedded viewer was not started" \
    [lsearch -exact $::starts {3 Stockfish}] -1
checkEq "exactly one window was opened" [llength $::starts] 1

puts "\nAnalyze Positions starts the visible analysis itself"

reset
proc .epd1.bottom.status {sub args} {}
proc .epd1.bottom.stop {sub args} {}
set ::epdAnnotateMode 1
::epd::launchAnnotateEpd 1 0 Stockfish
checkEq "the pass opened its own engine" $::opened Stockfish
checkEq "the live window uses the same preset" [lindex $::starts 0 1] Stockfish
checkEq "and the pass closed its engine" $::closed 1

puts "\nwithout the engine window layer the pass still runs"

reset
rename ::enginewin::start ""
::epd::launchAnnotateEpd 1 0 Stockfish
checkEq "the headless pass still opened its engine" $::opened Stockfish
checkEq "and closed it" $::closed 1

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
