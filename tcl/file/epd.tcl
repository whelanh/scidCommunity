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
  variable bestMoves {}
  variable epdName
  variable saveLog 0

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
    bind  $w.bottom.find <Return> "::epd::epdFindText $id $w.bottom.find"
    pack $w.bottom.status -side left
    pack $w.bottom.find   -side right
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
    $m add command -label [tr EpdPasteAnal] -accelerator "Ctrl+P" -underline 0 -command "::epd::pasteAnalysis $id"
    $m add command -label [tr EpdSortOpcodes] -accelerator "Ctrl+Shift+S" -underline 0 -command "::epd::sortEpdText $id"
    $m add command -label [tr EpdAddPosition] -accelerator "Ctrl+A" -underline 0 -command "::epd::addPosition $id"
    $m add command -label [tr EpdFindPos] -command "::epd::moveToDeepestMatch $id"
    $m add separator
    $m add command -label [tr EpdAnalPosition] -command "::epd::configAnnotateEpd $id"
    $m add command -label [tr EpdStripOpcodes] -accelerator "Ctrl+O" -command "::epd::chooseStripField $id"

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

    bind $w <F1> { helpWindow EPD }
    bind $w <Control-Down> "::epd::nextEpd $id"
    bind $w <Control-Up> "::epd::prevEpd $id"
    bind $w <Control-question> "::epd::randomEpd $id"
    bind $w <Control-P> "::epd::pasteAnalysis $id ; break"
    bind $w <Control-A> "::epd::addPosition $id"
    bind $w <Control-O> "::epd::chooseStripField $id"
    bind $w <Control-q> "::epd::closeEpdWin $id"
    bind $w <Control-w> "::epd::closeEpdWin $id"
    bind $w.lb <space> {toggleEngineAnalysis}
    bind $w <Control-s> "
      if {\[$w.text edit modified\]} {::epd::storeEpdText $id}
      ::epd::saveEpdWin $id"

    # 'break's stop identical/conflicting binds being handled by parent widgets.
    bind $w.text <Control-a> "$w.text tag add sel 0.0 end-1c; break;"
    bind $w.text <Control-z> "catch \"$w.text edit undo\"; break;"
    bind $w.text <Control-r> "catch \"$w.text edit redo\"; break;"
    bind $w.text <Control-y> "catch \"$w.text edit redo\"; break;"
    bind $w.text <Leave> "if {\[$w.text edit modified\]} {::epd::storeEpdText $id}"

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

      ttk::label $w.top.txt -text "This EPD file has been altered.\nDo you wish to save it?"
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
    sc_epd close $id
    focus .main
    destroy .epd$id
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

  ###  Launch the analysis engine and annotate each EPD, starting from the top.
  ###  engineIdx is the index into $::engines(list) of the engine to use.
  ###  Pausing the analysis engine terminates annotation.
  ###  If logfile is non-empty, the per-position results are written to it.
  proc launchAnnotateEpd {id engineIdx name {logfile ""}} {
    variable epdEngineName
    global epdAnnotateMode epdAnnotation epdDelay

    set w .epd$id
    set epdEngineName [string map {{ } _} $name]

    set epdAnnotation 1
    $w.bottom.status configure -text "Analyzing with $epdEngineName ($epdDelay secs/move)"
    update

    if {$epdAnnotateMode != 1} { clearOpcodes $id }

    # Open an analysis window running the chosen engine in a free slot.
    # makeAnalysisWin expects the window slot number as its first argument
    # and the engine index as its second.
    set win [::enginelist::freeSlot]
    makeAnalysisWin $win $engineIdx 1
    if {![winfo exists .analysisWin$win]} {
      $w.bottom.status configure -text "Failed to start analysis engine: $name"
      set epdAnnotation 0
      return
    }

    # Wait (up to ~10s) for the engine to finish its handshake and begin
    # analysing, so the first position gets a real result and the loop's
    # analyzeMode check below does not trip prematurely.
    for {set waited 0} {$waited < 100} {incr waited} {
      if {![winfo exists .analysisWin$win]} { break }
      if {$::analysis(analyzeMode$win)} { break }
      update
      after 100
    }

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
        puts $logfp [format "%-4s %-16s %-10s %-7s %5s %8s  %s" \
            "Pos" "Sought(bm/am)" "Found" "Result" "Depth" "Score" "FEN"]
        puts $logfp [string repeat - 100]
      }
    }

    set size [sc_epd size $id ]
    set bestMovesFound 0
    set bestMovesNoted 0
    set annErr ""

    for { set i 0 } { $i < $size } { incr i } {
      # Navigate to and load this position (guarded).
      if {[catch {
        $w.lb selection clear 0 end
        $w.lb selection set $i
        $w.lb see $i
        update idletasks
        loadEpd $id
        # Make sure the engine (whatever slot it is in) analyses this position.
        updateAnalysis $win
      } iterErr]} { set annErr $iterErr ; break }

      # Read the sought move(s) (bm/am) directly for THIS position. Do not
      # rely on the deferred bestMoves variable: it is updated by updateEpdWin
      # from an after-idle callback and therefore lags one position behind.
      set soughtMoves [::epd::soughtMovesFor $id]

      # Wait epdDelay seconds while actively pumping the event loop so the
      # engine keeps analysing. Using an active wait (rather than
      # after+vwait) is robust against timer starvation that occurs when a
      # fast engine floods its output during infinite analysis.
      set deadline [expr {[clock milliseconds] + int($epdDelay * 1000)}]
      while {[clock milliseconds] < $deadline} {
        if {![winfo exists .analysisWin$win]} { break }
        update
        after 50
      }

      # Stop if the engine was paused or its window closed.
      if {! [winfo exists .analysisWin$win] || !$::analysis(analyzeMode$win)} { break }

      # Record and (optionally) annotate the result for this position (guarded
      # so a single failure does not abort the run and leave the engine
      # analysing indefinitely).
      if {[catch {
        set foundMove [::epd::bestMoveSAN $win]
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
          ::epd::logAnnotateRow $logfp $win [expr {$i + 1}] $soughtMoves $foundMove $result
        }
        if {$epdAnnotateMode != 1} {
          pasteAnalysis $id $win $status
          storeEpdText $id
          updateEpdWin $id
        }
      } iterErr]} { set annErr $iterErr ; break }
    }

    # Always stop the engine we started, whatever happened.
    if {[winfo exists .analysisWin$win] && $::analysis(analyzeMode$win)} {
      toggleEngineAnalysis $win
    }

    if {$annErr ne ""} {
      $w.bottom.status configure -text "EPD analysis error: $annErr"
    } elseif {$epdAnnotateMode > 0} {
      set summary "Best moves found $bestMovesFound / $bestMovesNoted"
      $w.bottom.status configure -text "Result $epdEngineName ($epdDelay secs/move): $summary"
      if {$epdAnnotateMode == 2} { $w.text insert end "\n$summary" }
    }

    if {$logfp != ""} {
      puts $logfp [string repeat - 100]
      if {$bestMovesNoted > 0} {
        puts $logfp "Best moves found: $bestMovesFound / $bestMovesNoted"
      }
      catch { close $logfp }
    }
    set epdAnnotation 0

    # Notify the user when the whole file has been processed without error.
    if {$annErr eq "" && $i >= $size} {
      set msg "Analysis finished ($size positions)."
      if {$epdAnnotateMode > 0 && $bestMovesNoted > 0} {
        append msg "\nBest moves found: $bestMovesFound / $bestMovesNoted"
      }
      tk_messageBox -type ok -icon info -title "EPD analysis" -message $msg -parent $w
    }
  }

  ###  Return the engine's principal variation (for the analysis window in the
  ###  given slot) as a SAN string, or "" if unavailable.
  proc pvSAN {win} {
    set pv [string trim $::analysis(moves$win)]
    if {$pv eq ""} { return "" }
    # UCI engines report the PV in coordinate notation; convert to SAN so it
    # can be compared with the SAN bm/am opcodes from the EPD file.
    if {$::analysis(uci$win)} {
      catch { set pv [sc_pos coordToSAN [sc_pos fen] $pv] }
    }
    return $pv
  }

  ###  Return the engine's current best move (first move of the PV) in SAN,
  ###  for the analysis window in the given slot. Returns "" if unavailable.
  proc bestMoveSAN {win} {
    set move ""
    regexp {[a-zA-Z][^ ]*} [::epd::pvSAN $win] move
    return $move
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
  proc logAnnotateRow {logfp win posNo soughtMoves foundMove result} {
    set depth $::analysis(depth$win)
    if {$::analysis(scoremate$win) != 0} {
      set score [format "M%d" $::analysis(scoremate$win)]
    } else {
      set score [format "%+.2f" $::analysis(score$win)]
    }
    set fen [string range [sc_pos fen] 0 end-4]
    if {$soughtMoves eq ""} { set soughtMoves "-" }
    if {$foundMove eq ""} { set foundMove "?" }
    puts $logfp [format "%-4d %-16s %-10s %-7s %5s %8s  %s" \
        $posNo $soughtMoves $foundMove $result $depth $score $fen]
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
  ###  Annotate a single (current) EPD line in compliance with the EPD spec.
  ################################################################################
  proc pasteAnalysis {id {win -1} {status {}}} {
    variable epdEngineName
    global analysis

    set textwidget .epd$id.text
    if {! [winfo exists $textwidget]} { return }

    if {$win == -1} {
      for {set i 0} {$i < [llength $::engines(list)]} {incr i} {
        if {[winfo exists .analysisWin$i]} { set win $i ; break }
      }
    }
    if {$win == -1} { return }

    # Delete current opcodes "acd" "acn" "ce" "dm" "pv"
    set text [$textwidget get 1.0 end]
    $textwidget delete 1.0 end
    foreach line [split $text "\n"] {
      if {[string trim $line] == ""} { continue }
      if {![regexp {^acd |^acn |^ce |^dm |^pv } $line]} {
        $textwidget insert end $line\n
      }
    }

    $textwidget insert insert "acd $analysis(depth$win)\n"
    $textwidget insert insert "acn $analysis(nodes$win)\n"
    set dm [expr abs($analysis(scoremate$win))]
    if { $dm != 0 } {
      set ce [expr {32767 - ((2 * $dm) - 1)}]
    } else {
      set ce [expr {int($analysis(score$win) * 100)} ]
      if {[sc_pos side] == "black"} { set ce [expr {0 - $ce} ] }
    }
    $textwidget insert insert "ce $ce\n"
    $textwidget insert insert "dm $dm\n"
    $textwidget insert insert "pv [::epd::pvSAN $win]\n"
    if {$::epdAnnotateMode == 2 && $status != {}} {
      $textwidget insert insert "$epdEngineName $status"
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
      sc_epd set $id ""
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
