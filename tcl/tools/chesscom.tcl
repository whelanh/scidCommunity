######################################################################
#
# chesscom.tcl: Import games from Chess.com
#
# Downloads games month-by-month starting from a user-provided start
# year and concatenates them into a single PGN file, then opens the
# Games List window.
#
######################################################################

namespace eval ::chesscom {
  variable downloading 0
  variable tempDir ""
  variable username ""
  variable startYear ""
  variable progressWin ""
}

# ::chesscom::importGames
#   Prompt for username and start year
proc ::chesscom::importGames {} {
  if {$::chesscom::downloading} {
    tk_messageBox -icon warning -type ok -title "Chess.com Import" \
      -message "A download is already in progress. Please wait."
    return
  }

  set w .chesscomDialog
  if {[winfo exists $w]} {
    destroy $w
  }

  toplevel $w
  wm title $w "Import My Chess.com Games"
  wm resizable $w 0 0
  setWinLocation $w

  ttk::frame $w.content -padding {10 10}
  ttk::label $w.content.userLbl -text "Username:" -anchor w
  ttk::entry $w.content.userEntry -width 30 -textvariable ::chesscom::username
  ttk::label $w.content.yearLbl -text "Start year (YYYY):" -anchor w
  ttk::entry $w.content.yearEntry -width 10 -textvariable ::chesscom::startYear

  grid $w.content.userLbl   -row 0 -column 0 -sticky w -padx {0 8} -pady 4
  grid $w.content.userEntry -row 0 -column 1 -sticky ew -pady 4
  grid $w.content.yearLbl   -row 1 -column 0 -sticky w -padx {0 8} -pady 4
  grid $w.content.yearEntry -row 1 -column 1 -sticky w -pady 4
  grid columnconfigure $w.content 1 -weight 1
  pack $w.content -side top -fill both -expand 1

  ttk::frame $w.buttons -padding {10 10}
  ttk::button $w.buttons.ok -text "Download" -command "::chesscom::startDownload"
  ttk::button $w.buttons.cancel -text "Cancel" -command "destroy $w"
  pack $w.buttons.ok $w.buttons.cancel -side left -padx 5
  pack $w.buttons -side top -fill x

  focus $w.content.userEntry
  bind $w <Return> "::chesscom::startDownload"
  bind $w <Escape> "destroy $w"
  grab $w
}

# ::chesscom::startDownload
#   Validate inputs and kick off downloads
proc ::chesscom::startDownload {} {
  set username [string trim $::chesscom::username]
  set yearStr [string trim $::chesscom::startYear]

  if {$username eq ""} {
    tk_messageBox -icon warning -type ok -title "Chess.com Import" \
      -message "Please enter a username."
    return
  }

  if {![regexp {^\d{4}$} $yearStr]} {
    tk_messageBox -icon warning -type ok -title "Chess.com Import" \
      -message "Please enter a 4-digit start year (YYYY)."
    return
  }

  set year [expr {int($yearStr)}]
  set currentYear [clock format [clock seconds] -format "%Y"]
  set currentYearInt [expr {int($currentYear)}]

  if {$year <= 0 || $year > $currentYearInt} {
    tk_messageBox -icon warning -type ok -title "Chess.com Import" \
      -message "Start year must be between 0001 and $currentYearInt."
    return
  }

  destroy .chesscomDialog
  set ::chesscom::downloading 1
  catch {.menu.file entryconfig "Import my chess.com*" -state disabled}

  ::chesscom::showProgress

  if {[catch {
    set tempdir [file join [::chesscom::getTempDir] "scid_chesscom_[clock seconds]"]
    file mkdir $tempdir
    set ::chesscom::tempDir $tempdir
  } err]} {
    set ::chesscom::downloading 0
    catch {.menu.file entryconfig "Import my chess.com*" -state normal}
    tk_messageBox -icon error -type ok -title "Chess.com Import Error" \
      -message "Could not create temp directory:\n$err"
    return
  }

  if {[catch {
    ::chesscom::downloadUserGames $username $year
  } err]} {
    set ::chesscom::downloading 0
    catch {.menu.file entryconfig "Import my chess.com*" -state normal}
    catch {file delete -force $::chesscom::tempDir}
    tk_messageBox -icon error -type ok -title "Chess.com Import Error" \
      -message "Error downloading games for user '$username':\n$err"
    ::chesscom::hideProgress
    return
  }
}

# ::chesscom::downloadUserGames
#   Download month-by-month from start year to current month
proc ::chesscom::downloadUserGames {username startYear} {
  set pgnfile [file join $::chesscom::tempDir "chesscom_games.pgn"]
  set currentYear [expr {int([clock format [clock seconds] -format "%Y"])}]
  set currentMonth [expr {int([clock format [clock seconds] -format "%m"])}]
  set gamesFound 0

  for {set y $startYear} {$y <= $currentYear} {incr y} {
    set endMonth 12
    if {$y == $currentYear} {
      set endMonth $currentMonth
    }
    for {set m 1} {$m <= $endMonth} {incr m} {
      set mm [format "%02d" $m]
      set url [format "https://api.chess.com/pub/player/%s/games/%04d/%s/pgn" $username $y $mm]
      set monthfile [file join $::chesscom::tempDir "${y}_${mm}.pgn"]

      if {[catch {::chesscom::downloadMonth $url $monthfile} err]} {
        # If every request fails we'll catch at the end; continue trying
        catch {file delete -force $monthfile}
        continue
      }

      if {[file exists $monthfile] && [file size $monthfile] > 0} {
        set gamesFound 1
        set dataFd [open $monthfile r]
        set data [read $dataFd]
        close $dataFd

        set outFd [open $pgnfile a]
        puts -nonewline $outFd $data
        if {[string index $data end] ne "\n"} {
          puts $outFd ""
        }
        close $outFd
      }

      catch {file delete -force $monthfile}
    }
  }

  if {!$gamesFound} {
    catch {file delete -force $::chesscom::tempDir}
    error "No games were downloaded. Please check the username or adjust the start year."
  }

  ::chesscom::openPGN $pgnfile $username $startYear
}

# ::chesscom::downloadMonth
#   Download a single month using curl/wget/PowerShell/http fallback
proc ::chesscom::downloadMonth {apiurl outfile} {
  if {[auto_execok curl] ne ""} {
    if {[catch {exec curl -L -s -o "$outfile" "$apiurl" 2>@1} err]} {
      error "curl download failed: $err"
    }
  } elseif {[auto_execok wget] ne ""} {
    if {[catch {exec wget -q -O "$outfile" "$apiurl" 2>@1} err]} {
      error "wget download failed: $err"
    }
  } elseif {[info exists ::windowsOS] && $::windowsOS && [auto_execok powershell] ne ""} {
    if {[catch {exec powershell -NoLogo -NoProfile -Command "Invoke-WebRequest -Uri '$apiurl' -OutFile '$outfile'" 2>@1} err]} {
      error "PowerShell download failed: $err"
    }
  } else {
    ::chesscom::downloadWithHTTP $apiurl $outfile
  }

  if {![file exists $outfile]} {
    error "Downloaded file is missing"
  }
}

# ::chesscom::downloadWithHTTP
proc ::chesscom::downloadWithHTTP {apiurl outfile} {
  package require http
  if {[catch {package require tls} tlsErr]} {
    error "Tcl TLS support is unavailable: $tlsErr. Install the tls package or use curl/wget/PowerShell to download."
  }
  http::register https 443 [list ::tls::socket -autoservername true]

  if {[catch {
    set fd [open $outfile wb]
    set token [http::geturl $apiurl -channel $fd -timeout 120000]
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

# ::chesscom::openPGN
#   Open concatenated PGN and clean up
proc ::chesscom::openPGN {pgnfile username startYear} {
  set ::chesscom::downloading 0
  catch {.menu.file entryconfig "Import my chess.com*" -state normal}
  ::chesscom::hideProgress

  if {![file exists $pgnfile] || [file size $pgnfile] == 0} {
    catch {file delete -force $::chesscom::tempDir}
    error "No games were downloaded. Please check the username or start year."
  }

  if {[catch {
    ::file::Open $pgnfile
    tk_messageBox -icon info -type ok -title "Chess.com Import Complete" \
      -message "Successfully downloaded games for Chess.com user '$username' starting from $startYear.\n\nThe games are now open in the Games List window."
    after 5000 [list catch [list file delete -force $::chesscom::tempDir]]
  } err]} {
    catch {file delete -force $::chesscom::tempDir}
    error "Error opening PGN file: $err"
  }
}

# ::chesscom::showProgress
#   Display a small non-blocking progress notice
proc ::chesscom::showProgress {} {
  if {[winfo exists .chesscomProgress]} {
    destroy .chesscomProgress
  }
  set ::chesscom::progressWin .chesscomProgress
  toplevel $::chesscom::progressWin
  wm title $::chesscom::progressWin "Downloading..."
  wm resizable $::chesscom::progressWin 0 0
  setWinLocation $::chesscom::progressWin
  ttk::label $::chesscom::progressWin.msg -text "Downloading Chess.com games...\nThis may take a few moments." -padding {10 10}
  pack $::chesscom::progressWin.msg -side top -fill both
  update idletasks
}

# ::chesscom::hideProgress
#   Close the progress notice if present
proc ::chesscom::hideProgress {} {
  if {[info exists ::chesscom::progressWin] && [winfo exists $::chesscom::progressWin]} {
    destroy $::chesscom::progressWin
  }
}

# ::chesscom::getTempDir
proc ::chesscom::getTempDir {} {
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
