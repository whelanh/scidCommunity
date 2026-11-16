# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Accuracy for every game in the calibration corpus, from the application's own
# arithmetic -- not a port of it.
#
#   tclsh tools/app_accuracy.tcl <path/to/accuracy.tcl> <points.txt> <acc.txt>
#
# points.txt: one line per game -- "<id> <cp> <cp> ..." from White's perspective,
# starting at the initial position, exactly the series the engine pass wrote.
# acc.txt: "<id> <whiteAccuracy> <blackAccuracy>", unrounded.

lassign $argv accPath inPath outPath
source $accPath

set in [open $inPath r]
set out [open $outPath w]
while {[gets $in line] >= 0} {
    if {[string trim $line] eq ""} { continue }
    set words [split $line]
    set id [lindex $words 0]
    set cps [lrange $words 1 end]
    if {![llength $cps]} {
        puts $out "$id 0.0 0.0"
        continue
    }
    set acc [::accuracy::calculateFrom $cps white]
    puts $out "$id [lindex $acc 0] [lindex $acc 1]"
}
close $in
close $out
