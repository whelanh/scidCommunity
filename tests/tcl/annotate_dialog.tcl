#!/usr/bin/env tclsh
# The annotate dialog's decisions, as pure procs.
#
# The dialog's OK button is the only way into the annotate pipeline, and the
# pass it starts is the review's. What the button decides - which engine, where
# the opening ends, which tier, and whether the pane can run a review at all -
# is decided here, in review_annotate.tcl, so it can be tested without Tk and
# without an engine.
#
# The three decisions this file gates:
#
#   1. ::reviewannotate::dialogPlan - the pane's own preset, the book end the
#      caller walked, tier 1, the batch range, and the refusal for a pane that
#      cannot run a review (the driver's own sentence, not a second one).
#   2. ::reviewannotate::annotates - the classic blunders-only filter
#      (analysis.tcl:826-829), including the decided-position exemption. In
#      blunders-only mode this decides the LABEL as well as the marks: a sparse
#      pass is sparse in every artefact, not only in the NAGs.
#   3. ::reviewannotate::stopLabel - the one Cancel button's context label.
#      "Stop after this game" iff more games follow; "Stop now" otherwise.

set fails 0
set checks 0

proc check {name cond} {
    global fails checks
    incr checks
    if {![uplevel 1 [list expr $cond]]} {
        incr fails
        puts "FAIL $name"
    }
}

proc checkEq {name got want} {
    global fails checks
    incr checks
    if {$got ne $want} {
        incr fails
        puts "FAIL $name -- got '$got' want '$want'"
    }
}

proc checkHas {name haystack needle} {
    global fails checks
    incr checks
    if {[string first $needle $haystack] < 0} {
        incr fails
        puts "FAIL $name -- '$needle' is not in '$haystack'"
    }
}

proc checkHasNot {name haystack needle} {
    global fails checks
    incr checks
    if {[string first $needle $haystack] >= 0} {
        incr fails
        puts "FAIL $name -- '$needle' is in '$haystack'"
    }
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tests tcl game_stub.tcl]
source [file join $root tcl enginecfg.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools score_seed.tcl]
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools game_review.tcl]
source [file join $root tcl tools review_driver.tcl]
if {[catch {source [file join $root tcl tools review_annotate.tcl]} err]} {
    puts "FAIL cannot load tcl/tools/review_annotate.tcl: $err"
    puts "checks $checks fails [expr {$fails + 1}]"
    exit 1
}

# The classic annotator's thresholds (tcl/options.tcl informantDefaults).
array set ::informant {!? 0.3 ?! 0.3 ? 0.8 ?? 1.5 += 0.5 +/- 1.5 +- 2.5 +-- 4.0}

# The dialog's strings are translations, and the test does not load 29 language
# files; it answers the two tags the Cancel button asks for, and records which
# tag was asked.
array set ::translations {
    E,StopNow           {Stop now}
    E,StopAfterThisGame {Stop after this game}
}
set ::trAsked {}
proc ::tr {tag args} {
    lappend ::trAsked $tag
    if {[info exists ::translations(E,$tag)]} { return $::translations(E,$tag) }
    return $tag
}

########################################################################
### 1. Which engine, which book end, which tier

# Two presets: the one an analysis pane can run a review on, and one it cannot.
set ::engines(list) [list \
    [list Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {} {}] \
    [list OldEngine /usr/bin/oldengine {} {} 0 0 {} 0 {} {}]]

foreach wantProc {::reviewannotate::dialogPlan ::reviewannotate::annotates \
        ::reviewannotate::stopLabel} {
    incr checks
    if {[llength [info commands $wantProc]] == 0} {
        incr fails
        puts "FAIL $wantProc is not defined"
    }
}

set settings [dict create \
    game 7 blunders blundersonly batch 0 batchEnd 7 opening 0 openingMoves 12 bookEnd 6]
set plan [::reviewannotate::dialogPlan 2 Stockfish 1 $settings]

checkEq "the engine is the invoking pane's own preset" \
    [lindex [dict get $plan engine] 0] Stockfish
checkEq "the pane travels with the plan" [dict get $plan pane] 2
checkEq "the book end is the one the caller walked" [dict get $plan bookEnd] 6
checkEq "one game, so the range is that game" \
    [list [dict get $plan from] [dict get $plan to]] {7 7}
checkEq "the dialog ships tier 1" [dict get $plan tier] 1
checkEq "a UCI pane is not refused" [dict get $plan refuse] ""

# A pane whose engine is not UCI: the review cannot run on it, and the dialog
# says so in the driver's words rather than inventing a second sentence.
set plan [::reviewannotate::dialogPlan 1 OldEngine 0 $settings]
checkEq "an xboard pane is refused with the driver's sentence" \
    [dict get $plan refuse] {the review needs a UCI engine}
checkEq "and there is no engine to start" [dict get $plan engine] ""
checkEq "nor a book end to pass" [dict get $plan bookEnd] 0

# A pane naming a preset that no longer exists (the user removed it in the
# engine list while the pane was open).
set plan [::reviewannotate::dialogPlan 1 Vanished 1 $settings]
checkEq "a preset that is gone is refused" [dict get $plan refuse] {no engine selected}
checkEq "with no engine either" [dict get $plan engine] ""

# A batch: from the current game to the end the dialog names.
set bsettings [dict create \
    game 5 blunders allmoves batch 1 batchEnd 9 opening 1 openingMoves 15 bookEnd 0]
set plan [::reviewannotate::dialogPlan 1 Stockfish 1 $bsettings]
checkEq "a batch starts at the current game" [dict get $plan from] 5
checkEq "and ends where the dialog says" [dict get $plan to] 9
checkEq "and says it is a batch" [dict get $plan batch] 1
checkEq "the opening finder travels with it" \
    [list [dict get $plan opening] [dict get $plan openingMoves]] {1 15}

# A range that ends before the game it starts from is one game, not a loop that
# runs backwards and annotates nothing.
set bad [dict replace $bsettings batchEnd 3]
set plan [::reviewannotate::dialogPlan 1 Stockfish 1 $bad]
checkEq "a range behind the current game is that game" \
    [list [dict get $plan from] [dict get $plan to]] {5 5}

# Tier 2 (AI prose) is a separate change. A user with a provider configured must
# not have prose written into the game by pressing this dialog's OK.
namespace eval ::auto_comment {}
proc ::auto_comment::providerReady {} { return 1 }
set plan [::reviewannotate::dialogPlan 1 Stockfish 1 $settings]
checkEq "the dialog ships tier 1 whatever the provider says" [dict get $plan tier] 1
rename ::auto_comment::providerReady ""

########################################################################
### 2. The blunders-only filter
###
### The classic's filter (analysis.tcl:826-829): in blunders-only mode a move is
### annotated when it lost more than the blunder threshold, or when it lost
### anything and the position after it is in the mate range (327 pawns is the
### classic's mate encoding) - but never when the game is already lost, because
### then every move loses and the mark explains nothing.

checkEq "all-moves annotates a quiet move" [::reviewannotate::annotates 0 0 0 0.2] 1
checkEq "all-moves annotates a blunder" [::reviewannotate::annotates 0 2 0 2.0] 1
checkEq "blunders-only leaves a quiet move alone" [::reviewannotate::annotates 1 0 0 0.2] 0
checkEq "a drop under the threshold is not a blunder" [::reviewannotate::annotates 1 1 0 0.2] 0
checkEq "a mate-range position is marked for a small drop" \
    [::reviewannotate::annotates 1 1 0 330.0] 1
checkEq "a decided position is left alone" [::reviewannotate::annotates 1 2 1 2.0] 0
checkEq "a blunder in a live position is annotated" \
    [::reviewannotate::annotates 1 2 0 2.0] 1

########################################################################
### 3. The label is filtered with the marks (driven)
###
### The review labels every judged move. In blunders-only mode it must not: the
### label and the [%eval] are filtered by the same predicate as the NAGs, and a
### label an earlier all-moves run wrote on a move this mode does not annotate
### is taken off rather than left behind.

set ::MOVES {{e4 e2e4} {e5 e7e5} {Nf3 g1f3} {Nc6 b8c6} {Bb5 f1b5} {a6 a7a6}}
set ::CPS {20 30 25 30 220 215 210}
set ::BEST [dict create \
    0 {e2e4 e7e5} \
    1 {e7e5 g1f3} \
    2 {g1f3 b8c6} \
    3 {d7d5 e4d5} \
    4 {d2d4 e7e5} \
    5 {f1b5 a7a6} \
    6 {a7a6}]
set ::markTacticalExercises 0
set ::blunderThreshold 1.0
set ::useAnalysisBook 0
set ::addAnnotatorTag 0
set ::isBatchOpening 0
set ::annotateWhiteMoves 1
set ::annotateBlackMoves 1

# One annotate pass's write phase over the fixture, from the evaluations the
# analysis window would have handed it: `cps` are White's-POV centipawns per
# position, `best` the engine's line from each.
proc annotate {cps best {blunders blundersonly}} {
    set ::annotateBlunders $blunders
    set map [::review::mainLineMap [sc_game UCI_mainLine]]
    set results {}
    set i 0
    foreach cp $cps {
        set sign [expr {$i % 2 == 0 ? 1 : -1}]
        dict set results $i [dict create 1 [list 18 [expr {$sign * $cp}] cp [dict get $best $i]]]
        incr i
    }
    set p [dict create map $map plies [dict get $map plies] bookEnd 0 mpv 3]
    set counts [::reviewannotate::writeResults $p $results]
    return [list $counts [::gamestub::commentsByPly]]
}

# The comment at `ply`, or "" when the move carries none: a comment that held
# nothing but the review's tokens is gone once they are taken off, and the stub
# game then reports no comment at all.
proc commentAt {comments ply} {
    if {![dict exists $comments $ply]} { return "" }
    return [dict get $comments $ply]
}

set ::annotateBlunders allmoves
::gamestub::reset $::MOVES
lassign [annotate $::CPS $::BEST allmoves] counts comments
checkEq "all-moves labels every judged move" [dict get $counts written] 6
foreach ply {1 2 3 4 5 6} {
    checkHas "all-moves labels move $ply" [dict get $comments $ply] "\[MoveLabel"
}
checkHas "including the evaluation token" [dict get $comments 1] "\[%eval"

# The same game in blunders-only mode, on a board that still carries the
# all-moves labels: the four-move fixture's only blunder is Black's 4...Nc6, so
# every other move loses its label.
lassign [annotate $::CPS $::BEST blundersonly] counts comments
checkEq "blunders-only writes only the blunder" [dict get $counts written] 1
checkEq "and counts the moves it left alone" [dict get $counts skipped] 5
checkHas "the blunder keeps its label" [commentAt $comments 4] "\[MoveLabelMistake\]"
checkHas "and its evaluation" [commentAt $comments 4] "\[%eval"
foreach ply {1 2 3 5 6} {
    checkHasNot "the label a previous run wrote is taken off move $ply" \
        [commentAt $comments $ply] "\[MoveLabel"
    checkHasNot "and so is its evaluation token on move $ply" \
        [commentAt $comments $ply] "\[%eval"
}

# A decided game: the mover is already five pawns down when it throws two more.
# The classic leaves such a position alone, and a sparse pass must not label it
# either.
set lost {20 30 25 500 480 490 500}
lassign [annotate $lost $::BEST blundersonly] counts comments
checkHasNot "a decided game is not labelled" [commentAt $comments 4] "\[MoveLabel"

########################################################################
### 4. The one Cancel button's label
###
### "Stop now" for a single game; in a batch "Stop after this game", which flips
### to "Stop now" once it has been pressed and the current game is the last one
### that will be finished.

checkEq "a single game's Cancel stops now" [::reviewannotate::stopLabel 0] {Stop now}
checkEq "a batch's Cancel ends after this game" \
    [::reviewannotate::stopLabel 1] {Stop after this game}
check "and it asks for a translated string" [expr {[lsearch -exact $::trAsked StopNow] >= 0}]
check "in the batch it is the other key" \
    [expr {[lsearch -exact $::trAsked StopAfterThisGame] >= 0}]

# Both strings have to exist in the fallback language, or the button shows a
# tag name: this is the gate the 29 language files are held to.
set english [read [open [file join $root tcl lang english.tcl] r]]
close [lindex [file channels] end]
checkHas "the English StopNow string exists" $english "translate E StopNow {Stop now}"
checkHas "the English StopAfterThisGame string exists" $english \
    "translate E StopAfterThisGame {Stop after this game}"

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
