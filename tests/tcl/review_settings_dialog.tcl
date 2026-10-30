# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_settings_dialog.tcl -- build the Review Settings dialog under real Tk.
#
#   wish tests/tcl/review_settings_dialog.tcl
#   xvfb-run -a wish tests/tcl/review_settings_dialog.tcl   (no display)
#
# The tclsh harnesses cannot see this: ::reviewui decides what the dialog
# stores, but ::enginewin::reviewSettings makes the widgets, and a body it
# cannot compile leaves a half-built window. That is exactly what happened -
# one bracket short in the var_lines trace, so the rows appeared and the OK and
# Cancel buttons never did, and no setting could be applied at all.
#
# The scid environment is stubbed; nothing here touches a database, an engine or
# the network. Geometry is not asserted: window size is the window manager's
# business.

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
    if {[llength $args]} { return [lindex $args 0] }
    return $tag
}
proc ::button_image {args} { return "" }
# The real helper is in tcl/start.tcl: paint a classic widget with the theme's
# background, and repaint it when the theme changes.
proc ::applyThemeColor_background {widget} {
    set bg [ttk::style lookup . -background "" #d9d9d9]
    $widget configure -background $bg
    bind $widget <<ThemeChanged>> [list ::applyThemeColor_background $widget]
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
namespace eval ::enginecfg {}
proc ::enginecfg::get {name} { return {} }
set ::language E
set ::translatePieces 0

set root [file normalize [file join [file dirname [info script]] .. ..]]
set ::scidTclDir [file join $root tcl]
set ::scidShareDir $root
set ::scidVersion test
set ::scidName Scid
set ::initialdir $root
set ::showGameInfo 0
set ::language E
set ::initialdir $root

source [file join $root tcl tools score_seed.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools game_review.tcl]
source [file join $root tcl tools review_ui.tcl]
source [file join $root tcl windows engine.tcl]

wm withdraw .
toplevel .engineWin1

# ----------------------------------------------------------------- the dialog --
puts "\nthe Review Settings dialog"

::review::reset
set ::enginewin::pgnviewer(1) 0
set w ""
set rc [catch { set w [::enginewin::reviewSettings 1] } err]
checkEq "the dialog is built without an error" $rc 0
checkEq "and it is the window the button names" $w .engineWin1.reviewSettings

# The half-built window this harness was written for: the rows were there and
# the buttons were not, because the body stopped compiling mid-proc.
check "the OK button exists" [winfo exists $w.b.ok]
check "the Cancel button exists" [winfo exists $w.b.cancel]
foreach key {mpv depth var_lines var_cp move_comment_wait diagram} {
    check "the $key row is there" [winfo exists $w.f.v$key]
}
checkEq "it opens on the stored values" \
    [list $::enginewin::reviewsetting(1,var_lines) \
          $::enginewin::reviewsetting(1,var_cp)] {1 0}

# What the user does: type the numbers, press OK.
puts "\ntyping a value and pressing OK"
set ::enginewin::reviewsetting(1,var_lines) 2
set ::enginewin::reviewsetting(1,var_cp) 40
$w.b.ok invoke
checkEq "the dialog is gone" [winfo exists $w] 0
# trace add returns nothing, so a prefix kept as its return value is "", the
# removal fails silently, and every reopen leaves another trace behind.
checkEq "and its mpv trace went with it" \
    [llength [trace info variable ::enginewin::reviewsetting(1,mpv)]] 0
checkEq "var_lines is stored" $::reviewopt(var_lines) 2
checkEq "and so is var_cp" $::reviewopt(var_cp) 40
# A fresh start reads the saved option, which is what the next session sees.
set ::review::S [dict create]
checkEq "and a fresh start reads it back" [::review::get var_lines] 2

# A refusal keeps the dialog and the values the user can still correct.
puts "\na refused value keeps the dialog open"
::review::setValue mpv 3
set w2 [::enginewin::reviewSettings 1]
set ::enginewin::reviewsetting(1,var_lines) 9
$w2.b.ok invoke
checkEq "the dialog stays open" [winfo exists $w2] 1
check "the reason is shown" [expr {$::enginewin::reviewwhy(1) ne ""}]
checkEq "and the setting is not changed" [::review::get var_lines] 2
destroy $w2

# The var_lines spinbox follows mpv while the dialog is open.
puts "\nthe variation box follows the lines box"
set w3 [::enginewin::reviewSettings 1]
checkEq "reopening installs one trace, not a second" \
    [llength [trace info variable ::enginewin::reviewsetting(1,mpv)]] 1
set ::enginewin::reviewsetting(1,mpv) 5
checkEq "its ceiling follows mpv" [$w3.f.vvar_lines cget -to] 5
destroy $w3
checkEq "and closing removes it again" \
    [llength [trace info variable ::enginewin::reviewsetting(1,mpv)]] 0
catch { unset ::enginewin::reviewtraceptr(1) }

# A toplevel is a classic Tk widget and keeps Tk's grey; the ttk rows inside
# follow the theme, so the strip beside OK/Cancel is the only place the old
# colour showed through.
puts "\nthe window follows the theme"

ttk::style theme create reviewdark -parent classic -settings {
    ttk::style configure . -background #1e1e2e -foreground #cdd6f4
    ttk::style configure TFrame -background #1e1e2e
    ttk::style configure TLabel -background #1e1e2e -foreground #cdd6f4
}
ttk::style theme use reviewdark
set w4 [::enginewin::reviewSettings 1]
checkEq "the dialog is painted with the theme's background" \
    [$w4 cget -background] #1e1e2e
check "and not Tk's classic grey" \
    [expr {[$w4 cget -background] ne "#d9d9d9"}]
destroy $w4

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
