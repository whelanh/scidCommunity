#!/usr/bin/env tclsh
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_toolbar.tcl -- the engine window's review controls are icon-only.
#
#   tclsh tests/tcl/review_toolbar.tcl
#
# The review buttons used to repeat their labels as text; the rest of the engine
# toolbar is icon-only, and the text buttons were the first thing to disappear
# when the window was narrow. The labels are still the tooltips and the help
# pages, so the icons must be present in both themes and every button must keep
# its tooltip.
#
# This harness reads the glue instead of building Tk: it asserts the image names,
# the icon files and their 24x24 geometry, the tooltips, and the one piece of
# state that is not a widget property - the stop icon's grid remove.

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
proc readText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation auto
    set text [read $f]
    close $f
    return $text
}

set engineSrc [readText [file join $root tcl windows engine.tcl]]

puts "\nthe five review icons"

# key: the icon basename used by the button
set icons {
    game     {Game Review}
    move     {Move Comment}
    threat   {What's the Threat?}
    settings {Review Settings}
    stop     {Cancel}
}

foreach {key label} $icons {
    set name "tb_review_$key"
    check "$label: engine.tcl uses ::icon::$name" \
        [expr {[string first "-image ::icon::$name" $engineSrc] >= 0}]

    # The PGN window's toolbar uses ::icon:: images; configure_style recreates
    # them from these two directories on a theme change, so an open window
    # changes with the theme. img/buttons names are fixed at creation time.
    foreach dir {icons_light icons_dark} {
        set path [file join $root img $dir "$name.png"]
        check "$label: $dir/$name.png exists" [file exists $path]
        if {![file exists $path]} { continue }
        set f [open $path rb]
        fconfigure $f -translation binary
        set head [read $f 24]
        close $f
        binary scan $head @16II width height
        checkEq "$label: $dir/$name.png is 24x24" [list $width $height] {24 24}
    }
}

puts "\nlabels are tooltips, not text"

foreach {button key} {
    gamereview    ReviewGameButton
    movecomment   ReviewMoveButton
    reviewsettings ReviewSettings
} {
    check "$button: no text label" \
        [expr {[string first "-text \[::reviewui::label $key\]" $engineSrc] < 0}] \
        "the button fell back to its label as text"
}
check "reviewcancel: no text label" \
    [expr {[string first {ttk::button $btn.reviewcancel -text} $engineSrc] < 0}]

foreach {button tooltip} {
    gamereview     ReviewGameButtonTooltip
    movecomment    ReviewMoveButtonTooltip
    reviewsettings ReviewSettingsTooltip
} {
    check "$button: the tooltip is set from $tooltip" \
        [expr {[string first "::utils::tooltip::Set \$btn.$button \[::reviewui::label $tooltip\]" $engineSrc] >= 0}]
}
check "reviewcancel: the tooltip is Cancel" \
    [expr {[string first {::utils::tooltip::Set $btn.reviewcancel [tr Cancel]} $engineSrc] >= 0}]

puts "\nthe stop icon is live only while a pass runs"

check "reviewRefresh removes the stop icon" \
    [expr {[string first {grid remove $w.btn.reviewcancel} $engineSrc] >= 0}]
check "and puts it back when a pass starts" \
    [expr {[string first {grid $w.btn.reviewcancel} $engineSrc] >= 0}]
check "the review bar is built from the live set, threat optional" \
    [expr {[string first {set reviewButtons [list $btn.gamereview $btn.movecomment]} $engineSrc] >= 0 \
        && [string first {if {[winfo exists $btn.threat]} { lappend reviewButtons $btn.threat }} $engineSrc] >= 0}]
check "a visible divider separates the review settings icon from Config" \
    [expr {[string first {ttk::separator $btn.reviewgap -orient vertical} $engineSrc] >= 0 \
        && [string first {grid configure $btn.reviewgap -padx 9 -sticky ns} $engineSrc] >= 0 \
        && [string first {lappend reviewButtons $btn.reviewgap} $engineSrc] >= 0}]

puts "\nthe dark-theme icon cache"

# image names are ::icon::name. The cache builder used to match "icon::*", so it
# found nothing and every toolbar icon stayed black in a dark theme.
set startSrc [readText [file join $root tcl start.tcl]]
check "the cache builder matches absolute icon names" \
    [expr {[string first {dict keys $allNames "*icon::*"} $startSrc] >= 0}]
check "and strips the whole ::icon:: prefix" \
    [expr {[string first {string range $iname 8 end} $startSrc] >= 0}]

puts "\nthe threat button waits for its command"

check "the threat button is guarded by its command" \
    [expr {[string first {if {[llength [info commands ::enginewin::threat]]}} $engineSrc] >= 0}]
check "and its icon is the one prepared here" \
    [expr {[string first {tb_review_threat} $engineSrc] >= 0}]

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
