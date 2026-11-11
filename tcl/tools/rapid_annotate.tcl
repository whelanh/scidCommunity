# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later

############################################################
### Rapid annotate
###
### The engine windows (F2/F3) already evaluate every move of the current
### game when Autoscan is on, and draw the results into the score graph.
### This module keeps those evaluations in memory and, on demand
### (Ctrl+Shift+A), turns them into PGN data for the current game:
###   * an [%eval ...] comment for every evaluated position, so the PGN
###     viewer redraws the same graph when the game is loaded again;
###   * the annotations Game Review writes from the same evaluations: label,
###     [%eval], the label's NAG, the position assessment on marked moves, D and
###     variations, with the depth, MultiPV, variation and diagram settings in
###     Review Settings. The graph only keeps the best line, so this is a quick
###     pass rather than an exact copy of a depth-limited Game Review.
###
### The time per move is deliberately NOT the Batch Annotate setting: the
### scores being annotated are the ones the score graph has already
### collected, so the Autoscan time chosen in the engine window is the time
### per move of this feature.
############################################################

namespace eval ::rapid_annotate {
    # Evaluations collected from the engine score graphs.
    # scores($base,$game) is a dict: ply -> entry, where
    #   ply             number of half-moves played in the evaluated position
    #   entry           {depth score score_fmt score_fmt_depth pv eval position}
    #     depth         search depth reported by the engine
    #     score         pawns from White's side of the board; mate = +/-300.0
    #     score_fmt     "+1.24" / "M3" / "-M3" (the PGN notation used by
    #                   ::batch_annotate)
    #     score_fmt_depth  "18:+1.24", the comment written by Batch Annotate
    #     pv            UCI moves from that position
    #     eval          token for the [%eval] comment: "+1.24" / "#3" / "#-3"
    #     position      the "position ..." string that was analysed, so an
    #                   entry can be dropped once the game no longer has
    #                   that position at that ply
    variable scores
    array set scores {}
}

# Return the identifier of the game loaded in the main board.
proc ::rapid_annotate::key {} {
    return "[sc_base current],[sc_game number]"
}

# Record the evaluations carried by one engine "InfoPV" message.
# Called by ::enginewin::updateChart, so the data is exactly what the score
# graph is drawing.
#   plies: main-line plies where the evaluated position occurs
#   score: raw UCI score (centipawns, or moves to mate) from the side to move
proc ::rapid_annotate::record {id plies depth score score_type pv} {
    variable scores

    # An engine embedded in a PGN viewer analyses the game shown in that
    # window, which is not necessarily the game loaded in the main board:
    # the PGN viewer has its own score-saving path.
    if {[info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id)} {
        return
    }
    if {$score eq "" || $pv eq ""} { return }
    # Scores of a fail-soft/fail-high search are not evaluations.
    if {$score_type ni {cp mate}} { return }
    if {![string is integer -strict $depth]} { set depth 0 }

    # An unsaved game has no PGN to annotate.
    if {[sc_game number] < 1} { return }

    # UCI scores are from the point of view of the side to move, while PGN
    # annotations ([%eval], NAGs, variations) use White's point of view.
    set btm [expr {$::enginewin::pv_(btm,$id) ? 1 : 0}]
    if {$btm} { set score [expr {-$score}] }

    if {$score_type eq "mate"} {
        set value [expr {$score > 0 ? 300.0 : -300.0}]
        set score_fmt [expr {$score > 0 ? "M$score" : "-M[expr {-$score}]"}]
        # Lichess-style mate comment, understood by getScorefromComment.
        set evalStr "#$score"
    } else {
        set value [expr {$score / 100.0}]
        set score_fmt [format "%+.2f" $value]
        set evalStr $score_fmt
    }
    set pos ""
    if {[info exists ::enginewin::pv_(pos,$id)]} {
        set pos $::enginewin::pv_(pos,$id)
    }
    set entry [list $depth $value $score_fmt \
        [format "%d:%s" $depth $score_fmt] $pv $evalStr $pos]

    set key [::rapid_annotate::key]
    if {![info exists scores($key)]} { set scores($key) [dict create] }
    set game $scores($key)
    foreach ply $plies {
        # Ply 0 is the initial position: no move has been played there.
        if {![string is integer -strict $ply] || $ply < 1} { continue }
        # Engine 1 and Engine 2 can both analyse this game: keep the deeper
        # evaluation of each position, together with its own PV.
        if {[dict exists $game $ply] &&
            $depth <= [lindex [dict get $game $ply] 0]} { continue }
        dict set game $ply $entry
    }
    set scores($key) $game
    # The progress board's view of this run. Rapid annotate is the engine
    # window's own Autoscan pass, not a ::reviewdriver pass, so this file owns
    # the job: it begins one for the window the first time a line is recorded
    # and publishes the position being searched with it. A job another run owns
    # is left alone - a review in flight already has the board.
    catch { ::rapid_annotate::publishProgress $id }
    return
}

# The position the engine is on, for the progress board. `sc_pos fen` is that
# position: the graph records a line for the board the engine is analysing.
# `done` is the positions collected so far, `total` the main line's length.
proc ::rapid_annotate::publishProgress {id} {
    # Rapid Annotate is the engine window's Autoscan pass. An ordinary analysis
    # also reaches record; it must not own the progress pane.
    if {[info exists ::enginewin_autorun($id)] \
            && [lindex $::enginewin_autorun($id) 0] eq ""} { return }
    set job [::reviewprogress::job]
    set token ""
    if {[dict size $job]} {
        if {[dict get $job source] ne "rapid"} { return }
        # One board: a second engine window's Autoscan must not relabel the
        # first window's run (or leave its Cancel pointing at the wrong one).
        set origin {}
        catch { set origin [dict get $job fields origin] }
        set win [string trimleft $id .engineWin]
        if {[llength $origin] && [lindex $origin 0] eq "enginewin" \
                && [lindex $origin 1] ne $win} { return }
        set token [dict get $job token]
    } else {
        set engine ""
        catch { set engine $::enginewin_lastengine($id) }
        set win ""
        catch { set win [string trimleft $id .engineWin] }
        set token [::reviewprogress::begin [dict create source rapid \
            engine $engine origin [list enginewin $win] \
            cancel [list ::enginewin::stop $id]]]
    }
    set total 0
    catch { set total [dict size [::rapid_annotate::mainLinePositions]] }
    set done [::rapid_annotate::pending]
    # The engine searched a main-line position, not necessarily the one the
    # reader's cursor is on: use the Go position it is working from.
    set spec ""
    catch { set spec $::enginewin::pv_(pos,$id) }
    if {$spec ne ""} {
        ::reviewprogress::setSpec $token $spec $done $total
        return
    }
    set fen ""
    catch { set fen [sc_pos fen] }
    if {$fen eq ""} { return }
    ::reviewprogress::setPosition $token $fen $done $total
    return
}

# The run is over when the scores it was collected from are: a new game, or the
# commit that writes them. Nothing is cancelled by this - the board is
# decoration over the analysis, not a party to it.
proc ::rapid_annotate::progressDone {{id ""}} {
    set job [::reviewprogress::job]
    if {![dict size $job]} { return }
    if {[dict get $job source] ne "rapid"} { return }
    # A caller that names a window ends only that window's rapid job; another
    # window may own the one board. The no-argument form is the game-level end
    # (new game, commit) and ends the current rapid job.
    if {$id ne ""} {
        set origin {}
        catch { set origin [dict get $job fields origin] }
        if {[llength $origin] && [lindex $origin 0] eq "enginewin" \
                && [lindex $origin 1] ne [string trimleft $id .engineWin]} {
            return
        }
    }
    catch { ::reviewprogress::finish [dict get $job token] }
    return
}

# Called when a new game is loaded, and when the current game is reloaded,
# saved or undone. The evaluations are only a scratch pad for the game being
# analysed, so nothing of the old game survives: an edit that keeps the same
# game number (replacing a move, truncating, undoing) is caught later by the
# position check in ::rapid_annotate::evals.
proc ::rapid_annotate::onNewGame {} {
    variable scores
    catch { ::rapid_annotate::progressDone }
    array unset scores
}

# Positions of the current game's main line, keyed by ply (ply 1 is the
# position after the first move), in the "position ..." form the engine uses.
# Spaces are removed so that the same position compares equal whichever of
# sc_game UCI_currentPos and sc_game UCI_mainLine produced the string.
proc ::rapid_annotate::mainLinePositions {} {
    set mainLine [sc_game UCI_mainLine]
    set positions [dict create]
    for {set ply 1} {$ply < [llength $mainLine]} {incr ply} {
        dict set positions $ply \
            [string map {" " ""} [join [lrange $mainLine 0 $ply]]]
    }
    return $positions
}

# Return the collected evaluations of a game, one entry per collected ply, in
# the intermediate form ::rapid_annotate::reviewResults converts for the review
# writer.
proc ::rapid_annotate::evals {{key ""}} {
    variable scores
    if {$key eq ""} { set key [::rapid_annotate::key] }
    if {![info exists scores($key)]} { return {} }

    # An evaluation is only valid for the position it was made in. Editing the
    # game does not clear the store (the game number does not change), so drop
    # every entry whose position is no longer the position at that ply.
    set positions [::rapid_annotate::mainLinePositions]
    set evals [dict create]
    dict for {ply entry} $scores($key) {
        lassign $entry depth value score_fmt score_fmt_depth pv evalStr pos
        if {![dict exists $positions $ply] ||
            [string map {" " ""} $pos] ne [dict get $positions $ply]} { continue }
        dict set evals $ply [dict create \
            score $value \
            score_fmt $score_fmt \
            score_fmt_depth $score_fmt_depth \
            pv $pv \
            depth $depth \
            eval $evalStr]
    }
    return $evals
}

# Number of positions collected for the game in the main board.
proc ::rapid_annotate::pending {} {
    return [dict size [::rapid_annotate::evals]]
}

# The collected evaluations in the review writer's results shape:
#   ply -> {1 {depth score score-type pv}}
# The graph records only the best line, so there is one entry per position. A
# 100 ms line is as valid an input as a depth-18 one; the writer only annotates
# what the evaluation says, and cannot know how it was obtained.
proc ::rapid_annotate::reviewResults {evals map} {
    set sides [::reviewdriver::sides $map]
    set results [dict create]
    dict for {ply entry} $evals {
        if {![dict exists $sides $ply]} { continue }
        set stm [dict get $sides $ply]
        set depth [dict get $entry depth]
        set pv [dict get $entry pv]
        set fmt [dict get $entry score_fmt]
        if {[regexp {^(-?)M(\d+)$} $fmt -> neg dist]} {
            # score_fmt is White's point of view; the line must be the side to
            # move's, as the engine would have sent it.
            set wdist [expr {$neg eq "-" ? -$dist : $dist}]
            set raw [expr {$stm eq "w" ? $wdist : -$wdist}]
            dict set results $ply 1 [list $depth $raw mate $pv]
        } else {
            set raw [expr {round([dict get $entry score] * 100.0)}]
            if {$stm eq "b"} { set raw [expr {-$raw}] }
            dict set results $ply 1 [list $depth $raw cp $pv]
        }
    }
    return $results
}

# Write the collected evaluations and the annotations they imply into the
# current game (the PGN). Bound to Ctrl+Shift+A.
# Return true if the game was modified.
proc ::rapid_annotate::commit {} {
    set evals [::rapid_annotate::evals]
    if {[dict size $evals] == 0} {
        tk_messageBox -icon info -title "scidCommunity" -parent . -message \
            "No engine scores have been collected for this game yet.\n\nOpen Engine 1 or Engine 2 (F2/F3) with Autoscan enabled and let the score graph fill."
        return 0
    }
    set gnum [sc_game number]
    if {$gnum < 1} {
        tk_messageBox -icon info -title "scidCommunity" -parent . -message \
            "This game is not in a database yet.\n\nSave it first (Ctrl+S replaces, Ctrl+Shift+S adds) and let the engine analyse it again."
        return 0
    }
    if {[sc_var level]} {
        tk_messageBox -icon info -title "scidCommunity" -parent . -message \
            "Annotations are written to the main line.\n\nLeave the variation first (Up)."
        return 0
    }
    set base [sc_base current]
    if {[sc_base isReadOnly $base]} {
        tk_messageBox -icon info -title "scidCommunity" -parent . -message \
            "The current database is read-only: its games cannot be annotated."
        return 0
    }

    # Remember the ply, not the PGN offset: annotating changes the game text.
    set ply [sc_pos location]
    undoFeature save

    # The Game Review writer, from the scores the graph already collected: the
    # same labels, marks, assessment, D and variations a review would write - and
    # through the driver's shared seam, so Rapid Annotate gets the Brilliant/Great
    # verification a single game review does instead of bypassing it (issue #422
    # item 5). The verification is a second engine, so the write happens in its
    # answer; this returns 1 either way and the error handling stays where it was.
    set p ""
    if {[catch {
        set map [::review::mainLineMap [sc_game UCI_mainLine]]
        set plies [dict get $map plies]
        set verifier ""
        catch { set verifier [::review::verifier] }
        set p [dict create map $map plan [::review::plan $plies 0] \
            plies $plies bookEnd 0 mpv [::review::get mpv] \
            verifier $verifier \
            limits [dict create depth [::review::get depth] \
                movetime [::review::get movetime]]]
        ::reviewdriver::verifyWrite $p [::rapid_annotate::reviewResults $evals $map] \
            [list ::rapid_annotate::writeCommit $p $gnum $ply $base]
    } err]} {
        undoFeature undo
        set ::errorInfo $err
        ERROR::MessageBox
        return 0
    }
    return 1
}

# Write the review the graph's scores imply into the game. The tail of
# ::rapid_annotate::commit, kept apart so it can run after a verification search:
# the writer, the save and the redraw are one unit, and a failure has to undo the
# whole thing exactly as it did when this ran inline.
proc ::rapid_annotate::writeCommit {p gnum ply base results corrections} {
    # The game may have been navigated away from, or replaced, while the second
    # engine searched: writing then would put this game's review into another one.
    # The game number alone is not identity across databases, so the base is
    # checked too - `base` is the one this commit captured before the search.
    if {[catch { set here [sc_game number] }]} { set here "" }
    if {$here ne "" && $here ne [string trim $gnum]} { return 0 }
    if {[catch { set hereBase [sc_base current] }]} { set hereBase "" }
    if {$hereBase ne "" && $hereBase ne [string trim $base]} { return 0 }
    # The shared transform, immediately before the write.
    set results [::reviewdriver::verified $results $corrections]
    if {[dict size $corrections]} { dict set p corrections $corrections }
    if {[catch {
        ::reviewdriver::writeResults $p $results
        sc_move ply $ply
    } err]} {
        undoFeature undo
        set ::errorInfo $err
        ERROR::MessageBox
        return 0
    }

    if {[catch { sc_game save $gnum } err]} {
        undoFeature undo
        set ::errorInfo $err
        ERROR::MessageBox
        return 0
    }
    ::notify::DatabaseModified $base
    ::notify::PosChanged -pgn
    if {[winfo exists .commentWin]} { ::windows::commenteditor::Refresh }
    # The run is over when the scores are in the game; a new game is not needed
    # for the pane to stop showing it.
    ::rapid_annotate::progressDone
    return 1
}
