#!/usr/bin/env tclsh
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# epd_analysis.tcl -- the EPD headless session without a board or Tk.
#
#   tclsh tests/tcl/epd_analysis.tcl

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

namespace eval ::enginecfg {}
proc ::enginecfg::get {name} {
    return [list $name /bin/true {} {} 0 0 {} 1 {} {}]
}

namespace eval ::engineNoWin {}
namespace eval ::engine {}
set ::opened {}
set ::closed 0
set ::sent {}
set ::engineCb ""
proc ::engineNoWin::initEngine {id name cb {options ""}} {
    lappend ::opened [list $id $name $options]
    set ::engineCb $cb
    return 1
}
proc ::engineNoWin::closeEngine {id} { incr ::closed ; return }
proc ::engine::send {id msg {data ""}} {
    lappend ::sent [list $id $msg $data]
    return
}

puts "\nthe headless session"

checkEq "a UCI preset opens" [::epdanalysis::open TestEngine] ""
checkEq "on its own connection, not an engine window slot" \
    [lindex $::opened 0 0] epdAnalysis
check "the first options ask for one line" \
    [expr {[string first "MultiPV 1" $::sent] >= 0}]

puts "\none position, one best move"

set ::done 0
set ::infos 0
set ::result ""
set fen {6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1}
set token [::epdanalysis::ask $fen 4000 \
    [list apply {{d} { set ::result $d ; set ::done 1 }}] \
    [list apply {{sought start data} {
        incr ::infos
        set ::infoBest [dict get $data best_san]
    }} $fen 0]]
check "the search has a token" [expr {$token ne ""}]
check "the Go asks for the position and the time" \
    [expr {[lindex $::sent end 1] eq "Go" \
        && [string first "position fen $fen" [lindex $::sent end 2]] >= 0 \
        && [string first "movetime 4000" [lindex $::sent end 2]] >= 0}]

{*}$::engineCb {InfoPV {1 20 22 1000 500 0 0 120 30 cp 0 e7e5 d7d5}}
checkEq "onInfo sees the line" $::infos 1
checkEq "with the result dict last, as message supplies it" $::infoBest e5
{*}$::engineCb {InfoBestMove {e7e5}}
checkEq "the answer is delivered once" $::done 1
checkEq "with the best move in SAN" [dict get $::result best_san] e5
checkEq "the PV in SAN" [dict get $::result pv_san] {e5 d5}
# The UCI display formatter numbers a Black move ("1...e5"); EPD and the report
# want plain SAN. coordToSAN is preferred, so the formatter cannot leak a move
# number into best_san or the pv opcode.
namespace eval uci {}
proc ::uci::formatPv {pv fen} { return "1...e5 2.d5" }
checkEq "the PV stays plain SAN, not the numbered display line" \
    [::epdanalysis::pvSAN $fen {e7e5 d7d5}] {e5 d5}
checkEq "a single move loses its scoresheet number" \
    [::epdanalysis::sanMove $fen d7d5] d5
checkEq "the depth" [dict get $::result depth] 20
checkEq "the nodes" [dict get $::result nodes] 1000
checkEq "the score from the side to move" [dict get $::result score_stm] 0.3
checkEq "the score from White" [dict get $::result score_white] 0.3
checkEq "and no error" [dict get $::result error] ""

puts "\na late shallower line keeps the deeper result"

set ::late 0
set ::lateBest ""
set token [::epdanalysis::ask $fen 4000 \
    [list apply {{d} { set ::result $d }}] \
    [list apply {{sought start data} {
        incr ::late
        set ::lateBest [dict get $data best_san]
    }} $fen 0]]
{*}$::engineCb {InfoPV {1 20 22 2000 500 0 0 140 20 cp 0 e7e5 d7d5}}
{*}$::engineCb {InfoPV {1 18 20 1500 500 0 0 120 15 cp 0 g1f3 g8f6}}
# The bestmove belongs to the shallower re-search; the deeper line is the
# record, so the shallower search must not rewrite its move.
{*}$::engineCb {InfoBestMove {g1f3}}
checkEq "the deeper depth is kept" [dict get $::result depth] 20
checkEq "with its PV" [dict get $::result pv_san] {e5 d5}
checkEq "and its score" [dict get $::result score_stm] 0.2
checkEq "the deeper line's move is the answer" [dict get $::result best_san] e5
checkEq "the shallower line still reached the solve timer" $::late 2
checkEq "with its own move" $::lateBest Nf3

puts "\na bestmove with no line is still the answer"

set token [::epdanalysis::ask $fen 1000 [list apply {{d} { set ::result $d }}]]
{*}$::engineCb {InfoBestMove {e7e5}}
checkEq "the move" [dict get $::result best_san] e5
checkEq "with no depth" [dict get $::result depth] ""

puts "\na Black-to-move score is turned for White"

set fen2 {4k3/8/8/8/8/8/8/4K2R b - - 0 1}
set token [::epdanalysis::ask $fen2 1000 [list apply {{d} { set ::result $d }}]]
{*}$::engineCb {InfoPV {1 18 20 500 250 0 0 80 30 cp 0 e8d7}}
{*}$::engineCb {InfoBestMove {e8d7}}
checkEq "side-to-move score" [dict get $::result score_stm] 0.3
checkEq "White's score is the mirror" [dict get $::result score_white] -0.3

puts "\na mate keeps its distance and sign"

set token [::epdanalysis::ask $fen 1000 [list apply {{d} { set ::result $d }}]]
{*}$::engineCb {InfoPV {1 20 22 900 500 0 0 100 3 mate 0 a1a8}}
{*}$::engineCb {InfoBestMove {a1a8}}
checkEq "the mate distance for the side to move" [dict get $::result mate_stm] 3
checkEq "the mate distance for White" [dict get $::result mate_white] 3
checkEq "a mate for the side to move encodes positive" [::epdanalysis::mateCe + 3] 32761
checkEq "a mate against it encodes negative" [::epdanalysis::mateCe - 3] -32761

puts "\nstop, disconnect and a second position"

set token [::epdanalysis::ask $fen 1000 [list apply {{d} { set ::result $d }}]]
::epdanalysis::cancel
checkEq "Cancel answers the pending search" [dict get $::result error] cancelled

set token [::epdanalysis::ask $fen 1000 [list apply {{d} { set ::result $d }}]]
{*}$::engineCb {InfoDisconnected {}}
checkEq "a disconnect answers it too" [dict get $::result error] EpdEngineDisconnected

set token [::epdanalysis::ask $fen 1000 [list apply {{d} { set ::result $d }}]]
{*}$::engineCb {InfoPV {1 12 14 100 50 0 0 40 -20 cp 0 a1a8}}
{*}$::engineCb {InfoBestMove {a1a8}}
checkEq "a second position can be searched on the same connection" \
    [dict get $::result best_san] Ra8#
checkEq "with its own score" [dict get $::result score_stm] -0.2

::epdanalysis::close
checkEq "closing closes the one connection" $::closed 2

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
namespace eval epd {}
namespace eval epd {
    foreach name {normMove evalBestMove} {
        eval [procText [file join $root tcl file epd.tcl] $name]
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

puts "\nthe new EPD strings have English translations"
set ef [open [file join $root tcl lang english.tcl] r]
set english [read $ef]
close $ef
foreach key {
    EpdAnalysisTitle EpdAnalysisRunning EpdAnalysisMinTime
    EpdAnalysisStartFailed EpdAnalysisError EpdAnalysisStopped
    EpdAnalysisStopping EpdEngineNotStarted EpdEngineNoResult
    EpdSearchAlreadyRunning EpdNoEngineConfigured EpdOnlyUci
    EpdEngineDisconnected EpdEngineNoAnswer
} {
    check "translate E $key exists" \
        [expr {[string first "translate E $key " $english] >= 0}]
}

puts "\nno Analysis Engine window remains in the EPD path"

set fh [open [file join $root tcl file epd.tcl] r]
set src [read $fh]
close $fh
foreach needle {.analysisWin makeAnalysisWin ::analysis( toggleEngineAnalysis} {
    check "epd.tcl has no $needle" [expr {[string first $needle $src] < 0}]
}

puts "\n"
puts "$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
