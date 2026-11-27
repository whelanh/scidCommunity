# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# htext_icons.tcl -- a help page keeps rendering past an icon tag.
#
#   xvfb-run -a wish tests/tcl/htext_icons.tcl
#
# "What's the threat?" named <button tb_review_threat>, an icon that exists only
# as ::icon::tb_review_threat. ttk::button raised "image doesn't exist", the
# error ended the page at that tag, and the help read "It is the" and stopped.
# A bare icon name now falls back to its ::icon:: copy, and a name that exists
# nowhere no longer takes the rest of the page with it.

package require Tk

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

proc strIsPrefix {prefix str} {
    string equal -length [string length $prefix] $prefix $str
}
proc helpWindow {args} {}

source [file join $root tcl htext.tcl]

font create font_Regular
foreach f {font_Small font_SmallBold font_SmallItalic font_Bold font_BoldItalic
           font_Italic font_Fixed font_H1 font_H2 font_H3 font_H4 font_H5} {
    font create $f
}
array set ::pgnColor {Var {} Nag {}}

# One icon the way start.tcl names the toolbar buttons (global), one the way it
# names the newer icons (::icon::).
image create photo tb_global_icon -width 4 -height 4
image create photo ::icon::tb_scoped_icon -width 4 -height 4

proc render {text} {
    destroy .t
    text .t
    ::htext::init .t
    ::htext::display .t $text
    return [string trim [.t get 1.0 end]]
}

puts "\n== the name resolves =="
checkEq "a global image is used as it is" [::htext::iconName tb_global_icon] tb_global_icon
checkEq "a name only ::icon:: has gets it" [::htext::iconName tb_scoped_icon] ::icon::tb_scoped_icon
checkEq "an unknown name is returned unchanged" [::htext::iconName tb_nowhere] tb_nowhere

puts "\n== the page is shown to its end =="
checkEq "a global button" [render {Press <button tb_global_icon> now.}] "Press  now."
checkEq "an ::icon:: button" [render {Press <button tb_scoped_icon> now.}] "Press  now."
checkEq "an ::icon:: image" [render {See <img tb_scoped_icon> here.}] "See  here."
checkEq "a button with a command" \
    [render {Go <button tb_scoped_icon -command {set ::x 1}> on.}] "Go  on."
checkEq "two of them in a row" \
    [render {<button tb_scoped_icon> and <button tb_scoped_icon> end.}] "and  end."
destroy .t

puts "\n== a name that exists nowhere does not end the page =="
set rc [catch { render {Before <button tb_nowhere> after.} } out]
check "the page rendered" [expr {!$rc}] $out
check "the text after the tag is there" [string match "*after.*" $out] $out

puts "\n== the real help page =="
# The page the user reported, with the icon as start.tcl names it.
image create photo ::icon::tb_review_threat -width 4 -height 4
source [file join $root tcl help help.tcl]
set page [render $::helpText(ToolsWhatThreat)]
# htext keeps the source's line breaks and indents, so match on any whitespace.
check "the sentence with the button is whole" \
    [regexp {It is the\s+button in\s+the Engine window and the \[What's the threat\?\]\s+entry\s+in the Tools menu\.} $page] \
    [string range $page 150 400]
check "the page reaches its last line" [string match "*(Updated: scidCommunity*" $page] \
    [string range $page end-120 end]

# helpPL.tcl carries the same tag in its own page.
source [file join $root tcl help helpPL.tcl]
set pl [render $::helpText(P,ToolsWhatThreat)]
check "the Polish page is shown past the button" \
    [regexp {przyciskiem\s+w oknie\s+silnika\s+oraz} $pl] [string range $pl 150 450]
check "and to its last line" [string match "*(Updated: scidCommunity*" $pl] \
    [string range $pl end-120 end]

puts "\n$checks checks, $fails failures"
exit [expr {$fails > 0}]
