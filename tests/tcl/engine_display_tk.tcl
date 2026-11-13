#!/usr/bin/env wish
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# engine_display_tk.tcl -- the PV display's live block and history, under Tk.
#
#   wish tests/tcl/engine_display_tk.tcl
#   xvfb-run -a wish tests/tcl/engine_display_tk.tcl
#
# A MultiPV run keeps the current iteration in a fixed block at the top of the
# widget: row 1 is the best line (blue), the other rows are the other multipv
# slots. The block is rewritten in place as the engine reports each index, so
# the rows do not move while the search deepens. When the best line reaches a
# new depth the completed iteration is put at the top of the history, after a
# dashed rule; the history is newest-first and keeps the blue best line but
# loses the "header" tag, so only the live block is exportable. The display
# never scrolls itself.
# A single-PV run keeps its own display: the newest line at the top, the
# preceding iterations below it, no rule and no blue. Every line ends with the
# time the search has taken, in the retired Analysis window's form - seconds
# with two decimals in parentheses - with the unit added: "(12.34s)", after the
# nodes and W/D/L. ::enginewin_history turns the history off.
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

proc feed {multipv depth score pv {time 100}} {
    ::enginewin::updateDisplay 1 \
        [list $multipv $depth 20 1000 500 0 0 $time $score cp "" $pv]
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

puts "\nthe current iteration is a fixed block at the top"

feed 1 20  30 {e2e4 e7e5 g1f3}
feed 2 20  20 {d2d4 d7d5 c2c4}
feed 3 20  10 {g1f3 g8f6 d2d4}
checkEq "one depth is one block" [lineCount] 3
check "the best line is row 1" [string match "20/20*+0.30*e2e4*" [lineText 1]] [lineText 1]
check "the second line is row 2" [string match "20/20*+0.20*d2d4*" [lineText 2]] [lineText 2]
check "the third line is row 3" [string match "20/20*+0.10*g1f3*" [lineText 3]] [lineText 3]
check "the best line is blue" [expr {[lsearch -exact [blueLines] 1] >= 0}]
check "the others are not" \
    [expr {[lsearch -exact [blueLines] 2] < 0 && [lsearch -exact [blueLines] 3] < 0}]
checkEq "no rule before the first completed iteration" [llength [ruleLines]] 0

feed 1 21  35 {e2e4 e7e5 g1f3}
checkEq "a new depth adds a rule and the previous iteration" [lineCount] 7
check "the history starts after the live block" [isRule 4]
check "the live best line is the new depth" \
    [string match "21/20*+0.35*e2e4*" [lineText 1]] [lineText 1]
check "the live rows below it still carry the previous depth until updated" \
    [string match "20/20*+0.20*d2d4*" [lineText 2]] [lineText 2]
check "the history keeps the completed best line" \
    [string match "20/20*+0.30*e2e4*" [lineText 5]] [lineText 5]
check "the live best line is blue" [expr {[lsearch -exact [blueLines] 1] >= 0}]
check "the history's best line keeps its blue" [expr {[lsearch -exact [blueLines] 5] >= 0}]

feed 2 21  25 {d2d4 d7d5 c2c4}
feed 3 21  15 {g1f3 g8f6 d2d4}
checkEq "the live block is still rows 1..3" [lineCount] 7
check "the new second line" [string match "21/20*+0.25*d2d4*" [lineText 2]] [lineText 2]
check "the new third line" [string match "21/20*+0.15*g1f3*" [lineText 3]] [lineText 3]
check "the first history block is still there" \
    [expr {[lineText 5] eq "20/20\t+0.30\te2e4 e7e5 g1f3  (1.00K nodes) (0.10s)"}]

puts "\nthe live block is refreshed in place"

feed 2 21  28 {c2c4 e7e5 g1f3}
checkEq "no line is added for a refreshed PV" [lineCount] 7
checkEq "only one rule, so no new block" [llength [ruleLines]] 1
check "the refreshed line carries the new move" \
    [string match "21/20*+0.28*c2c4*" [lineText 2]] [lineText 2]
check "the best line keeps its blue" [expr {[lsearch -exact [blueLines] 1] >= 0}]

puts "\nonly the live block is exportable"

checkEq "the live block starts at line 1" [::enginewin::firstPvLine $t] 1
checkEq "the header tag is on the live block only" [headerLines] {1 2 3}
check "the history's best line lost it" \
    [expr {[lsearch -exact [headerLines] 5] < 0}] 1

puts "\nthe history reads newest to oldest"

# Three depths: the live block is the newest, then the iteration that just
# finished, then the one before it.
::enginewin::updateDisplay 1 ""
foreach depth {20 21 22} {
    feed 1 $depth $depth {e2e4 e7e5}
    feed 2 $depth [expr {$depth - 10}] {d2d4 d7d5}
    feed 3 $depth [expr {$depth - 20}] {g1f3 g8f6}
}
checkEq "two completed iterations are kept" [lineCount] 11
check "the live block is the newest" \
    [string match "22/20*" [lineText 1]] [lineText 1]
check "the first history block is the iteration just finished" \
    [string match "21/20*" [lineText 5]] [lineText 5]
check "the next history block is the one before it" \
    [string match "20/20*" [lineText 9]] [lineText 9]
check "a rule separates each block" [expr {[isRule 4] && [isRule 8]}]
check "each history block keeps its blue best line" \
    [expr {[lsearch -exact [blueLines] 5] >= 0 && [lsearch -exact [blueLines] 9] >= 0}]
checkEq "only the live block is exportable" [headerLines] {1 2 3}

puts "\na new depth keeps the configured number of lines"

::enginewin::updateDisplay 1 ""
feed 1 20  30 {e2e4 e7e5}
feed 2 20  20 {d2d4 d7d5}
feed 3 20  10 {g1f3 g8f6}
feed 1 21  35 {e2e4 c7c5}
checkEq "the live block is already three lines" [lineCount] 7
check "its best line is the new depth" \
    [string match "21/20*+0.35*e2e4 c7c5*" [lineText 1]] [lineText 1]
check "the second line is still the previous depth's" \
    [string match "20/20*+0.20*d2d4*" [lineText 2]] [lineText 2]
check "the third line too" \
    [string match "20/20*+0.10*g1f3*" [lineText 3]] [lineText 3]
checkEq "still one rule" [llength [ruleLines]] 1

feed 2 21  25 {d2d4 g8f6}
feed 3 21  15 {g1f3 d7d5}
check "the second line catches up" \
    [string match "21/20*+0.25*d2d4 g8f6*" [lineText 2]] [lineText 2]
check "the third line catches up" \
    [string match "21/20*+0.15*g1f3 d7d5*" [lineText 3]] [lineText 3]

puts "\na late line from an older depth fills its slot; it adds no block"

feed 2 20  22 {c2c4 e7e5}
checkEq "no block is added" [lineCount] 7
checkEq "no rule is added" [llength [ruleLines]] 1
check "the late line took the second slot of the live block" \
    [string match "20/20*+0.22*c2c4*" [lineText 2]] [lineText 2]
check "the best line did not move" \
    [string match "21/20*+0.35*e2e4 c7c5*" [lineText 1]] [lineText 1]

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
check "the live row count is gone" \
    [expr {![info exists ::enginewin::m_(pvLiveRows,1)]}]
feed 1 30  50 {e2e4}
checkEq "one line, no rule" [lineCount] 1
check "the line is the new search" [string match "30/20*+0.50*" [lineText 1]] [lineText 1]

puts "\nthe EPD paste takes the live block's PV"

# Paste analysis writes bm/ce/dm and pv as one line, so the PV must come from
# the same block the score and best move came from.
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
check "the pv is the live block's line" \
    [string match "*pv e2e4 e7e5*" $opcodes] $opcodes
check "not the completed iteration's line" \
    [expr {[string first "pv d2d4" $opcodes] < 0}] $opcodes

puts "\nthe history can be turned off"

set ::enginewin::engState(1) follow.run
::enginewin::updateDisplay 1 ""
feed 1 20  30 {e2e4 e7e5}
feed 2 20  20 {d2d4 d7d5}
feed 1 21  35 {e2e4 c7c5}
feed 2 21  25 {d2d4 g8f6}
checkEq "history was collected" [lineCount] 5
set ::enginewin_history 0
::enginewin::historyChanged
checkEq "turning it off removes what is already on screen" [lineCount] 2
checkEq "no history rule" [llength [ruleLines]] 0
feed 1 22  40 {e2e4 e7e5}
feed 2 22  30 {d2d4 d7d5}
checkEq "and no new history is collected" [lineCount] 2
check "the live block is the new depth" \
    [string match "22/20*+0.40*e2e4 e7e5*" [lineText 1]] [lineText 1]
set ::enginewin_history 1
unset ::enginewin::engState(1)

puts "\nthe view does not follow the history"

# A real height, so the widget can actually overflow. The live block must stay
# at the top: nothing in the display path calls "see end" any more.
pack .engineWin1.display -fill both -expand 1
grid $t -in .engineWin1.display -sticky news
$t configure -height 6
wm geometry .engineWin1 900x140
update
::enginewin::updateDisplay 1 ""
foreach depth {1 2 3 4 5 6 7 8 9 10} {
    feed 1 $depth $depth {e2e4 e7e5}
    feed 2 $depth [expr {10 - $depth}] {d2d4 d7d5}
}
check "the live block is still at the top" \
    [expr {[$t index @0,0] eq "1.0"}] [$t index @0,0]
check "the viewport was not scrolled" \
    [expr {[lindex [$t yview] 0] == 0.0}] [$t yview]
checkEq "the live block is still the exportable one" [::enginewin::firstPvLine $t] 1

puts "\nevery line ends with the time spent on the search"

# The Analysis window ended each iteration with the search time in seconds, two
# decimals in parentheses. The Engine Window shows the same field in the same
# place - last on the line, after the W/D/L and the node count - with the unit
# added: "(0.65s)".
checkEq "the label is the Analysis window's, with its unit" \
    [::enginewin::pvTimeLabel 650] (0.65s)

::enginewin::updateDisplay 1 ""
feed 1 20  30 {e2e4 e7e5} 650
feed 2 20  20 {d2d4 d7d5} 1250
check "the best line carries its own time" \
    [string match "*nodes) (0.65s)" [lineText 1]] [lineText 1]
check "the second line carries its own" \
    [string match "*nodes) (1.25s)" [lineText 2]] [lineText 2]
checkEq "the time is the last field" \
    [string range [lineText 1] end-[expr {[string length "(0.65s)"] - 1}] end] "(0.65s)"

feed 2 20  22 {c2c4 e7e5} 2000
checkEq "no line is added" [lineCount] 2
check "the refreshed line takes its new time" \
    [string match "*nodes) (2.00s)" [lineText 2]] [lineText 2]
check "the unrefreshed line keeps its own" \
    [string match "*nodes) (0.65s)" [lineText 1]] [lineText 1]

feed 1 21  35 {e2e4 c7c5} 3250
check "the live block's best line has its own time" \
    [string match "*nodes) (3.25s)" [lineText 1]] [lineText 1]
check "the line carried over from the old depth keeps its time" \
    [string match "*nodes) (2.00s)" [lineText 2]] [lineText 2]
check "the history keeps the completed iteration's time" \
    [string match "*nodes) (0.65s)" [lineText 4]] [lineText 4]
check "and the history's second line keeps its own" \
    [string match "*nodes) (2.00s)" [lineText 5]] [lineText 5]

::enginewin::updateDisplay 1 ""
feed 1 20  30 {e2e4 e7e5} {}
check "an engine that reports no time gets none on the line" \
    [expr {![regexp {\([0-9]+\.[0-9]+s?\)$} [lineText 1]]}] [lineText 1]
check "the line still ends with the node count" \
    [string match "*nodes)" [lineText 1]] [lineText 1]

# The place the user asked for: after the W/D/L percentages and the nodes.
::enginewin::updateDisplay 1 ""
::enginewin::updateDisplay 1 \
    [list 1 22 24 23193210 1000000 50 0 4250 25 cp {958 42 0} {e2e4 e7e5}]
checkEq "the time comes after the W/D/L and the nodes" \
    [lineText 1] "22/24\t+0.25\te2e4 e7e5  (W: 95.8%  D: 4.2%  L: 0.0%  23193.21K nodes) (4.25s)"

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
