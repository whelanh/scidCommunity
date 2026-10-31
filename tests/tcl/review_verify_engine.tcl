# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_verify_engine.tcl -- drive the verifier's own loop with a stub engine.
#
#   tclsh tests/tcl/review_verify_engine.tcl
#
# The pure test shows what a disagreement means; this one feeds the verifier's
# messages in and checks that a scripted second engine really does withdraw the
# upgrade and hand the correction back.

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
source [file join $root tcl tools review_driver.tcl]
source [file join $root tcl tools review_verify.tcl]

# A stub engine: every Go answers with the scripted top move.
namespace eval ::engineNoWin {}
set ::closed {}
proc ::engineNoWin::initEngine {id name callback} { return 1 }
proc ::engineNoWin::closeEngine {id} { lappend ::closed $id }
namespace eval ::engine {}
set ::goes 0
set ::lastGo {}
proc ::engine::send {id msg {data ""}} {
    if {$msg ne "Go"} { return }
    set ::lastGo $data
    set top [lindex $::tops $::goes]
    incr ::goes
    after 0 [list ::reviewverify::message \
        [list InfoPV [list 1 20 20 100 50 0 0 0 30 cp {} [list $top d5]]]]
    after 0 [list ::reviewverify::message {InfoBestMove {}}]
    return
}

set ::cfg [list "Engine B" "/bin/true" {} {} 0 0 "" 1 {} {}]
set ::map [dict create plies 12 \
    moves [dict create 10 Nf5] \
    positions [dict create 9 "position startpos moves e2e4 e7e5 g1f3 b8c6 f1c4 g8f6"]]
set ::results [dict create 9 [dict create 1 [list 20 30 cp {Nf5 d5}]]]

proc verifyRun {top label} {
    set ::goes 0
    set ::done 0
    set ::corr ""
    set ::tops [list $top]
    set labels [dict create 10 $label]
    set ::lim [dict create depth 20 movetime 400]
    ::reviewverify::start $::cfg $::map $::results $labels $::lim \
        [list apply {{corr} {set ::corr $corr ; set ::done 1}}]
    if {!$::done} { vwait ::done }
    # The engine is closed on the next event turn, so the message loop that
    # delivered the last answer is done with it first.
    update
    return $::corr
}

puts "\nthe second engine disagrees"

set corr [verifyRun Be3 brilliant]
checkEq "the Brilliant upgrade is withdrawn" $corr [dict create 10 best]
checkEq "and the verifier was closed" [lindex $::closed end] reviewVerify
# The verifier is not a deeper search: it runs under the pass's own limits,
# including the time cap, so it cannot outrun what the review promised.
check "the verifier's Go is the pass's depth and cap" \
    [expr {[string first "depth 20" $::lastGo] >= 0 \
        && [string first "movetime 400" $::lastGo] >= 0 \
        && [string first "depth 24" $::lastGo] < 0}]

puts "\nand when it agrees"

set corr [verifyRun Nf5 brilliant]
checkEq "there is nothing to correct" $corr {}

puts "\nno engine, no verification"

set ::tops {}
set ::goes 0
set ::done 0
set ::corr "untouched"
::reviewverify::start $::cfg $::map $::results [dict create 10 best] [dict create depth 20] \
    [list apply {{corr} {set ::corr $corr ; set ::done 1}}]
checkEq "a pass with no candidates is not a callback" $::done 0

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
