#!/usr/bin/env wish
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# search_presets_tk.tcl -- the Header search's Presets menu, under Tk.
#
#   wish tests/tcl/search_presets_tk.tcl
#   xvfb-run -a wish tests/tcl/search_presets_tk.tcl
#
# search_presets.tcl proves the data: what a preset stores, what a load
# restores and what a delete forgets. This harness proves the menu the search
# window shows, which the data test cannot reach: rebuilding it twice must not
# fail on the submenus the first build left behind, two names must not share a
# submenu, and the entries a user clicks must load and delete the preset they
# are labelled with.
#
# The window itself is not built: the menubutton and its menu are the two
# widgets board.tcl creates, so they are created here and the real rebuild
# procedure populates them.

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
set fh [open [file join $root tcl search header.tcl] r]
set lines [split [read $fh] "\n"]
close $fh

proc extractProc {lines procName} {
    set start -1
    for {set i 0} {$i < [llength $lines]} {incr i} {
        if {[string match "proc $procName *" [lindex $lines $i]]} {
            set start $i
            break
        }
    }
    if {$start < 0} { return "" }
    set text ""
    for {set i $start} {$i < [llength $lines]} {incr i} {
        append text [lindex $lines $i] "\n"
        if {[info complete $text]} { return $text }
    }
    return ""
}

set saveText   [extractProc $lines ::search::header::preset_save]
set loadText   [extractProc $lines ::search::header::preset_load]
set deleteText [extractProc $lines ::search::header::preset_delete]
set oneText    [extractProc $lines ::search::header::rebuild_presets_menu_one]
set menuText   [extractProc $lines ::search::header::rebuild_presets_menu]
foreach {name text} [list preset_save $saveText preset_load $loadText \
                          preset_delete $deleteText rebuild_presets_menu_one $oneText \
                          rebuild_presets_menu $menuText] {
    check "$name was extracted" [expr {$text ne ""}]
}
if {$saveText eq "" || $loadText eq "" || $deleteText eq "" || $oneText eq "" || $menuText eq ""} {
    puts "\n$checks checks, $fails failures"
    exit 1
}

namespace eval ::search::header {}
eval $saveText
eval $loadText
eval $deleteText
eval $oneText
eval $menuText

# The two widgets board.tcl creates for the Header search window.
proc ::tr {key} { return $key }

set w .wnd_HeaderSearch
frame $w
frame $w.buttons
ttk::menubutton $w.buttons.presets -text [::tr Presets] -menu $w.buttons.presets.m
menu $w.buttons.presets.m -tearoff 0
$w.buttons.presets.m add command -label [::tr Save]
$w.buttons.presets.m add separator
set m $w.buttons.presets.m

set ::searchHeader_Layouts {}
array set ::searchHeader_Data {}
array set ::sHeaderFlags {StdStart both}
array set ::sTitles {w:gm 1}
array set ::sPgntext {1 {}}
set ::sWhite "Kasparov, G"
set ::sBlack ""

::search::header::preset_save "Alpha"
set ::sWhite "Fischer, R"
::search::header::preset_save "Beta"

# ------------------------------------------------------------ the first build --
::search::header::rebuild_presets_menu_one $w
checkEq "the menu carries Save, a separator and one cascade per preset" [$m index end] 3
checkEq "the cascades are labelled with the preset names" \
    [list [$m entrycget 2 -label] [$m entrycget 3 -label]] {Alpha Beta}
set alphaMenu [$m entrycget 2 -menu]
checkEq "a cascade offers Load and Delete" [$alphaMenu index end] 1
checkEq "the cascade's first entry is Load" [$alphaMenu entrycget 0 -label] "Load"
checkEq "the cascade's second entry is Delete" [$alphaMenu entrycget 1 -label] "Delete"

# ------------------------------------------------------- rebuilding it again --
# The submenus of the first build must not make the second one fail.
set err ""
if {[catch {::search::header::rebuild_presets_menu_one $w} err]} {
    check "a second rebuild does not fail" 0 $err
} else {
    check "a second rebuild does not fail" 1
}
checkEq "a second rebuild leaves the same entries" [$m index end] 3
checkEq "a second rebuild keeps the labels" \
    [list [$m entrycget 2 -label] [$m entrycget 3 -label]] {Alpha Beta}

# ------------------------------------------- names that used to share a submenu --
# The old build derived the submenu's widget name from the preset name, with
# spaces folded to underscores, so these two produced the same widget path.
::search::header::preset_save "A B"
::search::header::preset_save "A_B"
::search::header::rebuild_presets_menu_one $w
checkEq "both similar names are listed" [$m index end] 5
set menus {}
for {set i 2} {$i <= 5} {incr i} { lappend menus [$m entrycget $i -menu] }
checkEq "every cascade has its own submenu" [llength [lsort -unique $menus]] 4

# ------------------------------------------------------------- invoking them --
# Load the preset whose cascade is labelled Alpha.
set ::sWhite "Changed"
$alphaMenu invoke 0
checkEq "the cascade's Load entry restores the preset" $::sWhite "Kasparov, G"

# Delete Beta through its own cascade, which must rebuild the menu.
set betaMenu [$m entrycget 3 -menu]
$betaMenu invoke 1
check "the deleted name leaves the menu" \
    [expr {[lsearch -exact [$m entrycget 2 -label] "Beta"] == -1 && [lsearch -exact [$m entrycget 3 -label] "Beta"] == -1}]
checkEq "the delete rebuilds the menu without it" [$m index end] 4
check "the deleted preset is forgotten" [expr {![info exists ::searchHeader_Data(Beta)]}]

puts "\n$checks checks, $fails failures"
if {$fails} { exit 1 }
exit 0
