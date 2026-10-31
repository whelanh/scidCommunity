# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# batch_annotate.tcl -- the Game List batch's engine-line parser.
#
#   tclsh tests/tcl/batch_annotate.tcl
#
# Batch annotate now feeds the Game Review writer, so the engine lines it
# collects have to be in the review's own shape: {depth score score-type pv},
# one per MultiPV rank, deepest line wins. The rest of the batch is pipes and
# the game database; this is the part that decides what the writer sees.

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

proc ::options.store {args} {}
set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools batch_annotate.tcl]

proc line {text} {
    return [::batch_annotate::collect $text [dict create]]
}

puts "\none info line per MultiPV rank"

set l [line {info depth 10 seldepth 12 multipv 1 score cp 34 nodes 100 pv e2e4 e7e5}]
checkEq "the line is the review's four fields" [dict get $l 1] \
    {10 34 cp {e2e4 e7e5}}
set l [::batch_annotate::collect \
    {info depth 11 seldepth 15 multipv 2 score cp -12 nodes 200 pv d2d4 d7d5} $l]
checkEq "rank two is kept beside it" [dict get $l 2] {11 -12 cp {d2d4 d7d5}}
checkEq "rank one is untouched" [dict get $l 1] {10 34 cp {e2e4 e7e5}}

puts "\nthe deepest line for a rank wins"

set l [::batch_annotate::collect \
    {info depth 12 seldepth 16 multipv 1 score cp 40 nodes 300 pv e2e4 c7c5} $l]
checkEq "a deeper line replaces the shallower one" [dict get $l 1] \
    {12 40 cp {e2e4 c7c5}}
set before $l
set l [::batch_annotate::collect \
    {info depth 9 seldepth 12 multipv 1 score cp 90 nodes 10 pv e2e4 e7e5} $l]
checkEq "a shallower line does not" [dict get $l 1] [dict get $before 1]

# UCI does not require a depth, and the engine may repeat a depth while finishing
# the iteration. Both must keep a usable line here, exactly as in the review
# driver's collector, or a move the pass could judge is reported as unjudged.
puts "\na line without a depth, and an equal-depth reading"
set l [line {info multipv 1 score cp 20 pv e2e4 e7e5}]
checkEq "a line without a depth is kept" [dict get $l 1] {0 20 cp {e2e4 e7e5}}
set l [line {info depth 10 multipv 1 score cp 20 pv e2e4 e7e5}]
set l [::batch_annotate::collect \
    {info depth 10 multipv 1 score cp 30 pv d2d4 d7d5} $l]
checkEq "an equal-depth line is the fresher reading" [dict get $l 1] \
    {10 30 cp {d2d4 d7d5}}

puts "\nwhat the writer cannot use is left out"

set l [line {info depth 10 multipv 1 score cp 10 lowerbound nodes 1 pv e2e4}]
checkEq "a bound is not a verdict" $l {}
set l [line {info depth 10 multipv 1 score cp 10 nodes 1}]
checkEq "a line without a PV is not a line" $l {}
set l [line {info depth 10 seldepth 12 multipv 1 score mate 3 nodes 1 pv e2e4 e7e5}]
checkEq "a mate keeps its distance and type" [dict get $l 1] \
    {10 3 mate {e2e4 e7e5}}
set l [line {info depth 10 multipv}]
checkEq "a malformed line changes nothing" $l {}
set l [line {info string score cp 20 pv e2e4 e7e5}]
checkEq "an info string is not an analysis line" $l {}

# The Go the batch sends is the pass's: the review's depth and, when Review
# Settings sets one, its time ceiling. The engine is stubbed - the transport's
# open/gets/eof answer the handshake from a queue and hand back a channel - so
# the test reads back what ::batch_annotate::feed_move actually wrote.
puts "\nthe batch sends the pass's two bounds"

source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools game_review.tcl]

set ::windowsOS 0
namespace eval ::enginecfg {}
proc ::enginecfg::get {name} {
    return [list $name tclsh {} {} 0 1800 {} 1 {} {} {}]
}

namespace eval ::batch_annotate_test {
    variable chan ""
    variable replies {}
}
rename open ::testopen
rename gets ::testgets
rename eof ::testeof
proc open {args} { return $::batch_annotate_test::chan }
proc gets {chan args} {
    if {$chan eq $::batch_annotate_test::chan} {
        if {![llength $::batch_annotate_test::replies]} { return -1 }
        set line [lindex $::batch_annotate_test::replies 0]
        set ::batch_annotate_test::replies [lrange $::batch_annotate_test::replies 1 end]
        if {[llength $args]} {
            upvar 1 [lindex $args 0] linevar
            set linevar $line
            return [string length $line]
        }
        return $line
    }
    return [::testgets $chan {*}$args]
}
proc eof {chan} {
    if {$chan eq $::batch_annotate_test::chan} { return 0 }
    return [::testeof $chan]
}

proc ::batch_annotate_test::go {movetime} {
    ::review::reset
    if {$movetime ne ""} { ::review::setValue movetime $movetime }
    # file tempfile answers the open channel and names the path in its variable
    # argument. Using the channel as a path wrote a cwd file called "fileN" and
    # left the real temp file behind.
    set path ""
    set tf [file tempfile path]
    close $tf
    set chan [::testopen $path w+]
    fconfigure $chan -buffering line
    set ::batch_annotate_test::chan $chan
    set ::batch_annotate_test::replies {uciok readyok}
    set ::batch_annotate::engine_name Stub
    ::batch_annotate::start_engines 1
    set ::batch_annotate::pipe_moves($chan) [list [list 1 "position startpos"]]
    ::batch_annotate::feed_move $chan
    seek $chan 0
    set written [read $chan]
    close $chan
    file delete $path
    set go ""
    foreach line [split $written "\n"] {
        if {[string match "go *" $line]} { set go $line }
    }
    return $go
}

checkEq "no cap in Review Settings, no time in the Go" \
    [::batch_annotate_test::go ""] "go depth 18"
checkEq "a cap in Review Settings reaches the pipe" \
    [::batch_annotate_test::go 400] "go depth 18 movetime 400"

# A short cap can end a search before the engine reports a single scored line.
# collect keeps nothing for it, the move is written with no verdict, and the game
# still counts as completed: the count is the only place the user learns the batch
# fell short of judging every move, so it has to reach the completion dialog.
#
# It is a count of MOVES. planPositions searches the position before each move and
# the position after it, so counting empty position results charged one empty
# search to the moves on both sides of it, and counted the successor of the last
# planned ply - a position no move is judged from. It also missed the move the
# engine never ranked when its successor came back with no usable line.
puts "\nunjudged moves are counted, not unjudged positions"

array set ::tr {
    BatchComplete      {Batch Annotation Complete!}
    BatchGames         {games}
    BatchProcessed     {processed}
    BatchUnscoredPlies {plies with no verdict: %s}
}

# judge labels what it measures, so the label ladder has to be here too.
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools review_driver.tcl]

set bmap [::review::mainLineMap [list {position startpos moves} e2e4 e7e5 g1f3 b8c6]]
set bplan [::review::plan [dict get $bmap plies] 0]

# Every move judged from the position before it; only the successor of the last
# move - the end of the game, not a move - came back empty.
set evals [dict create \
    0 [dict create 1 {20 30 cp {e2e4 e7e5}}] \
    1 [dict create 1 {20 25 cp {e7e5 g1f3}}] \
    2 [dict create 1 {20 20 cp {g1f3 b8c6}}] \
    3 [dict create 1 {20 10 cp {b8c6 g1f3}}]]
checkEq "an empty successor of the last move is not a ply with no verdict" \
    [::batch_annotate::unjudgedCount $bmap $evals $bplan] 0

# The engine never ranked the last move at its root, and the successor search came
# back with no line the writer can use: no verdict for that move, and nothing on
# the successor position to notice.
set evals2 [dict create \
    0 [dict create 1 {20 30 cp {e2e4 e7e5}}] \
    1 [dict create 1 {20 25 cp {e7e5 g1f3}}] \
    2 [dict create 1 {20 20 cp {g1f3 b8c6}}] \
    3 [dict create 1 {20 10 cp {d2d4 d7d5}}] \
    4 [dict create 2 {20 5 cp {a7a6}}]]
checkEq "a move with no line of its own and no successor line is counted" \
    [::batch_annotate::unjudgedCount $bmap $evals2 $bplan] 1

# A game that opens in the book: those plies are written as [Book], not left
# unjudged, so they must not inflate the count. The first two plies are book and
# were never searched; the last two have usable lines.
set bookEvals [dict create \
    2 [dict create 1 {20 20 cp {g1f3 b8c6}}] \
    3 [dict create 1 {20 15 cp {b8c6 g1f3}}] \
    4 [dict create 1 {20 10 cp {a7a6}}]]
checkEq "without the book range, book plies look unjudged" \
    [::batch_annotate::unjudgedCount $bmap $bookEvals $bplan] 2
checkEq "book plies are not counted as unjudged" \
    [::batch_annotate::unjudgedCount $bmap $bookEvals $bplan 2] 0

set ::batch_annotate::unscored_plies 1
set ::batch_annotate::games_completed 3
checkEq "the completion dialog reports games and unjudged plies" \
    [::batch_annotate::completionMessage] \
    {Batch Annotation Complete! 3 games processed, plies with no verdict: 1.}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
