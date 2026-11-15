# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# perf_rating.tcl -- the performance rating the report prints, and nothing else.
#
# The number answers one question: "based on the moves of this game, what rating
# does this play suggest?" It is computed from the moves alone. A rating in the
# PGN header is not read here and cannot change the answer -- the calibration
# corpus that fits the table needed ratings as ground truth; the report does not.
#
# The statistic is the expected score given away:
#
#   E(p) = ::accuracy::winPercent(eval at p) / 100
#   d_i  = max(0, E(best at p_i) - E(position after the move played))
#   ESL  = sum of d_i over the player's own moves        (expected-score points)
#
# It is additive on purpose. Accuracy pushes the same win%-point gap through an
# exponential (103.1668*exp(-0.04354*gap) - 3.1669) and averages the moves with
# volatility weights and a harmonic mean, so equal steps of accuracy are not
# equal amounts of expected score: 39 one-point losses plus one fifty-point loss
# cost 0.89 expected-score points against 0.40 for forty one-point losses, while
# the app's accuracy moves between 95.60 and 80.39 across the same pair -- the
# tail that separates players is not linear in the number the report shows.
# The per-move ratio E_after/E_best is rejected for the same reason in decided
# positions: at E_best = 0.05 a drop to 0.03 is 0.02 of expected score, and the
# ratio form calls it a 40% collapse of a position that was already lost.
#
# The table below is the calibration, fitted offline on KingBase2018 and
# validated on players the fit never saw (docs/performance-rating.md carries the
# corpus, the folds, and the held-out MAE/bias/RMSE of every candidate against
# the accuracy+ACPL curve it replaces). The curve is data, not arithmetic: no
# coefficients live in this file, only rows, so a re-fit replaces the table and
# nothing else.
#
# Outside the fitted range the table clamps at its ends: the loss axis starts at
# a game that gave away nothing and ends where the fitted values stop moving.

namespace eval ::perfrating {
    # {expected-score loss per move, rating}: non-increasing in the loss.
    #
    # Fitted on 500 KingBase2018 games, both players rated 2001-2855, at least
    # 40 plies, one evaluation per position with Stockfish 19 at movetime 150,
    # MultiPV 1, 1 thread, 16 MB hash -- 1000 player-games -- by isotonic
    # regression on player-disjoint 5-fold splits, averaged over 10 repeats,
    # rounded to the display's 25 and re-monotonised. Held out: MAE 164.3 for
    # this statistic against 378.2 for ::reviewreport::estimateElo on the same
    # folds. docs/performance-rating.md carries the corpus, the folds and the
    # table of comparisons. The database holds no both-rated game under 2000
    # inside the selection, so the table's ends are where the corpus ends:
    # outside them it clamps.
    variable TABLE {
        {0.0000 2725}
        {0.0025 2625}
        {0.0050 2475}
        {0.0075 2475}
        {0.0100 2450}
        {0.0125 2400}
        {0.0150 2375}
        {0.0200 2375}
        {0.0250 2350}
        {0.0300 2275}
        {0.0400 2275}
        {0.0500 2250}
        {0.0600 2100}
    }
    # Displayed at the table's own resolution: a rating to the nearest 25.
    variable BIN 25
}

# Load the app's win% function if the caller has not.
if {[llength [info commands ::accuracy::winPercent]] == 0} {
    foreach f [list [file join $::scidTclDir tools accuracy.tcl] \
                   [file join [file dirname [info script]] accuracy.tcl]] {
        if {[file exists $f]} { catch { source -encoding utf-8 $f } ; break }
    }
}

proc ::perfrating::table {} {
    variable TABLE
    return $TABLE
}

# The line's wording. The report block is English today; the label still goes
# through the translation table so the one user-visible string this feature adds
# is translatable like every other, and falls back to the English text in a
# tclsh harness where language.tcl is not loaded.
proc ::perfrating::label {} {
    if {[llength [info commands tr]]} {
        set t [tr ReviewEstimatedRating]
        if {$t ne "ReviewEstimatedRating"} { return $t }
    }
    return "performance rating (from this game)"
}

proc ::perfrating::tableMonotone {} {
    variable TABLE
    set last 1.0e9
    foreach row $TABLE {
        lassign $row x y
        if {$y > $last} { return 0 }
        set last $y
    }
    return 1
}

# The moves of one side that carry an evaluation. A ply the pass has no verdict
# for is not a measured move: scored as a perfect one it would pull every
# estimate up. Every judged ply is counted, whatever its label -- the fit's ESL
# is summed over exactly the plies the pass evaluated, so the display has to
# count the same ones or the table would be read at the wrong place on its axis.
proc ::perfrating::measuredMoves {moves side} {
    set out {}
    foreach m $moves {
        if {[dict get $m side] ne $side} { continue }
        if {[dict get $m eval_before_white] eq "" || [dict get $m eval_after_white] eq ""} {
            continue
        }
        lappend out $m
    }
    return $out
}

# Expected score given away with these moves, in expected-score points (0..1
# scale, summed): the fit's feature.
proc ::perfrating::esl {moves side} {
    set sum 0.0
    foreach m [measuredMoves $moves $side] {
        set before [dict get $m eval_before_white]
        set after [dict get $m eval_after_white]
        set eb [::accuracy::winPercent $before]
        set ea [::accuracy::winPercent $after]
        if {$side eq "black"} { set gap [expr {$ea - $eb}] } else { set gap [expr {$eb - $ea}] }
        if {$gap > 0} { set sum [expr {$sum + $gap / 100.0}] }
    }
    return $sum
}

# Expected score kept, as a percentage of the expected score that was on offer:
# a ratio of sums, not a mean of per-move ratios, which is the form that breaks
# where E_best is 0. This is the statistic's own quality check and a figure the
# calibration reads; the report does not print it.
proc ::perfrating::keptPercent {moves side} {
    set offered 0.0
    set kept 0.0
    foreach m [measuredMoves $moves $side] {
        set before [dict get $m eval_before_white]
        set after [dict get $m eval_after_white]
        set eb [::accuracy::winPercent $before]
        set ea [::accuracy::winPercent $after]
        if {$side eq "black"} { set eb [expr {100.0 - $eb}] ; set ea [expr {100.0 - $ea}] }
        if {$eb <= 0.0} { continue }
        set offered [expr {$offered + $eb}]
        set kept [expr {$kept + $ea}]
    }
    if {$offered <= 0.0} { return "" }
    return [expr {100.0 * $kept / $offered}]
}

# The table read at one value: interpolated between its rows, clamped at both
# ends, and rounded to the bin the report displays.
proc ::perfrating::estimate {eslPerMove} {
    variable TABLE
    variable BIN
    set x [expr {double($eslPerMove)}]
    set first [lindex $TABLE 0]
    set last [lindex $TABLE end]
    if {$x <= [lindex $first 0]} {
        set y [lindex $first 1]
    } elseif {$x >= [lindex $last 0]} {
        set y [lindex $last 1]
    } else {
        set y [lindex $last 1]
        set prev $first
        foreach row $TABLE {
            if {$x <= [lindex $row 0]} {
                lassign $prev x0 y0
                lassign $row x1 y1
                if {$x1 == $x0} {
                    set y $y1
                } else {
                    set y [expr {$y0 + ($y1 - $y0) * ($x - $x0) / ($x1 - $x0)}]
                }
                break
            }
            set prev $row
        }
    }
    return [expr {round($y / $BIN) * $BIN}]
}

# The rating this side's play suggests, or "" when the pass measured none of
# its moves.
proc ::perfrating::estimateFor {moves side} {
    set measured [measuredMoves $moves $side]
    if {![llength $measured]} { return "" }
    return [estimate [expr {[esl $moves $side] / [llength $measured]}]]
}
