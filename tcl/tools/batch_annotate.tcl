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
    variable use_book 0
    variable book_name ""
    
    variable pipes {}
    variable game_queue {}
    variable current_game ""
    variable current_game_fens {}
    variable current_game_evals ;# array mapping move_index -> eval_dict
    variable fen_queue {} ;# list of {move_index fen}
    variable active_engines 0
    variable num_moves 0
    variable moves_processed 0
    variable engine_state
    variable engine_eval
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
    pack $w.f.comment.scoreAll $w.f.comment.cbAnnotateVar $w.f.comment.cbShortAnnotation $w.f.comment.cbAddScore -fill x -anchor w -padx 5
    
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
    
    ::batch_annotate::process_next_game
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
    
    for {set i 0} {$i < $instances} {incr i} {
        set pipe [open "| \"[file nativename $cmd]\" $args" r+]
        fconfigure $pipe -buffering line -blocking 0
        
        # Initialize custom engine state
        set ::batch_annotate::engine_state($pipe) "idle"
        set ::batch_annotate::engine_eval($pipe) {}
        
        # Init UCI
        puts $pipe "uci"
        # Wait for uciok synchronously to avoid complex state machine
        set uciok 0
        while {1} {
            update
            if {[eof $pipe]} { break }
            if {[gets $pipe line] >= 0} {
                if {$line eq "uciok"} { set uciok 1; break }
            }
        }
        if {!$uciok} {
            puts $pipe "quit"
            catch {close $pipe}
            error "Engine did not respond with uciok"
        }
        puts $pipe "isready"
        while {1} {
            update
            if {[eof $pipe]} { break }
            if {[gets $pipe line] >= 0} {
                if {$line eq "readyok"} { break }
            }
        }
        
        fileevent $pipe readable [list ::batch_annotate::read_engine $pipe]
        lappend pipes $pipe
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

proc ::batch_annotate::process_next_game {} {
    variable game_queue
    variable base
    variable current_game
    variable current_game_fens
    variable fen_queue
    variable current_game_evals
    variable active_engines
    variable num_moves
    variable moves_processed
    variable pipes
    
    if {[llength $game_queue] == 0} {
        # All done!
        foreach pipe $pipes {
            catch { puts $pipe "quit" }
            catch { close $pipe }
        }
        set pipes {}
        if {[winfo exists .batchAnnotateProgress]} {
            destroy .batchAnnotateProgress
        }
        tk_messageBox -message "Batch Annotation Complete!"
        return
    }
    
    set current_game [lindex $game_queue 0]
    set game_queue [lreplace $game_queue 0 0]
    
    if {[winfo exists .batchAnnotateProgress]} {
        .batchAnnotateProgress.l configure -text "Analyzing Game $current_game... ([llength $game_queue] remaining)"
        .batchAnnotateProgress.pb configure -value 0 -maximum 100
    }
    
    # Save current game and load the one we want to annotate
    set prev_base [sc_base current]
    if {$prev_base != $base} { sc_base switch $base }
    
    # Push the current GUI game to stack so we don't destroy user state
    sc_game push copy
    
    sc_game load $current_game
    
    # Generate FENs for every move
    set current_game_fens {}
    sc_move start
    
    variable use_book
    variable book_name
    set book_moves_skipped 0
    if {$use_book && $book_name ne ""} {
        set bn [file join $::scidBooksDir $book_name]
        sc_book load $bn 2
        lassign [sc_book moves 2] bookmoves
        while {[string length $bookmoves] != 0 && ![sc_pos isAt end]} {
            sc_move forward
            incr book_moves_skipped
            lassign [sc_book moves 2] bookmoves
        }
        sc_book close 2
    }
    
    set idx $book_moves_skipped
    while {1} {
        lappend current_game_fens $idx [sc_pos fen]
        if {[sc_pos isAt end]} { break }
        sc_move forward
        incr idx
    }
    
    array unset current_game_evals
    set fen_queue $current_game_fens
    set num_moves [expr {[llength $current_game_fens] / 2}]
    set moves_processed 0
    set active_engines 0
    
    # Feed the engines
    foreach pipe $pipes {
        ::batch_annotate::feed_engine $pipe
    }
}

proc ::batch_annotate::feed_engine {pipe} {
    variable fen_queue
    variable movetime
    variable active_engines
    
    if {[llength $fen_queue] == 0} { return }
    
    set idx [lindex $fen_queue 0]
    set fen [lindex $fen_queue 1]
    set fen_queue [lreplace $fen_queue 0 1]
    
    set ::batch_annotate::engine_state($pipe) $idx
    set ::batch_annotate::engine_eval($pipe) {}
    
    puts $pipe "ucinewgame"
    puts $pipe "position fen $fen"
    puts $pipe "go movetime [expr {int($movetime * 1000)}]"
    
    incr active_engines
}

proc ::batch_annotate::read_engine {pipe} {
    variable num_moves
    variable moves_processed
    variable active_engines
    variable current_game_evals
    
    if {[gets $pipe line] < 0} {
        if {[eof $pipe]} {
            catch {close $pipe}
        }
        return
    }
    
    if {$line eq ""} { return }
    
    set idx $::batch_annotate::engine_state($pipe)
    if {$idx eq "idle"} { return }
    
    if {[string match "info *" $line]} {
        # Parse info
        if {[regexp {score (cp|mate) ([\-\d]+)} $line -> type val]} {
            set fen [lindex $::batch_annotate::current_game_fens [expr {$idx * 2 + 1}]]
            set side [lindex [split $fen " "] 1]
            
            if {$side eq "b"} { set val [expr {-$val}] }
            
            if {$type eq "mate"} {
                set score_fmt [expr {$val > 0 ? "M$val" : "M$val"}]
                set score_val [expr {$val > 0 ? 300.0 : -300.0}]
            } else {
                set score_val [expr {$val / 100.0}]
                if {$val > 0} {
                    set score_fmt [format "+%.2f" $score_val]
                } else {
                    set score_fmt [format "%.2f" $score_val]
                }
            }
            dict set ::batch_annotate::engine_eval($pipe) "score" $score_val
            dict set ::batch_annotate::engine_eval($pipe) "score_fmt" $score_fmt
        }
        if {[regexp {depth (\d+)} $line -> depth]} {
            dict set ::batch_annotate::engine_eval($pipe) "depth" $depth
        }
        if {[regexp { pv (.+)$} $line -> pv]} {
            dict set ::batch_annotate::engine_eval($pipe) "pv" $pv
        }
    } elseif {[string match "bestmove *" $line]} {
        # Engine finished this FEN
        set current_game_evals($idx) $::batch_annotate::engine_eval($pipe)
        set ::batch_annotate::engine_state($pipe) "idle"
        incr active_engines -1
        incr moves_processed
        
        if {[winfo exists .batchAnnotateProgress]} {
            if {$num_moves > 0} {
                .batchAnnotateProgress.pb configure -value [expr {($moves_processed * 100) / $num_moves}]
            } else {
                .batchAnnotateProgress.pb configure -value 100
            }
        }
        
        ::batch_annotate::feed_engine $pipe
        
        if {$active_engines == 0 && [llength $::batch_annotate::fen_queue] == 0} {
            # Game is completely analyzed
            after 10 ::batch_annotate::finish_game
        }
    }
}

proc ::batch_annotate::finish_game {} {
    variable current_game_evals
    variable annotate_mode
    variable blunder_threshold
    variable annotate_white
    variable annotate_black
    variable add_variation
    variable var_length
    variable short_annotation
    variable add_score_to_short
    variable score_all
    variable current_game
    variable num_moves
    
    # sc_game is still loaded from process_next_game
    sc_move start
    
    set prev_score ""
    set prev_score_fmt ""
    set prev_pv ""
    
    set idx 0
    while {1} {
        if {![info exists current_game_evals($idx)]} {
            if {[sc_pos isAt end]} { break }
            sc_move forward
            incr idx
            continue
        }
        
        set eval $current_game_evals($idx)
        set score ""
        set score_fmt ""
        set pv ""
        catch { set score [dict get $eval score] }
        catch { set score_fmt [dict get $eval score_fmt] }
        catch { set pv [dict get $eval pv] }
        
        set is_blunder 0
        set should_annotate 0
        
        set tomove [sc_pos side]
        
        # Check if we should annotate this side's move.
        if {$idx > 0} {
            if {$tomove eq "white"} {
                if {$annotate_black} { set should_annotate 1 }
            } else {
                if {$annotate_white} { set should_annotate 1 }
            }
        }
        
        if {$should_annotate && $score ne "" && $prev_score ne ""} {
            set delta [expr {$score - $prev_score}]
            if {$tomove eq "white"} {
                # Black just moved. If White's score increases, Black blundered.
                if {$delta >= $blunder_threshold} { set is_blunder 1 }
            } else {
                # White just moved. If White's score decreases, White blundered.
                if {$delta <= -$blunder_threshold} { set is_blunder 1 }
            }
        }
        
        if {$should_annotate && $score_fmt ne ""} {
            # Variation logic
            if {$is_blunder && $add_variation && $prev_pv ne ""} {
                sc_move back
                sc_var create
                
                # Extract PV
                set pv_moves [split [string trim $prev_pv] " "]
                set pv_moves [lrange $pv_moves 0 [expr {$var_length - 1}]]
                
                # Add first move and score
                ::uci::sc_move_add [lrange $pv_moves 0 0]
                if {!$short_annotation || $add_score_to_short} {
                    sc_pos setComment "\[$prev_score_fmt\]"
                }
                
                # Add remaining moves
                if {[llength $pv_moves] > 1} {
                    ::uci::sc_move_add [lrange $pv_moves 1 end]
                }
                
                sc_var exit
                sc_move forward
            }
            
            # Comment logic
            set do_comment 0
            if {$annotate_mode eq "allmoves"} { set do_comment 1 }
            if {$annotate_mode eq "blundersonly" && $is_blunder} { set do_comment 1 }
            
            if {$do_comment} {
                if {$is_blunder} { sc_pos addNag 4 }
                
                if {!$short_annotation} {
                    set text "\[$score_fmt\]"
                    sc_pos setComment "[sc_pos getComment] $text"
                } elseif {$add_score_to_short || $score_all} {
                    set text "\[$score_fmt\]"
                    sc_pos setComment "[sc_pos getComment] $text"
                }
            } elseif {$score_all} {
                set text "\[$score_fmt\]"
                sc_pos setComment "[sc_pos getComment] $text"
            }
        }
        
        set prev_score $score
        set prev_score_fmt $score_fmt
        set prev_pv $pv
        
        if {[sc_pos isAt end]} { break }
        sc_move forward
        incr idx
    }
    
    sc_game save $current_game
    sc_game pop
    
    ::notify::DatabaseModified [sc_base current]
    
    after 10 ::batch_annotate::process_next_game
}
