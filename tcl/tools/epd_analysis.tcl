# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# epd_analysis.tcl -- the Engine Window's messages as an EPD result record.
#
# Analyze Positions used to run a headless engine of its own. That made the
# report a second search, with a cold hash, its own MultiPV and its own time
# budget, and a reader had no way to tell why the window in front of them and
# the report disagreed. The pass drives the Engine Window now, so this module
# holds no connection: it only translates the window's raw "InfoPV" fields into
# the record the EPD writer, the log and the best-move tally use.
#
# No Tk is used here, so a stub message can drive the whole module in tclsh.

namespace eval ::epdanalysis {}

# sc_pos coordToSAN writes the scoresheet's numbering with each move
# ("1...e5", "2.d5"). EPD's pv opcode and the report's move columns want the
# bare move, so strip the number from each token. The same rule is in
# ::facts::sanLine; keep this module self-contained for its tclsh harness.
proc ::epdanalysis::bareMoves {moves} {
    set out {}
    foreach token $moves {
        regsub {^[0-9]+\.+} $token "" token
        lappend out $token
    }
    return $out
}

# A UCI move list as SAN, through the UCI formatter the rest of the tree keeps.
# The formatter needs the game's push/pop, so a headless test with no board gets
# the engine's coordinates instead of an empty line.
proc ::epdanalysis::pvSAN {fen pv} {
    # EPD and the report want plain SAN. coordToSAN is the board's own
    # conversion and is preferred over the display formatter; both number a
    # Black move ("1...e5"), so bareMoves strips the scoresheet number from each
    # token before it can reach best_san or the pv opcode.
    if {[llength [info commands sc_pos]]} {
        set out ""
        catch { set out [sc_pos coordToSAN $fen $pv] }
        if {[llength $out]} {
            return [join [::epdanalysis::bareMoves $out] " "]
        }
    }
    # The tree's UCI->SAN formatter. ::ucifmt is its own module, sourced at
    # start.tcl next to this file, so the guard is what tells a harness that
    # stubs it (the EPD pass is tested headless) from the app.
    if {[llength [info commands ::ucifmt::formatPv]]} {
        set out ""
        catch { set out [::ucifmt::formatPv $pv $fen] }
        if {$out ne ""} {
            return [join [::epdanalysis::bareMoves [split $out]] " "]
        }
    }
    return [join $pv " "]
}

proc ::epdanalysis::sanMove {fen uci} {
    if {$uci eq ""} { return "" }
    set out ""
    if {[llength [info commands sc_pos]]} {
        catch { set out [sc_pos coordToSAN $fen [list $uci]] }
        if {[llength $out]} {
            return [lindex [::epdanalysis::bareMoves $out] 0]
        }
    }
    set pv [::epdanalysis::pvSAN $fen [list $uci]]
    return [lindex $pv 0]
}

# Which way a side-to-move score has to be turned for White's point of view.
proc ::epdanalysis::sideSign {fen} {
    return [expr {[lindex [split $fen] 1] eq "b" ? -1 : 1}]
}

# The UCI/EPD ce encoding of a mate. `md` is the absolute distance; the sign is
# the side-to-move direction. A negative mate is -32761 for -M3, not -32773:
# the UCI parser uses -32767 - 2 * mate, and the mate itself is negative.
proc ::epdanalysis::mateCe {sign md} {
    if {$sign eq "-"} { return [expr {-32767 + 2 * $md}] }
    return [expr {32767 - 2 * $md}]
}

# The result record the EPD code writes. Scores are kept in all three forms the
# callers need: side to move (ce), White (the log and the old analysis display),
# and a mate distance with its sign (dm/log).
proc ::epdanalysis::emptyData {fen} {
    return [dict create fen $fen \
        best_uci "" best_san "" pv_uci "" pv_san "" \
        depth "" nodes "" time "" score_stm "" score_white "" \
        mate_stm "" mate_white "" score_type "" error ""]
}

proc ::epdanalysis::dataFromInfo {fen msgData} {
    lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time \
        score score_type score_wdl
    # InfoPV's last field is a PV: enginecomm passes it as one list element, but
    # a stub or a hand-built message may split it into words.
    set pv [join [lrange $msgData 11 end] " "]
    if {$multipv ne "" && $multipv ne "1"} { return "" }
    if {$score eq "" || $score_type ni {cp mate}} { return "" }
    set d [::epdanalysis::emptyData $fen]
    set sign [::epdanalysis::sideSign $fen]
    if {$pv eq ""} { set pv {} }
    set pvSAN [::epdanalysis::pvSAN $fen $pv]
    set best [lindex $pv 0]
    # The first move on its own, not the first word of the display line: the
    # latter can carry a move number ("1...Qc7") that the bm/am value never has.
    set bestSAN [::epdanalysis::sanMove $fen $best]
    dict set d pv_uci $pv
    dict set d pv_san $pvSAN
    dict set d best_uci $best
    dict set d best_san $bestSAN
    dict set d depth $depth
    dict set d nodes $nodes
    dict set d time $time
    dict set d score_type $score_type
    if {$score_type eq "mate"} {
        set mate [expr {$score eq "" ? "" : $score}]
        dict set d mate_stm $mate
        dict set d mate_white [expr {$mate eq "" ? "" : $sign * $mate}]
    } else {
        set cp [expr {$score eq "" ? "" : $score / 100.0}]
        dict set d score_stm $cp
        dict set d score_white [expr {$cp eq "" ? "" : $sign * $cp}]
    }
    return $d
}

# True when a new InfoPV line is below the depth of the result already held.
# Engines can re-search a line at a shallower depth before the bestmove (a line
# that was not finished when the deeper one was reported); that line must not
# replace the deeper depth, score and PV in the record the report and the pv
# opcode use. Equal and deeper lines replace, as does an unparsable depth.
proc ::epdanalysis::shallower {depth old} {
    if {![string is integer -strict $depth] \
            || ![string is integer -strict $old]} {
        return 0
    }
    return [expr {$depth < $old}]
}

# Take one InfoPV line into the record. The window can show a shallower
# re-search just before it answers; the deepest line it reached is what the
# reader watched fill in, so that is what the report keeps.
proc ::epdanalysis::absorb {data line} {
    if {$line eq ""} { return $data }
    if {[::epdanalysis::shallower [dict get $line depth] [dict get $data depth]]} {
        return $data
    }
    return $line
}

# The window's answer at the end of a search. A bestmove that arrives after a
# shallower re-search belongs to that search, and rewriting the move alone would
# pair it with the deeper depth, score and PV; use it only when the window never
# showed a line at all.
proc ::epdanalysis::withBestMove {data best fen} {
    if {$best eq "" || $best eq "0000" || $best eq "(none)"} { return $data }
    if {[dict get $data best_uci] ne ""} { return $data }
    dict set data best_uci $best
    dict set data best_san [::epdanalysis::sanMove $fen $best]
    return $data
}
