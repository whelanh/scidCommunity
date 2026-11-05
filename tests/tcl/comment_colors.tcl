# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# comment_colors.tcl -- the provenance spans Game Review and the coach write.
#
#   tclsh tests/tcl/comment_colors.tcl

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
source [file join $root tcl tools comment_colors.tcl]

puts "\nthe two writers and their colours"

checkEq "the review colour is the palette's green" $::commentcolors::reviewColor "#008000"
checkEq "the coach colour is the blue chosen for the dark themes" $::commentcolors::coachColor "#3B82F6"
checkEq "a review verdict is wrapped in the review colour" \
    [::commentcolors::wrapReview {[Best] [%eval +0.35]}] \
    {<span style="color:#008000">[Best] [%eval +0.35]</span>}
checkEq "a coach note is wrapped in the coach colour" \
    [::commentcolors::wrapCoach {[Coach] A note.}] \
    {<span style="color:#3B82F6">[Coach] A note.</span>}
checkEq "an empty block is not given an empty span" [::commentcolors::wrapCoach {}] ""

puts "\nthe wrapper is the comment editor's markup"

checkEq "the editor's four entities are escaped" \
    [::commentcolors::wrapCoach {a < b & c > d "e"}] \
    {<span style="color:#3B82F6">a &lt; b &amp; c &gt; d &quot;e&quot;</span>}
checkEq "each line gets its own span" \
    [::commentcolors::wrapCoachLines "one\ntwo"] \
    "<span style=\"color:#3B82F6\">one</span>\n<span style=\"color:#3B82F6\">two</span>"
checkEq "leading whitespace stays outside the span" \
    [::commentcolors::wrapReviewLines "  indented\nplain"] \
    "  <span style=\"color:#008000\">indented</span>\n<span style=\"color:#008000\">plain</span>"
checkEq "an empty line is left empty" \
    [::commentcolors::wrapCoachLines "one\n\ntwo"] \
    "<span style=\"color:#3B82F6\">one</span>\n\n<span style=\"color:#3B82F6\">two</span>"

puts "\nstripping what a writer put there"

checkEq "an empty wrapper is removed" \
    [::commentcolors::stripEmpty {<span style="color:#008000"> </span>}] ""
checkEq "a wrapper with text is kept" \
    [::commentcolors::stripEmpty {<span style="color:#008000">x</span>}] \
    {<span style="color:#008000">x</span>}
checkEq "a wrapped coach line goes with its wrapper" \
    [::commentcolors::stripLine \
        [::commentcolors::wrapCoach {[Coach] A note.}] {\[Coach\][^\n]*}] ""
checkEq "the plain form still goes (a game written before the colours)" \
    [::commentcolors::stripLine {[Coach] A note.} {\[Coach\][^\n]*}] ""
checkEq "a note beside the block survives" \
    [string trim [::commentcolors::stripLine \
        "My note. [::commentcolors::wrapCoach {[Coach] A note.}]" {\[Coach\][^\n]*}]] \
    "My note."

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
