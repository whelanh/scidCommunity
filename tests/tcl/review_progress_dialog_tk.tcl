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
# The pane's current position, for the "no run in flight" path.
proc sc_pos {args} { return {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1} }
# ::board::new, reproduced from tcl/board.tcl:662 as it actually is: a path that
# already exists is refused outright, and both the frame and the canvas inside
# it are created here. The stub this replaced omitted the guard AND the frame,
# which is the only reason the popup's build bug passed 17 green checks. The
# guard is the contract, and a check below asserts the path handed in was new.
proc ::board::new {w {psize 40}} {
    lappend ::board::newCalls $w
    set ::board::preExisted($w) [winfo exists $w]
    if {[winfo exists $w]} { return }
    ttk::frame $w -class Board
    canvas $w.bd -width [expr {8 * $psize}] -height [expr {8 * $psize}] \
        -highlightthickness 0
    grid $w.bd -row 6 -column 3
    set ::board::size($w) $psize
    return $w
}
proc ::board::update {w board {animate 0}} {
    lappend ::board::updates [list $w $board $animate]
    set ::board::drawn($w.bd) $board
    set ::board::animate($w.bd) $animate
    return
}
set ::board::newCalls {}
set ::board::updates {}

source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools review_progress.tcl]
source [file join $root tcl tools review_progress_ui.tcl]
# passFraction lives with the other review UI decisions; only it is needed here.
proc ::reviewui::passFraction {done total} { return 0 }

proc ::reviewdriver::cancel {} { set ::cancelled 1 }

proc settle {} { update idletasks ; update }

puts "== a failing build is reported, not swallowed =="

# The bug that kept this window invisible for two rounds was a silent catch
# around build: the run went on painting into a window that did not exist and
# nobody was told. A build that raises must reach the caller of show().
rename ::reviewprogress::ui::build ::reviewprogress::ui::build_real
proc ::reviewprogress::ui::build {} { error "forced build failure" }
set buildRc [catch { ::reviewprogress::ui::show } buildErr]
check "a failing build is reported, not swallowed" [expr {$buildRc == 1}] \
    "show returned instead of raising"
check "and it says why" [expr {[string match {*forced build failure*} $buildErr]}] \
    "got '$buildErr'"
rename ::reviewprogress::ui::build {}
rename ::reviewprogress::ui::build_real ::reviewprogress::ui::build

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

# ::board::new refuses a path that already exists. The popup handed it a frame
# it had made itself, so the board was never built and the window never appeared.
check "the path handed to ::board::new did not exist yet" \
    [expr {[info exists ::board::preExisted($win.board)] \
        && !$::board::preExisted($win.board)}]
check "::board::new made the Board frame, not a plain one" \
    [expr {[winfo exists $win.board] && [winfo class $win.board] eq "Board"}]

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

puts "== with no run in flight the board shows the pane's position =="

# The idle path calls ::board::update as (w, board, animate). It used to pass
# (w, 0, <board string>), so the string landed in the animate slot and the board
# never drew at all. The spy records the arguments, so the order is the assertion.
set ::board::updates {}
::reviewprogress::ui::show
settle
set last [lindex $::board::updates end]
check "the idle path drew a board" [expr {[llength $last] == 3}] "no call recorded"
checkEq "the board string is the second argument, not the animate slot" \
    [lindex $last 1] [::reviewprogress::positionToBoard \
        {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}]
check "the idle draw is not animated" [expr {[lindex $last 2] == 0}] \
    "got '[lindex $last 2]'"
checkEq "the idle path draws the popup's own board" [lindex $last 0] $win.board

puts ""
puts "$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
