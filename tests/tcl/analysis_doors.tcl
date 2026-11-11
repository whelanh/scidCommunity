#!/usr/bin/env tclsh
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# analysis_doors.tcl -- no UI path opens an Analysis window any more.
#
#   tclsh tests/tcl/analysis_doors.tcl
#
# Item 3 of #436 removes the doors: the Tools menu entry, the engine chooser's
# Open path, the saved-layout restore clause, and the spacebar branches. The
# Analysis window's own code stays until #437; this harness only proves that
# nothing in the UI reaches makeAnalysisWin.

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

proc procText {path name} {
    set src [readText $path]
    set from [string first "proc $name " $src]
    if {$from < 0} { return "" }
    set text ""
    foreach line [split [string range $src $from end] "\n"] {
        append text $line "\n"
        if {[info complete $text]} { break }
    }
    return $text
}

# Every .tcl under tcl/, so the "no caller" check cannot miss a new file.
proc tclFiles {dir} {
    set out {}
    foreach f [glob -nocomplain -directory $dir *] {
        if {[file isdirectory $f]} {
            lappend out {*}[tclFiles $f]
        } elseif {[string match *.tcl $f]} {
            lappend out $f
        }
    }
    return $out
}

puts "\nthe UI doors are gone"

set menu [readText [file join $root tcl menus.tcl]]
check "the Tools menu has no Analysis Engine entry" \
    [expr {[string first "-label ToolsAnalysis" $menu] < 0}]

set enginelist [readText [file join $root tcl tools enginelist.tcl]]
check "the engine chooser does not create an Analysis window" \
    [expr {[string first "makeAnalysisWin" $enginelist] < 0}]
check "it opens an Engine Window instead" \
    [expr {[string first "::enginewin::start" $enginelist] >= 0}]
check "and its button is the new label" \
    [expr {[string first "EngineOpenWindow" $enginelist] >= 0}]

set win [readText [file join $root tcl utils win.tcl]]
check "a saved layout does not restore an Analysis window" \
    [expr {[string first "makeAnalysisWin" $win] < 0}]
check "the restore path filters Analysis windows out" \
    [expr {[string first "layoutRestorableWindows" $win] >= 0}]
check "and prunes emptied containers and their sash entries" \
    [expr {[string first "layoutPrune" $win] >= 0}]

set main [readText [file join $root tcl main.tcl]]
check "the spacebar has no Analysis window branch" \
    [expr {[string first "analysisWin" $main] < 0}]
check "the toolbar names an Engine Window" \
    [expr {[string first "ToolsEngineWindow" $main] >= 0}]

# No UI file calls makeAnalysisWin. The definition itself lives in
# analysis.tcl, which #437 deletes, so that one file is excluded.
set callers {}
foreach file [tclFiles [file join $root tcl]] {
    if {[file tail $file] eq "analysis.tcl"} { continue }
    if {[string first "makeAnalysisWin" [readText $file]] >= 0} {
        lappend callers [string range $file [string length $root] end]
    }
}
checkEq "no UI file calls makeAnalysisWin" $callers {}

set english [readText [file join $root tcl lang english.tcl]]
check "the new Open label is in English" \
    [expr {[string first "translate E EngineOpenWindow {Open Engine Window}" $english] >= 0}]
check "and the toolbar's Engine Window label too" \
    [expr {[string first "menuText E ToolsEngineWindow" $english] >= 0}]

puts "\nthe engine chooser opens an Engine Window"

# The proc is lifted out: sourcing enginelist.tcl reads the user's engine file
# and builds dialogs. The stubs are the window and the preset list.
namespace eval enginelist {}
set ::engines(list) {{TestEngine /bin/true}}
set text [procText [file join $root tcl tools enginelist.tcl] \
    ::enginelist::openSelected]
if {$text eq ""} {
    check "::enginelist::openSelected can be lifted" 0
} else {
    eval $text
    proc {.enginelist.list.list} {args} { return 0 }
    set ::destroyed {}
    proc destroy {args} { set ::destroyed [lindex $args 0] }
    proc ::enginelist::setTime {args} {}
    set ::started {}
    namespace eval enginewin {}
    proc ::enginewin::start {id name} { set ::started [list $id $name] }

    ::enginelist::openSelected 1
    checkEq "Open starts an Engine Window for the preset" \
        $::started {{} TestEngine}
    checkEq "and closes the chooser" $::destroyed .enginelist

    set ::started {}
    set ::destroyed {}
    ::enginelist::openSelected 0
    checkEq "a double-click also starts the Engine Window" \
        $::started {{} TestEngine}
    checkEq "and leaves the chooser open" $::destroyed {}
}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
