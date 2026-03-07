############################################################
### Analysis Auto Comment
### Scans the entire game for annotated moves and generates
### AI commentary using variations as the primary PV source.
############################################################

namespace eval ::analysis_auto_comment {
    variable selectedModel ""
}

proc ::analysis_auto_comment::batch_generate {} {
    set w .analysisAutoCommentDlg
    if {[winfo exists $w]} {
        raise $w
        return
    }

    toplevel $w
    wm title $w "Auto Comment - Batch Process"
    wm resizable $w 1 1
    wm minsize $w 450 250
    wm transient $w .
    
    # Center the window
    update idletasks
    set x [expr {[winfo screenwidth $w]/2 - [winfo width $w]/2}]
    set y [expr {[winfo screenheight $w]/2 - [winfo height $w]/2}]
    wm geometry $w "+$x+$y"

    ttk::frame $w.content -padding 15
    pack $w.content -fill both -expand 1

    ttk::label $w.content.info -text \
        "This will scan the entire game and generate AI commentary for every move that has a NAG or an existing comment.\n\n" \
        -wraplength 400 -justify left
    pack $w.content.info -pady {0 10}

    ttk::label $w.content.note -text \
        "Note: This feature works best on games that have already been annotated (preferably with engine-generated variations and scores). For best results, run the Annotate button first." \
        -wraplength 400 -justify left -foreground #666666
    pack $w.content.note -pady {0 10}

    ttk::label $w.content.modellbl -text "LLM Provider:"
    pack $w.content.modellbl -anchor w
    ttk::combobox $w.content.provider -textvariable ::auto_comment::provider \
        -values {gemini deepseek} -state readonly -width 15
    pack $w.content.provider -anchor w -pady {0 10}

    ttk::frame $w.buttons -padding {0 5}
    pack $w.buttons -fill x

    ttk::button $w.buttons.start -text "Start" -command {
        destroy .analysisAutoCommentDlg
        ::analysis_auto_comment::run_batch
    }
    ttk::button $w.buttons.cancel -text "Cancel" -command "destroy $w"
    pack $w.buttons.cancel $w.buttons.start -side right -padx 5

    bind $w <Return> "$w.buttons.start invoke"
    bind $w <Escape> "destroy $w"
}

proc ::analysis_auto_comment::run_batch {} {
    # Check API keys first (reuse auto_comment logic)
    set provider $::auto_comment::provider
    set needKey 0
    if {$provider eq "deepseek"} {
        if {$::auto_comment::deepseekApiKey eq ""} { set needKey 1 }
    } else {
        if {$::auto_comment::apiKey eq ""} { set needKey 1 }
    }

    if {$needKey} {
        set answer [tk_messageBox -icon question -type yesno \
            -title "Auto Comment" \
            -message "No API key configured for [string totitle $provider].\n\nWould you like to configure it now?" \
            -parent .]
        if {$answer eq "yes"} {
            ::auto_comment::configureApiKey
        }
        return
    }

    # Save current position
    set savedPos [sc_pos pgnOffset]
    
    # Progress window
    set pw .batchProgress
    if {[winfo exists $pw]} { destroy $pw }
    toplevel $pw
    wm title $pw "Auto Comment - Processing"
    wm resizable $pw 1 1
    wm minsize $pw 350 150
    wm transient $pw .
    
    # Center the window
    update idletasks
    set x [expr {[winfo screenwidth $pw]/2 - [winfo width $pw]/2}]
    set y [expr {[winfo screenheight $pw]/2 - [winfo height $pw]/2}]
    wm geometry $pw "+$x+$y"
    
    ttk::frame $pw.content -padding 20
    pack $pw.content -fill both -expand 1
    
    ttk::label $pw.content.lbl -text "Scanning game for annotated moves..."
    pack $pw.content.lbl
    
    ttk::progressbar $pw.content.pb -mode indeterminate
    pack $pw.content.pb -fill x -pady 10
    
    update idletasks

    # Start scanning
    sc_move start
    set gameNum [sc_game number]
    set gameVariant [sc_game variant]
    set variant [expr {$gameVariant eq "chess960" ? "chess960" : "standard"}]
    set opening ""
    set eco [sc_game tag get ECO]
    if {$eco eq ""} { catch {set eco [sc_eco game]} }
    if {$eco ne ""} { set opening [::auto_comment::getOpeningName $eco] }

    set annotatedPositions {}

    # Initial scan to find moves to process
    while {1} {
        set nags [string trim [sc_pos getNags]]
        set comment [sc_pos getComment]
        set movePlayed [sc_game info previousMoveNT]
        
        # We check movePlayed to skip the very start of game (ply 0).
        # User only wants comments for moves that have a NAG (Annotation Symbol).
        # We skip if the only annotation is "D" (Diagram).
        if {$movePlayed ne "" && $nags ne "0" && $nags ne "D" && $nags ne ""} {
            lappend annotatedPositions [list [sc_pos pgnOffset] $movePlayed]
        }
        
        if {[sc_pos isAt end]} { break }
        sc_move forward
    }

    set total [llength $annotatedPositions]
    if {$total == 0} {
        destroy $pw
        sc_move pgn $savedPos
        tk_messageBox -icon info -type ok -title "Auto Comment" \
            -message "No annotated moves (NAGs or comments) found in this game." \
            -parent .
        return
    }

    $pw.content.pb configure -mode determinate -maximum $total -value 0
    set count 0

    foreach item $annotatedPositions {
        incr count
        lassign $item offset movePlayed

        $pw.content.lbl configure -text "Processing move $count of $total: $movePlayed"
        $pw.content.pb configure -value $count
        update idletasks

        # Move to the position AFTER the played move to read its comment/score
        sc_move pgn $offset
        set currentPgn [sc_game firstMoves -1]
        set playedMoveComment [sc_pos getComment]
        set playedMoveScore ""
        if {[regexp {(\d+):([+-]?\d+\.?\d*|Mate in -?\d+)} $playedMoveComment -> depth score]} {
            set playedMoveScore "score $score at depth $depth"
        } elseif {[regexp {(-?\d+\.?\d*|Mate in -?\d+)} $playedMoveComment score]} {
            set playedMoveScore $score
        }

        # Read the NAG annotation symbol (e.g., "!?", "??", "+-", or multiple like "?? +/-")
        set nagSymbol [string trim [sc_pos getNags]]
        if {$nagSymbol eq "0"} { set nagSymbol "" }

        sc_move back
        set prevFen [sc_pos fen]
        
        # 1. Fetch Tree Statistics WHILE AT THE PRIOR POSITION
        set treeInfo [::auto_comment::getTreeInfo [sc_base current]]
        
        # Determine source of evaluation
        set evalText ""
        set moveLabels [dict create]
        
        # 1. ALWAYS try to fetch Cloud Evaluations FIRST (Lichess, then ChessDB)
        # This provides the AI with multi-line context and inaccuracy/mistake labels.
        set evalJson [::auto_comment::fetchLichessEval $prevFen $variant]
        if {$evalJson ne ""} {
            lassign [::auto_comment::formatLichessEval $evalJson $prevFen] evalText moveLabels
        } else {
            set evalJson [::auto_comment::fetchChessDBEval $prevFen]
            if {$evalJson ne ""} {
                lassign [::auto_comment::formatChessDBEval $evalJson $prevFen] evalText moveLabels
            }
        }

        # 2. Extract PGN Variations as "Ground Truth"
        # If a variation exists, we treat it as the absolute best line, overriding cloud best moves if they differ.
        set varCount [sc_var count]
        if {$varCount > 0} {
            set variationMoves {}
            set varScores {}
            sc_var enter 0
            set firstVarMove [sc_game info previousMoveNT]
            lappend variationMoves $firstVarMove
            
            set firstComm [sc_pos getComment]
            if {[regexp {(\d+):([+-]?\d+\.?\d*|Mate in -?\d+)} $firstComm -> depth score]} {
                lappend varScores "score $score at depth $depth"
            } elseif {[regexp {(-?\d+\.?\d*|Mate in -?\d+)} $firstComm score]} {
                lappend varScores $score
            }

            set vCount 1
            while {$vCount < 10 && ![sc_pos isAt vend]} {
                sc_move forward
                set mv [sc_game info previousMoveNT]
                lappend variationMoves $mv
                set comm [sc_pos getComment]
                if {[regexp {(\d+):([+-]?\d+\.?\d*|Mate in -?\d+)} $comm -> depth score]} {
                    if {[llength $varScores] < [llength $variationMoves]} {
                        lappend varScores "score $score at depth $depth"
                    }
                } elseif {[regexp {(-?\d+\.?\d*|Mate in -?\d+)} $comm score]} {
                    if {[llength $varScores] < [llength $variationMoves]} { lappend varScores $score }
                }
                incr vCount
            }
            sc_var exit
            
            if {[llength $variationMoves] > 0} {
                set firstVarMove [lindex $variationMoves 0]
                set varLine [::lichess_eval::formatLine $prevFen $variationMoves]
                set varScoreStr [expr {[llength $varScores] > 0 ? [lindex $varScores 0] : "unknown score"}]
                
                set groundTruth "\nGROUND TRUTH BEST LINE (from PGN variation, $varScoreStr): $varLine\n"
                append groundTruth "TRUST this variation as the absolute best recommendation. Use the cloud analysis lines below ONLY for comparing other moves or understanding the general position evaluation. When commenting on the variation, simply refer to it as the best line without over-interpreting the deep follow-up moves to avoid hallucination.\n"
                
                set evalText "${evalText}${groundTruth}"
                # Ensure the variation's first move is labeled as best
                dict set moveLabels $firstVarMove "best"
            }
        }

        if {$evalText ne ""} {
            # Append verdict
            if {[dict exists $moveLabels $movePlayed]} {
                set playedLabel [dict get $moveLabels $movePlayed]
                append evalText "\nVERDICT: The played move $movePlayed is the engine's $playedLabel move."
            } else {
                append evalText "\nVERDICT: The played move $movePlayed does NOT appear in any of the engine's top lines, suggesting it may be a poor choice."
            }
            if {$playedMoveScore ne ""} {
                append evalText " The engine evaluation for the played move $movePlayed is $playedMoveScore."
            }

            # Identify who just moved (we are at the position BEFORE the move)
            set side [sc_pos side]
            set whoMoved [expr {$side eq "white" ? "White" : "Black"}]
            
            # Build prompt
            set prompt [::auto_comment::buildPrompt $prevFen $evalText $movePlayed $variant $opening $nagSymbol 1 1 $whoMoved 0 $currentPgn $treeInfo]

            # Query LLM
            set commentary ""
            if {$provider eq "deepseek"} {
                set commentary [::auto_comment::queryDeepSeek $prompt]
            } else {
                set commentary [::auto_comment::queryGemini $prompt]
            }
            
            if {$commentary ne "" && ![string match "ERROR:*" $commentary]} {
                # Go back to annotated position to append comment
                sc_move pgn $offset
                undoFeature save
                set existing [sc_pos getComment]
                if {[string first $commentary $existing] == -1} {
                    if {$existing ne ""} {
                        sc_pos setComment "$existing $commentary"
                    } else {
                        sc_pos setComment $commentary
                    }
                }
            }
        }
    }

    destroy $pw
    
    # Restore original position
    sc_move pgn $savedPos
    updateBoard -pgn
    if {[winfo exists .commentWin]} {
        ::windows::commenteditor::Refresh
    }
    
    tk_messageBox -icon info -type ok -title "Auto Comment" \
        -message "Batch processing complete. Generated commentary for $count moves." \
        -parent .
}
