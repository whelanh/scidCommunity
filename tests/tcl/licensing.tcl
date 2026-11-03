#!/usr/bin/env tclsh
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# licensing.tcl -- the notices this repository claims are the notices it keeps.
#
#   tclsh tests/tcl/licensing.tcl
#
# docs/third-party-notices.md is a promise: it names the files adapted from
# other projects and the licence each one is under. A promise nobody checks is
# a comment, so this harness reads the document and holds the tree to it:
# every file the tables name exists, every adapted file carries an SPDX line,
# and every file this project ships in the review layer has one too.
#
# Nothing here is a legal opinion. It is the mechanical half: a renamed or
# deleted file, or a header stripped in a merge, fails here rather than in a
# release.

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
set notices [file join $root docs third-party-notices.md]

puts "== the notices document exists and names its licences =="

check "docs/third-party-notices.md exists" [file exists $notices]
if {![file exists $notices]} {
    puts ""
    puts "$checks checks, $fails failures"
    exit 1
}
set fh [open $notices r]
set doc [read $fh]
close $fh

check "it records the GPL this project is under" \
    [expr {[string match {*GNU General Public License*} $doc]}]
check "it records the Patzer adaptation" [expr {[string match {*Patzer*} $doc]}]
check "it records the game-review plugin adaptation" \
    [expr {[string match {*David Crandall*} $doc]}]

puts "== every file a table names exists =="

# A table row is `| \`path\` | what it was adapted from |`. Paths in the prose
# are prose; the tables are the claim this repository can be held to.
set named {}
foreach line [split $doc "\n"] {
    if {![regexp {^\|\s*`([^`]+)`\s*\|} $line -> path]} { continue }
    lappend named $path
    check "$path exists" [file exists [file join $root $path]] "named in the notices table"
}
check "the tables name at least one file" [expr {[llength $named] > 0}]

puts "== every adapted file carries the licence it is claimed under =="

# The two files that reproduce Patzer's MIT code say so in their own header; a
# file that lost its header in a merge is the failure this catches.
foreach rel {tcl/tools/comment_facts.tcl tcl/tools/move_labels.tcl} {
    set path [file join $root $rel]
    if {![file exists $path]} { continue }
    set fh [open $path r]
    set head [read $fh 4096]
    close $fh
    check "$rel carries an SPDX identifier" \
        [expr {[string match {*SPDX-License-Identifier*} $head]}]
    if {$rel eq "tcl/tools/comment_facts.tcl"} {
        check "$rel reproduces the MIT permission notice" \
            [expr {[string match {*MIT*} $head] || [string match {*Permission is hereby granted*} $head]}]
    }
}

puts "== the review layer's own files are labelled =="

# Every new file this layer ships, not every file in the tree: the classic files
# predate the convention and rewriting their headers is not this harness's job.
set own {
    tcl/tools/review_progress.tcl
    tcl/tools/review_progress_ui.tcl
    tcl/tools/review_ui.tcl
    tcl/tools/review_driver.tcl
    tcl/tools/finish_game.tcl
    tcl/tools/review_annotate.tcl
    tcl/tools/rapid_annotate.tcl
    tcl/tools/batch_annotate.tcl
}
foreach rel $own {
    set path [file join $root $rel]
    check "$rel exists" [file exists $path]
    if {![file exists $path]} { continue }
    set fh [open $path r]
    set head [read $fh 2048]
    close $fh
    check "$rel carries an SPDX identifier" \
        [expr {[string match {*SPDX-License-Identifier*} $head]}]
}

puts ""
puts "$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
