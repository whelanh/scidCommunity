# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# uci_format.tcl -- UCI moves turned into the notation the interface shows.
#
# #437 §4 needs these helpers without the old ::uci pipe engine mode: Play
# versus Engine plays the engine's bestmove on the board and shows the coach's
# line in SAN, and both are this file's job. #437 §6 deletes the mode and points
# the rest of the tree here; until then ::uci:: keeps a one-line wrapper for each
# of them, so there is one implementation and every old caller keeps working.

namespace eval ::ucifmt {}

# UCI moves use long notation; play them on the game as they arrive.
# Returns 1 if a move could not be entered.
proc ::ucifmt::sc_move_add { moves } {

    foreach m $moves {
        # get rid of leading piece
        set c [string index $m 0]
        if {$c == "K" || $c == "Q" || $c == "R" || $c == "B" || $c == "N"} {
            set m [string range $m 1 end]
        }
        set s1 [string range $m 0 1]
        set s1 [::board::sq $s1]
        set s2 [string range $m 2 3]
        set s2 [::board::sq $s2]
        if {[string length $m] > 4} {
            set promo [string range $m 4 end]
            switch -- $promo {
                q { set p 2}
                r { set p 3}
                b { set p 4}
                n { set p 5}
                default { return 1 }
            }
            if { [catch { sc_move add $s1 $s2 $p } ] } { return 1 }
        } else  {
            if { [catch { sc_move add $s1 $s2 0 } ] } { return 1 }
        }
    }
    return 0
}

# make UCI output more readable (b1c3 -> Nc3)
# @p fen (when given) is the position the line starts from; without it the
# current game is the one the moves are played on.
proc ::ucifmt::formatPv { moves { fen "" } } {
    # Push a temporary copy of the current game:
    if {$fen != ""} {
        sc_game push
        sc_game startBoard $fen
    } else  {
        sc_game push copyfast
    }
    set tmp ""
    foreach m $moves {
        if { [::ucifmt::sc_move_add $m] == 1 } { break }
        set prev [sc_game info previousMoveNT]
        append tmp " $prev"
    }
    set tmp [string trim $tmp]

    # Pop the temporary game:
    sc_game pop

    return $tmp
}

# Format a line starting at the current position where <moves> were played
# first (in SAN notation).
proc ::ucifmt::formatPvAfterMoves { played_moves moves } {
    sc_game push copyfast
    sc_move addSan $played_moves

    set tmp ""
    foreach m $moves {
        if { [::ucifmt::sc_move_add $m] == 1 } {
            break
        }
        set prev [sc_game info previousMoveNT]
        append tmp " $prev"
    }
    set tmp [string trim $tmp]

    # Pop the temporary game:
    sc_game pop

    return $tmp
}

###
### End of file: uci_format.tcl
###
