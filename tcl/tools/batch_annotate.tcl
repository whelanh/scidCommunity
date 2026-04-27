namespace eval ::batch_annotate {
    variable base ""
    variable games {}
    
    variable engine_index 0
    variable instances 2
    variable movetime 1.0
    variable annotate_mode "blundersonly"
    variable blunder_threshold 1.0
    variable annotate_white 1
    variable annotate_black 1
    variable add_variation 1
    variable var_length 5
    variable short_annotation 0
    variable add_score_to_short 1
    variable score_all 0
    variable clear_old 0
    variable use_book 0
    variable book_name ""
    
    variable active_engines 0
    variable pipe_game ;# pipe -> game_id
    variable pipe_moves ;# pipe -> list of {idx uci_pos}
    variable pipe_evals ;# pipe -> array/dict of idx -> eval
    variable games_completed 0
    variable total_games 0
}

proc ::batch_annotate::config {db games_list} {
    variable base
    variable games
    variable instances
    variable movetime
    variable blunders_only
    variable blunder_threshold
    variable engine_index
    
    set base $db
    set games $games_list
    
    set w .batchAnnotateConfig
    if {[winfo exists $w]} {
        raise $w
        focus $w
        return
    }
    
    win::createDialog $w
    ::setTitle $w "Batch Annotate"
    
    ttk::frame $w.f
    pack $w.f -padx 10 -pady 10 -fill both -expand 1
    
    # Engine Selection
    ttk::labelframe $w.f.engine -text "Engine Selection"
    ttk::label $w.f.engine.lEngine -text "Chess Engine:"
    set engine_names {}
    if {[info exists ::engines(list)]} {
        foreach e $::engines(list) { lappend engine_names [lindex $e 0] }
    }
    if {[llength $engine_names] == 0} {
        tk_messageBox -message "No engines configured!"
        destroy $w
        return
    }
    ttk::combobox $w.f.engine.cbEngine -values $engine_names -state readonly
    $w.f.engine.cbEngine current 0
    ttk::label $w.f.engine.lInstances -text "Number of Instances:"
    ttk::spinbox $w.f.engine.sbInstances -textvariable ::batch_annotate::instances -from 1 -to 16 -width 5
    
    grid $w.f.engine.lEngine $w.f.engine.cbEngine -sticky w -pady 2 -padx 5
    grid $w.f.engine.lInstances $w.f.engine.sbInstances -sticky w -pady 2 -padx 5
    
    # Analysis Options
    ttk::labelframe $w.f.analyse -text "Game Review"
    ttk::label $w.f.analyse.lTime -text "Time per move (sec):"
    ttk::spinbox $w.f.analyse.sbTime -textvariable ::batch_annotate::movetime -from 0.1 -to 60.0 -increment 0.1 -width 5
    ttk::radiobutton $w.f.analyse.allmoves -text "Annotate all moves" -variable ::batch_annotate::annotate_mode -value "allmoves"
    ttk::radiobutton $w.f.analyse.blundersonly -text "Annotate blunders only" -variable ::batch_annotate::annotate_mode -value "blundersonly"
    ttk::frame $w.f.analyse.blunderbox
    ttk::label $w.f.analyse.blunderbox.label -text "Blunder threshold:"
    ttk::spinbox $w.f.analyse.blunderbox.spBlunder -width 5 -textvariable ::batch_annotate::blunder_threshold -from 0.1 -to 5.0 -increment 0.1 -justify right
    pack $w.f.analyse.blunderbox.label $w.f.analyse.blunderbox.spBlunder -side left
    
    grid $w.f.analyse.lTime $w.f.analyse.sbTime -sticky w -pady 2 -padx 5
    grid $w.f.analyse.blundersonly -columnspan 2 -sticky w -pady 2 -padx 5
    grid $w.f.analyse.blunderbox -columnspan 2 -sticky w -pady 2 -padx 20
    grid $w.f.analyse.allmoves -columnspan 2 -sticky w -pady 2 -padx 5
    
    # Annotate Which
    ttk::labelframe $w.f.av -text "Annotate Which"
    ttk::checkbutton $w.f.av.white -text "For White moves" -variable ::batch_annotate::annotate_white
    ttk::checkbutton $w.f.av.black -text "For Black moves" -variable ::batch_annotate::annotate_black
    ttk::frame $w.f.av.varlength
    ttk::label $w.f.av.varlength.label -text "Variation length (moves):"
    ttk::spinbox $w.f.av.varlength.spVar -width 5 -textvariable ::batch_annotate::var_length -from 1 -to 50 -increment 1
    pack $w.f.av.varlength.label $w.f.av.varlength.spVar -side left
    pack $w.f.av.white $w.f.av.black -side top -fill x -anchor w -padx 5
    pack $w.f.av.varlength -side top -fill x -anchor w -pady 4 -padx 5
    
    # Opening Book
    ttk::labelframe $w.f.book -text "Opening Book"
    ttk::checkbutton $w.f.book.cbBook -text "Use Book" -variable ::batch_annotate::use_book
    set bookPath $::scidBooksDir
    set bookList [lsort -dictionary [glob -nocomplain -directory $bookPath *.bin]]
    set tmp {}
    foreach file $bookList { lappend tmp [file tail $file] }
    if {[llength $tmp] == 0} {
        set ::batch_annotate::use_book 0
        $w.f.book.cbBook configure -state disabled
        ttk::combobox $w.f.book.comboBooks -values {"No books found"} -state disabled
        $w.f.book.comboBooks current 0
    } else {
        ttk::combobox $w.f.book.comboBooks -values $tmp -state readonly -textvariable ::batch_annotate::book_name
        if {$::batch_annotate::book_name eq ""} { $w.f.book.comboBooks current 0 }
    }
    pack $w.f.book.comboBooks -side bottom -anchor w -padx 5 -pady 5
    pack $w.f.book.cbBook -side bottom -anchor w -padx 5 -pady 2
    
    # Comments
    ttk::labelframe $w.f.comment -text "Comments"
    ttk::checkbutton $w.f.comment.cbAnnotateVar -text "Annotate variations" -variable ::batch_annotate::add_variation
    ttk::checkbutton $w.f.comment.cbShortAnnotation -text "Short annotations" -variable ::batch_annotate::short_annotation
    ttk::checkbutton $w.f.comment.cbAddScore -text "Add score to short annotations" -variable ::batch_annotate::add_score_to_short
    ttk::checkbutton $w.f.comment.scoreAll -text "Score all moves" -variable ::batch_annotate::score_all
    ttk::checkbutton $w.f.comment.cbClearOld -text "Clear old comments and variations" -variable ::batch_annotate::clear_old
    pack $w.f.comment.cbClearOld $w.f.comment.scoreAll $w.f.comment.cbAnnotateVar $w.f.comment.cbShortAnnotation $w.f.comment.cbAddScore -fill x -anchor w -padx 5
    
    grid $w.f.engine -row 0 -column 0 -pady 5 -padx 5 -sticky nswe
    grid $w.f.analyse -row 0 -column 1 -pady 5 -padx 5 -sticky nswe
    grid $w.f.av -row 1 -column 0 -pady 5 -padx 5 -sticky nswe
    grid $w.f.comment -row 1 -column 1 -pady 5 -padx 5 -sticky nswe
    grid $w.f.book -row 2 -column 0 -columnspan 2 -pady 5 -padx 5 -sticky nswe
    
    ttk::frame $w.buttons
    pack $w.buttons -fill x -padx 10 -pady 10
    
    ttk::button $w.buttons.ok -text "Start" -command [list ::batch_annotate::start $w]
    ttk::button $w.buttons.cancel -text "Cancel" -command [list destroy $w]
    
    pack $w.buttons.cancel $w.buttons.ok -side right -padx 5
}

proc ::batch_annotate::start {w} {
    variable engine_index
    variable games
    variable game_queue
    
    set engine_index [$w.f.engine.cbEngine current]
    destroy $w
    
    # Build queue of game indices
    set game_queue {}
    foreach s $games {
        lassign [split $s "_"] idx ply
        if {$idx ne ""} {
            lappend game_queue $idx
        }
    }
    set ::batch_annotate::total_games [llength $game_queue]
    set ::batch_annotate::games_completed 0
    
    # Open UI Progress Window
    set pw .batchAnnotateProgress
    if {[winfo exists $pw]} { destroy $pw }
    win::createDialog $pw
    ::setTitle $pw "Batch Annotate Progress"
    ttk::label $pw.l -text "Initializing engines..."
    ttk::progressbar $pw.pb -mode determinate -length 300
    ttk::button $pw.b -text "Cancel" -command ::batch_annotate::cancel
    pack $pw.l -padx 10 -pady 5
    pack $pw.pb -padx 10 -pady 5
    pack $pw.b -pady 10
    
    if {[catch {::batch_annotate::start_engines} err]} {
        tk_messageBox -message "Error starting engines: $err"
        destroy $pw
        return
    }
    
    # Start analysis on all pipes
    foreach pipe $::batch_annotate::pipes {
        ::batch_annotate::assign_game $pipe
    }
}

proc ::batch_annotate::start_engines {} {
    variable instances
    variable engine_index
    variable pipes
    
    set pipes {}
    set e [lindex $::engines(list) $engine_index]
    set cmd [lindex $e 1]
    set args [lindex $e 2]
    set dir [lindex $e 3]
    
    set pwd [pwd]
    if {$dir ne "" && $dir ne "."} {
        catch {cd $dir}
    }
    
    if {[catch {
        for {set i 0} {$i < $instances} {incr i} {
            set pipe [open "| \"[file nativename $cmd]\" $args" r+]
            lappend pipes $pipe
            fconfigure $pipe -buffering line -blocking 0
            
            # Initialize custom engine state
            set ::batch_annotate::engine_state($pipe) "idle"
            set ::batch_annotate::engine_eval($pipe) {}
            
            # Init UCI
            puts $pipe "uci"
            set uciok 0
            set timeout 50 ;# 50 * 100ms = 5 seconds
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
    tk_messageBox -message "Batch Annotation Cancelled"
}

proc ::batch_annotate::assign_game {pipe} {
    variable game_queue
    variable base
    variable pipe_game
    variable pipe_moves
    variable pipe_evals
    variable pipes
    variable total_games
    variable games_completed
    
    if {[llength $game_queue] == 0} {
        set ::batch_annotate::engine_state($pipe) "done"
        ::batch_annotate::check_completion
        return
    }
    
    set game_id [lindex $game_queue 0]
    set game_queue [lreplace $game_queue 0 0]
    
    set pipe_game($pipe) $game_id
    set pipe_evals($pipe) {}
    
    if {[winfo exists .batchAnnotateProgress]} {
        .batchAnnotateProgress.l configure -text "Analyzing Games... ($games_completed / $total_games completed)"
        .batchAnnotateProgress.pb configure -value [expr {($games_completed * 100) / $total_games}]
    }
    
    set prev_base [sc_base current]
    if {$prev_base != $base} { sc_base switch $base }
    sc_game push copy
    sc_game load $game_id
    
    set moves {}
    sc_move start
    set ply_count 0
    
    variable use_book
    variable book_name
    if {$use_book && $book_name ne ""} {
        set bn [file join $::scidBooksDir $book_name]
        sc_book load $bn 2
        lassign [sc_book moves 2] bookmoves
        while {[string length $bookmoves] != 0 && ![sc_pos isAt end]} {
            sc_move forward
            incr ply_count
            lassign [sc_book moves 2] bookmoves
        }
        sc_book close 2
    }
    
    set idx $ply_count
    while {1} {
        lappend moves [list $idx [sc_pos fen] [sc_game UCI_currentPos]]
        if {[sc_pos isAt end]} { break }
        sc_move forward
        incr idx
    }
    sc_game pop
    
    set pipe_moves($pipe) $moves
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
        tk_messageBox -message "Batch Annotation Complete! $games_completed / $total_games games processed."
    }
}

proc ::batch_annotate::feed_move {pipe} {
    variable pipe_moves
    variable movetime
    
    if {[llength $pipe_moves($pipe)] == 0} {
        ::batch_annotate::finalize_game $pipe
        return
    }
    
    set move_data [lindex $pipe_moves($pipe) 0]
    set pipe_moves($pipe) [lrange $pipe_moves($pipe) 1 end]
    
    lassign $move_data idx fen uci_pos
    set ::batch_annotate::engine_state($pipe) [list $idx $fen]
    
    dict set ::batch_annotate::engine_eval($pipe) "score" ""
    dict set ::batch_annotate::engine_eval($pipe) "score_fmt" ""
    dict set ::batch_annotate::engine_eval($pipe) "pv" ""
    dict set ::batch_annotate::engine_eval($pipe) "score_fmt_depth" ""
    
    puts $pipe $uci_pos
    puts $pipe "go movetime [expr {int($movetime * 1000)}]"
}

proc ::batch_annotate::read_engine {pipe} {
    variable game_queue
    variable pipe_game
    
    if {[gets $pipe line] < 0} {
        if {[eof $pipe]} {
            set state $::batch_annotate::engine_state($pipe)
            if {$state ne "idle" && $state ne "done"} {
                # Engine crashed! Re-queue the current game.
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
    
    lassign $state idx fen
    
    if {[string match "info *" $line]} {
        if {![string match "*lowerbound*" $line] && ![string match "*upperbound*" $line]} {
            if {[regexp {score (cp|mate) ([\-\d]+)} $line -> type val]} {
                set side [lindex [split $fen " "] 1]
                if {$side eq "b"} { set val [expr {-$val}] }
                
                if {$type eq "mate"} {
                    set score_fmt [expr {$val > 0 ? "M$val" : "-M[expr {-$val}]"}]
                    set score_val [expr {$val > 0 ? 300.0 : -300.0}]
                } else {
                    set score_val [expr {$val / 100.0}]
                    set score_fmt [format "%+.2f" $score_val]
                }
                dict set ::batch_annotate::engine_eval($pipe) "score" $score_val
                dict set ::batch_annotate::engine_eval($pipe) "score_fmt" $score_fmt
            }
            if {[regexp {depth (\d+)} $line -> depth]} {
                dict set ::batch_annotate::engine_eval($pipe) "depth" $depth
                set s_fmt ""
                catch { set s_fmt [dict get [set ::batch_annotate::engine_eval($pipe)] "score_fmt"] }
                if {$s_fmt ne ""} {
                    dict set ::batch_annotate::engine_eval($pipe) "score_fmt_depth" "$depth:$s_fmt"
                }
            }
            if {[regexp { pv (.+)$} $line -> pv]} {
                dict set ::batch_annotate::engine_eval($pipe) "pv" $pv
            }
        }
    } elseif {[string match "bestmove *" $line]} {
        # Store eval for this move
        dict set ::batch_annotate::pipe_evals($pipe) $idx $::batch_annotate::engine_eval($pipe)
        ::batch_annotate::feed_move $pipe
    }
}

proc ::batch_annotate::finalize_game {pipe} {
    variable pipe_game
    variable pipe_evals
    variable base
    variable games_completed
    
    set game_id $pipe_game($pipe)
    set evals $pipe_evals($pipe)
    
    # Switch to DB and load game
    set prev_base [sc_base current]
    if {$prev_base != $base} { sc_base switch $base }
    
    sc_game push copy
    sc_game load $game_id
    
    # Clear old if requested
    variable clear_old
    if {$clear_old} {
        catch { sc_game strip comments }
        catch { sc_game strip variations }
    }
    
    ::batch_annotate::annotate_logic $evals
    
    sc_game save $game_id
    sc_game pop
    ::notify::DatabaseModified [sc_base current]
    
    incr games_completed
    ::batch_annotate::assign_game $pipe
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
        
        set is_blunder 0
        set should_annotate 0
        set tomove [sc_pos side]
        
        if {$idx > 0} {
            if {($tomove eq "white" && $annotate_black) || ($tomove eq "black" && $annotate_white)} {
                set should_annotate 1
            }
        }
        
        if {$should_annotate && $score ne "" && $prev_score ne ""} {
            set delta [expr {$score - $prev_score}]
            if {($tomove eq "white" && $delta >= $blunder_threshold) || ($tomove eq "black" && $delta <= -$blunder_threshold)} {
                set is_blunder 1
            }
        }
        
        if {$should_annotate && $score_fmt ne ""} {
            if {$is_blunder && $add_variation && $prev_pv ne ""} {
                sc_move back
                sc_var create
                set pv_moves [lrange [split [string trim $prev_pv] " "] 0 [expr {$var_length - 1}]]
                ::uci::sc_move_add [lrange $pv_moves 0 0]
                if {!$short_annotation || $add_score_to_short} {
                    sc_pos setComment "\[$prev_score_fmt\]"
                }
                if {[llength $pv_moves] > 1} {
                    ::uci::sc_move_add [lrange $pv_moves 1 end]
                }
                sc_var exit
                sc_move forward
            }
            
            set do_comment 0
            if {$annotate_mode eq "allmoves" || ($annotate_mode eq "blundersonly" && $is_blunder)} { set do_comment 1 }
            
            if {$do_comment} {
                if {$is_blunder} { sc_pos addNag 4 }
                if {!$short_annotation || $add_score_to_short || $score_all} {
                    sc_pos setComment "[sc_pos getComment] \[$score_fmt\]"
                }
            } elseif {$score_all} {
                sc_pos setComment "[sc_pos getComment] \[$score_fmt\]"
            }
        }
        
        set prev_score $score
        set prev_score_fmt $score_fmt
        set prev_pv $pv
        if {[sc_pos isAt end]} { break }
        sc_move forward
        incr idx
    }
}
