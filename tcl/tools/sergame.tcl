###
### sergame.tcl: part of Scid.
### Copyright (C) 2007  Pascal Georges
### Consolidated "Play versus Engine" - combines Tactical Game coaching
### with Serious Game engine controls, time management, and opening books.
###
################################################################################
# Engine 1 = opponent (UCI), Engine 2 = coach (UCI)
################################################################################

namespace eval sergame {

  set ::uci::uciInfo(log_stdout1) 0
  set ::uci::uciInfo(log_stdout2) 0

  # if true, follow a specific opening
  set openingMovesList {}
  set openingMovesHash {}
  set openingMoves ""
  set outOfOpening 0
  array set engineListBox {}
  set engineName ""
  set bookSlot 2
  if {![info exists storeEval]} { set storeEval 0 }
  if {![info exists storeEvalAll]} { set storeEvalAll 0 }
  if {![info exists coachIndex]} { set coachIndex 0 }
  set engineColor ""
  if {![info exists playerColor]} { set playerColor "" }

  # coach blunder tracking
  set resignCount 0
  set lastblundervalue 0.0
  set blunderpending 0
  set currentPosHash 0
  set lscore {}
  set blunderWarningLabel ""
  set scoreLabel 0.0
  set coachNag ""

  # list of fen positions played to detect 3 fold repetition
  set lFen {}

  ################################################################################
  # config: configuration dialog for Play versus Engine
  ################################################################################
  proc config {} {
    global ::sergame::chosenOpening ::sergame::playerColor

    set w ".configSerGameWin"
    if {[winfo exists $w]} {
      focus $w
      return
    }

    win::createDialog $w
    wm title $w "$::tr(configurePlayEngine)"

    bind $w <F1> { helpWindow PlayVsEngine }
    setWinLocation $w

    # Create frames
    ttk::frame $w.fconfig
    ttk::frame $w.fconfig2
    ttk::frame $w.fbuttons
    ttk::labelframe $w.fengines -text "$::tr(Player) - $::tr(Engine)"
    ttk::labelframe $w.fcoach -text "Coaching"
    ttk::labelframe $w.ftime -text $::tr(TimeMode)
    ttk::labelframe $w.fopening -text $::tr(Opening)

    # Grid them visually identical to uwe's layout
    grid $w.fengines -row 0 -column 0 -pady { 0 10 } -sticky nswe -padx { 0 10 }
    grid $w.fcoach -row 0 -column 1 -pady { 0 10 } -sticky nswe -padx { 0 10 }
    grid $w.fopening -row 1 -column 0 -pady { 0 10 } -sticky nswe -padx { 0 10 }
    grid $w.ftime -row 1 -column 1 -pady { 0 10 } -sticky nswe -padx { 0 10 }
    grid $w.fconfig -row 2 -column 0 -pady { 0 10 } -sticky we -padx { 0 10 }
    grid $w.fconfig2 -row 2 -column 1 -pady { 0 10 } -sticky we -padx { 0 10 }
    grid $w.fbuttons -row 3 -column 1 -sticky se

    # ------------------ fengines frame ------------------
    # builds the list of UCI engines and formats the combobox
    set uciEngineNames {}
    set i 0
    set idx 0
    foreach e $::engines(list) {
      if { [lindex $e 7] != 1} { incr idx ; continue }
      set ::sergame::engineListBox($i) $idx
      set name [lindex $e 0]
      lappend uciEngineNames $name
      if {$idx == $::sergame::chosenEngine} {
        set selectedUciIdx $i
      }
      incr i
      incr idx
    }

    if {[llength $uciEngineNames] == 0} {
      tk_messageBox -type ok -message "No UCI engine defined" -icon error
      destroy $w
      return
    }

    ttk::frame $w.fengines.sel
    ttk::combobox $w.fengines.sel.combo -state readonly -values $uciEngineNames -width 22
    if {[info exists selectedUciIdx]} {
      $w.fengines.sel.combo current $selectedUciIdx
    } else {
      $w.fengines.sel.combo current 0
      set ::sergame::chosenEngine $::sergame::engineListBox(0)
    }

    ttk::button $w.fengines.sel.bEngineConfig -text "..." -width 3 -command {
      set selectedName [.configSerGameWin.fengines.sel.combo get]
      set chosenIndex -1
      set idx 0
      foreach e $::engines(list) {
        if {[lindex $e 0] eq $selectedName} {
          set chosenIndex $idx
          break
        }
        incr idx
      }
      if {$chosenIndex != -1} {
        set engineData [lindex $::engines(list) $chosenIndex]
        set name [lindex $engineData 0]
        set cmd [ toAbsPath [lindex $engineData 1] ]
        set args [lindex $engineData 2]
        set dir [ toAbsPath [lindex $engineData 3] ]
        set options [lindex $engineData 8]
        set ::uci::engineListIndex $chosenIndex
        ::uci::uciConfig 3 [ toAbsPath $cmd ] $args [ toAbsPath $dir ] $options
      }
    }
    pack $w.fengines.sel.combo -side left -fill x -expand yes
    pack $w.fengines.sel.bEngineConfig -side left -padx {5 0}
    pack $w.fengines.sel -side top -fill x -pady 5

    ttk::checkbutton $w.fengines.cbPonder -text $::tr(Ponder) -variable ::sergame::ponder
    pack $w.fengines.cbPonder -side top -anchor w

    # Player color selection (respect saved preference, default to board orientation)
    if {$::sergame::playerColor == ""} {
      if {[::board::isFlipped .main.board]} {
        set ::sergame::playerColor "black"
      } else {
        set ::sergame::playerColor "white"
      }
    }
    ttk::frame $w.fengines.player
    ttk::label $w.fengines.player.l -text "$::tr(Player) $::tr(GlistColor)"
    ttk::radiobutton $w.fengines.player.w -text $::tr(white) -value "white" -variable ::sergame::playerColor
    ttk::radiobutton $w.fengines.player.b -text $::tr(black) -value "black" -variable ::sergame::playerColor
    ttk::radiobutton $w.fengines.player.r -text $::tr(Random) -value "random" -variable ::sergame::playerColor
    pack $w.fengines.player.l $w.fengines.player.w $w.fengines.player.b $w.fengines.player.r -side left -padx 4
    pack $w.fengines.player -side top -anchor w -pady 5

    # ------------------ coach frame ------------------
    # Build coach list using same UCI-only filter as engine selector
    set coachNames {}
    array unset ::sergame::coachListBox
    set ci 0
    set idx 0
    set selectedCoachIdx 0
    foreach e $::engines(list) {
      if { [lindex $e 7] != 1} { incr idx ; continue }
      set ::sergame::coachListBox($ci) $idx
      lappend coachNames [lindex $e 0]
      if {$idx == $::sergame::coachIndex} {
        set selectedCoachIdx $ci
      }
      incr ci
      incr idx
    }
    if {[llength $coachNames] == 0} {
      # Fallback if no UCI engines
      set coachNames [list "No UCI engine"]
      set selectedCoachIdx 0
    }

    ttk::frame $w.fcoach.en
    ttk::checkbutton $w.fcoach.en.cbCoachWatching -text $::tr(CoachIsWatching) -variable ::sergame::coachIsWatching \
        -command "::sergame::toggleCoachControls $w"
    ttk::combobox $w.fcoach.en.cbCoach -values $coachNames -state readonly -width 20
    catch { $w.fcoach.en.cbCoach current $selectedCoachIdx }
    pack $w.fcoach.en.cbCoachWatching $w.fcoach.en.cbCoach -side left -padx 4 -pady 5

    ttk::frame $w.fcoach.ad
    ttk::checkbutton $w.fcoach.ad.cbLimitAnalysis -text $::tr(limitanalysis) -variable ::sergame::isLimitedAnalysisTime
    ttk::spinbox $w.fcoach.ad.val -width 3 -from 5 -to 360 -increment 1 -textvariable ::sergame::analysisTime -validate all -validatecommand { regexp {^[0-9]+$} %P }
    ttk::label $w.fcoach.ad.lblSec -text $::tr(seconds)
    pack $w.fcoach.ad.cbLimitAnalysis $w.fcoach.ad.val $w.fcoach.ad.lblSec -side left -anchor w -padx 4

    pack $w.fcoach.en $w.fcoach.ad -side top -anchor w -padx 4
    ::sergame::toggleCoachControls $w

    # ------------------ ftime frame ------------------
    ttk::checkbutton $w.ftime.cbChessClock -text $::tr(UseChessClock) -variable ::sergame::useChessClock
    pack $w.ftime.cbChessClock -side top -anchor w -pady {0 5}

    # --- Clock time settings (independent of engine thinking mode) ---
    ttk::frame $w.ftime.clock
    pack $w.ftime.clock -side top -fill x

    set row 0
    ttk::label $w.ftime.clock.whitelabel -text $::tr(White)
    grid $w.ftime.clock.whitelabel -row $row -column 0
    ttk::spinbox $w.ftime.clock.whitespminutes -background white -width 2 -from 1 -to 120 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    grid $w.ftime.clock.whitespminutes -row $row -column 1
    ttk::label $w.ftime.clock.whitelminutes -text $::tr(TimeMin)
    grid $w.ftime.clock.whitelminutes -row $row -column 2
    ttk::spinbox $w.ftime.clock.whitespseconds -background white -width 2 -from 0 -to 60 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    grid $w.ftime.clock.whitespseconds -row $row -column 3
    ttk::label $w.ftime.clock.whitelseconds -text $::tr(TimeSec)
    grid $w.ftime.clock.whitelseconds -row $row -column 4

    incr row
    ttk::label $w.ftime.clock.blacklabel -text $::tr(Black)
    grid $w.ftime.clock.blacklabel -row $row -column 0
    ttk::spinbox $w.ftime.clock.blackspminutes -background white -width 2 -from 1 -to 120 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    grid $w.ftime.clock.blackspminutes -row $row -column 1
    ttk::label $w.ftime.clock.blacklminutes -text $::tr(TimeMin)
    grid $w.ftime.clock.blacklminutes -row $row -column 2
    ttk::spinbox $w.ftime.clock.blackspseconds -background white -width 2 -from 0 -to 60 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    grid $w.ftime.clock.blackspseconds -row $row -column 3
    ttk::label $w.ftime.clock.blacklseconds -text $::tr(TimeSec)
    grid $w.ftime.clock.blacklseconds -row $row -column 4

    $w.ftime.clock.whitespminutes set [expr $::uci::uciInfo(wtime1) / (60 * 1000)]
    $w.ftime.clock.whitespseconds set [expr $::uci::uciInfo(winc1) /  1000]
    $w.ftime.clock.blackspminutes set [expr $::uci::uciInfo(btime1) / (60 * 1000)]
    $w.ftime.clock.blackspseconds set [expr $::uci::uciInfo(binc1) /  1000 ]

    # --- Engine thinking mode ---
    ttk::separator $w.ftime.sep -orient horizontal
    pack $w.ftime.sep -side top -fill x -pady 5

    # Time Bonus (engine uses remaining clock time)
    ttk::frame $w.ftime.timebonus
    ttk::radiobutton $w.ftime.timebonus.button -text $::tr(TimeBonus) -value "timebonus" -variable ::sergame::timeMode
    pack $w.ftime.timebonus -side top -fill x
    pack $w.ftime.timebonus.button -side left

    # Fixed depth
    ttk::frame $w.ftime.depth
    ttk::radiobutton $w.ftime.depth.button -text $::tr(FixedDepth) -value "depth" -variable ::sergame::timeMode -width 16
    ttk::spinbox $w.ftime.depth.value -background white -width 3 -from 1 -to 20 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    $w.ftime.depth.value set $::sergame::depth
    pack $w.ftime.depth -side top -fill x
    pack $w.ftime.depth.button -side left
    pack $w.ftime.depth.value -side left

    # Nodes (raw value, no x1000)
    ttk::frame $w.ftime.nodes
    ttk::radiobutton $w.ftime.nodes.button -text $::tr(Nodes) -value "nodes" -variable ::sergame::timeMode -width 16
    ttk::spinbox $w.ftime.nodes.value -background white -width 8 -from 1 -to 10000000 -increment 1000 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    $w.ftime.nodes.value set $::sergame::nodes
    pack $w.ftime.nodes -side top -fill x
    pack $w.ftime.nodes.button -side left
    pack $w.ftime.nodes.value -side left

    # Seconds per move
    ttk::frame $w.ftime.movetime
    ttk::radiobutton $w.ftime.movetime.button -text $::tr(SecondsPerMove) -value "movetime" -variable ::sergame::timeMode -width 16
    ttk::spinbox $w.ftime.movetime.value -background white -width 3 -from 1 -to 120 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    $w.ftime.movetime.value set [ expr $::sergame::movetime /1000]
    pack $w.ftime.movetime -side top -fill x
    pack $w.ftime.movetime.button -side left
    pack $w.ftime.movetime.value -side left

    # Config options
    ttk::checkbutton $w.fconfig.cbUseBook -text $::tr(UseBook) -variable ::sergame::useBook
    set bookPath $::scidBooksDir
    set bookList [ lsort -dictionary [ glob -nocomplain -directory $bookPath *.bin ] ]
    if { [llength $bookList] == 0 } {
      $w.fconfig.cbUseBook configure -state disabled
      set ::sergame::useBook 0
    }
    set bi 0
    set bdx 0
    set btmp {}
    foreach file $bookList {
      lappend btmp [ file tail $file ]
      if { $::sergame::bookToUse == [ file tail $file ]} {
        set bdx $bi
      }
      incr bi
    }
    ttk::combobox $w.fconfig.combo -width 12 -values $btmp
    catch { $w.fconfig.combo current $bdx }
    pack $w.fconfig.cbUseBook -side top -anchor w
    pack $w.fconfig.combo -side top -anchor w -padx 20 -fill x

    # Config options 2
    ttk::checkbutton $w.fconfig2.cbPosition -text $::tr(StartFromCurrentPosition) -variable ::sergame::startFromCurrent
    ttk::checkbutton $w.fconfig2.storeEval -text $::tr(AddScoreToShortAnnotations) -variable ::sergame::storeEval
    ttk::checkbutton $w.fconfig2.storeEvalAll -text [::tr AddScoreToAllMoves] -variable ::sergame::storeEvalAll
    pack $w.fconfig2.cbPosition $w.fconfig2.storeEval $w.fconfig2.storeEvalAll -side top -anchor w

    # Specific opening
    ttk::checkbutton $w.fopening.cbOpening -text $::tr(SpecificOpening) -variable ::sergame::isOpening
    ttk::frame $w.fopening.fOpeningList
    ttk::treeview $w.fopening.fOpeningList.lbOpening -columns {0} -show {} -selectmode browse \
        -yscrollcommand "$w.fopening.fOpeningList.ybar set"
    $w.fopening.fOpeningList.lbOpening column 0 -width 250
    $w.fopening.fOpeningList.lbOpening configure -height 5
    set oidx 0
    foreach o $::sergame::openingList {
        $w.fopening.fOpeningList.lbOpening insert {} end -id $oidx -values [list $o]
        incr oidx
    }
    $w.fopening.fOpeningList.lbOpening selection set $::sergame::chosenOpening
    $w.fopening.fOpeningList.lbOpening see $::sergame::chosenOpening

    ttk::scrollbar $w.fopening.fOpeningList.ybar -command "$w.fopening.fOpeningList.lbOpening yview"
    pack $w.fopening.cbOpening -fill x -side top
    pack $w.fopening.fOpeningList.ybar -side right -fill y
    pack $w.fopening.fOpeningList.lbOpening -side left -fill both -expand 1
    pack $w.fopening.fOpeningList -fill both -side top

    ttk::button $w.fbuttons.close -text $::tr(Play) -command {
      focus .
      ::sergame::syncConfigVars
      if {$::sergame::useBook} {
        if {$::sergame::bookToUse == "" } {
          set ::sergame::useBook 0
        }
      }
      destroy .configSerGameWin
      ::sergame::play $::sergame::chosenEngine
    }
    ttk::button $w.fbuttons.cancel -textvar ::tr(Cancel) -command "focus .; destroy $w"

    packbuttons right $w.fbuttons.cancel $w.fbuttons.close
    bind $w <Escape> { .configSerGameWin.fbuttons.cancel invoke }
    bind $w <Return> { .configSerGameWin.fbuttons.close invoke }
    bind $w <F1> { helpWindow PlayVsEngine }
    bind $w <Destroy> "::sergame::syncConfigVars"
    bind $w <Configure> "recordWinSize $w"
    wm resizable $w 0 0
  }

  proc syncConfigVars {} {
    set w ".configSerGameWin"
    if {![winfo exists $w]} { return }

    if {[catch {$w.fengines.sel.combo current} engineComboIdx] == 0} {
      if {[info exists ::sergame::engineListBox($engineComboIdx)]} {
        set ::sergame::chosenEngine $::sergame::engineListBox($engineComboIdx)
      }
      set ::sergame::engineName [$w.fengines.sel.combo get]
    }

    if {[catch {$w.fcoach.en.cbCoach current} coachComboIdx] == 0} {
      if {[info exists ::sergame::coachListBox($coachComboIdx)]} {
        set ::sergame::coachIndex $::sergame::coachListBox($coachComboIdx)
      }
    }

    catch { set ::sergame::depth [$w.ftime.depth.value get] }
    catch { set ::sergame::nodes [$w.ftime.nodes.value get] }
    catch { set ::sergame::movetime [expr {[$w.ftime.movetime.value get] * 1000}] }

    catch { set ::uci::uciInfo(wtime1) [expr {[$w.ftime.clock.whitespminutes get] * 1000 * 60}] }
    catch { set ::uci::uciInfo(btime1) [expr {[$w.ftime.clock.blackspminutes get] * 1000 * 60}] }
    catch { set ::uci::uciInfo(winc1) [expr {[$w.ftime.clock.whitespseconds get] * 1000}] }
    catch { set ::uci::uciInfo(binc1) [expr {[$w.ftime.clock.blackspseconds get] * 1000}] }
    catch { set ::uci::uciInfo(fixeddepth1) $::sergame::depth }
    catch { set ::uci::uciInfo(fixednodes1) $::sergame::nodes }
    catch { set ::uci::uciInfo(movetime1) $::sergame::movetime }

    catch { set ::sergame::chosenOpening [$w.fopening.fOpeningList.lbOpening selection] }

    if {$::sergame::useBook} {
      catch { set ::sergame::bookToUse [$w.fconfig.combo get] }
    }
  }

  proc toggleCoachControls {w} {
    if {$::sergame::coachIsWatching} {
      $w.fcoach.ad.cbLimitAnalysis configure -state normal
      $w.fcoach.ad.val configure -state normal
    } else {
      $w.fcoach.ad.cbLimitAnalysis configure -state disabled
      $w.fcoach.ad.val configure -state disabled
    }
  }

  ################################################################################
  # play: start the game
  ################################################################################
  proc play { engine {n 1} } {
    global ::sergame::chosenOpening ::sergame::isOpening ::sergame::openingList ::sergame::openingMovesList \
        ::sergame::openingMovesHash ::sergame::openingMoves ::sergame::outOfOpening

    if {$::sergame::isOpening || !$::sergame::startFromCurrent} {
      if {[::game::Clear] eq "cancel"} { return }
    }

    set ::sergame::lFen {}
    set ::sergame::lscore {}
    set ::sergame::resignCount 0
    set ::sergame::lastblundervalue 0.0
    set ::sergame::blunderpending 0
    set ::sergame::blunderWarningLabel ""
    set ::sergame::scoreLabel ""
    set ::sergame::coachNag ""
    set ::sergame::blunderCheckPending 0
    set ::sergame::coachAnalyzed 0
    set ::sergame::playerBlunderDelta 0.0
    set ::sergame::playerBlunderSeverity 0
    set ::sergame::postPlayerScore ""
    set ::sergame::engineBlunderDelta 0.0
    set ::sergame::engineBlunderSeverity 0
    set ::sergame::missedCapitalization 0
    set ::sergame::showBestMove 0

    set ::sergame::activeColor $::sergame::playerColor
    if {$::sergame::activeColor == "random"} {
      set ::sergame::activeColor [expr {rand() < 0.5 ? "white" : "black"}]
    }

    # Engine plays for the opposite side of player color
    if {$::sergame::activeColor == "white"} {
      set ::sergame::engineColor "black"
      if {[::board::isFlipped .main.board]} {
        ::board::flipAuto .main.board 0
      }
    } else {
      set ::sergame::engineColor "white"
      if {![::board::isFlipped .main.board]} {
        ::board::flipAuto .main.board 1
      }
    }

    # Start opponent engine (engine 1)
    ::uci::startEngine $engine $n
    set engineData [lindex $::engines(list) $engine]
    foreach {option} [lindex $engineData 8] {
      array set ::uciOptions$n $option
    }
    ::uci::sendUCIoptions $n

    set ::uci::uciInfo(prevscore$n) 0.0
    set ::uci::uciInfo(score$n) 0.0
    set ::uci::uciInfo(ponder$n) ""

    set ::uci::uciInfo(prevscore2) 0.0
    set ::uci::uciInfo(score2) 0.0
    set ::uci::uciInfo(pipe2) ""

    if {$::sergame::coachIsWatching} {
      ::uci::startEngine $::sergame::coachIndex 2
      set ::uci::uciInfo(multipv2) 1
      ::sergame::changePVSize 2
    }

    if {$::sergame::startFromCurrent} {
      set isOpening 0
    }

    # Ponder
    if {$::sergame::ponder} {
      ::sergame::sendToEngine $n "setoption name Ponder value true"
    } else {
      ::sergame::sendToEngine $n "setoption name Ponder value false"
    }

    # If following a specific opening line
    if {$isOpening} {
      set fields [split [lindex $openingList $chosenOpening] ":"]
      set openingName [lindex $fields 0]
      set openingMoves [string trim [lindex $fields 1]]
      set openingMovesList ""
      set openingMovesHash ""
      set outOfOpening 0
      foreach m [split $openingMoves] {
        if {$m =={}} { continue }
        set p [string trim $m]
        lappend openingMovesList [string trim [regsub {^[1-9]+\.} $p ""] ]
      }
      lappend openingMovesHash [sc_pos hash]
      foreach m $openingMovesList {
        if {[catch {sc_move addSan $m}]} { }
        lappend openingMovesHash [sc_pos hash]
      }
      # Rewind to starting position before gameplay begins
      sc_move start
    }

    if {!$::sergame::startFromCurrent} {
      sc_game tags set -event "Play vs Engine"
      sc_game tags set -$::sergame::activeColor "Player"
      sc_game tags set -$::sergame::engineColor "$::sergame::engineName"
      sc_game tags set -date [::utils::date::today]
    }

    set ::sergame::waitPlayerMove 0
    set ::sergame::wentOutOfBook 0
    set ::sergame::currentPosHash [sc_pos hash]

    # Create the game window
    set w .coachWin
    if {[winfo exists $w]} {
      focus .
      destroy $w
      return
    }

    createToplevel $w
    applyThemeColor_background $w
    setTitle $w "$::tr(configurePlayEngine)"

    ttk::frame $w.fdisplay
    ttk::frame $w.fthreshold
    ttk::frame $w.finformations
    ttk::frame $w.fclocks
    if {$::sergame::activeColor == "white"} {
      ttk::labelframe $w.fclockw -text "$::tr(Time) $::tr(Player)"
      ttk::labelframe $w.fclockb -text "$::tr(Time) $::tr(Engine)"
    } else {
      ttk::labelframe $w.fclockw -text "$::tr(Time) $::tr(Engine)"
      ttk::labelframe $w.fclockb -text "$::tr(Time) $::tr(Player)"
    }
    ttk::frame $w.fbuttons
    pack $w.fdisplay -side top -fill both -pady 5 -padx 10
    pack [ttk::separator $w.line1 -orient horizontal] -side top -fill x -padx 10 -pady 5
    pack $w.fthreshold -side top -fill both -pady 5 -padx 10
    pack [ttk::separator $w.line2 -orient horizontal] -side top -fill x -padx 10 -pady 5
    pack $w.finformations -side top -fill both -pady 5 -padx 10
    pack $w.fclocks -side top -fill both -pady 5 -padx 10
    pack $w.fclockb $w.fclockw -side left -padx 10 -pady 5 -expand 1
    pack $w.fbuttons -side top -pady "10 15"

    ttk::checkbutton $w.fdisplay.b1 -text $::tr(showblunderexists) -variable ::sergame::showblunder
    ttk::checkbutton $w.fdisplay.b2 -text $::tr(showblundervalue) -variable ::sergame::showblundervalue
    ttk::checkbutton $w.fdisplay.b5 -text $::tr(showscore) -variable ::sergame::showevaluation
    pack $w.fdisplay.b1 $w.fdisplay.b2 $w.fdisplay.b5 -anchor w

    ttk::label $w.fthreshold.l -text $::tr(moveblunderthreshold) -wraplength 300
    ttk::scale $w.fthreshold.t -orient horizontal -from 0.0 -to 10.0 -length 200 \
        -variable ::sergame::threshold -command { ::utils::validate::floatScale ::sergame::threshold 0.1 }
    ttk::label $w.fthreshold.labelt -textvariable ::sergame::threshold
    pack $w.fthreshold.l $w.fthreshold.labelt $w.fthreshold.t -side top -anchor w

    ttk::label $w.finformations.l1 -textvariable ::sergame::blunderWarningLabel -background linen
    ttk::label $w.finformations.l3 -textvariable ::sergame::scoreLabel -foreground WhiteSmoke -background SlateGray
    pack $w.finformations.l1 $w.finformations.l3 -padx 5 -pady 5 -side top -fill x

    ::sergame::resetBlunderLabels

    ttk::button $w.fbuttons.close -textvar ::tr(Abort) -command "destroy .coachWin"
    pack $w.fbuttons.close -expand yes -fill both -padx 20 -pady 2

    ::gameclock::new $w.fclockb 2 80
    ::gameclock::new $w.fclockw 1 80
    ::gameclock::reset 1
    ::gameclock::reset 2

    bind $w <F1> { helpWindow PlayVsEngine }
    bind $w <Destroy> "if {\[string equal $w %W\]} {::sergame::abortGame}"
    bind $w <Escape> "destroy .coachWin"
    wm minsize $w 45 0
    createToplevelFinalize $w

    ::setPlayMode "::sergame::callback"
    ::notify::GameChanged

    clocks init $n
    clocks start
    ::sergame::engineGo $n
  }

  proc callback {cmd args} {
    switch $cmd {
        premove {
            return [expr { ! $::sergame::waitPlayerMove }]
        }
        stop { destroy .coachWin }
    }
    return 0
  }

  proc abortGame { { n 1 } } {
    ::setPlayMode ""
    after cancel ::sergame::engineGo $n
    clocks stop
    set ::sergame::lFen {}
    if { $::uci::uciInfo(pipe$n) != ""} {
      ::uci::closeUCIengine $n
      set ::uci::uciInfo(bestmove$n) "abort"
    }
    if { [info exists ::uci::uciInfo(pipe2)] && $::uci::uciInfo(pipe2) != ""} {
      ::uci::closeUCIengine 2
    }
    if {[winfo exists .coachWin]} {
      ::gameclock::stop 1
      ::gameclock::stop 2
    }
    ::notify::GameChanged
  }

  ################################################################################
  # clocks: manage game clocks (counting up or down)
  ################################################################################
  proc clocks {cmd {n 1}} {
    switch $cmd {
      init {
          if {$::sergame::useChessClock} {
            ::gameclock::setSec 1 [expr 0 - $::uci::uciInfo(wtime$n)/1000]
            ::gameclock::setSec 2 [expr 0 - $::uci::uciInfo(btime$n)/1000]
          } else {
            ::gameclock::reset 1
            ::gameclock::reset 2
          }
      }
      start {
          if { [sc_pos side] == "white" } {
            ::gameclock::start 1
          } else {
            ::gameclock::start 2
          }
      }
      stop {
          ::gameclock::stop 1
          ::gameclock::stop 2
      }
      toggle {
          if {[::gameclock::stop 1]} {
            ::gameclock::storeTimeComment 1
            if {$::sergame::useChessClock} {
              ::gameclock::add 1 [expr $::uci::uciInfo(winc$n)/1000]
            }
            ::gameclock::start 2
          } elseif {[::gameclock::stop 2]} {
            ::gameclock::storeTimeComment 2
            if {$::sergame::useChessClock} {
              ::gameclock::add 2 [expr $::uci::uciInfo(binc$n)/1000]
            }
            ::gameclock::start 1
          }
          ::notify::PosChanged -pgn
      }
    }
  }

  proc takeBack {takebackClockW takebackClockB} {
    sc_move back 1
    if {$takebackClockW != ""} {
      ::gameclock::setSec 1 [expr 0 - $takebackClockW]
      ::gameclock::setSec 2 [expr 0 - $takebackClockB]
      clocks start
    }
    ::notify::PosChanged -pgn
  }

  proc blunderDialog {msg bestMoveText} {
    set w .blunderDialog
    if {[winfo exists $w]} { destroy $w }

    toplevel $w
    wm title $w "scidCommunity"
    wm transient $w .
    wm resizable $w 0 0
    applyThemeColor_background $w

    ttk::frame $w.msg
    ttk::label $w.msg.l -text $msg -wraplength 400 -justify left
    pack $w.msg.l -padx 15 -pady 15
    pack $w.msg -fill x

    ttk::separator $w.sep -orient horizontal
    pack $w.sep -fill x -padx 10

    ttk::frame $w.best
    ttk::label $w.best.l -text "" -wraplength 400 -foreground "#1a1aff"
    pack $w.best.l -padx 15 -pady {10 5}
    pack $w.best -fill x

    ttk::separator $w.sep2 -orient horizontal
    pack $w.sep2 -fill x -padx 10

    set ::blunderResult -1
    ttk::frame $w.btns
    ttk::button $w.btns.show -text "Show Best Move" -command "
      if {[string length \"$bestMoveText\"] > 0} {
        $w.best.l configure -text \"Best move: $bestMoveText\"
      } else {
        $w.best.l configure -text \"(Best move not available)\"
      }
      $w.btns.show configure -state disabled
    "
    ttk::button $w.btns.retry -text "Try Again" -command {set ::blunderResult 1}
    ttk::button $w.btns.keep -text "Use My Move" -command {set ::blunderResult 2}
    pack $w.btns.show $w.btns.retry $w.btns.keep -side left -padx 5
    pack $w.btns -pady {5 15}

    wm protocol $w WM_DELETE_WINDOW {set ::blunderResult 2}
    bind $w <Escape> {set ::blunderResult 2}
    setWinLocation $w
    focus $w.btns.retry
    grab set $w
    tkwait variable ::blunderResult
    grab release $w
    catch {destroy $w}
    return $::blunderResult
  }

  proc sendToEngine {n text} {
    ::sergame::logEngine $n "Scid  : $text"
    catch {puts $::uci::uciInfo(pipe$n) $text}
  }

  proc endOfGame {} {
    if { [string index [sc_game info previousMove] end ] == "#"} {
      clocks stop
      return 1
    }
    return 0
  }

  ################################################################################
  # engineGo: main game loop
  ################################################################################
  proc engineGo { n } {
    global ::sergame::isOpening ::sergame::openingMovesList ::sergame::openingMovesHash ::sergame::openingMoves \
        ::sergame::timeMode ::sergame::outOfOpening

    after cancel ::sergame::engineGo $n

    if { [::sergame::endOfGame] } { return }

    if { [sc_pos side] != $::sergame::engineColor } {
      set ::sergame::waitPlayerMove 1
      ::sergame::updateAnalysisText
      after 1000 ::sergame::engineGo $n
      return
    }

    set takebackClockW ""
    set takebackClockB ""
    if {$::sergame::waitPlayerMove} {
      set ::sergame::waitPlayerMove 0
      set ::sergame::lscore [list $::uci::uciInfo(score2)]
      set ::sergame::playerBlunderSeverity 0
      set ::sergame::playerBlunderDelta 0.0
      set ::sergame::engineBlunderSeverity 0
      set ::sergame::engineBlunderDelta 0.0
      set ::sergame::missedCapitalization 0
      set ::sergame::showBestMove 0
      set ::sergame::blunderCheckPending 0
      set takebackClockW [::gameclock::getSec 1]
      set takebackClockB [::gameclock::getSec 2]
      set ::sergame::takebackClockW $takebackClockW
      set ::sergame::takebackClockB $takebackClockB

      # Engine blunder detection using coach engine (compare evals before/after engine's move)
      if { $::sergame::coachIsWatching && $::sergame::coachAnalyzed && $::sergame::postPlayerScore != "" } {
        set engineCurrScore [lindex $::sergame::lscore 0]
        if {$engineCurrScore != ""} {
          set engineDelta [expr {$engineCurrScore - $::sergame::postPlayerScore}]
          set engBlunder 0
          set absEngDelta [expr abs($engineDelta)]
          if {$absEngDelta >= $::sergame::threshold} {
            if {$absEngDelta >= $::informant(??)} { set engBlunder 3
            } elseif {$absEngDelta >= $::informant(?)} { set engBlunder 2
            } elseif {$absEngDelta >= $::informant(?!)} { set engBlunder 1 }
          }
          if {$::sergame::activeColor == "black" && $engineDelta > 0} { set engBlunder 0 }
          if {$::sergame::activeColor == "white" && $engineDelta < 0} { set engBlunder 0 }
          set ::sergame::engineBlunderDelta $engineDelta
          set ::sergame::engineBlunderSeverity $engBlunder
        }
      }

      # Player blunder detection using coach engine (engine 2) - start async
      if { $::sergame::coachIsWatching && $::sergame::coachAnalyzed && $::uci::uciInfo(pipe2) != "" } {
        set prevScore [lindex $::sergame::lscore 0]
        if {$prevScore != ""} {
          ::sergame::stopAnalyze
          if {[info exists ::uci::uciInfo(pv2)] && $::uci::uciInfo(pv2) != ""} {
            set ::sergame::prevPv $::uci::uciInfo(pv2)
            set ::sergame::prevFen [expr {[info exists ::sergame::lastAnalyzeFen] ? $::sergame::lastAnalyzeFen : [sc_pos fen]}]
          }
          ::sergame::sendToEngine 2 "position fen [sc_pos fen]"
          ::sergame::sendToEngine 2 "go depth 12"
          set ::uci::uciInfo(score2) ""
          set ::uci::uciInfo(bestmove2) ""
          set ::sergame::blunderCheckPending 1
        }
      } else {
        set ::sergame::blunderCheckPending 0
      }

      # Store coach eval on the engine's previous move (only when coach is active)
      if { ($::sergame::storeEval == 1 || $::sergame::showevaluation == 1) && $::sergame::coachAnalyzed } {
        set engineMoveScore [lindex $::sergame::lscore 0]
        if {$engineMoveScore != ""} {
          catch {
            sc_move back 1
            storeEvalComment $engineMoveScore
            sc_move forward 1
          }
        }
      }

      clocks toggle $n
      if {[repetition]} { return }
    }

    # Make a move from a specific opening (engine's turn)
    if {$isOpening && !$outOfOpening} {
      set ply [ expr [sc_pos moveNumber] * 2 - 1]
      if { [sc_pos side] == "white" } { set ply [expr $ply - 1] }

      if { [lsearch $openingMovesHash [sc_pos hash]] == -1 && [llength $openingMovesList] >= $ply} {
        clocks stop
        set answer [tk_messageBox -icon question -parent .main -title $::tr(OutOfOpening) -type yesno \
            -message "$::tr(NotFollowedLine) $openingMoves\n $::tr(DoYouWantContinue)" ]
        if {$answer == no} {
          takeBack $takebackClockW $takebackClockB
          after 1000 ::sergame::engineGo $n
          return
        } else {
          set outOfOpening 1
        }
        clocks start
      }

      set hpos [sc_pos hash]
      set length [llength $openingMovesHash]
      for {set i 0} { $i < [expr $length-1] } { incr i } {
        set h [lindex $openingMovesHash $i]
        if {$h == $hpos} {
          set index [lsearch $openingMovesHash $h]
          set move [lindex $openingMovesList $index]
          set action "replace"
          if {![sc_pos isAt vend]} { set action [confirmReplaceMove] }
          if {$action == "replace"} {
            if {[catch {sc_move addSan $move}]} {}
          } elseif {$action == "var"} {
            sc_var create
            if {[catch {sc_move addSan $move}]} {}
          } elseif {$action == "mainline"} {
            sc_var create
            if {[catch {sc_move addSan $move}]} {}
            sc_var promote
            sc_move forward 1
          }
          clocks toggle $n
          updateBoard -pgn -animate
          if {[repetition]} { return }
          after 1000 ::sergame::engineGo $n
          return
        }
      }
    }

    # Use a book
    if {$::sergame::useBook && ! $::sergame::wentOutOfBook} {
      set move [ ::book::getMove $::sergame::bookToUse [sc_pos fen] $::sergame::bookSlot]
      if {$move == ""} {
        set ::sergame::wentOutOfBook 1
      } else {
        sc_move addSan $move
        ::utils::sound::AnnounceNewMove $move
        set ::uci::uciInfo(prevscore$n) 0.0
        clocks toggle $n
        updateBoard -pgn -animate
        if {[repetition]} { return }
        after 1000 ::sergame::engineGo $n
        return
      }
    }

    # Check if engine pondered on the right move
    if { $::sergame::ponder && $::uci::uciInfo(ponder$n) == [sc_game info previousMoveUCI]} {
      ::sergame::sendToEngine $n "ponderhit"
    } else {
      if { $::sergame::ponder } {
        ::sergame::sendToEngine $n "stop"
      }
      set ::analysis(waitForReadyOk$n) 0
      ::sergame::sendToEngine $n "isready"
      vwaitTimed ::analysis(waitForReadyOk$n) 5000 "nowarn"
      if {$::analysis(waitForReadyOk$n) != 0} {
        # Timeout - abort engine operation
        tk_messageBox -type ok -icon error -parent .main -title "Engine Error" -message "Engine did not respond to isready"
        ::sergame::abortGame
        return
      }
      ::sergame::sendToEngine $n "position fen [sc_pos fen]"

      if {$timeMode == "timebonus"} {
        if {$::sergame::useChessClock} {
          set wtime [expr [::gameclock::getSec 1] * 1000 ]
          set btime [expr [::gameclock::getSec 2] * 1000 ]
          ::sergame::sendToEngine $n "go wtime $wtime btime $btime winc $::uci::uciInfo(winc$n) binc $::uci::uciInfo(binc$n)"
        } else {
          set movetime [expr $::sergame::movetime > 0 ? $::sergame::movetime : 3000]
          ::sergame::sendToEngine $n "go movetime $movetime"
        }
      } elseif {$timeMode == "depth"} {
        ::sergame::sendToEngine $n "go depth $::uci::uciInfo(fixeddepth$n)"
      } elseif {$timeMode == "movetime"} {
        ::sergame::sendToEngine $n "go movetime $::uci::uciInfo(movetime$n)"
      } elseif {$timeMode == "nodes"} {
        ::sergame::sendToEngine $n "go nodes $::uci::uciInfo(fixednodes$n)"
      }
    }

    set ::uci::uciInfo(bestmove$n) ""
    vwait ::uci::uciInfo(bestmove$n)

    if { $::uci::uciInfo(bestmove$n) == "abort" } { return }

    # Finish async player blunder check (coach ran in parallel with engine)
    if {$::sergame::blunderCheckPending} {
      set prevScore [lindex $::sergame::lscore 0]
      set startTime [clock milliseconds]
      set maxWait 3000
      while {$::uci::uciInfo(bestmove2) == "" && $::uci::uciInfo(pipe2) != "" && [expr {[clock milliseconds] - $startTime}] < $maxWait} {
        update
        after 10
      }
      set currScore $::uci::uciInfo(score2)
      if {$currScore != "" && $prevScore != ""} {
        set delta [expr {$currScore - $prevScore}]
        set blunder 0
        set absDelta [expr abs($delta)]
        if {$absDelta >= $::sergame::threshold} {
          if {$absDelta >= $::informant(??)} { set blunder 3
          } elseif {$absDelta >= $::informant(?)} { set blunder 2
          } elseif {$absDelta >= $::informant(?!)} { set blunder 1 }
        }
        if {$::sergame::activeColor == "white" && $delta > 0} { set blunder 0 }
        if {$::sergame::activeColor == "black" && $delta < 0} { set blunder 0 }
        set ::sergame::playerBlunderDelta $delta
        set ::sergame::playerBlunderSeverity $blunder
        set ::sergame::postPlayerScore $currScore
        if {$::sergame::storeEvalAll == 1 && $::sergame::coachAnalyzed} {
          storeEvalComment $currScore
        }
        if {$blunder != 0} {
          if {$blunder == 1} { set tBlunder "DubiousMovePlayedTakeBack"
          } elseif {$blunder == 2} { set tBlunder "WeakMovePlayedTakeBack"
          } else { set tBlunder "BadMovePlayedTakeBack" }
          set msg $::tr($tBlunder)
          set bestMoveText ""
          set prevPv [expr {[info exists ::sergame::prevPv] ? $::sergame::prevPv : ""}]
          if {$prevPv ne ""} {
            set bestMoveUCI [lindex [split $prevPv] 0]
            if {$bestMoveUCI ne ""} {
              set prevFen [expr {[info exists ::sergame::prevFen] ? $::sergame::prevFen : [sc_pos fen]}]
              set bestMoveText $bestMoveUCI
              set san [::uci::formatPv $bestMoveUCI $prevFen]
              if {$san ne ""} { set bestMoveText $san }
            }
          }
          clocks stop
          set choice [::sergame::blunderDialog $msg $bestMoveText]
          if {$choice == 1} {
            set ::sergame::postPlayerScore ""
            sc_move back 1
            ::gameclock::setSec 1 [expr 0 - $::sergame::takebackClockW]
            ::gameclock::setSec 2 [expr 0 - $::sergame::takebackClockB]
            clocks start
            ::notify::PosChanged -pgn
            ::sergame::startAnalyze
            after 1000 ::sergame::engineGo $n
            return
          }
          clocks start
        }
      }
      set ::sergame::blunderCheckPending 0
    }

    # Check if player capitalized on an opponent engine blunder
    if { $::sergame::engineBlunderSeverity != 0 && $::sergame::playerBlunderSeverity == 0 } {
      set engineCurrScore [lindex $::sergame::lscore 0]
      if {$engineCurrScore != "" && $::sergame::postPlayerScore != ""} {
        set playerDelta [expr {$::sergame::postPlayerScore - $engineCurrScore}]
        set ::sergame::missedCapitalization 0
        if {$::sergame::activeColor == "white"} {
          if {$playerDelta <= $::informant(!?)} {
            set ::sergame::missedCapitalization 1
          } else {
            set ::sergame::engineBlunderSeverity 0
          }
        } else {
          if {$playerDelta >= [expr {0.0 - $::informant(!?)}]} {
            set ::sergame::missedCapitalization 1
          } else {
            set ::sergame::engineBlunderSeverity 0
          }
        }
      }
    } else {
      set ::sergame::missedCapitalization 0
    }

    set ::uci::uciInfo(prevscore$n) $::uci::uciInfo(score$n)
    ::sergame::updatePlayerAnalysis $::uci::uciInfo(score$n) $::uci::uciInfo(score2)

    ::uci::sc_move_add $::uci::uciInfo(bestmove$n)
    ::utils::sound::AnnounceNewMove $::uci::uciInfo(bestmove$n)

    if { ($::sergame::storeEval == 1 || $::sergame::showevaluation == 1) && !$::sergame::coachAnalyzed } {
      if {[info exists ::uci::uciInfo(score$n)]} {
        storeEvalComment $::uci::uciInfo(score$n)
      }
    }

    updateBoard -pgn -animate
    if {[repetition]} { return }

    clocks toggle $n

    if {$::sergame::coachIsWatching} {
      ::sergame::startAnalyze
    }

    # Ponder mode
    if {$::sergame::ponder && $::uci::uciInfo(ponder$n) != ""} {
      ::sergame::sendToEngine $n "position fen [sc_pos fen] moves $::uci::uciInfo(ponder$n)"
      set wtime [expr [::gameclock::getSec 1] * 1000 ]
      set btime [expr [::gameclock::getSec 2] * 1000 ]
      if {$timeMode == "timebonus"} {
        if {$::sergame::useChessClock} {
          ::sergame::sendToEngine $n "go ponder wtime $wtime btime $btime winc $::uci::uciInfo(winc$n) binc $::uci::uciInfo(binc$n)"
        } else {
          set movetime [expr $::sergame::movetime > 0 ? $::sergame::movetime : 3000]
          ::sergame::sendToEngine $n "go ponder movetime $movetime"
        }
      } elseif {$timeMode == "depth"} {
        ::sergame::sendToEngine $n "go ponder depth $::uci::uciInfo(fixeddepth$n)"
      } elseif {$timeMode == "movetime"} {
        ::sergame::sendToEngine $n "go ponder movetime $::uci::uciInfo(movetime$n)"
      } elseif {$timeMode == "nodes"} {
        ::sergame::sendToEngine $n "go ponder nodes $::uci::uciInfo(fixednodes$n)"
      }
    }

    after 1000 ::sergame::engineGo $n
  }

  ################################################################################
  # repetition: detect threefold repetition
  ################################################################################
  proc repetition {} {
    set elt [lrange [split [sc_pos fen]] 0 3]
    if { $elt != [ lindex $::sergame::lFen end ] } {
      lappend ::sergame::lFen $elt
    }
    if { [llength [lsearch -all $::sergame::lFen $elt] ] >=3 } {
      tk_messageBox -type ok -message $::tr(Draw) -parent .main -icon info
      return 1
    }
    return 0
  }

  ################################################################################
  # Coach analysis (engine 2): start/stop
  ################################################################################
  proc startAnalyze { } {
    global ::sergame::isLimitedAnalysisTime ::sergame::analysisTime
    set n 2
    after cancel ::sergame::stopAnalyze
    set ::analysis(waitForReadyOk$n) 0
    ::uci::sendToEngine $n "isready"
    vwaitTimed ::analysis(waitForReadyOk$n) 5000 "nowarn"
    if {$::analysis(waitForReadyOk$n) != 0} {
      return
    }
    ::uci::sendToEngine $n "position fen [sc_pos fen]"
    set ::sergame::lastAnalyzeFen [sc_pos fen]
    ::uci::sendToEngine $n "go depth 12"
    set ::sergame::coachAnalyzed 1

    if { $isLimitedAnalysisTime == 1 } {
      after [expr 1000 * $analysisTime] ::sergame::stopAnalyze
    }
  }

  proc stopAnalyze { } {
    after cancel ::sergame::stopAnalyze
    ::uci::sendToEngine 2 "stop"
  }

  ################################################################################
  # updatePlayerAnalysis: assess the player's just-played move
  ################################################################################
  proc updatePlayerAnalysis { sc1 sc2 } {
    if { ![winfo exists .coachWin] } { return }

    if { $::sergame::showevaluation && $sc2 != "" } {
      set ::sergame::scoreLabel "Score : $sc2"
    } else {
      set ::sergame::scoreLabel ""
    }

    if { $::sergame::showblunder } {
      if {$::sergame::playerBlunderSeverity != 0} {
        set delta $::sergame::playerBlunderDelta
        set ::sergame::lastblundervalue [expr abs($delta)]
        set scPrev [lindex $::sergame::lscore end]
        if { [expr abs($scPrev)] < $::informant(+--) } {
          if {$::sergame::coachNag ne ""} {
            catch {sc_pos removeNag $::sergame::coachNag}
          }
          set b [expr abs($delta)]
          if { $b >= $::informant(?!) && $b < $::informant(?) } {
            catch {sc_pos addNag "?!"}
            set ::sergame::coachNag "?!"
          } elseif { $b >= $::informant(?) && $b < $::informant(??) } {
            catch {sc_pos addNag "?"}
            set ::sergame::coachNag "?"
          } elseif { $b >= $::informant(??) } {
            catch {sc_pos addNag "??"}
            set ::sergame::coachNag "??"
          }
        }
        .coachWin.finformations.l1 configure -background LightCoral
        if { $::sergame::showblundervalue } {
          set tmp $::tr(blunder)
          append tmp [format " %+8.2f" $::sergame::lastblundervalue]
          set ::sergame::blunderWarningLabel $tmp
        } else {
          set ::sergame::blunderWarningLabel "$::tr(blunder) !"
        }
        set ::sergame::blunderpending 1
      } elseif {$::sergame::missedCapitalization} {
        if {$::sergame::coachNag ne ""} {
          catch {sc_pos removeNag $::sergame::coachNag}
          set ::sergame::coachNag ""
        }
        .coachWin.finformations.l1 configure -background LightYellow
        set ::sergame::blunderWarningLabel "You missed an opportunity - opponent made a mistake"
        set ::sergame::blunderpending 1
      } elseif {$::sergame::engineBlunderSeverity != 0} {
        .coachWin.finformations.l1 configure -background LightYellow
        set ::sergame::blunderWarningLabel "Opponent made a mistake - look for winning move"
        set ::sergame::blunderpending 1
      } else {
        if {$::sergame::coachNag ne ""} {
          catch {sc_pos removeNag $::sergame::coachNag}
          set ::sergame::coachNag ""
        }
        .coachWin.finformations.l1 configure -background linen
        set ::sergame::blunderWarningLabel $::tr(Noblunder)
        set ::sergame::blunderpending 0
      }
    }
  }

  ################################################################################
  # updateAnalysisText: refresh live coach analysis during the player's turn
  ################################################################################
  proc updateAnalysisText { } {
    if { ![winfo exists .coachWin] } { return }
    if { $::sergame::engineColor == "" } { return }
    if { $::sergame::engineColor == [sc_pos side] } { return }

    if { $::sergame::showblunder } {
      if {$::sergame::playerBlunderSeverity == 0 && $::sergame::engineBlunderSeverity == 0 && !$::sergame::missedCapitalization && !$::sergame::showBestMove} {
      .coachWin.finformations.l1 configure -background linen
      set ::sergame::blunderWarningLabel $::tr(Noinfo)
      set ::sergame::blunderpending 0
      }
    }

    if { $::sergame::showevaluation && [info exists ::uci::uciInfo(score2)] && $::uci::uciInfo(score2) != "" } {
      set ::sergame::scoreLabel "Score : $::uci::uciInfo(score2)"
    } else {
      set ::sergame::scoreLabel ""
    }
  }

  proc resetBlunderLabels {} {
    set ::sergame::blunderWarningLabel $::tr(Noinfo)
    set ::sergame::scoreLabel ""
    set ::sergame::lscore {}
    set ::sergame::playerBlunderDelta 0.0
    set ::sergame::playerBlunderSeverity 0
    set ::sergame::postPlayerScore ""
    set ::sergame::engineBlunderDelta 0.0
    set ::sergame::engineBlunderSeverity 0
    set ::sergame::missedCapitalization 0
    set ::sergame::showBestMove 0
  }

  ################################################################################
  # changePVSize: configure multipv for coach engine
  ################################################################################
  proc changePVSize {n} {
    set pv $::uci::uciInfo(multipv$n)
    ::sergame::sendToEngine $n "setoption name MultiPV value $pv"
    set ::uci::uciInfo(multipv$n) $pv
  }

  ################################################################################
  # logEngine: optional engine communication logging
  ################################################################################
  proc logEngine {n text} {
    if {[info exists ::uci::uciInfo(log_stdout$n)] && $::uci::uciInfo(log_stdout$n)} {
      puts stdout "$n $text"
    }
  }

  ################################################################################
  # Opening list (shared by config dialog)
  ################################################################################
  set openingList [ list \
      "$::tr(Reti): 1.Nf3" \
      "$::tr(English): 1.c4" \
      "$::tr(d4Nf6Miscellaneous): 1.d4 Nf6" \
      "$::tr(Trompowsky): 1.d4 Nf6 2.Bg5" \
      "$::tr(Budapest): 1.d4 Nf6 2.c4 e5" \
      "$::tr(OldIndian): 1.d4 Nf6 2.c4 d6" \
      "$::tr(BenkoGambit): 1.d4 Nf6 2.c4 c5 3.d5 b5" \
      "$::tr(ModernBenoni): 1.d4 Nf6 2.c4 c5 3.d5 e6" \
      "$::tr(DutchDefence): 1.d4 f5" \
      "1.e4" \
      "$::tr(Scandinavian): 1.e4 d5" \
      "$::tr(AlekhineDefence): 1.e4 Nf6" \
      "$::tr(Pirc): 1.e4 d6" \
      "$::tr(CaroKann): 1.e4 c6" \
      "$::tr(CaroKannAdvance): 1.e4 c6 2.d4 d5 3.e5" \
      "$::tr(Sicilian): 1.e4 c5" \
      "$::tr(SicilianAlapin): 1.e4 c5 2.c3" \
      "$::tr(SicilianClosed): 1.e4 c5 2.Nc3" \
      "$::tr(Sicilian): 1.e4 c5 2.Nf3 Nc6" \
      "$::tr(Sicilian): 1.e4 c5 2.Nf3 e6" \
      "$::tr(SicilianRauzer): 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 Nc6" \
      "$::tr(SicilianDragon): 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 g6 " \
      "$::tr(SicilianScheveningen): 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 e6" \
      "$::tr(SicilianNajdorf): 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6" \
      "$::tr(OpenGame): 1.e4 e5" \
      "$::tr(Vienna): 1.e4 e5 2.Nc3" \
      "$::tr(KingsGambit): 1.e4 e5 2.f4" \
      "$::tr(RussianGame): 1.e4 e5 2.Nf3 Nf6" \
      "$::tr(OpenGame): 1.e4 e5 2.Nf3 Nc6" \
      "$::tr(ItalianTwoKnights): 1.e4 e5 2.Nf3 Nc6 3.Bc4" \
      "$::tr(Spanish): 1.e4 e5 2.Nf3 Nc6 3.Bb5" \
      "$::tr(SpanishExchange): 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Bxc6" \
      "$::tr(SpanishOpen): 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Nxe4" \
      "$::tr(SpanishClosed): 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7" \
      "$::tr(FrenchDefence): 1.e4 e6" \
      "$::tr(FrenchAdvance): 1.e4 e6 2.d4 d5 3.e5" \
      "$::tr(FrenchTarrasch): 1.e4 e6 2.d4 d5 3.Nd2" \
      "$::tr(FrenchWinawer): 1.e4 e6 2.d4 d5 3.Nc3 Bb4" \
      "$::tr(FrenchExchange): 1.e4 e6 2.d4 d5 3.exd5 exd5" \
      "$::tr(QueensPawn): 1.d4 d5" \
      "$::tr(Slav): 1.d4 d5 2.c4 c6" \
      "$::tr(QGA): 1.d4 d5 2.c4 dxc4" \
      "$::tr(QGD): 1.d4 d5 2.c4 e6" \
      "$::tr(QGDExchange): 1.d4 d5 2.c4 e6 3.cxd5 exd5" \
      "$::tr(SemiSlav): 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Nf3 c6" \
      "$::tr(QGDwithBg5): 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Bg5" \
      "$::tr(QGDOrthodox): 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Bg5 Be7 5.e3 O-O 6.Nf3 Nbd7" \
      "$::tr(Grunfeld): 1.d4 Nf6 2.c4 g6 3.Nc3 d5" \
      "$::tr(GrunfeldExchange): 1.d4 Nf6 2.c4 g6 3.Nc3 d5 4.cxd5" \
      "$::tr(GrunfeldRussian): 1.d4 Nf6 2.c4 g6 3.Nc3 d5 4.Nf3 Bg7 5.Qb3" \
      "$::tr(Catalan): 1.d4 Nf6 2.c4 e6 3.g3 " \
      "$::tr(CatalanOpen): 1.d4 Nf6 2.c4 e6 3.g3 d5 4.Bg2 dxc4" \
      "$::tr(CatalanClosed): 1.d4 Nf6 2.c4 e6 3.g3 d5 4.Bg2 Be7" \
      "$::tr(QueensIndian): 1.d4 Nf6 2.c4 e6 3.Nf3 b6" \
      "$::tr(NimzoIndian): 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4" \
      "$::tr(NimzoIndianClassical): 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.Qc2" \
      "$::tr(NimzoIndianRubinstein): 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.e3" \
      "$::tr(KingsIndian): 1.d4 Nf6 2.c4 g6" \
      "$::tr(KingsIndianSamisch): 1.d4 Nf6 2.c4 g6 4.e4 d6 5.f3" \
      "$::tr(KingsIndianMainLine): 1.d4 Nf6 2.c4 g6 4.e4 d6 5.Nf3" \
      ]
}
###
### End of file: sergame.tcl
###
