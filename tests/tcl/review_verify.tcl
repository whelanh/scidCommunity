#!/usr/bin/env tclsh
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_verify.tcl -- the Brilliant/Great second opinion, without an engine.
#
#   tclsh tests/tcl/review_verify.tcl
#
# Two halves. The first is the verifier's own decision, as pure functions over
# result records: which positions are re-searched, and what a second engine's
# answer means. The second drives the three writers that write a review - the
# pass, the batch annotator and Rapid Annotate - and checks that each one calls
# the shared transform once and writes what it answered.
#
# The second engine itself is not run here (tests/tcl/review_verify_engine.tcl
# does that, through the driver's own queue). What is pinned here is the rule: a
# correction only ever moves a Brilliant or Great move down to Best, and a
# verification that found nothing usable changes nothing at all.

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

proc ::options.store {args} {}
set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools score_seed.tcl]
source [file join $root tcl enginecfg.tcl]
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools game_review.tcl]
source [file join $root tcl tools review_driver.tcl]
source [file join $root tcl tools review_verify.tcl]
source [file join $root tcl tools review_annotate.tcl]
source [file join $root tcl tools batch_annotate.tcl]
source [file join $root tcl tools rapid_annotate.tcl]
source [file join $root tests tcl game_stub.tcl]

# The application the batch and rapid writers report to. The game itself is the
# stub above; these are the notifications and the undo marker around it.
namespace eval ::notify {}
proc ::notify::DatabaseModified {args} {}
proc ::notify::PosChanged {args} {}
namespace eval ::ERROR {}
proc ::ERROR::MessageBox {} {}
proc undoFeature {args} {}
# No Tk in a tclsh harness: a window that is not there is not refreshed.
proc winfo {args} { return 0 }

# The board the write half drives: four moves, every one the engine's own choice
# at its reference position, so the ladder calls each of them Best and a
# correction is the only thing that can move one.
namespace eval ::fx {}
proc ::fx::map {} {
    return [dict create plies 4 \
        moves [dict create 1 e2e4 2 e7e5 3 g1f3 4 b8c6] \
        positions [dict create \
            0 {position startpos} \
            1 {position startpos moves e2e4} \
            2 {position startpos moves e2e4 e7e5} \
            3 {position startpos moves e2e4 e7e5 g1f3} \
            4 {position startpos moves e2e4 e7e5 g1f3 b8c6}]]
}
proc ::fx::results {} {
    return [dict create \
        0 [dict create 1 [list 20 30 cp {e2e4 e7e5}]] \
        1 [dict create 1 [list 20 20 cp {e7e5 g1f3}]] \
        2 [dict create 1 [list 20 25 cp {g1f3 b8c6}]] \
        3 [dict create 1 [list 20 10 cp {b8c6 d2d4}]] \
        4 [dict create 1 [list 20 5 cp {d2d4 d7d5}]]]
}
proc ::fx::reset {} {
    ::gamestub::reset [list {e4 e2e4} {e5 e7e5} {Nf3 g1f3} {Nc6 b8c6}]
}

##############################################################################
puts "\nwhich positions are verified"

# The labels a pass decided. Only Brilliant and Great are re-searched; a Best or
# a mistake has nothing a second engine can add.
set labels [dict create 1 best 2 brilliant 3 good 4 great]
set jobs [::reviewverify::jobs [::fx::map] [::fx::results] $labels 0]
checkEq "only Brilliant and Great are re-searched" [llength $jobs] 2
checkEq "a job carries the move, the reference position, its spec, the move the \
first engine chose and the label" \
    [lindex $jobs 0] [list 2 1 {position startpos moves e2e4} e7e5 brilliant]
checkEq "the next candidate's reference position follows the previous move" \
    [lindex $jobs 1 1] 3

puts "\nbook still wins"

set jobs [::reviewverify::jobs [::fx::map] [::fx::results] \
    [dict create 2 brilliant 4 great] 2]
checkEq "a candidate inside the book is not re-searched" \
    [llength $jobs] 1
checkEq "and the one past the book is" [lindex $jobs 0 0] 4
# Move Comment names one ply and the driver sets bookEnd 0 for it: the reader
# asked about that move, so the book must not skip it.
set jobs [::reviewverify::jobs [::fx::map] [::fx::results] \
    [dict create 2 brilliant] 0]
checkEq "a named ply is verified even when it is in the book" [llength $jobs] 1

puts "\na position the snapshot cannot name is not verified"

set thin [dict create plies 4 moves [dict create 2 e7e5] \
    positions [dict create 0 {position startpos} 2 {position startpos moves e2e4 e7e5}]]
set jobs [::reviewverify::jobs $thin [::fx::results] [dict create 2 brilliant] 0]
checkEq "a missing reference position is dropped" $jobs {}

##############################################################################
puts "\nthe second engine agrees"

proc lines {top second {s1 30} {s2 10}} {
    set l [dict create 1 [list 20 $s1 cp [list $top d5]]]
    if {$second ne ""} { dict set l 2 [list 20 $s2 cp [list $second d5]] }
    return $l
}
set brilliantJob [list [list 2 1 x e7e5 brilliant]]
set greatJob [list [list 4 3 x b8c6 great]]

checkEq "a Brilliant move the second engine also prefers keeps its label" \
    [::reviewverify::corrections $brilliantJob [dict create 1 [lines e7e5 g1f3]]] {}

# Great is a claim about the gap between the best and the second line: with a
# 200 cp gap the second engine confirms it, and nothing is corrected.
checkEq "a Great move with its gap confirmed keeps its label" \
    [::reviewverify::corrections $greatJob [dict create 3 [lines b8c6 d2d4 300 50]]] {}

##############################################################################
puts "\nand when it does not"

checkEq "a different best move withdraws the label" \
    [::reviewverify::corrections $brilliantJob [dict create 1 [lines g1f3 e7e5]]] \
    [dict create 2 best]
# The extra reply the Great claim needs: without the second line there is no gap
# to confirm. Two lines that are only 150 cp apart are a disagreement.
checkEq "a Great move whose gap is not there is withdrawn" \
    [::reviewverify::corrections $greatJob [dict create 3 [lines b8c6 d2d4 200 50]]] \
    [dict create 4 best]
checkEq "the correction is Best, the next label down" \
    [dict get [::reviewverify::corrections $greatJob [dict create 3 [lines b8c6 d2d4 200 50]]] 4] \
    best

puts "\nnever an upgrade"

# Both Brilliant and Great sit above Best; a correction that answered anything
# better would be a promotion, and the verifier never makes one.
set corr [::reviewverify::corrections $brilliantJob [dict create 1 [lines g1f3 e7e5]]]
check "the only label a correction can write is Best" [expr {$corr eq [dict create 2 best]}]
checkEq "a correction never carries the label it replaces" \
    [dict exists $corr 2] 1
# A move nobody called Brilliant or Great is not even a job: a miss stays a miss,
# and cannot be turned into a blunder by a second opinion.
set missLabels [dict create 1 best 2 miss 3 mistake 4 blunder]
checkEq "a miss is not a candidate" \
    [::reviewverify::jobs [::fx::map] [::fx::results] $missLabels 0] {}
checkEq "so no verification can touch it" \
    [::reviewverify::corrections {} [dict create 1 [lines g1f3 e7e5]]] {}

##############################################################################
puts "\nfail closed"

# A verifier that answered nothing, or answered something unusable, leaves the
# label exactly as the search produced it. "No evidence" is not a disagreement.
checkEq "no answer changes nothing" \
    [::reviewverify::corrections $brilliantJob {}] {}
checkEq "an empty result for the position changes nothing" \
    [::reviewverify::corrections $brilliantJob [dict create 1 {}]] {}
checkEq "a line with no best move changes nothing" \
    [::reviewverify::corrections $brilliantJob [dict create 1 [dict create 1 [list 20 30 cp {}]]]] {}
# Great needs the second line; a one-line answer cannot confirm the gap and
# cannot withdraw the label either - it has not measured the claim.
checkEq "a Great claim with no second line changes nothing" \
    [::reviewverify::corrections $greatJob [dict create 3 [lines b8c6 ""]]] {}
# A bound is not a measurement, and lineScore refuses it: the gap is unknown.
set bound [dict create 1 [list 20 30 cp {b8c6 d2d4}]]
dict set bound 2 [list 20 10 lowerbound {d2d4 d7d5}]
checkEq "a Great claim measured only by a bound changes nothing" \
    [::reviewverify::corrections $greatJob [dict create 3 $bound]] {}

puts "\na mate score is a score"

# The second engine agreeing on a mate is an agreement like any other: lineScore
# encodes it, and the label stays.
set mate [dict create 1 [list 20 3 mate {e7e5 d5} ]]
checkEq "a mate the second engine also finds keeps the label" \
    [::reviewverify::corrections $brilliantJob [dict create 1 $mate]] {}
set mate2 [dict create 1 [list 20 -2 mate {g1f3 d5}]]
checkEq "a mate for the other side is a different move" \
    [::reviewverify::corrections $brilliantJob [dict create 1 $mate2]] \
    [dict create 2 best]

##############################################################################
puts "\nthe shared transform"

set raw [::fx::results]
check "no corrections is the identity" \
    [expr {[::reviewdriver::verified $raw {}] eq $raw}]
set adjusted [::reviewdriver::verified $raw [dict create 2 best]]
check "no corrections means no key is added" \
    [expr {![dict exists [::reviewdriver::verified $raw {}] corrections]}]
checkEq "with corrections the results carry them" \
    [dict get $adjusted corrections] [dict create 2 best]

# What a writer sees: the label the verifier agreed with.
set sides [::reviewdriver::sides [::fx::map]]
checkEq "a Brilliant label the verifier withdrew is written as Best" \
    [::reviewdriver::labelRank best] 3
checkEq "a correction is applied to the judged move" \
    [dict get [::reviewdriver::judge [::fx::map] $adjusted $sides 2] label] best

# The guard: a corrections dict can only ever move a label down.
set up [::reviewdriver::verified $raw [dict create 2 brilliant]]
checkEq "a correction cannot promote a move" \
    [dict get [::reviewdriver::judge [::fx::map] $up $sides 2] label] best
set down [::reviewdriver::verified $raw [dict create 2 good]]
checkEq "a correction below the label is applied" \
    [dict get [::reviewdriver::judge [::fx::map] $down $sides 2] label] good

# And the labels of the moves nobody corrected are untouched.
set verdicts [::reviewdriver::verdicts [::fx::map] $down]
checkEq "an uncorrected move keeps its own label" [lindex [dict get $verdicts 3] 0] best

##############################################################################
puts "\nevery writer calls it once and writes its output"

# The transform is counted, not mocked: each path below runs its own writer for
# real, into the game stub, and the counter says how often the shared transform
# was consulted.
rename ::reviewdriver::verified ::reviewverify_verified_
set ::verifyCalls 0
proc ::reviewdriver::verified {results corrections} {
    incr ::verifyCalls
    return [::reviewverify_verified_ $results $corrections]
}
proc resetCalls {} { set ::verifyCalls 0 }
proc labelWord {label} { return [::movelabels::text $label] }

# A correction to a label below Best, so the write it causes is visible: the
# verifier's own rule only ever answers Best, which a Best move already is.
set visible [dict create 2 good]
set want [::review::commentText good 25]

puts "\n  the pass"

::fx::reset
resetCalls
set map [::fx::map]
set p [dict create map $map plan {1 2 3 4} plies 4 bookEnd 0 mpv 3 \
    writer ::reviewdriver::writeResults verifier "" limits {} \
    cursor [::review::cursorSave] notify 0 coach 0 report 0 token pass1]
::reviewdriver::writeRun $p [::fx::results] $visible
checkEq "the pass consults the transform once" $::verifyCalls 1
checkEq "and writes the label it answered" \
    [dict get [::gamestub::commentsByPly] 2] $want

puts "\n  the batch annotator"

::fx::reset
resetCalls
set ::batch_annotate::base 0
set bres [::fx::results]
set bp [dict create map $map plan {1 2 3 4} plies 4 bookEnd 0 mpv 3]
::batch_annotate::writeGame pipe0 1 $map {1 2 3 4} 0 $bp $bres $visible
checkEq "the batch consults the transform once" $::verifyCalls 1
checkEq "and writes the label it answered" \
    [dict get [::gamestub::commentsByPly] 2] $want

puts "\n  rapid annotate"

::fx::reset
resetCalls
set rres [::fx::results]
set rp [dict create map $map plan {1 2 3 4} plies 4 bookEnd 0 mpv 3]
::rapid_annotate::writeCommit $rp 1 0 0 $rres $visible
checkEq "rapid annotate consults the transform once" $::verifyCalls 1
checkEq "and writes the label it answered" \
    [dict get [::gamestub::commentsByPly] 2] $want

puts "\n  and the writer's own output, not the raw results"

# The label in the game comes from the transform's answer: with no corrections
# the same game is written with the label the search produced.
::fx::reset
resetCalls
::reviewdriver::writeRun $p [::fx::results] ""
checkEq "without corrections the label is the search's own" \
    [dict get [::gamestub::commentsByPly] 2] [::review::commentText best 25]
checkEq "and the transform still saw it" $::verifyCalls 1

puts "\n  the verifier's searches fail: nothing changes"

# Acceptance 3, at the level the writers see it: an all-flat run - every
# verification search answered nothing - writes exactly what an unverified
# review would.
::fx::reset
resetCalls
set flat [::reviewverify::corrections $brilliantJob {}]
::reviewdriver::writeRun $p [::fx::results] $flat
checkEq "a verifier that answered nothing corrects nothing" $flat {}
checkEq "and the write is the unverified one" \
    [dict get [::gamestub::commentsByPly] 2] [::review::commentText best 25]

##############################################################################
puts "\nthe three callers reach the seam"

# The section above calls each writer directly. These drive the callers that
# decide to write - ::reviewdriver::runDone, ::batch_annotate::finalize_game and
# ::rapid_annotate::commit - with the seam itself stubbed. What is pinned here is
# that each of them arrives at ::reviewdriver::verifyWrite rather than calling a
# writer on its own, which is the fault #380 warns about: a hook only the single
# game review passes through would leave the batch and Rapid Annotate with the
# labels a lone engine produced. The verifier's own search and its fail-closed
# rule are tested in tests/tcl/review_verify_engine.tcl; the stub below answers
# at once, which is the shape of "a verifier is configured".
rename ::reviewdriver::verifyWrite ::reviewverify_verifyWrite_
set ::seamCalls {}
proc ::reviewdriver::verifyWrite {p results write} {
    lappend ::seamCalls [dict create p $p results $results write $write]
    # Answer it now, with a correction the writer must apply, so what lands is
    # the writer's output and not a write the caller made by hand.
    {*}$write $results [dict create 2 good]
    return 0
}

puts "\n  the pass"

::fx::reset
set ::seamCalls {}
resetCalls
set map [::fx::map]
set p [dict create map $map plan {1 2 3 4} plies 4 bookEnd 0 mpv 3 \
    writer ::reviewdriver::writeResults verifier Komodo limits {} \
    positions {{0 {position startpos}} {1 {position startpos moves e2e4}}} \
    cursor [::review::cursorSave] notify 0 coach 0 report 0 token pass1]
set ::reviewdriver::pass $p
set ::reviewdriver::state {}
::reviewdriver::runDone [::fx::results]
checkEq "the pass's completion reaches the seam" [llength $::seamCalls] 1
checkEq "with the pass it was given" [dict get [lindex $::seamCalls 0] p] $p
checkEq "and the pass writes the label the seam answered" \
    [dict get [::gamestub::commentsByPly] 2] $want
checkEq "the pass is over once it has written" $::reviewdriver::pass {}

puts "\n  the batch annotator"

::fx::reset
set ::seamCalls {}
rename ::batch_annotate::assign_game ::batch_assign_real_
proc ::batch_annotate::assign_game {pipe} { incr ::assignCalls }
rename ::review::verifier ::review_verifier_real_
proc ::review::verifier {} { return Komodo }
set ::assignCalls 0
set map [::fx::map]
set ::batch_annotate::pipe_game(pipe0) 1
set ::batch_annotate::pipe_evals(pipe0) [::fx::results]
set ::batch_annotate::pipe_map(pipe0) $map
set ::batch_annotate::pipe_plan(pipe0) {1 2 3 4}
set ::batch_annotate::pipe_book(pipe0) 0
set ::batch_annotate::base 0
set ::batch_annotate::games_completed 0
set ::batch_annotate::unscored_plies 0
::batch_annotate::finalize_game pipe0
checkEq "the next game is started before the write" $::assignCalls 1
checkEq "the batch reaches the seam" [llength $::seamCalls] 1
checkEq "carrying the verifier Review Settings names" \
    [dict get [lindex $::seamCalls 0] p verifier] Komodo
checkEq "and the pass's depth" [dict get [lindex $::seamCalls 0] p limits depth] 18
checkEq "the batch writes the label the seam answered" \
    [dict get [::gamestub::commentsByPly] 2] $want

puts "\n  rapid annotate"

::fx::reset
set ::seamCalls {}
# The stub board has no read-only flag, and Rapid Annotate asks before it
# writes; a database that says nothing there is not writable, it is unreadable.
rename sc_base ::gamestub_sc_base
proc sc_base {sub args} {
    if {$sub eq "isReadOnly"} { return 0 }
    return [::gamestub_sc_base $sub {*}$args]
}
rename ::rapid_annotate::evals ::rapid_evals_real_
proc ::rapid_annotate::evals {} {
    # The chart's own shape: White's pawns, side to move unknown to the graph.
    return [dict create \
        1 [dict create depth 10 score 0.30 score_fmt +0.30 pv {e7e5}] \
        2 [dict create depth 12 score -0.50 score_fmt -0.50 pv {g1f3}]]
}
set ok [::rapid_annotate::commit]
checkEq "rapid annotate reaches the seam" [llength $::seamCalls] 1
checkEq "and the write it asked for is committed" $ok 1
# The rapid path's own score is the graph's, so the label is what is compared:
# the seam's correction is the thing this test is about.
checkEq "rapid annotate writes the label the seam answered" \
    [lindex [split [dict get [::gamestub::commentsByPly] 2]] 0] \
    [lindex [split $want] 0]

# Everything the stubs took is put back: the harness leaves the tree it loaded
# as it found it, so a later section cannot pass on a stub it did not ask for.
rename ::reviewdriver::verifyWrite {}
rename ::reviewverify_verifyWrite_ ::reviewdriver::verifyWrite
rename ::batch_annotate::assign_game {}
rename ::batch_assign_real_ ::batch_annotate::assign_game
rename ::review::verifier {}
rename ::review_verifier_real_ ::review::verifier
rename ::rapid_annotate::evals {}
rename ::rapid_evals_real_ ::rapid_annotate::evals
rename sc_base {}
rename ::gamestub_sc_base sc_base
unset -nocomplain ::batch_annotate::pipe_game(pipe0) ::batch_annotate::pipe_evals(pipe0) \
    ::batch_annotate::pipe_map(pipe0) ::batch_annotate::pipe_plan(pipe0) \
    ::batch_annotate::pipe_book(pipe0)

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
