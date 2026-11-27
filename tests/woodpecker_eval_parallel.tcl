# Copyright (C) 2026 Tommaso Bergamasco
# SPDX-License-Identifier: GPL-2.0-or-later
#
# woodpecker_eval_parallel.tcl -- the Woodpecker evaluation on one engine and on
# several: same marks, less time. Needs the built application and a UCI engine:
#
#   WP_ENGINE=/path/to/stockfish scidCommunity tests/woodpecker_eval_parallel.tcl
#
# Environment: WP_SET (bundled set number, default 5), WP_LIMIT (puzzles, default
# 160), WP_WORKERS (counts to compare, default "1 2 4 7").

proc envv {k d} { expr {[info exists ::env($k)] ? $::env($k) : $d} }
set root [file normalize [file join [file dirname [info script]] ..]]
foreach f {utils/chessboard.tcl tools/accuracy.tcl tools/move_labels.tcl tools/woodpecker_core.tcl
           tools/woodpecker_set.tcl enginecfg.tcl enginecomm.tcl tools/engine_limits.tcl
           tools/score_seed.tcl tools/comment_colors.tcl tools/game_review.tcl
           tools/review_driver.tcl tools/woodpecker_eval.tcl} {
    source -encoding utf-8 [file join $root tcl $f]
}
set engine [envv WP_ENGINE ""]
if {$engine eq ""} { puts stderr "WP_ENGINE is required"; exit 2 }
set tmp [file join [expr {[info exists ::env(TEMP)] ? $::env(TEMP) : "/tmp"}] wp_parallel_[pid]]
file delete -force $tmp
file mkdir $tmp
set ::scidUserDir $tmp
set ::clipbase_db [sc_info clipbase]
set ::engines(list) [list [list BenchEngine $engine {} {} 0 0 {} 1 {}]]

set k [envv WP_SET 5]
set d [file join $tmp pool]
file mkdir $d
file copy [lindex [glob -directory [file join $root puzzles] set-$k-*.pgn] 0] $d
set games [lrange [::woodpecker::set::readPool $d] 0 [expr {[envv WP_LIMIT 160] - 1}]]
set exs {}
foreach g $games { lappend exs [::woodpecker::set::bundledExercise $g] }
set dir [::woodpecker::set::newDir "Parallel"]
::woodpecker::set::buildFromExercises $dir [::woodpecker::set::newMeta Parallel bundled 28 1 [clock seconds]] $exs
set exList [lsort -integer [dict keys [::woodpecker::readExercises $dir]]]
puts "set $k: [llength $exList] puzzles, [::woodpecker::eval::cores] logical CPUs"

proc onProg {phase done total} { if {$done == $total} { puts "  $phase pass: $done positions" } }
proc onDone {status summary} { set ::done [list $status $summary] }
proc grade {workers} {
    global dir exList
    set ::woodpecker::eval::WORKERS $workers
    set ::done ""
    set t0 [clock milliseconds]
    ::woodpecker::eval::start $dir BenchEngine $exList onProg onDone
    vwait ::done
    set ms [expr {[clock milliseconds] - $t0}]
    if {[lindex $::done 0] ne "ok"} { error "workers $workers: $::done" }
    set marks [::woodpecker::readMarks $dir]
    return [list $ms [::woodpecker::marksAt $marks [::woodpecker::marksLatest $marks]]]
}

set fails 0
set base ""
foreach w [envv WP_WORKERS {1 2 4 7}] {
    lassign [grade $w] ms table
    if {$base eq ""} { set base $table; set baseMs $ms }
    set same 0; set diff 0
    dict for {ex e} $base {
        if {[dict get $e marks] eq [dict get $table $ex marks]} { incr same } else { incr diff }
    }
    puts [format "%2d worker(s): %6.1f s   x%.2f   marks equal to the first run on %d of %d puzzles" \
        $w [expr {$ms / 1000.0}] [expr {double($baseMs) / $ms}] $same [expr {$same + $diff}]]
    # Not byte-identical: each engine keeps its own hash from one position to the next, so a borderline
    # move can land on the other side of a mark. Measured 4-11%; much more means a real fault.
    if {$diff > 0.20 * ($same + $diff)} { incr fails }
    after 300
}
file delete -force $tmp
puts [expr {$fails ? "FAIL: marks differ" : "ok"}]
exit $fails
