#!/usr/bin/env tclsh
# Copyright (C) 2026
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Which preset each engine-window shortcut starts.
#
#   tclsh tests/tcl/engine_window_slots.tcl
#
# Tools -> Configure Engines sorts its list by last use, so an engine's position
# changes whenever a preset is opened or edited. F2/F3 used to follow that
# position (or, after the last-engine memory was added, fall back to the most
# recently used preset when a name no longer resolved). The fix gives each
# preset an explicit shortcut, kept by name:
#
#   * one preset per shortcut - assigning it to F3 removes it from F2;
#   * a rename carries the assignment (and each window's remembered preset);
#   * a delete drops both, rather than leaving a name that no longer resolves.
#
# The dialog end (the Key column and the radio buttons) needs Tk, so its wiring
# is checked against the source at the end, the way engine_duplicate.tcl does.

set fails 0
set checks 0

proc check {name cond} {
    global fails checks
    incr checks
    if {![uplevel 1 [list expr $cond]]} {
        incr fails
        puts "FAIL $name"
    }
}

proc checkEq {name got want} {
    global fails checks
    incr checks
    if {$got ne $want} {
        incr fails
        puts "FAIL $name -- got '$got' want '$want'"
    }
}

proc call {cmd} {
    if {[catch {uplevel 1 $cmd} res]} { return "ERR: $res" }
    return $res
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl enginecfg.tcl]

# The file writer and the dialogs are not under test here.
set ::tmpbase [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) \
                 : [info exists ::env(TEMP)] ? $::env(TEMP) : "/tmp"}]
set ::tmp [file join $::tmpbase "scid_engine_slots_[pid].dat"]
proc scidConfigFile {type} { return $::tmp }
set ::scidVersion 5.0
set ::tr(EngineNameInUse) {An engine named %s already exists. Save this one as %s instead?}
set ::answer yes
proc tk_messageBox {args} { return $::answer }

# Lift the data-layer procs out of enginelist.tcl: the list dialog itself needs
# Tk, and sourcing the whole file would run its top-level loader.
proc procText {path name} {
    set f [open $path r]
    set src [read $f]
    close $f
    set from [string first "proc $name " $src]
    if {$from < 0} { return "" }
    set text ""
    foreach line [split [string range $src $from end] "\n"] {
        append text $line "\n"
        if {[info complete $text]} { break }
    }
    return $text
}

set enginelistFile [file join $root tcl tools enginelist.tcl]
namespace eval enginelist {}
foreach name {::enginelist::applyEdit ::enginelist::nameTaken \
              ::enginelist::saveEdit ::enginelist::delete} {
    set text [procText $enginelistFile $name]
    if {$text eq ""} {
        puts "FAIL the engine list's $name could not be extracted"
        incr fails
        incr checks
        continue
    }
    eval $text
}
namespace eval engineNoWin {}
proc ::engineNoWin::saveEngineSetup {args} {}
proc ::enginelist::sort {{type ""}} {}

# A preset as ::enginelist::read would leave it.
proc entry {name {time 0}} {
    return [list $name "/usr/bin/$name" {} {} 0 $time {} 1 {}]
}
proc fields {name} {
    return [list $name "/usr/bin/$name" {} {} 0 0 {} 1 {}]
}
proc fileText {} {
    if {![file exists $::tmp]} { return "" }
    set f [open $::tmp r]
    set text [read $f]
    close $f
    return $text
}

puts "the shortcuts start unassigned"
array set ::enginecfg::shortcut {1 "" 2 ""}
array set ::enginewin_lastengine {}
checkEq "no F2 engine" [::enginecfg::shortcutEngine 1] {}
checkEq "no F3 engine" [::enginecfg::shortcutEngine 2] {}
checkEq "no label for an unassigned preset" [::enginecfg::shortcutOf A] {}

puts "a preset is assigned by name"
set ::engines(list) [list [entry A] [entry B]]
::enginecfg::assignShortcut 1 A
checkEq "F2 starts it" [::enginecfg::shortcutEngine 1] A
checkEq "the preset knows its key" [::enginecfg::shortcutOf A] 1
checkEq "the key's label" [::enginecfg::shortcutLabel 1] F2
checkEq "F3 is still free" [::enginecfg::shortcutEngine 2] {}

puts "one preset per window"
::enginecfg::assignShortcut 2 A
checkEq "moving it to F3 frees F2" [::enginecfg::shortcutEngine 1] {}
checkEq "and F3 starts it" [::enginecfg::shortcutEngine 2] A
::enginecfg::assignShortcut 1 B
checkEq "assigning another preset to F2 does not disturb F3" \
    [::enginecfg::shortcutEngine 2] A
::enginecfg::assignShortcut 1 A
checkEq "assigning a preset already on F3 takes it away from F3" \
    [::enginecfg::shortcutEngine 2] {}
checkEq "and leaves it on F2" [::enginecfg::shortcutEngine 1] A

puts "clearing"
::enginecfg::clearShortcut A
checkEq "a cleared preset starts nowhere" [::enginecfg::shortcutOf A] {}
checkEq "F2 is empty" [::enginecfg::shortcutEngine 1] {}
::enginecfg::clearShortcut NotThere
checkEq "clearing an unknown name is harmless" [::enginecfg::shortcutEngine 1] {}

puts "a missing preset is not started"
::enginecfg::assignShortcut 1 Gone
checkEq "an assignment to a name not in the list reads as empty" \
    [::enginecfg::shortcutEngine 1] {}
::enginecfg::clearShortcut Gone

puts "a window opens its assigned preset before its remembered one"
set ::engines(list) [list [entry A] [entry B]]
::enginecfg::assignShortcut 1 A
checkEq "F2 ignores the last preset" [::enginecfg::windowEngine 1 B] A
checkEq "an unassigned window keeps its last preset" \
    [::enginecfg::windowEngine 2 B] B
checkEq "so does a window past the two shortcuts" \
    [::enginecfg::windowEngine 3 B] B
::enginecfg::clearShortcut A
checkEq "with no assignment the last preset is used" \
    [::enginecfg::windowEngine 1 B] B

puts "a rename carries the assignment and the remembered engine"
set ::enginecfg::shortcut(1) A
set ::enginewin_lastengine(1) A
set ::enginewin_lastengine(2) B
set ::engines(list) [list [entry A] [entry B]]
::enginecfg::renameRefs A C
checkEq "the shortcut follows the new name" [::enginecfg::shortcutOf C] 1
checkEq "and the old name is not left behind" [::enginecfg::shortcutOf A] {}
checkEq "the window memory follows too" $::enginewin_lastengine(1) C
checkEq "another window is untouched" $::enginewin_lastengine(2) B

puts "a rename through ::enginecfg::rename does the same"
set ::engines(list) [list [entry A] [entry B]]
set ::enginecfg::shortcut(1) A
set ::enginewin_lastengine(1) A
checkEq "the rename returns the new name" [call {::enginecfg::rename A Renamed}] Renamed
checkEq "F2 follows" [::enginecfg::shortcutEngine 1] Renamed
checkEq "the window memory follows" $::enginewin_lastengine(1) Renamed
checkEq "the list has the new name" [call {lindex [::enginecfg::get Renamed] 0}] Renamed
checkEq "and not the old one" [call {::enginecfg::get A}] {}

puts "a delete drops both references"
set ::engines(list) [list [entry A] [entry B]]
set ::enginecfg::shortcut(1) A
set ::enginewin_lastengine(1) A
set ::enginewin_lastengine(2) B
checkEq "delete writes" [::enginelist::delete 0] true
checkEq "the shortcut is free" [::enginecfg::shortcutEngine 1] {}
checkEq "the window memory is cleared" $::enginewin_lastengine(1) {}
checkEq "the other window keeps its engine" $::enginewin_lastengine(2) B

puts "the edit dialog's shortcut is applied with the rest of the edit"
set ::engines(list) [list [entry A] [entry B]]
::enginecfg::write
checkEq "F2 set while editing A" [::enginelist::saveEdit 0 [fields A] 1] true
checkEq "A is on F2" [::enginecfg::shortcutEngine 1] A
checkEq "the file was written" [expr {[string first "Name A" [fileText]] >= 0}] 1
checkEq "F2 set while editing B takes it from A" \
    [::enginelist::saveEdit 1 [fields B] 1] true
checkEq "B is on F2" [::enginecfg::shortcutEngine 1] B
checkEq "A is no longer on a shortcut" [::enginecfg::shortcutOf A] {}

set ::enginewin_lastengine(1) B
checkEq "a rename with F2 selected keeps F2" \
    [::enginelist::saveEdit 1 [fields {B Renamed}] 1] true
checkEq "F2 starts the renamed preset" [::enginecfg::shortcutEngine 1] {B Renamed}
checkEq "the window memory follows the dialog's rename" \
    $::enginewin_lastengine(1) {B Renamed}

checkEq "editing a preset with None clears its key" \
    [::enginelist::saveEdit 1 [fields {B Renamed}] none] true
checkEq "F2 is now free" [::enginecfg::shortcutEngine 1] {}

set ::engines(list) [list [entry A] [entry B]]
::enginecfg::assignShortcut 2 A
checkEq "moving a preset to F2 through the dialog" \
    [::enginelist::saveEdit 0 [fields A] 1] true
checkEq "it is on F2" [::enginecfg::shortcutEngine 1] A
checkEq "and has left F3" [::enginecfg::shortcutEngine 2] {}
checkEq "the other preset stays unassigned" [::enginecfg::shortcutOf B] {}
set ::answer no
checkEq "a refused edit does not move the assignment" \
    [::enginelist::saveEdit 1 [fields A] 1] false
checkEq "so F2 still starts A" [::enginecfg::shortcutEngine 1] A
set ::answer yes

puts "the dialog exposes the assignment"
set fh [open $enginelistFile r]
set dialogSrc [read $fh]
close $fh
check "the list has a shortcut column" \
    [string match {*columns { "Name" "Key" "Elo" "Time" }*} $dialogSrc]
check "headed by the translated label" \
    [string match {*heading Key -text \[tr EngineShortcut\]*} $dialogSrc]
check "the column shows the preset's key" \
    [string match {*shortcutLabel \[::enginecfg::shortcutOf $name\]*} $dialogSrc]
check "the edit dialog has a shortcut radio group" \
    [string match {*radiobutton $f.shortcut.f2*} $dialogSrc]
check "with F2, F3 and None" \
    [expr {[string match {*variable engines(newShortcut) -value none*} $dialogSrc] &&
            [string match {*variable engines(newShortcut) -value 1*} $dialogSrc] &&
            [string match {*variable engines(newShortcut) -value 2*} $dialogSrc]}]
check "it passes the choice to saveEdit" \
    [expr {[string first {$engines(newShortcut)]} $dialogSrc] >= 0}]

# Where a window takes its engine from: the assignment first, then the
# remembered name. The engine window itself needs Tk, so this checks the source
# for the call that makes the assignment win.
set engineSrc [file join $root tcl windows engine.tcl]
set fh [open $engineSrc r]
set winSrc [read $fh]
close $fh
check "the engine window asks for an assigned preset" \
    [string match {*\[::enginecfg::windowEngine $id $::enginewin_lastengine($id)\]*} $winSrc]

# The Tools menu names the engine each shortcut starts, at the point of use.
set fh [open [file join $root tcl menus.tcl] r]
set menusSrc [read $fh]
close $fh
check "the menu entries are addressable" \
    [string match {*set ::menuEngineStart(1)*} $menusSrc]
check "the labels are repainted from the assignment" \
    [string match {*set name \[::enginecfg::shortcutEngine $id\]*} $menusSrc]
check "and after a language change" \
    [string match {*::menus::engineShortcutLabels*} $menusSrc]

file delete -force $::tmp

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
