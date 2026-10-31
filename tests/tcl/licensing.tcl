# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# licensing.tcl -- the notices the review layer depends on are still there.
#
#   tclsh tests/tcl/licensing.tcl
#
# This is not a legal opinion. It is the cheap check that a refactor did not
# drop a file's SPDX line or the full MIT text a ported file has to carry.

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

proc readFile {path} {
    set fh [open $path r]
    fconfigure $fh -encoding utf-8
    set text [read $fh]
    close $fh
    return $text
}

puts "\nthe project licence"

check "COPYING is present" [file exists [file join $root COPYING]]
check "the notices page is present" [file exists [file join $root docs third-party-notices.md]]

puts "\nevery new review file carries its SPDX line"

foreach name {
    review_report.tcl review_verify.tcl review_prose.tcl
    review_coach.tcl review_threat.tcl
} {
    set text [readFile [file join $root tcl tools $name]]
    check "$name says GPL-2.0-or-later" \
        [expr {[string first {SPDX-License-Identifier: GPL-2.0-or-later} $text] >= 0}] \
        "missing SPDX line"
}

puts "\nthe ported facts and labels keep the MIT notice"

foreach name {comment_facts.tcl move_labels.tcl} {
    set text [readFile [file join $root tcl tools $name]]
    check "$name says MIT" [expr {[string first "MIT" $text] >= 0}]
    check "$name has the permission text" \
        [expr {[string first {Permission is hereby granted} $text] >= 0}]
    check "$name names Patzer's authors" \
        [expr {[string first "Arsen" $text] >= 0 \
            && [string first "Apostolov" $text] >= 0}]
}

puts "\nthe notices name every source the review layer adapts"

set notices [readFile [file join $root docs third-party-notices.md]]
foreach want {Patzer {David Crandall} MIT GPL-2.0-or-later review_threat.tcl review_coach.tcl} {
    check "the notices mention $want" \
        [expr {[string first $want $notices] >= 0}]
}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
