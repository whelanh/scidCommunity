# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# engine_reply.tcl -- a reply survives a callback that closes its engine.
#
#   tclsh tests/tcl/engine_reply.tcl
#
# A one-shot probe (the threat probe, the verifier) closes its engine when the
# last answer arrives. That close happens inside ::engine::reply's callback, and
# it used to unset the client list the same proc was about to walk.

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
source [file join $root tcl enginecomm.tcl]

puts "\na callback that closes the engine"

set ::got ""
set ::engconn(callback_rp) [list apply {{msg} {
    unset ::engconn(netclients_rp)
    set ::got $msg
}}]
set ::engconn(netclients_rp) {}
set rc [catch { ::engine::reply rp {InfoGo {}} } err]
checkEq "the reply does not raise" $rc 0
checkEq "and the callback still sees the message" $::got {InfoGo {}}

puts "\nan ordinary reply with no clients"

set ::got ""
set ::engconn(callback_rp) [list apply {{msg} {set ::got $msg}}]
set ::engconn(netclients_rp) {}
set rc [catch { ::engine::reply rp {InfoBestMove {e2e4}} } err]
checkEq "no clients is not an error" $rc 0
checkEq "and the message is the engine's" $::got {InfoBestMove {e2e4}}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
