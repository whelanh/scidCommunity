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
  variable refreshInterval 60000
  variable autoUpdateBoard 1
  variable isPaused 0
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

  ttk::frame $w.options -padding {10 10}
  ttk::label $w.options.lbl -text "Refresh interval (>9 seconds):"
  ttk::entry $w.options.ent -width 5
  $w.options.ent insert 0 "60"
  
  pack $w.options.lbl $w.options.ent -side left -padx 5
  pack $w.options -fill x
  
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
  
  set interval [$w.options.ent get]
  if {![string is integer -strict $interval] || $interval <= 9} {
    tk_messageBox -icon error -type ok -title "Invalid Interval" \
      -message "Refresh interval must be an integer greater than 9 seconds."
    return
  }
  set ::lichess_tournament::refreshInterval [expr {$interval * 1000}]
  
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
  
  # create a safe filename from the tournament name (first 20 chars)
  set safeName [string range $name 0 19]
  # Replace characters invalid in filenames or potentially problematic
  regsub -all {[^a-zA-Z0-9\-\.\_\ ]} $safeName "_" safeName
  set safeName [string trim $safeName]
  if {$safeName eq ""} { set safeName "tournament" }
  
  set pgnFile [file join $::lichess_tournament::tempDir "${safeName}.pgn"]
  
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
  
  # Check if we are already monitoring this game to prevent infinite loops
  # (sc_move end and sc_game save can trigger updates that call this hook again)
  if {[dict exists $::lichess_tournament::gamePollingData gameUrl] && \
      [dict get $::lichess_tournament::gamePollingData gameUrl] eq $gameUrl} {
    ::lichess_tournament::vlog "Already monitoring this game, skipping initialization"
    return
  }
  
  # Stop any existing timer for this window
  ::lichess_tournament::stopGamePolling
  
  ::lichess_tournament::vlog "About to call startGamePolling..."
  # Start monitoring this game
  ::lichess_tournament::startGamePolling $gameUrl
  ::lichess_tournament::vlog "startGamePolling returned successfully"
  
  # Auto-jump to the end of the game
  sc_move end
  ::notify::PosChanged -pgn
}

# lichess_tournament::getGameMoves
#   Extract all mainline moves from the current game as SAN strings
#   Returns a list of {move comment} pairs
#
proc ::lichess_tournament::getGameMoves {} {
  set moves {}
  
  # Save current position
  set savedPly [sc_pos location]
  
  # Go to start
  sc_move start
  
  # Walk through the mainline collecting moves
  while {![sc_pos isAt vend]} {
    sc_move forward
    set move [sc_game info previous]
    set comment [sc_pos getComment]
    lappend moves [list $move $comment]
  }
  
  # Restore position
  catch {sc_move ply $savedPly}
  
  return $moves
}

# lichess_tournament::findLastCommonMove
#   Compare current game moves with downloaded PGN moves
#   Returns the ply number where they last match, or -1 if they never diverge
#
proc ::lichess_tournament::findLastCommonMove {downloadedMoves} {
  # Get current game moves
  set currentMoves [::lichess_tournament::getGameMoves]
  
  set lastCommonPly 0
  set minLen [expr {min([llength $currentMoves], [llength $downloadedMoves])}]
  
  for {set i 0} {$i < $minLen} {incr i} {
    set currentMove [lindex [lindex $currentMoves $i] 0]
    set downloadedMove [lindex [lindex $downloadedMoves $i] 0]
    
    if {$currentMove eq $downloadedMove} {
      set lastCommonPly [expr {$i + 1}]
    } else {
      # Found divergence point
      ::lichess_tournament::vlog "Divergence at ply $i: current='$currentMove' vs downloaded='$downloadedMove'"
      return $lastCommonPly
    }
  }
  
  # If we got here, all compared moves match
  # Return -1 to indicate no divergence in the compared range
  return -1
}

# lichess_tournament::demoteUserMovesToVariation
#   Demote user-added moves to a variation and prepare for new mainline
#   Takes the ply number of the last common move
#   Returns 1 on success, 0 on failure
#
proc ::lichess_tournament::demoteUserMovesToVariation {lastCommonPly} {
  if {[catch {
    ::lichess_tournament::vlog "Demoting user moves from ply $lastCommonPly"
    
    # Navigate to end to see what we're demoting
    sc_move end
    set endPly [sc_pos location]
    
    ::lichess_tournament::vlog "Current end is at ply $endPly"
    
    # If we're already at the common position, nothing to demote
    if {$endPly <= $lastCommonPly} {
      ::lichess_tournament::vlog "Nothing to demote"
      return 1
    }
    
    # Collect the user moves that need to be preserved
    set userMoves {}
    sc_move ply $lastCommonPly
    
    while {![sc_pos isAt vend]} {
      sc_move forward
      set moveUCI [sc_game info previousMoveUCI]
      set moveSAN [sc_game info previousMoveNT]
      set comment [sc_pos getComment]
      ::lichess_tournament::vlog "Collecting user move: UCI='$moveUCI', SAN='$moveSAN'"
      
      # Prefer SAN for adding later
      set move $moveSAN
      if {$move eq "" && $moveUCI ne ""} {
        set move $moveUCI
      }
      lappend userMoves [list $move $comment]
    }
    
    ::lichess_tournament::vlog "Collected [llength $userMoves] user moves"
    
    # Navigate back to last common position and truncate
    sc_move ply $lastCommonPly
    ::lichess_tournament::vlog "Truncating from ply $lastCommonPly"
    sc_game truncate
    
    # Save the game to commit the truncation
    ::lichess_tournament::vlog "Saving game after truncate"
    catch {sc_game save [sc_game number] [sc_base current]}
    
    # Save user moves as a comment at the divergence point
    if {[llength $userMoves] > 0} {
      ::lichess_tournament::vlog "Saving [llength $userMoves] user moves as comment"
      
      # Build a comment with the user's moves including move numbers
      set userMovesComment "Your analysis: "
      
      # Calculate the starting move number based on the ply
      # Move number = (ply + 1) / 2, rounded up
      set startingMoveNumber [expr {($lastCommonPly + 1 + 1) / 2}]
      
      # Determine if first move is White's or Black's
      # If ply is even, next move is White; if odd, next move is Black
      set isWhiteMove [expr {($lastCommonPly % 2) == 0}]
      
      set moveList {}
      set moveNumber $startingMoveNumber
      set whiteMove $isWhiteMove
      
      foreach moveEntry $userMoves {
        set move [lindex $moveEntry 0]
        
        if {$whiteMove} {
          # White's move: show full move number
          lappend moveList "${moveNumber}.${move}"
          set whiteMove 0
        } else {
          # Black's move: show move number with ...
          lappend moveList "${moveNumber}...${move}"
          set whiteMove 1
          incr moveNumber
        }
      }
      
      append userMovesComment [join $moveList " "]
      
      # Add the comment at the current position (after truncate)
      set existingComment [sc_pos getComment]
      if {$existingComment ne ""} {
        sc_pos setComment "$existingComment\n$userMovesComment"
      } else {
        sc_pos setComment $userMovesComment
      }
      
      ::lichess_tournament::vlog "Added user moves as comment: $userMovesComment"
    }
    
    # Save the game to persist the changes
    catch {sc_game save [sc_game number] [sc_base current]}
    
    ::lichess_tournament::vlog "Successfully demoted user moves to variation"
    return 1
    
  } err]} {
    ::lichess_tournament::vlog "ERROR in demoteUserMovesToVariation: $err"
    return 0
  }
}

# lichess_tournament::updateGameFromPgn
#   Download the latest PGN and update the current game with any new moves
#   Returns the new move count, or -1 on error
#
proc ::lichess_tournament::updateGameFromPgn {studyUrl lastMoveCount} {
  # puts "DEBUG: updateGameFromPgn called with studyUrl=$studyUrl, lastMoveCount=$lastMoveCount"
  set tempFile [file join $::lichess_tournament::tempDir "update_[clock seconds].pgn"]
  # puts "DEBUG: Temp file will be: $tempFile"
  
  # Download the current game PGN
  if {[catch {
    if {[auto_execok curl] ne ""} {
      # puts "DEBUG: Using curl to download"
      exec curl -L -s -o "$tempFile" "$studyUrl" 2>@1
    } elseif {[auto_execok wget] ne ""} {
      # puts "DEBUG: Using wget to download"
      exec wget -q -O "$tempFile" "$studyUrl" 2>@1
    } else {
      # puts "DEBUG: Using downloadWithHTTP"
      ::lichess_tournament::downloadWithHTTP $studyUrl $tempFile
    }
  } err]} {
    # puts "DEBUG: Error downloading PGN: $err"
    return -1
  }
  
  if {![file exists $tempFile]} {
    # puts "DEBUG: PGN file was not created"
    return -1
  }
  
  # puts "DEBUG: PGN file downloaded successfully, size: [file size $tempFile]"
  
  # Parse the downloaded PGN to get moves
  if {[catch {
    set newMoves [::lichess_tournament::extractMovesFromPgn $tempFile]
  } err]} {
    # puts "DEBUG: Error parsing PGN: $err"
    catch {file delete $tempFile}
    return -1
  }
  
  catch {file delete $tempFile}
  
  set totalMoveCount [llength $newMoves]
  ::lichess_tournament::vlog "Parsed $totalMoveCount moves from downloaded PGN"
  
  # Check for divergence between current game and downloaded PGN
  set divergencePly [::lichess_tournament::findLastCommonMove $newMoves]
  
  if {$divergencePly >= 0 && $divergencePly < $totalMoveCount} {
    # Divergence detected - user has added moves
    ::lichess_tournament::vlog "Detected divergence at ply $divergencePly"
    
    # Demote user moves to a variation
    if {[::lichess_tournament::demoteUserMovesToVariation $divergencePly]} {
      ::lichess_tournament::vlog "Successfully demoted user moves"
      
      # Now add the real moves from the downloaded PGN, starting after the divergence point
      set movesToAdd [lrange $newMoves $divergencePly end]
      ::lichess_tournament::vlog "Adding [llength $movesToAdd] real moves from ply $divergencePly"
      
      # Navigate to the divergence point (which is now the end after truncation)
      sc_move ply $divergencePly
      
      set addedCount 0
      foreach item $movesToAdd {
        set move [lindex $item 0]
        set comment [lindex $item 1]
        
        if {[catch {sc_move addSan $move} result]} {
          ::lichess_tournament::vlog "ERROR adding real move $move: $result"
          break
        } else {
          incr addedCount
          
          # Add comment if present
          if {$comment ne ""} {
            catch {sc_pos setComment $comment}
          }
        }
      }
      
      # Auto-save the game
      catch {sc_game save [sc_game number] [sc_base current]}
      
      # Update the display
      if {$::lichess_tournament::autoUpdateBoard} {
        sc_move end
        ::notify::PosChanged -pgn
      } else {
        ::pgn::Refresh 1
      }
      
      ::lichess_tournament::vlog "Added $addedCount moves after resolving divergence"
      return $totalMoveCount
    } else {
      ::lichess_tournament::vlog "Failed to demote user moves"
      return -1
    }
  }
  
  # No divergence - add any new moves that aren't in the current game
  if {$totalMoveCount > $lastMoveCount} {
    set movesToAdd [lrange $newMoves $lastMoveCount end]
    ::lichess_tournament::vlog "Found [llength $movesToAdd] new moves to add"
    
    if {[llength $movesToAdd] > 0} {
      # Navigate to the end of the game before adding moves
      sc_move end
      
      set addedCount 0
      foreach item $movesToAdd {
        set move [lindex $item 0]
        set comment [lindex $item 1]
        
        if {[catch {sc_move addSan $move} result]} {
          ::lichess_tournament::vlog "ERROR adding move $move: $result"
          # This shouldn't happen in normal flow, but if it does, it might indicate
          # a divergence we didn't detect. Try to handle it gracefully.
          ::lichess_tournament::vlog "Possible undetected divergence - attempting recovery"
          
          # Check if there's a divergence we missed
          set recoveryPly [::lichess_tournament::findLastCommonMove $newMoves]
          if {$recoveryPly >= 0 && $recoveryPly < $totalMoveCount} {
            ::lichess_tournament::vlog "Recovery: found divergence at ply $recoveryPly"
            if {[::lichess_tournament::demoteUserMovesToVariation $recoveryPly]} {
              # Retry adding from the correct position
              sc_move ply $recoveryPly
              set movesToAdd [lrange $newMoves $recoveryPly end]
              set addedCount 0
              foreach item $movesToAdd {
                set move [lindex $item 0]
                set comment [lindex $item 1]
                if {[catch {sc_move addSan $move}]} {
                  break
                } else {
                  incr addedCount
                  if {$comment ne ""} {
                    catch {sc_pos setComment $comment}
                  }
                }
              }
            }
          }
          break
        } else {
          incr addedCount
          
          # Add comment if present
          if {$comment ne ""} {
            catch {sc_pos setComment $comment}
          }
        }
      }
      
      # Auto-save the game to ensure updates are visible
      catch {sc_game save [sc_game number] [sc_base current]}
      
      if {$addedCount == 0} {
        ::lichess_tournament::vlog "Failed to add any moves"
        return -1
      }
      
      # Update the display
      if {$::lichess_tournament::autoUpdateBoard} {
        sc_move end
        ::notify::PosChanged -pgn
      } else {
        ::pgn::Refresh 1
      }
      # puts "DEBUG: Successfully added $addedCount moves and refreshed display"
    } else {
      # puts "DEBUG: No clean moves to add (all were result markers)"
    }
  } else {
    # puts "DEBUG: No new moves (totalMoveCount=$totalMoveCount, lastMoveCount=$lastMoveCount)"
  }
  
  # puts "DEBUG: Returning totalMoveCount=$totalMoveCount"
  return $totalMoveCount
}

# lichess_tournament::startGamePolling
#   Start polling timer for a live game and immediately update it
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
    ::lichess_tournament::vlog "Study URL: $studyUrl"
    
    # Store game data
    dict set ::lichess_tournament::gamePollingData gameUrl $gameUrl
    dict set ::lichess_tournament::gamePollingData studyUrl $studyUrl
    
    # Get the current move count in the open game
    # This is the number of moves already loaded from the tournament PGN
    set currentMoveCount 0
    if {[catch {
      # Navigate to end and get ply count
      sc_move end
      set moveNum [sc_pos moveNumber]
      set side [sc_pos side]
      # Convert to ply: if white to move, ply = (moveNum * 2) - 1, if black, ply = moveNum * 2
      if {$side eq "white"} {
        set currentMoveCount [expr {$moveNum * 2 - 2}]
      } else {
        set currentMoveCount [expr {$moveNum * 2 - 1}]
      }
      # puts "DEBUG: Current game at move $moveNum ($side to move) = $currentMoveCount plies"
    } err]} {
      # puts "DEBUG: Error getting current move count: $err"
      set currentMoveCount 0
    }
    
    # puts "DEBUG: Will use $currentMoveCount as starting point"
    
    # Immediately fetch the latest PGN and update the game
    # puts "DEBUG: About to call updateGameFromPgn with studyUrl=$studyUrl, currentMoveCount=$currentMoveCount"
    set newMoveCount [::lichess_tournament::updateGameFromPgn $studyUrl $currentMoveCount]
    # puts "DEBUG: updateGameFromPgn returned: $newMoveCount"
    
    if {$newMoveCount == -1} {
      # Error updating; use current count
      # puts "DEBUG: Error from updateGameFromPgn, using current count"
      set newMoveCount $currentMoveCount
    }
    
    dict set ::lichess_tournament::gamePollingData lastMoveCount $newMoveCount
    # puts "DEBUG: Stored lastMoveCount=$newMoveCount"
    
    # Reset pause state for new game
    set ::lichess_tournament::isPaused 0
    ::lichess_tournament::updatePauseButton
    
    # Schedule first poll
    set timerId [after $::lichess_tournament::refreshInterval ::lichess_tournament::pollGameUpdates]
    dict set ::lichess_tournament::liveGameTimers mainGame $timerId
    # puts "DEBUG: Scheduled timer with ID: $timerId"
  } err]} {
    # puts "DEBUG: ERROR in startGamePolling: $err"
    # puts "DEBUG: Error info: $::errorInfo"
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
  
  if {$::lichess_tournament::isPaused} {
    return
  }
  
  set studyUrl [dict get $gamePollingData studyUrl]
  set lastMoveCount [dict get $gamePollingData lastMoveCount]
  ::lichess_tournament::vlog "Poll tick. Last count=$lastMoveCount"
  
  # Update the game with any new moves
  set newMoveCount [::lichess_tournament::updateGameFromPgn $studyUrl $lastMoveCount]
  
  if {$newMoveCount == -1} {
    # Error updating; retry on next cycle
    ::lichess_tournament::scheduleNextPoll
    return
  }
  
  # Update the stored move count
  if {$newMoveCount > $lastMoveCount} {
    dict set ::lichess_tournament::gamePollingData lastMoveCount $newMoveCount
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
    ::lichess_tournament::vlog "Game finished with result: $result"
    return
  }
  
  # Schedule next poll
  ::lichess_tournament::scheduleNextPoll
  ::lichess_tournament::vlog "Scheduled next poll in [expr {$::lichess_tournament::refreshInterval / 1000}]s"
}

# lichess_tournament::scheduleNextPoll
#   Schedule the next polling cycle (1 minute)
#
proc ::lichess_tournament::scheduleNextPoll {} {
  set timerId [after $::lichess_tournament::refreshInterval ::lichess_tournament::pollGameUpdates]
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
  
  # Update UI button visibility
  ::lichess_tournament::updatePauseButton
}

# lichess_tournament::isMonitoring
#   Check if we are currently monitoring a game
#
proc ::lichess_tournament::isMonitoring {} {
  return [expr {[dict size $::lichess_tournament::gamePollingData] > 0}]
}

# lichess_tournament::togglePause
#   Toggle the pause state of the live monitoring
#
proc ::lichess_tournament::togglePause {} {
  set ::lichess_tournament::isPaused [expr {!$::lichess_tournament::isPaused}]
  
  if {$::lichess_tournament::isPaused} {
    # PAUSING
    ::lichess_tournament::vlog "Pausing updates"
    
    # Cancel any pending timer
    if {[dict exists $::lichess_tournament::liveGameTimers mainGame]} {
      set timerId [dict get $::lichess_tournament::liveGameTimers mainGame]
      catch {after cancel $timerId}
      dict unset ::lichess_tournament::liveGameTimers mainGame
    }
  } else {
    # RESUMING
    ::lichess_tournament::vlog "Resuming updates"
    
    # Save the current game state first to ensure we don't lose user data
    catch {sc_game save [sc_game number] [sc_base current]}
    
    # Immediately check for updates
    set gamePollingData $::lichess_tournament::gamePollingData
    if {[dict size $gamePollingData] > 0} {
      set studyUrl [dict get $gamePollingData studyUrl]
      
      # Recalculate the current real move count from the downloaded PGN
      # We need to compare against the actual downloaded moves, not our stored count
      # because the user may have added moves during pause
      ::lichess_tournament::vlog "Recalculating game state after pause"
      
      # Download fresh PGN to see the current real state
      set tempFile [file join $::lichess_tournament::tempDir "resume_[clock seconds].pgn"]
      if {[catch {
        if {[auto_execok curl] ne ""} {
          exec curl -L -s -o "$tempFile" "$studyUrl" 2>@1
        } elseif {[auto_execok wget] ne ""} {
          exec wget -q -O "$tempFile" "$studyUrl" 2>@1
        } else {
          ::lichess_tournament::downloadWithHTTP $studyUrl $tempFile
        }
      } err] == 0 && [file exists $tempFile]} {
        
        # Parse the real moves from Lichess
        if {[catch {
          set realMoves [::lichess_tournament::extractMovesFromPgn $tempFile]
        } err] == 0} {
          
          # Find where the real game and current game diverge
          set divergencePly [::lichess_tournament::findLastCommonMove $realMoves]
          set realMoveCount [llength $realMoves]
          
          # Get current game move count
          set currentMoves [::lichess_tournament::getGameMoves]
          set currentMoveCount [llength $currentMoves]
          
          ::lichess_tournament::vlog "Resume: divergencePly=$divergencePly, realMoves=$realMoveCount, currentMoves=$currentMoveCount"
          
          # Check if there's a divergence or if user has more moves than real game
          set needsDemotion 0
          set demotionPoint $divergencePly
          
          if {$divergencePly >= 0 && $divergencePly < $realMoveCount} {
            # True divergence: moves differ at some point
            ::lichess_tournament::vlog "True divergence detected at ply $divergencePly"
            set needsDemotion 1
            set demotionPoint $divergencePly
          } elseif {$divergencePly == -1 && $currentMoveCount > $realMoveCount} {
            # User has extra moves beyond the real game (no divergence in common range)
            ::lichess_tournament::vlog "User has extra moves: current=$currentMoveCount > real=$realMoveCount"
            set needsDemotion 1
            set demotionPoint $realMoveCount
          } elseif {$divergencePly == -1 && $currentMoveCount < $realMoveCount} {
            # Real game has progressed beyond current game (need to add moves)
            ::lichess_tournament::vlog "Real game has progressed: real=$realMoveCount > current=$currentMoveCount"
            set needsDemotion 0
          } else {
            ::lichess_tournament::vlog "Games are in sync"
            set needsDemotion 0
          }
          
          if {$needsDemotion} {
            # There's a divergence or extra user moves - demote and add real moves
            ::lichess_tournament::vlog "Demoting user moves from ply $demotionPoint after resume"
            
            if {[::lichess_tournament::demoteUserMovesToVariation $demotionPoint]} {
              ::lichess_tournament::vlog "Demoted user moves, now adding real moves"
              
              # Add the real moves from the server
              set movesToAdd [lrange $realMoves $demotionPoint end]
              sc_move ply $demotionPoint
              
              set addedCount 0
              foreach item $movesToAdd {
                set move [lindex $item 0]
                set comment [lindex $item 1]
                
                if {[catch {sc_move addSan $move} result] == 0} {
                  incr addedCount
                  if {$comment ne ""} {
                    catch {sc_pos setComment $comment}
                  }
                } else {
                  ::lichess_tournament::vlog "ERROR adding move $move after resume: $result"
                  break
                }
              }
              
              # Save and refresh
              catch {sc_game save [sc_game number] [sc_base current]}
              if {$::lichess_tournament::autoUpdateBoard} {
                sc_move end
                ::notify::PosChanged -pgn
              } else {
                ::pgn::Refresh 1
              }
              
              ::lichess_tournament::vlog "Added $addedCount real moves after resume"
            }
          } elseif {$currentMoveCount < $realMoveCount} {
            # Just need to add new moves, no demotion needed
            ::lichess_tournament::vlog "Adding new moves without demotion"
            
            set movesToAdd [lrange $realMoves $currentMoveCount end]
            sc_move end
            
            set addedCount 0
            foreach item $movesToAdd {
              set move [lindex $item 0]
              set comment [lindex $item 1]
              
              if {[catch {sc_move addSan $move} result] == 0} {
                incr addedCount
                if {$comment ne ""} {
                  catch {sc_pos setComment $comment}
                }
              } else {
                ::lichess_tournament::vlog "ERROR adding move $move after resume: $result"
                break
              }
            }
            
            # Save and refresh
            catch {sc_game save [sc_game number] [sc_base current]}
            if {$::lichess_tournament::autoUpdateBoard} {
              sc_move end
              ::notify::PosChanged -pgn
            } else {
              ::pgn::Refresh 1
            }
            
            ::lichess_tournament::vlog "Added $addedCount new moves"
          } else {
            ::lichess_tournament::vlog "No changes needed after resume"
          }
          
          # Update lastMoveCount to the real move count from server
          set realMoveCount [llength $realMoves]
          dict set ::lichess_tournament::gamePollingData lastMoveCount $realMoveCount
          ::lichess_tournament::vlog "Set lastMoveCount to $realMoveCount after resume"
        } else {
          ::lichess_tournament::vlog "Failed to parse PGN file: $err"
        }
        
        catch {file delete $tempFile}
      } else {
        ::lichess_tournament::vlog "Could not download PGN on resume, will retry on next poll"
      }
      
      # Schedule the next poll to continue regular monitoring
      ::lichess_tournament::scheduleNextPoll
    }
  }
  
  # Update button text
  ::lichess_tournament::updatePauseButton
}

# lichess_tournament::updatePauseButton
#   Update or hide/show the pause button in the PGN window
#
proc ::lichess_tournament::updatePauseButton {} {
  set btn .pgnWin.bottompanel.monitor
  
  # If PGN window or button doesn't exist, nothing to do
  if {![winfo exists $btn]} { return }
  
  if {[::lichess_tournament::isMonitoring]} {
    # Ensure it is visible
    if {![winfo ismapped $btn]} {
      pack $btn -side left -padx 2 -pady 2
    }
    
    # Update text based on state
    if {$::lichess_tournament::isPaused} {
      $btn configure -text "Resume"
    } else {
      $btn configure -text "Pause"
    }
  } else {
    # Not monitoring, hide it
    pack forget $btn
  }
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
  
  # 1. Remove header lines (lines starting with [)
  set body ""
  foreach line [split $content "\n"] {
    set t [string trim $line]
    if {[string index $t 0] eq "\["} { continue }
    append body "$line\n"
  }
  
  set moves {}
  set buffer ""
  set inComment 0
  set varDepth 0
  
  # 2. Parse the body character by character
  foreach char [split $body ""] {
    if {$inComment} {
      if {$char eq "\}"} {
        set inComment 0
        # Attach comment to the last move if available
        if {[llength $moves] > 0} {
          set lastIdx [expr {[llength $moves]-1}]
          set lastEntry [lindex $moves $lastIdx]
          set san [lindex $lastEntry 0]
          set existingComment [lindex $lastEntry 1]
          set newComment [string trim $buffer]
          
          if {$existingComment ne ""} {
            set finalComment "$existingComment $newComment"
          } else {
            set finalComment $newComment
          }
          
          # Update the entry with the comment
          lset moves $lastIdx [list $san $finalComment]
        }
        set buffer ""
      } else {
        append buffer $char
      }
    } elseif {$varDepth > 0} {
      if {$char eq "("} {
        incr varDepth
      } elseif {$char eq ")"} {
        incr varDepth -1
      }
    } else {
      # Normal move parsing
      if {$char eq "\{"} {
        # Start of comment - first flush buffer as move
        set token [string trim $buffer]
        if {$token ne ""} {
          lappend moves [list $token ""]
        }
        set buffer ""
        set inComment 1
      } elseif {$char eq "("} {
        # Start of variation - flush buffer
        set token [string trim $buffer]
        if {$token ne ""} {
          lappend moves [list $token ""]
        }
        set buffer ""
        incr varDepth
      } elseif {[string is space $char]} {
        # Separator - flush buffer
        set token [string trim $buffer]
        if {$token ne ""} {
          lappend moves [list $token ""]
        }
        set buffer ""
      } else {
        append buffer $char
      }
    }
  }
  
  # Flush any remaining buffer
  set token [string trim $buffer]
  if {$token ne ""} {
    lappend moves [list $token ""]
  }
  
  # 3. Clean up the moves (remove numbers, result markers, etc.)
  set cleanMoves {}
  foreach entry $moves {
    set token [lindex $entry 0]
    set comment [lindex $entry 1]
    
    # Remove period from "1." or "1.e4"
    # Case 1: "1." -> ignore
    if {[regexp {^\d+\.$} $token]} { continue }
    # Case 2: "1..." -> ignore
    if {[regexp {^\d+\.+$} $token]} { continue }
    
    # Case 3: "1.e4" -> keep "e4"
    if {[regexp {^\d+\.(.+)$} $token -> rest]} {
      set token $rest
    }
    
    # Skip result markers
    if {$token eq "*" || $token eq "1-0" || $token eq "0-1" || $token eq "1/2-1/2"} { continue }
    
    # Skip junk
    if {$token eq ""} { continue }
    
    lappend cleanMoves [list $token $comment]
  }

  return $cleanMoves
}

# Initialize: Nothing to do at load time

