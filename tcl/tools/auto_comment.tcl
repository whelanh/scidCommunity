############################################################
### Auto Comment - AI-generated chess commentary
### Queries engine evaluation APIs and uses Google Gemini
### to generate natural language commentary for positions.

namespace eval ::auto_comment {
    # Gemini API key - free from https://aistudio.google.com/apikey
    options.store ::auto_comment::apiKey ""
    options.store ::auto_comment::model "gemini-2.5-flash-lite"

    variable geminiApiBase "https://generativelanguage.googleapis.com/v1beta/models"
    variable lichessApiUrl "https://lichess.org/api/cloud-eval"
    variable chessdbApiUrl "http://www.chessdb.cn/cdb.php"
}

# ::auto_comment::configureApiKey
#   Dialog to set or change the Gemini API key.
#
proc ::auto_comment::configureApiKey {} {
    set w .autoCommentConfig
    if {[winfo exists $w]} {
        raise $w
        focus $w.entry
        return
    }

    toplevel $w
    wm title $w "Auto Comment - API Key"
    wm resizable $w 1 0

    ttk::frame $w.content -padding 15
    pack $w.content -fill both -expand 1

    ttk::label $w.content.info -text \
        "Enter your Google Gemini API key.\nGet a free key at: https://aistudio.google.com/apikey\n\nYour key is stored locally on your machine only.\nUse Options > Save Options to keep it between sessions." \
        -wraplength 400 -justify left
    pack $w.content.info -anchor w -pady {0 10}

    ttk::label $w.content.lbl -text "API Key:"
    pack $w.content.lbl -anchor w

    ttk::entry $w.entry -width 50 -textvariable ::auto_comment::apiKey
    pack $w.entry -in $w.content -fill x -pady {0 10}

    ttk::label $w.content.modellbl -text "Model:"
    pack $w.content.modellbl -anchor w

    ttk::entry $w.content.modelentry -width 30 -textvariable ::auto_comment::model
    pack $w.content.modelentry -anchor w -pady {0 10}

    ttk::frame $w.buttons -padding {15 5}
    pack $w.buttons -fill x

    ttk::button $w.buttons.ok -text "OK" -command "destroy $w"
    ttk::button $w.buttons.open -text "Open AI Studio" -command {
        openURL "https://aistudio.google.com/apikey"
    }
    pack $w.buttons.ok -side right -padx 5
    pack $w.buttons.open -side right -padx 5

    bind $w <Return> "destroy $w"
    bind $w <Escape> "destroy $w"
    focus $w.entry
}

# ::auto_comment::fetchLichessEval
#   Fetches cloud evaluation from the Lichess API.
#   Returns the raw JSON string, or "" on failure.
#
proc ::auto_comment::fetchLichessEval {fen} {
    set urlFen [string map {" " "%20"} $fen]
    set url "$::auto_comment::lichessApiUrl?fen=$urlFen&multiPv=3"

    set result ""
    if {![catch {exec curl -s --max-time 10 -H "Accept: */*" $url} result]} {
        # Check that it contains PV data (not an error response)
        if {[regexp {"pvs"} $result]} {
            return $result
        }
    }
    return ""
}

# ::auto_comment::fetchChessDBEval
#   Fallback: fetches evaluation from chessdb.cn.
#   Returns the raw JSON/text string, or "" on failure.
#
proc ::auto_comment::fetchChessDBEval {fen} {
    set urlFen [string map {" " "%20" "/" "%2F"} $fen]
    set url "$::auto_comment::chessdbApiUrl?action=queryall&board=$urlFen&showall=0&json=1"

    set result ""
    if {![catch {exec curl -s --max-time 10 $url} result]} {
        if {[string length $result] > 5} {
            return $result
        }
    }
    return ""
}

# ::auto_comment::formatLichessEval
#   Converts raw Lichess cloud eval JSON into human-readable text
#   with SAN notation and formatted scores.
#
proc ::auto_comment::formatLichessEval {jsonData fen} {
    # Determine side to move
    set color [lindex [split $fen] 1]
    set sideToMove [expr {$color eq "w" ? "White" : "Black"}]

    # Extract depth
    set depth ""
    regexp {"depth":(\d+)} $jsonData -> depth

    set isBlack [expr {$color eq "b"}]
    set result "Position evaluation (depth $depth). $sideToMove to move.\n"
    append result "Lines are ranked from best to worst for $sideToMove. Line 1 is the engine's top recommendation.\n"
    append result "Each line has a quality label showing how it compares to the best move.\n"

    # Move-label mapping: first SAN move -> quality label
    set moveLabels [dict create]

    # First pass: collect all PVs with their scores
    set pvList {}
    if {[regexp -indices {"pvs"\s*:\s*\[} $jsonData match]} {
        set arrayStart [lindex $match 1]
        set remaining [string range $jsonData $arrayStart end]

        while {[regexp -indices {\{[^\}]+\}} $remaining objMatch]} {
            set objStart [lindex $objMatch 0]
            set objEnd [lindex $objMatch 1]
            set obj [string range $remaining $objStart $objEnd]

            set moves ""
            set cp ""
            set mate ""

            regexp {"moves"\s*:\s*"([^"]*)"} $obj -> moves
            regexp {"cp"\s*:\s*(-?\d+)} $obj -> cp
            regexp {"mate"\s*:\s*(-?\d+)} $obj -> mate

            if {$moves ne ""} {
                lappend pvList [list $moves $cp $mate]
            }

            set remaining [string range $remaining [expr {$objEnd + 1}] end]
        }
    }

    # Get the best score (first line) for comparison
    set bestCp 0
    if {[llength $pvList] > 0} {
        set firstCp [lindex [lindex $pvList 0] 1]
        if {$firstCp ne ""} {
            # Normalize to side-to-move perspective for comparison
            set bestCp [expr {$isBlack ? -1 * $firstCp : $firstCp}]
        }
    }

    # Second pass: format with quality labels
    set lineNum 1
    foreach pv $pvList {
        lassign $pv moves cp mate

        # Compute quality label based on centipawn loss from best
        set label "best"
        if {$lineNum > 1 && $cp ne ""} {
            set thisCp [expr {$isBlack ? -1 * $cp : $cp}]
            set cpLoss [expr {$bestCp - $thisCp}]
            if {$cpLoss < 10} {
                set label "equal"
            } elseif {$cpLoss < 50} {
                set label "slightly worse"
            } elseif {$cpLoss < 100} {
                set label "inaccuracy"
            } elseif {$cpLoss < 200} {
                set label "mistake"
            } else {
                set label "blunder"
            }
        } elseif {$lineNum == 1 && $mate ne ""} {
            set label "best (mate)"
        }

        # Convert UCI to SAN
        set sanMoves [::lichess_eval::uciToSan $moves $fen]
        set numberedMoves [::lichess_eval::formatLine $fen $sanMoves]

        # Extract the first SAN move for move-label mapping
        set firstMove [lindex [split $sanMoves] 0]
        if {$firstMove ne ""} {
            dict set moveLabels $firstMove $label
        }

        append result "Line $lineNum ($label): $numberedMoves\n"
        incr lineNum
    }

    return [list $result $moveLabels]
}

# ::auto_comment::formatChessDBEval
#   Converts raw ChessDB JSON into human-readable text.
#   ChessDB already provides SAN notation, scores, and winrates.
#
proc ::auto_comment::formatChessDBEval {jsonData fen} {
    set color [lindex [split $fen] 1]
    set sideToMove [expr {$color eq "w" ? "White" : "Black"}]

    set result "Position evaluation (chessdb.cn). $sideToMove to move.\n"
    append result "Moves are ranked from best to worst for $sideToMove. Move 1 is the engine's top recommendation.\n"
    append result "Each move has a quality label showing how it compares to the best move.\n"
    append result "Top moves:\n"

    # Move-label mapping: SAN move -> quality label
    set moveLabels [dict create]

    # First pass: collect moves with scores
    set moveList {}
    set searchStart 0
    while {[llength $moveList] < 5 && [regexp -start $searchStart -indices \
            {"san"\s*:\s*"([^"]*)".*?"score"\s*:\s*(-?\d+).*?"winrate"\s*:\s*"([^"]*)"} \
            $jsonData match sanMatch scoreMatch wrMatch]} {

        set san [string range $jsonData [lindex $sanMatch 0] [lindex $sanMatch 1]]
        set score [string range $jsonData [lindex $scoreMatch 0] [lindex $scoreMatch 1]]
        set winrate [string range $jsonData [lindex $wrMatch 0] [lindex $wrMatch 1]]

        lappend moveList [list $san $score $winrate]
        set searchStart [expr {[lindex $match 1] + 1}]
    }

    # Get best score for comparison (chessdb scores are from side-to-move perspective)
    set bestScore 0
    if {[llength $moveList] > 0} {
        set bestScore [lindex [lindex $moveList 0] 1]
    }

    set count 0
    foreach mv $moveList {
        lassign $mv san score winrate
        incr count

        set label "best"
        if {$count > 1} {
            set cpLoss [expr {$bestScore - $score}]
            if {$cpLoss < 10} {
                set label "equal"
            } elseif {$cpLoss < 50} {
                set label "slightly worse"
            } elseif {$cpLoss < 100} {
                set label "inaccuracy"
            } elseif {$cpLoss < 200} {
                set label "mistake"
            } else {
                set label "blunder"
            }
        }

        dict set moveLabels $san $label
        append result "$count. $san ($label)\n"
    }

    return [list $result $moveLabels]
}

# ::auto_comment::queryGemini
#   Sends the FEN and engine analysis to the Gemini API.
#   Returns the generated commentary text, or "" on failure.
#
proc ::auto_comment::queryGemini {fen evalText {movePlayed ""}} {
    if {$::auto_comment::apiKey eq ""} {
        return ""
    }

    set model $::auto_comment::model
    set url "$::auto_comment::geminiApiBase/$model:generateContent"

    # Build the prompt with actual newlines (will be JSON-escaped below)
    set prompt "You are a chess commentator writing annotations for a chess game. You are given engine analysis and a VERDICT line that tells you exactly how the played move compares to the engine's best. TRUST the VERDICT completely — it is computed from engine scores and is always correct. Write commentary in 80 words or less based on the VERDICT. If the verdict says the move is \"best\" or \"equal\", praise it briefly and mention the key idea. If \"blunder\" or \"mistake\", clearly state it is an error and name the best alternative from Line 1 with a brief reason. Be specific and concrete. Do not use markdown formatting such as bold (**) or italics (*). Never capitalize chess move notation at the start of a sentence; pawn moves like a6, c5, e4 must stay lowercase."
    append prompt "\n\nFEN (position before the move): $fen"
    append prompt "\n\nMove played: $movePlayed"
    append prompt "\n\nEngine analysis for the position before the move:\n$evalText"

    # Escape the prompt for JSON string embedding.
    # Order matters: backslash first, then other special chars.
    set escaped [string map {
        "\\" "\\\\"
        "\"" "\\\""
        "\n" "\\n"
        "\r" "\\r"
        "\t" "\\t"
    } $prompt]

    set jsonBody "{\"contents\":\[{\"parts\":\[{\"text\":\"$escaped\"}\]}\]}"

    # Write JSON body to a temp file to avoid shell quoting issues
    set tmpfile [file join [::auto_comment::getTempDir] "auto_comment_req.json"]
    set fd [open $tmpfile w]
    puts -nonewline $fd $jsonBody
    close $fd

    set result ""
    set ok 0

    # Use 2>@1 to merge stderr into stdout so Tcl exec does not
    # treat curl diagnostic/warning output as an error.
    if {![catch {exec curl -s --max-time 30 \
            -H "Content-Type: application/json" \
            -H "x-goog-api-key: $::auto_comment::apiKey" \
            -X POST \
            -d @$tmpfile \
            $url 2>@1} result]} {
        set ok 1
    } else {
        puts stderr "Auto Comment: curl error: $result"
    }

    catch {file delete -force $tmpfile}

    if {!$ok} {
        return ""
    }

    # Check for API error responses
    if {[regexp {"error"\s*:\s*\{} $result]} {
        set errMsg ""
        regexp {"message"\s*:\s*"([^"]*)"} $result -> errMsg
        puts stderr "Auto Comment: Gemini API error: $errMsg"
        puts stderr "Auto Comment: Full response: $result"
        # Return a marker so generateComment can show the real error
        return "ERROR: $errMsg"
    }

    # Extract the text from the Gemini response
    # Response format: {"candidates":[{"content":{"parts":[{"text":"..."}],...},...}],...}
    set text ""
    if {[regexp {"text"\s*:\s*"((?:[^"\\]|\\.)*)"} $result -> rawText]} {
        # Unescape JSON string
        set text [string map {
            "\\n" "\n"
            "\\r" ""
            "\\t" " "
            "\\\"" "\""
            "\\\\" "\\"
        } $rawText]
        # Strip any markdown bold/italic markers the LLM might include
        set text [regsub -all {\*\*([^*]+)\*\*} $text {\1}]
        set text [regsub -all {\*([^*]+)\*} $text {\1}]
        # Fix capitalized pawn moves: A6->a6, C5->c5, etc.
        # Only matches a capital A-H followed by 1-8 that is NOT followed
        # by a lowercase letter (which would be a piece move like Bb4).
        set text [regsub -all {([^a-zA-Z])([A-H])([1-8])([^a-z])} $text {\1[string tolower "\2"]\3\4}]
        set text [subst -nobackslashes -novar $text]
        set text [string trim $text]
    } else {
        puts stderr "Auto Comment: Could not parse Gemini response: $result"
    }

    return $text
}

# ::auto_comment::generateComment
#   Main entry point. Fetches eval, queries LLM, inserts comment.
#
proc ::auto_comment::generateComment {} {
    # Check API key
    if {$::auto_comment::apiKey eq ""} {
        set answer [tk_messageBox -icon question -type yesno \
            -title "Auto Comment" \
            -message "No Gemini API key configured.\n\nWould you like to set one now?\n(Get a free key at aistudio.google.com/apikey)" \
            -parent .]
        if {$answer eq "yes"} {
            ::auto_comment::configureApiKey
        }
        return
    }

    # Get the move that was just played
    set movePlayed [sc_game info previousMove]

    if {$movePlayed eq ""} {
        tk_messageBox -icon info -type ok -title "Auto Comment" \
            -message "No move to comment on at the start of the game." \
            -parent .
        return
    }

    # Save current position, then step back to get the position
    # BEFORE the move was played — this is the position we evaluate.
    set savedOffset [sc_pos pgnOffset]
    sc_move back
    set prevFen [sc_pos fen]
    # Restore position
    sc_move pgn $savedOffset

    # Show a progress indicator
    set w .autoCommentProgress
    if {[winfo exists $w]} { destroy $w }
    toplevel $w
    wm title $w "Auto Comment"
    wm resizable $w 0 0
    ttk::label $w.lbl -text "Fetching engine analysis..." -padding 20
    pack $w.lbl
    update idletasks

    # Center the window
    set x [expr {[winfo screenwidth $w]/2 - 150}]
    set y [expr {[winfo screenheight $w]/2 - 30}]
    wm geometry $w "+$x+$y"
    update idletasks

    # Step 1: Fetch engine evaluation for the PREVIOUS position
    # (before the move was played)
    set evalJson [::auto_comment::fetchLichessEval $prevFen]
    set evalSource "lichess"
    set evalText ""

    set moveLabels [dict create]

    if {$evalJson ne ""} {
        # Convert Lichess UCI moves to human-readable SAN notation
        lassign [::auto_comment::formatLichessEval $evalJson $prevFen] evalText moveLabels
    } else {
        $w.lbl configure -text "Lichess eval not available, trying chessdb.cn..."
        update idletasks
        set evalJson [::auto_comment::fetchChessDBEval $prevFen]
        set evalSource "chessdb"
        if {$evalJson ne ""} {
            lassign [::auto_comment::formatChessDBEval $evalJson $prevFen] evalText moveLabels
        }
    }

    if {$evalText eq ""} {
        destroy $w
        tk_messageBox -icon info -type ok -title "Auto Comment" \
            -message "No engine evaluation available for this position from either Lichess or chessdb.cn.\n\nThis position may not have been analyzed yet." \
            -parent .
        return
    }

    # Match the played move against engine lines and append a verdict
    if {[dict exists $moveLabels $movePlayed]} {
        set playedLabel [dict get $moveLabels $movePlayed]
        append evalText "\nVERDICT: The played move $movePlayed is the engine's $playedLabel move."
    } else {
        append evalText "\nVERDICT: The played move $movePlayed does NOT appear in any of the engine's top lines, suggesting it may be a poor choice."
    }

    puts stderr "Auto Comment: Move played: $movePlayed"
    puts stderr "Auto Comment: Eval text sent to LLM:\n$evalText"

    # Step 2: Query Gemini with the previous position's eval and the move played
    $w.lbl configure -text "Generating AI commentary..."
    update idletasks

    set commentary [::auto_comment::queryGemini $prevFen $evalText $movePlayed]

    destroy $w

    if {$commentary eq ""} {
        tk_messageBox -icon warning -type ok -title "Auto Comment" \
            -message "Failed to generate commentary.\n\nPlease check your API key and internet connection." \
            -parent .
        return
    }

    if {[string match "ERROR:*" $commentary]} {
        set errDetail [string range $commentary 7 end]
        tk_messageBox -icon warning -type ok -title "Auto Comment" \
            -message "Gemini API error:\n\n$errDetail" \
            -parent .
        return
    }

    # Step 3: Insert as comment
    undoFeature save
    set existing [sc_pos getComment]
    if {$existing ne ""} {
        sc_pos setComment "$existing $commentary"
    } else {
        sc_pos setComment $commentary
    }

    # Refresh the PGN window and comment editor
    updateBoard -pgn
    if {[winfo exists .commentWin]} {
        ::windows::commenteditor::Refresh
    }
}

# ::auto_comment::getTempDir
#   Returns a suitable temporary directory.
#
proc ::auto_comment::getTempDir {} {
    if {[info exists ::env(TMPDIR)]} {
        return $::env(TMPDIR)
    } elseif {[info exists ::env(TEMP)]} {
        return $::env(TEMP)
    } elseif {[info exists ::env(TMP)]} {
        return $::env(TMP)
    } elseif {[file isdirectory "/tmp"]} {
        return "/tmp"
    } else {
        return [pwd]
    }
}
