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
#   * a delete drops the assignment; an already-open window keeps its live preset.
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

puts "the keys are configurable"
checkEq "the default first key" [::enginecfg::keySequence 1] F2
checkEq "the default second key" [::enginecfg::keySequence 2] F3
checkEq "a function key needs no rewriting" [::enginecfg::keyFromEvent F5 0] F5
checkEq "Control is recorded from the state" [::enginecfg::keyFromEvent 2 4] Control-2
checkEq "Shift is recorded too" [::enginecfg::keyFromEvent A 5] Control-Shift-A
checkEq "Alt is Tk's Mod1" [::enginecfg::keyFromEvent a 8] Mod1-a
checkEq "a bare modifier is not a key" [::enginecfg::keyFromEvent Shift_L 1] {}
checkEq "a Windows/Super combo is not captured" [::enginecfg::keyFromEvent F5 64] {}
checkEq "a written Ctrl+2 becomes Tk's spelling" \
    [::enginecfg::normalizeKey {Ctrl+2}] Control-2
checkEq "a written <F5> loses its brackets" [::enginecfg::normalizeKey {<F5>}] F5
checkEq "a written Alt becomes Mod1" [::enginecfg::normalizeKey {Alt+2}] Mod1-2
checkEq "and is shown as Alt" [::enginecfg::keyLabel 1 {Alt+2}] Alt+2
checkEq "the display form" [::enginecfg::keyLabel 1 Control-Shift-Key-2] Ctrl+Shift+2
check "a function key is safe" [::enginecfg::keyUsable F5]
check "Ctrl+2 is safe" [::enginecfg::keyUsable Control-2]
check "Alt+2 is safe" [::enginecfg::keyUsable Mod1-2]
check "a plain letter is not safe" [expr {![::enginecfg::keyUsable a]}]
check "Ctrl+C is reserved for copying" [::enginecfg::keyReserved Control-c]
check "Ctrl+Z is reserved for undo" [::enginecfg::keyReserved Control-z]
check "Ctrl+K is reserved for kill-line" [::enginecfg::keyReserved Control-k]
check "Ctrl+B is reserved for text navigation" [::enginecfg::keyReserved Control-b]
check "Ctrl+Left is word movement" [::enginecfg::keyReserved Control-Left]
check "Alt+F4 closes the window" [::enginecfg::keyReserved Mod1-F4]
check "F5 is not reserved" [expr {![::enginecfg::keyReserved F5]}]
checkEq "a reserved key is refused" [::enginecfg::setKey 1 Control-c] false
checkEq "a plain letter is refused" [::enginecfg::setKey 1 a] false
checkEq "and the old key is kept" [::enginecfg::keySequence 1] F2
checkEq "changing a key" [::enginecfg::setKey 1 F5] true
checkEq "the sequence follows" [::enginecfg::keySequence 1] F5
checkEq "the display follows" [::enginecfg::keyLabel 1] F5
checkEq "and so does the list column" [::enginecfg::shortcutLabel 1] F5
checkEq "a key written by hand is accepted" [::enginecfg::setKey 2 {Ctrl+2}] true
checkEq "and normalised" [::enginecfg::keySequence 2] Control-2
checkEq "an unknown window has no key" [::enginecfg::setKey 3 F6] false
::enginecfg::resetKeys
checkEq "reset puts the first default back" [::enginecfg::keySequence 1] F2
checkEq "and the second" [::enginecfg::keySequence 2] F3

puts "the platform names its own modifiers"
# tclsh has no tk command, so the harness supplies one: the code path a Mac
# build uses, where Mod1 is Command and Mod2 is Option.
proc tk {args} { return aqua }
checkEq "Command+Option is Mod1+Mod2" [::enginecfg::keyFromEvent F5 24] Mod1-Mod2-F5
checkEq "Mod1 is shown as Command" [::enginecfg::keyLabel 1 Mod1-F5] Cmd+F5
checkEq "Mod2 is shown as Option" [::enginecfg::keyLabel 1 Mod2-F5] Option+F5
check "Option+F5 is accepted" [::enginecfg::keyUsable Mod2-F5]
check "Option+a is text input, not a key" [expr {![::enginecfg::keyUsable Mod2-a]}]
check "Command+Q is reserved by macOS" [::enginecfg::keyReserved Mod1-q]
check "Command+Shift+4 is a screenshot" [::enginecfg::keyReserved Mod1-Shift-4]
check "Command+W closes the window" [::enginecfg::keyReserved Mod1-w]
checkEq "a typed Alt means Option on a Mac" [::enginecfg::normalizeKey {Alt+2}] Mod2-2
checkEq "and Command means Mod1" [::enginecfg::normalizeKey {Cmd+2}] Mod1-2
rename tk {}

puts "a saved key is validated as a whole pattern"
check "a valid pattern" [::enginecfg::keyValid Control-F5]
check "an unknown modifier is not a pattern" [expr {![::enginecfg::keyValid Bogus-F5]}]
set ::enginecfg::key(1) Bogus-F5
checkEq "an invalid saved key falls back to the default" [::enginecfg::keySequence 1] F2
::enginecfg::resetKeys
checkEq "Ctrl+Shift+N is the same physical key as Ctrl+N" \
    [lsort [::enginecfg::keyVariants Control-Shift-N]] \
    [lsort {Control-Shift-N Control-Shift-n Control-N Control-n}]
checkEq "plain Ctrl+n is a different key" [::enginecfg::keyVariants Control-n] Control-n

puts "Windows uses Alt, not Num Lock"
proc tk {args} { return win32 }
checkEq "Num Lock alone is not a modifier" [::enginecfg::keyFromEvent b 8] b
check "and does not make a shortcut" [expr {![::enginecfg::keyUsable [::enginecfg::keyFromEvent b 8]]}]
checkEq "Alt is Tk's Alt pattern" [::enginecfg::keyFromEvent F5 0x20000] Alt-F5
checkEq "Num Lock does not disturb Alt" [::enginecfg::keyFromEvent F5 0x20008] Alt-F5
check "Alt+2 is usable" [::enginecfg::keyUsable Alt-2]
checkEq "a typed Alt stays Alt" [::enginecfg::normalizeKey {Alt+2}] Alt-2
checkEq "a typed Mod1 becomes Alt" [::enginecfg::normalizeKey {Mod1+2}] Alt-2
check "Alt+F4 is reserved on Windows too" [::enginecfg::keyReserved Alt-F4]
rename tk {}

puts "overlapping key patterns are seen"
# A tiny Tk stand-in: the app binds Control-N (uppercase) to nameEditor. The
# conflict must be found for a candidate that is the same physical shortcut.
proc bind {args} {
    if {[lindex $args 0] eq "." && [lindex $args 1] eq "<Control-N>"} {
        return "nameEditor"
    }
    if {[lindex $args 0] eq "Text" && [lindex $args 1] eq "<Control-m>"} {
        return "tkTextInsert"
    }
    return ""
}
proc winfo {args} { return 1 }
check "Ctrl+Shift+N sees the Ctrl+N binding" \
    [expr {![::enginecfg::keyAvailable 2 Control-Shift-N]}]
check "plain Ctrl+n is a different key" [::enginecfg::keyAvailable 2 Control-n]
check "a Text class binding is a conflict" \
    [expr {![::enginecfg::keyAvailable 2 Control-m]}]
rename bind {}
rename winfo {}

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

puts "a delete drops the assignment"
set ::engines(list) [list [entry A] [entry B]]
set ::enginecfg::shortcut(1) A
set ::enginewin_lastengine(1) A
set ::enginewin_lastengine(2) B
checkEq "delete writes" [::enginelist::delete 0] true
checkEq "the shortcut is free" [::enginecfg::shortcutEngine 1] {}
# An engine window may still be running the deleted preset; Game Review reads
# that window's live config, so the per-window memory is left for the fallback
# in ::enginewin::Open (which ignores a name that no longer resolves).
checkEq "the open window's engine is left alone" $::enginewin_lastengine(1) A
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
check "the list has a Shortcut Keys button" \
    [string match {*::enginelist::editKeys*} $dialogSrc]
check "the edit dialog names each window's key" \
    [string match {*format \[tr EngineShortcutWindow\] 1*} $dialogSrc]
check "the capture reads the key event" \
    [string match {*keyFromEvent $sym $state*} $dialogSrc]
set applyAt [string first {::enginelist::applyEdit $index $fields} $dialogSrc]
check "the menu refreshes after the rename is stored" \
    [expr {$applyAt >= 0 &&
            [string first "::enginecfg::refreshShortcutMenus" $dialogSrc $applyAt] > $applyAt}]

# The main window installs the configurable pair rather than a fixed F2/F3.
set fh [open [file join $root tcl keyboard.tcl] r]
set keysSrc [read $fh]
close $fh
check "the main window installs the current engine keys" \
    [string match {*::keyboard::bindEngineShortcuts*} $keysSrc]
check "no fixed F2 line is left" \
    [expr {[string first {bind $w <F2>} $keysSrc] < 0}]
check "editable widgets do not dispatch an engine" \
    [string match {*excludeTextWidget %W; ::enginewin::toggleStartStop*} $keysSrc]
check "reset removes both bindings first" \
    [string match {*proc ::keyboard::rebindEngineShortcuts*} $keysSrc]
set fh [open [file join $root tcl enginecfg.tcl] r]
set enginecfgSrc [read $fh]
close $fh
check "reset calls the two-phase rebind" \
    [string match {*keyboard::rebindEngineShortcuts*} $enginecfgSrc]

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
