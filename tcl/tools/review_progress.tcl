# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_progress.tcl -- what a review progress board shows, without Tk.
#
# A review runs on its own engine connection and never touches the board: the
# reader can walk the game, open another one, or do nothing at all while it
# works. The progress board is the window onto that work, and it is fed a
# position as a FEN and nothing else. It has no game, no cursor and no clock, so
# it cannot move the user's board and cannot fight it for control - which is the
# whole point of it existing rather than the review drawing on the main board.
#
# Everything a widget would otherwise have to decide is here, where tclsh can
# reach it: the FEN-to-board-string feed, the header each source composes, and
# the job the window draws from. tcl/tools/review_progress_ui.tcl keeps the
# widgets and reads nothing but the job.

namespace eval ::reviewprogress {
    # The run the board is showing, or "" when nothing is running. One board,
    # one run: a second run started while the first is in flight takes the
    # board, because it is decoration over a run and the newest run is the one
    # the reader asked for.
    variable job ""
    variable seq 0
    # The window's draw hook, as {*}$painter <job>. Empty in tclsh, which is
    # what makes this file sourceable without Tk.
    variable painter ""
}

# The position the board draws, as ::board::update wants it: 64 characters,
# index 0 = a1, upper case white, lower case black, "." for an empty square.
#
# A FEN the parser refuses answers "": a stray frame of the wrong position is
# worse than a stale one, and the run keeps its last good board.
proc ::reviewprogress::positionToBoard {fen} {
    if {[string trim $fen] eq ""} { return "" }
    if {[catch { set pos [::chessboard::fromFen $fen] }]} { return "" }
    set out ""
    foreach square [dict get $pos board] {
        if {$square eq ""} { append out "." } else { append out $square }
    }
    if {[string length $out] != 64} { return "" }
    return $out
}

# A position a pass searches, as ::reviewdriver hands it to the engine:
# "position fen <fen> moves <m1> <m2> ...", or a bare FEN. The FEN alone is the
# position before the moves, so the moves are replayed on the pure board rather
# than on the game: the board the reader is looking at is not this pass's.
proc ::reviewprogress::specToBoard {spec} {
    set spec [string trim $spec]
    if {$spec eq ""} { return "" }
    set words [regexp -all -inline {\S+} $spec]
    set fen ""
    set moves {}
    set at [lsearch -exact $words fen]
    if {$at >= 0} {
        set rest [lrange $words [expr {$at + 1}] end]
        set m [lsearch -exact $rest moves]
        if {$m >= 0} {
            set fen [join [lrange $rest 0 [expr {$m - 1}]] " "]
            set moves [lrange $rest [expr {$m + 1}] end]
        } else {
            set fen [join $rest " "]
        }
    } else {
        set fen $spec
    }
    set board [::reviewprogress::positionToBoard $fen]
    if {$board eq "" || ![llength $moves]} { return $board }
    # A move list the pure board cannot play is not a position: keep the FEN's,
    # which is still the position the search started from.
    if {[catch {
        set pos [::chessboard::fromFen $fen]
        foreach uci $moves { set pos [::chessboard::makeMove $pos $uci] }
        set out ""
        foreach square [dict get $pos board] {
            if {$square eq ""} { append out "." } else { append out $square }
        }
        if {[string length $out] == 64} { set board $out }
    }]} { return $board }
    return $board
}

# The source, as a reader names it. The tokens are the runs, not the windows:
# two windows can run the same Game Review, and the header says which run.
proc ::reviewprogress::sourceLabel {source} {
    switch -- $source {
        review      { return [tr ReviewGameButton] }
        movecomment { return [tr ReviewMoveButton] }
        annotate    { return [tr Annotate] }
        rapid       { return [tr ReviewProgressRapid] }
        finish      { return [tr FinishGame] }
        default     { return $source }
    }
}

# Where the run came from, as {kind index}: the engine window that asked, or the
# analysis pane. Composed here rather than at draw time, because the window may
# have been closed by the time the board repaints.
proc ::reviewprogress::originText {spec} {
    if {![llength $spec]} { return "" }
    lassign $spec kind n
    switch -- $kind {
        enginewin    { return [format [tr ReviewProgressEngineWindow] $n] }
        analysispane { return [format [tr ReviewProgressAnalysisPane] $n] }
        default      { return [lindex $spec 0] }
    }
}

# The header, composed once where the run starts and carried in the job as a
# field. A lookup at draw time could name the engine of a window the user has
# since pointed elsewhere - the one thing a header must never do.
#
#   <source> — <engine> (<origin>) · game <n> of <total>
#
# Every part after the source is optional: a run whose preset was deleted keeps
# its name if it had one and shows only what it knows if it did not.
proc ::reviewprogress::header {fields} {
    set source ""
    catch { set source [dict get $fields source] }
    set out [::reviewprogress::sourceLabel $source]
    set engine ""
    catch { set engine [dict get $fields engine] }
    if {$engine ne ""} { append out " \u2014 $engine" }
    set origin ""
    catch { set origin [dict get $fields origin] }
    if {[llength $origin]} { set origin [::reviewprogress::originText $origin] }
    if {$origin ne ""} { append out " ($origin)" }
    set game ""
    set total ""
    catch { set game [dict get $fields game] }
    catch { set total [dict get $fields total] }
    if {$game ne "" && $total ne ""} {
        append out " \u00b7 " [format [tr ReviewProgressGameOf] $game $total]
    }
    return $out
}

# The window's draw hook. Empty in tclsh: a run with no window open still
# records its job, and the window picks it up when it is opened.
proc ::reviewprogress::setPainter {cmd} {
    variable painter
    set painter $cmd
    return
}

proc ::reviewprogress::paint {} {
    variable job
    variable painter
    if {$painter eq "" || ![dict size $job]} { return }
    # A painter that raises must not take the run down with it: the board is
    # decoration over a job, not a party to it.
    catch { {*}$painter $job }
    return
}

# A run has started. `fields` are the header's fields (source, engine, origin,
# and for a batch run game and total); the token is what the run publishes
# against, so a late reply from a run that has already ended is ignored.
proc ::reviewprogress::begin {fields} {
    variable job
    variable seq
    incr seq
    set token "progress$seq"
    set game ""
    set total ""
    catch { set game [dict get $fields game] }
    catch { set total [dict get $fields total] }
    set job [dict create token $token \
        header [::reviewprogress::header $fields] \
        source [expr {[dict exists $fields source] ? [dict get $fields source] : ""}] \
        board "" fen "" ply "" done "" total "" game $game totalGames $total]
    ::reviewprogress::paint
    return $token
}

proc ::reviewprogress::job {} {
    variable job
    return $job
}

# The position the run is searching now. `done`/`total` are the run's search
# counts when it has them; a batch run also passes the game it is on, so the
# header's game number moves with the run rather than at the next begin.
#
# Returns 1 when the board changed, 0 when the position was refused or the
# token is not the run the board is showing.
proc ::reviewprogress::setPosition {token fen {done ""} {total ""} {game ""}} {
    variable job
    if {![dict size $job] || [dict get $job token] ne $token} { return 0 }
    set board [::reviewprogress::positionToBoard $fen]
    if {$board eq ""} { return 0 }
    dict set job fen $fen
    dict set job board $board
    if {$done ne ""} { dict set job done $done }
    if {$total ne ""} { dict set job total $total }
    if {$game ne ""} { dict set job game $game }
    ::reviewprogress::paint
    return 1
}

# The position a pass is searching, from the spec the driver queued. Same
# contract as setPosition, with the moves in the spec replayed on the pure
# board so the board shows where the search actually is.
proc ::reviewprogress::setSpec {token spec {done ""} {total ""} {game ""}} {
    variable job
    if {![dict size $job] || [dict get $job token] ne $token} { return 0 }
    set board [::reviewprogress::specToBoard $spec]
    if {$board eq ""} { return 0 }
    dict set job fen [lindex [regexp -all -inline {\S+} $spec] 3]
    dict set job board $board
    catch { dict set job spec $spec }
    if {$done ne ""} { dict set job done $done }
    if {$total ne ""} { dict set job total $total }
    if {$game ne ""} { dict set job game $game }
    ::reviewprogress::paint
    return 1
}

# The progress line under the board. A run that has not searched yet says so
# rather than showing 0 of 0.
proc ::reviewprogress::progressText {job} {
    set done ""
    set total ""
    catch { set done [dict get $job done] }
    catch { set total [dict get $job total] }
    if {$done eq "" || $total eq ""} { return [tr ReviewProgressIdle] }
    return [format [tr ReviewProgress] $done $total]
}

# The run is over: nothing to show. The window stays open and says so, because
# closing it would be the run's decision and the run has none to make.
proc ::reviewprogress::finish {token} {
    variable job
    if {![dict size $job] || [dict get $job token] ne $token} { return 0 }
    set job ""
    ::reviewprogress::paint
    return 1
}

# Write a collected continuation into a game, once.
#
#   game   the game index to write, or "" / "0" for the game that is open
#   moves  the UCI moves to append at the end of the main line
#   note   an optional comment for the final position (a tablebase result)
#
# Returns "" when the moves landed, or the reason nothing was written.
#
# Nothing here paints. Tcl only paints when the event loop runs, so a commit
# that calls no `update`, no `updateBoard`, no `::notify::PosChanged` and no
# `::board::update` is atomic on screen however long it takes: the reader never
# sees the borrowed game. That is the whole of the rule, and it is why a run
# that writes a game the reader is not looking at can borrow one at all (the
# idiom at tcl/game.tcl:65: push a copy, load, edit, save, pop).
#
# A refused move undoes what it had written and pops the borrow; a cancelled
# run never reaches here, because the collect phase does not touch the game.
proc ::reviewprogress::commitMoves {game moves {note ""}} {
    if {![llength $moves] && $note eq ""} { return "" }
    set out ""
    set borrowed 0
    set marked 0
    if {[catch {
        if {$game ne "" && $game ne "0"} {
            sc_game push copy
            sc_game load $game
            set borrowed 1
        }
        # One restore point for the whole commit: a move the game refuses half
        # way through must not leave the line half extended.
        catch { undoFeature save ; set marked 1 }
        set cursor [::review::cursorSave]
        sc_move end
        foreach uci $moves {
            if {[::uci::sc_move_add $uci]} {
                set out "the move $uci was rejected"
                break
            }
        }
        if {$out eq "" && $note ne ""} {
            catch {
                sc_pos setComment [::review::mergeComment \
                    [sc_pos getComment] $note]
            }
        }
        if {$out eq "" && $borrowed} { sc_game save $game }
        if {$out ne "" && $marked} { catch { undoFeature undo } }
        # Same discipline as ::review::writeMove: a restore that could not find
        # its line leaves a known position, and only -1 needs the start.
        set restored 1
        if {[catch { set restored [::review::cursorRestore $cursor] }]} {
            set restored 1
        }
        if {$restored < 0} { catch { sc_move ply 0 } }
    } err]} {
        set out $err
        if {$marked} { catch { undoFeature undo } }
    }
    if {$borrowed} { catch { sc_game pop } }
    return $out
}
