### Multithreaded Computer Tournament 
###
### multicomp.tcl: part of Scid.
### Copyright (C) 2025- Uwe Klimmek

# Credit to Fulvio for a few lines of UCI code that enabled me
# to make this run nicely (without constantly reseting analysis),
# and gave me impetus for a decent control structure using
# semaphores/vwait instead of the often abused dig-deeper procedural flow 
# sometimes evident in tcl programs.
##################################

namespace eval comp {
    array set engine {} 
    set cSGLock 0
    set _Data(showscores) 1
    set _Data(showtimes) 2
    set _Data(base) 2
    set _Data(processes) 3
    set _Data(endaftergame) 0
    set _Data(current) 1
    set _Data(lastgame) 2
    set _Data(games) {}
    set _Data(showBoards) 1
    set _Data(count) 0 ; # number of computer players
    set _Data(start) 0 ; # "Start at position" radiobutton
    set _Data(delta) 4000; # 4 seconds is the time
    set _Data(tournament) "Scid Engine [tr Event]"
    set _Data(carousel) 1
    set _Data(site) "SCID"
    set _Data(seconds) 0.5
    set _Data(timecontrol) pergame ; # pergame or permove
    set _Data(minutes) 1
    set _Data(incr) 0.5
    set _Data(rounds) 2
    set _Data(firstonly) 0
    set _Data(usebook) 0
    set _Data(book) {}
    set _Data(bookName) ""
    set _Data(players) {}
    set _Data(playernames) {}
    set _Data(statustext) ""
    set _Data(replaybrokengame) 1
    set _Data(savebrokengame) 1
    set _Data(autosave) 0
    set _Data(engine) ""
    set _Data(runninggames) 0
    set _Data(paused) 0
    set _Data(bookTyp) ""
    set _Data(forceDraw) 0
    set _Data(forceDrawAfterMove) 25
    set _Data(forceDrawNumMoves) 10
    set _Data(forceDrawScore) 0.20
    set _Data(forceResign) 0
    set _Data(forceResignNumMoves) 10
    set _Data(forceResignScore) 1.5
    set _Data(repeatReverse) 0
}

# return index of actBook and a list of all books, return -1 if no books available
proc ::comp::getBookList { actBook } {
    set bookPath $::scidBooksDir
    set bookList [  lsort -dictionary [ glob -nocomplain -directory $bookPath *.opn *.epd *.bin] ]
    # No book found
    if { [llength $bookList] == 0 } {
        return [list -1 {}]
    }
    set tmp {}
    set idx 0
    set i 0
    foreach file $bookList {
        lappend tmp [ file tail $file ]
        if {$actBook == [ file tail $file ] } {
            set idx $i
        }
        incr i
    }
    return [list $idx $tmp]
}


# Convert FEN string to board representation
# (local copy since scidCommunity lacks pgnviewer.tcl)
proc ::comp::FENtoBoard { fen } {
    set b ""
    set end [string first " " $fen]
    incr end 1
    set m [string index $fen $end]
    set fen "/$fen"
    set line [string last "/" $fen]
    while { $line >= 0 } {
        set i [expr $line + 1]
        set c [string index $fen $i]
        while { $c ne "/" && $c ne " " } {
            if { [string is digit $c] } {
                for { set j 0 } { $j < $c } {incr j} { append b "." }
            } else { append b $c }
            incr i
            set c [string index $fen $i]
        }
        set fen [string replace $fen $line $line " "]
        set line [string last "/" $fen]
    }
    append b " $m"
    return $b
}

proc ::comp:loadBook { bookName } {
    global ::comp::_Data

    set _Data(bookTyp) [string range $bookName end-2 end]
    unset -nocomplain ::comp::openline
    set _Data(maxopen) 0
    if { $_Data(bookTyp) eq "bin" } return
    if { $::comp::_Data(usebook) } {
        set filename [ file join $::scidBooksDir $bookName ]
        set infile [open $filename r]
        set _Data(maxopen) 1
        while { [gets $infile line] > 0 } {
            set ::comp::openline($_Data(maxopen)) $line
            incr _Data(maxopen)
        }
        close $infile
        set ::comp::openline(0) $::comp::openline(1)
        set ::comp::openline($_Data(maxopen)) $::comp::openline(1)
    }
}

### Non-transient options are set in start.tcl
proc calcGames {} {
    global ::comp::_Data
    set _Data(count) [llength $_Data(playernames)]
    if { $_Data(firstonly)} {
        set _Data(lastgame) [expr {($_Data(count)-1) * $_Data(rounds)}]
    } else {
        set _Data(lastgame) [expr {$_Data(count) * ($_Data(count)-1) * $_Data(rounds) / 2}]
    }
    return $_Data(count)
}

proc ::comp::updateSelectedEngines { {sel ""} } {
    global ::comp::_Data
    set j 0
    .comp.engines.oldin.list delete [.comp.engines.oldin.list children {}]
    foreach y $_Data(playernames) {
        .comp.engines.oldin.list insert {} end -id $j -values [list $y]
        incr j
    }
    if { $sel ne "" } { .comp.engines.oldin.list selection set $sel }
}

proc ::comp::editEngines {} {
    global ::comp::_Data
    set sel [.comp.engines.oldin.list selection]
    if { [llength $sel] != 1 } return
    set sel [lindex $sel 0]
    set _Data(engine) [lindex $_Data(playernames) $sel]
    ::engineNoWin::changeEngine compEngine .comp.optscompEngine ::comp::_Data(engine) ::comp::eng_messages
}

proc ::comp::addEngines {} {
    global ::comp::_Data
    set sel [.comp.engines.oldout.list selection]
    lassign [::comp::getEngList] maxEng engList
    set engList [lsort $engList]
    foreach i $sel {
        set name [lindex $engList $i]
        lappend _Data(playernames) "$name"
        set ::comp::engine($_Data(count)) $name
    }
    ::comp::updateSelectedEngines
    calcGames
    set _Data(current) 1
}

proc ::comp::removeEngines {} {
    global ::comp::_Data
    set sel [.comp.engines.oldin.list selection]
    foreach i $sel {
        set _Data(playernames) [lreplace $_Data(playernames) $i $i]
    }
    ::comp::updateSelectedEngines
    calcGames
    set _Data(current) 1
}
proc ::comp::updownEngines { dir } {
    global ::comp::_Data
    set sel [.comp.engines.oldin.list selection]
    if { [llength $sel] != 1 } return
    set sel [lindex $sel 0]
    set name [lindex $_Data(playernames) $sel]
    set _Data(playernames) [lreplace $_Data(playernames) $sel $sel]
    incr sel $dir
    set _Data(playernames) [linsert $_Data(playernames) $sel $name]
    ::comp::updateSelectedEngines $sel
}

proc ::comp::configEngine { } {
    global ::comp::_Data
    set sel [.comp.engines.oldin.list selection]
    if { [llength $sel] != 1 } return
    set sel [lindex $sel 0]
    set _Data(engine) [lindex $_Data(playernames) $sel]
    .comp.compEngine.opts invoke
}

proc compInit { } {
  global ::comp::_Data engines

  set w .comp
  if {[winfo exists $w]} {
    raiseWin $w
    return
  }
  win::createDialog $w
  wm state $w withdrawn
  wm title $w "scidCommunity [tr Engine] [tr Tournament]"
  setWinLocation $w

  grid [ttk::labelframe $w.engines -text [tr ToolsConfigureEngines]] -row 0 -column 0 -rowspan 3 -sticky nswe -padx "0 10"
  grid [ttk::labelframe $w.tournament -text [tr Tournament]] -row 0 -column 1 -sticky nswe
  grid [ttk::labelframe $w.time -text [tr TimeMode]] -row 1 -column 1 -sticky nswe -pady 5
  grid [ttk::labelframe $w.config -text [tr GlistEditField]] -row 2 -column 1 -sticky nswe
  grid [ttk::frame $w.buttons] -row 4 -column 0 -columnspan 2 -sticky we -pady "5 0"
  grid [ttk::frame $w.games] -row 3 -column 0 -columnspan 2 -sticky nswe

  ### Engines
  lassign [::comp::getEngList] maxEng engList
  set l $w.engines
    foreach { i h e } [list out [tr Available] engList in [tr Selected] _Data(playernames)] {
      ttk::frame $l.old$i
      ttk::label $l.old$i.label -text $h -font font_Bold
      ttk::treeview $l.old$i.list -columns {0} -show {} -selectmode extended \
          -yscrollcommand "$l.old$i.ybar set"
      $l.old$i.list column 0 -width 140
      $l.old$i.list configure -height 20
      ttk::scrollbar $l.old$i.ybar -command "$l.old$i.list yview"
      pack $l.old$i.label -side top -anchor w
      pack $l.old$i.ybar -side right -fill y
      pack $l.old$i.list -side left -fill both -expand 1
      set j 0
      set il {}
      set e [set $e]
      foreach y [lsort $e] {
          $l.old$i.list insert {} end -id $j -values [list "$y"]
          incr j
      }
  }
  ::comp::updateSelectedEngines

  bind $l.oldin.list <<TreeviewSelect>> { ::comp::editEngines }
  grid $l.oldout -row 0 -column 0
  grid $l.oldin -row 0 -column 2
  grid [ttk::frame $l.btlr] -row 0 -column 1
  grid [ttk::frame $l.btud] -row 0 -column 1 -sticky s
  ttk::button $l.btlr.l -image tb_prev -command { ::comp::removeEngines }
  ttk::button $l.btlr.r -image tb_next -command { ::comp::addEngines }
  ttk::button $l.btud.u -image tb_up -command { ::comp::updownEngines -1 }
  ttk::button $l.btud.d -image tb_down -command { ::comp::updownEngines 1}
  ttk::button $l.config -image ::icon::filter_adv -command { ::comp::configEngine }
  grid $l.config -row 0 -column 1 -sticky n -pady 20
  ::engineNoWin::createEngineOptionsFrame $w compEngine ::comp::_Data(engine) 7 ::comp::eng_messages
  pack forget $w.compEngine.eng

  pack $l.btlr.r $l.btlr.l -side top -padx 5
  pack $l.btud.u $l.btud.d -side top

  set _Data(endaftergame) 0
  set _Data(countcombos) $_Data(count)

  ### Config widgets
  set row 0

  ttk::label $w.tournament.eventlabel -text $::tr(Event:)
  ttk::entry $w.tournament.evententry -width 26 -textvariable ::comp::_Data(tournament)

  grid $w.tournament.eventlabel -row $row -column 0 -sticky w -pady 2
  grid $w.tournament.evententry -row $row -column 1 -sticky we -pady 2 -columnspan 3

  incr row
  ttk::label $w.tournament.sitelabel -text $::tr(Site:)
  ttk::entry $w.tournament.siteentry -width 26 -textvariable ::comp::_Data(site)
  grid $w.tournament.sitelabel -row $row -column 0 -sticky w -pady 2
  grid $w.tournament.siteentry -row $row -column 1 -sticky we -pady 2 -columnspan 3

  incr row
  ttk::frame $w.tournament.firstonlyvalue
  ttk::label $w.tournament.firstonlyvalue.0 -text [tr FinderSortType]
  ttk::radiobutton $w.tournament.firstonlyvalue.1 -text [tr RoundRobin] -variable ::comp::_Data(firstonly) -value 0 -command "calcGames"
  ttk::radiobutton $w.tournament.firstonlyvalue.2 -text [tr Gauntlet] -variable ::comp::_Data(firstonly) -value 1 -command "calcGames"
  pack $w.tournament.firstonlyvalue.0 $w.tournament.firstonlyvalue.1 $w.tournament.firstonlyvalue.2 -side left -padx "0 5" 
  grid $w.tournament.firstonlyvalue -row $row -column 0 -pady 2 -sticky w -columnspan 4

  incr row
  ttk::label $w.tournament.roundslabel -text [tr Rounds]
  ttk::label $w.tournament.aktlabel -text [tr CompGameNext]
  ttk::label $w.tournament.roundsakt -textvar ::comp::_Data(current)
  ttk::spinbox $w.tournament.roundsvalue -textvariable ::comp::_Data(rounds) -from 1 -to 10 -width 3 -command "calcGames"

  grid $w.tournament.roundslabel -row $row -column 0 -sticky w -pady 2
  grid $w.tournament.roundsvalue -row $row -column 1 -pady 2 -sticky w
  grid $w.tournament.aktlabel -row $row -column 2 -sticky w -pady 2
  grid $w.tournament.roundsakt -row $row -column 3 -sticky w -pady 2

  incr row
  ttk::frame $w.time.control
  ttk::radiobutton $w.time.control.1 -variable ::comp::_Data(timecontrol) -value pergame -text [tr Game] -command checkTimeControl
  ttk::radiobutton $w.time.control.2 -variable ::comp::_Data(timecontrol) -value permove -text [tr move] -command checkTimeControl

  pack $w.time.control.1 $w.time.control.2 -side left -padx "0 5"
  grid $w.time.control  -row $row -column 0 -columnspan 3 -sticky w -pady 2

  incr row
  ttk::frame $w.time.timegame 
  ttk::label $w.time.timegame.label -text [tr TimeperGame]
  ttk::spinbox $w.time.timegame.base -textvariable ::comp::_Data(base) -from 0 -to 7200 -incr 5 -width 4

  ttk::label $w.time.timegame.label2 -text [tr TimeSec]
  ttk::spinbox $w.time.timegame.incr -textvariable ::comp::_Data(incr) -from 0 -to 60 -width 4 -incr 0.1
    ttk::label $w.time.timegame.label3 -text [tr FICSIncrement]

  pack $w.time.timegame.label -side left -padx "0 5"
  pack $w.time.timegame.base -side left
  pack $w.time.timegame.label2 -side left -padx "0 5"
  pack $w.time.timegame.label3 $w.time.timegame.incr -side right
  grid $w.time.timegame -row $row -column 0 -columnspan 2 -sticky ew -pady 2

  incr row
  ttk::frame $w.time.timesecs 
  ttk::label $w.time.timesecs.label -text [tr TimeperMove]
  set tmp $_Data(seconds)
  ttk::spinbox $w.time.timesecs.value -textvariable ::comp::_Data(seconds) -from 1 -to 3600 -width 4
  set _Data(seconds) $tmp
  ttk::label $w.time.timesecs.label2 -text [tr sec]

  pack $w.time.timesecs.label -side left -padx "0 5"
  pack $w.time.timesecs.value $w.time.timesecs.label2 -side left
  grid $w.time.timesecs -row $row -column 0 -columnspan 2 -sticky we -pady 2

  incr row
  ttk::frame $w.time.show
  ttk::label $w.time.show.l -text [tr compStoreTime]
  ttk::radiobutton $w.time.show.time0 -text [tr None] -variable ::comp::_Data(showtimes) -value 0
  ttk::radiobutton $w.time.show.time1 -text [tr Clock] -variable ::comp::_Data(showtimes) -value 1
  ttk::radiobutton $w.time.show.time2 -text [tr move] -variable ::comp::_Data(showtimes) -value 2
  pack $w.time.show.l -side left
  pack $w.time.show.time0 $w.time.show.time1 $w.time.show.time2 -side left -padx "5 0"
  grid $w.time.show -row $row -column 0 -sticky w -columnspan 3
    
  incr row
  ttk::frame $w.config.multi
  ttk::label $w.config.multi.label -text [tr compConcurrent]
  ttk::spinbox $w.config.multi.value -textvariable ::comp::_Data(processes) -from 1 -to 8 -width 2
  pack $w.config.multi.label $w.config.multi.value -side left
  grid $w.config.multi -row $row -column 0 -sticky w
  ttk::checkbutton $w.config.grafic -text [tr compShowBoards] -variable ::comp::_Data(showBoards)
  grid $w.config.grafic -row $row -column 1 -sticky w -padx 5
    
  incr row
  checkTimeControl

  ttk::checkbutton $w.config.carousel -text [tr compCarousel] -variable ::comp::_Data(carousel)
  grid $w.config.carousel -row $row -column 0 -padx 5 -sticky w

  ttk::checkbutton $w.config.scorevalue -text [tr compSaveEval] -variable ::comp::_Data(showscores)
  grid $w.config.scorevalue -row $row -column 1 -columnspan 2 -padx 5 -sticky w

  incr row
  ttk::label $w.config.0 -text [tr compCanceledGames]
  grid $w.config.0 -row $row -column 0 -columnspan 2 -sticky w -pady "2 0"
  incr row
  ttk::checkbutton $w.config.replaybroken -text [tr Replay] -variable ::comp::_Data(replaybrokengame)
  grid $w.config.replaybroken -row $row -column 0 -padx 13 -sticky w
  ttk::checkbutton $w.config.savebroken -text [tr Save] -variable ::comp::_Data(savebrokengame)
  grid $w.config.savebroken -row $row -column 1 -padx 8 -sticky w

  incr row
  ttk::checkbutton $w.config.autosave -text [tr compSave] -variable ::comp::_Data(autosave)
  grid $w.config.autosave -row $row -column 0 -columnspan 2 -sticky w

  incr row
  ttk::labelframe $w.config.forceDraw -text [tr compForceDraw]
  ttk::checkbutton $w.config.forceDraw.cb -variable ::comp::_Data(forceDraw)
  ttk::label $w.config.forceDraw.afterLabel -text [tr compAfterMove]
  ttk::spinbox $w.config.forceDraw.after -textvariable ::comp::_Data(forceDrawAfterMove) -from 0 -to 999 -width 4
  ttk::label $w.config.forceDraw.numLabel -text [tr compNumMoves]
  ttk::spinbox $w.config.forceDraw.num -textvariable ::comp::_Data(forceDrawNumMoves) -from 1 -to 999 -width 4
  ttk::label $w.config.forceDraw.scoreLabel -text [tr compScoreLess]
  ttk::spinbox $w.config.forceDraw.score -textvariable ::comp::_Data(forceDrawScore) -from 0 -to 100 -width 5 -increment 0.01
  pack $w.config.forceDraw.cb $w.config.forceDraw.afterLabel $w.config.forceDraw.after \
      $w.config.forceDraw.numLabel $w.config.forceDraw.num \
      $w.config.forceDraw.scoreLabel $w.config.forceDraw.score -side left -padx 2
  grid $w.config.forceDraw -row $row -column 0 -columnspan 2 -sticky ew -pady 2

  incr row
  ttk::labelframe $w.config.forceResign -text [tr compForceResign]
  ttk::checkbutton $w.config.forceResign.cb -variable ::comp::_Data(forceResign)
  ttk::label $w.config.forceResign.numLabel -text [tr compNumMoves]
  ttk::spinbox $w.config.forceResign.num -textvariable ::comp::_Data(forceResignNumMoves) -from 1 -to 999 -width 4
  ttk::label $w.config.forceResign.scoreLabel -text [tr compScoreGreater]
  ttk::spinbox $w.config.forceResign.score -textvariable ::comp::_Data(forceResignScore) -from 0 -to 100 -width 5 -increment 0.1
  pack $w.config.forceResign.cb $w.config.forceResign.numLabel $w.config.forceResign.num \
      $w.config.forceResign.scoreLabel $w.config.forceResign.score -side left -padx 2
  grid $w.config.forceResign -row $row -column 0 -columnspan 2 -sticky ew -pady 2
  ### Opening Book

  incr row
  ttk::frame $w.config.book
  ttk::checkbutton $w.config.book.value -variable ::comp::_Data(usebook) -text [tr UseBook]
  # load book names
  lassign [::comp::getBookList $_Data(bookName)] idx tmp
  if { $idx < 0 } {
    $w.config.book.value configure -state disabled
    set _Data(usebook) 0
  }
  if { $_Data(bookName) eq "" } { set _Data(bookName) [lindex $tmp $idx] }
  ttk::combobox $w.config.book.combo -values $tmp -textvariable ::comp::_Data(bookName)
  catch { $w.config.book.combo current $idx }

  grid $w.config.book -row $row -column 0 -columnspan 2 -sticky w
  pack $w.config.book.combo $w.config.book.value -side right -padx "0 5"

  incr row
  ttk::checkbutton $w.config.repeatReverse -text [tr compRepeatReverse] -variable ::comp::_Data(repeatReverse)
  grid $w.config.repeatReverse -row $row -column 0 -padx 13 -sticky w

  incr row
  ttk::label $w.games.aktstart -text "[tr games] "
  ttk::label $w.games.aktend -text " - "
  ttk::spinbox $w.games.roundakt -textvariable ::comp::_Data(current) -from 1 -to 999 -width 3
  ttk::spinbox $w.games.roundend -textvariable ::comp::_Data(lastgame) -from 1 -to 999 -width 4
  pack $w.games.aktstart $w.games.roundakt $w.games.aktend $w.games.roundend -side left -pady "4 0"
    
  ### OK, Cancel Buttons

  ttk::button $w.buttons.cancel -text $::tr(Cancel) -command compClose
  ttk::button $w.buttons.ok -text [tr compStart] -command "startComp; compOk"
  ttk::button $w.buttons.save -text [tr Save] -command "startComp; compSave"
  ttk::button $w.buttons.load -text [tr GsortLoad] -command "loadComp"

  focus $w.buttons.ok
  packbuttons right $w.buttons.cancel $w.buttons.ok $w.buttons.save $w.buttons.load -anchor e

  bind $w <Configure> "recordWinSize $w"
  wm protocol $w WM_DELETE_WINDOW compClose
  wm resizable $w 1 1
  bind $w <Escape> compClose
  bind $w <F1> {helpWindow Tourney}
  update
  wm state $w normal
}

proc checkTimeControl {} {
  global ::comp::_Data
  set w .comp
  if {$_Data(timecontrol) == "permove" } {
    foreach i [winfo children $w.time.timesecs] {
      $i configure -state normal
    }
    foreach i [winfo children $w.time.timegame] {
      $i configure -state disabled
    }
  } else {
    foreach i [winfo children $w.time.timesecs] {
      $i configure -state disabled
    }
    foreach i [winfo children $w.time.timegame] {
      $i configure -state normal
    }
  }
  update
}
proc loadComp {} {
    global ::comp::_Data engines scidConfigDir
    set filename ""
    set types { {{Scid Tournament Files} {.sto}} }
    set filename [tk_getOpenFile -initialdir $scidConfigDir -initialfile $_Data(tournament) -filetypes  $types -defaultextension ".sto"]
    if {$filename != ""} { source $filename }

    lassign [::comp::getEngList] maxEng engList
    foreach e $_Data(playernames) {
        set found [lsearch -exact $engList $e]
        if { $found < 0 } {
            tk_messageBox -type ok -title {scidCommunity: Fehler} -message "Engine $e not found."
            return
        }
    }
    .comp.config.book.combo set $_Data(book)
    ::comp::updateSelectedEngines
    compInit
    createGames $_Data(carousel)
    if {[winfo exists .comp.engines.list]} { destroy .comp.engines.list }
}

proc createGames { carousel } {
    global ::comp::_Data
    ### Place games in cue
    set _Data(games) {}
    set gamesPerRound [expr int($_Data(count)/2)]
    set even [expr ($_Data(count)+1) % 2]
    set rounds [expr $_Data(count) -1 ]
    set last [expr $_Data(count) -1 ]
    set plist {}
    set hlist {}
    if { !$even } {
        set last [expr $_Data(count) -2 ]
        set rounds $_Data(count)
    }
    if { $carousel && ! $_Data(firstonly) } {
        for {set k 1} {$k <= $_Data(rounds)} {incr k} {
            for {set i 0} {$i < $_Data(count)} {incr i} {
                lappend plist $i
            }
            ## Carousel or Rutschsystem
            for {set l 1} {$l <= $rounds} {incr l} {
                for {set i 0; set j $last } {$i < $gamesPerRound} {incr i; incr j -1 } {
                    if { $even && [expr ($l-1) % 2] } {
                        lappend _Data(games) [list [lindex $_Data(playernames) [lindex $plist $j]] [lindex $_Data(playernames) [lindex $plist $i]] "$k.$l"]
                        lappend hlist [list [lindex $_Data(playernames) [lindex $plist $i]] [lindex $_Data(playernames) [lindex $plist $j]] "[expr $k+1].$l"]
                    } else {
                        lappend _Data(games) [list [lindex $_Data(playernames) [lindex $plist $i]] [lindex $_Data(playernames) [lindex $plist $j]] "$k.$l"]
                        lappend hlist [list [lindex $_Data(playernames) [lindex $plist $j]] [lindex $_Data(playernames) [lindex $plist $i]] "[expr $k+1].$l"]
                    }
                }
                set help [lindex $plist end];
                set xlist [linsert $plist $even $help]
                set plist [lreplace $xlist end end]
            }
            incr k
            if { $k <= $_Data(rounds) } {
                append _Data(games) " $hlist"
                set hlist {}
            }
        }
    } else {
        for {set k 1} {$k <= $_Data(rounds)} {incr k} {
            for {set i 0} {$i < $_Data(count)} {incr i} {
                for {set j [expr $i + 1]} { $j < $_Data(count) } {incr j} {
                    lappend _Data(games) [list [lindex $_Data(playernames) $i] [lindex $_Data(playernames) $j] $k]
                    lappend hlist [list [lindex $_Data(playernames) $j] [lindex $_Data(playernames) $i] [expr $k+1]]
                }
                if {$_Data(firstonly)} {break}
            }
            incr k
            if { $k <= $_Data(rounds) } {
                append _Data(games) " $hlist"
                set hlist {}
            }
        }
    }
    if { $_Data(repeatReverse) } {
        set newGames {}
        foreach g $_Data(games) {
            lassign $g w b r
            lappend newGames $g
            lappend newGames [list $b $w "$r"]
        }
        set _Data(games) $newGames
        set _Data(lastgame) [llength $_Data(games)]
    }
}

proc startComp { } {
  global ::comp::_Data engines
    if { ! [calcGames] } { return }
    # make sure decimals have a leading 0
    catch {
        set _Data(incr) [expr $_Data(incr)]
        set _Data(base) [expr $_Data(base)]
        set _Data(seconds) [expr $_Data(seconds)]
    }
    
    set _Data(players) {} ;# to remember which engines are selected between widget restarts
    set _Data(book) [.comp.config.book.combo get]
    
    if {$_Data(timecontrol) == "permove"} {
        set _Data(time) [expr {int($_Data(seconds) * 1000)}]
        catch { puts "Move delay is $_Data(time) milliseconds" }
    } 

    if {$_Data(firstonly)} {
        set _Data(firstN) [lindex $_Data(playernames) 0]
    }
    createGames $_Data(carousel)
}

proc  toggleEndAfterGame {} {
    global ::comp::_Data
    if { $_Data(endaftergame) } {
        set _Data(endaftergame) 0
        .comp.buttons.save state !pressed
    } else {
        set _Data(endaftergame) 1
        .comp.buttons.save state pressed
    }
}

proc ::comp::resizeBoards {x} {
  global ::comp::_Data
    set i $_Data(processes)
    while { $i > 0 } {
        ::board::resize .comp.bds.g$i $x
        incr i -1
    }
}

proc compOk {} {
  global ::comp::_Data

  set num_games [llength $_Data(games)]
catch { puts "$num_games GAMES total: $_Data(games)" }
  if { $num_games == 0 } return 
  ## wait short for cleanup the engine analysis windows
  set w .comp

  set _Data(database) $::curr_db
  if {[sc_base isReadOnly $_Data(database)]} {
    set answer [tk_messageBox -title Tournament -icon question -type okcancel \
	-message {Database is read only. Continue ?} -parent $w]
    if {$answer != "ok"} {return}
  }
  if {![sc_pos isAt end] && $_Data(start) > 0} {
    set answer [tk_messageBox -title Tournament -icon question -type okcancel \
	-message {Die aktuelle Partie ist nicht am Ende der Partie. Fortfahren?} -parent $w]
    if {$answer != "ok"} {return}
  }

  ### Reconfigure init widget for pausing
  grid forget $w.config $w.time $w.engines $w.tournament

  $w.buttons.ok configure -text "   Pause    " -command compPause -state normal
  $w.buttons.save configure -text [tr compStop] -command "toggleEndAfterGame" -state normal
  pack forget $w.buttons.load
  $w.buttons.cancel configure -text [tr Cancel] -command { compAbort } -state normal
  wm title $w "scidCommunity [tr Engine] [tr Tournament]"
  focus $w.buttons.ok

  ttk::progressbar $w.progress -mode determinate -maximum $num_games -variable ::comp::_Data(current)
  grid $w.progress -column 0 -row 6 -columnspan 12 -sticky we
  ttk::label $w.status -textvariable ::comp::_Data(statustext)
  grid $w.status -column 0 -row 7 -columnspan 2 -sticky we

    if { $_Data(showBoards) } {
        set nextrow 5
        if { $_Data(processes) in { 5 6 } } { incr nextrow -1 }
        ttk::button $w.games.plus -text " + " -command "::comp::resizeBoards +1; update" -state normal
        ttk::button $w.games.minus -text " - " -command "::comp::resizeBoards -1; update" -state normal
        pack $w.games.plus $w.games.minus -side right -pady "4 0"

        ttk::frame $w.bds
        set b $w.bds
        set row 0
        for {set i 1; set j 0} {$i <= $_Data(processes) } {incr i; incr j} {
            set _Data(name,$i)(nameW) ""
            set _Data(name,$i)(nameB) ""
            set _Data(name,$i)(clockW) ""
            set _Data(name,$i)(clockB) ""
            ::board::new $b.g$i 40
            ::board::addNamesBar $b.g$i ::comp::_Data(name,$i)
            ::board::toggleEvalBar $b.g$i
            ::board::toggleMaterial $b.g$i
            if { $i == $nextrow } { set row 2; set j 0}
            grid $b.g$i -column $j -row $row -padx 5
            ttk::frame $b.b$i
            ttk::button $b.b$i.w -text "1-0" -command "::comp::adjucateGame $i 1"
            ttk::button $b.b$i.r -text " = " -command "::comp::adjucateGame $i ="
            ttk::button $b.b$i.l -text "0-1" -command "::comp::adjucateGame $i 0"
            pack $b.b$i.w $b.b$i.r $b.b$i.l -side left -padx 5
            grid $b.b$i -column $j -row [expr $row +1] -padx 5 -pady {2 5}
        }
        grid $w.bds -column 0 -row 0
    }
  ### Play games
  set game 0
  set _Data(statustext) ""
  set _Data(runninggames) 0
  set _Data(paused) 0
  ::comp:loadBook $_Data(bookName)
  if { $_Data(repeatReverse) } { array unset _Data {bookCache,*} }
  append _Data(statustext) [tr compRunning]
  while {$_Data(runninggames) < $_Data(processes) && $_Data(current) <= $_Data(lastgame)} {
    set thisgame [lindex $_Data(games) [expr $_Data(current) - 1]]
    set name1 [lindex $thisgame 0]
    set name2 [lindex $thisgame 1]
    set k     [lindex $thisgame 2]
    if {$name1 != {} && $name2 != {}} {
      incr game
catch { puts "Start $_Data(current): $name1 - $name2" }
      after [expr {$game * 500}] [list compNM $game $name1 $name2 $k]
      incr _Data(runninggames)
      set _Data(this,$game) $thisgame
      set _Data(currentIdx,$game) $_Data(current)
    }
    incr _Data(current)
  }
}

proc ::comp::compOkEnd {game} {
    global ::comp::_Data

    incr _Data(runninggames) -1
    set _Data(statustext) "[tr Result] [set _Data(name,$game)(nameW)] - [set _Data(name,$game)(nameB)]: $_Data(result,$game)\n"
    ::engineNoWin::closeEngine compEnginewhite$game
    ::engineNoWin::closeEngine compEngineblack$game
    if { ! $_Data(endaftergame) && $_Data(current) <= $_Data(lastgame) } {
        if { $_Data(result,$game) != "*" || !$_Data(replaybrokengame) } {
            set thisgame [lindex $_Data(games) [expr $_Data(current) - 1]]
            set _Data(currentIdx,$game) $_Data(current)
            incr _Data(current)
        } else {
catch { puts "replay $_Data(this,$game)" }
            set thisgame $_Data(this,$game)
        }
        if { $_Data(autosave) } { autocompSave }
        set name1 [lindex $thisgame 0]
        set name2 [lindex $thisgame 1]
        set k     [lindex $thisgame 2]
        if {$name1 != {} && $name2 != {}} {
            after 500 [list compNM $game $name1 $name2 $k]
catch { puts "Start $_Data(current): Slot $game $name1 - $name2" }
            incr _Data(runninggames)
            set _Data(this,$game) $thisgame
        }
    }
    if { $_Data(runninggames) > 0 } return
    
    if { $_Data(endaftergame) } { toggleEndAfterGame }

  ### Comp over
  if { $_Data(current) > $_Data(lastgame)} {
      append _Data(statustext) [tr compFinished]
      set _Data(current) $_Data(lastgame)
      pack forget .comp.buttons.save
  } else {
      append _Data(statustext) [tr compStopped]
      .comp.buttons.save configure -text [tr Continue] -state normal -command {
          compDestroy
          update
          compInit
          startComp
          compOk
      }
  }
  if {[winfo exists .comp]} {
    # voodoo that you do
    wm geometry .comp [wm geometry .comp]

    # Hmm - if we leave this window open , and run F2 (say) the engines can sometimes stop working 
    # So better make sure this window gets closed
    .comp.buttons.ok configure -text [tr Restart] -command {
       compDestroy
       update
       compInit
       set _Data(current) 1
    }
    .comp.buttons.cancel configure -text [tr Close] -command {
       if { $::comp::_Data(current) >= $::comp::_Data(lastgame) } { set ::comp::_Data(current) 1 }
       compDestroy
    }
    raiseWin .comp
  }
}

proc ::comp::makeBookLine {game} {
    global ::comp::_Data
    foreach i $_Data(moves,$game) {
        lappend _Data(comments,$game) "Book"
        lassign [::comp::compUpdateboard $_Data(board,$game) $i] res _Data(board,$game)
    }
}

#read bookline from *.bin opening book
proc ::comp::readBookLine {game} {
    global ::comp::_Data ::comp::cSGLock

    set inbook 1
    while { $cSGLock } {
        catch { puts "wait for make bookline" }
        vwait ::comp::cSGLock
    }
    set cSGLock 1
    sc_game push
    sc_game new
    while { $inbook} {
        set bestmove [::book::getMove $_Data(bookName) [sc_pos fen] 2]
        if {$bestmove ne ""} {
            if { [catch { sc_move addSan $bestmove }] } {
                set inbook 0
            } else {
                sc_move forward
            }
        } else {
            set inbook 0
        }
    }
    set moves [sc_game UCI_currentPos]
    set start [string first "moves " $moves]
    incr start 6
    set moves [string range $moves $start end]
    sc_game pop
    set cSGLock 0
    return $moves
}

proc compNM {game n m k} {
    global ::comp::_Data
    
    if {$_Data(timecontrol) == "pergame"} {
        set _Data(white,$game) [expr int($_Data(base)*1000)]
        set _Data(black,$game) [expr int($_Data(base)*1000)]
    }
    ## add 50ms to avoid lose on time
    set _Data(incr50) [expr int($_Data(incr) * 1000) + 50]

    update
    set repetition {}
    set material 0
    set pawns ""
    set _Data(score,$game) 0.0
    set _Data(fen,$game) startpos
    set _Data(moves,$game) {}
    set _Data(comments,$game) {}
    set _Data(scoreHistory,$game) {}
    set _Data(board,$game) "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr"
    if { $_Data(usebook) } {
        if { $_Data(repeatReverse) } {
            set pairId [expr {($_Data(currentIdx,$game) + 1) / 2}]
            if { [info exists _Data(bookCache,$pairId)] } {
                set cached $_Data(bookCache,$pairId)
                set _Data(moves,$game) [lindex $cached 0]
                set _Data(fen,$game) [lindex $cached 1]
                set _Data(board,$game) [lindex $cached 2]
                set _Data(comments,$game) {}
                foreach mv $_Data(moves,$game) { lappend _Data(comments,$game) "Book" }
            } else {
                switch $_Data(bookTyp) {
                    "opn" {
                        set _Data(moves,$game) $::comp::openline([expr {int( rand()*$_Data(maxopen) )}])
                        ::comp::makeBookLine $game
                    }
                    "epd" {
                        set _Data(fen,$game) $::comp::openline([expr {int( rand()*$_Data(maxopen) )}])
                        set _Data(board,$game) [::comp::FENtoBoard $_Data(fen,$game)]
                    }
                    "bin" {
                        set _Data(moves,$game) [::comp::readBookLine $game]
                        ::comp::makeBookLine $game
                    }
                }
                if {![info exists _Data(bookCache,$pairId)]} {
                    set _Data(bookCache,$pairId) [list $_Data(moves,$game) $_Data(fen,$game) $_Data(board,$game)]
                }
            }
        } else {
            switch $_Data(bookTyp) {
                "opn" {
                    set _Data(moves,$game) $::comp::openline([expr {int( rand()*$_Data(maxopen) )}])
                    ::comp::makeBookLine $game
                }
                "epd" {
                    set _Data(fen,$game) $::comp::openline([expr {int( rand()*$_Data(maxopen) )}])
                    set _Data(board,$game) [::comp::FENtoBoard $_Data(fen,$game)]
                }
                "bin" {
                    set _Data(moves,$game) [::comp::readBookLine $game]
                    ::comp::makeBookLine $game
                }
            }
        }
    }
    set tomove [expr { ([llength $_Data(moves,$game)] % 2) == 0 ? "white" : "black" } ]
    set _Data(result,$game) "*"
    set _Data(repetition,$game) {}
    set _Data(moves50,$game) 0
    set _Data(material,$game) {}
    set _Data(pawns,$game) {}
    set _Data(name,$game)(nameW) $n
    set _Data(name,$game)(nameB) $m
    set _Data(round,$game) $k
    set _Data(mate,$game) 0
    if { ! [::engineNoWin::initEngine compEnginewhite$game $n \
                [list ::comp::eng_messages compEnginewhite$game nop]] ||
         ! [::engineNoWin::initEngine compEngineblack$game $m \
                [list ::comp::eng_messages compEngineblack$game nop]] } {
        ::engineNoWin::closeEngine compEnginewhite$game
        ::engineNoWin::closeEngine compEngineblack$game
        return
    }
    set _Data(playing,$game) 1
    after 500 "::comp::compNextMove $game $tomove 0 \"\""
}

proc ::comp::compUpdateboard {board move} {
    set from [::board::sq [string range $move 0 1]]
    set to [::board::sq [string range $move 2 3]]
    set p [string index $board $from]
#todo sollte nicht vorkommen
    if { ! ($p in {K Q R B N P k q r b n p} ) || $from == $to } {
        catch { puts "wrong piece or wrong move: Piece:\($p\) Move $move $from $to $board" }
        return [list 0 $board]
    }
    if {$p eq "P" && $to > 55 } {
        set p [string toupper [string index $move 4]]
        if { $p eq "" } { set p "Q" }
    } elseif {$p eq "p" && $to < 8  } {
        set p [string index $move 4]
        if { $p eq "" } { set p "q" }
    }
#Rochaden
    if {[string index $board $from] == "K" } {
        if { $from == 4 && $to == 6 } {
            set board [string replace $board 7 7 "."]
            set board [string replace $board 5 5 "R"]
        } elseif { $from == 4 && $to == 2 } {
            set board [string replace $board 0 0 "."]
            set board [string replace $board 3 3 "R"]
        }
    } elseif {[string index $board $from] == "k" } {
        if { $from == 60 && $to == 62 } {
            set board [string replace $board 63 63 "."]
            set board [string replace $board 61 61 "r"]
        } elseif { $from == 60 && $to == 58 } {
            set board [string replace $board 56 56 "."]
            set board [string replace $board 59 59 "r"]
        }
    }
#Todo enpassant
    set board [string replace $board $to $to $p]
    set board [string replace $board $from $from "."]
    return [list 1 $board]
}

proc ::comp::compCheckMove { game tomove expired bestmove } {
    global ::comp::_Data

    set comment ""
    set result 0
#potentiel prolemeatisch Halogen blockiert alles, u.u. auch den Desktop! kovisto oder Smarthink blockieren
    if { $bestmove eq "Time out"} {
        set _Data(result,$game) [expr {$tomove eq "white" ? 0 : 1}]
        lappend _Data(comments,$game) "Time out: $tomove move $bestmove ismate $_Data(mate,$game) score $_Data(score,$game)"
    } elseif { ! [regexp {[a-h][1-8][a-h][1-8]} $bestmove] } {
        set _Data(result,$game) [ expr { $_Data(score,$game) > 0 ? 1 : 0}]
        if { [expr { abs($_Data(score,$game))} ] < 1 } { set _Data(result,$game) = }
        lappend _Data(comments,$game) "Game ends: $tomove Move $bestmove ismate $_Data(mate,$game) Score $_Data(score,$game)"
    } elseif { $_Data(mate,$game) } {
        # Mate score means the side to move has a forced win.
        set _Data(result,$game) [expr {$tomove eq "white" ? 1 : 0}]
        set mateMoves $_Data(matemoves,$game)
        foreach mv $mateMoves {
            lappend _Data(moves,$game) $mv
            lappend _Data(comments,$game) ""
        }
        if {[llength $mateMoves] > 0} {
            set _Data(comments,$game) [lreplace $_Data(comments,$game) end end "Mate detected: $tomove PV: $mateMoves"]
        } else {
            lappend _Data(comments,$game) "Mate detected: $tomove"
        }
    } else {
        lassign [::comp::compUpdateboard $_Data(board,$game) $bestmove] moveOk _Data(board,$game)
        if { $moveOk } {
            set result 1
            set sideToMove [expr {$tomove eq "white" ? "b" : "w"}]
            lassign [::comp::checkRepetition $_Data(repetition,$game) "$_Data(board,$game) $sideToMove"] isRepetition _Data(repetition,$game)
            lassign [::comp::checkfiftyMoveRule $_Data(moves50,$game) $_Data(material,$game) $_Data(pawns,$game) $_Data(board,$game)] \
                isFifty _Data(moves50,$game) _Data(material,$game) _Data(pawns,$game)
            if {$_Data(showscores) && $_Data(scoreIsNew,$game) } {
                append comment "\[%eval $_Data(score,$game)\]"
            }
            if { $isRepetition || $isFifty } {
                if { $isFifty } {
                    set text [expr { $isFifty > 1 ? "50-moves rule" : "Material"}]
                } else {
                    set text "3-fold repetion"
                }
                append comment $text
                set _Data(result,$game) "="
                set result 0
            }
            if {$_Data(timecontrol) == "pergame"} {
                set _Data($tomove,$game) [expr $_Data($tomove,$game) - $expired]
                if { $_Data(showBoards) || $_Data(showtimes) == 1 } {
                    set clkC [expr { $tomove == "white" ? "clockW" : "clockB" }]
                    set sec [expr $_Data($tomove,$game) / 1000 ]
                    set m [format "%d" [expr ($sec / 60) % 60] ]
                    set s [format "%02d" [expr $sec % 60] ]
                    if { $_Data(showBoards) } {
                        set _Data(name,$game)($clkC) "$m:$s,[string range [expr $_Data($tomove,$game) % 1000 ] 0 1]"
                    }
                    if {$_Data(showtimes) == 1} {
                        set h [format "%02d" [expr abs($sec) / 60 / 60] ]
                        append comment "\[%clk $h:$m:$s\]$comment"
                    }
                } elseif {$_Data(showtimes) == 2} {
                    set sec [expr $expired / 1000.0 ]
                    append comment "\[%emt $sec\]"
                }
                incr _Data($tomove,$game) $_Data(incr50)
            }
            lappend _Data(comments,$game) $comment
            lappend _Data(moves,$game) $bestmove
        } elseif { $bestmove ne "a1a1" } {
            #only debuginfo; but some engines send a1a1 for resign / end of game
            lappend _Data(comments,$game) "Wrong Move or wrong Piece: $tomove $bestmove\n$_Data(board,$game)"
            foreach i [array names ::comp::_Data] {
                if { [string first ",$game" $i] > 0} {
                    catch { puts "::comp::_Data($i) [list $::comp::_Data($i)]" }
                }
            }
        }
    }
    return $result
}

proc ::comp::compNextMove { game tomove expired bestmove } {
    global ::comp::_Data
    if { $_Data(playing,$game) && $bestmove ne "" } {
        set _Data(playing,$game) [compCheckMove $game $tomove $expired $bestmove]
        set tomove [expr {$tomove eq "white" ? "black" : "white"}]
        if { $_Data(showBoards) && $_Data(playing,$game) } {
            ::board::update .comp.bds.g$game "$_Data(board,$game) $tomove" 0
            set square1 [ ::board::sq [string range $bestmove 0 1 ] ]
            set square2 [ ::board::sq [string range $bestmove 2 3 ] ]
            if {$square1 ne $square2} { ::board::mark::DrawArrow .comp.bds.g$game.bd $square1 $square2 $::highlightLastMoveColor }
            if {$_Data(scoreIsNew,$game) } { ::board::updateEvalBar .comp.bds.g$game $_Data(score,$game) }
        }
        if { $_Data(playing,$game) } {
            lassign [::comp::compCheckAdjudication $game] _Data(playing,$game) _Data(result,$game)
        }
        while {$_Data(paused)} {
            vwait ::comp::_Data(paused)
        }
    }
    if { $_Data(playing,$game) } {
        set bestmove ""
        set _Data(scoreIsNew,$game) 0
        # Automatically time-out comp in $movetime + 4 secs
        set timeout [expr {$_Data(timecontrol) == "permove" ? $_Data(time) : $_Data($tomove,$game)}]
        after [expr {$timeout + $_Data(delta)}] "compTimeout $game $tomove"
        if {$_Data(timecontrol) == "pergame"} {
            set parameter "wtime $_Data(white,$game) btime $_Data(black,$game) winc $_Data(incr50) binc $_Data(incr50)"
        } elseif {$_Data(timecontrol) == "permove"} {
            set parameter "movetime $_Data(time)"
        } elseif {$_Data(timecontrol) == "depth"} {
            set parameter "depth $_Data(fixeddepth)"
        }
        set _Data(lasttime,$game) [clock clicks -milli]
        if { $_Data(fen,$game) eq "startpos"} {
            set position "position startpos"
        } else {
            set position "position fen $_Data(fen,$game)"
        }
        if { $_Data(moves,$game) ne "" } { append position " moves $_Data(moves,$game)" }
        ::engine::send compEngine$tomove$game Go [list $position $parameter]
    } else {
        ::comp::compSaveGame $game 
catch { puts "End $game [set _Data(name,$game)(nameW)] - [set _Data(name,$game)(nameB)] result: $_Data(result,$game)" }
        after 1000 "::comp::compOkEnd $game"
    }
}

proc ::comp::adjucateGame {game result} {
    global ::comp::_Data
    set _Data(playing,$game) 0
    set _Data(result,$game) $result
    lappend _Data(comments,$game) "Game judged by user"
}

proc ::comp::compCheckAdjudication {game} {
    global ::comp::_Data

    lappend _Data(scoreHistory,$game) $_Data(score,$game)
    set n_plies [llength $_Data(moves,$game)]
    set n_moves [expr {$n_plies / 2}]

    if { $_Data(forceDraw) && $n_moves >= $_Data(forceDrawAfterMove) } {
        set numPiles [expr {$_Data(forceDrawNumMoves) * 2}]
        set threshold $_Data(forceDrawScore)
        set history $_Data(scoreHistory,$game)
        set histLen [llength $history]
        if { $histLen >= $numPiles } {
            set recent [lrange $history end-[expr {$numPiles-1}] end]
            set allBelow 1
            foreach s $recent {
                if { abs($s) >= $threshold } {
                    set allBelow 0
                    break
                }
            }
            if { $allBelow } {
                set txt "Force draw adjudication ($_Data(forceDrawNumMoves) moves |score|<[format {%.2f} $threshold])"
                set n [llength $_Data(comments,$game)]
                if { $n > 0 } {
                    set last [lindex $_Data(comments,$game) end]
                    if { $last ne "" } { append last " - " }
                    append last $txt
                    lset _Data(comments,$game) end $last
                }
                return [list 0 "="]
            }
        }
    }

    if { $_Data(forceResign) } {
        set numPiles [expr {$_Data(forceResignNumMoves) * 2}]
        set threshold $_Data(forceResignScore)
        set history $_Data(scoreHistory,$game)
        set histLen [llength $history]
        if { $histLen >= $numPiles } {
            set recent [lrange $history end-[expr {$numPiles-1}] end]
            set whiteWins 1
            foreach s $recent {
                if { $s <= $threshold } {
                    set whiteWins 0
                    break
                }
            }
            if { $whiteWins } {
                set txt "Force resign adjudication: White wins ($_Data(forceResignNumMoves) moves score>[format {%.1f} $threshold])"
                set n [llength $_Data(comments,$game)]
                if { $n > 0 } {
                    set last [lindex $_Data(comments,$game) end]
                    if { $last ne "" } { append last " - " }
                    append last $txt
                    lset _Data(comments,$game) end $last
                }
                return [list 0 "1"]
            }
            set blackWins 1
            foreach s $recent {
                if { $s >= [expr {-$threshold}] } {
                    set blackWins 0
                    break
                }
            }
            if { $blackWins } {
                set txt "Force resign adjudication: Black wins ($_Data(forceResignNumMoves) moves score<-[format {%.1f} $threshold])"
                set n [llength $_Data(comments,$game)]
                if { $n > 0 } {
                    set last [lindex $_Data(comments,$game) end]
                    if { $last ne "" } { append last " - " }
                    append last $txt
                    lset _Data(comments,$game) end $last
                }
                return [list 0 "0"]
            }
        }
    }

    return [list 1 $_Data(result,$game)]
}

proc ::comp::compSaveGame {game} {
    global ::comp::_Data ::comp::cSGLock

    set oldCurrent $_Data(database)
    if { $_Data(database) ne $::curr_db } {
        set oldCurrent $::curr_db
        sc_base switch $_Data(database)
    }
    while { $cSGLock } {
        catch { puts "wait for save" }
        vwait ::comp::cSGLock
    }
    set cSGLock 1
    sc_game push
    sc_game new
    sc_game tags set -white [set _Data(name,$game)(nameW)]
    sc_game tags set -black [set _Data(name,$game)(nameB)]
    sc_game tags set -event $_Data(tournament)
    sc_game tags set -site $_Data(site)
    set total [expr int($_Data(base))]
    set mins [expr $total/60]
    set secs [expr $total%60]
    if {$secs == 0} {
        set timecontrol $mins
    } else {
        if {$secs < 10} { set secs "0$secs" }
        set timecontrol $mins:$secs
    }
    set lextra [list "Time \"[clock format [clock seconds] -format %T]\"\n"]
    lappend lextra [expr {$_Data(timecontrol) == "permove" ? "Movetime \"$_Data(seconds)\"" : "TimeControl \"$timecontrol/$_Data(incr)\""}]
    sc_game tags set -date [::utils::date::today] -round $_Data(round,$game) -extra $lextra

    if { $_Data(fen,$game) ne "startpos"} {
        sc_game startBoard $_Data(fen,$game)
    }
    foreach m $_Data(moves,$game) c $_Data(comments,$game) {
        catch { sc_move addSan $m }
        if { $c ne "" } { sc_pos setComment $c }
    }
    sc_game tags set -result $_Data(result,$game)
    if {[sc_pos moves] == {}} {
        if {![sc_pos isCheck]} {
            ### stalemate
            set res =
            sc_pos setComment [tr stalemate]
        } else {
            ### checkmate
            set res [expr {[sc_pos side] == {black} ? 1 : 0}]
        }
        if { $_Data(result,$game) ne $res } {sc_pos setComment "[sc_pos getComment] override result $_Data(result,$game) -> $res"}
        sc_game tags set -result $res
        set _Data(result,$game) $res
    } elseif { $_Data(mate,$game) } {
        #Mate detected but pv does not go to mate
        set _Data(result,$game) [expr { 1 - $_Data(result,$game) }]
        sc_pos setComment "[sc_pos getComment] mate not finished result $_Data(result,$game)"
        sc_game tags set -result $_Data(result,$game)
    }
    ### This game is over; Save game
    if {![sc_base isReadOnly $_Data(database)] && ( $_Data(result,$game) != "*" || $_Data(savebrokengame) || !$_Data(replaybrokengame) )} {
        sc_game save [sc_game number]
    }
    sc_game pop
    if { $oldCurrent ne $::curr_db } { sc_base switch $oldCurrent }
    set cSGLock 0
    ::windows::gamelist::Refresh
    if {[winfo exists $::crosstab::win]} { ::crosstab::Refresh }
}

proc compPause {} {
  global ::comp::_Data engines
  set w .comp
  $w.buttons.ok configure -text [tr Continue] -command compResume
  set _Data(paused) 1
}

proc compResume {} {
  global ::comp::_Data engines
  set w .comp

  $w.buttons.ok configure -text "  Pause  " -command compPause
  set _Data(paused) 0
}

#list of all UCI engines
proc ::comp::getEngList {} {
  set allEngList [::enginecfg::names ]
  set engList {}
  foreach name $allEngList {
      if { [lindex [::enginecfg::get $name] 7] } {
          lappend engList $name
      }
  }
  return [list [llength $engList] $engList]
}


proc compTimeout {game tomove} {
    global ::comp::_Data

    catch { puts "Timed out Game $game" }
    set expired [expr [clock clicks -milli] - $_Data(lasttime,$game)]
    ::comp::compNextMove $game $tomove 0 "Time out"
}

proc compAbort {} {
    # Close all games, called when game is active
    global ::comp::_Data

    if {$_Data(paused)} { compResume }
    set i $_Data(processes)
    while { $i > 0 } {
        set _Data(playing,$i) 0
        incr i -1
    }
    set _Data(games) {}
    set _Data(endaftergame) 1
}

proc compClose {} {
    global ::comp::_Data
    if {[.comp.buttons.cancel cget -text] == {End Comp}} {
        # comp is running. Double check before exitting
        set msg {A Computer Tournament is running.}
        
        set answer [tk_dialog .unsaved "scidCommunity: Confirm Quit" $msg question {} "   [tr FileExit]   " [tr Cancel]]
        if {$answer != 0} {
            return
        }
    }
    compDestroy
}

proc compDestroy {} {
    global ::comp::_Data

    set _Data(games) {}
    set _Data(playing,1) 0
    set _Data(playing,2) 0
    update idletasks
    destroy .comp
}

proc compSave {} {
    global ::comp::_Data
    global scidConfigDir

    set filename ""
    set types { {{Scid Tournament Files} {.sto}} }
    set filename [tk_getSaveFile -initialdir $scidConfigDir -initialfile $_Data(tournament) -filetypes  $types -defaultextension ".sto"]
    if {$filename != ""} {
        doCompSave $filename
    }
}
proc autocompSave {} {
    global ::comp::_Data
    global scidConfigDir

    set tname [string map { " " "" } $_Data(tournament)]
    append tname "_autosave.sto"
    set filename [file join $scidConfigDir $tname]
    doCompSave $filename
}

proc doCompSave { filename } {
    global ::comp::_Data
    if { [catch {open $filename w} stofile]} {
        tk_messageBox -title "scidCommunity: Save Tournament" -type ok -icon warning -message "Unable to write tournament file:\n$filename"
    } else {
        puts $stofile "# Scid comptournament file"
        puts $stofile ""
        foreach i [array names ::comp::_Data] {
            if { [string first "," $i] < 0 } {
                puts $stofile "set ::comp::_Data($i) [list $::comp::_Data($i)]"
            }
        }
        close $stofile
    } 
}

proc ::comp::eng_messages {id w msg} {
    global ::comp::_Data ::comp::options comp
    lassign $msg msgType msgData
    set game [string index $id end]
    set tomove [string range $id end-5 end-1]
    switch $msgType {
        "InfoConfig" {
            if { ! [winfo exists $w] } { return }
            set msgData [lindex $msgData 2]
            ::engineNoWin::initEngineOptions $id $w $msgData
        }
        "InfoPV" {
            lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time score score_type score_wdl pv
            if { $multipv == 1 && $score ne "" } {
                if { $score_type eq "mate" } {
                    set _Data(score,$game) [expr { $score > 0 ? 128 : -128 }]
                    if { [expr abs($score) ] < 2 } {
                        set _Data(mate,$game) 1
                        set _Data(matemoves,$game) $pv
                    }
                } else {
                    set _Data(score,$game) [expr $score / 100.0]
                    set _Data(scoreIsNew,$game) 1
                    set _Data(mate,$game) 0
                }
                if {$tomove == "black"} { set _Data(score,$game) [expr 0.0 - $_Data(score,$game)] }
            }
        }
        "InfoBestMove" {
            set expired [expr [clock clicks -milli] - $_Data(lasttime,$game)]
            after cancel "compTimeout $game $tomove"
            lassign $msgData bestmove
            ::comp::compNextMove $game $tomove $expired $bestmove
        }
        "InfoDisconnected" {
            lassign $msgData errorMsg
            if {$errorMsg eq ""} { set errorMsg "The connection with the engine terminated unexpectedly." }
            set _Data(bestmove,$game) $errorMsg
        }
    }
}

################################################################################
# add current position for 3fold _Data(repetition,$game) detection and returns 1 if
# the position is a _Data(repetition,$game)
################################################################################
proc ::comp::checkRepetition { journal board } {
    set isRep 0
    # append the position only if different from the last element
    if { $board != [ lindex $journal end ] } { lappend journal $board }
    # 3fold repetion detected
    if { [llength [lsearch -all $journal $board] ] >=3 } { set isRep 1 }
    return [list $isRep $journal]
}

proc ::comp::checkfiftyMoveRule { moves prevmaterial prevpawns board} {
    set isFiftyRule 0
    incr moves
    set material [string length [string map {"." ""} $board]]
    set pawns [string map {"n" "." "b" "." "r" "." "q" "." "k" "." "N" "." "B" "." "R" "." "Q" "." "K" "." } $board]
    if { $pawns ne $prevpawns || $material ne $prevmaterial } { set moves 0 }
    if { $moves >= 100  } { set isFiftyRule 2 }
    if { $material == 2 } { set isFiftyRule 1 }
    return [list $isFiftyRule $moves $material $pawns]
}
###
### End of file: multicomp.tcl

