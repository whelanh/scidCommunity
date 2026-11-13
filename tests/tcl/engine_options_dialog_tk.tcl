#!/usr/bin/env wish
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# engine_options_dialog_tk.tcl -- the engine options panel must fit its dialog.
#
#   xvfb-run -a wish tests/tcl/engine_options_dialog_tk.tcl
#
# Under Hyprland, win::createDialog centers a dialog with "wm geometry", which
# makes Tk treat the size the dialog had at that moment as the user's choice.
# The dialog then keeps that width when the engine options frame is gridded and
# the frame is drawn outside the window: the settings button beside the Name
# field looks like it does nothing. ::engineNoWin::showHideOptionsFrame now
# re-applies the size the content asks for, and gives the space back when the
# frame is hidden.
#
# The test pins a small dialog to its requested size (what Hyprland's centering
# leaves behind), shows the options frame through the real procedure, and
# checks that the frame lands inside the window.

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
source [file join $root tcl tools enginenowin.tcl]

# The frame's toggle only resizes under Hyprland; this harness is that session,
# and the engine connection is not part of what is measured here.
proc isHyprlandSession {} { return 1 }
proc ::engineNoWin::initEngine {args} { return 1 }

set w .optionsDialog
toplevel $w
wm title $w "engine options test"
catch { wm attributes $w -type dialog }

ttk::frame $w.form
ttk::label $w.form.name -text Name
ttk::entry $w.form.nameEntry -width 30
grid $w.form.name -row 0 -column 0 -sticky w
grid $w.form.nameEntry -row 0 -column 1 -sticky we
grid $w.form -row 0 -column 0 -sticky nsew

ttk::labelframe $w.options -text "Engine Parameter"
text $w.options.text -width 60 -height 20
pack $w.options.text

# The size Hyprland's centering leaves behind: the dialog as it was mapped.
update idletasks
wm geometry $w "[winfo reqwidth $w]x[winfo reqheight $w]+40+40"
update
set pinnedWidth [winfo width $w]

set ::testEngine TestEngine
::engineNoWin::showHideOptionsFrame test $w.options ::testEngine cb 2
update
after 100
update

check "the options frame is shown" [winfo ismapped $w.options]
check "the dialog grew to fit it" \
    [expr {[winfo width $w] >= [winfo reqwidth $w]}] \
    "window [winfo width $w], content [winfo reqwidth $w]"
check "the whole frame is inside the dialog" \
    [expr {[winfo x $w.options] + [winfo width $w.options] <= [winfo width $w]}] \
    "frame ends at [expr {[winfo x $w.options] + [winfo width $w.options]}], window is [winfo width $w]"
set shownWidth [winfo width $w]

::engineNoWin::showHideOptionsFrame test $w.options ::testEngine cb 2
update
after 100
update

check "the options frame is hidden" [expr {![winfo ismapped $w.options]}]
check "the dialog gives the space back" \
    [expr {abs([winfo width $w] - $pinnedWidth) <= 2}] \
    "window [winfo width $w], pinned $pinnedWidth"
check "the hidden frame needs less width" [expr {$shownWidth > $pinnedWidth}]

destroy $w
puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
