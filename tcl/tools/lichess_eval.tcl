# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later

############################################################
### Lichess Cloud Eval lookup
### Queries the Lichess cloud evaluation API and displays results

namespace eval ::lichess_eval {
    variable apiUrl "https://lichess.org/api/cloud-eval"
    variable multiPv 5
}

# ::lichess_eval::formatScore
#   Converts centipawn score to decimal (e.g. 40 -> "+0.40", -15 -> "-0.15")
#   If mate is provided, formats as "Mate in N"
#
proc ::lichess_eval::formatScore {args} {
    set cp ""
    set mate ""
    foreach {key val} $args {
        switch -- $key {
            -cp   { set cp $val }
            -mate { set mate $val }
        }
    }
    if {$mate ne ""} {
        if {$mate > 0} {
            return "Mate in $mate"
        } else {
            return "Mate in [expr {abs($mate)}] (for opponent)"
        }
    }
    if {$cp ne ""} {
        set score [expr {$cp / 100.0}]
        if {$score >= 0} {
            return [format "+%.2f" $score]
        } else {
            return [format "%.2f" $score]
        }
    }
    return "N/A"
}

# ::lichess_eval::uciToSan
#   Converts a space-separated string of UCI moves to SAN notation
#   starting from the given FEN position.
#   Uses ::uci::formatPv which handles push/pop of the game state.
#
proc ::lichess_eval::uciToSan {uciMoves fen} {
    set moveList [split $uciMoves " "]
    return [::uci::formatPv $moveList $fen]
}

# ::lichess_eval::formatLine
#   Formats a single PV line with move number annotations.
#   Takes a FEN and a SAN move string, returns numbered moves.
#
proc ::lichess_eval::formatLine {fen sanMoves} {
    # Determine whose turn it is and the starting move number
    set parts [split $fen]
    set color [lindex $parts 1]
    set moveNum [lindex $parts 5]
    if {$moveNum eq ""} { set moveNum 1 }

    set result ""
    set isBlack [expr {$color eq "b"}]
    set first 1

    foreach move $sanMoves {
        if {$isBlack && $first} {
            append result "${moveNum}...${move} "
            incr moveNum
            set isBlack 0
        } elseif {!$isBlack} {
            append result "${moveNum}.${move} "
            set isBlack 1
        } else {
            append result "${move} "
            incr moveNum
            set isBlack 0
        }
        set first 0
    }
    return [string trim $result]
}

# ::lichess_eval::lookupPosition
#   Queries the Lichess cloud eval API for the current position
#   and displays the results in a popup window.
#
proc ::lichess_eval::lookupPosition {} {
    # Get the current FEN and variant
    set fen [sc_pos fen]
    set gameVariant [sc_game variant]
    if {$gameVariant eq "chess960"} {
        set variant "chess960"
    } else {
        set variant "standard"
    }

    # URL-encode the FEN
    set urlFen [string map {" " "%20"} $fen]

    # Construct the API URL
    set url "$::lichess_eval::apiUrl?fen=$urlFen&multiPv=$::lichess_eval::multiPv&variant=$variant"

    # Create or reset the popup window
    set w .lichessEvalResult
    if {[winfo exists $w]} { destroy $w }

    toplevel $w
    wm title $w "Lichess Cloud Eval"
    wm resizable $w 1 1
    wm minsize $w 600 400
    if {[winfo exists .]} { wm transient $w . }

    ttk::frame $w.content -padding 20
    pack $w.content -fill both -expand 1

    ttk::label $w.content.loading -text "Querying Lichess cloud eval..." -font font_Bold
    pack $w.content.loading -pady 10

    update idletasks

    # Make the HTTP request using curl
    set result ""
    set err ""
    set ok 0

    set cmd [list curl -s --max-time 10 -H "Accept: */*" $url]
    if {![catch {exec {*}$cmd} result]} {
        set ok 1
    } else {
        set err $result
        # Fallback: Tcl http
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

    destroy $w.content.loading

    if {!$ok} {
        ::lichess_eval::showError $w "Failed to query Lichess cloud eval: $err"
        return
    }

    # Check for error responses
    if {[string match "*error*" $result] && ![regexp {"pvs"} $result]} {
        ::lichess_eval::showError $w "Position not found in Lichess cloud eval database.\n\nThis position may not have been analyzed by Lichess users yet."
        return
    }

    # Parse and display
    ::lichess_eval::displayResult $w $result $fen

    # Center the window
    update idletasks
    set winWidth [winfo width $w]
    set winHeight [winfo height $w]
    if {$winWidth < 100} { set winWidth 600 }
    if {$winHeight < 100} { set winHeight 400 }
    set x [expr {([winfo screenwidth $w] - $winWidth) / 2}]
    set y [expr {([winfo screenheight $w] - $winHeight) / 2}]
    wm geometry $w "+$x+$y"
}

# ::lichess_eval::displayResult
#   Parses the JSON response and displays it in a readable format
#
proc ::lichess_eval::displayResult {w jsonData fen} {
    # Extract depth
    set depth ""
    regexp {"depth":(\d+)} $jsonData -> depth

    # Determine side to move
    set color [lindex [split $fen] 1]
    set sideToMove [expr {$color eq "w" ? "White" : "Black"}]

    # Extract all PV lines
    # Parse the pvs array - find each object with "moves" and "cp"/"mate"
    set pvs {}
    set searchStart 0

    # Find the pvs array
    if {[regexp -indices {"pvs"\s*:\s*\[} $jsonData match]} {
        set arrayStart [lindex $match 1]
        # Extract individual PV objects
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
                lappend pvs [list $moves $cp $mate]
            }

            set remaining [string range $remaining [expr {$objEnd + 1}] end]
        }
    }

    if {[llength $pvs] == 0} {
        ::lichess_eval::showError $w "No evaluation data found for this position."
        return
    }

    # Build the display
    ttk::frame $w.result
    pack $w.result -fill both -expand 1 -padx 20 -pady 10

    ttk::label $w.result.title -text "Lichess Cloud Evaluation" -font font_Bold
    pack $w.result.title -pady {0 10}

    # Depth info
    if {$depth ne ""} {
        ttk::label $w.result.depth -text "Depth: $depth    Side to move: $sideToMove"
        pack $w.result.depth -anchor w -pady {0 10}
    }

    # Create a text widget for the PV lines
    text $w.result.lines -height 16 -width 70 -wrap word -relief solid \
        -borderwidth 1 -font font_Regular -spacing1 4 -spacing3 4
    $w.result.lines tag configure pvnum -font font_Bold
    $w.result.lines tag configure score -font font_Bold -foreground "blue"
    $w.result.lines tag configure moves -font font_Regular
    pack $w.result.lines -fill both -expand 1 -pady {0 10}

    set lineNum 1
    foreach pv $pvs {
        lassign $pv uciMoves cp mate

        # Format the score
        set scoreArgs {}
        if {$cp ne ""} { lappend scoreArgs -cp $cp }
        if {$mate ne ""} { lappend scoreArgs -mate $mate }
        set scoreStr [::lichess_eval::formatScore {*}$scoreArgs]

        # Convert UCI moves to SAN
        set sanMoves [::lichess_eval::uciToSan $uciMoves $fen]

        # Format with move numbers
        set numberedMoves [::lichess_eval::formatLine $fen $sanMoves]

        # Insert into text widget
        $w.result.lines insert end "Line $lineNum" pvnum
        $w.result.lines insert end "  " {}
        $w.result.lines insert end "$scoreStr" score
        $w.result.lines insert end "\n" {}
        $w.result.lines insert end "  $numberedMoves\n\n" moves

        incr lineNum
    }

    $w.result.lines configure -state disabled

    # Close button
    ttk::frame $w.buttons
    pack $w.buttons -fill x -pady {10 0}
    ttk::button $w.buttons.close -text "Close" -command "destroy $w"
    pack $w.buttons.close -side right

    bind $w <Escape> "destroy $w"
    bind $w <Return> "destroy $w"
    focus $w.buttons.close
}

# ::lichess_eval::showError
#   Displays an error message in the popup
#
proc ::lichess_eval::showError {w message} {
    ttk::frame $w.error
    pack $w.error -fill both -expand 1 -padx 20 -pady 10

    ttk::label $w.error.title -text "Lichess Cloud Eval" -font font_Bold
    pack $w.error.title -pady {0 10}

    ttk::label $w.error.msg -text $message -wraplength 400
    pack $w.error.msg -pady 10

    ttk::button $w.error.close -text "Close" -command "destroy $w"
    pack $w.error.close -pady {10 0}

    bind $w <Escape> "destroy $w"
    bind $w <Return> "destroy $w"
    focus $w.error.close
}
