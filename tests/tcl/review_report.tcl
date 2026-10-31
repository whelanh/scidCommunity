# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_report.tcl -- the deterministic report's pure calculations.
#
#   tclsh tests/tcl/review_report.tcl
#
# Accuracy, Elo, key moments and the phase split are what the report says about
# a game; this keeps the numbers and the boundaries honest without a board, an
# engine or a database.

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
proc near {a b {tol 0.05}} { expr {abs($a - $b) <= $tol} }

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools review_report.tcl]

checkEq "the driver's w is white" [::reviewreport::sideWord w] white
checkEq "its b is black" [::reviewreport::sideWord b] black

puts "\naccuracy"

set pts {}
for {set i 0} {$i < 20} {incr i} { lappend pts [list 100 50 0] }
checkEq "a perfect game is 100" [expr {round([::reviewreport::gameAccuracy $pts])}] 100
set pts {}
for {set i 0} {$i < 20} {incr i} { lappend pts [list 50 50 0] }
set acc [::reviewreport::gameAccuracy $pts]
check "a flat 50-point game is a little above 50" [near $acc 51.41 0.1] "got $acc"
set pts [list [list 100 50 0] [list 100 50 1] [list 100 50 1]]
checkEq "book moves are dropped" [expr {round([::reviewreport::gameAccuracy $pts])}] 100

puts "\nElo"

checkEq "0 ACPL is the top of the fit" [::reviewreport::eloFromAcpl 0] 2900
checkEq "8 ACPL still 2700" [::reviewreport::eloFromAcpl 8] 2700
checkEq "100 ACPL is 900" [::reviewreport::eloFromAcpl 100] 900
checkEq "150 ACPL is 600" [::reviewreport::eloFromAcpl 150] 600
checkEq "250 ACPL is 400" [::reviewreport::eloFromAcpl 250] 400
checkEq "an average game is anchored by ACPL" [::reviewreport::estimateElo 75 8] 2700
set high [::reviewreport::estimateElo 90 8]
check "a high accuracy nudges it up" [expr {$high > 2700}] "got $high"

puts "\nkey moments"

proc mv {ply side cls before after loss san} {
    return [dict create ply $ply side $side classification $cls \
        eval_before_white $before eval_after_white $after cp_loss $loss san $san]
}
set moves [list \
    [mv 2 white good 20 10 10 e4] \
    [mv 10 white blunder 100 -300 400 Qh5] \
    [mv 20 black mistake 50 -100 150 Nf6] \
    [mv 22 black inaccuracy 0 -20 20 a6]]
set keys [::reviewreport::keyMoments $moves 5]
checkEq "the blunder and the mistake are both kept" [llength $keys] 2
checkEq "in order of play" [list [dict get [lindex $keys 0] ply] [dict get [lindex $keys 1] ply]] \
    {10 20}
checkEq "the move number of a Black ply" [::reviewreport::moveNumber 20] {10...}
checkEq "and of a White ply" [::reviewreport::moveNumber 9] {5.}

puts "\nphases"

set openingFen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
set sparseFen  "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/4K3 w kq - 0 1"
set endFen     "8/8/8/4k3/8/8/8/4K2Q w - - 0 1"
check "a full back rank is not sparse" [expr {![::reviewreport::backrankSparse $openingFen]}]
check "a bare back rank is" [::reviewreport::backrankSparse $sparseFen]
check "a queen and king is an endgame" [::reviewreport::endgameNow $endFen]
check "the opening material is not" [expr {![::reviewreport::endgameNow $openingFen]}]
set moves {}
for {set ply 1} {$ply <= 20} {incr ply} {
    set fen [expr {$ply <= 12 ? $openingFen : $endFen}]
    set cls [expr {$ply == 10 ? "blunder" : "good"}]
    set after [expr {$ply == 10 ? -200 : 0}]
    lappend moves [dict create ply $ply side [expr {$ply % 2 ? "white" : "black"}] \
        fen_after $fen classification $cls eval_before_white 0 eval_after_white $after cp_loss 200]
}
set ph [::reviewreport::phaseSplit $moves]
checkEq "the opening keeps its twelve-ply floor" [dict get $ph opening to] 12
checkEq "the endgame starts after it" [dict get $ph endgame from] 13
check "the opening has both sides' accuracy" \
    [expr {[dict exists [dict get $ph opening] accW] && [dict exists [dict get $ph opening] accB]}]

puts "\nthe header"

set text [::reviewreport::headerText $moves]
check "it carries the marker" [expr {[string first {[Game review]} $text] == 0}]
check "both sides and their Elo" [expr {[string first "White:" $text] >= 0 && [string first "Black:" $text] >= 0 && [string first "estimated Elo" $text] >= 0}]
check "the key moments" [expr {[string first "Key moments:" $text] >= 0}]
check "and the phases" [expr {[string first "Phases:" $text] >= 0}]
# A scoresheet counts moves, not plies: the header must read "moves 1-13", not
# "1-26", or the reader is given a number no PGN uses.
check "the phase boundaries are in moves" \
    [expr {[string first "opening moves 1-" $text] >= 0}]
checkEq "a second run strips the old block" \
    [::reviewreport::stripHeader "A note. $text"] "A note."

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
