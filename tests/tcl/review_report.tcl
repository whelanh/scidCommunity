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

# The opening boundary is three signals, whichever fires first: Smyrnov's test
# (both sides have developed every minor piece and connected their rooks),
# mixedness above 150, and the majors-and-minors count down to ten. The
# back-rank count is not one of them, and there is no ply floor: a line that
# finishes developing on move 5 is out of the opening on move 4.
set openingFen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
set endFen     "8/8/8/4k3/8/8/8/4K2Q w - - 0 1"
# Both sides have every minor off its original square and both pairs of rooks
# connected; both kings are castled and both queens are off the first rank. The
# armies have barely met, so mixedness is 139 and the count is still 12: this
# position is over on Smyrnov alone.
set smyrnovFen "r3r1k1/pp2ppbp/1qn2np1/8/3P4/2NBPN2/PP1Q1PPP/R3R1K1 w - - 0 12"
# The same, except Black's queenside knight never left b8.
set halfMetFen "rn2r1k1/pp2ppbp/1q3np1/8/3P4/2NBPN2/PP1Q1PPP/R3R1K1 w - - 0 12"
# White has one rook: that side's rook condition is satisfied by there being no
# pair to connect, and the rest is still required.
set rookLessFen    "r3r1k1/pp2ppbp/1qn2np1/8/3P4/2NBPN2/PP1Q1PPP/R5K1 w - - 0 12"
set rookLessHalfFen "rn2r1k1/pp2ppbp/1q3np1/8/3P4/2NBPN2/PP1Q1PPP/R5K1 w - - 0 12"
# Rooks connected on the second rank, and on the a-file: neither needs the back
# rank.
set rankFen "r3r1k1/pp2ppbp/1qn2np1/8/3P4/2NBPN2/2R2R2/6K1 w - - 0 12"
set fileFen "r3r1k1/pp2ppbp/1qn2np1/8/R2B4/2N3P1/5P1P/6K1 w - - 0 12"
# Every minor developed, but the king still stands between the rooks.
set unconnectedFen "r3r1k1/pp2ppbp/1qn2np1/8/3P4/2NBPN2/PP1Q1PPP/R3K2R w KQ - 0 12"
# A sharp closed centre: pieces still on their original squares (so not Smyrnov)
# and the material count is 13, but mixedness is 161.
set sharpFen "r2q1rk1/pp3pbp/3p1np1/2pPn3/2P1P3/2N1BNP1/PP2BP1P/R2Q1RK1 w - - 0 13"
# The same shape scoring exactly 150: the threshold is strict, so this is not
# over.
set mixed150Fen "r2q1rk1/pp2ppbp/2n2np1/2pp4/2PPP3/2N1BN2/PP2BPPP/R2QK2R w KQ - 0 10"
# Four of the initial fourteen majors-and-minors gone (ten left), both back
# ranks still occupied, and neither development signal met: the early-exchange
# net. Eleven is below the net.
set tenFen    "r2qkbnr/pppppppp/8/8/8/8/PPPPPPPP/R2QKBNR w KQkq - 0 1"
set elevenFen "r2qkbnr/pppppppp/8/8/8/8/PPPPPPPP/R1BQKBNR w KQkq - 0 1"

check "the back-rank count is not a trigger any more" \
    [expr {[llength [info commands ::reviewreport::backrankSparse]] == 0}]
check "a queen and king is an endgame" [::reviewreport::endgameNow $endFen]
check "the opening material is not" [expr {![::reviewreport::endgameNow $openingFen]}]

# The initial position is an opening on every count.
checkEq "the initial position has fourteen majors-and-minors" \
    [::reviewreport::majorsMinors $openingFen] 14
checkEq "and no mixedness" [::reviewreport::mixedness $openingFen] 0
check "it is not over on Smyrnov" [expr {![::reviewreport::smyrnovOver $openingFen]}]
check "so the initial position is still the opening" \
    [expr {![::reviewreport::openingOver $openingFen]}]

# Smyrnov's test, side by side.
check "both sides developed and connected is over" \
    [::reviewreport::smyrnovOver $smyrnovFen]
check "and the opening has ended" [::reviewreport::openingOver $smyrnovFen]
check "one knight still at home and it is not over" \
    [expr {![::reviewreport::smyrnovOver $halfMetFen]}]
check "so the opening continues" [expr {![::reviewreport::openingOver $halfMetFen]}]
check "a side with one rook needs no connection" \
    [::reviewreport::smyrnovOver $rookLessFen]
check "but its other conditions still hold" \
    [expr {![::reviewreport::smyrnovOver $rookLessHalfFen]}]
check "rooks on the second rank are connected" \
    [::reviewreport::smyrnovOver $rankFen]
check "and rooks on a file are connected" [::reviewreport::smyrnovOver $fileFen]
check "a king between them is not" \
    [expr {![::reviewreport::smyrnovOver $unconnectedFen]}]

# mixedness, ported from the plugin, closes a tangle early.
check "mixedness sees the sharp centre" \
    [expr {[::reviewreport::mixedness $sharpFen] > 150}] \
    "got [::reviewreport::mixedness $sharpFen]"
check "and that position is not over on Smyrnov" \
    [expr {![::reviewreport::smyrnovOver $sharpFen]}]
check "so mixedness closes the opening on its own" \
    [::reviewreport::openingOver $sharpFen]
checkEq "exactly 150 is not above the threshold" \
    [::reviewreport::mixedness $mixed150Fen] 150
check "so it does not close the opening" \
    [expr {![::reviewreport::openingOver $mixed150Fen]}]

# The material net. Both back ranks are still occupied and neither development
# signal fires; ten majors-and-minors is four gone from fourteen.
check "ten majors-and-minors is over" [::reviewreport::openingOver $tenFen]
checkEq "and eleven is the count" [::reviewreport::majorsMinors $elevenFen] 11
check "eleven is not" [expr {![::reviewreport::openingOver $elevenFen]}]

# The boundary the report writes: the first ply whose position is over, less
# one. `openingTo` is the ply the opening phase ends on.
proc phaseMoves {default total overrides} {
    set out {}
    for {set ply 1} {$ply <= $total} {incr ply} {
        set fen $default
        foreach o $overrides {
            lassign $o from f
            if {$ply >= $from} { set fen $f }
        }
        lappend out [dict create ply $ply side [expr {$ply % 2 ? "white" : "black"}] \
            fen_after $fen classification good eval_before_white 0 \
            eval_after_white 0 cp_loss 0]
    }
    return $out
}

set ph [::reviewreport::phaseSplit [phaseMoves $openingFen 30 \
    [list [list 18 $sharpFen] [list 26 $smyrnovFen]]]]
checkEq "mixedness at 18 closes the opening at 17" [dict get $ph opening to] 17
set ph [::reviewreport::phaseSplit [phaseMoves $openingFen 30 \
    [list [list 18 $smyrnovFen] [list 26 $sharpFen]]]]
checkEq "Smyrnov at 18 closes it at 17 as well" [dict get $ph opening to] 17
set ph [::reviewreport::phaseSplit [phaseMoves $openingFen 30 \
    [list [list 26 $sharpFen]]]]
checkEq "a mixedness that first fires at 26 closes it at 25" [dict get $ph opening to] 25
set ph [::reviewreport::phaseSplit [phaseMoves $openingFen 30 \
    [list [list 22 $tenFen]]]]
checkEq "the material net firing at 22 closes it at 21" [dict get $ph opening to] 21
set ph [::reviewreport::phaseSplit [phaseMoves $openingFen 20 \
    [list [list 9 $smyrnovFen]]]]
checkEq "no floor: Smyrnov met at 9 closes it at 8" [dict get $ph opening to] 8

set moves [phaseMoves $openingFen 20 [list [list 13 $endFen]]]
set moves [lmap m $moves {
    if {[dict get $m ply] == 10} {
        dict merge $m {classification blunder eval_after_white -200 cp_loss 200}
    } else { set m }
}]
set ph [::reviewreport::phaseSplit $moves]
checkEq "the endgame starts where it is reached" [dict get $ph endgame from] 13
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
