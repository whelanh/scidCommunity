#!/usr/bin/env tclsh
# Copyright (C) 2026
# SPDX-License-Identifier: GPL-2.0-or-later
#
# subcommand_prefix.tcl -- no sc_* subcommand abbreviation may be ambiguous.
#
#   tclsh tests/tcl/subcommand_prefix.tcl
#
# The C++ sc_* commands dispatch on argv[1] with strUniqueMatch(), which accepts
# unique abbreviations. The Tcl code relies on this: it calls e.g. "sc_game tag"
# as an abbreviation of the "tags" subcommand. If a second subcommand ever shares
# that prefix (as "tagorder" did in v5.1.4.64, breaking every "sc_game tag get"
# call), the abbreviation becomes ambiguous and strUniqueMatch() returns -1.
#
# This harness reads the C++ dispatch tables and the Tcl call sites, and fails if
# any subcommand token the Tcl actually uses is an ambiguous abbreviation.

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

proc readText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation auto
    set text [read $f]
    close $f
    return $text
}

# ------------------------------------------------------------------ C++ side --
set cpp ""
foreach f {src/tkscid.cpp src/sc_base.cpp src/sc_filter.cpp} {
    append cpp "\n" [readText [file join $root $f]]
}

set term "};"

# Every "static const char *NAME[] = { ... };" table: {name entries startPos}.
set header {static\s+const\s+char\s*\*\s*(\w+)\s*\[\]\s*=\s*\{}
set tables {}
foreach {full nameRange} [regexp -all -inline -indices $header $cpp] {
    set nm [string range $cpp {*}$nameRange]
    set bodyStart [expr {[lindex $full 1] + 1}]
    set tClose [string first $term $cpp $bodyStart]
    if {$tClose < 0} { continue }
    set body [string range $cpp $bodyStart [expr {$tClose - 1}]]
    set entries {}
    foreach {fm g} [regexp -all -inline {"([^"]*)"} $body] {
        if {$g ne "" && $g ne "nullptr"} { lappend entries $g }
    }
    if {[llength $entries] > 1} { lappend tables [list $nm $entries [lindex $full 0]] }
}

proc enclosingCmd {cpp pos} {
    set pre [string range $cpp 0 [expr {$pos - 1}]]
    set cmd ""
    foreach {m g} [regexp -all -inline -indices {sc_([A-Za-z0-9_]+)\s*\(} $pre] {
        set cmd [string range $pre [lindex $g 0] [lindex $g 1]]
    }
    return $cmd
}

# Every argv[1] dispatch site: {cmd matchKind tblName pos}.
set sites {}
foreach {re kind} {
    {strUniqueMatch\s*\(\s*argv\[1\]\s*,\s*(\w+)\s*\)} unique
    {strExactMatch\s*\(\s*argv\[1\]\s*,\s*(\w+)\s*\)} exact
} {
    foreach {m g} [regexp -all -inline -indices $re $cpp] {
        set tblName [string range $cpp [lindex $g 0] [lindex $g 1]]
        set pos [lindex $m 0]
        set cmd [enclosingCmd $cpp $pos]
        if {$cmd ne ""} {
            # sc_filter's real dispatch lives in the legacy sc_filter_old; the
            # Tcl command is still "sc_filter".
            regsub {_old$} $cmd "" cmd
            lappend sites [list sc_$cmd $kind $tblName $pos]
        }
    }
}

# Resolve each command to its dispatch table: the table of that name closest
# before the strUniqueMatch/strExactMatch call.
set dispatch {}
foreach site $sites {
    lassign $site cmd kind tblName pos
    set bestPos -1
    set bestEntries {}
    foreach t $tables {
        lassign $t tn entries tpos
        if {$tn eq $tblName && $tpos < $pos && $tpos > $bestPos} {
            set bestPos $tpos
            set bestEntries $entries
        }
    }
    if {$bestPos >= 0 && [llength $bestEntries] > 1} {
        dict set dispatch $cmd [list $kind $bestEntries]
    }
}

# ------------------------------------------------------------------ Tcl side --
# Every "sc_<cmd> <token>" call in the Tcl sources (comment-only lines skipped).
proc tclFiles {dir} {
    set out {}
    foreach name [lsort [glob -nocomplain -directory $dir *]] {
        if {[file isdirectory $name]} {
            foreach f [tclFiles $name] { lappend out $f }
        } elseif {[string equal [file extension $name] ".tcl"]} {
            lappend out $name
        }
    }
    return $out
}

set usages {}
foreach f [tclFiles [file join $root tcl]] {
    foreach line [split [readText $f] "\n"] {
        if {[regexp {^\s*#} $line]} { continue }
        foreach {fm cmd token} [regexp -all -inline {sc_([A-Za-z_][A-Za-z0-9_]*)\s+([A-Za-z_][A-Za-z0-9_]*)} $line] {
            lappend usages [list $cmd $token]
        }
    }
}

# ------------------------------------------------------------------ check ----
# For each unique-match command, every Tcl subcommand token must be an exact
# match or a unique abbreviation. (A token that matches nothing is not a
# subcommand - a comment fragment or a variable - and is skipped.)
set ambiguous {}
foreach u [lsort -unique $usages] {
    lassign $u cmd token
    if {![dict exists $dispatch sc_$cmd]} { continue }
    lassign [dict get $dispatch sc_$cmd] kind entries
    if {$kind ne "unique"} { continue }
    if {[lsearch -exact $entries $token] >= 0} { continue }
    set hits [lsearch -all -inline $entries "$token*"]
    set n [llength $hits]
    if {$n >= 2} { lappend ambiguous "sc_$cmd $token (matches [list $hits])" }
}

check "no Tcl sc_* subcommand abbreviation is ambiguous" \
    [expr {[llength $ambiguous] == 0}] [join $ambiguous "; "]

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
