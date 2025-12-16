######################################################################
#
# lichess_tournament.tcl: Monitor live Lichess tournament broadcasts
#
# Downloads and displays live tournament games from Lichess broadcasts,
# with automatic polling of ongoing games every minute.
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
  # Verbose logging toggle (set to 1 to enable)
  variable verbose 0
}

# Internal helper to log when verbose is enabled
proc ::lichess_tournament::vlog {msg} {
  if {[info exists ::lichess_tournament::verbose] && $::lichess_tournament::verbose} {
    puts $msg
  }
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
      -message "No active broadcasts found at this time.\n\nPlease check:\n• Internet connection is active\n• Lichess.org is accessible\n• There are active broadcasts at lichess.org/broadcast"
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
  set seen_urls {}
  
  # Look for broadcast links: href="/broadcast/tournament/round/id"
  # Pattern: <a href="/broadcast/...">
  set pattern {href="/broadcast/([^"]+)"}
  
  # Extract all matches
  set matches [regexp -all -inline $pattern $html]
  
  ::lichess_tournament::vlog "Found [expr {[llength $matches] / 2}] broadcast links"
  
  foreach {full path} $matches {
    # path is like: tournament-name/round-name/id
    # We need to extract the full path up to the chapter ID
    set parts [split $path "/"]
    
    # Validate we have at least 3 parts (tournament/round/id)
    if {[llength $parts] < 3} {
      continue
    }
    
    # Get the last part (chapter ID) - should be alphanumeric
    set id [lindex $parts end]
    if {![string match {[a-zA-Z0-9]*} $id]} {
      continue
    }
    
    # Reconstruct the full broadcast URL
    set url "https://lichess.org/broadcast/${path}"
    
    # Check for duplicates by URL
    if {[lsearch $seen_urls $url] != -1} {
      continue
    }
    lappend seen_urls $url
    
    # Extract tournament name from the path
    # Format: /tournament-name/round-name/id
    # Use tournament-name (first part)
    set tournament_name [lindex $parts 0]
    set tournament_name [string map {- { }} $tournament_name]
    set tournament_name [string trim $tournament_name]
    set tournament_name [string totitle $tournament_name]
    # Filter out junk titles (numeric-only, very short tokens, common noise like "Vs")
    if {[string length $tournament_name] < 3} { continue }
    if {[regexp {^[0-9]+$} $tournament_name]} { continue }
    if {[string equal -nocase $tournament_name "Vs"]} { continue }
    
    ::lichess_tournament::vlog "Adding: $tournament_name -> $url"
    lappend tournaments $tournament_name $url
  }
  
  ::lichess_tournament::vlog "Parsed [expr {[llength $tournaments] / 2}] unique tournaments"
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
  listbox $w.list_frame.listbox -height 15 -width 60 -selectmode single \
    -yscrollcommand "$w.list_frame.scrollbar set"
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
    incr idx
  }
  
  # Store the tournament list in the widget
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
  ::lichess_tournament::vlog "onGameOpened called, tournamentModeActive=$::lichess_tournament::tournamentModeActive"
  
  # Only monitor if in tournament mode
  if {!$::lichess_tournament::tournamentModeActive} {
    ::lichess_tournament::vlog "Not in tournament mode, skipping"
    return
  }
  
  # Get the current game's headers
  ::lichess_tournament::vlog "About to fetch game tags..."
  set gameUrl ""
  set result "*"
  
  # Try to get the game URL from the Site tag (Lichess PGN format)
  if {[catch {
    set gameUrl [sc_game tags get Site]
  } err]} {
    ::lichess_tournament::vlog "Site tag not found or error: $err"
    set gameUrl ""
  }
  
  if {[catch {
    set result [sc_game tags get Result]
  } err]} {
    ::lichess_tournament::vlog "Result tag not found, assuming ongoing: $err"
    set result "*"
  }
  
  ::lichess_tournament::vlog "Game Site/URL: $gameUrl, Result: $result"
  
  # Only monitor if this is a live game from a Lichess broadcast
  if {$gameUrl eq "" || ![string match "https://lichess.org/broadcast/*" $gameUrl]} {
    ::lichess_tournament::vlog "Not a Lichess broadcast URL, skipping"
    return
  }
  
  # Only monitor if the game is still ongoing
  if {$result ne "*"} {
    ::lichess_tournament::vlog "Game is not ongoing (result=$result), skipping"
    return
  }
  
  ::lichess_tournament::vlog "Starting to monitor live game: $gameUrl"
  
  # Stop any existing timer for this window
  ::lichess_tournament::stopGamePolling
  
  ::lichess_tournament::vlog "About to call startGamePolling..."
  # Start monitoring this game
  ::lichess_tournament::startGamePolling $gameUrl
  ::lichess_tournament::vlog "startGamePolling returned successfully"
}

# lichess_tournament::startGamePolling
#   Start a 30-second polling timer for a live game (for testing)
#
proc ::lichess_tournament::startGamePolling {gameUrl} {
  if {[catch {
    ::lichess_tournament::vlog "startGamePolling called with URL: $gameUrl"
    
    set gameId [::lichess_tournament::extractGameId $gameUrl]
    
    # Extract study ID and chapter ID from broadcast URL
    # Format: https://lichess.org/broadcast/ii-memorial-antonio-moura/part-1/k8hhD94x/7TIYwcrU
    # Last two segments: k8hhD94x / 7TIYwcrU
    set parts [split $gameUrl "/"]
    ::lichess_tournament::vlog "URL has [llength $parts] parts"
    
    if {[llength $parts] >= 2} {
      set chapterId [lindex $parts end]
      set studyId [lindex $parts end-1]
      ::lichess_tournament::vlog "Extracted studyId=$studyId, chapterId=$chapterId"
    } else {
      ::lichess_tournament::vlog "Could not extract study/chapter IDs from URL: $gameUrl"
      return
    }
    
    # Build the study URL
    set studyUrl "https://lichess.org/study/${studyId}/${chapterId}.pgn"
    # Start polling for study URL
    ::lichess_tournament::vlog "Polling study URL: $studyUrl"
    
    # Store game data
    dict set ::lichess_tournament::gamePollingData gameUrl $gameUrl
    dict set ::lichess_tournament::gamePollingData studyUrl $studyUrl
    dict set ::lichess_tournament::gamePollingData lastMoveCount 0
    # Stored polling data
    
    # Get current move count by downloading the initial PGN and counting
    # Get initial move count
    if {[catch {
      set tempInitial [file join $::lichess_tournament::tempDir "initial_[clock seconds].pgn"]
      if {[auto_execok curl] ne ""} {
        exec curl -L -s -o "$tempInitial" $studyUrl 2>@1
      } elseif {[auto_execok wget] ne ""} {
        exec wget -q -O "$tempInitial" $studyUrl 2>@1
      } else {
        ::lichess_tournament::downloadWithHTTP $studyUrl $tempInitial
      }
      if {[file exists $tempInitial]} {
        set initialMoves [::lichess_tournament::extractMovesFromPgn $tempInitial]
        set moveCount [llength $initialMoves]
        catch {file delete $tempInitial}
      } else {
        set moveCount 0
      }
      dict set ::lichess_tournament::gamePollingData lastMoveCount $moveCount
    } err]} {
      # Error getting initial move count; default to 0
      dict set ::lichess_tournament::gamePollingData lastMoveCount 0
    }
    
    # Schedule first poll in 60 seconds (1 minute)
    set timerId [after 60000 ::lichess_tournament::pollGameUpdates]
    dict set ::lichess_tournament::liveGameTimers mainGame $timerId
    ::lichess_tournament::vlog "Scheduled first poll in 60s"
  } err]} {
    # Error starting game polling; keep app responsive
  }
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
  ::lichess_tournament::vlog "Poll tick. Last count=$lastMoveCount"
  
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
    # Error downloading PGN; silently retry next cycle
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
    # Error parsing PGN; retry next cycle
    catch {file delete $tempFile}
    ::lichess_tournament::scheduleNextPoll
    return
  }
  
  # Compare with current game and append new moves
  if {[llength $newMoves] > $lastMoveCount} {
    set movesToAdd [lrange $newMoves $lastMoveCount end]
    ::lichess_tournament::vlog "Found new moves: $movesToAdd"
    
    # Double-check: filter out any result markers that might have slipped through
    set cleanMoves {}
    foreach move $movesToAdd {
      if {$move ne "*" && $move ne "1-0" && $move ne "0-1" && $move ne "1/2-1/2"} {
        lappend cleanMoves $move
      }
    }
    
    if {[llength $cleanMoves] > 0} {
      if {[catch {
        # Navigate to the end of the game before adding moves
        sc_move end
        foreach move $cleanMoves {
          sc_move addSan $move
        }
        dict set ::lichess_tournament::gamePollingData lastMoveCount [llength $newMoves]
        # Update the display
        ::pgn::Refresh 1
      } err]} {
        # Error adding moves; continue polling
        ::lichess_tournament::vlog "Error adding moves: $err"
      }
    }
  } else {
    # No new moves
  }
  
  # Check if game is finished
  set result "*"
  if {[catch {
    set result [sc_game tags get Result]
  } err]} {
    # Assume game is still ongoing if we can't get the Result tag
    set result "*"
  }
  
  if {$result ne "*"} {
    # Game is finished, stop polling
    ::lichess_tournament::stopGamePolling
    catch {file delete $tempFile}
    ::lichess_tournament::vlog "Game finished with result: $result"
    return
  }
  
  catch {file delete $tempFile}
  
  # Schedule next poll
  ::lichess_tournament::scheduleNextPoll
  ::lichess_tournament::vlog "Scheduled next poll in 180s"
}

# lichess_tournament::scheduleNextPoll
#   Schedule the next polling cycle (30 seconds for testing)
#
proc ::lichess_tournament::scheduleNextPoll {} {
  set timerId [after 60000 ::lichess_tournament::pollGameUpdates]
  dict set ::lichess_tournament::liveGameTimers mainGame $timerId
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
  set ::lichess_tournament::gamePollingData {}
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
  
  # Build move text by skipping PGN headers
  set moveText ""
  foreach line [split $content "\n"] {
    set t [string trim $line]
    if {$t eq ""} { continue }
    # Skip header lines (those starting with [)
    if {[string index $t 0] eq "\["} { continue }
    append moveText " $t"
  }

  # Remove clock annotations {...} using string range approach
  set cleaned ""
  set len [string length $moveText]
  set i 0
  while {$i < $len} {
    set ch [string index $moveText $i]
    if {$ch eq "\{"} {
      # Skip until we find closing brace
      incr i
      while {$i < $len && [string index $moveText $i] ne "\}"} {
        incr i
      }
    } else {
      append cleaned $ch
    }
    incr i
  }
  
  # Remove move numbers (like "1.", "2.", etc.)
  set out [regsub -all {\d+\.} $cleaned ""]
  
  # Remove extra spaces and trim
  set out [string map [list "  " " "] $out]
  set out [string trim $out]

  # Tokenize and collect SAN moves
  set moves {}
  foreach token [split $out] {
    set tok [string trim $token]
    if {$tok eq ""} { continue }
    # Skip result markers - check each explicitly
    if {$tok eq "*" || $tok eq "1-0" || $tok eq "0-1" || $tok eq "1/2-1/2"} { continue }
    # Skip pure numbers (move numbers that slipped through)
    if {[regexp {^[0-9]+$} $tok]} { continue }
    # Skip tokens that are just dots
    if {[regexp {^\.+$} $tok]} { continue }
    lappend moves $tok
  }

  close $fd
  return $moves
}

# Initialize: Nothing to do at load time

