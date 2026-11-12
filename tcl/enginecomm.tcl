########################################################################
# Copyright (C) 2020 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

### Manage the communication with chess engines

# Communication takes place through the exchange of messages.
# Every local or remote client can send a message and the reply will be
# broadcasted to all the clients.
# Events:
# connection local or remote    >> InfoConfig
# net client disconnect         >> InfoConfig
# engine crash/local disconnect >> InfoDisconnected
# Messages from clients:
# SetOptions >> InfoConfig
# NewGame    >> InfoReady
# StopGo     >> InfoReady
# Go         >> InfoGo
#            >> InfoPV replies will be sent repeatedly by the engine until a new
#               message is received or one of the Go's limits is reached.
#            >> InfoBestMove if a limit has been reached.
#
# message InfoConfig {
#   enum Protocol {
#     "uci";
#     "xboard";
#     "network";
#   }
#   Protocol protocol = 1;
#
#   repeated string net_clients = 2;
#
#   enum OptionType {
#     "text";
#     "file";
#     "path";
#     "spin";
#     "slider";
#     "check";
#     "combo";
#     "button";
#     "save";
#     "reset";
#   }
#   message Option {
#     string name = 1;
#     string value = 2;
#     OptionType type = 3 [default = text];
#     string default = 4;
#     int32 min = 5;
#     int32 max = 6;
#     repeated string var = 7;
#     bool internal = 8 [default = false];
#   }
#   repeated Option options = 3;
# }
#
# message InfoDisconnected {
#   string error_msg = 1;
# }
#
# message InfoReady {
# }
#
# message InfoGo {
#   string position = 1;
#   repeated Limit limits = 2;
# }
#
# message InfoPV {
#   int32 multipv = 1;
#   int32 depth = 2;
#   int32 seldepth = 3;
#   int32 nodes = 4;
#   int32 nps = 5;
#   int32 hashfull = 6;
#   int32 tbhits = 7;
#   int32 time = 8;
#   int32 score = 9;
#   enum ScoreType {
#     "cp"
#     "mate"
#     "lowerbound"
#     "upperbound"
#   }
#   Score score_type = 10;
#   message ScoreWDL {
#     "win";
#     "draw";
#     "lose";
#   }
#   ScoreWDL score_wdl = 11;
#   string pv = 12;
# }
#
# message InfoBestMove {
#   string best_move = 1;
#   string ponder_move = 2;
# }
# The ponder move is the one an engine expects back after a "go ponder", and it
# is empty when the engine did not name one. Clients that only play the move
# read the first element (lindex $data 0), as they always have.
#
# Sent to the engine to change the value of one or more options.
# message SetOptions {
#   message Option {
#     string name = 1;
#     string value = 2;
#   }
#   repeated Option options = 1;
# }
#
# Sent to the engine to signal a new game or analysis and to specify
# the desired thinking output.
# message NewGame {
#   enum Option {
#     "analysis";
#     "chess960";
#     "ponder";
#     "post_pv";
#     "post_wdl";
#   }
#   repeated Option options = 1;
# }
#
# Sent to the engine to ask it to interrupt a previous Go message.
# message StopGo {
# }
#
# Sent to the engine to ask it to start thinking.
# message Go {
#   string position = 1;
#
#   enum LimitType {
#     "wtime"
#     "btime"
#     "winc"
#     "binc"
#     "movestogo"
#     "movetime"
#     "depth"
#     "nodes"
#     "mate"
#   }
#   message Limit {
#     LimitType limit = 1;
#     uint32 value = 2;
#   }
#   repeated Limit limits = 2;
# }

namespace eval engine {}

# Sets the hooks for logging the received and sent i/o (default: none).
# Should be invoked before connecting to the engine.
proc ::engine::setLogCmd {id {recv ""} {send ""}} {
    set ::engconn(logRecv_$id) $recv
    set ::engconn(logSend_$id) $send
}

# Starts a new engine process or connects to a remote engine.
# If protocols is not provided uses "uci" first and after 3s "xboard".
# If protocols is "network" opens a socket (indicated as host:port).
# Messages from the engine will be sent to @p callback.
# An exception is raised in case of error.
proc ::engine::connect {id callback exe_or_host args {protocols {uci xboard}}} {
    if {![info exists ::engconn(logSend_$id)]} {
        error "Set the log commands with ::engine::setLogCmd"
    }
    ::engine::close $id
    if {$protocols eq "network"} {
        set channel [socket {*}[split $exe_or_host :]]
    } else {
        set channel [open [list | $exe_or_host {*}$args] "r+"]
    }
    ::engine::init_ $id $channel $callback
    chan configure $channel -buffering line -blocking 0
    ::engine::handshake_ $id $protocols
    chan event $channel readable "::engine::onMessages_ $id $channel"
}

# If @p port is empty stops accepting network connection. Otherwise accept network
# connection on the specified port (if port is 0 use an automatic port).
# An exception is raised in case of error.
# Returns the listening port (empty if none).
proc ::engine::netserver {id {port ""}} {
    ::engine::closeServer_ $id
    if {$port == ""} {
        return ""
    }
    set ::engconn(serverchannel_$id) \
        [socket -server [list ::engine::connectd_ $id] $port]

    set sockname [chan configure $::engconn(serverchannel_$id) -sockname]
    return [lindex $sockname 2]
}

# Close the engine
proc ::engine::close {id} {
    if {[info exists ::engconn(channel_$id)]} {
        chan event $::engconn(channel_$id) readable {}
        if {$::engconn(protocol_$id) ne "network"} {
            if {$::engconn(waitReply_$id) eq "Go"} {
                {*}$::engconn(StopGo$id)
            }
            ::engine::rawsend $id "quit"
        }
        ::engine::destroy_ $id
    }
}

proc ::engine::pid {id} {
    if {![info exists ::engconn(channel_$id)]} {
        error "The engine is not open"
    }
    return [::pid $::engconn(channel_$id)]
}

# Sends a message to the engine.
# If the engine is local and a reply to a previous message is expected,
# the message is queued and sent after the reply has arrived.
# Sending a message also cancels queued "Go" messages.
# The "StopGo" message is always sent immediately, but only if the engine is thinking.
proc ::engine::send {id msg {msgData ""}} {
    if {![info exists ::engconn(channel_$id)]} {
        error "The engine is not open"
    }

    if {$::engconn(protocol_$id) eq "network"} {
        ::engine::rawsend $id [list $msg $msgData]
        return
    }
    if {$::engconn(waitReply_$id) eq "Go"} {
        set ::engconn(waitReply_$id) "StopGo"
        {*}$::engconn(StopGo$id)
    }
    if {[set idx [lsearch -index 0 $::engconn(sendQueue_$id) "Go"]] != -1} {
        set ::engconn(sendQueue_$id) [lreplace $::engconn(sendQueue_$id) $idx $idx]
    }
    if {$msg eq "StopGo"} {
        set ::engconn(sendQueue_$id) [linsert $::engconn(sendQueue_$id) 0 [list $msg $msgData]]
    } else {
        lappend ::engconn(sendQueue_$id) [list $msg $msgData]
    }
    if {$::engconn(waitReply_$id) == ""} {
        ::engine::done_ $id
    }
}

# The state one connection keeps about the engine on its far end ---------------
#
# A client that holds what an engine answered (the score of the search in
# flight, the move it gave, the move it expects back, its MultiPV width) and
# what the client gives the engine (the clock and the limits of the search)
# keeps it here, under the connection's own id. It is not a shared array keyed
# by engine slot number: two connections -- an opponent and a coach, two windows
# -- each hold their own record, so one cannot overwrite the other's score, move
# or clock, and a connection that dies takes its state with it rather than
# leaving a value that belongs to an engine nobody is talking to any more.
#
# The fields are the client's; ::enginecomm does not read them. The defaults are
# the caller's, so a field that was never set is a value the caller chose rather
# than an array error.

# One field of @p id's state, or @p default when it was never set.
proc ::engine::state {id field {default ""}} {
    if {![info exists ::engconn(state_$id)]} { return $default }
    set state $::engconn(state_$id)
    if {![dict exists $state $field]} { return $default }
    return [dict get $state $field]
}

# Set one field of @p id's state and return the value.
proc ::engine::setState {id field value} {
    if {![info exists ::engconn(state_$id)]} { set ::engconn(state_$id) {} }
    dict set ::engconn(state_$id) $field $value
    return $value
}

# Forget one field. A field the connection did not hold is not an error.
proc ::engine::unsetState {id field} {
    if {![info exists ::engconn(state_$id)]} { return }
    if {![dict exists $::engconn(state_$id) $field]} { return }
    dict unset ::engconn(state_$id) $field
    return
}

# True while @p id still names a live connection: the one a reply would be
# delivered on, and the one a message can still be sent to.
proc ::engine::connected {id} {
    return [::engine::open_ $id]
}

proc ::engine::init_ {id channel callback} {
    set ::engconn(protocol_$id) {}
    set ::engconn(callback_$id) $callback
    set ::engconn(channel_$id) $channel
    set ::engconn(serverchannel_$id) {}
    set ::engconn(netclients_$id) {}
    set ::engconn(waitReply_$id) {}
    set ::engconn(sendQueue_$id) {}

    set ::engconn(options_$id) {}
    # A new connection starts with no state: what the previous engine under this
    # id answered is not this engine's.
    set ::engconn(state_$id) {}
}

proc ::engine::destroy_ {id {localReply ""}} {
    after cancel [list ::engine::done_ $id]
    if {[info exists ::engconn(nextHandshake_$id)]} {
        after cancel $::engconn(nextHandshake_$id)
    }

    chan close $::engconn(channel_$id)
    ::engine::closeServer_ $id

    unset ::engconn(protocol_$id)
    unset ::engconn(channel_$id)
    unset ::engconn(serverchannel_$id)
    unset ::engconn(waitReply_$id) ; # the message to be answered
    unset ::engconn(sendQueue_$id) ; # the queue of messages waiting to be sent

    # When the engine's output is parsed its options and PV infos are stored in this vars:
    unset ::engconn(options_$id)
    unset -nocomplain ::engconn(InfoPV_$id)
    unset -nocomplain ::engconn(InfoBestMove_$id)
    # What the client kept about this engine goes with it: a score or a move
    # from a connection that is gone must not be read as the next one's. A
    # connection built by hand (a harness) may never have had any.
    unset -nocomplain ::engconn(state_$id)

    unset -nocomplain ::engconn(nextHandshake_$id)

    # Functions that converts messages to uci or xboard.
    unset -nocomplain ::engconn(SetOptions$id)
    unset -nocomplain ::engconn(NewGame$id)
    unset -nocomplain ::engconn(Go$id)
    unset -nocomplain ::engconn(StopGo$id)
    unset -nocomplain ::engconn(parseline$id)

    if {$localReply != ""} {
        set ::engconn(netclients_$id) {}
        ::engine::reply $id $localReply
    }
    unset ::engconn(netclients_$id)
    unset ::engconn(callback_$id)
}

proc ::engine::closeServer_ {id} {
    if {$::engconn(serverchannel_$id) != ""} {
        chan close $::engconn(serverchannel_$id)
    }
    set ::engconn(serverchannel_$id) ""
    foreach netchannel $::engconn(netclients_$id) {
        chan close [lindex $netchannel 0]
    }
    set ::engconn(netclients_$id) {}
}

proc ::engine::handshake_ {id protocols} {
    set ::engconn(protocol_$id) [lindex $protocols 0]
    switch $::engconn(protocol_$id) {
      "uci" {
        set ::engconn(SetOptions$id) [list ::uci::sendOptions $id]
        set ::engconn(NewGame$id) [list ::uci::sendNewGame $id]
        set ::engconn(Go$id) [list ::uci::sendGo $id]
        set ::engconn(StopGo$id) [list ::engine::rawsend $id "stop"]
        set ::engconn(parseline$id) "::uci::parseline"

        set ::engconn(waitReply_$id) "hello"
        ::engine::rawsend $id "uci"
      }
      "xboard" {
        set ::engconn(SetOptions$id) [list ::xboard::sendOptions $id]
        set ::engconn(NewGame$id) [list ::xboard::sendNewGame $id]
        set ::engconn(Go$id) [list ::xboard::sendGo $id]
        set ::engconn(StopGo$id) [list ::xboard::sendStopGo $id]
        set ::engconn(parseline$id) "::xboard::parseline"

        set ::engconn(waitReply_$id) "hello"
        ::engine::rawsend $id "xboard"
        ::engine::rawsend $id "protover 2"
      }
      "network" {
      }
      default {
        error "Unknown engine protocol"
      }
    }
    if {[llength $protocols] > 1} {
        set next [list [lrange $protocols 1 end]]
        set ::engconn(nextHandshake_$id) [after 2000 ::engine::handshake_ $id $next]
    } else {
        unset -nocomplain ::engconn(nextHandshake_$id)
        if {$::engconn(protocol_$id) eq "xboard"} {
            # TODO: this hack is necessary for old engines like phalanx
            after 2000 [list ::engine::done_ $id]
        }
    }
}

# Accept a network connection and creates the corresponding channel.
proc ::engine::connectd_ {id channel clientaddr clientport} {
    lappend ::engconn(netclients_$id) [list $channel $clientaddr $clientport]
    chan configure $channel -buffering line -blocking 0
    chan event $channel readable "::engine::forwardNetMsg_ $id $channel"
    ::engine::replyInfoConfig $id
}

# Forward the messages received from the network.
# When a network client disconnects a InfoConfig message is sent to the local
# callback and the other network clients.
proc ::engine::forwardNetMsg_ {id channel} {
    chan event $channel readable {}

    # A disconnected channel creates a readable event with no input
    if {[chan eof $channel]} {
        chan close $channel
        set idx [lsearch -exact -index 0 $::engconn(netclients_$id) $channel]
        set ::engconn(netclients_$id) [lreplace $::engconn(netclients_$id) $idx $idx]
        ::engine::replyInfoConfig $id
        return
    }
    while {[set msg [chan gets $channel]] != ""} {
        ::engine::send $id {*}$msg
    }
    chan event $channel readable "::engine::forwardNetMsg_ $id $channel"
}

# Is the connection still open under this id, and still the one the caller was
# reading? A callback is arbitrary code: a one-shot connection closes its engine
# when the answer it asked for arrives, and ::engine::destroy_ unsets the channel
# while the reader that delivered the message still has state to touch.
proc ::engine::open_ {id {channel ""}} {
    if {![info exists ::engconn(channel_$id)]} { return 0 }
    if {$channel ne "" && $::engconn(channel_$id) ne $channel} { return 0 }
    return 1
}

# Reads a line from the local engine or a reply message from a network engine.
# Parse local input accordingly to the engine protocol and sends the replies.
proc ::engine::onMessages_ {id channel} {
    chan event $channel readable {}

    # A disconnected channel creates a readable event with no input
    if {[chan eof $channel]} {
        ::engine::destroy_ $id [list InfoDisconnected ""]
        return
    }
    while {[set line [chan gets $channel]] != ""} {
        if {$::engconn(logRecv_$id) != ""} {
            {*}$::engconn(logRecv_$id) $line
            if {![::engine::open_ $id $channel]} { return }
        }
        if {$::engconn(protocol_$id) eq "network"} {
            ::engine::reply $id $line
            if {![::engine::open_ $id $channel]} { return }
        } elseif {[$::engconn(parseline$id) $id $line]} {
            if {[info exists ::engconn(InfoBestMove_$id)]} {
                if {$::engconn(waitReply_$id) ne "StopGo"} {
                    ::engine::reply $id [list InfoBestMove $::engconn(InfoBestMove_$id)]
                    if {![::engine::open_ $id $channel]} { return }
                }
                unset -nocomplain ::engconn(InfoBestMove_$id)
            }
            ::engine::done_ $id
            if {![::engine::open_ $id $channel]} { return }
        }
        if {[info exists ::engconn(InfoPV_$id)]} {
            if {$::engconn(waitReply_$id) ne "StopGo"} {
                ::engine::reply $id [list InfoPV $::engconn(InfoPV_$id)]
                if {![::engine::open_ $id $channel]} { return }
            }
            unset -nocomplain ::engconn(InfoPV_$id)
        }
    }
    if {![::engine::open_ $id $channel]} { return }
    chan event $channel readable "::engine::onMessages_ $id $channel"
}

proc ::engine::done_ {id} {
    if {![::engine::open_ $id]} { return }
    # The connection this timer belongs to. A callback that closes and
    # reconnects the same id has replaced it; the replacement is a different
    # operation, and its waitReply_/queue are not this one's to clear.
    set channel $::engconn(channel_$id)
    after cancel [list ::engine::done_ $id]
    switch $::engconn(waitReply_$id) {
        "hello" {
            if {[info exists ::engconn(nextHandshake_$id)]} {
                after cancel $::engconn(nextHandshake_$id)
                unset ::engconn(nextHandshake_$id)
            }
            ::engine::replyInfoConfig $id
         }
        "SetOptions" { ::engine::replyInfoConfig $id }
        "NewGame" { ::engine::reply $id [list InfoReady ""] }
    }
    if {![::engine::open_ $id $channel]} { return }
    set ::engconn(waitReply_$id) ""

    while { [llength $::engconn(sendQueue_$id)] } {
        lassign [lindex $::engconn(sendQueue_$id) 0] msg msgData
        set idx 1
        if {$msg eq "SetOptions"} {
            # Squash sequential SetOptions messages
            while {[lindex $::engconn(sendQueue_$id) $idx 0] eq "SetOptions"} {
                lappend msgData {*}[lindex $::engconn(sendQueue_$id) $idx 1]
                incr idx
            }
        }
        set ::engconn(sendQueue_$id) [lrange $::engconn(sendQueue_$id) $idx end]

        if {$msg eq "StopGo"} {
            # The "StopGo" message was already sent in ::engine::send
            ::engine::reply $id [list InfoReady ""]
            if {![::engine::open_ $id $channel]} { return }
            continue
        }
        set ::engconn(waitReply_$id) $msg
        if {$msgData eq ""} {
            {*}$::engconn($msg$id)
        } else {
            {*}$::engconn($msg$id) $msgData
        }
        if {$msg eq "Go"} {
            # Immediately send an InfoGo reply
            # A send hook is arbitrary code and may have closed the engine.
            ::engine::reply $id [list InfoGo $msgData]
            if {![::engine::open_ $id $channel]} { return }
        }
        break
    }
}

# Sends a reply to the local callback and all the remote clients.
proc ::engine::reply {id msg} {
    # A reply can arrive after the connection was torn down (a late timer, a
    # send hook): there is no callback to run and nothing to echo to.
    if {![info exists ::engconn(callback_$id)]} { return }
    # The channel this reply belongs to. The callback is user code and a
    # one-shot connection closes its engine when the answer arrives; a callback
    # that closes and reconnects the same id has replaced the channel, and the
    # replacement is a different operation which must not receive this message
    # or be walked as if it were the old one. destroy_ unsets the channel before
    # its local reply, so an empty capture is "closed" rather than "any".
    set channel ""
    catch { set channel $::engconn(channel_$id) }
    {*}$::engconn(callback_$id) $msg
    if {$channel eq "" || ![::engine::open_ $id $channel]} { return }
    foreach netchannel $::engconn(netclients_$id) {
        catch { chan puts [lindex $netchannel 0] $msg }
    }
}

proc ::engine::replyInfoConfig {id} {
    ::engine::reply $id [list InfoConfig \
        [list $::engconn(protocol_$id) $::engconn(netclients_$id) $::engconn(options_$id)]]
}

# Helper functions used by ::uci and ::xboard
# Return the type of the option
proc ::engine::updateOption {id name value} {
    set idx [lsearch -exact -index 0 $::engconn(options_$id) $name]
    if {$idx != -1} {
        set elem [lindex $::engconn(options_$id) $idx]
        set elem [lreplace $elem 1 1 $value]
        set ::engconn(options_$id) [lreplace $::engconn(options_$id) $idx $idx $elem]
        return [lindex $elem 2]
    }
    return ""
}

proc ::engine::rawsend {n msg} {
    chan puts $::engconn(channel_$n) $msg
    if {$::engconn(logSend_$n) != ""} {
        {*}$::engconn(logSend_$n) $msg
    }
}

namespace eval uci {}
namespace eval xboard {}

proc ::uci::sendOptions {id msgData}  {
    foreach option $msgData {
        lassign $option name value
        set type [::engine::updateOption $id $name $value]
        if {$type eq "button"} {
            ::engine::rawsend $id "setoption name $name"
        } else {
            ::engine::rawsend $id "setoption name $name value $value"
        }
    }
    ::engine::rawsend $id "isready"
}

proc ::xboard::sendOptions {id msgData} {
    foreach option $msgData {
        lassign $option name value
        set type [::engine::updateOption $id $name $value]
        if {$name in {memory cores egtpath} } {
            ::engine::rawsend $id "$name $value"
        } elseif {$value eq ""} {
            ::engine::rawsend $id "option $name"
        } else {
            if {$type eq "check"} {
                if {$value eq "true"} {
                    set value 1
                } else {
                    set value 0
                }
            }
            ::engine::rawsend $id "option $name=$value"
        }
    }
    after 200 [list ::engine::done_ $id]
}

proc ::uci::sendNewGame {id msgData} {
    if {[lsearch -index 0 $::engconn(options_$id) "UCI_AnalyseMode"] != -1} {
        set analyze [expr {"analysis" in $msgData ? "true" :"false"}]
        ::engine::rawsend $id "setoption name UCI_AnalyseMode value $analyze"
    }
    if {[lsearch -index 0 $::engconn(options_$id) "UCI_Chess960"] != -1} {
        set chess960 [expr {"chess960" in $msgData ? "true" :"false"}]
        ::engine::rawsend $id "setoption name UCI_Chess960 value $chess960"
    }
    if {[lsearch -index 0 $::engconn(options_$id) "UCI_ShowWDL"] != -1} {
        set wdl [expr {"post_wdl" in $msgData ? "true" :"false"}]
        ::engine::rawsend $id "setoption name UCI_ShowWDL value $wdl"
    }
    if {[lsearch -index 0 $::engconn(options_$id) "Ponder"] != -1} {
        set ponder [expr {"ponder" in $msgData ? "true" :"false"}]
        ::engine::rawsend $id "setoption name Ponder value $ponder"
    }
    ::engine::rawsend $id "ucinewgame"
    ::engine::rawsend $id "isready"
}

proc ::xboard::sendNewGame {id msgData} {
    ::engine::rawsend $id "new"
    if {"chess960" in $msgData} {
        ::engine::rawsend $id "variant fischerandom"
    }
    ::engine::rawsend $id "force"
    ::engine::rawsend $id [expr {"post_pv" in $msgData ? "post" :"nopost"}]
    ::engine::rawsend $id [expr {"ponder" in $msgData ? "hard" :"easy"}]
    #TODO: ::engine::rawsend $id "computer"
    #TODO: ::engine::rawsend $id "name ..."

    if {[lsearch -index 0 $::engconn(options_$id) "ping"] != -1} {
        ::engine::rawsend $id "ping 1"
    } else {
        after 500 "::engine::done_ $id"
    }
}

proc ::uci::sendGo {id msgData} {
    lassign $msgData position limits
    if {$limits == ""} {
        set limits "infinite"
    } else {
        set limits [join $limits]
    }
    ::engine::rawsend $id $position
    ::engine::rawsend $id "go $limits"
}

proc ::xboard::sendGo {id msgData} {
    lassign $msgData position limits
    #TODO: we need to reset the limits, but some engines, such as Crafty, do no support "new".
    ::engine::rawsend $id "new"
    foreach {limit} $limits {
        lassign $limit limit_type limit_value
        switch $limit_type {
            "depth" { ::engine::rawsend $id "sd $limit_value" }
            "movetime" { ::engine::rawsend $id "st $limit_value" }
        }
    }
    set fen ""
    set moves ""
    regexp {^position(?: fen)? (.*?)(?:\s+moves(.*))?$} $position -> fen moves
    if {$fen eq "" || $fen eq "startpos"} {
        set fen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    }
    ::engine::rawsend $id "setboard $fen"
    ::engine::rawsend $id "force"
    set usermove ""
    if {[lsearch -index 0 $::engconn(options_$id) "usermove"] != -1} {
        set usermove "usermove "
    }
    foreach move $moves {
        ::engine::rawsend $id "$usermove$move"
    }
    ::engine::rawsend $id [expr {$limits eq "" ? "analyze" : "go"}]
}

proc ::xboard::sendStopGo {id} {
    ::engine::rawsend $id "exit"
    after 500 "::engine::done_ $id"
}

proc ::xboard::parseline {id line} {
    if {[regexp {^\s*(\d+)\s+(-\d+|\d+)\s+(\d+)\s+(\d+)\s+(.*)$} $line -> depth score time nodes pv]} {
        set scoreType "cp"
        if {$score >= 100000} {
            set scoreType mate
            incr score -100000
        } elseif {$score <= -100000} {
            set scoreType mate
            incr score 100000
        }
        set ::engconn(InfoPV_$id) [list 1 $depth {} $nodes {} {} {} $time $score $scoreType {} $pv]
        return 0
    }

    if {[string match "move *" $line]} {
        lassign [split $line] -> ::engconn(InfoBestMove_$id)
        return 1
    }

    if {[string match "pong *" $line]} {
        return 1
    }

    if {[string match "feature *" $line]} {
        set line [string range $line 8 end]
        foreach {feat name default} [regexp -all -inline {(\w+)\s*=\s*("[^"]*"|\d+)} $line] {
            set default [string trim $default \"]
            set type {}
            set min {}
            set max {}
            set var {}
            if {$name eq "option"} {
                set internal 0
                # everything before " -" is considered the name
                lassign [regexp -inline {^(.*?)\s+-(\w+)\s*(.*)$} $default] -> name type extra
                if {$type eq "check"} {
                    set default [expr {$extra ? "true" : "false"}]
                } elseif {$type eq "spin" || $type eq "slider"} {
                    lassign [split $extra] default min max
                } elseif {$type eq "string" || $type eq "file" || $type eq "path"} {
                    set default $extra
                } elseif {$type eq "combo"} {
                    set var [split [string map [list " /// " \0] $extra] \0]
                    set idx [lsearch $var {\**}]
                    if {$idx >= 0} {
                        set default [string range [lindex $var $idx] 1 end]
                        lset var $idx $default
                    } else {
                        set default [lindex $var 0]
                    }
                } elseif {$type eq "button" || $type eq "save"} {
                    set default ""
                } else {
                    # Unknown type: ignore
                    set type ""
                }
            } else {
                if {$name in {done ping setboard san usermove nps time reuse memory smp \
                              variants name myname egt } } {
                    set internal 1
                    ::engine::rawsend $id "accepted $name"
                } else {
                    ::engine::rawsend $id "rejected $name"
                    continue
                }
                if {$name eq "done"} {
    after cancel [list ::engine::done_ $id]
                    if {$default} {
                        return 1
                    }
                }
                if {$name eq "time" || $name eq "reuse"} {
                    set default [expr {! $default }]
                }
                if {$default == 0} {
                    continue
                }
                if {$name eq "memory"} {
                    set internal 0
                    set type spin
                    set default 1
                    set min 1
                    set max 2147483646
                } elseif {$name eq "smp"} {
                    set internal 0
                    set name "cores"
                    set type spin
                    set default 1
                    set min 1
                    set max 2147483646
                } else {
                    set type "string"
                }
            }
            if {$name ne "" && $type ne ""} {
                lappend ::engconn(options_$id) \
                    [list $name $default $type $default $min $max $var $internal]
            }
        }
        return 0
    }

    #unknown
    return 0
}

proc ::uci::parseline {id line} {
    if {[string match "info *" $line]} {
        set beginPV [string first " pv " $line]
        if {$beginPV < 0} {
            return 0
        }
        set pv [string range $line [expr {$beginPV + 4}] end]
        set nextToken [string first "\x00" [string map {
            currmovenumber \x00 refutation \x00 seldepth \x00 hashfull \x00
            currmove \x00 currline \x00 multipv \x00 cpuload \x00 tbhits \x00
            string \x00 depth \x00 nodes \x00 score \x00 time \x00 nps \x00
        } $pv]]
        if {$nextToken >= 0} {
            incr nextToken -1
            set pv [string trim [string range $pv 0 $nextToken]]
            set line [string replace $line $beginPV [expr {$beginPV + 4 + $nextToken}] " "]
        } else {
            set line [string replace $line $beginPV end]
        }

        # multipv depth seldepth nodes nps hashfull tbhits time score score_type score_wdl pv
        set msgData [list 1 {} {} {} {} {} {} {} {} {} {} $pv]
        set idx -1
        set tokens [list multipv depth seldepth nodes nps hashfull tbhits time score]
        foreach elem [split $line] {
            # Use wideinteger (64-bit) rather than integer: in Tcl 8.6 "string is
            # integer" only accepts 32-bit values, so large node/nps/tbhits counts
            # (> 2147483647, common in long searches) would be silently dropped.
            if {[string is wideinteger -strict $elem]} {
                if {$idx >= 0 && $idx <= 8} {
                    lset msgData $idx $elem
                } elseif {$idx == 10} {
                    lset msgData $idx end+1 $elem
                }
            } else {
                if {$idx >= 8 && $elem in {cp mate lowerbound upperbound wdl}} {
                    if {$elem eq "wdl"} {
                        set idx 10
                    } else {
                        lset msgData 9 $elem
                    }
                } else {
                    set idx [lsearch -exact $tokens $elem]
                }
            }
        }
        set ::engconn(InfoPV_$id) $msgData
        return 0
    }

    if {[string match "bestmove *" $line]} {
        lassign [split $line] -> best ponder ponder_move
        # The move the engine expects back is part of the answer: a play path
        # that ponders has to ask the engine to continue the line it was
        # already thinking about, and nothing else in the engine's output
        # names that move.
        if {$ponder ne "ponder"} { set ponder_move "" }
        set ::engconn(InfoBestMove_$id) [list $best $ponder_move]
        return 1
    }

    if {$line eq "readyok" || $line eq "uciok"} {
        return 1
    }

    if {[string match "option *" $line]} {
        set tokens {name type default min max var}
        set name {}
        set type {}
        set default {}
        set min {}
        set max {}
        set var {}

        set unknown {}
        set currToken "unknown"
        foreach word [split $line] {
            if {[set idx [lsearch -exact $tokens $word]] != -1} {
                if {$word ne "var"} {
                    # remove the tokens that should appear only once
                    set tokens [lreplace $tokens $idx $idx]
                }
                set currToken $word
            } else {
                lappend $currToken $word
            }
        }
        set internal [expr {$name in {Ponder UCI_AnalyseMode UCI_Chess960 UCI_ShowWDL}}]
        if {$type eq "string"} {
            if {[string match -nocase "*file*" $name]} {
                set type "file"
            } elseif {[string match -nocase "*path*" $name]} {
                set type "path"
            }
        }
        lappend ::engconn(options_$id) [list [join $name] [join $default] \
            [join $type] [join $default] [join $min] [join $max] $var $internal]
        return 0
    }

    if {[string match "id name *" $line]} {
        set name [string range $line 8 end]
        lappend ::engconn(options_$id) [list myname $name string $name {} {} {} 1]
        return 0
    }

    #unknown
    return 0
}
