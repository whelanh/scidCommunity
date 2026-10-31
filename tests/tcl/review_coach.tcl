# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_coach.tcl -- the coach's facts, without a model.
#
#   tclsh tests/tcl/review_coach.tcl
#
# Every line the coach is allowed to say comes from these functions, so they are
# checked on their own: no model, no network, no board. A prompt built on the
# wrong facts is worse than no prompt, because the reader cannot tell.

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
set ::scidTclDir [file join $root tcl]
source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools comment_facts.tcl]
source [file join $root tcl tools review_report.tcl]
source [file join $root tcl tools review_coach.tcl]

set startFen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
set afterFen [::chessboard::toFen \
    [::chessboard::makeMove [::chessboard::fromFen $startFen] e2e4]]

proc mv {ply side uci cls before after} {
    return [dict create ply $ply side $side played $uci \
        fen_before $::startFen fen_after $::afterFen \
        classification $cls eval_before_white $before eval_after_white $after \
        eval_after_cp $after cp_loss [expr {abs($before - $after)}]]
}

set m [mv 1 white e2e4 good 20 20]
set moves {}
for {set ply 1} {$ply <= 16} {incr ply} {
    lappend moves [mv $ply [expr {$ply % 2 ? "white" : "black"}] \
        e2e4 [expr {$ply == 9 ? "inaccuracy" : "good"}] 20 \
        [expr {$ply == 9 ? -40 : 20}]]
}

puts "\nthe move facts"

set facts [::reviewcoach::moveFacts $m]
check "the move is described, not just named" \
    [expr {[string first "played:" $facts] >= 0}]
check "the verdict is in the facts" \
    [expr {[string first "verdict: good" $facts] >= 0}]
check "and the engine's line is available" \
    [expr {[string first "FACTS" $facts] < 0}]
check "each fact stays on its own line" \
    [expr {[regexp -line {^played: \S+.*\s\S+.*\s\S+} $facts] \
        && [llength [split $facts "\n"]] < 40}]

puts "\nthe game facts"

set gf [::reviewcoach::gameFacts $moves [dict create result 1-0 opening "Test Opening"]]
foreach want {{result: White won} {opening: Test Opening} {measured level:} {the game turned here} {weakest phase}} {
    check "it carries $want" [expr {[string first $want $gf] >= 0}]
}
check "and the moves that changed the result" \
    [expr {[string first "errors by" $gf] >= 0 || [string first "chances offered" $gf] >= 0}]

# The turning point is the error that began the collapse, not the later move
# that crossed a threshold. The shape is a real game: the queen blunder leaves
# Black on 13%, and a second error three moves later drops it under 10%.
puts "\nthe move the game turned on"

proc turningMove {ply side cls before after} {
    set pb [expr {$side eq "white" ? $before : -$before}]
    set pa [expr {$side eq "white" ? $after : -$after}]
    return [dict create ply $ply side $side classification $cls \
        eval_before_white $before eval_after_white $after \
        eval_before_cp $before eval_after_cp $after \
        player_before $pb player_after $pa]
}
set story {}
for {set ply 1} {$ply <= 32} {incr ply} {
    lappend story [turningMove $ply [expr {$ply % 2 ? "white" : "black"}] best 0 0]
}
lappend story [turningMove 33 black blunder 0 504]
lappend story [turningMove 34 white best 504 552]
lappend story [turningMove 35 black best 552 538]
lappend story [turningMove 36 white best 538 586]
lappend story [turningMove 37 black inaccuracy 586 772]
lappend story [turningMove 38 white best 772 815]
set turn [::reviewcoach::turningMove $story]
checkEq "the turning move is the blunder that started the collapse" \
    [dict get $turn ply] 33
checkEq "and it is the loser's move" [dict get $turn side] black

set pf [::reviewcoach::phaseFacts $moves opening]
check "a phase has its figures" \
    [expr {[string first "phase: opening" $pf] >= 0 && [string first "accuracy:" $pf] >= 0}]
check "and the state at its ends" \
    [expr {[string first "state at the start of this phase:" $pf] >= 0 \
        && [string first "state at the end of this phase:" $pf] >= 0}]

puts "\nthe prose markers"

checkEq "the prose markers come off together" \
    [::reviewcoach::strip "\[Best\] \[%eval +0.20\] \[Phase opening\] figs \[Coach\] words"] \
    "\[Best\] \[%eval +0.20\]"

# The header block is the coach's too: turning the coach off has to take it
# away, and the report's own header must survive.
puts "\nthe header block"

set ::loc 0
set ::comments [dict create]
proc sc_move {what {n 0}} {
    if {$what eq "ply"} { set ::loc $n }
    return ""
}
proc sc_pos {what args} {
    switch -- $what {
        location { return $::loc }
        getComment { return [expr {[dict exists $::comments $::loc] ? [dict get $::comments $::loc] : ""}] }
        setComment { dict set ::comments $::loc [lindex $args 0] ; return "" }
    }
    return ""
}
namespace eval ::review {}
proc ::review::cursorSave {} { return [list $::loc 0] }
proc ::review::cursorRestore {c} { set ::loc [lindex $c 0] ; return 1 }

dict set ::comments 0 "\[Game review\]\n  White: 90% CAPS accuracy\n\nSummary: old story\nLevel: old level\nOpening: old name"
::reviewcoach::stripHeaderAtStart
check "the header summary comes off" \
    [expr {[string first "old story" [dict get $::comments 0]] < 0 \
        && [string first "old level" [dict get $::comments 0]] < 0 \
        && [string first "old name" [dict get $::comments 0]] < 0}]
check "and the report header stays" \
    [expr {[string first "\[Game review\]" [dict get $::comments 0]] >= 0}]

# The report's own lines are indented under [Game review] and say "White:" and
# "Phases:", so a label at the start of a line is the coach's and nobody else's.
checkEq "an indented report line is not a header block" \
    [::reviewcoach::stripHeader "\[Game review\]\n  White: 90%\n  Phases: opening"] \
    "\[Game review\]\n  White: 90%\n  Phases: opening"

puts "\nthe same input gives the same facts"

checkEq "move facts are deterministic" [::reviewcoach::moveFacts $m] $facts
checkEq "game facts are deterministic" \
    [::reviewcoach::gameFacts $moves [dict create result 1-0 opening "Test Opening"]] $gf

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
