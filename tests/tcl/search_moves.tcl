# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# search_moves.tcl -- move-sequence search, against the real database code.
#
#   xvfb-run -a ./scidCommunity tests/tcl/search_moves.tcl
#
# The matching lives in Game::MoveMatch and the scan in sc_search_moves, so a
# stub would test nothing. This builds a real MEMORY base, imports a PGN, and
# checks the filter the search leaves behind: which games matched, at which ply
# the game list should open, and the side-to-move and mate filters.

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
set pgn [file join [file dirname [info script]] search_moves.pgn]

set id [sc_base create MEMORY search_moves_test]
sc_base switch $id
sc_base import $id $pgn

checkEq "the base holds the four games" [sc_base numGames $id] 4

# Run a search and return the number of games in the filter afterwards.
proc search {moves side mate {op reset}} {
    global id
    sc_filter search $id dbfilter moves $moves $side $mate -filter $op
    return [sc_filter count $id dbfilter]
}

puts "\n== a sequence matches only where it occurs in order =="
checkEq "e4 e5 occurs in one game" [search {e4 e5} wb 0] 1
checkEq "the single move e4 occurs twice" [search {e4} wb 0] 2
checkEq "e4 d4 is not a sequence" [search {e4 d4} wb 0] 0
checkEq "a sequence may start on black's move" [search {e5 Nf3} b 0] 1

puts "\n== side to move =="
checkEq "black to move before e4: none" [search {e4} b 0] 0
checkEq "white to move before e4: two" [search {e4} w 0] 2

puts "\n== the wildcard matches any single move =="
checkEq "d4 ? c4" [search {d4 ? c4} wb 0] 1
checkEq "e4 ? Nf3 spans both replies" [search {e4 ? Nf3} wb 0] 2

puts "\n== the check/mate mark and case are optional in the query =="
checkEq "qh4 matches Qh4#" [search {qh4} wb 0] 1
checkEq "Qh4+ matches Qh4#" [search {Qh4+} wb 0] 1

puts "\n== mate-only =="
checkEq "the mating move" [search {Qh4} wb 1] 1
checkEq "a move that is not mate" [search {e4} wb 1] 0

puts "\n== the filter remembers the ply to open at =="
search {Nf3} wb 0
sc_game load 1
checkEq "game 1 opens before white's second move" [sc_pos moveNumber] 2
checkEq "  with white to move" [sc_pos side] white
sc_game load 3
checkEq "game 3 opens before white's second move" [sc_pos moveNumber] 2
checkEq "  with white to move" [sc_pos side] white
search {Qh4} wb 1
sc_game load 4
checkEq "the mate opens on black's second move" [sc_pos moveNumber] 2
checkEq "  with black to move" [sc_pos side] black

puts "\n== combining with the previous filter =="
search {e4} wb 0
checkEq "and e4 e5 keeps one" [search {e4 e5} wb 0 and] 1
checkEq "and d4 leaves nothing" [search {d4} wb 0 and] 0
search {e4} wb 0
checkEq "or d4 adds the queen's pawn game" [search {d4} wb 0 or] 3

puts "\n== the window's options =="
source [file join $root tcl search board.tcl]
::search::movesOptions reset
checkEq "reset clears the text" $::search::movesOptText_ ""
checkEq "reset selects either side" $::search::movesOptSide_ wb
checkEq "reset unticks the mate" $::search::movesOptMate_ 0

set ::search::movesOptText_ "1. e4 e5 2. Nf3"
set ::search::movesOptSide_ w
set ::search::movesOptMate_ 1
checkEq "the move numbers are stripped" \
    [lindex [::search::movesOptions] 0] {moves {e4 e5 Nf3} w 1}


puts "\n== an empty list is refused =="
set err [catch {sc_filter search $id dbfilter moves {} wb 0 -filter reset} msg]
check "the empty search is an error" [expr {$err == 1}] $msg

puts "\n== a match past the byte cap is a match, not a read error =="
# The filter value is a byte, so a match found after 255 plies is capped at 255.
# 128 moves of knight shuffling put the only e4 at ply 257; that game must stay
# in the filter instead of being dropped as an unreadable game.
set longPgn [file join [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] \
                 "search_moves_long.tcl[pid].pgn"]
set fh [open $longPgn w]
set moves {}
for {set n 1} {$n <= 128} {incr n} {
    append moves "$n. " [expr {$n % 2 ? "Nf3 Nf6" : "Ng1 Ng8"}] " "
}
puts $fh "\[Event \"Long shuffle\"\]\n\[Result \"*\"\]\n\n${moves}129. e4 *"
close $fh

set longId [sc_base create MEMORY search_moves_long]
sc_base switch $longId
sc_base import $longId $longPgn
file delete $longPgn
checkEq "the long game imports" [sc_base numGames $longId] 1
sc_filter search $longId dbfilter moves {e4} wb 0 -filter reset
checkEq "the ply-257 match is kept" [sc_filter count $longId dbfilter] 1
sc_game load 1
checkEq "the capped filter opens at move 128" [sc_pos moveNumber] 128
checkEq "  with white to move" [sc_pos side] white

puts ""
if {$fails} {
    puts "FAILED $fails of $checks checks"
    exit 1
}
puts "$checks checks, 0 failures"
exit 0
