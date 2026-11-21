#!/usr/bin/env tclsh
# Feasibility probe: run the repository's own review verdict code
# (::reviewdriver::judge, ::movelabels::label/refine) on real Lichess puzzle
# solutions, with a real Stockfish doing the search the review pass would do
# (MultiPV 3, depth 18 = ::review DEFAULTS).
#
# Usage: tclsh puzzle_review_probe.tcl <repo> <puzzles.tsv> <out.tsv> [depth] [mpv]
#   <puzzles.tsv> comes from extract.py; Stockfish is expected at /usr/games/stockfish
#   or in $STOCKFISH.

lassign $argv root inTsv outTsv depth mpv
if {$depth eq ""} { set depth 18 }
if {$mpv eq ""} { set mpv 3 }

source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools score_seed.tcl]
source [file join $root tcl enginecfg.tcl]
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools comment_colors.tcl]
source [file join $root tcl tools game_review.tcl]
source [file join $root tcl tools review_driver.tcl]

source [file join [file dirname [info script]] sanlib.tcl]

# ---- a bare Stockfish connection --------------------------------------------
set sfExe /usr/games/stockfish
if {[info exists ::env(STOCKFISH)]} { set sfExe $::env(STOCKFISH) }
set sf [open "|$sfExe" r+]
fconfigure $sf -buffering line
proc sfSend {s} { puts $::sf $s }
proc sfWait {token} {
    while {[gets $::sf line] >= 0} { if {[string match "$token*" $line]} { return $line } }
    error "engine died"
}
sfSend uci; sfWait uciok
sfSend "setoption name MultiPV value $mpv"
set threads 3
if {[info exists ::env(THREADS)]} { set threads $::env(THREADS) }
sfSend "setoption name Threads value $threads"
sfSend "setoption name Hash value 128"
sfSend isready; sfWait readyok

# Search one "position ..." spec; return {lines firstDepthStable}
#   lines: mpvIndex -> {depth score type pv} (exact scores only, deepest kept)
#   bestByDepth: depth -> first move of MultiPV 1 at that depth
proc search {spec} {
    sfSend "ucinewgame"
    sfSend $spec
    sfSend "go depth $::depth"
    set lines [dict create]
    set bestByDepth [dict create]
    while {[gets $::sf line] >= 0} {
        if {[string match "bestmove*" $line]} break
        if {![string match "info *" $line] || [string first " pv " $line] < 0} continue
        if {[regexp {lowerbound|upperbound} $line]} continue
        regexp { depth (\d+)} $line -> d
        set k 1; regexp { multipv (\d+)} $line -> k
        if {![regexp { score (cp|mate) (-?\d+)} $line -> type score]} continue
        regexp { pv (.*)$} $line -> pv
        dict set lines $k [list $d $score $type $pv]
        if {$k == 1} { dict set bestByDepth $d [lindex $pv 0] }
    }
    return [list $lines $bestByDepth]
}

# The move a short, independent search prefers: what "obvious" means for the
# Woodpecker profile's `!` (a move this search does not choose is not obvious).
proc shallowBest {spec {d 3}} {
    sfSend "setoption name MultiPV value 1"
    sfSend "ucinewgame"
    sfSend $spec
    sfSend "go depth $d"
    set best [lindex [sfWait bestmove] 1]
    sfSend "setoption name MultiPV value $::mpv"
    return $best
}

# first depth from which MultiPV-1 keeps choosing `move` to the end
proc stableDepth {bestByDepth move} {
    set stable ""
    foreach d [lsort -integer [dict keys $bestByDepth]] {
        if {[dict get $bestByDepth $d] eq $move} {
            if {$stable eq ""} { set stable $d }
        } else {
            set stable ""
        }
    }
    return $stable
}

set in [open $inTsv r]
set out [open $outTsv w]
puts $out [join {id tier rating themes ply mover_index played engine_best is_best base_label nag refined refined_nag cp_before cp_after gap12 legal stable_depth hanging d3best sound_sac capture check} "\t"]
set n 0
while {[gets $in row] >= 0} {
    lassign [split $row "\t"] id tier rating initialPly solution themes pgn
    if {[catch { set fen0 [fenAfterPgn $pgn [expr {$initialPly + 1}]] } err]} {
        puts stderr "skip $id: $err"; continue
    }
    # The review's map, built the way ::review::mainLineMap builds one from
    # `sc_game UCI_mainLine` of a game that starts from this FEN.
    set ml [list "position fen $fen0 moves"]
    foreach m $solution { lappend ml $m }
    set map [::review::mainLineMap $ml]
    set plies [dict get $map plies]
    set results [dict create]
    set stab [dict create]
    for {set p 0} {$p <= $plies} {incr p} {
        lassign [search [dict get [dict get $map positions] $p]] lines bbd
        dict set results $p $lines
        dict set stab $p $bbd
    }
    set sides [::reviewdriver::sides $map]
    # board FEN for each ply, for the refinement's board tests
    set pos [::chessboard::fromFen $fen0]
    set fens [list $fen0]
    foreach m $solution { set pos [::chessboard::makeMove $pos $m]; lappend fens [::chessboard::toFen $pos] }
    # the solver's moves are plies 1, 3, 5 ... of the solution
    for {set p 1} {$p <= $plies} {incr p 2} {
        set v [::reviewdriver::judge $map $results $sides $p]
        set played [lindex $solution [expr {$p - 1}]]
        set lines [dict get $results [expr {$p - 1}]]
        set engineBest [lindex [lindex [dict get $lines 1] 3] 0]
        if {$v eq ""} {
            puts $out [join [list $id $tier $rating $themes $p [expr {($p+1)/2}] $played $engineBest "" none "" none "" "" "" "" "" "" ""] "\t"]
            continue
        }
        set label [dict get $v label]
        set before [dict get $v before]
        set after [dict get $v after]
        set cands {}
        foreach k [lsort -integer [dict keys $lines]] {
            set c [::reviewdriver::lineScore [dict get $lines $k]]
            if {$c ne ""} { lappend cands $c }
        }
        set gap ""
        if {[llength $cands] >= 2} { set gap [expr {[lindex $cands 0] - [lindex $cands 1]}] }
        set fb [lindex $fens [expr {$p - 1}]]
        set fa [lindex $fens $p]
        set pvAfter {}
        if {[dict exists $results $p] && [dict exists [dict get $results $p] 1]} {
            set pvAfter [lindex [dict get [dict get $results $p] 1] 3]
        }
        set legal [llength [::chessboard::legalMoves [::chessboard::fromFen $fb]]]
        set ctx [dict create is_best [dict get $v isBest] cp_before $before cp_after $after \
            cp_loss [::movelabels::cpLoss $before $after] win_drop [::movelabels::winDrop $before $after] \
            ply $p in_book 0 legal_moves $legal candidates $cands played $played \
            fen_before $fb fen_after $fa pv_after_played $pvAfter]
        set refined [::movelabels::refine $label $ctx]
        set hang ""
        catch { set hang [::chessboard::hangingMaterial $fb $fa [lindex [split $fb] 1]] }
        set sd [stableDepth [dict get $stab [expr {$p - 1}]] $played]
        set d3 [shallowBest [dict get [dict get $map positions] [expr {$p - 1}]]]
        # refine's sacrifice test without its +5 ceiling
        set stm [lindex [split $fb] 1]
        set sac 0
        if {[dict get $v isBest] && $hang ne "" && $hang >= 2 && [llength $pvAfter] \
            && ![::movelabels::isTrivialRecapture $stm $fb $pvAfter $fa]} { set sac 1 }
        set posB [::chessboard::fromFen $fb]
        set cap [expr {[::movelabels::captureVictim $posB $played] ne ""}]
        set posA [::chessboard::fromFen $fa]
        set chk [::chessboard::inCheck $posA [dict get $posA side]]
        puts $out [join [list $id $tier $rating $themes $p [expr {($p+1)/2}] $played $engineBest \
            [dict get $v isBest] $label [::review::nagForLabel $label] $refined [::review::nagForLabel $refined] \
            $before $after $gap $legal $sd $hang $d3 $sac $cap $chk] "\t"]
    }
    flush $out
    incr n
    if {$n % 10 == 0} { puts stderr "$n puzzles" }
}
close $out
sfSend quit
catch { close $sf }
puts "done: $n puzzles"
