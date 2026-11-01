# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_coach.tcl -- the facts a coach may use, and the prompts built from them.
#
# The deterministic half: every claim it makes about a position comes from
# ::facts::forMove (comment_facts.tcl), and every claim about the game as a
# whole comes from the deterministic report (review_report.tcl). Nothing here
# calls a model, a network or the engine, so all of it is testable in tclsh.
#
# The prompt texts turn those facts into a request. The model never analyses: a
# prompt carries the fact block for its subject and asks for prose about that
# block only, so a reply that names a move, a number or a phase that is not in
# the block is a failed request, not text to fix up. The shape is a short task,
# hard rules ("use only FACTS; never name what is not there"), and the FACTS
# block last. The model is a narrator, not a judge.
#
# The queue that sends the prompts, and the prose that comes back, are the next
# slice, not this file.
#
# The summary and phase facts, and the prompt texts, are adapted from David
# Crandall's "game-review" plugin (15_cr_llm.tcl and 17_cr_facts.tcl), which is
# GPL-2.0-or-later like this project and the reference for this layer rather
# than a runtime dependency. The move facts themselves are comment_facts.tcl,
# itself derived from Patzer's comment_facts and carrying its MIT notice. The
# file-by-file record is docs/third-party-notices.md.
#
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

proc ::reviewcoach::banWords {label} {
    set out {}
    foreach w {inaccuracy mistake blunder miss} {
        if {$w ne $label} { lappend out "\"$w\"" }
    }
    return [join $out {, }]
}

proc ::reviewcoach::movePrompt {m} {
    set facts [moveFacts $m]
    set label [dict get $m classification]
    return "You are a chess coach writing one annotation for a scoresheet.
Explain in plain English WHY this move is judged a $label: what it fails to do, what it allows, and what the better move achieves. Write for a club player reading the game later.
Rules:
- Use only the FACTS below. Never name a piece, square or move that is not in FACTS.
- FACTS lists every piece on the board: a piece it does not list is not there, so do not mention it.
- Do not describe what a line shows beyond the moves printed in it, and do not claim a move left something untouched or unprotected unless FACTS says so.
- Never mention castling, en passant, repetition or the fifty-move rule beyond what the corresponding FACTS lines say.
- FACTS includes the engine's line; you may refer to moves in that line (and only those) to show what the better move achieves.
- If FACTS says it gives no reason for the engine's preference, or that the move played achieves the same thing, do not supply a reason of your own: say only that the engine preferred the better move.
- Do NOT mention centipawns, evaluations, win percentages, accuracy, or any number at all. The reader already sees the score next to the move.
- Do not repeat the move number and do not use the words [banWords $label].
- No lists, no headings, no preamble. At most two sentences, plain prose.
FACTS:
$facts"
}

proc ::reviewcoach::momentPrompt {m} {
    return [movePrompt $m]
}

proc ::reviewcoach::phasePrompt {phase facts} {
    return "You are a chess coach writing one paragraph about the $phase of a game, for the scoresheet.
Write about both sides by colour - \"White\" and \"Black\". Never address anyone as \"you\".

Rules:
- Use only the FACTS below. Never name a piece, square or move that is not in FACTS.
- Open with one sentence on the state of this phase: who stood better when it began and whether that changed by its end.
- Then say what changed it, as consequences: one clause per turning event, giving what the move allowed or prevented and what followed from it. Never go through the moves in game order and never chain clauses with then, next or after that.
- Name a move only where it is the subject of a consequence you are stating. Never tell the reader that a move was played.
- Describe a move only with what FACTS says it did (moved from x to y, took the piece on z, checks). Never characterise it with a word FACTS does not use - retreat, develop, passive, active, natural, aggressive - and never call a move a retreat because it went backwards.
- Keep to the balance: if one side was already completely winning in this phase, say what the losing side was playing for rather than listing small errors.
- Never quote the accuracy, centipawn or ply figures from FACTS, and give no percentages. The reader sees those already.
- Never compare the two sides' accuracy, even in words: saying one side was more accurate is still a number in disguise.
- Never narrate the move sequence. The scoresheet already lists every move, so naming them one after another adds nothing.
- If FACTS says there are no moves you may name, write only about the phase as a whole and name no move at all.
- Keep both sides distinct: never credit one side with the other's move.
- No lists, no headings, no preamble. Two to four sentences of plain prose.
- End with one concrete thing the side that struggled should have done differently in this phase.
FACTS:
$facts"
}

proc ::reviewcoach::summaryPrompt {facts} {
    return "You are a chess coach writing the closing note of a game review, for the scoresheet.
Write about both sides by colour - \"White\" and \"Black\". Never address anyone as \"you\".

Rules:
- Use only the FACTS below. Never name a piece, square or move that is not in FACTS.
- Never quote accuracy, Elo, centipawn or percentage figures, and never list move tallies. The reader sees those beside the moves.
- Never call a move great, brilliant, best, an inaccuracy, a mistake or a blunder: the scoresheet already labels it. Say what the move did or allowed.
- Never name a better move without saying what it would have achieved: when FACTS says what the better move achieves, or gives the engine line, use it. If FACTS says it gives no reason for the engine's preference, or that the move played achieves the same thing, do not supply a reason of your own - say only that the engine preferred it.
- Never invent an opening name, never quote an ECO code, and never remark that a name is missing: the header already carries the code.
- The game turned on the move in FACTS marked \"the game turned here\". Name it in your first sentence and do not say that any other move turned the game.
- Do not describe what a line or variation shows beyond the moves in it. If FACTS does not say what a move achieved, say less rather than guessing.
- Prefer the consequence over the sequence: Black taking on e4 and losing the queen to a rook is a summary; naming each move in order is not. If FACTS gives the net exchange, put it in the first sentence.
- If FACTS gives the net material after the punishment, that is what the error cost: state it in outcome terms (the exchange, a piece, a rook, a queen), not as what the immediate reply captured. If FACTS says the punishment was a fork, the fork is the mechanism and the net material is the price.
- FACTS says when the game was decided, with a move number. If you mention it, use that move number exactly. Mistakes made after that point did not change the result: mention them only as loose play in a lost position, never as being as important as the move that decided the game.
- No lists, no headings, no preamble, no markdown.
- Answer in exactly three labelled lines, each starting at the beginning of a line:
SUMMARY: at most three sentences, sixty words total, and preferably two. The FIRST sentence must name the move the game turned on AND its consequence in outcome terms - what it cost on the board, such as a queen for a rook or a lost piece - in that same sentence. Never spend a sentence on the mechanism; the reader has the scoresheet. Shape: the game turned on move 9, when Black's queen took the pawn on e4 and was won for a rook. Do not mention an error that did not change the result.
LEVEL: one sentence on the strength of play this game shows. Start from FACTS marked \"measured level\", naming each side's level in words; then name the single thing that would most have improved the weaker side's play in THIS game, stated concretely (for example, checking that a piece is defended before committing it). One game cannot show a habit or a pattern, so never use those words and never describe one. Do not retell the game and do not repeat the turning point.
OPENING: at most two sentences on the opening. If FACTS gives no opening name, write exactly NONE and say nothing else about it.
FACTS:
$facts"
}

proc ::reviewcoach::parseSummary {text} {
    set out [dict create summary "" level "" opening ""]
    foreach line [split $text "\n"] {
        set t [string trim $line]
        foreach {tag key} {SUMMARY summary LEVEL level OPENING opening} {
            if {[string match -nocase "${tag}:*" $t]} {
                dict set out $key [string trim [string range $t [expr {[string length $tag] + 1}] end]]
            }
        }
    }
    if {[dict get $out summary] eq ""} {
        # no labels at all: the whole answer is the summary
        dict set out summary [string trim $text]
    }
    # "NONE" is the answer the prompt asks for when there is no opening name.
    if {[string match -nocase {none*} [dict get $out opening]]} {
        dict set out opening ""
    }
    return $out
}

# ── prompts for a whole review ──────────────────────────────────────────────

proc ::reviewcoach::gameMeta {} {
    set game [dict create result "" opening ""]
    catch { dict set game result [string trim [sc_game tags get Result]] }
    catch { dict set game opening [string trim [sc_game tags get Opening]] }
    # A header with only an ECO code still has a name in the opening table;
    # the prose must not say the name is missing when it can be derived.
    if {[dict get $game opening] eq ""} {
        set eco ""
        catch { set eco [string trim [sc_game tags get ECO]] }
        if {$eco ne "" && [llength [info commands ::auto_comment::getOpeningName]]} {
            set name ""
            catch { set name [::auto_comment::getOpeningName $eco] }
            if {$name ne "" && $name ne $eco} { dict set game opening $name }
        }
    }
    return $game
}

# The prompts a review asks for: the summary, one per phase with figures, and
# one for each key moment plus every mistake/blunder, capped at ten moves.
proc ::reviewcoach::buildPrompts {moves game} {
    set prompts {}
    set gf [gameFacts $moves $game]
    if {$gf ne ""} {
        lappend prompts [dict create kind summary key 0 prompt [summaryPrompt $gf] max 800]
    }
    foreach ph {opening middlegame endgame} {
        set pf [phaseFacts $moves $ph]
        if {$pf eq ""} { continue }
        lappend prompts [dict create kind phase key $ph prompt [phasePrompt $ph $pf] max 500]
    }

    set plies {}
    foreach k [::reviewreport::keyMoments $moves 5] { lappend plies [dict get $k ply] }
    foreach m $moves {
        if {[lsearch -exact {mistake miss blunder} [dict get $m classification]] >= 0} {
            lappend plies [dict get $m ply]
        }
    }
    set n 0
    foreach ply [lsort -integer -unique $plies] {
        if {[incr n] > 10} { break }
        set m ""
        foreach cand $moves { if {[dict get $cand ply] == $ply} { set m $cand ; break } }
        if {$m eq ""} { continue }
        # The reply that punished this move is the next analysed position: its
        # line starts from the board after the move, so it is the refutation.
        # Without it the move facts cannot say what the move allowed.
        foreach cand $moves {
            if {[dict get $cand ply] == [expr {$ply + 1}]} {
                if {[dict exists $cand best_pv] && [llength [dict get $cand best_pv]]} {
                    dict set m punish_pv [dict get $cand best_pv]
                }
                break
            }
        }
        lappend prompts [dict create kind moment key $ply \
            prompt [momentPrompt $m] max 320]
    }
    return $prompts
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
