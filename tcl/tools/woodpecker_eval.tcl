### woodpecker_eval.tcl: Woodpecker trainer - grading a set with the review.
### SPDX-License-Identifier: GPL-2.0-or-later
###
### Two passes on the review's own engine connection (::reviewdriver::start):
###   1. every position of every solution, MultiPV 3, depth 12 - the review's
###      verdict per move (::reviewdriver::judge). On puzzles depth 12 gives the
###      same labels as the review's default 18 at a twelfth of the time
###      (docs/woodpecker-plan.md 3.3);
###   2. the position before each solver move, MultiPV 1, depth 3 - what a short
###      search plays, for the "not the obvious move" test.
### The marks (::woodpecker::markFor) become a new marks version and are written
### into the set's database as NAGs. Nothing runs during a training session.

namespace eval ::woodpecker::eval {
    variable DEPTH 12
    variable MPV 3
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
        for {set p 0} {$p <= $n} {incr p} {
            set k [expr {$ex * $KEY + $p}]
            if {[dict exists $deepRes $k]} { dict set deep $p [dict get $deepRes $k] }
            if {[dict exists $shallowRes $k 1]} {
                dict set shallow $p [lindex [dict get $shallowRes $k 1] 3 0]
            }
        }
        dict set out $ex [dict create marks [marksOf [dict get $e fen] [dict get $e solution] $deep $shallow] \
            source review]
    }
    return $out
}

################################################################################
# Running the passes

proc ::woodpecker::eval::busy {} {
    variable run
    return [expr {[dict size $run] > 0}]
}

# Grade `exList` of the set in `dir` with the engine preset `engineName`.
#   onProgress {phase done total}   phase: deep | shallow | write
#   onDone {status summary}          status: ok | cancelled | error
proc ::woodpecker::eval::start {dir engineName exList onProgress onDone} {
    variable run
    variable DEPTH
    variable MPV
    if {[busy]} { error "a Woodpecker evaluation is already running" }
    set cfg [::enginecfg::get $engineName]
    if {$cfg eq ""} { error "no engine named '$engineName'" }
    if {[lindex $cfg 7] eq "" || [lindex $cfg 7] eq 0} { error "the evaluation needs a UCI engine" }
    set exs [::woodpecker::readExercises $dir]
    set valid {}
    foreach ex $exList { if {[dict exists $exs $ex]} { lappend valid $ex } }
    set exList $valid
    if {![llength $exList]} { error "nothing to evaluate" }
    set run [dict create dir $dir cfg $cfg exs $exs exList $exList \
        onProgress $onProgress onDone $onDone deep {} token ""]
    set token [::reviewdriver::start $cfg [deepPositions $exs $exList] $MPV \
        [dict create depth $DEPTH] [list ::woodpecker::eval::progress deep] \
        ::woodpecker::eval::deepDone 0]
    dict set run token $token
    return $token
}

proc ::woodpecker::eval::progress {phase done total args} {
    variable run
    if {![dict size $run]} { return }
    set cb [dict get $run onProgress]
    if {$cb ne ""} { catch { {*}$cb $phase $done $total } }
}

# The first pass is over. Its connection is closed from an idle callback the
# driver queued, so the second pass starts after that one has run.
proc ::woodpecker::eval::deepDone {results} {
    variable run
    if {![dict size $run]} { return }
    dict set run deep $results
    after idle [list after 0 ::woodpecker::eval::startShallow]
}

proc ::woodpecker::eval::startShallow {} {
    variable run
    if {![dict size $run]} { return }
    if {[catch {
        set token [::reviewdriver::start [dict get $run cfg] \
            [shallowPositions [dict get $run exs] [dict get $run exList]] 1 \
            [dict create depth $::woodpecker::P(shallowDepth)] \
            [list ::woodpecker::eval::progress shallow] ::woodpecker::eval::shallowDone 0]
        dict set run token $token
    } err]} {
        finish error $err
    }
}

proc ::woodpecker::eval::shallowDone {results} {
    variable run
    if {![dict size $run]} { return }
    after idle [list after 0 [list ::woodpecker::eval::write $results]]
}

proc ::woodpecker::eval::write {shallow} {
    variable run
    if {![dict size $run]} { return }
    progress write 0 1
    if {[catch {
        set marks [marksFromResults [dict get $run exs] [dict get $run exList] [dict get $run deep] $shallow]
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
    set token [dict get $run token]
    if {$token ne ""} { catch { ::reviewdriver::stop $token 0 } }
    finish cancelled {}
}

proc ::woodpecker::eval::finish {status summary} {
    variable run
    if {![dict size $run]} { return }
    set cb [dict get $run onDone]
    set run {}
    if {$cb ne ""} { catch { {*}$cb $status $summary } }
}
