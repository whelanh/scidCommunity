#!/usr/bin/env tclsh
# Add board features (capture / check / quiet) to each probe row.
# Usage: tclsh features.tcl <repo> <puzzles.tsv> <probe_out.tsv> <out.tsv>
lassign $argv root inTsv probeTsv outTsv
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl utils chessboard.tcl]
source [file join [file dirname [info script]] sanlib.tcl]

set fh [open $inTsv]
while {[gets $fh row] >= 0} {
    lassign [split $row "\t"] id tier rating initialPly solution themes pgn
    set fen0 [fenAfterPgn $pgn [expr {$initialPly + 1}]]
    set pos [::chessboard::fromFen $fen0]
    set p 0
    foreach m $solution {
        incr p
        set cap [expr {[::movelabels::captureVictim $pos $m] ne ""}]
        set after [::chessboard::makeMove $pos $m]
        set chk [::chessboard::inCheck $after [dict get $after side]]
        set feat($id,$p) [list $cap $chk [expr {!$cap && !$chk && [string length $m] == 4}]]
        set pos $after
    }
}
close $fh
set in [open $probeTsv]
set out [open $outTsv w]
gets $in header
puts $out "$header\tcapture\tcheck\tquiet"
set cols [split $header "\t"]
set iId [lsearch $cols id]; set iPly [lsearch $cols ply]
while {[gets $in row] >= 0} {
    set f [split $row "\t"]
    set k "[lindex $f $iId],[lindex $f $iPly]"
    puts $out "$row\t[join $feat($k) "\t"]"
}
close $out
