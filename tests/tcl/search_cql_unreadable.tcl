# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# search_cql_unreadable.tcl -- a CQL search over a base holding a game whose
# gamefile record cannot be read.
#
#   xvfb-run -a ./scidCommunity tests/tcl/search_cql_unreadable.tcl
#
# Hugh Whelan's 4.45M-game database held one malformed record, and every CQL
# search over it ended in "Error reading game file." after a 55 s scan;
# 6e7b52ca made sc_search_cql skip a game that does not decode instead of
# failing the whole search. No other harness can reach that path: the fixtures
# they import were written by the importer itself, so every record decodes.
# This one builds a real file-based base, closes it, overwrites exactly one
# game's record in the .sg4 file with bytes that cannot decode, and reopens it.
# The index entry is left alone - the game keeps its offset and a non-zero
# length - so it stays a candidate and the search has to survive reading it.
# That is why the fixture has to be damaged on disk: nothing the Tcl layer can
# do produces a record that fails scidBaseT::getGame().
#
# What this proves: the search returns TCL_OK instead of "Error reading game
# file.", dbfilter holds exactly the readable matches, an `or` search leaves the
# damaged game out while adding the games that match outside the filter, and a
# second search gives the same filter - the skip leaves no half-read gamefile
# state behind. Every count below moves without the damage (qh4 matches two
# games, not one, and nothing is skipped), so removing the skip from the search
# is visible here rather than on a user's damaged database.

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

# ---------------------------------------------------------------------------
# The fixture: five games with distinct players, so a header filter can name
# any one of them, and exactly two of them end in Qh4#. Game 2 is the one that
# gets damaged, so a readable game still follows it in the gamefile (a record
# that was the last in the file could be shortened or extended without
# touching another game's data, which would hide a mistake in the damage).
# ---------------------------------------------------------------------------
set tmp [expr {[info exists ::env(TMPDIR)] && $::env(TMPDIR) ne "" ? $::env(TMPDIR) : "/tmp"}]
set stem [file join $tmp "search_cql_unreadable[pid]"]
set pgn "$stem.pgn"
set base "$stem"

proc cleanup {} {
    global base id
    catch {sc_base close $id}
    file delete -force {*}[glob -nocomplain "$base.*"]
}

set fh [open $pgn w]
puts $fh {[Event "Damaged base"]
[Site "?"]
[Date "2026.01.01"]
[Round "1"]
[White "Alice"]
[Black "Zed"]
[Result "1-0"]

1. f3 e5 2. g4 Qh4# 1-0

[Event "Damaged base"]
[Site "?"]
[Date "2026.01.01"]
[Round "2"]
[White "Bob"]
[Black "Yan"]
[Result "1-0"]

1. f3 e5 2. g4 Qh4# 1-0

[Event "Damaged base"]
[Site "?"]
[Date "2026.01.01"]
[Round "3"]
[White "Carol"]
[Black "Xer"]
[Result "1/2-1/2"]

1. e4 e5 2. Nf3 Nc6 1/2-1/2

[Event "Damaged base"]
[Site "?"]
[Date "2026.01.01"]
[Round "4"]
[White "Dave"]
[Black "Wes"]
[Result "1-0"]

1. d4 d5 2. c4 e6 1-0

[Event "Damaged base"]
[Site "?"]
[Date "2026.01.01"]
[Round "5"]
[White "Eve"]
[Black "Vic"]
[Result "0-1"]

1. e4 c5 2. Nf3 d6 0-1
}
close $fh

# ---------------------------------------------------------------------------
# Reading the .si4 index: 8 bytes of magic, then the version (2), the base type
# (4), the number of games (3), the autoload game (3), a 108-byte description
# and six 9-byte custom-flag descriptions. Each game then has a 47-byte entry
# whose first four bytes are the offset of its record in the .sg4 gamefile and
# whose next three hold its length: the low 16 bits, then a byte whose top bit
# is length bits 16.. and whose low six bits are custom flags (src/indexentry.h,
# src/codec_scid4.cpp). The Tcl layer exposes none of this, so the harness parses
# it to find the record it is about to damage - and to show that the index entry
# it leaves behind is the one it thinks it is.
# ---------------------------------------------------------------------------
proc readBytes {fh n} {
    set data [read $fh $n]
    if {[string length $data] != $n} { error "short read from the database file" }
    binary scan $data c* bytes
    set out {}
    foreach b $bytes {
        if {$b < 0} { set b [expr {$b + 256}] }
        lappend out $b
    }
    return $out
}
proc beUInt {bytes} {
    set v 0
    foreach b $bytes { set v [expr {$v * 256 + $b}] }
    return $v
}

# Return {magic numGames headerSize {offset length}} for one 1-based game.
proc indexEntry {si4 game} {
    set fh [open $si4 rb]
    # The magic is the C string "Scid.si", so its eighth byte is the NUL.
    set magic [string trimright [read $fh 8] "\0"]
    read $fh 2                       ;# version
    read $fh 4                       ;# base type
    set numGames [beUInt [readBytes $fh 3]]
    read $fh 3                       ;# autoload game
    read $fh 108                     ;# description
    read $fh 54                      ;# six custom-flag descriptions
    set header [tell $fh]
    seek $fh [expr {$header + 47 * ($game - 1)}]
    set entry [readBytes $fh 47]
    close $fh
    if {[llength $entry] != 47} { error "short index entry" }
    set offset [beUInt [lrange $entry 0 3]]
    set lenLow [beUInt [lrange $entry 4 5]]
    set lenFlags [lindex $entry 6]
    set length [expr {(($lenFlags & 0x80) << 9) | $lenLow}]
    return [list $magic $numGames $header [list $offset $length]]
}

# The game numbers in dbfilter, in order. gameslist returns three elements per
# game - "number_ply", the game info and the extras - so the number is the part
# of the first one before the underscore.
proc filterGames {id} {
    set n [sc_base numGames $id]
    if {$n == 0} { return {} }
    set out {}
    foreach {tag info extra} [sc_base gameslist $id 0 $n dbfilter N+] {
        lappend out [lindex [split $tag _] 0]
    }
    return $out
}

# Run a CQL search and leave the result string in ::report. Returns the catch
# code, so a fatal read ("Error reading game file.") shows up as an error rather
# than as a count.
proc search {query {op reset}} {
    set code [catch {sc_search cql $op 0 1 $query} ::report]
    return $code
}

# ---------------------------------------------------------------------------
# A base whose games all decode.
# ---------------------------------------------------------------------------
puts "\n== a five-game base, two games ending in Qh4# ==\n"
set id [sc_base create SCID4 $base]
sc_base switch $id
sc_base import $id $pgn
checkEq "the base holds the five games" [sc_base numGames $id] 5

puts "\n== the search matches both of them before any damage ==\n"
checkEq "the query returns normally" [search "cql() qh4"] 0
checkEq "and matches the two fool's mates" [sc_filter count $id dbfilter] 2
checkEq "games 1 and 2" [filterGames $id] {1 2}
checkEq "the whole base matches a plain piece designator" \
    [expr {[search "cql() K"] == 0 ? [sc_filter count $id dbfilter] : "error"}] 5

# ---------------------------------------------------------------------------
# Damage: close the base, overwrite game 2's record with bytes that cannot
# decode, reopen. The record is overwritten in place - same length, same file
# size - because a 0xFF byte is read as a tag length of 255, the special
# three-byte EventDate encoding: each pass through decodeTags() then consumes
# five bytes and never meets the zero that ends the tag section, so the decode
# runs off the end of the record and returns ERROR_Decode. That is the failure
# getGame() reports for a malformed game on a real database, and the index entry
# still points at the record.
# ---------------------------------------------------------------------------
puts "\n== one record is damaged on disk, its index entry left alone ==\n"
checkEq "the base closes" [catch {sc_base close $id}] 0
set si4 "$base.si4"
set sg4 "$base.sg4"
lassign [indexEntry $si4 2] magic numGames header offsetLen
checkEq "the index file is a Scid index" $magic "Scid.si"
checkEq "it still lists the five games" $numGames 5
lassign $offsetLen offset length
check "the damaged game keeps a record of its own" [expr {$length > 0}] \
    "offset $offset length $length"
check "the record starts inside the gamefile" \
    [expr {$offset + $length <= [file size $sg4]}] "offset $offset length $length"
set sg4Size [file size $sg4]

set fh [open $sg4 r+b]
fconfigure $fh -translation binary
seek $fh $offset
puts -nonewline $fh [binary format c* [lrepeat $length 0xFF]]
close $fh
checkEq "the damage does not change the gamefile's size" [file size $sg4] $sg4Size

set fh [open $sg4 rb]
seek $fh $offset
set damaged [readBytes $fh $length]
close $fh
checkEq "the record now holds the sentinel bytes" $damaged [lrepeat $length 255]
lassign [indexEntry $si4 2] magic numGames header offsetLen
checkEq "the index entry is unchanged" $offsetLen [list $offset $length]

puts "\n== the base still opens, and only that game is unreadable ==\n"
set id [sc_base open $si4]
sc_base switch $id
checkEq "the reopened base is the current one" [sc_base current] $id
checkEq "the base reopens with its five games" [sc_base numGames $id] 5
checkEq "the readable neighbour reads" [catch {sc_game load 1}] 0
checkEq "the damaged game does not" [catch {sc_game load 2} err] 1
check "its reader says the record is corrupt" \
    [expr {[string first "corrupt" $err] >= 0}] $err
checkEq "the record after it still reads" [catch {sc_game load 3}] 0

# ---------------------------------------------------------------------------
# The search itself. This is the path 6e7b52ca fixed: before it, the game 2
# record above made every CQL search over the base return "Error reading game
# file." after walking the whole base.
# ---------------------------------------------------------------------------
puts "\n== the search skips the damaged game instead of failing ==\n"
checkEq "the search returns TCL_OK" [search "cql() qh4"] 0
check "there is no read error in the report" \
    [expr {[string first "Error reading game file." $::report] < 0}] $::report
checkEq "only the readable fool's mate is in the filter" [sc_filter count $id dbfilter] 1
checkEq "game 1" [filterGames $id] {1}
check "the damaged game is not in the filter" \
    [expr {[lsearch -exact [filterGames $id] 2] < 0}] [filterGames $id]

puts "\n== an or search leaves the damaged game out too ==\n"
# The search has to add every readable game the query matches outside the
# filter - and reach the damaged record again while doing it, because an OR
# search scans the games that are out of the filter.
checkEq "the or search returns TCL_OK" [search "cql() K" or] 0
check "there is no read error in the report" \
    [expr {[string first "Error reading game file." $::report] < 0}] $::report
checkEq "the four readable games are in the filter" [sc_filter count $id dbfilter] 4
checkEq "games 1 and 3 to 5" [filterGames $id] {1 3 4 5}
check "the damaged game was not added" \
    [expr {[lsearch -exact [filterGames $id] 2] < 0}] [filterGames $id]

puts "\n== the base is still usable afterwards ==\n"
# The skip must not leave the gamefile half-read: a second search over the same
# damaged base has to give the same filter, and a good game after the damaged
# one has to read as it did before.
checkEq "the second search returns TCL_OK" [search "cql() qh4"] 0
checkEq "and gives the same filter" [filterGames $id] {1}
checkEq "a readable game after the damaged one still reads" [catch {sc_game load 5}] 0
sc_move forward 1
checkEq "and its moves are the ones that were imported" \
    [expr {[catch {sc_pos side}] == 0 ? [sc_pos side] : "error"}] black
# The damage is confined to the record: the index entry still names the game's
# players, which is what keeps the damaged game a search candidate.
sc_filter reset $id dbfilter full
checkEq "the base still knows who the damaged game was" \
    [expr {[string first "Bob" [sc_base gameslist $id 0 5 dbfilter N+]] >= 0}] 1

puts "\n== the search says how many games it could not read ==\n"
# The report is the statistics line plus the count of games whose record could
# not be read (the window words that count in the user's language). The count is
# asserted unconditionally: a result that carries only the statistics line is
# the regression this harness exists for, so it must fail rather than be noted.
search "cql() qh4"
set report $::report
check "it reports the one game it could not read" \
    [expr {[llength $report] == 2 && [lindex $report 1] == 1}] $report

cleanup
puts ""
if {$fails} {
    puts "FAILED $fails of $checks checks"
    exit 1
}
puts "$checks checks, 0 failures"
exit 0
