#!/usr/bin/env wish
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# tactics_trainer.tcl -- the Tactics puzzle trainer survives the #437 §3a
# retirement of Review game and Calvar.
#
#   wish tests/tcl/tactics_trainer.tcl
#   xvfb-run -a wish tests/tcl/tactics_trainer.tcl     (no display)
#
# §3a deletes two entries from the Play / Training submenu. The third, Tactics,
# stays - and a menu entry is only "kept" if the module behind it still starts,
# loads a puzzle, referees an answer and stops. Nothing else in the tree runs
# that loop: the module is sourced at startup and its procs are only compiled
# when called, so a retired ::calvar:: or a stale ::analysis(multiPV) read
# would survive every harness in this directory and fail in the user's hands.
#
# The engine layer and the chess database are stubbed (this file owns neither),
# but the trainer's own loop is real: ::tactics::createWin builds the window,
# ::tactics::startAnalyze arms its timer, ::tactics::stopAnalyze reads the
# engine reply, and ::tactics::mainLoop is what decides solved, failed or
# "carry on". The preset is shaped like the ones the engine dialog builds
# (name, command, args, dir, ..., UCI flag at index 7, which is the field
# ::tactics::config filters on), so the trainer is started the way the menu
# starts it, by preset index.

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

# ------------------------------------------------------------------ harness state --
namespace eval fake {
    variable log {}          ;# one line per stubbed engine/core call
    variable cursor 0
    variable moves {}        ;# SAN of the line the fake game holds
    variable side white
    variable flipped 0
    variable comment ""
    variable tags {}
    variable saved {}
    variable previousMove ""
    variable nextGame 1
    variable box ""
    variable playMode ""
    variable flips {}
    variable filterReset 0
    variable analysisTime 1
}
proc fake::log {what} { lappend ::fake::log $what }
proc fake::count {pattern} {
    set n 0
    foreach e $::fake::log { if {[string match $pattern $e]} { incr n } }
    return $n
}

# ---------------------------------------------------------------- the strings --
# english.tcl is the catalogue: the harness reads the real labels, so a page or
# a menu key renamed by another change shows up here rather than as an error.
array set ::tr {}
proc translate {lang key args} {
    set ::tr($key) [lindex $args 0]
}
proc menuText {lang key text args} { set ::tr($key) $text }
source -encoding utf-8 [file join $root tcl lang english.tcl]
proc tr {tag args} {
    if {[info exists ::tr($tag)]} { return $::tr($tag) }
    if {[llength $args]} { return [lindex $args 0] }
    return $tag
}

# The trainer also reads $::tr(Key) directly, which bypasses the proc above and
# errors on a key the catalogue does not carry. The C translation layer falls
# back to the key's own name; fill the same default here for every key
# tactics.tcl actually reads, so a newly added label shows as a bare key in a
# check rather than as a startup error.
proc readText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation auto
    set text [read $f]
    close $f
    return $text
}
set tacticsSrc [readText [file join $root tcl tools tactics.tcl]]
foreach {all key} [regexp -all -inline {\$::tr\((\w+)\)} $tacticsSrc] {
    if {![info exists ::tr($key)]} { set ::tr($key) $key }
}

# ------------------------------------------------------------- the engine layer --
# ::uci:: is the engine layer this phase keeps (it dies in #437 §6, after §4).
# What the trainer owns is which commands it sends and what it does with the
# reply, so that is what is recorded.
namespace eval ::uci {
    proc resetUciInfo {slot} { fake::log "resetUciInfo $slot" }
    proc startEngine {idx slot} {
        fake::log "startEngine preset=$idx slot=$slot"
        set ::fake::enginePreset $idx
        return 0
    }
    proc sendToEngine {slot text} { fake::log "send $slot $text" }
    proc closeUCIengine {slot} {
        fake::log "closeUCIengine $slot"
        set ::fake::closed 1
    }
}
namespace eval ::analysis {}
set ::analysis(multiPV5) {}

# ----------------------------------------------------------------- the presets --
# The engine dialog builds these entries from the engine configuration; the
# trainer only ever sees the list. Field 7 is "is UCI", which ::tactics::config
# filters on, and field 3 is the working directory initEngine would cd into.
set ::engines(list) [list \
    [list "Stockfish" "/usr/games/stockfish" "" "/usr/share/stockfish" "" 0 0 1] \
    [list "Not-UCI" "/usr/games/xboard" "" "/usr/share/xboard" "" 0 0 0]]

# ------------------------------------------------------------ the chess database --
set ::curr_db 1
proc main_isFlipped {} { return $::fake::flipped }
proc sc_pos {sub args} {
    switch -- $sub {
        isAt {
            switch -- [lindex $args 0] {
                start { return [expr {$::fake::cursor == 0}] }
                end   { return [expr {$::fake::cursor >= [llength $::fake::moves]}] }
            }
        }
        side { return $::fake::side }
        fen {
            # The trainer compares FENs to notice a move it did not expect.
            return "fen-$::fake::cursor-$::fake::side"
        }
        getComment { return $::fake::comment }
        previousMove - previousMoveNT { return $::fake::previousMove }
    }
    return ""
}
proc sc_move {sub args} {
    switch -- $sub {
        forward { incr ::fake::cursor }
        back {
            incr ::fake::cursor -1
            if {$::fake::cursor < 0} { set ::fake::cursor 0 }
            set ::fake::previousMove ""
            fake::log "move back"
        }
        addSan {
            lappend ::fake::moves [lindex $args 0]
            set ::fake::cursor [llength $::fake::moves]
            fake::log "addSan [lindex $args 0]"
        }
    }
    return 1
}
proc sc_var {args} { return "" }
proc sc_game {sub args} {
    switch -- $sub {
        info {
            switch -- [lindex $args 0] {
                previousMove   { return $::fake::previousMove }
                previousMoveNT { return $::fake::previousMove }
                number         { return 1 }
            }
        }
        tags {
            # tags set -site <text>
            set ::fake::tags [lindex $args 2]
            fake::log "tags site=[lindex $args 2]"
        }
        save { lappend ::fake::saved [lindex $args 0] ; fake::log "save" }
        load { fake::log "load [lindex $args 0]" }
    }
    return 1
}
proc sc_filter {sub args} {
    switch -- $sub {
        search { fake::log "filter search" }
        next   { set n $::fake::nextGame ; set ::fake::nextGame 0 ; return $n }
        reset  { set ::fake::filterReset 1 ; fake::log "filter reset" }
    }
    return 0
}
proc sc_base {sub args} { return 1 }
namespace eval ::notify {}
proc ::notify::GameChanged {args} {}
proc ::notify::filter {args} {}
namespace eval ::board {}
proc ::board::flipAuto {w args} {
    # The trainer flips the board so the player is at the bottom; that flag is
    # what ::tactics::isPlayerTurn reads through main_isFlipped.
    set ::fake::flipped [expr {[string is true -strict [lindex $args 0]]}]
    lappend ::fake::flips auto
    fake::log "flipAuto $args"
}
proc ::board::flip {w} {
    set ::fake::flipped [expr {!$::fake::flipped}]
    lappend ::fake::flips flip
}
namespace eval ::gameclock {}
proc ::gameclock::new {args} {}
proc ::gameclock::reset {n} {}
proc ::gameclock::start {n} {}
proc ::gameclock::stop {n} {}
namespace eval ::file {}
proc ::file::OpenOrSwitch {fname} { fake::log "openBase $fname" ; return 0 }
proc ::setPlayMode {mode} { set ::fake::playMode $mode ; fake::log "playMode '$mode'" }
proc progressWindow {args} {}
proc closeProgressWindow {} {}
proc updateBoard {args} {}
proc updateStatusBar {} {}
proc updateTitle {} {}
proc helpWindow {args} {}
proc tk_messageBox {args} {
    set i [lsearch $args -message]
    if {$i >= 0} { set ::fake::box [lindex $args [expr {$i + 1}]] }
    fake::log "messageBox $::fake::box"
    return ok
}
proc createToplevel {w args} {
    # The docking container is not built here; the trainer only needs a real
    # window whose Destroy binding fires ::tactics::endTraining.
    if {![winfo exists $w]} { toplevel $w }
    fake::log "createToplevel $w"
}
proc setTitle {w title} { wm title $w $title }
proc createToplevelFinalize {w} {}

# ------------------------------------------------------------------- the module --
source -encoding utf-8 [file join $root tcl tools tactics.tcl]

# The main window the trainer takes focus back to, and the analysis time it
# arms its timer with.
frame .main
set ::tactics::analysisTime 1

# A helper: run the event loop for a while so after-timers can fire.
proc pump {ms} {
    set ::pump_done 0
    after $ms { set ::pump_done 1 }
    vwait ::pump_done
}

puts "\nstart (::tactics::createWin, preset 0)"
set ::fake::moves {}
set ::fake::cursor 0
set ::fake::side white
::tactics::createWin 1 0
check "the trainer window exists" [winfo exists .tacticsWin]
check "the UCI preset was the one started" \
    [expr {$::fake::enginePreset == 0}]
check "the engine was started on the trainer's own slot" \
    [expr {[fake::count "startEngine preset=0 slot=5"] == 1}]
check "the game was searched for unsolved puzzles" \
    [expr {[fake::count "filter search"] == 1}]
check "the play mode is the trainer's callback" \
    [expr {$::fake::playMode eq "::tactics::callback"}]
check "analysis was requested on the puzzle position" \
    [expr {[fake::count "send 5 position fen *"] == 1}]
check "a go infinite followed it" \
    [expr {[fake::count "send 5 go infinite"] == 1}]
checkEq "the trainer clock label is the loading text" \
    $::tactics::infoEngineLabel "[::tr Thinking] ..."
check "the analysis timer is armed (analyse mode on)" \
    [expr {$::tactics::analysisEngine(analyzeMode) == 1}]

puts "\ntimer expiry (::tactics::startAnalyze -> stopAnalyze)"
set ::analysis(multiPV5) [list [list 0 35 "1. Qh5 Nf6 2. Qxf7#"]]
pump 1400
check "the analysis timer expired and stopped the engine" \
    [expr {$::tactics::analysisEngine(analyzeMode) == 0}]
check "the score of the engine's line was taken from the reply" \
    [expr {$::tactics::analysisEngine(score) == 35}]
checkEq "the line was taken from the reply" \
    $::tactics::analysisEngine(moves) "1. Qh5 Nf6 2. Qxf7#"
checkEq "the timer expiry is shown to the user" \
    $::tactics::infoEngineLabel $::tr(AnalyzeDone)
checkEq "one puzzle is on the board" $::tactics::prevFen "fen-0-white"

puts "\nright answer (::tactics::mainLoop -> solved)"
# The player played what the engine expected: prevLine's reply move.
set ::tactics::prevLine "1. Qh5 Nf6 2. Qxf7"
set ::tactics::prevScore 35
set ::fake::previousMove "Nf6"
set ::fake::side black
set ::fake::moves {Nf6}
set ::fake::cursor 1
set ::fake::tags ""
set ::fake::box ""
set ::analysis(multiPV5) [list [list 0 900 "1... Nf6 2. Qxf7"]]
# The reply to the player's move is what the referee compares against.
set ::tactics::analysisEngine(moves) "1. Qh5 Nf6 2. Qxf7"
set ::tactics::analysisEngine(score) 35
set ::tactics::solved "problem solved"
set ::tactics::failed "problem failed"
::tactics::mainLoop
pump 1400
catch { after cancel ::tactics::mainLoop }
checkEq "the puzzle is marked solved" $::fake::tags $::tactics::solved
check "the solved game was saved" [expr {[llength $::fake::saved] >= 1}]
check "the engine's next move was played on the board" \
    [expr {[fake::count "addSan *"] >= 1}]
checkEq "no complaint was shown" $::fake::box ""

puts "\nwrong answer (::tactics::mainLoop -> failed)"
set ::fake::tags ""
set ::fake::box ""
set ::fake::saved {}
set ::tactics::prevLine "1. Qh5 Nf6 2. Qxf7#"
set ::tactics::prevScore 35
set ::fake::previousMove "a3"
set ::fake::side black
set ::fake::moves {a3}
set ::fake::cursor 1
set ::analysis(multiPV5) [list [list 0 900 "1... Nf6 2. Qxf7#"]]
set ::tactics::analysisEngine(moves) "1. Qh5 Nf6 2. Qxf7#"
set ::tactics::analysisEngine(score) 35
::tactics::mainLoop
pump 1400
catch { after cancel ::tactics::mainLoop }
checkEq "the puzzle is marked failed" $::fake::tags $::tactics::failed
check "the missed line was reported to the user" \
    [expr {[string first $::tr(BestSolutionNotFound) $::fake::box] >= 0}]
check "the bad move was taken back" [expr {[fake::count "move back"] >= 1}]
check "the failed game was not saved" [expr {[llength $::fake::saved] == 0}]

puts "\nstop (destroy the window)"
set ::fake::closed 0
destroy .tacticsWin
pump 200
check "the window is gone" [expr {![winfo exists .tacticsWin]}]
check "the engine was closed" [expr {$::fake::closed == 1}]
checkEq "the play mode was released" $::fake::playMode ""
check "the database filter was reset" [expr {$::fake::filterReset == 1}]

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
