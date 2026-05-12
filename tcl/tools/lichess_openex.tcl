# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later

############################################################
### Lichess Opening Explorer
### Queries the Lichess Opening Explorer API and displays
### move statistics, top games, and recent games.
### https://lichess.org/api#tag/opening-explorer

namespace eval ::lichess_openex {
    variable baseUrl "https://explorer.lichess.ovh"

    # Persisted options (saved via Options > Save Options)
    options.store ::lichess_openex::apiToken ""
    options.store ::lichess_openex::database "masters"
    options.store ::lichess_openex::numMoves 12
    options.store ::lichess_openex::topGames 15
    options.store ::lichess_openex::recentGames 4
    options.store ::lichess_openex::sinceYear ""
    options.store ::lichess_openex::untilYear ""
    options.store ::lichess_openex::sinceMonth ""
    options.store ::lichess_openex::untilMonth ""
    options.store ::lichess_openex::speeds [list ultraBullet bullet blitz rapid classical correspondence]
    options.store ::lichess_openex::ratings [list 0 1000 1200 1400 1600 1800 2000 2200 2500]
    options.store ::lichess_openex::playerName ""
    options.store ::lichess_openex::playerColor "white"
    options.store ::lichess_openex::modes [list rated casual]
}

# ::lichess_openex::openDialog
#   Main entry point: shows the settings dialog before querying the API.
#
proc ::lichess_openex::openDialog {} {
    set w .lichessOpenExDialog
    if {[winfo exists $w]} {
        raise $w
        focus $w
        return
    }

    toplevel $w
    wm title $w "Lichess Opening Explorer"
    wm resizable $w 1 0
    if {[winfo exists .]} { wm transient $w . }
    wm protocol $w WM_DELETE_WINDOW [list ::lichess_openex::onCancel $w]

    # --- Save backup of all persisted settings for Cancel ---
    set ::lichess_openex::backup_db $::lichess_openex::database
    set ::lichess_openex::backup_token $::lichess_openex::apiToken
    set ::lichess_openex::backup_numMoves $::lichess_openex::numMoves
    set ::lichess_openex::backup_topGames $::lichess_openex::topGames
    set ::lichess_openex::backup_recentGames $::lichess_openex::recentGames
    set ::lichess_openex::backup_sinceYear $::lichess_openex::sinceYear
    set ::lichess_openex::backup_untilYear $::lichess_openex::untilYear
    set ::lichess_openex::backup_sinceMonth $::lichess_openex::sinceMonth
    set ::lichess_openex::backup_untilMonth $::lichess_openex::untilMonth
    set ::lichess_openex::backup_playerName $::lichess_openex::playerName
    set ::lichess_openex::backup_playerColor $::lichess_openex::playerColor
    set ::lichess_openex::backup_speeds $::lichess_openex::speeds
    set ::lichess_openex::backup_ratings $::lichess_openex::ratings
    set ::lichess_openex::backup_modes $::lichess_openex::modes

    # --- Individual checkbox variables (synced to persisted lists via traces) ---
    foreach sp {ultraBullet bullet blitz rapid classical correspondence} {
        set ::lichess_openex::chk_speed_$sp [expr {[lsearch -exact $::lichess_openex::speeds $sp] >= 0}]
    }
    foreach rt {0 1000 1200 1400 1600 1800 2000 2200 2500} {
        set ::lichess_openex::chk_rating_$rt [expr {[lsearch -exact $::lichess_openex::ratings $rt] >= 0}]
    }
    foreach md {rated casual} {
        set ::lichess_openex::chk_mode_$md [expr {[lsearch -exact $::lichess_openex::modes $md] >= 0}]
    }

    # Add write traces so checkbox changes immediately update the persisted list variables
    foreach sp {ultraBullet bullet blitz rapid classical correspondence} {
        trace add variable ::lichess_openex::chk_speed_$sp write ::lichess_openex::syncSpeeds
    }
    foreach rt {0 1000 1200 1400 1600 1800 2000 2200 2500} {
        trace add variable ::lichess_openex::chk_rating_$rt write ::lichess_openex::syncRatings
    }
    foreach md {rated casual} {
        trace add variable ::lichess_openex::chk_mode_$md write ::lichess_openex::syncModes
    }

    # --- Build the dialog ---
    ttk::frame $w.content -padding 12
    pack $w.content -fill both -expand 1

    set row 0

    # API Token
    ttk::label $w.content.tokenlbl -text "Lichess API Token (required):"
    ttk::entry $w.content.tokenentry -width 45 -textvariable ::lichess_openex::apiToken -show "*"
    grid $w.content.tokenlbl   -row $row -column 0 -sticky w -padx {0 8} -pady 2
    grid $w.content.tokenentry -row $row -column 1 -columnspan 3 -sticky ew -pady 2
    incr row

    # Database selector
    ttk::label $w.content.dblbl -text "Database:"
    ttk::radiobutton $w.content.db_masters -text "Masters" -variable ::lichess_openex::database \
        -value "masters" -command [list ::lichess_openex::updateDialogFields $w]
    ttk::radiobutton $w.content.db_lichess -text "Lichess Games" -variable ::lichess_openex::database \
        -value "lichess" -command [list ::lichess_openex::updateDialogFields $w]
    ttk::radiobutton $w.content.db_player -text "Player" -variable ::lichess_openex::database \
        -value "player" -command [list ::lichess_openex::updateDialogFields $w]
    grid $w.content.dblbl       -row $row -column 0 -sticky w -padx {0 8} -pady 4
    grid $w.content.db_masters  -row $row -column 1 -sticky w -pady 4
    grid $w.content.db_lichess  -row $row -column 2 -sticky w -pady 4
    grid $w.content.db_player   -row $row -column 3 -sticky w -pady 4
    incr row

    ttk::separator $w.content.sep1 -orient horizontal
    grid $w.content.sep1 -row $row -column 0 -columnspan 4 -sticky ew -pady 6
    incr row

    # --- Common fields ---
    ttk::label $w.content.moveslbl -text "Number of moves:"
    ttk::spinbox $w.content.movesspin -from 1 -to 50 -width 5 \
        -textvariable ::lichess_openex::numMoves
    grid $w.content.moveslbl  -row $row -column 0 -sticky w -padx {0 8} -pady 2
    grid $w.content.movesspin -row $row -column 1 -sticky w -pady 2
    incr row

    ttk::label $w.content.topglbl -text "Top games:"
    ttk::spinbox $w.content.topgspin -from 0 -to 15 -width 5 \
        -textvariable ::lichess_openex::topGames
    grid $w.content.topglbl  -row $row -column 0 -sticky w -padx {0 8} -pady 2
    grid $w.content.topgspin -row $row -column 1 -sticky w -pady 2
    incr row

    ttk::label $w.content.recglbl -text "Recent games:"
    ttk::spinbox $w.content.recgspin -from 0 -to 8 -width 5 \
        -textvariable ::lichess_openex::recentGames
    grid $w.content.recglbl  -row $row -column 0 -sticky w -padx {0 8} -pady 2
    grid $w.content.recgspin -row $row -column 1 -sticky w -pady 2
    incr row

    # --- Masters date fields (since/until as years) ---
    ttk::label $w.content.msylbl -text "Since year:"
    ttk::entry $w.content.msyentry -width 8 -textvariable ::lichess_openex::sinceYear
    ttk::label $w.content.muylbl -text "Until year:"
    ttk::entry $w.content.muyentry -width 8 -textvariable ::lichess_openex::untilYear
    set ::lichess_openex::dlg_masters_row $row
    grid $w.content.msylbl   -row $row -column 0 -sticky w -padx {0 8} -pady 2
    grid $w.content.msyentry -row $row -column 1 -sticky w -pady 2
    grid $w.content.muylbl   -row $row -column 2 -sticky w -padx {8 8} -pady 2
    grid $w.content.muyentry -row $row -column 3 -sticky w -pady 2
    incr row

    # --- Lichess/Player date fields (since/until as YYYY-MM) ---
    ttk::label $w.content.lsmlbl -text "Since (YYYY-MM):"
    ttk::entry $w.content.lsmentry -width 10 -textvariable ::lichess_openex::sinceMonth
    ttk::label $w.content.lumlbl -text "Until (YYYY-MM):"
    ttk::entry $w.content.lumentry -width 10 -textvariable ::lichess_openex::untilMonth
    set ::lichess_openex::dlg_lichdate_row $row
    grid $w.content.lsmlbl   -row $row -column 0 -sticky w -padx {0 8} -pady 2
    grid $w.content.lsmentry -row $row -column 1 -sticky w -pady 2
    grid $w.content.lumlbl   -row $row -column 2 -sticky w -padx {8 8} -pady 2
    grid $w.content.lumentry -row $row -column 3 -sticky w -pady 2
    incr row

    # --- Lichess-specific: Speed checkbuttons ---
    ttk::labelframe $w.content.speedframe -text "Time Controls" -padding 4
    set col 0
    foreach sp {ultraBullet bullet blitz rapid classical correspondence} {
        ttk::checkbutton $w.content.speedframe.sp_$sp -text $sp \
            -variable ::lichess_openex::chk_speed_$sp
        grid $w.content.speedframe.sp_$sp -row 0 -column $col -sticky w -padx 4
        incr col
    }
    set ::lichess_openex::dlg_speed_row $row
    grid $w.content.speedframe -row $row -column 0 -columnspan 4 -sticky ew -pady 4
    incr row

    # --- Lichess-specific: Rating checkbuttons ---
    ttk::labelframe $w.content.ratingframe -text "Rating Groups" -padding 4
    set col 0
    foreach rt {0 1000 1200 1400 1600 1800 2000 2200 2500} {
        set lbl $rt
        if {$rt == 0} { set lbl "0+" }
        ttk::checkbutton $w.content.ratingframe.rt_$rt -text $lbl \
            -variable ::lichess_openex::chk_rating_$rt
        grid $w.content.ratingframe.rt_$rt -row 0 -column $col -sticky w -padx 3
        incr col
    }
    set ::lichess_openex::dlg_rating_row $row
    grid $w.content.ratingframe -row $row -column 0 -columnspan 4 -sticky ew -pady 4
    incr row

    # --- Player-specific: Username, Color, Modes ---
    ttk::label $w.content.playerlbl -text "Player username:"
    ttk::entry $w.content.playerentry -width 20 -textvariable ::lichess_openex::playerName
    set ::lichess_openex::dlg_player_row $row
    grid $w.content.playerlbl   -row $row -column 0 -sticky w -padx {0 8} -pady 2
    grid $w.content.playerentry -row $row -column 1 -columnspan 2 -sticky w -pady 2
    incr row

    ttk::label $w.content.colorlbl -text "Player color:"
    ttk::radiobutton $w.content.color_w -text "White" -variable ::lichess_openex::playerColor -value "white"
    ttk::radiobutton $w.content.color_b -text "Black" -variable ::lichess_openex::playerColor -value "black"
    set ::lichess_openex::dlg_color_row $row
    grid $w.content.colorlbl -row $row -column 0 -sticky w -padx {0 8} -pady 2
    grid $w.content.color_w  -row $row -column 1 -sticky w -pady 2
    grid $w.content.color_b  -row $row -column 2 -sticky w -pady 2
    incr row

    ttk::labelframe $w.content.modeframe -text "Game Modes" -padding 4
    ttk::checkbutton $w.content.modeframe.rated -text "Rated" -variable ::lichess_openex::chk_mode_rated
    ttk::checkbutton $w.content.modeframe.casual -text "Casual" -variable ::lichess_openex::chk_mode_casual
    grid $w.content.modeframe.rated  -row 0 -column 0 -sticky w -padx 4
    grid $w.content.modeframe.casual -row 0 -column 1 -sticky w -padx 4
    set ::lichess_openex::dlg_mode_row $row
    grid $w.content.modeframe -row $row -column 0 -columnspan 4 -sticky ew -pady 4
    incr row

    grid columnconfigure $w.content 1 -weight 1

    # --- Buttons ---
    ttk::frame $w.buttons -padding {12 6}
    pack $w.buttons -fill x
    ttk::button $w.buttons.go -text "Go" -command [list ::lichess_openex::onGo $w]
    ttk::button $w.buttons.cancel -text "Cancel" -command [list ::lichess_openex::onCancel $w]
    pack $w.buttons.cancel -side right -padx 5
    pack $w.buttons.go -side right -padx 5

    bind $w <Return> [list ::lichess_openex::onGo $w]
    bind $w <Escape> [list ::lichess_openex::onCancel $w]

    # Show/hide fields based on current database selection
    ::lichess_openex::updateDialogFields $w

    # Center
    update idletasks
    set x [expr {([winfo screenwidth $w] - [winfo reqwidth $w]) / 2}]
    set y [expr {([winfo screenheight $w] - [winfo reqheight $w]) / 2}]
    wm geometry $w "+$x+$y"

    focus $w.buttons.go
}

# ::lichess_openex::updateDialogFields
#   Shows/hides database-specific fields in the dialog.
#
proc ::lichess_openex::updateDialogFields {w} {
    set db $::lichess_openex::database

    # Masters date fields (year-based)
    set mastersWidgets [list $w.content.msylbl $w.content.msyentry $w.content.muylbl $w.content.muyentry]
    # Lichess/Player date fields (YYYY-MM)
    set lichdateWidgets [list $w.content.lsmlbl $w.content.lsmentry $w.content.lumlbl $w.content.lumentry]
    # Speed frame
    set speedWidgets [list $w.content.speedframe]
    # Rating frame (Lichess only)
    set ratingWidgets [list $w.content.ratingframe]
    # Player fields
    set playerWidgets [list $w.content.playerlbl $w.content.playerentry]
    set colorWidgets [list $w.content.colorlbl $w.content.color_w $w.content.color_b]
    set modeWidgets [list $w.content.modeframe]

    # Hide all optional fields first
    foreach wdg [concat $mastersWidgets $lichdateWidgets $speedWidgets $ratingWidgets $playerWidgets $colorWidgets $modeWidgets] {
        grid remove $wdg
    }

    switch -- $db {
        "masters" {
            foreach wdg $mastersWidgets { grid $wdg }
        }
        "lichess" {
            foreach wdg $lichdateWidgets { grid $wdg }
            foreach wdg $speedWidgets { grid $wdg }
            foreach wdg $ratingWidgets { grid $wdg }
        }
        "player" {
            foreach wdg $lichdateWidgets { grid $wdg }
            foreach wdg $speedWidgets { grid $wdg }
            foreach wdg $playerWidgets { grid $wdg }
            foreach wdg $colorWidgets { grid $wdg }
            foreach wdg $modeWidgets { grid $wdg }
        }
    }
}

# ::lichess_openex::onGo
#   Validate dialog, save settings, close dialog, query API.
#
proc ::lichess_openex::onGo {w} {
    # Require an API token (Lichess has required one for Opening Explorer since March 2026)
    if {[string trim $::lichess_openex::apiToken] eq ""} {
        tk_messageBox -icon warning -type ok -title "Lichess Opening Explorer" \
            -message "A Lichess API token is required.\n\nAs of March 2026, Lichess requires an API token to access the Opening Explorer. Please enter your token in the \"Lichess API Token\" field above.\n\nYou can create a token at: https://lichess.org/account/oauth/token" -parent $w
        focus $w.content.tokenentry
        return
    }

    # Validate player-specific requirements
    if {$::lichess_openex::database eq "player"} {
        if {[string trim $::lichess_openex::playerName] eq ""} {
            tk_messageBox -icon warning -type ok -title "Lichess Opening Explorer" \
                -message "Please enter a Lichess username for the Player database." -parent $w
            return
        }
    }

    # All persisted variables are already up-to-date (widgets bind directly).
    # Remove the checkbox traces before destroying the dialog.
    ::lichess_openex::removeTraces
    destroy $w
    ::lichess_openex::queryExplorer
}

# ::lichess_openex::onCancel
#   Restores persisted variables from backup and closes the dialog.
#
proc ::lichess_openex::onCancel {w} {
    # Remove traces first
    ::lichess_openex::removeTraces

    # Restore all persisted variables from backup
    set ::lichess_openex::database $::lichess_openex::backup_db
    set ::lichess_openex::apiToken $::lichess_openex::backup_token
    set ::lichess_openex::numMoves $::lichess_openex::backup_numMoves
    set ::lichess_openex::topGames $::lichess_openex::backup_topGames
    set ::lichess_openex::recentGames $::lichess_openex::backup_recentGames
    set ::lichess_openex::sinceYear $::lichess_openex::backup_sinceYear
    set ::lichess_openex::untilYear $::lichess_openex::backup_untilYear
    set ::lichess_openex::sinceMonth $::lichess_openex::backup_sinceMonth
    set ::lichess_openex::untilMonth $::lichess_openex::backup_untilMonth
    set ::lichess_openex::playerName $::lichess_openex::backup_playerName
    set ::lichess_openex::playerColor $::lichess_openex::backup_playerColor
    set ::lichess_openex::speeds $::lichess_openex::backup_speeds
    set ::lichess_openex::ratings $::lichess_openex::backup_ratings
    set ::lichess_openex::modes $::lichess_openex::backup_modes

    destroy $w
}

# ::lichess_openex::syncSpeeds
#   Trace callback: rebuilds the persisted speeds list from checkbox variables.
#
proc ::lichess_openex::syncSpeeds {args} {
    set speeds {}
    foreach sp {ultraBullet bullet blitz rapid classical correspondence} {
        if {[set ::lichess_openex::chk_speed_$sp]} {
            lappend speeds $sp
        }
    }
    set ::lichess_openex::speeds $speeds
}

# ::lichess_openex::syncRatings
#   Trace callback: rebuilds the persisted ratings list from checkbox variables.
#
proc ::lichess_openex::syncRatings {args} {
    set ratings {}
    foreach rt {0 1000 1200 1400 1600 1800 2000 2200 2500} {
        if {[set ::lichess_openex::chk_rating_$rt]} {
            lappend ratings $rt
        }
    }
    set ::lichess_openex::ratings $ratings
}

# ::lichess_openex::syncModes
#   Trace callback: rebuilds the persisted modes list from checkbox variables.
#
proc ::lichess_openex::syncModes {args} {
    set modes {}
    foreach md {rated casual} {
        if {[set ::lichess_openex::chk_mode_$md]} {
            lappend modes $md
        }
    }
    set ::lichess_openex::modes $modes
}

# ::lichess_openex::removeTraces
#   Removes the write traces added by openDialog to avoid leaks.
#
proc ::lichess_openex::removeTraces {} {
    foreach sp {ultraBullet bullet blitz rapid classical correspondence} {
        catch {trace remove variable ::lichess_openex::chk_speed_$sp write ::lichess_openex::syncSpeeds}
    }
    foreach rt {0 1000 1200 1400 1600 1800 2000 2200 2500} {
        catch {trace remove variable ::lichess_openex::chk_rating_$rt write ::lichess_openex::syncRatings}
    }
    foreach md {rated casual} {
        catch {trace remove variable ::lichess_openex::chk_mode_$md write ::lichess_openex::syncModes}
    }
}

# ::lichess_openex::buildUrl
#   Constructs the Opening Explorer API URL from the current settings and FEN.
#
proc ::lichess_openex::buildUrl {fen} {
    set db $::lichess_openex::database
    set urlFen [::lichess_openex::urlEncode $fen]

    # Detect Chess960 variant from the current game
    set gameVariant [sc_game variant]
    if {$gameVariant eq "chess960"} {
        set variant "chess960"
    } else {
        set variant "standard"
    }

    set url "$::lichess_openex::baseUrl/$db?fen=$urlFen"

    # Common params
    append url "&moves=$::lichess_openex::numMoves"

    if {$db ne "player"} {
        append url "&topGames=$::lichess_openex::topGames"
    }
    append url "&recentGames=$::lichess_openex::recentGames"

    switch -- $db {
        "masters" {
            # Masters database is OTB games only; no variant param needed
            if {$::lichess_openex::sinceYear ne ""} {
                append url "&since=$::lichess_openex::sinceYear"
            }
            if {$::lichess_openex::untilYear ne ""} {
                append url "&until=$::lichess_openex::untilYear"
            }
        }
        "lichess" {
            append url "&variant=$variant"
            if {$::lichess_openex::sinceMonth ne ""} {
                append url "&since=$::lichess_openex::sinceMonth"
            }
            if {$::lichess_openex::untilMonth ne ""} {
                append url "&until=$::lichess_openex::untilMonth"
            }
            if {[llength $::lichess_openex::speeds] > 0} {
                foreach sp $::lichess_openex::speeds {
                    append url "&speeds%5B%5D=$sp"
                }
            }
            if {[llength $::lichess_openex::ratings] > 0} {
                foreach rt $::lichess_openex::ratings {
                    append url "&ratings%5B%5D=$rt"
                }
            }
        }
        "player" {
            append url "&variant=$variant"
            append url "&player=[::lichess_openex::urlEncode $::lichess_openex::playerName]"
            append url "&color=$::lichess_openex::playerColor"
            if {$::lichess_openex::sinceMonth ne ""} {
                append url "&since=$::lichess_openex::sinceMonth"
            }
            if {$::lichess_openex::untilMonth ne ""} {
                append url "&until=$::lichess_openex::untilMonth"
            }
            if {[llength $::lichess_openex::speeds] > 0} {
                foreach sp $::lichess_openex::speeds {
                    append url "&speeds%5B%5D=$sp"
                }
            }
            if {[llength $::lichess_openex::modes] > 0} {
                foreach md $::lichess_openex::modes {
                    append url "&modes%5B%5D=$md"
                }
            }
        }
    }
    return $url
}

# ::lichess_openex::urlEncode
#   Simple URL encoding for FEN strings and usernames.
#
proc ::lichess_openex::urlEncode {str} {
    return [string map {
        " " "%20" "/" "%2F" "+" "%2B" "?" "%3F" "&" "%26" "=" "%3D"
        "#" "%23" "%" "%25"
    } $str]
}

# ::lichess_openex::lastJsonLine
#   For NDJSON (streamed) responses, returns the last non-empty line
#   that looks like JSON. For single-line JSON, returns the input as-is.
#
proc ::lichess_openex::lastJsonLine {data} {
    set data [string trim $data]
    if {$data eq ""} { return "" }
    # If the response has multiple lines, take the last one with JSON content
    set lines [split $data "\n"]
    if {[llength $lines] <= 1} { return $data }
    # Walk backwards to find the last line containing a JSON object
    for {set i [expr {[llength $lines] - 1}]} {$i >= 0} {incr i -1} {
        set line [string trim [lindex $lines $i]]
        if {$line ne "" && [string index $line 0] eq "\{"} {
            return $line
        }
    }
    return $data
}

# ::lichess_openex::httpGet
#   Cross-platform HTTP GET. Returns the response body or throws an error.
#   If token is non-empty, includes Authorization header.
#   Uses pipe-based curl to handle NDJSON streaming (player endpoint)
#   where curl may exit non-zero despite returning valid data.
#   If extractJson is 1 (default), applies NDJSON extraction and requires
#   a JSON response. Set to 0 for raw responses (e.g. PGN from game export).
#
proc ::lichess_openex::httpGet {url {token ""} {extractJson 1}} {
    set result ""

    # Build curl command as a list
    set cmd [list curl -s --max-time 15 -H "Accept: */*"]
    if {$token ne ""} {
        lappend cmd -H "Authorization: Bearer $token"
    }
    lappend cmd $url

    # Use open-pipe to capture stdout regardless of curl exit code.
    # The player endpoint returns NDJSON (streamed), which can cause
    # curl to exit non-zero even though valid data was received.
    if {![catch {
        set fd [open "|$cmd" r]
        set result [read $fd]
    } pipeErr]} {
        # close may throw if curl exited non-zero, but we already have data
        catch {close $fd}
    } else {
        catch {close $fd}
        set result ""
    }

    if {$extractJson} {
        # Extract last JSON line (handles NDJSON from player endpoint)
        set result [::lichess_openex::lastJsonLine $result]
        if {$result ne "" && [string index $result 0] eq "\{"} {
            return $result
        }
    } else {
        # Return raw response (e.g. PGN from game export)
        set result [string trim $result]
        if {$result ne ""} {
            return $result
        }
    }

    # Fallback: Tcl http + tls
    set err1 "curl: $pipeErr"
    if {![catch {package require http}]} {
        catch {package require tls}
        catch {::http::register https 443 ::tls::socket}
        set headers [list Accept "*/*"]
        if {$token ne ""} {
            lappend headers Authorization "Bearer $token"
        }
        set httpToken ""
        if {![catch {set httpToken [::http::geturl $url -timeout 15000 -headers $headers]} httpErr]} {
            set result [::http::data $httpToken]
            ::http::cleanup $httpToken
            if {$extractJson} {
                set result [::lichess_openex::lastJsonLine $result]
            }
            return $result
        }
        set err1 "$err1; http: $httpErr"
    }

    # Windows fallback: PowerShell
    if {[info exists ::windowsOS] && $::windowsOS && [auto_execok powershell] ne ""} {
        set psHeaders ""
        if {$token ne ""} {
            set psHeaders "-Headers @{'Authorization'='Bearer \$env:LICHESS_OPENEX_TOKEN'; 'Accept'='*/*'}"
            set ::env(LICHESS_OPENEX_TOKEN) $token
        } else {
            set psHeaders "-Headers @{'Accept'='*/*'}"
        }
        set ::env(LICHESS_OPENEX_URL) $url
        if {![catch {exec powershell -NoLogo -NoProfile -Command \
            "(Invoke-WebRequest -Uri \$env:LICHESS_OPENEX_URL $psHeaders -TimeoutSec 15).Content"} result]} {
            catch {unset ::env(LICHESS_OPENEX_TOKEN)}
            catch {unset ::env(LICHESS_OPENEX_URL)}
            if {$extractJson} {
                set result [::lichess_openex::lastJsonLine $result]
            }
            return $result
        }
        catch {unset ::env(LICHESS_OPENEX_TOKEN)}
        catch {unset ::env(LICHESS_OPENEX_URL)}
    }

    error "Failed to query Lichess Opening Explorer: $err1"
}

# ::lichess_openex::queryExplorer
#   Gets the current FEN, builds URL, performs HTTP request, displays results.
#
proc ::lichess_openex::queryExplorer {} {
    set fen [sc_pos fen]
    set url [::lichess_openex::buildUrl $fen]
    set token $::lichess_openex::apiToken

    # Create or reset the results window
    set w .lichessOpenExResult
    if {[winfo exists $w]} { destroy $w }

    toplevel $w
    wm title $w "Lichess Opening Explorer"
    wm resizable $w 1 1
    wm minsize $w 850 500
    if {[winfo exists .]} { wm transient $w . }

    ttk::frame $w.content -padding 10
    pack $w.content -fill both -expand 1

    ttk::label $w.content.loading -text "Querying Lichess Opening Explorer..." -font font_Bold
    pack $w.content.loading -pady 10

    update idletasks

    # Perform the query
    set ok 0
    set result ""
    if {![catch {set result [::lichess_openex::httpGet $url $token]} err]} {
        set ok 1
    } else {
        set result $err
    }

    destroy $w.content.loading

    if {!$ok} {
        ::lichess_openex::showError $w "Failed to query Lichess Opening Explorer:\n$result"
        return
    }

    # Check for error responses
    if {[string match "*\"error\"*" $result] || [string match "*Not Found*" $result]} {
        if {![regexp {"moves"} $result]} {
            ::lichess_openex::showError $w "Position not found in the $::lichess_openex::database database.\n\nThe API returned:\n[string range $result 0 300]"
            return
        }
    }

    # Parse and display results
    ::lichess_openex::displayResults $w $result $fen

    # Center the window
    update idletasks
    set winWidth [winfo width $w]
    set winHeight [winfo height $w]
    if {$winWidth < 100} { set winWidth 850 }
    if {$winHeight < 100} { set winHeight 500 }
    set x [expr {([winfo screenwidth $w] - $winWidth) / 2}]
    set y [expr {([winfo screenheight $w] - $winHeight) / 2}]
    wm geometry $w "+$x+$y"
}

# ::lichess_openex::displayResults
#   Parses JSON and populates the results window.
#
proc ::lichess_openex::displayResults {w jsonData fen} {
    # Parse overall W/D/L
    set totalWhite 0
    set totalDraws 0
    set totalBlack 0
    regexp {"white":(\d+)} $jsonData -> totalWhite
    regexp {"draws":(\d+)} $jsonData -> totalDraws
    regexp {"black":(\d+)} $jsonData -> totalBlack
    set totalGames [expr {$totalWhite + $totalDraws + $totalBlack}]

    # --- Top panel: W/D/L and Moves table ---
    ttk::frame $w.top
    pack $w.top -fill both -expand 1 -padx 5 -pady 5

    # W/D/L summary
    set dbLabel [string totitle $::lichess_openex::database]
    ttk::label $w.top.title -text "Lichess Opening Explorer - $dbLabel Database" -font font_Bold
    pack $w.top.title -anchor w -pady {0 4}

    ttk::frame $w.top.wdl
    pack $w.top.wdl -anchor w -pady {0 8}

    if {$totalGames > 0} {
        set wPct [format "%.1f" [expr {$totalWhite * 100.0 / $totalGames}]]
        set dPct [format "%.1f" [expr {$totalDraws * 100.0 / $totalGames}]]
        set bPct [format "%.1f" [expr {$totalBlack * 100.0 / $totalGames}]]
        set fmtTotal [::lichess_openex::formatNumber $totalGames]
        set fmtWhite [::lichess_openex::formatNumber $totalWhite]
        set fmtDraws [::lichess_openex::formatNumber $totalDraws]
        set fmtBlack [::lichess_openex::formatNumber $totalBlack]
        ttk::label $w.top.wdl.info -text \
            "Total: $fmtTotal games  |  White wins: $fmtWhite ($wPct%)  |  Draws: $fmtDraws ($dPct%)  |  Black wins: $fmtBlack ($bPct%)"
    } else {
        ttk::label $w.top.wdl.info -text "No games found for this position."
    }
    pack $w.top.wdl.info -side left

    # --- Moves table ---
    ttk::label $w.top.moveslbl -text "Moves:" -font font_Bold
    pack $w.top.moveslbl -anchor w -pady {4 2}

    set cols {san white draws black total pct avgRating eco opening}
    set colNames {"Move" "White" "Draws" "Black" "Total" "Win%" "Avg Rating" "ECO" "Opening"}

    ttk::frame $w.top.movesframe
    pack $w.top.movesframe -fill both -expand 1

    ttk::treeview $w.top.movesframe.tree -columns $cols -show headings -height 12 \
        -selectmode browse
    ttk::scrollbar $w.top.movesframe.sb -orient vertical -command "$w.top.movesframe.tree yview"
    $w.top.movesframe.tree configure -yscrollcommand "$w.top.movesframe.sb set"

    foreach c $cols n $colNames {
        $w.top.movesframe.tree heading $c -text $n
    }
    $w.top.movesframe.tree column san       -width 60  -anchor center
    $w.top.movesframe.tree column white     -width 65  -anchor e
    $w.top.movesframe.tree column draws     -width 65  -anchor e
    $w.top.movesframe.tree column black     -width 65  -anchor e
    $w.top.movesframe.tree column total     -width 70  -anchor e
    $w.top.movesframe.tree column pct       -width 55  -anchor e
    $w.top.movesframe.tree column avgRating -width 75  -anchor e
    $w.top.movesframe.tree column eco       -width 50  -anchor center
    $w.top.movesframe.tree column opening   -width 200 -anchor w

    pack $w.top.movesframe.tree -side left -fill both -expand 1
    pack $w.top.movesframe.sb -side right -fill y

    # Parse moves array and populate
    ::lichess_openex::parseMoves $w.top.movesframe.tree $jsonData
    bind $w.top.movesframe.tree <Double-1> [list ::lichess_openex::onMoveClick $w.top.movesframe.tree]

    # --- Bottom panel: Top Games and Recent Games ---
    ttk::frame $w.bottom
    pack $w.bottom -fill both -expand 1 -padx 5 -pady 5

    # Top Games
    set hasTopGames [expr {$::lichess_openex::database ne "player"}]
    if {$hasTopGames} {
        ttk::label $w.bottom.topglbl -text "Top Games:" -font font_Bold
        pack $w.bottom.topglbl -anchor w -pady {4 2}

        set gameCols {san winner whiteName whiteRating blackName blackRating date}
        set gameColNames {"Move" "Winner" "White" "W.Rating" "Black" "B.Rating" "Date"}

        ttk::frame $w.bottom.topgframe
        pack $w.bottom.topgframe -fill both -expand 1

        ttk::treeview $w.bottom.topgframe.tree -columns $gameCols -show headings -height 6 \
            -selectmode browse
        ttk::scrollbar $w.bottom.topgframe.sb -orient vertical -command "$w.bottom.topgframe.tree yview"
        $w.bottom.topgframe.tree configure -yscrollcommand "$w.bottom.topgframe.sb set"

        foreach c $gameCols n $gameColNames {
            $w.bottom.topgframe.tree heading $c -text $n \
                -command [list ::lichess_openex::sortByColumn $w.bottom.topgframe.tree $c 1]
        }
        $w.bottom.topgframe.tree column san         -width 55  -anchor center
        $w.bottom.topgframe.tree column winner      -width 55  -anchor center
        $w.bottom.topgframe.tree column whiteName   -width 150 -anchor w
        $w.bottom.topgframe.tree column whiteRating -width 65  -anchor e
        $w.bottom.topgframe.tree column blackName   -width 150 -anchor w
        $w.bottom.topgframe.tree column blackRating -width 65  -anchor e
        $w.bottom.topgframe.tree column date        -width 80  -anchor center

        pack $w.bottom.topgframe.tree -side left -fill both -expand 1
        pack $w.bottom.topgframe.sb -side right -fill y

        ::lichess_openex::parseGames $w.bottom.topgframe.tree $jsonData "topGames" $fen
        bind $w.bottom.topgframe.tree <Double-1> [list ::lichess_openex::onGameClick $w.bottom.topgframe.tree]
    }

    # Recent Games
    ttk::label $w.bottom.recglbl -text "Recent Games:" -font font_Bold
    pack $w.bottom.recglbl -anchor w -pady {8 2}

    set gameCols {san winner whiteName whiteRating blackName blackRating date}
    set gameColNames {"Move" "Winner" "White" "W.Rating" "Black" "B.Rating" "Date"}

    ttk::frame $w.bottom.recgframe
    pack $w.bottom.recgframe -fill both -expand 1

    ttk::treeview $w.bottom.recgframe.tree -columns $gameCols -show headings -height 5 \
        -selectmode browse
    ttk::scrollbar $w.bottom.recgframe.sb -orient vertical -command "$w.bottom.recgframe.tree yview"
    $w.bottom.recgframe.tree configure -yscrollcommand "$w.bottom.recgframe.sb set"

    foreach c $gameCols n $gameColNames {
        $w.bottom.recgframe.tree heading $c -text $n \
            -command [list ::lichess_openex::sortByColumn $w.bottom.recgframe.tree $c 1]
    }
    $w.bottom.recgframe.tree column san         -width 55  -anchor center
    $w.bottom.recgframe.tree column winner      -width 55  -anchor center
    $w.bottom.recgframe.tree column whiteName   -width 150 -anchor w
    $w.bottom.recgframe.tree column whiteRating -width 65  -anchor e
    $w.bottom.recgframe.tree column blackName   -width 150 -anchor w
    $w.bottom.recgframe.tree column blackRating -width 65  -anchor e
    $w.bottom.recgframe.tree column date        -width 80  -anchor center

    pack $w.bottom.recgframe.tree -side left -fill both -expand 1
    pack $w.bottom.recgframe.sb -side right -fill y

    ::lichess_openex::parseGames $w.bottom.recgframe.tree $jsonData "recentGames" $fen
    bind $w.bottom.recgframe.tree <Double-1> [list ::lichess_openex::onGameClick $w.bottom.recgframe.tree]

    # --- Close button ---
    ttk::frame $w.btnbar
    pack $w.btnbar -fill x -pady {5 0}
    ttk::button $w.btnbar.close -text "Close" -command "destroy $w"
    pack $w.btnbar.close -side right -padx 5

    bind $w <Escape> "destroy $w"
    focus $w.btnbar.close
}

# ::lichess_openex::parseMoves
#   Extracts the "moves" array from JSON and populates the treeview.
#
proc ::lichess_openex::parseMoves {tree jsonData} {
    # Find the "moves" array
    if {![regexp -indices {"moves"\s*:\s*\[} $jsonData match]} {
        return
    }
    set arrayStart [lindex $match 1]
    set remaining [string range $jsonData $arrayStart end]

    # Find the end of the moves array (balanced brackets)
    set depth 1
    set pos 1
    set len [string length $remaining]
    while {$pos < $len && $depth > 0} {
        set ch [string index $remaining $pos]
        if {$ch eq "\["} { incr depth }
        if {$ch eq "\]"} { incr depth -1 }
        incr pos
    }
    set movesJson [string range $remaining 0 [expr {$pos - 2}]]

    # Extract individual move objects using balanced-brace parser
    # (move objects may contain nested objects like "opening":{...} or "game":{...})
    set searchStr $movesJson
    while {[set idx [string first "\{" $searchStr]] >= 0} {
        set depth 1
        set p [expr {$idx + 1}]
        set slen [string length $searchStr]
        while {$p < $slen && $depth > 0} {
            set ch [string index $searchStr $p]
            if {$ch eq "\{"} { incr depth }
            if {$ch eq "\}"} { incr depth -1 }
            incr p
        }
        set objEnd [expr {$p - 1}]
        set obj [string range $searchStr $idx $objEnd]

        set san ""
        set mWhite 0
        set mDraws 0
        set mBlack 0
        set avgRating ""
        set eco ""
        set opening ""

        regexp {"san"\s*:\s*"([^"]*)"} $obj -> san
        regexp {"white"\s*:\s*(\d+)} $obj -> mWhite
        regexp {"draws"\s*:\s*(\d+)} $obj -> mDraws
        regexp {"black"\s*:\s*(\d+)} $obj -> mBlack
        regexp {"averageRating"\s*:\s*(\d+)} $obj -> avgRating

        # Opening info: {"eco":"A00","name":"..."}
        if {[regexp {"opening"\s*:\s*\{([^\}]*)\}} $obj -> openObj]} {
            regexp {"eco"\s*:\s*"([^"]*)"} $openObj -> eco
            regexp {"name"\s*:\s*"([^"]*)"} $openObj -> opening
        }

        set total [expr {$mWhite + $mDraws + $mBlack}]
        if {$total > 0} {
            set pct [format "%.1f" [expr {$mWhite * 100.0 / $total}]]
        } else {
            set pct ""
        }

        if {$san ne ""} {
            set fmtW [::lichess_openex::formatNumber $mWhite]
            set fmtD [::lichess_openex::formatNumber $mDraws]
            set fmtB [::lichess_openex::formatNumber $mBlack]
            set fmtT [::lichess_openex::formatNumber $total]
            $tree insert {} end -values [list $san $fmtW $fmtD $fmtB $fmtT $pct $avgRating $eco $opening]
        }

        set searchStr [string range $searchStr [expr {$objEnd + 1}] end]
    }
}

# ::lichess_openex::parseGames
#   Extracts "topGames" or "recentGames" array from JSON and populates the treeview.
#   Each item stores the game ID as a tag for click handling.
#
proc ::lichess_openex::parseGames {tree jsonData arrayName {fen ""}} {
    # Find the named array
    if {![regexp -indices "\"$arrayName\"\\s*:\\s*\\\[" $jsonData match]} {
        return
    }
    set arrayStart [lindex $match 1]
    set remaining [string range $jsonData $arrayStart end]

    # Find the end of the array (balanced brackets)
    set depth 1
    set pos 1
    set len [string length $remaining]
    while {$pos < $len && $depth > 0} {
        set ch [string index $remaining $pos]
        if {$ch eq "\["} { incr depth }
        if {$ch eq "\]"} { incr depth -1 }
        incr pos
    }
    set gamesJson [string range $remaining 0 [expr {$pos - 2}]]

    # Extract individual game objects - use a more robust nested-object parser
    set searchStr $gamesJson
    while {[set idx [string first "\{" $searchStr]] >= 0} {
        # Find balanced closing brace
        set depth 1
        set p [expr {$idx + 1}]
        set slen [string length $searchStr]
        while {$p < $slen && $depth > 0} {
            set ch [string index $searchStr $p]
            if {$ch eq "\{"} { incr depth }
            if {$ch eq "\}"} { incr depth -1 }
            incr p
        }
        set obj [string range $searchStr $idx [expr {$p - 1}]]

        set san ""
        set gameId ""
        set winner ""
        set whiteName ""
        set whiteRating ""
        set blackName ""
        set blackRating ""
        set month ""
        set year ""

        regexp {"uci"\s*:\s*"([^"]*)"} $obj -> uci
        regexp {"san"\s*:\s*"([^"]*)"} $obj -> san
        regexp {"id"\s*:\s*"([^"]*)"} $obj -> gameId

        # winner can be "white", "black", or null
        if {[regexp {"winner"\s*:\s*"([^"]*)"} $obj -> winner]} {
            # got it
        } elseif {[regexp {"winner"\s*:\s*null} $obj]} {
            set winner "draw"
        }

        # Extract white player info: "white":{"name":"...","rating":...}
        if {[regexp {"white"\s*:\s*\{([^\}]*)\}} $obj -> wObj]} {
            regexp {"name"\s*:\s*"([^"]*)"} $wObj -> whiteName
            regexp {"rating"\s*:\s*(\d+)} $wObj -> whiteRating
        }
        # Extract black player info
        if {[regexp {"black"\s*:\s*\{([^\}]*)\}} $obj -> bObj]} {
            regexp {"name"\s*:\s*"([^"]*)"} $bObj -> blackName
            regexp {"rating"\s*:\s*(\d+)} $bObj -> blackRating
        }

        regexp {"year"\s*:\s*(\d+)} $obj -> year
        regexp {"month"\s*:\s*"([^"]*)"} $obj -> month

        set dateStr ""
        if {$month ne ""} {
            set dateStr $month
        } elseif {$year ne ""} {
            set dateStr $year
        }

        # Convert UCI move to SAN notation using the FEN position
        set moveStr ""
        if {[info exists uci] && $uci ne "" && $fen ne ""} {
            set moveStr [::lichess_openex::uciToSan $uci $fen]
        }
        # Fallback to san field from JSON, then raw uci
        if {$moveStr eq "" && $san ne ""} {
            set moveStr $san
        }
        if {$moveStr eq "" && [info exists uci] && $uci ne ""} {
            set moveStr $uci
        }

        # Map winner to display text
        set winnerDisplay ""
        switch -- $winner {
            "white" { set winnerDisplay "1-0" }
            "black" { set winnerDisplay "0-1" }
            "draw"  { set winnerDisplay "1/2" }
            default { set winnerDisplay "?" }
        }

        if {$gameId ne ""} {
            $tree insert {} end -values [list $moveStr $winnerDisplay $whiteName $whiteRating $blackName $blackRating $dateStr] \
                -tags [list "gid_$gameId"]
        }

        set searchStr [string range $searchStr $p end]
    }
}

# ::lichess_openex::onMoveClick
#   Handles double-click on a move row in the upper panel.
#   Makes the move on the current board (as variation if one exists, or appended).
#   Then refreshes the explorer with the new position.
#
proc ::lichess_openex::onMoveClick {tree} {
    set sel [$tree selection]
    if {$sel eq ""} return

    set san [lindex [$tree item $sel -values] 0]
    if {$san eq ""} return

    if {[catch {::addSanMove $san} err]} {
        tk_messageBox -icon error -type ok -title "Lichess Opening Explorer" \
            -message "Failed to add move $san:\n$err"
    } else {
        # Refresh the explorer for the new position
        ::lichess_openex::queryExplorer
    }
}

# ::lichess_openex::onGameClick
#   Handles double-click on a game row in top/recent games treeview.
#   Extracts the game ID from the tag and loads the game.
#
proc ::lichess_openex::onGameClick {tree} {
    set sel [$tree selection]
    if {$sel eq ""} return

    set tags [$tree item $sel -tags]
    set gameId ""
    foreach tag $tags {
        if {[string match "gid_*" $tag]} {
            set gameId [string range $tag 4 end]
            break
        }
    }

    if {$gameId eq ""} return

    # Confirm with user
    set whiteName [lindex [$tree item $sel -values] 2]
    set blackName [lindex [$tree item $sel -values] 4]
    set ans [tk_messageBox -icon question -type yesno \
        -title "Load Game" \
        -message "Load game $whiteName vs $blackName (ID: $gameId) into the clipbase?"]
    if {$ans ne "yes"} return

    ::lichess_openex::loadGame $gameId
}

# ::lichess_openex::loadGame
#   Fetches a game by ID from Lichess and imports it into the clipbase.
#
proc ::lichess_openex::loadGame {gameId} {
    set url "https://lichess.org/game/export/${gameId}?clocks=true&evals=true&opening=true"
    set token $::lichess_openex::apiToken

    # Fetch the PGN (raw response, not JSON)
    set pgnData ""
    if {[catch {set pgnData [::lichess_openex::httpGet $url $token 0]} err]} {
        tk_messageBox -icon error -type ok -title "Lichess Opening Explorer" \
            -message "Failed to fetch game $gameId:\n$err"
        return
    }

    if {$pgnData eq "" || [string match "*Not Found*" $pgnData]} {
        tk_messageBox -icon error -type ok -title "Lichess Opening Explorer" \
            -message "Game $gameId not found on Lichess."
        return
    }

    # Switch to clipbase and import
    ::file::SwitchToBase $::clipbase_db
    if {[::game::Clear] eq "cancel"} { return }
    if {[catch {
        set importResult [sc_game import $pgnData]
        
        # Save imported game to clipbase to allow loading multiple games without discard dialog
        sc_game save 0 $::clipbase_db
        set new_game_num [sc_base numGames $::clipbase_db]
        sc_game load $new_game_num
        
        ::notify::GameChanged
    } err]} {
        tk_messageBox -icon error -type ok -title "Lichess Opening Explorer" \
            -message "Failed to import game:\n$err"
        return
    }

    # Open the game list window for clipbase, or refresh if already open
    set found 0
    foreach glwin $::windows::gamelist::wins {
        if {[info exists ::gamelistBase($glwin)] && $::gamelistBase($glwin) == $::clipbase_db} {
            ::windows::gamelist::Refresh 1 [list $glwin]
            ::win::makeVisible $glwin
            set found 1
            break
        }
    }
    if {!$found} {
        catch { ::windows::gamelist::Open $::clipbase_db }
    }

    tk_messageBox -icon info -type ok -title "Lichess Opening Explorer" \
        -message "Game loaded into clipbase successfully."
}

# ::lichess_openex::formatNumber
#   Formats an integer with comma separators (e.g. 102344 -> "102,344").
#
proc ::lichess_openex::formatNumber {n} {
    # Handle negative numbers
    if {$n < 0} {
        return "-[::lichess_openex::formatNumber [expr {-$n}]]"
    }
    set s [format "%d" $n]
    set len [string length $s]
    if {$len <= 3} { return $s }
    set result ""
    set i 0
    foreach ch [split $s ""] {
        if {$i > 0 && ($len - $i) % 3 == 0} {
            append result ","
        }
        append result $ch
        incr i
    }
    return $result
}

# ::lichess_openex::uciToSan
#   Converts a UCI move (e.g. "e2e4") to SAN using the existing
#   ::uci::formatPv utility and the given FEN position.
#   Returns the original UCI string if conversion fails.
#
proc ::lichess_openex::uciToSan {uciMove fen} {
    if {$uciMove eq ""} { return "" }
    if {[catch {set san [::uci::formatPv [list $uciMove] $fen]}]} {
        return $uciMove
    }
    if {$san eq "" || $san eq $uciMove} {
        return $uciMove
    }
    return $san
}

# ::lichess_openex::sortByColumn
#   Sorts a treeview by the given column. Toggles between ascending
#   and descending on repeated clicks.
#
proc ::lichess_openex::sortByColumn {tree col ascending} {
    set numericCols {whiteRating blackRating}
    set isNumeric [expr {$col in $numericCols}]

    set data {}
    foreach item [$tree children {}] {
        set val [$tree set $item $col]
        # Replace empty or non-numeric values with -1 for numeric columns
        if {$isNumeric && ($val eq "" || ![string is integer -strict $val])} {
            set val -1
        }
        lappend data [list $val $item]
    }

    if {$isNumeric} {
        set data [lsort -index 0 -integer [expr {$ascending ? "-increasing" : "-decreasing"}] $data]
    } else {
        set data [lsort -index 0 -dictionary [expr {$ascending ? "-increasing" : "-decreasing"}] $data]
    }

    set idx 0
    foreach entry $data {
        $tree move [lindex $entry 1] {} $idx
        incr idx
    }

    # Toggle direction for next click
    $tree heading $col -command [list ::lichess_openex::sortByColumn $tree $col [expr {!$ascending}]]
}

# ::lichess_openex::showError
#   Displays an error message in the results window.
#
proc ::lichess_openex::showError {w message} {
    ttk::frame $w.error
    pack $w.error -fill both -expand 1 -padx 20 -pady 10

    ttk::label $w.error.title -text "Lichess Opening Explorer" -font font_Bold
    pack $w.error.title -pady {0 10}

    ttk::label $w.error.msg -text $message -wraplength 500
    pack $w.error.msg -pady 10

    ttk::button $w.error.close -text "Close" -command "destroy $w"
    pack $w.error.close -pady {10 0}

    bind $w <Escape> "destroy $w"
    bind $w <Return> "destroy $w"
    focus $w.error.close
}
