#!/usr/bin/env tclsh
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# epd_analysis_window.tcl -- Analyze Positions drives the Engine Window.
#
#   tclsh tests/tcl/epd_analysis_window.tcl
#
# The pass has no engine of its own any more. It loads each position on the
# board, ::enginewin::onPosChanged hands it to the window, and the pass reads
# the window's answer back through ::enginewin::watch. This check holds that
# contract with a stubbed window: no engine process and no Tk are involved.

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
proc tk_messageBox {args} { return ok }
set ::status ""
set ::stopState ""
set ::WIN [dict create .epd1 1 .engineWin1 1]
proc winfo {sub args} {
    if {$sub eq "exists"} {
        return [expr {[dict exists $::WIN [lindex $args 0]]}]
    }
    return 1
}

# Widgets the pass steps on, as plain commands with Tk's paths for names.
proc .epd1.lb {sub args} {
    if {$sub eq "selection"} {
        set ::sel [lindex $args 1]
        return
    }
    if {$sub eq "curselection"} { return $::sel }
    return
}
proc .epd1.text {sub args} {
    if {$sub eq "edit"} { return 0 }
    return
}
proc .epd1.bottom.status {sub args} {
    if {$sub eq "configure"} { set ::status $args }
    return
}
proc .epd1.bottom.stop {sub args} {
    if {$sub eq "configure"} { set ::stopState $args }
    return
}

# The EPD file: two positions, each with its bm and the move the window will
# answer for it.
set ::posList {
    {{6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1} Qc7 Qc7}
    {{4k3/8/8/8/8/8/8/4K2R b - - 0 1} Kd8 a1a8}
}
set ::loadedIdx 0
set ::sel 0
set ::loaded {}
set ::sent {}
set ::watched {}
set ::unwatched {}
set ::answers right                                          ;# right|none|wrong
proc sc_epd {sub args} {
    switch -- $sub {
        size { return [llength $::posList] }
        name { return epd-test.epd }
        load {
            set ::loadedIdx [lindex $args 1]
            lappend ::loaded $::loadedIdx
            return
        }
        get {
            return "bm [lindex [lindex $::posList $::loadedIdx] 1]"
        }
        strip { return 0 }
    }
    return ""
}
proc sc_game {sub args} {
    if {$sub eq "UCI_currentPos"} { return "position fen [sc_pos fen]" }
    return ""
}
proc sc_pos {sub args} {
    if {$sub eq "fen"} { return [lindex [lindex $::posList $::loadedIdx] 0] }
    if {$sub eq "coordToSAN"} { return [lindex $args 1] }
    return ""
}
proc sc_base {args} { return 0 }
namespace eval ::board {}
proc ::board::flip {args} { return }

# ::notify::PosChanged is what hands the position to the window; the stub window
# answers on the next event-loop turn, exactly where the engine's InfoPV lands.
proc updateBoard {args} { after 0 [list ::test::answer $::loadedIdx] }
namespace eval ::test {}
proc ::test::answer {idx} {
    lassign [lindex $::posList $idx] fen bm engineMove
    set win 1
    set pos "position fen $fen"
    set "::enginewin::pv_(pos,$win)" $pos
    if {$::answers eq "none"} { return }
    if {$::answers eq "wrong"} { set engineMove a1a8 }
    ::epd::watchEngine $win InfoGo [list $pos {}]
    ::epd::watchEngine $win InfoPV \
        [list 1 20 22 1000 500 0 0 120 30 cp 0 $engineMove]
    ::epd::watchEngine $win InfoBestMove [list $engineMove]
}

namespace eval ::enginewin {}
array set ::enginewin::engState {}
array set ::enginewin::pgnviewer {}
array set ::enginewin_lastengine {}
array set ::enginewin::locked {}
array set ::enginewin::paused {}
array set ::enginewin::pv_ {}
array set ::enginewin::depth {}
array set ::enginewin::movetime {}
set ::follow 1
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
proc ::enginewin::stateFollow {id} { return $::follow }
proc ::enginewin::watch {id script} {
    set ::enginewin::watch_($id) $script
    set ::watched [list $id $script]
    return
}
proc ::enginewin::unwatch {id} {
    unset -nocomplain ::enginewin::watch_($id)
    lappend ::unwatched $id
    return
}
proc ::enginewin::autorunOff {id} {
    lappend ::autorun [list off $id]
    return
}
proc ::enginewin::autorunRestore {id} {
    lappend ::autorun [list restore $id]
    return
}
proc ::enginewin::holdLimits {id limits} {
    lappend ::limits [list hold $id $limits]
    set saved [list $::enginewin::depth($id) $::enginewin::movetime($id)]
    set ::enginewin::depth($id) [dict get $limits depth]
    set ::enginewin::movetime($id) [dict get $limits movetime]
    return $saved
}
proc ::enginewin::releaseLimits {id saved} {
    lappend ::limits [list release $id $saved]
    if {![llength $saved]} { return }
    set ::enginewin::depth($id) [lindex $saved 0]
    set ::enginewin::movetime($id) [lindex $saved 1]
    return
}
namespace eval ::engine {}
proc ::engine::send {id msg {data ""}} {
    lappend ::sent [list $id $msg $data]
    return
}
namespace eval ::win {}
proc ::win::makeVisible {w} { lappend ::visible $w }

source [file join $root tcl tools epd_analysis.tcl]
source [file join $root tcl file epd.tcl]

set ::logPath [file join \
    [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] \
    "epd-driving-[pid].log"]

proc reset {} {
    array unset ::enginewin::engState
    array unset ::enginewin::pgnviewer
    array unset ::enginewin_lastengine
    array unset ::enginewin::locked
    array unset ::enginewin::paused
    array unset ::enginewin::pv_
    array unset ::enginewin::depth
    array unset ::enginewin::movetime
    array set ::enginewin::engState {}
    array set ::enginewin::pgnviewer {}
    array set ::enginewin_lastengine {}
    array set ::enginewin::locked {}
    array set ::enginewin::paused {}
    array set ::enginewin::pv_ {}
    array set ::enginewin::depth {}
    array set ::enginewin::movetime {}
    set ::starts {}
    set ::visible {}
    set ::watched {}
    set ::unwatched {}
    set ::sent {}
    set ::loaded {}
    set ::loadedIdx 0
    set ::sel 0
    set ::status ""
    set ::stopState ""
    set ::answers right
    set ::follow 1
    set ::WIN [dict create .epd1 1 .engineWin1 1]
    set ::epdAnnotateMode 1
    set ::epdAnnotation 0
    set ::epdDelay 0.05
    set ::epd::analysisRunning 0
    set ::epd::analysisOwner ""
    set ::epd::analysisStopRequested 0
    set ::epd::drive {}
    set ::autorun {}
    set ::limits {}
    set ::epd::driveDone 0
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
checkEq "and started" [lindex $::starts 0] {2 Stockfish}

puts "\na locked window is left alone: a new one is opened"

reset
set ::enginewin::engState(3) locked.run
set ::enginewin_lastengine(3) Stockfish
set ::enginewin::locked(3) 1
checkEq "a new window is opened" [::epd::showAnalysisWindow Stockfish] 11

puts "\nthe pass drives that window, position by position"

reset
set ::enginewin::engState(1) follow.run
set ::enginewin_lastengine(1) TestEngine
# The reader's usual limits: the pass must not use them, and must give them back.
set ::enginewin::depth(1) 20
set ::enginewin::movetime(1) 2000
::epd::launchAnnotateEpd 1 0 TestEngine $::logPath

checkEq "both positions were loaded, in order" $::loaded {0 1}
checkEq "the window was watched" [lindex $::watched 0] 1
checkEq "with the pass's own reader" [lindex $::watched 1] ::epd::watchEngine
checkEq "and released at the end" $::unwatched {1}
checkEq "the run is over" $::epd::analysisRunning 0
checkEq "the engine was never stopped mid-pass" \
    [lsearch -exact [lmap m $::sent {lindex $m 1}] StopGo] -1
checkEq "Autoscan is off for the run and put back" \
    $::autorun {{off 1} {restore 1}}
checkEq "the window's limits are borrowed for the budget" \
    [lindex $::limits 0] {hold 1 {depth {} movetime 50}}
checkEq "and given back exactly" \
    [lindex $::limits end] {release 1 {20 2000}}
checkEq "the usual depth is back" $::enginewin::depth(1) 20
checkEq "the usual time limit is back" $::enginewin::movetime(1) 2000
check "the status names the window and the tally" \
    [string match {*Best moves found 1 / 2*} $::status] $::status
check "the summary says which window searched" \
    [string match {*Engine Window 1*} $::status] $::status
checkEq "the Stop button is disabled again" \
    [string match {*-state disabled*} $::stopState] 1

set fh [open $::logPath r]
set log [read $fh]
close $fh
file delete $::logPath
check "the header names the window whose search is recorded" \
    [string match {*Window:   Engine Window 1 (the search this report records)*} $log] $log
check "the header states the search's limits" \
    [string match {*Limits:   movetime 50 ms*} $log] $log
check "the header states the budget per position" \
    [string match {*Time/pos: 0.05 s per position*} $log] $log
check "the matching position is TRUE" [string match {*Qc7*TRUE*} $log] $log
check "the other is FALSE" [string match {*a1a8*FALSE*} $log] $log
checkEq "two answer rows" [regexp -all -line {^\d+\s+\S+\s+\S+\s+(TRUE|FALSE)} $log] 2

puts "\nno timers are left behind"

checkEq "the deadline and the watchdog are cancelled" [after info] {}

puts "\na stopped engine window ends the pass instead of waiting"

reset
set ::enginewin::engState(1) follow.run
set ::enginewin_lastengine(1) TestEngine
set ::follow 0
::epd::launchAnnotateEpd 1 0 TestEngine
checkEq "no position was loaded" $::loaded {}
check "the status says it stopped" [string match *EpdAnalysisStopped* $::status] $::status
checkEq "the run is over" $::epd::analysisRunning 0

puts "\nthe seconds are a cap: the pass stops the window's search"

reset
set ::epd::drive [dict create win 1 pos p fen f sought "" token t1 solveMs "" \
    start 0 stopRequested 0 \
    data [::epdanalysis::emptyData f] deadline "" watchdog ""]
set ::epd::driveDone 0
::epd::cutoffDrive 1 t1
checkEq "StopGo goes to the window" [lindex $::sent end 1] StopGo
checkEq "the search is not finished yet" $::epd::driveDone 0
::epd::finishDrive ""
checkEq "the answer wakes the pass" $::epd::driveDone 1

set ::epd::drive [dict create win 1 pos p fen f sought "" token t2 solveMs "" \
    start 0 stopRequested 0 \
    data [::epdanalysis::emptyData f] deadline "" watchdog ""]
set ::epd::driveDone 0
set ::sent {}
::epd::cutoffDrive 1 stale-token
checkEq "a stale deadline does nothing" $::sent {}

reset
set ::epd::drive [dict create win 1 pos p fen f sought "" token t3 solveMs "" \
    start 0 stopRequested 0 \
    data [::epdanalysis::emptyData f] deadline "" watchdog ""]
dict unset ::WIN .engineWin1
::epd::cutoffDrive 1 t3
checkEq "a window that is gone ends the position as closed" \
    [dict get $::epd::drive data error] closed

puts "\nthe window closing ends the position at once"

reset
set ::epd::drive [dict create win 1 pos p fen f sought "" token t4 solveMs "" \
    start 0 stopRequested 0 \
    data [::epdanalysis::emptyData f] deadline "" watchdog ""]
set ::epd::driveDone 0
::epd::watchEngine 1 InfoWindowClosed {}
checkEq "the pass is woken" $::epd::driveDone 1
checkEq "as closed, not as a failed search" \
    [dict get $::epd::drive data error] closed

puts "\nthe engine's answer ends the position"

reset
set ::epd::drive [dict create win 1 pos p fen f sought "" token t5 solveMs "" \
    start 0 stopRequested 0 \
    data [::epdanalysis::emptyData f] deadline "" watchdog ""]
set ::epd::driveDone 0
::epd::watchEngine 1 InfoGo [list p {}]
::epd::watchEngine 1 InfoBestMove [list Qc7]
checkEq "the answer ends it at once" $::epd::driveDone 1
checkEq "with the move" [dict get $::epd::drive data best_san] Qc7
checkEq "and no search was stopped" $::sent {}

puts "\na search that ignores the budget is stopped after a grace"

reset
set ::epd::drive [dict create win 1 pos p fen f sought "" token t6 solveMs "" \
    start 0 stopRequested 0 \
    data [::epdanalysis::emptyData f] deadline "" watchdog ""]
set ::epd::driveDone 0
# The loop arms this from the request time; arm the same stop here.
dict set ::epd::drive deadline [after 10 [list ::epd::cutoffDrive 1 t6]]
after 700 [list set ::waited 1]
vwait ::waited
checkEq "the safety stop goes to the window" [lindex $::sent end 1] StopGo
checkEq "and waits for its acknowledgement" $::epd::driveDone 0
# ::enginecomm suppresses the stopped search's bestmove and reports the stop as
# InfoReady; that is the answer the pass must accept, not only InfoBestMove.
::epd::watchEngine 1 InfoReady {}
checkEq "the stop's acknowledgement ends the position" $::epd::driveDone 1

puts "\nInfoReady without a requested stop is not an answer"

reset
set ::epd::drive [dict create win 1 pos p fen f sought "" token t7 solveMs "" \
    start 0 stopRequested 0 \
    data [::epdanalysis::emptyData f] deadline "" watchdog ""]
set ::epd::driveDone 0
::epd::watchEngine 1 InfoReady {}
checkEq "the handshake's InfoReady is ignored" $::epd::driveDone 0

puts "\n"
puts "$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
