#!/usr/bin/env wish
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# comment_default_color_tk.tcl -- the Comment Window's own comment colour.
#
#   xvfb-run -a wish tests/tcl/comment_default_color_tk.tcl
#
# The editor keeps text the reader typed without a span in ::pgnColor(Comment),
# the same colour the PGN window paints. The Format menu sets it; this drives
# that entry point without opening the whole window.

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
source [file join $root tcl windows comment.tcl]

proc tr {tag args} { return $tag }
namespace eval ::pgn {}
proc ::pgn::ResetColors {} { incr ::pgnResets }
# The real proc posts the menu; this test only asks what it built.
proc tk_popup {args} {}

# The widgets the two procs touch. The real createWin builds these; here they
# only have to exist and answer -foreground.
frame .testComment
frame .testComment.cf
frame .testComment.cf.txtframe
text .testComment.cf.txtframe.text
pack .testComment
pack .testComment.cf
pack .testComment.cf.txtframe
pack .testComment.cf.txtframe.text
set ::windows::commenteditor::w_ .testComment
set ::pgnResets 0

puts "\nthe reader's colour is the one the PGN window paints"

set ::pgnColor(Comment) "#008b00"
::windows::commenteditor::applyDefaultColor_
checkEq "unspanned text takes ::pgnColor(Comment)" \
    [.testComment.cf.txtframe.text cget -foreground] "#008b00"

puts "\nthe Format menu's entry point"

proc ::tk_chooseColor {args} { return "#112233" }
set menu [::windows::commenteditor::showFormatMenu_ .testComment.cf.txtframe.text]
# showFormatMenu_ pops the menu up; the menu exists and carries the command.
set m .testComment.cf.txtframe.text.formatmenu
set labels {}
set idx ""
for {set i 0} {$i <= [$m index end]} {incr i} {
    if {[catch { set label [$m entrycget $i -label] }]} { continue }
    lappend labels $label
    if {$label eq "CommentDefaultColor"} { set idx $i }
}
check "the menu carries the default-colour entry" [expr {$idx ne ""}] $labels
checkEq "and it opens the colour chooser" \
    [$m entrycget $idx -command] ::windows::commenteditor::chooseDefaultColor_

$m invoke $idx
checkEq "choosing a colour saves it in ::pgnColor(Comment)" \
    $::pgnColor(Comment) "#112233"
checkEq "and the editor follows at once" \
    [.testComment.cf.txtframe.text cget -foreground] "#112233"
checkEq "and the PGN window is told to repaint" $::pgnResets 1

puts "\na theme change keeps the reader's colour"

# applyThemeStyle runs on <<ThemeChanged>> and puts the theme's foreground back.
# The editor's own handler has to run after it and put the comment colour back.
.testComment.cf.txtframe.text configure -foreground "#ff0000"
update
event generate .testComment.cf.txtframe.text <<ThemeChanged>> -when now
update
checkEq "the comment colour survives a theme change" \
    [.testComment.cf.txtframe.text cget -foreground] "#112233"
check "the handler is attached once" \
    [expr {[regexp -all {::windows::commenteditor::applyDefaultColor_} \
        [bind .testComment.cf.txtframe.text <<ThemeChanged>>]] == 1}] \
    [bind .testComment.cf.txtframe.text <<ThemeChanged>>]

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
