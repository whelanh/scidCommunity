# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# engine_seed.tcl -- the engine window's seeding hook, without a window.
#
#   tclsh tests/tcl/engine_seed.tcl
#
# The seeding hook lives in tcl/windows/engine.tcl, which cannot be sourced: it
# wants Tk and a live engine window. So the procedures under test are lifted out
# of it by name (the way tests/tcl/options_write.tcl lifts its one) and the board
# and the chart are stubs that record what they were asked for.
#
# Three things are pinned here, all deferred findings from PR #378:
#
#   1. a seeded ply is marked in pv_(seeded,$id) and not in pv_(depths,$id), so
#      Autorun skips it and a manual search at it still reaches the chart;
#   2. the walk over the main line puts the board back where it found it, even
#      when it found it inside a nested variation;
#   3. the chart's click path passes an empty score, which must not raise.

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
set src [file join $root tcl windows engine.tcl]

# The pure modules the lifted procedures call, taken whole: they are what the
# real window uses, so the harness cannot disagree with them.
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools score_seed.tcl]
source [file join $root tcl tools comment_colors.tcl]
source [file join $root tcl tools game_review.tcl]

# The namespaces the lifted procedures and the stubs live in. Creating them up
# front is not decoration: tclsh has none of them, and a proc for an unknown
# namespace raises.
namespace eval ::enginewin {}
namespace eval ::notify {}
namespace eval ::rapid_annotate {}


# --------------------------------------------------------------- extraction --
set fh [open $src r]
set ::lines [split [read $fh] "\n"]
close $fh

# The text of one procedure, found by its definition line and read until the
# braces balance. "" when the definition is not in the file at all.
proc procText {anchor} {
    set start [lsearch -exact $::lines $anchor]
    if {$start < 0} { return "" }
    set text ""
    for {set i $start} {$i < [llength $::lines]} {incr i} {
        append text [lindex $::lines $i] "\n"
        if {[info complete $text]} break
    }
    return $text
}

# Lift one procedure by its definition line and eval it. Returns 1 when it is
# now a procedure.
proc lift {anchor name} {
    set text [procText $anchor]
    if {$text eq ""} { return 0 }
    if {[catch { eval $text } err]} {
        puts "  note $name did not evaluate: $err"
        return 0
    }
    return [expr {[llength [info procs $name]] == 1}]
}

# Gate a section on its procedure having been lifted, and fail loudly when it
# has not: a silently skipped section would read as a pass.
proc have {name} {
    if {[llength [info procs $name]]} { return 1 }
    check "$name is available to test" 0
    return 0
}

puts "extraction"
check "seedChart is lifted" [lift "proc ::enginewin::seedChart {id} {" ::enginewin::seedChart]
check "seedLabel is lifted" [lift "proc ::enginewin::seedLabel {ply score} {" ::enginewin::seedLabel]
check "analyzeMainLine is lifted" [lift "proc ::enginewin::analyzeMainLine {id} {" ::enginewin::analyzeMainLine]
check "updateChart is lifted" \
    [lift "proc ::enginewin::updateChart {id {msgData \"\"}} {" ::enginewin::updateChart]

set seedChartText [procText "proc ::enginewin::seedChart {id} {"]
set seedLabelText [procText "proc ::enginewin::seedLabel {ply score} {"]
set connectText [procText "proc ::enginewin::connectEngine {id enginename} {"]
set sendText [procText "proc ::enginewin::sendPosition {id position plyInMainLine} {"]


# The anchors this slice adds. On a tree without them these fail, which is the
# RED half of the pairing: nothing below can pass by accident.
check "seedChart saves the whole cursor" [expr {[string first {::review::cursorSave} $seedChartText] >= 0}]
check "seedChart restores the whole cursor" [expr {[string first {::review::cursorRestore} $seedChartText] >= 0}]
check "a seeded ply drops any stale depth" \
    [expr {[string first {dict unset depths $i} $seedChartText] >= 0}]
check "seedLabel answers a click with a label" \
    [expr {[string first {return "$mv$suffix stored"} $seedLabelText] >= 0}]

# Both reset sites: the seeded markers are chart state and go wherever the
# depths go. sendPosition's reset has to come before it seeds.
check "connectEngine resets the seeded markers" \
    [expr {[string first {pv_(seeded,$id) [dict create]} $connectText] >= 0}]
set seededAt [string first {pv_(seeded,$id) [dict create]} $sendText]
set seedCallAt [string first {::enginewin::seedChart $id} $sendText]
check "sendPosition resets the seeded markers before it seeds" \
    [expr {$seededAt >= 0 && $seedCallAt >= 0 && $seededAt < $seedCallAt}]

# -------------------------------------------------------------------- stubs --
namespace eval ::board {
    variable plies 0
    variable comments {}      ;# dict: main-line ply -> the comment on it
    variable loc 0            ;# the absolute ply counter, as sc_pos reports it
    variable frames {}        ;# {number branchPly movesInside} outermost first
    variable moves {}         ;# the sc_* calls, in order
}
namespace eval ::chart {
    variable calls {}
    variable points {}
}
namespace eval ::annot { variable calls {} }

# A position is identified by the path that reaches it, the way the real board
# identifies it by its FEN: a variation position is never equal to the main-line
# position at the same ply counter.
proc ::board::fen {} {
    variable loc
    variable frames
    if {![llength $frames]} { return "fen/m$loc" }
    set parts {}
    foreach f $frames {
        lappend parts "v[lindex $f 0]-b[lindex $f 1]-m[lindex $f 2]"
    }
    return "fen/[join $parts]/"
}

proc ::board::reset {plies comments} {
    variable loc 0
    variable frames {}
    variable moves {}
    set ::board::plies $plies
    set ::board::comments $comments
}

proc ::board::note {args} { lappend ::board::moves $args }

# sc_pos: the four questions the lifted procedures ask. These commands are named
# globally because that is what engine.tcl calls, so the state they share is
# named fully: `variable` inside a global proc would reach ::comments, not
# ::board::comments.
proc sc_pos {what} {
    switch -- $what {
        location { return $::board::loc }
        fen { return [::board::fen] }
        side { return [expr {$::board::loc % 2 ? "black" : "white"}] }
        getComment {
            if {[llength $::board::frames]} { return "" }
            if {[dict exists $::board::comments $::board::loc]} {
                return [dict get $::board::comments $::board::loc]
            }
            return ""
        }
        default { return "" }
    }
}

# sc_move: `ply` is the main line only (MoveToPly = start, then forward N), which
# is exactly the trap finding 2 is about.
proc sc_move {what args} {
    set n [expr {[llength $args] ? [lindex $args 0] : 1}]
    switch -- $what {
        ply {
            set ::board::frames {}
            set ::board::loc $n
        }
        start {
            set ::board::frames {}
            set ::board::loc 0
        }
        forward {
            incr ::board::loc $n
            if {[llength $::board::frames]} {
                set last [lindex $::board::frames end]
                lset last 2 [expr {[lindex $last 2] + $n}]
                set ::board::frames [lreplace $::board::frames end end $last]
            }
        }
        back {
            incr ::board::loc -$n
            if {[llength $::board::frames]} {
                set last [lindex $::board::frames end]
                lset last 2 [expr {[lindex $last 2] - $n}]
                set ::board::frames [lreplace $::board::frames end end $last]
            }
        }
        default {}
    }
    ::board::note sc_move $what $n
}

# sc_var: `enter n` moves into the variation AND plays its first move, as
# MoveIntoVariation does; `exit` returns to the position it branched from.
proc sc_var {what args} {
    switch -- $what {
        level { return [llength $::board::frames] }
        number { return [lindex [lindex $::board::frames end] 0] }
        enter {
            lappend ::board::frames [list [lindex $args 0] $::board::loc 1]
            incr ::board::loc
        }
        exit {
            if {[llength $::board::frames]} {
                set ::board::loc [lindex [lindex $::board::frames end] 1]
                set ::board::frames [lrange $::board::frames 0 end-1]
            }
        }
        default {}
    }
    ::board::note sc_var $what {*}$args
}

proc sc_game {args} { return "" }

# The window: Tk is absent, so the canvas exists as far as this harness cares.
proc winfo {sub args} { return 1 }

namespace eval ::engine { variable calls {} }
proc ::engine::send {id cmd args} {
    lappend ::engine::calls [list $id $cmd {*}$args]
}

proc ::enginewin::stateLocked {id} { return 0 }
proc ::notify::PosChanged {args} {}
proc ::rapid_annotate::record {id plies depth score score_type pv} {
    lappend ::annot::calls [list $id $plies $depth $score $score_type $pv]
}

proc ::chart::setDataPoint {w x score callback} {
    lappend ::chart::calls [list setDataPoint $x $score]
    dict set ::chart::points $x $score
}
proc ::chart::setAccuracy {w wAcc bAcc} {
    lappend ::chart::calls [list setAccuracy $wAcc $bAcc]
}
# The graph carries a missing ply forward: index 0 is the position before the
# first move, so a game of N plies yields N+1 entries.
proc ::chart::getScores {w} {
    set out {}
    for {set i 0} {$i <= [expr {[llength [dict keys $::chart::points]] ? [lindex [lsort -integer [dict keys $::chart::points]] end] : 0}]} {incr i} {
        if {[dict exists $::chart::points $i]} { lappend out [dict get $::chart::points $i] } else { lappend out 0 }
    }
    return $out
}

# The window's own state, keyed by id, as the real window keeps it.
set id 1
set ::enginewin::pgnviewer($id) 0
set ::enginewin::m_(scoreside,$id) white
set ::enginewin_autorun($id) {movetime 50}
# A six-move main line: the chart and the Autorun pass both read this.
set ::enginewin::m_(mainLine,$id) [list \
    "position startpos moves" e2e4 e7e5 g1f3 b8c6 g2g3 d7d6]

# The recorded Go: {id Go {position ...} {limits ...}}, so the position string is
# the first element of the third field.
proc goPosition {i} {
    return [lindex [lindex [lindex $::engine::calls $i] 2] 0]
}


# -------------------------------------------------- finding 1: seeded markers --
puts "\n== a seeded ply is marked, and only marked =="
if {[have ::enginewin::seedChart]} {
    set comments [dict create \
        1 {[%eval 0.20]} \
        2 {[%eval -0.35]} \
        3 {[%eval 0.10]} \
        5 {[%eval #3]}]
    ::board::reset 6 $comments
    # Depth entries left over from an earlier pass: one at a ply the game now
    # knows (3), one at a ply it does not (6).
    set ::enginewin::pv_(depths,$id) [dict create 3 12 6 7]
    set ::enginewin::pv_(seeded,$id) {}
    set ::chart::calls {}
    set ::chart::points {}
    set ::annot::calls {}

    set count [::enginewin::seedChart $id]
    checkEq "four plies carry a stored score" $count 4

    set seeded $::enginewin::pv_(seeded,$id)
    set depths $::enginewin::pv_(depths,$id)
    checkEq "the seeded plies are the four with a score" [lsort -integer [dict keys $seeded]] {1 2 3 5}
    foreach p {1 2 3 5} {
        check "ply $p is in the seeded map" [dict exists $seeded $p]
        check "and not in the depth map" [expr {![dict exists $depths $p]}]
    }
    check "a ply without a score is in neither" [expr {![dict exists $seeded 4]}]
    check "the stale depth of a seeded ply is gone" [expr {![dict exists $depths 3]}] "depths: $depths"
    checkEq "the depth of a ply the game does not know is kept" \
        [expr {[dict exists $depths 6] ? [dict get $depths 6] : "missing"}] 7
    checkEq "each seeded ply reached the chart" \
        [lsort -integer [dict keys $::chart::points]] {1 2 3 5}
    check "the graph was told its accuracy" \
        [expr {[llength [lsearch -all -inline -index 0 $::chart::calls setAccuracy]] > 0}]
}

# ------------------------------------- finding 1: Autorun still skips them --
puts "\n== Autorun still skips a seeded ply =="
if {[have ::enginewin::analyzeMainLine]} {
    set ::enginewin::pv_(postponed,$id) ""
    set ::engine::calls {}
    # Plies 1 and 2 are seeded, 3 to 6 are searched: ply 0 is the only gap left.
    set ::enginewin::pv_(seeded,$id) [dict create 1 1 2 1]
    set ::enginewin::pv_(depths,$id) [dict create 3 20 4 20 5 20 6 20]
    checkEq "Autorun queues the one unsearched position" [::enginewin::analyzeMainLine $id] 1
    checkEq "it is the start position" [llength $::engine::calls] 1
    checkEq "and the Go is for the start position" \
        [goPosition 0] {position startpos moves}
    check "the depth map did not swallow a seeded ply" [expr {![dict exists $::enginewin::pv_(depths,$id) 1]}]

    # A seeded ply in the middle: the gap before it is what gets queued.
    set ::engine::calls {}
    set ::enginewin::pv_(seeded,$id) [dict create 2 1]
    set ::enginewin::pv_(depths,$id) [dict create 3 18 4 18 5 18 6 18]
    checkEq "Autorun queues around a seeded ply" [::enginewin::analyzeMainLine $id] 1
    checkEq "the gap is ply 1" [goPosition 0] {position startpos moves e2e4}

    # Everything seeded: nothing to do, which is the whole point of the markers.
    set ::engine::calls {}
    set ::enginewin::pv_(seeded,$id) [dict create 0 1 1 1 2 1 3 1 4 1]
    checkEq "a fully seeded game needs no Autorun pass" [::enginewin::analyzeMainLine $id] 0
    checkEq "and nothing was sent" [llength $::engine::calls] 0
}

# ------------------------------- finding 1: a manual search reaches the chart --
puts "\n== a manual search at a seeded ply is not discarded =="
if {[have ::enginewin::updateChart]} {
    set ::enginewin_chartH($id) 30
    set ::enginewin::pv_(pos,$id) "position startpos moves e2e4"
    set ::enginewin::pv_(btm,$id) 0
    set ::enginewin::pv_(seeded,$id) [dict create 2 1]
    set ::enginewin::pv_(depths,$id) [dict create]
    set ::enginewin::pv_(ply,$id) 2
    set ::chart::calls {}
    set ::chart::points {}
    set ::annot::calls {}
    ::enginewin::updateChart $id {1 20 24 1000 5000 3 0 400 34 cp {} e2e4 e7e5}

    checkEq "rapid_annotate got the position" [lindex [lindex $::annot::calls 0] 1] 2
    checkEq "with the score it searched" [lindex [lindex $::annot::calls 0] 3] 34
    checkEq "and the chart got the point" [dict get $::chart::points 2] 34
    check "the depth is recorded as searched" [dict exists $::enginewin::pv_(depths,$id) 2]

    # updateChart itself is untouched: a genuinely deeper earlier search at a
    # ply still wins over a shallower manual one.
    set ::chart::calls {}
    set ::annot::calls {}
    set ::enginewin::pv_(depths,$id) [dict create 7 30]
    set ::enginewin::pv_(ply,$id) 7
    ::enginewin::updateChart $id {1 18 22 1000 5000 3 0 400 20 cp {} e2e4}
    checkEq "a shallower result than the stored depth is dropped" [llength $::annot::calls] 0
    checkEq "and nothing reaches the chart" [llength $::chart::calls] 0
}

# ----------------------------------- finding 2: the restore is path-aware --
puts "\n== seedChart puts a board in a nested variation back =="
if {[have ::enginewin::seedChart]} {
    ::board::reset 6 [dict create 1 {[%eval 0.20]} 2 {[%eval -0.35]}]
    set ::enginewin::pv_(depths,$id) [dict create]
    set ::enginewin::pv_(seeded,$id) {}
    set ::chart::points {}
    # Two levels in: variation 2 at main-line ply 4, then variation 1 inside it,
    # two moves into that one. The ply counter alone (7) says nothing about it.
    sc_move ply 4
    sc_var enter 2
    sc_var enter 1
    sc_move forward 1
    set wasFen [sc_pos fen]
    set wasLoc [sc_pos location]
    set wasLevel [sc_var level]
    checkEq "the cursor starts seven plies in, two levels down" $wasLoc 7
    checkEq "and two variations deep" $wasLevel 2

    set ::board::moves {}
    set count [::enginewin::seedChart $id]
    checkEq "the walk still seeded the main line" $count 2
    checkEq "the board came back to the same position" [sc_pos fen] $wasFen
    checkEq "at the same ply counter" [sc_pos location] $wasLoc
    checkEq "and in the same variation" [sc_var level] $wasLevel
    checkEq "the innermost variation is the one it was in" [sc_var number] 1
    check "the walk did happen" \
        [expr {[llength [lsearch -all -inline -exact $::board::moves {sc_move ply 1}]] == 1}]
}

puts "\n== a restore that falls back keeps the saved base =="
if {[have ::enginewin::seedChart]} {
    ::board::reset 6 [dict create 1 {[%eval 0.20]}]
    set ::enginewin::pv_(depths,$id) [dict create]
    set ::enginewin::pv_(seeded,$id) {}
    set ::chart::points {}
    # The cursor is at absolute ply 7, two levels down, branching from ply 4.
    sc_move ply 4
    sc_var enter 2
    sc_var enter 1
    sc_move forward 1
    # A restore that reports 0 could not re-enter the variation and left the
    # board on the saved main-line base: that base is a known position and must
    # be kept. The absolute counter (7) is a different position altogether.
    rename ::review::cursorRestore ::review::cursorRestoreReal
    proc ::review::cursorRestore {state} { sc_move ply 4 ; return 0 }
    set ::board::moves {}
    set count [::enginewin::seedChart $id]
    checkEq "the walk still seeded the main line" $count 1
    checkEq "the board is on the saved base" [sc_pos location] 4
    check "and the fallback did not jump to the absolute ply" \
        [expr {[lsearch -exact $::board::moves {sc_move ply 7}] < 0}]
    rename ::review::cursorRestore {}
    rename ::review::cursorRestoreReal ::review::cursorRestore
}

# ----------------------------------------- finding 3: the empty-score label --
puts "\n== the chart's click path passes an empty score =="
if {[have ::enginewin::seedLabel]} {
    ::board::reset 6 {}
    set ::board::moves {}
    set err [catch { ::enginewin::seedLabel 5 "" } label]
    checkEq "a click does not raise" $err 0
    checkEq "and answers with the move it points at" $label {3. stored}
    check "the click navigated" \
        [expr {[lsearch -exact $::board::moves {sc_move start 1}] >= 0
               && [lsearch -exact $::board::moves {sc_move forward 5}] >= 0}]

    set err [catch { ::enginewin::seedLabel 4 34 } label]
    checkEq "a real score still formats" $err 0
    checkEq "with its move and its evaluation" $label "2... stored\n+0.34"
}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
