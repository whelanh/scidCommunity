#!/usr/bin/env tclsh
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# pgn_format_prefs.tcl -- the PGN format preferences reach the C++ writers.
#
#   tclsh tests/tcl/pgn_format_prefs.tcl
#
# Discussion #460 added the global "Add spaces after move number" preference,
# stored in ::pgn::moveNumberSpaces. Issue #534 showed it has to reach more
# than the exporters: compacting a PGN database rewrites every game with the
# PGN codec, so the C++ writers must be told about it as well. The same holds
# for the tag-order preference and for the PGN line endings -- a compacted
# PGN must look like an exported one.
#
# Each value travels through a small proc in tcl/options.tcl ("sc_game
# setTagOrder", "setMoveNumSpace", "setPgnEol") and, for the two variables the
# preferences dialog edits, a variable trace. The trace is what keeps every
# checkbutton and combobox in step, so no callback can be forgotten.
# tcl/options.tcl cannot be sourced on its own, so these procs and lines are
# lifted out of it by name; moving or renaming them fails the extraction
# loudly rather than passing silently.

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

set src [file join $root tcl options.tcl]
set text [readText $src]
set lines [split $text "\n"]

# The whole proc at the line that declares it, found by its name.
proc extractProc {lines name} {
    set start -1
    for {set i 0} {$i < [llength $lines]} {incr i} {
        if {[string match "proc $name *" [lindex $lines $i]]} {
            set start $i
            break
        }
    }
    if {$start < 0} { return "" }
    set procText ""
    for {set i $start} {$i < [llength $lines]} {incr i} {
        append procText [lindex $lines $i] "\n"
        if {[info complete $procText]} break
    }
    return $procText
}

proc extractLine {lines wanted} {
    foreach line $lines {
        if {$line eq $wanted} { return 1 }
    }
    return 0
}

foreach name {::pgn::applyTagOrder ::pgn::applyMoveNumSpace ::pgn::applyPgnEol} {
    if {[extractProc $lines $name] eq ""} {
        puts "FAIL cannot find $name in $src"
        exit 1
    }
}
foreach {label line} [list \
        "the tag-order startup call" "::pgn::applyTagOrder" \
        "the move-number trace" \
        "trace add variable ::pgn::moveNumberSpaces write ::pgn::applyMoveNumSpace" \
        "the move-number startup call" "::pgn::applyMoveNumSpace" \
        "the line-ending trace" \
        "trace add variable ::exportFlags(eol) write ::pgn::applyPgnEol" \
        "the line-ending startup call" "::pgn::applyPgnEol"] {
    if {![extractLine $lines $line]} {
        puts "FAIL cannot find $label in $src"
        exit 1
    }
}

# -------------------------------------------------------------------- set-up --
namespace eval ::pgn {}
set ::pgn::tagOrder {WhiteElo BlackElo ECO EventDate ScidFlags Others}
set ::pgn::sortOtherTags 0
set ::pgn::moveNumberSpaces 0
array set ::exportFlags {eol native}
set ::calls {}
proc sc_game {args} { lappend ::calls $args }

eval [extractProc $lines ::pgn::applyTagOrder]
eval [extractProc $lines ::pgn::applyMoveNumSpace]
eval [extractProc $lines ::pgn::applyPgnEol]
eval "trace add variable ::pgn::moveNumberSpaces write ::pgn::applyMoveNumSpace"
eval "trace add variable ::exportFlags(eol) write ::pgn::applyPgnEol"

# --------------------------------------------------------------------- tests --
set ::calls {}
::pgn::applyTagOrder
checkEq "the tag order reaches the writer" $::calls \
    {{setTagOrder {WhiteElo BlackElo ECO EventDate ScidFlags Others} 0}}

set ::calls {}
::pgn::applyMoveNumSpace
checkEq "the startup move-number preference is applied" $::calls \
    {{setMoveNumSpace 0}}
set ::calls {}
set ::pgn::moveNumberSpaces 1
checkEq "a write applies the new move-number value" $::calls \
    {{setMoveNumSpace 1}}

set ::calls {}
::pgn::applyPgnEol
checkEq "the startup line ending is applied" $::calls {{setPgnEol native}}
set ::calls {}
set ::exportFlags(eol) crlf
checkEq "the export dialog's choice applies crlf" $::calls {{setPgnEol crlf}}
set ::calls {}
set ::exportFlags(eol) lf
checkEq "and applies lf" $::calls {{setPgnEol lf}}

# Every UI toggle edits a traced variable, so no callback has to remember to
# call the apply procs itself.
set prefs [readText [file join $root tcl windows preferences.tcl]]
check "Preferences > Moves edits the traced move-number variable" \
    [expr {[string first "-variable ::pgn::moveNumberSpaces" $prefs] >= 0}]

set pgnWin [readText [file join $root tcl windows pgn.tcl]]
check "the PGN window menu edits the same variable" \
    [expr {[string first "-variable ::pgn::moveNumberSpaces" $pgnWin] >= 0}]

set endTcl [readText [file join $root tcl end.tcl]]
check "the export dialog writes the traced line-ending variable" \
    [expr {[string first {set exportFlags(eol)} $endTcl] >= 0}]
check "Preferences > PGN Export writes the same variable" \
    [expr {[string first {set ::exportFlags(eol)} $prefs] >= 0}]

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
