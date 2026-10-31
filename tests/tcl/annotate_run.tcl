#!/usr/bin/env tclsh
# The annotate run: the dialog's plan, the driver's pass, the write, and the one
# Cancel button - driven end to end with a stub engine and the stub game, so the
# wiring is exercised without Tk.
#
# What this gates that the pure tests cannot:
#
#   * the plan the dialog decides actually starts a pass on the pane's preset and
#     hands it the book end the dialog walked;
#   * the pass writes the game (the writer is wired, not merely defined);
#   * the progress line is the run's own state, and the Cancel label beside it is
#     "Stop now" for one game and "Stop after this game" in a batch, flipping on
#     the first press;
#   * a cancelled run writes nothing and leaves nothing running;
#   * a batch runs one pass per game and saves each one.

set fails 0
set checks 0

proc check {name cond} {
    global fails checks
    incr checks
    if {![uplevel 1 [list expr $cond]]} {
        incr fails
        puts "FAIL $name"
    }
}

proc checkEq {name got want} {
    global fails checks
    incr checks
    if {$got ne $want} {
        incr fails
        puts "FAIL $name -- got '$got' want '$want'"
    }
}

proc checkHas {name haystack needle} {
    global fails checks
    incr checks
    if {[string first $needle $haystack] < 0} {
        incr fails
        puts "FAIL $name -- '$needle' is not in '$haystack'"
    }
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tests tcl game_stub.tcl]
source [file join $root tcl enginecfg.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools score_seed.tcl]
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools game_review.tcl]
source [file join $root tcl tools review_driver.tcl]
source [file join $root tcl tools review_annotate.tcl]

array set ::informant {!? 0.3 ?! 0.3 ? 0.8 ?? 1.5 += 0.5 +/- 1.5 +- 2.5 +-- 4.0}
array set ::translations {
    E,StopNow           {Stop now}
    E,StopAfterThisGame {Stop after this game}
}
proc ::tr {tag args} {
    if {[info exists ::translations(E,$tag)]} { return $::translations(E,$tag) }
    return $tag
}

# The engine layer, stubbed the way tests/tcl/review_driver.tcl stubs it.
set ::sent {}
set ::closed {}
set ::connseq 0
namespace eval ::engine {}
proc ::engine::setLogCmd {id args} {}
proc ::engine::connect {id callback exe args {protocols {uci xboard}}} {
    incr ::connseq
    set ::engconn(channel_$id) chan$::connseq
    set ::engine_callback $callback
    lappend ::sent [list connect $id $exe $args $protocols]
    set ::opened $::connseq
}
proc ::engine::send {id msg args} { lappend ::sent [list send $id $msg [lindex $args 0]] }
proc ::engine::close {id} { lappend ::closed $id }

proc feed {msgType msgData} { {*}$::engine_callback [list $msgType $msgData] }

proc pump {} {
    after idle {set ::pumped 1}
    vwait ::pumped
    unset -nocomplain ::pumped
}

# The status line and the notifications, recorded rather than drawn.
namespace eval ::notify {}
namespace eval ::board {}
set ::painted {}
set ::updated 0
proc ::notify::PosChanged {args} {}
proc ::notify::DatabaseModified {args} {}
proc updateStatusBar {} { incr ::updated }
proc ::board::setInfoAlert {w header msg color cmd} {
    lappend ::painted [list $header $msg $cmd]
}

set ::engines(list) [list \
    [list Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {} {}]]

proc annotateSettings {} {
    set ::annotateBlunders allmoves
    set ::blunderThreshold 1.0
    set ::markTacticalExercises 0
    set ::useAnalysisBook 0
    set ::addAnnotatorTag 0
    set ::isBatchOpening 0
    set ::analysis(uci1) 1
    set ::analysis(uci2) 1
    ::review::reset
    return
}

# One engine reply set for the position at `ply` of the fixture, with the score
# the side to move sees. The pass asks one position at a time, so every position
# is answered here in order.
proc answer {cp pv} {
    feed InfoPV [list 1 18 18 500 100 0 0 40 $cp cp 0 $pv]
    feed InfoBestMove {}
    return
}

########################################################################
### One game, from the dialog's plan to the written game

annotateSettings
::gamestub::reset [list {e4 e2e4} {e5 e7e5}]
set ::gamestub::number 3
set plan [::reviewannotate::dialogPlan 1 Stockfish 1 \
    [dict create game 3 blunders allmoves batch 0 batchEnd 3 bookEnd 0]]
checkEq "the plan is ready to run" [dict get $plan refuse] ""
checkEq "running it starts a pass" [::reviewannotate::run $plan] ""
check "the run is in flight" [::reviewannotate::running]

# The pass opens the pane's own preset on the driver's connection.
checkEq "the pane's preset is the engine" [lindex [lindex $::sent 0] 2] /usr/bin/stockfish

feed InfoConfig {}
checkHas "the first position is searched" [lindex $::sent end] {send 20 Go}
checkEq "the progress line starts at zero" [::reviewannotate::statusText] {0/3}

# e2e4 is the engine's own move at the first position, and e7e5 at the second.
answer 20 {e2e4 e7e5}
checkEq "progress follows the pass" [::reviewannotate::statusText] {1/3}
answer -20 {e7e5 g1f3}
answer 20 {g1f3 b8c6}
pump
checkEq "the pass finished cleanly" [dict get [::reviewdriver::status] state] done
checkEq "and wrote both moves" [dict get [::reviewdriver::status] written] 2
checkHas "the label landed in the game" [dict get [::gamestub::commentsByPly] 1] "\[MoveLabel"
checkEq "the run is over" [::reviewannotate::running] 0
checkEq "the progress line is handed back" $::reviewannotate::progressText ""
check "the board was told to redraw" [expr {$::updated > 0}]

# The progress line's Cancel was the single-game one, and it was a live button.
set lastPaint [lindex $::painted end]
checkEq "the status line names the pass" [lindex $lastPaint 0] "Annotate:"
checkEq "and offers the single-game Cancel" [lindex $lastPaint 2] ::reviewannotate::cancelAction

########################################################################
### Cancel stops a single game and writes nothing

annotateSettings
::gamestub::reset [list {e4 e2e4} {e5 e7e5}]
set plan [::reviewannotate::dialogPlan 1 Stockfish 1 \
    [dict create game 3 blunders allmoves batch 0 batchEnd 3 bookEnd 0]]
::reviewannotate::run $plan
feed InfoConfig {}
answer 20 {e2e4 e7e5}
checkEq "the label offers Stop now" [::reviewannotate::stopLabel [::reviewannotate::moreGames]] {Stop now}
checkEq "Cancel stops it" [::reviewannotate::cancelAction] 1
pump
checkEq "the pass is cancelled" [dict get [::reviewdriver::status] state] cancelled
checkEq "and the game is untouched" [::gamestub::commentsByPly] ""
checkEq "nothing is left running" [::reviewannotate::running] 0

########################################################################
### A batch: one pass per game, one save per game, and the Cancel escalation

annotateSettings
::gamestub::reset [list {e4 e2e4} {e5 e7e5}]
set ::gamestub::number 3
set plan [::reviewannotate::dialogPlan 1 Stockfish 1 \
    [dict create game 3 blunders allmoves batch 1 batchEnd 4 bookEnd 0]]
checkEq "the batch covers both games" [list [dict get $plan from] [dict get $plan to]] {3 4}
set openedBefore $::opened
checkEq "running it starts the first game" [::reviewannotate::run $plan] ""
checkEq "the batch Cancel ends after this game" \
    [::reviewannotate::stopLabel [::reviewannotate::moreGames]] {Stop after this game}
checkEq "and the game loaded is the first of the range" $::gamestub::number 3
feed InfoConfig {}
answer 20 {e2e4 e7e5}
answer -20 {e7e5 g1f3}
answer 20 {g1f3 b8c6}
pump
# The first game's pass wrote and was saved, and the second pass started: a
# batch is a chain, and only the completion hook can advance it.
checkHas "the first game was labelled" [dict get [::gamestub::commentsByPly] 1] "\[MoveLabel"
checkEq "the second game is loaded and searching" $::gamestub::number 4
check "one pass per game was opened" [expr {$::opened == $openedBefore + 2}]
checkEq "the progress line names the game" [::reviewannotate::statusText] {0/3 game 2/2}

feed InfoConfig {}
answer 20 {e2e4 e7e5}
answer -20 {e7e5 g1f3}
answer 20 {g1f3 b8c6}
pump
checkEq "the batch ends with the last game" [::reviewannotate::running] 0
checkEq "both passes finished cleanly" [dict get [::reviewdriver::status] state] done

# The escalation: in a batch the first press asks for the game in flight to be
# finished and the rest to be dropped; the label says so, then says Stop now.
annotateSettings
::gamestub::reset [list {e4 e2e4} {e5 e7e5}]
set ::gamestub::number 3
set plan [::reviewannotate::dialogPlan 1 Stockfish 1 \
    [dict create game 3 blunders allmoves batch 1 batchEnd 5 bookEnd 0]]
set openedBefore $::opened
::reviewannotate::run $plan
checkEq "a three-game batch starts at the first" $::gamestub::number 3
checkEq "and its Cancel ends after this game" \
    [::reviewannotate::stopLabel [::reviewannotate::moreGames]] {Stop after this game}
feed InfoConfig {}
check "the first press only asks for this game" [::reviewannotate::cancelAction]
checkEq "the label flips to Stop now" [::reviewannotate::stopLabel [::reviewannotate::moreGames] 1] {Stop now}
checkEq "and the run is still going" [::reviewannotate::running] 1
answer 20 {e2e4 e7e5}
answer -20 {e7e5 g1f3}
answer 20 {g1f3 b8c6}
pump
checkEq "the game in flight was finished and written" \
    [dict get [::reviewdriver::status] state] done
checkEq "the run ended there" [::reviewannotate::running] 0
checkEq "and no further game was loaded" $::gamestub::number 3
check "no further pass was opened" [expr {$::opened == $openedBefore + 1}]

########################################################################
### The dialog's variation controls reach the writer
###
### The dialog renders a White/Black side filter and a "Variation length (moves)"
### spinner, and the classic annotator read both: the toggles decided whether a
### move got the engine's line at all, the spinner clipped it to
### annotationVariationLength*2-1 plies. The plan carries them; this section runs
### the real pass and reads what the writer was handed, so a plan key that is
### computed and then dropped on the way fails here rather than in a game.

# The writer's own arguments, recorded instead of written: the variation is what
# this section is about, and the stub game drops variations anyway.
rename ::review::writeMove ::review::writeMoveSaved
proc ::review::writeMove {ply label eval_cp lines} {
    lappend ::wrote [list $ply $label $lines]
    return ""
}

proc wroteLines {ply} {
    foreach rec $::wrote {
        if {[lindex $rec 0] == $ply} { return [lindex $rec 2] }
    }
    return ""
}

proc wroteLabel {ply} {
    foreach rec $::wrote {
        if {[lindex $rec 0] == $ply} { return [lindex $rec 1] }
    }
    return ""
}

# The six-move fixture, driven the way the driver asks: one answer per position,
# in order, from the side to move. Black's 4...Nc6 is the blunder, and the engine's
# line at the position before it is four plies long - longer than the two-move
# (three-ply) clip this section asks the dialog for.
set ::PVS [list \
    {e2e4 e7e5} {e7e5 g1f3} {g1f3 b8c6} \
    {d7d5 e4d5 c6d5 g1f3} {d2d4 e7e5} {f1b5 a7a6} {a7a6}]

proc driveAnnotate {settings} {
    annotateSettings
    ::gamestub::reset [list \
        {e4 e2e4} {e5 e7e5} {Nf3 g1f3} {Nc6 b8c6} {Bb5 f1b5} {a6 a7a6}]
    set ::wrote {}
    set plan [::reviewannotate::dialogPlan 1 Stockfish 1 $settings]
    set err [::reviewannotate::run $plan]
    if {$err ne ""} { return $err }
    feed InfoConfig {}
    set i 0
    foreach cp {20 -30 25 -30 220 -215 210} {
        answer $cp [lindex $::PVS $i]
        incr i
    }
    pump
    return ""
}

checkEq "the White-only pass runs" [driveAnnotate [dict create \
    game 3 blunders allmoves batch 0 batchEnd 3 bookEnd 0 \
    white 1 black 0 varLength 4]] ""
checkEq "White-only draws no variation on Black's move" [wroteLines 4] ""
checkEq "but the move is still labelled" [wroteLabel 4] "mistake"

checkEq "the Black-only pass runs" [driveAnnotate [dict create \
    game 3 blunders allmoves batch 0 batchEnd 3 bookEnd 0 \
    white 0 black 1 varLength 2]] ""
checkEq "the engine's line was four plies long" [llength [lindex $::PVS 3]] 4
checkEq "Black-only draws it, clipped to the spinner's moves" \
    [lindex [wroteLines 4] 0 1] {d7d5 e4d5 c6d5}
checkEq "and only one line came back" [llength [wroteLines 4]] 1

checkEq "the defaults pass runs" [driveAnnotate [dict create \
    game 3 blunders allmoves batch 0 batchEnd 3 bookEnd 0]] ""
checkEq "with no length set the whole line is kept" \
    [lindex [wroteLines 4] 0 1] {d7d5 e4d5 c6d5 g1f3}
checkEq "and both sides are annotated" [wroteLabel 4] "mistake"

rename ::review::writeMove {}
rename ::review::writeMoveSaved ::review::writeMove

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
