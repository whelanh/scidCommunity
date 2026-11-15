# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# perf_rating.tcl -- the performance rating's pure calculations.
#
#   tclsh tests/tcl/perf_rating.tcl
#
# The rating comes from the expected score a player gave away with the moves
# played:
#
#   E(p) = ::accuracy::winPercent(eval at p) / 100
#   d_i  = max(0, E(best at p_i) - E(position after the move played))
#   ESL  = sum of d_i over the player's own moves
#
# and the fitted, monotone table turns ESL per move into a rating. Nothing here
# reads a rating from the game: the estimate is a function of the moves alone.

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
proc near {a b {tol 0.005}} { expr {abs($a - $b) <= $tol} }

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools perf_rating.tcl]

# ── the table ───────────────────────────────────────────────────────────────
puts "\ntable"

set table [::perfrating::table]
check "the table has rows" [expr {[llength $table] >= 8}] [llength $table]
check "the table is monotone: a bigger loss never buys a higher rating" \
    [::perfrating::tableMonotone]
set lastX -1.0
set lastY 100000
set ascending 1
set monotone 1
foreach row $table {
    lassign $row x y
    if {$x <= $lastX} { set ascending 0 }
    if {$y > $lastY} { set monotone 0 }
    set lastX $x
    set lastY $y
}
check "its loss axis ascends" $ascending
check "its ratings never rise as the loss grows" $monotone

set BIN $::perfrating::BIN
set bin 0
foreach row $table {
    lassign $row x y
    if {$y % $BIN != 0} { set bin 1 }
}
check "every table rating is on the display's own grid" [expr {$bin == 0}]

# ── the lookup ──────────────────────────────────────────────────────────────
puts "\nlookup"

lassign [lindex $table 0] firstX firstY
lassign [lindex $table end] lastX lastY

checkEq "a perfect game clamps to the table's top" \
    [::perfrating::estimate 0.0] $firstY
checkEq "a hopeless game clamps to the table's bottom" \
    [::perfrating::estimate [expr {$lastX * 10}]] $lastY
checkEq "a negative loss is not a better-than-perfect game" \
    [::perfrating::estimate -0.5] $firstY

set mono 1
set rounded 1
set prev 100000
for {set i 0} {$i <= 400} {incr i} {
    set x [expr {$i * $lastX / 200.0}]
    set y [::perfrating::estimate $x]
    if {$y > $prev} { set mono 0 }
    if {[string is entier -strict $y] == 0} { set rounded 0 }
    if {$y % $BIN != 0} { set rounded 0 }
    set prev $y
}
check "the lookup never rises as the loss grows" $mono
check "every answer is an integer on the bin grid" $rounded

# Inside the fitted range the lookup interpolates between the table's rows
# instead of stepping at them: a table with 25-point bins would otherwise jump
# 25 points on the last 0.0001 of a bin.
set midX [expr {([lindex [lindex $table 1] 0] + [lindex [lindex $table 2] 0]) / 2.0}]
set between [::perfrating::estimate $midX]
lassign [lindex $table 1] x1 y1
lassign [lindex $table 2] x2 y2
check "a point between two rows lands between their ratings" \
    [expr {$between <= $y1 && $between >= $y2}] "$between between $y1 and $y2"

# ── the statistic ───────────────────────────────────────────────────────────
puts "\nstatistic"

# winPercent -> cp, so a construction can state its losses in the units the
# card states them in: percentage points of expected score.
proc cpOf {wp} {
    if {$wp <= 0.0} { return -4000.0 }
    if {$wp >= 100.0} { return 4000.0 }
    return [expr {-log(100.0 / $wp - 1.0) / 0.00368208}]
}

# White's moves drop the win% by the given amounts, Black's hold it.
proc movesOf {start losses} {
    set moves {}
    set wp $start
    set before [cpOf $wp]
    set ply 0
    foreach l $losses {
        set wp [expr {$wp - $l}]
        set after [cpOf $wp]
        incr ply
        lappend moves [dict create ply $ply side white cp_loss 0 \
            eval_before_white $before eval_after_white $after]
        # Black's move holds the score: no loss for Black.
        incr ply
        lappend moves [dict create ply $ply side black cp_loss 0 \
            eval_before_white $after eval_after_white $after]
        set before $after
    }
    return $moves
}

# The {side before after} pairs accuracy takes, from the report's move dicts.
proc pairsOf {moves} {
    set pairs {}
    foreach m $moves {
        set before [dict get $m eval_before_white]
        set after [dict get $m eval_after_white]
        if {$before eq "" || $after eq ""} { continue }
        lappend pairs [list [dict get $m side] $before $after]
    }
    return $pairs
}

# Forty one-point losses: ESL 0.40, and the app's accuracy for that game is
# 95.60 -- both figures the calibration card states.
set flat [movesOf 50.0 [lrepeat 40 1.0]]
check "forty 1% losses are 0.40 of expected score" \
    [near [::perfrating::esl $flat white] 0.40] [::perfrating::esl $flat white]
lassign [::accuracy::calculatePairs [pairsOf $flat]] accW accB
check "the flat game's accuracy is 95.60" [near $accW 95.60 0.005] $accW

# Thirty-nine 1% losses and one 50% loss: 97 -> 47 -> 8. ESL is exactly 0.89,
# more than twice the flat game's cost, and the app's accuracy falls to 80.39.
set tail [movesOf 97.0 [concat 50.0 [lrepeat 39 1.0]]]
check "a 50% loss plus 39 of 1% is 0.89" \
    [near [::perfrating::esl $tail white] 0.89] [::perfrating::esl $tail white]
lassign [::accuracy::calculatePairs [pairsOf $tail]] tailW tailB
check "the tail game's accuracy is 80.39, not the unweighted 93.4" \
    [near $tailW 80.39 0.02] $tailW

# A decided position: E_best 0.05 -> E_after 0.03 is 0.02 of expected score
# given away. The ratio form would call it a 40% loss of a position worth
# almost nothing; the additive form is what the fit is on.
set decided {}
lappend decided [dict create ply 1 side white cp_loss 0 \
    eval_before_white [cpOf 5] eval_after_white [cpOf 3]]
check "a 5% -> 3% position costs 0.02, not the 40% the ratio form reports" \
    [near [::perfrating::esl $decided white] 0.02 1e-6] [::perfrating::esl $decided white]

# Ratio of sums, not mean of ratios: one move in a dead-drawn-to-lost position
# has E_best = 0, where a per-move ratio divides by zero and a 5% -> 3% move
# scores as a 60% disaster.
set mixed {}
lappend mixed [dict create ply 1 side white cp_loss 0 \
    eval_before_white [cpOf 50] eval_after_white [cpOf 50]]
lappend mixed [dict create ply 2 side white cp_loss 0 \
    eval_before_white [cpOf 0] eval_after_white [cpOf 0]]
lappend mixed [dict create ply 3 side white cp_loss 0 \
    eval_before_white [cpOf 60] eval_after_white [cpOf 30]]
set kept [::perfrating::keptPercent $mixed white]
check "the kept percentage is a ratio of sums" \
    [near $kept [expr {100.0 * (50 + 0 + 30) / (50 + 0 + 60)}] 0.01] $kept
check "it stays a sane percentage where a mean of ratios divides by zero" \
    [expr {$kept > 0 && $kept <= 100}] $kept

# Sides travel with the move, not with the ply: a hole in the collected list
# must not hand Black's moves to White.
set holed {}
lappend holed [dict create ply 1 side white cp_loss 0 \
    eval_before_white [cpOf 50] eval_after_white [cpOf 45]]
lappend holed [dict create ply 3 side white cp_loss 0 \
    eval_before_white [cpOf 45] eval_after_white [cpOf 40]]
lappend holed [dict create ply 4 side black cp_loss 0 \
    eval_before_white [cpOf 40] eval_after_white [cpOf 40]]
check "White's own moves are counted, holes and all" \
    [expr {[llength [::perfrating::measuredMoves $holed white]] == 2}]
check "a ply the pass did not judge is not a move for anyone" \
    [expr {[llength [::perfrating::measuredMoves $holed black]] == 1}]

# Book plies carry no evaluation: they are not measured moves and must not be
# scored as perfect ones.
set book {}
lappend book [dict create ply 1 side white cp_loss 0 \
    eval_before_white "" eval_after_white ""]
lappend book [dict create ply 2 side white cp_loss 0 \
    eval_before_white [cpOf 50] eval_after_white [cpOf 50]]
check "a book ply is not a measured move" \
    [expr {[llength [::perfrating::measuredMoves $book white]] == 1}]
check "a side with no measured move has no estimate" \
    [expr {[::perfrating::estimateFor [lrange $book 0 0] white] eq ""}]

# The estimate itself: a perfect game sits at the table's top, and the number
# is the table's, not a curve's.
checkEq "a game with no loss gets the table's top rating" \
    [::perfrating::estimateFor $flat white] [::perfrating::estimate 0.01]

puts ""
if {$fails} {
    puts "$checks checks, $fails failures"
    exit 1
}
puts "$checks checks, 0 failures"
