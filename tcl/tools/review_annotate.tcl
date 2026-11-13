# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_annotate.tcl -- the marks the review writer asks for.
#
# A review writes a label, an [%eval] and its variations itself, in
# ::reviewdriver::writeResults. Three marks are not its own and are written from
# here instead, because they are Review Settings' business and the Game Review
# pass, the engine window's review, the Game List batch and Rapid Annotate must
# not disagree about them:
#
#   * FindOpeningErrors     -> ::reviewannotate::openingMark, the opening tag at
#                              the ply the opening book ended;
#   * MarkTacticalExercises -> ::reviewannotate::writeTactical, the game's T flag
#                              and the "****D<difficulty> <before>-><after>"
#                              comment on the move that made it a puzzle.
#
# ::reviewdriver::writeResults calls the first after its move loop and the
# second from inside it, each behind an `info commands` guard, so this module is
# a set of hooks rather than a pass: nothing here searches, nothing here needs
# Tk, and every write goes through the sc_* commands.
#
# What used to live here -- the legacy Annotate dialog's decisions, its writer,
# its tier-2 prose and its run, next-move and Cancel state -- went with the
# Analysis window in #437 §5. The NAG ladders, the diagram tag and the assessment
# table it also carried are ::review::'s now and always were.

namespace eval ::reviewannotate {}

########################################################################
### The scores the marks compare
###
### The classic annotator kept every figure it wrote in White's perspective; the
### review's lines are the engine's own (side to move), so the places that
### compare them with a White-POV number flip them here.

# A centipawn figure from the side to move's point of view, as White's. The
# classic pipeline kept every figure it wrote in White's perspective (the UCI
# parser flips the engine's score before storing multiPV); the review's lines
# are the engine's own, so the places that compare them with a White-POV number
# have to flip them the same way.
proc ::reviewannotate::whiteScore {cp side} {
    if {$cp eq ""} { return "" }
    if {$side eq "black"} { return [expr {-$cp}] }
    return $cp
}

# A saved Review Settings switch, as 1 or 0. The review layer owns these; a
# harness that has not loaded game_review.tcl gets the default rather than an
# error in the middle of a write.

# A saved Review Settings switch, as 1 or 0. The review layer owns these; a
# harness that has not loaded game_review.tcl gets the default rather than an
# error in the middle of a write.
proc ::reviewannotate::setting {key {default 0}} {
    if {[llength [info commands ::review::get]] == 0} { return $default }
    if {[catch { set value [::review::get $key] }]} { return $default }
    if {[string is boolean -strict $value]} { return [expr {$value ? 1 : 0}] }
    if {[string is integer -strict $value]} { return [expr {$value != 0}] }
    return $default
}

########################################################################
### The exercise
###
### A game that carries a puzzle carries the T flag, so a filter can select it,
### and the move carries "****D<difficulty> <before>-><after>".

# Write the exercise's marks onto one move. `nag` is added only if it is not
# already there: a re-run must not stack a second "??".
proc ::reviewannotate::exercise {ply nag difficulty prevscore score} {
    set ok 0
    if {[catch {
        sc_move ply $ply
        if {$nag ne "" && [string first $nag "[sc_pos getNags]"] == -1} {
            sc_pos addNag $nag
        }
        set prefix [format "****D%d %.1f->%.1f" $difficulty $prevscore $score]
        set existing [sc_pos getComment]
        # A previous run's exercise prefix is replaced, not stacked: re-running
        # the annotator must not grow the comment.
        regsub {^\*{4}D[0-9]+ [-0-9.]+->[-0-9.]+ ?} $existing {} existing
        if {$existing eq ""} {
            sc_pos setComment $prefix
        } else {
            sc_pos setComment "$prefix $existing"
        }
        # A read-only base (a PGN file) refuses the flag; the comment still went
        # in, and the classic code catches the same refusal.
        catch { sc_base gameflag [sc_base current] [sc_game number] set T }
        set ok 1
    }]} {
        return 0
    }
    return $ok
}

# How long an engine needs to find this move, as the classic annotator measured
# it: the shortest of the fixed budgets at which the move
# is still found, plus one. The scale runs 1..9, and it is what the "****D"
# comment carries.
#
# The position has to be the one the caller means: this reads the board, it does
# not move it.
proc ::reviewannotate::difficulty {bm0} {
    set timer {1 2 5 10 50 100 200 1000}
    set movelist {}
    foreach t $timer {
        set res [sc_pos analyze -time $t -hashkb 1 -pawnkb 1 -mindepth 0]
        lappend movelist [lindex $res 1]
    }
    for {set t [expr {[llength $timer] - 1}]} {$t >= 0} {incr t -1} {
        if {[lindex $movelist $t] != $bm0} { break }
    }
    return [expr {$t + 2}]
}

# The before/after evaluations of a verdict in White's point of view, which is
# what the classic annotator wrote and what markExercise's thresholds read.
# `mover` is "w" or "b" - the side to move before the move - from the pass map.
proc ::reviewannotate::whiteVerdict {verdict mover} {
    set beforeMover [dict get $verdict before]
    set afterMover [dict get $verdict after]
    if {[dict get $verdict eval_cp] ne ""} {
        set afterMover [dict get $verdict eval_cp]
        if {$mover eq "b"} { set afterMover [expr {-$afterMover}] }
    }
    if {[dict get $verdict isBest]} { set beforeMover $afterMover }
    if {$mover eq "b"} {
        return [list [expr {-$beforeMover}] [expr {-$afterMover}]]
    }
    return [list $beforeMover $afterMover]
}

# The tactical-exercise marks for one judged move, from the same helpers the
# annotate writer uses. Both writers call this, so Game Review and the Game List
# batch cannot disagree about the flag or the difficulty comment.
#
# `results` is the pass's results and `mpv` its MultiPV count; the lines at `ply`
# are the position AFTER the move, which is what markExercise reads. `nag` is
# the move's mark when the caller already decided it (the review writer passes
# the NAG it wrote); "" means use the label's own.
proc ::reviewannotate::writeTactical {ply verdict mover results mpv {nag ""}} {
    if {[llength [info commands ::review::nagForLabel]] == 0} { return 0 }
    if {$nag eq ""} { set nag [::review::nagForLabel [dict get $verdict label]] }
    if {$nag ne "?" && $nag ne "??"} { return 0 }
    lassign [::reviewannotate::whiteVerdict $verdict $mover] before after
    set lines [::reviewdriver::lines $results $ply $mpv]
    return [::reviewannotate::markExercise $before $after "" $lines]
}

# Mark the game as an exercise when the position was a puzzle rather than a
# position that was already decided. This is the classic annotator's markExercise,
# kept for the review writer: same gates, same thresholds, same comment.
#
# `before`/`after` are the evaluations of the position before and after the move
# in centipawns from WHITE's point of view - the classic's $analysis(prevscore)
# and $analysis(score), and what the "****D<difficulty> a->b" comment carries -
# and `lines` are the engine's lines at the position AFTER the move, best first,
# in the {cp pv} shape ::review::selectLines takes. Those are the two things
# $analysis(multiPV1) and $analysis(score) held in the classic loop.
#
# The mark itself is the caller's: the classic writes the NAG before it runs
# these gates, so a move refused as an exercise still carries its "??".
#
# Returns 1 when the game was marked as an exercise.
proc ::reviewannotate::markExercise {before after nag lines} {
    # The classic code works in pawns; the conversion is here so the thresholds
    # and the comment's format stay the ones the Informant settings mean.
    set prevscore [expr {$before / 100.0}]
    set score [expr {$after / 100.0}]

    # Review Settings owns the switch. Every review pass runs a UCI engine, so
    # the classic's "is the pane UCI?" gate is not a second condition here.
    if {![::reviewannotate::setting tactical_exercises]} { return 0 }

    set deltamove [expr {$score - $prevscore}]
    if {[expr abs($deltamove)] < $::informant(+/-)} { return 0 }
    # A decided game is not a puzzle.
    if {[expr {$prevscore * $score}] >= 0} {
        if {[expr abs($prevscore)] > $::informant(+--)} { return 0 }
        if {[expr abs($prevscore)] > $::informant(+-) &&
            [expr abs($score)] < [expr {2 * abs($prevscore)}]} { return 0 }
    }
    # The best move has to be much better than the others.
    if {[llength $lines] < 2} { return 0 }
    set sc2 [lindex [lindex $lines 1] 0]
    if {$sc2 eq ""} { return 0 }
    set sc2 [expr {[::reviewannotate::whiteScore $sc2 [sc_pos side]] / 100.0}]
    if {[expr abs($score - $sc2)] < 1.5} { return 0 }
    # ... and there has to be only one winning move.
    if {[expr {$score * $sc2}] > 0.0 && [expr abs($score)] > $::informant(+-) &&
        [expr abs($sc2)] > $::informant(+-)} {
        return 0
    }
    # The best move must not lose the position.
    if {[sc_pos side] eq "white" && $score < [expr {0.0 - $::informant(+/-)}]} { return 0 }
    if {[sc_pos side] eq "black" && $score > $::informant(+/-)} { return 0 }
    # The best move is the one the shallow search must not have found. The pass
    # supplies UCI; sc_pos analyze answers SAN, so convert before comparing.
    set pv [lindex [lindex $lines 0] 1]
    set bm0 [lindex $pv 0]
    if {$bm0 eq ""} { return 0 }
    catch {
        set san [sc_pos coordToSAN [sc_pos fen] [list $bm0]]
        if {[llength $san]} { set bm0 [lindex $san 0] }
    }
    set shallow {}
    foreach depth {1 2 3} {
        set res [sc_pos analyze -time 1000 -hashkb 32 -pawnkb 1 -searchdepth $depth]
        lappend shallow [lindex $res 1]
    }
    if {[lindex $shallow 0] == $bm0 && [lindex $shallow 1] == $bm0 &&
        [lindex $shallow 2] == $bm0} {
        return 0
    }
    set difficulty [difficulty $bm0]
    # The nag is already on the move; exercise writes the flag and the comment.
    exercise [sc_pos location] "" $difficulty $prevscore $score
    return 1
}

########################################################################
### The opening

# The tag the opening-errors finder leaves on a game whose opening went wrong.
# "" outside the window the user asked for.
proc ::reviewannotate::openingTag {moveNumber side window} {
    if {![string is integer -strict $moveNumber] || ![string is integer -strict $window]} {
        return ""
    }
    if {$moveNumber >= $window} { return "" }
    return "opBlunder $moveNumber ($side)"
}

# Write the opening-errors entry for a pass, when Review Settings asks for it.
# The classic tagged the game where the opening book ended, not at the first
# move; `bookEnd` is that ply, and the finder's window is measured from there.
# Returns 1 when the tag was written.
proc ::reviewannotate::openingMark {p} {
    if {![::reviewannotate::setting opening_errors]} { return 0 }
    set window 12
    if {[llength [info commands ::review::get]]} {
        catch { set window [::review::get opening_window] }
    }
    set bookEnd 0
    catch { set bookEnd [dict get $p bookEnd] }
    if {![string is integer -strict $bookEnd] || $bookEnd <= 0} {
        # 0 is the pass's "no book / no book skipping" default, not a detected
        # departure at the first move: without a real boundary there is no
        # opening to tag.
        return 0
    }
    set plies 0
    catch { set plies [dict get $p plies] }
    if {![string is integer -strict $plies] || $plies <= 0} { set plies 0 }
    if {$plies > 0 && $bookEnd >= $plies} {
        # The all-book answer from ::review::bookEnd ... 1: the game never left
        # the book, so it has no opening boundary to tag.
        return 0
    }
    set cursor ""
    catch { set cursor [::review::cursorSave] }
    set wrote 0
    if {![catch {
        sc_move ply $bookEnd
        set tag [::reviewannotate::openingTag [sc_pos moveNumber] [sc_pos side] $window]
        if {$tag ne "" && [::reviewannotate::appendAnnotator $tag]} {
            set wrote 1
        }
    }]} {}
    if {$cursor ne ""} { catch { ::review::cursorRestore $cursor } }
    return $wrote
}

# Add to the game's Annotator tag, keeping whatever is already there
#: a second pass appends to the same tag rather than
# replacing what the first engine wrote.
proc ::reviewannotate::appendAnnotator {text} {
    if {$text eq ""} { return 0 }
    # PGN writes an extra tag as Name "value"; a quote inside the value would
    # close the header string. A name is not prose, so use the same replacement
    # ::review::appendAnnotator does.
    set text [string map {"\"" "'"} $text]
    if {[catch { set extra [sc_game tags get "Extra"] }]} { return 0 }
    set nExtra {}
    set seen 0
    set other ""
    foreach line $extra {
        if {$seen == 1} {
            # A second pass appends only an entry the tag does not already carry:
            # a re-run of Game Review or a batch must not grow the tag.
            set present 0
            foreach part [split $line ","] {
                if {[string trim $part] eq $text} { set present 1 ; break }
            }
            if {!$present} { set line "$line, $text" }
            # A two-element Tcl list survives a quote or a brace in either
            # value; building the quoted line by hand did not, and the tag setter
            # silently drops an entry that is not a pair.
            lappend nExtra [list Annotator $line]
            set seen 2
        } elseif {$other ne ""} {
            lappend nExtra [list $other $line]
            set other ""
        } elseif {[string match "Annotator" $line]} {
            set seen 1
        } else {
            set other $line
        }
    }
    if {$seen == 0} {
        lappend nExtra [list Annotator $text]
    }
    # A Tcl list of two-element entries: scid clears the extra tags and parses
    # each element as {name value} (src/tkscid.cpp, sc_game_tags_set -extra).
    if {[catch { sc_game tags set -extra $nExtra }]} { return 0 }
    return 1
}
