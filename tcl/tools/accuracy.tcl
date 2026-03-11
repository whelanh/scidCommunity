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
        set n [llength $centipawns]
        if {$n < 2} { return {0.0 0.0} }

        set winPercents {}
        foreach cp $centipawns {
            lappend winPercents [winPercent $cp]
        }

        # windowSize = (cps.size / 10).atLeast(2).atMost(8)
        # Note: cps.size in Lichess code is usually plies evaluated.
        set cps_size [expr {$n - 1}]
        set windowSize [expr {$cps_size / 10}]
        if {$windowSize < 2} { set windowSize 2 }
        if {$windowSize > 8} { set windowSize 8 }
        
        # Sliding windows for weights
        # Lichess code: fill(windowSize.atMost(allWinPercentValues.size) - 2)(firstWindow) ::: sliding(windowSize)
        set weights {}
        set fillCount [expr {min($windowSize, $n) - 2}]
        set firstWindow [lrange $winPercents 0 [expr {min($n, $windowSize) - 1}]]
        set w_first [stdDev $firstWindow]
        if {$w_first < 0.5} { set w_first 0.5 }
        if {$w_first > 12.0} { set w_first 12.0 }
        
        for {set i 0} {$i < $fillCount} {incr i} {
            lappend weights $w_first
        }
        for {set i 0} {$i <= [expr {$n - $windowSize}]} {incr i} {
            set window [lrange $winPercents $i [expr {$i + $windowSize - 1}]]
            set w [stdDev $window]
            if {$w < 0.5} { set w 0.5 }
            if {$w > 12.0} { set w 12.0 }
            lappend weights $w
        }

        set whiteAccs {}
        set blackAccs {}
        
        # moves are between (prev, next)
        set nMoves [expr {$n - 1}]
        # weights length should match nMoves
        for {set i 0} {$i < $nMoves} {incr i} {
            set prev [lindex $winPercents $i]
            set next [lindex $winPercents [expr {$i + 1}]]
            set w [lindex $weights $i]
            
            if {$i % 2 == 0} {
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
