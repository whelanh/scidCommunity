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
if {![info exists ::utils::sound::moveSoundOnly]} { set ::utils::sound::moveSoundOnly 0 }
set ::utils::sound::soundQueue {}
set ::utils::sound::soundFiles [list \
    King Queen Rook Bishop Knight CastleQ CastleK Back Mate Promote Check \
    a b c d e f g h x 1 2 3 4 5 6 7 8 move alert \
    move_check move_castling move_capture move_promotion move_normal]

# soundTheme: an optional sound theme (a subdirectory name under themesDir).
# An empty value means "use only the base sound folder". A theme overrides the
# move/event sounds (move, move_capture, move_castling, move_check,
# move_promotion, Check, Mate, ...) while the base folder keeps supplying the
# spoken piece/file/rank announcement sounds.
if {![info exists ::utils::sound::soundTheme]} { set ::utils::sound::soundTheme "" }
set ::utils::sound::themesDir [file nativename [file join $::scidShareDir sounds themes]]

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
      # pw-play uses native PipeWire protocol which doesn't work in Flatpak sandboxes.
      # paplay uses PulseAudio protocol which works with --socket=pulseaudio.
      set players {paplay pw-play aplay canberra-gtk-play}
      if {[info exists ::env(FLATPAK_ID)]} {
        # Exclude pw-play in Flatpak - it can't connect via native PipeWire protocol
        set players {paplay aplay canberra-gtk-play}
      }
      foreach p $players {
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

    # In Snap strict confinement, XDG_RUNTIME_DIR is overridden to a snap-specific
    # subdirectory. We must use the REAL user socket path instead.
    if {[info exists ::env(SNAP)]} {
      if {![catch {set uid [exec id -u]} err]} {
        set pulseSocket "/run/user/$uid/pulse/native"
        if {[file exists $pulseSocket]} {
          set ::env(PULSE_SERVER) "unix:$pulseSocket"
        }
      }
    }

    # In Flatpak, the PulseAudio socket is provided via --socket=pulseaudio
    # but we need to ensure PULSE_SERVER points to the correct location.
    # Flatpak typically sets this automatically, but if not, try the default path.
    if {[info exists ::env(FLATPAK_ID)]} {
      if {![catch {set uid [exec id -u]} err]} {
        # Try the standard PipeWire/PulseAudio socket location
        set pulseSocket "/run/user/$uid/pulse/native"
        if {[file exists $pulseSocket] && ![info exists ::env(PULSE_SERVER)]} {
          set ::env(PULSE_SERVER) "unix:$pulseSocket"
        }
      }
    }
  }
}

# ::utils::sound::ListThemes
#   Returns the sorted list of available sound themes (subdirectory names under
#   themesDir). Bundled Lichess themes live here, and a user can drop a folder
#   of their own move/event sounds into the same place to add a custom theme.
proc ::utils::sound::ListThemes {} {
  variable themesDir
  set themes {}
  if {[file isdirectory $themesDir]} {
    foreach d [lsort [glob -nocomplain -directory $themesDir -type d *]] {
      lappend themes [file tail $d]
    }
  }
  return $themes
}

# ::utils::sound::SoundFile
#   Resolves the full path of a sound "name" (without the .wav extension),
#   honouring the active theme. Returns "" when the file is unavailable in
#   both the theme and the base sound folder.
proc ::utils::sound::SoundFile {name} {
  variable soundFolder
  variable soundTheme
  variable themesDir
  if {$soundTheme ne ""} {
    set themed [file join $themesDir $soundTheme "$name.wav"]
    if {[file readable $themed]} {
      return $themed
    }
  }
  set base [file join $soundFolder "$name.wav"]
  if {[file readable $base]} {
    return $base
  }
  return ""
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
    set f [SoundFile $soundFile]
    if {$f ne "" && [file readable $f]} {
      if {$backend == "snack"} {
        sound_$soundFile configure -file $f
      }
      incr count
    }
  }
  return $count
}

# ::utils::sound::GetMoveSoundFile
#   Given an untranslated SAN move string, returns the appropriate
#   sound_move_* name for moveSoundOnly mode. Priority:
#   castling > promotion > check/mate > capture > normal
proc ::utils::sound::GetMoveSoundFile {move} {
  # Castling
  if {[string range $move 0 4] == "O-O-O" || [string range $move 0 2] == "O-O"} {
    set candidate "sound_move_castling"
  } elseif {[string first "=" $move] >= 0} {
    # Promotion (e.g. e8=Q or e8=Q+)
    set candidate "sound_move_promotion"
  } elseif {[string last "+" $move] >= 0 || [string last "#" $move] >= 0} {
    # Check or checkmate
    set candidate "sound_move_check"
  } elseif {[string first "x" $move] >= 0} {
    # Capture
    set candidate "sound_move_capture"
  } else {
    set candidate "sound_move_normal"
  }
  # Fall back to generic move sound if specific file is missing
  set name [string range $candidate 6 end]
  if {[SoundFile $name] eq ""} {
    return "sound_move"
  }
  return $candidate
}

proc ::utils::sound::AnnounceMove {move} {
  variable hasSound
  variable soundMap
  
  if {! $hasSound} { return }

  # Save original move for move-type sound detection before any rewriting
  set originalMove $move
  
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
      PlaySound [GetMoveSoundFile $originalMove]
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
  # PowerShell plays asynchronously; stopping mid-playback is not practical.
  
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

  if {$isPlayingSound} { return }
  if {[llength $soundQueue] == 0} { return }
  
  set next [lindex $soundQueue 0]
  set soundQueue [lrange $soundQueue 1 end]
  set isPlayingSound 1
  
  set name [string range $next 6 end]
  set f [SoundFile $name]
  if {$f eq "" || ! [file readable $f]} {
    set isPlayingSound 0
    after idle ::utils::sound::CheckSoundQueue
    return
  }

  if {$backend == "snack"} {
    catch { $next play -blocking 0 -command ::utils::sound::SoundFinished }
    after 5000 ::utils::sound::CancelSounds
  } elseif {$backend == "scidsnd"} {
    puts $pipe "[file nativename $f]"
  } elseif {$backend == "powershell"} {
    # Windows PowerShell backend - uses .NET SoundPlayer for async playback
    set nativePath [file nativename $f]
    # Escape single quotes for PowerShell string literal (double them)
    set escapedPath [string map {' ''} $nativePath]
    set cmd "powershell -Command \"(New-Object Media.SoundPlayer '$escapedPath').PlayAsync()\""
    if {[catch { exec {*}$cmd & } err]} {
      puts stderr "scidCommunity sound error (powershell): $err"
      set isPlayingSound 0
      after idle ::utils::sound::CheckSoundQueue
      return
    }
    # PowerShell cold-start is slow (~400-600ms); delay accounts for startup + short sound
    after 600 ::utils::sound::SoundFinished
  } elseif {$backend == "afplay"} {
    catch { exec afplay $f & }
    # Increase delay to account for sound length
    after 450 ::utils::sound::SoundFinished
  } else {
    # Linux players: aplay, paplay, etc.
    # In Snap, run synchronously so we can capture errors from the live app (interfaces active).
    # For normal native builds, still background it for UI responsiveness.
    if {[info exists ::env(SNAP)]} {
      after idle [list apply {{backend f} {
        if {[catch { exec $backend $f } err]} {
          puts stderr "scidCommunity sound error ($backend): $err"
        }
        ::utils::sound::SoundFinished
      }} $backend $f]
    } else {
      if {[catch { exec $backend $f & } err]} {
        puts stderr "scidCommunity sound error ($backend): $err"
      }
      after 450 ::utils::sound::SoundFinished
    }
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

# ::utils::sound::ThemeValues
#   Display labels for the theme dropdown: the "Default" entry first, followed
#   by each available theme folder name.
proc ::utils::sound::ThemeValues {} {
  return [concat [list [tr SoundsThemeDefault]] [::utils::sound::ListThemes]]
}

# ::utils::sound::ThemeIndex
#   Index into ThemeValues for the given theme ("" selects the default entry).
proc ::utils::sound::ThemeIndex {theme} {
  set themes [::utils::sound::ListThemes]
  if {$theme eq ""} { return 0 }
  set i [lsearch -exact $themes $theme]
  if {$i < 0} { return 0 }
  return [expr {$i + 1}]
}

# ::utils::sound::ApplyTheme
#   Sets the active sound theme and re-reads the sound files so the Snack
#   backend points at the themed files. The other backends resolve files at
#   play time via SoundFile, so they pick up the change immediately.
proc ::utils::sound::ApplyTheme {theme} {
  variable soundTheme
  set soundTheme $theme
  catch { ::utils::sound::ReadFolder }
}

proc ::utils::sound::OnThemeSelected { w } {
  set idx [$w current]
  if {$idx <= 0} {
    ::utils::sound::ApplyTheme ""
  } else {
    set themes [::utils::sound::ListThemes]
    ::utils::sound::ApplyTheme [lindex $themes [expr {$idx - 1}]]
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
    ttk::frame $w.themeRow
    ttk::label $w.themeRow.l -text [tr SoundsTheme]
    ttk::combobox $w.themeRow.c -state readonly -values [::utils::sound::ThemeValues] -width 20
    $w.themeRow.c current [::utils::sound::ThemeIndex $::utils::sound::soundTheme]
    bind $w.themeRow.c <<ComboboxSelected>> [list ::utils::sound::OnThemeSelected $w.themeRow.c]
    ttk::label $w.themeHelp -text [tr SoundsThemeHelp]
    pack $w.themeRow.l $w.themeRow.c -side left -anchor w -padx "0 5"
    pack $w.themeRow -side top -anchor w -pady "2 0"
    pack $w.themeHelp -side top -anchor w
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
