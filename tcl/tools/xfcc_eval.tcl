# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# xfcc_eval.tcl -- the Evaluate button of the Play on ICCF and Play on LSS
# windows.
#
# After "Update Games" has filled a window's Your Turn list, Evaluate asks the
# engine preset assigned to the F2 shortcut (with that preset's own options and
# depth/time limits) for its best move in every Your Turn game, appends that
# move to the game in the open database and saves the game. "Send Moves" then
# sends it, exactly as if the reader had played the move by hand.
#
# Both windows keep the same state under their own namespace (yourTurnGames,
# gameData, gameToDbMap, statusText, dbMoves, parseSanTokens), so one routine
# serves both: ::xfcceval::run takes the namespace name ("iccf" or "lss") and
# the prefix of that window's translation keys ("ICCF" or "LSS").
#
# The engine is opened without a window (::engineNoWin), as Finish Game does,
# and the move is written with ::reviewprogress::commitMoves, which borrows the
# database game and restores the reader's own game afterwards.

namespace eval ::xfcceval {
    variable active 0
    variable cancel 0
    variable waitId ""
    variable best ""
    variable signal ""
    # A preset with no depth/time limit would search forever; this is what the
    # pass uses instead.
    variable defaultMovetime 5000
}

set ::xfcceval::EngineId xfccEval

proc ::xfcceval::message {id msg} {
    lassign $msg type data
    switch -- $type {
        InfoBestMove {
            if {$id ne $::xfcceval::waitId || !$::xfcceval::active} { return }
            lassign $data best
            set ::xfcceval::best $best
            set ::xfcceval::signal move
        }
        InfoDisconnected {
            if {$id ne $::xfcceval::waitId || !$::xfcceval::active} { return }
            set ::xfcceval::best ""
            set ::xfcceval::signal gone
        }
    }
    return
}

# The preset the F2 shortcut starts: the assigned preset, else the one that
# window opened last. "" if neither resolves to a preset.
proc ::xfcceval::engineName {} {
    set last ""
    if {[info exists ::enginewin_lastengine(1)]} { set last $::enginewin_lastengine(1) }
    set name [::enginecfg::windowEngine 1 $last]
    if {$name ne "" && [::enginecfg::get $name] ne ""} { return $name }
    return ""
}

# The Go limits of a preset, or a fixed movetime when there are none.
#
# The fallback is the one the engine window itself uses (::enginewin::loadLimits):
# a preset from before presets carried limits has none of its own, and the window
# then shows the global depth/movetime settings. Without the same fallback here
# such a preset would be searched for the fixed movetime instead of the limits
# the F2 window displays.
proc ::xfcceval::limits {name} {
    set fallback {depth {} movetime {}}
    catch { dict set fallback depth $::enginewin::depth_limit }
    catch { dict set fallback movetime $::enginewin::movetime_limit }
    set lim [::enginelimits::goLimits [::enginelimits::forName $name $fallback]]
    if {![llength $lim]} {
        set lim [list [list movetime $::xfcceval::defaultMovetime]]
    }
    return $lim
}

# The position at the end of a database game and that game's variant (0 for
# standard chess, else Chess960), read without disturbing the game on the
# board. The variant has to be read while the game is borrowed: afterwards
# sc_game answers for the reader's own game. {} if the game cannot be read.
proc ::xfcceval::endState {dbGameNum} {
    set state {}
    if {[catch {
        sc_game push copy
        set pushed 1
        sc_game load $dbGameNum
        sc_move end
        set fen [sc_pos fen]
        set variant 0
        catch { set variant [sc_game variant] }
        set state [list $fen $variant]
    }]} {
        set state {}
    }
    if {[info exists pushed]} { catch { sc_game pop } }
    return $state
}

# Do the DB game's moves equal the server's? Compared without check marks.
proc ::xfcceval::samePrefix {a b} {
    foreach x $a y $b {
        if {[regsub {[\+#]} $x ""] ne [regsub {[\+#]} $y ""]} { return 0 }
    }
    return 1
}

# Press of the Evaluate button. A second press while a pass runs cancels it.
proc ::xfcceval::run {ns prefix parent} {
    if {$::xfcceval::active} {
        ::xfcceval::stop
        return
    }
    upvar #0 ::${ns}::yourTurnGames yourTurn
    upvar #0 ::${ns}::statusText status
    upvar #0 ::${ns}::games games

    if {![sc_base inUse]} {
        tk_messageBox -message $::tr(${prefix}NoDatabase) -icon warning -parent $parent
        return
    }
    if {[llength $games] == 0} {
        tk_messageBox -message $::tr(${prefix}NeedUpdate) -icon info -parent $parent
        return
    }
    set name [::xfcceval::engineName]
    if {$name eq ""} {
        tk_messageBox -message $::tr(${prefix}EvaluateNoEngine) -icon warning -parent $parent
        return
    }
    set limits [::xfcceval::limits $name]
    set id $::xfcceval::EngineId

    if {[catch {
        ::engineNoWin::initEngine $id $name [list ::xfcceval::message $id]
    } err]} {
        catch { ::engineNoWin::closeEngine $id }
        tk_messageBox -message $err -icon warning -parent $parent
        return
    }

    set ::xfcceval::active 1
    set ::xfcceval::cancel 0
    set ::xfcceval::waitId $id
    set btn $parent.nb.yourturn.top.eval
    set busy [list $parent.nb.yourturn.top.update $parent.nb.yourturn.top.send]
    set count [dict create done 0 skipped 0 failed 0]
    # Commits are made into the database the pass started in: the reader may
    # switch databases during a long search, and a game number means a
    # different game there.
    set base [sc_base current]

    # Everything from here to the end of the pass is cleaned up whatever
    # happens: an error in one game must not leave the pass marked as running,
    # the engine open and the window's buttons disabled.
    try {
        catch { $btn configure -text $::tr(Cancel) }
        foreach b $busy { catch { $b state disabled } }

        set total [llength $yourTurn]
        set n 0
        foreach gid $yourTurn {
            if {$::xfcceval::cancel} { break }
            incr n
            set status [format $::tr(${prefix}Evaluating) $n $total]
            update idletasks

            set outcome failed
            catch {
                set outcome [::xfcceval::one $ns $gid $id $limits $base]
            }
            switch -- $outcome {
                done - skipped - failed { dict incr count $outcome }
                lost { dict incr count failed ; break }
                cancel { break }
                default { dict incr count failed }
            }
        }
    } finally {
        set ::xfcceval::active 0
        catch { ::engineNoWin::closeEngine $id }
        if {[winfo exists $parent]} {
            catch { $btn configure -text $::tr(${prefix}Evaluate) }
            foreach b $busy { catch { $b state !disabled } }
            set status [format $::tr(${prefix}Evaluated) [dict get $count done] \
                [dict get $count skipped] [dict get $count failed]]
            catch { ::${ns}::populateGameList }
        }
    }
    return
}

# Evaluate one Your Turn game. Returns done, skipped, failed, or - when the
# whole pass has to end - lost (the engine or the database went away) or cancel.
proc ::xfcceval::one {ns gid id limits base} {
    upvar #0 ::${ns}::gameData gameData
    upvar #0 ::${ns}::gameToDbMap dbMap

    if {![info exists gameData($gid)] || ![info exists dbMap($gid)] || $dbMap($gid) <= 0} {
        return skipped
    }
    # ICCF lists games that have not started yet; there is nothing to play.
    if {$ns eq "iccf" && ![::iccf::gameStarted $gameData($gid)]} {
        return skipped
    }
    if {![::xfcceval::baseIs $base]} { return lost }
    set dbGameNum $dbMap($gid)
    set serverTokens [::${ns}::parseSanTokens [::${ns}::dictGetDefault $gameData($gid) moves ""]]
    set dbTokens [::${ns}::parseSanTokens [::${ns}::dbMoves $dbGameNum]]
    # Only a game that is exactly where the server is needs a move. One that
    # already carries a further move (an earlier Evaluate, or the reader's own
    # choice) is left alone, and so is one that disagrees with the server.
    if {[llength $dbTokens] != [llength $serverTokens] ||
        ![::xfcceval::samePrefix $serverTokens $dbTokens]} {
        return skipped
    }
    set state [::xfcceval::endState $dbGameNum]
    if {![llength $state]} { return skipped }
    lassign $state fen variant
    if {$fen eq "" || [catch { ::chessboard::fromFen $fen } pos] ||
        ![llength [::chessboard::legalMoves $pos]]} {
        return skipped
    }

    set ::xfcceval::best ""
    set ::xfcceval::signal ""
    catch { ::engine::send $id NewGame [list analysis post_pv post_wdl $variant] }
    if {[catch { ::engine::send $id Go [list "position fen $fen" $limits] }]} {
        return lost
    }
    vwait ::xfcceval::signal
    if {!$::xfcceval::active || $::xfcceval::cancel} { return cancel }
    if {$::xfcceval::signal eq "gone"} { return lost }
    set move $::xfcceval::best
    if {$move eq "" || $move eq "(none)"} { return failed }

    # The search can take minutes with the event loop running. The move was
    # chosen for the position that was searched, so it is written only if the
    # same database is still open and the game still ends where it did.
    if {![::xfcceval::baseIs $base]} { return lost }
    set nowTokens [::${ns}::parseSanTokens [::${ns}::dbMoves $dbGameNum]]
    if {$nowTokens ne $dbTokens} { return skipped }
    if {[::reviewprogress::commitMoves $dbGameNum [list $move]] eq ""} {
        return done
    }
    return failed
}

# Is the database the pass started in still the current one?
proc ::xfcceval::baseIs {base} {
    if {[catch { expr {[sc_base inUse] && [sc_base current] eq $base} } same]} {
        return 0
    }
    return $same
}

# Stop after the current search. The stopped search's reply is swallowed by the
# engine layer, so the vwait is woken here.
proc ::xfcceval::stop {} {
    if {!$::xfcceval::active} { return }
    set ::xfcceval::cancel 1
    catch { ::engine::send $::xfcceval::waitId StopGo }
    set ::xfcceval::signal cancel
    return
}
