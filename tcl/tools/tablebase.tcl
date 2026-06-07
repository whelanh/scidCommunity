############################################################
### Tablebase lookup window using Lichess API
### Copyright (C) 2025

namespace eval ::tablebase {
    # Use HTTPS for the Lichess tablebase API
    variable lichessUrl "https://tablebase.lichess.ovh/standard"
    variable lichessChess960Url "https://tablebase.lichess.ovh/chess960"
}

# ::tablebase::getApiUrl
#   Returns the correct Lichess tablebase API URL based on game variant.
#
proc ::tablebase::getApiUrl {} {
    set gameVariant [sc_game variant]
    if {$gameVariant eq "chess960"} {
        return $::tablebase::lichessChess960Url
    }
    return $::tablebase::lichessUrl
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
    
    # Construct the API URL (variant-aware)
    set url "[::tablebase::getApiUrl]?fen=$urlFen"
    
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
    # Delegate to the existing, robust UCI->SAN conversion utility
    return [::uci::formatPv $uciMove $fen]
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
    
    # Construct the API URL (variant-aware)
    set url "[::tablebase::getApiUrl]?fen=$urlFen"
    
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

# =======================================================================
# Lichess Endgame Tablebase Dedicated Window 
# =======================================================================

namespace eval ::tablebase::window {
    variable isOpen 0
    variable tbTraining 0
    variable requestCount 0
    variable buffer
}

# ::tablebase::window::isOpen
proc ::tablebase::window::isOpen {} {
    return [winfo exists .tbWin]
}

# ::tablebase::window::Open
proc ::tablebase::window::Open {} {
    set w .tbWin
    if {[winfo exists $w]} { 
        wm deiconify $w
        raise $w
        return 
    }
    
    ::createToplevel $w
    ::setTitle $w "scidCommunity: [tr TablebaseWindow]"
    
    # Control frame at the bottom
    pack [ttk::frame $w.b] -side bottom -fill x -pady 5 -padx 5
    
    # Results frame (autoscrollText creates the frame)
    set f $w.pos
    
    # Text widget for results
    autoscrollText y $f $f.text Treeview
    $f.text configure -width 40 -height 20 -font font_Fixed -wrap none -state normal
    
    # Determine if theme is dark by checking the background color's brightness
    set bg [ttk::style lookup TFrame -background]
    if {$bg eq ""} { set bg "white" }
    set isDark 0
    catch {
        foreach {r g b} [winfo rgb . $bg] break
        if {($r*299 + $g*587 + $b*114) / 1000 < 32768} { set isDark 1 }
    }
    
    if {$isDark} {
        set win_color "#66ff66"  ;# light green
        set draw_color "#88ccff" ;# light blue
        set loss_color "#ff6666" ;# light red
        set move_color "#66ccff" ;# lighter blue for links
    } else {
        set win_color "darkgreen"
        set draw_color "darkblue"
        set loss_color "darkred"
        set move_color "blue"
    }
    
    # Text tags for styling
    $f.text tag configure win_title -foreground $win_color -font font_Bold
    $f.text tag configure draw_title -foreground $draw_color -font font_Bold
    $f.text tag configure loss_title -foreground $loss_color -font font_Bold
    $f.text tag configure move -foreground $move_color
    $f.text tag bind move <Enter> "$f.text configure -cursor hand2"
    $f.text tag bind move <Leave> "$f.text configure -cursor {}"
    
    pack $f -side top -fill both -expand yes
    
    # Buttons
    ttk::checkbutton $w.b.training -text $::tr(Training) -variable ::tablebase::window::tbTraining -command ::tablebase::window::results
    ttk::button $w.b.refresh -text "Refresh" -command ::tablebase::window::results
    dialogbutton $w.b.close -text $::tr(Close) -command "destroy $w"
    
    packbuttons right $w.b.close
    pack $w.b.training $w.b.refresh -side left -padx 2 -pady 2
    
    bind $w <Destroy> { set ::tablebase::window::tbTraining 0; set ::tablebase::window::isOpen 0 }
    wm minsize $w 350 400
    ::createToplevelFinalize $w
    
    set ::tablebase::window::isOpen 1
    set ::tablebase::window::tbTraining 0
    ::tablebase::window::results
}

# ::tablebase::window::results
proc ::tablebase::window::results {} {
    set w .tbWin
    if {![winfo exists $w]} { return }
    
    set t $w.pos.text
    $t configure -state normal
    $t delete 1.0 end
    
    if {$::tablebase::window::tbTraining} {
        $t insert end "\n [tr TBTrainingHidden]\n"
        $t configure -state disabled
        return
    }
    
    # Check piece count
    set fen [sc_pos fen]
    set pieces [::tablebase::countPieces $fen]
    if {$pieces > 7} {
        $t insert end "\n [tr TBTooMany]\n"
        $t configure -state disabled
        return
    }
    
    $t insert end "\n [tr TBQuerying]\n"
    $t configure -state disabled
    
    # URL-encode spaces in FEN for the query string
    set urlFen [string map {" " "%20"} $fen]
    set url "[::tablebase::getApiUrl]?fen=$urlFen"
    
    # Asynchronous curl
    incr ::tablebase::window::requestCount
    set currentReq $::tablebase::window::requestCount
    set ::tablebase::window::buffer($currentReq) ""
    
    if {![catch {open "| curl -s --max-time 10 $url" r} fd]} {
        fconfigure $fd -blocking 0
        fileevent $fd readable [list ::tablebase::window::curlCallback $fd $fen $currentReq]
    } else {
        $t configure -state normal
        $t delete 1.0 end
        $t insert end "\n [tr TBError]\n"
        $t configure -state disabled
    }
}

proc ::tablebase::window::curlCallback {fd fen reqId} {
    set w .tbWin
    
    append ::tablebase::window::buffer($reqId) [read $fd]
    
    if {[eof $fd]} {
        set result $::tablebase::window::buffer($reqId)
        unset ::tablebase::window::buffer($reqId)
        catch {close $fd}
        
        # Only update if this is the most recent request and window exists
        if {[winfo exists $w] && $reqId == $::tablebase::window::requestCount} {
            ::tablebase::window::displayResults $result $fen
        }
    }
}

proc ::tablebase::window::compareWin {a b} {
    set dtzA [expr {abs([lindex $a 0])}]
    set dtzB [expr {abs([lindex $b 0])}]
    if {$dtzA != $dtzB} { return [expr {$dtzA - $dtzB}] }
    set dtmA [lindex $a 1]; set dtmB [lindex $b 1]
    if {$dtmA ne "" && $dtmB ne ""} { return [expr {abs($dtmA) - abs($dtmB)}] }
    return 0
}

proc ::tablebase::window::compareLoss {a b} {
    set dtzA [expr {abs([lindex $a 0])}]
    set dtzB [expr {abs([lindex $b 0])}]
    if {$dtzA != $dtzB} { return [expr {$dtzB - $dtzA}] }
    set dtmA [lindex $a 1]; set dtmB [lindex $b 1]
    if {$dtmA ne "" && $dtmB ne ""} { return [expr {abs($dtmB) - abs($dtmA)}] }
    return 0
}

proc ::tablebase::window::displayResults {jsonData fen} {
    set w .tbWin
    if {![winfo exists $w]} { return }
    
    set t $w.pos.text
    $t configure -state normal
    $t delete 1.0 end
    
    if {[string match "*not found*" $jsonData] || [string match "*error*" $jsonData]} {
        $t insert end "\n [tr TBNotFound]\n"
        $t configure -state disabled
        return
    }
    
    set category ""
    regexp {"category":"([^"]+)"} $jsonData -> category
    
    $t insert end "\n [tr TBCategory] $category\n\n"
    
    # Extract the moves array
    set movesJson ""
    if {[regexp {"moves":\[(.*?)\]} $jsonData -> movesJson]} {
        # Parse individual moves manually using regex
        set moveMatches [regexp -all -inline {\{[^\}]+\}} $movesJson]
        
        set winMoves {}
        set drawMoves {}
        set lossMoves {}
        
        foreach moveObj $moveMatches {
            set uci ""
            set san ""
            set mcat ""
            set wdl ""
            set dtz ""
            set dtm ""
            
            regexp {"uci":"([^"]+)"} $moveObj -> uci
            regexp {"san":"([^"]+)"} $moveObj -> san
            regexp {"category":"([^"]+)"} $moveObj -> mcat
            regexp {"wdl":(-?\d+)} $moveObj -> wdl
            regexp {"dtz":(-?\d+)} $moveObj -> dtz
            regexp {"dtm":(-?\d+)} $moveObj -> dtm
            
            if {$san eq ""} { set san [::tablebase::uciToSan $uci $fen] }
            
            # Format display string
            set displayStr [format "%-8s %-12s DTZ: %-4s" $san $mcat [expr {$dtz ne "" ? abs($dtz) : "-"}]]
            if {$dtm ne ""} {
                append displayStr [format " DTM: %-4s" [expr {abs($dtm)}]]
            }
            
            if {$wdl > 0} {
                lappend winMoves [list $dtz $dtm $displayStr $san]
            } elseif {$wdl == 0} {
                lappend drawMoves [list $dtz $dtm $displayStr $san]
            } else {
                lappend lossMoves [list $dtz $dtm $displayStr $san]
            }
        }
        
        set winMoves [lsort -command ::tablebase::window::compareWin $winMoves]
        set drawMoves [lsort -command ::tablebase::window::compareLoss $drawMoves]
        set lossMoves [lsort -command ::tablebase::window::compareLoss $lossMoves]
        
        if {[llength $winMoves] > 0} {
            $t insert end " [tr TBWinMoves]\n" win_title
            foreach m $winMoves { 
                set san [lindex $m 3]
                $t insert end "  "
                $t insert end "[lindex $m 2]" [list move $san]
                $t insert end "\n"
                
                # Make moves clickable
                $t tag bind $san <ButtonPress-1> [list ::tablebase::window::addMove $san]
            }
            $t insert end "\n"
        }
        if {[llength $drawMoves] > 0} {
            $t insert end " [tr TBDrawMoves]\n" draw_title
            foreach m $drawMoves { 
                set san [lindex $m 3]
                $t insert end "  "
                $t insert end "[lindex $m 2]" [list move $san]
                $t insert end "\n"
                $t tag bind $san <ButtonPress-1> [list ::tablebase::window::addMove $san]
            }
            $t insert end "\n"
        }
        if {[llength $lossMoves] > 0} {
            $t insert end " [tr TBLossMoves]\n" loss_title
            foreach m $lossMoves { 
                set san [lindex $m 3]
                $t insert end "  "
                $t insert end "[lindex $m 2]" [list move $san]
                $t insert end "\n"
                $t tag bind $san <ButtonPress-1> [list ::tablebase::window::addMove $san]
            }
            $t insert end "\n"
        }
    } else {
        $t insert end " [tr TBNoMoves]\n"
    }
    
    $t configure -state disabled
}

proc ::tablebase::window::addMove {san} {
    if {[catch {sc_move addSan $san} err] == 0} {
        updateBoard
    }
}