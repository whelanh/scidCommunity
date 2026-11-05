# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# game_info_comment.tcl -- the Game Info panel shows comment text, not markup.
#
#   xvfb-run -a ./scidCommunity tests/tcl/game_info_comment.tcl
#
# The comment editor stores colours as <span style="..."> markup. The PGN
# window renders it; the Game Info panel must not print the tags. This drives
# the built binary's own sc_game info, so it needs the application, not tclsh.

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

sc_game new
sc_pos setComment {Plain <span style="color:#008000">[Best] [%eval +0.35]</span> and <span style="color:#3B82F6">[Coach] A &amp; B</span> plus <b>bold</b> 4 < 5}
set info [sc_game info -cfull 1]

check "the comment text is in the panel" [expr {[string first "Plain" $info] >= 0}] $info
check "the review span is not printed" [expr {[string first "<span" $info] < 0}] $info
check "and neither is its closing tag" [expr {[string first "</span>" $info] < 0}] $info
check "the bold tags are not printed" \
    [expr {[string first "<b>" $info] < 0 && [string first "</b>" $info] < 0}] $info
check "an entity is shown as its character" [expr {[string first "A & B" $info] >= 0}] $info
check "a literal angle bracket is left for htext to display" \
    [expr {[string first "4 <lt> 5" $info] >= 0}] $info

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
