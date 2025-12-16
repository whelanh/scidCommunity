######################################################################
#
# lichess_tournament.tcl: Monitor live Lichess tournament broadcasts
#
# Downloads and displays live tournament games from Lichess broadcasts,
# with automatic polling of ongoing games every 3 minutes.
#
######################################################################

namespace eval ::lichess_tournament {
  variable downloading 0
  variable fetching_broadcasts 0
  variable tempDir ""
  variable currentTournamentUrl ""
  variable currentTournamentPgnUrl ""
  variable tournamentModeActive 0
  variable liveGameTimers [dict create]
  variable gamePollingData [dict create]
}

# lichess_tournament::openTournament
#   Main entry point: fetch broadcasts and show tournament selection dialog
#
proc ::lichess_tournament::openTournament {} {
  if {$::lichess_tournament::fetching_broadcasts} {
    tk_messageBox -icon warning -type ok -title "Lichess Tournament" \
      -message "Fetching broadcasts list. Please wait."
    return
  }
  
  set ::lichess_tournament::fetching_broadcasts 1
  catch {.menu.file entryconfig "Open Lichess Tournament*" -state disabled}
  
  # Fetch the broadcasts list asynchronously
  if {[catch {
    ::lichess_tournament::fetchBroadcastsList
  } err]} {
    set ::lichess_tournament::fetching_broadcasts 0
    catch {.menu.file entryconfig "Open Lichess Tournament*" -state normal}
    tk_messageBox -icon error -type ok -title "Lichess Tournament Error" \
      -message "Error fetching broadcasts list:\n$err"
    return
  }
}

# lichess_tournament::fetchBroadcastsList
#   Download and parse Lichess broadcasts page
#
proc ::lichess_tournament::fetchBroadcastsList {} {
  set broadcastsUrl "https://lichess.org/broadcast?ref=offerspill.com"
  
  # Create temp directory for this download
  if {[catch {
    set tempdir [file join [::lichess::getTempDir] "scid_tournament_[clock seconds]"]
    file mkdir $tempdir
    set ::lichess_tournament::tempDir $tempdir
  } err]} {
    error "Could not create temp directory: $err"
  }
  
  set broadcastsFile [file join $::lichess_tournament::tempDir "broadcasts.html"]
  
  # Download the broadcasts page
  if {[auto_execok curl] ne ""} {
    if {[catch {
      exec curl -L -s -o "$broadcastsFile" "$broadcastsUrl" 2>@1
    } err]} {
      error "curl download failed: $err"
    }
  } elseif {[auto_execok wget] ne ""} {
    if {[catch {
      exec wget -q -O "$broadcastsFile" "$broadcastsUrl" 2>@1
    } err]} {
      error "wget download failed: $err"
    }
  } elseif {[info exists ::windowsOS] && $::windowsOS && [auto_execok powershell] ne ""} {
    if {[catch {
      exec powershell -NoLogo -NoProfile -Command "Invoke-WebRequest -Uri '$broadcastsUrl' -OutFile '$broadcastsFile'" 2>@1
    } err]} {
      error "PowerShell download failed: $err"
    }
  } else {
    ::lichess_tournament::downloadWithHTTP $broadcastsUrl $broadcastsFile
  }
  
  if {![file exists $broadcastsFile] || [file size $broadcastsFile] == 0} {
    error "Could not download broadcasts page"
  }
  
  # Parse the HTML to extract tournament links
  set tournaments [::lichess_tournament::parseBroadcasts $broadcastsFile]
  set ::lichess_tournament::fetching_broadcasts 0
  catch {.menu.file entryconfig "Open Lichess Tournament*" -state normal}
  
  if {[llength $tournaments] == 0} {
    tk_messageBox -icon info -type ok -title "Lichess Tournament" \
      -message "No active broadcasts found at this time."
    return
  }
  
  # Show tournament selection dialog
  ::lichess_tournament::showTournamentSelector $tournaments
}

# lichess_tournament::downloadWithHTTP
#   Download using Tcl http package (fallback)
#
proc ::lichess_tournament::downloadWithHTTP {url file} {
  package require http
  if {[catch {package require tls} tlsErr]} {
    error "Tcl TLS support is unavailable: $tlsErr"
  }
  
  http::register https 443 [list ::tls::socket -autoservername true]
  
  if {[catch {
    set fd [open $file wb]
    set token [http::geturl $url \
      -channel $fd \
      -timeout 120000]
    close $fd
    
    set ncode [http::ncode $token]
    http::cleanup $token
    
    if {$ncode != 200} {
      error "HTTP download failed with status: $ncode"
    }
  } err]} {
    catch {close $fd}
    error "HTTP download error: $err"
  }
}

# lichess_tournament::parseBroadcasts
#   Extract tournament links and titles from HTML
#   Returns list of {title url}
#
proc ::lichess_tournament::parseBroadcasts {htmlFile} {
  set fd [open $htmlFile r]
  fconfigure $fd -encoding utf-8
  set html [read $fd]
  close $fd
  
  set tournaments {}
  
  # Look for broadcast links: https://lichess.org/broadcast/...
  # Pattern: href="https://lichess.org/broadcast/[^/]+/[^/]+/[a-zA-Z0-9]+"
  set pattern {href="(https://lichess\.org/broadcast/[^/"]+/[^/"]+/[a-zA-Z0-9]+)"}
  
  # Extract all matches
  set matches [regexp -all -inline $pattern $html]
  
  foreach {full url} $matches {
    # Extract tournament name from title attribute or data nearby
    # For now, use the last segment of the URL as a fallback title
    set parts [split $url "/"]
    set name [lindex $parts end-2]
    set name [string map {- { }} $name]
    set name [string totitle $name]
    
    # Check if we already have this tournament
    set found 0
    foreach {existing_name existing_url} $tournaments {
      if {$existing_url eq $url} {
        set found 1
        break
      }
    }
    if {!$found} {
      lappend tournaments $name $url
    }
  }
  
  return $tournaments
}

# lichess_tournament::showTournamentSelector
#   Display a listbox dialog for selecting which tournament to open
#
proc ::lichess_tournament::showTournamentSelector {tournaments} {
  set w .tournamentSelectorDialog
  if {[winfo exists $w]} {
    destroy $w
  }
  
  toplevel $w
  wm title $w "Select Lichess Tournament"
  wm resizable $w 1 1
  setWinLocation $w
  
  ttk::frame $w.top -padding {10 10}
  ttk::label $w.top.lbl -text "Available Broadcasts:" -font {TkDefaultFont 10 bold}
  pack $w.top.lbl -anchor w
  pack $w.top -fill x -padx 10 -pady {10 5}
  
  # Create listbox with scrollbar
  ttk::frame $w.list_frame
  listbox $w.list_frame.listbox -height 15 -width 60 -yscrollcommand "$w.list_frame.scrollbar set"
  ttk::scrollbar $w.list_frame.scrollbar -orient vertical -command "$w.list_frame.listbox yview"
  
  grid $w.list_frame.listbox -row 0 -column 0 -sticky nsew
  grid $w.list_frame.scrollbar -row 0 -column 1 -sticky ns
  grid columnconfigure $w.list_frame 0 -weight 1
  grid rowconfigure $w.list_frame 0 -weight 1
  
  pack $w.list_frame -fill both -expand 1 -padx 10 -pady 5
  
  # Populate listbox with tournament names
  set idx 0
  foreach {name url} $tournaments {
    $w.list_frame.listbox insert end $name
    $w.list_frame.listbox itemconfigure $idx -selectmode extended
    incr idx
  }
  
  # Store the tournament list in the widget
  $w.list_frame.listbox configure -listvariable ::tournamentList_$w
  set ::tournamentList_$w $tournaments
  
  # Buttons
  ttk::frame $w.buttons -padding {10 10}
  ttk::button $w.buttons.ok -text "Open Tournament" \
    -command "::lichess_tournament::selectTournament $w"
  ttk::button $w.buttons.cancel -text "Cancel" \
    -command "destroy $w"
  pack $w.buttons.ok $w.buttons.cancel -side left -padx 5
  pack $w.buttons -fill x
  
  # Bind double-click to OK
  bind $w.list_frame.listbox <Double-Button-1> "::lichess_tournament::selectTournament $w"
  bind $w <Escape> "destroy $w"
  
  focus $w.list_frame.listbox
}

# lichess_tournament::selectTournament
#   Handle tournament selection from the dialog
#
proc ::lichess_tournament::selectTournament {w} {
  set selection [$w.list_frame.listbox curselection]
  if {[llength $selection] == 0} {
    tk_messageBox -icon warning -type ok -title "Selection Required" \
      -message "Please select a tournament."
    return
  }
  
  set idx [lindex $selection 0]
  set tournaments [set ::tournamentList_$w]
  set url [lindex $tournaments [expr {$idx * 2 + 1}]]
  set name [lindex $tournaments [expr {$idx * 2}]]
  
  destroy $w
  
  # Store tournament info and start download
  set ::lichess_tournament::currentTournamentUrl $url
  set ::lichess_tournament::currentTournamentPgnUrl "${url}.pgn"
  
  ::lichess_tournament::downloadTournamentGames $name $url
}

# lichess_tournament::downloadTournamentGames
#   Download the tournament PGN file and open in Games List
#
proc ::lichess_tournament::downloadTournamentGames {name url} {
  if {$::lichess_tournament::downloading} {
    tk_messageBox -icon warning -type ok -title "Lichess Tournament" \
      -message "A download is already in progress. Please wait."
    return
  }
  
  set ::lichess_tournament::downloading 1
  catch {.menu.file entryconfig "Open Lichess Tournament*" -state disabled}
  
  set pgnUrl "${url}.pgn"
  set pgnFile [file join $::lichess_tournament::tempDir "tournament.pgn"]
  
  # Download the PGN file
  if {[catch {
    if {[auto_execok curl] ne ""} {
      exec curl -L -s -o "$pgnFile" "$pgnUrl" 2>@1
    } elseif {[auto_execok wget] ne ""} {
      exec wget -q -O "$pgnFile" "$pgnUrl" 2>@1
    } elseif {[info exists ::windowsOS] && $::windowsOS && [auto_execok powershell] ne ""} {
      exec powershell -NoLogo -NoProfile -Command "Invoke-WebRequest -Uri '$pgnUrl' -OutFile '$pgnFile'" 2>@1
    } else {
      ::lichess_tournament::downloadWithHTTP $pgnUrl $pgnFile
    }
  } err]} {
    set ::lichess_tournament::downloading 0
    catch {.menu.file entryconfig "Open Lichess Tournament*" -state normal}
    tk_messageBox -icon error -type ok -title "Lichess Tournament Error" \
      -message "Error downloading tournament games:\n$err"
    return
  }
  
  if {![file exists $pgnFile] || [file size $pgnFile] == 0} {
    set ::lichess_tournament::downloading 0
    catch {.menu.file entryconfig "Open Lichess Tournament*" -state normal}
    tk_messageBox -icon error -type ok -title "Lichess Tournament Error" \
      -message "Downloaded file is empty or missing"
    return
  }
  
  set ::lichess_tournament::downloading 0
  catch {.menu.file entryconfig "Open Lichess Tournament*" -state normal}
  
  # Mark tournament mode as active
  set ::lichess_tournament::tournamentModeActive 1
  
  # Open the PGN file in Games List
  if {[catch {
    ::file::Open $pgnFile
    
    tk_messageBox -icon info -type ok -title "Lichess Tournament Loaded" \
      -message "Tournament '$name' loaded successfully.\n\nOpen a game to begin live monitoring."
  } err]} {
    set ::lichess_tournament::tournamentModeActive 0
    tk_messageBox -icon error -type ok -title "Error" \
      -message "Error opening tournament games:\n$err"
  }
}

# lichess_tournament::onGameOpened
#   Hook called when a game is opened in the PGN window
#   Determines if the game is live and starts polling if needed
#
proc ::lichess_tournament::onGameOpened {} {
  # Only monitor if in tournament mode
  if {!$::lichess_tournament::tournamentModeActive} {
    return
  }
  
  # Get the current game's headers
  set gameUrl [sc_game tags get GameURL ""]
  set result [sc_game tags get Result "*"]
  
  # Only monitor if this is a live game from a Lichess broadcast
  if {$gameUrl eq "" || ![string match "https://lichess.org/broadcast/*" $gameUrl]} {
    return
  }
  
  # Only monitor if the game is still ongoing
  if {$result ne "*"} {
    return
  }
  
  # Stop any existing timer for this window
  ::lichess_tournament::stopGamePolling
  
  # Start monitoring this game
  ::lichess_tournament::startGamePolling $gameUrl
}

# lichess_tournament::startGamePolling
#   Start a 3-minute polling timer for a live game
#
proc ::lichess_tournament::startGamePolling {gameUrl} {
  set gameId [::lichess_tournament::extractGameId $gameUrl]
  
  # Extract study ID and chapter ID from broadcast URL
  # Format: https://lichess.org/broadcast/ii-memorial-antonio-moura/part-1/k8hhD94x/7TIYwcrU
  # Last two segments: k8hhD94x / 7TIYwcrU
  set parts [split $gameUrl "/"]
  if {[llength $parts] >= 2} {
    set chapterId [lindex $parts end]
    set studyId [lindex $parts end-1]
  } else {
    return
  }
  
  # Build the study URL
  set studyUrl "https://lichess.org/study/${studyId}/${chapterId}.pgn"
  
  # Store game data
  dict set ::lichess_tournament::gamePollingData gameUrl $gameUrl
  dict set ::lichess_tournament::gamePollingData studyUrl $studyUrl
  dict set ::lichess_tournament::gamePollingData lastMoveCount 0
  
  # Get current move count
  sc_game ply
  if {[catch {
    set currentPly [sc_game ply]
    dict set ::lichess_tournament::gamePollingData lastMoveCount [expr {$currentPly / 2}]
  }]} {
    dict set ::lichess_tournament::gamePollingData lastMoveCount 0
  }
  
  # Schedule first poll in 3 minutes
  set timerId [after 180000 ::lichess_tournament::pollGameUpdates]
  set ::lichess_tournament::liveGameTimers mainGame $timerId
}

# lichess_tournament::pollGameUpdates
#   Download and check for new moves in the live game
#
proc ::lichess_tournament::pollGameUpdates {} {
  set gamePollingData $::lichess_tournament::gamePollingData
  if {[dict size $gamePollingData] == 0} {
    return
  }
  
  set studyUrl [dict get $gamePollingData studyUrl]
  set lastMoveCount [dict get $gamePollingData lastMoveCount]
  
  # Download the current game PGN
  set tempFile [file join $::lichess_tournament::tempDir "polling_[clock seconds].pgn"]
  
  if {[catch {
    if {[auto_execok curl] ne ""} {
      exec curl -L -s -o "$tempFile" "$studyUrl" 2>@1
    } elseif {[auto_execok wget] ne ""} {
      exec wget -q -O "$tempFile" "$studyUrl" 2>@1
    } else {
      ::lichess_tournament::downloadWithHTTP $studyUrl $tempFile
    }
  } err]} {
    # Silently retry on next cycle
    ::lichess_tournament::scheduleNextPoll
    return
  }
  
  if {![file exists $tempFile]} {
    ::lichess_tournament::scheduleNextPoll
    return
  }
  
  # Parse the downloaded PGN to get moves
  if {[catch {
    set newMoves [::lichess_tournament::extractMovesFromPgn $tempFile]
  } err]} {
    catch {file delete $tempFile}
    ::lichess_tournament::scheduleNextPoll
    return
  }
  
  # Compare with current game and append new moves
  if {[llength $newMoves] > $lastMoveCount} {
    set movesToAdd [lrange $newMoves $lastMoveCount end]
    
    if {[catch {
      foreach move $movesToAdd {
        sc_move add $move
      }
      dict set ::lichess_tournament::gamePollingData lastMoveCount [llength $newMoves]
    } err]} {
      # Error adding moves; continue polling
    }
  }
  
  # Check if game is finished
  set result [sc_game tags get Result "*"]
  if {$result ne "*"} {
    # Game is finished, stop polling
    ::lichess_tournament::stopGamePolling
    catch {file delete $tempFile}
    return
  }
  
  catch {file delete $tempFile}
  
  # Schedule next poll
  ::lichess_tournament::scheduleNextPoll
}

# lichess_tournament::scheduleNextPoll
#   Schedule the next polling cycle (3 minutes)
#
proc ::lichess_tournament::scheduleNextPoll {} {
  set timerId [after 180000 ::lichess_tournament::pollGameUpdates]
  set ::lichess_tournament::liveGameTimers mainGame $timerId
}

# lichess_tournament::stopGamePolling
#   Cancel the polling timer
#
proc ::lichess_tournament::stopGamePolling {} {
  if {[dict exists $::lichess_tournament::liveGameTimers mainGame]} {
    set timerId [dict get $::lichess_tournament::liveGameTimers mainGame]
    catch {after cancel $timerId}
    dict unset ::lichess_tournament::liveGameTimers mainGame
  }
  dict set ::lichess_tournament::gamePollingData {}
}

# lichess_tournament::extractGameId
#   Extract the game ID from a Lichess broadcast game URL
#
proc ::lichess_tournament::extractGameId {url} {
  set parts [split $url "/"]
  return [lindex $parts end]
}

# lichess_tournament::extractMovesFromPgn
#   Parse a PGN file and extract the move list
#   Returns a list of moves in algebraic notation
#
proc ::lichess_tournament::extractMovesFromPgn {pgnFile} {
  set fd [open $pgnFile r]
  fconfigure $fd -encoding utf-8
  set content [read $fd]
  close $fd
  
  set moves {}
  
  # Find the moves section (after headers, starts with first move)
  # Look for the mainline moves
  set lines [split $content "\n"]
  set inMoves 0
  set moveText ""
  
  foreach line $lines {
    set trimmed [string trim $line]
    
    # Skip header lines (they start with [)
    if {[string match "\[*" $trimmed]} {
      continue
    }
    
    # Skip empty lines
    if {$trimmed eq ""} {
      continue
    }
    
    # This should be move text
    append moveText " $trimmed"
  }
  
  # Parse moves from moveText
  # Simple regex: match move patterns like 1.e4, e5, Nf3, etc.
  # Remove move numbers and periods
  set moveText [regsub -all {\d+\.} $moveText ""]
  
  # Remove variations (parentheses content) and comments
  set moveText [regsub -all {\([^)]*\)} $moveText ""]
  set moveText [regsub -all "\\{\\[^\}\\]*\\}" $moveText ""]
  
  # Split into tokens and filter out non-move tokens
  set tokens [split $moveText]
  foreach token $tokens {
    set token [string trim $token]
    if {$token ne "" && ![string match "*-*" $token]} {
      lappend moves $token
    }
  }
  
  return $moves
}

# Initialize: Nothing to do at load time

