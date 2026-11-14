############################################################
### Tablebase lookup window using Lichess API
### Copyright (C) 2025

namespace eval ::tablebase {
    # Use HTTPS for the Lichess tablebase API
    variable lichessUrl "https://tablebase.lichess.ovh/standard"
}

# ::tablebase::buildUrl
#   Constructs the tablebase API URL from a FEN, adding variant parameter
#   for Chess960 positions (same pattern as cloud eval / opening explorer).
#
proc ::tablebase::buildUrl {fen} {
    # Properly URL-encode the FEN string
    set urlFen [string map {" " "%20" "+" "%2B" "/" "%2F"} $fen]
    set url "$::tablebase::lichessUrl?fen=$urlFen"
    set gameVariant [sc_game variant]
    if {$gameVariant eq "chess960"} {
        append url "&variant=chess960"
    }
    return $url
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

# ::tablebase::findCurl
#   Locate a usable curl executable. Prefers one on PATH, then a copy bundled
#   with scidCommunity next to the application binary (see the release
#   packaging), and finally a system curl (e.g. Windows' System32).
#   Returns the executable path, or "" when none is found.
#
proc ::tablebase::findCurl {} {
    # auto_execok returns a *list* (so callers can append arguments). Take the
    # path element out of it: otherwise a path containing spaces stringifies
    # as {C:\Program Files\...\curl.exe} and exec looks for the braces too.
    set exe [auto_execok curl]
    if {$exe ne ""} { return [lindex $exe 0] }

    set exeDir ""
    catch {set exeDir [file dirname [info nameofexecutable]]}
    set dirs {}
    if {$exeDir ne ""} {
        lappend dirs $exeDir
        lappend dirs [file join $exeDir .. bin]
        lappend dirs [file join $exeDir .. engines]
    }
    if {[info exists ::env(SystemRoot)] && $::env(SystemRoot) ne ""} {
        lappend dirs [file join $::env(SystemRoot) System32]
    }
    foreach dir $dirs {
        foreach name {curl curl.exe} {
            set candidate [file join $dir $name]
            if {[file executable $candidate]} { return $candidate }
        }
    }
    return ""
}

# ::tablebase::httpQuery
#   Fetch $url and return a list {ok result err}.
#   Tries, in order: a curl executable, wget, Windows PowerShell, and finally
#   Tcl's built-in http package (with TLS registered for HTTPS). The reasons
#   from the methods that were attempted are collected in $err so the caller
#   can report why the lookup failed.
#
proc ::tablebase::httpQuery {url} {
    set result ""
    set err ""

    # 1) curl (preferred). -q ignores any user _curlrc; -sS stays silent on
    #    success but prints errors, which the exec error handling captures.
    #    An empty body is treated as a failure so the next transport is tried.
    set curlExe [::tablebase::findCurl]
    if {$curlExe ne ""} {
        if {![catch {exec $curlExe -q -sS --connect-timeout 10 --max-time 10 $url} result]} {
            if {[string trim $result] ne ""} {
                return [list 1 $result ""]
            }
            set err "curl: empty response"
        } else {
            set err "curl: $result"
        }
    } else {
        set err "curl not found"
    }

    # 2) wget. Write the body to a temp file so stderr diagnostics can be kept
    #    without corrupting the response (exec treats stderr output as an error).
    set wgetExe [auto_execok wget]
    if {$wgetExe ne "" && ![catch {set tmpChan [file tempfile tmpPath]} tmpErr]} {
        close $tmpChan
        set out ""
        if {![catch {
            exec wget --no-verbose --timeout=10 --tries=1 -O $tmpPath $url 2>@1
        } out]} {
            set body ""
            catch {
                set f [open $tmpPath r]
                set body [read $f]
                close $f
            }
            file delete -force $tmpPath
            if {[string trim $body] ne ""} {
                return [list 1 $body ""]
            }
            append err "; wget: empty response"
        } else {
            file delete -force $tmpPath
            append err "; wget: $out"
        }
    } elseif {$wgetExe ne ""} {
        append err "; wget: cannot create temp file: $tmpErr"
    }

    # 3) Windows PowerShell (present on every supported Windows release).
    #    Download to a temp file so the raw response is read back exactly,
    #    regardless of how PowerShell formats objects on stdout.
    set psExe ""
    if {[info exists ::windowsOS] && $::windowsOS} { set psExe [auto_execok powershell] }
    if {$psExe ne "" && ![catch {set tmpChan [file tempfile tmpPath]} tmpErr]} {
        close $tmpChan
        set ::env(SAFE_TB_URL) $url
        set ::env(SAFE_TB_FILE) $tmpPath
        set out ""
        if {![catch {
            exec powershell -NoLogo -NoProfile -Command \
                "Invoke-WebRequest -UseBasicParsing -TimeoutSec 10 -Uri \$env:SAFE_TB_URL -OutFile \$env:SAFE_TB_FILE" 2>@1
        } out]} {
            set body ""
            catch {
                set f [open $tmpPath r]
                set body [read $f]
                close $f
            }
            file delete -force $tmpPath
            if {[string trim $body] ne ""} {
                return [list 1 $body ""]
            }
            append err "; powershell: empty response"
        } else {
            file delete -force $tmpPath
            append err "; powershell: $out"
        }
    } elseif {$psExe ne ""} {
        append err "; powershell: cannot create temp file: $tmpErr"
    }

    # 4) Tcl's built-in http package. Register TLS (with SNI, matching the
    #    other online modules) and only accept a completed 200 response.
    if {![catch {package require http}]} {
        catch {package require tls}
        catch {::http::register https 443 [list ::tls::socket -autoservername true]}
        set token ""
        if {![catch {set token [::http::geturl $url -timeout 10000]} httpErr]} {
            set status [::http::status $token]
            set code [::http::ncode $token]
            set data [::http::data $token]
            ::http::cleanup $token
            if {$status eq "ok" && $code == 200 && [string trim $data] ne ""} {
                return [list 1 $data ""]
            }
            append err "; http: $status HTTP $code $data"
        } else {
            append err "; http: $httpErr"
        }
    } else {
        append err "; Tcl http package unavailable"
    }

    return [list 0 "" $err]
}

# ::tablebase::queryTablebaseResult
#   Queries the tablebase and returns a simplified result string
#   Returns: "winning", "losing", "draw", or "error: <message>"
#
proc ::tablebase::queryTablebaseResult {fen} {
    # Construct the API URL (variant-aware)
    set url [::tablebase::buildUrl $fen]

    lassign [::tablebase::httpQuery $url] ok result err

    if {!$ok} {
        return "error: Failed to query tablebase ($err)"
    }

    set result [string trim $result]
    if {$result eq ""} {
        return "error: Empty tablebase response"
    }
    if {![string match "\{*" $result]} {
        return "error: Unexpected tablebase response: [string range $result 0 200]"
    }

    if {[string match "*not found*" $result] || [string match "*error*" $result]} {
        return "error: Position not found in tablebase"
    }

    # Extract category from JSON (tolerate optional whitespace after the colon)
    set category ""
    if {[regexp {"category"[ \t]*:[ \t]*"([^"]+)"} $result -> category]} {
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
    
    return "error: Unable to parse tablebase result: [string range $result 0 200]"
}

# ::tablebase::uciToSan
#   Converts a UCI move (e.g., "e2e4") to SAN (e.g., "e4" or "Nge7")
#   Requires the FEN to determine piece types and disambiguation
#
proc ::tablebase::uciToSan {uciMove fen} {
    # Delegate to the existing, robust UCI->SAN conversion utility
    return [::ucifmt::formatPv $uciMove $fen]
}

# ::tablebase::lookupPosition
#   Queries the Lichess 7-man tablebase API for the current position
#   and displays the results in a user-friendly popup window.
#
proc ::tablebase::lookupPosition {} {
    # Get the FEN of the current position
    set fen [sc_pos fen]
    
    # Construct the API URL (variant-aware)
    set url [::tablebase::buildUrl $fen]
    
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
    
    # Make the HTTP request (curl/wget/PowerShell, then Tcl http with TLS)
    lassign [::tablebase::httpQuery $url] ok result err

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
    set jsonData [string trim $jsonData]

    # Guard against empty or non-JSON responses (blocked request, proxy/AV
    # interstitial page, or a plain-text API error) and surface what came back
    # instead of the unhelpful "Unable to evaluate this position".
    if {$jsonData eq ""} {
        ::tablebase::showError $w "The tablebase returned an empty response.\n\nThis usually means the request was blocked (proxy, firewall or antivirus) or the network connection failed. Please try again."
        return
    }
    if {![string match "\{*" $jsonData]} {
        ::tablebase::showError $w "Unexpected response from the tablebase:\n\n[string range $jsonData 0 500]"
        return
    }

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

    # Extract category (win, loss, draw, etc.), tolerating optional whitespace
    if {[regexp {"category"[ \t]*:[ \t]*"([^"]+)"} $jsonData -> category]} {
        # Category found
    }

    if {$category eq ""} {
        ::tablebase::showError $w "Could not read the tablebase response (no category field):\n\n[string range $jsonData 0 500]"
        return
    }

    # Extract DTZ (distance to zeroing - halfmoves until capture/pawn move)
    if {[regexp {"dtz"[ \t]*:[ \t]*(-?\d+)} $jsonData -> dtz]} {
        # DTZ found
    }
    
    # Extract DTM (distance to mate) if available
    if {[regexp {"dtm"[ \t]*:[ \t]*(-?\d+)} $jsonData -> dtm]} {
        # DTM found
    }
    
    # Extract DTC (distance to conversion) for 8-man positions
    set dtc ""
    if {[regexp {"dtc"[ \t]*:[ \t]*(-?\d+)} $jsonData -> dtc]} {
        # DTC found (used in partial 8-man tablebase results)
    }
    
    # Extract best move from moves array (use SAN if available)
    set uciMove ""
    set bestmove ""
    if {[regexp {\{"uci"[ \t]*:[ \t]*"([^"]+)"[^\}]*"san"[ \t]*:[ \t]*"([^"]+)"} $jsonData -> uciMove bestmove]} {
    } elseif {[regexp {"uci"[ \t]*:[ \t]*"([^"]+)"} $jsonData -> uciMove]} {
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
    
    set url [::tablebase::buildUrl $fen]
    
    # Asynchronous curl
    incr ::tablebase::window::requestCount
    set currentReq $::tablebase::window::requestCount
    set ::tablebase::window::buffer($currentReq) ""

    # Pick an asynchronous transport: curl or wget through a pipe, falling back
    # to Tcl's http package (asynchronous -command callback) when neither is
    # available. Never block the UI thread on a synchronous request.
    set curlExe [::tablebase::findCurl]
    set wgetExe ""
    if {$curlExe eq ""} { set wgetExe [auto_execok wget] }

    if {$curlExe ne "" || $wgetExe ne ""} {
        if {$curlExe ne ""} {
            set cmd [list $curlExe -q -sS --connect-timeout 10 --max-time 10 $url]
        } else {
            set cmd [list $wgetExe --no-verbose --timeout=10 --tries=1 -O - $url]
        }
        # Use list-form open to avoid shell injection
        if {![catch {open "|$cmd" r} fd]} {
            fconfigure $fd -blocking 0
            fileevent $fd readable [list ::tablebase::window::curlCallback $fd $fen $currentReq]
            return
        }
    } elseif {![catch {package require http}]} {
        catch {package require tls}
        catch {::http::register https 443 [list ::tls::socket -autoservername true]}
        if {![catch {
            ::http::geturl $url -timeout 10000 \
                -command [list ::tablebase::window::httpCallback $fen $currentReq]
        }]} {
            return
        }
    }

    $t configure -state normal
    $t delete 1.0 end
    $t insert end "\n [tr TBError]\n"
    $t configure -state disabled
}

# ::tablebase::window::httpCallback
#   Asynchronous completion handler for the Tcl http fallback.
#
proc ::tablebase::window::httpCallback {fen reqId token} {
    set w .tbWin
    set status ""
    set code ""
    set data ""
    catch {
        set status [::http::status $token]
        set code [::http::ncode $token]
        set data [::http::data $token]
    }
    catch {::http::cleanup $token}

    # Only pass the response through when the request completed with a 200.
    if {$status ne "ok" || $code != 200} { set data "" }

    if {[winfo exists $w] && $reqId == $::tablebase::window::requestCount} {
        ::tablebase::window::displayResults $data $fen
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
    # Normalize DTZ to numeric default (0) when empty
    set rawDtzA [lindex $a 0]
    set rawDtzB [lindex $b 0]
    set dtzA [expr {$rawDtzA eq "" ? 0 : abs($rawDtzA)}]
    set dtzB [expr {$rawDtzB eq "" ? 0 : abs($rawDtzB)}]
    if {$dtzA != $dtzB} { return [expr {$dtzA - $dtzB}] }
    set dtmA [lindex $a 1]; set dtmB [lindex $b 1]
    if {$dtmA ne "" && $dtmB ne ""} { return [expr {abs($dtmA) - abs($dtmB)}] }
    return 0
}

proc ::tablebase::window::compareLoss {a b} {
    # Normalize DTZ to numeric default (0) when empty
    set rawDtzA [lindex $a 0]
    set rawDtzB [lindex $b 0]
    set dtzA [expr {$rawDtzA eq "" ? 0 : abs($rawDtzA)}]
    set dtzB [expr {$rawDtzB eq "" ? 0 : abs($rawDtzB)}]
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
    
    set jsonData [string trim $jsonData]
    if {[string match "*not found*" $jsonData] || [string match "*error*" $jsonData]} {
        $t insert end "\n [tr TBNotFound]\n"
        $t configure -state disabled
        return
    }
    
    # Guard against empty or non-JSON response
    if {![string match "\{*" $jsonData]} {
        $t insert end "\n [tr TBQueryError]\n"
        $t configure -state disabled
        return
    }
    
    set category ""
    regexp {"category"[ \t]*:[ \t]*"([^"]+)"} $jsonData -> category
    
    $t insert end "\n [tr TBCategory] $category\n\n"
    
    # Extract the moves array
    set movesJson ""
    if {[regexp {"moves"[ \t]*:[ \t]*\[(.*?)\]} $jsonData -> movesJson]} {
        # Parse individual moves manually using regex
        set moveMatches [regexp -all -inline {\{[^\}]+\}} $movesJson]
        
        set winMoves {}
        set drawMoves {}
        set lossMoves {}
        
        foreach moveObj $moveMatches {
            set uci ""
            set san ""
            set mcat ""
            set dtz ""
            set dtm ""
            
            regexp {"uci"[ \t]*:[ \t]*"([^"]+)"} $moveObj -> uci
            regexp {"san"[ \t]*:[ \t]*"([^"]+)"} $moveObj -> san
            regexp {"category"[ \t]*:[ \t]*"([^"]+)"} $moveObj -> mcat
            regexp {"dtz"[ \t]*:[ \t]*(-?\d+)} $moveObj -> dtz
            regexp {"dtm"[ \t]*:[ \t]*(-?\d+)} $moveObj -> dtm
            
            if {$san eq ""} { set san [::tablebase::uciToSan $uci $fen] }
            
            # Format display string
            set displayStr [format "%-8s %-12s DTZ: %-4s" $san $mcat [expr {$dtz ne "" ? abs($dtz) : "-"}]]
            if {$dtm ne ""} {
                append displayStr [format " DTM: %-4s" [expr {abs($dtm)}]]
            }
            
            # Classify by category (the Lichess API no longer includes a wdl field)
            switch -glob $mcat {
                "win"  { lappend winMoves  [list $dtz $dtm $displayStr $san] }
                "draw" { lappend drawMoves [list $dtz $dtm $displayStr $san] }
                "loss" { lappend lossMoves [list $dtz $dtm $displayStr $san] }
                default { lappend drawMoves [list $dtz $dtm $displayStr $san] }
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