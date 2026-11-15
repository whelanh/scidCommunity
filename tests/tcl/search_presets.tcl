#!/usr/bin/env tclsh
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# search_presets.tcl -- the Header search's saved presets.
#
#   tclsh tests/tcl/search_presets.tcl
#
# tcl/search/header.tcl needs Tk and Scid at load time (::options.store,
# sc_info limit elo), so the file cannot be sourced here. The three data
# procedures are lifted out of it by name, the way mask_autoload.tcl lifts the
# tree mask's procedures, and the widgets they would touch are never built.
#
# What matters is the data: a preset stores every search field and both array
# fields, loading it restores them and clears a field the preset does not
# carry, and deleting it takes the name out of the menu's list.

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
set headerFile [file join $root tcl search header.tcl]
set boardFile  [file join $root tcl search board.tcl]
set fh [open $headerFile r]
set lines [split [read $fh] "\n"]
close $fh

# --------------------------------------------------------------- extraction --
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
check "preset_save was extracted"   [expr {$saveText ne ""}]
check "preset_load was extracted"   [expr {$loadText ne ""}]
check "preset_delete was extracted" [expr {$deleteText ne ""}]
if {$saveText eq "" || $loadText eq "" || $deleteText eq ""} {
    puts "\n$checks checks, $fails failures"
    exit 1
}
# The procedures are namespace-qualified; the namespace must exist first.
namespace eval ::search::header {}

eval $saveText
eval $loadText
eval $deleteText

# -------------------------------------------------------------------- set-up --
# The variables a preset carries. The names are the dialog's own, and the
# storage keeps its historical "Layout" names.
set ::searchHeader_Layouts {}
array set ::searchHeader_Data {}
array set ::sHeaderFlags {}
array set ::sTitles {}
array set ::sPgntext {}

proc resetFields {} {
    foreach {var value} {
        sWhite {} sBlack {} sEvent {} sSite {} sRound {} sAnnotated 0
        sDateMin {} sDateMax {} sEventDateMin {} sEventDateMax {}
        sWhiteEloMin {} sWhiteEloMax {} sBlackEloMin {} sBlackEloMax {}
        sEloDiffMin {} sEloDiffMax {} sGlMin {} sGlMax {}
        sGnumMin {} sGnumMax {} sEcoMin {} sEcoMax {} sEco Yes
        sSideToMoveW w sSideToMoveB b
        sResWin {} sResLoss {} sResDraw {} sResOther {}
        sTagName Annotator sTagValue {} sVariantStd 1 sVariant960 1 sIgnoreCol No
    } {
        set ::$var $value
    }
    array unset ::sPgntext ; array set ::sPgntext {1 {} 2 {} 3 {}}
    array unset ::sHeaderFlags ; array set ::sHeaderFlags {StdStart both Promotions both}
    array unset ::sTitles ; array set ::sTitles {w:gm 1 b:gm 1}
}

# ------------------------------------------------------- save and load round --
resetFields
set ::sWhite "Kasparov, G"
set ::sBlack "Karpov, A"
set ::sWhiteEloMin 2600
set ::sDateMin "1984.01.01"
set ::sResWin 1
set ::sTagName "Annotator"
set ::sTagValue "boob"
set ::sPgntext(2) "1. e4 e5"
set ::sHeaderFlags(Promotions) "white"
set ::sTitles(b:gm) 0

::search::header::preset_save "World Championship"
checkEq "save adds the name to the menu list" [lindex $::searchHeader_Layouts 0] "World Championship"
set wcName "World Championship"
check "save stores data for the name" [expr {[info exists ::searchHeader_Data($wcName)]}]

resetFields
checkEq "the fields were reset before loading" $::sWhite ""

::search::header::preset_load "World Championship"
checkEq "load restores a string field" $::sWhite "Kasparov, G"
checkEq "load restores the opponent" $::sBlack "Karpov, A"
checkEq "load restores an Elo bound" $::sWhiteEloMin "2600"
checkEq "load restores a date bound" $::sDateMin "1984.01.01"
checkEq "load restores a result flag" $::sResWin "1"
checkEq "load restores the tag name" $::sTagName "Annotator"
checkEq "load restores the tag value" $::sTagValue "boob"
checkEq "load restores an array field" $::sPgntext(2) "1. e4 e5"
checkEq "load restores a header flag" $::sHeaderFlags(Promotions) "white"
checkEq "load restores a title flag" $::sTitles(b:gm) "0"

# ----------------------------------------------------------------- name list --
::search::header::preset_save "World Championship"
checkEq "re-saving a name does not duplicate it" [llength $::searchHeader_Layouts] 1

resetFields
set ::sWhite "Fischer, R"
::search::header::preset_save "Candidates"
check "a second preset is listed" \
    [expr {[lsearch -exact $::searchHeader_Layouts "Candidates"] >= 0}]

# --------------------------------------------- a field the preset does not carry --
resetFields
set ::sWhite "Tal, M"
set ::sBlack "Botvinnik, M"
::search::header::preset_save "Partial"
# Drop the opponent from the stored data, the way a preset written by a version
# without that field would arrive.
set kept {}
foreach {k v} $::searchHeader_Data(Partial) {
    if {$k eq "sBlack"} continue
    lappend kept $k $v
}
set ::searchHeader_Data(Partial) $kept

set ::sBlack "Stale, Value"
::search::header::preset_load "Partial"
checkEq "a field missing from the preset is cleared" $::sBlack ""
checkEq "a field the preset carries is still loaded" $::sWhite "Tal, M"

# ------------------------------------------------------------ array clearing --
resetFields
array set ::sHeaderFlags {StdStart both Promotions both NoveltyFlag both}
::search::header::preset_save "Flags"
array unset ::sHeaderFlags
array set ::sHeaderFlags {StdStart both Promotions both NoveltyFlag both ExtraFlag both}
::search::header::preset_load "Flags"
check "an array key the preset does not carry is gone" [expr {![info exists ::sHeaderFlags(ExtraFlag)]}]
checkEq "an array key the preset carries survives" $::sHeaderFlags(NoveltyFlag) "both"

# -------------------------------------------------------------------- delete --
set before $::searchHeader_Layouts
::search::header::preset_delete "Candidates"
check "delete removes the data" [expr {![info exists ::searchHeader_Data(Candidates)]}]
check "delete removes the name" \
    [expr {[lsearch -exact $::searchHeader_Layouts "Candidates"] == -1}]
checkEq "delete leaves the other names alone" $::searchHeader_Layouts \
    [lreplace $before [lsearch -exact $before "Candidates"] [lsearch -exact $before "Candidates"]]

resetFields
set ::sWhite "Kept"
::search::header::preset_load "Candidates"
checkEq "loading a deleted preset changes nothing" $::sWhite "Kept"

# ------------------------------------------------------- the interface wiring --
# The menu the search window builds is the presets menu, the old disabled Save
# button and its empty stub are gone, and the label is a translation key.
set bf [open $boardFile r]
set board [read $bf]
close $bf
check "the search window builds a Presets menubutton" \
    [expr {[string first {ttk::menubutton $w.buttons.presets -text [::tr Presets]} $board] >= 0}]
check "the disabled Save button is gone" \
    [expr {![string match "*-state disabled*" $board]}]
check "the empty save_ stub is gone" \
    [expr {![string match "*proc ::search::save_*" $board]}]

set ef [open [file join $root tcl lang english.tcl] r]
set english [read $ef]
close $ef
foreach key {Presets SavePreset PresetName} {
    check "english.tcl carries the $key key" \
        [string match "*translate E $key *" $english]
}

puts "\n$checks checks, $fails failures"
if {$fails} { exit 1 }
exit 0
