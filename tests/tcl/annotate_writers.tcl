#!/usr/bin/env tclsh
# The annotate writers: the pieces of the classic annotator (tcl/tools/analysis.tcl)
# that a review pass has to be able to write before the classic pipeline can be
# retired - the NAG ladders, the diagram tag, the exercise flag and its
# difficulty comment, and the opening book's two comments.
#
# Each one is checked against the game the classic code writes into
# (tests/tcl/game_stub.tcl), not against a mock of the writer.

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

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tests tcl game_stub.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools game_review.tcl]

# The classic annotator's thresholds. They are options in the real session
# (tcl/options.tcl informantDefaults), so the tests set the same values here.
namespace eval :: {}
array set informant {!? 0.3 ?! 0.3 ? 0.8 ?? 1.5 += 0.5 +/- 1.5 +- 2.5 +-- 4.0}

if {[catch {source [file join $root tcl tools review_annotate.tcl]} err]} {
    puts "FAIL cannot load tcl/tools/review_annotate.tcl: $err"
    puts "checks $checks fails [expr {$fails + 1}]"
    exit 1
}

# A game both halves of this file can drive.
proc fixture {} {
    ::gamestub::reset [list \
        {e4 e2e4} {e5 e7e5} {Nf3 g1f3} {Nc6 b8c6} {Bb5 f1b5} {a6 a7a6}]
}

### 1. NAG from a label ########################################################
#
# The label is the review's verdict word; the NAG is the mark a PGN reader sees.

checkEq "blunder label is ??" [::reviewannotate::nagForLabel blunder] "??"
checkEq "mistake label is ?"  [::reviewannotate::nagForLabel mistake]  "?"
checkEq "inaccuracy label is ?!" [::reviewannotate::nagForLabel inaccuracy] "?!"
checkEq "good label carries no NAG" [::reviewannotate::nagForLabel good] ""
checkEq "excellent label carries no NAG" [::reviewannotate::nagForLabel excellent] ""
checkEq "best label carries no NAG" [::reviewannotate::nagForLabel best] ""
checkEq "brilliant label is !!" [::reviewannotate::nagForLabel brilliant] "!!"
checkEq "great label is !" [::reviewannotate::nagForLabel great] "!"
checkEq "miss label is ?" [::reviewannotate::nagForLabel miss] "?"
checkEq "an unknown label writes nothing" [::reviewannotate::nagForLabel ""] ""

# The drop ladder is the classic one, in centipawns: a review that writes NAGs
# has to keep writing the same marks the Informant thresholds give, or a game
# annotated before the retirement reads differently afterwards.
checkEq "a two pawn drop is ??" [::reviewannotate::nagForDrop 220 20] "??"
checkEq "a one pawn drop is ?"  [::reviewannotate::nagForDrop 120 20] "?"
checkEq "a half pawn drop is ?!" [::reviewannotate::nagForDrop 60 20] "?!"
checkEq "a tenth of a pawn is nothing" [::reviewannotate::nagForDrop 30 20] ""
checkEq "giving a pawn back is !?" [::reviewannotate::nagForDrop 70 120] "!?"
checkEq "a black move drops in the other direction" [::reviewannotate::nagForDrop -20 -120] "?"
checkEq "an unmeasured move writes nothing" [::reviewannotate::nagForDrop "" ""] ""

### 2. The diagram tag, in blunders-only mode ##################################
#
# The RTF exporter draws a diagram where "D" sits (tcl/file/rtf.tcl hasDiagramNag_),
# and the classic annotator puts it on the move BEFORE the blunder, so the
# diagram shows the position the blunder was played in.

fixture
sc_move ply 5
checkEq "a blunder gets a diagram" [::reviewannotate::markDiagram 5 1] 1
checkEq "the diagram hangs on the move before it" [dict get [::gamestub::nagsByPly] 4] "D"
checkEq "the blunder move itself carries no D" [dict exists [::gamestub::nagsByPly] 5] 0
checkEq "a second mark is not added twice" [::reviewannotate::markDiagram 5 1] 0
checkEq "the game keeps one D" [dict get [::gamestub::nagsByPly] 4] "D"

fixture
checkEq "all-moves mode writes no diagram" [::reviewannotate::markDiagram 5 0] 0
checkEq "and nothing lands in the game" [::gamestub::nagsByPly] ""

fixture
checkEq "the first move has no predecessor to hang a diagram on" \
    [::reviewannotate::markDiagram 1 1] 0
checkEq "so the game is unchanged" [::gamestub::nagsByPly] ""

### 3. The exercise: T flag and difficulty comment #############################
#
# markExercise (analysis.tcl:536-608) is what makes a game a puzzle: the game
# carries the T flag so a filter can select it, and the move carries
# "****D<difficulty> <before>-><after>".

fixture
sc_move ply 5
sc_pos setComment "12:+0.50"
checkEq "the exercise is written" \
    [::reviewannotate::exercise 5 "??" 3 0.5 -1.2] 1
checkEq "the game is flagged T" $::gamestub::flags "T"
checkEq "the comment carries the difficulty and both scores" \
    [sc_pos getComment] "****D3 0.5->-1.2 12:+0.50"
checkEq "the move keeps its ??" [dict get [::gamestub::nagsByPly] 5] "??"

# The difficulty is the classic timing ladder: the shortest budget at which the
# engine still finds the move, plus one. The stub answers e2e4 while it has it
# and d2d4 after, so the break is at index 4 and the difficulty is 6.
fixture
::gamestub::queueReplies [list [list 0 e2e4] [list 0 e2e4] [list 0 e2e4] \
    [list 0 e2e4] [list 0 d2d4] [list 0 e2e4] [list 0 e2e4] [list 0 e2e4]]
checkEq "the ladder measures the budget that finds it" [::reviewannotate::difficulty e2e4] 6

### 4. The opening book's comments #############################################
#
# bookAnnotation (analysis.tcl:486-531) writes one or the other of these two
# comments as the game leaves the book.

fixture
# The book offers d4 on the fifth move; the game played Bb5, so that is the move
# that left the book - and the classic comment names the book's move.
set ::gamestub::book {0 {e4} 1 {e5} 2 {Nf3} 3 {Nc6} 4 {d4}}
set r [::reviewannotate::bookPass "/books/x.bin" 1]
checkEq "the book is loaded from the named file" $::gamestub::loaded "/books/x.bin"
checkEq "the book ends at the move that left it" [dict get $r ply] 5
checkEq "the comment names the move it left from" \
    [dict get [::gamestub::commentsByPly] 5] "Out of book d4"

# A game that ends while it is still in book gets the other comment.
::gamestub::reset [list {e4 e2e4} {e5 e7e5}]
set ::gamestub::book {0 {e4} 1 {e5} 2 {Nf3}}
set r [::reviewannotate::bookPass "/books/x.bin" 1]
checkEq "a game that ends in book says so" \
    [dict get [::gamestub::commentsByPly] 2] "Last book move"

# A game outside the book on its first move.
fixture
set ::gamestub::book {0 {d4}}
set r [::reviewannotate::bookPass "/books/x.bin" 1]
checkEq "a first move out of book still says it" \
    [dict get [::gamestub::commentsByPly] 1] "Out of book d4"

### 5. Batch games and the opening-errors tag ##################################

set ::gamestub::games 4
set ::gamestub::number 1
set seen {}
::reviewannotate::games 2 4 {lappend seen [sc_game number]}
checkEq "the iterator visits the games it is given" $seen "2 3 4"

# One game that cannot be loaded does not stop the batch, and the batch reports
# what it skipped.
set seen {}
set r [::reviewannotate::games 1 3 {if {[sc_game number] == 2} {error "read only"} ; lappend seen [sc_game number]}]
checkEq "a refused game does not stop the batch" $seen "1 3"
checkEq "and it is counted" [dict get $r failed] 1

# find-opening-errors marks the games whose opening went wrong, by adding to the
# Annotator tag: "opBlunder <move number> (<side>)".
checkEq "a move inside the opening window is tagged" \
    [::reviewannotate::openingTag 6 black 10] "opBlunder 6 (black)"
checkEq "a move past it is not" [::reviewannotate::openingTag 12 black 10] ""
fixture
::reviewannotate::appendAnnotator "Stockfish 16 (1 sec)"
checkEq "the annotator tag is created" \
    [string trim $::gamestub::annotator] "Annotator \"Stockfish 16 (1 sec)\""
::reviewannotate::appendAnnotator "opBlunder 6 (black)"
checkEq "a second annotator is appended to the same tag" \
    [string trim $::gamestub::annotator] \
    "Annotator \"Stockfish 16 (1 sec), opBlunder 6 (black)\""

### 6. Tiers ###################################################################
#
# Tier 2 is the review with AI prose, tier 1 without. Nothing else differs.

namespace eval ::auto_comment {}
proc ::auto_comment::providerReady {} { return 0 }
checkEq "no provider is tier 1" [::reviewannotate::tier] 1
proc ::auto_comment::providerReady {} { return 1 }
checkEq "a configured provider is tier 2" [::reviewannotate::tier] 2

### 7. Prose goes into the comment, and only in tier 2 #########################
proc ::auto_comment::query {prompt {maxTokens 300}} { return "White is winning." }
fixture
checkEq "tier 2 asks the provider" [::reviewannotate::proseText 5 blunder] "White is winning."
checkEq "and writes what came back" \
    [::reviewannotate::prose 5 "White is winning."] "White is winning."
checkEq "the prose lands in the move's comment" \
    [sc_pos getComment] "White is winning."

fixture
proc ::auto_comment::providerReady {} { return 0 }
checkEq "tier 1 asks nobody" [::reviewannotate::proseText 5 blunder] ""
checkEq "tier 1 writes no prose" [::reviewannotate::prose 5 "White is winning."] ""
checkEq "and the comment stays empty" [sc_pos getComment] ""

puts "checks $checks fails $fails"
exit [expr {$fails ? 1 : 0}]
