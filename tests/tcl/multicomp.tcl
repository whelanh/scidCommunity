#!/usr/bin/env tclsh
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Computer tournament (tcl/tools/multicomp.tcl): the PGN time control, the
# repetition key that decides a draw, and the time-per-move deadline.
#
#   tclsh tests/tcl/multicomp.tcl            # the tree's multicomp.tcl
#   tclsh tests/tcl/multicomp.tcl FILE.tcl   # any other copy (e.g. the base)

set fails 0
set checks 0

proc check {name cond} {
    global fails checks
    incr checks
    if {![uplevel 1 [list expr $cond]]} {
        incr fails
        puts "FAIL $name"
    }
}

proc checkEq {name got want} {
    global fails checks
    incr checks
    if {$got ne $want} {
        incr fails
        puts "FAIL $name -- got '$got' want '$want'"
    }
}

proc checkMatch {name got pattern} {
    global fails checks
    incr checks
    if {![string match $pattern $got]} {
        incr fails
        puts "FAIL $name -- got '$got' want '$pattern'"
    }
}

# A check that a procedure added by this branch may not exist in an older copy
# of the file must still report a FAIL rather than take the run down with it.
proc call {script} {
    if {[catch {uplevel 1 $script} v]} { return "ERROR:$v" }
    return $v
}

# The stubs multicomp.tcl needs: tr at load time, and the square conversions of
# tcl/board.tcl (a1 == 0, uppercase white at the bottom) at call time.
proc tr {s} { return $s }
namespace eval ::board {}
proc ::board::sq {n} {
    if {![info exists ::squares]} {
        set ::squares {}
        foreach rank {1 2 3 4 5 6 7 8} {
            foreach file {a b c d e f g h} { lappend ::squares $file$rank }
        }
    }
    return [lsearch -exact $::squares $n]
}
proc ::board::san {i} {
    return [format %c%c [expr {($i % 8) + 97}] [expr {($i / 8) + 49}]]
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
if {[llength $argv]} {
    set file [lindex $argv 0]
} else {
    set file [file join $root tcl tools multicomp.tcl]
}
if {[catch {source $file} err]} {
    puts "FAIL cannot load $file: $err"
    puts "\n$checks checks, $fails failures"
    exit 1
}

set START "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr"

# Replay a move list the way ::comp::compCheckMove drives the repetition test:
# board through compUpdateboard, state through nextPositionState, key through
# repetitionKey, journal through checkRepetition.  Returns, per ply, whether the
# position was called a repetition.
#
# A copy of the file without the castling/en-passant state procedures is replayed
# with the old keying (placement and side only), so the run shows the false draw
# itself instead of an "invalid command name".
proc replay {moves} {
    set stateful [expr {
        [llength [info commands ::comp::stateFromPosition]] &&
        [llength [info commands ::comp::nextPositionState]] &&
        [llength [info commands ::comp::startPositionKey]] &&
        [llength [info commands ::comp::repetitionKey]] }]
    set board $::START
    if {$stateful} {
        lassign [::comp::stateFromPosition startpos $board] rights epsq
        set journal [list [::comp::startPositionKey startpos]]
    } else {
        set rights ""
        set epsq ""
        set journal {}
    }
    set side w
    set out {}
    foreach mv $moves {
        set pre $board
        lassign [::comp::compUpdateboard $pre $mv] ok board
        if {!$ok} { error "compUpdateboard rejected $mv" }
        set side [expr {$side eq "w" ? "b" : "w"}]
        if {$stateful} {
            lassign [::comp::nextPositionState [list $rights $epsq] $pre $mv] rights epsq
            set key [::comp::repetitionKey $board $side $rights $epsq]
        } else {
            set key "$board $side"
        }
        lassign [::comp::checkRepetition $journal $key] isRep journal
        lappend out [list $isRep]
    }
    return $out
}

proc repAt {plies ply} {
    return [lindex [lindex $plies [expr {$ply - 1}]] 0]
}

puts "the PGN time control"
set ::comp::_Data(timecontrol) pergame
set ::comp::_Data(base) 300
set ::comp::_Data(incr) 0.5
# PGN TimeControl is base+increment in seconds: "5:00/0.5" read as 0 moves in 5
# seconds, and no chess database could use it.
checkEq "5:00 + 0.5 is 300+0.5" [call {::comp::timeControlTag}] {TimeControl "300+0.5"}
set ::comp::_Data(base) 60
set ::comp::_Data(incr) 0
checkEq "60 + 0 is 60+0, not 1:00/0" [call {::comp::timeControlTag}] {TimeControl "60+0"}
set ::comp::_Data(base) 2
set ::comp::_Data(incr) 0.5
checkEq "2 s + 0.5 is 2+0.5" [call {::comp::timeControlTag}] {TimeControl "2+0.5"}
set ::comp::_Data(timecontrol) permove
set ::comp::_Data(seconds) 0.5
checkEq "a time per move stays Movetime" [call {::comp::timeControlTag}] {Movetime "0.5"}
set ::comp::_Data(timecontrol) pergame

puts "\nthe repetition key"
checkEq "the key holds placement, side, rights and ep" \
    [call {::comp::repetitionKey {RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr w} w KQkq -}] \
    [list $START w KQkq -]
checkEq "a FEN board's side token is not part of it" \
    [call {::comp::repetitionKey [list $START b] b - e3}] [list $START b - e3]

# A rook out and home again returns the placement, but White's Q-side right is
# gone for good: the second and third occurrences are not the first position.
set castlingMoves {
    b1c3 g8f6 a1b1 f6g8 b1a1 g8f6
    a1b1 f6g8 b1a1 g8f6
    a1b1 f6g8 b1a1 g8f6
}
set p [call {replay $::castlingMoves}]
# Base (placement + side only) sees three of the same position at ply 10 and
# calls a draw; the rights differ at the first one, so it is not a repetition.
checkEq "a repetition that differs in castling rights is not a draw" [call {repAt $p 10}] 0
checkEq "the real third occurrence is a draw" [call {repAt $p 14}] 1
checkEq "the first occurrence is never a draw" [call {repAt $p 2}] 0

# A double pawn push leaves an en-passant square; the same placement reached by
# ordinary moves is a different position.
set epMoves {
    e2e4 g8f6 g1f3 f6g8 f3g1
    g8f6 g1f3 f6g8 f3g1
    g8f6 g1f3 f6g8 f3g1
}
set q [call {replay $::epMoves}]
# Base sees the placement three times at ply 9, though the first one still had
# an en-passant capture available and the others did not.
checkEq "a repetition that differs in en passant is not a draw" [call {repAt $q 9}] 0
checkEq "the real third occurrence is a draw here too" [call {repAt $q 13}] 1

puts "\ntime per move"
set ::comp::_Data(timecontrol) permove
set ::comp::_Data(time) 1000
checkEq "1.75 s of a 1 s clock is still in time" [call {::comp::moveOverrun 1750 1000}] 0
checkEq "the grace keeps a 1.8 s first move alive on a 1 s clock" \
    [call {::comp::moveOverrun 1800 1000}] 0
checkEq "the grace ends at 2.75 s for a 1 s clock" [call {::comp::moveOverrun 2750 1000}] 0
checkEq "2.75 s and a tick is too late" [call {::comp::moveOverrun 2751 1000}] 1
set ::comp::_Data(time) 500
checkEq "a 0.5 s clock allows 1.875 s" [call {::comp::moveOverrun 1875 500}] 0
checkEq "and not 1.9 s" [call {::comp::moveOverrun 1900 500}] 1
set ::comp::_Data(timecontrol) pergame
set ::comp::_Data(time) 1000
checkEq "time per game never adjudicates on the reply time" \
    [call {::comp::moveOverrun 600000 1000}] 0

# The loss comment is written in seconds: "950 secs" for an 0.95 s clock was a
# millisecond value, and a reader of the saved game cannot tell.
set ::comp::_Data(timecontrol) permove
set ::comp::_Data(time) 1000
set ::comp::_Data(comments,3) {}
set ::comp::_Data(mate,3) 0
set ::comp::_Data(score,3) 0.0
set ::comp::_Data(result,3) "*"
set ::comp::_Data(moves,3) {}
catch {::comp::compCheckMove 3 white 2800 "Time out"}
set comment [lindex $::comp::_Data(comments,3) 0]
checkMatch "the loss comment names the seconds it took" $comment {*2.80 secs*}
checkMatch "and the time the engine was allowed" $comment {*allowed 2.75 secs*}
check "the raw millisecond count is gone" [expr {[string first 2800 $comment] < 0}]

puts "\nthe tournament's own move path"
# ::comp::compCheckMove is where the key is built for real: a played move has to
# come back accepted, land in the move list, and carry its en-passant square.
proc playMove {game move} {
    set ::comp::_Data(timecontrol) pergame
    set ::comp::_Data(incr50) 50
    set ::comp::_Data(white,$game) 60000
    set ::comp::_Data(black,$game) 60000
    set ::comp::_Data(board,$game) $::START
    set ::comp::_Data(moves,$game) {}
    set ::comp::_Data(comments,$game) {}
    set ::comp::_Data(repetition,$game) [list [::comp::startPositionKey startpos]]
    lassign [::comp::stateFromPosition startpos $::comp::_Data(board,$game)] r e
    set ::comp::_Data(crights,$game) $r
    set ::comp::_Data(epsq,$game) $e
    set ::comp::_Data(score,$game) 0.0
    set ::comp::_Data(scoreIsNew,$game) 0
    set ::comp::_Data(showscores,$game) 0
    set ::comp::_Data(showBoards,$game) 0
    set ::comp::_Data(showtimes,$game) 0
    set ::comp::_Data(mate,$game) 0
    set ::comp::_Data(moves50,$game) 0
    set ::comp::_Data(material,$game) {}
    set ::comp::_Data(pawns,$game) {}
    set ::comp::_Data(playing,$game) 1
    return [::comp::compCheckMove $game white 100 $move]
}

checkEq "a played move is accepted" [call {playMove 4 e2e4}] 1
checkEq "it lands in the move list" [call {set ::comp::_Data(moves,4)}] e2e4
checkEq "and the double push records e3 as the ep square" \
    [call {set ::comp::_Data(epsq,4)}] e3
checkEq "castling rights survive an ordinary pawn move" \
    [call {set ::comp::_Data(crights,4)}] KQkq

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
