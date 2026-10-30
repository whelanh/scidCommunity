# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# rapid_annotate.tcl -- the score graph's evaluations in the review's shape.
#
#   tclsh tests/tcl/rapid_annotate.tcl
#
# Rapid annotate now feeds ::reviewdriver::writeResults from the scores the
# engine windows collected. The chart stores White's point of view in pawns; the
# writer wants the side to move's centipawns (or mate distance). This pins that
# conversion, which is the only part of the path that is not the writer itself.

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
source [file join $root tcl tools review_driver.tcl]
source [file join $root tcl tools rapid_annotate.tcl]

# A two-move game: position 0 is White to move, 1 Black, 2 White.
set map [dict create plies 2 \
    moves [dict create 1 e2e4 2 e7e5] \
    positions [dict create \
        0 {position startpos} \
        1 {position startpos moves e2e4} \
        2 {position startpos moves e2e4 e7e5}]]

proc entry {depth score fmt pv} {
    return [dict create depth $depth score $score score_fmt $fmt pv $pv]
}

puts "\nWhite's point of view becomes the side to move's"

set results [::rapid_annotate::reviewResults [dict create \
    1 [entry 10 0.30 +0.30 {e7e5}] \
    2 [entry 12 -0.50 -0.50 {g1f3}]] $map]
checkEq "at Black's position the score is negated" [dict get $results 1 1] \
    {10 -30 cp e7e5}
checkEq "at White's position it is unchanged" [dict get $results 2 1] \
    {12 -50 cp g1f3}

puts "\na mate keeps its distance and side"

set results [::rapid_annotate::reviewResults [dict create \
    1 [entry 10 300.0 M3 {e7e5}]] $map]
checkEq "White mates, Black is to move" [dict get $results 1 1] \
    {10 -3 mate e7e5}
set results [::rapid_annotate::reviewResults [dict create \
    2 [entry 10 -300.0 -M3 {g1f3}]] $map]
checkEq "Black mates, White is to move" [dict get $results 2 1] \
    {10 -3 mate g1f3}

puts "\nonly positions the game still has"

set results [::rapid_annotate::reviewResults [dict create \
    9 [entry 10 0.10 +0.10 {a2a3}]] $map]
checkEq "a ply past the game is dropped" $results {}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
