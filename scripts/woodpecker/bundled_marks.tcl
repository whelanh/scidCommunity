# Copyright (C) 2026 Tommaso Bergamasco
# SPDX-License-Identifier: GPL-2.0-or-later
#
# bundled_marks.tcl -- regenerate puzzles/marks.tsv: the ! and !! of every
# bundled puzzle, graded with the trainer's own evaluation (::woodpecker::eval)
# so a new set needs no review of its own. Run it inside the built application
# (it needs the sc_* commands and a UCI engine):
#
#   scidCommunity scripts/woodpecker/bundled_marks.tcl
#
# Environment:
#   WP_ENGINE  the engine executable (required; the committed file was made with Stockfish 18)
#   WP_SETS    the set numbers to grade, default "1 2 3 4 5 6 7 8 9"
#   WP_LIMIT   only the first N puzzles of each set (a check, not a result)
#   WP_OUT     the output file; required with WP_SETS or WP_LIMIT, default puzzles/marks.tsv
#
# Roughly two hours for all 9000 puzzles on one core. To use more cores run one
# process per set with its own WP_OUT, then join the parts:
#   (head -4 part1.tsv; for f in part?.tsv; do grep -hv '^#' $f; done) > puzzles/marks.tsv

proc envv {k d} { expr {[info exists ::env($k)] ? $::env($k) : $d} }
set root [file normalize [file join [file dirname [info script]] .. ..]]
foreach f {utils/chessboard.tcl tools/accuracy.tcl tools/move_labels.tcl tools/woodpecker_core.tcl
           tools/woodpecker_set.tcl enginecfg.tcl enginecomm.tcl tools/engine_limits.tcl
           tools/score_seed.tcl tools/comment_colors.tcl tools/game_review.tcl
           tools/review_driver.tcl tools/woodpecker_eval.tcl} {
    source -encoding utf-8 [file join $root tcl $f]
}

set engine [envv WP_ENGINE ""]
if {$engine eq ""} { puts stderr "WP_ENGINE is required"; exit 2 }
set sets  [envv WP_SETS {1 2 3 4 5 6 7 8 9}]
set limit [envv WP_LIMIT ""]
set out   [envv WP_OUT ""]
if {$out eq ""} {
    if {$sets ne {1 2 3 4 5 6 7 8 9} || $limit ne ""} {
        puts stderr "a partial run needs its own WP_OUT"
        exit 2
    }
    set out [file join $root puzzles marks.tsv]
}
set tmp [file join [expr {[info exists ::env(TEMP)] ? $::env(TEMP) : "/tmp"}] bundled_marks_[pid]]
file delete -force $tmp
file mkdir $tmp
set ::scidUserDir $tmp
set ::clipbase_db [sc_info clipbase]
set ::engines(list) [list [list MarksEngine $engine {} {} 0 0 {} 1 {}]]

proc onDone {status summary} { set ::done [list $status $summary] }

proc grade {k} {
    global root tmp limit
    # One set's file in a folder of its own: readPool reads every set-*.pgn it finds.
    set d [file join $tmp pool$k]
    file mkdir $d
    file copy [lindex [glob -directory [file join $root puzzles] set-$k-*.pgn] 0] $d
    set games [::woodpecker::set::readPool $d]
    if {$limit ne ""} { set games [lrange $games 0 [expr {$limit - 1}]] }
    set exs {}
    foreach g $games { lappend exs [::woodpecker::set::bundledExercise $g] }
    set dir [::woodpecker::set::newDir "Marks $k"]
    ::woodpecker::set::buildFromExercises $dir \
        [::woodpecker::set::newMeta "Marks $k" bundled 28 1 [clock seconds]] $exs
    set rows [::woodpecker::readExercises $dir]
    set ::done ""
    set exList [lsort -integer [dict keys $rows]]
    puts "set $k: [llength $exList] puzzles"
    ::woodpecker::eval::start $dir MarksEngine $exList {} onDone
    vwait ::done
    lassign $::done status summary
    if {$status ne "ok"} { error "set $k: evaluation $status $summary" }
    set marks [::woodpecker::readMarks $dir]
    set table [::woodpecker::marksAt $marks [::woodpecker::marksLatest $marks]]
    set lines {}
    dict for {ex r} $rows {
        set ms [lmap m [dict get $table $ex marks] { expr {$m eq "" ? "-" : $m} }]
        lappend lines "[dict get $r puzzleId]\t[join $ms { }]"
    }
    return $lines
}

set lines {}
foreach k $sets { lappend lines {*}[grade $k] }

catch { exec $engine << "uci\nquit\n" } uci
if {![regexp -line {^id name (.+)$} $uci -> engineName]} { set engineName "an unknown engine" }
set header "# Woodpecker marks for the bundled puzzles (set-*.pgn): one line per puzzle, PuzzleId TAB the mark of each
# solver move (\"-\" none, \"!\" or \"!!\"), separated by spaces. A new set takes them instead of asking for a review.
# Made by scripts/woodpecker/bundled_marks.tcl: [string trim $engineName] (Threads 1, Hash 16), depth $::woodpecker::eval::DEPTH MultiPV $::woodpecker::eval::MPV, then depth $::woodpecker::P(shallowDepth),
# with ::woodpecker::markFor as committed. Regenerate it when markFor changes.\n"
set ch [open $out w]
fconfigure $ch -encoding utf-8 -translation lf
puts -nonewline $ch $header
foreach l $lines { puts $ch $l }
close $ch
file delete -force $tmp
puts "wrote [llength $lines] lines to $out"
exit 0
