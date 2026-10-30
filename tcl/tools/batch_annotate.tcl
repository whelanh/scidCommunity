namespace eval ::batch_annotate {
    variable base ""
    variable games {}
    
    variable engine_name
    variable instances
    
    variable pipe_game ;# pipe -> game_id
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

    set ::batch_annotate::game_queue {}
    foreach s $games {
        lassign [split [string trim $s] "_"] idx ply
        if {$idx ne "" && [string is integer -strict $idx] && $idx > 0} {
            lappend ::batch_annotate::game_queue $idx
        }
    }
    set num_games [llength $::batch_annotate::game_queue]
    set ::batch_annotate::total_games $num_games
    set ::batch_annotate::games_completed 0

    set num_engines $instances
    if {$num_engines > $num_games} { set num_engines $num_games }
    if {$num_engines < 1} { return }

    set pw .batchAnnotateProgress
    if {[winfo exists $pw]} { destroy $pw }
    win::createDialog $pw
    ::setTitle $pw $::tr(BatchProgress)
    ttk::label $pw.l -text $::tr(BatchInitializingEngines)
    ttk::button $pw.b -text $::tr(BatchCancel) -command ::batch_annotate::cancel
    pack $pw.l -padx 10 -pady 10
    pack $pw.b -pady 10

    if {[catch {::batch_annotate::start_engines $num_engines} err]} {
        tk_messageBox -message "Error starting engines: $err"
        destroy $pw
        return
    }

    foreach pipe $::batch_annotate::pipes {
        ::batch_annotate::assign_game $pipe
    }
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

proc ::batch_annotate::cancel {} {
    variable pipes
    foreach pipe $pipes {
        catch { puts $pipe "quit" }
        catch { close $pipe }
    }
    set pipes {}
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
            set ::batch_annotate::engine_state($pipe) "done"
            ::batch_annotate::check_completion
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
    
    set all_done 1
    foreach p $pipes {
        if {$::batch_annotate::engine_state($p) ne "done"} { set all_done 0; break }
    }
    if {$all_done} {
        foreach p $pipes { catch { puts $p "quit"; close $p } }
        set pipes {}
        if {[winfo exists .batchAnnotateProgress]} { destroy .batchAnnotateProgress }
        tk_messageBox -message "$::tr(BatchComplete) $games_completed $::tr(BatchGames) $::tr(BatchProcessed)."
    }
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
    if {$score_type ne "" && $score ne "" && $depth ne "" && $pv ne ""} {
        if {[dict exists $lines $multipv] &&
            [lindex [dict get $lines $multipv] 0] >= $depth} {
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

proc ::batch_annotate::finalize_game {pipe} {
    variable pipe_game
    variable pipe_evals
    variable pipe_map
    variable pipe_plan
    variable pipe_book
    variable base
    variable games_completed

    incr games_completed
    set game_id $pipe_game($pipe)
    set evals $pipe_evals($pipe)
    set map $pipe_map($pipe)
    set plan $pipe_plan($pipe)
    set bookEnd $pipe_book($pipe)

    # Start the next game immediately to keep the engine busy; the write is the
    # slow part.
    ::batch_annotate::assign_game $pipe

    set prev_base [sc_base current]
    if {$prev_base != $base} { sc_base switch $base }

    sc_game push copy
    sc_game load $game_id

    # Exactly the Game Review writer: label, [%eval], the label's NAG, the
    # assessment and the diagram, with variations from Review Settings.
    set p [dict create map $map plan $plan plies [dict get $map plies] \
        bookEnd $bookEnd mpv $::batch_annotate::mpv]
    catch { ::reviewdriver::writeResults $p $evals }

    sc_game save $game_id
    sc_game pop
    ::notify::DatabaseModified [sc_base current]
}
