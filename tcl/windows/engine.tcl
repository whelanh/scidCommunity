########################################################################
# Copyright (C) 2020-2026 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

### Window for chess engine configuration and position analysis

source [file join $::scidTclDir tools accuracy.tcl]

# Functions callable from outside:
# ::enginewin::listEngines
#   Return a list containing the engine's ID, name and running state.
# ::enginewin::start id ?enginename?
#   Start an engine (opens window if necessary).
# ::enginewin::stop id
#   Stop the engine.
# ::enginewin::toggleStartStop id ?enginename?
#   Toggle the running state of the engine.
# ::enginewin::Open id ?enginename?
#   Open a new engine window.
#
# Functions responding to events:
# ::enginewin::onNewGame id
#   Handles the <<NotifyNewGame>> event, flagging the engine to reset.
# ::enginewin::onPosChanged ?ids?
#   Sends the updated position to the active engines.

namespace eval enginewin {}

# Legacy depth and movetime values, shared across all engines. They are only a
# fallback now: search limits belong to the engine preset (tools/engine_limits.tcl)
# and each window keeps its own copy, so "Stockfish Deep" and "Stockfish Quick"
# can differ in the limit that matters most. Options written by an older version
# still load here and seed any preset that has no limits of its own.
if {![info exists ::enginewin::depth_limit]} {
    set ::enginewin::depth_limit ""
}
if {![info exists ::enginewin::movetime_limit]} {
    set ::enginewin::movetime_limit ""
}
::options.store ::enginewin::depth_limit
::options.store ::enginewin::movetime_limit

# Per-window limits, taken from the preset when the engine is opened.
if {![info exists ::enginewin::depth]} { array set ::enginewin::depth {} }
if {![info exists ::enginewin::movetime]} { array set ::enginewin::movetime {} }

# Flag to show save options reminder only once per session
set ::enginewin::limits_reminder_shown false

# Engine states:
# close.follow            -> No engine is open.
# close.follow.disconnect -> The engine was open, but the connection was terminated.
# ready.follow.pause      -> The engine is open and ready (paused).
# ready.follow.autorun    -> The engine is analyzing the current game.
# ready.follow.run        -> The engine is analyzing the current position.
# ready.follow.run.done   -> The engine has finished analyzing the current position.
# ready.follow.run.idle   -> The engine is idle after changing an option.
# ready.locked.run        -> The engine is analyzing a fixed position.
# ready.locked.run.done   -> The engine has finished analyzing a fixed position.
# ready.locked.run.idle   -> The engine is idle after changing an option.
array set ::enginewin::engState {}

# Return a list containing the engine's ID, engine's name and true if it is running.
# Return only the engines available for current position analysis.
proc ::enginewin::listEngines {} {
    lmap id [array names ::enginewin::engState] {
        set follow [::enginewin::stateFollow $id]
        if {!$follow && ![::enginewin::statePaused $id] || [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id)} { continue }
        list $id $::enginewin_lastengine($id) $follow
    }
}

# Handles <<NotifyNewGame>>. Schedule a NewGame msg for the engine.
# Seed the score graph from the evaluations the game already carries.
#
# A game from Lichess, from a previous review or from Ctrl+Shift+A knows its own
# scores; re-searching them costs time and replaces a stored score with a
# shallower guess. The seeded plies are also marked in the depth map, which is
# what ::enginewin::analyzeMainLine tests before it queues a position, so the
# Autorun pass only fills the gaps.
proc ::enginewin::seedChart {id} {
    # An embedded viewer shows a game the board does not hold: sc_move would read
    # the wrong game, so those windows are left to the engine pass.
    if {[info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id)} {
        return 0
    }
    set w .engineWin$id
    if {![winfo exists $w.chart.canvas]} { return 0 }
    set canvas $w.chart.canvas
    set ply0 0
    catch { set ply0 [sc_pos location] }
    set n 0
    catch { set n [expr {[llength $::enginewin::m_(mainLine,$id)] - 1}] }
    if {$n < 1} { return 0 }
    # The walk below is a main-line walk, but the board may not be on the main
    # line: the ply counter cannot describe a variation, and `sc_move ply` only
    # ever lands on the main line. So the whole cursor is saved before the first
    # move and restored after the last - see ::review::cursorSave.
    set cursor [::review::cursorSave]
    # The seeded plies are marked in their own map, not in the depth map: Autorun
    # tests for them so it does not re-search a stored score, but a manual search
    # still reaches updateChart's depth check and replaces the point, which a
    # marker of 100000 in the depth map would have blocked.
    upvar ::enginewin::pv_(seeded,$id) seeded
    upvar ::enginewin::pv_(depths,$id) depths
    if {![info exists depths]} { set depths [dict create] }
    set seeded [dict create]
    set count 0
    for {set i 1} {$i <= $n} {incr i} {
        if {[catch { sc_move ply $i }]} break
        if {[catch { sc_pos location } loc] || $loc != $i} break
        set cp [::seed::score [sc_pos getComment]]
        if {$cp eq ""} continue
        set side white
        catch { set side [sc_pos side] }
        set scoreside white
        catch { set scoreside $::enginewin::m_(scoreside,$id) }
        ::chart::setDataPoint $canvas $i [::seed::forSide $cp $side $scoreside] \
            [list ::enginewin::seedLabel]
        dict set seeded $i 1
        # A depth entry left by an earlier pass would gate a manual search at
        # this ply again, so it goes with the marker.
        if {[dict exists $depths $i]} { dict unset depths $i }
        incr count
    }
    # Every way out of the walk comes through here, a break included. 0 means
    # the variation could not be re-entered but the board is on the saved
    # main-line base - a known position, and not the absolute ply counter, which
    # points somewhere else entirely when the cursor was inside a variation.
    # Only -1 ("no position at all") needs the saved counter as a last resort.
    set restored 0
    catch { set restored [::review::cursorRestore $cursor] }
    if {$restored < 0} { catch { sc_move ply $ply0 } }
    # Accuracy means something only when the stored scores cover the game: the
    # chart carries a missing ply forward, so a handful of evaluations would be
    # averaged as if the line between them had been played.
    if {$count && [::seed::covers $seeded $n]} {
        set scores [::chart::getScores $canvas]
        if {[llength $scores] > 1} {
            lassign [::accuracy::calculate $scores] wAcc bAcc
            catch { ::chart::setAccuracy $canvas $wAcc $bAcc }
        }
    }
    return $count
}

# The chart calls a point's callback as {xIndex score}, so this takes exactly
# those two arguments; anything else raises on hover.
proc ::enginewin::seedLabel {ply score} {
    set mv [expr {($ply + 1) / 2}]
    set suffix [expr {$ply % 2 ? "." : "..."}]
    # A click calls the callback with an empty score, the way chartCallback
    # treats it: navigate to the ply instead of formatting a label. The label
    # itself is discarded by ::chart::_onClick, so it only has to be a string -
    # formatting an empty score would raise inside a Tk callback.
    if {$score eq ""} {
        catch {
            sc_move start
            sc_move forward $ply
            ::notify::PosChanged -pgn
        }
        return "$mv$suffix stored"
    }
    return "$mv$suffix stored\n[::seed::label $score]"
}

proc ::enginewin::onNewGame {id} {
    set ::enginewin::m_(newgame,$id) true
    ::stored_eval::clear $id
    ::rapid_annotate::onNewGame
    # A new game is a new main line: stop a pass over the old one, whichever
    # window started it. Its verdicts were being written into the game that is
    # going away.
    catch { ::enginewin::reviewStopAll }
    catch { ::enginewin::reviewRefresh $id }
    set w .engineWin$id
    if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
        set w .pv$::enginewin::pgnviewer($id).engineWin$id
    }
    if {[winfo exists $w.chart.canvas]} {
        set mainLine [sc_game UCI_mainLine]
        if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
            set mainLine [::pgnviewer::getMainline $::enginewin::pgnviewer($id)]
        }
        ::chart::clear $w.chart.canvas [expr {max(1, [llength $mainLine] - 1)}]
    }
}

# Sends the updated position to the active engines
proc ::enginewin::onPosChanged { {ids ""}} {
    set position ""
    foreach {id} [array names ::enginewin::engState] {
        if {![::enginewin::stateFollow $id]} { continue }
        if {$ids ne "" && $id ni $ids} { continue }
        if {$ids == $id && $::enginewin::pgnviewer($id) } {
            lassign [::pgnviewer::getPosition $::enginewin::pgnviewer($ids)] position ply
            if {[catch { ::enginewin::sendPosition $ids $position $ply }]} {
                ::enginewin::changeState $id paused.deceased
            }
            break
        } else {
            if {$position eq ""} {
                set position [sc_game UCI_currentPos]
                set ply [expr {[sc_var level] ? -1 : [sc_pos location]}]
            }
            if {[catch { ::enginewin::sendPosition $id $position $ply }]} {
                ::enginewin::changeState $id paused.deceased
            }
        }
    }
    # Update stored eval display for all engine windows
    foreach {id} [array names ::enginewin::engState] {
        set w .engineWin$id
        if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
            set w .pv$::enginewin::pgnviewer($id).engineWin$id
        }
        if {[winfo exists $w.stored_eval]} {
            ::enginewin::updateStoredEvalDisplay $id
        }
    }
    # A review's write phase ends with this notification: ::reviewdriver::run is
    # told -notify 1 by the window that started it, so the game has just been
    # written into and that window has to be given back (its status line and its
    # buttons). Guarded by the owner so every other position change is free.
    if {$::enginewin::reviewowner ne ""} {
        catch { ::enginewin::reviewRefreshAll }
    }
}

# Start an engine (if necessary it will opens a new enginewin window).
# Return the engine's id.
proc ::enginewin::start { {id ""} {enginename ""} {pgnviewer 0}} {
    if { $pgnviewer > 0 } {
        if { $id eq "" || ![winfo exists .pv$pgnviewer.engineWin$id]} {
            set id [::enginewin::Open $id $enginename $pgnviewer]
        } elseif {![::enginewin::statePaused $id]} {
            return $id
        }
    } elseif {$id eq "" || ![winfo exists .engineWin$id]} {
        set id [::enginewin::Open $id $enginename $pgnviewer]
    } elseif {![::enginewin::statePaused $id]} {
        return $id
    }
    ::enginewin::changeState $id follow.*
    ::enginewin::onPosChanged $id
    return $id
}

# Stop the engine.
# Return true if a StopGo message was sent to the engine.
proc ::enginewin::stop {id} {
    set w .engineWin$id
    if {[info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id)} {
        set w .pv$::enginewin::pgnviewer($id).engineWin$id
    }
    if {[winfo exists $w] &&
        ([::enginewin::stateFollow $id] || [::enginewin::stateLocked $id])} {
        ::enginewin::changeState $id paused.*
        ::engine::send $id StopGo
        return true
    }
    return false
}

# If the engine is running, stop it. Otherwise invoke ::enginewin::start
# Return the engine's id.
proc ::enginewin::toggleStartStop { {id ""} {enginename ""} } {
    if {[::enginewin::stop $id]} {
        return $id
    }
    set pgnviewer 0
    if {[info exists ::enginewin::pgnviewer($id)]} {
        set pgnviewer $::enginewin::pgnviewer($id)
    }
    return [::enginewin::start $id $enginename $pgnviewer]
}

# Whether the connection id belongs to someone other than an engine window. The
# review pass runs on a connection of its own (tools/review_driver.tcl), and
# ::engine::connect closes any connection that already holds the id it is given,
# so a window must not be opened on it.
proc ::enginewin::idReserved {id} {
    if {[llength [info commands ::reviewdriver::reservedId]]} {
        return [::reviewdriver::reservedId $id]
    }
    return 0
}

proc ::enginewin::Open { {id ""} {enginename ""} {pgnviewer 0} } {
    if {$id == ""} {
        set id 1
        if { $pgnviewer } {
            while {[info exists ::enginewin::pgnviewer($id)] || [::enginewin::idReserved $id]} {
                incr id
            }
        } else {
            while {[winfo exists .engineWin$id] || [::enginewin::idReserved $id]} {
                incr id
            }
        }
    }
    if { $pgnviewer } {
        set w .pv$pgnviewer.engineWin$id
        ttk::frame $w
    } else {
        set w .engineWin$id
        if {! [::win::createWindow $w ""]} {
            ::win::makeVisible $w
            return
        }
    }
    set ::enginewin::pgnviewer($id) $pgnviewer
    set ::enginewin::w($id) $w

    ::options.store ::enginewin_lastengine($id) ""
    ::options.store ::enginewin_autorun($id) {{movetime 50}}
    ::options.store ::enginewin_chartH($id) 160
    ::options.store ::enginewin_storedEvalH($id) 140

    # The main windows is divided in three parts:
    # - at the top $w.header_info which shows time, nps, etc...
    # - at the bottom the buttons bar
    # - in the middle $w.main which is further divided in parts:
    #   - $w.debug where all the engine's i/o is shown (can be hidden)
    #   - $w.display where the pv lines are shown
    #   - $w.chart where the evaluation chart is shown
    #   - right: $w.config with all the engine options (can be hidden)

    ttk::frame $w.header_info
    ttk_text $w.header_info.text -style Toolbutton -wrap word -height 1 -pady 2
    autoscrollBars y $w.header_info $w.header_info.text

    ttk::frame $w.main

    ttk::frame $w.config
    ttk::frame $w.config.btn
    ::enginecfg::createConfigButtons $id $w.config.btn
    bind $w.config.btn <<EngineCfgConnect>> "::enginewin::connectEngine {*}%d"
    ttk::frame $w.config.options
    ::enginecfg::createConfigOptions $id $w.config.options
    bind $w.config.options <<EngineCfgConnect>> "::enginewin::connectEngine {*}%d"
    bind $w.config.options <<EngineCfgLayout>> "::enginewin::changeDisplayLayout {*}%d"
    grid columnconfigure $w.config 0 -weight 1
    grid rowconfigure $w.config 1 -weight 1
    grid $w.config.btn
    grid $w.config.options -sticky news

    ttk::panedwindow $w.pane -orient vertical
    ttk::frame $w.stored_eval
    ::enginewin::createStoredEvalFrame $id $w.stored_eval
    $w.pane add $w.stored_eval -weight 1
    ttk::frame $w.debug
    ttk_text $w.debug.lines -state disabled
    autoscrollBars y $w.debug $w.debug.lines
    ttk::frame $w.display
    ::enginewin::createDisplayFrame $id $w.display
    $w.pane add $w.display -weight 2
    ttk::frame $w.chart
    ttk_canvas $w.chart.canvas -highlightthickness 0
    ::chart::init $w.chart.canvas {FONT font_Regular}
    grid $w.chart.canvas -sticky news
    grid rowconfigure $w.chart 0 -weight 1
    grid columnconfigure $w.chart 0 -weight 1
    $w.pane add $w.chart -weight 0
    bind $w.pane <Map>  [list apply {{id w} {
        update idletasks
        set npanes [llength [$w.pane panes]]
        set chartSash [expr {$npanes - 2}]
        $w.pane sashpos $chartSash \
            [expr {[winfo height $w.pane] - $::enginewin_chartH($id)}]
        set storedIdx [lsearch -exact [$w.pane panes] $w.stored_eval]
        $w.pane sashpos $storedIdx $::enginewin_storedEvalH($id)
    }} $id $w]
    bind $w.pane <ButtonRelease-1> [list apply {{id w} {
        set npanes [llength [$w.pane panes]]
        set n_sash [expr {$npanes - 2}]
        set ::enginewin_chartH($id) [expr {[winfo height $w.pane] - [$w.pane sashpos $n_sash]}]
        set storedIdx [lsearch -exact [$w.pane panes] $w.stored_eval]
        set ::enginewin_storedEvalH($id) [$w.pane sashpos $storedIdx]
    }} $id $w]

    grid $w.pane -row 0 -column 0 -in $w.main -sticky news
    grid $w.config -row 0 -column 1 -in $w.main -sticky news -padx {10 0}
    grid rowconfigure $w.main 0 -weight 1
    grid columnconfigure $w.main 0 -weight 1000
    grid columnconfigure $w.main 1 -weight 1

    ttk::frame $w.btn
    ::enginewin::createButtonsBar $id $w.btn $w.display

    grid $w.header_info -sticky news
    grid $w.main -sticky news
    grid $w.btn -sticky news
    grid rowconfigure $w 0 -weight 0
    grid rowconfigure $w 1 -weight 1
    grid rowconfigure $w 2 -weight 0
    grid columnconfigure $w 0 -weight 1

    bind $w <<NotifyNewGame>> "::enginewin::onNewGame $id"

    # Play the engine's best move with the spacebar (Lichess-style shortcut).
    # A custom bind tag is used because $w is a plain frame that can be docked
    # inside a notebook, in which case a binding on $w would not reach the
    # widgets inside the window.
    set ::enginewin::spaceTag($id) "EnginewinSpace$id"
    bind $::enginewin::spaceTag($id) <space> \
        "if {\[::enginewin::spaceKey $id %W\]} { break }"
    ::addBindtagToTree $w $::enginewin::spaceTag($id)

    # Ctrl+Shift+A writes the score graph and its annotations into the game
    # (see tools/rapid_annotate.tcl). Same custom-tag technique as <space>, so
    # the key works from any widget of the window, docked or not.
    # Shift is named explicitly: <Control-A> also matches Ctrl+A with Caps Lock
    # on. A docked window also reaches the main-window binding through the "."
    # bind tag, so the unconditional break stops the key being handled twice
    # (two message boxes) when commit has nothing to do.
    set ::enginewin::rapidTag($id) "EnginewinRapid$id"
    bind $::enginewin::rapidTag($id) <Control-Shift-A> \
        { excludeTextWidget %W ; ::rapid_annotate::commit ; break }
    ::addBindtagToTree $w $::enginewin::rapidTag($id)

    # The engine should be closed before the debug .text is destroyed
    bind $w.config <Destroy> [list apply {{id w} {
        if {![info exists ::enginewin::engState($id)]} { return }
        # The pass runs on its own connection, so closing the window would
        # otherwise leave it searching a game nothing shows any more - and
        # ::reviewdriver::busy would keep every other window from starting one.
        catch { ::enginewin::reviewCancel $id }
        ::stored_eval::cancelQuery $id
        ::stored_eval::clear $id
        unset ::enginewin::engState($id)
        ::engine::close $id
        array unset ::enginewin::m_ *,$id
        array unset ::enginewin::pv_ *,$id
        catch { unset ::enginecfg::engConfig_$id }
        catch { unset ::enginewin::spaceTag($id) }
        catch { unset ::enginewin::rapidTag($id) }
        unset ::enginewin::pgnviewer($id)
        ::notify::EngineBestMove $id {} {} {}
    }} $id $w]

    set ::enginewin::engState($id) {}
    set ::enginewin::m_(afterId,$id) {}
    set ::enginewin::m_(pvlines,$id) {}
    set ::enginewin::m_(position,$id) ""
    set ::enginewin::m_(posPly,$id) ""
    set ::enginewin::m_(mainLine,$id) ""
    set ::enginewin::m_(newgame,$id) true
    set ::enginewin::m_(startTime,$id) [clock milliseconds]
    set ::enginewin::m_(currentFen,$id) ""
    set ::enginewin::m_(currentPVs,$id) {}
    set ::enginewin::m_(currentDepth,$id) 0

    if {$enginename eq ""} {
        set enginename $::enginewin_lastengine($id)
    }
    # A slot that has never been used (or whose last engine was renamed or
    # deleted) has no remembered engine. Start the most recently used
    # configured engine instead of opening an empty engine window; if none are
    # configured, leave the config pane visible so the user can add one.
    if {$enginename eq "" || [::enginecfg::get $enginename] eq ""} {
        set enginename [lindex [::enginecfg::names] 0]
    }
    catch { ::enginewin::connectEngine $id $enginename }
    if {$enginename ne ""} {
        ::enginewin::toggleConfigPane $id hide
    }
    return $id
}

# Creates $w.display, where the pv lines sent by the engine will be shown.
proc ::enginewin::createDisplayFrame {id display} {
    set pv_lines $display.pv_lines
    ttk_text $pv_lines -exportselection true -padx 4 -state disabled
    autoscrollBars both $display $pv_lines

    set tab [font measure font_Regular -displayof $display "xxxxxxx"]
    $pv_lines configure -tabs [list [expr {$tab * 2}] right [expr {int($tab * 2.2)}]]
    $pv_lines tag configure lmargin -lmargin2 [expr {$tab * 3}]
    $pv_lines tag configure markmove -underline 1
    $pv_lines tag bind moves <ButtonRelease-1> {
        if {[%W tag ranges sel] eq ""} {
            ::enginewin::exportMoves %W @%x,%y
        }
    }
    $pv_lines tag bind moves <Motion> [list apply {{id} {
        set old_markmove [%W tag nextrange markmove 1.0]
        if {[%W tag ranges sel] ne ""} {
            destroy .enginewinBoard
            if {$old_markmove ne ""} { %W tag remove markmove {*}$old_markmove }
            return
        }
        # TODO:
        # Using wordstart and wordend would be a lot more efficient.
        # However they do not consider the [+.-] chars as part of the word.
        # set movestart [%W index "@%x,%y wordstart"]
        # %W tag add markmove $movestart "$movestart wordend"
        set movestart "[%W search -backwards -regexp {\s} "@%x,%y"] +1chars"
        # Limit the forward search to the current line: when the pv is the last
        # text on the line (e.g. the engine sent no node count or WDL info) there
        # is no trailing space and an unbounded search would wrap onto the next
        # line, highlighting the depth/score/first move of the following line.
        set moveend [%W search " " $movestart "$movestart lineend"]
        if {$moveend eq ""} { set moveend [%W index "$movestart lineend"] }
        set new_markmove [list [%W index $movestart] $moveend]
        if {$new_markmove eq $old_markmove} { return }

        if {$old_markmove ne ""} { %W tag remove markmove {*}$old_markmove }
        %W tag add markmove {*}$new_markmove
        after cancel $::enginewin::m_(afterId,$id)
        set ::enginewin::m_(afterId,$id) [after 10 [list apply {{id w} {
            # An exception will be thrown if the engine sent an illegal pv,
            # the tag was removed, the text widget is destroyed or not visible
            if {[catch {
                lassign [$w tag nextrange markmove 1.0] index
                set moves [::enginewin::getMoves $w $index]
                set pos [sc_pos board $::enginewin::m_(position,$id) $moves]
                lassign [$w bbox $index] x y width height
                set x [expr {$x + [winfo rootx $w] + $width}]
                incr y [winfo rooty $w]
                ::board::popup .enginewinBoard $pos $x $y $height
                ::board::flip .enginewinBoard.bd [main_isFlipped]
            }]} {
                destroy .enginewinBoard
            }
        }} $id %W]]
    }} $id]
    $pv_lines tag bind moves <Any-Leave> {
        %W tag remove markmove 1.0 end
        destroy .enginewinBoard
    }
}

# Creates $w.stored_eval, where stored evaluation results are shown.
proc ::enginewin::createStoredEvalFrame {id frame} {
    # $frame is already created (e.g., .engineWin1.stored_eval)
    # We just need to populate it with widgets
    
    ttk::label $frame.title -text "Stored Evaluations" -font font_Bold
    
    text $frame.text -exportselection true -padx 4 -state disabled -height 12 -wrap word
    $frame.text tag configure header -font font_Bold
    $frame.text tag configure pvnum -font font_Bold
    $frame.text tag configure score -font font_Bold -foreground "blue"
    $frame.text tag configure moves -font font_Regular
    autoscrollBars y $frame $frame.text
    
    grid $frame.title -sticky ew
    grid $frame.text -sticky news
    grid rowconfigure $frame 1 -weight 1
    grid columnconfigure $frame 0 -weight 1
}

# Update the stored eval display for the current board position.
proc ::enginewin::updateStoredEvalDisplay {id} {
    set w .engineWin$id
    if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
        set w .pv$::enginewin::pgnviewer($id).engineWin$id
    }
    if {![winfo exists $w.stored_eval]} { return }
    
    set fen [sc_pos fen]
    set fenKey [::stored_eval::fenKey $fen]
    set storedData [::stored_eval::get $id $fenKey]
    
    $w.stored_eval.text configure -state normal
    $w.stored_eval.text delete 1.0 end
    
    if {$storedData ne ""} {
        lassign $storedData depth source pvlines
        if {[llength $pvlines] > 0} {
            lassign [lindex $pvlines 0] multipv score score_type pv_uci
            set scoreStr $score
            if {$score_type eq "mate"} {
                set scoreStr [expr {$score >= 0 ? "+M$score" : "-M[expr {abs($score)}]"}]
            } else {
                set scoreStr [format "%+.2f" [expr {$score / 100.0}]]
            }
            # Update the evaluation bar with the best stored line.
            # Only the bar: the arrows belong to the engine and must survive
            # this refresh (the engine may already have stopped searching).
            ::updateMainEvalBarOnly $id $scoreStr
        }

        set formatted [::stored_eval::formatForDisplay $storedData $fen]
        foreach item $formatted {
            lassign $item tag text
            $w.stored_eval.text insert end $text $tag
        }
    } else {
        # No stored data - query Lichess
        $w.stored_eval.text insert end "Querying Lichess..." header
        # Clear only the evaluation bar while waiting for Lichess/Engine.
        # Do not touch the engine's best-move arrows.
        ::updateMainEvalBarOnly $id ""
        ::stored_eval::queryLichessAsync $id $fen ::enginewin::onLichessResult
    }
    
    $w.stored_eval.text configure -state disabled
}

# Callback when a Lichess cloud eval query completes.
proc ::enginewin::onLichessResult {id fen result} {
    if {$result ne ""} {
        lassign $result depth pvlines
        set fenKey [::stored_eval::fenKey $fen]
        ::stored_eval::store $id $fenKey $depth "lichess" $pvlines
        # Refresh the display only if the board is still on the queried
        # position. A late reply for an earlier position must not restart
        # (or clear) the query for the current one.
        if {[::stored_eval::fenKey [sc_pos fen]] eq $fenKey} {
            ::enginewin::updateStoredEvalDisplay $id
        }
    }
}

# Creates the buttons bar
proc ::enginewin::createButtonsBar {id btn display} {
    ttk::button $btn.startStop -image [list [::button_image tb_eng_on] pressed [::button_image tb_eng_off] user1 [::button_image tb_eng_off]] \
        -style Toolbutton -command "::enginewin::toggleStartStop $id"
    #TODO: change the tooltip to "Start/stop engine"
    ::utils::tooltip::Set $btn.startStop [tr StartEngine]

    ttk::button $btn.lock -image [::button_image tb_eng_lock] -style Toolbutton -command [list apply {{id} {
        if {[::enginewin::stateLocked $id]} {
            ::enginewin::changeState $id follow.*
            ::enginewin::onPosChanged $id
        } elseif {[::enginewin::stateFollow $id]} {
            ::enginewin::changeState $id locked.*
        }
    }} $id]
    ::utils::tooltip::Set $btn.lock [tr LockEngine]

    set pv_lines $display.pv_lines
    ttk::button $btn.addbestmove -image [::button_image tb_eng_addbestmove] -style Toolbutton \
        -command "::enginewin::exportMoves $pv_lines 1.0"
    ::utils::tooltip::Set $btn.addbestmove [tr AddMove]
    ttk::button $btn.addlines -image [::button_image tb_eng_addlines] -style Toolbutton \
        -command "::enginewin::exportLines $pv_lines"
    ::utils::tooltip::Set $btn.addlines [tr AddAllVariations]

    # Plays the rest of the game out with the engines chosen in its dialog. The
    # pass runs on its own connections, so it never takes this window's engine.
    ttk::button $btn.finish -image [::button_image tb_finish_off] -style Toolbutton \
        -command [list ::enginewin::finishGame $id]
    ::utils::tooltip::Set $btn.finish [tr FinishGame]
    if {[info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id)} {
        $btn.finish configure -state disabled
    }

    ttk::spinbox $btn.multipv -increment 1 -width 4 -state disabled \
        -validate key -validatecommand [list ::validate::integer %P 0] \
        -command "after idle \[bind $btn.multipv <FocusOut>\]"
    bind $btn.multipv <Return> { {*}[bind %W <FocusOut>] }
    bind $btn.multipv <FocusOut> "::enginewin::changeOption $id multipv $btn.multipv"
    ::utils::tooltip::Set $btn.multipv [tr Lines]

    menu $btn.menus
    ttk::menubutton $btn.overflow -text "..." -style Toolbutton \
        -direction above -menu $btn.menus

    menu $btn.menus.threads
    foreach {threads_value} {1 2 4 6 8 12 16 32 64} {
        $btn.menus.threads add command -label "$threads_value CPU" -command \
            "::enginewin::changeOption $id threads $threads_value"
    }
    #TODO: change keyboard focus to the threads widget
    $btn.menus.threads add command -label "..." -command \
        "::enginewin::toggleConfigPane $id threads"
    ttk::menubutton $btn.threads -text "1 CPU" -state disabled \
        -style Toolbutton -direction above -menu $btn.menus.threads

    menu $btn.menus.hash
    foreach {hash_value} {16 64 256 1024 2048 4096 8192} {
        $btn.menus.hash add command -label "$hash_value MB" -command \
            "::enginewin::changeOption $id hash $hash_value"
    }
    $btn.menus.hash add command -label "..." -command \
        "::enginewin::toggleConfigPane $id hash"
    ttk::menubutton $btn.hash -text "?? MB" -state disabled \
        -style Toolbutton -direction above -menu $btn.menus.hash

    ttk::label $btn.depth_label -text "[tr Depth]:" -style Toolbutton
    ttk::entry $btn.depth -textvariable ::enginewin::depth($id) -width 6 -justify right \
        -validate key -validatecommand {expr {[string is integer %P] || [string length %P] == 0}}
    bind $btn.depth <Return> "::enginewin::applyLimits $id"
    bind $btn.depth <FocusOut> "::enginewin::applyLimits $id"
    ::utils::tooltip::Set $btn.depth "Search depth limit (leave empty for unlimited)"

    ttk::label $btn.movetime_label -text "[tr TimeMs]:" -style Toolbutton
    ttk::entry $btn.movetime -textvariable ::enginewin::movetime($id) -width 8 -justify right \
        -validate key -validatecommand {expr {[string is integer %P] || [string length %P] == 0}}
    bind $btn.movetime <Return> "::enginewin::applyLimits $id"
    bind $btn.movetime <FocusOut> "::enginewin::applyLimits $id"
    ::utils::tooltip::Set $btn.movetime "Move time limit in milliseconds (leave empty for unlimited)"

    menu $btn.menus.autorun
    $btn.menus.autorun add radiobutton -label "Off" -value {{}} -variable ::enginewin_autorun($id)
    foreach {ms} {10 25 50 100 250 500 1000} {
        $btn.menus.autorun add radiobutton -variable ::enginewin_autorun($id) \
            -label "$ms ms" -value [list [list movetime $ms]]
    }
    ttk::style configure AutorunButton.Toolbutton
    ttk::style map EnginewinAuto.Toolbutton -foreground {user1 #FF5E0E}
    ttk::menubutton $btn.autorun -text "\u601D" \
        -style EnginewinAuto.Toolbutton -direction above -menu $btn.menus.autorun

    ttk::button $btn.config -image [::button_image tb_eng_config] -style Toolbutton \
        -command "::enginewin::toggleConfigPane $id"
    $btn.config state pressed

    ttk::button $btn.gamereview -text [::reviewui::label ReviewGameButton] \
        -command [list ::enginewin::reviewGame $id]
    ::utils::tooltip::Set $btn.gamereview [::reviewui::label ReviewGameButtonTooltip]

    ttk::button $btn.movecomment -text [::reviewui::label ReviewMoveButton] \
        -command [list ::enginewin::reviewMove $id]
    ::utils::tooltip::Set $btn.movecomment [::reviewui::label ReviewMoveButtonTooltip]

    ttk::button $btn.reviewsettings -text [::reviewui::label ReviewSettings] \
        -command [list ::enginewin::reviewSettings $id]
    ::utils::tooltip::Set $btn.reviewsettings [::reviewui::label ReviewSettings]

    # Live only while a pass runs: a pass has its own engine connection and the
    # only thing the user can do with it is stop it.
    ttk::button $btn.reviewcancel -text [tr Cancel] \
        -command [list ::enginewin::reviewCancel $id]
    set ::enginewin::reviewstatus($id) ""
    ttk::label $btn.reviewstatus -textvariable ::enginewin::reviewstatus($id) \
        -anchor w

    grid $btn.startStop $btn.lock $btn.addbestmove $btn.addlines $btn.finish \
         $btn.multipv $btn.depth_label $btn.depth $btn.movetime_label $btn.movetime \
         $btn.autorun $btn.threads $btn.hash \
         $btn.overflow x $btn.gamereview $btn.movecomment $btn.reviewsettings \
         $btn.reviewcancel $btn.reviewstatus $btn.config -sticky ew
    grid columnconfigure $btn 13 -weight 1
    grid remove $btn.overflow

    set collapsible [dict create autorun "Autoscan" threads "CPUs" hash "Hash"]
    bind $btn <Configure> [list ::collapseMenubuttons %W overflow $collapsible]
    ::enginewin::reviewRefresh $id
}

########################################################################
### Game Review and Move Comment
###
### Two buttons over one engine pass. The pass (::reviewdriver) runs on its own
### connection, so neither button disturbs the analysis the user is watching.
### ::reviewdriver::run is the whole of it: it snapshots the main line, searches
### the positions, turns the replies into verdicts and writes them into the game
### with ::review::writeMove - labels, [%eval] and variations - and puts the board
### back where the reader left it. This window decides nothing about that; it asks
### ::reviewui::runCall what to call, calls it, and shows ::reviewdriver::status.
###
### Everything decided here is decided in tcl/tools/review_ui.tcl, where a tclsh
### test can reach it. The glue below is guarded: no widget, no engine, no
### driver, no pass - and no error in the middle of a game.
########################################################################

array set ::enginewin::reviewstatus {}
array set ::enginewin::reviewsetting {}
# The window that started the pass in flight. One run exists at a time (the
# driver refuses a second), so the Cancel button and the status line belong to
# whoever started it, and to no other engine window.
set ::enginewin::reviewowner ""

# The toplevel of this engine's window: an embedded PGN viewer's engine window
# lives under the viewer, not at .engineWin.
proc ::enginewin::reviewWindow {id} {
    if {[info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id)} {
        return .pv$::enginewin::pgnviewer($id).engineWin$id
    }
    return .engineWin$id
}

# The pass state this window is in, as ::reviewui::buttons wants it: "" unless
# this window started the run that is in flight.
proc ::enginewin::reviewPass {id} {
    variable reviewowner
    if {$reviewowner ne $id} { return "" }
    if {[llength [info commands ::reviewdriver::status]] == 0} { return "" }
    set state ""
    catch { set state [dict get [::reviewdriver::status] state] }
    if {$state eq "searching" || $state eq "writing"} { return $state }
    return ""
}


# The facts ::reviewui::buttons needs, read from the window and the board.
proc ::enginewin::reviewState {id} {
    set state [dict create game 0 engine "" pass "" move ""]
    # An embedded PGN viewer shows a game the main board does not hold, and the
    # review reads the board's game: not offered there rather than reviewing
    # something the window is not showing.
    if {[info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id)} {
        return $state
    }
    # The engine this window analyses with. Its preset is where Threads, Hash and
    # MultiPV come from (::review::effective reads them from there), so the pass
    # is configured from the same one the window shows.
    set name ""
    catch { set name $::enginewin_lastengine($id) }
    if {$name ne ""} { dict set state engine $name }
    dict set state pass [::enginewin::reviewPass $id]
    if {[catch { set map [::review::mainLineMap [sc_game UCI_mainLine]] }]} {
        return $state
    }
    dict set state game [dict get $map plies]
    # Move Comment labels the move the reader is on - the one that produced this
    # position - so the start of the line has nothing to offer while the last
    # move does. Inside a variation the move indexes mean something else: the
    # pass covers the main line, so the button is disabled there.
    if {[llength [info commands sc_var]] && [sc_var level] == 0} {
        if {![catch { set here [sc_pos location] }]} {
            catch {
                set ply [::reviewui::moveCommentPly $map $here]
                if {$ply ne ""} {
                    dict set state move [::review::playedMove $map $ply]
                }
            }
        }
    }
    return $state
}

# Put the bar in the state ::reviewui::buttons says it is in. Never touches the
# status line: the pass owns that.
proc ::enginewin::reviewRefresh {id} {
    set w [::enginewin::reviewWindow $id]
    if {![winfo exists $w.btn.gamereview]} { return }
    set b [::reviewui::buttons [::enginewin::reviewState $id]]
    # -state, not `state`: ttk's state subcommand takes flags (disabled,
    # !disabled), while ::reviewui answers in the widget-state vocabulary.
    catch { $w.btn.gamereview configure -state [dict get $b review] }
    catch { $w.btn.movecomment configure -state [dict get $b movecomment] }
    catch { $w.btn.reviewcancel configure -state [dict get $b cancel] }
}

# The book Game Review reads: the one loaded in the Book window's first slot,
# else the book configured as #1. "" when there is neither.
proc ::enginewin::reviewBook {} {
    set name ""
    if {[info exists ::book::currentBook1] && $::book::currentBook1 ne ""} {
        set name $::book::currentBook1
    } elseif {[info exists ::book::lastBook1]} {
        set name $::book::lastBook1
    }
    if {$name eq ""} { return "" }
    set dir ""
    catch { set dir $::scidBooksDir }
    if {$dir ne "" && [file dirname $name] eq "."} {
        set name [file join $dir $name]
    }
    return $name
}

# The state ::reviewui::runCall decides from: the open game, the preset this
# window analyses with, and what this build's driver offers.
#
# `plies` is the moves to judge ("" for the whole planned line) and `depth` the
# depth to search ("" to let the pass take the review's own).
proc ::enginewin::reviewRunState {id {plies ""} {depth ""}} {
    set state [dict create game 0 engine "" driver 0 bookEnd 0 plies $plies depth $depth \
        progress [list ::enginewin::reviewProgress $id] notify 1]
    if {[llength [info commands ::reviewdriver::run]]} { dict set state driver 1 }
    set name ""
    catch { set name $::enginewin_lastengine($id) }
    if {$name ne ""} {
        catch { dict set state engine [::enginecfg::get $name] }
    }
    catch {
        dict set state game [dict get [::review::mainLineMap [sc_game UCI_mainLine]] plies]
    }
    # Game Review leaves the opening to the book: the moves up to the book end
    # are written as [Book], not judged. Move Comment names the move it wants,
    # so it asks for nothing here.
    if {![llength $plies]} {
        set skip 1
        catch { set skip [::review::get skip_book] }
        if {$skip} {
            set book [::enginewin::reviewBook]
            if {$book ne ""} {
                set end 0
                # allBook 1: a game that stays in the book is all book, and
                # every move of it is labelled rather than judged.
                catch { set end [::review::bookEnd $book 5 1] }
                if {$end > 0} { dict set state bookEnd $end }
            }
        }
    }
    return $state
}

# Show what the driver's state says, for the window that started the pass.
# Never raises: it is called from a progress callback and from the notification
# that ends the write phase.
proc ::enginewin::reviewStatus {id} {
    variable reviewowner
    if {$reviewowner ne $id} { return }
    if {[llength [info commands ::reviewdriver::status]] == 0} { return }
    set text ""
    catch { set text [::reviewui::statusText [::reviewdriver::status]] }
    if {![info exists ::enginewin::reviewstatus($id)]} {
        set ::enginewin::reviewstatus($id) ""
    }
    set ::enginewin::reviewstatus($id) $text
    # A run that is over hands the window back: another press must be able to
    # start one, and another window may start its own.
    if {[::enginewin::reviewPass $id] eq ""} { set reviewowner "" }
}

# Start the run the decision names. "" when nothing started, which is not an
# error: the status line has already said why.
proc ::enginewin::reviewStart {id state} {
    variable reviewowner
    set w [::enginewin::reviewWindow $id]
    if {![winfo exists $w.btn.gamereview]} { return "" }
    set call [::reviewui::runCall $state]
    if {[dict get $call entry] eq ""} {
        set ::enginewin::reviewstatus($id) \
            [::reviewui::failedText [dict get $call reason]]
        ::enginewin::reviewRefresh $id
        return ""
    }
    # The window owns the pass only from the moment it has one: a refused start
    # must not take a run that is already in flight away from the window that
    # started it, and the driver's refusals include exactly that case (a second
    # press while a pass is searching).
    set entry [dict get $call entry]
    set err [catch { $entry {*}[dict get $call args] } why]
    if {$err} {
        set why "the review could not start: $why"
    }
    if {$why ne ""} {
        # ::reviewdriver::run answers a refusal in words instead of raising: no
        # engine, an engine that cannot be opened, a pass already running. The
        # last is another window's run, so nothing here is claimed and nothing
        # there is given up - only the refusing window says why.
        set ::enginewin::reviewstatus($id) [::reviewui::failedText $why]
        ::enginewin::reviewRefresh $id
        return ""
    }
    # The run is in flight and this window started it.
    set reviewowner $id
    # Nothing to search is a run that finished (a book cover, an empty plan):
    # the driver says so, and there is nothing left to show.
    ::enginewin::reviewStatus $id
    ::enginewin::reviewRefresh $id
    return 1
}

# Game Review: the whole main line, from where the plan says to start.
#
# bookEnd is 0: the pass starts at the first move. Asking a book where the game
# leaves it would be a second search before the first, and ::review::startPly
# already knows what to do with the answer once something supplies it.
# Finish Game: play the rest of the game out. The dialog and the pass live in
# tools/finish_game.tcl; while a pass is running the same button cancels it.
proc ::enginewin::finishGame {id} {
    if {[llength [info commands ::finishgame::dialog]] == 0} { return }
    # A PGN viewer's engine has its own game; sc_pos/sc_game are the main
    # board's, so the pass would play into the wrong game.
    if {[info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id)} {
        return
    }
    if {$::finishgame::active} {
        ::finishgame::stop
        return
    }
    ::finishgame::dialog $id
    return
}

proc ::enginewin::reviewGame {id} {
    set w [::enginewin::reviewWindow $id]
    if {![winfo exists $w.btn.gamereview]} { return }
    if {[catch { set map [::review::mainLineMap [sc_game UCI_mainLine]] }]} { return }
    ::enginewin::reviewStart $id [::enginewin::reviewRunState $id]
}

# Move Comment: the move the reader is on, and only that move.
#
# Two positions, the one before the move and the one after it, because a verdict
# needs both scores: what the move was worth and what it brought. The depth comes
# from moveCommentDepth - if the window's own analysis has already reached the
# review's depth, comment from that and wait for nothing; otherwise search at the
# review's depth.
proc ::enginewin::reviewMove {id} {
    set w [::enginewin::reviewWindow $id]
    if {![winfo exists $w.btn.movecomment]} { return }
    if {[catch { set map [::review::mainLineMap [sc_game UCI_mainLine]] }]} { return }
    if {[catch { set here [sc_pos location] }]} { return }
    if {[llength [info commands sc_var]] && [sc_var level] != 0} { return }
    set ply [::reviewui::moveCommentPly $map $here]
    if {$ply eq ""} { return }
    # The position BEFORE the commented move: the pass searches it first, and the
    # window's depth map is keyed by it. Writing at `ply` puts the label and
    # [%eval] after the move, and a diagram before it.
    set from [expr {$ply - 1}]
    # What the window has already reached for that position: the depth map the
    # Autorun pass fills in. A missing entry is "nothing yet".
    set depth_now ""
    if {[info exists ::enginewin::pv_(depths,$id)]} {
        set depths $::enginewin::pv_(depths,$id)
        if {[dict exists $depths $from]} { set depth_now [dict get $depths $from] }
    }
    # The depth the review would search at, which is the preset's own floor when
    # that is deeper than the setting: a comment has to agree with a review, or
    # the same move gets two verdicts at two depths.
    set target ""
    set name ""
    catch { set name $::enginewin_lastengine($id) }
    if {$name ne ""} {
        catch { set target [dict get [::review::effective [::enginecfg::get $name]] depth] }
    }
    set plan [::reviewui::moveCommentDepth $depth_now $target]
    ::enginewin::reviewStart $id [::enginewin::reviewRunState $id \
        [list $ply] [dict get $plan depth]]
}

# Cancel: the pass stops where it is, and the write phase never runs - the driver
# writes only once the whole search has finished - so nothing is written.
#
# Only the window that started the pass stops it: an engine window closing is not
# a reason to throw away a review another window is running.
proc ::enginewin::reviewCancel {id} {
    variable reviewowner
    # Only the window that started the pass may stop it. A run started outside
    # the window - annotate mode calls the same driver - belongs to no window,
    # and closing one must not cancel it.
    if {$reviewowner ne $id} { return }
    catch { ::reviewdriver::cancel }
    set reviewowner ""
    if {[info exists ::enginewin::reviewstatus($id)]} {
        set ::enginewin::reviewstatus($id) ""
    }
    catch { ::enginewin::reviewRefresh $id }
}

# The game changed under the board. A pass reads a snapshot of it, so whatever was
# running is writing into a game that is gone: stop it, whichever window started
# it, and take every window's status line back with it.
proc ::enginewin::reviewStopAll {} {
    variable reviewowner
    # The cursor the pass saved belongs to the game that is going away: restoring
    # it would move the board to that ply in the new game.
    catch { ::reviewdriver::cancel 0 }
    set reviewowner ""
    foreach id [array names ::enginewin::engState] {
        if {[info exists ::enginewin::reviewstatus($id)]} {
            set ::enginewin::reviewstatus($id) ""
        }
        catch { ::enginewin::reviewRefresh $id }
    }
}

# The driver's progress callback: {*}[list ::enginewin::reviewProgress $id] <done>
# <total>. The counts are already in ::reviewdriver::status, so all this does is
# put them on the status line.
proc ::enginewin::reviewProgress {id done total} {
    ::enginewin::reviewStatus $id
    catch { ::enginewin::reviewRefresh $id }
}

# The board changed under every window, which is how a finished review announces
# itself: the driver asks for this notification (-notify 1) once the write phase
# has ended, and the window that started the pass has to be given back.
proc ::enginewin::reviewRefreshAll {} {
    foreach id [array names ::enginewin::engState] {
        catch { ::enginewin::reviewStatus $id }
        catch { ::enginewin::reviewRefresh $id }
    }
}

# The settings dialog: the five settings the pass's own decisions read.
#
# Threads and Hash are deliberately not here. They belong to the engine preset
# (#382) and are set from the window's own controls; the dialog shows what the
# preset carries, read-only, so the numbers are visible where the review's are.
proc ::enginewin::reviewSettings {id} {
    set w [::enginewin::reviewWindow $id].reviewSettings
    if {[winfo exists $w]} {
        raise $w
        return
    }
    set name ""
    catch { set name $::enginewin_lastengine($id) }
    # What the rows' notes read: the preset this window has open. A window with no
    # engine yet has no preset, and a note then stays empty rather than guessing.
    set ::enginewin::reviewsetcfg($id) {}
    catch { set ::enginewin::reviewsetcfg($id) [::enginecfg::get $name] }
    toplevel $w
    # The ttk widgets inside follow the theme, but a toplevel keeps Tk's
    # classic background, and the button row does not cover the window's width:
    # the strip beside OK/Cancel stayed light grey on every dark theme. Paint
    # the window itself with the theme's colour and follow a theme change.
    catch { ::applyThemeColor_background $w }
    wm title $w [::reviewui::label ReviewSettings]
    catch { wm transient $w [::enginewin::reviewWindow $id] }
    ttk::frame $w.f -padding 10
    grid $w.f -sticky news
    set row 0
    foreach key [::reviewui::settingKeys] {
        lassign [::reviewui::settingRange $key] lo hi
        set ::enginewin::reviewsetting($id,$key) [::review::get $key]
        ttk::label $w.f.l$key -text "[::reviewui::settingLabel $key]:" -anchor w
        ttk::spinbox $w.f.v$key -from $lo -to $hi -increment 1 -width 6 \
            -textvariable ::enginewin::reviewsetting($id,$key)
        grid $w.f.l$key -row $row -column 0 -sticky w -pady 2
        grid $w.f.v$key -row $row -column 1 -sticky w -padx {10 0} -pady 2
        # Kept per key so a row can be revisited: the time cap's note is a third
        # column of the row the setting is on.
        set rowOf($key) $row
        incr row
    }
    # var_lines is capped by mpv, so its box follows the mpv box while the user
    # edits: opening with MultiPV 3 and raising it to 5 has to offer 4 and 5
    # lines without closing the dialog. The range comes from ::reviewui, which
    # also lowers a var_lines the new mpv no longer allows.
    if {[winfo exists $w.f.vmpv] && [winfo exists $w.f.vvar_lines]} {
        # trace add returns nothing, so the prefix itself is what has to be
        # kept: trace remove needs the same command it was given, or the trace
        # stays behind on a closed dialog and every reopen adds another.
        set ::enginewin::reviewtraceptr($id) [list apply {{id w args} {
            set mpv $::enginewin::reviewsetting($id,mpv)
            if {![string is integer -strict $mpv]} { return }
            set hi [lindex [::reviewui::settingRange var_lines $mpv] 1]
            catch { $w.f.vvar_lines configure -to $hi }
            catch {
                if {$::enginewin::reviewsetting($id,var_lines) > $hi} {
                    set ::enginewin::reviewsetting($id,var_lines) $hi
                }
            }
        }} $id $w]
        trace add variable ::enginewin::reviewsetting($id,mpv) write \
            $::enginewin::reviewtraceptr($id)
        bind $w <Destroy> [list apply {{id w} {
            if {"%W" ne $w} { return }
            catch {
                trace remove variable ::enginewin::reviewsetting($id,mpv) write \
                    $::enginewin::reviewtraceptr($id)
            }
            unset -nocomplain ::enginewin::reviewtraceptr($id)
        }} $id $w]
    }

    # The time cap's note, on its own row: a review value of 0 means "no cap of my
    # own", and the pass then runs on the engine preset's Limits.movetime. The
    # note follows the box while the user types, exactly as the variation box
    # follows mpv, so the dialog never claims a bound the pass would not use - and
    # never leaves a box reading 0 while the preset imposes a cap.
    if {[winfo exists $w.f.vmovetime]} {
        set ::enginewin::reviewsettingnote($id) ""
        ttk::label $w.f.nmovetime -textvariable ::enginewin::reviewsettingnote($id) \
            -anchor w
        grid $w.f.nmovetime -row $rowOf(movetime) -column 2 -sticky w -padx {10 0} -pady 2
        # The prefix, not its return value (trace add answers nothing), so the
        # trace can be removed by the same command that installed it. `args`
        # swallows the three arguments a variable trace appends (name, element,
        # op) - a lambda that does not take them fails at the first edit.
        set ::enginewin::reviewnotetr($id) [list apply {{id args} {
            set note ""
            catch {
                set note [::reviewui::movetimeNote \
                    $::enginewin::reviewsetting($id,movetime) \
                    $::enginewin::reviewsetcfg($id)]
            }
            set ::enginewin::reviewsettingnote($id) $note
        }} $id]
        trace add variable ::enginewin::reviewsetting($id,movetime) write \
            $::enginewin::reviewnotetr($id)
        # And once for the state the dialog opens in.
        {*}$::enginewin::reviewnotetr($id)
        # Appended, not replaced: the mpv row above already bound <Destroy> on
        # this same toplevel, and Tcl's `bind` REPLACES a binding unless the
        # script starts with "+". Replacing it left the mpv trace installed for
        # good, and every reopen stacked another one on a dialog already gone.
        bind $w <Destroy> +[list apply {{id w} {
            if {"%W" ne $w} { return }
            catch {
                trace remove variable ::enginewin::reviewsetting($id,movetime) write \
                    $::enginewin::reviewnotetr($id)
            }
            unset -nocomplain ::enginewin::reviewnotetr($id)
            unset -nocomplain ::enginewin::reviewsettingnote($id)
            unset -nocomplain ::enginewin::reviewsetcfg($id)
        }} $id $w]
    }

    set note ""
    if {$name ne ""} {
        catch { set note [::reviewui::presetNote [::enginecfg::get $name]] }
    }
    if {$note ne ""} {
        ttk::label $w.f.preset -text $note -anchor w
        grid $w.f.preset -row $row -column 0 -columnspan 2 -sticky w -pady {8 0}
        incr row
    }
    # A refusal is shown here rather than in a message box: the dialog stays open
    # on the value that was refused, so it can be corrected without losing the
    # rest of the edit. The variable exists before the label names it.
    set ::enginewin::reviewwhy($id) ""
    ttk::label $w.f.why -textvariable ::enginewin::reviewwhy($id) -anchor w
    grid $w.f.why -row $row -column 0 -columnspan 2 -sticky w -pady {8 0}
    incr row
    ttk::frame $w.b
    grid $w.b -row $row -column 0 -columnspan 2 -sticky e -pady {10 0}
    ttk::button $w.b.ok -text [tr OK] \
        -command [list ::enginewin::reviewSettingsApply $id $w]
    ttk::button $w.b.cancel -text [tr Cancel] -command [list destroy $w]
    grid $w.b.ok $w.b.cancel -padx 4
    catch { grab $w }
    return $w
}

proc ::enginewin::reviewSettingsApply {id w} {
    if {![winfo exists $w]} { return }
    set values [dict create]
    foreach key [::reviewui::settingKeys] {
        if {[info exists ::enginewin::reviewsetting($id,$key)]} {
            dict set values $key $::enginewin::reviewsetting($id,$key)
        }
    }
    set why [::reviewui::applySettings $values]
    if {[llength $why]} {
        set ::enginewin::reviewwhy($id) [join $why "; "]
        return
    }
    destroy $w
    ::enginewin::reviewRefresh $id
}

# Apply depth and movetime limits and restart engine if running
proc ::enginewin::applyLimits {id} {
    # A half-typed number must not reach the preset: put the stored values back.
    if {![::enginelimits::valid depth $::enginewin::depth($id)] ||
        ![::enginelimits::valid movetime $::enginewin::movetime($id)]} {
        ::enginewin::loadLimits $id
        return
    }
    # Limits belong to the engine preset, so they follow that engine everywhere
    # and no longer need a separate "Save Options" step.
    set name $::enginewin_lastengine($id)
    set lim [list depth $::enginewin::depth($id) movetime $::enginewin::movetime($id)]
    if {[::enginelimits::saveFor $name $lim] && !$::enginewin::limits_reminder_shown} {
        set ::enginewin::limits_reminder_shown true
        tk_messageBox -title "scidCommunity" -type ok -icon info \
            -message "The depth and time limits are now saved with the engine preset \"$name\"."
    }

    # If engine is running, restart it with new limits
    set state $::enginewin::engState($id)
    if {[string match *.run $state] || [string match *.autorun $state]} {
        # Stop and restart with new limits
        ::engine::send $id StopGo
        set position [sc_game UCI_currentPos]
        set ply [expr {[sc_var level] ? -1 : [sc_pos location]}]
        ::enginewin::sendPosition $id $position $ply
    }
}

# Show or hide the configuration pane for a specific engine window.
# Show can be "hide", "" (toggle), or the name of an option
proc ::enginewin::toggleConfigPane {id {show ""}} {
    set w .engineWin$id
    if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
        set w .pv$::enginewin::pgnviewer($id).engineWin$id
    }
    set isVisible [expr {[grid info $w.config] ne ""}]
    if {$show eq "" && $isVisible} { set show "hide" }

    if {$show eq "hide"} {
        $w.btn.config state !pressed
        grid remove $w.config
    } else {
        $w.btn.config state pressed
        grid $w.config
        if {$show ne ""} {
            ::enginecfg::focusOption $id $w.config.options $show
        }
    }
}

proc ::enginewin::changeDisplayLayout {id param value} {
    set w .engineWin$id
    if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
        set w .pv$::enginewin::pgnviewer($id).engineWin$id
    }
    switch $param {
        "debug" {
            ::enginewin::logEngine $id $value
        }
        "notation" -
        "scoreside" {
            set ::enginewin::m_($param,$id) $value
        }
        "wrap" {
            $w.display.pv_lines configure -wrap $value
        }
    }
}

proc ::enginewin::logEngine {id on} {
    set w .engineWin$id
    if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
        set w .pv$::enginewin::pgnviewer($id).engineWin$id
    }
    catch { $w.pane forget $w.debug }
    $w.debug.lines configure -state normal
    $w.debug.lines delete 1.0 end
    $w.debug.lines configure -state disabled
    if {$on} {
        $w.pane insert 0 $w.debug -weight 1
        ::engine::setLogCmd $id \
            [list ::enginewin::updateDebug $id $w.debug.lines "" ""]\
            [list ::enginewin::updateDebug $id $w.debug.lines header ">>"]
    } else {
        ::engine::setLogCmd $id "" ""
    }
}

# Determine whether it is Black to move in a given UCI "position" string.
# Returns {isBlackToMove plyCount}.
proc ::enginewin::blackToMove {uci_pos} {
    set idx [string first "moves" $uci_pos]
    if {$idx < 0} {
        set n 0
    } else {
        set t [string range $uci_pos $idx end]
        set n [expr {[string length $t] - [string length [string map {{ } {}} $t]]}]
        set uci_pos [string range $uci_pos 0 $idx]
    }
    if {[string first "fen" $uci_pos] >= 0 && [string first "w" $uci_pos] < 0} {
        set base 1
    } else {
        set base 0
    }
    return [list [expr {($base + $n) % 2 == 1}] $n]
}

# Checks if the given UCI position appears within the main line of moves.
# ply_pos: the number of plies contained in uci_pos.
# Returns a list of all the plies where the position appears in the main line.
# or an empty list if not found. Multiple matches are possible due to null moves.
proc ::enginewin::inMainLine {main_line uci_pos ply_pos {acc {}}} {
    set match [string last $uci_pos [join $main_line]]
    if {$match == -1} {
        return $acc
    }
    if {$match == 0} {
        return [lappend acc $ply_pos]
    }
    set pre_ply 0
    set i 0
    while {$i < $match} {
        incr i [expr {[string length [lindex $main_line $pre_ply]] + 1}]
        incr pre_ply
    }
    tailcall inMainLine [lrange $main_line 0 [expr {$pre_ply - 1}]] \
        $uci_pos $ply_pos [lappend acc [expr {$pre_ply + $ply_pos}]]
}

proc ::enginewin::formatPV {notation position pv} {
    set translated untranslated
    if {$notation > 0} {
        set pv [sc_pos coordToSAN $position $pv]
    }
    if {$notation == 1 || $notation == -1} {
        set pv [::trans $pv]
        set translated translated
    } elseif {$notation == 3 || $notation == -3} {
        set pv [string map {K "\u2654" Q "\u2655" R "\u2656" B "\u2657" N "\u2658"} $pv]
    }
    return [list $pv $translated]
}

proc ::enginewin::updateDebug {id widget tag prefix msg} {
    set t [format "(%.3f) " \
        [expr {( [clock milliseconds] - $::enginewin::m_(startTime,$id) ) / 1000.0}]]
    $widget configure -state normal
    $widget insert end "$t[set prefix]$msg\n" $tag
    $widget see end
    $widget configure -state disabled
}

proc ::enginewin::updateChart {id {msgData ""}} {
    if {[set ::enginewin_chartH($id)] < 10} { return }

    set w .engineWin$id
    if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
        set w .pv$::enginewin::pgnviewer($id).engineWin$id
    }

    lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time score score_type score_wdl pv
    if {$multipv != 1 || $score eq ""} { return }

    upvar ::enginewin::pv_(depths,$id) depths
    set plies [lmap elem $::enginewin::pv_(ply,$id) {
        if {[dict exists $depths $elem] && $depth < [dict get $depths $elem]} { continue }
        set elem
    }]
    if {$plies eq ""} { return }

    # Keep the evaluations for ::rapid_annotate (Ctrl+Shift+A) before the
    # display conversions below rewrite the score.
    ::rapid_annotate::record $id $plies $depth $score $score_type $pv

    if {$::enginewin::m_(scoreside,$id) eq "white" && $::enginewin::pv_(btm,$id)} {
        set score [expr { - $score }]
    }
    if {$score_type eq "mate"} {
        set score [expr {$score * 100000}]
    }

    foreach ply $plies {
        dict set depths $ply $depth
        ::chart::setDataPoint $w.chart.canvas $ply $score \
            [list ::enginewin::chartCallback $id $::enginewin::pv_(pos,$id) $depth $seldepth]
    }

    set canvas $w.chart.canvas
    set currentScores [::chart::getScores $canvas]
    if {[llength $currentScores] > 1} {
        lassign [::accuracy::calculate $currentScores] wAcc bAcc
        ::chart::setAccuracy $canvas $wAcc $bAcc
    }

}
proc ::enginewin::chartCallback {id uci_pos depth seldepth ply value} {
    if {$value eq "" } {
        # Navigate to the clicked ply in the main line
        sc_move start
        sc_move forward $ply
        # Trigger position change notifications for engine and stored eval
        ::notify::PosChanged -pgn
        return ""
    }
    if {$ply == 0} {
        set txt ""
    } else {
        set move [lindex $uci_pos end]
        if {[catch {
            lassign [::enginewin::formatPV $::enginewin::m_(notation,$id) [lrange $uci_pos 0 end-1] $move] txt
        }]} {
            set moveNum [expr {($ply + 1) / 2}]
            set suffix  [expr {$ply % 2 ? "." : "..."}]
            set txt "$moveNum$suffix$move"
        }
    }
    if {abs($value) < 100000} {
        set value [format {%+.2f} [expr {$value / 100.0}]]
    } else {
        set value "#[format {%+d} [expr {$value / 100000}]]"
    }
    if {$seldepth ne ""} { set depth "$depth/$seldepth" }
    return "$txt\n$value\n$depth"
}

proc ::enginewin::updateDisplay {id msgData} {
    lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time score score_type score_wdl pv
    if {$time eq ""} { set time 0 }
    if {$nps eq ""} { set nps 0 }
    if {$hashfull eq ""} { set hashfull 0 }
    if {$tbhits eq ""} { set tbhits 0 }

    set w .engineWin$id
    if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
        set w .pv$::enginewin::pgnviewer($id).engineWin$id
    }
    $w.header_info.text configure -state normal
    $w.header_info.text delete 1.0 end
    $w.header_info.text insert end "[tr Time]: " header
    $w.header_info.text insert end [format "%.2f s" [expr {$time / 1000.0}]]
    $w.header_info.text insert end "   [tr Nodes]: " header
    $w.header_info.text insert end [format "%.2f Kn/s" [expr {$nps / 1000.0}]]
    $w.header_info.text insert end "   Hash: " header
    $w.header_info.text insert end [format "%.1f%%" [expr {$hashfull / 10.0}]]
    $w.header_info.text insert end "   TB Hits: " header
    $w.header_info.text insert end $tbhits
    $w.header_info.text configure -state disabled

    set pv_lines $w.display.pv_lines
    $pv_lines configure -state normal
    if {$msgData eq ""} {
        $pv_lines delete 1.0 end
        $pv_lines configure -state disabled
        # Clear stored PV lines for multi-arrow display
        set ::enginewin::m_(pvlines,$id) {}
if {[array exists ::enginewin::pvBestMove]} {
    foreach key [array names ::enginewin::pvBestMove "$id,*"] {
        unset ::enginewin::pvBestMove($key)
    }
}
        return
    }

    set notation $::enginewin::m_(notation,$id)
    set scoreside $::enginewin::m_(scoreside,$id)

    set pvDisplay $pv
    # Limit the length of each PV line according to the user preference
    # (the preference is expressed in moves; 1 move = 2 plies).
    if {[info exists ::enginePvDisplayLength] && $::enginePvDisplayLength > 0} {
        set pvDisplay [lrange $pvDisplay 0 [expr {$::enginePvDisplayLength * 2 - 1}]]
    }
    if {[catch {
        lassign [::enginewin::formatPV $notation $::enginewin::pv_(pos,$id) $pvDisplay] pvDisplay translated
    }]} {
        set pvDisplay "illegal_pv! $pvDisplay"
        set translated untranslated
    }

    set scoreStr $score
    if {$scoreStr ne ""} {
        if {$scoreside eq "white" && $::enginewin::pv_(btm,$id)} {
            set scoreStr [expr { - $scoreStr }]
        }
        if {$score_type eq "mate"} {
            if {$scoreStr >= 0} {
                set scoreStr "+M$scoreStr"
            } else {
                set scoreStr "-M[string range $scoreStr 1 end]"
            }
        } else {
            set scoreStr [format "%+.2f" [expr {$scoreStr / 100.0}]]
            if {$score_type eq "lowerbound" || $score_type eq "upperbound"} {
                lappend extraInfo $score_type
            }
        }
    }
    set depthStr $depth
    if {$seldepth ne ""} {
        set depthStr "$depthStr/$seldepth"
    }
    if {$score_wdl ne ""} {
        lassign $score_wdl win draw lose
        if {$draw eq ""} { set draw 0 }
        if {$lose eq ""} { set lose 0 }
        lappend extraInfo [format "W: %.1f%%" [expr {$win / 10.0}]]
        lappend extraInfo [format "D: %.1f%%" [expr {$draw / 10.0}]]
        lappend extraInfo [format "L: %.1f%%" [expr {$lose / 10.0}]]
    }
    if {$nodes ne ""} {
        if {$nodes > 100000000} {
            lappend extraInfo [format "%.2fM nodes" [expr {$nodes / 1000000.0}]]
        } else {
            lappend extraInfo [format "%.2fK nodes" [expr {$nodes / 1000.0}]]
        }
    }
    set pvline ""
    # End of the first move: first space after the first alpha char
    regexp {^(.*?[A-Za-z].*?)(\s.*)$} $pvDisplay -> pvDisplay pvline

    set line $multipv
    if {$multipv == 1} {
        # Previous line nr. 1 is now obsolete
        $pv_lines tag remove header 1.0 1.end
    }
    # If the engine has repeatedly sent multipv 1, do not delete the obsolete lines
    catch { $pv_lines tag nextrange header 2.0 } multilines
    if {$line > 1 || $multilines ne ""} {
        # Multipv lines >= than the current one are now obsolete and deleted.
        $pv_lines delete $line.0 end
    }
    $pv_lines insert $line.0 "\n"
    $pv_lines insert $line.end "$depthStr\t"
    $pv_lines insert $line.end "$scoreStr" header
    $pv_lines insert $line.end "\t"
    $pv_lines insert $line.end "$pvDisplay" [list header moves $translated]
    $pv_lines insert $line.end "$pvline" [list lmargin moves]
    if {[info exists extraInfo]} {
        $pv_lines insert $line.end "  ([join $extraInfo {  }])" lmargin
    }
    $pv_lines configure -state disabled

    # Accumulate raw PV data for stored eval cache
    if {$pv ne ""} {
        set depthNum $depth
        if {![string is integer -strict $depthNum]} { set depthNum 0 }
        set pvEntry [list $multipv $score $score_type $pv]
        if {$multipv == 1} {
            set ::enginewin::m_(currentPVs,$id) [list $pvEntry]
            set ::enginewin::m_(currentDepth,$id) $depthNum
        } else {
            lappend ::enginewin::m_(currentPVs,$id) $pvEntry
        }
    }

    # Extract best move (UCI format) from raw PV for arrow display
    set best_move [lindex [split $pv] 0]

    # show bestmove for first three multipv
    if {$line < 4 && ![::enginewin::stateLocked $id]} {
        if { $line == 1 } {
            set ::enginewin::scorePV1($id) $scoreStr
        } elseif { $::enginewin::scorePV1($id) ne "" && $scoreStr ne "" && \
                   [string index $::enginewin::scorePV1($id) 1] ne "M" && [string index $scoreStr 1] ne "M" && \
                   [catch {expr { abs($::enginewin::scorePV1($id) - $scoreStr) }} diff] == 0 && \
                   $diff > $::informant(+/-) } {
            set scoreStr ""
            set best_move ""
        }
        if {$scoreside eq "engine" && $::enginewin::pv_(btm,$id) && $scoreStr ne ""} {
            set sign_reversed [expr { [string index $scoreStr 0] eq "+" ? "-" : "+" }]
            set scoreStr "$sign_reversed[string range $scoreStr 1 end]"
        }
        if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
            ::pgnviewer::EngineBestMove $::enginewin::pgnviewer($id) $id $scoreStr $best_move [::enginewin::getEngineColor 1 $line]
        } else {
            set ::enginewin::pvBestMove($id,$multipv) $best_move
            if {$multipv == 1} {
                foreach key [array names ::enginewin::pvBestMove $id,*] {
                    if {$key ne "$id,1"} { unset ::enginewin::pvBestMove($key) }
                }
            }
set allMoves {}
for {set pv 1} {$pv <= 3} {incr pv} {
    if {[info exists ::enginewin::pvBestMove($id,$pv)]} {
        lappend allMoves $::enginewin::pvBestMove($id,$pv)
    }
}
set notifyScore $scoreStr
if {$multipv != 1 && [info exists ::enginewin::scorePV1($id)]} {
    set notifyScore $::enginewin::scorePV1($id)
}
::notify::EngineBestMove $id $best_move $notifyScore $allMoves
        }
    }
}

# Take the search limits (and autorun cadence) from the engine's preset.
# Any key the preset leaves unset falls back to the legacy global settings.
proc ::enginewin::loadLimits {id {name ""}} {
    if {$name eq ""} {
        set name $::enginewin_lastengine($id)
    }
    set fallback [list depth $::enginewin::depth_limit \
                       movetime $::enginewin::movetime_limit]
    set lim [::enginelimits::forName $name $fallback]
    set ::enginewin::depth($id) [dict get $lim depth]
    set ::enginewin::movetime($id) [dict get $lim movetime]
    if {[dict get $lim autorun] ne ""} {
        # The Autorun menu's radio values are one-element lists; the variable
        # must have the same shape or the menu shows no selection.
        set ::enginewin_autorun($id) [list [list movetime [dict get $lim autorun]]]
    }
    return $lim
}

# Invoked when the engine's name changes.
# Update the window's title and ::enginewin_lastengine accordingly.
proc ::enginewin::updateEngineName {id name} {
    set ::enginewin_lastengine($id) $name
    ::enginewin::loadLimits $id $name
    set w .engineWin$id
    if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
        set w .pv$::enginewin::pgnviewer($id).engineWin$id
    }
    ::setTitle $w "[tr Engine]: $name"
    event generate $w.config.btn <<UpdateEngineName>> -data [list $name]
}

proc ::enginewin::updateOptions {id msgData} {
    set w .engineWin$id
    if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
        set w .pv$::enginewin::pgnviewer($id).engineWin$id
    }
    if {$msgData eq ""} {
        $w.btn.multipv set ""
        $w.btn.multipv configure -state disabled
        $w.btn.threads configure -state disabled -text "1 CPU"
        $w.btn.hash configure -state disabled -text "?? MB"
        return
    }
    lassign $msgData protocol netclients options
    for {set i 0} {$i < [llength $options]} {incr i} {
        lassign [lindex $options $i] name value type default min max var_list internal
        if {$internal || $type in [list button save reset]} { continue }

        if {[string equal -nocase $name "multipv"] && $min ne "" && $max ne ""} {
            $w.btn.multipv configure -state normal -from $min -to $max -style {}
            $w.btn.multipv set $value
        } elseif {[string equal -nocase $name "threads"]} {
            $w.btn.threads configure -state normal -text "$value CPU"
        } elseif {[string equal -nocase $name "hash"]} {
            $w.btn.hash configure -state normal -text "$value MB"
        }
    }
}

# Retrieve the moves at the line specified by index.
# An index linenumber.0 can be used to retrive just the first move.
# An index linenumber.end can be used to retrive all the moves.
# If index is not valid an exception is raised.
proc ::enginewin::getMoves {w index} {
    lassign [$w tag nextrange moves "$index linestart"] begin end
    # Constrain the forward search to the current line. If the pv is the last
    # text on the line (e.g. the engine sent no node count or WDL info) there is
    # no trailing space; an unbounded search would wrap onto the next line and
    # return moves mixed with the depth/score of the following line, which would
    # make the last move impossible to select. In that case fall back to the end
    # of the moves range ($end) so the whole line (including the last move) is used.
    if {[regexp {^\d+\.0$} $index]} {
        set space [$w search " " $begin "$begin lineend"]
        if {$space ne ""} { set end $space }
    } elseif {![regexp {^\d+\.end$} $index]} {
        set space [$w search " " $index "$index lineend"]
        if {$space ne ""} { set end $space }
    }
    if {[$w tag nextrange translated $begin $end] eq ""} {
        set moves [$w get $begin $end]
    } else {
        set moves [::untrans [$w get $begin $end]]
    }
    return [string map {"\u2654" K "\u2655" Q "\u2656" R "\u2657" B "\u2658" N} $moves]
}

# Add the moves to the current game
# An index linenumber.0 can be used to add just the first move.
# An index linenumber.end can be used to add all the moves.
# Return false if index is not valid.
proc ::enginewin::exportMoves {w index} {
    # A finish pass is playing the game; a move added by hand would make the
    # position the pass is waiting on stale.
    if {[info exists ::finishgame::active] && $::finishgame::active} { return false }
    if {[catch {::enginewin::getMoves $w $index} line]} {
        return false
    }
    set before [list [sc_pos location] [sc_game info previous]]
    ::undoFeature save
    catch {sc_game import $line}
    # sc_game import reports errors in its result instead of raising, so check
    # whether the position actually changed. If nothing was imported, do not
    # touch the board or notify the engines.
    if {[list [sc_pos location] [sc_game info previous]] eq $before} {
        return false
    }
    ::notify::PosChanged -pgn
    return true
}

# Handle a <space> keypress in an engine window.
# Return true if the key was consumed (the caller then stops the binding chain).
proc ::enginewin::spaceKey {id widget} {
    if {![spaceTriggersEngineMove $widget]} { return false }
    ::enginewin::playBestMove $id
    return true
}

# Play the engine's best move (the first move of the first PV line) in the
# current game. This is the action bound to the spacebar in engine windows,
# and matches Lichess' behaviour. In multiPV mode only the best line is used.
# Return true if the move was successfully added.
proc ::enginewin::playBestMove {id} {
    if {[info exists ::finishgame::active] && $::finishgame::active} { return false }
    set w .engineWin$id
    if {[info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id)} {
        set w .pv$::enginewin::pgnviewer($id).engineWin$id
    }
    if {![winfo exists $w]} { return false }
    # Only act while the engine is actually analyzing a position. Otherwise
    # the stored best move / display may be stale (e.g. after the engine was
    # stopped), and playing it would disturb the board or restart the engine.
    if {![info exists ::enginewin::engState($id)]} { return false }
    if {![::enginewin::stateFollow $id] && ![::enginewin::stateLocked $id]} { return false }
    # Prefer the raw UCI best move: it is independent of the display notation
    # and of non-move prefixes in the PV text.
    if {[info exists ::enginewin::pvBestMove($id,1)] && $::enginewin::pvBestMove($id,1) ne ""} {
        if {[catch {::addMoveUCI $::enginewin::pvBestMove($id,1)} ok] == 0 && $ok} {
            return true
        }
    }
    # Fall back to the first move shown in the PV display.
    return [::enginewin::exportMoves $w.display.pv_lines 1.0]
}

# Add all the move lines to the current game.
proc ::enginewin::exportLines {w} {
    if {[info exists ::finishgame::active] && $::finishgame::active} { return }
    set i_line 1
    set location [sc_move pgn]
    while {![catch {::enginewin::getMoves $w $i_line.end} line]} {
        # When multipv is 1, the old lines are also shown, but do not export them
        lassign [$w tag nextrange header "$i_line.end linestart"] is_latest
        if {$is_latest eq ""} { break }
        if {$i_line == 1} { ::undoFeature save }
        catch {sc_game import $line}
        sc_move pgn $location
        incr i_line
    }
    ::notify::PosChanged pgnonly
}

# Sends a SetOptions message to the engine if an option's value is different.
proc ::enginewin::changeOption {id name widget_or_value} {
    set restart [expr {[::enginewin::stateFollow $id] || [::enginewin::stateLocked $id]}]
    set idx [::enginecfg::findOption $id $name]
    if {[winfo exists $widget_or_value]} {
        set changed [::enginecfg::setOptionFromWidget $id $idx $widget_or_value]
    } else {
        set changed [::enginecfg::setOption $id $idx $widget_or_value]
    }
    if {$changed && $restart} {
        set ply [expr {[sc_var level] ? -1 : [sc_pos location]}]
        ::enginewin::sendPosition $id $::enginewin::m_(position,$id) $ply
    }
}

# Sets the current state of the engine and updates the relevant buttons.
# The first part is the USER-REQUESTED MODE:
#    - paused:   The engine is not analyzing
#    - follow:   The engine analyzes the current board position
#    - locked:   The engine remains fixed on a specific position
# The second part is the ENGINE STATUS:
#    - closed:   The engine process is not running (connection closed)
#    - deceased: The engine process terminated unexpectedly
#    - idle:     The engine is idle and waiting for a task
#    - done:     The engine has completed its assigned task (e.g., reached the depth/time limit).
#    - run:      The engine is currently analyzing
#
# | engState             | startStop | lock | addbestmove | addlines | limits |
# |----------------------|-----------|------|-------------|----------|--------|
# | paused.closed        | D         | D    | D           | D        | D      |
# | paused.deceased      | D         | D    | D           | D        | D      |
# | paused.idle          |           | D    |             |          |        |
# | follow.idle          | U         |      |             |          |        |
# | follow.done          | U         |      |             |          | P      |
# | follow.run           | P         |      |             |          |        |
# | follow.done.autorun  | P         |      |             | P        | P      |
# | follow.idle.autorun  | P         |      |             | P        |        |
# | locked.run           | P         | P    |             |          |        |
# | locked.idle          | U         | P    |             |          |        |
# | locked.done          | U         | P    |             |          | P      |
#
# newState can contain "*" as a placeholder for the old corresponding part.
proc ::enginewin::changeState {id newState} {
    # Handle pattern with * placeholder
    if {[string first * $newState] >= 0} {
        set newState [join [lmap new [split $newState .] old [split $::enginewin::engState($id) .] {
            set v [expr {$new eq "*" ? $old : $new}]
            expr {$v eq "" ? [continue] : $v}
        }] .]
    }

    if {$::enginewin::engState($id) eq $newState} { return }

    set buttons {
        btn.addbestmove {}
        btn.addlines    {}
        btn.autorun     {*autorun user1   * !user1}
        btn.lock        {l* pressed   * !pressed}
        btn.startStop   {p* {!pressed !user1}   *run {pressed !user1}   * {!pressed user1}}
    }
    set w .engineWin$id
    if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
        set w .pv$::enginewin::pgnviewer($id).engineWin$id
    }
    set closed [string match *sed $newState]
    foreach {btn btnspec} $buttons {
        if {$closed} {
            $w.$btn configure -state disabled
            $w.$btn state {!pressed !user1}
        } else {
            $w.$btn configure -state normal
            foreach {p s} $btnspec {
                if {[string match $p $newState]} {
                    $w.$btn state $s
                    break
                }
            }
        }
    }

    if {![string match f* $newState]} {
        if {[string match p* $newState]} {
            $w.btn.lock configure -state disabled
        }
        ::chart::moveCursorLine $w.chart.canvas ""
        # Mirror cursor hide to PGN viewer chart
        if {$::enginewin::pgnviewer($id)} {
            set pvCanvas .pv$::enginewin::pgnviewer($id).c
            if {[winfo exists $pvCanvas]} { ::chart::moveCursorLine $pvCanvas "" }
        }
        if { $::enginewin::pgnviewer($id) } {
            ::pgnviewer::EngineBestMove $::enginewin::pgnviewer($id) $id "" "" [::enginewin::getEngineColor 1 1]
            ::pgnviewer::EngineBestMove $::enginewin::pgnviewer($id) $id "" "" [::enginewin::getEngineColor 1 2]
            ::pgnviewer::EngineBestMove $::enginewin::pgnviewer($id) $id "" "" [::enginewin::getEngineColor 1 3]
        } else {
if {[array exists ::enginewin::pvBestMove]} {
    foreach key [array names ::enginewin::pvBestMove "$id,*"] {
        unset ::enginewin::pvBestMove($key)
    }
}
            ::notify::EngineBestMove $id "" "" {}
            ::notify::EngineBestMove $id "" "" {}
            ::notify::EngineBestMove $id "" "" {}
        }
    } elseif {$::enginewin::engState($id) in {paused.idle paused.closed}} {
        ::enginewin::toggleConfigPane $id hide
    }
    set ::enginewin::engState($id) $newState
    # An engine that has just started, stopped or died changes what the review
    # buttons can do. Guarded: the window may not have its bar yet.
    catch { ::enginewin::reviewRefresh $id }
}

proc ::enginewin::stateFollow {id} {string match f* $::enginewin::engState($id)}
proc ::enginewin::stateLocked {id} {string match l* $::enginewin::engState($id)}
proc ::enginewin::statePaused {id} {string match p* $::enginewin::engState($id)}

proc ::enginewin::getEngineColor {id pv} {
    array set color {
        1 "#ff0000"  2 "#ff4000"  3 "#ff4040"
        4 "#00ff00"  5 "#40ff00"  6 "#40ff40"
        7 "#0000ff"  8 "#4000ff"  9 "#4040ff"
       10 "#ffff00" 11 "#ffff40" 12 "#ffff80"
    }
    set id [expr {($id-1) * 3 + $pv}]
    if { $id > 12 } { set id 1 }
    return $color($id)
}

# If any, closes the connection with the current engine.
# If "config" is not "" opens a connection with a new engine.
proc ::enginewin::connectEngine {id enginename} {
    ::engine::close $id
    ::stored_eval::clear $id
    ::enginewin::updateDisplay $id ""
    ::enginewin::updateOptions $id ""
    ::enginewin::changeState $id paused.closed

    set ::enginewin::pv_(depths,$id) [dict create]
    # The seeded markers belong to the same chart as the depths: a new engine
    # must not inherit them, or Autorun would skip a ply nothing has searched.
    set ::enginewin::pv_(seeded,$id) [dict create]
    set ::enginewin::pv_(pos,$id) ""
    set ::enginewin::pv_(limits,$id) ""
    set ::enginewin::pv_(btm,$id) 0
    set ::enginewin::pv_(ply,$id) ""
    set ::enginewin::pv_(postponed,$id) ""

    set config [::enginecfg::get $enginename]
    lassign $config name cmd args wdir elo time _ uci options
    ::enginewin::updateEngineName $id $name

    set configFrame .engineWin$id.config.options
    if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
        set configFrame .pv$::enginewin::pgnviewer($id).engineWin$id.config.options
    }
    set netport [::enginecfg::resetConfigOptions $id $configFrame $config]

    if {$config eq ""} { return }
    
    # Save accumulated PVs from the previous session before clearing
    ::enginewin::saveAccumulatedPVs $id

    update idletasks

    switch $uci {
      0 { set protocol "xboard" }
      1 { set protocol [list uci xboard] }
      2 { set protocol "network" }
      default { set protocol [list uci xboard] }
    }
    if {[catch {
        if {$wdir != "" && $wdir != "."} {
            set oldwdir [pwd]
            cd $wdir
        }
        ::engine::connect $id [list ::enginewin::callback $id] $cmd $args $protocol
        if {[info exists oldwdir]} {
            cd $oldwdir
        }
    } errorMsg]} {
        return [::enginewin::callback $id [list InfoDisconnected [list $errorMsg]]]
    }

    if {[catch { ::enginecfg::setupNetd $id $netport }]} {
        ERROR::MessageBox
    }

    if {[llength $options]} {
        ::engine::send $id SetOptions $options
    }
    # Send a NewGame message to receive InfoReady when the engine completes the initialization.
    ::engine::send $id NewGame [list {}]
    # But also schedule a NewGame message, that depends on the position, when the engine starts.
    set ::enginewin::m_(newgame,$id) true
}

# Receive the engine's messages
proc ::enginewin::callback {id msg} {
    variable pv_
    set configFrame .engineWin$id.config.options
    if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
        set configFrame .pv$::enginewin::pgnviewer($id).engineWin$id.config.options
    }
    lassign $msg msgType msgData
    switch $msgType {
        "InfoConfig" {
            ::enginewin::updateOptions $id $msgData
            set renamed [::enginecfg::updateConfigOptions $id $configFrame $msgData]
            if {$renamed ne ""} {
                ::enginewin::updateEngineName $id $renamed
            }
            ::enginewin::changeState $id *.idle
        }
        "InfoGo" {
            lassign $msgData pv_(pos,$id) pv_(limits,$id)
            lassign [blackToMove $pv_(pos,$id)] pv_(btm,$id) n_ply
            if {$::enginewin::m_(posPly,$id) ne "" && $pv_(pos,$id) eq $::enginewin::m_(position,$id)} {
                set pv_(ply,$id) $::enginewin::m_(posPly,$id)
                if {$pv_(ply,$id) < 0} { set pv_(ply,$id) "" }
                set ::enginewin::m_(posPly,$id) ""
                ::enginewin::changeState $id *.run
                set cw .engineWin$id
                if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
                    set cw .pv$::enginewin::pgnviewer($id).engineWin$id
                }
                ::chart::moveCursorLine $cw.chart.canvas $pv_(ply,$id)
                # Mirror cursor to PGN viewer chart
                if {[info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id)} {
                    set pvCanvas .pv$::enginewin::pgnviewer($id).c
                    if {[winfo exists $pvCanvas]} { ::chart::moveCursorLine $pvCanvas $pv_(ply,$id) }
                }
            } else {
                ::enginewin::changeState $id *.*.autorun
                set pv_(ply,$id) [inMainLine $::enginewin::m_(mainLine,$id) $pv_(pos,$id) $n_ply]
            }
        }
        "InfoPV" {
            if {$pv_(pos,$id) eq $::enginewin::m_(position,$id)} {
                ::enginewin::updateDisplay $id $msgData
            }
            ::enginewin::updateChart $id $msgData
        }
        "InfoBestMove" {
            # The limits this search was started with
            set expectedLimits [::enginelimits::goLimits \
                [list depth $::enginewin::depth($id) movetime $::enginewin::movetime($id)]]
            if {$pv_(limits,$id) eq $expectedLimits
                && $pv_(pos,$id) eq $::enginewin::m_(position,$id)} {
                ::enginewin::saveAccumulatedPVs $id
                ::enginewin::changeState $id *.done
            }
            if {![::enginewin::analyzeMainLine $id]} {
                ::enginewin::changeState $id *.*
                if {$pv_(postponed,$id) ne ""} {
                    ::enginewin::sendPosition $id $::enginewin::m_(position,$id) $pv_(postponed,$id)
                }
            }
        }
        "InfoReady" {
            ::enginecfg::autoSaveConfig $id $configFrame true
            ::enginewin::saveAccumulatedPVs $id
            ::enginewin::changeState $id *.idle
            # Trigger initial stored eval lookup for current position
            after idle [list ::enginewin::updateStoredEvalDisplay $id]
        }
        "InfoDisconnected" {
            ::enginewin::updateOptions $id ""
            ::enginecfg::autoSaveConfig $id $configFrame false
            ::enginecfg::updateConfigOptions $id $configFrame {}
            ::enginewin::changeState $id paused.deceased
            lassign $msgData errorMsg
            if {$errorMsg eq ""} {
                set errorMsg "The connection with the engine terminated unexpectedly."
            }
            tk_messageBox -icon warning -type ok -parent . -message $errorMsg
        }
    }
}

# Save the accumulated engine PV data for multi-arrow display.
# Called before sending a new position or when the engine stops.
proc ::enginewin::saveAccumulatedPVs {id} {
    set fen $::enginewin::m_(currentFen,$id)
    if {$fen eq ""} { return }

    set pvs $::enginewin::m_(currentPVs,$id)
    if {[llength $pvs] == 0} { return }

    set line1Depth $::enginewin::m_(currentDepth,$id)
    if {$line1Depth == 0} { return }

    # UCI engines report scores from side-to-move's perspective.
    # Normalize to White's perspective (matching Lichess convention).
    set sideToMove [lindex [split $fen] 1]
    if {$sideToMove eq "b"} {
        set normalizedPVs {}
        foreach pv $pvs {
            lassign $pv multipv score score_type pv_uci
            set score [expr {-$score}]
            lappend normalizedPVs [list $multipv $score $score_type $pv_uci]
        }
        set pvs $normalizedPVs
    }

    # Store the PVs in the stored_eval database
    set fenKey [::stored_eval::fenKey $fen]
    ::stored_eval::store $id $fenKey $line1Depth "engine" $pvs

    # Clear accumulated data
    set ::enginewin::m_(currentPVs,$id) {}
    set ::enginewin::m_(currentDepth,$id) 0
}

# Sends a position to an engine.
# When the engine replies with an InfoGo message the state will change to "run".
proc ::enginewin::sendPosition {id position plyInMainLine} {
    variable m_
    # Save accumulated PVs for the previous position before clearing
    ::enginewin::saveAccumulatedPVs $id
    
    set ::enginewin::pv_(postponed,$id) ""
    ::enginewin::updateDisplay $id ""
    # Clear stored PV lines for multi-arrow display
    set ::enginewin::m_(pvlines,$id) {}
    set ::enginewin::m_(currentPVs,$id) {}
    set ::enginewin::m_(currentDepth,$id) 0
    if {$m_(newgame,$id)} {
        set m_(newgame,$id) false
        ::engine::send $id NewGame [list analysis post_pv post_wdl [sc_game variant]]
        set oldMainLine [expr {[info exists m_(mainLine,$id)] ? $m_(mainLine,$id) : ""}]
        set m_(mainLine,$id) [sc_game UCI_mainLine]
        if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
            set m_(mainLine,$id) [::pgnviewer::getMainline $::enginewin::pgnviewer($id)]
        }
        set w .engineWin$id
        if { [info exists ::enginewin::pgnviewer($id)] && $::enginewin::pgnviewer($id) } {
            set w .pv$::enginewin::pgnviewer($id).engineWin$id
        }
        if {$oldMainLine eq ""} {
            ::chart::clear $w.chart.canvas [expr {[llength $m_(mainLine,$id)] - 1}]
        }
        # Mirror disabled: the embedded engine window handles chart/display.
        # if {$::enginewin::pgnviewer($id)} {
        #     set pvN $::enginewin::pgnviewer($id)
        #     set pvCanvas .pv$pvN.c
        #     if {[winfo exists $pvCanvas]} {
        #         ::chart::clear $pvCanvas [expr {[llength $m_(mainLine,$id)] - 1}]
        #         if {[lsearch [.pv$pvN.p panes] $pvCanvas] == -1} {
        #             .pv$pvN.p add $pvCanvas -weight 0
        #         }
        #     }
        # }
        set ::enginewin::pv_(depths,$id) [dict create]
        set ::enginewin::pv_(seeded,$id) [dict create]
        set ::enginewin::pv_(postponed,$id) $plyInMainLine
        # What the game already knows, before any engine starts. This has to
        # come AFTER the depth reset above: the seeded markers are what
        # analyzeMainLine tests before it queues a position, so seeding earlier
        # would let Autorun re-search - and overwrite - a stored score.
        catch { ::enginewin::seedChart $id }
    }
    set m_(position,$id) $position
    set m_(posPly,$id) ""
    # Update current FEN for PV tracking
    set ::enginewin::m_(currentFen,$id) [sc_pos fen]
    if {$::enginewin::pv_(postponed,$id) eq "" || ![analyzeMainLine $id]} {
        set ::enginewin::pv_(postponed,$id) ""
        set m_(posPly,$id) $plyInMainLine
        # Limits come from the engine preset, with the legacy globals as fallback
        set limits [::enginelimits::goLimits \
            [list depth $::enginewin::depth($id) movetime $::enginewin::movetime($id)]]
        ::engine::send $id Go [list $position $limits]
    }
}

# Searches for unevaluated positions in the main line.
# Returns 0 if all positions have been evaluated, otherwise, returns 1 and
# starts analyzing the last unevaluated position.
proc ::enginewin::analyzeMainLine {id} {
    if {[lindex $::enginewin_autorun($id) 0] eq ""
        || [::enginewin::stateLocked $id]} { return 0 }

    upvar ::enginewin::pv_(depths,$id) depths
    upvar ::enginewin::pv_(seeded,$id) seeded
    if {![info exists seeded]} { set seeded [dict create] }
    set i [llength $::enginewin::m_(mainLine,$id)]
    while {[incr i -1] >= 0} {
        if {![dict exists $depths $i] && ![dict exists $seeded $i] \
            && $i ne $::enginewin::pv_(postponed,$id)} {
            dict set depths $i 0
            set uci_pos [join [lrange $::enginewin::m_(mainLine,$id) 0 $i]]
            set uci_pos [string range $uci_pos [string last "position" $uci_pos] end]
            ::engine::send $id Go [list $uci_pos $::enginewin_autorun($id)]
            return 1
        }
    }
    return 0
}
