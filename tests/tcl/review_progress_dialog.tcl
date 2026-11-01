# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_progress_dialog.tcl -- the pass's progress window under real Tk.
#
#   wish tests/tcl/review_progress_dialog.tcl
#   xvfb-run -a wish tests/tcl/review_progress_dialog.tcl   (no display)
#
# The tclsh harnesses cannot see this: ::reviewui decides the text and the
# fraction, but ::enginewin builds the widgets. The window must appear when a
# pass starts, follow the search and then the coach, stay up while the model
# writes, and go away when the pass is over or is cancelled.
#
# The scid environment is stubbed; nothing here touches a database, an engine or
# the network. Geometry is not asserted: window placement is the window
# manager's business.

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

# --------------------------------------------------------------- environment --
proc options.store {varname {default ""}} {
    if {![info exists $varname]} { set $varname $default }
}
proc options.write {} { return 1 }
proc openURL {url} {}
proc tk_messageBox {args} { return ok }
proc tr {tag args} {
    array set EN {
        ReviewGameButton    {Game Review}
        ReviewProgress      {Reviewing position %s of %s}
        ReviewCoachProgress {Coach prose: %s of %s}
        ReviewWriting       {Writing the review...}
    }
    if {[info exists EN($tag)]} { return $EN($tag) }
    if {[llength $args]} { return [lindex $args 0] }
    return $tag
}
proc ::button_image {args} { return "" }
# The real helper paints a classic toplevel with the theme's background.
proc ::applyThemeColor_background {widget} {
    catch { $widget configure -background #1e1e2e }
}
namespace eval ::utils::tooltip {}
proc ::utils::tooltip::Set {args} {}
namespace eval ::board {}
proc ::board::update {args} {}
proc ::board::setmarks {args} {}
namespace eval ::pgn {}
proc ::pgn::Refresh {args} {}
namespace eval ::win {}
proc ::win::add {args} {}
set ::language E
set ::translatePieces 0

set root [file normalize [file join [file dirname [info script]] .. ..]]
set ::scidTclDir [file join $root tcl]
set ::scidShareDir $root
set ::scidVersion test
set ::scidName Scid
set ::initialdir $root
set ::showGameInfo 0

source [file join $root tcl tools score_seed.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools game_review.tcl]
source [file join $root tcl tools review_ui.tcl]
source [file join $root tcl windows engine.tcl]

# The driver is the only thing this window reads. It is replaced with a state
# the test sets, so the search, the write and the coach are three dicts.
namespace eval ::reviewdriver {}
set ::passState {state idle searched 0 total 0 written 0 failed 0 coachDone 0 coachTotal 0 errors {} reason "" restored 0}
proc ::reviewdriver::status {} { return $::passState }
proc ::reviewdriver::cancel {{restore 1}} { set ::cancelled [expr {$restore}] ; return 1 }

wm withdraw .
toplevel .engineWin1
set ::enginewin::pgnviewer(1) 0

# Which toplevel the popup is, and the label text it shows.
proc popup {} { return [::enginewin::reviewProgressWindow 1] }
proc popupText {} {
    if {![winfo exists [popup]]} { return "" }
    return [set ::enginewin::reviewprogress(1)]
}

puts "\nthe window appears when a pass starts"

set ::enginewin::reviewowner 1
set ::passState [dict merge $::passState {state searching searched 2 total 8}]
::enginewin::reviewStatus 1
set w [popup]
check "the progress window is built" [winfo exists $w]
checkEq "it is the pass's window" $w .engineWin1.reviewProgress
check "it has a bar" [winfo exists $w.bar]
checkEq "the window follows the theme's background" [$w cget -background] #1e1e2e
check "and a Cancel button" [winfo exists $w.cancel]
checkEq "the search's position is on it" [popupText] "Reviewing position 2 of 8"
check "and the bar is a quarter full" \
    [expr {abs([$w.bar cget -value] - 0.25) < 0.001}]

puts "\nit stays up while the coach writes"

set ::passState [dict merge $::passState {state writing written 8 coachDone 3 coachTotal 6}]
::enginewin::reviewStatus 1
check "the window is still there" [winfo exists $w]
checkEq "and says the coach is writing" [popupText] "Coach prose: 3 of 6"
check "the bar follows the answers" \
    [expr {abs([$w.bar cget -value] - 0.5) < 0.001}]

# Before the first answer there is nothing to count yet: the window must still
# be there and say what the pass is doing, not disappear.
set ::passState [dict merge $::passState {state writing coachDone 0 coachTotal 0}]
::enginewin::reviewStatus 1
checkEq "before the coach counts, it says what it is doing" [popupText] \
    "Writing the review..."
check "and the bar is full, not empty" \
    [expr {[$w.bar cget -value] == 1.0}]

puts "\nthe window goes away when the pass is over"

set ::passState [dict merge $::passState {state done written 8}]
::enginewin::reviewStatus 1
check "the window is gone" [expr {![winfo exists $w]}]

puts "\nclosing it hides it, and a new pass shows it again"

set ::enginewin::reviewowner 1
set ::passState [dict merge $::passState {state searching searched 1 total 4}]
::enginewin::reviewStatus 1
set w [popup]
check "a new pass shows the window" [winfo exists $w]
checkEq "and it starts at the first position" [popupText] "Reviewing position 1 of 4"
# The close button the window manager offers.
::enginewin::reviewHideProgress 1
check "closing it takes it away" [expr {![winfo exists $w]}]
set ::passState [dict merge $::passState {state searching searched 2 total 4}]
::enginewin::reviewStatus 1
check "and it does not pop back on the next count" [expr {![winfo exists $w]}]
set ::passState [dict merge $::passState {state done}]
::enginewin::reviewStatus 1
set ::enginewin::reviewowner 1
set ::passState [dict merge $::passState {state searching searched 1 total 2}]
::enginewin::reviewStatus 1
check "the pass after next shows it again" [winfo exists [popup]]

puts "\nCancel stops the pass from the window"

set ::cancelled {}
[popup].cancel invoke
checkEq "the window's Cancel cancels the pass" $::cancelled 1
checkEq "and the owner is given back" $::enginewin::reviewowner ""
check "and the window goes away" [expr {![winfo exists [popup]]}]

set ::passState [dict merge $::passState {state done}]
::enginewin::reviewStatus 1
check "a done pass leaves no window" [expr {![winfo exists [popup]]}]

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
