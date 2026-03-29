# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later

######################################################################
#
# lichess.tcl: Import games from Lichess.org
#
# Downloads all games from a user's Lichess account and opens them
# as a PGN file for the user to import/filter/merge
#
######################################################################

namespace eval ::lichess {
  variable downloading 0
  variable tempDir ""
  variable username ""
  variable startYear ""
  variable startMonth ""
}

# lichess::importGames
#   Main entry point: prompts for username, downloads games, opens in Games List
#
proc ::lichess::importGames {} {
  if {$::lichess::downloading} {
    tk_messageBox -icon warning -type ok -title "Lichess Import" \
      -message "A download is already in progress. Please wait."
    return
  }
  
  # Create dialog to get username and start date
  set w .lichessDialog
  if {[winfo exists $w]} {
    destroy $w
  }
  
  toplevel $w
  wm title $w "Import My Lichess Games"
  wm resizable $w 0 0
  
  # Center the dialog
  setWinLocation $w
  
  ttk::frame $w.content -padding {10 10}
  ttk::label $w.content.userLbl -text "Username:" -anchor w
  ttk::entry $w.content.userEntry -width 30 -textvariable ::lichess::username
  ttk::label $w.content.yearLbl -text "Start year (YYYY):" -anchor w
  ttk::entry $w.content.yearEntry -width 10 -textvariable ::lichess::startYear
  ttk::label $w.content.monthLbl -text "Start month (1-12):" -anchor w
  ttk::entry $w.content.monthEntry -width 5 -textvariable ::lichess::startMonth
  
  grid $w.content.userLbl   -row 0 -column 0 -sticky w -padx {0 8} -pady 4
  grid $w.content.userEntry -row 0 -column 1 -sticky ew -pady 4
  grid $w.content.yearLbl   -row 1 -column 0 -sticky w -padx {0 8} -pady 4
  grid $w.content.yearEntry -row 1 -column 1 -sticky w -pady 4
  grid $w.content.monthLbl  -row 2 -column 0 -sticky w -padx {0 8} -pady 4
  grid $w.content.monthEntry -row 2 -column 1 -sticky w -pady 4
  grid columnconfigure $w.content 1 -weight 1
  pack $w.content -side top -fill both -expand 1
  
  ttk::frame $w.buttons -padding {10 10}
  ttk::button $w.buttons.ok -text "Download" -command "::lichess::startDownload $w"
  ttk::button $w.buttons.cancel -text "Cancel" -command "destroy $w"
  pack $w.buttons.ok $w.buttons.cancel -side left -padx 5
  pack $w.buttons -side top -fill x
  
  # Focus on entry and bind Return key
  focus $w.content.userEntry
  bind $w <Return> "::lichess::startDownload $w"
  bind $w <Escape> "destroy $w"
  
  # Make dialog modal
  grab $w
}

# lichess::startDownload
#   Validates inputs and initiates download

proc ::lichess::startDownload {w} {
  set username [string trim $::lichess::username]
  set yearStr [string trim $::lichess::startYear]
  set monthStr [string trim $::lichess::startMonth]
  
  if {$username eq ""} {
    tk_messageBox -icon warning -type ok -title "Lichess Import" \
      -message "Please enter a username."
    return
  }
  if {![regexp {^\d{4}$} $yearStr]} {
    tk_messageBox -icon warning -type ok -title "Lichess Import" \
      -message "Please enter a 4-digit start year (YYYY)."
    return
  }
  if {![regexp {^\d{1,2}$} $monthStr]} {
    tk_messageBox -icon warning -type ok -title "Lichess Import" \
      -message "Please enter a start month from 1 to 12."
    return
  }
  set year [expr {int($yearStr)}]
  set month [expr {int($monthStr)}]
  set currentYearInt [expr {int([clock format [clock seconds] -format "%Y"])}]
  set currentMonthInt [expr {int([clock format [clock seconds] -format "%m"])}]
  if {$year <= 0 || $year > $currentYearInt} {
    tk_messageBox -icon warning -type ok -title "Lichess Import" \
      -message "Start year must be between 0001 and $currentYearInt."
    return
  }
  if {$month < 1 || $month > 12} {
    tk_messageBox -icon warning -type ok -title "Lichess Import" \
      -message "Start month must be between 1 and 12."
    return
  }
  
  # Compute since/until epochs in milliseconds (UTC, start-of-month to now)
  set sinceStr [format "%04d-%02d-01 00:00:00 UTC" $year $month]
  if {[catch {set sinceSec [clock scan $sinceStr -timezone UTC]} scanErr]} {
    tk_messageBox -icon error -type ok -title "Lichess Import Error" \
      -message "Could not parse the start date: $scanErr"
    return
  }
  set sinceMs [expr {$sinceSec * 1000}]
  set untilMs [expr {[clock seconds] * 1000}]
  if {$sinceMs >= $untilMs} {
    tk_messageBox -icon warning -type ok -title "Lichess Import" \
      -message "Start date must be before the current date."
    return
  }
  
  # Disable Download button during work
  $w.buttons.ok configure -state disabled
  $w.buttons.cancel configure -command "destroy $w"
  catch {grab release $w}
  
  set ::lichess::downloading 1
  # Disable the menu item during download
  catch {.menu.file entryconfig "Import my Lichess*" -state disabled}
  
  # Create temp directory for this download
  if {[catch {
    set tempdir [file join [::lichess::getTempDir] "scid_lichess_[clock seconds]"]
    file mkdir $tempdir
    set ::lichess::tempDir $tempdir
  } err]} {
    set ::lichess::downloading 0
    catch {.menu.file entryconfig "Import my Lichess*" -state normal}
    tk_messageBox -icon error -type ok -title "Lichess Import Error" \
      -message "Could not create temp directory:\n$err"
    destroy $w
    return
  }
  
  # Download the games
  if {[catch {
    ::lichess::downloadUserGames $username $sinceMs $untilMs
  } err]} {
    set ::lichess::downloading 0
    catch {.menu.file entryconfig "Import my Lichess*" -state normal}
    file delete -force $::lichess::tempDir
    if {[winfo exists $w]} {
      destroy $w
    }
    tk_messageBox -icon error -type ok -title "Lichess Import Error" \
      -message "Error downloading games for user '$username':\n$err\n\nPlease check that the username is correct."
    return
  }
  
  if {[winfo exists $w]} {
    destroy $w
  }
}

# lichess::downloadUserGames
#   Download games for a Lichess user within a date range

proc ::lichess::downloadUserGames {username sinceMs untilMs} {
  set pgnfile [file join $::lichess::tempDir "lichess_games.pgn"]
  
  # Construct the Lichess API URL
  set apiurl "https://lichess.org/api/games/user/${username}?tags=true&clocks=true&evals=true&opening=true&literate=true&since=${sinceMs}&until=${untilMs}"
  
  # Use exec curl to download via HTTPS (most reliable)
  # Use auto_execok which works on all platforms (including Windows)
  if {[auto_execok curl] ne ""} {
    if {[catch {
      exec curl -L -s -o "$pgnfile" "$apiurl" 2>@1
    } err]} {
      error "curl download failed: $err"
    }
  } elseif {[auto_execok wget] ne ""} {
    if {[catch {
      exec wget -q -O "$pgnfile" "$apiurl" 2>@1
    } err]} {
      error "wget download failed: $err"
    }
  } elseif {[info exists ::windowsOS] && $::windowsOS && [auto_execok powershell] ne ""} {
    # Windows fallback: PowerShell Invoke-WebRequest
    if {[catch {
      set ::env(SAFE_DL_URL) $apiurl
      set ::env(SAFE_DL_FILE) $pgnfile
      exec powershell -NoLogo -NoProfile -Command {Invoke-WebRequest -Uri $env:SAFE_DL_URL -OutFile $env:SAFE_DL_FILE} 2>@1
    } err]} {
      error "PowerShell download failed: $err"
    }
  } else {
    # No external downloader; try Tcl http (requires TLS support)
    ::lichess::downloadWithHTTP $apiurl $pgnfile
  }
  
  # Verify the file was downloaded
  if {![file exists $pgnfile]} {
    error "Downloaded file is missing"
  }
  
  if {[file size $pgnfile] == 0} {
    error "No games found for user '$username'. Please check that the username is correct."
  }
  
  # Check if the file contains valid PGN data
  set fd [open $pgnfile r]
  set firstline [gets $fd]
  close $fd
  
  # Lichess returns error messages in plain text, check for common errors
  if {[string match "*User not found*" $firstline] || [string match "*Invalid username*" $firstline]} {
    error "User '$username' not found on Lichess.org"
  }
  
  ::lichess::openPGN $pgnfile $username
}

# lichess::downloadWithHTTP
#   Download using Tcl http package (fallback method)
#
proc ::lichess::downloadWithHTTP {apiurl pgnfile} {
  package require http
  if {[catch {package require tls} tlsErr]} {
    error "Tcl TLS support is unavailable: $tlsErr. Install the tls package or use curl/wget/PowerShell to download."
  }
  
  # Register TLS
  http::register https 443 [list ::tls::socket -autoservername true]
  
  if {[catch {
    set fd [open $pgnfile wb]
    set token [http::geturl $apiurl \
      -channel $fd \
      -timeout 120000]
    close $fd
    
    set status [http::code $token]
    set ncode [http::ncode $token]
    http::cleanup $token
    
    if {$ncode != 200} {
      error "HTTP download failed with status: $status"
    }
  } err]} {
    catch {close $fd}
    error "HTTP download error: $err"
  }
}

# lichess::openPGN
#   Open the downloaded PGN file in a Games List window
#
proc ::lichess::openPGN {pgnfile username} {
  # Re-enable menu
  set ::lichess::downloading 0
  catch {.menu.file entryconfig "Import my Lichess*" -state normal}
  
  # Import the PGN file into a temporary database
  # Use the same approach as TWIC by invoking the standard file importer
  if {[catch {
    # Open the PGN file via the existing file import flow
    ::file::Open $pgnfile
    
    # Show success message
    tk_messageBox -icon info -type ok -title "Lichess Import Complete" \
      -message "Successfully downloaded games for Lichess user '$username'.\n\nThe games are now open in the Games List window."
    
    # Clean up temp directory after a delay to allow file to be read
    after 5000 [list catch [list file delete -force $::lichess::tempDir]]
  } err]} {
    # Clean up on error
    catch {file delete -force $::lichess::tempDir}
    error "Error opening PGN file: $err"
  }
}

# lichess::getTempDir
#   Get system temp directory (cross-platform)
#
proc ::lichess::getTempDir {} {
  if {[info exists ::env(TMPDIR)]} {
    return $::env(TMPDIR)
  } elseif {[info exists ::env(TEMP)]} {
    return $::env(TEMP)
  } elseif {[info exists ::env(TMP)]} {
    return $::env(TMP)
  } elseif {[file isdirectory "/tmp"]} {
    return "/tmp"
  } elseif {[info exists ::env(USERPROFILE)]} {
    return [file join $::env(USERPROFILE) "AppData" "Local" "Temp"]
  } else {
    return [pwd]
  }
}

# Initialize namespace
namespace eval ::lichess {}
