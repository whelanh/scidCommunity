# SPDX-License-Identifier: GPL-2.0-or-later
#
# check.tcl -- fast, headless correctness checks for "sc_search cql".
#
#   ./scidCommunity tests/cql/check.tcl ?pgn?
#
# Unlike tests/tcl/search_cql.tcl this never sources tcl/start.tcl, so it creates
# no window and no menus: a script argument runs the application with just its
# Tcl commands registered. It is not display-free, though - the binary calls
# Tk_Init unconditionally - so a machine with no X server must run it under
# xvfb-run (CI does). It builds a MEMORY base from the (five game)
# search_moves.pgn, runs queries through the real engine and checks the filter
# each leaves behind, in well under a second.
#
# Use it while working on the CQL driver and its index pre-filters. The Tk
# harness remains the end-to-end gate (window, menu, progress bar); CI runs
# that under Xvfb.

set here [file dirname [info script]]
set root [file normalize [file join $here .. ..]]
set pgn [expr {
    [llength $argv] > 0 ? [lindex $argv 0]
                        : [file join $root tests tcl search_moves.pgn]
}]

set id [sc_base create MEMORY cql_check]
sc_base switch $id
sc_base import $id $pgn
set games [sc_base numGames $id]
puts "base: $games games from $pgn"

set fails 0
proc check {label got want} {
    if {$got eq $want} {
        puts "  ok   $label ($got)"
    } else {
        puts "  FAIL $label -- got '$got' want '$want'"
        incr ::fails
    }
}

# run ?filterOp? query -- search and return the size of the resulting filter.
proc run {args} {
    global id
    lassign $args query op
    if {![info exists op] || $op eq ""} { set op reset }
    sc_search cql $op 0 0 $query
    return [sc_filter count $id dbfilter]
}

puts "\n== position filters ==\n"
check "a plain designator matches every game" [run {cql() K}] $games
check "mate is the fool's mate game" [run {cql() mate}] 1
check "check is the same game" [run {cql() check}] 1
check "a square designator may be followed by a variable" \
    [run {cql() square $x in [a1,b2] [a1,b2]$x}] $games

puts "\n== :gamenumber ==\n"
check "one game" [run {cql(:gamenumber 1 1) K}] 1
check "two games" [run {cql(:gamenumber 1 2) K}] 2
check "a multi-line query is one query" [run "cql(:gamenumber 4 4)\n   mate"] 1
check "a range outside the base matches nothing" \
    [run {cql(:gamenumber 100 200) mate}] 0

puts "\n== game-level tag filters (index pre-filter) ==\n"
# These exercise CqlQueryIndexRejectsGame(): a game it rejects must be one the
# engine would reject too, so each count has to agree with the decoded answer.
check "player in the filter body" [run {cql() player "Alpha"}] 1
check "player, either colour" [run {cql() player "Beta"}] 1
check "player that is nobody" [run {cql() player "NoSuch" mate}] 0
check "player and a position filter" [run {cql() player "Eta" mate}] 1
check "player in the cql() specification" [run {cql(:player "Gamma") K}] 1
check "result in the cql() specification" [run {cql(:result 0-1) K}] 2
check "event in the cql() specification" [run {cql(:event "Sicilian") K}] 1
check "site in the cql() specification" [run {cql(:site "?") K}] $games
check "year in the cql() specification" [run {cql(:year 1999) K}] 0
check "elo in the cql() specification" [run {cql(:elo 2000 3000) K}] 0
check "result 1-0" [run {cql() :result 1-0 K}] 1
check "result 0-1" [run {cql() :result 0-1 K}] 2
check "result draw" [run {cql() :result 1/2-1/2 K}] 1
check "event" [run {cql() event "Sicilian" K}] 1
check "event that is nobody's" [run {cql() event "NoSuch" K}] 0
check "site" [run {cql() site "?" K}] $games
check "year" [run {cql() year 2026 mate}] 1
check "year that excludes the base" [run {cql() year 1999 K}] 0
check "elo range with no rated games" [run {cql() elo 2000 3000 K}] 0
check "the game number and a tag filter together" \
    [run {cql(:gamenumber 1 2) player "Alpha"}] 1

# Safety: an "or" can match through its other branch, so a rejecting tag
# filter inside it must not reject the game.
check "a rejecting branch after 'or' does not reject the game" \
    [run {cql() mate or player "NoSuch"}] 1
check "a rejecting branch before 'or' does not reject the game" \
    [run {cql() player "NoSuch" or mate}] 1

puts "\n== parallel workers (a base big enough to split) ==\n"
# sc_search cql splits the candidates across threads once there are enough of
# them, and each worker parses its own copy of the query. Repeating this PGN
# gives a base large enough to take that path; every count must be the serial
# one scaled by the number of copies.
set small $id
set copies 600
set in [open $pgn r]
set game [read $in]
close $in
set out [file tempfile bigPgn cqlcheck.pgn]
for {set i 0} {$i < $copies} {incr i} {
    puts -nonewline $out $game
}
close $out
set id [sc_base create MEMORY cql_check_parallel]
sc_base switch $id
sc_base import $id $bigPgn
file delete $bigPgn
set games [sc_base numGames $id]
puts "base: $games games from $copies copies"
check "a plain designator matches every game" [run {cql() K}] $games
check "mate in every copy" [run {cql() mate}] $copies
check "player in every copy" [run {cql() player "Eta" mate}] $copies
check "player that is nobody" [run {cql() player "NoSuch" mate}] 0
check "result 0-1 in every copy" \
    [run {cql() :result 0-1 K}] [expr {2 * $copies}]
check "a :gamenumber range in the middle" \
    [run {cql(:gamenumber 1000 1010) K}] 11
check "a :gamenumber range at the end" \
    [run "cql(:gamenumber [expr {$games - 5}] $games) mate"] 1
set id $small
sc_base switch $id

puts "\n== filter operations ==\n"
check "two games to start from" [run {cql(:gamenumber 1 2) K}] 2
check "and: no intersection" [run {cql() :result 1/2-1/2 mate} and] 0
check "two games again" [run {cql(:gamenumber 1 2) K}] 2
check "or: union" [run {cql() mate} or] 3
check "reset starts again" [run {cql() mate} reset] 1

puts "\n[expr {$fails ? "FAILED $fails" : "all checks passed"}]"
exit [expr {$fails ? 1 : 0}]
