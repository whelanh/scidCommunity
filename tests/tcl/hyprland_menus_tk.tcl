#!/usr/bin/env wish
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# hyprland_menus_tk.tcl -- a menu must stay where Tk posted it.
#
#   wish tests/tcl/hyprland_menus_tk.tcl
#   xvfb-run -a wish tests/tcl/hyprland_menus_tk.tcl
#
# Hyprland, on a workspace switched to its "floating" layout, opens every
# window in the middle of the screen at a fixed size; Omarchy does it with a
# window rule. The rule catches Tk's menu windows too, so each menu and submenu
# comes up as a large square that no longer sits next to the menu above it, and
# covers it. ::hyprMenus puts the geometry Tk posted back.
#
# The harness stands in for the compositor: once a menu is posted it moves and
# resizes the menu window itself, the way the rule does, and checks that the
# menu returns to the size its entries ask for and the position Tk gave it. Off
# Hyprland nothing is installed, and a move a second after the menu was posted
# - the user dragging a torn-off menu - is left alone.

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
# The real Hyprland check, so the gate is the one the application uses.
source [file join $root tcl windows.tcl]

puts "\noff Hyprland nothing is installed"

unset -nocomplain ::env(HYPRLAND_INSTANCE_SIGNATURE)
source [file join $root tcl hyprland-menus.tcl]
check "no map binding" [expr {[bind Menu <Map>] eq ""}] [bind Menu <Map>]
check "no configure binding" [expr {[bind Menu <Configure>] eq ""}] [bind Menu <Configure>]

puts "\non Hyprland the geometry a menu was posted with is kept"

set ::env(HYPRLAND_INSTANCE_SIGNATURE) test
::hyprMenus::install
check "the menu is watched when it maps" \
    [expr {[regexp -all {::hyprMenus::onMap} [bind Menu <Map>]] == 1}] \
    [bind Menu <Map>]
check "and when the compositor configures it" \
    [expr {[regexp -all {::hyprMenus::onConfigure} [bind Menu <Configure>]] == 1}] \
    [bind Menu <Configure>]

menu .probe -tearoff 0
.probe add command -label One
.probe add command -label Two
menu .probe.sub -tearoff 0
.probe.sub add command -label A
.probe.sub add command -label B
.probe add cascade -label Sub -menu .probe.sub

# What the compositor does to a window that opens: a large square in the
# middle of the screen, in place of the menu Tk laid out.
proc compositorOpens {w} {
    wm geometry $w 900x700+40+40
    update
}
proc menuGeometry {w} {
    list [winfo width $w] [winfo height $w] [winfo rootx $w] [winfo rooty $w]
}

.probe post 300 200
update
set posted [menuGeometry .probe]
check "the menu posts at the requested size and position" \
    [expr {[lindex $posted 0] == [winfo reqwidth .probe]
        && [lindex $posted 1] == [winfo reqheight .probe]
        && [lindex $posted 2] == 300 && [lindex $posted 3] == 200}] $posted

compositorOpens .probe
set after [menuGeometry .probe]
check "the menu returns to its requested size" \
    [expr {[lindex $after 0] == [winfo reqwidth .probe]
        && [lindex $after 1] == [winfo reqheight .probe]}] $after
check "and to the position Tk posted it at" \
    [expr {[lindex $after 2] == 300 && [lindex $after 3] == 200}] $after

# A submenu is its own window and the rule catches it the same way.
.probe.sub post 400 260
update
compositorOpens .probe.sub
set after [menuGeometry .probe.sub]
check "a submenu returns to its requested size" \
    [expr {[lindex $after 0] == [winfo reqwidth .probe.sub]
        && [lindex $after 1] == [winfo reqheight .probe.sub]}] $after
check "and it branches off the position it was posted at" \
    [expr {[lindex $after 2] == 400 && [lindex $after 3] == 260}] $after
.probe.sub unpost

# Scaling can leave a pixel between the position Tk asked for and the position
# the menu window gets; that is not the compositor's rule and is not chased.
set size [lindex [split [winfo geometry .probe] +] 0]
wm geometry .probe +301+200
update
checkEq "a one-pixel offset is not chased" [winfo geometry .probe] "${size}+301+200"

# A menu torn down while its checks are still pending must raise nothing: a
# context menu comes and goes with the click that picks an entry from it.
set ::errors {}
proc bgerror {msg} { lappend ::errors $msg }
menu .vanish -tearoff 0
.vanish add command -label Gone
.vanish post 300 200
update
destroy .vanish

# A torn-off menu is dragged by the user long after it was posted; that move
# must not be undone. The wait also lets the destroyed menu's pending checks
# fire, which is what the error list above is for.
after 1400 {set ::probeWatched 1}
vwait ::probeWatched
check "a menu destroyed while it is watched raises nothing" \
    [expr {[llength $::errors] == 0}] $::errors
wm geometry .probe 400x300+600+500
update
checkEq "a move after the watch window is left alone" \
    [winfo geometry .probe] "400x300+600+500"

.probe unpost
destroy .probe

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
