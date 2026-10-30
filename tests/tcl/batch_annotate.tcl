# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# batch_annotate.tcl -- the Game List batch's engine-line parser.
#
#   tclsh tests/tcl/batch_annotate.tcl
#
# Batch annotate now feeds the Game Review writer, so the engine lines it
# collects have to be in the review's own shape: {depth score score-type pv},
# one per MultiPV rank, deepest line wins. The rest of the batch is pipes and
# the game database; this is the part that decides what the writer sees.

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

proc ::options.store {args} {}
set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools batch_annotate.tcl]

proc line {text} {
    return [::batch_annotate::collect $text [dict create]]
}

puts "\none info line per MultiPV rank"

set l [line {info depth 10 seldepth 12 multipv 1 score cp 34 nodes 100 pv e2e4 e7e5}]
checkEq "the line is the review's four fields" [dict get $l 1] \
    {10 34 cp {e2e4 e7e5}}
set l [::batch_annotate::collect \
    {info depth 11 seldepth 15 multipv 2 score cp -12 nodes 200 pv d2d4 d7d5} $l]
checkEq "rank two is kept beside it" [dict get $l 2] {11 -12 cp {d2d4 d7d5}}
checkEq "rank one is untouched" [dict get $l 1] {10 34 cp {e2e4 e7e5}}

puts "\nthe deepest line for a rank wins"

set l [::batch_annotate::collect \
    {info depth 12 seldepth 16 multipv 1 score cp 40 nodes 300 pv e2e4 c7c5} $l]
checkEq "a deeper line replaces the shallower one" [dict get $l 1] \
    {12 40 cp {e2e4 c7c5}}
set before $l
set l [::batch_annotate::collect \
    {info depth 9 seldepth 12 multipv 1 score cp 90 nodes 10 pv e2e4 e7e5} $l]
checkEq "a shallower line does not" [dict get $l 1] [dict get $before 1]

puts "\nwhat the writer cannot use is left out"

set l [line {info depth 10 multipv 1 score cp 10 lowerbound nodes 1 pv e2e4}]
checkEq "a bound is not a verdict" $l {}
set l [line {info depth 10 multipv 1 score cp 10 nodes 1}]
checkEq "a line without a PV is not a line" $l {}
set l [line {info depth 10 seldepth 12 multipv 1 score mate 3 nodes 1 pv e2e4 e7e5}]
checkEq "a mate keeps its distance and type" [dict get $l 1] \
    {10 3 mate {e2e4 e7e5}}
set l [line {info depth 10 multipv}]
checkEq "a malformed line changes nothing" $l {}

# The Go the batch sends is the pass's: the review's depth and, when Review
# Settings sets one, its time ceiling. The engine is stubbed - the transport's
# open/gets/eof answer the handshake from a queue and hand back a channel - so
# the test reads back what ::batch_annotate::feed_move actually wrote.
puts "\nthe batch sends the pass's two bounds"

source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools game_review.tcl]

set ::windowsOS 0
namespace eval ::enginecfg {}
proc ::enginecfg::get {name} {
    return [list $name tclsh {} {} 0 1800 {} 1 {} {} {}]
}

namespace eval ::batch_annotate_test {
    variable chan ""
    variable replies {}
}
rename open ::testopen
rename gets ::testgets
rename eof ::testeof
proc open {args} { return $::batch_annotate_test::chan }
proc gets {chan args} {
    if {$chan eq $::batch_annotate_test::chan} {
        if {![llength $::batch_annotate_test::replies]} { return -1 }
        set line [lindex $::batch_annotate_test::replies 0]
        set ::batch_annotate_test::replies [lrange $::batch_annotate_test::replies 1 end]
        if {[llength $args]} {
            upvar 1 [lindex $args 0] linevar
            set linevar $line
            return [string length $line]
        }
        return $line
    }
    return [::testgets $chan {*}$args]
}
proc eof {chan} {
    if {$chan eq $::batch_annotate_test::chan} { return 0 }
    return [::testeof $chan]
}

proc ::batch_annotate_test::go {movetime} {
    ::review::reset
    if {$movetime ne ""} { ::review::setValue movetime $movetime }
    set path [file tempfile]
    set chan [::testopen $path w+]
    fconfigure $chan -buffering line
    set ::batch_annotate_test::chan $chan
    set ::batch_annotate_test::replies {uciok readyok}
    set ::batch_annotate::engine_name Stub
    ::batch_annotate::start_engines 1
    set ::batch_annotate::pipe_moves($chan) [list [list 1 "position startpos"]]
    ::batch_annotate::feed_move $chan
    seek $chan 0
    set written [read $chan]
    close $chan
    file delete $path
    set go ""
    foreach line [split $written "\n"] {
        if {[string match "go *" $line]} { set go $line }
    }
    return $go
}

checkEq "no cap in Review Settings, no time in the Go" \
    [::batch_annotate_test::go ""] "go depth 18"
checkEq "a cap in Review Settings reaches the pipe" \
    [::batch_annotate_test::go 400] "go depth 18 movetime 400"

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
