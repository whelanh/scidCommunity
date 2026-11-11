### epd.tcl: EPD editing window(s) for ScidCommunity.
#
# Copyright (C) 2000  Shane Hudson
# Copyright (C) 2007  Pascal Georges
# Copyright (C) 2019  Bonnie A
# Copyright (C) 2019  stevenaaus
#
# Reimplemented for ScidCommunity against the modern sc_epd command and the
# docking window system (createToplevel/setMenu/setTitle).
#
# Note: Text and listbox widgets include "-exportselection false", else this
# entire set of code falls apart (and interferes with other applications
# during annotation).
#
# Note: sc_epd open (EpdBook::readFile) keeps the last occurrence of any
#   duplicate FEN (later lines overwrite earlier ones). Malformed lines are
#   preserved when reading, but will not match any valid board position.
#
# Caution: Updating modifications to the text widget requires that the
#   respective position be loaded on the main board. When navigating the
#   listbox we update the internal text before updating the board. When adding
#   a position the board is necessarily in sync, and we also update the internal
#   text whenever the mouse <Leave>s the text widget.

set epdAnnotation 0
set epdAnnotateMode 0
if {![info exists epdDelay]} { set epdDelay 3 }

namespace eval epd {
  variable maxEpd
  variable stripField {}
  variable epdTimer
  variable epdEngineName
  variable analysisRunning 0
  variable analysisOwner ""
  variable analysisStopRequested 0
  variable bestMoves {}
  variable epdName
  variable saveLog 0
  variable clipFen {}
  variable clipOpcodes {}

  set maxEpd [sc_info limit epd]
  array set epdTimer {}
  array set epdName {}

  # Minimal replacement for the old placeWinOverParent helper.
  proc placeWin {w parent} {
    if {![winfo exists $parent]} { set parent . }
    update idletasks
    set x [expr {[winfo rootx $parent] + 40}]
    set y [expr {[winfo rooty $parent] + 40}]
    catch {wm geometry $w +$x+$y}
  }

  # Apply the current ttk theme's colors to a classic listbox and re-apply
  # whenever the theme changes. Classic Tk widgets do not follow ttk themes.
  proc applyThemeListbox {lb} {
    set bg [ttk::style lookup . -fieldbackground "" white]
    set fg [ttk::style lookup . -foreground "" black]
    set sbg [ttk::style lookup . -selectbackground "" #4a6984]
    set sfg [ttk::style lookup . -selectforeground "" white]
    catch {
      $lb configure -background $bg -foreground $fg \
          -selectbackground $sbg -selectforeground $sfg
    }
    bind $lb <<ThemeChanged>> "::epd::applyThemeListbox $lb"
  }

  proc epdFindText {id entry} {
    set lb .epd$id.lb
    set text .epd$id.text
    # Flush unsaved edits before searching
    if {[$text edit modified]} {
      storeEpdText $id
    }
    set find [$entry get]
    set i [$lb curselection]
    if {$i == ""} { set i 0 }
    set size [$lb size]
    set found 0
    while {[incr i] < $size && !$found} {
      sc_epd load $id $i
      set found [regexp $find [sc_epd get $id]]
    }

    if {!$found} {
      set i 0
    } else {
      incr i -1
    }
    $text tag remove Highlight 1.0 end
    $lb selection clear 0 end
    $lb selection set $i
    event generate $lb <<ListboxSelect>>
    update idletasks
    set found [$text search -regexp -nocase -- $find 0.0]
    if {[ regexp {(.*)\.(.*)} $found t1 line char]} {
      $text see $found
      regexp -nocase -- $find [$text get $line.0 $line.end] matchVar
      set length [string length $matchVar]
      if {$length < 1} { set length 1 }
      $text tag add Highlight $found $line.[expr $char + $length]
    } else {
      bell
    }
  }

  ################################################################################
  ### Open up a new EPD window.
  ### cmd is "create", "open" or "openSilent".
  ### When fname is empty we prompt, using ::initialDir(epd) as a starting point.
  ################################################################################
  proc newEpdWin {cmd {fname ""}} {
    variable maxEpd
    variable epdName

    set showErrors 1
    if {$cmd == "openSilent"} {
      set showErrors 0
      set cmd open
    }
    if {$fname == ""} { set showErrors 1 }

    if {[sc_epd available] < 1} {
      if {$showErrors} {
        tk_messageBox -type ok -icon info -title "Too many EPD files open" \
            -message "You already have $maxEpd EPD files open; close one first."
      }
      return 0
    }

    set open_types { {"EPD files" {".epd"} } }
    set new_types $open_types
    if {$fname == ""} {
      if {![info exists ::initialDir(epd)] || ![file isdirectory $::initialDir(epd)]} {
        set ::initialDir(epd) $::env(HOME)
      }
      if {$cmd == "create"} {
        set fname [tk_getSaveFile -initialdir $::initialDir(epd) -filetypes $new_types -title "Create an EPD file"]
      } elseif {$cmd == "open"} {
        set fname [tk_getOpenFile -initialdir $::initialDir(epd) -filetypes $open_types -title "Open an EPD file"]
      } else {
        return 0
      }
    }
    if {$fname == ""} { return 0 }
    set ::initialDir(epd) [file dirname $fname]

    # Initialize the EpdBook internals.
    if {[catch {sc_epd $cmd $fname} result]} {
      if {$showErrors} {
        tk_messageBox -type ok -icon error -title "scidCommunity: EPD file error" -message $result
      }
      return 0
    }

    # id is 1 for first epd window, 2 for second...
    set id $result
    set w .epd$id
    set epdName($id) [file tail $fname]

    if {[::createToplevel $w] eq "already_exists"} { return 0 }
    ::setTitle $w "EPD file: $epdName($id)"

    ttk::frame $w.grid
    ttk_text $w.text -width 60 -height 8 \
        -wrap none -setgrid 1 -yscrollcommand "$w.ybar set" \
        -xscrollcommand "$w.xbar set" -undo 1 -exportselection false
    $w.text tag configure Highlight -background orange -foreground black

    ttk::scrollbar $w.ybar -takefocus 0 -command "$w.text yview"
    ttk::scrollbar $w.xbar -orient horizontal -takefocus 0 -command "$w.text xview"

    ttk::frame $w.bottom
    ttk::label $w.bottom.status -font font_Small
    ttk::entry $w.bottom.find -width 10 -font font_Small
    ttk::button $w.bottom.stop -text [tr Stop] -state disabled \
        -command "::epd::stopAnalysis $id"
    bind  $w.bottom.find <Return> "::epd::epdFindText $id $w.bottom.find"
    pack $w.bottom.status -side left
    pack $w.bottom.find   -side right
    pack $w.bottom.stop   -side right -padx 4
    listbox $w.lb  -font font_Regular -width 60 -height 8 -setgrid 1 -yscrollcommand "$w.ybar2 set" \
        -xscrollcommand "$w.xbar2 set" -selectmode single -exportselection false \
        -highlightthickness 0 -relief flat
    ::epd::applyThemeListbox $w.lb
    ttk::scrollbar $w.ybar2 -takefocus 0 -command "$w.lb yview"
    ttk::scrollbar $w.xbar2 -orient horizontal -takefocus 0 -command "$w.lb xview"

    menu $w.menu
    ::setMenu $w $w.menu
    $w.menu add cascade -label [tr File]  -menu $w.menu.file -underline 0
    $w.menu add cascade -label [tr Tools] -menu $w.menu.tools -underline 0
    $w.menu add cascade -label [tr Help]  -menu $w.menu.help -underline 0

    foreach i {file tools help} {
      menu $w.menu.$i -tearoff 0
    }

    set m $w.menu.file
    $m add command -label [tr FileNew] -underline 0 -command {::epd::newEpdWin create}
    $m add command -label [tr FileOpen] -underline 0 -command {::epd::newEpdWin open}
    $m add command -label [tr Save] -accelerator "Ctrl+S" -underline 0 -command "::epd::saveEpdWin $id"
    # Closing is deferred with "after idle" because on Windows menu commands
    # execute inside the native menu's modal loop: destroying the window (and
    # with it this menu) at that point crashes tk_popup/tk::PostOverPoint.
    $m add command -label [tr Close] -accelerator "Ctrl+W" -underline 0 -command "after idle {::epd::closeEpdWin $id}"

    set m $w.menu.tools
    $m add command -label [tr EpdPasteAnal] -accelerator "Ctrl+Shift+P" -underline 0 -command "::epd::pasteAnalysis $id"
    $m add command -label [tr EpdSortOpcodes] -accelerator "Ctrl+Shift+S" -underline 0 -command "::epd::sortEpdText $id"
    $m add command -label [tr EpdAddPosition] -accelerator "Ctrl+Shift+A" -underline 0 -command "::epd::addPosition $id"
    $m add command -label [tr EpdDeletePosition] -command "::epd::deleteEpdRow $id"
    $m add command -label [tr EpdCopyRecord] -command "::epd::copyEpdRecord $id"
    $m add command -label [tr EpdPasteRecord] -command "::epd::pasteEpdRecord $id"
    $m add command -label [tr EpdFindPos] -command "::epd::moveToDeepestMatch $id"
    $m add separator
    $m add command -label [tr EpdAnalPosition] -command "::epd::configAnnotateEpd $id"
    $m add command -label [tr EpdStripOpcodes] -accelerator "Ctrl+Shift+O" -command "::epd::chooseStripField $id"

    $w.menu.help add command -label "EPD [tr Help]" -underline 0 -accelerator "F1" -command "helpWindow EPD"
    $w.menu.help add command -label [tr HelpIndex] -underline 0 -command "helpWindow Index"

    pack $w.bottom -side bottom -fill x -padx 5 -pady 3
    pack $w.grid -fill both -expand yes
    grid $w.text -in $w.grid -row 0 -column 0 -sticky news
    grid $w.ybar -in $w.grid -row 0 -column 1 -sticky news
    grid $w.xbar -in $w.grid -row 1 -column 0 -sticky news
    grid $w.lb -in $w.grid -row 2 -column 0 -sticky news
    grid $w.ybar2 -in $w.grid -row 2 -column 1 -sticky news
    grid $w.xbar2 -in $w.grid -row 3 -column 0 -sticky news

    grid rowconfig $w.grid 0 -weight 1 -minsize 0
    grid rowconfig $w.grid 2 -weight 2 -minsize 0
    grid columnconfig $w.grid 0 -weight 1 -minsize 0

    # Right-mouse button cut/copy/paste menu:
    menu $w.text.edit -tearoff 0
    $w.text.edit add command -label "Cut"  -command "tk_textCut $w.text"
    $w.text.edit add command -label "Copy" -command "tk_textCopy $w.text"
    $w.text.edit add command -label "Paste" -command "tk_textPaste $w.text"
    bind $w.text <ButtonPress-3> "tk_popup $w.text.edit %X %Y"

    # Right-mouse button menu for listbox:
    menu $w.lb.edit -tearoff 0
    $w.lb.edit add command -label [tr EpdCopyRecord] -command "::epd::copyEpdRecord $id"
    $w.lb.edit add command -label [tr EpdDeleteRow] -command "::epd::deleteEpdRow $id"
    bind $w.lb <ButtonPress-3> "tk_popup $w.lb.edit %X %Y"

    bind $w <F1> { helpWindow EPD }
    bind $w <Control-Down> "::epd::nextEpd $id"
    bind $w <Control-Up> "::epd::prevEpd $id"
    bind $w <Control-question> "::epd::randomEpd $id"
    bind $w <Control-P> "::epd::pasteAnalysis $id ; break"
    bind $w <Control-A> "::epd::addPosition $id"
    bind $w <Control-O> "::epd::chooseStripField $id"
    bind $w <Control-w> "::epd::closeEpdWin $id"
    bind $w <Control-s> "
      if {\[$w.text edit modified\]} {::epd::storeEpdText $id}
      ::epd::saveEpdWin $id"
    bind $w <Control-S> "::epd::sortEpdText $id"

    # 'break's stop identical/conflicting binds being handled by parent widgets.
    bind $w.text <Control-a> "$w.text tag add sel 0.0 end-1c; break;"
    bind $w.text <Control-z> "catch \"$w.text edit undo\"; break;"
    bind $w.text <Control-r> "catch \"$w.text edit redo\"; break;"
    bind $w.text <Control-y> "catch \"$w.text edit redo\"; break;"
    bind $w.text <Leave> "if {\[$w.text edit modified\]} {::epd::storeEpdText $id}"

    if {[::game::Clear] == "cancel"} {
      closeEpdWin $id
      return 0
    }
    loadEpdLines $id
    updateEpdWin $id

    bind $w.lb <<ListboxSelect>> "::epd::loadEpd $id"
    bind $w <Destroy> "+if {\[string equal $w %W\]} { ::epd::closeEpdWin $id }"
    ::createToplevelFinalize $w
    focus $w.lb

    return 1
  }

  proc isAltered {id} {
    return [sc_epd altered $id]
  }

  ################################################################################
  ### Destroy/Close epd window
  ################################################################################
  proc closeEpdWin {id} {
    if {![winfo exists .epd$id]} { return }

    if {[isAltered $id] && ![sc_epd readonly $id]} {
      set w .confirmEPDExit
      if {[winfo exists $w]} { return }
      toplevel $w
      ::applyThemeColor_background $w
      wm title $w scidCommunity
      set ::epd::answer 2
      pack [ttk::frame $w.top] -side top
      addHorizontalRule $w
      pack [ttk::frame $w.bottom] -expand 1 -fill x -side bottom

      ttk::label $w.top.txt -text [tr EpdCloseWarning]
      pack $w.top.txt -padx 5 -pady 5 -side right

      ttk::button $w.bottom.b1 -width 10 -text [tr Save]     -command {destroy .confirmEPDExit ; set ::epd::answer 0}
      ttk::button $w.bottom.b2 -width 10 -text [tr EpdDontSave] -command {destroy .confirmEPDExit ; set ::epd::answer 1}
      ttk::button $w.bottom.b3 -width 10 -text [tr Cancel]   -command {destroy .confirmEPDExit ; set ::epd::answer 2}
      pack $w.bottom.b1 $w.bottom.b2 $w.bottom.b3 -side left -padx 10 -pady 5

      bind $w <Destroy> {set ::epd::answer 2}
      ::epd::placeWin $w .epd$id
      catch { grab $w }
      focus $w.bottom.b2
      vwait ::epd::answer
      if {$::epd::answer == 2} {return}
      if {$::epd::answer == 0} { ::epd::saveEpdWin $id }
    }
    bind .epd$id <Destroy> ""
    # A run owns an engine and a waiting loop; only its own window may stop it.
    # Closing another EPD window leaves the active pass alone.
    if {[info exists ::epd::analysisOwner] && $::epd::analysisOwner eq $id} {
      catch { ::epd::stopAnalysis $id }
      catch { ::epdanalysis::close }
    }
    sc_epd close $id
    focus .main
    destroy .epd$id
  }

  ################################################################################
  ### Delete the selected EPD row.
  ################################################################################
  proc deleteEpdRow {id} {
    set w .epd$id
    if {![winfo exists $w]} { return }
    if {[sc_epd readonly $id]} { return }
    set idx [$w.lb curselection]
    if {$idx == ""} { return }

    if {[$w.text edit modified]} {
      storeEpdText $id
    }

    sc_epd remove $id $idx

    $w.lb delete $idx
    set size [$w.lb size]
    for {set i $idx} {$i < $size} {incr i} {
      set line [$w.lb get $i]
      if {[regexp {^\d+\s+(.*)$} $line -> fen]} {
        $w.lb delete $i
        $w.lb insert $i "[expr {$i + 1}]    $fen"
      }
    }

    set remaining [$w.lb size]
    if {$remaining == 0} {
      updateEpdWin $id
      return
    }

    if {$idx >= $remaining} {
      set idx [expr {$remaining - 1}]
    }
    $w.lb selection set $idx
    $w.lb see $idx
    updateEpdWin $id
  }

  ################################################################################
  ### Copy the selected EPD record (FEN + opcodes) to a clipboard variable.
  ################################################################################
  proc copyEpdRecord {id} {
    variable clipFen
    variable clipOpcodes
    set w .epd$id
    if {![winfo exists $w]} { return }
    set idx [$w.lb curselection]
    if {$idx == ""} { return }

    if {[$w.text edit modified]} {
      storeEpdText $id
    }

    set clipFen [join [lrange [split [sc_pos fen] " "] 0 3] " "]
    set clipOpcodes [sc_epd get $id]
  }

  ################################################################################
  ### Paste the previously copied EPD record into this EPD file.
  ################################################################################
  proc pasteEpdRecord {id} {
    variable clipFen
    variable clipOpcodes
    if {$clipFen eq ""} { return }
    set w .epd$id
    if {![winfo exists $w]} { return }
    if {[sc_epd readonly $id]} { return }

    if {[$w.text edit modified]} {
      storeEpdText $id
    }

    sc_game push
    sc_game startBoard $clipFen

    set exists [sc_epd exists $id]
    sc_epd set $id $clipOpcodes

    if {!$exists} {
      set size [sc_epd size $id]
      $w.lb insert end "$size    $clipFen"
      set idx [expr {$size - 1}]
    } else {
      set idx [sc_epd index $id]
    }

    sc_game pop

    updateEpdWin $id
  }
  ################################################################################
  ### Save changes to the EPD file.
  ################################################################################
  proc saveEpdWin {id} {
    if {[sc_epd readonly $id]} {
      tk_messageBox -type ok -icon error -title "EPD file error" \
        -message "Save failed\nEPD file is read-only."
    } else {
      sc_epd write $id
    }
    updateEpdWin $id
  }

  ################################################################################
  ### Update the EPD window to agree with the EpdBook internals for the current
  ### board position. Also invoked whenever the main board is updated.
  ################################################################################
  proc updateEpdWin {id} {
    variable bestMoves
    global epdAnnotateMode epdAnnotation

    set w .epd$id
    if {![winfo exists $w]} { return }

    $w.text delete 1.0 end
    set text [sc_epd get $id]
    $w.text insert end $text
    $w.text edit modified false
    $w.text edit reset

    if {$epdAnnotation && $epdAnnotateMode} {
      if {[regexp -line {bm .*$} $text match]} {
        set bestMoves [string map {, { }} [string range $match 3 end]]
      } else {
        if {[regexp -line {am .*$} $text match]} {
          set bestMoves "avoid [string map {, { }} [string range $match 3 end]]"
        } else {
          set bestMoves {}
        }
      }
    }

    if {!$epdAnnotation} {
      set strStat "[sc_epd size $id] [tr positions]"
      if {[sc_epd readonly $id]} {
        append strStat " ([tr EpdReadOnly])"
      } elseif {[isAltered $id]} {
        append strStat " ([tr EpdAltered])"
      }
      set moves [lsort -ascii [sc_epd moves $id]]
      set len [llength $moves]
      if {$len} {
        append strStat "  \[$len: [join $moves " "]\]"
      } else {
        append strStat "  \[[tr EpdNoMoves]\]"
      }
      $w.bottom.status configure -text $strStat
    }

    updateEpdListbox $id
  }

  proc updateEpdListbox {id} {
    set w .epd$id
    set idx [sc_epd index $id]
    $w.lb selection clear 0 end
    if {$idx >= 0} {
      $w.lb selection set $idx
      $w.lb see $idx
    }
  }

  ################################################################################
  ### Invoked from ::notify::privPosChanged whenever the main board changes.
  ################################################################################
  proc updateEpdWins {} {
    variable maxEpd
    for {set i 1} {$i <= $maxEpd} {incr i} {
      if {[winfo exists .epd$i]} {
        set text .epd$i.text
        # Preserve unsaved edits before refreshing
        if {[winfo exists $text] && [$text edit modified]} {
          storeEpdText $i
        }
        updateEpdWin $i
      }
    }
  }

  ################################################################################
  ### Saves the text for a single EPD line.
  ################################################################################
  proc storeEpdText {id} {
    set w .epd$id
    $w.text edit modified false
    if { ! [sc_epd exists $id] } { return }
    set text [$w.text get 1.0 "end-1c"]
    sc_epd set $id $text
  }

  ################################################################################
  ### The listbox selection has changed (or we are stepping through with
  ### annotation). Save the previous text, then load the selected position.
  ################################################################################
  proc loadEpd { id } {
    if { [sc_epd size $id] == 0 } { return }
    set w .epd$id
    if { [$w.text edit modified] } { storeEpdText $id }
    set idx [$w.lb curselection]
    if {$idx == ""} { return }
    sc_epd load $id $idx
    # Orient the board from the perspective of the side to move.
    ::board::flip .main.board [expr {[sc_pos side] eq "black"}]
    updateBoard -pgn
  }

  proc prevEpd {id} {
    if { [sc_epd size $id] == 0 } { return }
    set w .epd$id
    set idx [$w.lb curselection]
    if { $idx == "" } { set idx [sc_epd size $id] }
    if {$idx > 0} {
      incr idx -1
      $w.lb selection clear 0 end
      $w.lb selection set $idx
      $w.lb see $idx
      loadEpd $id
    }
  }

  proc nextEpd {id} {
    if { [sc_epd size $id] == 0 } { return }
    set w .epd$id
    set idx [$w.lb curselection]
    if { $idx == "" } { set idx -1 }
    if {$idx < [ expr [$w.lb index end] - 1 ]} {
      incr idx 1
      $w.lb selection clear 0 end
      $w.lb selection set $idx
      $w.lb see $idx
      loadEpd $id
    }
  }

  proc randomEpd {id} {
    if { [sc_epd size $id] == 0 } { return }
    set w .epd$id
    set idx [expr {(int (rand() * [$w.lb index end]))}]
    $w.lb selection clear 0 end
    $w.lb selection set $idx
    $w.lb see $idx
    loadEpd $id
  }

  ################################################################################
  ###  Load up the listbox with EPD FEN strings (called just after opening).
  ################################################################################
  proc loadEpdLines { id } {
    set w .epd$id
    set size [sc_epd size $id]
    if { $size == 0 } { return }
    for { set i 1 } { $i <= $size } { incr i } {
      sc_epd next $id
      set fen [string range [sc_pos fen] 0 end-4]
      $w.lb insert end "$i    $fen"
    }
    sc_epd load $id 0
    $w.lb selection set 0
    updateBoard -pgn
  }

  proc configAnnotateEpd {id} {
    global engines epdAnnotateMode
    if {! [winfo exists .epd$id.text]} { return }

    if {[llength $engines(list)] == 0} {
      tk_messageBox -type ok -icon info -title "scidCommunity: no engines" \
          -message "No chess engines are configured.\nPlease add an engine ([tr Tools] -> [tr EngineList]) first." \
          -parent .epd$id
      return
    }

    set w .epdAnnotateConfig
    if {[winfo exists $w]} { raiseWin $w ; return }
    toplevel $w
    ::applyThemeColor_background $w
    wm title $w "Analyze EPD"
    ::epd::placeWin $w .epd$id

    ttk::frame $w.seconds
    ttk::frame $w.engine
    ttk::frame $w.mode

    ttk::label $w.seconds.label -text [tr EpdAnnotateTime]
    ttk::spinbox $w.seconds.spDelay  -width 8 -textvariable ::epdDelay -from 1 -to 300 -increment 1 -validate all -validatecommand {string is int %P}

    set values {}
    foreach e $engines(list) { lappend values [lindex $e 0] }

    ttk::combobox  $w.engine.combo -width 20 -state readonly -values $values
    $w.engine.combo current 0
    ttk::label $w.engine.label -text [tr Engine]

    ttk::radiobutton $w.mode.tally -variable epdAnnotateMode -value 1 -text [tr EpdCountBestMoves]
    ttk::radiobutton $w.mode.annot -variable epdAnnotateMode -value 0 -text [tr Annotate]
    ttk::radiobutton $w.mode.both  -variable epdAnnotateMode -value 2 -text [tr Both]

    ttk::frame $w.log
    ttk::checkbutton $w.log.cb -variable ::epd::saveLog -text [tr EpdSaveLog]

    pack $w.engine $w.seconds $w.mode $w.log -side top -pady 5 -padx 5
    pack $w.engine.label $w.engine.combo     -side left -fill x -padx 5
    pack $w.seconds.label $w.seconds.spDelay -side left -fill x -padx 5
    pack $w.mode.tally $w.mode.annot $w.mode.both -side left -fill x -padx 3
    pack $w.log.cb -side left -fill x -padx 3

    ttk::frame $w.buttons
    dialogbutton $w.buttons.ok -text OK -command "::epd::startAnnotateEpd $id $w"
    dialogbutton $w.buttons.cancel -text [tr Cancel] -command "destroy $w"
    pack $w.buttons -side bottom -padx 5 -pady 5
    pack $w.buttons.ok $w.buttons.cancel -side left -padx 10
    bind $w <F1> { helpWindow EPD }
    bind $w <Escape> "$w.buttons.cancel invoke"
  }

  ###  Validate the annotation config dialog and start annotation, optionally
  ###  prompting for a results log file.
  proc startAnnotateEpd {id w} {
    global engines
    set idx [$w.engine.combo current]
    set isUCI [lindex [lindex $engines(list) $idx] 7]
    if {!$isUCI} {
      tk_messageBox -type ok -icon info -title Oops \
          -message {Only UCI engines supported} -parent $w
      return
    }
    set name [$w.engine.combo get]

    set logfile ""
    if {$::epd::saveLog} {
      set epdpath [sc_epd name $id]
      set logfile [tk_getSaveFile \
          -initialdir [file dirname $epdpath] \
          -initialfile "[file rootname [file tail $epdpath]]-analysis.txt" \
          -filetypes {{"Text files" {.txt}} {"All files" *}} \
          -title "Save EPD analysis results" -parent $w]
      if {$logfile == ""} { return }
    }

    destroy $w
    update
    ::epd::launchAnnotateEpd $id $idx $name $logfile
  }

  ###  Launch a headless UCI engine and annotate each EPD, starting from the top.
  ###  engineIdx is kept for the caller's shape; the preset name is what opens.
  ###  The Stop button, or closing the EPD window, ends the pass.
  ###  If logfile is non-empty, the per-position results are written to it.
  proc launchAnnotateEpd {id engineIdx name {logfile ""}} {
    variable epdEngineName
    global epdAnnotateMode epdAnnotation epdDelay
    variable analysisRunning
    variable analysisOwner
    variable analysisStopRequested

    set w .epd$id
    if {$analysisRunning} {
      $w.bottom.status configure -text "Another EPD analysis is already running."
      # epdAnnotation belongs to the run already in flight; do not clear it.
      return
    }
    set epdEngineName [string map {{ } _} $name]

    set err [::epdanalysis::open $name]
    if {$err ne ""} {
      $w.bottom.status configure -text "Failed to start analysis engine: $err"
      set epdAnnotation 0
      return
    }

    set epdAnnotation 1
    set analysisRunning 1
    set analysisOwner $id
    set analysisStopRequested 0
    catch { $w.bottom.stop configure -state normal }
    $w.bottom.status configure -text "Analyzing with $epdEngineName ($epdDelay secs/move)"
    update

    # update pumps window events: the reader may have closed this EPD window
    # already, in which case the handle is gone and the flag must not stay set.
    if {![winfo exists $w]} {
      catch { ::epdanalysis::close }
      set analysisRunning 0
      set analysisOwner ""
      set analysisStopRequested 0
      set epdAnnotation 0
      return
    }

    if {$epdAnnotateMode != 1} { clearOpcodes $id }

    # Open the results log file, if requested.
    set logfp ""
    if {$logfile != ""} {
      if {[catch {open $logfile w} logfp]} {
        tk_messageBox -type ok -icon error -title "EPD analysis log" \
            -message "Could not open log file:\n$logfp" -parent $w
        set logfp ""
      } else {
        set modeText [lindex {Annotate {Count best moves} Both} $epdAnnotateMode]
        puts $logfp "EPD analysis results"
        puts $logfp "Engine:   $name"
        puts $logfp "EPD file: [sc_epd name $id]"
        puts $logfp "Mode:     $modeText"
        puts $logfp "Time/pos: $epdDelay s"
        puts $logfp "Date:     [clock format [clock seconds]]"
        puts $logfp [string repeat - 100]
        puts $logfp [format "%-4s %-16s %-10s %-7s %7s %5s %8s  %s" \
            "Pos" "Sought(bm/am)" "Found" "Result" "Time(s)" "Depth" "Score" "FEN"]
        puts $logfp [string repeat - 100]
      }
    }

    set size [sc_epd size $id]
    set bestMovesFound 0
    set bestMovesNoted 0
    set annErr ""
    set cancelled 0
    set i 0
    set movetime [expr {int($epdDelay * 1000)}]

    for { set i 0 } { $i < $size } { incr i } {
      if {$analysisStopRequested} { set cancelled 1 ; break }
      if {[catch {
        $w.lb selection clear 0 end
        $w.lb selection set $i
        $w.lb see $i
        update idletasks
        loadEpd $id
      } iterErr]} { set annErr $iterErr ; break }

      # Read the sought move(s) (bm/am) for THIS position before the search.
      set soughtMoves [::epd::soughtMovesFor $id]
      set fen [sc_pos fen]
      if {$analysisStopRequested} { set cancelled 1 ; break }
      set posStartMs [clock milliseconds]
      set ::epd::analysisSolveMs ""
      set ::epd::analysisResult ""

      # The first info line that matches bm/am gives the time-to-solve, even
      # when the engine later changes its mind about the best move.
      set onInfo [list apply {{sought start data} {
        if {$::epd::analysisSolveMs ne "" || $sought eq ""} { return }
        set bm [dict get $data best_san]
        if {$bm ne "" && [::epd::evalBestMove $sought $bm] eq "TRUE"} {
          set ::epd::analysisSolveMs [clock milliseconds]
        }
      }} $soughtMoves $posStartMs]
      set token [::epdanalysis::ask $fen $movetime \
          [list apply {{data} { set ::epd::analysisResult $data }}] $onInfo]
      if {$token eq "" && $::epd::analysisResult eq ""} {
        set annErr "the engine did not start the search"
        break
      }
      if {$token ne ""} { vwait ::epd::analysisResult }
      if {![winfo exists $w]} { set cancelled 1 ; break }
      set data $::epd::analysisResult
      if {![dict size $data]} { set annErr "the engine returned no result" ; break }
      set reason [dict get $data error]
      if {$reason eq "cancelled"} { set cancelled 1 ; break }
      if {$reason ne ""} { set annErr $reason ; break }

      set solveTime "-"
      if {$::epd::analysisSolveMs ne ""} {
        set solveTime [format "%.1f" \
            [expr {($::epd::analysisSolveMs - $posStartMs) / 1000.0}]]
      }

      if {[catch {
        set foundMove [dict get $data best_san]
        set result [::epd::evalBestMove $soughtMoves $foundMove]
        set status {}
        if {$epdAnnotateMode > 0} {
          set status no-result
          if {$soughtMoves != ""} {
            incr bestMovesNoted
            if {$result eq "TRUE"} {
              incr bestMovesFound
              set status success
            } else {
              set status fail
            }
          }
        }
        if {$logfp != ""} {
          ::epd::logAnnotateRow $logfp $data [expr {$i + 1}] \
              $soughtMoves $foundMove $result $solveTime
        }
        if {$epdAnnotateMode != 1} {
          pasteAnalysisData $id $data $status
          storeEpdText $id
          updateEpdWin $id
        }
      } iterErr]} { set annErr $iterErr ; break }
    }

    ::epdanalysis::close
    set analysisRunning 0
    set analysisOwner ""
    set analysisStopRequested 0
    catch { $w.bottom.stop configure -state disabled }

    if {[winfo exists $w]} {
      if {$annErr ne ""} {
        $w.bottom.status configure -text "EPD analysis error: $annErr"
      } elseif {$cancelled} {
        $w.bottom.status configure -text "Analysis stopped."
      } elseif {$epdAnnotateMode > 0} {
        set summary "Best moves found $bestMovesFound / $bestMovesNoted"
        $w.bottom.status configure -text "Result $epdEngineName ($epdDelay secs/move): $summary"
        if {$epdAnnotateMode == 2} { $w.text insert end "\n$summary" }
      } elseif {$i >= $size} {
        $w.bottom.status configure -text "Analysis finished ($size positions)."
      }
    }

    if {$logfp != ""} {
      puts $logfp [string repeat - 100]
      if {$bestMovesNoted > 0} {
        puts $logfp "Best moves found: $bestMovesFound / $bestMovesNoted"
      }
      catch { close $logfp }
    }
    set epdAnnotation 0

    if {[winfo exists $w] && $annErr eq "" && !$cancelled && $i >= $size} {
      set msg "Analysis finished ($size positions)."
      if {$epdAnnotateMode > 0 && $bestMovesNoted > 0} {
        append msg "\nBest moves found: $bestMovesFound / $bestMovesNoted"
      }
      tk_messageBox -type ok -icon info -title "EPD analysis" -message $msg -parent $w
    }
  }

  # The EPD window's Stop button and its close path. The waiting vwait gets the
  # cancelled result from ::epdanalysis, so the loop unwinds and closes the
  # engine; this proc does not destroy the window.
  proc stopAnalysis {id} {
    variable analysisRunning
    variable analysisOwner
    variable analysisStopRequested
    if {![info exists analysisRunning] || !$analysisRunning} { return }
    if {$id ne $analysisOwner} { return }
    set analysisStopRequested 1
    set w .epd$id
    if {[winfo exists $w]} {
      $w.bottom.status configure -text "Stopping..."
      catch { $w.bottom.stop configure -state disabled }
    }
    catch { ::epdanalysis::cancel }
  }

  ###  Return the slot number of the first open engineWin window, or -1.
  proc findEngineWin {} {
    for {set n 1} {$n <= 16} {incr n} {
      if {[winfo exists .engineWin$n]} {
        return $n
      }
    }
    return -1
  }

  ###  Build EPD opcode text from a running or recently-run Engine Window.
  ###  Returns opcode lines (may be empty) when no engine window is open.
  proc buildEngineOpcodes {} {
    set text {}

    set win [::epd::findEngineWin]
    if {$win != -1} {
      if {[info exists ::enginewin::pvBestMove($win,1)]} {
        set uci $::enginewin::pvBestMove($win,1)
        if {$uci != ""} {
          catch { set bm [sc_pos coordToSAN [sc_pos fen] $uci] }
          if {[info exists bm] && $bm != ""} {
            append text "bm $bm\n"
          }
        }
      }
      if {[info exists ::enginewin::scorePV1($win)]
          && $::enginewin::scorePV1($win) != ""} {
        set scoreStr $::enginewin::scorePV1($win)
        set btm 0
        if {[info exists ::enginewin::pv_(btm,$win)]} {
          set btm $::enginewin::pv_(btm,$win)
        }
        set sideEngine [expr {
          [info exists ::enginewin::m_(scoreside,$win)]
          && $::enginewin::m_(scoreside,$win) eq "engine"
        }]
        if {[regexp {^[+-]?M(\d+)$} $scoreStr -> dm]} {
          append text "dm $dm\n"
        } else {
          set ce [expr {int([string map {"+" ""} $scoreStr] * 100)}]
          if {$sideEngine && $btm} {
            set ce [expr {0 - $ce}]
          }
          append text "ce $ce\n"
        }
        set pv ""
        catch {
          set ew [::enginewin::reviewWindow $win]
          set pv [::enginewin::getMoves $ew.display.pv_lines 1.0]
        }
        if {$pv ne ""} { append text "pv $pv\n" }
      }
      return $text
    }

    return $text
  }

  ###  Return the bm (best) or am (avoid) move list for the current EPD
  ###  position, in the form used by evalBestMove: "" (none), "Qc7 Qd6"
  ###  (best moves) or "avoid Nf3 h4" (avoid moves).
  proc soughtMovesFor {id} {
    set text [sc_epd get $id]
    if {[regexp -line {^bm[ \t]+(.+)$} $text -> m]} {
      return [string trim [string map {, { }} $m]]
    }
    if {[regexp -line {^am[ \t]+(.+)$} $text -> m]} {
      return "avoid [string trim [string map {, { }} $m]]"
    }
    return {}
  }

  ###  Normalise a SAN move for comparison. EPD bm/am fields often omit the
  ###  check "+" and mate "#" suffixes that an engine reports, and castling is
  ###  sometimes written with zeros (0-0) instead of letters (O-O). Strip the
  ###  suffixes and canonicalise castling so equivalent moves compare equal.
  proc normMove {m} {
    set m [string trimright $m "+#!?"]
    set m [string map {0-0-0 O-O-O 0-0 O-O} $m]
    return $m
  }

  ###  Compare the engine's move against a position's bm/am opcode value.
  ###  soughtMoves is "" (none), "e4 Nf3 ..." (best moves), or
  ###  "avoid Nf3 ..." (avoid moves). Returns TRUE, FALSE or "-".
  proc evalBestMove {soughtMoves foundMove} {
    if {$soughtMoves eq "" || $foundMove eq ""} { return "-" }
    set foundMove [::epd::normMove $foundMove]
    if {[string match avoid* $soughtMoves]} {
      set avoid {}
      foreach m [string range $soughtMoves 6 end] { lappend avoid [::epd::normMove $m] }
      return [expr {[lsearch -exact $avoid $foundMove] == -1 ? "TRUE" : "FALSE"}]
    }
    set best {}
    foreach m $soughtMoves { lappend best [::epd::normMove $m] }
    return [expr {[lsearch -exact $best $foundMove] > -1 ? "TRUE" : "FALSE"}]
  }

  ###  Write one result row to the analysis log file.
  proc logAnnotateRow {logfp data posNo soughtMoves foundMove result solveTime} {
    set depth [dict get $data depth]
    if {$depth eq ""} { set depth 0 }
    set mate [dict get $data mate_white]
    if {$mate ne "" && $mate != 0} {
      set score [format "M%d" $mate]
    } else {
      set score [dict get $data score_white]
      if {$score eq ""} {
        set score "-"
      } else {
        set score [format "%+.2f" $score]
      }
    }
    set fen [dict get $data fen]
    set fen [string range $fen 0 end-4]
    if {$soughtMoves eq ""} { set soughtMoves "-" }
    if {$foundMove eq ""} { set foundMove "?" }
    puts $logfp [format "%-4d %-16s %-10s %-7s %7s %5s %8s  %s" \
        $posNo $soughtMoves $foundMove $result $solveTime $depth $score $fen]
  }

  ################################################################################
  ###  Strips all opcodes that will be pasted during annotation.
  ################################################################################
  proc clearOpcodes {id} {
    foreach opcode { "acd" "acn" "ce" "dm" "pv" } {
      sc_epd strip $id $opcode
      updateEpdWin $id
    }
  }

  ################################################################################
  ###  Remove the opcodes a previous paste wrote.
  ################################################################################
  proc stripAnalysisOpcodes {textwidget {keepAcdAcn 0}} {
    set text [$textwidget get 1.0 end]
    $textwidget delete 1.0 end
    foreach line [split $text "\n"] {
      if {[string trim $line] == ""} { continue }
      if {$keepAcdAcn && [regexp {^(acd|acn) } $line]} {
        $textwidget insert end $line\n
      } elseif {![regexp {^acd |^acn |^ce |^dm |^pv } $line]} {
        $textwidget insert end $line\n
      }
    }
  }

  ################################################################################
  ###  Annotate a single (current) EPD line from a headless result dict.
  ################################################################################
  proc pasteAnalysisData {id data {status {}}} {
    variable epdEngineName
    global epdAnnotateMode

    set textwidget .epd$id.text
    if {! [winfo exists $textwidget]} { return }
    stripAnalysisOpcodes $textwidget

    set depth [dict get $data depth]
    if {$depth eq ""} { set depth 0 }
    set nodes [dict get $data nodes]
    if {$nodes eq ""} { set nodes 0 }
    set mate [dict get $data mate_stm]
    set score [dict get $data score_stm]
    if {$mate eq ""} {
      set dm 0
      if {$score eq ""} {
        set ce 0
      } else {
        set ce [expr {round($score * 100)}]
      }
    } else {
      set dm [expr {abs($mate)}]
      set ce [expr {$mate < 0 ? -32767 - 2 * $mate : 32767 - 2 * $mate}]
    }
    $textwidget insert insert "acd $depth\n"
    $textwidget insert insert "acn $nodes\n"
    $textwidget insert insert "ce $ce\n"
    $textwidget insert insert "dm $dm\n"
    $textwidget insert insert "pv [dict get $data pv_san]\n"
    if {$epdAnnotateMode == 2 && $status ne ""} {
      $textwidget insert insert "$epdEngineName $status"
    }
  }

  ################################################################################
  ###  Paste the running Engine Window's analysis into the EPD line.
  ################################################################################
  proc pasteAnalysis {id {win -1} {status {}}} {
    variable epdEngineName
    global epdAnnotateMode

    set textwidget .epd$id.text
    if {! [winfo exists $textwidget]} { return }
    set opcodes [::epd::buildEngineOpcodes]
    if {[string trim $opcodes] eq ""} { return }
    stripAnalysisOpcodes $textwidget 1
    $textwidget insert insert $opcodes
    if {$epdAnnotateMode == 2 && $status ne ""} {
      set name ""
      if {$win == -1} { set win [::epd::findEngineWin] }
      if {$win != -1} { catch { set name $::enginewin_lastengine($win) } }
      if {$name eq ""} { set name $epdEngineName }
      $textwidget insert insert "$name $status"
    }
  }

  ################################################################################
  ###  Sort the opcodes in the text widget.
  ################################################################################
  proc sortEpdText {id} {
    set textwidget .epd$id.text
    if {! [winfo exists $textwidget]} { return }
    set text [$textwidget get 1.0 "end-1c"]
    set sortedlist [lsort [split $text "\n"]]
    set newtext {}
    foreach i $sortedlist {
      if {$i != ""} { append newtext "$i\n" }
    }
    if {! [string compare $text $newtext]} { return }
    $textwidget delete 1.0 end
    $textwidget insert end "$newtext"
    storeEpdText $id
  }

  ################################################################################
  ###  Launch the strip window.
  ################################################################################
  proc chooseStripField {id} {
    variable stripField
    variable epdName

    if {! [winfo exists .epd$id]} { return }
    if {[winfo exists .epdStrip]} { raiseWin .epdStrip ; return }
    set w [toplevel .epdStrip]
    ::applyThemeColor_background $w
    wm title $w "Strip EPD Opcode"
    ::epd::placeWin $w .epd$id
    wm resizable $w false false
    ttk::label $w.label -text "EPD opcode to be removed from $epdName($id)"
    ttk::entry $w.e -width 10  -textvariable ::epd::stripField
    pack $w.label $w.e -side top -pady 5 -padx 5
    addHorizontalRule $w
    set b [ttk::frame $w.buttons]
    pack $b -side bottom -pady 5
    ttk::button $b.ok -text [tr EpdStripOpcodes] -command "
      destroy $w
      ::epd::stripEpdField $id \$::epd::stripField
    "
    ttk::button $b.cancel -text [tr Cancel] -command "
      destroy $w
      focus .epd$id.lb
    "
    pack $b.ok $b.cancel -side left -padx 5
    bind $w <Return> "$b.ok invoke"
    bind $w <Escape> "$b.cancel invoke"
    bind $w <F1> { helpWindow EPD }
    focus $w.e
  }

  ################################################################################
  ###  Strip an opcode from all EPD lines.
  ################################################################################
  proc stripEpdField {id field} {
    if {$field == ""} {return}
    set result [sc_epd strip $id $field]
    updateEpdWin $id
    tk_messageBox -type ok -icon info -title "scidCommunity: EPD field stripped" \
        -message "scidCommunity stripped EPD field \"$field\" from $result positions." -parent .epd$id
  }

  ################################################################################
  ###  Add the current board position to the list of EPD positions.
  ################################################################################
  proc addPosition {id} {
    set w .epd$id
    if {[sc_epd exists $id]} {
      set idx [sc_epd index $id]
    } else {
      sc_epd set $id [::epd::buildEngineOpcodes]
      set size [sc_epd size $id]
      set fen [string range [sc_pos fen] 0 end-4]
      $w.lb insert end "$size    $fen"
      set idx [expr $size - 1]
    }
    $w.lb selection clear 0 end
    $w.lb selection set $idx
    $w.lb see $idx
    updateEpdWin $id
  }

  ################################################################################
  ###  Move the board to the deepest ply in the current game that matches a
  ###  position in the current EPD file.
  ################################################################################
  proc moveToDeepestMatch {id} {
    set ply [sc_epd deepest $id]
    sc_move ply $ply
    updateBoard
  }
}
