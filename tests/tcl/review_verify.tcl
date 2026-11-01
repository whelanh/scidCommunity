# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_verify.tcl -- when a Brilliant/Great upgrade is withdrawn.
#
#   tclsh tests/tcl/review_verify.tcl
#
# The second engine is not run here; the decision is pure. Jobs are built from
# the pass's labels, and a disagreement on the best move (or a Great move with
# no gap to the second line) has to downgrade to Best.

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

set map [dict create plies 12 \
    moves [dict create 10 Nf5] \
    positions [dict create 9 "position startpos moves e2e4 e7e5 g1f3 b8c6 f1c4 g8f6" \
        10 "position startpos moves e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 Nf5"]]

# The analysis best move at k=9 is Nf5; the second line is Be3.
proc lines {top second {s1 30} {s2 10}} {
    set l [dict create 1 [list 20 $s1 cp [list $top d5]]]
    if {$second ne ""} { dict set l 2 [list 20 $s2 cp [list $second]] }
    return $l
}
set results [dict create 9 [lines Nf5 Be3]]

puts "\nwhich positions are verified"

set jobs [::reviewverify::jobs $map $results \
    [dict create 8 best 10 brilliant 11 great 12 mistake]]
checkEq "only Brilliant and Great" [llength $jobs] 2
checkEq "the reference position, the spec, the best move" \
    [lindex $jobs 0] [list 10 9 "position startpos moves e2e4 e7e5 g1f3 b8c6 f1c4 g8f6" Nf5 brilliant]
checkEq "the next move's reference is the following position" \
    [lindex $jobs 1 1] 10

puts "\nthe second engine agrees"

set vres [dict create 9 [lines Nf5 Be3]]
checkEq "a Brilliant move stays" [::reviewverify::corrections [list [list 10 9 x Nf5 brilliant]] $vres] {}
set vres [dict create 9 [lines Nf5 Be3 300 50]]
checkEq "a Great move with a wide gap stays" \
    [::reviewverify::corrections [list [list 10 9 x Nf5 great]] $vres] {}

puts "\nand when it does not"

set vres [dict create 9 [lines Be3 Nf5]]
checkEq "a different best move downgrades" \
    [::reviewverify::corrections [list [list 10 9 x Nf5 brilliant]] $vres] [dict create 10 best]
set vres [dict create 9 [lines Nf5 Be3 210 50]]
checkEq "a Great move without a 200 cp gap downgrades" \
    [::reviewverify::corrections [list [list 10 9 x Nf5 great]] $vres] [dict create 10 best]
checkEq "no verifier lines downgrades too" \
    [::reviewverify::corrections [list [list 10 9 x Nf5 great]] {}] [dict create 10 best]

puts "\nnothing to verify is not a failure"

checkEq "no candidates starts nothing" \
    [::reviewverify::start {Engine A} $map $results [dict create 10 best] [dict create depth 20] {list}] 0

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
