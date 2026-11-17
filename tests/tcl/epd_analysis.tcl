#!/usr/bin/env tclsh
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# epd_analysis.tcl -- the Engine Window's messages as an EPD record, no Tk.
#
#   tclsh tests/tcl/epd_analysis.tcl
#
# The pass drives the Engine Window now, so this module holds no connection to
# test: it turns the window's raw InfoPV fields into the record the EPD writer
# and the report consume. The driving loop itself is in epd_analysis_window.tcl.

set fails 0
set checks 0
proc check {label cond {detail ""}} {
    incr ::checks
    if {$cond} {
        puts "  ok   $label"
    } else {
        incr ::fails
        if {$detail eq ""} { puts "  FAIL $label" } else { puts "  FAIL $label -- $detail" }
    }
}
proc checkEq {label got want} {
    check $label [expr {$got eq $want}] "got '$got' want '$want'"
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
# The module reports its reasons through tr; this harness has no language file.
proc ::tr {tag} { return $tag }
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools epd_analysis.tcl]

# A tclsh has no board; coordToSAN is the one C command the result record uses.
array set ::SAN {
    a1a8 {1.Ra8#}
    e7e5 {1...e5}
    d7d5 {2.d5}
    g1f3 {2.Nf3}
}
proc sc_pos {sub args} {
    if {$sub eq "coordToSAN"} {
        set uci [lindex $args 1]
        set out {}
        foreach u $uci {
            if {[info exists ::SAN($u)]} { lappend out $::SAN($u) } else { lappend out $u }
        }
        return $out
    }
    return ""
}

set fen {6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1}

puts "\none info line becomes the record"

set rec [::epdanalysis::dataFromInfo $fen {1 20 22 1000 500 0 0 120 30 cp 0 e7e5 d7d5}]
checkEq "the best move in SAN" [dict get $rec best_san] e5
checkEq "the PV in SAN" [dict get $rec pv_san] {e5 d5}
checkEq "the depth" [dict get $rec depth] 20
checkEq "the nodes" [dict get $rec nodes] 1000
checkEq "the score from the side to move" [dict get $rec score_stm] 0.3
checkEq "the score from White" [dict get $rec score_white] 0.3
checkEq "and no error" [dict get $rec error] ""

checkEq "a line from another MultiPV slot is not the record" \
    [::epdanalysis::dataFromInfo $fen {3 20 22 1000 500 0 0 120 30 cp 0 e7e5 d7d5}] ""
checkEq "a fail-high search is not an evaluation" \
    [::epdanalysis::dataFromInfo $fen {1 20 22 1000 500 0 0 120 30 lowerbound 0 e7e5}] ""

puts "\nSAN without a scoresheet number"

# The UCI display formatter numbers a Black move ("1...e5"); EPD and the report
# want plain SAN. coordToSAN is preferred, so the formatter cannot leak a move
# number into best_san or the pv opcode.
checkEq "the PV is plain SAN, not the numbered display line" \
    [::epdanalysis::pvSAN $fen {e7e5 d7d5}] {e5 d5}
# ... and the fallback is real: with coordToSAN unavailable (the position has no
# board, exactly the case the guard is for) pvSAN goes through the formatter, so
# the guard has to name the module the formatter actually lives in.
namespace eval ::ucifmt {}
proc ::ucifmt::formatPv {pv fen} { return "1...e5 2.d5" }
rename sc_pos ::real_sc_pos
checkEq "with no coordToSAN the ::ucifmt fallback is taken" \
    [::epdanalysis::pvSAN $fen {e7e5 d7d5}] {e5 d5}
rename ::real_sc_pos sc_pos
checkEq "a single move loses its scoresheet number" \
    [::epdanalysis::sanMove $fen d7d5] d5

puts "\nthe deepest line the window showed is the record"

set deep [::epdanalysis::dataFromInfo $fen {1 20 22 2000 500 0 0 140 20 cp 0 e7e5 d7d5}]
set shallow [::epdanalysis::dataFromInfo $fen {1 18 20 1500 500 0 0 120 15 cp 0 g1f3 g8f6}]
checkEq "a shallower line does not replace it" \
    [dict get [::epdanalysis::absorb $deep $shallow] depth] 20
# The bestmove belongs to the shallower re-search; the deeper line is the
# record, so the shallower search must not rewrite its move.
checkEq "with its PV" \
    [dict get [::epdanalysis::absorb $deep $shallow] pv_san] {e5 d5}
checkEq "and its score" \
    [dict get [::epdanalysis::absorb $deep $shallow] score_stm] 0.2
checkEq "a deeper line replaces it" \
    [dict get [::epdanalysis::absorb $shallow $deep] depth] 20
checkEq "an equal depth replaces it" \
    [dict get [::epdanalysis::absorb $shallow \
        [::epdanalysis::dataFromInfo $fen {1 18 20 900 500 0 0 90 5 cp 0 a1a8}]] \
        score_stm] 0.05
checkEq "an unparsable depth replaces it" \
    [dict get [::epdanalysis::absorb $deep \
        [::epdanalysis::dataFromInfo $fen {1 {} 20 900 500 0 0 90 5 cp 0 a1a8}]] \
        depth] ""

puts "\na bestmove with no line is still the answer"

set empty [::epdanalysis::emptyData $fen]
checkEq "the move" [dict get [::epdanalysis::withBestMove $empty e7e5 $fen] best_san] e5
checkEq "with no depth" [dict get [::epdanalysis::withBestMove $empty e7e5 $fen] depth] ""
checkEq "a line already holds the move, so the bestmove leaves it alone" \
    [dict get [::epdanalysis::withBestMove $deep g1f3 $fen] best_san] e5
checkEq "a null move is no move" \
    [dict get [::epdanalysis::withBestMove $empty 0000 $fen] best_san] ""

puts "\na Black-to-move score is turned for White"

set fen2 {4k3/8/8/8/8/8/8/4K2R b - - 0 1}
set rec2 [::epdanalysis::dataFromInfo $fen2 {1 18 20 500 250 0 0 80 30 cp 0 e8d7}]
checkEq "side-to-move score" [dict get $rec2 score_stm] 0.3
checkEq "White's score is the mirror" [dict get $rec2 score_white] -0.3

puts "\na mate keeps its distance and sign"

set mate [::epdanalysis::dataFromInfo $fen {1 20 22 900 500 0 0 100 3 mate 0 a1a8}]
checkEq "the mate distance for the side to move" [dict get $mate mate_stm] 3
checkEq "the mate distance for White" [dict get $mate mate_white] 3
checkEq "a mate for the side to move encodes positive" [::epdanalysis::mateCe + 3] 32761
checkEq "a mate against it encodes negative" [::epdanalysis::mateCe - 3] -32761

puts "\nthe report compares the move, not its display number"

proc procText {path name} {
    set f [open $path r]
    set src [read $f]
    close $f
    set from [string first "proc $name " $src]
    if {$from < 0} { return "" }
    set text ""
    foreach line [split [string range $src $from end] "\n"] {
        append text $line "\n"
        if {[info complete $text]} { break }
    }
    return $text
}
namespace eval epd {
    foreach name {normMove evalBestMove} {
        # $::root, not $root: Tcl 9 does not fall back to a global variable
        # when a read inside a namespace finds nothing local.
        eval [procText [file join $::root tcl file epd.tcl] $name]
    }
}
checkEq "a numbered SAN is normalised" [::epd::normMove "1...Qc7"] Qc7
# The report's own rows: the display number must not hide a match.
foreach {sought found want} {
    Qc7  {1...Qc7} TRUE
    Rc7  {1.Ra1}   FALSE
    O-O  {1...O-O} TRUE
    Rd8  {1.Rd8}   TRUE
    g3   {1.g3}    TRUE
    h5   {1...h5}  TRUE
    Nb5  {1.Nb5}   TRUE
} {
    checkEq "the report scores $sought against $found" \
        [::epd::evalBestMove $sought $found] $want
}
checkEq "numbered castling matches letter castling" \
    [::epd::evalBestMove O-O "1...0-0"] TRUE
checkEq "an avoid move still compares" \
    [::epd::evalBestMove {avoid Nf3} "1.Nf3"] FALSE

puts "\nthe pass holds no engine of its own"

set fh [open [file join $root tcl file epd.tcl] r]
set src [read $fh]
close $fh
foreach needle {::epdanalysis::open ::epdanalysis::ask ::epdanalysis::close \
        ::epdanalysis::cancel ::epdanalysis::message} {
    check "epd.tcl does not call $needle" [expr {[string first $needle $src] < 0}]
}
set fh [open [file join $root tcl tools epd_analysis.tcl] r]
set module [read $fh]
close $fh
foreach needle {::engineNoWin::initEngine ::engine::send} {
    check "the module does not open or drive an engine" \
        [expr {[string first $needle $module] < 0}]
}

puts "\nthe new EPD strings have English translations"
set ef [open [file join $root tcl lang english.tcl] r]
set english [read $ef]
close $ef
foreach key {
    EpdAnalysisTitle EpdAnalysisRunning EpdAnalysisMinTime
    EpdAnalysisStartFailed EpdAnalysisError EpdAnalysisStopped
    EpdAnalysisStopping EpdEngineNoResult EpdOnlyUci EpdEngineNoAnswer
} {
    check "translate E $key exists" \
        [expr {[string first "translate E $key " $english] >= 0}]
}

puts "\nno Analysis Engine window remains in the EPD path"

foreach needle {.analysisWin makeAnalysisWin ::analysis( toggleEngineAnalysis} {
    check "epd.tcl has no $needle" [expr {[string first $needle $src] < 0}]
}

puts "\n"
puts "$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
