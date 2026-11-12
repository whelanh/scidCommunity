# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# epd_analysis.tcl -- the EPD window's headless analysis session.
#
# The EPD "Analyse positions" pass used to open an Analysis Engine window and
# read its ::analysis(...) state. This module owns a private UCI connection
# instead: one engine for the whole pass, one position at a time, the same
# `go movetime` the pass always used, and a result dict for the EPD writer.
#
# No Tk is used here. The caller supplies a completion callback and an optional
# per-info callback, so a stub engine can drive the whole module in tclsh.

namespace eval ::epdanalysis {
    # The id is a string, not one of the engine windows' numeric slots: an EPD
    # pass must never take a window's engine.
    variable id epdAnalysis
    variable seq 0
    variable engine ""
    # {token fen onDone onInfo timeout data}; empty when no search is running.
    variable job {}
}

# A UCI move list as SAN, through the UCI formatter the rest of the tree keeps.
# The formatter needs the game's push/pop, so a headless test with no board gets
# the engine's coordinates instead of an empty line.
proc ::epdanalysis::pvSAN {fen pv} {
    # EPD and the report want plain SAN. coordToSAN is the board's own
    # conversion and, unlike the UCI display formatter, does not prefix a Black
    # move with "1..." - that prefix would hide the match from evalBestMove and
    # would make an EPD pv opcode invalid. Prefer it; the formatter is only a
    # fallback for a headless harness with no board.
    if {[llength [info commands sc_pos]]} {
        set out ""
        catch { set out [sc_pos coordToSAN $fen $pv] }
        if {[llength $out]} { return [join $out " "] }
    }
    if {[llength [info commands ::uci::formatPv]]} {
        set out ""
        catch { set out [::uci::formatPv $pv $fen] }
        if {$out ne ""} { return $out }
    }
    return [join $pv " "]
}

proc ::epdanalysis::sanMove {fen uci} {
    if {$uci eq ""} { return "" }
    set out ""
    if {[llength [info commands sc_pos]]} {
        catch { set out [sc_pos coordToSAN $fen [list $uci]] }
        if {[llength $out]} { return [lindex $out 0] }
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

# Open a UCI preset for an EPD pass. Returns "" or the reason it could not.
proc ::epdanalysis::open {engine} {
    if {[dict size $::epdanalysis::job]} {
        return [::tr EpdSearchAlreadyRunning]
    }
    ::epdanalysis::close
    set cfg ""
    catch { set cfg [::enginecfg::get $engine] }
    if {![llength $cfg]} { return [::tr EpdNoEngineConfigured] }
    if {[lindex $cfg 7] eq "" || [lindex $cfg 7] eq 0} {
        return [::tr EpdOnlyUci]
    }
    if {[catch {
        ::engineNoWin::initEngine $::epdanalysis::id $engine \
            [list ::epdanalysis::message]
    } err]} {
        return $err
    }
    set ::epdanalysis::engine $engine
    # EPD wants one line: the best move. A preset left on MultiPV 3 must not
    # make every position wait for lines the writer will not use.
    catch { ::engine::send $::epdanalysis::id SetOptions [list [list MultiPV 1]] }
    return ""
}

# Start one search. `movetime` is milliseconds; `onDone` is called once with the
# result dict, `onInfo` (when given) on every exact MultiPV 1 info line so the
# EPD caller can record the first moment the engine finds the sought move.
# Returns the search token, or "" when the command could not be sent.
proc ::epdanalysis::ask {fen movetime onDone {onInfo ""}} {
    variable seq
    variable job
    if {[dict size $job]} { return "" }
    set token "epd[incr seq]"
    set job [dict create token $token fen $fen onDone $onDone onInfo $onInfo \
        timeout "" data [::epdanalysis::emptyData $fen]]
    set lim [::enginelimits::goLimits [dict create movetime $movetime]]
    if {[catch {
        ::engine::send $::epdanalysis::id Go [list "position fen $fen" $lim]
    } err]} {
        set j $job
        set job {}
        catch { {*}[dict get $j onDone] \
            [dict set [dict get $j data] error $err] }
        return ""
    }
    # The engine should answer at movetime; the margin is for a process that
    # dies or stops sending without disconnecting. The caller's own cancel is
    # the normal early exit.
    set timeout [after [expr {$movetime + 15000}] \
        [list ::epdanalysis::timeout $token]]
    dict set job timeout $timeout
    return $token
}

proc ::epdanalysis::message {msg} {
    variable job
    if {![dict size $job]} { return }
    lassign $msg type data
    switch -- $type {
        "InfoPV" {
            set d [::epdanalysis::dataFromInfo [dict get $job fen] $data]
            if {$d eq ""} { return }
            dict set job data $d
            set cb [dict get $job onInfo]
            if {$cb ne ""} { catch { {*}$cb $d } }
        }
        "InfoBestMove" {
            set best [lindex $data 0]
            set d [dict get $job data]
            if {$best ne "" && $best ne "0000" && $best ne "(none)"} {
                dict set d best_uci $best
                dict set d best_san [::epdanalysis::sanMove [dict get $job fen] $best]
            }
            dict set job data $d
            ::epdanalysis::finish ""
        }
        "InfoDisconnected" {
            ::epdanalysis::finish [::tr EpdEngineDisconnected]
        }
    }
    return
}

proc ::epdanalysis::timeout {token} {
    variable job
    if {![dict size $job] || [dict get $job token] ne $token} { return }
    ::epdanalysis::finish [::tr EpdEngineNoAnswer]
}

proc ::epdanalysis::finish {err} {
    variable job
    if {![dict size $job]} { return }
    set j $job
    set job {}
    if {[dict get $j timeout] ne ""} {
        catch { after cancel [dict get $j timeout] }
    }
    set d [dict get $j data]
    dict set d error $err
    set cb [dict get $j onDone]
    if {$cb ne ""} { catch { {*}$cb $d } }
    return $d
}

# The result of the search in flight, updated as info lines arrive. The EPD
# loop uses it only through onInfo; this accessor is for a caller that wants the
# current line without waiting for bestmove.
proc ::epdanalysis::current {} {
    variable job
    if {![dict size $job]} { return "" }
    return [dict get $job data]
}

# Stop the search and report it as cancelled. The engine is closed when the EPD
# pass ends (or when close is called), not here: one stop may be followed by the
# loop's own cleanup.
proc ::epdanalysis::cancel {} {
    variable id
    variable job
    if {![dict size $job]} { return 0 }
    catch { ::engine::send $id StopGo }
    ::epdanalysis::finish "cancelled"
    return 1
}

proc ::epdanalysis::close {} {
    variable id
    variable engine
    if {[dict size $::epdanalysis::job]} { ::epdanalysis::finish "cancelled" }
    catch { ::engineNoWin::closeEngine $id }
    set engine ""
    return
}
