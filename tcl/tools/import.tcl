###
### import.tcl: part of Scid.
### Copyright (C) 2000  Shane Hudson.
###

### Import game window

proc importPgnGame {} {
  if {[winfo exists .importWin]} { return }
  set w .importWin
  win::createDialog $w
  wm title $w "scidCommunity: $::tr(ImportPGN)"
  wm minsize $w 50 5
  ttk::frame $w.b
  pack $w.b -side bottom -fill x
  set pane [::utils::pane::Create $w.pane edit err 580 300 0.8]
  pack $pane -side top -expand true -fill both
  set edit $w.pane.edit
  autoscrollText both $edit.f $edit.text Treeview
  $edit.text configure -height 12 -width 80 -wrap none -setgrid 1 -state normal
  # Override tab-binding for this widget:
  bind $edit.text <Key-Tab> "[bind all <Key-Tab>]; break"
  grid $edit.f -row 0 -column 0 -sticky nesw
  grid rowconfig $edit 0 -weight 1 -minsize 0
  grid columnconfig $edit 0 -weight 1 -minsize 0
  
  # Right-mouse button cut/copy/paste menu:
  menu $edit.text.rmenu -tearoff 0
  $edit.text.rmenu add command -label "Cut" -command "tk_textCut $edit.text"
  $edit.text.rmenu add command -label "Copy" -command "tk_textCopy $edit.text"
  $edit.text.rmenu add command -label "Paste" -command "tk_textPaste $edit.text"
  $edit.text.rmenu add command -label "Select all" -command "$edit.text tag add sel 1.0 end"
  bind $edit.text <ButtonPress-$::MB3> "tk_popup $edit.text.rmenu %X %Y"
  
  autoscrollText y $pane.err.f $pane.err.text Treeview
  $pane.err.text configure -height 4 -width 75 -wrap word -setgrid 1 -state normal
  $pane.err.text insert end $::tr(ImportHelp1)
  $pane.err.text insert end "\n"
  $pane.err.text insert end $::tr(ImportHelp2)
  $pane.err.text configure -state disabled
  pack $pane.err.f -side left -expand true -fill both

  ttk::button $w.b.paste -text "$::tr(PasteCurrentGame) (Alt-P)" -command {
    .importWin.pane.edit.text delete 1.0 end
    setLanguageTemp E
    .importWin.pane.edit.text insert end [sc_game pgn -width 70]
    setLanguageTemp $::language
    .importWin.pane.err.text configure -state normal
    .importWin.pane.err.text delete 1.0 end
    .importWin.pane.err.text configure -state disabled
  }
  ttk::button $w.b.clear -text "$::tr(Clear) (Alt-C)" -command {
    .importWin.pane.edit.text delete 1.0 end
    .importWin.pane.err.text configure -state normal
    .importWin.pane.err.text delete 1.0 end
    .importWin.pane.err.text configure -state disabled
  }
  ttk::button $w.b.ok -text "$::tr(Import) (Alt-I)" -command {
    if {[::game::Clear] eq "cancel"} { return }
    set err [catch {sc_game import \
          [.importWin.pane.edit.text get 1.0 end]} result]
    .importWin.pane.err.text configure -state normal
    .importWin.pane.err.text delete 1.0 end
    .importWin.pane.err.text insert end $result
    .importWin.pane.err.text configure -state disabled
    if {! $err} {
      flipBoardForPlayerNames
      ::notify::GameChanged
    }
  }
  ttk::button $w.b.cancel -textvar ::tr(Close) -command {
    destroy .importWin; focus .
  }
  pack $w.b.paste $w.b.clear -side left -padx 5 -pady "15 5"
  packdlgbuttons $w.b.cancel $w.b.ok
  # Paste the current selected text automatically:
  # if {[catch {$w.pane.edit.text insert end [selection get]}]} {
  # ?
  # }
  # Select all of the pasted text:
  $w.pane.edit.text tag add sel 1.0 end
  
  bind $w <F1> { helpWindow Import }
  bind $w <Alt-i> { .importWin.b.ok invoke }
  bind $w <Alt-p> { .importWin.b.paste invoke }
  bind $w <Alt-c> { .importWin.b.clear invoke }
  bind $w <Escape> { .importWin.b.cancel invoke }
  # bind $w.pane.edit.text <Any-KeyRelease> { .importWin.b.ok invoke }
  focus $w.pane.edit.text
}


proc importClipboardGame {} {
  importPgnGame
  set w .importWin.pane.edit.text
  catch {event generate $w <<Paste>>}
  # Paste the current selected text automatically if no data was pasted from clipboard:
  # Tk's own paste only asks for the STRING target, which Wayland clipboard
  # owners may refuse, so fall back to the target-aware helper.
  if { [ $w get 1.0 end ] == "\n" } {
    set clipText [::utils::getClipboardText]
    if {$clipText ne ""} {
      $w insert end $clipText
    }
  }
}

proc importPgnLine {line} {
  importPgnGame
  set w .importWin.pane.edit.text
  $w delete 1.0 end
  $w insert end $line
  $w tag add sel 1.0 end
  focus $w
}

################################################################################
#
################################################################################
proc importMoveList {line} {
  sc_move start
  sc_move addSan $line
  updateBoard -pgn
}
################################################################################
#
################################################################################
proc importMoveListTrans {line} {
  set doImport 0
    if {[llength [sc_game firstMoves 1]] == 0} {
      set doImport 1
    } elseif {[tk_messageBox -message [::tr "OverwriteExistingMoves"] -type yesno -icon question ] == yes} {
      set doImport 1
    }
  if {$doImport} {
    set line [untrans $line]
    sc_move start
    sc_move addSan $line
    updateBoard -pgn
  }
}


### The log window of a file import: a progress bar, Stop and Close, and the
### text widget $w.text. It stays busy until importLogDone.
proc importLogWindow {w title} {
  if {[winfo exists $w]} { destroy $w }
  win::createDialog $w
  wm title $w "scidCommunity: $title"

  ttk::frame $w.buttons
  canvas $w.progress -width 400 -height 20 -bg white -relief solid -border 1 -highlightthickness 0
  $w.progress create rectangle 0 0 0 0 -fill DodgerBlue3 -outline DodgerBlue3 -tags bar
  $w.progress create text 395 10 -anchor e -font font_Regular -tags time \
    -fill black -text "0:00 / 0:00"

  ttk::button $w.buttons.stop -textvar ::tr(Stop) -command { progressBarCancel}
  ttk::button $w.buttons.close -textvar ::tr(Close) -state disabled -command "
    focus .
    destroy $w
  "
  grid $w.progress $w.buttons.stop $w.buttons.close -in $w.buttons
  grid rowconfigure $w.buttons 0 -weight 1
  grid columnconfigure $w.buttons 0 -weight 1

  autoscrollText both $w.t $w.text TLabel
  $w.text configure -wrap none
  grid $w.t -pady {0 10} -sticky news
  grid $w.buttons -sticky news
  grid rowconfigure $w 0 -weight 1
  grid columnconfigure $w 0 -weight 1

  grab $w.buttons.stop

  busyCursor .
}

proc importLogDone {w} {
  unbusyCursor .
  $w.text configure -state disabled
  $w.buttons.close configure -state normal
  $w.buttons.stop configure -state disabled
  grab release $w.buttons.stop
}

### Import one file into <base>, writing the outcome to the log window <w>.
#   Returns {code clean}: code is 0 (done), 1 (error) or 3 (interrupted),
#   clean is false when there is something the user should read.
proc importFileToBase {w base fname} {
  $w.text insert end "$::tr(ImportingFrom) [file tail $fname]...\n"
  set ext [string tolower [file extension $fname]]
  if {$ext eq ".cbh"} {
    # Not readable yet, and read as PGN it would give garbage.
    $w.text insert end "[tr CbhNotSupported]\n\n"
    return {1 0}
  }
  $w.text configure -state disabled
  progressBarSet $w.progress 401 21
  set cb2 [expr {$ext eq ".2cbh"}]
  if {$cb2} {
    # shortcut: no duplicate check for a ChessBase database (importGamesNoDup
    # reads PGN only), fine for importing into a new base; add it if asked.
    set err [catch {sc_base import $base $fname} result]
    if {$err == 0} {
      lassign $result nImported warnings
      set result [list $nImported 0 0 $warnings]
    }
  } else {
    set err [catch {sc_base import_nodup $base $fname} result]
  }
  $w.text configure -state normal
  if {$err == 1} {
    $w.text insert end "[ERROR::getErrorMsg]\n$result\n\n"
    return {1 0}
  }
  lassign $result nImported nSkipped nUpdated warnings
  set str "[tr Imported] $nImported "
  if {$nImported == 1} { append str [tr game] } else { append str [tr games] }
  if {$nSkipped > 0} {
    append str ", [tr Skipped] $nSkipped "
    if {$nSkipped == 1} { append str [tr DuplicateGame] } else { append str [tr DuplicateGames] }
  }
  if {$nUpdated > 0} {
    append str ", [tr Updated] $nUpdated "
    if {$nUpdated == 1} { append str [tr game] } else { append str [tr games] }
  }
  if {$warnings == ""} {
    append str " [tr [expr {$cb2 ? "NoImportErrorsWarnings" : "NoPgnErrorsWarnings"}]]"
  } else {
    append str ".\n[tr [expr {$cb2 ? "ImportErrorsWarnings" : "PgnErrorsWarnings"}]]\n$warnings"
  }
  $w.text insert end "$str\n\n"
  if {$err == 3} {
    $w.text insert end ".\nINTERRUPTED\n"
    return {3 0}
  }
  return [list 0 [expr {$warnings == ""}]]
}

### Import file of Pgn or ChessBase games:
proc importPgnFile {{base} {fnames ""}} {
  if {$fnames == ""} {
    set ftypes [list [list [tr PgnAndChessBase] {.pgn .PGN .2cbh .2CBH .cbh .CBH}]]
    lappend ftypes { "Portable Game Notation files" {".pgn" ".PGN"} }
    lappend ftypes [list [tr ChessBaseDatabases] {.2cbh .2CBH .cbh .CBH}]
    lappend ftypes { "Text files" {".txt" ".TXT"} }
    lappend ftypes { "All files" {"*"} }

    set fnames [tk_getOpenFile -multiple 1 -initialdir $::initialDir(pgn) -filetypes $ftypes -title "$::tr(ImportingIn) [file tail [sc_base filename $base] ]" ]
    if {$fnames == ""} { return }
    set ::initialDir(pgn) [file dirname [lindex $fnames 0]]
    set autoclose 0
  } else {
    set autoclose 1
  }
  
  set w .ipgnWin
  importLogWindow $w "$::tr(ImportingFiles) [file tail [sc_base filename $base] ]"
  foreach fname $fnames {
    lassign [importFileToBase $w $base $fname] err clean
    if {!$clean} { set autoclose 0 }
    if {$err == 3} { break }
  }
  importLogDone $w

  after idle "::notify::DatabaseModified $base"
  if { $autoclose } { destroy $w }
}

### Convert a folder of PGN and ChessBase files into Scid databases.

# The .pgn and .2cbh files under <dir>, each as {path relativeDir}.
proc importFolderFiles {dir {rel ""}} {
  set found {}
  foreach f [glob -nocomplain -directory $dir -types f *] {
    if {[string tolower [file extension $f]] in {.pgn .2cbh}} {
      lappend found [list $f $rel]
    }
  }
  foreach d [glob -nocomplain -directory $dir -types d *] {
    # A link to a parent folder would recurse for ever.
    if {[file type $d] eq "link"} { continue }
    lappend found {*}[importFolderFiles $d [file join $rel [file tail $d]]]
  }
  return $found
}

# What to convert: a list of {sourceFile targetStem}, one database each.
# With <flatten> every database goes into <dest>, otherwise into the same
# subfolder as its source. A name already taken gets _2, _3...; names are
# compared ignoring case, as Windows and macOS do.
proc importFolderPlan {src dest flatten} {
  set plan {}
  set taken [dict create]
  foreach item [lsort -index 0 [importFolderFiles $src]] {
    lassign $item f rel
    if {$flatten} { set rel "" }
    set stem [file join $dest $rel [file rootname [file tail $f]]]
    set target $stem
    for {set n 2} {[dict exists $taken [string tolower $target]]} {incr n} {
      set target "${stem}_$n"
    }
    dict set taken [string tolower $target] 1
    lappend plan [list $f $target]
  }
  return $plan
}

# Create one SCID5 database for each planned file. A database that is already
# there is left alone, so converting again after Stop resumes the work.
proc importFolderRun {src dest flatten} {
  set plan [importFolderPlan $src $dest $flatten]
  set prev [sc_base current]
  set w .ipgnWin
  importLogWindow $w [tr ConvertFolderTitle]
  set created 0
  set skipped 0
  set failed 0
  foreach item $plan {
    lassign $item f target
    # The extension is explicit: sc_base would take the ".v2" of a name
    # like "games.v2" as the index file's own extension.
    set si5 "$target.si5"
    if {[file exists $si5]} {
      incr skipped
      $w.text configure -state normal
      $w.text insert end "[file tail $si5]: [tr AlreadyExistsSkipped]\n\n"
      continue
    }
    $w.text configure -state normal
    if {[catch {
      file mkdir [file dirname $target]
      set base [sc_base create SCID5 $si5]
    } msg]} {
      incr failed
      $w.text insert end "$si5\n[ERROR::getErrorMsg]\n$msg\n\n"
      continue
    }
    set ::progressCanvas(cancel) 0
    lassign [importFileToBase $w $base $f] err
    sc_base close $base
    if {$err == 0} {
      incr created
    } else {
      # Do not keep a partial database: the next run would skip it. These
      # files are new, since create fails if any of them exists.
      file delete -- $si5 "$target.sg5" "$target.sn5"
      if {$err == 1} { incr failed }
    }
    # A small file may import without a progress report, so handle a click
    # on Stop here, before the next file resets the cancel flag.
    update
    if {$err == 3 || $::progressCanvas(cancel)} { break }
  }
  if {[catch { sc_base switch $prev }]} {
    catch { sc_base switch [sc_info clipbase] }
  }
  $w.text configure -state normal
  $w.text insert end "[format [tr ConvertFolderDone] $created $skipped $failed]\n"
  $w.text see end
  importLogDone $w
}

# The window asking what to convert, where to and how.
proc importFolder {} {
  set w .convertFolderWin
  if {[winfo exists $w]} { raise $w; return }
  win::createDialog $w
  wm title $w "scidCommunity: [tr ConvertFolderTitle]"
  if {![info exists ::importFolderOpt(src)]} {
    array set ::importFolderOpt [list src "" dest "" flatten 0]
  }

  ttk::frame $w.f -padding 10
  pack $w.f -side top -fill both -expand 1
  set row 0
  foreach {key label initial} {src SourceFolder pgn dest DestinationFolder base} {
    ttk::label $w.f.l$key -text [tr $label]
    ttk::entry $w.f.e$key -textvariable ::importFolderOpt($key) -width 50
    ttk::button $w.f.b$key -text [tr Browse] \
      -command [list importFolderBrowse $w $key $initial]
    grid $w.f.l$key $w.f.e$key $w.f.b$key -row $row -sticky ew -pady 3 -padx 3
    incr row
  }
  foreach {value label} {0 KeepFolderStructure 1 AllInOneFolder} {
    ttk::radiobutton $w.f.r$value -text [tr $label] \
      -variable ::importFolderOpt(flatten) -value $value
    ttk::label $w.f.h$value -text [tr ${label}Help] -wraplength 450
    grid $w.f.r$value -row $row -columnspan 3 -sticky w -pady {8 0}
    grid $w.f.h$value -row [incr row] -columnspan 3 -sticky w -padx {24 0}
    incr row
  }
  ttk::label $w.f.note -text [tr ConvertFolderNote] -wraplength 480
  grid $w.f.note -row $row -columnspan 3 -sticky w -pady {12 0}
  grid columnconfigure $w.f 1 -weight 1

  ttk::frame $w.buttons
  pack $w.buttons -side bottom -fill x
  ttk::button $w.buttons.ok -text [tr Convert] -default active \
    -command [list importFolderStart $w]
  ttk::button $w.buttons.cancel -text [tr Cancel] -command [list destroy $w]
  packdlgbuttons $w.buttons.cancel $w.buttons.ok
  bind $w <Return> [list $w.buttons.ok invoke]
  bind $w <Escape> [list $w.buttons.cancel invoke]
  focus $w.f.esrc
}

proc importFolderBrowse {w key initial} {
  set start $::importFolderOpt($key)
  if {$start eq ""} { set start $::initialDir($initial) }
  set dir [tk_chooseDirectory -parent $w -initialdir $start -mustexist 1]
  if {$dir ne ""} { set ::importFolderOpt($key) $dir }
}

proc importFolderStart {w} {
  set src $::importFolderOpt(src)
  set dest $::importFolderOpt(dest)
  # "file isdirectory" is false for an empty name.
  if {![file isdirectory $src] || ![file isdirectory $dest]} {
    tk_messageBox -parent $w -icon warning -type ok \
      -title [tr ConvertFolderTitle] -message [tr ChooseBothFolders]
    return
  }
  destroy $w
  importFolderRun $src $dest $::importFolderOpt(flatten)
}

### Import a PGN file into a chosen database, skipping duplicate games.
#
#   Prompts the user to pick a destination database (the clipbase or any
#   open, writable database) and imports the PGN file into it. Games whose
#   normalized White and Black players, exact Date, Result and exact move
#   sequence all match a game already present (or an earlier game in the
#   same batch) are skipped. If the only matching game is marked for
#   deletion, it is restored instead of importing a duplicate. If the same
#   online game (chess.com Link or Lichess Site URL) is present with a
#   different move list or Result, that game is updated instead of adding a
#   second copy.
#
#   Reports the outcome itself (success summary, import error, or the
#   "no writable database" message) and returns 1 on success, 0 otherwise
#   (cancelled, no writable database, or import failure). It never raises.
#
#   If <strip> is non-empty ("comments", "commentsnonag", "variations" or
#   "all"), the newly imported and updated games have that content stripped as
#   part of the import, using the same routine as the Game List batch strip
#   feature.

# importStripGames:
#   Build the "game_0" list to pass to ::game::StripSelected: appended games
#   plus games that an import updated in place, without duplicates.
proc importStripGames {numBefore numAfter updatedGames} {
  set seen [dict create]
  set games {}
  for {set g [expr {$numBefore + 1}]} {$g <= $numAfter} {incr g} {
    set item "${g}_0"
    if {![dict exists $seen $item]} {
      dict set seen $item 1
      lappend games $item
    }
  }
  foreach g $updatedGames {
    set item "${g}_0"
    if {![dict exists $seen $item]} {
      dict set seen $item 1
      lappend games $item
    }
  }
  return $games
}
proc importPgnNoDup {pgnfile title {strip ""}} {
  set bases {}
  foreach i [sc_base list] {
    if {[sc_base isReadOnly $i]} { continue }
    if {$i == $::clipbase_db} {
      lappend bases [list $i [tr Clipbase]]
    } else {
      lappend bases [list $i "Base $i: [::file::BaseName $i]"]
    }
  }
  if {[llength $bases] == 0} {
    tk_messageBox -icon error -type ok -title $title \
      -message [tr NoWritableDatabases]
    return 0
  }

  set w .importBaseDialog
  if {[winfo exists $w]} { destroy $w }
  toplevel $w
  wm title $w $title
  wm resizable $w 0 0
  setWinLocation $w

  # Default to the current database if it is writable, else the first one.
  set ::importBaseChoice [lindex [lindex $bases 0] 0]
  if {$::curr_db != $::clipbase_db && ![sc_base isReadOnly $::curr_db]} {
    set ::importBaseChoice $::curr_db
  }

  ttk::frame $w.content -padding {10 10}
  ttk::label $w.content.lbl -text [tr ImportInto] -anchor w
  pack $w.content.lbl -side top -anchor w -pady {0 6}
  foreach b $bases {
    lassign $b baseId label
    ttk::radiobutton $w.content.rb$baseId -text $label \
      -variable ::importBaseChoice -value $baseId
    pack $w.content.rb$baseId -side top -anchor w
  }
  pack $w.content -side top -fill both -expand 1

  ttk::frame $w.buttons -padding {10 10}
  ttk::button $w.buttons.ok -text [tr Import] -command "set ::importBaseResult 1; destroy $w"
  ttk::button $w.buttons.cancel -text [tr Cancel] -command "set ::importBaseResult 0; destroy $w"
  pack $w.buttons.ok $w.buttons.cancel -side left -padx 5
  pack $w.buttons -side top -fill x

  set ::importBaseResult 0
  bind $w <Return> "$w.buttons.ok invoke"
  bind $w <Escape> "$w.buttons.cancel invoke"
  grab $w
  tkwait window $w

  if {!$::importBaseResult} { return 0 }
  set base $::importBaseChoice

  # Newly imported games are appended at the end of the database, so the games
  # to strip (if requested) are exactly the contiguous range of game numbers
  # between the count before and after the import.
  set numBefore 0
  if {$strip ne ""} {
    set numBefore [sc_base numGames $base]
  }

  progressWindow "scidCommunity" "$::tr(ImportingIn) [::file::BaseName $base]..." $::tr(Cancel)
  set err [catch {sc_base import_nodup $base $pgnfile} result]
  closeProgressWindow true
  if {$err} {
    ERROR::MessageBox
    return 0
  }

  set nImported [lindex $result 0]
  set nSkipped  [lindex $result 1]
  set nUpdated  [lindex $result 2]
  set warnings  [lindex $result 3]
  set updatedGames [lindex $result 4]

  if {$strip ne "" && ($nImported > 0 || $nUpdated > 0)} {
    set numAfter [sc_base numGames $base]
    set games [importStripGames $numBefore $numAfter $updatedGames]
    ::game::StripSelected $base $games $strip 0
  }

  after idle "::notify::DatabaseModified $base"

  set msg "[tr Imported] $nImported "
  if {$nImported == 1} { append msg [tr game] } else { append msg [tr games] }
  append msg " [tr Into] [::file::BaseName $base]."
  if {$nSkipped > 0} {
    if {$nSkipped == 1} {
      append msg "\n\n[tr Skipped] $nSkipped [tr DuplicateGame]."
    } else {
      append msg "\n\n[tr Skipped] $nSkipped [tr DuplicateGames]."
    }
  }
  if {$nUpdated > 0} {
    append msg "\n\n[tr Updated] $nUpdated [tr games]."
  }
  if {$warnings ne ""} {
    append msg "\n\n[tr PgnErrorsWarnings]\n$warnings"
  }
  tk_messageBox -icon info -type ok -title $title -message $msg
  return 1
}

###
### End of file: import.tcl
###

