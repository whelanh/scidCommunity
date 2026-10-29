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

# The mark a label implies. best/good/excellent are unmarked: the absence of a
# mark is the classic way of saying "nothing went wrong here", and ?? on every
# third move is noise.
proc ::reviewannotate::nagForLabel {label} {
    switch -- $label {
        blunder    { return "??" }
        mistake    { return "?" }
        miss       { return "?" }
        inaccuracy { return "?!" }
        brilliant  { return "!!" }
        great      { return "!" }
    }
    return ""
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
namespace eval ::reviewannotate {
    # The classic maps (analysis.tcl:936-938): four thresholds, then the negative
    # half of the table. The order is the table's, not a ladder to tune.
    variable INF_LIST {0 "+=" 1 "+/-" 2 "+-" 3 "+--"}
    variable NAG_LIST {0 "=" 1 "+=" 2 "+/-" 3 "+-" 4 "+--" 5 "=" 6 "=+" 7 "-/+" 8 "-+" 9 "--+"}
}

proc ::reviewannotate::scoreToNag {score} {
    variable INF_LIST
    variable NAG_LIST
    set tmp [expr {abs($score)}]
    set i 0
    for {set i 0} {$i < 4} {incr i} {
        if {$tmp < $::informant([dict get $INF_LIST $i])} { break }
    }
    if {$score < 0.0} { set i [expr {$i + 5}] }
    return [dict get $NAG_LIST $i]
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
    # only in this build: same gate as the classic.
    if {![info exists ::analysis(uci1)] || !$::analysis(uci1)} { return 0 }

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
    set sc2 [expr {$sc2 / 100.0}]
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
        # Is the move played here one the book offered from the previous
        # position? Then the game never actually left the book.
        set played [sc_game info previousMoveNT]
        if {[string match -nocase "*$played*" $prev] != 1} {
            set kind out
            if {$prev ne ""} {
                set comment "[::trans $prev]"
            }
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
    set end 0
    set cursor [::review::cursorSave]
    if {[catch {
        sc_book load $bookFile $slot
        set bookmoves ""
        lassign [sc_book moves $slot] bookmoves
        while {[string length $bookmoves] != 0 && ![sc_pos isAt vend]} {
            ::move::Forward
            lassign [sc_book moves $slot] bookmoves
        }
        sc_book close $slot
        set end [sc_pos location]
    }]} {
        catch { sc_book close $slot }
        set end 0
    }
    catch { ::review::cursorRestore $cursor }
    return $end
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
    # The tag text, not a Tcl list of it: the classic hands scid the braced list
    # (one element, so the value round-trips as one word and a second annotator
    # cannot find the tag it should append to), and joining flattens it into the
    # lines scid reads back as words.
    catch { sc_game tags set -extra [join $nExtra ""] }
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
proc ::reviewannotate::proseText {ply label} {
    if {[::reviewannotate::tier] < 2} { return "" }
    set san ""
    catch { sc_move ply $ply ; set san [sc_game info previousMoveNT] }
    set prompt "You are annotating a chess game. The move $san is a $label. In one sentence, explain what is wrong or right with it, in the voice of a coach. Plain text, no markdown."
    set reply ""
    if {[catch { set reply [::auto_comment::query $prompt 200] }]} { return "" }
    return [string trim $reply]
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

# Write one finished pass into the game. Same contract as
# ::reviewdriver::writeResults - the pass dict and the results dict - and the
# same {written failed errors} answer, plus the marks this file owns.
#
# Every judged move gets the review's own write (label, [%eval], variations).
# The classic annotator's marks go on the moves the annotate dialog's mode
# covers: all of them in all-moves mode, only the ones over the blunder
# threshold in blunders-only mode - the same filter analysis.tcl:826-829 applies.
proc ::reviewannotate::writeResults {p results} {
    set map [dict get $p map]
    set bookEnd [dict get $p bookEnd]
    set mpv [dict get $p mpv]
    set sides [::reviewdriver::sides $map]
    set blundersOnly [::reviewannotate::blundersOnly]
    set tier [::reviewannotate::tier]
    set threshold 1.0
    catch { set threshold $::blunderThreshold }
    set written 0
    set failed 0
    set errors {}
    foreach ply [::review::plan [dict get $p plies] $bookEnd] {
        set verdict [::reviewdriver::judge $map $results $sides $ply]
        if {$verdict eq ""} { continue }
        set label [dict get $verdict label]
        set eval_cp [dict get $verdict eval_cp]
        set lines [::reviewdriver::lines $results [expr {$ply - 1}] $mpv]
        # The label, the [%eval] and the variations: the review's own write.
        set err [::review::writeMove $ply $label $eval_cp $lines]
        if {$err ne ""} {
            incr failed
            lappend errors $err
            continue
        }
        # The verdict's own figures are the mover's; everything the classic
        # annotator wrote down was from White's point of view.
        set mover w
        catch { set mover [dict get $sides [expr {$ply - 1}]] }
        set beforeMover [dict get $verdict before]
        set afterMover [dict get $verdict after]
        if {$mover eq "b"} {
            set beforeWhite [expr {-$beforeMover}]
            set afterWhite [expr {-$afterMover}]
        } else {
            set beforeWhite $beforeMover
            set afterWhite $afterMover
        }
        set drop [expr {($beforeMover - $afterMover) / 100.0}]
        if {!$blundersOnly || abs($drop) > $threshold} {
            set nag [::reviewannotate::nagForDrop $beforeMover $afterMover]
            if {[catch {
                sc_move ply $ply
                if {$nag ne ""} { sc_pos addNag $nag }
                # The position assessment the classic put beside the verdict
                # (analysis.tcl:852-854), from White's score.
                catch { sc_pos addNag [::reviewannotate::scoreToNag [expr {$afterWhite / 100.0}]] }
                if {$nag eq "??"} {
                    set afterLines [::reviewdriver::lines $results $ply $mpv]
                    ::reviewannotate::markExercise $beforeWhite $afterWhite $nag $afterLines
                }
            }]} {
                lappend errors "ply $ply: $::errorInfo"
            }
            if {$blundersOnly} { catch { ::reviewannotate::markDiagram $ply 1 } }
        } elseif {$drop < 0 && abs($drop) > $::informant(!?)} {
            # A move better than the engine's line: the one mark the classic
            # writes outside the annotated moves (analysis.tcl:898-901).
            catch { sc_move ply $ply ; sc_pos addNag "!?" }
        }
        if {$tier >= 2} {
            catch {
                set text [::reviewannotate::proseText $ply $label]
                if {$text ne ""} { ::reviewannotate::prose $ply $text }
            }
        }
        incr written
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
    return [dict create written $written failed $failed errors $errors]
}

# The T-flag filter: the games in a range that carry the exercise flag. This is
# what "show me the exercises" reads, and what the classic annotator's
# sc_base gameflag ... set T is for.
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
# arguments go through unchanged (-bookEnd, -progress, -notify).
#
# The opening book's end is decided here, before the pass, when the annotate
# dialog has a book selected: skipping the opening is the review's own
# ::review::skip_book setting, and it needs the number, not the book.
proc ::reviewannotate::start {engine args} {
    set opts {}
    set haveBook 0
    foreach {key value} $args {
        if {$key eq "-bookEnd"} { set haveBook 1 }
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
    lappend opts -writer ::reviewannotate::writeResults
    return [::reviewdriver::run $engine {*}$opts]
}
