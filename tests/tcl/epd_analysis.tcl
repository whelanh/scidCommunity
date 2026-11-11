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
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools epd_analysis.tcl]

# A tclsh has no board; coordToSAN is the one C command the result record uses.
array set ::SAN {
    a1a8 Ra8#
    e7e5 e5
    d7d5 d5
    g1f3 Nf3
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
checkEq "the depth" [dict get $::result depth] 20
checkEq "the nodes" [dict get $::result nodes] 1000
checkEq "the score from the side to move" [dict get $::result score_stm] 0.3
checkEq "the score from White" [dict get $::result score_white] 0.3
checkEq "and no error" [dict get $::result error] ""

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

puts "\nstop, disconnect and a second position"

set token [::epdanalysis::ask $fen 1000 [list apply {{d} { set ::result $d }}]]
::epdanalysis::cancel
checkEq "Cancel answers the pending search" [dict get $::result error] cancelled

set token [::epdanalysis::ask $fen 1000 [list apply {{d} { set ::result $d }}]]
{*}$::engineCb {InfoDisconnected {}}
checkEq "a disconnect answers it too" [dict get $::result error] "the engine disconnected"

set token [::epdanalysis::ask $fen 1000 [list apply {{d} { set ::result $d }}]]
{*}$::engineCb {InfoPV {1 12 14 100 50 0 0 40 -20 cp 0 a1a8}}
{*}$::engineCb {InfoBestMove {a1a8}}
checkEq "a second position can be searched on the same connection" \
    [dict get $::result best_san] Ra8#
checkEq "with its own score" [dict get $::result score_stm] -0.2

::epdanalysis::close
checkEq "closing closes the one connection" $::closed 2

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
