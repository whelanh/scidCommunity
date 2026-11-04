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

puts "\nthe rapid pass feeds the progress board"

# Rapid annotate is the engine window's own Autoscan pass, not a reviewdriver
# pass, so this file owns the job: it begins one for the window on the first
# line it records and publishes the position the engine is on. The window is
# stubbed here because the job, not the widget, is what this gates.
proc ::tr {tag args} {
    switch -- $tag {
        ReviewProgressRapid { return {Rapid annotate} }
        ReviewProgressEngineWindow { return {Engine window %s} }
        ReviewProgressAnalysisPane { return {Analysis pane %s} }
        ReviewProgressIdle { return {No review is running} }
        ReviewProgress { return {%s of %s} }
        ReviewProgressGameOf { return {game %s of %s} }
        default { return $tag }
    }
}
source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools review_progress.tcl]
proc ::enginewin_lastengine {id} { return {Stockfish Deep} }
# ::enginewin_lastengine is an array in the app, not a proc: the popup reads
# `$::enginewin_lastengine($id)`.
unset -nocomplain ::enginewin_lastengine
set ::enginewin_lastengine(1) {Stockfish Deep}
set ::sc_fen {rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1}
proc sc_pos {args} { return $::sc_fen }
proc ::rapid_annotate::mainLinePositions {} { return {1 a 2 b 3 c 4 d} }
proc ::rapid_annotate::pending {} { return 2 }

::rapid_annotate::publishProgress 1
set job [::reviewprogress::job]
checkEq "a recorded line begins a rapid job" [dict get $job source] rapid
checkEq "the header names the engine and its window" [dict get $job header] \
    {Rapid annotate — Stockfish Deep (Engine window 1)}
checkEq "the board is the position the engine is on" [dict get $job board] \
    [::reviewprogress::positionToBoard $::sc_fen]
checkEq "progress counts the positions collected" [dict get $job done] 2
checkEq "out of the main line's length" [dict get $job total] 4

# The engine seeded the search from a main-line position; the pane shows that
# position, not whatever the reader's cursor happens to be.
namespace eval ::enginewin {}
set ::enginewin::pv_(pos,1) {position startpos moves e2e4 e7e5}
::rapid_annotate::publishProgress 1
checkEq "the board is the position the engine searched" \
    [dict get [::reviewprogress::job] board] \
    {RNBQKBNRPPPP.PPP............P.......p...........pppp.ppprnbqkbnr}
unset ::enginewin::pv_(pos,1)

# Ordinary analysis reaches record too; with Autoscan off it must not take the
# pane. The job is finished first, so an empty job is the whole assertion.
::reviewprogress::finish [dict get [::reviewprogress::job] token]
set ::enginewin_autorun(1) {}
::rapid_annotate::publishProgress 1
checkEq "ordinary analysis does not own the board" [::reviewprogress::job] {}
set ::enginewin_autorun(1) {movetime 50}

# A review in flight already owns the board: the rapid pass records its scores
# and leaves the job alone rather than taking the window from the run.
set reviewToken [::reviewprogress::begin [dict create \
    source review engine Stockfish origin [list enginewin 9]]]
set before [::reviewprogress::job]
::rapid_annotate::publishProgress 1
checkEq "a review in flight keeps the board" [::reviewprogress::job] $before
::reviewprogress::finish $reviewToken

# Two engine windows can both Autoscan. The second must not relabel the first
# window's job or leave its Cancel pointing at the wrong engine.
set rapidToken [::reviewprogress::begin [dict create source rapid \
    engine {Stockfish Deep} origin {enginewin 1} cancel {::enginewin::stop 1}]]
set before [::reviewprogress::job]
::rapid_annotate::publishProgress 2
checkEq "another window's Autoscan leaves the job alone" \
    [::reviewprogress::job] $before
::reviewprogress::finish $rapidToken

::rapid_annotate::publishProgress 1
set rapidToken [dict get [::reviewprogress::job] token]
checkEq "the rapid run owns it again" [dict get [::reviewprogress::job] source] rapid
::rapid_annotate::progressDone
checkEq "the end of the pass ends the job" [::reviewprogress::job] {}
checkEq "and leaves no progress line behind" \
    [::reviewprogress::progressText [::reviewprogress::job]] {No review is running}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
