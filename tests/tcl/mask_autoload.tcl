#!/usr/bin/env tclsh
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# mask_autoload.tcl -- the Tree window's "Auto-load last mask" option (#486).
#
#   tclsh tests/tcl/mask_autoload.tcl
#
# tcl/windows/tree.tcl needs Tk, so that file cannot be sourced here. The
# procedures under test are lifted out of it by name, the way options_write.tcl
# lifts options.finishWrite, and their Tk/Scid calls are stubbed.
#
# The behaviour that matters is at open time: an automatic open must use the
# first recent mask, must not show a modal error when the file has gone or is
# damaged, and must not stop the tree window from refreshing.

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
set treeFile [file join $root tcl windows tree.tcl]
set fh [open $treeFile r]
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

set readText [extractProc $lines ::tree::mask::safeReadMaskFile]
set addText  [extractProc $lines ::tree::mask::addRecent]
set openText [extractProc $lines ::tree::mask::open]
check "safeReadMaskFile was extracted" [expr {$readText ne ""}]
check "addRecent was extracted" [expr {$addText ne ""}]
check "open was extracted" [expr {$openText ne ""}]
if {$readText eq "" || $addText eq "" || $openText eq ""} {
    puts "\n$checks checks, $fails failures"
    exit 1
}

# -------------------------------------------------------------------- set-up --
namespace eval ::tree::mask {
    array set mask {}
    set maskSerialized {}
    set maskFile ""
    set dirty 0
    set maxRecent 10
    set recentMask {}
}

proc ::tree::mask::askForSave {} {}
proc ::tree::refresh {args} { incr ::refreshCalls }
proc winfo {sub args} { return 0 }
proc sc_base {args} { return {} }
proc tk_messageBox {args} {
    lappend ::dialogs $args
    return ok
}

set ::dialogs {}
set ::refreshCalls 0
eval $readText
eval $addText
eval $openText

set dir [file join [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] "mask_autoload_[pid]"]
catch {file delete -force $dir}
file mkdir $dir
proc fileWithMask {path} {
    set fen "8/8/8/8/8/8/8/K6k w - - 0 1"
    array set m [list $fen [list [list e4 "  " white "" tb_empty tb_empty] {}]]
    set fh [open $path w]
    puts -nonewline $fh "set ::tree::mask::maskSerialized [list [array get m]]"
    close $fh
}

set maskA [file join $dir a.stm]
set maskB [file join $dir b.stm]
set missing [file join $dir gone.stm]
set corrupt [file join $dir corrupt.stm]
fileWithMask $maskA
fileWithMask $maskB
set fh [open $corrupt w]
puts -nonewline $fh "not a mask file"
close $fh

proc resetMaskState {recent} {
    array unset ::tree::mask::mask
    array set ::tree::mask::mask {}
    set ::tree::mask::maskSerialized {}
    set ::tree::mask::maskFile ""
    set ::tree::mask::dirty 0
    set ::tree::mask::recentMask $recent
    set ::dialogs {}
    set ::refreshCalls 0
}

# --------------------------------------------------- the most recent is first --
puts "\n== an automatic open uses the mask that was used last =="
resetMaskState [list $maskB $maskA]
set rc [::tree::mask::open $maskA autoLoad]
checkEq "the open succeeds" $rc 1
checkEq "the mask becomes the open one" $::tree::mask::maskFile $maskA
checkEq "it moves to the front of the recent list" [lindex $::tree::mask::recentMask 0] $maskA
checkEq "it is not listed twice" [llength [lsearch -all -exact $::tree::mask::recentMask $maskA]] 1
checkEq "the tree is refreshed" $::refreshCalls 1
checkEq "no dialog is shown" $::dialogs {}

# ------------------------------------------------------- a vanished mask file --
puts "\n== a mask that has gone does not stop the tree window =="
resetMaskState [list $missing $maskA]
# A failed open clears the mask data, so it must not leave the old content
# marked as unsaved: the next tree window would ask to save an empty mask.
set ::tree::mask::dirty 1
set rc [::tree::mask::open $missing autoLoad]
checkEq "the automatic open reports failure" $rc 0
checkEq "no mask is left open" $::tree::mask::maskFile ""
checkEq "the cleared mask is not left dirty" $::tree::mask::dirty 0
checkEq "no modal error is shown" $::dialogs {}

# ---------------------------------------------------------- a damaged mask file --
puts "\n== a damaged mask does not stop the tree window =="
resetMaskState [list $corrupt $maskA]
set rc [::tree::mask::open $corrupt autoLoad]
checkEq "the automatic open reports failure" $rc 0
checkEq "no mask is left open" $::tree::mask::maskFile ""
checkEq "no modal error is shown" $::dialogs {}

# A manual open still tells the user what went wrong.
puts "\n== opening the same damaged file by hand still reports it =="
resetMaskState [list $corrupt $maskA]
set rc [::tree::mask::open $corrupt]
checkEq "the manual open reports failure" $rc 0
checkEq "one error dialog is shown" [llength $::dialogs] 1

# ---------------------------------------------------------------- recent list --
puts "\n== the recent list keeps the last-used order =="
resetMaskState {}
set ::tree::mask::maxRecent 3
::tree::mask::addRecent $maskA
::tree::mask::addRecent $maskB
::tree::mask::addRecent $maskA
checkEq "the last mask added is first" [lindex $::tree::mask::recentMask 0] $maskA
checkEq "the earlier mask follows" [lindex $::tree::mask::recentMask 1] $maskB
checkEq "the list has no duplicate" [llength $::tree::mask::recentMask] 2
::tree::mask::addRecent "c.stm"
::tree::mask::addRecent "d.stm"
checkEq "the list is capped at maxRecent" [llength $::tree::mask::recentMask] 3
checkEq "the oldest entry was dropped" [lsearch -exact $::tree::mask::recentMask $maskB] -1
checkEq "the newest entries are kept in order" [lindex $::tree::mask::recentMask 2] $maskA

# ------------------------------------------------------------------- wiring --
puts "\n== the option and its saved name are wired in =="
set optionHits [lsearch -glob $lines {*menu.opt add checkbutton -label TreeOptAutoLoadMask*}]
check "the Tree Options menu has the checkbutton" [expr {$optionHits != -1}]
set autoOpenHits [lsearch -glob $lines {*::tree::mask::open $lastMask autoLoad*}]
check "the Tree window opens the last mask with autoLoad" [expr {$autoOpenHits != -1}]

set optionsFile [file join $root tcl options.tcl]
set fh [open $optionsFile r]
set optionLines [split [read $fh] "\n"]
close $fh
set savedHits [lsearch -glob $optionLines {*::tree::mask::autoLoadMask*}]
check "the option is written to the options file" [expr {$savedHits != -1}]

set englishFile [file join $root tcl lang english.tcl]
set fh [open $englishFile r]
set englishLines [split [read $fh] "\n"]
close $fh
set labelHits [lsearch -glob $englishLines {*menuText E TreeOptAutoLoadMask*}]
check "the label has an English translation tag" [expr {$labelHits != -1}]

file delete -force $dir
puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
