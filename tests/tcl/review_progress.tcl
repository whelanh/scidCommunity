#!/usr/bin/env tclsh
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_progress.tcl -- the review progress board, without Tk.
#
#   tclsh tests/tcl/review_progress.tcl
#
# The progress board is decoration over a run: it is fed a position as a FEN,
# never the game, so it cannot move the user's board and cannot fight it for
# control. Everything that decides what it shows lives here, where tclsh can
# reach it: the FEN-to-board-string feed, the header each source composes, and
# the rule that a borrowed game is written without a frame being painted while
# it is current.

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
source [file join $root tcl utils chessboard.tcl]

# The English text of every key this file adds. tr() answers in the reader's
# language in the app; a tclsh test has no language files, so it answers from
# here and an unknown tag answers itself, which is what Scid does for an
# untranslated string.
array set ::EN {
    ReviewGameButton           {Game Review}
    ReviewMoveButton           {Move Comment}
    Annotate                   {Annotate}
    FinishGame                 {Finish game}
    ReviewProgress             {Reviewing position %s of %s}
    ReviewProgressTitle        {Review progress}
    ReviewProgressIdle         {No review is running}
    ReviewProgressGameOf       {game %s of %s}
    ReviewProgressEngineWindow {Engine window %s}
    ReviewProgressAnalysisPane {Analysis pane %s}
    ReviewProgressRapid        {Rapid annotate}
}
proc tr {tag args} {
    if {[info exists ::EN($tag)]} { return $::EN($tag) }
    return $tag
}

source [file join $root tcl tools review_progress.tcl]

puts "== the position feed: a FEN becomes a board string =="

# ::board::update draws a 64-character string, index 0 = a1, upper case white,
# lower case black, "." for an empty square. Nothing else is drawn from it, so
# this is the whole contract between a run and the board.
checkEq "start position" \
    [::reviewprogress::positionToBoard \
        {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}] \
    {RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr}

checkEq "after 1.e4" \
    [::reviewprogress::positionToBoard \
        {rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1}] \
    {RNBQKBNRPPPP.PPP............P...................pppppppprnbqkbnr}

# The board string carries no side-to-move marker: that is the board's own
# field, and a progress board that showed it would be reading the game.
check "a FEN with no board part is refused rather than painted" \
    [expr {[::reviewprogress::positionToBoard ""] eq ""}]
check "a malformed FEN is refused rather than raising" \
    [expr {[::reviewprogress::positionToBoard {not/a/fen}] eq ""}]

puts "== the header names the engine and the source =="

# A header is composed where the run starts and carried in the job as a string:
# a lookup at draw time could name the engine of the window the user has since
# switched, which is the one thing the header must never do.
checkEq "Game Review in an engine window" \
    [::reviewprogress::header [dict create \
        source review engine {Stockfish Deep} origin [list enginewin 2]]] \
    {Game Review — Stockfish Deep (Engine window 2)}

checkEq "Move Comment in an engine window" \
    [::reviewprogress::header [dict create \
        source movecomment engine {Stockfish Deep} origin [list enginewin 2]]] \
    {Move Comment — Stockfish Deep (Engine window 2)}

checkEq "annotate in an analysis pane" \
    [::reviewprogress::header [dict create \
        source annotate engine {Stockfish Deep} origin [list analysispane 1]]] \
    {Annotate — Stockfish Deep (Analysis pane 1)}

checkEq "a batch pass carries the game number" \
    [::reviewprogress::header [dict create source annotate engine {Stockfish Deep} \
        origin [list analysispane 1] game 47 total 200]] \
    {Annotate — Stockfish Deep (Analysis pane 1) · game 47 of 200}

checkEq "a single-game pass carries no game number" \
    [::reviewprogress::header [dict create source annotate engine {Stockfish Deep} \
        origin [list analysispane 1] game 47]] \
    {Annotate — Stockfish Deep (Analysis pane 1)}

checkEq "Finish Game names its source" \
    [::reviewprogress::header [dict create \
        source finish engine {Stockfish Deep} origin [list enginewin 1]]] \
    {Finish game — Stockfish Deep (Engine window 1)}

checkEq "Rapid annotate names its source" \
    [::reviewprogress::header [dict create source rapid engine {Stockfish Deep} \
        origin [list enginewin 1]]] \
    {Rapid annotate — Stockfish Deep (Engine window 1)}

# An engine name is not guaranteed: a run can be started from a window whose
# preset has since been deleted, and a header of "Game Review —  ()" is worse
# than one that names only what it knows.
checkEq "a missing engine name leaves no empty dash" \
    [::reviewprogress::header [dict create source review engine "" origin ""]] \
    {Game Review}

puts "== the job carries what it shows =="

set ::painted {}
proc ::recorder {job} { lappend ::painted $job ; return }

::reviewprogress::setPainter ::recorder
set token [::reviewprogress::begin [dict create \
    source review engine {Stockfish Deep} origin [list enginewin 2]]]
check "begin answers a token" [expr {$token ne ""}]
check "the window hears that a run started" [expr {[llength $::painted] == 1}]

::reviewprogress::setPosition $token \
    {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1} 12 40
set job [::reviewprogress::job]
checkEq "the job's header is the field begin composed" \
    [dict get $job header] {Game Review — Stockfish Deep (Engine window 2)}
checkEq "the job's board is the position it was fed" \
    [dict get $job board] {RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr}
checkEq "the progress line counts the position" \
    [::reviewprogress::progressText $job] {Reviewing position 12 of 40}
check "the painter was called with the job" [expr {[llength $::painted] == 2}]

# A position the feed refuses is not painted: a stray frame of the wrong
# position is worse than a stale one, and the run keeps its last good board.
::reviewprogress::setPosition $token "" 13 40
checkEq "a refused position leaves the last board in place" \
    [dict get [::reviewprogress::job] board] \
    {RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr}

# The window is decoration: a run that ends leaves no job, and the next one
# starts from the same slot rather than from a stale header.
::reviewprogress::finish $token
checkEq "no job once the run has ended" [::reviewprogress::job] {}

puts "== a borrowed game is written without a frame being painted =="

# The borrow idiom (tcl/game.tcl:65) is what lets a run write a game the reader
# is not looking at: push a copy, load the target, edit, save, pop. It walks the
# board while the target game is current - the very thing this card exists to
# stop - unless nothing may paint between the push and the pop. Tcl only paints
# at idle, so the rule is simply that the commit calls no paint entry point.
#
# Every entry point is stubbed, and each one that would paint records and
# raises: a commit that paints is not a commit that quietly flickers, it is a
# commit this test cannot get through.

namespace eval ::sc_game {}
namespace eval ::sc_move {}
namespace eval ::sc_pos {}
namespace eval ::uci {}
namespace eval ::review {}
namespace eval ::board {}
namespace eval ::notify {}

set ::calls {}
set ::painted 0
set ::undo 0
proc ::record {what} { lappend ::calls $what ; return }
proc ::paintCall {what} { incr ::painted ; lappend ::calls "PAINT $what" ; error "painted: $what" }
proc ::update args { ::paintCall update }
proc ::updateBoard args { ::paintCall updateBoard }
proc ::sc_game {args} { ::record "game $args" ; return "" }
proc ::sc_move {args} { ::record "move $args" ; return "" }
proc ::sc_pos {args} { ::record "pos $args" ; return "" }
proc ::undoFeature {what args} {
    if {$what eq "save"} { ::record undosave ; return }
    incr ::undo ; ::record "undo $what"
}
proc ::uci::sc_move_add {uci} { ::record "add $uci" ; return 0 }
proc ::notify::PosChanged args { ::paintCall notify }
proc ::board::update args { ::paintCall board }
proc ::review::mergeComment {existing new} { return [string trim "$existing $new"] }
proc ::review::cursorSave {} { ::record cursorsave ; return {loc 0 base 0 path {} fen {}} }
proc ::review::cursorRestore {state} { ::record cursorrestore ; return 1 }

# --- a game the reader is not looking at ---------------------------------------
set ::calls {}
set ::painted 0
set ::undo 0
set err [::reviewprogress::commitMoves 47 {e2e4 e7e5 g1f3}]

checkEq "the borrow wrote the game and said so" $err {}
check "nothing painted while the borrowed game was current" [expr {$::painted == 0}]

set order [list "game push copy" "game load 47" "move end" \
    "add e2e4" "add e7e5" "add g1f3" "game save 47" "game pop"]
set got {}
foreach call $::calls {
    if {[string match "add *" $call] || [string match "game *" $call] \
            || $call eq "move end"} {
        lappend got $call
    }
}
checkEq "the writes land once each, and the borrow is popped last" \
    [lrange $got 0 1] [lrange $order 0 1]
checkEq "the borrowed moves are appended at the end of the line" \
    [lrange $got 2 5] [lrange $order 2 5]
checkEq "the borrowed game is saved before it is popped" \
    [lrange $got 6 7] [lrange $order 6 7]
check "the cursor is put back exactly once" \
    [expr {[lsearch -exact $::calls cursorrestore] == \
        [expr {[llength $::calls] - 2}]}]
check "a commit that works leaves the undo layer alone" [expr {$::undo == 0}]

# --- the game the reader is looking at ----------------------------------------
set ::calls {}
set ::painted 0
set err [::reviewprogress::commitMoves "" {e2e4 e7e5}]
checkEq "the open game is written without a borrow" $err {}
check "the open game is not loaded, saved or popped" \
    [expr {[lsearch -exact $::calls "game load 47"] < 0}]
check "the open game's moves are appended at the end" \
    [expr {[lsearch -exact $::calls "move end"] >= 0}]
check "nothing painted for the open game either" [expr {$::painted == 0}]

# --- a refused move leaves nothing behind -------------------------------------
set ::calls {}
set ::painted 0
set ::undo 0
proc ::uci::sc_move_add {uci} {
    ::record "add $uci"
    if {$uci eq "g1f3"} { return 1 }
    return 0
}
set err [::reviewprogress::commitMoves 47 {e2e4 e7e5 g1f3}]
check "a refused move is reported, not swallowed" [expr {$err ne ""}]
check "a refused move undoes the writes it had made" [expr {$::undo > 0}]
check "a refused commit still pops the borrow" \
    [expr {[lindex $::calls end] eq "game pop"}]
check "nothing painted on a refused commit" [expr {$::painted == 0}]

# --- cancel is not a commit ---------------------------------------------------
# The collect phase never touches the game, so a run cancelled during the
# search has nothing to undo. This is the whole of "cancel writes nothing".
set ::calls {}
checkEq "an empty move list is not a write at all" \
    [::reviewprogress::commitMoves 47 {}] {}
check "an empty move list still does not touch a game" \
    [expr {[lsearch -exact $::calls "game push copy"] < 0}]

puts ""
puts "$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
