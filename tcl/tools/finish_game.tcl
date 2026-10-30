# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# finish_game.tcl -- the engine-window Finish Game.
#
# This is the same pass the Analysis window's Finish Game runs, moved to a
# button in the engine windows: engine per side, seconds and depth per side.
# The annotation options are the one thing left out; Game Review writes
# annotations now.
#
# The engines are opened without a window (::engineNoWin), which is the module
# built for annotate and finish game, so the presets' Threads/Hash and options
# are used exactly as the settings carry them. The moves are played into the
# open game and the old pass's tablebase and repetition checks are kept.

namespace eval ::finishgame {
    # One pass at a time. `waitId` is the connection the loop is waiting on and
    # `signal` is what wakes the vwait: a move, a lost engine, or a cancel.
    variable active 0
    variable cancel 0
    variable owner ""
    variable waitId ""
    variable best ""
    variable signal ""
    variable whiteEngine ""
    variable blackEngine ""
    variable whiteSeconds 10
    variable whiteDepth 30
    variable blackSeconds 10
    variable blackDepth 30
    variable oldMode 0
}

::options.store ::finishgame::whiteEngine ""
::options.store ::finishgame::blackEngine ""
::options.store ::finishgame::whiteSeconds 10
::options.store ::finishgame::whiteDepth 30
::options.store ::finishgame::blackSeconds 10
::options.store ::finishgame::blackDepth 30

# The two connections. String ids: the numeric ones belong to engine windows
# and the review pass, and ::engine::connect closes whatever holds the id it is
# given.
set ::finishgame::WhiteId finishWhite
set ::finishgame::BlackId finishBlack

proc ::finishgame::connection {side} {
    if {$side eq "white"} { return $::finishgame::WhiteId }
    return $::finishgame::BlackId
}

# One engine's reply. Only the search the loop is waiting on matters: a late
# bestmove from a position that has already been played must not become the
# next move.
proc ::finishgame::message {id msg} {
    lassign $msg type data
    switch -- $type {
        InfoBestMove {
            if {$id ne $::finishgame::waitId || !$::finishgame::active} { return }
            lassign $data best
            set ::finishgame::best $best
            set ::finishgame::signal move
        }
        InfoDisconnected {
            if {$id ne $::finishgame::waitId || !$::finishgame::active} { return }
            set ::finishgame::best ""
            set ::finishgame::signal gone
        }
    }
    return
}

# The per-side limits, as the Go message wants them.
proc ::finishgame::limits {side} {
    if {$side eq "white"} {
        set seconds $::finishgame::whiteSeconds
        set depth $::finishgame::whiteDepth
    } else {
        set seconds $::finishgame::blackSeconds
        set depth $::finishgame::blackDepth
    }
    return [::enginelimits::goLimits [list \
        depth $depth movetime [expr {$seconds * 1000}]]]
}

# Open the two engines and play until the game ends or the user cancels.
# `ownerId` is the engine window that asked, so the pass can put its button
# back; it is not otherwise special.
proc ::finishgame::start {ownerId white black} {
    variable active
    if {$active} { return }
    set owner [::enginewin::reviewWindow $ownerId]
    if {[catch {
        ::engineNoWin::initEngine $::finishgame::WhiteId $white \
            [list ::finishgame::message $::finishgame::WhiteId]
        ::engineNoWin::initEngine $::finishgame::BlackId $black \
            [list ::finishgame::message $::finishgame::BlackId]
    } err]} {
        ::finishgame::closeEngines
        tk_messageBox -title "scidCommunity: [tr FinishGame]" -type ok \
            -icon warning -message $err
        return
    }
    set ::finishgame::active 1
    set ::finishgame::cancel 0
    set ::finishgame::owner $owner
    set ::finishgame::best ""
    set ::finishgame::signal ""
    set ::finishgame::waitId ""
    # The old pass's flag: it suppresses the repetition notices addMoveUCI
    # would otherwise pop up, and marks the game as being played by an engine.
    set ::finishgame::oldMode 0
    catch { set ::finishgame::oldMode $::finishGameMode }
    set ::finishGameMode 1
    # Chess960 and the rest of the variant go with NewGame, as the engine
    # windows send it when they start.
    set variant 0
    catch { set variant [sc_game variant] }
    foreach id [list $::finishgame::WhiteId $::finishgame::BlackId] {
        catch { ::engine::send $id NewGame [list analysis post_pv post_wdl $variant] }
    }
    catch { grab $owner }
    catch { $owner.btn.finish configure -image [::button_image tb_finish_on] }
    update idletasks
    ::finishgame::play
    return
}

# The move loop. It holds the event loop through vwait, so the board repaints
# and the Cancel button (the same Finish Game button, now On) stays live.
proc ::finishgame::play {} {
    set reason end
    while {1} {
        if {!$::finishgame::active || $::finishgame::cancel} {
            set reason cancel
            break
        }
        if {[::pgn::getRepetitionCount] >= 3} {
            sc_game tags set -result "1/2-1/2"
            updateBoard -pgn
            set reason repetition
            break
        }
        # The old pass's tablebase check: a position with seven pieces or fewer
        # may be settled without asking the engine.
        set fen [sc_pos fen]
        set pieces 99
        catch { set pieces [::tablebase::countPieces $fen] }
        if {$pieces <= 7} {
            set tb ""
            catch { set tb [::tablebase::queryTablebaseResult $fen] }
            if {$tb ne "" && ![string match "error:*" $tb]} {
                sc_pos setComment "[sc_pos getComment] Tablebase: $tb"
                updateBoard -pgn
                set reason tablebase
                break
            }
        }
        set side [sc_pos side]
        set id [::finishgame::connection $side]
        set position [sc_game UCI_currentPos]
        set ::finishgame::waitId $id
        set ::finishgame::best ""
        set ::finishgame::signal ""
        if {[catch { ::engine::send $id Go \
            [list $position [::finishgame::limits $side]] } err]} {
            set reason "engine: $err"
            break
        }
        vwait ::finishgame::signal
        if {!$::finishgame::active || $::finishgame::cancel} {
            set reason cancel
            break
        }
        if {$::finishgame::signal eq "gone"} {
            set reason "the engine disconnected"
            break
        }
        set move $::finishgame::best
        if {$move eq ""} {
            set reason "the engine returned no move"
            break
        }
        if {$move eq "(none)"} {
            # No legal move: the position is terminal. It is mate when the side
            # to move is in check, and stalemate otherwise.
            if {[catch { sc_pos isCheck } check] || !$check} {
                sc_game tags set -result "1/2-1/2"
                updateBoard -pgn
                set reason stalemate
            } else {
                set reason mate
            }
            break
        }
        if {[catch { set played [::addMoveUCI $move] } err]} {
            set reason "the engine's move $move was rejected: $err"
            break
        }
        if {!$played} {
            set reason "the engine's move $move was rejected"
            break
        }
        if {[string index [sc_game info previousMove] end] eq "#"} {
            set reason mate
            break
        }
    }
    ::finishgame::done $reason
    return
}

# Stop after the current search. The same button that started the pass is the
# Cancel button, so it has to wake the vwait itself: a stopped search's reply is
# swallowed by the engine layer rather than delivered as a bestmove.
proc ::finishgame::stop {} {
    if {!$::finishgame::active} { return }
    set ::finishgame::cancel 1
    if {$::finishgame::waitId ne ""} {
        catch { ::engine::send $::finishgame::waitId StopGo }
    }
    set ::finishgame::signal cancel
    return
}

proc ::finishgame::closeEngines {} {
    catch { ::engineNoWin::closeEngine $::finishgame::WhiteId }
    catch { ::engineNoWin::closeEngine $::finishgame::BlackId }
}

proc ::finishgame::done {reason} {
    set ::finishgame::active 0
    set owner $::finishgame::owner
    ::finishgame::closeEngines
    catch { set ::finishGameMode $::finishgame::oldMode }
    catch { grab release $owner }
    catch { $owner.btn.finish configure -image [::button_image tb_finish_off] }
    set ::finishgame::owner ""
    set ::finishgame::waitId ""
    if {[lsearch -exact {end mate stalemate cancel repetition tablebase} $reason] < 0} {
        tk_messageBox -title "scidCommunity: [tr FinishGame]" -type ok \
            -icon warning -message "[tr FinishGame]: $reason"
    }
    return
}

########################################################################
### The dialog
###
### Engine names are the engine presets. The window the button was pressed in
### supplies the default name for both sides.

proc ::finishgame::engineNames {} {
    if {[llength [info commands ::enginecfg::names]] == 0} { return {} }
    return [::enginecfg::names]
}

proc ::finishgame::dialog {ownerId} {
    set w .finishGame
    if {[winfo exists $w]} { raise $w ; return }
    set names [::finishgame::engineNames]
    if {![llength $names]} {
        tk_messageBox -title "scidCommunity: [tr FinishGame]" -type ok \
            -icon info -message "No engine is configured."
        return
    }
    # The engine in the window that asked is the default for both sides, even
    # when a previous dialog chose another; the stored value is only a fallback
    # when that window has no engine.
    set current ""
    catch { set current $::enginewin_lastengine($ownerId) }
    if {[lsearch -exact $names $current] >= 0} {
        set ::finishgame::whiteEngine $current
        set ::finishgame::blackEngine $current
    } else {
        if {[lsearch -exact $names $::finishgame::whiteEngine] < 0} {
            set ::finishgame::whiteEngine [lindex $names 0]
        }
        if {[lsearch -exact $names $::finishgame::blackEngine] < 0} {
            set ::finishgame::blackEngine [lindex $names 0]
        }
    }

    win::createDialog $w
    wm resizable $w 0 0
    ::setTitle $w "scidCommunity: [tr FinishGame]"

    foreach side {white black} {
        set f $w.$side
        ttk::labelframe $f -text [tr [string totitle $side]] -padding 5
        grid $f -sticky we -pady 6
        ttk::label $f.eng_l -text "[tr Engine]:"
        ttk::combobox $f.eng -width 24 -state readonly -values $names \
            -textvariable ::finishgame::${side}Engine
        ttk::label $f.sec_l -text "[tr SecondsPerMove]:"
        ttk::spinbox $f.sec -width 5 -from 1 -to 999 -justify right \
            -textvariable ::finishgame::${side}Seconds
        ttk::label $f.dep_l -text "[tr Depth]:"
        ttk::spinbox $f.dep -width 5 -from 1 -to 999 -justify right \
            -textvariable ::finishgame::${side}Depth
        grid $f.eng_l -row 0 -column 0 -sticky w
        grid $f.eng -row 0 -column 1 -columnspan 3 -sticky we -padx {6 0}
        grid $f.sec_l -row 1 -column 0 -sticky w -pady {6 0}
        grid $f.sec -row 1 -column 1 -sticky w -padx {6 0} -pady {6 0}
        grid $f.dep_l -row 2 -column 0 -sticky w
        grid $f.dep -row 2 -column 1 -sticky w -padx {6 0}
        grid columnconfigure $f 1 -weight 1
    }

    ttk::frame $w.buttons
    ttk::button $w.buttons.cancel -text [tr Cancel] \
        -command [list destroy $w]
    ttk::button $w.buttons.ok -text [tr OK] \
        -command [list ::finishgame::apply $w $ownerId]
    packbuttons right $w.buttons.cancel $w.buttons.ok
    grid $w.buttons -sticky e -pady {8 0}
    focus $w.buttons.ok
    bind $w <Escape> [list destroy $w]
    bind $w <Return> [list $w.buttons.ok invoke]
    ::tk::PlaceWindow $w pointer
    grab $w
    return $w
}

proc ::finishgame::apply {w ownerId} {
    foreach side {white black} {
        foreach var [list ${side}Seconds ${side}Depth] {
            set value [set ::finishgame::$var]
            if {![string is integer -strict $value] || $value < 1} {
                tk_messageBox -title "scidCommunity: [tr FinishGame]" -type ok \
                    -icon warning -parent $w \
                    -message "Seconds and Depth must be whole numbers above zero."
                return
            }
        }
    }
    set white $::finishgame::whiteEngine
    set black $::finishgame::blackEngine
    destroy $w
    ::finishgame::start $ownerId $white $black
    return
}
