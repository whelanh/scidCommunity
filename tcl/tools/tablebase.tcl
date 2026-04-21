############################################################
### Tablebase lookup window using Lichess API
### Copyright (C) 2025

namespace eval ::tablebase {
    # Use HTTPS for the Lichess tablebase API
    variable lichessUrl "https://tablebase.lichess.ovh/standard"
}

# ::tablebase::countPieces
#   Counts the total number of pieces on the board from a FEN string
#
proc ::tablebase::countPieces {fen} {
    # FEN format: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    # First field is the board position
    set boardPart [lindex [split $fen] 0]
    
    # Count all piece characters (uppercase and lowercase letters)
    set count 0
    foreach char [split $boardPart ""] {
        if {[string is alpha $char]} {
            incr count
        }
    }
    return $count
}

# ::tablebase::queryTablebaseResult
#   Queries the tablebase and returns a simplified result string
#   Returns: "winning", "losing", "draw", or "error: <message>"
#
proc ::tablebase::queryTablebaseResult {fen} {
    # URL-encode spaces in FEN for the query string
    # (Lichess expects standard URL encoding like %20, not underscores)
    set urlFen [string map {" " "%20"} $fen]
    
    # Construct the API URL
    set url "$::tablebase::lichessUrl?fen=$urlFen"
    
    # Try to query the tablebase
    set result ""
    set err ""
    set ok 0

    # Try curl first (preferred)
    set cmd [list curl -s --max-time 10 $url]
    if {![catch {exec {*}$cmd} result]} {
        set ok 1
    } else {
        set err $result
        # Fallback: Tcl's built-in http package (register TLS for HTTPS)
        if {![catch {package require http}]} {
            catch {package require tls}
            catch {::http::register https 443 ::tls::socket}
            set token ""
            if {![catch {set token [::http::geturl $url -timeout 10000]} httpErr]} {
                set result [::http::data $token]
                ::http::cleanup $token
                set ok 1
            } else {
                set err $httpErr
            }
        }
    }

    if {!$ok} {
        return "error: Failed to query tablebase"
    }
    
    if {[string match "*not found*" $result] || [string match "*error*" $result]} {
        return "error: Position not found in tablebase"
    }
    
    # Extract category from JSON
    set category ""
    if {[regexp {"category":"([^"]+)"} $result -> category]} {
        # Determine side to move for clear messaging
        set color [lindex [split $fen] 1]
        set sideToMove [expr {$color eq "w" ? "White" : "Black"}]
        set opponent [expr {$color eq "w" ? "Black" : "White"}]
        
        # Map category to clear result messages
        switch -glob $category {
            "win"            { return "winning for $sideToMove" }
            "loss"           { return "losing for $sideToMove (winning for $opponent)" }
            "draw"           { return "draw with perfect play" }
            "cursed-win"     { return "winning for $sideToMove" }
            "blessed-loss"   { return "draw with perfect play" }
            "maybe-win"      { return "likely winning for $sideToMove (partial analysis)" }
            "maybe-loss"     { return "likely losing for $sideToMove (partial analysis)" }
            "unknown"        { return "unknown (outside tablebase coverage)" }
            default           { return "error: Unknown category: $category" }
        }
    }
    
    return "error: Unable to parse tablebase result"
}

# ::tablebase::uciToSan
#   Converts a UCI move (e.g., "e2e4") to SAN (e.g., "e4" or "Nge7")
#   Requires the FEN to determine piece types and disambiguation
#
proc ::tablebase::uciToSan {uciMove fen} {
    if {$uciMove eq "" || [string length $uciMove] < 4} {
        return $uciMove
    }
    
    set from [string range $uciMove 0 1]
    set to [string range $uciMove 2 3]
    set promotion ""
    if {[string length $uciMove] >= 5} {
        set promotion [string index $uciMove 4]
    }
    
    set board [lindex [split $fen] 0]
    set rows [split $board "/"]
    
    set fromFile [string index $from 0]
    set fromRank [string index $from 1]
    set toFile [string index $to 0]
    set toRank [string index $to 1]
    
    set fromCol [scan $fromFile "%c"]
    set fromRow [expr {8 - $fromRank}]
    set toCol [scan $toFile "%c"]
    set toRow [expr {8 - $toRank}]
    
    set piece ""
    set pieceChar [string index [lindex $rows $fromRow] [expr {$fromCol - 97}]]
    if {$pieceChar ne "" && [string is alpha $pieceChar]} {
        set piece [string toupper $pieceChar]
    }
    
    if {$piece eq ""} {
        return $uciMove
    }
    
    set isCapture 0
    set toChar [string index [lindex $rows $toRow] [expr {$toCol - 97}]]
    if {$toChar ne "" && [string is alpha $toChar]} {
        set isCapture 1
    }
    
    if {$piece eq "K" && [expr {$fromCol - $toCol}] == -2 && $fromRank == "1" && $toRank == "1"} {
        return "O-O"
    }
    if {$piece eq "K" && [expr {$fromCol - $toCol}] == 2 && $fromRank == "1" && $toRank == "1"} {
        return "O-O-O"
    }
    
    set san ""
    if {$piece ne "P"} {
        append san $piece
    }
    
    set sameDestPieces 0
    foreach {p pchar} {P "" N "N" B "B" R "R" Q "Q" K "K"} {
        if {$p eq "P"} continue
        set rowIdx 0
        foreach row $rows {
            set colIdx 0
            foreach c [split $row ""] {
                if {$c eq ""} break
                if {$c eq "/"} continue
                if {[string is digit $c]} {
                    incr colIdx $c
                    continue
                }
                set ptype [string toupper $c]
                if {$ptype eq $p} {
                    set isWhite [string is lower $c]
                    set fenColor [lindex [split $fen] 1]
                    set wantWhite [expr {$fenColor eq "w"}]
                    if {$isWhite != $wantWhite} {
                        incr colIdx
                        continue
                    }
                    set curCol [expr {97 + $colIdx}]
                    set curRow $rowIdx
                    set destStr [format "%c%d" [expr {$curCol}] [expr {8 - $curRow}]]
                    if {$destStr eq $to && "$curCol,$curRow" != "$fromCol,$fromRow"} {
                        incr sameDestPieces
                        break
                    }
                }
                incr colIdx
            }
            incr rowIdx
        }
    }
    
    if {$sameDestPieces > 0} {
        if {$fromFile ne $toFile} {
            append san $fromFile
        }
        if {$fromRank ne $toRank} {
            append san $fromRank
        }
    }
    
    if {$isCapture || $piece eq "P"} {
        if {$piece eq "P"} {
            append san $fromFile
        }
        append san "x"
    }
    
    append san $to
    
    if {$promotion ne ""} {
        append san "=" [string toupper $promotion]
    }
    
    return $san
}

# ::tablebase::lookupPosition
#   Queries the Lichess 7-man tablebase API for the current position
#   and displays the results in a user-friendly popup window.
#
proc ::tablebase::lookupPosition {} {
    # Get the FEN of the current position
    set fen [sc_pos fen]
    
    # Convert spaces in FEN to underscores for the URL
    set urlFen [string map {" " "_"} $fen]
    
    # Construct the API URL
    set url "$::tablebase::lichessUrl?fen=$urlFen"
    
    # Show a temporary "Loading..." message
    set w .tablebaseResult
    if {[winfo exists $w]} { destroy $w }
    
    toplevel $w
    wm title $w "Tablebase Lookup"
    wm resizable $w 0 0
    
    ttk::frame $w.content -padding 20
    pack $w.content -fill both -expand 1
    
    ttk::label $w.content.loading -text "Querying Lichess tablebase..." -font font_Bold
    pack $w.content.loading -pady 10
    
    # Make the HTTP request (prefer curl, fallback to Tcl http)
    set result ""
    set err ""
    set ok 0

    # Try curl first (fast, keeps existing behavior)
    set cmd [list curl -s --max-time 10 $url]
    if {![catch {exec {*}$cmd} result]} {
        set ok 1
    } else {
        set err $result
        # Fallback: Tcl's built-in http package (works if curl is missing)
        if {![catch {package require http}]} {
            set token ""
            if {![catch {set token [::http::geturl $url -timeout 10000]} httpErr]} {
                set result [::http::data $token]
                ::http::cleanup $token
                set ok 1
            } else {
                set err $httpErr
            }
        }
    }

    if {!$ok} {
        destroy $w.content.loading
        ::tablebase::showError $w "Failed to query tablebase: $err"
    } else {
        # Parse and display the JSON result
        destroy $w.content.loading
        ::tablebase::displayResult $w $result $fen
    }
    
    # Center the window
    update idletasks
    set x [expr {[winfo screenwidth $w]/2 - [winfo width $w]/2}]
    set y [expr {[winfo screenheight $w]/2 - [winfo height $w]/2}]
    wm geometry $w "+$x+$y"
}

# ::tablebase::displayResult
#   Parses the JSON response and displays it in a readable format
#
proc ::tablebase::displayResult {w jsonData fen} {
    # Simple JSON parsing (for basic structure)
    # This handles the typical Lichess tablebase response
    
    if {[string match "*not found*" $jsonData] || [string match "*error*" $jsonData]} {
        ::tablebase::showError $w "Position not found in tablebase."
        return
    }
    
    # Try to extract key information from JSON
    set category ""
    set dtm ""
    set dtz ""
    set bestmove ""
    set outcome ""
    
    # Extract category (win, loss, draw, etc.)
    if {[regexp {"category":"([^"]+)"} $jsonData -> category]} {
        # Category found
    }
    
    # Extract DTZ (distance to zeroing - halfmoves until capture/pawn move)
    if {[regexp {"dtz":(-?\d+)} $jsonData -> dtz]} {
        # DTZ found
    }
    
    # Extract DTM (distance to mate) if available
    if {[regexp {"dtm":(-?\d+)} $jsonData -> dtm]} {
        # DTM found
    }
    
    # Extract DTC (distance to conversion) for 8-man positions
    set dtc ""
    if {[regexp {"dtc":(-?\d+)} $jsonData -> dtc]} {
        # DTC found (used in partial 8-man tablebase results)
    }
    
    # Extract best move from moves array (use SAN if available)
    set uciMove ""
    set bestmove ""
    if {[regexp {\{"uci":"([^"]+)","san":"([^"]+)"} $jsonData -> uciMove bestmove]} {
    } elseif {[regexp {"uci":"([^"]+)"} $jsonData -> uciMove]} {
        set bestmove [::tablebase::uciToSan $uciMove $fen]
    }
    
    # Determine the outcome description
    set description ""
    set color [lindex [split $fen] 1]
    set sideToMove [expr {$color eq "w" ? "White" : "Black"}]
    set opponent [expr {$color eq "w" ? "Black" : "White"}]
    
    switch -glob $category {
        "win" {
            set description "This position is **winning** for $sideToMove."
            if {$dtz ne ""} {
                set absValue [expr {abs($dtz)}]
                append description "\n\nThe position can be won in $absValue halfmoves to the next capture or pawn move."
            }
            if {$dtm ne "" && $dtm > 0} {
                append description "\nForced mate in $dtm moves."
            }
        }
        "loss" {
            set description "This position is **losing** for $sideToMove (winning for $opponent)."
            if {$dtz ne ""} {
                set absValue [expr {abs($dtz)}]
                append description "\n\n$opponent can win in $absValue halfmoves to the next capture or pawn move."
            }
            if {$dtm ne "" && $dtm < 0} {
                set absDtm [expr {abs($dtm)}]
                append description "\n$opponent has a forced mate in $absDtm moves."
            }
        }
        "draw" {
            set description "This position is a **draw** with perfect play."
        }
        "cursed-win" {
            set description "This position is a **cursed win** for $sideToMove."
            append description "\n\nWhile technically winning, the 50-move rule will be reached before conversion unless the opponent makes a mistake."
        }
        "blessed-loss" {
            set description "This position is a **blessed loss** for $sideToMove."
            append description "\n\nWhile technically losing, $sideToMove can force a draw by the 50-move rule with perfect defense."
        }
        "maybe-win" {
            set description "This position is a **likely win** for $sideToMove (partial 8-man analysis)."
            append description "\n\nThe tablebase analysis is incomplete for this 8-man position, but the available data suggests a winning position."
            if {$dtc ne ""} {
                set absValue [expr {abs($dtc)}]
                append description "\n\nDistance to conversion: $absValue halfmoves."
            }
        }
        "maybe-loss" {
            set description "This position is a **likely loss** for $sideToMove (partial 8-man analysis)."
            append description "\n\nThe tablebase analysis is incomplete for this 8-man position, but the available data suggests a losing position."
            if {$dtc ne ""} {
                set absValue [expr {abs($dtc)}]
                append description "\n\nDistance to conversion: $absValue halfmoves."
            }
        }
        "unknown" {
            set description "Category: unknown\n\nThis position is outside the tablebase coverage."
        }
        default {
            if {$category ne ""} {
                set description "Category: $category"
            } else {
                set description "Unable to evaluate this position."
            }
        }
    }
    
    # Create the display
    ttk::frame $w.result
    pack $w.result -fill both -expand 1 -padx 20 -pady 10
    
    ttk::label $w.result.title -text "Lichess Endgame Tablebase Result" -font font_Bold
    pack $w.result.title -pady {0 10}
    
    # FEN display
    ttk::label $w.result.fenlabel -text "Position:" -font font_Bold
    pack $w.result.fenlabel -anchor w
    text $w.result.fen -height 2 -width 60 -wrap word -relief flat -background [ttk::style lookup TFrame -background] -font font_Regular
    $w.result.fen insert 1.0 $fen
    $w.result.fen configure -state disabled
    pack $w.result.fen -fill x -pady {0 10}
    
    # Main description
    text $w.result.desc -height 8 -width 60 -wrap word -relief solid -borderwidth 1 -font font_Regular
    $w.result.desc insert 1.0 $description
    $w.result.desc tag configure bold -font font_Bold
    
    # Apply bold formatting to **text**
    set pos 1.0
    while {[set start [$w.result.desc search "**" $pos end]] ne ""} {
        set end [$w.result.desc search "**" "$start + 2 chars" end]
        if {$end eq ""} break
        $w.result.desc delete $start "$start + 2 chars"
        set end [$w.result.desc index "$end - 2 chars"]
        $w.result.desc delete $end "$end + 2 chars"
        $w.result.desc tag add bold $start $end
        set pos $end
    }
    
    $w.result.desc configure -state disabled
    pack $w.result.desc -fill both -expand 1 -pady {0 10}
    
    # Best move
    if {$bestmove ne ""} {
        ttk::label $w.result.bestlabel -text "Best Move: $bestmove" -font font_Bold
        pack $w.result.bestlabel -anchor w -pady {5 0}
    }
    
    # Close button
    ttk::frame $w.buttons
    pack $w.buttons -fill x -pady {10 0}
    ttk::button $w.buttons.close -text "Close" -command "destroy $w"
    pack $w.buttons.close -side right
    
    bind $w <Escape> "destroy $w"
    bind $w <Return> "destroy $w"
    focus $w.buttons.close
}

# ::tablebase::showError
#   Displays an error message in the popup
#
proc ::tablebase::showError {w message} {
    ttk::frame $w.error
    pack $w.error -fill both -expand 1 -padx 20 -pady 10
    
    ttk::label $w.error.title -text "Tablebase Lookup" -font font_Bold
    pack $w.error.title -pady {0 10}
    
    ttk::label $w.error.msg -text $message -wraplength 400
    pack $w.error.msg -pady 10
    
    ttk::button $w.error.close -text "Close" -command "destroy $w"
    pack $w.error.close -pady {10 0}
    
    bind $w <Escape> "destroy $w"
    bind $w <Return> "destroy $w"
    focus $w.error.close
}
