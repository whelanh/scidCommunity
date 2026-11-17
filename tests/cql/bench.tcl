# SPDX-License-Identifier: GPL-2.0-or-later
#
# bench.tcl -- headless timing for "sc_search cql".
#
#   ./scidCommunity tests/cql/bench.tcl ?pgn? ?games? ?rangeEnd?
#
# Builds a MEMORY base by repeating the PGN (five games by default) until it
# holds at least @games games, then times a few queries. No display, no Tk.
# A synthetic base is enough to see whether a change removes work per game: the
# real database only scales the numbers.
#
# Defaults: search_moves.pgn, 100000 games, :gamenumber range ending at 1000.

set here [file dirname [info script]]
set root [file normalize [file join $here .. ..]]
set pgn [expr {
    [llength $argv] > 0 ? [lindex $argv 0]
                        : [file join $root tests tcl search_moves.pgn]
}]
set wantGames [expr {[llength $argv] > 1 ? [lindex $argv 1] : 100000}]
set rangeEnd [expr {[llength $argv] > 2 ? [lindex $argv 2] : 1000}]

set in [open $pgn r]
set game [read $in]
close $in
set perCopy [regexp -all -line {^\[Event } $game]
if {$perCopy < 1} { set perCopy 1 }
set copies [expr {($wantGames + $perCopy - 1) / $perCopy}]

# file tempfile creates the file in the system temporary directory.
set out [file tempfile bigPgn cqlbench.pgn]
for {set i 0} {$i < $copies} {incr i} {
    puts -nonewline $out $game
}
close $out

set id [sc_base create MEMORY cql_bench]
sc_base switch $id
set t [clock milliseconds]
sc_base import $id $bigPgn
file delete $bigPgn
puts "import: [sc_base numGames $id] games in [expr {[clock milliseconds]-$t}] ms"

proc timed {label query} {
    global id
    set t [clock milliseconds]
    sc_search cql reset 0 0 $query
    set ms [expr {[clock milliseconds]-$t}]
    puts [format "%-42s %6d ms  %6d games" $label $ms \
              [sc_filter count $id dbfilter]]
}

puts "\n(include :gamenumber costs one more query below)"
timed ":gamenumber 1 $rangeEnd mate" "cql(:gamenumber 1 $rangeEnd) mate"
timed "full range, mate" {cql() mate}
timed "full range, plain designator" {cql() K}
timed "full range, player that is nobody" {cql() player "NoSuch" mate}
