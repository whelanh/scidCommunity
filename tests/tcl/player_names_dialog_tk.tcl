# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# player_names_dialog_tk.tcl -- the My Player Names dialog shows its OK row.
#
#   wish tests/tcl/player_names_dialog_tk.tcl
#   xvfb-run -a wish tests/tcl/player_names_dialog_tk.tcl   (no display)
#
# The dialog was pinned to 560x440. That fits at the default font size, but a
# larger UI font -- what a HiDPI display does to every point-sized font -- wraps
# the description onto more lines, and the content then asks for more height
# than the window had. Packed last, the button row was the slave that lost its
# space, so OK and Cancel sat below the visible area until the window was
# dragged bigger.
#
# This harness builds the real dialog twice: once at the default size and once
# with Tk's scaling doubled, and asserts that every button is inside the window
# and that the window is at least as tall as its contents ask for. It also
# shrinks the dialog to the minimum it allows and checks the buttons survive
# that, which is what the pack order buys.
#
# The scid environment is stubbed; nothing here opens a database, an engine or
# the network.

set fails 0
set checks 0
# Unbuffered: if a run hangs, the line it stopped at is what says where.
fconfigure stdout -buffering none
proc check {label cond {detail ""}} {
    incr ::checks
    if {$cond} {
        puts "  ok   $label"
    } else {
        incr ::fails
        if {$detail eq ""} { puts "  FAIL $label" } else { puts "  FAIL $label -- $detail" }
    }
}

# --------------------------------------------------------------- environment --
set root [file normalize [file join [file dirname [info script]] .. ..]]

# The pieces of the main window the dialog is built from. misc.tcl has the
# dialog button helpers and the auto-hiding scrollbars; utils/win.tcl has
# createDialog and makeVisible, which is what sizes and shows the window here.
source [file join $root tcl misc.tcl]
source [file join $root tcl utils win.tcl]
source [file join $root tcl main.tcl]

# main.tcl schedules loadPlayersPhoto on idle. It reads the scid data
# directories, which do not exist here, and an error raised from an idle
# callback puts Tk into a modal error dialog -- which under Xvfb waits for a
# click that never comes, so the harness would hang instead of failing.
foreach id [after info] { after cancel $id }
proc bgerror {msg} {
    puts "  FAIL background error: $msg"
    exit 1
}

# The translation table. The description is the English one from
# tcl/lang/english.tcl: its length is what decides how many lines it wraps to.
set ::language E
namespace eval :: { variable tr }
proc tr {tag {lang ""}} { return $::tr($tag) }
set ::tr(OptionsBoardNames) {My Player Names...}
set ::tr(MyPlayerNamesDescription) {Enter a list of preferred player names below, one name per line. Wildcards (e.g. "?" for any single character, "*" for any sequence of characters) are permitted.
Every time a game with a player in the list is loaded, the main window chessboard will be rotated if necessary to show the game from that players perspective.}
set ::tr(White) {White}
set ::tr(Black) {Black}
set ::tr(Help) {Help}
set ::tr(Cancel) {Cancel}

# The font every widget in the dialog uses. A point size, like createFonts makes
# it, so that tk scaling moves it the way a display scale factor does.
font create font_Regular -size 10
font create font_Bold -size 10 -weight bold
ttk::style configure . -font font_Regular

# autoscrollText lives in start.tcl, which starts the whole application. This is
# its body without the parts that need the theme machinery.
proc applyThemeStyle {style widget} {
    foreach {option value} [ttk::style configure $style] {
        catch { $widget configure $option $value }
    }
}
proc autoscrollText {bars frame widget style} {
    ttk::frame $frame
    text $widget -cursor arrow -state disabled -highlightthickness 0 -font font_Regular
    $widget tag configure header -font font_Bold
    applyThemeStyle $style $widget
    autoscrollBars $bars $frame $widget
}
proc applyThemeColor_background {widget} { }
proc isHyprlandSession {} { return 0 }
proc raiseWin {w} { }
proc helpWindow {args} { }
proc sc_game {args} { return "" }

set ::myPlayerNames {Crandall, David}

# ---------------------------------------------------------------- checks ------
# A button is visible when its bottom edge is above the bottom edge of the
# window it is in: pack leaves a slave that does not fit where it is, off the
# window, rather than resizing the window to hold it.
proc buttonsInside {w} {
    set out {}
    set winBottom [expr {[winfo rooty $w] + [winfo height $w]}]
    foreach b {white black help ok cancel} {
        set wd $w.b.$b
        if {![winfo exists $wd]} { lappend out "$b missing"; continue }
        if {![winfo ismapped $wd]} { lappend out "$b unmapped"; continue }
        set bottom [expr {[winfo rooty $wd] + [winfo height $wd]}]
        if {$bottom > $winBottom} { lappend out "$b cut off by [expr {$bottom - $winBottom}]px" }
    }
    return $out
}

proc buildDialog {label} {
    editMyPlayerNames
    update
    set w .editMyPlayerNames
    puts "\n== $label =="
    check "the dialog is built" [winfo exists $w] $w
    if {![winfo exists $w]} { return "" }
    set inside [buttonsInside $w]
    check "every button is inside the window" [expr {[llength $inside] == 0}] $inside
    check "the window is as tall as its contents ask for" \
        [expr {[winfo height $w] >= [winfo reqheight $w]}] \
        "height [winfo height $w] wants [winfo reqheight $w]"
    check "the description is inside the window too" \
        [expr {[winfo rooty $w.desc] + [winfo height $w.desc] <= [winfo rooty $w] + [winfo height $w]}] \
        "desc bottom [expr {[winfo rooty $w.desc] + [winfo height $w.desc]}] window bottom [expr {[winfo rooty $w] + [winfo height $w]}]"
    return $w
}

# The size it opens with is the whole point: a user should not have to drag the
# window before the buttons appear.
set w [buildDialog "opening at the default font size"]
if {$w ne ""} {
    check "it is not smaller than the size it always had" \
        [expr {[winfo height $w] >= 440 && [winfo width $w] >= 560}] \
        "[winfo width $w]x[winfo height $w]"
}

# Dragging the dialog smaller must not hide the buttons again. The name list is
# the part that gives way.
if {$w ne ""} {
    puts "\n== shrinking to the minimum keeps the button row =="
    lassign [wm minsize $w] minW minH
    wm geometry $w "${minW}x${minH}"
    update
    set inside [buttonsInside $w]
    check "every button is still inside the window" [expr {[llength $inside] == 0}] $inside
    check "the description is still inside the window" \
        [expr {[winfo rooty $w.desc] + [winfo height $w.desc] <= [winfo rooty $w] + [winfo height $w]}] \
        "desc bottom [expr {[winfo rooty $w.desc] + [winfo height $w.desc]}] window bottom [expr {[winfo rooty $w] + [winfo height $w]}]"
    destroy $w
}

# A display scale factor of 2 is what a 200% display does to a point-sized font:
# every line of the description gets taller and the text box asks for twice the
# height. The window has to follow, which a fixed 440 cannot do.
tk scaling 2.0
set w [buildDialog "opening at 200% scaling"]
if {$w ne ""} {
    check "the window grew past the old fixed height" \
        [expr {[winfo height $w] > 440}] "height [winfo height $w]"
    destroy $w
}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
