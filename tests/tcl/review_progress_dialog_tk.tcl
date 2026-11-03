#!/usr/bin/env wish
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_progress_dialog_tk.tcl -- the progress popup's widgets, under Tk.
#
#   xvfb-run -a wish tests/tcl/review_progress_dialog_tk.tcl
#
# The tclsh harness (review_progress_dialog.tcl) decides what the popup shows;
# this builds it and drives the parts only a widget can answer: that it is one
# window and not two, that its board is sized without a measured width, that it
# carries no bindings, that a position published while it was covered is on
# screen when it comes back, and that closing it cancels nothing.

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

# --- the app's surface, as much of it as the popup touches --------------------
array set ::EN {
    ReviewProgressTitle        {Review progress}
    ReviewProgressIdle         {No review is running}
    ReviewProgressProgress     {Reviewing position %s of %s}
    ReviewProgress             {Reviewing position %s of %s}
    ReviewProgressGameOf       {game %s of %s}
    ReviewProgressEngineWindow {Engine window %s}
    ReviewProgressAnalysisPane {Analysis pane %s}
    ReviewProgressRapid        {Rapid annotate}
    ReviewGameButton           {Game Review}
    ReviewMoveButton           {Move Comment}
    Annotate                   {Annotate}
    FinishGame                 {Finish game}
    Cancel                     {Cancel}
}
proc tr {tag args} {
    if {[info exists ::EN($tag)]} { return [expr {[llength $args] ? [format $::EN($tag) {*}$args] : $::EN($tag)}] }
    return $tag
}
namespace eval ::icon {}
namespace eval ::utils::tooltip {}
namespace eval ::board {}
namespace eval ::reviewui {}
namespace eval ::reviewdriver {}
proc ::utils::tooltip::Set args {}
proc ::setTitle {w text} { wm title $w $text }
foreach f {font_Small font_SmallBold} { set ::$f TkDefaultFont }
proc ::tk::PlaceWindow {w args} { return }
# The board the popup draws on: ::board::new builds $w.bd, as tcl/board.tcl does,
# and records what it was asked to draw.
proc ::board::new {w {psize 40}} {
    canvas $w.bd -width [expr {8 * $psize}] -height [expr {8 * $psize}] \
        -highlightthickness 0
    set ::board::size($w) $psize
    return $w
}
proc ::board::update {w board {animate 0}} {
    set ::board::drawn($w.bd) $board
    set ::board::animate($w.bd) $animate
    return
}

source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools review_progress.tcl]
source [file join $root tcl tools review_progress_ui.tcl]
# passFraction lives with the other review UI decisions; only it is needed here.
proc ::reviewui::passFraction {done total} { return 0 }

proc ::reviewdriver::cancel {} { set ::cancelled 1 }

proc settle {} { update idletasks ; update }

puts "== one window, built on first use and reused =="

set win [::reviewprogress::ui::show]
settle
check "the popup exists" [winfo exists $win]
set first $win
::reviewprogress::ui::hide
settle
check "hiding withdraws rather than destroying" [expr {[winfo exists $win] && [wm state $win] eq "withdrawn"}]
set again [::reviewprogress::ui::show]
settle
checkEq "showing again reuses the same toplevel" $again $first
check "exactly one popup exists" [expr {[llength [winfo children .]] >= 1}]

puts "== the board is sized without a measured width, and is read-only =="

set canvas $win.board.bd
check "the canvas exists" [winfo exists $canvas]
# A canvas built while the window is withdrawn has no geometry; the explicit
# psize is what gives it one. The stub records the psize it was handed, which is
# the property that matters: the window never asks the canvas how wide it is.
check "the board is built at the explicit psize, not a measured width" \
    [expr {[info exists ::board::size($win.board)] \
        && $::board::size($win.board) == 40}]
check "the canvas is out of the focus order" \
    [expr {[string trim [$canvas cget -takefocus]] eq "0"}]
check "no square bindings are installed" \
    [expr {[bind $canvas] eq ""}]

puts "== a run feeds the header and the board, and a covered one keeps up =="

set token [::reviewprogress::begin [dict create \
    source review engine {Stockfish Deep} origin {enginewin 2}]]
settle
checkEq "the header is the string the run composed" \
    [$win.header cget -text] {Game Review — Stockfish Deep (Engine window 2)}

set fen {rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1}
set want {RNBQKBNRPPPP.PPP............P...................pppppppprnbqkbnr}
::reviewprogress::setPosition $token $fen 12 40
settle
checkEq "the board shows the position the run is searching" \
    $::board::drawn($canvas) $want
check "the redraw is animated off" [expr {$::board::animate($canvas) == 0}]

# Covered does not mean paused: the run publishes while the window is hidden,
# and <Map> draws what is current rather than what was current when it went.
::reviewprogress::ui::hide
settle
set fen2 {rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2}
::reviewprogress::setPosition $token $fen2 20 40
settle
check "a covered window keeps the run going" \
    [expr {[dict get [::reviewprogress::job] token] eq $token}]
::reviewprogress::ui::show
settle
checkEq "uncovering redraws from the current position" \
    $::board::drawn($canvas) \
    [::reviewprogress::positionToBoard $fen2]

puts "== closing cancels nothing; Cancel is the run's own =="

set ::cancelled 0
::reviewprogress::ui::hide
settle
check "closing the popup does not cancel the run" [expr {$::cancelled == 0}]
check "the job outlives the window" [expr {[dict size [::reviewprogress::job]] > 0}]

::reviewprogress::ui::show
settle
$win.cancel invoke
settle
check "Cancel asks the run to stop" [expr {$::cancelled == 1}]

::reviewprogress::finish $token
settle
checkEq "a finished run leaves the popup idle" \
    [$win.progress cget -text] {No review is running}

puts ""
puts "$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
