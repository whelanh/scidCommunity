#!/usr/bin/env tclsh
# The parity gate for issue #380 phase C.
#
# One game, annotated twice: once by the classic pipeline
# (tcl/tools/analysis.tcl - the real procs, driven with the same engine
# evaluations the analysis window would have handed them) and once by the review
# (::reviewannotate::writeResults, the write phase annotate mode now uses). The
# artefacts compared are the ones the classic pipeline exists for, read back
# through the exporters that consume them:
#
#   * the PGN NAG stream, rendered by the RTF exporter's own ::rtf::nagToSymbol;
#   * the RTF game walk (::rtf::collectGame), including the board diagram the
#     "D" NAG asks for and which move it lands on;
#   * the exercise: the game's T flag, the filter that selects it, and the
#     "****D<difficulty> <before>-><after>" comment.
#
# Anything that differs is asserted as differing, on purpose: the review also
# writes its label and its [%eval], which is the point of the mode and which the
# classic pipeline never wrote. That difference is named in the test so that a
# later reader does not have to diff two artefacts to find it.

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
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools score_seed.tcl]
source [file join $root tcl tools game_review.tcl]
source [file join $root tcl tools review_driver.tcl]
source [file join $root tcl tools review_annotate.tcl]

# The classic pipeline under test, loaded whole: the point of the gate is that
# the shipped procs and the new writer agree, not that a copy of them does.
namespace eval ::book {}
set ::book::lastBook1 ""
if {[catch {source [file join $root tcl tools analysis.tcl]} err]} {
    puts "FAIL cannot load the classic annotator: $err"
    puts "checks $checks fails [expr {$fails + 1}]"
    exit 1
}
# The exporter whose walk and NAG rendering are the artefacts.
source [file join $root tcl file rtf.tcl]

# The Informant thresholds the classic annotator reads from the options file.
array set informant {!? 0.3 ?! 0.3 ? 0.8 ?? 1.5 += 0.5 +/- 1.5 +- 2.5 +-- 4.0}

########################################################################
### The fixture
###
### A six-move Ruy Lopez in which Black's 4...Nc6 throws away two pawns and is
### the only move worth marking. `CPS` is the evaluation of every position from
### the start, in centipawns from White's point of view - the analysis window's
### own figures, which both pipelines are handed.

set ::MOVES {{e4 e2e4} {e5 e7e5} {Nf3 g1f3} {Nc6 b8c6} {Bb5 f1b5} {a6 a7a6}}
set ::CPS {20 30 25 30 220 215 210}

# The engine's preferred line from each position, in UCI. Position 3 is the one
# where the game's move (b8c6) is not the engine's choice: that is the blunder.
set ::BEST [dict create \
    0 {e2e4 e7e5} \
    1 {e7e5 g1f3} \
    2 {g1f3 b8c6} \
    3 {d7d5 e4d5} \
    4 {d2d4 e7e5} \
    5 {f1b5 a7a6} \
    6 {a7a6}]

# The annotate dialog's settings, in the state both halves of the gate read.
proc settings {} {
    set ::annotateBlunders blundersonly
    set ::annotateWhiteMoves 0
    set ::annotateBlackMoves 0
    set ::blunderThreshold 1.0
    set ::isShortAnnotation 1
    set ::addScoreToShortAnnotations 1
    set ::scoreAllMoves 0
    set ::addAnnotatorTag 0
    set ::markTacticalExercises 1
    set ::annotationVariationLength 4
    set ::wentOutOfBook 0
    set ::useAnalysisBook 0
    set ::isBatchOpening 0
    set ::analysis(uci1) 1
    set ::analysis(depth1) 18
    set ::analysis(prevdepth1) 18
    set ::analysis(moves1) ""
    set ::analysis(prevmoves1) ""
    set ::analysis(scoremate1) 0
    set ::analysis(prevscoremate1) 0
    return
}

# What scid's own analyser answers while the exercise's difficulty is measured:
# three shallow probes that disagree (so the move is not obvious), then the
# timing ladder, which still finds the move at the five longest budgets and not
# at the shorter ones - a difficulty of 6.
proc queueAnalyze {} {
    ::gamestub::queueReplies [list \
        [list 0 "g1f3"] [list 0 "d2d4"] [list 0 "d2d4"] \
        [list 0 "a2a3"] [list 0 "a2a3"] [list 0 "a2a3"] [list 0 "a2a3"] [list 0 "a2a3"] \
        [list 0 "d2d4"] [list 0 "d2d4"] [list 0 "d2d4"]]
    return
}

# The engine's lines at the position after each move, in the shape the classic
# analysis window keeps them ({lineNumber score moves}), which is what
# markExercise reads.
proc classicLines {ply} {
    if {$ply == 4} {
        return {{1 2.20 {d2d4 e7e5}} {2 0.50 {g1f3 d7d5}}}
    }
    return {{1 0.20 {e2e4}} {2 0.10 {d2d4}}}
}

# Run the classic pipeline over the fixture exactly as annotate mode does: the
# board walks forward one move at a time and addAnnotation is called once the
# engine has answered for the position it reached.
proc classicAnnotate {} {
    set n [llength $::MOVES]
    settings
    set ::analysis(score1) [expr {[lindex $::CPS 0] / 100.0}]
    set ::analysis(prevscore1) [expr {[lindex $::CPS 0] / 100.0}]
    set ::initialAnalysis 1
    sc_move ply 0
    addAnnotation 1
    for {set ply 1} {$ply <= $n} {incr ply} {
        sc_move ply $ply
        set ::analysis(score1) [expr {[lindex $::CPS $ply] / 100.0}]
        set ::analysis(multiPV1) [classicLines $ply]
        addAnnotation 1
    }
    return
}

# Run the review's write phase over the same game, from the same evaluations:
# the results dict is what ::reviewdriver collects from the engine, with each
# position's lines from the point of view of the side to move.
proc reviewAnnotate {} {
    settings
    set map [::review::mainLineMap [sc_game UCI_mainLine]]
    set results {}
    set i 0
    foreach cps $::CPS {
        set sign [expr {$i % 2 == 0 ? 1 : -1}]
        set lines [dict create 1 [list 18 [expr {$sign * $cps}] cp [dict get $::BEST $i]]]
        if {$i == 4} {
            # MultiPV 2 at the position after the blunder: the exercise gate
            # needs the second-best line, and the shallow probes need a best
            # move that is not the one the game played.
            dict set lines 2 [list 18 50 cp {g1f3 d7d5}]
        }
        dict set results $i $lines
        incr i
    }
    set p [dict create map $map plies [dict get $map plies] bookEnd 0 mpv 3]
    return [::reviewannotate::writeResults $p $results]
}

# The export artefacts, read through the exporters' own code.
proc artefact {} {
    set elements [::rtf::collectGame]
    # Element 0 is the position before the first move, and is only there when
    # that position carries something; every element after it is one move.
    if {[llength $elements] && [lindex [lindex $elements 0] 0] eq ""} {
        set elements [lrange $elements 1 end]
    }
    set nags {}
    set diagrams {}
    set ply 0
    foreach element $elements {
        incr ply
        lappend nags [lindex $element 1]
        if {[lindex $element 4] ne ""} { lappend diagrams $ply }
    }
    return [dict create nags $nags diagrams $diagrams flags $::gamestub::flags]
}

########################################################################
### The gate

::gamestub::reset $::MOVES
queueAnalyze
classicAnnotate
set classic [artefact]
set classicComments [::gamestub::commentsByPly]

::gamestub::reset $::MOVES
queueAnalyze
set counts [reviewAnnotate]
set review [artefact]
set reviewComments [::gamestub::commentsByPly]

checkEq "every move was written by the review" [dict get $counts written] 6
checkEq "and none was refused" [dict get $counts errors] ""

# 1. The diagram. The RTF exporter draws a board wherever the "D" NAG sits, and
#    the classic puts it on the move BEFORE the blunder so the diagram shows the
#    position the blunder was played in. Same move, same diagram.
checkEq "the classic export has the blunder's diagram" [dict get $classic diagrams] "3"
checkEq "the review export has it on the same move" [dict get $review diagrams] "3"

# 2. The PGN NAGs, rendered by the exporter: "??" for the blunder and the
#    position assessment beside it, nothing on the quiet moves.
checkEq "the classic wrote the blunder's NAGs" [lindex [dict get $classic nags] 3] "?? +/-"
checkEq "the review writes the same NAGs" [dict get $review nags] [dict get $classic nags]

# 3. The exercise: the flag, the filter that selects it, and the comment.
checkEq "the classic flagged the game T" [dict get $classic flags] "T"
checkEq "the review flags it too" [dict get $review flags] "T"
checkEq "and the T filter selects it" [::reviewannotate::exerciseGames 1 1] "1"
checkHas "the classic marked it an exercise" [dict get $classicComments 4] "****D6 0.3->2.2"
checkHas "the review marked it the same" [dict get $reviewComments 4] "****D6 0.3->2.2"
checkHas "the difficulty came from the timing ladder" \
    [dict get $reviewComments 4] "****D6 0.3->2.2"

# 4. The difference the mode is for, stated rather than left to be discovered:
#    the review writes its verdict word and the [%eval] token, and the classic
#    never did. Nothing in (1)-(3) above depends on it.
checkHas "the review writes its label" [dict get $reviewComments 4] "\[MoveLabelMistake\]"
checkHas "the review writes the percent-eval token" [dict get $reviewComments 4] "\[%eval +2.20\]"
checkHasNot "the classic wrote neither" [dict get $classicComments 4] "\[MoveLabel"

########################################################################
### The other branch: a move better than the engine's line
###
### The one mark the classic writes outside the moves it annotates. A gain of
### two pawns is not a blunder, so nothing gets the assessment or the diagram -
### only "!?" - and the two pipelines have to agree about that too.

set ::MOVES {{e4 e2e4} {e5 e7e5} {Nf3 g1f3} {Nc6 b8c6}}
set ::CPS {20 30 20 220 215}
# The engine's choice at each position, and the same figure the classic side
# gets from classicLines. The played move at ply 3 is not it: a move can be
# better than the engine's line without being the engine's move, and that is the
# branch this fixture tests.
set ::BEST [dict create \
    0 {e2e4 e7e5} \
    1 {e7e5 g1f3} \
    2 {e2e4 e7e5} \
    3 {d7d5 e4d5} \
    4 {a7a6}]

::gamestub::reset $::MOVES
queueAnalyze
classicAnnotate
set classic [artefact]

::gamestub::reset $::MOVES
queueAnalyze
set counts [reviewAnnotate]
set review [artefact]

checkEq "the gain is marked !? by the classic" [lindex [dict get $classic nags] 2] "!?"
checkEq "the review marks it the same way" [dict get $review nags] [dict get $classic nags]
checkEq "and no diagram is drawn for a gain" [dict get $review diagrams] ""
checkEq "neither pipeline calls it an exercise" [dict get $review flags] ""

puts "checks $checks fails $fails"
exit [expr {$fails ? 1 : 0}]
