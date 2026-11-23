# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# htext_link_colors.tcl -- a hyperlink stays readable on a dark theme (#531).
#
#   xvfb-run -a wish tests/tcl/htext_link_colors.tcl
#
# The tip window is an htext widget on the theme's own background, so on cobalt2
# (and the other dark themes) its links were X11 "blue" on #122738 - about
# 1.8:1, which is the clash in #531. Links now take their colour from the
# widget's background, the yellow hover highlight changes the foreground with
# it, and a theme change recolours the links already drawn.

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

# strIsPrefix is the application's C command; helpWindow is the help module's.
# Link rendering only needs them to exist, but a click binding has to resolve.
proc strIsPrefix {prefix str} {
    string equal -length [string length $prefix] $prefix $str
}
proc helpWindow {args} {}

source [file join $root tcl htext.tcl]

# ::htext::init wants the application's named fonts and the PGN colours.
font create font_Regular
foreach f {font_Small font_SmallBold font_SmallItalic font_Bold font_BoldItalic
           font_Italic font_Fixed font_H1 font_H2 font_H3 font_H4 font_H5} {
    font create $f
}
array set ::pgnColor {Var {} Nag {}}

# WCAG relative luminance and contrast ratio, from the colours Tk resolves.
proc relLum {w color} {
    lassign [winfo rgb $w $color] r g b
    set out {}
    foreach c [list $r $g $b] {
        set c [expr {$c / 65535.0}]
        if {$c <= 0.03928} {
            lappend out [expr {$c / 12.92}]
        } else {
            lappend out [expr {(($c + 0.055) / 1.055) ** 2.4}]
        }
    }
    lassign $out r g b
    return [expr {0.2126 * $r + 0.7152 * $g + 0.0722 * $b}]
}
proc contrast {w a b} {
    set la [relLum $w $a]
    set lb [relLum $w $b]
    return [expr {(max($la, $lb) + 0.05) / (min($la, $lb) + 0.05)}]
}

proc linkTags {w} {
    set tags {}
    foreach tag [$w tag names] {
        if {[string match "link *" $tag]} { lappend tags $tag }
    }
    return $tags
}
proc linkTag {w name} {
    foreach tag [$w tag names] {
        if {[string match "link $name *" $tag]} { return $tag }
    }
    return ""
}
proc linkFg {w name} {
    return [lindex [$w tag cget [linkTag $w $name] -foreground] 0]
}
proc drawLinks {w} {
    ::htext::init $w
    ::htext::display $w \
        {See the <a Index>help page</a> and the <a Moves>moves page</a>.}
}

# What the tip window does on cobalt2: ttk_text gives it the Treeview colours.
text .dark -background "#122738" -foreground white
drawLinks .dark

puts "\n== a link on a dark background =="
check "both links were drawn" [expr {[llength [linkTags .dark]] == 2}]
checkEq "the link is no longer plain blue" [linkFg .dark Index] "LightSkyBlue"
check "it still reads as a link" [.dark tag cget [linkTag .dark Index] -underline]
check "the click binding is intact" \
    [expr {[.dark tag bind [linkTag .dark Index] <ButtonRelease-1>] ne ""}]

set r [contrast .dark [linkFg .dark Index] [.dark cget -background]]
check "it clears WCAG AA (4.5:1) on the cobalt background" \
    [expr {$r >= 4.5}] [format "%.2f:1" $r]
check "plain blue would not have (the old colour)" \
    [expr {[contrast .dark blue [.dark cget -background]] < 3.0}] \
    [format "%.2f:1" [contrast .dark blue [.dark cget -background]]]

puts "\n== the light help window keeps the classic blue =="
text .light -background white -foreground black
drawLinks .light
checkEq "the light window's link is blue" [linkFg .light Index] "blue"
checkEq "::htext::linkColor follows the widget's background" \
    [list [::htext::linkColor .dark] [::htext::linkColor .light]] \
    [list LightSkyBlue blue]

puts "\n== the yellow hover highlight takes the foreground with it =="
set tag [linkTag .dark Index]
uplevel #0 [.dark tag bind $tag <Any-Enter>]
checkEq "the highlight is yellow" \
    [lindex [.dark tag cget $tag -background] 0] "yellow"
checkEq "the label is dark on the highlight" [lindex [.dark tag cget $tag -foreground] 0] "blue"
set hr [contrast .dark [lindex [.dark tag cget $tag -foreground] 0] \
    [lindex [.dark tag cget $tag -background] 0]]
check "the hovered label is readable (a light blue would not be)" \
    [expr {$hr >= 4.5}] [format "%.2f:1" $hr]
check "a light blue on the highlight would not be" \
    [expr {[contrast .dark LightSkyBlue yellow] < 3.0}] \
    [format "%.2f:1" [contrast .dark LightSkyBlue yellow]]
uplevel #0 [.dark tag bind $tag <Any-Leave>]
checkEq "leaving restores the dark-theme link colour" \
    [linkFg .dark Index] "LightSkyBlue"
checkEq "and drops the highlight" [.dark tag cget $tag -background] ""

puts "\n== an unknown span colour does not abort the display =="
text .span
::htext::init .span
set err [catch {
    ::htext::display .span {Before <span style="color:notacolour">note</span> after}
} msg]
check "the display survives an unknown span colour" [expr {$err == 0}] $msg
checkEq "the text is still shown" [.span get 1.0 end-1c] "Before note after"

puts "\n== a theme change recolours the links already drawn =="
.dark configure -background white -foreground black
::htext::configureColors .dark
checkEq "they follow the window to a light background" [linkFg .dark Index] "blue"
.dark configure -background "#122738" -foreground white
::htext::configureColors .dark
checkEq "and back to the light blue on the dark one" \
    [linkFg .dark Index] "LightSkyBlue"

puts "\n$checks checks, $fails failures"
destroy .
exit [expr {$fails > 0}]
