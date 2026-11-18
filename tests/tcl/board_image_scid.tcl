#!/usr/bin/env wish
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# The board screenshot against the real game commands:
#
#   xvfb-run -a ./scidCommunity tests/tcl/board_image_scid.tcl
#
# board_image_tk.tcl stubs sc_pos and sc_game, so it cannot catch a mismatch
# between the image and what the real commands report.  This plays a real
# game with the installed engine, gives the last move real NAGs, stores a real
# comment holding marks, saves the PNG and samples it.  It runs through the
# app binary (like the other tests that need sc_*), not through wish.

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

# What tcl/board.tcl needs at load time: piece sheets, board textures, the
# theme hook, the square colours, and the preferences the screenshot reads.
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
set ::arrowLastMove 1
set ::highlightLastMove 0
set ::highlightLastMoveWidth 2
set ::highlightLastMoveColor grey
set ::highlightLastMovePattern {}
set ::highlightLastMoveNag 1
set ::highlightLastMoveEval 1
proc tr {s} { return $s }
proc ::applyThemeColor_background {args} {}

source [file join $root tcl board.tcl]

set dir [file join [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] \
    "board_image_scid_[pid]"]
catch {file delete -force $dir}
file mkdir $dir

# A real game whose last move (Nc6) carries both badge kinds, and a real
# comment with the marks a user draws.
sc_game new
foreach san {e4 e5 Nf3 Nc6} { sc_move addSan $san }
sc_pos addNag "?!"
sc_pos addNag "+-"
sc_pos setComment {[%csl Gd4,Re5] [%cal Yh4h8] [%draw circle,f7,blue]}
sc_game tag set -result "1-0"

puts "\nthe real commands"
check "the last move is Nc6" [expr {[sc_game info previousMoveUCI] eq "b8c6"}]
check "the comment holds the marks" \
    [expr {[string first "%csl Gd4,Re5" [sc_pos getComment]] >= 0}] \
    "comment=[sc_pos getComment]"
check "the NAGs reach getNags" \
    [expr {[string first "?!" [sc_pos getNags]] >= 0}] "nags=[sc_pos getNags]"
check "the game has a result" [expr {[sc_game tag get Result] ne "*"}]

::board::new .b 40
::board::showMarks .b 1
::board::setmarks .b [sc_pos getComment]
::board::update .b [sc_pos board] 0

set psize  [::board::imageSize 160]
set border $::board::_border(.b)
set poffset [expr {[image height $::board::letterToPiece(K)$psize] - $psize}]
set scale [expr {max(2, $psize / 45)}]
set margin [expr {7 * $scale + 14}]

# Sampling helpers: the top-left corner of a square in the image, and the
# distinct colours in a small rectangle.
proc squareOrigin {sq psize border poffset margin} {
    set col [expr {$sq % 8}]
    set row [expr {7 - $sq / 8}]
    return [list [expr {$margin + $border + $col * ($psize + $border)}] \
                 [expr {$margin + $poffset + $border + $row * ($psize + $border)}]]
}
proc coloursAt {img x y w h} {
    set colours {}
    for {set dx 0} {$dx < $w} {incr dx} {
        for {set dy 0} {$dy < $h} {incr dy} {
            lappend colours [$img get [expr {$x + $dx}] [expr {$y + $dy}]]
        }
    }
    return [lsort -unique $colours]
}

puts "\nthe saved image"
set f [file join $dir "position.png"]
::board::saveImage .b $f
check "the PNG was written" [expr {[file exists $f]}]
set img [image create photo -file $f]
check "it is the whole board" \
    [expr {[image width $img] == $psize * 8 + $border * 9 + 2 * $margin}] \
    "got [image width $img]"

puts "\nthe marks from the real comment"
# d4 (27) is the green %csl square, e5 (36) the red one.  The square outline
# is inset by 3% of the square.
set inset [expr {int($psize * 0.03)}]
lassign [squareOrigin 27 $psize $border $poffset $margin] x y
set cols [coloursAt $img [expr {$x + $inset - 2}] [expr {$y + $psize / 4}] 5 [expr {$psize / 2}]]
check "the green square is drawn" [expr {[lsearch -exact $cols "0 128 0"] >= 0}] "colours=$cols"
lassign [squareOrigin 36 $psize $border $poffset $margin] x y
set cols [coloursAt $img [expr {$x + $inset - 2}] [expr {$y + $psize / 4}] 5 [expr {$psize / 2}]]
check "the red square is drawn" [expr {[lsearch -exact $cols "255 0 0"] >= 0}] "colours=$cols"

# The h4-h8 arrow is vertical, so its shaft crosses the middle of h6 (47).
lassign [squareOrigin 47 $psize $border $poffset $margin] x y
set cols [coloursAt $img [expr {$x + $psize / 2 - 3}] [expr {$y + $psize / 2 - 3}] 6 6]
check "the arrow is drawn" [expr {[lsearch -exact $cols "255 255 0"] >= 0}] "colours=$cols"

# The blue circle on f7 (53) is a ring around the square's middle.
lassign [squareOrigin 53 $psize $border $poffset $margin] x y
set cols [coloursAt $img [expr {$x + $psize / 2 - 2}] \
    [expr {$y + $psize / 2 - int($psize * 0.47)}] 5 5]
check "the circle is drawn" [expr {[lsearch -exact $cols "0 0 255"] >= 0}] "colours=$cols"

puts "\nthe badges on the last move"
# c6 (42) is where Nc6 landed: ?! at the top right, +- at the top left.
lassign [squareOrigin 42 $psize $border $poffset $margin] x y
set badge [coloursAt $img [expr {$x + $psize - 20}] [expr {$y - 20}] 40 40]
check "the annotation badge is drawn" \
    [expr {[lsearch -exact $badge "255 48 48"] >= 0}] "colours=$badge"
set badge [coloursAt $img [expr {$x - 20}] [expr {$y - 20}] 40 40]
check "the evaluation badge is drawn" \
    [expr {[lsearch -exact $badge "32 112 32"] >= 0}] "colours=$badge"
check "the evaluation NAG is read from its number" \
    [expr {[lindex [::board::_lastMoveEvaluationBadge [sc_pos getNags]] 0] eq "+-"}]

puts "\nthe result"
# The result tag is 1-0, so White's badge says 1 and Black's says 0, beside
# each king.
lassign [squareOrigin 4 $psize $border $poffset $margin] x y
set badge [coloursAt $img [expr {$x + $psize - 20}] [expr {$y - 20}] 40 40]
check "the winner's badge is drawn" \
    [expr {[lsearch -exact $badge "208 208 208"] >= 0}] "colours=$badge"
lassign [squareOrigin 60 $psize $border $poffset $margin] x y
set badge [coloursAt $img [expr {$x + $psize - 20}] \
    [expr {$y - 20 + $psize / 5}] 40 40]
check "the loser's badge is drawn" \
    [expr {[lsearch -exact $badge "48 48 48"] >= 0}] "colours=$badge"

image delete $img
file delete -force $dir
puts "\n$checks checks, $fails failures"
exit [expr {$fails > 0}]
