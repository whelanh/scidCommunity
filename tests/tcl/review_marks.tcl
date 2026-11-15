#!/usr/bin/env tclsh
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_marks.tcl -- the marks ::reviewannotate holds for the review writer.
#
#   tclsh tests/tcl/review_marks.tcl
#
# tcl/tools/review_annotate.tcl is no longer a pass. #437 §5 retired the legacy
# Annotate dialog, its writer and its run state with the Analysis window, and
# what is left is two hooks the review writer calls behind `info commands`
# guards (tcl/tools/review_driver.tcl:1425, :1469):
#
#   * ::reviewannotate::writeTactical, from inside the move loop, for
#     MarkTacticalExercises - the game's T flag and the
#     "****D<difficulty> <before>-><after>" comment on the move that made it a
#     puzzle;
#   * ::reviewannotate::openingMark, after the loop, for FindOpeningErrors - the
#     "opBlunder <move> (<side>)" entry in the game's Annotator tag, at the ply
#     the opening book ended.
#
# Both are shipped behaviour for every pass that writes a whole game (Game
# Review, the engine window's review, the Game List batch, Rapid Annotate), so
# they keep a harness of their own once the annotate pass and its tests are
# gone. Each one is checked against the game the stub writes into
# (tests/tcl/game_stub.tcl), not against a mock of the writer.
#
# The checks that used to sit beside these - the drop ladder, the diagram tag,
# the tier-2 prose, the book walk, the run and its Cancel - tested the writer
# and the pass that this change deletes; they went with them.

set fails 0
set checks 0
proc check {name cond {detail ""}} {
    global fails checks
    incr checks
    if {![uplevel 1 [list expr $cond]]} {
        incr fails
        if {$detail eq ""} { puts "FAIL $name" } else { puts "FAIL $name -- $detail" }
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

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tests tcl game_stub.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools score_seed.tcl]
source [file join $root tcl enginecfg.tcl]
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools comment_colors.tcl]
source [file join $root tcl tools game_review.tcl]
source [file join $root tcl tools review_driver.tcl]

# The Informant thresholds the exercise gate reads are options in the real
# session (tcl/options.tcl informantDefaults); the harness sets the same values.
array set informant {!? 0.3 ?! 0.3 ? 0.8 ?? 1.5 += 0.5 +/- 1.5 +- 2.5 +-- 4.0}

if {[catch {source [file join $root tcl tools review_annotate.tcl]} err]} {
    puts "FAIL cannot load tcl/tools/review_annotate.tcl: $err"
    puts "checks $checks fails [expr {$fails + 1}]"
    exit 1
}

# The module is the two hooks and what they need, and nothing that runs a pass.
set kept {}
foreach name {whiteScore setting exercise difficulty whiteVerdict writeTactical
              markExercise openingTag openingMark appendAnnotator} {
    checkEq "::reviewannotate::$name is defined" \
        [expr {[llength [info commands ::reviewannotate::$name]] > 0}] 1
    lappend kept ::reviewannotate::$name
}
checkEq "and nothing else is" [lsort [info commands ::reviewannotate::*]] [lsort $kept]

# A game both halves of this file can drive.
proc fixture {} {
    ::gamestub::reset [list \
        {e4 e2e4} {e5 e7e5} {Nf3 g1f3} {Nc6 b8c6} {Bb5 f1b5} {a6 a7a6}]
}

### 1. The scores the marks compare #############################################
#
# The review's lines are the engine's own (side to move); the exercise's
# thresholds are in White's point of view, as the classic annotator kept them.

checkEq "a side-to-move score on White's move is White's" \
    [::reviewannotate::whiteScore 120 white] 120
checkEq "and flips on Black's" [::reviewannotate::whiteScore 120 black] -120
checkEq "an empty score stays empty" [::reviewannotate::whiteScore "" black] ""

# Review Settings' switches: the review layer owns them, and a harness without
# game_review.tcl gets the default rather than an error mid-write.
::review::reset
checkEq "an unset switch is the default asked for" \
    [::reviewannotate::setting tactical_exercises 0] 0
::review::setValue tactical_exercises 1
checkEq "a set switch is 1" [::reviewannotate::setting tactical_exercises 0] 1
::review::setValue tactical_exercises 0
checkEq "and 0 when it is off" [::reviewannotate::setting tactical_exercises 1] 0
rename ::review::get ::review::getSaved
checkEq "a missing ::review::get is the default, not an error" \
    [::reviewannotate::setting tactical_exercises 7] 7
rename ::review::getSaved ::review::get

### 2. The exercise: T flag, difficulty comment and the move's NAG ##############

fixture
::review::reset
::review::setValue tactical_exercises 1
sc_move ply 5
sc_pos setComment "12:+0.50"
checkEq "the exercise is written" \
    [::reviewannotate::exercise 5 "??" 3 0.5 -1.2] 1
checkEq "the game is flagged T" $::gamestub::flags "T"
checkEq "the comment carries the difficulty and both scores" \
    [sc_pos getComment] "****D3 0.5->-1.2 12:+0.50"
checkEq "the move carries its mark" [dict get [::gamestub::nagsByPly] 5] "??"

# A second run replaces the prefix it wrote, rather than stacking a second one.
fixture
sc_move ply 5
::reviewannotate::exercise 5 "??" 3 0.5 -1.2
::reviewannotate::exercise 5 "??" 3 0.5 -1.2
checkEq "a second exercise replaces the prefix, not stacks it" \
    [sc_pos getComment] "****D3 0.5->-1.2"
checkEq "and the flag is on the game" \
    [expr {[lsearch -exact $::gamestub::flags T] >= 0}] 1

# The difficulty is the timing ladder: the shortest budget at which the engine
# still finds the move, plus one. The stub answers e2e4 while it has it and
# d2d4 after, so the break is at index 4 and the difficulty is 6.
fixture
::gamestub::queueReplies [list [list 0 e2e4] [list 0 e2e4] [list 0 e2e4] \
    [list 0 e2e4] [list 0 d2d4] [list 0 e2e4] [list 0 e2e4] [list 0 e2e4]]
checkEq "the ladder measures the budget that finds it" [::reviewannotate::difficulty e2e4] 6

### 3. The exercise gate ########################################################

# A pass with the switch off marks nothing, however good the position.
fixture
::review::reset
checkEq "no switch, no exercise" \
    [::reviewannotate::markExercise 0 -400 "" {{-400 {e7e5}} {0 {d2d4}}} ] 0
checkEq "and the game carries no flag" $::gamestub::flags ""

# One line is not a puzzle: the gate needs a best move to be better than.
::review::setValue tactical_exercises 1
fixture
sc_move ply 1
checkEq "a single line is not a puzzle" \
    [::reviewannotate::markExercise 0 -400 "" {{-400 {e7e5}}}] 0

# The gates pass: the drop is over the blunder threshold, the best move is much
# better than the second, and the shallow search does not find it.
fixture
sc_move ply 1
::gamestub::queueReplies [list [list 0 d2d4] [list 0 d2d4] [list 0 d2d4] \
    [list 0 e2e4] [list 0 e2e4] [list 0 e2e4] [list 0 e2e4] [list 0 e2e4]]
set marked [::reviewannotate::markExercise 0 -400 "" {{-400 {e2e4}} {0 {d2d4}}}]
checkEq "a real puzzle is marked" $marked 1
checkEq "the game is flagged T" $::gamestub::flags "T"
checkHas "and the comment names a difficulty" [sc_pos getComment] "****D"
checkEq "the mark itself is the caller's: nothing is added here" \
    [dict exists [::gamestub::nagsByPly] 1] 0

### 4. writeTactical: only a "?" or "??" move is offered ########################

# The driver passes the NAG it wrote. A quiet verdict is not a puzzle mark, and
# the hook must not write an exercise on the back of one.
fixture
sc_move ply 1
set results [dict create 1 [dict create 1 [list 18 -400 cp {e2e4}] \
                                      2 [list 18 0 cp {d2d4}]]]
checkEq "a good move is not offered" \
    [::reviewannotate::writeTactical 1 [dict create before 0 after 0 eval_cp "" label best isBest 1] \
        w $results 2 "!"] 0
checkEq "and nothing was written" $::gamestub::flags ""

# A "??" is: the same results, the driver's own mark, and the exercise lands.
fixture
sc_move ply 1
::gamestub::queueReplies [list [list 0 d2d4] [list 0 d2d4] [list 0 d2d4] \
    [list 0 e2e4] [list 0 e2e4] [list 0 e2e4] [list 0 e2e4] [list 0 e2e4]]
checkEq "a ? move is offered to the exercise gate" \
    [::reviewannotate::writeTactical 1 \
        [dict create before 0 after -400 eval_cp "" label blunder isBest 0] w $results 2 "?"] 1
checkEq "and the game is flagged T" $::gamestub::flags "T"

# The mark with no NAG from the caller comes from the verdict's own label.
fixture
sc_move ply 1
::gamestub::queueReplies [list [list 0 d2d4] [list 0 d2d4] [list 0 d2d4] \
    [list 0 e2e4] [list 0 e2e4] [list 0 e2e4] [list 0 e2e4] [list 0 e2e4]]
checkEq "the label's own mark is enough" \
    [::reviewannotate::writeTactical 1 \
        [dict create before 0 after -400 eval_cp "" label blunder isBest 0] w $results 2] 1
checkEq "and it is the same T flag" $::gamestub::flags "T"

### 5. The opening-errors tag ###################################################

checkEq "a move inside the opening window is tagged" \
    [::reviewannotate::openingTag 6 black 10] "opBlunder 6 (black)"
checkEq "a move past it is not" [::reviewannotate::openingTag 12 black 10] ""
checkEq "a non-numeric move number is not" [::reviewannotate::openingTag x black 10] ""

# The tag the finder leaves is appended to the game's Annotator tag, keeping what
# a first pass put there.
fixture
::reviewannotate::appendAnnotator "Stockfish 16 (1 sec)"
checkEq "the annotator tag is created" \
    [string trim $::gamestub::annotator] "Annotator \"Stockfish 16 (1 sec)\""
::reviewannotate::appendAnnotator "opBlunder 6 (black)"
checkEq "a second entry is appended to the same tag" \
    [string trim $::gamestub::annotator] \
    "Annotator \"Stockfish 16 (1 sec), opBlunder 6 (black)\""
checkEq "the same entry twice is not appended twice" \
    [::reviewannotate::appendAnnotator "opBlunder 6 (black)"] 1
checkEq "and the tag did not grow" \
    [string trim $::gamestub::annotator] \
    "Annotator \"Stockfish 16 (1 sec), opBlunder 6 (black)\""
checkEq "an empty entry writes nothing" [::reviewannotate::appendAnnotator ""] 0

# A quote in the value would close the tag's string: a name is not prose.
fixture
::reviewannotate::appendAnnotator {Stock "fish" 16}
checkHas "a quote in the name is replaced" \
    [string trim $::gamestub::annotator] "Stock 'fish' 16"

### 6. openingMark: the tag, from the pass, at the book's end ####################

fixture
::review::reset
checkEq "no switch, no tag" \
    [::reviewannotate::openingMark [dict create bookEnd 1 plies 6]] 0

::review::setValue opening_errors 1
fixture
checkEq "no book end, no tag" \
    [::reviewannotate::openingMark [dict create bookEnd 0 plies 6]] 0
checkEq "a pass that never left the book has no tag" \
    [::reviewannotate::openingMark [dict create bookEnd 6 plies 6]] 0

fixture
checkEq "a pass with a real book end is tagged" \
    [::reviewannotate::openingMark [dict create bookEnd 1 plies 6]] 1
checkHas "at the ply the book ended, in the game's Annotator tag" \
    $::gamestub::annotator "opBlunder 1 (black)"
checkEq "and the board is put back" $::gamestub::cursor 0

# The window the user asked for moves the tag: the same pass, a window of one
# move, and the departure at move 1 is inside it.
fixture
::review::setValue opening_window 1
checkEq "the settings' window is what the tag is measured from" \
    [::reviewannotate::openingMark [dict create bookEnd 1 plies 6]] 1
::review::setValue opening_window 12

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
