# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
namespace eval ::batch_annotate {
    variable base ""
    variable games {}
    
    variable engine_name
    variable instances
    
    variable pipe_game ;# pipe -> game_id
    variable pipe_seq ;# pipe -> the game's place in the run
    variable pipe_moves ;# pipe -> list of {ply position}
    variable pipe_evals ;# pipe -> dict ply -> {rank {depth score type pv}}
    variable pipe_map ;# pipe -> the game's main-line map
    variable pipe_plan ;# pipe -> every move, for the writer
    variable pipe_book ;# pipe -> where the opening book ends
    variable engine_lines ;# pipe -> the MultiPV lines of the position in flight
    variable mpv 3
    variable depth 18
    variable movetime ""
    variable games_completed 0
    variable total_games 0
    # Games actually handed to a pipe, for the pane's "game n of total": a
    # skipped entry is not a game of the run.
    variable assigned 0
    # game_id -> its place in the run. A retried game keeps its number rather
    # than taking a new one.
    variable seq_of
    # Moves whose search ended with no verdict: a time cap can stop a position
    # before the engine reports a single scored line, and such a move is written
    # with no verdict. Counted per move, not per searched position, so the
    # completion dialog can say how far the batch fell short of judging every
    # move - the games counter alone reports a game as done whether or not every
    # move in it got judged.
    variable unscored_plies 0
    # Bumped when a batch starts. A verifier callback that outlives its batch
    # carries the id it was born with and cannot write into the next run.
    variable run_id 0
}

# Register user-configurable preferences for saving via Options > Save Options
::options.store ::batch_annotate::instances 2
::options.store ::batch_annotate::engine_name ""

proc ::batch_annotate::config {db games_list} {
    variable base
    variable games

    set base $db
    set games $games_list

    set w .batchAnnotateConfig
    if {[winfo exists $w]} {
        raise $w
        focus $w
        return
    }

    win::createDialog $w
    ::setTitle $w $::tr(BatchAnnotate)

    ttk::frame $w.f
    pack $w.f -padx 10 -pady 10 -fill both -expand 1

    ttk::labelframe $w.f.engine -text $::tr(BatchEngineSelection)
    ttk::label $w.f.engine.lEngine -text $::tr(BatchChessEngine)
    set engine_names {}
    catch { set engine_names [::enginecfg::names] }
    if {[llength $engine_names] == 0} {
        tk_messageBox -message "No engines configured!"
        destroy $w
        return
    }
    if {[lsearch -exact $engine_names $::batch_annotate::engine_name] < 0} {
        set ::batch_annotate::engine_name [lindex $engine_names 0]
    }
    ttk::combobox $w.f.engine.cbEngine -values $engine_names -state readonly \
        -textvariable ::batch_annotate::engine_name
    ttk::label $w.f.engine.lInstances -text $::tr(BatchNumberOfInstances)
    ttk::spinbox $w.f.engine.sbInstances -textvariable ::batch_annotate::instances \
        -from 1 -to 16 -width 5

    grid $w.f.engine.lEngine $w.f.engine.cbEngine -sticky w -pady 2 -padx 5
    grid $w.f.engine.lInstances $w.f.engine.sbInstances -sticky w -pady 2 -padx 5
    grid $w.f.engine -sticky nswe

    ttk::frame $w.buttons
    pack $w.buttons -fill x -padx 10 -pady 10
    ttk::button $w.buttons.ok -text $::tr(BatchStart) \
        -command [list ::batch_annotate::start $w]
    ttk::button $w.buttons.cancel -text $::tr(BatchCancel) -command [list destroy $w]
    pack $w.buttons.cancel $w.buttons.ok -side right -padx 5
}

proc ::batch_annotate::start {w} {
    variable instances
    variable games

    destroy $w

    set ::batch_annotate::cancelled 0
    incr ::batch_annotate::run_id
    set ::batch_annotate::game_queue {}
    foreach s $games {
        lassign [split [string trim $s] "_"] idx ply
        if {$idx ne "" && [string is integer -strict $idx] && $idx > 0} {
            lappend ::batch_annotate::game_queue $idx
        }
    }
    # A stale selection or a game number past the base cannot be a game of this
    # run; dropping it here keeps both the total and the header's numbering
    # honest instead of shifting every game after it.
    set max_games 0
    catch { set max_games [sc_base numGames $::batch_annotate::base] }
    # Always filter, including an unavailable/zero count: a selection that
    # cannot be a game now must not start engines and then find nothing.
    set valid {}
    foreach g $::batch_annotate::game_queue {
        if {[string is integer -strict $g] && $g > 0 && $g <= $max_games} {
            lappend valid $g
        }
    }
    set ::batch_annotate::game_queue $valid
    set num_games [llength $::batch_annotate::game_queue]
    set ::batch_annotate::total_games $num_games
    set ::batch_annotate::games_completed 0
    set ::batch_annotate::assigned 0
    set ::batch_annotate::seq_of [dict create]
    set ::batch_annotate::unscored_plies 0

    set num_engines $instances
    if {$num_engines > $num_games} { set num_engines $num_games }
    if {$num_engines < 1} { return }

    # The progress board's job for the whole batch: one board, showing whichever
    # game is in flight, and a header whose game number moves with the run. The
    # header is a field from here on - the engine name is read once, here, and
    # never looked up again at draw time.
    catch {
        set ::batch_annotate::token [::reviewprogress::begin [dict create \
            source annotate engine $::batch_annotate::engine_name \
            total $num_games cancel ::batch_annotate::cancel]]
    }

    set pw .batchAnnotateProgress
    if {[winfo exists $pw]} { destroy $pw }
    win::createDialog $pw
    ::setTitle $pw $::tr(BatchProgress)
    ttk::label $pw.l -text $::tr(BatchInitializingEngines)
    ttk::button $pw.b -text $::tr(BatchCancel) -command ::batch_annotate::cancel
    pack $pw.l -padx 10 -pady 10
    pack $pw.b -pady 10

    if {[catch {::batch_annotate::start_engines $num_engines} err]} {
        ::batch_annotate::endProgress
        tk_messageBox -message "Error starting engines: $err"
        destroy $pw
        return
    }

    foreach pipe $::batch_annotate::pipes {
        ::batch_annotate::assign_game $pipe
    }
    # A selection that turns out to have no games (the base emptied after the
    # dialog, stale numbers) leaves every pipe done with no finalize_game to
    # run the completion check. End the batch here; a busy pipe makes this a
    # no-op.
    ::batch_annotate::check_completion
}

proc ::batch_annotate::start_engines {num_instances} {
    variable pipes
    variable engine_name

    set cfg [::enginecfg::get $engine_name]
    if {![llength $cfg]} { error "No engine selected" }
    lassign $cfg ename cmd args wdir elo time url uci options limits
    if {!$uci} { error "Batch annotate needs a UCI engine" }

    # The figures a Game Review pass would use: the review's depth floor over
    # the preset's, the review's time ceiling when it has one, MultiPV at least
    # two, and the pass budget for Threads/Hash. ::review::effective is the only
    # place either figure is decided, so the batch cannot invent a third rule.
    set eff [::review::effective $cfg]
    set ::batch_annotate::mpv [dict get $eff mpv]
    set ::batch_annotate::depth [dict get $eff depth]
    set ::batch_annotate::movetime [dict get $eff movetime]
    set threads [dict get $eff threads]
    set hash [dict get $eff hash]

    set pipes {}
    set pwd [pwd]
    if {$wdir ne "" && $wdir ne "."} {
        catch {cd $wdir}
    }
    if {[catch {
        for {set i 0} {$i < $num_instances} {incr i} {
            if {$::windowsOS} {
                set pipe [open [list | $cmd {*}$args] r+]
            } else {
                set pipe [open "| \"[file nativename $cmd]\" $args" r+]
            }
            lappend pipes $pipe
            fconfigure $pipe -buffering line -blocking 0
            set ::batch_annotate::engine_state($pipe) "idle"

            puts $pipe "uci"
            set uciok 0
            set timeout 50
            while {$timeout > 0} {
                update
                if {[eof $pipe]} { break }
                if {[gets $pipe line] >= 0} {
                    if {$line eq "uciok"} { set uciok 1; break }
                }
                after 100
                incr timeout -1
            }
            if {!$uciok} { error "Engine handshake timeout: uciok not received" }

            puts $pipe "setoption name MultiPV value $::batch_annotate::mpv"
            if {$threads ne ""} { puts $pipe "setoption name Threads value $threads" }
            if {$hash ne ""} { puts $pipe "setoption name Hash value $hash" }
            puts $pipe "isready"
            set readyok 0
            set timeout 50
            while {$timeout > 0} {
                update
                if {[eof $pipe]} { break }
                if {[gets $pipe line] >= 0} {
                    if {$line eq "readyok"} { set readyok 1; break }
                }
                after 100
                incr timeout -1
            }
            if {!$readyok} { error "Engine handshake timeout: readyok not received" }

            fileevent $pipe readable [list ::batch_annotate::read_engine $pipe]
        }
    } err]} {
        foreach p $pipes { catch { puts $p "quit"; close $p } }
        set pipes {}
        catch {cd $pwd}
        error $err
    }
    catch {cd $pwd}
}

# End the pane's job for this batch, if one is live. The board is decoration
# over the run: cancellation, completion and a failed start all take the same
# path, so a dead job cannot keep another run's board suppressed.
proc ::batch_annotate::endProgress {} {
    if {[info exists ::batch_annotate::token]} {
        catch { ::reviewprogress::finish $::batch_annotate::token }
        unset ::batch_annotate::token
    }
    return
}

proc ::batch_annotate::cancel {} {
    variable pipes
    set ::batch_annotate::cancelled 1
    # A verification is a second engine on the driver's connection, not one of
    # the batch pipes. Do not call ::reviewverify::stop without a token here: it
    # may belong to a Game Review. The cancelled guard and the run id drop any
    # batch answer that was already on its way.
    foreach pipe $pipes {
        catch { puts $pipe "quit" }
        catch { close $pipe }
    }
    set pipes {}
    ::batch_annotate::endProgress
    if {[winfo exists .batchAnnotateProgress]} {
        destroy .batchAnnotateProgress
    }
    tk_messageBox -message $::tr(BatchCancelled)
}

proc ::batch_annotate::assign_game {pipe} {
    variable game_queue
    variable base
    variable pipe_game
    variable pipe_moves
    variable pipe_evals
    variable pipe_map
    variable pipe_plan
    variable pipe_book

    set game_id ""
    while {1} {
        if {[llength $::batch_annotate::game_queue] == 0} {
            # The caller that is finishing a game calls check_completion after
            # the game is written; completion before the save would report a
            # batch that has not reached the database yet.
            set ::batch_annotate::engine_state($pipe) "done"
            return
        }

        set game_id [lindex $::batch_annotate::game_queue 0]
        set ::batch_annotate::game_queue [lrange $::batch_annotate::game_queue 1 end]

        if {$game_id eq "" || ![string is integer -strict $game_id] || $game_id <= 0} {
            continue
        }
        if {[catch {sc_base numGames $::batch_annotate::base} max_games]} {
            continue
        }
        if {$game_id > $max_games} { continue }
        break
    }

    set pipe_game($pipe) $game_id
    # The game's place in the run, fixed for the life of the game. Counting the
    # games actually assigned rather than the queue's position keeps a skipped
    # selection from shifting every later number; a game requeued after an
    # engine died keeps the number it already had.
    if {![info exists ::batch_annotate::seq_of]} {
        set ::batch_annotate::seq_of [dict create]
    }
    if {[dict exists $::batch_annotate::seq_of $game_id]} {
        set pipe_seq($pipe) [dict get $::batch_annotate::seq_of $game_id]
    } else {
        incr ::batch_annotate::assigned
        dict set ::batch_annotate::seq_of $game_id $::batch_annotate::assigned
        set pipe_seq($pipe) $::batch_annotate::assigned
    }
    set pipe_evals($pipe) {}

    if {[winfo exists .batchAnnotateProgress]} {
        .batchAnnotateProgress.l configure -text "$::tr(BatchAnalyzingGames)"
    }

    set prev_base [sc_base current]
    if {$prev_base != $::batch_annotate::base} {
        if {[catch {sc_base switch $::batch_annotate::base}]} {
            set ::batch_annotate::engine_state($pipe) "done"
            ::batch_annotate::check_completion
            return
        }
    }
    sc_game push copy
    sc_game load $game_id

    # The same snapshot a Game Review pass takes: the main line, where the book
    # ends, every move for the writer, and the positions it has to search.
    set map [::review::mainLineMap [sc_game UCI_mainLine]]
    set plies [dict get $map plies]
    set bookEnd 0
    set skip 1
    catch { set skip [::review::get skip_book] }
    if {$skip} {
        set book [::enginewin::reviewBook]
        if {$book ne ""} {
            catch { set bookEnd [::review::bookEnd $book 5 1] }
        }
    }
    set plan [::review::plan $plies 0]
    set search {}
    foreach ply $plan {
        if {$bookEnd == 0 || $ply >= $bookEnd} { lappend search $ply }
    }
    set pipe_map($pipe) $map
    set pipe_plan($pipe) $plan
    set pipe_book($pipe) $bookEnd
    set pipe_moves($pipe) [::reviewdriver::planPositions $map $search]

    sc_game pop
    puts $pipe "ucinewgame"
    ::batch_annotate::feed_move $pipe
}

proc ::batch_annotate::check_completion {} {
    variable pipes
    variable total_games
    variable games_completed
    # Cancel already closed the run and showed its own message. A verifier that
    # answers afterwards must not turn the empty pipe list into "Batch complete".
    if {[info exists ::batch_annotate::cancelled] && $::batch_annotate::cancelled} {
        return
    }
    
    set all_done 1
    foreach p $pipes {
        if {$::batch_annotate::engine_state($p) ne "done"} { set all_done 0; break }
    }
    if {$all_done} {
        foreach p $pipes { catch { puts $p "quit"; close $p } }
        set pipes {}
        ::batch_annotate::endProgress
        if {[winfo exists .batchAnnotateProgress]} { destroy .batchAnnotateProgress }
        tk_messageBox -message [::batch_annotate::completionMessage]
    }
}

# What the completion dialog says: the games it finished, and how many plies in
# them ended with no verdict. The two are different questions - a game counts as
# done as soon as its write lands - and under a time cap an empty search result is
# the likeliest way for a move to go unjudged, so the count is the only place a
# user learns the batch fell short of judging every move.
proc ::batch_annotate::completionMessage {} {
    variable games_completed
    variable unscored_plies
    set games "$games_completed $::tr(BatchGames) $::tr(BatchProcessed)"
    set unjudged [format $::tr(BatchUnscoredPlies) $unscored_plies]
    return "$::tr(BatchComplete) $games, $unjudged."
}

proc ::batch_annotate::feed_move {pipe} {
    variable pipe_moves

    if {[llength $pipe_moves($pipe)] == 0} {
        ::batch_annotate::finalize_game $pipe
        return
    }

    set move_data [lindex $pipe_moves($pipe) 0]
    set pipe_moves($pipe) [lrange $pipe_moves($pipe) 1 end]

    lassign $move_data ply position
    set ::batch_annotate::engine_state($pipe) [list $ply $position]
    set ::batch_annotate::engine_lines($pipe) [dict create]

    # The board shows the position this pipe is searching now, and the header
    # says which game of the run it belongs to. The spec is the driver's own
    # `position fen ... moves ...` shape, replayed on a pure board, so this
    # cannot touch the game - the batch's borrows are push/load/save/pop and are
    # never current across an event loop turn.
    catch {
        if {[info exists ::batch_annotate::token]} {
            set game ""
            catch { set game $::batch_annotate::pipe_seq($pipe) }
            set done $::batch_annotate::games_completed
            ::reviewprogress::setSpec $::batch_annotate::token $position \
                $done $::batch_annotate::total_games $game
        }
    }

    puts $pipe $position
    # Both bounds in one Go, built by ::enginelimits::goLimits from the figures
    # ::review::effective computed: the review's depth floor and (when Review
    # Settings sets one) its time ceiling. The engine stops at whichever comes
    # first. The pipe is a text channel, so the list is joined rather than
    # handed to ::engine::send, which takes a list message.
    set limits [::enginelimits::goLimits [dict create \
        depth $::batch_annotate::depth movetime $::batch_annotate::movetime]]
    puts $pipe "go [join $limits]"
}

# Add one UCI "info" line to a position's MultiPV lines, in the review's
# {depth score score-type pv} shape. The deepest line for a rank wins; bounds
# and lines without a PV are not a verdict and are left out.
proc ::batch_annotate::collect {line lines} {
    # `info string` is free text, not an analysis line. It can contain the words
    # "score cp 20 pv ..." in a diagnostic, and since a line no longer needs a
    # depth it would otherwise become a verdict.
    if {[string match "info string *" $line]} {
        return $lines
    }
    # A bound is not a verdict: the review's lineScore would not use it either.
    if {[string match "*lowerbound*" $line] || [string match "*upperbound*" $line]} {
        return $lines
    }
    set multipv 1
    set depth ""
    set score ""
    set score_type ""
    set pv ""
    regexp {multipv (\d+)} $line -> multipv
    regexp { depth (\d+)} $line -> depth
    regexp {score (cp|mate) (-?\d+)} $line -> score_type score
    regexp { pv (.+)$} $line -> pv
    # UCI does not require `depth`, and an engine that omits it still has a
    # usable line. The review driver's collector keeps those; this one must too,
    # or a move the pass could judge is counted as unjudged here.
    if {![string is integer -strict $depth]} { set depth 0 }
    if {$score_type ne "" && $score ne "" && $pv ne ""} {
        # Equal depth: the later line is the fresher reading, as in the review
        # driver's collector. A deeper line still wins.
        if {[dict exists $lines $multipv] &&
            [lindex [dict get $lines $multipv] 0] > $depth} {
            return $lines
        }
        dict set lines $multipv [list $depth $score $score_type $pv]
    }
    return $lines
}

proc ::batch_annotate::read_engine {pipe} {
    variable game_queue
    variable pipe_game

    if {[gets $pipe line] < 0} {
        if {[eof $pipe]} {
            set state $::batch_annotate::engine_state($pipe)
            if {$state ne "idle" && $state ne "done"} {
                if {[info exists pipe_game($pipe)]} {
                    lappend game_queue $pipe_game($pipe)
                }
            }
            set ::batch_annotate::engine_state($pipe) "done"
            catch {close $pipe}
            ::batch_annotate::check_completion
        }
        return
    }
    if {$line eq ""} { return }

    set state $::batch_annotate::engine_state($pipe)
    if {$state eq "idle" || $state eq "done"} { return }
    lassign $state ply position

    if {[string match "info *" $line]} {
        set ::batch_annotate::engine_lines($pipe) \
            [::batch_annotate::collect $line $::batch_annotate::engine_lines($pipe)]
    } elseif {[string match "bestmove *" $line]} {
        dict set ::batch_annotate::pipe_evals($pipe) $ply \
            $::batch_annotate::engine_lines($pipe)
        ::batch_annotate::feed_move $pipe
    }
}

# How many of the moves this game set out to judge will be written with no
# verdict: the writer's own decision (::reviewdriver::judge), counted per move,
# not per searched position.
#
# Counting empty position results overstated it. ::reviewdriver::planPositions
# searches the position BEFORE each move and the position AFTER it, so one empty
# search could be charged to two moves, and the successor of the last planned
# ply is not a move at all - no move is judged from it. A move is judged from the
# position before it, with the successor only supplying the figure after it.
#
# A null move is a header in place of a ply, not a move to label, so it is not
# counted either - judge refuses it for the same reason.
proc ::batch_annotate::unjudgedCount {map evals plan {bookEnd 0}} {
    set sides [::reviewdriver::sides $map]
    set n 0
    foreach ply $plan {
        if {[::review::playedMove $map $ply] eq ""} { continue }
        # The writer labels the book as theory, not as a move it failed to
        # judge; counting those plies would report every book line as unjudged.
        if {$bookEnd > 0 && $ply <= $bookEnd} { continue }
        if {[::reviewdriver::judge $map $evals $sides $ply] eq ""} { incr n }
    }
    return $n
}

proc ::batch_annotate::finalize_game {pipe} {
    variable pipe_game
    variable pipe_evals
    variable pipe_map
    variable pipe_plan
    variable pipe_book
    variable base
    variable games_completed
    variable unscored_plies

    incr games_completed
    set game_id $pipe_game($pipe)
    set evals $pipe_evals($pipe)
    set map $pipe_map($pipe)
    set plan $pipe_plan($pipe)
    set bookEnd $pipe_book($pipe)

    # Moves this game set out to judge, and how many will get no verdict. Kept
    # per move (see unjudgedCount) because a searched position is not a move:
    # the count is what the completion dialog reports, so it has to be the
    # number the writer actually left unjudged.
    incr unscored_plies [::batch_annotate::unjudgedCount $map $evals $plan $bookEnd]

    # Start the next game immediately to keep the engine busy; the write is the
    # slow part.
    ::batch_annotate::assign_game $pipe

    # Exactly the Game Review writer: label, [%eval], the label's NAG, the
    # assessment and the diagram, with variations from Review Settings. It is
    # reached through the driver's shared seam, so the batch gets the same
    # Brilliant/Great verification a single game review does - the batch must not
    # bypass it (issue #422 item 5). The verifier is its own engine; the batch's
    # pipes are already on the next game by the time it answers.
    set engineName ""
    catch { set engineName $::batch_annotate::engine_name }
    set engineCfg ""
    if {$engineName ne ""} { catch { set engineCfg [::enginecfg::get $engineName] } }
    set p [dict create map $map plan $plan plies [dict get $map plies] \
        bookEnd $bookEnd mpv $::batch_annotate::mpv \
        engine $engineCfg base $::batch_annotate::base \
        runId $::batch_annotate::run_id \
        verifier [::batch_annotate::verifierEngine] \
        limits [dict create depth $::batch_annotate::depth \
            movetime $::batch_annotate::movetime]]
    ::reviewdriver::verifyWrite $p $evals \
        [list ::batch_annotate::writeGame $pipe $game_id $map $plan $bookEnd $p]
}

# The verifier engine Review Settings names, or "" for Off. Read per game, so a
# setting changed while the batch runs applies to the games it has not reached:
# the batch is one pass over many games, not one pass over one game.
proc ::batch_annotate::verifierEngine {} {
    set name ""
    catch { set name [::review::verifier] }
    return $name
}

# Write one finished game into the database. The tail of ::finalize_game: the
# game is loaded, written with the review writer, saved and put back. Kept apart
# because the verifier can answer after ::finalize_game returns - its search is
# a second engine, and the batch's pipes are already busy with the next game -
# so everything the write needs travels in the arguments rather than in the
# per-pipe arrays, which assign_game has since overwritten.
proc ::batch_annotate::writeGame {pipe game_id map plan bookEnd p results corrections} {
    variable base
    # Cancel closes the batch and closes the batch's own pipes. A verification
    # answer that was already in flight is not a reason to write one more game or
    # to show the completion box over the cancelled run. A new batch has its own
    # run id, so an answer from the previous run cannot write into it either.
    set runId ""
    catch { set runId [dict get $p runId] }
    if {$runId ne "" && $runId ne $::batch_annotate::run_id} { return }
    if {[info exists ::batch_annotate::cancelled] && $::batch_annotate::cancelled} {
        return
    }
    # The shared transform, immediately before the write: the label the writer
    # puts in the game is the one the second engine agreed with.
    set results [::reviewdriver::verified $results $corrections]
    if {[dict size $corrections]} { dict set p corrections $corrections }

    # The base is the run's, not whatever ::batch_annotate::base names now: a new
    # dialog can overwrite the namespace while this answer is still in flight.
    set runBase ""
    catch { set runBase [dict get $p base] }
    if {$runBase eq ""} { set runBase $base }
    set prev_base [sc_base current]
    if {$prev_base != $runBase} { sc_base switch $runBase }

    sc_game push copy
    sc_game load $game_id

    catch { ::reviewdriver::writeResults $p $results }

    sc_game save $game_id
    sc_game pop
    ::notify::DatabaseModified $runBase
    ::batch_annotate::check_completion
}
