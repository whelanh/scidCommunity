#!/usr/bin/env tclsh
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# language_catalogues.tcl -- the bookkeeping every interface language needs.
#
#   tclsh tests/tcl/language_catalogues.tcl
#
# The translation files themselves are checked for key coverage by the move
# label and review UI harnesses. This one checks that the files and the code
# agree on which languages exist: a catalogue added to tcl/lang but not to
# addLanguage never appears in the Language menu, and a file added under a name
# the registry does not use is never loaded. The language list is read from
# addLanguage, so neither this harness nor the others need editing when a
# language is added. The rest of the per-language wiring (piece maps, the
# sc_info switches, the maintenance tools) is listed in
# docs/ADDING_A_LANGUAGE.md.

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
source [file join $root tests tcl lang_registry.tcl]
proc readText {path} {
    set fh [open $path r]
    fconfigure $fh -encoding utf-8 -translation auto
    set text [read $fh]
    close $fh
    return $text
}
set langDir [file join $root tcl lang]

puts "the catalogue list"
set catalogues [languageCatalogues $root]
check "addLanguage lists the languages" [expr {[llength $catalogues] > 1}]
array set seenLetter {}
array set seenFile {}
foreach pair $catalogues {
    lassign $pair letter file
    check "letter $letter is used once" [expr {![info exists seenLetter($letter)]}]
    check "file $file is listed once" [expr {![info exists seenFile($file)]}]
    set seenLetter($letter) 1
    set seenFile($file) 1
}

puts "\nthe catalogues on disk"
set langTools {checklangs.tcl propagatelang.tcl removedeadlang.tcl removetoken.tcl}
set onDisk {}
foreach path [glob -nocomplain -directory $langDir *.tcl] {
    set name [file tail $path]
    if {$name in $langTools} { continue }
    lappend onDisk $name
}
checkEq "every catalogue on disk is registered" [lsort $onDisk] [languageFiles $root]

puts "\nevery catalogue is a language table"
foreach pair $catalogues {
    lassign $pair letter file
    set path [file join $langDir $file]
    if {![file readable $path]} {
        check "$file exists" 0
        continue
    }
    set text [readText $path]
    check "$file defines setLanguage_$letter" \
        [expr {[string first "proc setLanguage_$letter " $text] >= 0}]
    check "$file has $letter translation entries" \
        [regexp -all -- "(?:menuText|translate|helpMsg) $letter " $text]
}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
