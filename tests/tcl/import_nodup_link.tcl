# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# import_nodup_link.tcl -- an updated online game replaces its old copy.
#
#   xvfb-run -a ./scidCommunity tests/tcl/import_nodup_link.tcl
#
# A daily game imported while it was in progress must be updated in place
# when the finished PGN (same chess.com Link) arrives. The old short copy and
# the new long copy must not both remain in the database.

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

set stem [file join /tmp "scid_import_link_[pid]"]
set shortPgn "${stem}_short.pgn"
set longPgn "${stem}_long.pgn"
set tags {[Event "Live Chess"]
[Site "Chess.com"]
[Date "2026.11.10"]
[Round "-"]
[White "alice"]
[Black "bob"]
[Link "https://www.chess.com/game/daily/123456"]}

set fd [open $shortPgn w]
puts $fd $tags
puts $fd {[Result "*"]}
puts $fd ""
puts $fd {1. e4 {[%clk 0:03:00]} e5 2. Nf3 Nc6 3. Bb5 a6 *}
close $fd
set fd [open $longPgn w]
puts $fd $tags
puts $fd {[Result "1-0"]}
puts $fd ""
puts $fd {1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 1-0}
close $fd

set h [sc_base create SCID5 "${stem}_db"]
lassign [sc_base import_nodup $h $shortPgn] ni ns nu
check "the short game is imported once" [expr {$ni == 1 && $ns == 0 && $nu == 0}] "imported=$ni skipped=$ns updated=$nu"
lassign [sc_base import_nodup $h $longPgn] ni ns nu
check "the finished game updates the short copy" [expr {$ni == 0 && $ns == 0 && $nu == 1}] "imported=$ni skipped=$ns updated=$nu"
check "there is still one game" [expr {[sc_base numGames $h] == 1}] "games=[sc_base numGames $h]"
sc_game load 1
set pgn [sc_game pgn -tags 0]
check "the stored game has the full move list" [expr {[string first "5.O-O" $pgn] >= 0}] $pgn
lassign [sc_base import_nodup $h $shortPgn] ni ns nu
check "the shorter PGN does not downgrade it" [expr {$ni == 0 && $ns == 1 && $nu == 0}] "imported=$ni skipped=$ns updated=$nu"
check "there is still one game after the short re-import" [expr {[sc_base numGames $h] == 1}]
sc_base close $h

foreach f [glob -nocomplain "${stem}*"] {
    catch {file delete -force $f}
}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
