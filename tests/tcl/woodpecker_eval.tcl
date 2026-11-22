#!/usr/bin/env tclsh
# Woodpecker evaluation: the positions the two passes search and the marks
# their results give, without an engine (the results are written by hand in
# the driver's shape: ply -> {mpvIndex -> {depth score type pv}}).

set fails 0
set checks 0
proc checkEq {name got want} {
    global fails checks
    incr checks
    if {$got ne $want} { incr fails; puts "FAIL $name -- got '$got' want '$want'" }
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
foreach f {tools/accuracy.tcl tools/move_labels.tcl utils/chessboard.tcl tools/score_seed.tcl
           enginecfg.tcl tools/engine_limits.tcl tools/comment_colors.tcl tools/game_review.tcl
           tools/review_driver.tcl tools/woodpecker_core.tcl tools/woodpecker_eval.tcl} {
    source -encoding utf-8 [file join $root tcl $f]
}

set fen {6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1}
set exs [dict create 7 [::woodpecker::exerciseRow 7 7 "" "" $fen {a1a8} ""]]

set deep [::woodpecker::eval::deepPositions $exs {7}]
checkEq "the first pass searches every position of the line" [lmap p $deep { lindex $p 0 }] {7000 7001}
checkEq "from the exercise's FEN" [lindex $deep 0 1] "position fen $fen moves"
checkEq "the position after the move" [lindex $deep 1 1] "position fen $fen moves a1a8"
set sh [::woodpecker::eval::shallowPositions $exs {7}]
checkEq "the second pass searches before each solver move" $sh [list [list 7000 "position fen $fen moves"]]

set deepRes [dict create \
    7000 [dict create 1 {12 1 mate a1a8} 2 {12 30 cp {a1a7 h7h6}}] \
    7001 [dict create 1 {0 0 mate {}}]]
set m [::woodpecker::eval::marksFromResults $exs {7} $deepRes [dict create 7000 [dict create 1 {3 1 mate a1a8}]]]
checkEq "an obvious mate earns no mark" [dict get $m 7 marks] [list ""]
checkEq "the marks come from the review" [dict get $m 7 source] review
set m [::woodpecker::eval::marksFromResults $exs {7} $deepRes [dict create 7000 [dict create 1 {3 20 cp a1a7}]]]
checkEq "a mate the short search misses is !" [dict get $m 7 marks] [list "!"]
# A pass that lost its engine reports only the positions it reached. An
# exercise it never got to must be left out, so it keeps its earlier marks;
# grading it would append a new version of blanks over them.
set m [::woodpecker::eval::marksFromResults $exs {7} [dict create] [dict create]]
checkEq "an exercise the engine never reached is not graded" $m [dict create]
set half [dict create 7000 [dict get $deepRes 7000]]
set m [::woodpecker::eval::marksFromResults $exs {7} $half [dict create]]
checkEq "half a line is not graded" $m [dict create]

# Cutting a pass for several engines: whole exercises, dealt in turn, nothing lost.
set pos {}
foreach ex {1 2 3 4 5} { foreach ply {0 1 2} { lappend pos [list [expr {$ex * 1000 + $ply}] x] } }
set c [::woodpecker::eval::chunks $pos 2]
checkEq "two chunks" [llength $c] 2
checkEq "the exercises alternate" [lmap p [lindex $c 0] { expr {[lindex $p 0] / 1000} }] {1 1 1 3 3 3 5 5 5}
checkEq "every position is in a chunk" [expr {[llength [lindex $c 0]] + [llength [lindex $c 1]]}] 15
checkEq "no empty chunk is returned" [llength [::woodpecker::eval::chunks [lrange $pos 0 2] 4]] 1
set ::woodpecker::eval::WORKERS 6
checkEq "one engine per four exercises at most" [::woodpecker::eval::workerCount 9] 3
checkEq "never more than 8" [expr {[set ::woodpecker::eval::WORKERS 20; ::woodpecker::eval::workerCount 400]}] 8
checkEq "one exercise, one engine" [::woodpecker::eval::workerCount 1] 1
checkEq "worker preset: one thread, small hash" [lindex [::woodpecker::eval::workerCfg {n e a d 0 0 {} 1 {{Threads 8} {Hash 4096} {Ponder true}}}] 8] {{Ponder true} {Threads 1} {Hash 64}}

puts "$checks checks, $fails failures"
exit [expr {$fails > 0}]
