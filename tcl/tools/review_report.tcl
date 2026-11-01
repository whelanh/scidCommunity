# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_report.tcl -- the deterministic part of a Game Review report.
#
# Accuracy, estimated Elo, label tally, key moments and the opening /
# middlegame / endgame split, from the pass's own results. No AI and no second
# search: a review already has every figure this needs.
#
# The formulas follow David Crandall's game-review plugin (and Patzer's
# classifier.ts / accuracy.ts / keyMoments.ts, MIT, (c) Arsen Apostolov and
# contributors); the licence notice for the ported parts is in move_labels.tcl,
# which carries the same attribution for the label ladder. The file-by-file
# record is docs/third-party-notices.md.
#
# One figure is not this file's to define: the accuracy is the application's own
# ::accuracy::calculate (accuracy.tcl), the same call the engine window's chart
# and the PGN viewer's chart make, so a game has one accuracy here and not two.
#
# mixedness and its scoring table are ported verbatim from the same plugin
# (plugins/game-review/11_cr_classify.tcl, ::crclass::mixedness and
# ::crclass::_mixedScore, GPL-2.0-or-later): it is the licence-compatible
# reference for the signal, and this project uses it unchanged so that a
# position scores the same here as it does there. Which signals close the
# opening, and in what order, is this file's own rule.
#
# The report is written as a block in the game's header comment, marked with
# [Game review] so a second pass replaces it rather than stacking another one.

namespace eval ::reviewreport {
    variable CLASS_WEIGHT
    array set CLASS_WEIGHT {
        brilliant 9 miss 8 great 7 blunder 6 mistake 4 inaccuracy 1.5
    }
    variable PIECE_VALUE
    array set PIECE_VALUE {p 1 n 3 b 3 r 5 q 9 k 0}
}

# Load the two pure modules the report shares with the label ladder.
if {[llength [info commands ::accuracy::winPercent]] == 0} {
    foreach f [list [file join $::scidTclDir tools accuracy.tcl] \
                   [file join [file dirname [info script]] accuracy.tcl]] {
        if {[file exists $f]} { catch { source -encoding utf-8 $f } ; break }
    }
}
if {[llength [info commands ::chessboard::fromFen]] == 0} {
    foreach f [list [file join $::scidTclDir utils chessboard.tcl] \
                   [file join [file dirname [info script]] .. utils chessboard.tcl]] {
        if {[file exists $f]} { catch { source -encoding utf-8 $f } ; break }
    }
}

# ::reviewdriver::sides answers w/b; the report speaks white/black.
proc ::reviewreport::sideWord {side} {
    return [expr {$side eq "b" ? "black" : "white"}]
}

proc ::reviewreport::winPct {cp} {
    return [::accuracy::winPercent $cp]
}

# The report's accuracy is the app's own: ::accuracy::calculate, the figure the
# engine window's chart and the PGN viewer's chart show for the same game. The
# report used to blend one of its own (volatility-weighted and harmonic means
# with a low-end floor and a shift) and call the result a CAPS accuracy, so the
# same game carried two numbers, and the name was a vendor's for an algorithm
# that is not published - a local variant cannot borrow it.
#
# calculate() reads index 0 as the position before White's move. The report
# hands accuracy.tcl the moves themselves - {side before after}, the same
# arithmetic in its pair form - because a phase slice can open on Black's move,
# and because the collected list can have holes: a book ply carries no
# evaluation, and a ply the pass has no verdict for is not in the list at all.
# Each pair carries the side that made the move, not the position it happens to
# hold; read by position, a hole hands every move after it to the other player.
proc ::reviewreport::evalSeries {moves} {
    set pairs {}
    foreach m $moves {
        set before [dict get $m eval_before_white]
        set after [dict get $m eval_after_white]
        # Book plies and moves the pass has no verdict for carry no evaluation.
        if {$before eq "" || $after eq ""} { continue }
        lappend pairs [list [dict get $m side] $before $after]
    }
    return $pairs
}

# {white <accuracy> black <accuracy>} over these moves, unrounded.
proc ::reviewreport::accuracyOf {moves} {
    set pairs [evalSeries $moves]
    if {![llength $pairs]} {
        return [dict create white 0.0 black 0.0]
    }
    lassign [::accuracy::calculatePairs $pairs] w b
    return [dict create white $w black $b]
}

# The report prints one decimal.
proc ::reviewreport::round1 {x} {
    return [expr {round($x * 10) / 10.0}]
}

proc ::reviewreport::eloFromAcpl {acpl} {
    set a [expr {max(0.0, $acpl)}]
    if {$a <= 8} {
        set elo [expr {2900 - ($a / 8.0) * 200}]
    } elseif {$a <= 12} {
        set elo [expr {2700 - (($a - 8) / 4.0) * 200}]
    } elseif {$a <= 18} {
        set elo [expr {2500 - (($a - 12) / 6.0) * 300}]
    } elseif {$a <= 25} {
        set elo [expr {2200 - (($a - 18) / 7.0) * 300}]
    } elseif {$a <= 35} {
        set elo [expr {1900 - (($a - 25) / 10.0) * 300}]
    } elseif {$a <= 50} {
        set elo [expr {1600 - (($a - 35) / 15.0) * 200}]
    } elseif {$a <= 70} {
        set elo [expr {1400 - (($a - 50) / 20.0) * 200}]
    } elseif {$a <= 100} {
        set elo [expr {1200 - (($a - 70) / 30.0) * 300}]
    } elseif {$a <= 150} {
        set elo [expr {900 - (($a - 100) / 50.0) * 300}]
    } elseif {$a <= 250} {
        set elo [expr {600 - (($a - 150) / 100.0) * 200}]
    } else {
        set elo [expr {max(300, 400 - ($a - 250) * 0.4)}]
    }
    return [expr {round(max(300, min(2900, $elo)))}]
}

proc ::reviewreport::estimateElo {accuracy acpl} {
    set fromAcpl [eloFromAcpl $acpl]
    set adjust [expr {max(-100.0, min(100.0, ($accuracy - 75) * 10))}]
    return [expr {round(max(300, min(2900, $fromAcpl + $adjust * 0.2)))}]
}

# Key moments: the biggest swings, weighted by how costly the label is, with
# chosen moments at least four plies apart.
proc ::reviewreport::keyMoments {moves {max 5}} {
    variable CLASS_WEIGHT
    set cands {}
    foreach m $moves {
        set cls [dict get $m classification]
        if {![info exists CLASS_WEIGHT($cls)]} { continue }
        set ply [dict get $m ply]
        set side [dict get $m side]
        set eb [expr {[dict get $m eval_before_white] ne "" ? [dict get $m eval_before_white] : 0}]
        set ea [expr {[dict get $m eval_after_white] ne "" ? [dict get $m eval_after_white] : 0}]
        set wpB [winPct $eb]
        set wpA [winPct $ea]
        set delta [expr {abs($wpB - $wpA)}]
        set loss [dict get $m cp_loss]
        set san ""
        catch { set san [dict get $m san] }
        set score [expr {min(600, $loss) + 60 * $CLASS_WEIGHT($cls) + 2 * $delta}]
        lappend cands [dict create ply $ply side $side san $san \
            classification $cls cp_loss $loss win_pct_delta $delta score $score]
    }
    set sorted [lsort -command {apply {{a b} {
        set sa [dict get $a score] ; set sb [dict get $b score]
        if {$sa > $sb} { return -1 }
        if {$sa < $sb} { return 1 }
        return 0
    }}} $cands]
    set picked {}
    foreach c $sorted {
        set skip 0
        foreach p $picked {
            if {abs([dict get $p ply] - [dict get $c ply]) <= 4} { set skip 1 ; break }
        }
        if {$skip} { continue }
        lappend picked $c
        if {[llength $picked] >= $max} { break }
    }
    return [lsort -integer -increasing -command {apply {{a b} {
        expr {[dict get $a ply] - [dict get $b ply]}
    }}} $picked]
}

# ── phases ──────────────────────────────────────────────────────────────────
# The opening ends on the first position where any of three signals fires:
#
#   * Smyrnov's test: both sides have developed every minor piece and connected
#     their rooks (smyrnovOver);
#   * mixedness above 150: how far the two armies have grown into each other,
#     which closes a sharp, tangled opening early so that a hypermodern line is
#     not held to Smyrnov's strictness (mixedness);
#   * ten or fewer majors-and-minors on the board: four of the initial fourteen
#     n/b/r/q are gone. The count is both sides together, never per side (per
#     side the initial count is seven), so `<= 10` is the safety net for a game
#     that trades material fast -- it fires early, which is why it is not the
#     primary signal, only the floor under the other two.
#
# There is no ply floor: a line that finishes developing on move 5 is out of the
# opening on move 4, and the report says so.
#
# The endgame begins when the material on the board is gone: 26 points in total,
# or six majors-and-minors. The middlegame is whatever is between the two: a
# game that ends before the opening has ended has no middlegame bucket and gets
# no middlegame prose, which is the truth about it.

proc ::reviewreport::boardOf {fen} {
    set pos ""
    catch { set pos [::chessboard::fromFen $fen] }
    return $pos
}

proc ::reviewreport::majorsMinors {fen} {
    set pos [boardOf $fen]
    if {$pos eq ""} { return 99 }
    set n 0
    foreach p [dict get $pos board] {
        if {$p ne "" && [string tolower $p] in {n b r q}} { incr n }
    }
    return $n
}

# Every piece on the board, both sides summed. The endgame boundary is a total
# on the board and not a share of it, so an uneven endgame (20 points against 5)
# is still an endgame; pawns count 1, which is what makes Speelman's "thirteen
# points a side" a material figure rather than a pieces-only one.
proc ::reviewreport::pointsOnBoard {fen} {
    variable PIECE_VALUE
    set pos [boardOf $fen]
    if {$pos eq ""} { return 99 }
    set points 0
    foreach p [dict get $pos board] {
        if {$p eq ""} { continue }
        incr points $PIECE_VALUE([string tolower $p])
    }
    return $points
}

# A minor piece still on the square it started on has not been developed. The
# home squares are c1/f1/b1/g1 and c8/f8/b8/g8; a captured minor cannot be on
# its square, so the square being empty satisfies the test and the game has
# moved on.
proc ::reviewreport::minorsDeveloped {board color} {
    set home [expr {$color eq "w" ? {1 2 5 6} : {57 58 61 62}}]
    foreach sq $home {
        set p [lindex $board $sq]
        if {$p ne "" && [::chessboard::colorOf $p] eq $color \
            && [string tolower $p] in {n b}} { return 0 }
    }
    return 1
}

# Two rooks are connected when they share a rank or a file with every square
# strictly between them empty -- on the back rank, on the second rank, on a
# file, anywhere. Fewer than two rooks makes the question moot: the back rank
# has stopped being the open question, and demanding a pair that no longer
# exists would leave such a game in the opening for ever.
proc ::reviewreport::rooksConnected {board color} {
    set rooks {}
    for {set sq 0} {$sq < 64} {incr sq} {
        set p [lindex $board $sq]
        if {$p ne "" && [::chessboard::colorOf $p] eq $color \
            && [string tolower $p] eq "r"} { lappend rooks $sq }
    }
    if {[llength $rooks] < 2} { return 1 }
    lassign $rooks r1 r2
    if {[expr {$r1 / 8}] == [expr {$r2 / 8}]} {
        for {set sq [expr {$r1 + 1}]} {$sq < $r2} {incr sq} {
            if {[lindex $board $sq] ne ""} { return 0 }
        }
        return 1
    }
    if {[expr {$r1 % 8}] == [expr {$r2 % 8}]} {
        for {set sq [expr {$r1 + 8}]} {$sq < $r2} {incr sq 8} {
            if {[lindex $board $sq] ne ""} { return 0 }
        }
        return 1
    }
    return 0
}

# Smyrnov's test: a side is out of the opening when every minor piece has left
# its original square and its rooks are connected. Both sides have to pass.
proc ::reviewreport::smyrnovOver {fen} {
    set pos [boardOf $fen]
    if {$pos eq ""} { return 0 }
    set board [dict get $pos board]
    foreach color {w b} {
        if {![minorsDeveloped $board $color]} { return 0 }
        if {![rooksConnected $board $color]} { return 0 }
    }
    return 1
}

# lichess mixedness: every 2x2 window of files a-g and ranks 1-7 is scored for
# pieces of the two colours standing in each other's space. Ported verbatim from
# David Crandall's game-review plugin (plugins/game-review/11_cr_classify.tcl,
# ::crclass::_mixedScore and ::crclass::mixedness), which is GPL-2.0-or-later
# like this project; the board reads are this file's own. The threshold the
# plugin uses to say a position is no longer an opening is 150.
proc ::reviewreport::_mixedScore {y white black} {
    switch -- $white {
        0 {
            switch -- $black {
                1 { return [expr {1 + $y}] }
                2 { return [expr {$y < 6 ? 2 + (6 - $y) : 0}] }
                3 - 4 { return [expr {$y < 7 ? 3 + (7 - $y) : 0}] }
            }
            return 0
        }
        1 {
            switch -- $black {
                0 { return [expr {1 + (8 - $y)}] }
                1 { return [expr {5 + abs(4 - $y)}] }
                2 { return [expr {4 + (7 - $y)}] }
                3 { return [expr {5 + (7 - $y)}] }
            }
            return 0
        }
        2 {
            switch -- $black {
                0 { return [expr {$y > 2 ? 2 + ($y - 2) : 0}] }
                1 { return [expr {4 + ($y - 1)}] }
                2 { return 7 }
            }
            return 0
        }
        3 {
            switch -- $black {
                0 { return [expr {$y > 1 ? 3 + ($y - 1) : 0}] }
                1 { return [expr {5 + ($y - 1)}] }
            }
            return 0
        }
        4 {
            switch -- $black {
                0 { return [expr {$y > 1 ? 3 + ($y - 1) : 0}] }
            }
            return 0
        }
    }
    return 0
}

proc ::reviewreport::mixedness {fen} {
    set pos [boardOf $fen]
    if {$pos eq ""} { return 0 }
    set board [dict get $pos board]
    set acc 0
    for {set ry 0} {$ry <= 6} {incr ry} {
        for {set fx 0} {$fx <= 6} {incr fx} {
            set w 0 ; set b 0
            foreach sq [list [expr {$ry*8 + $fx}] [expr {$ry*8 + $fx + 1}] \
                             [expr {($ry+1)*8 + $fx}] [expr {($ry+1)*8 + $fx + 1}]] {
                set p [lindex $board $sq]
                if {$p eq ""} continue
                if {[::chessboard::colorOf $p] eq "w"} { incr w } else { incr b }
            }
            incr acc [_mixedScore [expr {$ry + 1}] $w $b]
        }
    }
    return $acc
}

# The opening is over on the first of the three signals to fire.
proc ::reviewreport::openingOver {fen} {
    return [expr {[majorsMinors $fen] <= 10 ||
                  [smyrnovOver $fen] ||
                  [mixedness $fen] > 150}]
}

# The endgame test, in the terms of the sources it comes from. Speelman's
# thirteen points a side is 26 on the board (pawns at 1); Flear's "at most one
# piece besides kings and pawns" and Minev's board count are the same figure; the
# total is both sides summed, so an uneven endgame is not split. Queens off is
# the usual way to reach the total (Fine: the king activates), not a condition on
# it — a queen endgame inside 26 points is an endgame. The six majors-and-minors
# net is the safety valve for a game that trades pieces fast.
proc ::reviewreport::endgameNow {fen} {
    return [expr {[pointsOnBoard $fen] <= 26 || [majorsMinors $fen] <= 6}]
}

proc ::reviewreport::phaseStats {moves from to} {
    if {$from > $to} { return "" }
    set slice {}
    foreach m $moves {
        set ply [dict get $m ply]
        if {$ply >= $from && $ply <= $to} { lappend slice $m }
    }
    if {[llength $slice] < 4} { return "" }
    # A phase that is entirely book (or entirely unjudged) has no measured move
    # to report. Returning 0.0 for both sides printed a 0% phase and made it the
    # coach's "weakest phase"; no figures is the honest answer.
    if {![llength [evalSeries $slice]]} { return "" }
    set wCp {} ; set bCp {}
    foreach m $slice {
        if {[dict get $m eval_before_white] eq ""} { continue }
        set cls [dict get $m classification]
        set isBook [expr {[lsearch -exact {book forced} $cls] >= 0}]
        set side [dict get $m side]
        set before [expr {$side eq "white" ? [dict get $m eval_before_white] : -[dict get $m eval_before_white]}]
        set after [expr {$side eq "white" ? [dict get $m eval_after_white] : -[dict get $m eval_after_white]}]
        set cpl [expr {min(300, max(0, $before - $after))}]
        if {$isBook} { continue }
        if {$side eq "white"} { lappend wCp $cpl } else { lappend bCp $cpl }
    }
    set sumW 0.0 ; foreach x $wCp { set sumW [expr {$sumW + $x}] }
    set sumB 0.0 ; foreach x $bCp { set sumB [expr {$sumB + $x}] }
    # The phase's own series: it may open on Black's move, and accuracyOf
    # reads the side that moved first from the slice.
    set acc [accuracyOf $slice]
    return [dict create from $from to $to plies [llength $slice] \
        accW [round1 [dict get $acc white]] \
        accB [round1 [dict get $acc black]] \
        acplW [expr {[llength $wCp] ? round($sumW / [llength $wCp]) : 0}] \
        acplB [expr {[llength $bCp] ? round($sumB / [llength $bCp]) : 0}]]
}

# The opening ends at the first ply whose position is over, and `openingTo` is
# the ply before it: the position after ply N is the one the move at N reached,
# so the opening ends where the position last was still an opening.
proc ::reviewreport::phaseSplit {moves} {
    # The collected list can have holes: collect drops a ply it cannot judge, so
    # a 20-ply game can arrive as 19 entries. The bound is therefore the last
    # collected ply, not a count of entries; with no holes the two are equal.
    set total [expr {[llength $moves] ? [dict get [lindex $moves end] ply] : 0}]
    if {$total == 0} { return {} }
    set openingTo $total
    foreach m $moves {
        set ply [dict get $m ply]
        set fen [dict get $m fen_after]
        if {$fen ne "" && [openingOver $fen]} {
            set openingTo [expr {$ply - 1}]
            break
        }
    }
    set end ""
    foreach m $moves {
        set ply [dict get $m ply]
        if {$ply <= $openingTo} { continue }
        set fen [dict get $m fen_after]
        if {$fen ne "" && [endgameNow $fen]} { set end $ply ; break }
    }
    set midFrom [expr {$openingTo + 1}]
    set midTo [expr {$end eq "" ? $total : $end - 1}]
    set endFrom [expr {$end eq "" ? $total + 1 : $end}]
    set endStats ""
    if {$end ne ""} { set endStats [phaseStats $moves $endFrom $total] }
    return [dict create \
        opening [phaseStats $moves 1 $openingTo] \
        middlegame [phaseStats $moves $midFrom $midTo] \
        endgame $endStats]
}

# ── the pass's moves ────────────────────────────────────────────────────────

proc ::reviewreport::collect {p results} {
    set map [dict get $p map]
    set plan [dict get $p plan]
    set bookEnd 0
    catch { set bookEnd [dict get $p bookEnd] }
    set mpv 3
    catch { set mpv [dict get $p mpv] }
    set sides [::reviewdriver::sides $map]
    set verdicts [::reviewdriver::verdicts $map $results]
    set corrections {}
    catch { set corrections [dict get $p corrections] }
    set moves {}
    set cursor ""
    catch { set cursor [::review::cursorSave] }
    foreach ply $plan {
        if {[catch { sc_move ply $ply }] || [sc_pos location] != $ply} { continue }
        set san ""
        catch { set san [sc_game info previousMoveNT] }
        set fen_after ""
        catch { set fen_after [sc_pos fen] }
        catch { sc_move ply [expr {$ply - 1}] }
        set fen_before ""
        catch { set fen_before [sc_pos fen] }
        set side ""
        catch { set side [sideWord [dict get $sides [expr {$ply - 1}]]] }
        set played ""
        catch { set played [dict get [dict get $map moves] $ply] }
        if {$ply <= $bookEnd} {
            lappend moves [dict create ply $ply side $side san $san played $played \
                fen_before $fen_before fen_after $fen_after \
                classification book cp_loss 0 eval_before_white "" eval_after_white ""]
            continue
        }
        if {![dict exists $verdicts $ply]} { continue }
        set v [::reviewdriver::judge $map $results $sides $ply]
        if {$v eq ""} { continue }
        set label [dict get $v label]
        if {[dict exists $corrections $ply]} {
            set label [dict get $corrections $ply]
        }
        set before [dict get $v before]
        set after [dict get $v after]
        if {$before eq "" || $after eq ""} {
            set eb ""
            set ea ""
            set pb ""
            set pa ""
            set loss 0
        } else {
            set pb $before
            set pa $after
            set eb [expr {$side eq "black" ? -$before : $before}]
            set ea [expr {$side eq "black" ? -$after : $after}]
            set loss [expr {min(1000, max(0, $before - $after))}]
        }
        set best_pv ""
        catch { set best_pv [lindex [dict get $results [expr {$ply - 1}] 1] 3] }
        set best_uci [lindex $best_pv 0]
        # The engine's move in the notation the scoresheet uses. sc_pos may not
        # be there in a tclsh harness, and a missing name is better than a crash:
        # the comment falls back to describing the move.
        set best_san ""
        if {$best_uci ne ""} {
            if {[llength [info commands ::facts::sanLine]]} {
                catch { set best_san [lindex [::facts::sanLine $fen_before [list $best_uci]] 0] }
            } elseif {[llength [info commands sc_pos]]} {
                catch { set best_san [lindex [sc_pos coordToSAN $fen_before [list $best_uci]] 0] }
            }
        }
        lappend moves [dict create ply $ply side $side san $san played $played \
            fen_before $fen_before fen_after $fen_after \
            classification $label cp_loss $loss \
            eval_before_white $eb eval_after_white $ea eval_before_cp $eb \
            eval_after_cp $ea player_before $pb player_after $pa \
            best_uci $best_uci best_san $best_san best_pv $best_pv]
    }
    catch { if {$cursor ne ""} { ::review::cursorRestore $cursor } }
    return $moves
}

# ── the report ──────────────────────────────────────────────────────────────

proc ::reviewreport::sideSummary {moves side} {
    set cps {}
    set tally {}
    foreach m $moves {
        if {[dict get $m side] ne $side} { continue }
        set cls [dict get $m classification]
        if {[dict get $m eval_before_white] ne ""} {
            set before [expr {$side eq "white" ? [dict get $m eval_before_white] : -[dict get $m eval_before_white]}]
            set after [expr {$side eq "white" ? [dict get $m eval_after_white] : -[dict get $m eval_after_white]}]
            set isBook [expr {[lsearch -exact {book forced} $cls] >= 0}]
            if {!$isBook} { lappend cps [expr {min(300, max(0, $before - $after))}] }
        }
        if {$cls ne ""} { dict incr tally $cls }
    }
    # The game's own figure, not this side's moves on their own: the chart
    # beside the report reads the whole game's series, so the report does too.
    set acc [round1 [dict get [accuracyOf $moves] $side]]
    set acpl 0
    if {[llength $cps]} {
        set sum 0 ; foreach x $cps { set sum [expr {$sum + $x}] }
        set acpl [expr {round($sum / [llength $cps])}]
    }
    return [dict create accuracy $acc acpl $acpl \
        elo [estimateElo $acc $acpl] tally $tally]
}

proc ::reviewreport::moveNumber {ply} {
    if {$ply % 2 == 1} { return "[expr {($ply + 1) / 2}]." }
    return "[expr {$ply / 2}]..."
}

proc ::reviewreport::headerText {moves} {
    set w [sideSummary $moves white]
    set b [sideSummary $moves black]
    set out "\[Game review\]"
    append out "\n  White: [dict get $w accuracy]% accuracy, ACPL [dict get $w acpl], estimated Elo [dict get $w elo]"
    append out "\n  Black: [dict get $b accuracy]% accuracy, ACPL [dict get $b acpl], estimated Elo [dict get $b elo]"
    foreach {side label} [list White $w Black $b] {
        set parts {}
        foreach cls {brilliant great best excellent good book forced inaccuracy mistake miss blunder} {
            set n 0
            catch { set n [dict get [dict get $label tally] $cls] }
            if {$n > 0} { lappend parts "$n $cls" }
        }
        if {[llength $parts]} { append out "\n  $side labels: [join $parts {, }]" }
    }
    set keys [keyMoments $moves 5]
    if {[llength $keys]} {
        set parts {}
        foreach k $keys {
            lappend parts "[moveNumber [dict get $k ply]][dict get $k san] ([dict get $k classification])"
        }
        append out "\n  Key moments: [join $parts {; }]"
    }
    set phases [phaseSplit $moves]
    set pp {}
    foreach name {opening middlegame endgame} {
        set ph ""
        catch { set ph [dict get $phases $name] }
        if {$ph eq ""} { continue }
        set fromMove [expr {([dict get $ph from] + 1) / 2}]
        set toMove [expr {([dict get $ph to] + 1) / 2}]
        lappend pp "$name moves $fromMove-$toMove (W [dict get $ph accW] / B [dict get $ph accB])"
    }
    if {[llength $pp]} { append out "\n  Phases: [join $pp {; }]" }
    return $out
}

proc ::reviewreport::stripHeader {comment} {
    # The block is the marker line and the indented lines under it, and nothing
    # else. It used to be "the marker to the next [ or the end of the comment",
    # which ate a note the player typed below the block - and the block is
    # written last, so a note added under it sat behind the marker. A line that
    # is not indented ends the block, so anything after it survives.
    regsub -all {\[Game review\][^\n]*(?:\n[ \t]+[^\n]*)*} $comment "" comment
    return [string trim $comment]
}

# Add the report to the game's header comment. Called after the write phase,
# with the game still loaded; `p` must carry `report 1`.
proc ::reviewreport::write {p results} {
    if {![dict exists $p report] || ![dict get $p report]} { return }
    set moves [collect $p $results]
    if {![llength $moves]} { return }
    set text [headerText $moves]
    set cursor ""
    catch { set cursor [::review::cursorSave] }
    if {[catch { sc_move ply 0 }] || [sc_pos location] != 0} {
        catch { if {$cursor ne ""} { ::review::cursorRestore $cursor } }
        return
    }
    set old [stripHeader [sc_pos getComment]]
    sc_pos setComment [string trim "$old\n$text"]
    catch { if {$cursor ne ""} { ::review::cursorRestore $cursor } }
    return
}
