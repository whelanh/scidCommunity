#!/usr/bin/env tclsh
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# engine_reply.tcl -- a reply survives the callback that closes its engine.
#
#   tclsh tests/tcl/engine_reply.tcl
#
# The one-shot connections (the threat probe, the verifier) open an engine, send
# one search and close the connection from inside the callback that receives the
# answer. ::engine::reply invoked that callback first and then walked the
# connection's client list -- which the callback's ::engine::close had already
# unset. The failure was invisible at the call site: the message had been
# delivered, so it surfaced as a stray background error.
#
# The engine side and the client side are real sockets, not stubs, because the
# contract is about what happens to a channel that close has shut: chan event,
# chan puts and chan close must all behave as they do against a live engine.

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
proc checkEq {label got want {detail ""}} {
    if {$detail eq ""} { set detail "got '$got' want '$want'" }
    check $label [expr {$got eq $want}] $detail
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl enginecomm.tcl]

# A connected pair of sockets. ::engine::close calls chan event on the engine
# side, and only a socket supports it; a pipe write end answers "channel is not
# readable" before the path under test is reached.
proc socketPair {} {
    set ::accepted ""
    set server [socket -server {apply {{chan addr port} {set ::accepted $chan}}} \
        -myaddr 127.0.0.1 0]
    set port [lindex [chan configure $server -sockname] 2]
    set client [socket 127.0.0.1 $port]
    vwait ::accepted
    chan close $server
    return [list $client $::accepted]
}

# Build the connection record ::engine::close and ::engine::destroy_ expect.
# Two independent socket pairs: the first is the engine link, the second is the
# network client's link, so what the client was sent can be read back from the
# far end. Returns the id.
proc newConn {id callback} {
    lassign [socketPair] engineSide enginePeer
    lassign [socketPair] clientSide clientPeer
    # A socket is fully buffered by default; a reply the test cannot read until
    # the channel closes would make the echo assertion untestable.
    chan configure $clientSide -buffering line
    set ::engconn(protocol_$id) uci
    set ::engconn(callback_$id) $callback
    set ::engconn(channel_$id) $engineSide
    set ::engconn(serverchannel_$id) {}
    set ::engconn(netclients_$id) [list [list $clientSide 127.0.0.1 1]]
    set ::engconn(waitReply_$id) {}
    set ::engconn(sendQueue_$id) {}
    set ::engconn(options_$id) {}
    # ::engine::connect requires the log hooks to exist before it opens a
    # connection, and rawsend reads logSend_ unconditionally on close.
    set ::engconn(logSend_$id) ""
    set ::enginePeer($id) $enginePeer
    set ::clientPeer($id) $clientPeer
    return $id
}

# What the network client was sent, or "" when it was closed without a write.
# The read yields first: a non-blocking gets on the loopback arrives one event
# later even though the write has already returned.
proc clientSaw {id} {
    set clientSide $::clientPeer($id)
    chan configure $clientSide -blocking 0
    after 100
    return [string trim [read $clientSide]]
}

puts "\na callback that closes the engine"

set ::seen ""
newConn rp [list apply {{msg} {
    set ::seen $msg
    ::engine::close rp
}}]
set rc [catch {::engine::reply rp {InfoBestMove {e2e4}}} err]
checkEq "the reply does not raise" $rc 0 $err
checkEq "and the callback still sees the message" $::seen {InfoBestMove {e2e4}}
check "the connection is torn down" [expr {![info exists ::engconn(channel_rp)]}]
checkEq "and no client is written to after the close" [clientSaw rp] ""

puts "\nclosing twice"

set rc [catch {::engine::close rp} err]
checkEq "a second close is a no-op" $rc 0 $err

puts "\nan ordinary reply, engine left open"

set ::seen ""
newConn rp2 [list apply {{msg} {set ::seen $msg}}]
set rc [catch {::engine::reply rp2 {InfoBestMove {d2d4}}} err]
checkEq "the reply does not raise" $rc 0 $err
checkEq "the callback sees the message" $::seen {InfoBestMove {d2d4}}
checkEq "and the client is echoed, unchanged" [clientSaw rp2] {InfoBestMove {d2d4}}
check "the connection survives" [expr {[info exists ::engconn(channel_rp2)]}]

puts "\nno clients at all"

set ::seen ""
newConn rp3 [list apply {{msg} {set ::seen $msg}}]
chan close [lindex $::engconn(netclients_rp3) 0 0]
set ::engconn(netclients_rp3) {}
set rc [catch {::engine::reply rp3 {InfoReady {}}} err]
checkEq "no clients is not an error" $rc 0 $err
checkEq "and the callback still runs" $::seen {InfoReady {}}

puts "\ndestroy_ with a local reply whose callback closes too"

set ::seen ""
newConn rp4 [list apply {{msg} {
    set ::seen $msg
    catch {::engine::close rp4}
}}]
set rc [catch {::engine::destroy_ rp4 {InfoDisconnected {}}} err]
checkEq "destroy_ does not raise" $rc 0 $err
checkEq "and the local reply reaches the callback" $::seen {InfoDisconnected {}}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
