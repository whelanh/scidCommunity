############################################################
### Tablebase lookup window using Lichess API
### Copyright (C) 2025

namespace eval ::tablebase {
    variable lichessUrl "http://tablebase.lichess.ovh/standard"
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
        ::tablebase::showError $w "Position not found in tablebase. This feature works for positions with 7 pieces or fewer."
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
    
    # Extract best move
    if {[regexp {"uci":"([^"]+)"} $jsonData -> bestmove]} {
        # Best move found
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
        "maybe-win" -
        "maybe-loss" {
            set description "Position evaluation uncertain."
        }
        "unknown" {
            set description "Category: unknown\n\nMust be 7 or fewer pieces for endgame result."
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
    
    ttk::label $w.result.title -text "Lichess 7-Man Tablebase Result" -font font_Bold
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
