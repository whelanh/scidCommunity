######################################################################
#
# iccf.tcl: Download ICCF archives
#
# Authenticates, then downloads, unzips and
# imports a monthly ICCF games archive.
#
# This feature is only built when scidCommunity is compiled with
# -DINCLUDE_ICCF=ON.  It is NOT included in any Release, Flatpak,
# COPR, AUR, or Snap build.
#
# Users must supply their own ~/.chessarch/config (Linux/macOS) or
# %USERPROFILE%\.chessarch\config (Windows) — no documentation is
# provided for this file intentionally.
#
######################################################################

namespace eval ::iccf {
  variable downloading 0
  variable tempDir ""
}

# iccf::getConfigFile
#   Locate the user's config file on any platform.
#
proc ::iccf::getConfigFile {} {
  global env tcl_platform

  if {$tcl_platform(platform) eq "windows"} {
    if {[info exists env(USERPROFILE)]} {
      return [file join $env(USERPROFILE) ".chessarch" "config"]
    }
  } else {
    if {[info exists env(HOME)]} {
      return [file join $env(HOME) ".chessarch" "config"]
    }
  }
  return ""
}

# iccf::readConfig
#   Parse the config file and return a dict of key/value pairs.
#   Lines starting with # are comments; blank lines are ignored.
#   Format: key = value
#
proc ::iccf::readConfig {configFile} {
  set cfg [dict create]
  if {[catch {
    set fd [open $configFile r]
    while {[gets $fd line] >= 0} {
      set line [string trim $line]
      if {$line eq "" || [string index $line 0] eq "#"} { continue }
      if {[regexp {^([^=]+)=(.*)$} $line -> key val]} {
        dict set cfg [string trim $key] [string trim $val]
      }
    }
    close $fd
  } err]} {
    error "Cannot read config file: $err"
  }
  return $cfg
}

# iccf::verifyCredentials
#   Returns 1 on success, 0 on failure.
#
proc ::iccf::verifyCredentials {username password wsdl_url soap_action} {
  if {[auto_execok curl] eq ""} {
    error "curl is required for ICCF authentication but was not found."
  }

  # Normalize the endpoint URL - remove ?WSDL suffix if present for the actual call
  set endpoint_url [regsub {\?WSDL$} $wsdl_url ""]

  set soapBody "<?xml version=\"1.0\" encoding=\"utf-8\"?>\
<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
 xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\
 xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">\
<soap:Body>\
<GetMyGames xmlns=\"http://www.bennedik.com/webservices/XfccBasic\">\
<username>[string map {< &lt; > &gt;} $username]</username>\
<password>[string map {< &lt; > &gt;} $password]</password>\
</GetMyGames>\
</soap:Body>\
</soap:Envelope>"

  # Write SOAP body to temp file to avoid shell escaping issues with XML
  set tmpfile [file join [::iccf::getTempDir] "iccf_soap_[clock seconds].xml"]
  set fd [open $tmpfile w]
  puts -nonewline $fd $soapBody
  close $fd

  set result ""
  set code [catch {
    set result [exec curl -s --max-time 30 \
      -H "Content-Type: text/xml; charset=utf-8" \
      -H "SOAPAction: \"$soap_action\"" \
      -H "User-Agent: scidCommunity/1.0" \
      -d @$tmpfile \
      $endpoint_url]
  } errMsg]

  file delete -force $tmpfile

  if {$code != 0} {
    error "curl request failed: $errMsg"
  }

  if {[string first "GetMyGamesResult" $result] >= 0} {
    return 1
  }
  return 0
}

# iccf::showDownloadDialog
#   Main entry point: pops a small dialog asking for year and month,
#   then triggers the download.
#
proc ::iccf::showDownloadDialog {} {
  if {$::iccf::downloading} {
    tk_messageBox -icon warning -type ok \
      -title "ICCF Download" \
      -message "A download is already in progress. Please wait."
    return
  }

  set w .iccfDlg
  catch {destroy $w}
  toplevel $w
  wm title $w "Download ICCF Archive"
  wm resizable $w 0 0

  # Determine default year/month from current date
  set now [clock seconds]
  set defYear  [clock format $now -format "%Y"]
  set defMonth [clock format $now -format "%m"]

  ttk::frame $w.f -padding 10
  pack $w.f -fill both -expand 1

  ttk::label $w.f.lbl -text "Select the archive year and month:"
  grid $w.f.lbl -row 0 -column 0 -columnspan 2 -pady {0 8} -sticky w

  ttk::label $w.f.ylbl -text "Year (YYYY):"
  ttk::spinbox $w.f.year -from 2000 -to 2099 -width 6 \
    -textvariable ::iccf::dlgYear -format "%04.0f"
  set ::iccf::dlgYear $defYear
  grid $w.f.ylbl -row 1 -column 0 -sticky w -padx {0 5}
  grid $w.f.year -row 1 -column 1 -sticky w

  ttk::label $w.f.mlbl -text "Month (01-12):"
  ttk::spinbox $w.f.month -from 1 -to 12 -width 4 \
    -textvariable ::iccf::dlgMonth -format "%02.0f"
  set ::iccf::dlgMonth $defMonth
  grid $w.f.mlbl -row 2 -column 0 -sticky w -padx {0 5} -pady {4 0}
  grid $w.f.month -row 2 -column 1 -sticky w -pady {4 0}

  ttk::frame $w.btns -padding {10 0 10 10}
  pack $w.btns -fill x

  ttk::button $w.btns.ok -text "OK" -command {
    set y [format "%04d" [expr {int($::iccf::dlgYear)}]]
    set m [format "%02d" [expr {int($::iccf::dlgMonth)}]]
    destroy .iccfDlg
    ::iccf::downloadArchive $y $m
  }
  ttk::button $w.btns.cancel -text "Cancel" -command {destroy .iccfDlg}
  pack $w.btns.cancel $w.btns.ok -side right -padx 4

  wm transient $w .
  wm deiconify $w
  focus $w.f.year
  grab $w
}

# iccf::downloadArchive
#   Orchestrates config read -> auth -> download -> unzip -> open.
#
proc ::iccf::downloadArchive {year month} {
  set ::iccf::downloading 1
  catch {.menu.tools entryconfig "Download ICCF*" -state disabled}

  # --- Step 1: locate and read config ---
  set configFile [::iccf::getConfigFile]
  if {$configFile eq "" || ![file exists $configFile]} {
    ::iccf::_done
    tk_messageBox -icon error -type ok -title "ICCF Download Error" \
      -message "Configuration file not found.\n\nExpected location:\n$configFile"
    return
  }

  if {[catch {set cfg [::iccf::readConfig $configFile]} err]} {
    ::iccf::_done
    tk_messageBox -icon error -type ok -title "ICCF Download Error" \
      -message "Could not read configuration file:\n$err"
    return
  }

  foreach key {archive_base_url username password wsdl_url soap_action} {
    if {![dict exists $cfg $key] || [dict get $cfg $key] eq ""} {
      ::iccf::_done
      tk_messageBox -icon error -type ok -title "ICCF Download Error" \
        -message "Configuration file is missing required key: $key"
      return
    }
  }

  set baseUrl    [dict get $cfg archive_base_url]
  set username   [dict get $cfg username]
  set password   [dict get $cfg password]
  set wsdlUrl    [dict get $cfg wsdl_url]
  set soapAction [dict get $cfg soap_action]

  # --- Step 2: authenticate ---
  if {[catch {set ok [::iccf::verifyCredentials $username $password $wsdlUrl $soapAction]} err]} {
    ::iccf::_done
    tk_messageBox -icon error -type ok -title "ICCF Download Error" \
      -message "Authentication error:\n$err"
    return
  }
  if {!$ok} {
    ::iccf::_done
    tk_messageBox -icon error -type ok -title "ICCF Authentication Failed" \
      -message "ICCF membership verification failed.\n\nCheck your credentials in:\n[::iccf::getConfigFile]"
    return
  }

  # --- Step 3: create temp dir ---
  if {[catch {
    set tempdir [file join [::iccf::getTempDir] "scid_iccf_[clock seconds]"]
    file mkdir $tempdir
    set ::iccf::tempDir $tempdir
  } err]} {
    ::iccf::_done
    tk_messageBox -icon error -type ok -title "ICCF Download Error" \
      -message "Could not create temp directory:\n$err"
    return
  }

  # --- Step 4: download the ZIP ---
  # Ensure baseUrl ends without trailing slash for clean concatenation
  set baseUrl [string trimright $baseUrl "/"]
  set archiveName "archive${year}${month}.zip"
  set archiveUrl  "${baseUrl}/${archiveName}"
  set zipfile     [file join $::iccf::tempDir "iccf.zip"]

  if {[catch {::iccf::downloadFile $archiveUrl $zipfile} err]} {
    file delete -force $::iccf::tempDir
    ::iccf::_done
    tk_messageBox -icon error -type ok -title "ICCF Download Error" \
      -message "Failed to download archive:\n$archiveUrl\n\n$err"
    return
  }

  if {![file exists $zipfile] || [file size $zipfile] == 0} {
    file delete -force $::iccf::tempDir
    ::iccf::_done
    tk_messageBox -icon error -type ok -title "ICCF Download Error" \
      -message "Downloaded file is empty or missing."
    return
  }

  # --- Step 5: extract and open ---
  if {[catch {::iccf::extractAndOpen $zipfile $year $month} err]} {
    file delete -force $::iccf::tempDir
    ::iccf::_done
    tk_messageBox -icon error -type ok -title "ICCF Download Error" \
      -message "Failed to extract archive:\n$err"
    return
  }

  ::iccf::_done
}

# iccf::_done
#   Re-enable menu item and clear downloading flag.
#
proc ::iccf::_done {} {
  set ::iccf::downloading 0
  catch {.menu.tools entryconfig "Download ICCF*" -state normal}
}

# iccf::downloadFile
#   Download a URL to a local file using curl / wget / PowerShell.
#
proc ::iccf::downloadFile {url destfile} {
  if {[auto_execok curl] ne ""} {
    if {[catch {
      exec curl -L -s -o $destfile $url
    } err]} {
      error "curl download failed: $err"
    }
  } elseif {[auto_execok wget] ne ""} {
    if {[catch {
      exec wget -q -O $destfile $url
    } err]} {
      error "wget download failed: $err"
    }
  } elseif {[info exists ::windowsOS] && $::windowsOS && [auto_execok powershell] ne ""} {
    set nativeDest [file nativename $destfile]
    if {[catch {
      exec powershell -NoLogo -NoProfile -Command \
        "Invoke-WebRequest -Uri '$url' -OutFile '$nativeDest'" 2>@1
    } err]} {
      error "PowerShell download failed: $err"
    }
  } else {
    # Tcl http fallback (requires TLS)
    package require http
    if {[catch {package require tls} tlsErr]} {
      error "No download tool available (curl/wget/PowerShell) and Tcl TLS is unavailable: $tlsErr"
    }
    http::register https 443 [list ::tls::socket]
    set fd [open $destfile wb]
    if {[catch {
      set token [http::geturl $url -channel $fd -timeout 120000]
      close $fd
      set status [http::code $token]
      http::cleanup $token
      if {![string match "200*" $status]} {
        error "HTTP status: $status"
      }
    } err]} {
      catch {close $fd}
      error "HTTP download error: $err"
    }
  }
}

# iccf::extractAndOpen
#   Extract PGN files from the ZIP archive and open them in scidCommunity.
#   Uses the same multi-method approach as twic.tcl.
#
proc ::iccf::extractAndOpen {zipfile year month} {
  set extractdir [file join $::iccf::tempDir "extracted"]
  file mkdir $extractdir
  set extracted 0

  # Method 1: unzip command
  if {[auto_execok unzip] ne ""} {
    if {![catch {exec unzip -q -o $zipfile -d $extractdir 2>@1}]} {
      set extracted 1
    }
  }

  # Method 2: tar
  if {!$extracted && [auto_execok tar] ne ""} {
    if {![catch {exec tar -xf $zipfile -C $extractdir 2>@1}]} {
      set extracted 1
    }
  }

  # Method 3: PowerShell Expand-Archive (Windows)
  if {!$extracted && [info exists ::windowsOS] && $::windowsOS \
      && [auto_execok powershell] ne ""} {
    set nativeZip  [file nativename $zipfile]
    set nativeExtr [file nativename $extractdir]
    if {![catch {
      exec powershell -NoLogo -NoProfile -Command \
        "Expand-Archive -LiteralPath \"$nativeZip\" -DestinationPath \"$nativeExtr\" -Force" 2>@1
    }]} {
      if {[llength [glob -directory $extractdir -nocomplain *.pgn]] > 0} {
        set extracted 1
      }
    }
  }

  # Method 4: Tcl built-in zipfs (Tcl 8.6+)
  if {!$extracted && [llength [info commands zipfs::mount]] > 0} {
    if {![catch {
      set mountpoint "/iccf_temp_[clock seconds]"
      zipfs::mount $mountpoint $zipfile
      foreach src [glob -directory $mountpoint -nocomplain *.pgn] {
        file copy -force $src [file join $extractdir [file tail $src]]
      }
      catch {zipfs::unmount $mountpoint}
      set extracted 1
    }]} {}
  }

  # Method 5: vfs::zip
  if {!$extracted && ![catch {package require vfs::zip}]} {
    if {![catch {
      vfs::zip::Mount $zipfile mnt
      foreach src [glob -directory mnt -nocomplain *.pgn] {
        file copy -force $src [file join $extractdir [file tail $src]]
      }
      catch {vfs::zip::Unmount mnt}
      set extracted 1
    }]} {}
  }

  set pgnfiles [glob -directory $extractdir -nocomplain -type f *.pgn]

  if {[llength $pgnfiles] == 0} {
    error "No PGN files found in archive — no supported extraction method available."
  }

  # Merge multiple PGN files if necessary
  if {[llength $pgnfiles] > 1} {
    set merged [file join $::iccf::tempDir "iccf_${year}${month}.pgn"]
    set outfd [open $merged w]
    foreach pf $pgnfiles {
      set infd [open $pf r]
      while {[gets $infd line] >= 0} { puts $outfd $line }
      close $infd
      puts $outfd ""
    }
    close $outfd
    set pgnfile $merged
  } else {
    set pgnfile [lindex $pgnfiles 0]
  }

  # Copy to a permanent location
  set destdir [::iccf::findBaseDir]
  if {$destdir eq ""} { set destdir [pwd] }

  set destfile [file join $destdir "iccf_${year}${month}.pgn"]
  set counter 1
  while {[file exists $destfile]} {
    set destfile [file join $destdir "iccf_${year}${month}_${counter}.pgn"]
    incr counter
  }

  file copy $pgnfile $destfile
  file delete -force $::iccf::tempDir

  ::file::Open $destfile

  tk_messageBox -icon info -type ok -title "ICCF Download Complete" \
    -message "ICCF archive downloaded successfully.\n\nYear: $year  Month: $month\nFile: [file tail $destfile]\n\nYou can now filter, merge, or import these games."
}

# iccf::getTempDir
#   Return a suitable temporary directory (same logic as twic.tcl).
#
proc ::iccf::getTempDir {} {
  global tcl_platform env

  foreach v {TMPDIR TEMP TMP} {
    if {[info exists env($v)]} { return $env($v) }
  }

  switch -- $tcl_platform(platform) {
    windows {
      if {[info exists env(USERPROFILE)]} {
        return [file join $env(USERPROFILE) "AppData" "Local" "Temp"]
      }
      return "C:\\Temp"
    }
    unix {
      if {[file isdirectory "/tmp"]}     { return "/tmp" }
      if {[file isdirectory "/var/tmp"]} { return "/var/tmp" }
    }
  }
  return [pwd]
}

# iccf::findBaseDir
#   Return the user's home directory as a save location.
#
proc ::iccf::findBaseDir {} {
  global env
  if {[info exists env(HOME)]}         { return $env(HOME) }
  if {[info exists env(USERPROFILE)]}  { return $env(USERPROFILE) }
  return ""
}
