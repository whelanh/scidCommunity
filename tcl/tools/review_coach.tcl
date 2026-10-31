# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_coach.tcl -- the facts a coach may use, without a model.
#
# The deterministic half of the coach layer: every claim it makes about a
# position comes from ::facts::forMove (comment_facts.tcl), and every claim
# about the game as a whole comes from the deterministic report
# (review_report.tcl). Nothing here calls a model, a network or the engine, so
# all of it is testable in tclsh.
#
# The prompt texts and the queue that sends them are the next slice, not this
# file: this half exists to be checked on its own first.
#
# The summary and phase facts are adapted from David Crandall's "game-review"
# plugin (15_cr_llm.tcl and 17_cr_facts.tcl), which is GPL-2.0-or-later like this
# project and the reference for this layer rather than a runtime dependency. The
# move facts themselves are comment_facts.tcl, itself derived from Patzer's
# comment_facts and carrying its MIT notice. The file-by-file record is
# docs/third-party-notices.md.

namespace eval ::reviewcoach {}

proc ::reviewcoach::gameNumber {} {
    if {[catch { sc_game number } n]} { return "" }
    return $n
}

# Load what the facts and report need when the caller has not.
if {[llength [info commands ::chessboard::fromFen]] == 0} {
    foreach f [list [file join $::scidTclDir utils chessboard.tcl] \
                   [file join [file dirname [info script]] .. utils chessboard.tcl]] {
        if {[file exists $f]} { catch { source -encoding utf-8 $f } ; break }
    }
}
if {[llength [info commands ::facts::forMove]] == 0} {
    foreach f [list [file join $::scidTclDir tools comment_facts.tcl] \
                   [file join [file dirname [info script]] comment_facts.tcl]] {
        if {[file exists $f]} { catch { source -encoding utf-8 $f } ; break }
    }
}
if {[llength [info commands ::reviewreport::sideSummary]] == 0} {
    foreach f [list [file join $::scidTclDir tools review_report.tcl] \
                   [file join [file dirname [info script]] review_report.tcl]] {
        if {[file exists $f]} { catch { source -encoding utf-8 $f } ; break }
    }
}

proc ::reviewcoach::balanceWord {cpWhite} {
    set a [expr {abs($cpWhite)}]
    if {$a < 100} { return "level" }
    set who [expr {$cpWhite > 0 ? "White" : "Black"}]
    if {$a < 300} { return "$who somewhat better" }
    if {$a < 600} { return "$who clearly better" }
    if {$a < 1000} { return "$who winning" }
    return "$who completely winning"
}

proc ::reviewcoach::levelBand {elo} {
    if {$elo <= 0} { return "" }
    if {$elo < 800}  { return "beginner" }
    if {$elo < 1100} { return "improver" }
    if {$elo < 1400} { return "club player" }
    if {$elo < 1700} { return "strong club player" }
    if {$elo < 2000} { return "tournament player" }
    return "expert"
}

# The coaching figures, from the mover's point of view. The model never sees
# these as numbers; they weight and select what the FACTS describe.
proc ::reviewcoach::_cpSwing {m} {
    if {![dict exists $m player_before] || [dict get $m player_before] eq ""} { return 0.0 }
    if {![dict exists $m player_after] || [dict get $m player_after] eq ""} { return 0.0 }
    return [expr {[dict get $m player_before] - [dict get $m player_after]}]
}

proc ::reviewcoach::_winSwing {m} {
    if {![dict exists $m player_before] || [dict get $m player_before] eq ""} { return 0.0 }
    if {![dict exists $m player_after] || [dict get $m player_after] eq ""} { return 0.0 }
    return [expr {[::reviewreport::winPct [dict get $m player_before]] - [::reviewreport::winPct [dict get $m player_after]]}]
}

proc ::reviewcoach::contestion {evalWhite} {
    set a [expr {abs($evalWhite)}]
    if {$a <= 200} { return 1.0 }
    if {$a >= 800} { return 0.0 }
    return [expr {(800 - $a) / 600.0}]
}

proc ::reviewcoach::_significance {m} {
    set ev [expr {[dict exists $m eval_before_cp] ? [dict get $m eval_before_cp] : 0}]
    return [expr {[_winSwing $m] * [contestion $ev]}]
}

proc ::reviewcoach::_bySignificance {moves limit} {
    set sorted [lsort -command {apply {{a b} {
        set sa [::reviewcoach::_significance $a] ; set sb [::reviewcoach::_significance $b]
        if {$sa > $sb} { return -1 }
        if {$sa < $sb} { return 1 }
        return 0
    }}} $moves]
    return [lrange $sorted 0 [expr {$limit - 1}]]
}

proc ::reviewcoach::_bySwing {moves limit} {
    set sorted [lsort -command {apply {{a b} {
        set sa [::reviewcoach::_cpSwing $a] ; set sb [::reviewcoach::_cpSwing $b]
        if {$sa > $sb} { return -1 }
        if {$sa < $sb} { return 1 }
        return 0
    }}} $moves]
    return [lrange $sorted 0 [expr {$limit - 1}]]
}

proc ::reviewcoach::moveAt {moves ply} {
    foreach m $moves { if {[dict get $m ply] == $ply} { return $m } }
    return ""
}

# The move the game turned on.
#
# Two facts have to agree: the move has to be one of the loser's errors, and it
# has to be the error that started the collapse rather than the later move that
# crossed an arbitrary line. After Black's queen blunder a game can still be at
# 13% - not "practically lost" by the 10% rule, but the move a coach calls the
# turning point all the same. So: find the last position at which the loser was
# still in the game (20%), and take the costliest error by the loser after it.
# If nothing there is an error, fall back to the 10% crossing.
proc ::reviewcoach::turningMove {moves} {
    set LAST ""
    foreach m $moves {
        if {[dict exists $m unsearched]} continue
        if {![dict exists $m eval_after_cp] || [dict get $m eval_after_cp] eq ""} continue
        set LAST $m
    }
    if {$LAST eq ""} { return "" }
    set final [dict get $LAST eval_after_cp]
    if {$final == 0} { return "" }
    set LINE 10.0
    set loser [expr {$final > 0 ? "black" : "white"}]
    set seq {}
    foreach m $moves {
        if {[dict exists $m unsearched]} continue
        if {![dict exists $m eval_after_cp] || [dict get $m eval_after_cp] eq ""} continue
        set ev [dict get $m eval_after_cp]
        set wp [expr {$loser eq "white" ? [::reviewreport::winPct $ev] : [::reviewreport::winPct [expr {-$ev}]]}]
        lappend seq [list [dict get $m ply] $wp $m]
    }
    set n [llength $seq]
    # The last point the loser was still competitive. Everything after it is
    # the collapse, and the error that began it is the turning point.
    set comp -1
    for {set k 0} {$k < $n} {incr k} {
        lassign [lindex $seq $k] ply wp m
        if {$wp >= 20.0} { set comp $k }
    }
    set best ""
    set bestSig 0.0
    for {set k [expr {$comp + 1}]} {$k < $n} {incr k} {
        lassign [lindex $seq $k] ply wp m
        set cls ""
        catch { set cls [dict get $m classification] }
        if {[lsearch -exact {inaccuracy mistake miss blunder} $cls] < 0} continue
        set side ""
        catch { set side [dict get $m side] }
        if {$side ne $loser} continue
        set sig [_significance $m]
        if {$sig > $bestSig} { set bestSig $sig ; set best $m }
    }
    if {$best ne "" && $bestSig >= 0.5} { return $best }
    # No error in the collapse: name the move that crossed the 10% line.
    set start $n
    for {set k [expr {$n - 1}]} {$k >= 0} {incr k -1} {
        lassign [lindex $seq $k] ply wp m
        if {$wp < $LINE} { set start $k } else { break }
    }
    if {$start < $n} { return [lindex $seq $start 2] }
    return ""
}

# What actually punished a move: the reply, whether it attacked the piece that
# moved, the fork that followed, the net material and the forced answer.
proc ::reviewcoach::punishmentFacts {turn moves} {
    set out {}
    if {$turn eq ""} { return $out }
    set tply [dict get $turn ply]
    set td [::facts::describeMove [dict get $turn fen_before] [dict get $turn played]]
    set tside [expr {[dict get $td side] eq "White" ? "w" : "b"}]
    set tpiece [dict get $td piece]
    set reply [moveAt $moves [expr {$tply + 1}]]
    if {$reply ne ""} {
        lappend out "the punishment: [::facts::phaseMoveLine $reply]"
        if {[catch {
            set rpos [::chessboard::makeMove [::chessboard::fromFen [dict get $reply fen_before]] [dict get $reply played]]
            set tsq [dict get $td to]
            set hits [::facts::attackersOf $rpos [::chessboard::sqIndex $tsq] [::facts::other $tside]]
        }]} { set hits {} }
        if {[llength $hits]} { lappend out "the punishment attacks the $tpiece on $tsq" }
        foreach pply [list [expr {$tply + 1}] [expr {$tply + 2}] [expr {$tply + 3}]] {
            set pm [moveAt $moves $pply]
            if {$pm eq ""} continue
            set fl ""
            catch { set fl [::facts::forkLine [dict get $pm fen_before] [dict get $pm played]] }
            if {$fl ne ""} { lappend out $fl ; break }
        }
        set later [moveAt $moves [expr {$tply + 6}]] 
        if {$later ne ""} {
            set swing ""
            catch { set swing [::facts::materialSwing [dict get $turn fen_before] [dict get $later fen_after]] }
            if {$swing ne ""} { lappend out "net material after the punishment: $swing" }
        }
        set answer [moveAt $moves [expr {$tply + 2}]]
        if {$answer ne ""} {
            set prevLoss [expr {[dict exists $turn cp_loss] ? [dict get $turn cp_loss] : 0}]
            set ansLoss [expr {[dict exists $answer cp_loss] ? [dict get $answer cp_loss] : 0}]
            if {$prevLoss >= 200 && $ansLoss <= 50} {
                set txt [::facts::phaseMoveLine $answer -noclass]
                lappend out "the punished side answered with: $txt, which was forced by the earlier mistake"
            } else {
                lappend out "the punished side answered with: [::facts::phaseMoveLine $answer]"
            }
        }
        set after [moveAt $moves [expr {$tply + 3}]]
        if {$after ne ""} { lappend out "and then: [::facts::phaseMoveLine $after]" }
        if {$answer ne "" && $after ne ""} {
            if {[catch {
                set da [::facts::describeMove [dict get $answer fen_before] [dict get $answer played]]
                set df [::facts::describeMove [dict get $after fen_before] [dict get $after played]]
                set took [dict get $da capture]
                set lost [dict get $df capture]
            }]} { set took "" ; set lost "" }
            if {$took ne "" && $lost ne ""} {
                set who [expr {$tside eq "w" ? "White" : "Black"}]
                lappend out "netted out: $who's $lost went for a $took"
            }
        }
    }
    return $out
}

# Everything a move prompt may say about one move.
proc ::reviewcoach::moveFacts {m} {
    set lines {}
    if {[dict exists $m classification]} {
        lappend lines "verdict: [dict get $m classification]"
    }
    # forMove returns the whole block, newline-joined: append it as one line list
    # element rather than iterating it, or every word becomes its own line.
    lappend lines [::facts::forMove $m]
    return [join $lines "\n"]
}

# The game-level facts: the result and opening, each side's measured level, the
# move the game turned on and what punished it, the errors that changed the
# result, each side's best moves, the chances offered and the weakest phases.
# The figures themselves stay in the report header; the model is told not to
# repeat numbers, so they are not repeated here.
proc ::reviewcoach::summaryFacts {moves game} {
    set w [::reviewreport::sideSummary $moves white]
    set b [::reviewreport::sideSummary $moves black]
    set lines {}
    set bw [levelBand [dict get $w elo]]
    set bb [levelBand [dict get $b elo]]
    if {$bw ne "" && $bb ne ""} {
        lappend lines "measured level: White $bw, Black $bb"
        lappend lines "the weaker side: [expr {[dict get $w elo] >= [dict get $b elo] ? "Black" : "White"}]"
    }
    set res ""
    catch { set res [string trim [dict get $game result]] }
    if {$res eq "1-0"} { lappend lines "result: White won" } \
    elseif {$res eq "0-1"} { lappend lines "result: Black won" } \
    elseif {$res eq "1/2-1/2"} { lappend lines "result: drawn" }
    set opening ""
    catch { set opening [dict get $game opening] }
    if {$opening ne ""} { lappend lines "opening: $opening" } \
    else { lappend lines "opening: no name recorded" }
    set tree ""
    catch { set tree [dict get $game database] }
    if {$tree ne ""} { lappend lines "database: $tree" }

    set decided ""
    foreach m $moves {
        if {[dict exists $m unsearched]} continue
        if {![dict exists $m eval_after_cp] || [dict get $m eval_after_cp] eq ""} continue
        if {abs([dict get $m eval_after_cp]) >= 800} { set decided [dict get $m ply] ; break }
    }
    if {$decided ne ""} {
        lappend lines "the game was decided by move [expr {($decided + 1) / 2}], after which the result was no longer in doubt"
    }

    set bad {}
    set whiteCostly {}
    set blackCostly {}
    set gains {}
    foreach m $moves {
        if {[dict exists $m unsearched]} continue
        set cls ""
        catch { set cls [dict get $m classification] }
        set side [dict get $m side]
        if {[lsearch -exact {inaccuracy mistake miss blunder} $cls] >= 0} {
            lappend bad $m
            if {$side eq "white"} { lappend whiteCostly $m } else { lappend blackCostly $m }
        } elseif {[lsearch -exact {book forced} $cls] < 0} {
            set gain [expr {-[_winSwing $m]}]
            if {$gain >= 10.0} { lappend gains [list $gain $side $m] }
        }
    }
    set whiteBest {}
    set blackBest {}
    foreach e [lsort -command {apply {{a b} {
        set sa [lindex $a 0] ; set sb [lindex $b 0]
        if {$sa > $sb} { return -1 }
        if {$sa < $sb} { return 1 }
        return 0
    }}} $gains] {
        lassign $e gain side m
        if {$side eq "white"} {
            if {[llength $whiteBest] < 2} { lappend whiteBest $m }
        } else {
            if {[llength $blackBest] < 2} { lappend blackBest $m }
        }
    }

    set turn [turningMove $moves]
    if {$turn eq ""} {
        foreach m [_bySignificance $bad 1] { set turn $m }
    }
    if {$turn ne ""} { lappend lines "the game turned here: [::facts::phaseMoveLine $turn]" }
    foreach l [punishmentFacts $turn $moves] { lappend lines $l }

    foreach {who lst} [list White $whiteCostly Black $blackCostly] {
        set picked {}
        foreach m [_bySwing $lst 8] {
            if {[_significance $m] < 0.5} continue
            if {[_winSwing $m] < 10.0} continue
            if {$turn ne "" && [dict get $m ply] == [dict get $turn ply]} continue
            lappend picked $m
            if {[llength $picked] >= 2} break
        }
        if {![llength $picked]} continue
        set out {}
        foreach m $picked { lappend out [::facts::phaseMoveLine $m] }
        lappend lines "errors by $who that changed the result: [join $out {; }]"
    }
    foreach {who lst} [list White $whiteBest Black $blackBest] {
        set picked [lrange $lst 0 1]
        if {![llength $picked]} continue
        set out {}
        foreach m $picked { lappend out [::facts::phaseMoveLine $m] }
        lappend lines "$who's best moves: [join $out {; }]"
    }

    set gifts {}
    foreach m [_bySwing $bad 2] {
        set ply [dict get $m ply]
        set ans [moveAt $moves [expr {$ply + 1}]]
        set line "[::facts::phaseMoveLine $m]"
        if {$ans ne ""} { append line "; answered by [::facts::phaseMoveLine $ans]" } \
        else { append line "; nobody could answer it, the game was over" }
        lappend gifts $line
    }
    if {[llength $gifts]} {
        lappend lines "chances offered and taken:"
        foreach g $gifts { lappend lines "  $g" }
    }

    set phases [::reviewreport::phaseSplit $moves]
    set weak {}
    foreach side {white black} {
        set key [expr {$side eq "white" ? "accW" : "accB"}]
        set worst "" ; set worstAcc 101.0
        foreach ph {opening middlegame endgame} {
            set st ""
            catch { set st [dict get $phases $ph] }
            if {$st eq ""} continue
            set a [dict get $st $key]
            if {$a < $worstAcc} { set worstAcc $a ; set worst $ph }
        }
        if {$worst ne ""} {
            lappend weak "[expr {$side eq "white" ? "White" : "Black"}]'s weakest phase: $worst"
        }
    }
    if {[llength $weak]} { lappend lines [join $weak {; }] }
    return [join $lines "\n"]
}

proc ::reviewcoach::gameFacts {moves game} {
    return [summaryFacts $moves $game]
}

proc ::reviewcoach::phaseNotable {moves phase} {
    set phases [::reviewreport::phaseSplit $moves]
    set st ""
    catch { set st [dict get $phases $phase] }
    if {$st eq ""} { return {} }
    set out {}
    foreach m $moves {
        set ply [dict get $m ply]
        if {$ply < [dict get $st from] || $ply > [dict get $st to]} continue
        if {[dict exists $m unsearched]} continue
        set sw [_significance $m]
        set cls ""
        catch { set cls [dict get $m classification] }
        if {$sw >= 1.0 || ($cls eq "brilliant" && $sw <= -1)} { lappend out $m }
        if {[llength $out] >= 8} break
    }
    return $out
}

proc ::reviewcoach::phaseFacts {moves phase} {
    set phases [::reviewreport::phaseSplit $moves]
    set st ""
    catch { set st [dict get $phases $phase] }
    if {$st eq ""} { return "" }
    set lines {}
    lappend lines "phase: $phase"
    set fromMove [expr {([dict get $st from] + 1) / 2}]
    set toMove [expr {([dict get $st to] + 1) / 2}]
    lappend lines "moves in this phase: $fromMove-$toMove"
    lappend lines "accuracy: White [format %.1f [dict get $st accW]], Black [format %.1f [dict get $st accB]]"
    lappend lines "average centipawn loss: White [dict get $st acplW], Black [dict get $st acplB]"
    set firstM "" ; set lastM ""
    foreach m $moves {
        set ply [dict get $m ply]
        if {$ply < [dict get $st from] || $ply > [dict get $st to]} continue
        if {$firstM eq ""} { set firstM $m }
        set lastM $m
    }
    if {$firstM ne ""} {
        # A move with no evaluation still had a board: the state line is about
        # the position, so a missing number reads as level rather than raising.
        set b0 0 ; set b1 0
        if {[dict exists $firstM eval_before_white] && [dict get $firstM eval_before_white] ne ""} {
            set b0 [dict get $firstM eval_before_white]
        }
        if {[dict exists $lastM eval_after_white] && [dict get $lastM eval_after_white] ne ""} {
            set b1 [dict get $lastM eval_after_white]
        }
        lappend lines "state at the start of this phase: [balanceWord $b0]"
        lappend lines "state at the end of this phase: [balanceWord $b1]"
    }
    set notable {}
    foreach m [phaseNotable $moves $phase] { lappend notable [::facts::phaseMoveLine $m] }
    if {[llength $notable]} {
        lappend lines "the moves that shaped this phase, in game order:"
        foreach n $notable { lappend lines "  $n" }
    } else {
        lappend lines "moves you may name in this phase: none"
    }
    return [join $lines "\n"]
}

# Remove the prose this layer wrote, keeping the review's own label, eval and
# marks. A phase block or a coach note is marked, so a re-run replaces it.
proc ::reviewcoach::strip {comment} {
    regsub -all {\[Phase (?:opening|middlegame|endgame)\][^\[]*} $comment "" comment
    regsub -all {\[Coach\][^\[]*} $comment "" comment
    return [string trim $comment]
}

# The header block is three labelled lines. The report's own header lines are
# indented under [Game review] and say "White:", "Black:" and "Phases:", so a
# label at the start of a line is this layer's and nobody else's.
proc ::reviewcoach::stripHeader {comment} {
    set out [regsub -line -all {^(Summary|Level|Opening):.*$} $comment ""]
    regsub -all {\n\n\n+} $out "\n\n" out
    return [string trim $out]
}

# Take the coach's header block off, if this game has one.
proc ::reviewcoach::stripHeaderAtStart {} {
    if {[catch { sc_move ply 0 }] || [sc_pos location] != 0} { return }
    set old [sc_pos getComment]
    set new [stripHeader $old]
    if {$new ne [string trim $old]} { sc_pos setComment $new }
    return
}
