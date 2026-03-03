############################################################
### Auto Comment - AI-generated chess commentary
### Queries engine evaluation APIs and uses an LLM (Gemini
### or DeepSeek) to generate natural language commentary.

namespace eval ::auto_comment {
    # LLM provider: "gemini" or "deepseek"
    options.store ::auto_comment::provider "gemini"

    # Gemini settings
    options.store ::auto_comment::apiKey ""
    options.store ::auto_comment::model "gemini-2.5-flash-lite"

    # DeepSeek settings
    options.store ::auto_comment::deepseekApiKey ""
    options.store ::auto_comment::deepseekModel "deepseek-reasoner"

    variable geminiApiBase "https://generativelanguage.googleapis.com/v1beta/models"
    variable deepseekApiBase "https://api.deepseek.com"
    variable lichessApiUrl "https://lichess.org/api/cloud-eval"
    variable chessdbApiUrl "http://www.chessdb.cn/cdb.php"
}

# ::auto_comment::configureApiKey
#   Dialog to configure LLM provider and API keys.
#
proc ::auto_comment::configureApiKey {} {
    set w .autoCommentConfig
    if {[winfo exists $w]} {
        raise $w
        return
    }

    toplevel $w
    wm title $w "Auto Comment - Settings"
    wm resizable $w 1 0

    ttk::frame $w.content -padding 15
    pack $w.content -fill both -expand 1

    ttk::label $w.content.info -text \
        "Configure your LLM provider and API key(s).\nKeys are stored locally on your machine only.\nUse Options > Save Options to keep settings between sessions." \
        -wraplength 420 -justify left
    pack $w.content.info -anchor w -pady {0 10}

    # Provider selector
    ttk::label $w.content.provlbl -text "LLM Provider:"
    pack $w.content.provlbl -anchor w
    ttk::combobox $w.content.provider -textvariable ::auto_comment::provider \
        -values {gemini deepseek} -state readonly -width 15
    pack $w.content.provider -anchor w -pady {0 10}

    # --- Gemini section ---
    ttk::labelframe $w.content.gemini -text "Google Gemini" -padding 10
    pack $w.content.gemini -fill x -pady {0 10}

    ttk::label $w.content.gemini.keylbl -text "API Key:"
    pack $w.content.gemini.keylbl -anchor w
    ttk::entry $w.content.gemini.key -width 50 -textvariable ::auto_comment::apiKey
    pack $w.content.gemini.key -fill x -pady {0 5}

    ttk::label $w.content.gemini.modellbl -text "Model:"
    pack $w.content.gemini.modellbl -anchor w
    ttk::entry $w.content.gemini.model -width 30 -textvariable ::auto_comment::model
    pack $w.content.gemini.model -anchor w -pady {0 5}

    ttk::button $w.content.gemini.open -text "Get Gemini Key" -command {
        openURL "https://aistudio.google.com/apikey"
    }
    pack $w.content.gemini.open -anchor w

    # --- DeepSeek section ---
    ttk::labelframe $w.content.deepseek -text "DeepSeek" -padding 10
    pack $w.content.deepseek -fill x -pady {0 10}

    ttk::label $w.content.deepseek.keylbl -text "API Key:"
    pack $w.content.deepseek.keylbl -anchor w
    ttk::entry $w.content.deepseek.key -width 50 -textvariable ::auto_comment::deepseekApiKey
    pack $w.content.deepseek.key -fill x -pady {0 5}

    ttk::label $w.content.deepseek.modellbl -text "Model:"
    pack $w.content.deepseek.modellbl -anchor w
    ttk::entry $w.content.deepseek.model -width 30 -textvariable ::auto_comment::deepseekModel
    pack $w.content.deepseek.model -anchor w -pady {0 5}

    ttk::button $w.content.deepseek.open -text "Get DeepSeek Key" -command {
        openURL "https://platform.deepseek.com/api_keys"
    }
    pack $w.content.deepseek.open -anchor w

    # --- Buttons ---
    ttk::frame $w.buttons -padding {15 5}
    pack $w.buttons -fill x

    ttk::button $w.buttons.ok -text "OK" -command "destroy $w"
    pack $w.buttons.ok -side right -padx 5

    bind $w <Return> "destroy $w"
    bind $w <Escape> "destroy $w"
}

# ::auto_comment::fetchLichessEval
#   Fetches cloud evaluation from the Lichess API.
#   Returns the raw JSON string, or "" on failure.
#
proc ::auto_comment::fetchLichessEval {fen {variant "standard"}} {
    set urlFen [string map {" " "%20"} $fen]
    set url "$::auto_comment::lichessApiUrl?fen=$urlFen&multiPv=5&variant=$variant"

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

    # No PVs found — return empty
    if {[llength $pvList] == 0} {
        return [list "" [dict create]]
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

    # Parse individual move objects from the JSON "moves" array
    # to avoid cross-object mismatches when some scores are "??"
    set moveList {}
    if {[regexp -indices {"moves"\s*:\s*\[} $jsonData arrayMatch]} {
        set arrayStart [lindex $arrayMatch 1]
        set remaining [string range $jsonData $arrayStart end]

        while {[llength $moveList] < 5 && \
               [regexp -indices {\{[^\}]+\}} $remaining objMatch]} {
            set objStart [lindex $objMatch 0]
            set objEnd [lindex $objMatch 1]
            set obj [string range $remaining $objStart $objEnd]

            set san ""
            set score ""
            set winrate ""
            regexp {"san"\s*:\s*"([^"]*)"} $obj -> san
            regexp {"score"\s*:\s*(-?\d+)} $obj -> score
            regexp {"winrate"\s*:\s*"([^"]*)"} $obj -> winrate

            # Only include moves with a known numeric score
            if {$san ne "" && $score ne ""} {
                lappend moveList [list $san $score $winrate]
            }

            set remaining [string range $remaining [expr {$objEnd + 1}] end]
        }
    }

    # No moves found — return empty
    if {[llength $moveList] == 0} {
        return [list "" [dict create]]
    }

    # Get best score for comparison (chessdb scores are from side-to-move perspective)
    set bestScore [lindex [lindex $moveList 0] 1]

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

# ::auto_comment::buildPrompt
#   Builds the LLM prompt from the position data.
#   Returns the prompt string.
#
proc ::auto_comment::buildPrompt {fen evalText movePlayed variant {opening ""} {nagSymbol ""}} {
    set prompt "You are a chess commentator writing annotations for an intermediate club-level player who understands tactics but not deep strategy. You are given engine analysis and a VERDICT line. TRUST the VERDICT completely — it is computed from engine scores and is always correct."
    append prompt "\n\nPGN Annotation Symbols Reference:"
    append prompt "\nThe following annotation symbols may appear in the PGN (added by human annotators or local engine analysis). Use them to enrich your commentary when appropriate:"
    append prompt "\n  !?  (Interesting move) – worth considering, has merit"
    append prompt "\n  ?   (Poor move) – suboptimal, better alternatives exist"
    append prompt "\n  ??  (Blunder) – a serious mistake that loses significant material or advantage"
    append prompt "\n  ?!  (Dubious move) – questionable, risky, or hard to justify"
    append prompt "\n  +=  (Slight advantage) – small edge for White"
    append prompt "\n  +/- (Clear advantage) – White has a noticeable edge"
    append prompt "\n  +-  (Winning advantage) – White should win with correct play"
    append prompt "\n  +-- (Decisive/crushing advantage) – White has a completely winning position"
    append prompt "\n\nInstructions:"
    append prompt "\n- For moves labeled \"best\": explain the concrete idea — what does the move threaten, gain, or prevent? Reference the follow-up from the engine line if instructive. Keep it under 60 words."
    append prompt "\n- For \"equal\" moves: note it is a valid alternative and briefly contrast it with the engine's top choice from Line 1. Keep it under 60 words."
    append prompt "\n- For \"inaccuracy\", \"mistake\", or \"blunder\": clearly state the severity, name the best alternative from Line 1 with a concrete reason, and explain what the played move misses. Use up to 100 words for these."
    append prompt "\n- Do not use markdown formatting such as bold (**) or italics (*)."
    append prompt "\n- Never capitalize chess move notation at the start of a sentence; pawn moves like a6, c5, e4 must stay lowercase."
    append prompt "\n- ONLY refer to moves that appear in the engine analysis — do NOT invent or guess moves."
    if {$variant eq "chess960"} {
        append prompt "\n- This is a Chess960 (Fischer Random) game. Pieces start on non-standard squares. Do NOT assume standard piece placement."
    }

    # Game context
    if {$opening ne ""} {
        append prompt "\n\nOpening: $opening"
    }
    append prompt "\n\nFEN (position before the move): $fen"

    # Parse castling rights from FEN to prevent hallucinated castling plans
    set castling [lindex [split $fen] 2]
    set castleNotes {}
    if {[string first "K" $castling] == -1 && [string first "Q" $castling] == -1} {
        lappend castleNotes "White has already castled (or lost castling rights)."
    }
    if {[string first "k" $castling] == -1 && [string first "q" $castling] == -1} {
        lappend castleNotes "Black has already castled (or lost castling rights)."
    }
    if {[llength $castleNotes] > 0} {
        append prompt "\nCastling status: [join $castleNotes " "]"
    }

    append prompt "\n\nMove played: $movePlayed"
    if {$nagSymbol ne ""} {
        append prompt "\nAnnotation for this move: $nagSymbol"
    }
    append prompt "\n\nEngine analysis for the position before the move:\n$evalText"
    return $prompt
}

# ::auto_comment::cleanupText
#   Post-processes LLM output: strips markdown, fixes move notation.
#
proc ::auto_comment::cleanupText {text} {
    # Strip any markdown bold/italic markers the LLM might include
    set text [regsub -all {\*\*([^*]+)\*\*} $text {\1}]
    set text [regsub -all {\*([^*]+)\*} $text {\1}]
    # Fix capitalized pawn moves: A6->a6, C5->c5, etc.
    set text [regsub -all {([^a-zA-Z])([A-H])([1-8])([^a-z])} $text {\1[string tolower "\2"]\3\4}]
    set text [subst -nobackslashes -novar $text]
    # Fix lowercase piece moves: nf3->Nf3, bg5->Bg5, etc.
    set text [regsub -all {(^|[^a-zA-Z])([bknqr])([a-h][1-8])} $text {\1[string toupper "\2"]\3}]
    set text [subst -nobackslashes -novar $text]
    # Also fix piece captures: nxf3->Nxf3, bxe5->Bxe5, etc.
    set text [regsub -all {(^|[^a-zA-Z])([bknqr])(x[a-h][1-8])} $text {\1[string toupper "\2"]\3}]
    set text [subst -nobackslashes -novar $text]
    return [string trim $text]
}

# ::auto_comment::escapeJson
#   Escapes a string for embedding inside a JSON string value.
#
proc ::auto_comment::escapeJson {str} {
    return [string map {
        "\\" "\\\\"
        "\"" "\\\""
        "\n" "\\n"
        "\r" "\\r"
        "\t" "\\t"
    } $str]
}

# ::auto_comment::queryGemini
#   Sends the prompt to the Gemini API.
#   Returns the generated commentary text, or "" on failure.
#
proc ::auto_comment::queryGemini {prompt} {
    set model $::auto_comment::model
    set url "$::auto_comment::geminiApiBase/$model:generateContent"

    set escaped [::auto_comment::escapeJson $prompt]
    set jsonBody "{\"contents\":\[{\"parts\":\[{\"text\":\"$escaped\"}\]}\]}"

    set tmpfile [file join [::auto_comment::getTempDir] "auto_comment_req.json"]
    set fd [open $tmpfile w]
    puts -nonewline $fd $jsonBody
    close $fd

    set result ""
    set ok 0

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
        return "ERROR: $errMsg"
    }

    # Extract text from Gemini response
    set text ""
    if {[regexp {"text"\s*:\s*"((?:[^"\\]|\\.)*)"} $result -> rawText]} {
        set text [string map {
            "\\n" "\n"
            "\\r" ""
            "\\t" " "
            "\\\"" "\""
            "\\\\" "\\"
        } $rawText]
    } else {
        puts stderr "Auto Comment: Could not parse Gemini response: $result"
    }

    return [::auto_comment::cleanupText $text]
}

# ::auto_comment::queryDeepSeek
#   Sends the prompt to the DeepSeek API (OpenAI-compatible).
#   Returns the generated commentary text, or "" on failure.
#
proc ::auto_comment::queryDeepSeek {prompt} {
    set model $::auto_comment::deepseekModel
    set url "$::auto_comment::deepseekApiBase/chat/completions"

    set escapedPrompt [::auto_comment::escapeJson $prompt]
    set jsonBody "{\"model\":\"$model\",\"messages\":\[{\"role\":\"user\",\"content\":\"$escapedPrompt\"}\],\"stream\":false,\"temperature\":1.0}"

    set tmpfile [file join [::auto_comment::getTempDir] "auto_comment_req.json"]
    set fd [open $tmpfile w]
    puts -nonewline $fd $jsonBody
    close $fd

    set result ""
    set ok 0

    if {![catch {exec curl -s --max-time 60 \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $::auto_comment::deepseekApiKey" \
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
        puts stderr "Auto Comment: DeepSeek API error: $errMsg"
        puts stderr "Auto Comment: Full response: $result"
        return "ERROR: $errMsg"
    }

    # Extract text from DeepSeek response (OpenAI format)
    # {"choices":[{"message":{"content":"..."},...}],...}
    set text ""
    if {[regexp {"content"\s*:\s*"((?:[^"\\]|\\.)*)"} $result -> rawText]} {
        set text [string map {
            "\\n" "\n"
            "\\r" ""
            "\\t" " "
            "\\\"" "\""
            "\\\\" "\\"
        } $rawText]
    } else {
        puts stderr "Auto Comment: Could not parse DeepSeek response: $result"
    }

    return [::auto_comment::cleanupText $text]
}

# ::auto_comment::displayPrompt
#   Replaces the content of an existing window with the prompt display.
#   The window must already exist and be mapped (same pattern as Lichess Eval:
#   destroy loading label, add result frame as sibling, update idletasks, center).
#
proc ::auto_comment::displayPrompt {w prompt} {
    variable _pendingPrompt $prompt

    wm title $w "Auto Comment - LLM Prompt"

    # Remove the loading label (child of $w.content, matching Lichess eval pattern)
    destroy $w.content.loading

    # Build the prompt display as $w.result (new sibling of $w.content,
    # same structure as Lichess eval's displayResult)
    ttk::frame $w.result
    pack $w.result -fill both -expand 1 -padx 20 -pady 10

    # Toolbar: buttons and provider selector at the top
    ttk::frame $w.result.toolbar
    pack $w.result.toolbar -fill x -pady {0 5}

    ttk::label $w.result.toolbar.provlbl -text "Send via:"
    ttk::combobox $w.result.toolbar.provider -textvariable ::auto_comment::provider \
        -values {gemini deepseek} -state readonly -width 10
    pack $w.result.toolbar.provlbl -side left -padx {0 2}
    pack $w.result.toolbar.provider -side left -padx {0 10}

    ttk::button $w.result.toolbar.send -text "Send" -command [list apply {{w} {
        destroy $w
        ::auto_comment::sendPrompt
    }} $w]
    ttk::button $w.result.toolbar.copy -text "Copy" -command [list apply {{w} {
        $w.result.text configure -state normal
        $w.result.text tag add sel 1.0 end
        event generate $w.result.text <<Copy>>
        $w.result.text configure -state disabled
        $w.result.toolbar.copy configure -text "Copied!"
        after 1500 [list catch [list $w.result.toolbar.copy configure -text "Copy"]]
    }} $w]
    ttk::button $w.result.toolbar.cancel -text "Cancel" -command "destroy $w"

    pack $w.result.toolbar.send -side left -padx 5
    pack $w.result.toolbar.copy -side left -padx 5
    pack $w.result.toolbar.cancel -side left -padx 5

    ttk::label $w.result.info -text \
        "Review the prompt below. Send to an LLM, or Copy to paste into a web AI." \
        -wraplength 650 -justify left
    pack $w.result.info -anchor w -pady {0 5}

    # Text widget (same pattern as Lichess Eval: direct pack, no frame)
    text $w.result.text -height 35 -width 100 -wrap word -relief solid \
        -borderwidth 1 -font font_Regular -spacing1 4 -spacing3 4
    pack $w.result.text -fill both -expand 1 -pady {0 10}

    $w.result.text insert end $prompt
    $w.result.text configure -state disabled

    bind $w <Escape> "destroy $w"
    focus $w.result.toolbar.send

    # Center the window
    update idletasks
    set x [expr {[winfo screenwidth $w]/2 - [winfo width $w]/2}]
    set y [expr {[winfo screenheight $w]/2 - [winfo height $w]/2}]
    wm geometry $w "+$x+$y"
}

# ::auto_comment::sendPrompt
#   Called when the user clicks Send in the prompt preview window.
#   Handles API key check, LLM query, and comment insertion.
#
proc ::auto_comment::sendPrompt {} {
    set prompt $::auto_comment::_pendingPrompt

    # Check API key before sending
    set needKey 0
    if {$::auto_comment::provider eq "deepseek"} {
        if {$::auto_comment::deepseekApiKey eq ""} { set needKey 1 }
    } else {
        if {$::auto_comment::apiKey eq ""} { set needKey 1 }
    }
    if {$needKey} {
        set answer [tk_messageBox -icon question -type yesno \
            -title "Auto Comment" \
            -message "No API key configured for [string totitle $::auto_comment::provider].\n\nWould you like to configure it now?" \
            -parent .]
        if {$answer eq "yes"} {
            ::auto_comment::configureApiKey
        }
        return
    }

    # Show progress while querying LLM
    set w .autoCommentProgress
    if {[winfo exists $w]} { destroy $w }
    toplevel $w
    wm title $w "Auto Comment"
    wm resizable $w 0 0
    ttk::label $w.lbl -text "Generating AI commentary ([string totitle $::auto_comment::provider])..." \
        -padding 20
    pack $w.lbl
    update idletasks
    set x [expr {[winfo screenwidth $w]/2 - 150}]
    set y [expr {[winfo screenheight $w]/2 - 30}]
    wm geometry $w "+$x+$y"
    update idletasks

    # Query the LLM
    if {$::auto_comment::provider eq "deepseek"} {
        set commentary [::auto_comment::queryDeepSeek $prompt]
    } else {
        set commentary [::auto_comment::queryGemini $prompt]
    }

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
            -message "[string totitle $::auto_comment::provider] API error:\n\n$errDetail" \
            -parent .
        return
    }

    # Insert as comment
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

# ::auto_comment::generateComment
#   Main entry point. Fetches eval, queries LLM, inserts comment.
#
proc ::auto_comment::generateComment {} {
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

    # Create popup window (same pattern as Lichess Eval: always resizable,
    # loading label inside a content frame, no early wm geometry)
    set w .autoCommentPrompt
    if {[winfo exists $w]} { destroy $w }
    toplevel $w
    wm title $w "Auto Comment"
    wm resizable $w 1 1

    ttk::frame $w.content -padding 20
    pack $w.content -fill both -expand 1

    ttk::label $w.content.loading -text "Fetching engine analysis..." -font font_Bold
    pack $w.content.loading -pady 10

    update idletasks

    # Detect game variant (standard or chess960)
    set gameVariant [sc_game variant]
    if {$gameVariant eq "chess960"} {
        set variant "chess960"
    } else {
        set variant "standard"
    }

    # Step 1: Fetch engine evaluation for the PREVIOUS position
    # (before the move was played)
    set evalJson [::auto_comment::fetchLichessEval $prevFen $variant]
    set evalSource "lichess"
    set evalText ""

    set moveLabels [dict create]

    if {$evalJson ne ""} {
        # Convert Lichess UCI moves to human-readable SAN notation
        lassign [::auto_comment::formatLichessEval $evalJson $prevFen] evalText moveLabels
    } else {
        $w.content.loading configure -text "Lichess eval not available, trying chessdb.cn..."
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

    # Get opening info from ECO code
    set opening ""
    set eco [sc_game tag get ECO]
    if {$eco eq ""} {
        # Try auto-classifying if no ECO header
        catch {set eco [sc_eco game]}
    }
    if {$eco ne ""} {
        set opening $eco
    }

    # Build the prompt and display it in the SAME window (no destroy/recreate)
    set prompt [::auto_comment::buildPrompt $prevFen $evalText $movePlayed $variant $opening]

    ::auto_comment::displayPrompt $w $prompt
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
