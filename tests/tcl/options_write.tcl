# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# options_write.tcl -- the atomic half of saving the options file.
#
#   tclsh tests/tcl/options_write.tcl
#
# options.write writes a temporary file and hands it to options.finishWrite,
# which closes it and renames it over the real options file. That rename is
# the reason a failed save cannot destroy settings the user already had: the
# old file is still the one on disk until the new one is complete.
#
# tcl/options.tcl cannot be sourced on its own (it reads the user's options and
# sets up the whole application), so the procedure under test is lifted out of
# it by name. A rename or a move fails the extraction loudly rather than
# passing silently.

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

# --------------------------------------------------------------- extraction --
set root [file normalize [file join [file dirname [info script]] .. ..]]
set src [file join $root tcl options.tcl]
set fh [open $src r]
set lines [split [read $fh] "\n"]
close $fh

set start [lsearch -exact $lines "proc options.finishWrite {fh tmpFile realFile} {"]
if {$start < 0} {
    puts "FAIL cannot find options.finishWrite in $src"
    exit 1
}
set text ""
for {set i $start} {$i < [llength $lines]} {incr i} {
    append text [lindex $lines $i] "\n"
    if {[info complete $text]} break
}
eval $text
check "options.finishWrite was extracted" [expr {[llength [info procs options.finishWrite]] == 1}]

# -------------------------------------------------------------------- set-up --
set dir [file join [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] "options_write_test_[pid]"]
catch {file delete -force $dir}
file mkdir $dir
set real [file join $dir "options.dat"]
set tmp [file join $dir "options.dat.tmp[pid]"]

proc writeFile {path text} {
    set fh [open $path w]
    puts -nonewline $fh $text
    close $fh
}

# ------------------------------------------------------------------- success --
puts "\n== a completed write replaces the file =="
writeFile $real "old settings"
writeFile $tmp "new settings"
set fh [open $tmp a]
set err [options.finishWrite $fh $tmp $real]
checkEq "no error" $err {}
set fh [open $real r]
set content [read $fh]
close $fh
checkEq "the new content is in place" $content "new settings"
check "the temporary file is gone" [expr {![file exists $tmp]}]
if {$::tcl_platform(platform) eq "windows"} {
    puts "  skip permissions are not a POSIX mode on this platform"
} else {
    file stat $real st
    checkEq "the result is owner-only" [format %04o [expr {$st(mode) & 0o777}]] 0600
}

# --------------------------------------------------- every saved name lives --
# options.write writes each name in its list as `set NAME [set NAME]` with no
# guard, so a name with no setter raises "can't read NAME" and takes
# ::file::Exit down with it under the default optionsAutoSave 1 - the user's
# preferences are never written at all. Two names the Analysis window's
# InitDefaultAnnotate used to set were still saved that way after #437 §5
# deleted it, and nothing caught it: this is the check that would have.
puts "\n== every name the writer saves is defined somewhere =="

set i0 [lsearch -regexp $lines {foreach i \{boardSize}]
check "the writer's list of saved names was found" [expr {$i0 >= 0}]
set listText ""
set i $i0
while {$i >= 0 && $i < [llength $lines]} {
    set l [string trim [lindex $lines $i]]
    append listText " " [string trimright $l "\\"]
    incr i
    if {[string last "\} \{" $l] >= 0} break
}
set open [string first "\{" $listText]
set close [string last "\}" $listText]
set names {}
if {$open >= 0 && $close > $open} {
    foreach name [regexp -all -inline {\S+} [string range $listText [expr {$open + 1}] [expr {$close - 1}]]] {
        lappend names $name
    }
}
# A guard on the extraction: an empty or half-read list would pass the check
# below without testing anything.
check "and it was read whole" [expr {[llength $names] > 100}] "$names"

proc treeText {dir} {
    set text ""
    set pending [list $dir]
    while {[llength $pending]} {
        set here [lindex $pending 0]
        set pending [lrange $pending 1 end]
        foreach f [glob -nocomplain -directory $here *] {
            if {[file isdirectory $f]} {
                lappend pending $f
            } elseif {[string match *.tcl $f]} {
                set fh [open $f r]
                fconfigure $fh -encoding utf-8 -translation auto
                append text [read $fh] "\n"
                close $fh
            }
        }
    }
    return $text
}
set tree [treeText [file join $root tcl]]

set orphan {}
foreach name $names {
    set esc [string map {\( \\\( \) \\\)} $name]
    set pat [format {^[ \t]*(?:set|array set|variable)[ \t]+(?:::)?%s[ \t]} $esc]
    if {![regexp -line -- $pat $tree]} { lappend orphan $name }
}
checkEq "every saved name has a setter in tcl/" $orphan {}
foreach name [lrange $orphan 0 9] { puts "       no setter for $name" }

# ------------------------------------------------------------------- failure --
puts "\n== a failed rename keeps the file that was already there =="
writeFile $real "settings the user already had"
writeFile $tmp "a half-written replacement"
set fh [open $tmp a]

# Make the rename fail the way a full or read-only filesystem would.
rename file ::real_file
set ::failRename 1
proc file {sub args} {
    if {$sub eq "rename" && $::failRename} { return -code error "No space left on device" }
    return [uplevel 1 [list ::real_file $sub {*}$args]]
}

set err [options.finishWrite $fh $tmp $real]
check "the failure is reported" [expr {$err ne ""}] $err
check "it names the reason" [string match {*No space left*} $err] $err

set ::failRename 0
set fh [open $real r]
set content [read $fh]
close $fh
checkEq "the old settings are untouched" $content "settings the user already had"
check "the temporary file is cleaned up" [expr {![file exists $tmp]}]

file delete -force $dir
puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
