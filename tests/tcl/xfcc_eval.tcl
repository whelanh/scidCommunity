# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# xfcc_eval.tcl -- the Evaluate button of the ICCF/LSS windows, without Tk.
#
#   tclsh tests/tcl/xfcc_eval.tcl
#
# The engine layer and the database are stubbed. Checked: only Your Turn games
# that sit exactly at the server's move count are searched, the engine gets the
# F2 preset's limits (or the fixed fallback), each best move is committed to
# its own database game, and a cancel or lost engine ends the pass cleanly.

set fails 0
proc check {label cond} {
    if {$cond} { puts "  ok   $label" } else { incr ::fails ; puts "  FAIL $label" }
}
proc checkEq {label got want} { check "$label (got '$got')" [expr {$got eq $want}] }

set root [file normalize [file join [file dirname [info script]] .. ..]]
proc update {args} {}
proc catch_btn {} {}
proc tk_messageBox {args} { lappend ::boxes $args ; return ok }
proc winfo {args} { return 1 }
array set ::tr {Cancel Cancel
  LSSEvaluate Evaluate LSSEvaluating {Evaluating %s of %s} LSSEvaluated {done %s skipped %s failed %s}
  LSSNoDatabase nodb LSSNeedUpdate needupdate LSSEvaluateNoEngine noengine}

# environment
proc sc_base {args} { return 1 }
proc sc_game {sub args} {
    switch $sub {
        variant { return 0 }
        push - pop { return }
        load { set ::loaded [lindex $args 0] ; return }
    }
}
proc sc_move {args} {}
proc sc_pos {args} { return $::fens($::loaded) }
namespace eval ::chessboard {}
proc ::chessboard::fromFen {f} { return [dict create fen $f] }
proc ::chessboard::legalMoves {p} { return [expr {[dict get $p fen] eq "mated" ? {} : {e2e4}}] }
namespace eval ::enginewin {}
namespace eval ::enginecfg {}
proc ::enginecfg::windowEngine {id last} { return $::f2 }
proc ::enginecfg::get {n} { return [expr {$n eq "" ? "" : [list $n]}] }
namespace eval ::enginelimits {}
proc ::enginelimits::forName {n {fb {}}} { return [expr {$::legacy ? [dict merge {depth {} movetime {}} $fb] : $::lim}] }
set ::legacy 0
proc ::enginelimits::goLimits {l} {
    set o {} ; foreach k {depth movetime} { if {[dict exists $l $k] && [dict get $l $k] ne ""} { lappend o [list $k [dict get $l $k]] } } ; return $o
}
namespace eval ::engineNoWin {}
proc ::engineNoWin::initEngine {id name cb} { set ::cb $cb ; lappend ::log "init $name" }
proc ::engineNoWin::closeEngine {id} { lappend ::log close }
namespace eval ::engine {}
proc ::engine::send {id what {data {}}} {
    if {$what eq "Go"} {
        lappend ::log "go $data"
        regexp {fen (\S+)} [lindex $data 0] -> f
        after idle [list {*}$::cb [list InfoBestMove [list $::reply($f)]]]
    }
}
namespace eval ::reviewprogress {}
set ::commits {}
proc ::reviewprogress::commitMoves {g moves {note ""}} { lappend ::commits [list $g $moves] ; return "" }
# the window namespace
namespace eval ::lss {
    variable games {x} yourTurnGames {1 2 3 4 5} statusText ""
    array set gameData {} ; array set gameToDbMap {}
}
proc ::lss::dictGetDefault {d k def} { expr {[dict exists $d $k] ? [dict get $d $k] : $def} }
proc ::lss::parseSanTokens {s} { return $s }
proc ::lss::dbMoves {n} { return $::dbm($n) }
proc ::lss::populateGameList {} { set ::repopulated 1 }
foreach {id srv db fen} {
  1 {e4 e5} {e4 e5} fenA
  2 {d4}    {d4 d5} fenB
  3 {c4}    {c4}    mated
  4 {Nf3}   {Nf3}   fenD
  5 {b3}    {b3}    fenE } {
    set ::lss::gameData($id) [dict create moves $srv]
    set ::lss::gameToDbMap($id) [expr {$id * 10}]
    set ::dbm([expr {$id * 10}]) $db
    set ::fens([expr {$id * 10}]) $fen
}
unset ::lss::gameToDbMap(5)   ;# no database game for this one
array set ::reply {fenA a2a3 fenD g1f3}
set ::f2 "Stockfish"
set ::lim {depth 20 movetime {}}
set ::log {}

source [file join $root tcl tools xfcc_eval.tcl]

puts "-- run"
set ::xfcceval::EngineId xfccEval
::xfcceval::run lss LSS .lss
checkEq "committed moves" $::commits {{10 a2a3} {40 g1f3}}
checkEq "limits sent" [lindex $::log 1] "go {position fen fenA} {{depth 20}}"
check "engine opened with F2 preset" [expr {[lindex $::log 0] eq "init Stockfish"}]
check "engine closed" [expr {[lindex $::log end] eq "close"}]
checkEq "status" $::lss::statusText "done 2 skipped 3 failed 0"
check "list refreshed" [info exists ::repopulated]
check "idle after run" [expr {!$::xfcceval::active}]

puts "-- legacy preset: the window's global limits apply"
set ::legacy 1
set ::enginewin::depth_limit 66 ; set ::enginewin::movetime_limit 310000
checkEq "global limits used" [::xfcceval::limits Stockfish] {{depth 66} {movetime 310000}}
set ::legacy 0
puts "-- fallback limits"
set ::lim {depth {} movetime {}}
checkEq "fixed movetime" [::xfcceval::limits Stockfish] {{movetime 5000}}

puts "-- no engine"
set ::f2 ""
set ::boxes {}
::xfcceval::run lss LSS .lss
checkEq "refused with message" [lindex $::boxes 0 1] noengine 

puts [expr {$fails ? "$fails FAILED" : "all passed"}]
exit [expr {$fails ? 1 : 0}]
