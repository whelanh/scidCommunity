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
# One decimal, or empty when the number is not there yet.
proc r1 {x} { if {$x eq ""} { return "" } ; return [expr {round($x * 10) / 10.0}] }

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools review_report.tcl]

checkEq "the driver's w is white" [::reviewreport::sideWord w] white
checkEq "its b is black" [::reviewreport::sideWord b] black

puts "\naccuracy"

# The report's figure is the app's own: ::accuracy::calculate, the number the
# engine window's chart and the PGN viewer's chart show for the same game. It
# used to be a CAPS-style blend of its own, which put two accuracy numbers on
# one game and borrowed a name for an algorithm nobody has published.

# A run of White-perspective scores, one before each move and one after the
# last - the series a chart holds. Blunder-heavy, where the two methods are
# furthest apart.
set cps {30 25 20 -40 -60 -55 -120 -180 -150 -160 -300 -280 -260 -220 -210 \
         -250 -190 -170 -150 -140 -130}
proc curveMoves {cps {firstPly 1}} {
    set out {}
    set ply [expr {$firstPly - 1}]
    foreach cp [lrange $cps 0 end-1] {
        incr ply
        lappend out [dict create ply $ply side [expr {$ply % 2 ? "white" : "black"}] \
            fen_after "" classification good cp_loss 0 eval_before_white $cp \
            eval_after_white [lindex $cps [expr {$ply - $firstPly + 1}]]]
    }
    return $out
}
set curve [curveMoves $cps]

set gotW ""
set gotB ""
catch {
    set accs [::reviewreport::accuracyOf $curve]
    set gotW [dict get $accs white]
    set gotB [dict get $accs black]
}
check "the report's figure is the app's accuracy" \
    [expr {$gotW ne "" && $gotW eq [lindex [::accuracy::calculate $cps] 0] \
        && $gotB eq [lindex [::accuracy::calculate $cps] 1]}] \
    "got '$gotW' / '$gotB', want '[lindex [::accuracy::calculate $cps] 0]' / '[lindex [::accuracy::calculate $cps] 1]'"

set shown ""
catch { set shown [dict get [::reviewreport::sideSummary $curve white] accuracy] }
checkEq "the header prints that number to one decimal" $shown \
    [expr {round([lindex [::accuracy::calculate $cps] 0] * 10) / 10.0}]

check "the CAPS-style variant is gone" \
    [expr {[llength [info commands ::reviewreport::gameAccuracy]] == 0 \
        && [llength [info commands ::reviewreport::stdev]] == 0}]

puts "\nparity"

# ::accuracy::calculate reads index 0 as the position before White's move, so a
# phase that opens on Black's move would be scored with the sides swapped.
# calculateFrom takes the side that moved first; calculate delegates to it.
set series {0 50 100 60 40 -20 -40 -80 -60 -30 10 20 40 60 80 70 50 30 10 -10 -30}
set delegated ""
catch { set delegated [::accuracy::calculateFrom $series white] }
checkEq "calculate is calculateFrom with White first" \
    $delegated [::accuracy::calculate $series]

set swapped ""
catch { set swapped [::accuracy::calculateFrom $series black] }
# One side plays perfectly, the other loses material on every move. Read from
# Black's move, the flawless number is Black's; calculate() on the same list
# hands it to White, which is the swap calculateFrom exists to prevent.
set lopsided {0 0 -250 -250 -500 -500 -800 -800 -1000 -1000 -1000}
set lopsidedFrom [::accuracy::calculateFrom $lopsided black]
set lopsidedNaive [::accuracy::calculate $lopsided]
check "read from Black's move, the flawless side is Black" \
    [expr {[lindex $lopsidedFrom 1] > 99 && [lindex $lopsidedFrom 0] < [lindex $lopsidedFrom 1] - 10}] \
    "got '$lopsidedFrom'"
check "and a naive call hands it to White" \
    [expr {[lindex $lopsidedNaive 0] > 99 && [lindex $lopsidedNaive 0] != [lindex $lopsidedFrom 0]}] \
    "got '$lopsidedNaive'"

# A phase that begins on Black's move: plies 2..20 of the same game.
set ph ""
catch { set ph [::reviewreport::phaseStats $curve 2 20] }
set sliceCps [lrange $cps 1 end]
set sliceW ""
set sliceB ""
catch { lassign [::accuracy::calculateFrom $sliceCps black] sliceW sliceB }
set phW ""
set phB ""
catch {
    set phW [dict get $ph accW]
    set phB [dict get $ph accB]
}
checkEq "a phase that starts on Black's move is not reversed" \
    [list $phW $phB] [list [r1 $sliceW] [r1 $sliceB]]

lassign [::accuracy::calculate $sliceCps] naiveW naiveB
check "a naive call would have swapped the sides" \
    [expr {$sliceW ne "" && $naiveW ne $sliceW && abs($naiveW - $sliceW) > 0.5}] \
    "naive White $naiveW, sliced White '$sliceW'"

# Padded to White-first with one position in front, the slice is a series
# calculate() can read: at twenty moves the window is two either way, so every
# weight lands on the same move and Black - the side that opened the phase -
# scores exactly the same.
set padded [linsert $sliceCps 0 [lindex $sliceCps 0]]
set padB ""
set sliceBB ""
catch { set sliceBB [lindex [::accuracy::calculateFrom $sliceCps black] 1] }
catch { set padB [lindex [::accuracy::calculate $padded] 1] }
checkEq "padded to White-first, the first mover keeps its number" \
    $padB $sliceBB

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

# A collected list can have holes. ::reviewreport::collect drops a ply it cannot
# judge (no sc_move target, no verdict, or judge returns ""), so a 20-ply game
# reaches the split as 19 entries whose last ply is still 20. The phase
# boundaries therefore have to be plies, not a count of the list: taking
# [llength $moves] as the last ply leaves the tail outside every range, and the
# report's phase figures then describe less than the game.
set holed [phaseMoves $openingFen 20 [list [list 15 $endFen]]]
set holed [lmap m $holed {
    if {[dict get $m ply] == 11} { continue } else { set m }
}]
checkEq "the synthetic list has the hole" [llength $holed] 19
checkEq "and still ends on ply 20" [dict get [lindex $holed end] ply] 20

set ph [::reviewreport::phaseSplit $holed]
set ranges {}
foreach phase {opening middlegame endgame} {
    set d [dict get $ph $phase]
    if {$d ne ""} { lappend ranges [list $phase [dict get $d from] [dict get $d to]] }
}
set loose {}
foreach m $holed {
    set ply [dict get $m ply]
    set hits 0
    foreach r $ranges {
        lassign $r name from to
        if {$ply >= $from && $ply <= $to} { incr hits }
    }
    if {$hits != 1} { lappend loose "$ply in $hits" }
}
check "every collected ply is in exactly one phase" \
    [expr {[llength $loose] == 0}] "off: [join $loose {, }] -- ranges: $ranges"
checkEq "the last phase reaches the last collected ply" \
    [lindex [lindex $ranges end] 2] 20

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
check "the figure is called accuracy, and no vendor's name" \
    [expr {[string first "% accuracy" $text] >= 0 && [string first "CAPS" $text] < 0}]
checkEq "a second run strips the old block" \
    [::reviewreport::stripHeader "A note. $text"] "A note."

puts "\nthe block removal"

# The block is the marker line and the indented lines under it, and nothing
# else. It used to be "the marker to the next [ or the end of the comment",
# which ate whatever the player had typed below the block - and the writer
# appends the block last, so a note typed under it sat behind the marker.
checkEq "a note above the block survives" \
    [::reviewreport::stripHeader "My note.\n$text"] "My note."
checkEq "a note below the block survives" \
    [::reviewreport::stripHeader "$text\nA note typed below."] "A note typed below."

# Two writes through the writer itself, with the pass's own collection stubbed
# out: the note under the block has to be there after the second review.
set ::loc 0
set ::comments [dict create]
proc sc_move {what {n 0}} {
    if {$what eq "ply"} { set ::loc $n }
    return ""
}
proc sc_pos {what args} {
    switch -- $what {
        location { return $::loc }
        getComment { return [expr {[dict exists $::comments $::loc] ? [dict get $::comments $::loc] : ""}] }
        setComment { dict set ::comments $::loc [lindex $args 0] ; return "" }
    }
    return ""
}
namespace eval ::review {}
proc ::review::cursorSave {} { return [list $::loc 0] }
proc ::review::cursorRestore {c} { set ::loc [lindex $c 0] ; return 1 }
set ::stubMoves $moves
proc ::reviewreport::collect {p results} { return $::stubMoves }
set ::pass [dict create report 1]
dict set ::comments 0 "Opening idea: Nf3 first.\n\n$text\nRemember to check c5."
::reviewreport::write $::pass {}
::reviewreport::write $::pass {}
set comment [dict get $::comments 0]
check "a note below the block survives the next review" \
    [expr {[string first "Remember to check c5." $comment] >= 0}] \
    "got [string map {\n {\\n}} $comment]"
check "and the note above it" \
    [expr {[string first "Opening idea: Nf3 first." $comment] >= 0}]
checkEq "the block is written once" [regexp -all {\[Game review\]} $comment] 1

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
