# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later

########################################################################
# Lichess accuracy calculation logic.
# Duplicates the methodology used by Lichess.
########################################################################

namespace eval ::accuracy {
    # Win% = 50 + 50 * (2 / (1 + exp(-0.00368208 * centipawns)) - 1)
    # Normailized to White's perspective.
    proc winPercent {cp} {
        return [expr {50.0 + 50.0 * (2.0 / (1.0 + exp(-0.00368208 * $cp)) - 1.0)}]
    }

    # Accuracy% = 103.1668 * exp(-0.04354 * (winPercentBefore - winPercentAfter)) - 3.1669
    proc moveAccuracy {before after} {
        set loss [expr {$before - $after}]
        if {$loss < 0} { set loss 0.0 }
        set acc [expr {103.1668 * exp(-0.04354 * $loss) - 3.1669}]
        if {$acc > 100.0} { set acc 100.0 }
        if {$acc < 0.0} { set acc 0.0 }
        return $acc
    }

    # Standard Deviation for volatility
    proc stdDev {values} {
        set n [llength $values]
        if {$n < 2} { return 0.5 }
        set sum 0.0
        foreach v $values { set sum [expr {$sum + $v}] }
        set mean [expr {$sum / $n}]
        set sumSq 0.0
        foreach v $values { set sumSq [expr {$sumSq + pow($v - $mean, 2)}] }
        set variance [expr {$sumSq / ($n - 1)}]
        return [expr {sqrt($variance)}]
    }

    # Calculate Game Accuracy for White and Black
    # centipawns: list of scores from White's perspective, starting from ply 0.
    proc calculate {centipawns} {
        return [calculateFrom $centipawns white]
    }

    # The same arithmetic over a game carried as moves: each element is
    # {side before after} - the side that made the move, and the White-
    # perspective score either side of it. A list collected from a pass can
    # have holes: a book ply carries no evaluation, and a ply the pass has no
    # verdict for is not in the list at all. A hole must not move the side of
    # the moves after it, so the side travels with its pair instead of being
    # read from the pair's position. The gap's own score change is not a move:
    # it is in the volatility window, and it is scored for neither side.
    proc calculatePairs {pairs} {
        set nMoves [llength $pairs]
        if {$nMoves == 0} { return {0.0 0.0} }

        # The positions these moves visit, in order, and where each pair starts
        # in that list. Consecutive pairs meet at a shared position, which is
        # stated once; the far end of a hole is stated too, so the window sees
        # the change the hole made.
        set centipawns {}
        set at {}
        foreach pair $pairs {
            set before [lindex $pair 1]
            set after [lindex $pair 2]
            if {![llength $centipawns] || [lindex $centipawns end] != $before} {
                lappend centipawns $before
            }
            lappend at [expr {[llength $centipawns] - 1}]
            lappend centipawns $after
        }

        set winPercents {}
        foreach cp $centipawns {
            lappend winPercents [winPercent $cp]
        }
        set n [llength $winPercents]

        # windowSize = (cps.size / 10).atLeast(2).atMost(8)
        # Note: cps.size in Lichess code is usually plies evaluated.
        set cps_size [expr {$n - 1}]
        set windowSize [expr {$cps_size / 10}]
        if {$windowSize < 2} { set windowSize 2 }
        if {$windowSize > 8} { set windowSize 8 }

        # Sliding windows for weights
        # Lichess code: fill(windowSize.atMost(allWinPercentValues.size) - 2)(firstWindow) ::: sliding(windowSize)
        set fillCount [expr {min($windowSize, $n) - 2}]
        set firstWindow [lrange $winPercents 0 [expr {min($n, $windowSize) - 1}]]
        set w_first [stdDev $firstWindow]
        if {$w_first < 0.5} { set w_first 0.5 }
        if {$w_first > 12.0} { set w_first 12.0 }

        set whiteAccs {}
        set blackAccs {}

        # A move is between its own two ends, always; its weight is the window
        # that opens on it.
        for {set i 0} {$i < $nMoves} {incr i} {
            lassign [lindex $pairs $i] side before after
            set idx [lindex $at $i]
            if {$idx < $fillCount} {
                set w $w_first
            } else {
                set start [expr {$idx - $fillCount}]
                set w [stdDev [lrange $winPercents $start [expr {$start + $windowSize - 1}]]]
                if {$w < 0.5} { set w 0.5 }
                if {$w > 12.0} { set w 12.0 }
            }
            set prev [lindex $winPercents $idx]
            set next [lindex $winPercents [expr {$idx + 1}]]

            if {$side eq "white" || $side eq "w"} {
                # White's move
                set acc [moveAccuracy $prev $next]
                lappend whiteAccs [list $acc $w]
            } else {
                # Black's move
                set acc [moveAccuracy [expr {100.0 - $prev}] [expr {100.0 - $next}]]
                lappend blackAccs [list $acc $w]
            }
        }

        return [list [computeFinal $whiteAccs] [computeFinal $blackAccs]]
    }

    # The same arithmetic for a series that does not open on White's move: a
    # report's phase can start on Black's, and index 0 would then be read as
    # White's move and the two sides swapped. `firstSide` is the side that made
    # the move between index 0 and index 1 - "white" by default, which is what
    # calculate has always assumed.
    proc calculateFrom {centipawns {firstSide white}} {
        set n [llength $centipawns]
        if {$n < 2} { return {0.0 0.0} }
        set whiteFirst [expr {$firstSide eq "black" || $firstSide eq "b" ? 0 : 1}]

        # A contiguous series states one side per pair by alternation; the
        # sides are named here so the arithmetic itself never guesses.
        set pairs {}
        for {set i 0} {$i < $n - 1} {incr i} {
            lappend pairs [list [expr {($i % 2 == 0) == $whiteFirst ? "white" : "black"}] \
                [lindex $centipawns $i] [lindex $centipawns [expr {$i + 1}]]]
        }
        return [calculatePairs $pairs]
    }
    
    proc computeFinal {accWeights} {
        if {[llength $accWeights] == 0} { return 0.0 }
        
        # Volatility weighted mean
        set sumWeighted 0.0
        set sumWeights 0.0
        foreach item $accWeights {
            lassign $item acc w
            set sumWeighted [expr {$sumWeighted + $acc * $w}]
            set sumWeights [expr {$sumWeights + $w}]
        }
        set weightedMean [expr {$sumWeights > 0 ? $sumWeighted / $sumWeights : 0.0}]
        
        # Harmonic mean
        set sumHarmonicInv 0.0
        foreach item $accWeights {
            lassign $item acc w
            # Handle accuracy near 0 to avoid division by zero
            if {$acc < 0.01} { set acc 0.01 }
            set sumHarmonicInv [expr {$sumHarmonicInv + 1.0 / $acc}]
        }
        set harmonicMean [expr {[llength $accWeights] / $sumHarmonicInv}]
        
        return [expr {($weightedMean + $harmonicMean) / 2.0}]
    }
}
