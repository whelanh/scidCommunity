# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_annotate.tcl -- annotate as a review mode.
#
# The annotate menu runs a review pass and writes what the classic annotator
# (tcl/tools/analysis.tcl) wrote, plus what a review adds. There are two tiers
# and only one difference between them: with an AI provider configured
# (::auto_comment::providerReady) each annotated move also gets a sentence of
# prose; without one the labels, the [%eval] tokens and the variations are the
# whole annotation.
#
# A review writes a label and a [%eval] (::review::writeMove). The classic
# annotator wrote marks instead: NAGs from the score drop, the "D" diagram tag
# in blunders-only mode, the exercise flag with its difficulty comment, and the
# opening book's two comments. Those are here, so the classic pipeline can be
# retired without the export artefacts changing - and tests/tcl/annotate_parity.tcl
# is the gate that proves it, comparing the two against the same game.
#
# Nothing here searches, and nothing here needs Tk: every write goes through the
# sc_* commands, which is what lets the parity test drive both pipelines.

namespace eval ::reviewannotate {}

########################################################################
### The NAG ladders
###
### Two of them, and they are deliberately different ladders:
###
###   * nagForDrop is the classic one, in centipawns. The Informant thresholds
###     ($::informant(??), (?), (?!) and (!?)) decide the mark from how much the
###     move cost. This is what annotate writes, because a game annotated before
###     the retirement has to read the same afterwards.
###   * nagForLabel is the review's own vocabulary turned into a mark, for the
###     callers that only have a label (Move Comment, a report, a future
###     single-move annotate) and no evaluation pair to measure.

# A centipawn figure from the side to move's point of view, as White's. The
# classic pipeline kept every figure it wrote in White's perspective (the UCI
# parser flips the engine's score before storing multiPV); the review's lines
# are the engine's own, so the places that compare them with a White-POV number
# have to flip them the same way.
proc ::reviewannotate::whiteScore {cp side} {
    if {$cp eq ""} { return "" }
    if {$side eq "black"} { return [expr {-$cp}] }
    return $cp
}

# The mark a label implies. best/good/excellent are unmarked: the absence of a
# mark is the classic way of saying "nothing went wrong here", and ?? on every
# third move is noise.
proc ::reviewannotate::nagForLabel {label} {
    # One mapping, in ::review: the engine window's review and the annotator have
    # to agree about which mark a verdict word implies.
    return [::review::nagForLabel $label]
}

# The classic drop ladder (analysis.tcl:833-841, 899-901) for one move, from the
# evaluations of the position before and after it (centipawns, from the mover's
# point of view; before - after is positive when the move lost ground). "" when
# the move was not measured on both sides - "no drop measured" is not
# "excellent".
proc ::reviewannotate::nagForDrop {before after} {
    if {$before eq "" || $after eq ""} { return "" }
    if {![string is double -strict $before] || ![string is double -strict $after]} {
        return ""
    }
    # The classic thresholds are in pawns (options.tcl informantDefaults), so the
    # comparison happens in pawns whatever the caller measured in.
    set drop [expr {($before - $after) / 100.0}]
    if {$drop > 0} {
        if {$drop > $::informant(??)} { return "??" }
        if {$drop > $::informant(?)}  { return "?" }
        if {$drop > $::informant(?!) } { return "?!" }
        return ""
    }
    # A move better than the engine's line is the one improvement the classic
    # annotator marked, in the branch that otherwise annotates nothing.
    if {abs($drop) > $::informant(!?)} { return "!?" }
    return ""
}

# The position-assessment mark the classic annotator wrote beside the verdict
# (analysis.tcl:942-956): "=" for a level position, "+/-" for a clear advantage,
# and so on. `score` is in pawns from White's point of view - the same figure
# that went into the classic comment.
proc ::reviewannotate::scoreToNag {score} {
    # One assessment table, in ::review: the engine window's review writes the
    # same marks, and the two must agree.
    return [::review::scoreToNag $score]
}

########################################################################
### The diagram tag
###
### "D" is what the RTF exporter draws a board for (tcl/file/rtf.tcl
### hasDiagramNag_), and the classic annotator sets it in blunders-only mode.
### It goes on the move BEFORE the annotated one (analysis.tcl:859-865): the
### NAGs of a position belong to the move that led to it, and RTF renders the
### position after that move - which is exactly the position the blunder was
### played in.

# Returns 1 when a diagram was added, 0 when it was already there, when the
# mode does not ask for one, or when the move has no predecessor.
proc ::reviewannotate::markDiagram {ply {blundersOnly 1}} {
    if {!$blundersOnly} { return 0 }
    if {![string is integer -strict $ply] || $ply < 2} { return 0 }
    set added 0
    if {[catch {
        sc_move ply [expr {$ply - 1}]
        if {[string first "D" "[sc_pos getNags]"] == -1} {
            sc_pos addNag "D"
            set added 1
        }
    }]} {
        return 0
    }
    return $added
}

########################################################################
### The exercise
###
### A game that carries a puzzle carries the T flag, so a filter can select it,
### and the move carries "****D<difficulty> <before>-><after>" (analysis.tcl:604).

# Write the exercise's marks onto one move. `nag` is added only if it is not
# already there: a re-run must not stack a second "??".
proc ::reviewannotate::exercise {ply nag difficulty prevscore score} {
    set ok 0
    if {[catch {
        sc_move ply $ply
        if {$nag ne "" && [string first $nag "[sc_pos getNags]"] == -1} {
            sc_pos addNag $nag
        }
        set prefix [format "****D%d %.1f->%.1f" $difficulty $prevscore $score]
        set existing [sc_pos getComment]
        # A previous run's exercise prefix is replaced, not stacked: re-running
        # the annotator must not grow the comment.
        regsub {^\*{4}D[0-9]+ [-0-9.]+->[-0-9.]+ ?} $existing {} existing
        if {$existing eq ""} {
            sc_pos setComment $prefix
        } else {
            sc_pos setComment "$prefix $existing"
        }
        # A read-only base (a PGN file) refuses the flag; the comment still went
        # in, and the classic code catches the same refusal.
        catch { sc_base gameflag [sc_base current] [sc_game number] set T }
        set ok 1
    }]} {
        return 0
    }
    return $ok
}

# How long an engine needs to find this move, as the classic annotator measured
# it (analysis.tcl:583-600): the shortest of the fixed budgets at which the move
# is still found, plus one. The scale runs 1..9, and it is what the "****D"
# comment carries.
#
# The position has to be the one the caller means: this reads the board, it does
# not move it.
proc ::reviewannotate::difficulty {bm0} {
    set timer {1 2 5 10 50 100 200 1000}
    set movelist {}
    foreach t $timer {
        set res [sc_pos analyze -time $t -hashkb 1 -pawnkb 1 -mindepth 0]
        lappend movelist [lindex $res 1]
    }
    for {set t [expr {[llength $timer] - 1}]} {$t >= 0} {incr t -1} {
        if {[lindex $movelist $t] != $bm0} { break }
    }
    return [expr {$t + 2}]
}

# Is `pane`'s engine UCI? "" when the pane was never created. The value is the
# flag itself, normalised: a session that never opened Preferences can leave the
# entry as a Tk boolean string.
proc ::reviewannotate::paneUci {pane} {
    if {![info exists ::analysis(uci$pane)]} { return "" }
    set raw $::analysis(uci$pane)
    if {[string is boolean -strict $raw]} { return [expr {$raw ? 1 : 0}] }
    if {[string is integer -strict $raw]} { return [expr {$raw != 0}] }
    return 0
}

# The exercise probe drives scid's own analyser, which is the UCI engine only in
# this build - the classic's gate, read from the pane whose preset is running the
# pass. The dialog records that pane when it opens (::annotatePane,
# analysis.tcl:368), and its tactical checkbox is disabled on the same pane's
# engine, so the two cannot disagree. Pane 1 is only the fallback for a session
# that never opened the dialog: the classic annotator had one pane.
proc ::reviewannotate::exercisePaneUci {} {
    set pane 1
    catch { set pane $::annotatePane }
    if {[string is integer -strict $pane]} {
        set uci [::reviewannotate::paneUci $pane]
        if {$uci ne ""} { return $uci }
    }
    set uci [::reviewannotate::paneUci 1]
    if {$uci eq ""} { return 0 }
    return $uci
}

# Port of markExercise (analysis.tcl:536-608): mark the game as an exercise when
# the position was a puzzle rather than a position that was already decided.
#
# `before`/`after` are the evaluations of the position before and after the move
# in centipawns from WHITE's point of view - the classic's $analysis(prevscore)
# and $analysis(score), and what the "****D<difficulty> a->b" comment carries -
# and `lines` are the engine's lines at the position AFTER the move, best first,
# in the {cp pv} shape ::review::selectLines takes. Those are the two things
# $analysis(multiPV1) and $analysis(score) held in the classic loop.
#
# The mark itself is the caller's: the classic writes the NAG before it runs
# these gates, so a move refused as an exercise still carries its "??".
#
# Returns 1 when the game was marked as an exercise.
proc ::reviewannotate::markExercise {before after nag lines} {
    # The classic code works in pawns; the conversion is here so the thresholds
    # and the comment's format stay the ones the Informant settings mean.
    set prevscore [expr {$before / 100.0}]
    set score [expr {$after / 100.0}]

    if {!$::markTacticalExercises} { return 0 }
    # The difficulty probe drives scid's own analyser, which is the UCI engine
    # only in this build: the classic's gate, on the pane that opened the dialog.
    if {![::reviewannotate::exercisePaneUci]} { return 0 }

    set deltamove [expr {$score - $prevscore}]
    if {[expr abs($deltamove)] < $::informant(+/-)} { return 0 }
    # A decided game is not a puzzle.
    if {[expr {$prevscore * $score}] >= 0} {
        if {[expr abs($prevscore)] > $::informant(+--)} { return 0 }
        if {[expr abs($prevscore)] > $::informant(+-) &&
            [expr abs($score)] < [expr {2 * abs($prevscore)}]} { return 0 }
    }
    # The best move has to be much better than the others.
    if {[llength $lines] < 2} { return 0 }
    set sc2 [lindex [lindex $lines 1] 0]
    if {$sc2 eq ""} { return 0 }
    set sc2 [expr {[::reviewannotate::whiteScore $sc2 [sc_pos side]] / 100.0}]
    if {[expr abs($score - $sc2)] < 1.5} { return 0 }
    # ... and there has to be only one winning move.
    if {[expr {$score * $sc2}] > 0.0 && [expr abs($score)] > $::informant(+-) &&
        [expr abs($sc2)] > $::informant(+-)} {
        return 0
    }
    # The best move must not lose the position.
    if {[sc_pos side] eq "white" && $score < [expr {0.0 - $::informant(+/-)}]} { return 0 }
    if {[sc_pos side] eq "black" && $score > $::informant(+/-)} { return 0 }
    # The move must not be the one any shallow search would guess.
    set pv [lindex [lindex $lines 0] 1]
    set bm0 [lindex $pv 0]
    if {$bm0 eq ""} { return 0 }
    set shallow {}
    foreach depth {1 2 3} {
        set res [sc_pos analyze -time 1000 -hashkb 32 -pawnkb 1 -searchdepth $depth]
        lappend shallow [lindex $res 1]
    }
    if {[lindex $shallow 0] == $bm0 && [lindex $shallow 1] == $bm0 &&
        [lindex $shallow 2] == $bm0} {
        return 0
    }
    set difficulty [difficulty $bm0]
    # The nag is already on the move; exercise writes the flag and the comment.
    exercise [sc_pos location] "" $difficulty $prevscore $score
    return 1
}

########################################################################
### The opening book
###
### bookAnnotation (analysis.tcl:486-531) walks the game out of the book and
### says which happened: the last book move, or the move that left it.

# Walk the game from where the cursor is to the end of the book, writing the
# classic comment. Returns {ply <n> kind <out|last> comment <text>}.
#
# The walk moves the board: the caller owns the cursor (the annotate mode saves
# and restores it, the way the classic annotator did by moving forward only).
proc ::reviewannotate::bookPass {bookFile slot} {
    set ply [sc_pos location]
    set kind ""
    set comment ""
    if {[catch {
        sc_book load $bookFile $slot
        set prev ""
        lassign [sc_book moves $slot] bookmoves
        while {[string length $bookmoves] != 0 && ![sc_pos isAt vend]} {
            ::move::Forward
            set prev $bookmoves
            lassign [sc_book moves $slot] bookmoves
        }
        sc_book close $slot
        set ply [sc_pos location]
        # No book move at all: the book never had anything to say about this
        # game, so there is no comment to write (and an empty `prev` would
        # otherwise match the empty played move and claim "last book move").
        if {$prev eq ""} {
            return [list ply $ply kind "" comment ""]
        }
        # Is the move played here one the book offered from the previous
        # position? Then the game never actually left the book. Exact, because
        # a substring match calls "a6" a book move when the book offered "Ba6".
        set played [sc_game info previousMoveNT]
        if {$played eq "" || [lsearch -nocase -exact $prev $played] < 0} {
            set kind out
            set comment "[::trans $prev]"
        } else {
            set kind last
        }
    }]} {
        catch { sc_book close $slot }
        return [list ply $ply kind "" comment ""]
    }
    set existing [sc_pos getComment]
    if {$kind eq "out"} {
        if {$comment ne ""} {
            set text "$existing $::tr(MoveOutOfBook) $comment"
        } else {
            set text "$existing $::tr(MoveOutOfBook)"
        }
    } else {
        set text "$existing $::tr(LastBookMove)"
    }
    # The classic builds " $::tr(MoveOutOfBook)" and leaves a leading space when
    # the comment was empty; one comment, one trim.
    sc_pos setComment [string trim $text]
    return [list ply $ply kind $kind comment [string trim $text]]
}

# Where the book ends, without writing anything: the ply the pass should stop
# skipping the opening at. Returns 0 when the game never leaves the book or the
# book cannot be read - the pass then searches the whole line, which is the
# review's own default.
proc ::reviewannotate::findBookEnd {bookFile slot} {
    # The walk itself lives in ::review::bookEnd, so the annotator and the
    # engine window's review cannot disagree about where the book ends. The
    # annotator's answer for a game that ends in book is 0: there is nothing to
    # skip, and it searches the whole line.
    return [::review::bookEnd $bookFile $slot 0]
}

########################################################################
### Batch games and the opening-errors finder
###
### "Annotate several games" and "find opening errors" both need a game
### iterator; the classic kept it in the autoplay loop.

# Run `body` once per game in the range, in the global namespace. A game that
# cannot be loaded, and a body that fails, are counted and skipped: one
# unreadable game must not end a batch of a thousand.
#
# Returns {run <n> failed <n> errors {{<game> <message>} ...}}.
proc ::reviewannotate::games {from to body} {
    set out [dict create run 0 failed 0 errors {}]
    for {set g $from} {$g <= $to} {incr g} {
        if {[catch {
            sc_game load $g
            uplevel 1 $body
        } err]} {
            dict incr out failed
            dict lappend out errors [list $g $err]
        } else {
            dict incr out run
        }
    }
    return $out
}

# The tag the opening-errors finder leaves on a game whose opening went wrong.
# "" outside the window the user asked for.
proc ::reviewannotate::openingTag {moveNumber side window} {
    if {![string is integer -strict $moveNumber] || ![string is integer -strict $window]} {
        return ""
    }
    if {$moveNumber >= $window} { return "" }
    return "opBlunder $moveNumber ($side)"
}

# Add to the game's Annotator tag, keeping whatever is already there
# (analysis.tcl:960-989): a second pass appends to the same tag rather than
# replacing what the first engine wrote.
proc ::reviewannotate::appendAnnotator {text} {
    if {[catch { set extra [sc_game tags get "Extra"] }]} { return 0 }
    set nExtra {}
    set seen 0
    set other ""
    foreach line $extra {
        if {$seen == 1} {
            lappend nExtra "Annotator \"$line, $text\"\n"
            set seen 2
        } elseif {$other ne ""} {
            lappend nExtra "$other \"$line\"\n"
            set other ""
        } elseif {[string match "Annotator" $line]} {
            set seen 1
        } else {
            set other $line
        }
    }
    if {$seen == 0} {
        lappend nExtra "Annotator \"$text\"\n"
    }
    # A Tcl list of two-element entries: scid clears the extra tags and parses
    # each element as {name value} (src/tkscid.cpp, sc_game_tags_set -extra).
    # Joining the lines into one string leaves every entry a single word, so the
    # list would parse to nothing and the game would lose its extra tags.
    catch { sc_game tags set -extra $nExtra }
    return 1
}

########################################################################
### The tiers
###
### Tier 2 is the review with AI prose, tier 1 the same review without it. The
### labels, the [%eval] tokens, the variations and every mark above are in both.

proc ::reviewannotate::tier {} {
    if {[llength [info commands ::auto_comment::providerReady]] == 0} { return 1 }
    set ready 0
    if {[catch { set ready [::auto_comment::providerReady] }]} { return 1 }
    if {$ready} { return 2 }
    return 1
}

# Ask the provider for one sentence about the move at `ply`. "" in tier 1, when
# nothing is configured, or when the request fails - prose is an extra, and an
# annotate run must not fail because a model is unreachable.
#
# One request per judged move, and ::auto_comment::query blocks: it runs curl on
# the calling thread. In the write phase that thread is the Tk event loop, so
# tier 2 freezes the window for the length of the run. It is not wired to the
# dialog yet; wiring it needs batching, or a worker and a progress dialog.
proc ::reviewannotate::proseText {ply label} {
    if {[::reviewannotate::tier] < 2} { return "" }
    set san ""
    catch { sc_move ply $ply ; set san [sc_game info previousMoveNT] }
    set prompt "You are annotating a chess game. The move $san is a $label. In one sentence, explain what is wrong or right with it, in the voice of a coach. Plain text, no markdown."
    set reply ""
    if {[catch { set reply [::auto_comment::query $prompt 200] }]} { return "" }
    set reply [string trim $reply]
    # ::auto_comment::query reports a failed request as an "ERROR: ..." string
    # rather than an exception; that is not a sentence to paste into a game.
    if {[string match "ERROR:*" $reply]} { return "" }
    return $reply
}

# Put prose on the move's comment. The label and the [%eval] are already there
# (::review::writeMove), so this appends.
proc ::reviewannotate::prose {ply text} {
    if {$text eq ""} { return "" }
    if {[::reviewannotate::tier] < 2} { return "" }
    set out ""
    if {[catch {
        sc_move ply $ply
        sc_pos setComment [::review::mergeComment [sc_pos getComment] $text]
        set out $text
    }]} {
        return ""
    }
    return $out
}

########################################################################
### Review mode: the write phase
###
### ::reviewdriver searches; this writes what annotate mode wants in the game.
### It is handed to ::reviewdriver::run as its -writer, so the pass, the
### progress and the cursor handling stay the driver's.

# The blunders-only setting the annotate dialog has always had
# (::annotateBlunders in analysis.tcl): in that mode every mark is also a place
# a reader wants to see the board.
proc ::reviewannotate::blundersOnly {} {
    if {[info exists ::annotateBlunders] && $::annotateBlunders eq "blundersonly"} {
        return 1
    }
    return 0
}

# The classic blunders-only filter (analysis.tcl:826-829), as a decision:
#
#   (blundersonly && (isBlunder > 1 || (isBlunder > 0 && abs(score) >= 327.0))
#       && !gameIsLost)
#   || allmoves
#
# `isBlunder` is the classic's three-state measure of the drop (2 over the
# blunder threshold, 1 over nothing, 0 a move that did not lose ground),
# `gameIsLost` says the position was already decided, and `afterPawns` is the
# move's own evaluation in pawns - the classic tests it for the mate range, so
# a losing move in a won game is still marked.
#
# In blunders-only mode this decides the whole write, the label included: a
# sparse pass is sparse in every artefact, not only in the NAGs.
proc ::reviewannotate::annotates {blundersOnly isBlunder gameIsLost afterPawns} {
    if {!$blundersOnly} { return 1 }
    if {$gameIsLost} { return 0 }
    if {$isBlunder > 1} { return 1 }
    if {$isBlunder > 0 && abs($afterPawns) >= 327.0} { return 1 }
    return 0
}

# The book the annotate dialog selected, as {file slot}, or "" when the user
# turned the book off or none is installed.
proc ::reviewannotate::book {} {
    if {![info exists ::useAnalysisBook] || !$::useAnalysisBook} { return "" }
    if {![info exists ::useAnalysisBookName] || $::useAnalysisBookName eq ""} { return "" }
    set dir ""
    catch { set dir $::scidBooksDir }
    set file $::useAnalysisBookName
    if {$dir ne "" && [file dirname $file] eq "."} {
        set file [file join $dir $file]
    }
    set slot 1
    catch { set slot $::analysisBookSlot }
    return [list $file $slot]
}

# Take off what a previous pass wrote beside the label on a move this mode does
# not annotate: the label, the [%eval] beside it, and the mark the label implied.
# The user's own prose and their own tokens are kept - ::review::stripReviewTokens
# removes only the review's vocabulary.
#
# Returns 1 when something was taken off, 0 when there was nothing of ours there.
proc ::reviewannotate::dropLabel {ply} {
    set changed 0
    if {[catch {
        sc_move ply $ply
        if {[sc_pos location] != $ply} { return 0 }
        set comment [sc_pos getComment]
        set old [::review::labelOfComment $comment]
        if {$old ne ""} {
            set nag [::review::nagForLabel $old]
            if {$nag ne ""} { catch { ::review::dropNag $nag } }
        }
        set stripped [::review::stripReviewTokens $comment]
        if {$stripped ne $comment} {
            sc_pos setComment $stripped
            set changed 1
        }
    }]} {
        return 0
    }
    return $changed
}

# The annotate dialog's two variation controls, as decisions.
#
# `variationWanted` is the review's own rule (a mistake, a blunder, a missed
# win); the dialog's White/Black toggles are in front of it, the way they were in
# front of the classic annotator (analysis.tcl:867-877): a variation is the move
# that should have been played, so it belongs to the side that moved. Selecting
# one side suppresses the lines on the other side's moves and nothing else - the
# label and the marks are the review's and are written either way.
proc ::reviewannotate::variationAllowed {label white black mover} {
    if {![::review::variationWanted $label]} { return 0 }
    if {$mover eq "w"} { return [expr {$white ? 1 : 0}] }
    if {$mover eq "b"} { return [expr {$black ? 1 : 0}] }
    return 0
}

# The same lines clipped to the dialog's "Variation length (moves)". The classic
# kept `annotationVariationLength * 2 - 1` plies of every line (analysis.tcl:763),
# and `plies` here is already that figure. 0 is no length set: leave the line
# whole rather than empty.
proc ::reviewannotate::clipLines {lines plies} {
    if {![string is integer -strict $plies] || $plies < 1} { return $lines }
    set out {}
    foreach entry $lines {
        lappend out [list [lindex $entry 0] [lrange [lindex $entry 1] 0 [expr {$plies - 1}]]]
    }
    return $out
}

# Write one finished pass into the game. Same contract as
# ::reviewdriver::writeResults - the pass dict and the results dict - and the
# same {written failed errors} answer, plus the marks this file owns.
#
# `tier` is the tier this run may write at. The dialog pins it to 1 (tier 2 -
# AI prose - is a separate change), and a caller that does not name one gets
# whatever this session is configured for.
#
# In all-moves mode every judged move gets the review's own write (label,
# [%eval], and - where the label says a better move existed - the engine's
# line). In blunders-only mode the classic annotator's filter decides the whole
# write: the moves it does not cover keep nothing of the review's, including the
# label a previous all-moves pass wrote there.
proc ::reviewannotate::writeResults {p results {tier ""} {opts ""}} {
    set map [dict get $p map]
    set bookEnd [dict get $p bookEnd]
    set mpv [dict get $p mpv]
    set sides [::reviewdriver::sides $map]
    set blundersOnly [::reviewannotate::blundersOnly]
    # The dialog's variation controls, as `dialogPlan` decided them: which sides
    # get the engine's line, and how many plies of it. A caller that names none -
    # a test, another writer's caller - gets both sides and no clip, which is
    # what the review wrote before the dialog had them.
    set white 1
    set black 1
    set varPlies 0
    if {[dict size $opts]} {
        if {[dict exists $opts white]} { set white [dict get $opts white] }
        if {[dict exists $opts black]} { set black [dict get $opts black] }
        if {[dict exists $opts varPlies]} { set varPlies [dict get $opts varPlies] }
    }
    if {![string is integer -strict $tier]} { set tier [::reviewannotate::tier] }
    if {$tier > 1} { set tier 1 }
    set threshold 1.0
    catch { set threshold $::blunderThreshold }
    set written 0
    set skipped 0
    set failed 0
    set errors {}
    foreach ply [::review::plan [dict get $p plies] $bookEnd] {
        set verdict [::reviewdriver::judge $map $results $sides $ply]
        if {$verdict eq ""} { continue }
        set label [dict get $verdict label]
        set eval_cp [dict get $verdict eval_cp]
        # The verdict's own figures are the mover's; everything the classic
        # annotator wrote down was from White's point of view.
        set mover w
        catch { set mover [dict get $sides [expr {$ply - 1}]] }
        # Same gate as ::reviewdriver::writeResults: a variation is the move
        # that should have been played, so it belongs on a mistake, blunder or
        # missed win and nowhere else - and, since the dialog has the classic's
        # side filter, on the side whose toggle is on.
        set lines {}
        if {[::reviewannotate::variationAllowed $label $white $black $mover]} {
            set lines [::reviewannotate::clipLines \
                [::reviewdriver::lines $results [expr {$ply - 1}] $mpv] $varPlies]
        }
        set beforeMover [dict get $verdict before]
        # The classic measured the change between two POSITIONS - the score
        # before the move and the score after it - not the move's cost against
        # the engine's best line. ::reviewdriver::judge gives both, and eval_cp
        # (White's point of view after the move) is the position one: a move the
        # engine expected can still move the evaluation, which is what "!?"
        # means. When no successor was measured there is no position figure, and
        # the ladder's own pair is all there is.
        set afterMover [dict get $verdict after]
        if {[dict get $verdict eval_cp] ne ""} {
            set afterMover [dict get $verdict eval_cp]
            if {$mover eq "b"} { set afterMover [expr {-$afterMover}] }
        }
        # The classic measures the engine's own move as no drop at all: it sets
        # prevscore to the position-after score before computing the delta, so a
        # little search drift between the two roots never marks the move the
        # engine chose.
        if {[dict get $verdict isBest]} { set beforeMover $afterMover }
        if {$mover eq "b"} {
            set beforeWhite [expr {-$beforeMover}]
            set afterWhite [expr {-$afterMover}]
        } else {
            set beforeWhite $beforeMover
            set afterWhite $afterMover
        }
        set drop [expr {($beforeMover - $afterMover) / 100.0}]
        # The classic's blunders-only filter has three states and one exemption:
        # a move over the threshold (2), a move that lost anything (1), one that
        # did not (0), and a position already decided - which is not annotated
        # unless every move loses anyway and the mark explains why (the classic's
        # abs(score) >= 327 clause, the mate range).
        set isBlunder [expr {$drop > $threshold ? 2 : ($drop > 0 ? 1 : 0)}]
        # The Informant thresholds, and the classic's 327 clause, are in pawns;
        # the figures here are centipawns.
        set beforePawns [expr {$beforeWhite / 100.0}]
        set afterPawns [expr {$afterWhite / 100.0}]
        set gameIsLost 0
        if {$mover eq "b"} {
            set gameIsLost [expr {$beforePawns > $::informant(+--)}]
        } else {
            set gameIsLost [expr {$beforePawns < -$::informant(+--)}]
        }
        set annotate [::reviewannotate::annotates $blundersOnly $isBlunder $gameIsLost $afterPawns]
        if {!$annotate} {
            # A sparse mode is sparse in every artefact: a label, a [%eval] or a
            # mark a previous all-moves pass wrote here is taken off rather than
            # left describing a verdict this pass does not make. The gain mark
            # below is the classic's one write outside the annotated moves.
            # Which verdict the previous review left here is read BEFORE the
            # label goes, because only that verdict's diagram is ours to take
            # back. markDiagram hung the D on the move before the one it judged,
            # so a D sitting there with no label behind it is the user's own and
            # stays - ::reviewdriver::clearMarks draws the same line by bailing
            # when the comment carries no label at all.
            set oldLabel ""
            catch {
                sc_move ply $ply
                if {[sc_pos location] == $ply} {
                    set oldLabel [::review::labelOfComment [sc_pos getComment]]
                }
            }
            catch { ::reviewannotate::dropLabel $ply }
            catch { sc_move ply $ply ; ::review::dropAssessment }
            # The diagram tag is not one of ::review::assessmentNags, so dropping
            # the assessment keeps it. A blunders-only rerun that stops annotating
            # this move would leave the exporter drawing a board for a verdict this
            # pass does not make, so the mark goes with it - but only when that
            # verdict was the mistake or blunder that put it there.
            if {$oldLabel eq "mistake" || $oldLabel eq "blunder"} {
                catch { ::review::setDiagram $ply 0 }
            }
            if {$isBlunder == 0 && abs($drop) > $::informant(!?)} {
                catch { sc_move ply $ply ; sc_pos addNag "!?" }
            }
            incr skipped
            continue
        }
        # The label, the [%eval] and the variation: the review's own write.
        set err [::review::writeMove $ply $label $eval_cp $lines]
        if {$err ne ""} {
            incr failed
            lappend errors $err
            continue
        }
        set markFailed 0
        set nag [::reviewannotate::nagForDrop $beforeMover $afterMover]
        if {[catch {
            sc_move ply $ply
            # Scid's AddNag REPLACES the move's first mark instead of adding
            # beside it, so a bare addNag here overwrites the !?/?! a user put on
            # the move. ::review::hasMoveNag is the same line the driver's write
            # phase draws: only a move carrying no mark of its own gets the
            # engine's.
            if {$nag ne "" && ![::review::hasMoveNag]} {
                catch { ::review::addNagIfAbsent $nag }
            }
            # The position assessment the classic put beside the verdict
            # (analysis.tcl:852-854), from White's score.
            catch { sc_pos addNag [::reviewannotate::scoreToNag [expr {$afterWhite / 100.0}]] }
            # The classic offers both of these to markExercise: it writes
            # the ?? or ? itself, then the gates decide whether the move is
            # a puzzle. The nag is already on the move here, so the caller's
            # copy is empty and nothing is written twice.
            if {$nag eq "??" || $nag eq "?"} {
                set afterLines [::reviewdriver::lines $results $ply $mpv]
                ::reviewannotate::markExercise $beforeWhite $afterWhite "" $afterLines
            }
        }]} {
            set markFailed 1
            lappend errors "ply $ply: $::errorInfo"
        }
        if {$blundersOnly} { catch { ::reviewannotate::markDiagram $ply 1 } }
        if {$tier >= 2} {
            catch {
                set text [::reviewannotate::proseText $ply $label]
                if {$text ne ""} { ::reviewannotate::prose $ply $text }
            }
        }
        if {$markFailed} { incr failed } else { incr written }
    }
    # The book comments: the walk needs the cursor at the start of the game, so
    # it happens once, after the moves are written, and puts it back.
    set book [::reviewannotate::book]
    if {$book ne ""} {
        set cursor [::review::cursorSave]
        if {[catch {
            sc_move ply 0
            ::reviewannotate::bookPass [lindex $book 0] [lindex $book 1]
        } err]} {
            lappend errors "book: $err"
        }
        catch { ::review::cursorRestore $cursor }
    }
    # The Annotator tag, when the dialog asked for it, and the opening-errors
    # entry the batch opening finder leaves on a game whose opening went wrong.
    # Both are the tags a later pass appends to rather than replaces, and both
    # read the pass being written - the tag names the engine that wrote it - so
    # the pass goes with the call.
    catch { ::reviewannotate::tagGame $p }
    return [dict create written $written skipped $skipped failed $failed errors $errors]
}

# The T-flag filter: the games in a range that carry the exercise flag. This is
# what "show me the exercises" reads, and what the classic annotator's
# sc_base gameflag ... set T is for.
#
# It is a scan, not a load: the current game is left on the last one it looked
# at, and a caller that cares saves and restores it.
proc ::reviewannotate::exerciseGames {from to} {
    set out {}
    for {set g $from} {$g <= $to} {incr g} {
        set flagged 0
        if {![catch {
            sc_game load $g
            set flagged [sc_base gameflag [sc_base current] $g get T]
        }] && $flagged} {
            lappend out $g
        }
    }
    return $out
}

# Annotate the current game: a review pass whose write phase is this file's.
# `engine` is the preset, as ::reviewdriver::run takes it; the rest of the
# arguments go through unchanged (-bookEnd, -progress, -done, -notify).
#
# The opening book's end is decided here, before the pass, when the annotate
# dialog has a book selected: skipping the opening is the review's own
# ::review::skip_book setting, and it needs the number, not the book.
#
# `-tier` is the tier the write phase may reach; the dialog pins it to 1, and a
# caller that does not name one gets this session's own answer.
proc ::reviewannotate::start {engine args} {
    set opts {}
    set haveBook 0
    set tier [::reviewannotate::tier]
    # The dialog's variation controls travel to the writer with the run, the way
    # the tier does; a caller that names none gets the both-sides, no-clip default
    # writeResults applies.
    set wopts {white 1 black 1 varPlies 0}
    foreach {key value} $args {
        if {$key eq "-bookEnd"} { set haveBook 1 }
        if {$key eq "-tier"} { set tier $value ; continue }
        if {$key eq "-write"} { set wopts $value ; continue }
        lappend opts $key $value
    }
    if {!$haveBook} {
        set book [::reviewannotate::book]
        if {$book ne ""} {
            set end [::reviewannotate::findBookEnd [lindex $book 0] [lindex $book 1]]
            if {$end > 0} {
                lappend opts -bookEnd $end
            }
        }
    }
    # The writer is a command prefix, so the tier travels with the run rather
    # than in a module variable a second pass could overwrite.
    lappend opts -writer [list ::reviewannotate::writeResultsAtTier $tier $wopts]
    return [::reviewdriver::run $engine {*}$opts]
}

# The driver calls the writer as {*}$writer <pass> <results>; this puts the run's
# tier, and the dialog's variation controls, in front of the two arguments
# writeResults takes.
proc ::reviewannotate::writeResultsAtTier {tier wopts p results} {
    return [::reviewannotate::writeResults $p $results $tier $wopts]
}

########################################################################
### The dialog's decision
###
### The OK button asks this what to start. It is a pure proc on purpose: the
### dialog's only unique job is this decision, and a decision that needs Tk to
### be tested is a decision that is not tested.
###
### `settings` carries the dialog's own state:
###
###   game          the current game number (where a batch starts)
###   blunders      allmoves | blundersonly
###   batch         0 | 1
###   batchEnd      the last game of a batch
###   opening       0 | 1   (the opening-errors finder)
###   openingMoves  the move window the finder scans
###   bookEnd       the ply the caller's book walk ended at (0: no book)
###
### The engine is never one of them: it is the invoking pane's own preset, the
### entry the user chose when opening that pane. There is no picker and no
### second engine setting.

# A dialog setting that is a checkbox: 1 or 0, from whatever the widget left in
# the dict (Tk booleans are 0/1, but a hand-built dict may say "true" or omit it).
proc ::reviewannotate::settingFlag {settings key {default 1}} {
    if {![dict exists $settings $key]} { return $default }
    set raw [dict get $settings $key]
    if {[string is boolean -strict $raw]} { return [expr {$raw ? 1 : 0}] }
    if {[string is integer -strict $raw]} { return [expr {$raw != 0}] }
    return $default
}

proc ::reviewannotate::dialogPlan {n name uci settings} {
    set game 1
    if {[dict exists $settings game]} { set game [dict get $settings game] }
    if {![string is integer -strict $game] || $game < 1} { set game 1 }
    set blunders allmoves
    if {[dict exists $settings blunders] && [dict get $settings blunders] eq "blundersonly"} {
        set blunders blundersonly
    }
    set batch 0
    if {[dict exists $settings batch] && [dict get $settings batch]} { set batch 1 }
    set to $game
    if {$batch && [dict exists $settings batchEnd]} {
        set end [dict get $settings batchEnd]
        # A range that ends before the game it starts from is one game: a loop
        # with no iterations would report a batch that annotated nothing.
        if {[string is integer -strict $end] && $end > $game} { set to $end }
    }
    set opening 0
    if {[dict exists $settings opening] && [dict get $settings opening]} { set opening 1 }
    set openingMoves 12
    if {[dict exists $settings openingMoves] &&
        [string is integer -strict [dict get $settings openingMoves]] &&
        [dict get $settings openingMoves] > 0} {
        set openingMoves [dict get $settings openingMoves]
    }
    set bookEnd 0
    if {[dict exists $settings bookEnd] &&
        [string is integer -strict [dict get $settings bookEnd]] &&
        [dict get $settings bookEnd] > 0} {
        set bookEnd [dict get $settings bookEnd]
    }
    # The dialog's White/Black toggles and its "Variation length (moves)" spinner
    # (analysis.tcl:445-452). Both were the classic annotator's own options: the
    # toggles decided whether a move got the engine's line as a variation at all,
    # and the spinner clipped every line to annotationVariationLength*2-1 plies.
    # A caller that names neither gets the classic's defaults - both sides on,
    # no length set.
    set white [::reviewannotate::settingFlag $settings white 1]
    set black [::reviewannotate::settingFlag $settings black 1]
    set varPlies 0
    if {[dict exists $settings varLength] &&
        [string is integer -strict [dict get $settings varLength]] &&
        [dict get $settings varLength] > 0} {
        # The dialog speaks in moves and the game in plies; this is the classic's
        # own conversion (analysis.tcl:763).
        set varPlies [expr {[dict get $settings varLength] * 2 - 1}]
    }
    # Tier 2 (AI prose) is a separate change: this dialog ships tier 1, whatever
    # a configured provider would answer at run time.
    set out [dict create \
        pane $n engine "" engineName $name uci [expr {$uci ? 1 : 0}] \
        bookEnd $bookEnd tier 1 blunders $blunders batch $batch \
        from $game to $to opening $opening openingMoves $openingMoves \
        white $white black $black varPlies $varPlies refuse ""]
    set engine ""
    if {$name ne "" && [llength [info commands ::enginecfg::get]]} {
        catch { set engine [::enginecfg::get $name] }
    }
    # The refusals are the driver's own sentences: a second phrasing for the
    # same refusal is a second thing to keep in step.
    if {[llength $engine] == 0} {
        dict set out refuse "no engine selected"
        dict set out bookEnd 0
        return $out
    }
    if {!$uci} {
        dict set out refuse "the review needs a UCI engine"
        dict set out bookEnd 0
        return $out
    }
    dict set out engine $engine
    return $out
}

########################################################################
### The run: one game, or a batch of them
###
### The driver runs one pass at a time and writes on completion. A batch is
### therefore a chain of passes, one per game, and the chain is this file's:
### load the game, pass it to the driver, and on the driver's completion hook
### save it and start the next one.
###
### The state a run needs lives in ::reviewannotate::run, so the progress line,
### the Cancel button and the hook all read the same thing. Nothing here depends
### on a window being open: the pass is a job, and the progress line is
### decoration over it.

namespace eval ::reviewannotate {
    variable run {}
    variable progressText ""
}

proc ::reviewannotate::running {} {
    variable run
    return [expr {[dict size $run] > 0}]
}

# Is there a game after the one in flight? This is the whole of the Cancel
# button's context: a single game stops now, a batch stops after this one.
proc ::reviewannotate::moreGames {} {
    variable run
    if {![dict size $run]} { return 0 }
    return [expr {[llength [dict get $run games]] > [dict get $run index] + 1}]
}

# The one Cancel button's label. "Stop after this game" iff more games follow -
# until it has been pressed, when it is already stopping now and says so.
proc ::reviewannotate::stopLabel {more {pressed 0}} {
    if {$pressed} { return [::tr StopNow] }
    if {$more} { return [::tr StopAfterThisGame] }
    return [::tr StopNow]
}

# Start the run `dialogPlan` decided. Returns "" when it started, otherwise the
# reason it did not - in which case nothing was loaded, searched or written.
proc ::reviewannotate::run {plan} {
    variable run
    if {[dict size $run]} { return "a pass is already running" }
    set refuse [dict get $plan refuse]
    if {$refuse ne ""} { return $refuse }
    set games {}
    for {set g [dict get $plan from]} {$g <= [dict get $plan to]} {incr g} {
        lappend games $g
    }
    set run [dict create plan $plan games $games index -1 stopAfter 0 last {0 0}]
    return [::reviewannotate::nextGame]
}

# Start the pass for the next game of the run. A batch borrows the base: the
# user's game is pushed, the game to annotate is loaded, and the pair is put
# back when that game's pass has finished - so the board comes back to where the
# user left it however the run ends.
proc ::reviewannotate::nextGame {} {
    variable run
    dict incr run index
    set games [dict get $run games]
    if {[dict get $run index] >= [llength $games]} {
        return [::reviewannotate::finish]
    }
    set plan [dict get $run plan]
    set game [lindex $games [dict get $run index]]
    set batch [expr {[llength $games] > 1}]
    if {$batch} {
        # The push is undone below when the load fails: a copy left on the game
        # stack is one the user's own `sc_game pop` would find later, and the
        # base has to come back exactly as it was.
        set pushed 0
        if {[catch {
            sc_game push copy
            set pushed 1
            sc_game load $game
        } err]} {
            # The game cannot be read. Neither half of the finished-game step can
            # run here: the board still holds the base - the load never happened,
            # and the push above is undone - so saving would write the user's own
            # game into this game's slot, and advancing would start a pass on a
            # range whose input is already broken. Stop the way a cancelled pass
            # stops, and say what went wrong.
            if {$pushed} { catch { sc_game pop } }
            if {[dict get $run index] > 0} {
                dict lappend run problems "game $game could not be read: $err"
            }
            ::reviewannotate::finish
            return "game $game could not be read: $err"
        }
        dict set run borrowed 1
        dict set run game $game
    }
    # The book is walked for the game in flight, not for the caller's: in a batch
    # the game has just been loaded, and a single game is the one on the board.
    # The plan's number is only the fallback for a caller that walked it itself
    # (no book selected here) - it was measured on whatever game the dialog was
    # opened over, and applying it to a later game of the range would skip that
    # game's own opening, or annotate it as a mistake.
    set bookEnd [dict get $plan bookEnd]
    set book [::reviewannotate::book]
    if {$book ne ""} {
        set bookEnd 0
        catch { set bookEnd [::reviewannotate::findBookEnd [lindex $book 0] [lindex $book 1]] }
        if {$bookEnd < 0} { set bookEnd 0 }
    }
    dict set run last {0 0}
    # The dialog's variation controls, when the plan carries them - a plan built by
    # an older caller keeps the writer's own defaults.
    set wopts {white 1 black 1 varPlies 0}
    foreach key {white black varPlies} {
        if {[dict exists $plan $key]} { dict set wopts $key [dict get $plan $key] }
    }
    set err [::reviewannotate::start [dict get $plan engine] \
        -bookEnd $bookEnd \
        -progress ::reviewannotate::progress \
        -done ::reviewannotate::done \
        -notify 1 \
        -write $wopts \
        -tier [dict get $plan tier]]
    if {$err ne ""} {
        # A refusal leaves the run's counts alone; what it must not leave behind
        # is a borrowed game.
        if {[dict get $run index] > 0} { dict lappend run problems $err }
        ::reviewannotate::returnGame
        ::reviewannotate::finish
        return $err
    }
    # The driver can finish synchronously when there is nothing to search: a
    # game with no main-line moves, or one the book covers, sets state done and
    # no done hook will fire. Without this the run would wait for a pass that
    # does not exist, and a borrowed game would stay on the board.
    set now ""
    catch { set now [::reviewdriver::status] }
    if {[dict size $now] && [dict get $now state] eq "done"} {
        return [::reviewannotate::done $now]
    }
    # What the pass is about to do, so the progress line reads "0 of N" rather
    # than "0 of 0" until the first position finishes.
    set total 0
    catch { set total [dict get [::reviewdriver::status] total] }
    dict set run last [list 0 $total]
    ::reviewannotate::paintStatus
    return ""
}

# Give the borrowed game back, if there is one. Nothing is saved here: a pass
# that did not finish wrote nothing (the driver's write phase runs once, on the
# last reply), and Cancel is defined as writing nothing.
proc ::reviewannotate::returnGame {} {
    variable run
    if {![dict size $run]} { return }
    if {[dict exists $run borrowed] && [dict get $run borrowed]} {
        # Give the borrowed game back only while it is still the one on the
        # board. If the user opened another game, popping would replace that
        # game with the pre-batch copy and undo their navigation.
        set current ""
        catch { set current [sc_game number] }
        if {$current eq "" || ![dict exists $run game] ||
            $current eq [dict get $run game]} {
            catch { sc_game pop }
        }
        dict unset run borrowed
    }
}

# The driver's completion hook: called once per pass, with the status dict.
# A cancelled pass is one the driver stopped, not one that finished, and it ends
# the run where it is. Cancel on the button empties the run before stopping the
# driver, so this mostly only sees a running one - but opening another game stops
# every pass too (::enginewin::reviewStopAll), and then the game on the board is
# not the one the pass was reading: saving it would write the newly opened game
# into this run's slot, and advancing would annotate games nobody asked for.
proc ::reviewannotate::done {state} {
    variable run
    if {![dict size $run]} { return }
    set stateName ""
    catch { set stateName [dict get $state state] }
    # ::reviewdriver::stop sets state=cancelled; a pass that searched to the end
    # ends on done, and one whose engine gave up on failed.
    if {$stateName eq "cancelled"} {
        ::reviewannotate::returnGame
        return [::reviewannotate::finish]
    }
    if {$stateName eq "failed"} {
        set reason ""
        catch { set reason [dict get $state reason] }
        if {$reason eq ""} { set reason "the review pass failed" }
        dict lappend run problems $reason
        ::reviewannotate::returnGame
        return [::reviewannotate::finish]
    }
    set failed 0
    catch { set failed [dict get $state failed] }
    if {$failed > 0} {
        set msg "$failed move(s) could not be written"
        set errors {}
        catch { set errors [dict get $state errors] }
        if {[llength $errors]} { append msg ": [lindex $errors 0]" }
        dict lappend run problems $msg
    }
    set games [dict get $run games]
    if {[llength $games] > 1} {
        set game [lindex $games [dict get $run index]]
        set current ""
        catch { set current [sc_game number] }
        if {$current ne "" && $current ne $game} {
            dict lappend run problems \
                "the game changed while it was being annotated; it was not saved"
            ::reviewannotate::returnGame
            return [::reviewannotate::finish]
        }
        catch { sc_game save $game }
        catch { ::notify::DatabaseModified [sc_base current] }
    }
    ::reviewannotate::returnGame
    if {[dict get $run stopAfter]} {
        return [::reviewannotate::finish]
    }
    if {[llength $games] > [dict get $run index] + 1} {
        return [::reviewannotate::nextGame]
    }
    return [::reviewannotate::finish]
}

# The run is over, however it ended. The progress line goes back to whatever the
# board was saying, and the board is told the game changed - the comments land
# across the whole line, so the PGN pane has to be regenerated.
proc ::reviewannotate::finish {} {
    variable run
    set problems {}
    if {[dict size $run]} { catch { set problems [dict get $run problems] } }
    set run {}
    set ::reviewannotate::progressText ""
    # The annotate button was the Cancel for this run: put it back where the
    # dialog found it, on the pane the run was started from.
    catch {
        set n 1
        catch { set n $::annotatePane }
        if {[winfo exists .analysisWin$n.b1.annotate]} {
            .analysisWin$n.b1.annotate state !pressed
        }
    }
    if {[llength [info commands updateStatusBar]]} { catch { updateStatusBar } }
    if {[llength $problems]} {
        catch {
            tk_messageBox -icon warning -title "scidCommunity: [::tr Annotate]" \
                -message [join [lrange $problems 0 5] "\n"]
        }
    }
    return ""
}

# The one Cancel button. In a batch the first press asks for the current game to
# finish and the rest to be dropped; the second, or a press on a single game,
# stops now. Stopping now writes nothing.
proc ::reviewannotate::cancelAction {} {
    variable run
    if {![dict size $run]} { return 0 }
    if {[::reviewannotate::moreGames] && ![dict get $run stopAfter]} {
        dict set run stopAfter 1
        ::reviewannotate::paintStatus
        return 1
    }
    # Empty the run first: the driver's stop runs the completion hook, and a hook
    # that still saw a run would start the next game of a batch being cancelled.
    set r $run
    set run {}
    catch { ::reviewdriver::cancel 1 }
    if {[dict exists $r borrowed] && [dict get $r borrowed]} {
        catch { sc_game pop }
    }
    ::reviewannotate::finish
    return 1
}

# The progress line: where the pass has got to, and the Cancel button's label
# beside it. A covered or absent window changes nothing here - the text is the
# run's state, and painting it is decoration.
proc ::reviewannotate::progress {done total} {
    variable run
    if {![dict size $run]} { return }
    dict set run last [list $done $total]
    ::reviewannotate::paintStatus
    return
}

proc ::reviewannotate::statusText {} {
    variable run
    if {![dict size $run]} { return "" }
    lassign [dict get $run last] done total
    set text "$done/$total"
    set games [dict get $run games]
    if {[llength $games] > 1} {
        append text " game [expr {[dict get $run index] + 1}]/[llength $games]"
    }
    return $text
}

proc ::reviewannotate::paintStatus {} {
    variable run
    if {![dict size $run]} { return }
    set text [::reviewannotate::statusText]
    append text " " [::reviewannotate::stopLabel \
        [::reviewannotate::moreGames] [dict get $run stopAfter]]
    set ::reviewannotate::progressText $text
    # The board's info line is the status line. It is decoration: a session with
    # no board (a headless run, a test) paints nothing and the pass is unaffected.
    if {[llength [info commands ::board::setInfoAlert]] == 0} { return }
    catch {
        ::board::setInfoAlert .main.board "Annotate:" \
            $text red ::reviewannotate::cancelAction
    }
    return
}

# The game's own tags, after a pass: the opening-errors entry the batch opening
# finder leaves on a game whose opening went wrong, and the Annotator tag the
# dialog asks for. Both are tags a second pass appends to rather than replaces,
# which is what appendAnnotator is for.
#
# The classic annotator wrote "<engine> (<delay> sec)" - it had a per-move delay
# to report. A review pass has none: its cost is the review's depth or time cap,
# both of which the Review Settings show, so the tag says which pass wrote it.
#
# `p` is the pass the write phase was handed; its `engine` entry is the preset
# the pass search on, and the first element of it is the engine's name.
proc ::reviewannotate::tagGame {p} {
    set cursor [::review::cursorSave]
    if {[info exists ::isBatchOpening] && $::isBatchOpening} {
        set window 12
        catch { set window $::isBatchOpeningMoves }
        catch {
            sc_move ply 0
            set tag [::reviewannotate::openingTag [sc_pos moveNumber] [sc_pos side] $window]
            if {$tag ne ""} { ::reviewannotate::appendAnnotator $tag }
        }
    }
    if {[info exists ::addAnnotatorTag] && $::addAnnotatorTag} {
        set name ""
        catch { set name [lindex [dict get $p engine] 0] }
        if {$name eq ""} { set name review }
        catch { ::reviewannotate::appendAnnotator "$name (review)" }
    }
    catch { ::review::cursorRestore $cursor }
    return
}
