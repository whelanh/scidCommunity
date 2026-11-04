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
    # The classic Analysis window's index when the pass was started there, ""
    # for an engine window. Both are the same pass; only the button that shows
    # it is different.
    variable pane ""
    # The game the pass belongs to, captured when it starts: a long pass must
    # not write its continuation into a game the reader opened meanwhile.
    variable identity ""
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

# Is the cursor on the main line at its end? The pass collects from here and
# the commit appends at the main-line end, so a midgame cursor or a variation
# is a different position and must be refused rather than written over.
proc ::finishgame::atLineEnd {} {
    set level 0
    catch { set level [sc_var level] }
    if {$level != 0} { return 0 }
    set at 0
    catch { set at [sc_pos isAt vend] }
    return [expr {$at ? 1 : 0}]
}

# The game this pass belongs to, for the commit check. The number alone is 0
# for a new game, so the final position is what tells two unsaved games apart;
# for a database game the base and number are already unique. Read at the start
# and again at the commit, and compare: a game opened or edited meanwhile is not
# this pass's to write.
proc ::finishgame::gameIdentity {} {
    set base 0
    set number 0
    catch { set base [sc_base current] }
    catch { set number [sc_game number] }
    set fen ""
    set cursor ""
    catch { set cursor [::review::cursorSave] }
    if {[catch { sc_move end ; set fen [sc_pos fen] }]} { set fen "" }
    if {$cursor ne ""} { catch { ::review::cursorRestore $cursor } }
    return [dict create base $base number $number fen $fen]
}

# The part of a FEN two positions must share to be the same position for the
# repetition rule: placement, side to move, castling rights and en passant.
proc ::finishgame::positionKey {fen} {
    return [join [lrange [split $fen] 0 3] " "]
}

# The positions the game has already reached up to the cursor. The pass plays on
# a pure board, but a repetition can include the history before it started, so
# the seed comes from the game, once, and the cursor is put back.
proc ::finishgame::gameRepetitions {} {
    set reps [dict create]
    set cursor ""
    catch { set cursor [::review::cursorSave] }
    set end 0
    catch { set end [sc_pos location] }
    if {[catch {
        sc_move ply 0
        set p 0
        while {1} {
            dict incr reps [::finishgame::positionKey [sc_pos fen]]
            if {$p >= $end} { break }
            if {[catch { sc_move forward }]} { break }
            incr p
        }
    }]} {}
    if {$cursor ne ""} { catch { ::review::cursorRestore $cursor } }
    return $reps
}

# Open the two engines and play until the game ends or the user cancels.
# `ownerId` is the engine window that asked, so the pass can put its button
# back; it is not otherwise special.
proc ::finishgame::start {ownerId white black} {
    variable active
    if {$active} { return }
    # The commit appends at the end of the main line. A pass started from a
    # midgame cursor would search from one position and write at another, so it
    # must start where it will write.
    if {[::finishgame::atLineEnd] == 0} {
        catch {
            tk_messageBox -title "scidCommunity: [tr FinishGame]" -type ok \
                -icon info -message [tr FinishGameAtEnd]
        }
        return
    }
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
    # The progress board is fed a FEN and nothing else: it cannot move the
    # reader's board because it has no game to move. The origin is the window's
    # number, not its widget path: a header reading "Engine window .engineWin1"
    # is an implementation detail the reader should never see.
    set engineName $white
    if {$black ne $white} { set engineName "$white / $black" }
    set ::finishgame::token [::reviewprogress::begin [dict create \
        source finish engine $engineName origin [list enginewin $ownerId] \
        cancel ::finishgame::stop]]
    set ::finishgame::identity [::finishgame::gameIdentity]
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
    catch { $owner.btn.finish configure -image ::icon::tb_finish_on }
    update idletasks
    ::finishgame::play
    return
}

# The classic Analysis window's Finish Game: the same collect and the same one
# commit, driven from the pane's own engine preset.
#
# It exists as its own entry point rather than as a second implementation: the
# pane is a window with its own engine, not an engine window, so it cannot call
# ::finishgame::start. Everything below ::finishgame::play is shared, which is
# what makes the two surfaces behave identically - the collect touches no game,
# the commit happens once, and a cancel writes nothing.
proc ::finishgame::startPane {n} {
    variable active
    if {$active} { return }
    if {[::finishgame::atLineEnd] == 0} {
        catch { set ::finishGameMode 0 }
        catch { .analysisWin$n.b1.bFinishGame configure -image ::icon::tb_finish_off }
        catch {
            tk_messageBox -title "scidCommunity: [tr FinishGame]" -type ok \
                -icon info -message [tr FinishGameAtEnd]
        }
        return
    }
    set name ""
    catch { set name $::analysis(name$n) }
    if {$name eq ""} { return }
    if {[catch {
        ::engineNoWin::initEngine $::finishgame::WhiteId $name \
            [list ::finishgame::message $::finishgame::WhiteId]
        ::engineNoWin::initEngine $::finishgame::BlackId $name \
            [list ::finishgame::message $::finishgame::BlackId]
    } err]} {
        ::finishgame::closeEngines
        # The caller has already turned the pane's toggle On; a pass that never
        # starts has to put it back, or the button needs two presses.
        catch { set ::finishGameMode 0 }
        catch {
            .analysisWin$n.b1.bFinishGame configure -image ::icon::tb_finish_off
        }
        catch {
            tk_messageBox -title "scidCommunity: [tr FinishGame]" -type ok \
                -icon warning -message $err
        }
        return
    }
    set ::finishgame::active 1
    set ::finishgame::cancel 0
    set ::finishgame::owner ""
    set ::finishgame::pane $n
    set ::finishgame::best ""
    set ::finishgame::signal ""
    set ::finishgame::waitId ""
    set ::finishgame::token [::reviewprogress::begin [dict create \
        source finish engine $name origin [list analysispane $n] \
        cancel ::finishgame::stop]]
    set ::finishgame::identity [::finishgame::gameIdentity]
    # The pane's toggle is already On when this is called, so the state to put
    # back after the pass is Off. Reading the live flag here made done_ restore
    # On while turning the button Off, and the next press only cleared it.
    set ::finishgame::oldMode 0
    set ::finishGameMode 1
    set variant 0
    catch { set variant [sc_game variant] }
    foreach id [list $::finishgame::WhiteId $::finishgame::BlackId] {
        catch { ::engine::send $id NewGame [list analysis post_pv post_wdl $variant] }
    }
    update idletasks
    ::finishgame::play
    return
}

# The move loop. It holds the event loop through vwait, so the board repaints
# and the Cancel button (the same Finish Game button, now On) stays live.
#
# It collects the continuation and writes nothing until the last move is in:
# every move is played on a pure ::chessboard position, never on the game, so
# the reader's board and cursor stay exactly where they were for the whole of a
# pass that can run for hours. The moves land in one commit at the end, and a
# run that is cancelled, loses an engine or is refused has written nothing at
# all - the collect phase has nothing to undo because it touched nothing.
proc ::finishgame::play {} {
    set reason end
    set ::finishgame::collected {}
    set ::finishgame::note ""
    set fen ""
    catch { set fen [sc_pos fen] }
    set pos ""
    if {[catch { set pos [::chessboard::fromFen $fen] }]} {
        set reason "the position could not be read"
        ::finishgame::settle $reason
        ::finishgame::done $reason
        return
    }
    set token $::finishgame::token
    # The game's own history, then the collected moves: a repetition that
    # includes positions from before this pass is still a repetition.
    set reps [::finishgame::gameRepetitions]
    while {1} {
        if {!$::finishgame::active || $::finishgame::cancel} {
            set reason cancel
            break
        }
        # The game may already be at its third occurrence before this pass makes
        # a move; the old autoplay stopped on that and so does this one.
        if {[dict get $reps [::finishgame::positionKey $fen]] >= 3} {
            set reason repetition
            break
        }
        # The position is terminal when the side to move has no legal move. The
        # game is asked nothing: it is not this pass's board.
        if {![llength [::chessboard::legalMoves $pos]]} {
            if {[::chessboard::inCheck $pos [dict get $pos side]]} {
                set reason mate
            } else {
                set reason stalemate
            }
            break
        }
        # The old pass's tablebase check: a position with seven pieces or fewer
        # may be settled without asking the engine. The note is written with the
        # commit, into the position it belongs to.
        set pieces 99
        catch { set pieces [::tablebase::countPieces $fen] }
        if {$pieces <= 7} {
            set tb ""
            catch { set tb [::tablebase::queryTablebaseResult $fen] }
            if {$tb ne "" && ![string match "error:*" $tb]} {
                set ::finishgame::note "Tablebase: $tb"
                set reason tablebase
                break
            }
        }
        # A run that is going nowhere has to end: fifty moves of shuffling is
        # the longest a game can legally be extended without a capture or a pawn
        # move, and the collect phase has no repetition counter to lean on
        # because the game is not being played.
        if {[llength $::finishgame::collected] >= 500} { break }
        # The progress board shows the position being searched, not ply one.
        ::reviewprogress::setPosition $token $fen \
            [llength $::finishgame::collected] [llength $::finishgame::collected]
        set side [dict get $pos side]
        # ::chessboard speaks FEN's "w"/"b"; the two connections are named
        # white and black, and the limits are per side.
        set which [expr {$side eq "b" ? "black" : "white"}]
        set id [::finishgame::connection $which]
        set ::finishgame::waitId $id
        set ::finishgame::best ""
        set ::finishgame::signal ""
        # The FEN, not the game: the game's own position is the reader's, and
        # the search has moved on from it.
        if {[catch { ::engine::send $id Go \
            [list "position fen $fen" [::finishgame::limits $which]] } err]} {
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
            if {[::chessboard::inCheck $pos [dict get $pos side]]} {
                set reason mate
            } else {
                set reason stalemate
            }
            break
        }
        if {[catch { set next [::chessboard::makeMove $pos $move] }]} {
            set reason "the engine's move $move was rejected"
            break
        }
        lappend ::finishgame::collected $move
        set pos $next
        set fen [::chessboard::toFen $pos]
        set key [::finishgame::positionKey $fen]
        dict incr reps $key
        if {[dict get $reps $key] >= 3} {
            # Threefold: the old pass checked the game before every move and
            # stopped here; the collect phase has to count the pure positions.
            set reason repetition
            break
        }
    }
    # The one write of the pass, and the last thing the collect phase leads to.
    set wrote [::finishgame::commit $reason]
    if {$wrote ne ""} { set reason $wrote }
    ::finishgame::settle $reason
    # The commit writes with the reader's board untouched, so the PGN view has
    # to hear that the line changed.
    if {[llength [info commands ::notify::PosChanged]]} {
        catch { ::notify::PosChanged -pgn }
    }
    ::finishgame::done $reason
    return
}

# The one write of the pass. It is here, outside the loop, so that every way out
# of the loop - the end of the game, a cancel, a lost engine - leaves the game
# exactly as it was found until this point, and this point is reached once.
#
# The commit borrows nothing: Finish Game plays into the game the reader is
# looking at. A run whose game was closed or replaced meanwhile is refused by
# the cursor save rather than written into whatever is open now.
proc ::finishgame::commit {reason} {
    set moves $::finishgame::collected
    set note $::finishgame::note
    if {[string equal $reason cancel]} { return "" }
    # A pass can run for hours and the reader may open another game meanwhile.
    # The cursor save inside commitMoves describes a position, not a game, so
    # the game's identity is checked here, before anything is written.
    if {$::finishgame::identity ne ""} {
        if {[::finishgame::gameIdentity] ne $::finishgame::identity} {
            return [tr FinishGameGameChanged]
        }
    }
    return [::reviewprogress::commitMoves "" $moves $note]
}

# The result tags a settled game carries, written after the moves so the tag is
# never a claim about a game the pass did not write.
proc ::finishgame::settle {reason} {
    switch -- $reason {
        stalemate - repetition {
            catch { sc_game tags set -result "1/2-1/2" }
        }
    }
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
    # The pane's job is this pass's too: without this it would keep the last
    # board and header of a run that is over.
    if {[info exists ::finishgame::token] && $::finishgame::token ne ""} {
        catch { ::reviewprogress::finish $::finishgame::token }
        set ::finishgame::token ""
    }
    set owner $::finishgame::owner
    ::finishgame::closeEngines
    catch { set ::finishGameMode $::finishgame::oldMode }
    catch { grab release $owner }
    catch { $owner.btn.finish configure -image ::icon::tb_finish_off }
    # The classic pane's own toggle: the same pass has to put back the button it
    # turned on, whether it ran there or in an engine window.
    if {$::finishgame::pane ne ""} {
        catch {
            .analysisWin$::finishgame::pane.b1.bFinishGame \
                configure -image ::icon::tb_finish_off
        }
    }
    set ::finishgame::pane ""
    set ::finishgame::owner ""
    set ::finishgame::waitId ""
    set ::finishgame::identity ""
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
