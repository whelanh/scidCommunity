### woodpecker_eval.tcl: Woodpecker trainer - grading a set with the review.
### SPDX-License-Identifier: GPL-2.0-or-later
###
### Two passes on the review's own engine connections (::reviewdriver::start), each cut into
### chunks that run side by side on up to 8 one-thread engines (workerCount):
###   1. every position of every solution, MultiPV 3, depth 12 - the review's
###      verdict per move (::reviewdriver::judge). On puzzles depth 12 gives the
###      same labels as the review's default 18 at a twelfth of the time
###      (docs/woodpecker-method.md, Decision 3);
###   2. the position before each solver move, MultiPV 1, depth 3 - what a short
###      search plays, for the "not the obvious move" test.
### The marks (::woodpecker::markFor) become a new marks version and are written
### into the set's database as NAGs. Nothing runs during a training session.

namespace eval ::woodpecker::eval {
    variable DEPTH 12
    variable MPV 3
    # Engines run side by side: 0 = decide from the CPUs (workerCount), else exactly this many.
    variable WORKERS 0
    # Fewest exercises worth one engine of their own.
    variable MIN_CHUNK 4
    variable run {}
    # Results are keyed ex * KEY + ply, so one pass covers the whole set.
    variable KEY 1000
    variable pending {}
}

# The review's map of one exercise: the line from its FEN.
proc ::woodpecker::eval::mapOf {fen solution} {
    return [::review::mainLineMap [concat [list "position fen $fen moves"] $solution]]
}

# The marks of one exercise from the two passes' results for it.
#   deep     ply -> {mpvIndex -> {depth score type pv}}  (plies 0..n)
#   shallow  ply -> the move the short search chose at that position
# Returns one mark per solver move.
proc ::woodpecker::eval::marksOf {fen solution deep shallow} {
    set map [mapOf $fen $solution]
    set sides [::reviewdriver::sides $map]
    set pos [::chessboard::fromFen $fen]
    set fens [list $fen]
    foreach m $solution {
        set pos [::chessboard::makeMove $pos $m]
        lappend fens [::chessboard::toFen $pos]
    }
    set out {}
    for {set p 1} {$p <= [llength $solution]} {incr p 2} {
        set v [::reviewdriver::judge $map $deep $sides $p]
        if {$v eq ""} { lappend out ""; continue }
        set played [lindex $solution [expr {$p - 1}]]
        set pvAfter {}
        if {[dict exists $deep $p 1]} { set pvAfter [lindex [dict get $deep $p 1] 3] }
        set facts [::woodpecker::moveFacts [lindex $fens [expr {$p - 1}]] $played $pvAfter]
        set sh ""
        if {[dict exists $shallow [expr {$p - 1}]]} { set sh [dict get $shallow [expr {$p - 1}]] }
        set ctx [dict merge $facts [dict create label [dict get $v label] \
            isBest [dict get $v isBest] played $played pvAfter $pvAfter shallow $sh]]
        lappend out [::woodpecker::markFor $ctx]
    }
    return $out
}

# The positions of the first pass, and of the second.
proc ::woodpecker::eval::deepPositions {exs exList} {
    variable KEY
    set out {}
    foreach ex $exList {
        set e [dict get $exs $ex]
        set map [mapOf [dict get $e fen] [dict get $e solution]]
        dict for {ply spec} [dict get $map positions] {
            lappend out [list [expr {$ex * $KEY + $ply}] $spec]
        }
    }
    return $out
}

proc ::woodpecker::eval::shallowPositions {exs exList} {
    variable KEY
    set out {}
    foreach ex $exList {
        set e [dict get $exs $ex]
        set map [mapOf [dict get $e fen] [dict get $e solution]]
        set n [llength [dict get $e solution]]
        for {set p 1} {$p <= $n} {incr p 2} {
            lappend out [list [expr {$ex * $KEY + $p - 1}] [dict get $map positions [expr {$p - 1}]]]
        }
    }
    return $out
}

# The marks of every exercise from the two passes' raw results.
proc ::woodpecker::eval::marksFromResults {exs exList deepRes shallowRes} {
    variable KEY
    set out [dict create]
    foreach ex $exList {
        set e [dict get $exs $ex]
        set deep [dict create]
        set shallow [dict create]
        set n [llength [dict get $e solution]]
        set reached 1
        for {set p 0} {$p <= $n} {incr p} {
            set k [expr {$ex * $KEY + $p}]
            if {[dict exists $deepRes $k]} {
                dict set deep $p [dict get $deepRes $k]
            } else {
                set reached 0
            }
            if {[dict exists $shallowRes $k 1]} {
                dict set shallow $p [lindex [dict get $shallowRes $k 1] 3 0]
            }
        }
        # A pass that lost its engine reports only the positions it reached.
        # Grading an exercise it never got to would append a new version of
        # blanks over the marks that exercise already had, so leave it out:
        # it keeps its earlier marks and is not counted as graded.
        if {!$reached} { continue }
        dict set out $ex [dict create marks [marksOf [dict get $e fen] [dict get $e solution] $deep $shallow] \
            source review]
    }
    return $out
}

################################################################################
# Running the passes
#
# Each pass is cut into one chunk per worker and every chunk runs on an engine
# connection of its own, one thread each - the way the tree search cuts its
# candidates into shards (src/tkscid.cpp). A depth-12 search of a puzzle is far
# too short for Threads to help, while separate engines scale with the cores.

proc ::woodpecker::eval::busy {} {
    variable run
    return [expr {[dict size $run] > 0}]
}

# Logical CPUs; 1 when the system will not say.
proc ::woodpecker::eval::cores {} {
    set n 1
    if {[info exists ::env(NUMBER_OF_PROCESSORS)]} {
        set n $::env(NUMBER_OF_PROCESSORS)
    } elseif {[catch { set n [exec nproc] }]} {
        catch { set n [exec sysctl -n hw.logicalcpu] }
    }
    return [expr {[string is integer -strict $n] && $n > 0 ? $n : 1}]
}

# How many engines to run for `count` exercises: WORKERS if set, else half the logical CPUs
# (hyper-threads share a core: measured on 4 cores / 8 CPUs, 4 engines gave x2.4 and 7 only x2.6,
# and left the interface responsive), at most 8 (the ids the driver reserves) and
# no more than one per MIN_CHUNK exercises, which would only pay for starting them.
proc ::woodpecker::eval::workerCount {count} {
    variable WORKERS
    variable MIN_CHUNK
    set n $WORKERS
    if {$n < 1} { set n [expr {([cores] + 1) / 2}] }
    set n [expr {min($n, 8, ($count + $MIN_CHUNK - 1) / $MIN_CHUNK)}]
    return [expr {max($n, 1)}]
}

# The preset with one thread and a small hash: the engines share the machine.
proc ::woodpecker::eval::workerCfg {cfg} {
    while {[llength $cfg] < 9} { lappend cfg {} }
    set opts {}
    foreach o [lindex $cfg 8] {
        if {[string tolower [lindex $o 0]] ni {threads hash}} { lappend opts $o }
    }
    lappend opts {Threads 1} {Hash 64}
    return [lreplace $cfg 8 8 $opts]
}

# Cut {key spec} positions into `n` lists by exercise (key / KEY), dealing the
# exercises out in turn so the long and the short ones mix.
proc ::woodpecker::eval::chunks {positions n} {
    variable KEY
    set out [lrepeat $n {}]
    set slot [dict create]
    set next 0
    foreach p $positions {
        set ex [expr {[lindex $p 0] / $KEY}]
        if {![dict exists $slot $ex]} { dict set slot $ex [expr {$next % $n}]; incr next }
        set i [dict get $slot $ex]
        lset out $i [linsert [lindex $out $i] end $p]
    }
    set kept {}
    foreach c $out { if {[llength $c]} { lappend kept $c } }
    return $kept
}

# Grade `exList` of the set in `dir` with the engine preset `engineName`.
#   onProgress {phase done total}   phase: deep | shallow | write
#   onDone {status summary}          status: ok | cancelled | error
proc ::woodpecker::eval::start {dir engineName exList onProgress onDone} {
    variable run
    if {[busy]} { error "a Woodpecker evaluation is already running" }
    set cfg [::enginecfg::get $engineName]
    if {$cfg eq ""} { error "no engine named '$engineName'" }
    if {[lindex $cfg 7] eq "" || [lindex $cfg 7] eq 0} { error "the evaluation needs a UCI engine" }
    set exs [::woodpecker::readExercises $dir]
    set valid {}
    foreach ex $exList { if {[dict exists $exs $ex]} { lappend valid $ex } }
    set exList $valid
    if {![llength $exList]} { error "nothing to evaluate" }
    set workers [workerCount [llength $exList]]
    # One engine keeps the preset as the user configured it.
    if {$workers > 1} { set cfg [workerCfg $cfg] }
    set run [dict create dir $dir cfg $cfg exs $exs exList $exList workers $workers \
        onProgress $onProgress onDone $onDone deep {} tokens {} phase {}]
    # The driver refuses an engine id another pass is using (the Game Review
    # takes the same one). A run left in `run` after that error would answer
    # busy for the rest of the session and refuse every later Evaluate.
    if {[catch {
        runPhase deep [deepPositions $exs $exList] $::woodpecker::eval::MPV $::woodpecker::eval::DEPTH \
            ::woodpecker::eval::deepDone
    } err]} {
        set run {}
        return -code error $err
    }
    return [dict get $run tokens]
}

# Start every chunk of `positions` and call `next results` when all are done.
proc ::woodpecker::eval::runPhase {phase positions mpv depth next} {
    variable run
    set chunks [chunks $positions [dict get $run workers]]
    dict set run phase [dict create name $phase next $next waiting [llength $chunks] results {} \
        done [lrepeat [llength $chunks] 0] total [llength $positions]]
    dict set run tokens {}
    set i 0
    foreach chunk $chunks {
        # Id "" is the review's own connection; extra workers take the ones after it.
        set id [expr {[dict get $run workers] > 1 ? [expr {$::reviewdriver::ENGINE_ID + 1 + $i}] : ""}]
        if {[catch {
            set token [::reviewdriver::start [dict get $run cfg] $chunk $mpv [dict create depth $depth] \
                [list ::woodpecker::eval::progress $phase $i] [list ::woodpecker::eval::chunkDone $phase] 0 standard $id]
        } err]} {
            foreach t [dict get $run tokens] { catch { ::reviewdriver::stop $t 0 } }
            return -code error $err
        }
        dict lappend run tokens $token
        incr i
    }
}

# A chunk reports each finished position; the progress is the sum over chunks.
proc ::woodpecker::eval::progress {phase chunk done total args} {
    variable run
    if {![dict size $run]} { return }
    dict set run phase done [lreplace [dict get $run phase done] $chunk $chunk $done]
    report $phase [::tcl::mathop::+ {*}[dict get $run phase done]] [dict get $run phase total]
}

# Tell the caller how far a phase is.
proc ::woodpecker::eval::report {phase done total} {
    variable run
    if {![dict size $run]} { return }
    set cb [dict get $run onProgress]
    if {$cb ne ""} { catch { {*}$cb $phase $done $total } }
}

# A chunk is over. The last one hands the merged results on from an idle
# callback: the connections close from idle callbacks the driver queued, and the
# next pass reuses their ids.
proc ::woodpecker::eval::chunkDone {phase results} {
    variable run
    if {![dict size $run]} { return }
    dict set run phase results [dict merge [dict get $run phase results] $results]
    dict set run phase waiting [expr {[dict get $run phase waiting] - 1}]
    if {[dict get $run phase waiting] > 0} { return }
    set next [dict get $run phase next]
    after idle [list after 0 [list $next [dict get $run phase results]]]
}

proc ::woodpecker::eval::deepDone {results} {
    variable run
    if {![dict size $run]} { return }
    dict set run deep $results
    if {[catch {
        runPhase shallow [shallowPositions [dict get $run exs] [dict get $run exList]] 1 \
            $::woodpecker::P(shallowDepth) ::woodpecker::eval::shallowDone
    } err]} {
        finish error $err
    }
}

proc ::woodpecker::eval::shallowDone {results} {
    variable run
    if {![dict size $run]} { return }
    write $results
}


proc ::woodpecker::eval::write {shallow} {
    variable run
    if {![dict size $run]} { return }
    report write 0 1
    if {[catch {
        set marks [marksFromResults [dict get $run exs] [dict get $run exList] [dict get $run deep] $shallow]
        # Nothing reached (the engine died at the first position): a new
        # version of blanks would hide the marks already in the set.
        if {![dict size $marks]} { error "the engine did not finish any exercise" }
        set dir [dict get $run dir]
        set ver [::woodpecker::marksAppend $dir $marks]
        # The NAGs go into the set's database, which means loading its games.
        # During a training session the board belongs to the session: the
        # write waits for it to end (the scores use marks.tsv, not the NAGs).
        if {[info exists ::woodpecker::ui::run(on)] && $::woodpecker::ui::run(on)} {
            lappend ::woodpecker::eval::pending [list $dir $marks]
        } else {
            ::woodpecker::set::writeMarks $dir $marks
        }
        set one 0; set two 0; set moves 0
        dict for {ex e} $marks {
            foreach m [dict get $e marks] {
                incr moves
                if {$m eq "!"} { incr one } elseif {$m eq "!!"} { incr two }
            }
        }
        set summary [dict create version $ver exercises [dict size $marks] moves $moves bang $one bangbang $two]
    } err]} {
        finish error $err
        return
    }
    finish ok $summary
}

# Marks whose NAGs could not be written while a session was running.
proc ::woodpecker::eval::flushPending {} {
    variable pending
    set todo $pending
    set pending {}
    foreach p $todo {
        lassign $p dir marks
        catch { ::woodpecker::set::writeMarks $dir $marks }
    }
}

proc ::woodpecker::eval::cancel {} {
    variable run
    if {![dict size $run]} { return }
    foreach token [dict get $run tokens] { catch { ::reviewdriver::stop $token 0 } }
    finish cancelled {}
}

proc ::woodpecker::eval::finish {status summary} {
    variable run
    if {![dict size $run]} { return }
    set cb [dict get $run onDone]
    set run {}
    if {$cb ne ""} { catch { {*}$cb $status $summary } }
}
