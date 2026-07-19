# ::file::Exit
#
#    Prompt for confirmation then exit.
#
proc ::file::Exit {}  {
  # Check for altered game in all bases except the clipbase:
  set unsavedCount 0
  set savedBase [sc_base current]
  set msg ""
  foreach i [sc_base list] {
    sc_base switch $i
    if {[sc_game altered] && ![sc_base isReadOnly $i]} {
      if {$unsavedCount == 0} {
        append msg $::tr(ExitUnsaved)
        append msg "\n\n"
      }
      incr unsavedCount
      set fname [::file::BaseName $i]
      set g [sc_game number]
      append msg "   Base $i: $fname "
      append msg "($::tr(game) $g)"
      append msg "\n"
    }
  }
  # Switch back to original database:
  sc_base switch $savedBase

  # Check if a mask is opened and dirty
  ::tree::mask::close

  if {$msg != ""} {
    append msg "\n"
  }
  append msg $::tr(ExitDialog)

  # Only ask before exiting if there are unsaved changes:
  if {$unsavedCount > 0} {
    set answer [tk_messageBox -title "scidCommunity: [tr FileExit]" \
        -message $msg -type yesno -icon question]
    if {$answer != "yes"} { return }
  }
  if {$::optionsAutoSave} {
    options.write
  }
  ::recentFiles::save
  ::utils::history::Save
  destroy .
}


# ::file::New
#
#   Opens file-save dialog and creates a new database.
#
proc ::file::New {} {
  set ftype {
    { "Scid5 databases" {".si5"} }
    { "PGN files" {".pgn" ".PGN"} }
    { "Scid4 databases" {".si4"} }
  }

  set fName [tk_getSaveFile \
             -initialdir $::initialDir(base) \
             -filetypes $ftype \
             -defaultextension ".si5" \
             -title "Create a Scid database"]

  if {$fName == ""} { return }
  set file_extension [string tolower [file extension $fName]]
  if {$file_extension == ".si5"} {
    set dbType "SCID5"
  } elseif {$file_extension == ".si4"} {
    set dbType "SCID4"
  } elseif {$file_extension == ".pgn"} {
    set dbType "PGN"
  }
  if {[catch {sc_base create $dbType $fName} baseId]} {
    ERROR::MessageBox "$fName\n"
    return
  }
  set ::curr_db $baseId
  set ::initialDir(base) [file dirname $fName]
  ::recentFiles::add $fName
  ::windows::gamelist::Open $::curr_db
  ::notify::DatabaseChanged
  ::notify::GameChanged
  return $baseId
}

# ::file::Open
#
#    Opens file-open dialog and opens the selected Scid database.
#
proc ::file::Open {{fName ""}} {
  if {$fName == ""} {
      set ftype {
        { "All Scid files" {".si5" ".si4" ".si3" ".pgn" ".epd"} }
        { "Scid databases" {".si5" ".si4" ".si3"} }
        { "PGN files" {".pgn" ".PGN"} }
        { "EPD files" {".epd" ".EPD"} }
      }

    set fName [tk_getOpenFile -initialdir $::initialDir(base) -filetypes $ftype -title "Open a Scid file"]
  }
  set err [::file::Open_ "$fName"]
  if {$err == 2 && [string tolower [file extension "$fName"]] == ".epd"} {
    set ::initialDir(base) [file dirname "$fName"]
    ::recentFiles::add "$fName"
    return 2
  }
  if {$err == 0} {
    set ::initialDir(base) [file dirname "$fName"]
    ::recentFiles::add "$fName"
    set ::curr_db $::file::lastOpened
    ::windows::gamelist::Open $::curr_db
    ::notify::DatabaseChanged
    set gamenum 0
    foreach {tagname tagvalue} [sc_base extra $::curr_db] {
      if {$tagname eq "autoload" && [string is integer -strict $tagvalue] && $tagvalue > 0} {
        set gamenum $tagvalue
        break
      }
    }
    
    if {[sc_base numGames $::curr_db] > 0} {
      set sortStr ""
      foreach w $::windows::gamelist::wins {
        if {$::gamelistBase($w) == $::curr_db && [info exists ::glistSortStr($w.games.glist)]} {
          set sortStr [string trim $::glistSortStr($w.games.glist)]
          break
        }
      }
      
      # If there is a custom sort order (i.e. not default "0 +"), override the autoload game
      # with the first game from that sorted result.
      if {$sortStr != "" && $sortStr != "0 +"} {
        if {[catch {sc_base gameslist $::curr_db 0 1 "dbfilter" $sortStr} topGameRes] == 0} {
          if {[llength $topGameRes] >= 3} {
            set idx [lindex $topGameRes 0]
            lassign [split $idx "_"] gn ply
            if {[string is integer -strict $gn] && $gn > 0} {
              set gamenum $gn
            }
          }
        }
      }
    }

    if {$gamenum == 0} { set gamenum 1 }

    if {$gamenum <= [sc_base numGames $::curr_db]} {
      ::game::Load $gamenum 0
    } else {
      ::notify::GameChanged
    }
  }
  return $err
}

# Open a database or switch to it if it is already open.
proc ::file::OpenOrSwitch { fname } {
  set slot [sc_base slot $fname]
  if {$slot != 0} {
    return [::file::SwitchToBase $slot]
  }
  return [::file::Open "$fname"]
}

proc ::file::openBaseAsTree { { fName "" } } {
  set current [sc_base current]
  set err [::file::Open $fName]
  if {$err == 0} {
    ::file::SwitchToBase $current
    ::tree::make $::file::lastOpened 1
  }
  return $err
}

proc ::file::Open_ {fName } {
  if {$fName == ""} { return 2}

  set ext [string tolower [file extension "$fName"] ]
  if {[sc_base slot $fName] != 0} {
    tk_messageBox -title "scidCommunity: opening file" -message "The database you selected is already opened."
    return 1
  }

  set err 0
  if {"$ext" == ".si3"} {
    set err [::file::Upgrade [file rootname "$fName"] ]
  } elseif {"$ext" == ".pgn"} {
    # PGN file:
    set tip "[tr Tip]:\n[tr TipConvertPGN]\n([tr Database] -> [tr CopyAllGames] -> [tr FileNew])"
    progressWindow "scidCommunity" "$::tr(OpeningTheDatabase): $fName...\n\n$tip" $::tr(Cancel)
    set err [catch {sc_base open PGN "$fName"} ::file::lastOpened]
    closeProgressWindow
    if {$err} {
      ERROR::MessageBox "$fName\n"
    } else {
      catch { sc_base extra $::file::lastOpened type 3 }
    }
  } elseif {"$ext" == ".epd"} {
    # EPD file: open in dedicated EPD editor window.
    if {[::epd::newEpdWin open "$fName"]} {
      return 2
    }
    return 1
  } else {
    if {$ext == ".si5" || $ext eq ""} {
      set dbType "SCID5"
    } elseif {$ext == ".si4"} {
      set dbType "SCID4"
    } else {
      tk_messageBox -title "scidCommunity: opening file" -message "Unsupported database format:  $ext"
      return 1;
    }
    progressWindow "scidCommunity" "$::tr(OpeningTheDatabase): [file tail "$fName"]..." $::tr(Cancel)
    set err [catch {sc_base open $dbType $fName} ::file::lastOpened]
    closeProgressWindow
    if {$err} {
      if { $::errorCode == $::ERROR::NameDataLoss } { set err 0 }
      ERROR::MessageBox "$fName\n"
    }
  }

  return $err
}

# ::file::Upgrade
#
#   Upgrades an old (version 3) Scid database to version 4.
#
proc ::file::Upgrade {name} {
  if {[file readable "$name.si4"]} {
    set msg [string trim $::tr(ConfirmOpenNew)]
    set res [tk_messageBox -title "scidCommunity" -type yesno -icon info -message $msg]
    if {$res == "no"} { return }
    return [::file::Open_ "$name.si4"]
  }

  set msg [string trim $::tr(ConfirmUpgrade)]
  set res [tk_messageBox -title "scidCommunity" -type yesno -icon info -message $msg]
  if {$res == "no"} { return }

  set err [catch {
    file copy "$name.sg3"  "$name.sg4"
    file copy "$name.sn3"  "$name.sn4"
    file copy "$name.si3"  "$name.si4" }]
  if {$err} {
    ERROR::MessageBox "$name\n"
    return 1
  }

  progressWindow "scidCommunity" "$::tr(Opening): [file tail $name]..." $::tr(Cancel)
  set err [catch {sc_base open $name} ::file::lastOpened]
  closeProgressWindow
  if {$::errorCode == $::ERROR::NameDataLoss} {
    ERROR::MessageBox "$name\n"
    set err 0
  }
  if {$err} {
    ERROR::MessageBox "$name\n"
    catch {
      file delete "$name.sg4"
      file delete "$name.sn4"
      file delete "$name.si4" }
  } else {
    progressWindow "scidCommunity" [concat $::tr(CompactDatabase) "..."] $::tr(Cancel)
    set err_compact [catch {sc_base compact $::file::lastOpened}]
    closeProgressWindow
    if {$err_compact} { ERROR::MessageBox }
  }
  return $err
}

# ::file::Close:
#   Closes the active base.
#
proc ::file::Close {{base -1}} {
  # Remember the current base:
  set current [sc_base current]
  if {$base < 0} { set base $current }
  if {![sc_base inUse $base]} { return }
  # Switch to the base which will be closed, and check for changes:
  sc_base switch $base
  set confirm [::game::ConfirmDiscard]
  if {$confirm == 0} {
    sc_base switch $current
    return
  }
  # Close Tree window whenever a base is closed/switched:
  if {[winfo exists .treeWin$base]} { destroy .treeWin$base }

  ::search::CloseAll

  # If base to close was the current one, reset to clipbase
  if { $current == $base } { set current 9 }

  if {[catch {sc_base close $base}]} {
    ERROR::MessageBox
  }

  if {$confirm == 2} { ::notify::DatabaseModified $::clipbase_db }

  # Now switch back to the original base
  ::file::SwitchToBase $current 0
}

proc ::file::SwitchToBase {{b} {saveHistory 1}} {
  if {$b == [sc_base current]} { return 1 }

  set err 1
  if {![catch {sc_base switch $b} res]} {
    set err 0
    set ::curr_db $res
  }
  ::notify::GameChanged
  ::notify::DatabaseChanged
  return $err
}

proc ::file::BaseName {baseIdx} {
  set fname [file tail [sc_base filename $baseIdx]]
  set ext [string tolower [file extension $fname] ]
  if {$ext == ".si5"} {
    return [file rootname $fname]
  }
  return $fname
}

# Databases that will be automatically loaded ad startup
proc ::file::autoLoadBases.load {} {
  if {![info exists ::autoLoadBases]} { return }
  foreach base $::autoLoadBases {
    set err [::file::Open $base]
    if {$err != 0 && $err != 2} {
      set idx [lsearch -exact $::autoLoadBases $base]
      if {$idx != -1} { set ::autoLoadBases [lreplace $::autoLoadBases $idx $idx] }
    }
  }
}

proc ::file::autoLoadBases.save { {channelId} } {
  if {![info exists ::autoLoadBases]} { return }
  puts $channelId "set ::autoLoadBases [list $::autoLoadBases]"
}
proc ::file::autoLoadBases.find { {baseIdx} } {
  if {![info exists ::autoLoadBases]} { return -1 }
  if {[ catch {set base [sc_base filename $baseIdx]} ]} { return -1}
  return [lsearch -exact $::autoLoadBases $base]
}
proc ::file::autoLoadBases.add { {baseIdx} } {
  if {[ catch {set base [sc_base filename $baseIdx]} ]} { return }
  lappend ::autoLoadBases $base
}
proc ::file::autoLoadBases.remove { {baseIdx} } {
  if {![info exists ::autoLoadBases]} { return -1 }
  if {[ catch {set base [sc_base filename $baseIdx]} ]} { return }
  set idx [lsearch -exact $::autoLoadBases $base]
  if {$idx != -1} {
    set ::autoLoadBases [lreplace $::autoLoadBases $idx $idx]
  }
  return $idx
}

proc RegisterDropEvents {target} {
  if {$::macOS} {return}
  ::tkdnd::drop_target register $target DND_Files
  bind $target <<DropEnter>> { HandleDropEvent enter %W}
  bind $target <<DropLeave>> { HandleDropEvent leave %W}
  bind $target <<Drop>> { HandleDropEvent %D %W}
}

proc HandleDropEvent {action window} {
  switch $action {
    enter  {}
    leave  {}
    default {
      after idle [namespace code [list OpenUri $window $action]]
    }
  }
  return copy
}

proc OpenUri {window uriFiles} {
  raiseWin [winfo toplevel $window]
  update idletasks

  set errorList {}
  set rejectList {}
  set databaseList {}
  set filelist $uriFiles

  foreach file $filelist {
    set uri [string trimright $file]
    set file $uri
    if {[string length $file]} {
      if {[string equal -length 5 $file "file:"]} {
        if {[string equal -length 17 $file "file://localhost/"]} {
          set file [string range $file 16 end]
        } elseif {[string equal -length 8 $file "file:///"]} {
          set file [string range $file 7 end]
        } elseif {[string index $file 5] eq "/"} {
          set file [string range $uri 5 end]
          for {set n 1} {$n < 5} {incr n} { if {[string index $file $n] eq "/"} { break } }
          set file [string range $uri [expr {$n - 1}] end]
          if {![file exists $file]} {
            set i [string first "/" $file 1]
            if {$i >= 0} {
              set f [string range $file $i end]
              if {[file exists $f]} { set file $f }
            }
          }
        } else {
          set file [string range $file 5 end]
        }
      }
      set file [file normalize $file]
    }
    if {[file exists $file]} {
      lappend databaseList $file
    }
  }

  foreach file $databaseList {
    ::file::Open $file
  }

  if {[llength $errorList]} {
    if {[string match file:* $uriFiles] && [llength $databaseList] == 0} {
      set message [tr DndCannotOpenUri]
      if {[llength $errorList] > 10} {
        append message \n\n [join [lrange $errorList 0 9] \n]
        append message \n...
      } else {
        append message \n\n [join $errorList \n]
      }
    } else {
      set message [tr DndInvalidUri]
    }
    tk_messageBox -icon warning -type ok -parent . -message $message
  }

  if {[llength $rejectList]} {
    set message [tr DndUriRejected]
    if {[llength $rejectList] > 10} {
      append message \n\n [join [lrange $rejectList 0 9] \n]
      append message \n...
    } else {
      append message \n\n [join $rejectList \n]
    }
    set detail [tr DndUriRejectedDetail]
    tk_messageBox -icon info -type ok -parent . -message $message -detail $detail
  }

  if {[llength $databaseList] + [llength $rejectList] + [llength $errorList] == 0} {
    set message [tr DndEmptyUriList]
    tk_messageBox -icon info -type ok -parent . -message $message
  }
}

proc bgerror {err} {
  if {$err eq "selection owner didn't respond"} {
    set parent [::tkdnd::get_drop_target]
    if {[llength $parent] == 0} { set parent . }
    after idle [list tk_messageBox \
      -icon error \
      -parent $parent \
      -message [tr DndOwnerDidntRespond] \
    ]
  } elseif {[string match {*selection doesn't exist*} $err]} {
  } else {
    ERROR::Error $err
  }
}
