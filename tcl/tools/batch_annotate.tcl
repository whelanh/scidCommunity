namespace eval ::batch_annotate {
    variable base ""
    variable games {}
    
    variable engine_index 0
    variable engine_name
    variable instances
    variable movetime
    variable annotate_mode
    variable blunder_threshold
    variable annotate_white
    variable annotate_black
    variable add_variation
    variable var_length
    variable short_annotation
    variable add_score_to_short
    variable score_all
    variable clear_old
    variable use_book
    variable book_name
    
    variable active_engines 0
    variable pipe_game ;# pipe -> game_id
    variable pipe_moves ;# pipe -> list of {ply position}
    variable pipe_evals ;# pipe -> dict ply -> {rank {depth score type pv}}
    variable pipe_map ;# pipe -> the game's main-line map
    variable pipe_plan ;# pipe -> every move, for the writer
    variable pipe_book ;# pipe -> where the opening book ends
    variable engine_lines ;# pipe -> the MultiPV lines of the position in flight
    variable mpv 3
    variable depth 18
    variable games_completed 0
    variable total_games 0
}

# Register user-configurable preferences for saving via Options > Save Options
::options.store ::batch_annotate::instances 2
::options.store ::batch_annotate::movetime 1.0
::options.store ::batch_annotate::annotate_mode "blundersonly"
::options.store ::batch_annotate::blunder_threshold 1.0
::options.store ::batch_annotate::annotate_white 1
::options.store ::batch_annotate::annotate_black 1
::options.store ::batch_annotate::add_variation 1
::options.store ::batch_annotate::var_length 5
::options.store ::batch_annotate::short_annotation 0
::options.store ::batch_annotate::add_score_to_short 1
::options.store ::batch_annotate::score_all 0
::options.store ::batch_annotate::clear_old 0
::options.store ::batch_annotate::use_book 0
::options.store ::batch_annotate::book_name ""
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
    # the preset's, MultiPV at least two, and the pass budget for Threads/Hash.
    set eff [::review::effective $cfg]
    set ::batch_annotate::mpv [dict get $eff mpv]
    set ::batch_annotate::depth [dict get $eff depth]
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
    # Depth, not time: the review depth from Review Settings, with the preset's
    # floor, is what Game Review would have searched.
    puts $pipe "go depth $::batch_annotate::depth"
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

proc ::batch_annotate::annotate_logic {evals} {
    variable annotate_mode
    variable blunder_threshold
    variable annotate_white
    variable annotate_black
    variable add_variation
    variable var_length
    variable short_annotation
    variable add_score_to_short
    variable score_all
    
    sc_move start
    set prev_score ""
    set prev_score_fmt ""
    set prev_pv ""
    
    set idx 0
    while {1} {
        if {![dict exists $evals $idx]} {
            if {[sc_pos isAt end]} { break }
            sc_move forward
            incr idx
            continue
        }
        
        set eval [dict get $evals $idx]
        set score ""
        set score_fmt ""
        set pv ""
        catch { set score [dict get $eval score] }
        catch { 
            set score_fmt [dict get $eval score_fmt_depth] 
            if {$score_fmt eq ""} { set score_fmt [dict get $eval score_fmt] }
        }
        catch { set pv [dict get $eval pv] }
        
        set tomove [sc_pos side]
        set at_end [sc_pos isAt end]
        
        # Mate scores are stored as +/-300.0; flag them so we skip
        # numeric-evaluation NAGs that would be meaningless.
        set is_mate [expr {$score ne "" && [string is double -strict $score] && abs($score) >= 100.0}]
        set prev_is_mate [expr {$prev_score ne "" && [string is double -strict $prev_score] && abs($prev_score) >= 100.0}]
        
        # Capture the SAN of the move that was just played (for the closing
        # line at the end of the game). Bail-out style mirrors analysis.tcl,
        # which never adds a closing line on a checkmating move.
        set gamemove ""
        catch { set gamemove [sc_game info previousMoveNT] }
        set gamemove_is_mate [expr {[string length $gamemove] > 0 && [string index $gamemove end] eq "#"}]
        
        # Should this side's move be annotated? `tomove` is the side now
        # to move (i.e., the OPPONENT of the side that just moved).
        set should_annotate 0
        if {$idx > 0} {
            if {($tomove eq "white" && $annotate_black) || ($tomove eq "black" && $annotate_white)} {
                set should_annotate 1
            }
        }
        
        # Did the played move match the engine's preferred move from the
        # previous position? This mirrors analysis.tcl's bestMovePlayed /
        # bestMoveIsMate logic: we render the engine's first PV move into
        # SAN (via a scratch copy of the game) and compare to the move
        # actually played. If they match we suppress the redundant
        # variation and smooth out small score drift.
        set bestMovePlayed 0
        set bestMoveIsMate 0
        if {$prev_pv ne "" && $gamemove ne ""} {
            set pv_first [lindex [split [string trim $prev_pv] " "] 0]
            if {$pv_first ne ""} {
                set best_san ""
                if {![catch {
                    sc_game push copyfast
                    sc_move back 1
                    if {[::uci::sc_move_add [list $pv_first]] == 0} {
                        set best_san [sc_game info previousMoveNT]
                    }
                    sc_game pop
                }]} {
                    if {$best_san ne "" && $best_san eq $gamemove} {
                        set bestMovePlayed 1
                    }
                    if {$best_san ne "" && [string index $best_san end] eq "#"} {
                        set bestMoveIsMate 1
                    }
                }
            }
        }
        
        # Compute deltamove the same way analysis.tcl does:
        #   deltamove = prevscore - score, then negated when white just moved
        # so that a positive value always means "the player who just moved
        # made a worse move".  When the engine's preferred move WAS played
        # we use score in place of prevscore to absorb tiny eval drift.
        set effective_prev_score $prev_score
        if {$bestMovePlayed && $score ne ""} {
            set effective_prev_score $score
        }
        set delta_move 0
        set absdeltamove 0
        if {$effective_prev_score ne "" && $score ne ""} {
            set delta_move [expr {$effective_prev_score - $score}]
            if {$tomove eq "white"} {
                set delta_move [expr {0.0 - $delta_move}]
            }
            set absdeltamove [expr {abs($delta_move)}]
        }
        
        # gameIsLost: was the player who just moved already in a losing
        # position before they moved? (Don't pile on annotations if so.)
        set gameIsLost 0
        if {$prev_score ne ""} {
            if {$tomove eq "white"} {
                set gameIsLost [expr {$prev_score > $::informant(+--)}]
            } else {
                set gameIsLost [expr {$prev_score < (0.0 - $::informant(+--))}]
            }
        }
        
        # isBlunder levels (mirror analysis.tcl):
        #   2 = full blunder (deltamove > blunder_threshold)
        #   1 = mild slip    (0 < deltamove <= blunder_threshold)
        #   0 = no slip      (deltamove <= 0)
        set isBlunder 0
        if {$delta_move > $blunder_threshold} {
            set isBlunder 2
        } elseif {$delta_move > 0} {
            set isBlunder 1
        }
        
        # Decide whether this move enters the full annotation path.
        set do_annotate 0
        if {$should_annotate && $score_fmt ne ""} {
            if {$annotate_mode eq "allmoves"} {
                set do_annotate 1
            } elseif {$annotate_mode eq "blundersonly" && !$gameIsLost} {
                if {$isBlunder > 1} {
                    set do_annotate 1
                } elseif {$isBlunder > 0 && $is_mate} {
                    # Match analysis.tcl's `abs(score) >= 327.0` mate guard
                    set do_annotate 1
                }
            }
        }
        
        if {$do_annotate} {
            # Move-quality NAG, picked by |delta| against the user's
            # configurable ::informant thresholds (the same table the
            # Analysis window uses).
            if {$isBlunder > 0} {
                if {$absdeltamove > $::informant(??)} {
                    catch { sc_pos addNag "??" }
                } elseif {$absdeltamove > $::informant(?)} {
                    catch { sc_pos addNag "?" }
                } elseif {$absdeltamove > $::informant(?!)} {
                    catch { sc_pos addNag "?!" }
                }
            } elseif {$absdeltamove > $::informant(!?)} {
                catch { sc_pos addNag "!?" }
            }
            
            # Score comment for the played move (plain depth:+score, to
            # match analysis.tcl's PGN format).
            if {!$short_annotation || $add_score_to_short || $score_all} {
                sc_pos setComment "[sc_pos getComment] $score_fmt"
            }
            
            # Position-evaluation NAG (=, +=, +/-, +-, +--, ...).
            if {!$is_mate} {
                catch { sc_pos addNag [scoreToNag $score] }
            }
            
            # Alternative variation showing what should have been played.
            if {$isBlunder > 0 && $add_variation && $prev_pv ne ""} {
                sc_move back
                # Diagram NAG in blundersonly mode (avoid duplicates).
                if {$annotate_mode eq "blundersonly"} {
                    if {[string first "D" "[sc_pos getNags]"] == -1} {
                        catch { sc_pos addNag "D" }
                    }
                }
                # Mirror analysis.tcl's per-side variation gate.
                set addThisVariation 0
                if {$annotate_white && $annotate_black} {
                    set addThisVariation 1
                } elseif {$annotate_white && $tomove eq "black"} {
                    set addThisVariation 1
                } elseif {$annotate_black && $tomove eq "white"} {
                    set addThisVariation 1
                }
                if {$addThisVariation} {
                    sc_var create
                    set pv_moves [lrange [split [string trim $prev_pv] " "] 0 [expr {$var_length - 1}]]
                    if {[llength $pv_moves] > 0} {
                        ::uci::sc_move_add [lrange $pv_moves 0 0]
                        # Skip the score comment when the engine's first
                        # move is itself a mating move (matches
                        # analysis.tcl's bestMoveIsMate behavior).
                        if {!$bestMoveIsMate && !$prev_is_mate} {
                            if {!$short_annotation || $add_score_to_short} {
                                sc_pos setComment "$prev_score_fmt"
                            }
                        }
                        if {[llength $pv_moves] > 1} {
                            ::uci::sc_move_add [lrange $pv_moves 1 end]
                        }
                        if {!$prev_is_mate} {
                            catch { sc_pos addNag [scoreToNag $prev_score] }
                        }
                    }
                    sc_var exit
                }
                sc_move forward
            }
        } else {
            # Not in the full annotation path. Mirror the small
            # "interesting move" / score-everything fallbacks from
            # analysis.tcl's else branch.
            if {$should_annotate && $score_fmt ne ""} {
                if {$isBlunder == 0 && $absdeltamove > $::informant(!?)} {
                    catch { sc_pos addNag "!?" }
                }
                if {$score_all} {
                    sc_pos setComment "[sc_pos getComment] $score_fmt"
                }
            }
        }
        
        # Closing PV variation on the final move of the game.
        # (analysis.tcl's $addClosingLine block.)
        if {$at_end && $score_fmt ne "" && $pv ne "" && \
            $gamemove ne "" && !$gamemove_is_mate} {
            sc_move back
            sc_var create
            if {![catch {sc_move addSan $gamemove}]} {
                if {!$is_mate} {
                    if {!$short_annotation || $add_score_to_short} {
                        sc_pos setComment "$score_fmt"
                    }
                }
                set pv_moves [lrange [split [string trim $pv] " "] 0 [expr {$var_length - 1}]]
                if {[llength $pv_moves] > 0} {
                    ::uci::sc_move_add $pv_moves
                }
                if {!$is_mate} {
                    catch { sc_pos addNag [scoreToNag $score] }
                }
            }
            sc_var exit
            sc_move forward
        }
        
        set prev_score $score
        set prev_score_fmt $score_fmt
        set prev_pv $pv
        if {[sc_pos isAt end]} { break }
        sc_move forward
        incr idx
    }
}
