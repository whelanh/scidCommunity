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

  # --- the game's two engine connections ---------------------------------
  # The module used to share the old Analysis engine mode: two numeric engine
  # slots in that mode's shared state, a flag it waited on, and a blocking wait
  # for the bestmove. Each engine now owns a ::engineNoWin connection under its
  # own id (a literal, as for every other ::engineNoWin client), keeps what the
  # engine answers and what the game gives the engine in that connection's own
  # state, and answers through the connection's callback. The ids are strings,
  # not slot numbers, so the two engines -- the opponent and the coach -- cannot
  # overwrite each other's score, bestmove, ponder flag or clock.
  set playerId sergamePlayer
  set coachId sergameCoach

  # The game's clock and increment, in milliseconds. Each connection carries its
  # own copy (see seedClocks): a search reads the clock of the connection it runs
  # on. options.tcl sets these; the defaults here are for a harness that sources
  # this file alone.
  if {![info exists wtime]} { set wtime [expr 5 * 60 * 1000] }
  if {![info exists winc]}  { set winc  [expr 10 * 1000] }
  if {![info exists btime]} { set btime [expr 5 * 60 * 1000] }
  if {![info exists binc]}  { set binc  [expr 10 * 1000] }

  # if true, follow a specific opening
  set openingMovesList {}
  set openingMovesHash {}
  set openingMoves ""
  set outOfOpening 0
  array set engineListBox {}
  set engineName ""
  set coachName ""
  set bookSlot 2
  if {![info exists storeEval]} { set storeEval 0 }
  if {![info exists storeEvalAll]} { set storeEvalAll 0 }
  if {![info exists coachIndex]} { set coachIndex 0 }
  set engineColor ""
  if {![info exists playerColor]} { set playerColor "" }

  # coach blunder tracking
  # lscore: coach evaluations of the positions reached after each engine move
  # liveScore/livePv: last coach output captured during the player's turn
  # (score2 is only sign-reliable while the analyzed position is on the board)
  set resignCount 0
  set lastblundervalue 0.0
  set blunderpending 0
  set currentPosHash 0
  set lscore {}
  set liveScore ""
  set livePv ""
  set playerMoved 0
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
      # The engine's options are the preset's own, edited where every other
      # preset is edited: the legacy UCI options window belongs to the old pipe
      # engine mode that #437 §6 deletes.
      ::enginelist::choose
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
    ttk::spinbox $w.fcoach.ad.val -width 3 -from 1 -to 360 -increment 1 -textvariable ::sergame::analysisTime -validate all -validatecommand { regexp {^[0-9]+$} %P }
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

    $w.ftime.clock.whitespminutes set [expr $::sergame::wtime / (60 * 1000)]
    $w.ftime.clock.whitespseconds set [expr $::sergame::winc /  1000]
    $w.ftime.clock.blackspminutes set [expr $::sergame::btime / (60 * 1000)]
    $w.ftime.clock.blackspseconds set [expr $::sergame::binc /  1000 ]

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
      ::sergame::play
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
      set ::sergame::coachName [$w.fcoach.en.cbCoach get]
    }

    catch { set ::sergame::depth [$w.ftime.depth.value get] }
    catch { set ::sergame::nodes [$w.ftime.nodes.value get] }
    catch { set ::sergame::movetime [expr {[$w.ftime.movetime.value get] * 1000}] }

    catch { set ::sergame::wtime [expr {[$w.ftime.clock.whitespminutes get] * 1000 * 60}] }
    catch { set ::sergame::btime [expr {[$w.ftime.clock.blackspminutes get] * 1000 * 60}] }
    catch { set ::sergame::winc [expr {[$w.ftime.clock.whitespseconds get] * 1000}] }
    catch { set ::sergame::binc [expr {[$w.ftime.clock.blackspseconds get] * 1000}] }

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
  proc play { {n 1} } {
    global ::sergame::chosenOpening ::sergame::isOpening ::sergame::openingList ::sergame::openingMovesList \
        ::sergame::openingMovesHash ::sergame::openingMoves ::sergame::outOfOpening

    # Abort and clean up any previous game before starting a new one
    if {[winfo exists .coachWin]} {
      focus .
      destroy .coachWin
    }
    # createToplevelFinalize removes this window's docking container on idle,
    # and this proc destroys and rebuilds the window inside one call: without
    # pumping the idle here the second Play in a session died with
    #   window name ".fdockcoachWin" already exists in parent
    # before the game window was built - engine started, no interface, clocks
    # never armed. The explicit destroy is the belt: an idle that never ran
    # leaves the frame behind.
    catch { update idletasks }
    catch { destroy .fdockcoachWin }

    if {$::sergame::isOpening || !$::sergame::startFromCurrent} {
      if {[::game::Clear] eq "cancel"} { return }
    }

    set ::sergame::lFen {}
    set ::sergame::lscore {}
    set ::sergame::liveScore ""
    set ::sergame::livePv ""
    set ::sergame::playerMoved 0
    set ::sergame::resignCount 0
    set ::sergame::lastblundervalue 0.0
    set ::sergame::blunderpending 0
    set ::sergame::blunderWarningLabel ""
    set ::sergame::scoreLabel ""
    set ::sergame::coachNag ""

    set ::sergame::activeColor $::sergame::playerColor
    if {$::sergame::activeColor == "random"} {
      set ::sergame::activeColor [lindex {white black} [expr {int(rand() * 2)}]]
    }

    # Engine plays for the opposite side of player color
    if {$::sergame::activeColor == "white"} {
      set ::sergame::engineColor "black"
      ::board::flip .main.board 0
    } else {
      set ::sergame::engineColor "white"
      ::board::flip .main.board 1
    }

    # Start opponent engine (engine 1) on its own connection. The config dialog
    # recorded the chosen engine's name; resolve it against the current list
    # here, because Configure Engines can reorder the list after the dialog was
    # built and an index stored then is not the engine the user picked.
    ::sergame::openEngine $::sergame::engineName $n

    if {$::sergame::coachIsWatching} {
      ::sergame::openEngine $::sergame::coachName 2
      ::sergame::stSet 2 multipv 1
      ::sergame::changePVSize 2
      ::sergame::startAnalyze
    }

    if {$::sergame::startFromCurrent} {
      set isOpening 0
    }

    # Ponder
    if {$::sergame::ponder} {
      ::sergame::sendOptions $n [list [list Ponder true]]
    } else {
      ::sergame::sendOptions $n [list [list Ponder false]]
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
    createToplevel $w
    applyThemeColor_background $w
    setTitle $w "$::tr(configurePlayEngine)"

    ttk::frame $w.fdisplay
    ttk::frame $w.fthreshold
    ttk::frame $w.finformations
    ttk::frame $w.fclocks
    # fclockw always holds the white clock (gameclock 1);
    # fclockb always holds the black clock (gameclock 2).
    # Labels show the actual colours of the clocks they contain.
    ttk::labelframe $w.fclockw -text "$::tr(Time) $::tr(White)"
    ttk::labelframe $w.fclockb -text "$::tr(Time) $::tr(Black)"
    ttk::frame $w.fbuttons
    pack $w.fdisplay -side top -fill both -pady 5 -padx 10
    pack [ttk::separator $w.line1 -orient horizontal] -side top -fill x -padx 10 -pady 5
    pack $w.fthreshold -side top -fill both -pady 5 -padx 10
    pack [ttk::separator $w.line2 -orient horizontal] -side top -fill x -padx 10 -pady 5
    pack $w.finformations -side top -fill both -pady 5 -padx 10
    pack $w.fclocks -side top -fill both -pady 5 -padx 10
    # Stack the clocks vertically: the engine's clock goes above the player's
    # clock. The engine plays the opposite colour to the player, so choose the
    # top frame accordingly (engine is black when the player is white, and
    # engine is white when the player is black).
    if {$::sergame::activeColor == "white"} {
      pack $w.fclockb $w.fclockw -side top -fill x -padx 10 -pady 5
    } else {
      pack $w.fclockw $w.fclockb -side top -fill x -padx 10 -pady 5
    }
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

    ::gameclock::new $w.fclockb 2 88
    ::gameclock::new $w.fclockw 1 88
    # Colour each clock face to match its side: white clock = white face with
    # black markings, black clock = black face with white markings.
    ::gameclock::setColor 1 white
    ::gameclock::setColor 2 black
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
            if { $::sergame::waitPlayerMove } {
              # Player is about to move — cancel any pending deferred-eval
              # from the previous engine move so it doesn't land on the
              # wrong position, then freeze the coach's eval BEFORE the
              # board changes.
              after cancel ::sergame::_storeCoachEvalDeferred
              if {$::sergame::coachIsWatching} {
                ::sergame::stopAnalyze
                set ::sergame::liveScore [::sergame::st 2 score ""]
                set ::sergame::livePv [::sergame::st 2 pv ""]
              }
              return 0
            }
            return 1
        }
        stop { destroy .coachWin }
    }
    return 0
  }

  proc abortGame { { n 1 } } {
    ::setPlayMode ""
    # Both loops, not just the role that disconnected: a coach that dies while
    # the opponent's poll is still scheduled must not leave that poll running.
    after cancel ::sergame::engineGo 1
    after cancel ::sergame::engineGo 2
    clocks stop
    set ::sergame::lFen {}
    # A game that ends takes its connections with it. A search that is still
    # running has no move to give this game any more, and the answer it may
    # still deliver must not reach the board: closing the connection drops both
    # the quest (see ::sergame::answer) and the state it was keeping.
    ::sergame::closeEngines
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
            ::gameclock::setSec 1 [expr 0 - [::sergame::st $n wtime 0]/1000]
            ::gameclock::setSec 2 [expr 0 - [::sergame::st $n btime 0]/1000]
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
              ::gameclock::add 1 [expr [::sergame::st $n winc 0]/1000]
            }
            ::gameclock::start 2
          } elseif {[::gameclock::stop 2]} {
            ::gameclock::storeTimeComment 2
            if {$::sergame::useChessClock} {
              ::gameclock::add 2 [expr [::sergame::st $n binc 0]/1000]
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

  ################################################################################
  # The game's engine connections
  #
  # One connection per engine, opened by ::engineNoWin under the id this module
  # names it by. What the engine answers, and what the game gives the engine,
  # lives in that connection's state (::engine::state): nothing is shared, so
  # the coach's reply cannot rewrite the opponent's score, and no answer is
  # written anywhere keyed by a slot number.
  ################################################################################

  # The connection an engine plays on: n = 1 the opponent, n = 2 the coach.
  proc connId {n} {
    if {$n == 2} { return $::sergame::coachId }
    return $::sergame::playerId
  }

  # One field of n's connection state (see ::engine::state).
  proc st {n field {default ""}} {
    return [::engine::state [::sergame::connId $n] $field $default]
  }

  proc stSet {n field value} {
    return [::engine::setState [::sergame::connId $n] $field $value]
  }

  # Copy the game's clock and limits onto a connection: the search that runs
  # there reads them from its own state.
  proc seedClocks {n} {
    global ::sergame::wtime ::sergame::winc ::sergame::btime ::sergame::binc \
        ::sergame::depth ::sergame::nodes ::sergame::movetime
    ::sergame::stSet $n wtime $::sergame::wtime
    ::sergame::stSet $n btime $::sergame::btime
    ::sergame::stSet $n winc  $::sergame::winc
    ::sergame::stSet $n binc  $::sergame::binc
    ::sergame::stSet $n fixeddepth $::sergame::depth
    ::sergame::stSet $n fixednodes $::sergame::nodes
    ::sergame::stSet $n movetime   $::sergame::movetime
  }

  # Open one engine on its own connection. `name` is the preset's name, not its
  # index: the list can be reordered (Configure Engines sorts it) after the
  # config dialog recorded the choice, so the name is resolved against the
  # current list here. Returns 1 when it could not be started, having said so
  # the way the game always has: the caller carries on and the game reports the
  # engine missing on its first move.
  proc openEngine {name n} {
    set id [::sergame::connId $n]
    # ::engineNoWin::initEngine answers 1 without connecting when a live
    # connection already holds this id (it tests engConfig_$id): a game that
    # ended badly must not lend its engine, and its callback, to the next one.
    catch { ::engineNoWin::closeEngine $id }
    set index [lsearch -exact -index 0 $::engines(list) $name]
    if {$index < 0} {
      tk_messageBox -title "scidCommunity: error starting engine" -icon warning -type ok \
        -message "Unable to start the program:\n[toAbsPath $name]"
      return 1
    }
    set engineData [lindex $::engines(list) $index]
    if {[catch {
      ::engineNoWin::initEngine $id $name [list ::sergame::message $n]
    } err]} {
      tk_messageBox -title "scidCommunity: error starting engine" -icon warning -type ok \
        -message "Unable to start the program:\n[toAbsPath [lindex $engineData 1]]"
      return 1
    }
    # What this connection keeps. The opponent starts level and without a move;
    # the coach has no score of its own until it has searched.
    if {$n == 2} {
      ::sergame::stSet $n score ""
      ::sergame::stSet $n prevscore ""
    } else {
      ::sergame::stSet $n score 0.0
      ::sergame::stSet $n prevscore 0.0
    }
    ::sergame::stSet $n ponder ""
    ::sergame::stSet $n pv ""
    ::sergame::stSet $n depth ""
    ::sergame::stSet $n bestmove ""
    ::sergame::stSet $n multipv 1
    ::sergame::stSet $n log_stdout 0
    ::sergame::stSet $n search ""
    ::sergame::stSet $n searches 0
    ::sergame::stSet $n want ""
    ::sergame::stSet $n fen ""
    ::sergame::seedClocks $n
    # Engine traffic goes through ::enginecomm's own log hooks, which know the
    # direction of every line: the module does not have to log its own sends.
    ::engine::setLogCmd $id [list ::sergame::logEngine $n "Engine:"] \
                              [list ::sergame::logEngine $n "Scid  :"]
    return 0
  }

  proc closeEngines {} {
    foreach n {1 2} {
      set id [::sergame::connId $n]
      set wasConnected [::engine::connected $id]
      if {$wasConnected} {
        ::sergame::stSet $n search ""
        ::sergame::stSet $n want ""
        ::sergame::stSet $n bestmove ""
        ::sergame::stSet $n ponder ""
      }
      # Always close, connected or not: a connection whose engine died is gone
      # from ::enginecomm but still owns its ::enginecfg::engConfig_$id entry,
      # and an entry left behind makes the next initEngine answer 1 without
      # connecting - the game after a crash had no engine until a second Play.
      catch { ::engineNoWin::closeEngine $id }
    }
  }

  proc sendOptions {n options} {
    set id [::sergame::connId $n]
    if {![::engine::connected $id]} { return 0 }
    catch { ::engine::send $id SetOptions $options }
    return 1
  }

  # The `go` limits of this move, as ::enginecomm's Go message carries them: a
  # list of {type value} pairs, which becomes the engine's own "go ..." line.
  proc goLimits {n} {
    global ::sergame::timeMode ::sergame::movetime ::sergame::useChessClock
    switch -- $timeMode {
      timebonus {
        if {$::sergame::useChessClock} {
          set wtime [expr [::gameclock::getSec 1] * 1000 ]
          set btime [expr [::gameclock::getSec 2] * 1000 ]
          return [list wtime $wtime btime $btime \
            winc [::sergame::st $n winc 0] binc [::sergame::st $n binc 0]]
        }
        set ms [expr $::sergame::movetime > 0 ? $::sergame::movetime : 3000]
        return [list movetime $ms]
      }
      depth    { return [list depth [::sergame::st $n fixeddepth 1]] }
      movetime { return [list movetime [::sergame::st $n movetime 0]] }
      nodes    { return [list nodes [::sergame::st $n fixednodes 0]] }
    }
    return {}
  }

  # The position a search actually starts from: `moves` (a UCI move list, e.g. a
  # ponder line) applied to `fen`. A ponder search is "position fen <fen> moves
  # <moves>", so the engine's score and PV are for the position after <moves>,
  # not before; that is the fen its score must be turned by and its line shown
  # from. Falls back to the unshifted fen when the position cannot be computed.
  proc fenAfter {fen moves} {
    set result $fen
    if {[catch { sc_game push }]} { return $result }
    if {[catch {
      sc_game startBoard $fen
      ::ucifmt::sc_move_add [split $moves]
      set result [sc_pos fen]
    }]} {
      set result $fen
    }
    catch { sc_game pop }
    return $result
  }

  # Send one search and record what its answer is for: "move" means the answer
  # is the move the game plays, "line" the coach's evaluation. Nothing here
  # waits -- ::enginecomm delivers the answer to ::sergame::message, and a
  # search that is replaced, cancelled or orphaned by a dead engine leaves
  # nothing behind but the search number it was sent under.
  # `moves` (when given) is the ponder line the search starts from.
  proc ask {n limits {moves ""} {want move}} {
    set id [::sergame::connId $n]
    if {![::engine::connected $id]} { return 0 }
    set fen [sc_pos fen]
    set position "position fen $fen"
    if {$moves ne ""} { append position " moves $moves" }
    set token [expr {[::sergame::st $n searches 0] + 1}]
    ::sergame::stSet $n searches $token
    ::sergame::stSet $n search $token
    ::sergame::stSet $n want $want
    # The position the engine answers for: after the ponder moves, so a score is
    # turned for White by the side that is actually to move and the line is
    # shown from the position the engine searched (not the one before it).
    if {$moves ne ""} {
      ::sergame::stSet $n fen [::sergame::fenAfter $fen $moves]
    } else {
      ::sergame::stSet $n fen $fen
    }
    # A new search has no score yet: the one held here belongs to the previous
    # search, and must not be quoted as this one's.
    ::sergame::stSet $n score ""
    ::sergame::stSet $n pv ""
    ::sergame::stSet $n depth ""
    ::sergame::stSet $n bestmove ""
    if {[catch { ::engine::send $id Go [list $position $limits] } err]} {
      ::sergame::stSet $n search ""
      return 0
    }
    return 1
  }

  # The engine pondered the move the player played: it keeps searching the same
  # line, and its answer is still the move the game plays. ponderhit is not a
  # request -- UCI defines no reply to it, and what follows is the pending Go's
  # bestmove -- so it goes onto the connection's wire without touching the reply
  # queue that bestmove belongs to.
  proc ponderHit {n} {
    set id [::sergame::connId $n]
    if {![::engine::connected $id]} { return 0 }
    catch { ::engine::rawsend $id "ponderhit" }
    return 1
  }

  # A UCI score in pawns from White's point of view, which is the form this
  # module has always compared (it is what the old reader in uci.tcl wrote): a
  # cp score is the engine's own, a mate is the ±327.xx sentinel its distance
  # produces, and the side to move turns it.
  proc whiteScore { score scoreType fen } {
    set mate 0
    if {$scoreType eq "mate"} {
      set mate [expr {int($score)}]
      set cp [expr {$mate < 0 ? -32767 - 2 * $mate : 32767 - 2 * $mate}]
    } else {
      set cp [expr {double($score)}]
    }
    if {[lindex [split $fen] 1] eq "b"} {
      set cp [expr {0.0 - $cp}]
      if {$mate} {
        set mate [expr {0 - $mate}]
        if {$cp < 0} { set cp [expr {$cp - 1.0}] }
      }
    } elseif {$mate && $cp > 0} {
      set cp [expr {$cp + 1.0}]
    }
    return [expr {double($cp) / 100.0}]
  }

  # Messages from ::enginecomm on one of the game's connections. n is the role
  # the connection plays in this game (1 opponent, 2 coach), bound when the
  # connection was opened: the callback belongs to the connection, not to a slot.
  proc message {n msg} {
    lassign $msg type data
    switch -- $type {
      InfoPV         { ::sergame::onInfo $n $data }
      InfoBestMove   { ::sergame::onBestMove $n $data }
      InfoDisconnected { ::sergame::engineGone $n }
    }
    return
  }

  # Keep the line of the search in flight. ::enginecomm drops info lines that
  # arrive after a stop request, so the line has to be kept while it streams.
  proc onInfo {n msgData} {
    if {[::sergame::st $n search] eq ""} { return }
    lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time \
        score scoreType scoreWdl
    # The old reader took the first line of a multiPV search and nothing else.
    if {$multipv ne "" && $multipv ne 1} { return }
    if {$score eq "" || $scoreType ni {cp mate}} { return }
    set pv [join [lrange $msgData 11 end] " "]
    set fen [::sergame::st $n fen ""]
    ::sergame::stSet $n depth $depth
    ::sergame::stSet $n score [::sergame::whiteScore $score $scoreType $fen]
    if {$pv ne ""} { ::sergame::stSet $n pv [::ucifmt::formatPv $pv $fen] }
    return
  }

  # The engine answered. The move (and the one it expects back) is kept on its
  # own connection, and only the answer to the question the game is waiting on
  # continues the game.
  proc onBestMove {n data} {
    lassign $data best ponder
    if {[::sergame::st $n search] eq ""} { return }
    if {[::sergame::st $n want] ne "move"} {
      # The coach's line, or a ponder search that finished on its own: it is
      # not this game's move, and the game asks again when it is its turn.
      ::sergame::stSet $n search ""
      ::sergame::stSet $n want ""
      return
    }
    ::sergame::stSet $n search ""
    ::sergame::stSet $n want ""
    ::sergame::stSet $n bestmove $best
    ::sergame::stSet $n ponder $ponder
    after 0 [list ::sergame::answer $n]
    return
  }

  # The engine's process died. There is no move to play and no line to show:
  # the game stops rather than waiting for an answer that is not coming.
  proc engineGone {n} {
    # The connection is already gone (::enginecomm unsets its state with it):
    # do not recreate it just to write into it.
    if {[::engine::connected [::sergame::connId $n]]} {
      ::sergame::stSet $n search ""
      ::sergame::stSet $n want ""
    }
    if {![winfo exists .coachWin]} { return }
    catch { tk_messageBox -type ok -icon warning -parent .main \
      -title "scidCommunity" -message [::tr EpdEngineDisconnected] }
    ::sergame::abortGame $n
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
      after 200 ::sergame::engineGo $n
      return
    }

    set takebackClockW ""
    set takebackClockB ""
    if {$::sergame::waitPlayerMove} {
      set ::sergame::waitPlayerMove 0
      set ::sergame::playerMoved 1

      # liveScore/livePv were already frozen in the premove callback
      # before the board changed — cannot be sign-corrupted.

      set takebackClockW [::gameclock::getSec 1]
      set takebackClockB [::gameclock::getSec 2]
      set ::sergame::takebackClockW $takebackClockW
      set ::sergame::takebackClockB $takebackClockB

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
        ::sergame::stSet $n prevscore 0.0
        clocks toggle $n
        updateBoard -pgn -animate
        if {[repetition]} { return }
        after 1000 ::sergame::engineGo $n
        return
      }
    }

    # Check if engine pondered on the right move
    if { $::sergame::ponder && [::sergame::st $n ponder] ne "" \
        && [::sergame::st $n search] ne "" \
        && [::sergame::st $n ponder] == [sc_game info previousMoveUCI] } {
      # The search it is already running is this move's: let it finish it.
      # `search` is empty when that ponder search has already answered itself,
      # and a ponderhit for a search nobody is running would wait for ever.
      ::sergame::ponderHit $n
    } else {
      if {![::sergame::ask $n [::sergame::goLimits $n]]} {
        # There is no engine to ask: it never started, or its connection went
        # away between moves. Stop the game rather than wait for a move that
        # cannot come (the old mode waited 5 s for "ready" and then said so).
        ::sergame::engineGone $n
        return
      }
    }
    # The move arrives at ::sergame::answer (through the connection's callback);
    # nothing here waits for it, so the window stays live while the engine
    # thinks, and a search that is replaced, cancelled or orphaned by a dead
    # engine leaves no waiter behind.
    return
  }

  ################################################################################
  # answer: the engine's move arrives, and the game continues
  #
  # This was the tail of engineGo, the half that ran after the blocking wait for
  # the engine's bestmove. The wait is gone; the work is the same and it runs
  # from the reply that delivered the move.
  ################################################################################
  proc answer { n } {
    set bestmove [::sergame::st $n bestmove]
    if { $bestmove eq "" } { return }
    if {![winfo exists .coachWin]} { return }
    # An answer is only this game's move while it is the engine's turn: a search
    # that finished after the game moved on (a ponder line the player did not
    # play, a search the game cancelled) must not put its move on the board.
    if { [sc_pos side] != $::sergame::engineColor } { return }

    # --- Player blunder detection (opponent engine score comparison) ---
    set wasTakeback 0
    set playerDidMove $::sergame::playerMoved
    set ::sergame::playerMoved 0
    # Both scores have to be there for a comparison to mean anything. The old
    # mode's shared array kept the previous search's score, so this could never
    # see nothing; a connection's state is cleared when its search starts, so an
    # engine that answers without a line at all (no info, or only a bound, or
    # only multiPV lines) would otherwise subtract "" and take the answer, and
    # the game, down with it.
    if { $::sergame::coachIsWatching && $playerDidMove
        && [::sergame::st $n prevscore] ne ""
        && [::sergame::st $n score] ne "" } {
      set blunder 0
      set delta [expr {[::sergame::st $n score 0.0] - [::sergame::st $n prevscore 0.0]}]
      if {$delta > $::informant(?!) && $::sergame::engineColor == "white" ||
        $delta < [expr 0.0 - $::informant(?!)] && $::sergame::engineColor == "black" } {
        set blunder 1
      }
      if {$delta > $::informant(?) && $::sergame::engineColor == "white" ||
        $delta < [expr 0.0 - $::informant(?)] && $::sergame::engineColor == "black" } {
        set blunder 2
      }
      if {$delta > $::informant(??) && $::sergame::engineColor == "white" ||
        $delta < [expr 0.0 - $::informant(??)] && $::sergame::engineColor == "black" } {
        set blunder 3
      }
      if {$blunder == 1} {
        set tBlunder "DubiousMovePlayedTakeBack"
      } elseif {$blunder == 2} {
        set tBlunder "WeakMovePlayedTakeBack"
      } elseif {$blunder == 3} {
        set tBlunder "BadMovePlayedTakeBack"
      }
      if {$blunder != 0} {
        clocks stop
        set bestMoveText ""
        if {[llength $::sergame::livePv] > 0} {
          set bestMoveText [lindex [split $::sergame::livePv] 0]
        }
        set choice [::sergame::blunderDialog $::tr($tBlunder) $bestMoveText]
        if {$choice == 1} {
          sc_move back 1
          ::gameclock::setSec 1 [expr 0 - $::sergame::takebackClockW]
          ::gameclock::setSec 2 [expr 0 - $::sergame::takebackClockB]
          clocks start
          ::notify::PosChanged -pgn
          ::sergame::startAnalyze
          set ::sergame::waitPlayerMove 1
          after 1000 ::sergame::engineGo $n
          return
        }
        clocks start
      }
    }

    # --- Engine blunder & eval from coach (port of tacgame's makePhalanxMove) ---
    if { $::sergame::coachIsWatching } {
      ::sergame::stopAnalyze
      if {$::sergame::liveScore != ""} {
        lappend ::sergame::lscore $::sergame::liveScore
      }

      # Resign check
      if { ( $::sergame::engineColor == "black" && [lindex $::sergame::lscore end] >  $::informant(+--) ) || \
           ( $::sergame::engineColor == "white" && [lindex $::sergame::lscore end] < [expr 0.0 - $::informant(+--)] ) } {
        incr ::sergame::resignCount
      } else {
        set ::sergame::resignCount 0
      }
    }

    ::sergame::stSet $n prevscore [::sergame::st $n score]

    # Store eval on the player's move BEFORE the engine's move is played
    if { $wasTakeback == 0 && $playerDidMove && ( $::sergame::storeEval == 1 || $::sergame::storeEvalAll == 1 ) } {
      if {$::sergame::coachIsWatching && $::sergame::liveScore ne ""} {
        storeEvalComment $::sergame::liveScore
      } elseif {[::sergame::st $n score] ne ""} {
        storeEvalComment [::sergame::st $n score]
      }
    }

    ::ucifmt::sc_move_add [list $bestmove]
    ::utils::sound::AnnounceNewMove $bestmove

    updateBoard -pgn -animate
    if {[repetition]} { return }

    clocks toggle $n

    if {$::sergame::coachIsWatching} {
      ::sergame::startAnalyze
    }

    # Store eval on the engine's move — deferred so the coach has time
    # to analyze the new position after startAnalyze.
    if { ( $::sergame::storeEval == 1 || $::sergame::storeEvalAll == 1 || $::sergame::showevaluation == 1 ) } {
      if {$::sergame::coachIsWatching} {
        after cancel ::sergame::_storeCoachEvalDeferred
        after 500 ::sergame::_storeCoachEvalDeferred
      } elseif {[::sergame::st $n score] ne ""} {
        storeEvalComment [::sergame::st $n score]
      }
    }

    if { $::sergame::resignCount > 3 } {
      if {$::sergame::activeColor == "white"} {
        sc_game tags set -result "1-0"
      } else {
        sc_game tags set -result "0-1"
      }
      catch {sc_game save [sc_game number] [sc_base current]}
      ::notify::GameChanged
      tk_messageBox -type ok -message "$::tr(Iresign) - $::tr(ResultSaved)" -parent .main -icon info
      set ::sergame::resignCount 0
    }

    # Ponder mode: start the next search from the move the engine expects back.
    if {$::sergame::ponder && [::sergame::st $n ponder ""] ne ""} {
      set limits [linsert [::sergame::goLimits $n] 0 ponder]
      ::sergame::ask $n $limits [::sergame::st $n ponder]
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
    after cancel ::sergame::stopAnalyze
    # The coach searches the position on the board and streams its line; the
    # answer is not the game's move (want "line"), so a line that arrives while
    # it is the player's turn updates the display and nothing else.
    ::sergame::ask 2 {infinite} "" line

    if { $isLimitedAnalysisTime == 1 }  {
      after [expr 1000 * $analysisTime] ::sergame::stopAnalyze
    }
  }

  proc stopAnalyze { } {
    after cancel ::sergame::stopAnalyze
    set id [::sergame::connId 2]
    if {[::engine::connected $id]} {
      catch { ::engine::send $id StopGo }
    }
  }

  ################################################################################
  # updateAnalysisText: live coach warning during the player's turn
  #   Port of tacgame's original blunder detection
  ################################################################################
  proc updateAnalysisText { } {
    global ::sergame::showblunder ::sergame::blunderWarningLabel \
        ::sergame::showblundervalue ::sergame::showevaluation ::sergame::lscore \
        ::sergame::threshold ::sergame::lastblundervalue ::sergame::scoreLabel \
        ::sergame::blunderpending ::sergame::coachNag

    if { ![winfo exists .coachWin] } { return }
    if { $::sergame::engineColor == "" } { return }

    # only update when it is human turn
    if { $::sergame::engineColor == [sc_pos side] } { return }

    set sc1 [::sergame::st 2 score ""]
    set sc2 [lindex $lscore end]

    # Not enough scores yet
    if { $sc1 eq "" || [llength $lscore] < 1 || $sc2 eq "" } {
      set blunderWarningLabel $::tr(Noinfo)
      set scoreLabel ""
      if { $showevaluation && $sc1 ne "" } {
        set scoreLabel "Score : $sc1"
      }
      return
    }

    # Check for engine blunder: has the score improved in the player's favor?
    if { $showblunder } {
      if { ($sc1 - $sc2 > $threshold && $::sergame::engineColor == "black") || \
            ($sc1 - $sc2 < [expr 0.0 - $threshold] && $::sergame::engineColor == "white") } {
        set lastblundervalue [expr {$sc1 - $sc2}]
        # NAG the engine's move if the game wasn't already dead
        if { [expr abs($sc2)] < $::informant(+--) } {
          if {$coachNag ne ""} {
            catch {sc_pos removeNag $::sergame::coachNag}
          }
          set b [expr abs($lastblundervalue)]
          if { $b >= $::informant(?!) && $b < $::informant(?) } {
            catch {sc_pos addNag "?!"}
            set coachNag "?!"
          } elseif { $b >= $::informant(?) && $b < $::informant(??) }  {
            catch {sc_pos addNag "?"}
            set coachNag "?"
          } elseif  { $b >= $::informant(??) } {
            catch {sc_pos addNag "??"}
            set coachNag "??"
          }
        }
        .coachWin.finformations.l1 configure -background LightCoral
        if { $showblundervalue } {
          set tmp $::tr(blunder)
          append tmp [format " %+8.2f" [expr abs($lastblundervalue)]]
          set blunderWarningLabel $tmp
          set blunderpending 1
        } else {
          set blunderWarningLabel "$::tr(blunder) !"
        }
      } else {
        if {$coachNag ne ""} {
          catch {sc_pos removeNag $::sergame::coachNag}
          set coachNag ""
        }
        .coachWin.finformations.l1 configure -background linen
        set blunderWarningLabel $::tr(Noblunder)
        set blunderpending 0
      }
    }

    # displays current score sent by the "good" engine (Toga)
    if { $showevaluation } {
      set scoreLabel "Score : $sc1"
    } else {
      set scoreLabel ""
    }
  }

  proc resetBlunderLabels {} {
    set ::sergame::blunderWarningLabel $::tr(Noinfo)
    set ::sergame::scoreLabel ""
    set ::sergame::lscore {}
    set ::sergame::liveScore ""
    set ::sergame::livePv ""
  }

  proc _storeCoachEvalDeferred {} {
    # The coach has been repositioned by startAnalyze and should have
    # produced at least one info line by now.  Store its eval on the
    # current position (the engine's last move).
    if {[::sergame::st 2 score ""] ne ""} {
      storeEvalComment [::sergame::st 2 score]
    }
  }

  ################################################################################
  # changePVSize: configure multipv for coach engine
  ################################################################################
  proc changePVSize {n} {
    set pv [::sergame::st $n multipv 1]
    ::sergame::sendOptions $n [list [list MultiPV $pv]]
    ::sergame::stSet $n multipv $pv
  }

  ################################################################################
  # logEngine: optional engine communication logging (a ::enginecomm log hook)
  ################################################################################
  proc logEngine {n prefix text} {
    if {[::sergame::st $n log_stdout 0]} {
      puts stdout "$n $prefix $text"
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
