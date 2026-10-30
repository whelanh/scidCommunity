# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# game_review.tcl -- the review pass's settings and its two decisions.
#
#   tclsh tests/tcl/game_review.tcl

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
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools score_seed.tcl]
source [file join $root tcl tools game_review.tcl]

puts "settings"

::review::reset
checkEq "mpv defaults to 3" [::review::get mpv] 3
checkEq "depth defaults to 18" [::review::get depth] 18
checkEq "a diagram is written at mistakes and blunders by default" \
    [::review::get diagram] 1
checkEq "a variation shows the better move by default" [::review::get var_lines] 1
checkEq "no threshold by default" [::review::get var_cp] 0

checkEq "mpv can be raised" [::review::setValue mpv 4] ""
checkEq "and is remembered" [::review::get mpv] 4
checkEq "mpv above the cap is refused" [::review::setValue mpv 9] {mpv must be 1..5}
checkEq "and keeps the old value" [::review::get mpv] 4
checkEq "depth can be raised" [::review::setValue depth 24] ""
checkEq "a shallow depth is refused" [::review::setValue depth 4] {depth must be 6..60}
checkEq "a non-number is refused" [::review::setValue depth deep] {depth must be a whole number}
checkEq "an unknown key is refused" [::review::setValue colour red] {unknown setting: colour}

# var_lines cannot exceed mpv, and lowering mpv lowers it.
checkEq "var_lines above mpv is refused" [::review::setValue var_lines 5] {var_lines cannot exceed mpv (4)}
::review::setValue mpv 5
checkEq "var_lines up to mpv is accepted" [::review::setValue var_lines 5] ""
checkEq "it is remembered" [::review::get var_lines] 5
::review::setValue mpv 2
checkEq "lowering mpv lowers var_lines with it" [::review::get var_lines] 2
checkEq "no problems reported" [::review::problems] {}

# mpv 1 means no alternatives at all, so var_lines goes to 0 rather than to 1:
# ::review::problems refuses that combination, and the setter must too.
checkEq "mpv 1 is allowed" [::review::setValue mpv 1] ""
checkEq "mpv 1 turns variations off" [::review::get var_lines] 0
checkEq "var_lines 1 is refused while mpv is 1" \
    [::review::setValue var_lines 1] {var_lines needs mpv of at least 2}
checkEq "and problems agrees with the setter" [::review::problems] {}

puts "where the pass starts"

::review::reset
checkEq "no book, start at the first move" [::review::startPly 0] 0
checkEq "book ends at position 7: start one earlier" [::review::startPly 7] 6
checkEq "the plan runs from there to the end" [::review::plan 10 7] {7 8 9 10}
checkEq "the whole game when there is no book" [::review::plan 3 0] {1 2 3}
::review::setValue skip_book 0
checkEq "with book skipping off the pass starts at move 1" [::review::startPly 7] 0
checkEq "and covers the whole game" [::review::plan 3 7] {1 2 3}

puts "the pass's helpers are there"

# Asserted by absence on the pre-fix tree: every section below needs one of
# these, so naming them first makes the RED side report each missing anchor
# instead of stopping at the first call.
foreach helper {searchPlies mainLineMap playedMove cursorSave cursorRestore} {
    check "::review::$helper exists" \
        [expr {[llength [info commands ::review::$helper]] > 0}]
}

puts "the positions the pass searches"

::review::reset
checkEq "no book: the position before every move, and the last one" \
    [::review::searchPlies 3 0] {0 1 2 3}
checkEq "book ends at 7: the pass starts one position earlier" \
    [::review::searchPlies 10 7] {6 7 8 9 10}
checkEq "one move: the start and the position after it" \
    [::review::searchPlies 1 0] {0 1}
checkEq "an empty plan has no positions" [::review::searchPlies 0 0] {}
checkEq "a book that covers the game has no positions" [::review::searchPlies 3 5] {}
check "never a negative position" \
    [expr {[lindex [::review::searchPlies 3 0] 0] >= 0}]
::review::setValue skip_book 0
checkEq "with book skipping off, the whole game" [::review::searchPlies 3 7] {0 1 2 3}
::review::reset

puts "the main line as the pass reads it"

set map [::review::mainLineMap [list {position startpos moves} e2e4 e7e5]]
checkEq "plies counts the moves" [dict get $map plies] 2
checkEq "the move played at each ply" [dict get $map moves] {1 e2e4 2 e7e5}
checkEq "the position after each ply" [dict get $map positions] [list \
    0 "position startpos moves" \
    1 "position startpos moves e2e4" \
    2 "position startpos moves e2e4 e7e5"]
checkEq "the move played at ply 1" [::review::playedMove $map 1] e2e4
checkEq "the move played at ply 2" [::review::playedMove $map 2] e7e5
checkEq "a ply past the end has no move" [::review::playedMove $map 3] {}
checkEq "the setup is not a ply" [::review::playedMove $map 0] {}
checkEq "a setup-only game has no plies" \
    [dict get [::review::mainLineMap [list {position startpos moves}]] plies] 0
checkEq "an empty line maps to nothing" \
    [::review::playedMove [::review::mainLineMap {}] 1] {}

# A null move has no token: it is emitted as a fresh setup header in place of
# that ply's move, so it must read as "no move played" and must not shift the
# plies after it. The indexes do not move - the element is just not a move.
set fen "position fen 8/8/8/8/8/8/8/K6k w - - 0 1 moves"
set map [::review::mainLineMap [list {position startpos moves} e2e4 $fen e7e5]]
checkEq "a null move still counts as a ply" [dict get $map plies] 3
checkEq "the null ply has no move token" [dict get $map moves] [list 1 e2e4 2 "" 3 e7e5]
checkEq "a null move has no played move" [::review::playedMove $map 2] {}
check "a header is never reported as a move" \
    [expr {[string match "position *" [::review::playedMove $map 2]] == 0}]
set positions [dict get $map positions]
checkEq "the position before the null move" [dict get $positions 1] \
    "position startpos moves e2e4"
checkEq "the header is the position after it" [dict get $positions 2] $fen
checkEq "and the moves after it build on that header" [dict get $positions 3] \
    "$fen e7e5"

puts "which verdicts carry a variation"

# A variation is the move that should have been played, so it belongs on the
# moves the label says could have been better.
foreach label {mistake blunder miss} {
    check "a $label carries a variation" [::review::variationWanted $label]
}
foreach label {best excellent good inaccuracy forced book brilliant great} {
    check "a $label does not" [expr {![::review::variationWanted $label]}]
}

puts "which lines become variations"

::review::reset
set lines {{20 pvA} {10 pvB} {-30 pvC}}
::review::setValue var_lines 0
checkEq "var_lines 0 writes no variation" [::review::selectLines $lines pvA] {}
::review::setValue var_lines 2
checkEq "two alternates, best first" [::review::selectLines $lines pvA] {pvB pvC}
checkEq "one alternate" [::review::selectLines [list {20 pvA} {10 pvB}] pvA] {pvB}
checkEq "the played move's own line is not a variation" \
    [::review::selectLines [list {20 pvA}] pvA] {}
# A blunder: the best line is not the move played, so it is the variation the
# game is missing - not line 2 of the engine's list.
checkEq "the best line is a variation when the game played something else" \
    [::review::selectLines $lines Qxd8] {pvA pvB}
checkEq "the played move is dropped wherever it ranks" \
    [::review::selectLines {{20 pvA} {10 pvB} {5 pvC}} pvB] {pvA pvC}
# Nothing is dropped when the caller cannot say which move was played.
checkEq "an unknown played move keeps the best line" \
    [::review::selectLines [list {20 pvA} {10 pvB}]] {pvA pvB}

# The worked example: best +2.50 for White is -250 for the Black mover, and an
# alternative that scores +3.00 is 50cp worse, so a 50cp threshold excludes it.
set example [list {-250 pvBest} {-300 pvWorse} {-280 pvCloser}]
checkEq "no threshold keeps both" [::review::selectLines $example pvBest] {pvWorse pvCloser}
::review::setValue var_cp 50
checkEq "a 50cp threshold drops the line exactly 50 worse" \
    [::review::selectLines $example pvBest] {pvCloser}
::review::setValue var_cp 100
checkEq "a wider threshold keeps them" [::review::selectLines $example pvBest] {pvWorse pvCloser}

# Lines that are not in order, or have no moves, are not variations.
checkEq "a line ahead of the best is ignored" \
    [::review::selectLines [list {10 pvA} {40 pvAhead}] pvA] {}
checkEq "a line with no moves is ignored" \
    [::review::selectLines [list {10 pvA} {-20 {}}] pvA] {}

# var_lines is the count that is inserted, not the count that is examined.
::review::setValue mpv 5
::review::setValue var_lines 1
::review::setValue var_cp 0
checkEq "only the first eligible alternate" \
    [::review::selectLines {{20 a} {10 b} {5 c}} a] {b}

puts "when the move comment may write"

::review::reset
checkEq "by default it waits for the review depth" [::review::moveCommentPlan 12] 18
checkEq "at the review depth it writes" [::review::moveCommentPlan 18] now
checkEq "deeper than the review depth writes too" [::review::moveCommentPlan 22] now
checkEq "with no depth reported it waits" [::review::moveCommentPlan ""] 18
# A preset may carry a deeper limit than the setting; the caller passes it in,
# because only the caller knows which engine the pass will run on.
checkEq "a deeper target is what it waits for" [::review::moveCommentPlan 20 30] 30
checkEq "and at that target it writes" [::review::moveCommentPlan 30 30] now
checkEq "an empty target is the setting" [::review::moveCommentPlan 12 ""] 18
::review::setValue move_comment_wait 0
checkEq "immediate mode writes whatever the engine has" [::review::moveCommentPlan 4] now
checkEq "and writes even with nothing to report" [::review::moveCommentPlan ""] now

puts "the comment a move carries"

::review::reset
check "the label and the evaluation" \
    [string match {*\[%eval -1.20\]*} [::review::commentText blunder -120]]
check "a label without an evaluation" \
    [expr {[string first "%eval" [::review::commentText good ""]] < 0}]
checkEq "an existing comment is kept" \
    [::review::mergeComment {A fine move.} {[Blunder]}] {A fine move. [Blunder]}
checkEq "and is not repeated" \
    [::review::mergeComment {A fine move. [Blunder]} {[Blunder]}] {A fine move. [Blunder]}
checkEq "an empty comment is just the new text" \
    [::review::mergeComment {} {[Good]}] {[Good]}

# A second review has to replace what the first one wrote: one verdict, and the
# [%eval] the graph reads first must be the new one.
checkEq "a previous verdict and score are removed" \
    [::review::stripReviewTokens {A fine move. [good] [%eval +0.20]}] {A fine move.}
checkEq "other tokens and the prose survive" \
    [::review::stripReviewTokens {[%clk 0:03:00] A fine move.}] {[%clk 0:03:00] A fine move.}
# Only the ladder's own words are removed. A positional rule also deleted a
# user's tag sitting in front of the evaluation.
checkEq "a known verdict and its score are removed" \
    [::review::stripReviewTokens {[good] [%eval +0.20]}] {}
checkEq "a user tag in front of the score survives" \
    [::review::stripReviewTokens {[Source] [%eval +0.20]}] {[Source]}
checkEq "a timestamp before the verdict survives" \
    [::review::stripReviewTokens {[%clk 0:03:00] [good] [%eval +0.20]}] \
    {[%clk 0:03:00]}
checkEq "a re-review leaves one verdict and one score" \
    [::review::mergeComment \
        [::review::stripReviewTokens {A fine move. [good] [%eval +0.20]}] \
        [::review::commentText blunder -120]] \
    {A fine move. [blunder] [%eval -1.20]}

puts "writing one move"

# The sc_* layer is stubbed: the point of these checks is which calls are made,
# not what scid does with them.
set ::calls {}
# The stub board is a ply counter plus the variation path walked to reach it:
# `level` is how many sc_var exits reach the main line, `nums` the variation
# number at each level, `exits` the ply counter of the position each level
# branched from. That is exactly what ::review::cursorSave has to read, and it
# is enough to put the board back.
set ::fakeLevel 0
set ::fakeNums {}
set ::fakeExit {}
# How many variations exist at a given "<ply>,<level>" branch point.
set ::fakeVarCounts [dict create]
proc sc_pos {args} {
    switch -- [lindex $args 0] {
        location { return $::fakeLoc }
        # The position identity the restore compares: the same ply in a
        # renumbered sibling is a different line, which the fake FEN shows.
        # The line tag changes when a renumbered sibling takes the number the
        # saved cursor names; ply and level alone cannot see that.
        fen { return "$::fakeLoc/$::fakeLevel/$::fakeLine" }
        getComment { return $::fakeComment }
        setComment { lappend ::calls [list setComment [lindex $args 1]] ; set ::fakeComment [lindex $args 1] ; return "" }
    }
    return ""
}
proc sc_move {args} {
    set what [lindex $args 0]
    set n [lindex $args 1]
    # sc_move ply N is the MAIN line - MoveToStart then N MoveForward - so it
    # leaves every variation. Asking for a ply beyond it leaves the game where it
    # was, which is what the real command does here.
    switch -- $what {
        ply {
            if {$n <= $::fakeLen} {
                set ::fakeLoc $n
                set ::fakeLevel 0
                set ::fakeNums {}
                set ::fakeExit {}
            }
        }
        forward {
            if {$n eq ""} { set n 1 }
            incr ::fakeLoc $n
        }
        back { incr ::fakeLoc -1 }
    }
    lappend ::calls [list move $what $n]
    return ""
}
proc fakeVarCount {} {
    set key "$::fakeLoc,$::fakeLevel"
    if {[dict exists $::fakeVarCounts $key]} {
        return [dict get $::fakeVarCounts $key]
    }
    return 0
}
proc sc_var {args} {
    lappend ::calls [list var [lindex $args 0]]
    switch -- [lindex $args 0] {
        count { return [fakeVarCount] }
        list  { lappend ::listAt $::fakeLoc ; return $::fakeVars }
        level { return $::fakeLevel }
        number {
            if {!$::fakeLevel} { return 0 }
            return [lindex $::fakeNums end]
        }
        enter {
            set n [lindex $args 1]
            if {$n >= [fakeVarCount]} { error "No such variation!" }
            # The number matters: entering two different siblings has to be
            # distinguishable in the recorded calls.
            lset ::calls end [list var enter $n]
            # MoveIntoVariation and then MoveForward: entering plays the
            # variation's first move, so the ply counter advances by one.
            lappend ::fakeExit $::fakeLoc
            lappend ::fakeNums $n
            incr ::fakeLevel
            incr ::fakeLoc
            return ""
        }
        exit {
            if {$::fakeLevel == 0} { error "No such variation!" }
            set ::fakeLoc [lindex $::fakeExit end]
            set ::fakeExit [lrange $::fakeExit 0 end-1]
            set ::fakeNums [lrange $::fakeNums 0 end-1]
            incr ::fakeLevel -1
            return ""
        }
        create {
            # A new variation is opened to be filled; the caller exits it.
            lappend ::fakeExit $::fakeLoc
            lappend ::fakeNums 0
            incr ::fakeLevel
            return ""
        }
        delete {
            if {$::fakeLevel == 0} { error "No such variation!" }
            lappend ::calls {var delete}
            set ::fakeLoc [lindex $::fakeExit end]
            set ::fakeExit [lrange $::fakeExit 0 end-1]
            set ::fakeNums [lrange $::fakeNums 0 end-1]
            incr ::fakeLevel -1
            return ""
        }
    }
    return ""
}
# Put the board at `loc`, inside the variations named by `nums`, whose branch
# positions are `exits` (outermost first), in a game of `len` main-line moves.
proc fakeCursor {loc nums exits {len 40}} {
    set ::fakeLen $len
    set ::fakeLoc $loc
    set ::fakeNums $nums
    set ::fakeExit $exits
    set ::fakeLevel [llength $nums]
    set ::fakeVarCounts [dict create]
    set ::fakeLine L
    set ::fakeVars {}
    set ::listAt {}
    set ::calls {}
}
set ::fakeVars {}
set ::listAt {}
# UCI_mainLine is the setup followed by the moves, as the real command returns
# it, so element $ply is the move played at ply $ply.
proc sc_game {args} {
    if {[lindex $args 0] eq "UCI_mainLine"} { return $::fakeMainLine }
    return ""
}
namespace eval ::uci { proc sc_move_add {moves} { lappend ::calls [list add $moves] ; return 0 } }

puts "where the board was"

# On the main line there is nothing to walk back into: the ply counter is the
# whole position.
fakeCursor 5 {} {}
set state [::review::cursorSave]
checkEq "a main-line cursor is a ply" [dict get $state loc] 5
checkEq "whose base is itself" [dict get $state base] 5
checkEq "with an empty path" [dict get $state path] {}
checkEq "and it restores exactly" [::review::cursorRestore $state] 1
checkEq "leaving the board where it was" [list $::fakeLoc $::fakeLevel] {5 0}

# One variation, branched from ply 3, cursor two moves inside it.
fakeCursor 5 {0} {3}
set state [::review::cursorSave]
checkEq "one variation: the captured ply" [dict get $state loc] 5
checkEq "one variation: the main-line base" [dict get $state base] 3
checkEq "one variation: which one and how far in" [dict get $state path] {{0 2}}
checkEq "saving leaves the board on the base ply" [list $::fakeLoc $::fakeLevel] {3 0}
set ::fakeVarCounts [dict create "3,0" 2]
set ::calls {}
checkEq "it restores exactly" [::review::cursorRestore $state] 1
checkEq "on the captured ply, in the variation" \
    [list $::fakeLoc $::fakeLevel [lindex $::fakeNums end]] {5 1 0}
checkEq "by walking the path" $::calls \
    {{move ply 3} {var enter 0} {move forward 1} {var level}}

# A variation inside a variation: the path is outermost first, because that is
# the order a restore has to enter.
fakeCursor 8 {1 0} {3 6}
set state [::review::cursorSave]
checkEq "nested: the outer path is innermost-first when captured, outer first when read" \
    [dict get $state path] {{1 3} {0 2}}
checkEq "nested: the base is the main-line ply" [dict get $state base] 3
set ::fakeVarCounts [dict create "3,0" 2 "6,1" 1]
set ::calls {}
checkEq "nested: it restores exactly" [::review::cursorRestore $state] 1
checkEq "nested: on the captured ply, both levels deep" \
    [list $::fakeLoc $::fakeLevel $::fakeNums] {8 2 {1 0}}
checkEq "nested: entering each level and walking the rest of it" $::calls \
    {{move ply 3} {var enter 1} {move forward 2} {var enter 0} {move forward 1} {var level}}

# A cursor at the variation's own start, before its first move. Entering plays
# that move, so the restore has to step back out of it.
fakeCursor 3 {0} {3}
set state [::review::cursorSave]
checkEq "a cursor before the variation's first move" [dict get $state path] {{0 0}}
set ::fakeVarCounts [dict create "3,0" 1]
set ::calls {}
checkEq "it restores exactly too" [::review::cursorRestore $state] 1
checkEq "one move back out of the auto-played first move" $::calls \
    {{move ply 3} {var enter 0} {move back {}} {var level}}
checkEq "and is still inside the variation" [list $::fakeLoc $::fakeLevel] {3 1}

# An insertion at the same branch point renumbers the siblings - writeMove does
# exactly that - so the captured number may no longer name the same line. The
# restore must say so and retreat to the base ply, never land inside the wrong
# variation.
fakeCursor 5 {1} {3}
set state [::review::cursorSave]
checkEq "the second variation, two moves in" [dict get $state path] {{1 2}}
set ::fakeVarCounts [dict create "3,0" 2]
# Variation 1 now exists with the same move count, so the ply and level checks
# alone would accept it; it is a different line, which the position shows.
set ::fakeLine other
checkEq "a renumbered sibling is not the same position" [::review::cursorRestore $state] 0
checkEq "and the board is on the base ply, not in some other line" \
    [list $::fakeLoc $::fakeLevel] {3 0}
set ::fakeVarCounts [dict create "3,0" 1]
checkEq "a variation that is gone falls back" [::review::cursorRestore $state] 0

# A state that cannot be read is a fallback, not an exception.
checkEq "an unreadable cursor does not raise" \
    [::review::cursorRestore [list loc now base 2 path {}]] 0

puts "writing one move"

::review::reset
::review::setValue var_lines 1
fakeCursor 5 {} {} 10
set ::fakeComment "Existing note."
# The engine's best line is the move played at ply 4, so it is not a variation.
set ::fakeMainLine [list {position startpos moves} m1 m2 m3 pvBest m5]
set ::calls {}
set err [::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt}}]
checkEq "it succeeds" $err {}
check "the comment is written at the move" \
    [expr {[lsearch -exact $::calls {setComment {Existing note. [blunder] [%eval -1.20]}}] >= 0}]
check "a variation is created" [expr {[lsearch -exact $::calls {var create}] >= 0}]
check "with the alternate line" [expr {[lsearch -exact $::calls {add pvAlt}] >= 0}]
check "and not with the line the game already played" \
    [expr {[lsearch -exact $::calls {add pvBest}] < 0}]
check "and the game is left where it was" [expr {$::fakeLoc == 5}]

# A blunder: the best line is not the move played, so it is the variation.
set ::fakeMainLine [list {position startpos moves} m1 m2 m3 m5 m6]
set ::calls {}
::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt}}
check "the best line is inserted" [expr {[lsearch -exact $::calls {add pvBest}] >= 0}]
check "and the weaker line is not" [expr {[lsearch -exact $::calls {add pvAlt}] < 0}]

# No variations when the setting is off, and none when the move is not there.
set ::calls {}
::review::setValue var_lines 0
::review::writeMove 4 good 20 {{20 pvBest} {10 pvAlt}}
check "no variation with var_lines 0" [expr {[lsearch -exact $::calls {var create}] < 0}]

fakeCursor 2 {} {} 3
checkEq "a ply that is not in the game is refused" \
    [::review::writeMove 4 good 20 {}] {ply 4 is not in this game}
check "and the game is left where it was, not moved to the start" \
    [expr {$::fakeLoc == 2}]

# var_lines > 1 inserts every distinct alternative, and a variation a previous
# review already wrote is not duplicated.
::review::reset
::review::setValue var_lines 2
fakeCursor 5 {} {} 10
set ::fakeComment "Existing note."
set ::fakeMainLine [list {position startpos moves} m1 m2 m3 pvBest m5]
::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt} {-250 pvThird}}
check "both alternates are inserted" \
    [expr {[lsearch -exact $::calls {add pvAlt}] >= 0 \
        && [lsearch -exact $::calls {add pvThird}] >= 0}] $::calls
check "two variations are created" \
    [expr {[llength [lsearch -all $::calls {var create}]] == 2}] $::calls
checkEq "the variation list is read before the move, not after it" \
    [lindex $::listAt 0] 3
set ::fakeVars {pvAlt}
set ::calls {}
::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt} {-250 pvThird}}
check "an existing variation is not duplicated" \
    [expr {[lsearch -exact $::calls {add pvAlt}] < 0}] $::calls
check "a new one is still added" \
    [expr {[lsearch -exact $::calls {add pvThird}] >= 0}] $::calls

puts "writing a move inside a variation"

# The board was inside a variation when the review started: the write has to
# leave it there, path and all.
::review::reset
::review::setValue var_lines 1
set ::fakeComment ""
set ::fakeMainLine [list {position startpos moves} m1 m2 m3 pvBest m5]
fakeCursor 5 {0} {3} 10
set ::fakeVarCounts [dict create "3,0" 2]
checkEq "a write inside a variation succeeds" \
    [::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt}}] {}
checkEq "and the variation path is restored" [list $::fakeLoc $::fakeLevel] {5 1}
checkEq "in the same variation" [lindex $::fakeNums end] 0

# The refusal path restores it too - and a refusal is not a reason to move the
# board to the start of the line.
fakeCursor 5 {0} {3} 3
set ::fakeVarCounts [dict create "3,0" 2]
checkEq "a refused ply still says so" \
    [::review::writeMove 4 good 20 {}] {ply 4 is not in this game}
checkEq "and the variation path is restored" [list $::fakeLoc $::fakeLevel] {5 1}
check "the board did not end up at the start of the line" \
    [expr {$::fakeLoc != 0}]

# If the line cannot be found again the board goes to the start of the line, and
# that is still a write, not a refusal: the comment landed.
fakeCursor 5 {1} {3} 10
set ::fakeVarCounts [dict create "3,0" 1]
checkEq "a write whose line is gone still counts as written" \
    [::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt}}] {}
# The base ply the restore reached is a known position: keep it rather than
# jumping to the start of the game.
checkEq "and the board is left on the base ply" \
    [list $::fakeLoc $::fakeLevel] {3 0}

# A null move at the ply being written: there is no move to drop from the
# engine's lines, so the best line is inserted rather than discarded on a guess.
::review::reset
::review::setValue var_lines 1
set ::fakeComment ""
set ::fakeMainLine [list {position startpos moves} m1 m2 m3 \
    "position fen 8/8/8/8/8/8/8/K6k w - - 0 1 moves" m6]
fakeCursor 5 {} {} 10
::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt}}
check "with a null move nothing is dropped" \
    [expr {[lsearch -exact $::calls {add pvBest}] >= 0}] $::calls

puts "a rejected variation move is a refusal"

# ::uci::sc_move_add answers 1 when the game refuses a move. Half a line is not a
# line: the variation is deleted and the refusal is reported, so a caller that
# counts successful writes does not count a partial one.
::review::reset
::review::setValue var_lines 1
set ::fakeComment ""
set ::fakeMainLine [list {position startpos moves} m1 m2 m3 pvBest m5]
set ::fakeVars {}
fakeCursor 5 {} {} 10
namespace eval ::uci {
    proc sc_move_add {moves} {
        lappend ::calls [list add $moves]
        if {$moves eq "pvAlt"} { return 1 }
        return 0
    }
}
set why [::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt}}]
check "a variation the game refuses is reported" [expr {$why ne ""}]
check "and names the move that was rejected" [string match {*pvAlt*} $why]
check "the half-written variation is deleted, not left behind" \
    [expr {[lsearch -exact $::calls {var delete}] >= 0}] $::calls
check {the comment still landed with its [%eval]} \
    [string match {*%eval*} $::fakeComment]

puts "\nsaved settings"
# Review Settings is an ordinary preference: the values are option variables, and
# the working copy starts from them. This is what a restart looks like.
::review::reset
set ::reviewopt(depth) 25
set ::reviewopt(mpv) 2
set ::reviewopt(var_lines) 2
set ::review::S [dict create]
checkEq "a saved depth is the one in force" [::review::get depth] 25
checkEq "and a saved mpv" [::review::get mpv] 2
checkEq "and a saved variation count" [::review::get var_lines] 2
checkEq "the settings that were never saved keep their default" \
    [::review::get var_cp] 0
::review::setValue depth 30
checkEq "a change is written where the options file reads it" $::reviewopt(depth) 30
::review::setValue depth 0
checkEq "and a refused change is not written" $::reviewopt(depth) 30
# A hand-edited options file must not decide how the pass searches.
set ::reviewopt(depth) 0
set ::reviewopt(mpv) 99
set ::reviewopt(var_lines) 40
set ::review::S [dict create]
checkEq "a saved depth below the floor is raised to it" [::review::get depth] 6
checkEq "a saved mpv above the ceiling is lowered to it" [::review::get mpv] 5
checkEq "and var_lines follows the mpv it was saved with" [::review::get var_lines] 5
set ::reviewopt(mpv) 1
set ::review::S [dict create]
checkEq "one line means no variations at all" [::review::get var_lines] 0
set ::reviewopt(depth) "deep"
set ::review::S [dict create]
checkEq "a value that is not a number is ignored" [::review::get depth] 18
set ::reviewopt(move_comment_wait) 2
set ::reviewopt(diagram) 3
set ::review::S [dict create]
checkEq "a flag saved above 1 is on, not invalid" [::review::get move_comment_wait] 1
checkEq "and the diagram switch is normalised too" [::review::get diagram] 1
checkEq "and the setter accepts what was loaded" \
    [::review::setValue move_comment_wait [::review::get move_comment_wait]] ""
set ::reviewopt(skip_book) -4
set ::review::S [dict create]
checkEq "a negative flag is on as well" [::review::get skip_book] 1
checkEq "the diagram switch refuses anything but 0 or 1" \
    [::review::setValue diagram 2] "diagram is 0 or 1"
array unset ::reviewopt
::review::reset

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
