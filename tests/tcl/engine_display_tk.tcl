#!/usr/bin/env wish
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# engine_display_tk.tcl -- the PV display's MultiPV blocks, under Tk.
#
#   xvfb-run -a wish tests/tcl/engine_display_tk.tcl
#
# A MultiPV run used to replace the whole display with the lines of the newest
# depth. It now keeps one block per depth, separated by a dashed rule, the best
# line of each block in blue and the other lines in the normal colour; the
# newest block is refreshed in place as the engine reports its remaining lines.
# Each block shows the latest line of every multipv slot, so a new depth keeps
# the earlier slots' lines until the engine updates them, as the Analysis
# window did. A single-PV run keeps its own display: the newest line at the
# top, the preceding iterations below it, no rule and no blue.
#
# The window's engine, board and chart are not part of this: the harness feeds
# the InfoPV messages the UCI reader would, into the real ::enginewin::updateDisplay
# and the real widgets, and reads back what a reader would see.

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

# The application's surface, as much of it as this file touches.
namespace eval ::options {}
proc ::options.store {args} {}
proc tr {tag args} { return $tag }
namespace eval notify {}
proc ::notify::EngineBestMove {args} {}
proc ttk_text {w args} { text $w {*}$args }
proc autoscrollBars {args} {}
font create font_Regular -family Helvetica -size 10

set ::scidTclDir [file join $root tcl]
source [file join $root tcl windows engine.tcl]
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools epd_analysis.tcl]
proc sc_info {args} { return 4 }
source [file join $root tcl file epd.tcl]

# The best-move block also drives the arrows; not under test here.
proc ::enginewin::stateLocked {id} { return 1 }

toplevel .engineWin1
frame .engineWin1.header_info
text .engineWin1.header_info.text
frame .engineWin1.display
::enginewin::createDisplayFrame 1 .engineWin1.display

set t .engineWin1.display.pv_lines
set ::enginewin::m_(notation,1) 0
set ::enginewin::m_(scoreside,1) ""
set ::enginewin::pv_(btm,1) 0
set ::enginewin::pv_(pos,1) "8/8/8/8/8/8/8/K6k w - - 0 1"
set ::enginewin::pv_(ply,1) ""

proc feed {multipv depth score pv} {
    ::enginewin::updateDisplay 1 \
        [list $multipv $depth 20 1000 500 0 0 100 $score cp "" $pv]
}

# The widget's lines, without the empty final element "get" adds.
proc lines {} {
    set all [split [$::t get 1.0 end] "\n"]
    while {[llength $all] && [lindex $all end] eq ""} {
        set all [lrange $all 0 end-1]
    }
    return $all
}
proc lineText {n} { return [lindex [lines] [expr {$n - 1}]] }
proc lineCount {} { return [llength [lines]] }
proc isRule {n} {
    set text [lineText $n]
    return [expr {[string length $text] == 70 && $text eq [string repeat {-} 70]}]
}
proc ruleLines {} {
    set out {}
    for {set i 1} {$i <= [lineCount]} {incr i} {
        if {[isRule $i]} { lappend out $i }
    }
    return $out
}
proc blueLines {} {
    set out {}
    foreach range [$::t tag ranges blue] {
        lappend out [lindex [split [lindex $range 0] .] 0]
    }
    return $out
}
proc headerLines {} {
    set out {}
    foreach range [$::t tag ranges header] {
        lappend out [lindex [split [lindex $range 0] .] 0]
    }
    return [lsort -integer -unique $out]
}

puts "\nthe colours are the Analysis window's"

checkEq "the best line is the window's light blue" \
    [$t tag cget blue -foreground] DodgerBlue3
checkEq "the separator is grey" [$t tag cget gray -foreground] gray

puts "\na MultiPV run keeps a block per depth"

feed 1 20  30 {e2e4 e7e5 g1f3}
feed 2 20  20 {d2d4 d7d5 c2c4}
feed 3 20  10 {g1f3 g8f6 d2d4}
checkEq "one depth is one block" [lineCount] 3
check "the best line" [string match "20/20*+0.30*e2e4*" [lineText 1]] [lineText 1]
check "the second line" [string match "20/20*+0.20*d2d4*" [lineText 2]] [lineText 2]
check "the third line" [string match "20/20*+0.10*g1f3*" [lineText 3]] [lineText 3]
check "the best line is blue" [expr {[lsearch -exact [blueLines] 1] >= 0}]
check "the others are not" \
    [expr {[lsearch -exact [blueLines] 2] < 0 && [lsearch -exact [blueLines] 3] < 0}]

feed 1 21  35 {e2e4 e7e5 g1f3}
feed 2 21  25 {d2d4 d7d5 c2c4}
feed 3 21  15 {g1f3 g8f6 d2d4}
checkEq "a new depth adds a block, not a replacement" [lineCount] 7
check "the blocks are separated by a rule" [isRule 4]
check "the new best line" [string match "21/20*+0.35*e2e4*" [lineText 5]] [lineText 5]
check "the new second line" [string match "21/20*+0.25*d2d4*" [lineText 6]] [lineText 6]
check "the new third line" [string match "21/20*+0.15*g1f3*" [lineText 7]] [lineText 7]
check "the newest best line is blue" [expr {[lsearch -exact [blueLines] 5] >= 0}]
check "the newest other lines are not" \
    [expr {[lsearch -exact [blueLines] 6] < 0 && [lsearch -exact [blueLines] 7] < 0}]
check "the first block is still there" \
    [expr {[lineText 1] eq "20/20\t+0.30\te2e4 e7e5 g1f3  (1.00K nodes)"}]

puts "\nthe newest block is refreshed in place"

feed 2 21  28 {c2c4 e7e5 g1f3}
checkEq "no line is added for a refreshed PV" [lineCount] 7
checkEq "only one rule, so no new block" [llength [ruleLines]] 1
check "the refreshed line carries the new move" \
    [string match "21/20*+0.28*c2c4*" [lineText 6]] [lineText 6]
check "the best line keeps its blue" [expr {[lsearch -exact [blueLines] 5] >= 0}]

puts "\nonly the newest block is exportable"

checkEq "the newest block starts at its best line" [::enginewin::firstPvLine $t] 5
checkEq "the header tag is only on the newest block" [headerLines] {5 6 7}
checkEq "the obsolete block's best line lost it" \
    [expr {[lsearch -exact [headerLines] 1] < 0}] 1

puts "\na new block keeps the configured number of lines"

::enginewin::updateDisplay 1 ""
feed 1 20  30 {e2e4 e7e5}
feed 2 20  20 {d2d4 d7d5}
feed 3 20  10 {g1f3 g8f6}
feed 1 21  35 {e2e4 c7c5}
checkEq "the new block is already three lines" [lineCount] 7
check "its best line is the new depth" \
    [string match "21/20*+0.35*e2e4 c7c5*" [lineText 5]] [lineText 5]
check "the second line is still the previous depth's" \
    [string match "20/20*+0.20*d2d4*" [lineText 6]] [lineText 6]
check "the third line too" \
    [string match "20/20*+0.10*g1f3*" [lineText 7]] [lineText 7]
checkEq "still one rule" [llength [ruleLines]] 1

feed 2 21  25 {d2d4 g8f6}
feed 3 21  15 {g1f3 d7d5}
check "the second line catches up" \
    [string match "21/20*+0.25*d2d4 g8f6*" [lineText 6]] [lineText 6]
check "the third line catches up" \
    [string match "21/20*+0.15*g1f3 d7d5*" [lineText 7]] [lineText 7]

puts "\na late line from an older depth fills its slot; it adds no block"

feed 2 20  22 {c2c4 e7e5}
checkEq "no block is added" [lineCount] 7
checkEq "no rule is added" [llength [ruleLines]] 1
check "the late line took the second slot of the newest block" \
    [string match "20/20*+0.22*c2c4*" [lineText 6]] [lineText 6]
check "the best line did not move" \
    [string match "21/20*+0.35*e2e4 c7c5*" [lineText 5]] [lineText 5]

puts "\na shallower best line starts the history again"

feed 1 5  5 {e2e4}
checkEq "the old blocks are gone" [lineCount] 1
checkEq "there is no rule" [llength [ruleLines]] 0
check "the new search is on screen" \
    [string match "5/20*+0.05*e2e4*" [lineText 1]] [lineText 1]
feed 2 5  1 {d2d4}
checkEq "and its other line joins the block" [lineCount] 2
check "on the next line" [string match "5/20*+0.01*d2d4*" [lineText 2]] [lineText 2]

puts "\nthe first best line may arrive after a secondary line"

::enginewin::updateDisplay 1 ""
feed 2 8  20 {d2d4 d7d5}
feed 1 7  30 {e2e4 e7e5}
checkEq "the secondary line is kept" [lineCount] 2
check "the best line takes the first slot" \
    [string match "7/20*+0.30*e2e4*" [lineText 1]] [lineText 1]
check "the line that arrived first keeps the second" \
    [string match "8/20*+0.20*d2d4*" [lineText 2]] [lineText 2]
checkEq "the block is keyed by the best line" $::enginewin::m_(pvBestDepth,1) 7

puts "\na single PV keeps the Engine Window's own display"

::enginewin::updateDisplay 1 ""
feed 1 20  30 {e2e4 e7e5 g1f3}
feed 1 21  35 {e2e4 e7e5 g1f3}
feed 1 22  40 {e2e4 e7e5 g1f3}
checkEq "the newest line is at the top" 3 [lineCount]
check "the newest depth is line 1" [string match "22/20*+0.40*" [lineText 1]] [lineText 1]
check "the older depth follows" [string match "21/20*+0.35*" [lineText 2]] [lineText 2]
check "the oldest is last" [string match "20/20*+0.30*" [lineText 3]] [lineText 3]
checkEq "no rules" [llength [ruleLines]] 0
checkEq "no blue" [llength [blueLines]] 0
checkEq "the newest line is the exportable one" [::enginewin::firstPvLine $t] 1

puts "\na block is still ordered when the engine reports it out of order"

::enginewin::updateDisplay 1 ""
feed 2 20  20 {d2d4 d7d5 c2c4}
feed 1 20  30 {e2e4 e7e5 g1f3}
checkEq "the block is still two lines" [lineCount] 2
check "multipv 1 is line 1 even though it arrived second" \
    [string match "20/20*+0.30*e2e4*" [lineText 1]] [lineText 1]
check "multipv 2 is line 2" \
    [string match "20/20*+0.20*d2d4*" [lineText 2]] [lineText 2]
check "the best line is blue" [expr {[lsearch -exact [blueLines] 1] >= 0}]

puts "\na cleared display starts a new run"

::enginewin::updateDisplay 1 ""
check "the block state is gone" \
    [expr {![info exists ::enginewin::m_(pvBlockDepth,1)]}]
feed 1 30  50 {e2e4}
checkEq "one line, no rule" [lineCount] 1
check "the line is the new search" [string match "30/20*+0.50*" [lineText 1]] [lineText 1]

puts "\nthe EPD paste takes the newest block's PV"

# Paste analysis writes bm/ce/dm and pv as one line, so the PV must come from
# the same (newest) block the score and best move came from.
::enginewin::updateDisplay 1 ""
feed 1 20  10 {d2d4 d7d5}
feed 2 20   5 {c2c4 e7e5}
feed 1 21  20 {e2e4 e7e5}
feed 2 21  15 {g1f3 g8f6}
proc sc_pos {sub args} {
    if {$sub eq "fen"} { return "8/8/8/8/8/8/8/K6k w - - 0 1" }
    if {$sub eq "coordToSAN"} { return e4 }
    return ""
}
set ::enginewin::pvBestMove(1,1) e2e4
set ::enginewin::scorePV1(1) "+0.50"
set opcodes [::epd::buildEngineOpcodes]
check "the best move is the newest move" [string match "*bm e4*" $opcodes] $opcodes
check "the pv is the newest block's line" \
    [string match "*pv e2e4 e7e5*" $opcodes] $opcodes
check "not the oldest block's line" \
    [expr {[string first "pv d2d4" $opcodes] < 0}] $opcodes

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
