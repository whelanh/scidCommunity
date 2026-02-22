### sound.tcl
### Functions for playing sound files to announce moves.
### Part of Scid. Copyright (C) Shane Hudson 2004.
### Copyright (C) 2013-2024 Fulvio Benini, whelanh
###
### Uses the free Tcl/Tk sound package "Snack" if available.
### If not, it falls back to system-native audio players (aplay, paplay, afplay, powershell).

namespace eval ::utils::sound {}

set ::utils::sound::backend "none"
set ::utils::sound::pipe ""
set ::utils::sound::hasSound 0
set ::utils::sound::isPlayingSound 0
set ::utils::sound::moveSoundOnly 0
set ::utils::sound::soundQueue {}
set ::utils::sound::soundFiles [list \
    King Queen Rook Bishop Knight CastleQ CastleK Back Mate Promote Check \
    a b c d e f g h x 1 2 3 4 5 6 7 8 move alert]

# soundMap
#   Maps characters in a move to sounds.
array set ::utils::sound::soundMap {
  K King Q Queen R Rook B Bishop N Knight k CastleK q CastleQ
  x x U Back # Mate = Promote  + Check alert alert
  a a b b c c d d e e f f g g h h
  1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8
} 

# ::utils::sound::Setup
#   Called once at startup to detect audio capabilities.
proc ::utils::sound::Setup {} {
  variable hasSound
  variable soundFiles
  variable backend
  variable pipe

  set hasSound 0
  set backend "none"

  # 1. Try Snack
  if {![catch {package require snack 2.0}]} {
    set backend "snack"
    set hasSound 1
    foreach soundFile $soundFiles {
      ::snack::sound sound_$soundFile
    }
  }

  # 2. Try scidsnd.exe on Windows
  if {! $hasSound && $::windowsOS} {
    if {![catch {set pipe [open "| scidsnd.exe" "r+"]}]} {
      set backend "scidsnd"
      set hasSound 1
      fconfigure $pipe -blocking 0 -buffering line
      fileevent $pipe readable { gets $::utils::sound::pipe ; ::utils::sound::SoundFinished }
    }
  }

  # 3. Try System Players
  if {! $hasSound} {
    if {$::windowsOS} {
      set backend "powershell"
      set hasSound 1
    } elseif {$::macOS} {
      if {[auto_execok afplay] != ""} {
        set backend "afplay"
        set hasSound 1
      }
    } else {
      # Linux/Unix. 
      # Prefer paplay over pw-play in Snap/Flatpak as PulseAudio protocol is often more stable for sandboxes.
      foreach p {paplay pw-play aplay canberra-gtk-play} {
        if {[auto_execok $p] != ""} {
          set backend $p
          set hasSound 1
          break
        }
      }
    }
  }

  if {$hasSound} {
    # Self-healing: if the saved soundFolder is not readable, try to reset it to the default
    if {! [file isdirectory $::utils::sound::soundFolder] || [::utils::sound::ReadFolder] == 0} {
      set defaultFolder [file normalize [file join $::scidShareDir sounds]]
      if {[file isdirectory $defaultFolder]} {
        set ::utils::sound::soundFolder $defaultFolder
      }
    }
    ::utils::sound::ReadFolder

    # In Snap strict confinement, bundled audio tools (paplay, pw-play) need
    # to know where the host PulseAudio/PipeWire socket lives.
    # Set PULSE_SERVER explicitly using XDG_RUNTIME_DIR from the host.
    if {[info exists ::env(SNAP)] && [info exists ::env(XDG_RUNTIME_DIR)]} {
      set ::env(PULSE_SERVER) "unix:$::env(XDG_RUNTIME_DIR)/pulse/native"
    }
  }
}

# ::utils::sound::ReadFolder
#   Reads sound files from the specified directory.
proc ::utils::sound::ReadFolder {{newFolder ""}} {
  variable soundFiles
  variable soundFolder
  variable backend
  
  if {$newFolder != ""} { set soundFolder $newFolder }
  
  set count 0
  foreach soundFile $soundFiles {
    set f [file join $soundFolder $soundFile.wav]
    if {[file readable $f]} {
      if {$backend == "snack"} {
        sound_$soundFile configure -file $f
      }
      incr count
    } else {
      # Log missing/unreadable files if we are troubleshooting
      # puts stderr "scidCommunity: Sound file not readable: $f"
    }
  }
  puts stderr "scidCommunity: Found $count sound files in $soundFolder"
  return $count
}

proc ::utils::sound::AnnounceMove {move} {
  variable hasSound
  variable soundMap
  
  if {! $hasSound} { return }
  
  if {[string range $move 0 4] == "O-O-O"} { set move q }
  if {[string range $move 0 2] == "O-O"} { set move k }
  set move [::untrans $move]
  set parts [split $move ""]
  set soundList {}
  foreach part $parts {
    if {[info exists soundMap($part)]} {
      lappend soundList sound_$soundMap($part)
    }
  }
  if {[llength $soundList] > 0} {
    CancelSounds
    if {$::utils::sound::moveSoundOnly} {
      PlaySound sound_move
    } else {
      foreach s $soundList {
        PlaySound $s
      }
    }
  }
}

proc ::utils::sound::AnnounceNewMove {move} {
  if {$::utils::sound::announceNew || $::utils::sound::moveSoundOnly} { AnnounceMove $move }
}

proc ::utils::sound::AnnounceForward {move} {
  if {$::utils::sound::announceForward || $::utils::sound::moveSoundOnly} { AnnounceMove $move }
}

proc ::utils::sound::AnnounceBack {} {
  if {$::utils::sound::announceBack || $::utils::sound::moveSoundOnly} { AnnounceMove U }
}

proc ::utils::sound::SoundFinished {} {
  after cancel ::utils::sound::CancelSounds
  set ::utils::sound::isPlayingSound 0
  # Add a small delay (150ms) between concatenated sounds
  after 150 ::utils::sound::CheckSoundQueue
}

proc ::utils::sound::CancelSounds {} {
  variable backend
  variable pipe
  variable hasSound
  
  if {! $hasSound} { return }

  if {$backend == "snack"} {
    snack::audio stop
  } elseif {$backend == "scidsnd"} {
    puts $pipe "stop"
  }
  # Note: External system players usually play short files rapidly; 
  # killing them might be more complex than worth for move sounds.
  
  set ::utils::sound::soundQueue {}
  set ::utils::sound::isPlayingSound 0
}

proc ::utils::sound::PlaySound {sound} {
  if {! $::utils::sound::hasSound} { return }
  lappend ::utils::sound::soundQueue $sound
  after idle ::utils::sound::CheckSoundQueue
}

proc ::utils::sound::CheckSoundQueue {} {
  variable soundQueue
  variable isPlayingSound
  variable backend
  variable pipe
  variable soundFolder

  if {$isPlayingSound} { return }
  if {[llength $soundQueue] == 0} { return }
  
  set next [lindex $soundQueue 0]
  set soundQueue [lrange $soundQueue 1 end]
  set isPlayingSound 1
  
  set name [string range $next 6 end]
  set f [file join $soundFolder $name.wav]
  if {! [file readable $f]} {
    puts stderr "scidCommunity sound error: file not readable: $f"
    set isPlayingSound 0
    after idle ::utils::sound::CheckSoundQueue
    return
  }

  puts stderr "scidCommunity debug: Playing $f using $backend"

  if {$backend == "snack"} {
    catch { $next play -blocking 0 -command ::utils::sound::SoundFinished }
    after 5000 ::utils::sound::CancelSounds
  } elseif {$backend == "scidsnd"} {
    puts $pipe "[file nativename $f]"
  } elseif {$backend == "powershell"} {
    set cmd "powershell -ExecutionPolicy Bypass -Command \"(New-Object Media.SoundPlayer '[file nativename $f]').PlaySync()\""
    catch { exec {*}$cmd & }
    # Increase delay to account for sound length
    after 450 ::utils::sound::SoundFinished
  } elseif {$backend == "afplay"} {
    catch { exec afplay $f & }
    # Increase delay to account for sound length
    after 450 ::utils::sound::SoundFinished
  } else {
    # Linux players: aplay, paplay, etc.
    # We use a trick to capture errors: if it fails to start, catch will get it.
    # Redirect stderr to stdout and then to /dev/null if it works, 
    # but that makes debugging hard. Let's just catch and log to stderr for now.
    if {[catch { exec $backend $f & } err]} {
      puts stderr "scidCommunity sound error ($backend): $err"
    }
    # Note: If it's silent despite no error, the server connection might be blocked by Snap.
    
    # Increase delay to account for sound length (e.g. 450ms + 150ms gap in SoundFinished)
    after 450 ::utils::sound::SoundFinished
  }
}

proc ::utils::sound::UpdateOptions {mode} {
  if {$mode == "mso"} {
    if {$::utils::sound::moveSoundOnly} {
      set ::utils::sound::announceNew 0
      set ::utils::sound::announceForward 0
      set ::utils::sound::announceBack 0
    }
  } else {
    if {$::utils::sound::announceNew || $::utils::sound::announceForward || $::utils::sound::announceBack} {
      set ::utils::sound::moveSoundOnly 0
    }
  }
}

proc ::utils::sound::OptionsDialog { w } {
     if { ! $::utils::sound::hasSound} {
        ttk::label $w.status -text [tr SoundsSoundDisabled]
        pack $w.status -side bottom
    } else {
        variable backend
        ttk::label $w.backend -text "Audio Backend: $backend" -foreground gray
        pack $w.backend -side bottom -pady 5
    }
    ttk::checkbutton $w.mso -variable ::utils::sound::moveSoundOnly -text [tr SoundsMoveSoundOnly] \
        -command { ::utils::sound::UpdateOptions mso }
    ttk::checkbutton $w.n -variable ::utils::sound::announceNew -text [tr SoundsAnnounceNew] \
        -command { ::utils::sound::UpdateOptions ann }
    ttk::checkbutton $w.f -variable ::utils::sound::announceForward -text [tr SoundsAnnounceForward] \
        -command { ::utils::sound::UpdateOptions ann }
    ttk::checkbutton $w.b -variable ::utils::sound::announceBack -text [tr SoundsAnnounceBack] \
        -command { ::utils::sound::UpdateOptions ann }
    pack $w.mso $w.n $w.f $w.b -side top -anchor w -padx "0 5"
}

proc ::utils::sound::GetDialogChooseFolder { widget } {
    set newFolder [tk_chooseDirectory \
                       -initialdir $::utils::sound::soundFolder \
                       -title "scidCommunity: $::tr(SoundsFolder)" -parent [winfo toplevel $widget] ]
    if {$newFolder != "" && $newFolder != $::utils::sound::soundFolder } {
        if { [::utils::sound::OptionsDialogChooseFolder $newFolder] } {
            $widget delete 0 end
            $widget insert end $newFolder
        }
    }
}

proc ::utils::sound::OptionsDialogChooseFolder { newFolder } {
    set ::utils::sound::soundFolder [file nativename $newFolder]
    set numSoundFiles [::utils::sound::ReadFolder]
    tk_messageBox -title "scidCommunity: Sound Files" -type ok -icon info -parent .resDialog \
        -message "Found $numSoundFiles of [llength $::utils::sound::soundFiles] sound files in $::utils::sound::soundFolder"
    return $numSoundFiles
}

proc ::utils::sound::OptionsDialogOK {} {
  variable soundFolder
  set w .soundOptions
  catch {grab release $w}
  destroy $w
  set isNewSoundFolder 0
  if {$soundFolder != $::utils::sound::soundFolder_temp} {
    set isNewSoundFolder 1
  }
  foreach v {soundFolder announceNew announceForward announceBack} {
    set ::utils::sound::$v [set ::utils::sound::${v}_temp]
  }
  if {$isNewSoundFolder  &&  $soundFolder != ""} {
    set numSoundFiles [::utils::sound::ReadFolder]
    tk_messageBox -title "scidCommunity: Sound Files" -type ok -icon info \
        -message "Found $numSoundFiles of [llength $::utils::sound::soundFiles] sound files in $::utils::sound::soundFolder"
  }
}

::utils::sound::Setup
