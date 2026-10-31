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
source [file join $root tcl tools game_review.tcl]
source [file join $root tcl tools review_driver.tcl]

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

# The classic pipeline keeps every figure it writes in White's perspective; the
# review's lines are the engine's own (side to move), so the comparison with a
# White-POV score has to flip them, exactly as the classic's UCI parser did.
set haveWhite [expr {[llength [info commands ::reviewannotate::whiteScore]] > 0}]
check "a side-to-move score can be turned into White's" $haveWhite
if {$haveWhite} {
    checkEq "a side-to-move score on White's move is White's" \
        [::reviewannotate::whiteScore 120 white] 120
    checkEq "and flips on Black's" [::reviewannotate::whiteScore 120 black] -120
    checkEq "an empty score stays empty" [::reviewannotate::whiteScore "" black] ""
}

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

# A second run replaces the prefix it wrote, rather than stacking a second one.
fixture
sc_move ply 5
::reviewannotate::exercise 5 "??" 3 0.5 -1.2
::reviewannotate::exercise 5 "??" 3 0.5 -1.2
checkEq "a second exercise replaces the prefix, not stacks it" \
    [sc_pos getComment] "****D3 0.5->-1.2"

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

# A book that never had a move for the game has nothing to say - and an empty
# book move list must not match the empty played move and claim "last book move".
fixture
set ::gamestub::book {}
set r [::reviewannotate::bookPass "/books/x.bin" 1]
checkEq "a book with no move writes no comment" [dict get $r kind] ""
checkEq "and the game's comments are untouched" [dict get [::gamestub::commentsByPly]] {}

# ::review::bookEnd counts the plies that follow the book, and answers 0 for a
# game that never leaves it unless the caller asks for the whole line. The
# engine window uses that "all book" answer; the classic annotator does not.
set haveBookEnd [expr {[llength [info commands ::review::bookEnd]] > 0}]
check "the review can measure a book end" $haveBookEnd
if {$haveBookEnd} {
fixture
set ::gamestub::book {0 {e4} 1 {e5} 2 {Nf3}}
checkEq "the book end is the number of moves followed" \
    [::review::bookEnd "/books/x.bin" 5] 3
checkEq "the same book, a game that ends in it" \
    [::review::bookEnd "/books/x.bin" 5 1] 3
fixture
set ::gamestub::book {0 {e4} 1 {e5} 2 {Nf3} 3 {Nc6} 4 {Bb5} 5 {a6} 6 {d4}}
checkEq "a game still in book at the end is all book" \
    [::review::bookEnd "/books/x.bin" 5 1] 6
checkEq "but the annotator is told there is nothing to skip" \
    [::review::bookEnd "/books/x.bin" 5 0] 0
fixture
set ::gamestub::book {}
checkEq "a book with no move has no end" [::review::bookEnd "/books/x.bin" 5] 0

# The book end counts the moves the game actually played from the book. A game
# that deviates at the first move has no book plies at all, and one that follows
# a book move and then deviates counts only the move it followed.
::gamestub::reset [list {a3 a7a3}]
set ::gamestub::book {0 {e4}}
checkEq "a first-move deviation is not a book move" \
    [::review::bookEnd "/books/x.bin" 5 1] 0
::gamestub::reset [list {e4 e2e4} {a6 a7a6}]
set ::gamestub::book {0 {e4} 1 {d4}}
checkEq "the move that leaves the book is not counted" \
    [::review::bookEnd "/books/x.bin" 5 1] 1
}

# A book move is a move, not a substring: "a6" is not "Ba6".
::gamestub::reset [list {a6 a7a6}]
set ::gamestub::book {0 {Ba6}}
set r [::reviewannotate::bookPass "/books/x.bin" 1]
checkEq "a book offering Ba6 does not claim a6 came from it" \
    [dict get [::gamestub::commentsByPly] 1] "Out of book Ba6"

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

### 6b. Where the book ends, and the review-mode entry point #####################

# The pass has to know where to stop skipping the opening before it starts, and
# the walk that finds it must not leave the board somewhere else.
fixture
set ::gamestub::book {0 {e4} 1 {e5} 2 {Nf3} 3 {Nc6}}
sc_move ply 2
checkEq "the pass is told where the book ends" [::reviewannotate::findBookEnd "/books/x.bin" 1] 4
checkEq "and the board is put back" $::gamestub::cursor 2

# The walk is over the game's opening, not from the cursor: a mid-game cursor
# outside the book must not report its own ply as the end.
fixture
set ::gamestub::book {0 {e4}}
sc_move ply 3
checkEq "the book end comes from the start, not the cursor" \
    [::reviewannotate::findBookEnd "/books/x.bin" 1] 1
checkEq "and the board comes back" $::gamestub::cursor 3

# A game that never leaves the book has no book end to speak of: returning the
# final ply would make the pass skip every move before it.
::gamestub::reset [list {e4 e2e4} {e5 e7e5}]
set ::gamestub::book {0 {e4} 1 {e5} 2 {Nf3}}
checkEq "a game that ends in book has no book end" \
    [::reviewannotate::findBookEnd "/books/x.bin" 1] 0

# The annotate mode is the driver's pass with this file's writer: with no engine
# there is nothing to start, and the refusal is the driver's own - which also
# proves -writer is an option the driver knows.
fixture
checkEq "annotate mode refuses without an engine" [::reviewannotate::start ""] "no engine selected"
checkEq "and the board never moved" $::gamestub::cursor 0

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

# ::auto_comment::query reports a failed request as an "ERROR: ..." string, not
# as an exception; that is not a sentence to write into a game.
proc ::auto_comment::providerReady {} { return 1 }
proc ::auto_comment::query {prompt {maxTokens 300}} { return "ERROR: no model selected" }
checkEq "a provider error is not prose" [::reviewannotate::proseText 5 blunder] ""

### 8. The classic's blunders-only filter ######################################
#
# The filter is not "drop > threshold": the classic also leaves a decided
# position alone, marks a mate-range position even for a small drop (its 327
# clause), and offers a "?" move to markExercise exactly like a "??" one. The
# review has to agree, or retiring the classic changes which moves a game gets
# marked on.

proc annotateSettings {} {
    set ::annotateBlunders blundersonly
    set ::blunderThreshold 1.0
    set ::markTacticalExercises 0
    set ::analysis(uci1) 0
    set ::useAnalysisBook 0
    ::review::reset
    return
}

# A one-move game, annotated by the review's write phase from one position pair
# in centipawns from White's point of view.
proc annotateOne {before after {pvMove d2d4}} {
    ::gamestub::reset [list {e4 e2e4} {e5 e7e5}]
    set map [::review::mainLineMap [sc_game UCI_mainLine]]
    set results [dict create \
        0 [dict create 1 [list 18 $before cp [list $pvMove e7e5]]] \
        1 [dict create 1 [list 18 [expr {-$after}] cp {e7e5}]]]
    set p [dict create map $map plies [dict get $map plies] bookEnd 0 mpv 3]
    return [::reviewannotate::writeResults $p $results]
}

annotateSettings
annotateOne -550 -750
checkEq "a blunder in a decided game is not marked" [::gamestub::nagsByPly] ""

# Game Review writes a position assessment on every judged move. A blunders-only
# pass that does not annotate this move leaves nothing of the review's on it: the
# assessment, the label and the [%eval] all describe a verdict the mode does not
# make, so the sparse mode filters the whole write and not only the marks (the
# sparse case is gated in tests/tcl/annotate_dialog.tcl).
annotateSettings
::gamestub::reset [list {e4 e2e4} {e5 e7e5}]
sc_move ply 1
sc_pos addNag "+="
set map [::review::mainLineMap [sc_game UCI_mainLine]]
set results [dict create \
    0 [dict create 1 [list 18 -550 cp {d2d4 e7e5}]] \
    1 [dict create 1 [list 18 750 cp {e7e5}]]]
set p [dict create map $map plies [dict get $map plies] bookEnd 0 mpv 3]
set counts [::reviewannotate::writeResults $p $results]
checkEq "an unannotated move is counted as skipped" [dict get $counts skipped] 2
set nags ""
catch { set nags [dict get [::gamestub::nagsByPly] 1] }
check "an unannotated move keeps no stale assessment" \
    [expr {[string first "+=" $nags] < 0}]
set comment ""
catch { set comment [dict get [::gamestub::commentsByPly] 1] }
check "and no stale evaluation is written either" \
    [expr {[string first "\[%eval" $comment] < 0}]

# The diagram mark is not one of ::review::assessmentNags, so dropping the
# assessment keeps it: a blunders-only rerun that stops annotating the move
# would leave the exporter drawing a board for a verdict this pass no longer
# makes. markDiagram hung it on the move BEFORE the verdict (analysis.tcl:859-865),
# so that is the move the sparse pass has to take it off.
annotateSettings
::gamestub::reset [list {e4 e2e4} {e5 e7e5}]
sc_move ply 1
sc_pos addNag "D"
sc_pos addNag "!?"
set map [::review::mainLineMap [sc_game UCI_mainLine]]
set results [dict create \
    0 [dict create 1 [list 18 -550 cp {d2d4 e7e5}]] \
    1 [dict create 1 [list 18 750 cp {e7e5}]]]
set p [dict create map $map plies [dict get $map plies] bookEnd 0 mpv 3]
set counts [::reviewannotate::writeResults $p $results]
checkEq "a sparse rerun annotates neither move" [dict get $counts skipped] 2
set nags ""
catch { set nags [dict get [::gamestub::nagsByPly] 1] }
check "a dropped verdict takes its diagram mark with it" \
    [expr {[lsearch -exact $nags D] < 0}]
check "and leaves the move's other marks alone" \
    [expr {[lsearch -exact $nags "!?"] >= 0}]

# The write phase's last step is the game's own tags: the opening-errors entry
# the finder leaves ("opBlunder <move> (<side>)", analysis.tcl:740-742) and the
# Annotator tag the dialog's checkbox asks for (analysis.tcl:743-745). Both read
# the pass being written - the tag names the engine that wrote it - so the writer
# has to hand the pass on; a call that forgets it raises `wrong # args` inside the
# catch and neither tag is ever written.
annotateSettings
fixture
set tagMap [::review::mainLineMap [sc_game UCI_mainLine]]
set tagResults [dict create \
    0 [dict create 1 [list 18 20 cp {e2e4 e7e5}]] \
    1 [dict create 1 [list 18 -30 cp {e7e5 g1f3}]]]
set tagPass [dict create map $tagMap plies [dict get $tagMap plies] \
    bookEnd 0 mpv 3 engine {Stockfish /usr/bin/stockfish}]
set ::addAnnotatorTag 1
set ::isBatchOpening 1
set ::isBatchOpeningMoves 12
::reviewannotate::writeResults $tagPass $tagResults
checkHas "the pass writes the opening-errors entry" \
    $::gamestub::annotator "opBlunder 1 (white)"
checkHas "and the Annotator tag, named for the pass's engine" \
    $::gamestub::annotator "Stockfish (review)"
annotateSettings

annotateSettings
annotateOne 200 60 e2e4
checkEq "a best move is not marked for search drift" [::gamestub::nagsByPly] ""

annotateSettings
annotateOne 99700 99600
set nags ""
catch { set nags [dict get [::gamestub::nagsByPly] 1] }
check "a mate-range position is marked for a small drop" \
    [expr {[string first "?" $nags] >= 0}]

annotateSettings
rename ::reviewannotate::markExercise ::reviewannotate::markExerciseSaved
set ::offered {}
proc ::reviewannotate::markExercise {before after nag lines} {
    lappend ::offered [sc_pos location]
    return 0
}
# A 1.3-pawn drop is over the blunder threshold, so the move is annotated, but
# it is a "?" on the Informant ladder (0.8 < 1.3 < 1.5) - and the classic offers
# that to markExercise as well.
annotateOne 130 0
checkEq "a ? move is offered to the exercise gate like the classic" $::offered {1}
rename ::reviewannotate::markExercise {}
rename ::reviewannotate::markExerciseSaved ::reviewannotate::markExercise

# A mark that fails is a failed move, not a written one: the label landed, the
# exercise did not, and the counts have to say so.
annotateSettings
rename ::reviewannotate::markExercise ::reviewannotate::markExerciseSaved
proc ::reviewannotate::markExercise {args} { error "no exercise here" }
set r [annotateOne 130 0]
rename ::reviewannotate::markExercise {}
rename ::reviewannotate::markExerciseSaved ::reviewannotate::markExercise
checkEq "a mark that fails is counted as failed" [dict get $r failed] 1
checkEq "and its reason is kept" [expr {[llength [dict get $r errors]] > 0}] 1

puts "checks $checks fails $fails"
exit [expr {$fails ? 1 : 0}]
