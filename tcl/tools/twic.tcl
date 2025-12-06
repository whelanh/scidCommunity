######################################################################
#
# twic.tcl: Download TWIC (The Week In Chess) games
#
# Fetches the latest TWIC chess games from chesscenter.com
# and opens them as a PGN file for the user to import/filter/merge
#
######################################################################

namespace eval ::twic {
  variable downloading 0
  variable tempDir ""
}

# twic::downloadWeek
#   Main entry point: downloads TWIC games and opens in import dialog
#
proc ::twic::downloadWeek {week} {
  if {$::twic::downloading} {
    tk_messageBox -icon warning -type ok -title "TWIC Download" \
      -message "A download is already in progress. Please wait."
    return
  }
  
  set ::twic::downloading 1
  
  # Disable the menu item during download
  catch {.menu.tools entryconfig "Download TWIC*" -state disabled}
  
  # Create temp directory for this download
  if {[catch {
    set tempdir [file join [::twic::getTempDir] "scid_twic_[clock seconds]"]
    file mkdir $tempdir
    set ::twic::tempDir $tempdir
  } err]} {
    set ::twic::downloading 0
    catch {.menu.tools entryconfig "Download TWIC*" -state normal}
    tk_messageBox -icon error -type ok -title "TWIC Download Error" \
      -message "Could not create temp directory:\n$err"
    return
  }
  
  # Determine which week to download
  if {$week eq "latest"} {
    set weeknum [::twic::getCurrentWeekNumber]
  } else {
    set weeknum $week
  }
  
  # Download the TWIC games
  if {[catch {
    ::twic::downloadTWICWeek $weeknum
  } err]} {
    set ::twic::downloading 0
    catch {.menu.tools entryconfig "Download TWIC*" -state normal}
    file delete -force $::twic::tempDir
    tk_messageBox -icon error -type ok -title "TWIC Download Error" \
      -message "Error downloading TWIC week $weeknum:\n$err"
    return
  }
}

# twic::getCurrentWeekNumber
#   Calculate the current TWIC week number based on date
#   TWIC week 1621 is approximately Dec 4, 2025
#   Each week increments by 1, released on Monday at ~8pm EST
#
proc ::twic::getCurrentWeekNumber {} {
  # Use a known reference: Week 1621 on approximately Dec 4, 2025
  # Reference epoch: Dec 4, 2025 00:00:00 UTC
  set reference_week 1621
  set reference_epoch 1764758400  ;# 2025-12-04 00:00:00 UTC
  
  set current_epoch [clock seconds]
  
  # Calculate days since reference date
  set days_since_ref [expr {($current_epoch - $reference_epoch) / 86400}]
  
  # Calculate weeks since reference (games released Monday, so round down)
  set weeks_since_ref [expr {int($days_since_ref / 7)}]
  
  # Current week number
  set weeknum [expr {$reference_week + $weeks_since_ref}]
  
  return $weeknum
}

# twic::downloadTWICWeek
#   Download TWIC games for a specific week number using HTTPS
#
proc ::twic::downloadTWICWeek {weeknum} {
  set zipfile [file join $::twic::tempDir "twic.zip"]
  
  # Construct the download URL with the 'g' suffix
  set zipurl "https://theweekinchess.com/zips/twic${weeknum}g.zip"
  
  # Use exec curl to download via HTTPS (more reliable than Tcl http)
  if {![catch {exec which curl}]} {
    if {[catch {
      exec curl -s -o $zipfile "$zipurl"
    } err]} {
      error "curl download failed: $err"
    }
  } elseif {![catch {exec which wget}]} {
    if {[catch {
      exec wget -q -O $zipfile "$zipurl"
    } err]} {
      error "wget download failed: $err"
    }
  } elseif {[info exists ::windowsOS] && $::windowsOS && [auto_execok powershell] ne ""} {
    # Windows fallback: PowerShell Invoke-WebRequest via temp script file
    # (avoids all the escaping/quoting hell)
    set tempdir [::twic::getTempDir]
    set psscript [file join $tempdir "twic_download_[clock milliseconds].ps1"]
    
    # Create a simple PowerShell script file
    if {[catch {
      set fd [open $psscript w]
      puts $fd "\$ProgressPreference = 'SilentlyContinue'"
      puts $fd "\[Net.ServicePointManager\]::SecurityProtocol = \[Net.SecurityProtocolType\]::Tls12"
      puts $fd "Invoke-WebRequest -Uri '$zipurl' -OutFile '$zipfile' -UseBasicParsing"
      close $fd
    } err]} {
      error "Could not create PowerShell script: $err"
    }
    
    # Execute the script
    if {[catch {
      exec powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File $psscript 2>@1
    } err]} {
      catch {file delete $psscript}
      error "PowerShell script execution failed: $err"
    }
    
    # Clean up the script
    catch {file delete $psscript}
    
    if {![file exists $zipfile] || [file size $zipfile] == 0} {
      error "PowerShell did not create '$zipfile' or file is empty."
    }
  } else {
    # No external downloader; try Tcl http (requires TLS support)
    ::twic::downloadWithHTTP $zipurl $zipfile
  }
  
  # Verify the file was downloaded
  if {![file exists $zipfile] || [file size $zipfile] == 0} {
    error "Downloaded file is empty or missing"
  }
  
  ::twic::extractZIP $zipfile
}

# twic::downloadWithHTTP
#   Download using Tcl http package (fallback method)
#
proc ::twic::downloadWithHTTP {zipurl zipfile} {
  package require http
  if {[catch {package require tls} tlsErr]} {
    error "Tcl TLS support is unavailable: $tlsErr. Install the tls package or use curl/wget/PowerShell to download."
  }
  
  # Note: This will only work if Tcl has HTTPS support via TLS
  if {[catch {
    set fd [open $zipfile wb]
    set token [http::geturl $zipurl \
      -channel $fd \
      -timeout 60000]
    close $fd
    
    set status [http::code $token]
    http::cleanup $token
    
    if {![string match "200*" $status]} {
      error "HTTP download failed with status: $status"
    }
  } err]} {
    catch {close $fd}
    error "HTTP download error: $err"
  }
}

# twic::downloadZIP
#   Download the ZIP file containing PGN games
#   (Now handled by downloadTWICWeek, kept for compatibility)
#
proc ::twic::downloadZIP {zipurl} {
  # This is kept for backward compatibility but downloadTWICWeek
  # now handles the actual download using curl/wget
  error "Use downloadTWICWeek instead"
}

# twic::extractZIP
#   Extract PGN files from ZIP archive
#   Tries multiple methods: unzip command, then Tcllib vfs::zip, then fallback zip handling
#
proc ::twic::extractZIP {zipfile} {
  set extractdir [file join $::twic::tempDir "extracted"]
  file mkdir $extractdir
  
  set extracted 0
  
  # Method 1: Try using unzip command
  if {![catch {exec which unzip}]} {
    if {![catch {
      exec unzip -q -o $zipfile -d $extractdir 2>@1
      set extracted 1
    }]} {
      # Success with unzip
    }
  }
  
  # Method 2: Try Tcllib vfs::zip if unzip didn't work
  if {!$extracted && ![catch {package require vfs::zip}]} {
    if {![catch {
      vfs::zip::Mount $zipfile mnt
      foreach src [glob -directory mnt -nocomplain *.pgn] {
        set dst [file join $extractdir [file tail $src]]
        file copy -force $src $dst
      }
      catch {vfs::zip::Unmount mnt}
      set extracted 1
    }]} {
      # Success with vfs::zip
    }
  }
  
  # Method 3: Try to use Tcl's zip support via zlib/tar
  if {!$extracted && ![catch {package require tar}]} {
    if {![catch {
      package require zlib
      set fd [open $zipfile rb]
      fconfigure $fd -translation binary
      
      # Try to read as a zip file and extract
      set data [read $fd]
      close $fd
      
      # Simple ZIP extraction: look for local file headers
      # This is a basic implementation for PGN files
      set pos 0
      while {$pos < [string length $data]} {
        # ZIP local file header signature: 0x04034b50
        set sig [binary scan [string range $data $pos [expr {$pos+3}]] H* hex; set hex]
        if {$sig ne "504b0304"} {
          incr pos
          continue
        }
        
        # Found local file header
        binary scan [string range $data $pos [expr {$pos+30}]] x4Ia4Ia4Ia2Ia2Ia2Ia2Ia2Ia4Ia4Ia4Ia2Ia2 \
          vers flags compr time date crc csize usize namelen extlen
        
        set namelen [expr {$namelen & 0xFFFF}]
        set extlen [expr {$extlen & 0xFFFF}]
        set name [string range $data [expr {$pos+30}] [expr {$pos+30+$namelen-1}]]
        
        # Skip if it's a directory or not a PGN file
        if {[string match "*.pgn" $name] && ![string match "*/" $name]} {
          set filedata_start [expr {$pos + 30 + $namelen + $extlen}]
          set filedata_end [expr {$filedata_start + $csize}]
          
          if {$filedata_end <= [string length $data]} {
            set filedata [string range $data $filedata_start $filedata_end]
            
            # Decompress if needed (method 8 = deflate)
            set method [expr {($flags >> 0) & 0xFF}]
            if {$method == 8} {
              # Deflate compression
              if {![catch {
                set filedata [zlib decompress $filedata]
              }]} {
                # Decompression succeeded, write file
                set outfile [file join $extractdir [file tail $name]]
                set outfd [open $outfile wb]
                puts -nonewline $outfd $filedata
                close $outfd
                set extracted 1
              }
            } elseif {$method == 0} {
              # No compression, just write it
              set outfile [file join $extractdir [file tail $name]]
              set outfd [open $outfile wb]
              puts -nonewline $outfd $filedata
              close $outfd
              set extracted 1
            }
          }
        }
        
        incr pos [expr {30 + $namelen + $extlen + $csize}]
      }
    } err]} {
      # zlib/tar method failed
    }
  }
  
  # If we still haven't extracted, try the simple approach
  if {!$extracted} {
    # Last resort: try to manually parse ZIP file (simplified approach)
    if {![catch {
      set fd [open $zipfile rb]
      fconfigure $fd -translation binary
      set data [read $fd]
      close $fd
      
      # Look for PGN files by searching for PGN headers in the ZIP
      set pos 0
      while {[set idx [string first "\[Event" $data $pos]] >= 0} {
        # Found a PGN event, extract from here until next local file header or end
        set start [string last "\x04\x34\x4b\x50" $data [expr {$idx - 1}]]
        if {$start < 0} {
          set start 0
        }
        
        # This is a simplified extraction - just copy the PGN data
        # In practice, we'd need proper ZIP header parsing
        incr pos [expr {$idx + 1}]
      }
    }]} {
      # Even basic fallback failed
    }
  }
  
  # Check if we successfully extracted anything
  set pgnfiles [glob -directory $extractdir -nocomplain -type f *.pgn]
  
  if {[llength $pgnfiles] == 0} {
    error "Cannot extract ZIP: no supported extraction method available"
  }
  
  # If multiple PGN files, merge them first
  if {[llength $pgnfiles] > 1} {
    ::twic::mergePGNFiles $pgnfiles
  } else {
    ::twic::openPGNInImport [lindex $pgnfiles 0]
  }
}

# twic::mergePGNFiles
#   Merge multiple PGN files into a single file
#
proc ::twic::mergePGNFiles {pgnfiles} {
  set outputfile [file join $::twic::tempDir "twic_merged.pgn"]
  
  if {[catch {
    set outfd [open $outputfile w]
    
    foreach pgnfile $pgnfiles {
      set infd [open $pgnfile r]
      while {[gets $infd line] >= 0} {
        puts $outfd $line
      }
      close $infd
      # Add blank line between files for readability
      puts $outfd ""
    }
    
    close $outfd
  } err]} {
    catch {close $outfd}
    error "Error merging PGN files: $err"
  }
  
  ::twic::openPGNInImport $outputfile
}

# twic::openPGNInImport
#   Open the PGN file in the import dialog
#
proc ::twic::openPGNInImport {pgnfile} {
  # Re-enable the menu item
  catch {.menu.tools entryconfig "Download TWIC*" -state normal}
  set ::twic::downloading 0
  
  if {![file exists $pgnfile]} {
    tk_messageBox -icon error -type ok -title "TWIC Download Error" \
      -message "Error: PGN file not found"
    file delete -force $::twic::tempDir
    return
  }
  
  # Copy PGN to a more permanent location
  set destdir [::twic::findBaseDir]
  if {$destdir eq ""} {
    set destdir [pwd]
  }
  
  set destfile [file join $destdir "twic_[clock format [clock seconds] -format %Y%m%d].pgn"]
  
  # Make sure destination is writable and unique
  set counter 1
  while {[file exists $destfile]} {
    set destfile [file join $destdir "twic_[clock format [clock seconds] -format %Y%m%d]_$counter.pgn"]
    incr counter
  }
  
  if {[catch {
    file copy $pgnfile $destfile
  } err]} {
    tk_messageBox -icon error -type ok -title "TWIC Download Error" \
      -message "Could not copy PGN file to destination:\n$err"
    file delete -force $::twic::tempDir
    return
  }
  
  # Clean up temp directory
  file delete -force $::twic::tempDir
  
  # Open the import dialog with the PGN file
  ::file::Open $destfile
  
  tk_messageBox -icon info -type ok -title "TWIC Download Complete" \
    -message "TWIC games downloaded successfully.\n\nFile: [file tail $destfile]\n\nYou can now filter, merge, or import these games."
}

# twic::getTempDir
#   Get a suitable temp directory for this platform
#
proc ::twic::getTempDir {} {
  global tcl_platform env
  
  # Try standard locations
  if {[info exists env(TMPDIR)]} {
    return $env(TMPDIR)
  }
  if {[info exists env(TEMP)]} {
    return $env(TEMP)
  }
  if {[info exists env(TMP)]} {
    return $env(TMP)
  }
  
  # Platform-specific defaults
  switch -- $tcl_platform(platform) {
    windows {
      if {[info exists env(USERPROFILE)]} {
        return [file join $env(USERPROFILE) "AppData" "Local" "Temp"]
      }
      return "C:\\Temp"
    }
    unix {
      if {[file isdirectory "/tmp"]} {
        return "/tmp"
      }
      if {[file isdirectory "/var/tmp"]} {
        return "/var/tmp"
      }
    }
  }
  
  # Last resort: use current directory
  return [pwd]
}

# twic::findBaseDir
#   Find a suitable directory to save downloaded PGN files
#
proc ::twic::findBaseDir {} {
  global env
  
  # Prefer user's home directory
  if {[info exists env(HOME)]} {
    return $env(HOME)
  }
  if {[info exists env(USERPROFILE)]} {
    return $env(USERPROFILE)
  }
  
  return ""
}
