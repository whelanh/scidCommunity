#!/usr/bin/env wish
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# comment_infobar_tk.tcl -- the Info Bar under the board and the colour palette.
#
#   xvfb-run -a wish tests/tcl/comment_infobar_tk.tcl
#
# The Comment Window stores colours as <span style="..."> markup. The Info Bar
# is a plain text widget, not htext, so it must render the spans itself: text
# in the editor's colour, no tags on screen. The Format menu offers the same
# colours as the board's marker picker, as unlabelled squares.

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
namespace eval ::utils {}
source [file join $root tcl utils.tcl]
source [file join $root tcl windows comment.tcl]

proc tr {tag args} { return $tag }
proc tk_popup {args} {}
set ::pgnColor(Comment) "#008b00"

# ---------------------------------------------------------------- the palette --
puts "\nthe palette follows the annotation format"

set ::lichessFormat 1
checkEq "Lichess format offers six colours" \
    [::utils::annotationColors] {green red orange yellow blue cyan}
set ::lichessFormat 0
checkEq "ChessBase format adds four" \
    [::utils::annotationColors] \
    {green red orange yellow blue cyan purple white black gray}

# The Format > Text Color menu uses that palette, as squares with no labels.
puts "\nthe Format menu offers the palette as squares"

frame .testComment
frame .testComment.cf
frame .testComment.cf.txtframe
text .testComment.cf.txtframe.text
set ::windows::commenteditor::w_ .testComment

set ::lichessFormat 0
::windows::commenteditor::chooseColor_
set m .testComment.cf.txtframe.text.colormenu
check "the colour menu is built" [winfo exists $m]

set palette [::utils::annotationColors]
set entries {}
for {set i 0} {$i <= [$m index end]} {incr i} {
    if {[catch {$m type $i} type] || $type ne "command"} { continue }
    lappend entries $i
}
checkEq "one entry per colour and a custom colour" \
    [llength $entries] [expr {[llength $palette] + 1}]

set expected {}
foreach color $palette {
    lappend expected "::windows::commenteditor::setStyleDim_ color [::utils::annotationColorValue $color]"
}
set squareCommands {}
foreach idx [lrange $entries 0 end-1] {
    set image [$m entrycget $idx -image]
    set label [$m entrycget $idx -label]
    lappend squareCommands [$m entrycget $idx -command]
    check "entry $idx carries a swatch image" \
        [expr {[llength [info commands $image]] > 0}] $image
    check "entry $idx has no colour label" [expr {$label eq ""}] $label
}
checkEq "every colour has a swatch command" $squareCommands $expected
checkEq "the last entry is the custom colour" \
    [$m entrycget [lindex $entries end] -label] "CustomColor"

set rows [expr {([llength $palette] + 1) / 2}]
check "the first column starts without a break" \
    [expr {[$m entrycget [lindex $entries 0] -columnbreak] == 0}]
check "the second column starts after $rows rows" \
    [expr {[$m entrycget [lindex $entries $rows] -columnbreak] == 1}]

# --------------------------------------------------------------- the Info Bar --
puts "\nthe Info Bar shows the comment, not its markup"

namespace eval ::board {}
image create photo emptySquare -width 20 -height 20
emptySquare put "#ffffff" -to 0 0 20 20
set ::boardStyles {Merida}
set ::boardStyle Merida
set ::boardSize 40
set ::boardSizes {40}
set ::darkThemes {}
set ::MB3 3
set ::scidImgDir [file join $root img]
source [file join $root tcl board.tcl]

frame .main
frame .main.board
frame .main.board.bar
frame .main.board.bar.info
text .main.board.bar.info.t
pack .main.board.bar.info.t

set markup {Idea <span style="color:#ff0000">red</span> and 4 < 5 &amp; done}
::board::setInfoAlert .main.board "Comment" $markup $::pgnColor(Comment) "" 1
set t .main.board.bar.info.t
set shown [$t get 1.0 end-1c]

checkEq "the text is shown without tags" \
    $shown "Comment Idea red and 4 < 5 & done"
check "no span is printed" [expr {[string first "<span" $shown] < 0}] $shown

set redAt [$t search -exact "red" 1.0]
set redTags {}
foreach tag [$t tag names $redAt] {
    if {![catch {$t tag cget $tag -foreground} fg] && $fg ne ""} {
        lappend redTags $fg
    }
}
check "the red run keeps its colour" \
    [expr {[lsearch -exact $redTags "#ff0000"] >= 0}] $redTags

set ideaAt [$t search -exact "Idea" 1.0]
set ideaTags {}
foreach tag [$t tag names $ideaAt] {
    if {![catch {$t tag cget $tag -foreground} fg] && $fg ne ""} {
        lappend ideaTags $fg
    }
}
check "the unspanned text takes the comment colour" \
    [expr {[lsearch -exact $ideaTags $::pgnColor(Comment)] >= 0}] $ideaTags

# A comment imported from elsewhere can carry a colour Tk does not know. It
# must not abort the Info Bar update; it falls back to the comment colour.
set err [catch {
    ::board::setInfoAlert .main.board "Comment" \
        {Bad <span style="color:notacolour">colour</span> end} \
        $::pgnColor(Comment) "" 1
} msg]
check "an invalid span colour does not abort the Info Bar" [expr {$err == 0}] $msg
set shownBad [$t get 1.0 end-1c]
checkEq "the invalid run still shows its text" $shownBad "Comment Bad colour end"

set badAt [$t search -exact "colour" 1.0]
set badTags {}
foreach tag [$t tag names $badAt] {
    if {![catch {$t tag cget $tag -foreground} fg] && $fg ne ""} {
        lappend badTags $fg
    }
}
check "the invalid colour falls back to the comment colour" \
    [expr {[lsearch -exact $badTags $::pgnColor(Comment)] >= 0}] $badTags

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
