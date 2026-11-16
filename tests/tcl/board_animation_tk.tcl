#!/usr/bin/env wish
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# The two ::board redraw promises the sergame draw/resign dialogs rely on:
#
#   xvfb-run -a wish tests/tcl/board_animation_tk.tcl
#
#   1. ::board::waitForAnimation forces a redraw before the dialog is raised.
#      It called "update", which inside ::board is ::board::update -- a
#      different command with a different arity -- so the call raised, catch
#      swallowed it, and no redraw happened.
#   2. A cancelled animation leaves no move in flight. ::board::update cancels
#      the pending ::board::_animate, but cleared the moving flag only when the
#      redraw also asked for no animation: with animate 1 and an unchanged board
#      no new animation starts, the flag stayed 1, and waitForAnimation's vwait
#      waited for something nothing was going to clear.

set fails 0
set checks 0
proc check {name cond {detail ""}} {
    global fails checks
    incr checks
    if {![uplevel 1 [list expr $cond]]} {
        incr fails
        if {$detail eq ""} { puts "FAIL $name" } else { puts "FAIL $name -- $detail" }
    } else { puts "ok   $name" }
}

# The stubs tcl/board.tcl's load-time InitBoard needs: a piece sheet set, board
# textures, the theme hook, a colour pair, and sc_pos for ::board::new.
namespace eval ::board {}
set root [file normalize [file join [file dirname [info script]] .. ..]]
set ::scidImgDir [file join $root img]
set ::boardStyles {Default}
set ::boardStyle Default
set ::boardSize 40
image create photo texLite -width 20 -height 20
image create photo texDark -width 20 -height 20
set ::boardfile_lite texLite
set ::boardfile_dark texDark
set ::borderwidth 5
set ::squareColor_lite "#ffffff"
set ::squareColor_dark "#888888"
set ::glossOfDanger 0
set ::START "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr"
proc tr {s} { return $s }
proc ::applyThemeColor_background {args} {}
proc sc_pos {args} { return $::START }

source [file join $root tcl board.tcl]

::board::new .b 40

puts "the redraw waitForAnimation promises"
set ::tick 0
after 0 {set ::tick 1}
::board::waitForAnimation 0
check "waitForAnimation drains pending idle work" [expr {$::tick == 1}] "tick=$::tick"

puts "\na cancelled animation"
::board::update .b $::START 0
check "a first redraw is the position it was given" \
    [expr {$::board::_data(.b) eq $::START}]

# A move animation is in flight and a redraw is asked for with animate 1 while
# the board does not change: the animation is cancelled and no new one starts,
# so this is the only place the moving flag can be cleared -- leave it and
# waitForAnimation's vwait below never returns.
set ::board::_animate(.b,moving) 1
after 0 "::board::_animate .b"
::board::update .b $::START 1
check "the moving flag is cleared when the animation is cancelled" \
    [expr {$::board::_animate(.b,moving) == 0}] \
    "moving=$::board::_animate(.b,moving)"
# With nothing left to clear it, this returns at once on a cleared flag and
# blocks the dialogs forever on a stale one.
::board::waitForAnimation 0
check "waitForAnimation returns" 1

puts "\n$checks checks, $fails failures"
exit [expr {$fails > 0}]
