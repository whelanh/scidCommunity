###########################################################
### new pgnviewer window

namespace eval ::pgnviewer {

    # use for scoregraph in engine.tcl
    proc ::pgnviewer::getPosition { n } {
        set nr $::pgnviewer::_move($n)
        set move [lindex $::pgnviewer::_game($n) $nr]
        lassign $move rav depth board2 nag comment san uci
        set ply [lindex $::pgnviewer::_mainMove($n) $nr]
        if { $rav > 0 || $ply < 0} {
            return [list "position fen $board2" $ply]
        }
        if { $nr > 0 } {
            set rav 1
            while { $rav } {
                incr nr -1
                set move [lindex $::pgnviewer::_game($n) $nr]
                lassign $move rav depth board nag comment san uci2
            }
        } else {
            set board $board2
        }
        return [list "position fen $board moves $uci" $ply]
    }
    proc ::pgnviewer::goPositionMainLine { n ply } {
        set ply [lsearch $::pgnviewer::_mainMove($n) $ply]
        update .pv$n $n $ply
    }
    proc ::pgnviewer::getMainline { n } {
        lassign [lindex $::pgnviewer::_game($n) 0] rav depth board
        set ll [linsert $::pgnviewer::_mainLine($n) 0 "position fen $board moves"]
        return $ll
    }
    proc ::pgnviewer::calcMainline { n } {
        unset -nocomplain ::pgnviewer::_mainLine($n)
        set ::pgnviewer::_mainMove($n) [list 0]
        lassign [lindex $::pgnviewer::_game($n) 0] rav depth board
        set m 1
        for { set i 1 } { $i <= $::pgnviewer::_maxply($n) } {} {
            set move [lindex $::pgnviewer::_game($n) $i]
            lassign $move rav depth board nag comment san uci
            lappend ::pgnviewer::_mainLine($n) $uci
            lappend ::pgnviewer::_mainMove($n) $m
            set j [nextScoreMove $n $i]
            incr m
            incr i
            while { $i < $j } {
                lappend ::pgnviewer::_mainMove($n) -1
                incr i
            }
        }
    }
    proc ::pgnviewer::getSide { n e } {
        if { $::pgnviewer::_evalEngine($n) == $e} {
            set move [lindex $::pgnviewer::_game($n) $::pgnviewer::_evalAktMove($n)]
        } else {
            set move [lindex $::pgnviewer::_game($n) $::pgnviewer::_move($n)]
        }
        lassign $move rav depth board
        if { [lindex $board 1] eq "w" } {set ret "white" } else { set ret "black" }
        return $ret
    }
    proc ::pgnviewer::GotoScoreMove {w xc} {
        regexp {^\.pv(\d+)} $w -> n
        set x [expr round([::utils::graph::xunmap score$n $xc] * 2 + 0.5) ]
        ::pgnviewer::update .pv$n $n [lindex $::pgnviewer::_evalMove($n) $x]
    }
    proc ::pgnviewer::ScorePopupEval {w mc xc yc} {
        regexp {^\.pv(\d+)} $w -> n
        set x [expr round([::utils::graph::xunmap score$n $mc] * 2 + 0.5) ]
        if { $x <= 0 || $x >= [llength $::pgnviewer::_evalMove($n)] } return
        set move [lindex $::pgnviewer::_game($n) [lindex $::pgnviewer::_evalMove($n) $x]]
        set bd [FENtoBoard [lindex $move 2]]
        set movenr [expr $x / 2.0 - 0.5]
        set label "[expr int(($x+1) / 2)]. "
        if { ! [expr $x % 2] } { append label "... " }
        append label [lindex $move 5]
        set i [lsearch $::pgnviewer::_scores($n) $movenr]
        set score ""
        if { $i >= 0 && !($i % 2) } {
            incr i
            set score "Eval.: [lindex $::pgnviewer::_scores($n) $i]"
        }
        ::tools::graphs::score::Popup .pgnviewerPopup $bd $label $score $xc $yc
        ::board::flip .pgnviewerPopup.bd [::board::isFlipped [string range $w 0 end-2].bd]
        ::board::lastMoveHighlight .pgnviewerPopup.bd [lindex $move 6]
    }
    proc ::pgnviewer::ScoreUpdate { n } {
        if { ! [winfo exists .pv$n.t.text] } { return }
        set canvas .pv$n.c
        if { ! [winfo exists $canvas] } { return }

        # When an engine is running it populates the chart directly
        # via updateChart (same path as the standalone Engine window).
        set eid $::pgnviewer::_engine($n)
        if {$eid ne "" && [winfo exists .pv$n.engineWin$eid]} { return }
        if {$::pgnviewer::_evalEngine($n) > 0} { return }

        # Determine total plies from _evalMove
        set totalPlies [llength $::pgnviewer::_evalMove($n)]
        set maxPly [expr {$totalPlies > 1 ? $totalPlies - 1 : 1}]

        ::chart::clear $canvas $maxPly

        # Populate chart from _scores.
        # _scores format: {movenr score movenr score ...}
        # movenr to ply: ply = int(round((movenr + 0.5) * 2))
        # Scores are in pawns; normalize to White's perspective by negating
        # Black-to-move positions (odd ply) — matches updateChart in engine.tcl.
        foreach {movenr score} $::pgnviewer::_scores($n) {
            set ply [expr {int(round(($movenr + 0.5) * 2))}]
            if {$ply < 0} { set ply 0 }
            if {$ply > $maxPly} { set ply $maxPly }
            if {$ply % 2 == 1} { set score [expr { - $score }] }
            set cp [expr {int($score * 100)}]
            ::chart::setDataPoint $canvas $ply $cp \
                [list ::pgnviewer::chartCallback $n]
        }

        # Calculate and display accuracy (same method as engine window)
        set currentScores [::chart::getScores $canvas]
        if {[llength $currentScores] > 1} {
            lassign [::accuracy::calculate $currentScores] wAcc bAcc
            ::chart::setAccuracy $canvas $wAcc $bAcc
        }

        # Move cursor to current position
        set evalIdx [lsearch $::pgnviewer::_evalMove($n) $::pgnviewer::_move($n)]
        if {$evalIdx >= 0} {
            ::chart::moveCursorLine $canvas $evalIdx
        } else {
            ::chart::moveCursorLine $canvas
        }

        # Update eval bar
        set evalBar ""
        if {$evalIdx >= 0} {
            set movenr [expr {$evalIdx / 2.0 - 0.5}]
            set i [lsearch $::pgnviewer::_scores($n) $movenr]
            if { $i >= 0 && !($i % 2) } {
                incr i
                set evalBar [lindex $::pgnviewer::_scores($n) $i]
            }
        }
        ::board::updateEvalBar .pv$n.bd $evalBar
    }
    proc ::pgnviewer::chartCallback {n ply value} {
        if {$value eq ""} {
            # Click: navigate to position
            if {$ply >= 0 && $ply < [llength $::pgnviewer::_evalMove($n)]} {
                ::pgnviewer::update .pv$n $n [lindex $::pgnviewer::_evalMove($n) $ply]
            }
            return ""
        }
        # Hover: format tooltip
        set label ""
        if {$ply > 0 && $ply < [llength $::pgnviewer::_evalMove($n)]} {
            set gameIdx [lindex $::pgnviewer::_evalMove($n) $ply]
            set move [lindex $::pgnviewer::_game($n) $gameIdx]
            set moveNum [expr {($ply + 1) / 2}]
            set san [lindex $move 5]
            if {$ply % 2 == 1} {
                set label "$moveNum. $san"
            } else {
                set label "$moveNum... $san"
            }
        }
        if {abs($value) >= 100000} {
            set scoreStr "#[format {%+d} [expr {$value / 100000}]]"
        } else {
            set scoreStr [format {%+.2f} [expr {$value / 100.0}]]
        }
        return "$label\n$scoreStr"
    }

    set ::pgnCalcAktiv 0

    # Hilfsfunktion für GetScore und CalcScore
    proc ::pgnviewer::insertScore { n } {
        if { $::pgnviewer::_score($n) ne "" } {
            set score $::pgnviewer::_score($n)
            if { [string first "M" $score] > 0 } { set score "[string index $score 0]12" }
            set ind [lsearch $::pgnviewer::_scores($n) $::pgnviewer::_engply($n)]
            if { $ind >= 0 } {
                incr ind
                set ::pgnviewer::_scores($n) [lreplace $::pgnviewer::_scores($n) $ind $ind $score]
            } else {
                lappend ::pgnviewer::_scores($n) $::pgnviewer::_engply($n) $score
            }
        }
    }
    # Hilfsfunktion für GetScore und CalcScore
    proc ::pgnviewer::nextScoreMove { n i} {
        while { $i <= $::pgnviewer::_maxply($n) } {
            incr i
            set move [lindex $::pgnviewer::_game($n) $i]
            lassign $move rav1 depth1 ;# board1 nag1 comment1 san1 uci1 tag1
            if { ($rav1 == 0 && $depth1 == 0) } { break }
        }
        return $i
    }
    # Read score from game
    proc ::pgnviewer::GetScore { n } {
        set ::pgnviewer::_engply($n) -0.5
        for { set i 0 } { $i <= $::pgnviewer::_maxply($n) } {} {
            set move [lindex $::pgnviewer::_game($n) $i]
            set ::pgnviewer::_score($n) ""
            lassign $move rav depth board nag comment san uci
            set ::pgnviewer::_score($n) [getScorefromComment $comment 12]
            insertScore $n
            lappend ::pgnviewer::_evalMove($n) $i
            set ::pgnviewer::_engply($n) [expr $::pgnviewer::_engply($n) + 0.5]
            set i [nextScoreMove $n $i]
        }
        # Scoregraph nur anzeigen, wenn auch Scores da sind
        ::pgnviewer::ScoreUpdate $n
    }

    # Evaluate Score with engine (uses same engine autorun path as Engine 1 window)
    proc ::pgnviewer::CalcScore { n time } {
        if { $::enginewin_lastengine(1) eq "" } { return }
        set id $::pgnviewer::_engine($n)
        if {$id eq "" || ![winfo exists .pv$n.engineWin$id]} {
            ::pgnviewer::engineOnOff $n
            set id $::pgnviewer::_engine($n)
        }
        if {$id ne ""} {
            set ::enginewin_autorun($id) [list [list movetime $time]]
        }
    }

    proc ::pgnviewer::SaveScore { n } {
        sc_game push
        sc_base switch $::pgnviewer::_base($n)
        sc_game load $::pgnviewer::_gnum($n)
        foreach { i j } $::pgnviewer::_scores($n) {
            catch {sc_move ply [expr {$i * 2}]}
            storeEvalComment $j
        }
        sc_game save $::pgnviewer::_gnum($n)
        sc_game new ; #unload game
        sc_base switch $::curr_db
        sc_game pop
    }

    proc ::pgnviewer::ScaleScoreGraph {n amount {factor 1}} {
        incr ::pgnviewer::_MaxY($n) [expr {$amount / $factor < 0 ? 1 : -1}]
        if { $::pgnviewer::_MaxY($n) < 1 } {
            set ::pgnviewer::_MaxY($n) 1
        } elseif { $::pgnviewer::_MaxY($n) > 7 } { set ::pgnviewer::_MaxY($n) 7 }
        ::pgnviewer::ScoreUpdate $n
    }

    proc ::pgnviewer::SetupScoreGraphPopup { w n } {
        # Chart handles tooltips natively; kept as a no-op for callers.
    }

    proc ::pgnviewer::ScoreGraph { w n } {
        ttk_canvas $w.c -highlightthickness 0 -width 100 -height 68
        ::chart::init $w.c {FONT font_Regular}
        bind $w.c <2> {incr ::pgnCalcAktiv -1}
    }

    proc ::pgnviewer::EngineBestMove { n e score move color} {
        if { $::pgnviewer::_evalEngine($n) == $e } {
            if { $score ne "" } {
                set ::pgnviewer::_score($n) $score
            }
        } else {
            set w .pv$n
            ::board::updateEvalBar $w.bd $score
            ::board::mark::DrawBestMove $w.bd $move $color
        }
    }

    proc ::pgnviewer::engineOnOff { n } {
        set id $::pgnviewer::_engine($n)
        set w .pv$n
        if { $id ne "" && [winfo exists $w.engineWin$id] } {
            grid forget $w.engineWin$id
            destroy $w.engineWin$id
            ::pgnviewer::EngineBestMove $n "" "" "" ""
            set ::pgnviewer::_engine($n) ""
        } else {
            set id [::enginewin::Open $id $::enginewin_lastengine(1) $n]
            set ew $w.engineWin$id
            $ew.display.pv_lines configure -height 0
            catch { $ew.pane forget $ew.stored_eval }
            catch { $ew.pane forget $ew.debug }
            ::update
            grid $ew -row 2 -column 0 -sticky news -columnspan 2
            grid rowconfigure $w 2 -weight 1
            set ::pgnviewer::_engine($n) $id
            catch { $w.p forget $w.c }
        }
    }

    proc ::pgnviewer::setupDefaults { n } {
        set w .pgnviewerDefDialog
        if { [winfo exists $w] } return

        win::createDialog $w
        ::setTitle $w "scidCommunity PGN-Viewer Defaults"

        ttk::frame $w.config
        ttk::checkbutton $w.config.sh -text [tr PgnOptShort] -variable ::pgnviewer::shortHeader -command "::pgnviewer::updateDefaults $n"
        ttk::checkbutton $w.config.sn -text [tr PgnOptSymbols] -variable ::pgnviewer::symbolicNags -command "::pgnviewer::updateDefaults $n"
        ttk::checkbutton $w.config.ic -text [tr PgnOptIndentC] -variable ::pgnviewer::indentComments -command "::pgnviewer::updateDefaults $n"
        ttk::checkbutton $w.config.iv -text [tr PgnOptIndentV] -variable ::pgnviewer::indentVars -command "::pgnviewer::updateDefaults $n"
        ttk::checkbutton $w.config.mn -text [tr PgnOptSpace] -variable ::pgnviewer::moveNumberSpaces -command "::pgnviewer::updateDefaults $n"
        ttk::checkbutton $w.config.cf -text [tr PgnOptColumn] -variable ::pgnviewer::columnFormat -command "::pgnviewer::updateDefaults $n"
        ttk::checkbutton $w.config.sm -text [tr PgnOptStripMarks] -variable ::pgnviewer::stripMarks -command "::pgnviewer::updateDefaults $n"
        ttk::checkbutton $w.config.bm -text [tr PgnOptBoldMainLine] -variable ::pgnviewer::boldMainLine -command "::pgnviewer::updateDefaults $n"
        ttk::checkbutton $w.config.sp -text [tr GInfoPhotos] -variable ::pgnviewer::showPhoto -command "::pgnviewer::updateDefaults $n"
        ttk::checkbutton $w.config.bo -text [tr Diagram] -variable ::pgnviewer::showDiagramm -command "::pgnviewer::updateDefaults $n"
        ttk::checkbutton $w.config.so -text [tr SoundsMove] -variable ::pgnviewer::sound -command "::pgnviewer::updateDefaults $n"
        ttk::checkbutton $w.config.mat -text [tr GInfoMaterial] -variable ::pgnviewer::mat -command "::pgnviewer::updateDefaults $n"
        ttk::checkbutton $w.config.eval -text [tr showscore] -variable ::pgnviewer::eval -command "::pgnviewer::updateDefaults $n"
        ttk::radiobutton $w.config.eg -text [tr GraphLine] -variable ::pgnviewer::evalType -value 1 -command "::pgnviewer::updateDefaults $n"
        ttk::radiobutton $w.config.eb -text [tr GraphBar] -variable ::pgnviewer::evalType -value 0 -command "::pgnviewer::updateDefaults $n"
        ttk::checkbutton $w.config.sb -text [tr GraphPopup] -variable ::pgnviewer::showPopup -command "::pgnviewer::updateDefaults $n"

        ttk::frame $w.config.s
        ttk::label $w.config.s.lb -text [tr OptionsBoardSize]
        ttk::combobox $w.config.s.size -width 4 -textvar ::pgnviewer::size -values $::boardSizes
        bind $w.config.s.size <<ComboboxSelected>> "::pgnviewer::updateDefaults $n"
        menu $w.config.s.menu
        $w.config.s.menu add command -image ::icon::tb_coords_no -command "set ::pgnviewer::coords 0; ::pgnviewer::updateDefaults $n"
        $w.config.s.menu add command -image ::icon::tb_coords_in -command "set ::pgnviewer::coords 1; ::pgnviewer::updateDefaults $n"
        $w.config.s.menu add command -image ::icon::tb_coords_inall -command "set ::pgnviewer::coords 2; ::pgnviewer::updateDefaults $n"
        $w.config.s.menu add command -image ::icon::tb_coords_2side -command "set ::pgnviewer::coords 3; ::pgnviewer::updateDefaults $n"
        $w.config.s.menu add command -image ::icon::tb_coords_no -command "set ::pgnviewer::coords 4; ::pgnviewer::updateDefaults $n"
        $w.config.s.menu add command -image ::icon::tb_coords_small -command "set ::pgnviewer::coords 5; ::pgnviewer::updateDefaults $n"
        $w.config.s.menu add command -image ::icon::tb_coords_all -command "set ::pgnviewer::coords 6; ::pgnviewer::updateDefaults $n"
        ttk::menubutton $w.config.s.coords -image ::icon::tb_coords_small -style TButton -menu $w.config.s.menu
        pack $w.config.sh $w.config.sn $w.config.ic $w.config.iv $w.config.mn $w.config.cf $w.config.sm \
            $w.config.bm $w.config.sp $w.config.bo $w.config.so -side top -anchor nw -pady 2
        pack $w.config.s.lb $w.config.s.size -side left -anchor n -padx {0 4}
        pack $w.config.s.coords -side left -anchor n -padx 10
        pack $w.config.mat $w.config.eval $w.config.eg $w.config.eb $w.config.sb $w.config.s -side top -anchor nw -pady 2
        pack $w.config -side top -expand no -padx 4 -anchor nw

        wm resizable $w 1 0
    }

    proc ::pgnviewer::setupMenu { n } {
        set w .pv$n
        menu $w.menu
        $w.menu add command -label [tr PgnVarClose] -command "::htext::resetToggleVar $w.t.text 1"
        $w.menu add command -label [tr PgnVarOpen] -command "::htext::resetToggleVar $w.t.text 0"
        $w.menu add separator
        $w.menu add checkbutton -label [tr PgnOptShort] -variable ::pgnviewer::_shortHeader($n) -command "::pgnviewer::Refresh .pv$n $n"
        $w.menu add checkbutton -label [tr PgnOptSymbols] -variable ::pgnviewer::_symbolicNags($n) -command "::pgnviewer::Refresh .pv$n $n"
        $w.menu add checkbutton -label [tr PgnOptStripMarks] -variable ::pgnviewer::_stripMarks($n) -command "::pgnviewer::Refresh .pv$n $n"
        $w.menu add checkbutton -label [tr GInfoPhotos] -variable ::pgnviewer::_photo($n) -command "::pgnviewer::Refresh .pv$n $n"
        $w.menu add checkbutton -label [tr Diagram] -variable ::pgnviewer::_showDiagramm($n) -command "::pgnviewer::Refresh .pv$n $n"
        $w.menu add checkbutton -label [tr SoundsMove] -variable ::pgnviewer::_sound($n) -command "::pgnviewer::Refresh .pv$n $n"
        $w.menu add radiobutton -label [tr GraphLine] -variable ::pgnviewer::_evalType($n) -value 1 -command "::pgnviewer::Refresh .pv$n $n"
        $w.menu add radiobutton -label [tr GraphBar] -variable ::pgnviewer::_evalType($n) -value 0 -command "::pgnviewer::Refresh .pv$n $n"
        $w.menu add checkbutton -label [tr GraphPopup] -variable ::pgnviewer::_showPopup($n) -command "::pgnviewer::SetupScoreGraphPopup .pv$n $n"
        bind $w <3> "tk_popup $w.menu %X %Y"
    }

    proc ::pgnviewer::updateDefaults { n } {
        set ::pgnviewer::_shortHeader($n) $::pgnviewer::shortHeader
        set ::pgnviewer::_photo($n) $::pgnviewer::showPhoto
        set ::pgnviewer::_stripMarks($n) $::pgnviewer::stripMarks
        set ::pgnviewer::_symbolicNags($n) $::pgnviewer::symbolicNags
        set ::pgnviewer::_showDiagramm($n) $::pgnviewer::showDiagramm
        set ::pgnviewer::_sound($n) $::pgnviewer::sound
        set ::pgnviewer::_evalType($n) $::pgnviewer::evalType
        set ::pgnviewer::_showPopup($n) $::pgnviewer::showPopup
        set ::pgnviewer::_coords($n) $::pgnviewer::coords
        ::pgnviewer::SetupScoreGraphPopup .pv$n $n
        ::pgnviewer::Refresh .pv$n $n
        ::board::coords .pv$n.bd $::pgnviewer::_coords($n)
        ::board::resize .pv$n.bd $::pgnviewer::size
        ::board::resize .pv$n.bd redraw
    }

    proc ::pgnviewer::toggleheader { w n } {
        if {[$w.t.text tag ranges sel] eq ""} {
            set ::pgnviewer::_shortHeader($n) [expr {![set ::pgnviewer::_shortHeader($n)]}]
            ::pgnviewer::Refresh $w $n
            $w.t.text yview moveto 0
        }
    }
    proc ::pgnviewer::togglephoto { w n } {
        if {[$w.t.text tag ranges sel] eq ""} {
            set ::pgnviewer::_photo($n) [expr {![set ::pgnviewer::_photo($n)]}]
            ::pgnviewer::Refresh $w $n
            $w.t.text yview moveto 0
        }
    }
    proc ::pgnviewer::autosize { w } {
        # Berücksichtige die 2 Spielernamenzeilen
        set bb [grid bbox $w 0 0]
        set y [expr [lindex $bb 3] - 22]
        set bb [lreplace $bb 3 3 $y]
        ::board::resizeAuto $w.bd $bb
    }

    ################################################################################
    # create new pgn viewer window
    ################################################################################
    proc ::pgnviewer::new {base gnum {ply -1}} {
        set n 1
        while {[winfo exists .pv$n]} { incr n }
        set w .pv$n
        toplevel $w
        if {$base < 1} { set base [sc_base current] }
        if {$gnum < 1} { set gnum [sc_game number] }
        set ::pgnviewer::_move($n) 0
        set ::pgnviewer::autoplay($n) 0
        set ::pgnviewer::_base($n) $base
        set ::pgnviewer::_gnum($n) $gnum
        foreach var {shortHeader stripMarks showPhoto showDiagramm sound evalType showPopup coords symbolicNags indentVars indentComments moveNumberSpaces columnFormat boldMainLine eval mat} {
            if {![info exists ::pgnviewer::$var]} { set ::pgnviewer::$var 0 }
        }
        if {![info exists ::pgnviewer::size]} { set ::pgnviewer::size 32 }
        set ::pgnviewer::_shortHeader($n) $::pgnviewer::shortHeader
        set ::pgnviewer::_photo($n) $::pgnviewer::showPhoto
        set ::pgnviewer::_stripMarks($n) $::pgnviewer::stripMarks
        set ::pgnviewer::_showDiagramm($n) $::pgnviewer::showDiagramm
        set ::pgnviewer::_sound($n) $::pgnviewer::sound
        set ::pgnviewer::_players($n)(nameW) ""
        set ::pgnviewer::_players($n)(nameB) ""
        set ::pgnviewer::_players($n)(clockW) ""
        set ::pgnviewer::_players($n)(clockB) ""
        set ::pgnviewer::_engine($n) ""
        set ::pgnviewer::_evalEngine($n) 0
        set ::pgnviewer::_scores($n) {}
        set ::pgnviewer::_MaxY($n) 6
        set ::pgnviewer::_evalMove($n) {}
        set ::pgnviewer::_evalType($n) $::pgnviewer::evalType
        set ::pgnviewer::_showPopup($n) $::pgnviewer::showPopup
        set ::pgnviewer::_coords($n) $::pgnviewer::coords

        grid [ttk::frame $w.l] -row 0 -column 0 -sticky new
        grid [ttk::frame $w.r] -row 0 -column 1 -sticky news
        grid rowconfigure $w 0 -weight 1
        grid columnconfigure $w 0 -weight 1 -minsize 400
        grid columnconfigure $w 1 -weight 1
        pack [ttk::frame $w.b] -in $w.l -side bottom -anchor n
        pack [ttk::frame $w.b2] -in $w.r -side bottom -fill x
        pack [ttk::panedwindow $w.p -orient vertical] -in $w.r -side bottom -fill both -expand yes
        applyThemeColor_background $w
        ::board::new $w.bd $::pgnviewer::size
        ::board::coords $w.bd $::pgnviewer::_coords($n)
        ::board::addNamesBar $w.bd ::pgnviewer::_players($n)
        ::board::showMarks $w.bd 1
        if { $::pgnviewer::eval } { ::board::toggleEvalBar $w.bd }
        if { $::pgnviewer::mat } { ::board::toggleMaterial $w.bd }
        pack $w.bd -in $w.l -side left -padx 0 -pady 0 -expand yes

        autoscrollText y $w.t $w.t.text Treeview
        $w.t.text configure -wrap word -state normal -tabs {1c right 2c 4c} \
            -width 64 -height 12 -font font_Small -setgrid 1
        $w.t.text tag configure right -justify right
        ::pgnviewer::ScoreGraph $w $n
        $w.p add $w.t -weight 1
        catch { $w.p forget $w.c }

        bind $w <F1> {helpWindow GameList Browsing}
        bind $w <Escape> "destroy $w"
        bind $w <Home> "::pgnviewer::update $w $n 0"
        bind $w <End> "::pgnviewer::update $w $n end"
        bind $w <Left> "::pgnviewer::update $w $n -1"
        bind $w <Right> "::pgnviewer::update $w $n +1"
        bind $w <Up> "::pgnviewer::update $w $n up"
        bind $w <Down> "::pgnviewer::update $w $n down"
        bind $w.bd <Configure> "::pgnviewer::autosize $w"
        bindMouseWheel $w.bd "::pgnviewer::mousewheelHandler $w $n"
        bindMouseWheel $w.bd.bd "::pgnviewer::mousewheelHandler $w $n"
        $w.t.text tag bind tag <ButtonRelease-1> "::pgnviewer::toggleheader $w $n"
        $w.t.text tag bind tag <ButtonRelease-3> "::pgnviewer::togglephoto $w $n"

        ttk::button $w.b.start -image ::icon::tb_start -command "::pgnviewer::update $w $n 0"
        ttk::button $w.b.back -image ::icon::tb_prev -command "::pgnviewer::update $w $n -1"
        ttk::button $w.b.forward -image ::icon::tb_next -command "::pgnviewer::update $w $n +1"
        ttk::button $w.b.end -image ::icon::tb_end -command "::pgnviewer::update $w $n end"
        ttk::button $w.b.up -image ::icon::tb_up -command "::pgnviewer::update $w $n up"
        ::utils::tooltip::Set $w.b.up $::tr(LeaveVariant)
        ttk::button $w.b.down -image ::icon::tb_down -command "::pgnviewer::update $w $n down"
        ttk::button $w.b.autoplay -image ::icon::tb_play -command "::pgnviewer::autoplay $w $n"
        ttk::button $w.b.flip -image ::icon::tb_flip -command "::board::flip $w.bd"
        ttk::button $w.b.mat -image ::icon::tb_material -command "::board::toggleMaterial $w.bd"
        ttk::button $w.b.eval -image ::icon::tb_score -command "::board::toggleEvalBar $w.bd"
        menu $w.b.menu
        $w.b.menu add command -image ::icon::tb_coords_no -command "::board::coords $w.bd 0 ; ::board::resize $w.bd redraw"
        $w.b.menu add command -image ::icon::tb_coords_in -command "::board::coords $w.bd 1 ; ::board::resize $w.bd redraw"
        $w.b.menu add command -image ::icon::tb_coords_inall -command "::board::coords $w.bd 2 ; ::board::resize $w.bd redraw"
        $w.b.menu add command -image ::icon::tb_coords_2side -command "::board::coords $w.bd 3 ; ::board::resize $w.bd redraw"
        $w.b.menu add command -image ::icon::tb_coords_no -command "::board::coords $w.bd 4 ; ::board::resize $w.bd redraw"
        $w.b.menu add command -image ::icon::tb_coords_small -command "::board::coords $w.bd 5 ; ::board::resize $w.bd redraw"
        $w.b.menu add command -image ::icon::tb_coords_all -command "::board::coords $w.bd 6 ; ::board::resize $w.bd redraw"
        ttk::menubutton $w.b.coords -image ::icon::tb_coords_small -style TButton -menu $w.b.menu

        pack $w.b.start $w.b.back $w.b.up $w.b.down $w.b.forward $w.b.end \
            $w.b.autoplay $w.b.flip $w.b.mat $w.b.eval $w.b.coords -side left -padx 3 -pady 1

        if {$gnum > 0} {
            menu $w.evalmenu
            foreach {time_value} {1000 600 200 100 50} {
                $w.evalmenu add command -label "$time_value ms" -command "::pgnviewer::CalcScore $n $time_value"
            }
            ttk::menubutton $w.b2.eval -text [tr PgnEvaluate] -style Toolbutton -direction above -menu $w.evalmenu
            ttk::button $w.b2.sav -image ::icon::tb_save -command "::pgnviewer::SaveScore $n"
            tooltip::tooltip $w.b2.sav [tr PgnSaveEval]
            ttk::button $w.b2.eng -image ::icon::tb_engine -command "::pgnviewer::engineOnOff $n"
            ttk::checkbutton $w.b2.comm -text "\[%]" -offvalue 1 -onvalue 0 -variable ::pgnviewer::_stripMarks($n) \
                -command "::pgnviewer::Refresh $w $n"
            ::utils::tooltip::Set $w.b2.comm [tr ExportStripMarks]
            ttk::button $w.b2.conf -image ::icon::tb_config -command "::pgnviewer::setupDefaults $n"
            ttk::button $w.b2.load -textvar ::tr(LoadGame) -command "sc_base switch $base; ::game::Load $gnum"
            ttk::button $w.b2.merge -textvar ::tr(MergeGame) -command "mergeGame $base $gnum"
            ::pgnviewer::setupMenu $n

            pack $w.b2.eng -side left -pady 1
            pack $w.b2.conf $w.b2.merge $w.b2.load $w.b2.comm $w.b2.eval $w.b2.sav -side right -padx 3 -pady 1
        }

        if { [::board::isFlipped .main.board] } {
            ::board::flip $w.bd
        }
        # Take input focus even if -state is disabled
        bind $w.t.text <ButtonPress-1> "focus %W"

        # Workaround for Text widget bug (Tk 8.6.6+)
        # The new "asynchronous update of line heights" does not work if
        # the Text widget is inside an inactive ttk::notebook tab.
        if {![catch { $w.t.text sync }]} { bind $w.t.text <Visibility> "$w.t.text sync" }

        $w.t.text tag configure Current -background $::pgnColor(Current)
        ::htext::init $w.t.text
        ::htext::updateRate $w.t.text 0
        ::pgnviewer::Refresh $w $n
        ::pgnviewer::GetScore $n
        ::board::updateFlag $w.bd [set ::pgnviewer::_players($n)(nameW)] w
        ::board::updateFlag $w.bd [set ::pgnviewer::_players($n)(nameB)] b
    }

    ################################################################################
    # ::pgnviewer::ShowBoard:
    #    Produces a popup window showing the board position in the
    #    game at the current mouse location in the PGN window.
    ################################################################################
    proc ShowBoard {w n xc yc nr} {
        set move [lindex $::pgnviewer::_game($n) $nr]
        set bd [FENtoBoard [lindex $move 2]]
        ::board::popup .pgnviewerPopup $bd $xc $yc
        ::board::flip .pgnviewerPopup.bd [::board::isFlipped $w.bd]
        ::board::lastMoveHighlight .pgnviewerPopup.bd [lindex $move 6]
    }

    ################################################################################
    # ::pgnviewer::HideBoard
    #    Hides the window produced by ::pgn::ShowBoard.
    ################################################################################
    proc HideBoard {} {
        if {[winfo exists .pgnviewerPopup]} {wm withdraw .pgnviewerPopup}
    }

    ###################################
    # convert FEN to Board
    proc ::pgnviewer::FENtoBoard { fen } {
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

    proc ::pgnviewer::mcallback { w moveTag } {
        # Check if it is a move tag:
        set n $::pgnviewer::m_callN
        set wpv $::pgnviewer::m_callW
        set movenr $::pgnviewer::m_callMoveNr
        set move [lindex $::pgnviewer::_game($n) $movenr]
        lappend move [string range $moveTag 2 end]
        #append pgn tag number to the game position
        set ::pgnviewer::_game($n) [lreplace $::pgnviewer::_game($n) $movenr $movenr $move]
        $w tag bind $moveTag <ButtonRelease-1> "::pgnviewer::update $wpv $n $movenr"
        # Bind right button to popup a PGN board:
        $w tag bind $moveTag <ButtonRelease-$::MB2> "::pgnviewer::HideBoard"
        $w tag bind $moveTag <ButtonPress-$::MB2> "::pgnviewer::ShowBoard $wpv $n %X %Y $movenr"
        $w tag bind $moveTag <Any-Enter> "$w tag configure $moveTag -underline 1 ; $w configure -cursor hand2"
        $w tag bind $moveTag <Any-Leave> "$w tag configure $moveTag -underline 0 ; $w configure -cursor {}"
        incr ::pgnviewer::m_callMoveNr
        return [list m $moveTag ]
    }
    proc ::pgnviewer::ccallback {w commentTag} {
        $w tag configure $commentTag -foreground $::pgnColor(Comment) -font font_Regular
        return [list c $commentTag ]
    }

    ################################################################################
    # ::pgnviewer::Refresh
    #    Updates the PGN window. If $pgnNeedsUpdate == 0, then the
    #    window text is not regenerated; only the current and next move
    #    tags will be updated.
    ################################################################################
    proc Refresh { w n } {
        busyCursor .
        $w.t.text configure -state normal
        $w.t.text delete 0.0 end
        set font font_Regular
        if { $::pgnviewer::boldMainLine } {
            set font font_Bold
        }
        $w.t.text configure -font $font
        sc_game push
        sc_base switch $::pgnviewer::_base($n)
        set filename [file tail [sc_base filename $::pgnviewer::_base($n)]]
        sc_game load $::pgnviewer::_gnum($n)
        set ::pgnviewer::_players($n)(nameW) [sc_game info white]
        set ::pgnviewer::_players($n)(nameB) [sc_game info black]
        wm title $w "PGN-Viewer: [set ::pgnviewer::_players($n)(nameW)] - [set ::pgnviewer::_players($n)(nameB)] ($filename: $::pgnviewer::_gnum($n))"
        set ::pgnviewer::_pgnStr($n) [sc_game pgn -symbols $::pgnviewer::symbolicNags \
                        -indentVariations $::pgnviewer::indentVars -indentComments $::pgnviewer::indentComments \
                        -showDiagram $::pgnviewer::_showDiagramm($n) \
                        -space $::pgnviewer::moveNumberSpaces -format color -column $::pgnviewer::columnFormat \
                        -shortHeader $::pgnviewer::_shortHeader($n) -markCodes $::pgnviewer::_stripMarks($n)]
        if { $::pgnviewer::_showDiagramm($n) } {
            set ::pgnviewer::_pgnStr($n) [string map {"\[#\]" "<board>" } $::pgnviewer::_pgnStr($n)]
        }
        set ::pgnviewer::_game($n) [sc_base getGame $::pgnviewer::_base($n) $::pgnviewer::_gnum($n)]
        set ::pgnviewer::_maxply($n) [expr [llength $::pgnviewer::_game($n)] - 1 ]
        calcMainline $n
        set ::pgnviewer::m_callN $n
        set ::pgnviewer::m_callW $w
        set ::pgnviewer::m_callMoveNr 1
        if {$::pgnviewer::_photo($n)} {
            set isWP [getphoto photoW${n} [spellCheckPlayerName [set ::pgnviewer::_players($n)(nameW)]]]
            set isBP [getphoto photoB${n} [spellCheckPlayerName [set ::pgnviewer::_players($n)(nameB)]]]
            set res [expr $isWP + $isBP]
            switch $res {
                0 { set firstLine "" }
                1 { set firstLine "-\n" }
                2 { set firstLine "\n" }
            }
        } else { set firstLine "" }
        ::htext::display $w.t.text "$firstLine$::pgnviewer::_pgnStr($n)" "" 1  $::pgnviewer::_showDiagramm($n) ::pgnviewer::mcallback ::pgnviewer::ccallback
        set ::pgnviewer::result($n) [string index $::pgnviewer::_pgnStr($n) end-7]
        sc_game new ; #unload game
        sc_base switch $::curr_db
        sc_game pop
        unset ::pgnviewer::m_callN
        unset ::pgnviewer::m_callW
        unset ::pgnviewer::m_callMoveNr

        if {$::pgnviewer::_photo($n)} {
            if {[image width photoW$n] != 0} {
                $w.t.text image create 1.0 -image photoW$n -padx 10
                $w.t.text tag add right 1.0 1.end
            }
            if {[image width photoB$n] != 0} {
                $w.t.text image create 1.end -image photoB$n
                $w.t.text tag add right 1.0 1.end
            }
        }

        $w.t.text configure -state disabled
        unbusyCursor .
        ::pgnviewer::update $w $n $::pgnviewer::_move($n)
        ::pgnviewer::update_current_move $w 1
    }

    proc update_current_move {w n} {
        $w.t.text tag remove Current 1.0 end
        set moveRange [$w.t.text tag nextrange "m_$n" 1.0]
        if {[llength $moveRange] == 2} {
            ::htext::showVar $w.t.text [lindex $moveRange 0]
            $w.t.text tag add Current [lindex $moveRange 0] [lindex $moveRange 1]
            $w.t.text see [lindex $moveRange 1]
        } else {
            $w.t.text yview moveto 0
        }
    }
    proc lastMoveHighlight {w n uci san nag ply board } {
        ::board::lastMoveHighlight $w $uci \"$nag\"
        set isMate [string first "#" $san]
        if { $isMate > 0 || ($ply >= $::pgnviewer::_maxply($n) && $::highlightLastMoveNag) } {
            # Show Result on King positions on the board
            set res $::pgnviewer::result($n)
            if { $res ne "*"  || $isMate > 0} {
                switch $res {
                    1 { set t1 0; set t2 1 }
                    0 { set t1 1; set t2 0 }
                    2 { set t1 "\u00BD"; set t2 "\u00BD" }
                }
                if {$isMate > 0 } {
                    if { [string index [lindex $::pgnviewer::_game($n) $ply] 65] eq "w" } {
                        set t1 "#"; set t2 1
                    } else {
                        set t2 "#"; set t1 1
                    }
                }
                ::board::mark::DrawNag $w [string first "K" $board] $t1 "#d0d0d0" "#303030"
                ::board::mark::DrawNag $w [string first "k" $board] $t2 "#303030" "#d0d0d0"
            }
        }
    }

    proc update {w n ply} {
        if {! [winfo exists $w]} { return }
        switch $ply {
            "+1" { ; # next move in same line/variation
                set san1 ""
                set ply $::pgnviewer::_move($n)
                set move [lindex $::pgnviewer::_game($n) $ply]
                lassign $move rav depth board nag comment san uci
                set stop $ply
                while { $ply < $::pgnviewer::_maxply($n) } {
                    incr ply
                    set move [lindex $::pgnviewer::_game($n) $ply]
                    lassign $move rav1 depth1 board1 nag1 comment1 san1 uci11
                    if { ($rav == $rav1 && $depth == $depth1) } { break }
                    if { $rav1 == 0 && $rav > 0} { set ply $stop ; break }
                }
                if { $::pgnviewer::_sound($n) && $san1 ne "" } { ::utils::sound::AnnounceForward $san1 }
            }
            "-1" { ; # previous move in same line/variation
                set ply $::pgnviewer::_move($n)
                set move [lindex $::pgnviewer::_game($n) $ply]
                lassign $move rav depth board nag comment san uci
                while { $ply > 0 } {
                    incr ply -1
                    set move [lindex $::pgnviewer::_game($n) $ply]
                    lassign $move rav1 depth1 board1 nag1 comment1 san1 uci11
                    if { ($rav == $rav1 && $depth == $depth1) || $rav1 < $rav } { break }
                }
            }
            "up" { ; # Leave Variation
                set ply $::pgnviewer::_move($n)
                set move [lindex $::pgnviewer::_game($n) $ply]
                lassign $move rav depth board nag comment san uci
                while { $ply > 0 } {
                    incr ply -1
                    set move [lindex $::pgnviewer::_game($n) $ply]
                    lassign $move rav1 depth1 board1 nag1 comment1 san1 uci11
                    if { $rav1 < $rav || $rav1 == 0 } { break }
                }
            }
            "down" { ; # Enter Variation
                set ply $::pgnviewer::_move($n)
                set move [lindex $::pgnviewer::_game($n) $ply]
                lassign $move rav depth board nag comment san uci
                set stop $ply
                while { $ply < $::pgnviewer::_maxply($n) } {
                    incr ply
                    set move [lindex $::pgnviewer::_game($n) $ply]
                    lassign $move rav1 depth1 board1 nag1 comment1 san1 uci11
                    if { ($rav != $rav1 )|| ($depth != $depth1) } { break }
                }
            }
        }
        if {$ply > $::pgnviewer::_maxply($n)} { set ply $::pgnviewer::_maxply($n) }
        if {$ply < 0 } { set ply 0 }
        set move [lindex $::pgnviewer::_game($n) $ply]
        lassign $move rav depth board nag comment san uci
        set move [lindex $::pgnviewer::_game($n) [expr $ply - 1]]
        lassign $move rav2 depth2 board2 nag2 comment2

        # look for clock info in comments
        set clocktime1 ""
        set clocktime2 ""
        set tomove [lindex [split $board] 1]
        set clkExp {.*?\[%clk\s*(.*?)\s*\].*}
        regexp $clkExp $comment -> clocktime1
        regexp $clkExp $comment2 -> clocktime2
        #TODO show clocktime from previous move when a variation is before
        if { $tomove == "b"} {
            set ::pgnviewer::_players($n)(clockW) $clocktime1
            set ::pgnviewer::_players($n)(clockB) $clocktime2
        } else {
            set ::pgnviewer::_players($n)(clockB) $clocktime1
            set ::pgnviewer::_players($n)(clockW) $clocktime2
        }

        ::board::setmarks $w.bd $comment
        set board [FENtoBoard $board]
        ::board::update $w.bd $board 0
        ::board::material $w.bd
        ::pgnviewer::update_current_move $w $n
        # Workaround for board.tcl
        if {$uci ne "" } { after [expr $::animateDelay + 5] ::pgnviewer::lastMoveHighlight $w.bd $n $uci $san \"$nag\" $ply \"$board\" }

        if {$::pgnviewer::autoplay($n)} {
            if {$::pgnviewer::_move($n) == $ply || $ply >= $::pgnviewer::_maxply($n)} {
                ::pgnviewer::autoplay $w $n
            } else {
                after cancel [list ::pgnviewer::update $w $n +1]
                after $::autoplayDelay [list ::pgnviewer::update $w $n +1]
            }
        }
        set ::pgnviewer::_move($n) $ply
        ::pgnviewer::ScoreUpdate $n
        ::enginewin::onPosChanged $::pgnviewer::_engine($n)
    }

    proc ::pgnviewer::autoplay {w n} {
        if {$::pgnviewer::autoplay($n)} {
            set ::pgnviewer::autoplay($n) 0
            $w.b.autoplay configure -image ::icon::tb_play
        } else {
            set ::pgnviewer::autoplay($n) 1
            $w.b.autoplay configure -image ::icon::tb_stop
            ::pgnviewer::update $w $n +1
        }
    }
    proc ::pgnviewer::mousewheelHandler {w n direction} {
        if {$direction < 0} {
            ::pgnviewer::update $w $n -1
        } else {
            ::pgnviewer::update $w $n +1
        }
    }
}
