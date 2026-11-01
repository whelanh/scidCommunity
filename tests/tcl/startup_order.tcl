#!/usr/bin/env tclsh
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# startup_order.tcl -- end.tcl must be last in start.tcl's tcl_files list.
#
#   tclsh tests/tcl/startup_order.tcl
#
# end.tcl is not a library: sourcing it restores the layout, builds the menus
# and opens the default windows. The engine window the default layout opens
# calls into the review modules (::reviewui, ::review, ::enginelimits), so if
# end.tcl is sourced before them, creating that window raises "invalid command
# name ::reviewui::label" and the process exits before the event loop starts.
# v5.1.4.50 shipped exactly that ordering and died on every start that used
# the default layout.
#
# start.tcl appends the macOS drag-and-drop file to tcl_files after the list,
# which is harmless: nothing in end.tcl's startup sequence calls it.
#
# The test reads the braced tcl_files list out of start.tcl and checks the one
# invariant that prevents this: end.tcl comes last.

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

set root [file normalize [file join [file dirname [info script]] .. ..]]
set src [file join $root tcl start.tcl]
set fh [open $src r]
set lines [split [read $fh] "\n"]
close $fh

# ------------------------------------------------------------------ extract --
set start [lsearch -exact $lines "set tcl_files {"]
check "tcl_files is a braced list at column 0" [expr {$start >= 0}]
if {$start < 0} {
    puts "\n$checks checks, $fails failures"
    exit 1
}

set body {}
set end -1
for {set i [expr {$start + 1}]} {$i < [llength $lines]} {incr i} {
    # The closing brace is spelled as an escape: a literal one would end the
    # braced body of this very loop.
    if {[lindex $lines $i] eq "\u007d"} { set end $i; break }
    lappend body [string trim [lindex $lines $i]]
}
check "the tcl_files list is closed" [expr {$end >= 0}]

# An empty element means a comment or blank line slipped into the braced list:
# Tcl would source it as a file name.
set empty [lsearch -exact $body ""]
check "no empty or comment entries" [expr {$empty == -1}] \
    [expr {$empty == -1 ? "" : "entry [expr {$empty + 1}]"}]

set files [list {*}$body]
check "the list has more than a hundred files" [expr {[llength $files] > 100}] \
    "got [llength $files]"

# --------------------------------------------------------------- the check --
set hits [lsearch -all -exact $files "end.tcl"]
check "end.tcl is listed exactly once" [expr {[llength $hits] == 1}] \
    "found [llength $hits]"

check "end.tcl is the last file sourced" \
    [expr {[llength $files] > 0 && [lindex $files end] eq "end.tcl"}] \
    "last is '[lindex $files end]'"

# The modules whose commands are reached from end.tcl's startup sequence, each
# one spelled as a reminder of what breaks when it moves after end.tcl.
foreach f {
    tools/game_review.tcl
    tools/review_driver.tcl
    tools/review_annotate.tcl
    tools/review_ui.tcl
    tools/engine_limits.tcl
    tools/finish_game.tcl
    tools/comment_facts.tcl
} {
    set at [lsearch -exact $files $f]
    set endAt [lsearch -exact $files "end.tcl"]
    check "$f is sourced" [expr {$at >= 0}]
    check "$f is before end.tcl" [expr {$at >= 0 && $endAt >= 0 && $at < $endAt}] \
        "at $at, end.tcl at $endAt"
}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
