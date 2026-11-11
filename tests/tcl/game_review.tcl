# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# game_review.tcl -- the review pass: its settings, its two decisions, and the
# line map the pass walks.
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
source [file join $root tcl tools comment_colors.tcl]
source [file join $root tcl tools game_review.tcl]

puts "settings"

::review::reset
checkEq "mpv defaults to 3" [::review::get mpv] 3
checkEq "depth defaults to 18" [::review::get depth] 18
checkEq "a diagram is written at mistakes and blunders by default" \
    [::review::get diagram] 1
# The coach is an extra layer over a review that works without it, so a fresh
# install must not spend a user's requests without being asked.
checkEq "coach prose is off by default" [::review::get coach] 0
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

# movetime is the pass's own ceiling on one position, in milliseconds. 0 means
# the review has no cap of its own - the preset's Limits.movetime, or no bound at
# all, decides (::review::passLimits) - so it is a value the setter takes rather
# than a blank field.
checkEq "the review sets no time cap of its own by default" [::review::get movetime] 0
checkEq "a cap can be set" [::review::setValue movetime 1500] ""
checkEq "and is remembered" [::review::get movetime] 1500
checkEq "a negative cap is refused" [::review::setValue movetime -1] {movetime must be 0..3600000}
checkEq "a cap beyond the preset layer's ceiling is refused" \
    [::review::setValue movetime 3600001] {movetime must be 0..3600000}
checkEq "and the old value is kept" [::review::get movetime] 1500
checkEq "a non-number is refused" [::review::setValue movetime soon] {movetime must be a whole number}
checkEq "0 is the way back to no cap" [::review::setValue movetime 0] ""
# A hand-edited options file must not decide that a pass never gets a search.
set ::reviewopt(movetime) -5
set ::review::S [dict create]
checkEq "a negative value in the options file reads as no cap" [::review::get movetime] 0
unset ::reviewopt(movetime)
::review::reset
checkEq "and the default is back with the working copy" [::review::get movetime] 0

puts "the limits a pass searches under"

# Depth is a floor and time is a ceiling. The preset may only deepen a pass, and
# a time cap only ever shortens one. The cap has one owner at a time: the
# review's own value when it has one, otherwise the preset's, otherwise none -
# never the smaller of the two, which would search shallower than either setting
# asked for. ::review::passLimits is that table, so every caller (Game Review,
# Move Comment, the batch, annotate) reads the same answer.
::review::reset
set noPreset [dict create depth {} movetime {}]
set presetOnly [dict create depth 30 movetime 900]
set shallowPreset [dict create depth 12 movetime {}]

checkEq "neither side caps: the review's depth alone" \
    [::review::passLimits [::review::all] $noPreset] {depth 18 movetime {}}
checkEq "the preset's cap applies when the review sets none" \
    [::review::passLimits [::review::all] $presetOnly] {depth 30 movetime 900}
checkEq "the preset's depth is still a floor under that cap" \
    [dict get [::review::passLimits [::review::all] $presetOnly] depth] 30

::review::setValue movetime 2000
checkEq "the review's own cap wins over the preset's" \
    [::review::passLimits [::review::all] $presetOnly] {depth 30 movetime 2000}
checkEq "and is not the lesser of the two" \
    [dict get [::review::passLimits [::review::all] $presetOnly] movetime] 2000
checkEq "the review's cap with no preset cap" \
    [::review::passLimits [::review::all] $noPreset] {depth 18 movetime 2000}
checkEq "a shallower preset lowers neither the depth nor the cap" \
    [::review::passLimits [::review::all] $shallowPreset] {depth 18 movetime 2000}
checkEq "an empty preset leaves both as the review has them" \
    [::review::passLimits [::review::all] {}] {depth 18 movetime 2000}
::review::setValue movetime 0
checkEq "clearing the cap falls back to the preset's" \
    [::review::passLimits [::review::all] $presetOnly] {depth 30 movetime 900}
checkEq "and to none when the preset has none" \
    [::review::passLimits [::review::all] $noPreset] {depth 18 movetime {}}
::review::reset

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

puts "the position assessment"

# The Informant table, in pawns from White's point of view. The thresholds are
# strict: 0.5 exactly is already "+=".
checkEq "a level position is =" [::review::scoreToNag 0.0] "="
checkEq "a small White plus is +=" [::review::scoreToNag 0.6] "+="
checkEq "a clear White plus is +/-" [::review::scoreToNag 1.6] "+/-"
checkEq "a winning White plus is +-" [::review::scoreToNag 2.6] "+-"
checkEq "a crushing White plus is +--" [::review::scoreToNag 4.5] "+--"
checkEq "the Black half mirrors it" [::review::scoreToNag -0.6] "=+"
checkEq "and a crushing Black plus is --+" [::review::scoreToNag -4.5] "--+"
checkEq "a negative level position is = too" [::review::scoreToNag -0.4] "="
checkEq "the threshold is strict" [::review::scoreToNag 0.5] "+="
checkEq "no score means no assessment" [::review::assessmentNag ""] ""
checkEq "centipawns become pawns" [::review::assessmentNag 160] "+/-"
set ::informant(+=) 1.0
checkEq "the thresholds are the user's" [::review::scoreToNag 0.8] "="
unset -nocomplain ::informant(+=)

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
# A time cap bounds the pass, not the wait. The wait is the review's depth: a
# capped pass may stop shallower than ::review::depth, and Move Comment then
# writes that shallower verdict rather than waiting for a depth the cap will
# never reach.
::review::reset
::review::setValue movetime 1000
checkEq "a time cap does not lower the depth the wait asks for" \
    [::review::moveCommentPlan 12] 18
checkEq "and a deep enough analysis still writes" [::review::moveCommentPlan 18] now
::review::reset

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
# The verdict is stored inside the review's colour span; stripping its tokens
# must not leave the empty wrapper behind.
checkEq "a wrapped verdict and score go with their span" \
    [::review::stripReviewTokens [::commentcolors::wrapReview {[good] [%eval +0.20]}]] {}
checkEq "a wrapped verdict leaves the reader's prose" \
    [::review::stripReviewTokens "My note. [::commentcolors::wrapReview {[good] [%eval +0.20]}]"] "My note."
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

puts "the stub board"

# The sc_* layer is stubbed: the point of these checks is which calls are made,
# not what scid does with them. The review navigates by route, so the stub is a
# movelist rather than a ply counter. A node is one position and the move that
# led to it:
#
#   uci san     the move into it ("" at the root and at a null move)
#   comment     its comment;  nags  its NAGs
#   prev next   the move before and after it in its own line ("" at the ends)
#   vars        the variations branching from the position AFTER it, the first
#               move of each in order - what sc_var count/list/enter read, and
#               what renumbering a sibling changes
#   ply         the absolute sc_pos location
#
# sc_var level and number are read off the tree, never remembered: a sibling
# inserted before the cursor's own variation has to show up as a renumber.
set ::fakeNodes [dict create]
set ::fakeNextId 0
set ::fakeCur 0
set ::calls {}
set ::listAt {}

proc fakeNew {} {
    incr ::fakeNextId
    set id $::fakeNextId
    dict set ::fakeNodes $id [dict create uci "" san "" comment "" nags {} \
        prev "" next "" vars {} ply 0]
    return $id
}
proc fakeGet {id key} {
    if {![dict exists $::fakeNodes $id]} { return "" }
    return [dict get [dict get $::fakeNodes $id] $key]
}
proc fakeSet {id key value} {
    set n [dict get $::fakeNodes $id]
    dict set n $key $value
    dict set ::fakeNodes $id $n
}
# A game: the root, then the main line. A "" move is a null move - a ply with
# no move, which UCI_mainLine reports as a fresh position header.
proc fakeBoard {moves} {
    set ::fakeNodes [dict create]
    set ::fakeNextId 0
    dict set ::fakeNodes 0 [dict create uci "" san "" comment "" nags {} \
        prev "" next "" vars {} ply 0]
    set prev 0
    foreach m $moves {
        set id [fakeNew]
        fakeSet $id uci $m
        fakeSet $id san "SAN_$m"
        fakeSet $id prev $prev
        fakeSet $id ply [expr {[fakeGet $prev ply] + 1}]
        fakeSet $prev next $id
        set prev $id
    }
    set ::fakeCur $prev
    set ::calls {}
    set ::listAt {}
    set ::fakeGone {}
    return $prev
}
# The main-line node at `ply` (0 is the root), or the last one before it.
proc fakeAtPly {ply} {
    set id 0
    for {set i 0} {$i < $ply} {incr i} {
        set nxt [fakeGet $id next]
        if {$nxt eq ""} { break }
        set id $nxt
    }
    return $id
}
# Put the cursor on the main line at `ply`.
proc fakeGoto {ply} {
    set ::fakeCur [fakeAtPly $ply]
    set ::calls {}
    set ::listAt {}
    return $::fakeCur
}
# A variation branching from the position after node `branch`, inserted at
# `index` among its siblings ("" appends). Returns its nodes, first move first.
# No moves is an empty variation: one that has been opened and not filled - the
# only state in which cursorSave reports 0 moves inside a level.
proc fakeVariation {branch moves {index ""}} {
    set ids {}
    set prev $branch
    if {![llength $moves]} {
        set id [fakeNew]
        fakeSet $id prev $branch
        # A variation that has been opened and not filled is the branch position
        # itself: no move has been played, so the location counter has not
        # advanced past the branch. That is the state cursorSave reports as
        # 0 moves inside a level.
        fakeSet $id ply [fakeGet $branch ply]
        lappend ids $id
    } else {
        foreach m $moves {
            set id [fakeNew]
            fakeSet $id uci $m
            fakeSet $id san "SAN_$m"
            fakeSet $id prev $prev
            fakeSet $id ply [expr {[fakeGet $prev ply] + 1}]
            if {$prev ne $branch} { fakeSet $prev next $id }
            lappend ids $id
            set prev $id
        }
    }
    set vars [fakeGet $branch vars]
    if {$index eq ""} {
        lappend vars [lindex $ids 0]
    } else {
        set vars [linsert $vars $index [lindex $ids 0]]
    }
    fakeSet $branch vars $vars
    return $ids
}
# Put the cursor on node `id`. The variation stack is not remembered anywhere:
# it is read off the tree, so a renumbering is visible without being told.
proc fakeCursorAt {id} {
    set ::fakeCur $id
    set ::calls {}
    set ::listAt {}
    return $id
}
# The variation numbers entered to reach `id`, outermost first.
proc fakeRoute {id} {
    set route {}
    set cur $id
    while {$cur ne "" && $cur != 0} {
        set n [lsearch -exact [fakeGet [fakeGet $cur prev] vars] $cur]
        if {$n >= 0} { set route [linsert $route 0 $n] }
        set cur [fakeGet $cur prev]
    }
    return $route
}
# The first move of the innermost variation on the path to `id`.
proc fakeVarRoot {id} {
    set cur $id
    while {$cur ne "" && $cur != 0} {
        if {[lsearch -exact [fakeGet [fakeGet $cur prev] vars] $cur] >= 0} { return $cur }
        set cur [fakeGet $cur prev]
    }
    return ""
}
# `position ... moves ...` for the cursor's position, path-addressed: the moves
# since the root, or since the last null move.
proc fakeCurrentPos {{id ""}} {
    if {$id eq ""} { set id $::fakeCur }
    set path {}
    set cur $id
    while {$cur != 0} {
        if {[fakeGet $cur uci] eq ""} {
            set s "position fen FEN$cur moves"
            foreach m $path { append s " " $m }
            return $s
        }
        set path [linsert $path 0 [fakeGet $cur uci]]
        set cur [fakeGet $cur prev]
    }
    set s "position startpos moves"
    foreach m $path { append s " " $m }
    return $s
}
# A move added by ::uci::sc_move_add: the fresh variation node becomes it and
# the cursor moves onto it, so every later move is the next in that variation.
proc fakeAddMove {m} {
    set id $::fakeCur
    if {[fakeGet $id uci] eq ""} {
        fakeSet $id uci $m
        fakeSet $id san "SAN_$m"
        fakeSet $id ply [expr {[fakeGet [fakeGet $id prev] ply] + 1}]
        return
    }
    set new [fakeNew]
    fakeSet $new uci $m
    fakeSet $new san "SAN_$m"
    fakeSet $new prev $id
    fakeSet $new ply [expr {[fakeGet $id ply] + 1}]
    fakeSet $id next $new
    set ::fakeCur $new
}
# Where the board is, in the terms a restore is judged by.
proc fakeWhere {} {
    return [list [sc_pos fen] [sc_pos location] [sc_var level] [sc_var number]]
}

# The board's own view of a position: a ply counter, a fen, and the comment and
# NAGs of the move that led to it. The fen is the node's identity - two nodes are
# the same position only if they are the same node - which is what a restore
# compares.
# (Comments cannot live inside a braced switch body: it is a list, so a `#` there
# is a pattern, not a comment.)
proc sc_pos {args} {
    switch -- [lindex $args 0] {
        location { return [fakeGet $::fakeCur ply] }
        fen { return "FEN$::fakeCur" }
        getComment { return [fakeGet $::fakeCur comment] }
        setComment {
            lappend ::calls [list setComment [lindex $args 1]]
            fakeSet $::fakeCur comment [lindex $args 1]
            return ""
        }
        getNags {
            set nags [fakeGet $::fakeCur nags]
            if {![llength $nags]} { return 0 }
            return $nags
        }
        addNag {
            set nag [lindex $args 1]
            lappend ::calls [list nag add $nag]
            set nags [fakeGet $::fakeCur nags]
            if {[lsearch -exact $nags $nag] < 0} { lappend nags $nag }
            fakeSet $::fakeCur nags $nags
            return ""
        }
        clearNags { fakeSet $::fakeCur nags {} ; return "" }
    }
    return ""
}
# Navigation. `sc_move ply N` is the MAIN line - MoveToStart then N MoveForward -
# so it leaves every variation; past the last move it stops there, as MoveToPly
# does. `forward` answers how many moves were actually made, 0 at the leaf, so a
# caller can find the end of a line without an error.
proc sc_move {args} {
    set what [lindex $args 0]
    set n [lindex $args 1]
    switch -- $what {
        ply {
            set ::fakeCur [fakeAtPly $n]
            lappend ::calls [list move ply $n]
            return ""
        }
        forward {
            set count 1
            if {$n ne ""} { set count $n }
            set made 0
            for {set i 0} {$i < $count} {incr i} {
                set nxt [fakeGet $::fakeCur next]
                if {$nxt eq ""} { break }
                set ::fakeCur $nxt
                incr made
            }
            lappend ::calls [list move forward $n]
            return $made
        }
        back {
            set count 1
            if {$n ne ""} { set count $n }
            set made 0
            for {set i 0} {$i < $count} {incr i} {
                set prev [fakeGet $::fakeCur prev]
                if {$prev eq ""} { break }
                # MoveBackup refuses at a variation's first move: the way out of
                # a variation is sc_var exit, not back.
                if {[lsearch -exact [fakeGet $prev vars] $::fakeCur] >= 0} { break }
                set ::fakeCur $prev
                incr made
            }
            lappend ::calls [list move back $n]
            return $made
        }
        end {
            set ::fakeCur [fakeAtPly 1000000]
            lappend ::calls [list move end $n]
            return ""
        }
        endVar {
            while {[fakeGet $::fakeCur next] ne ""} { set ::fakeCur [fakeGet $::fakeCur next] }
            lappend ::calls [list move endVar $n]
            return ""
        }
    }
    lappend ::calls [list move $what $n]
    return ""
}
# The variations at the current position. `list` answers the first move of every
# sibling, as the real command reports it: the only name a variation has that
# survives an insertion. `level` and `number` are read off the tree, so a
# renumbering is visible without being told.
proc sc_var {args} {
    lappend ::calls [list var [lindex $args 0]]
    switch -- [lindex $args 0] {
        count { return [llength [fakeGet $::fakeCur vars]] }
        list {
            lappend ::listAt [fakeGet $::fakeCur ply]
            set out {}
            foreach v [fakeGet $::fakeCur vars] { lappend out [fakeGet $v uci] }
            return $out
        }
        level { return [llength [fakeRoute $::fakeCur]] }
        number {
            set route [fakeRoute $::fakeCur]
            if {![llength $route]} { return 0 }
            return [lindex $route end]
        }
        enter {
            set n [lindex $args 1]
            set vars [fakeGet $::fakeCur vars]
            if {$n >= [llength $vars]} { error "No such variation!" }
            # A variation deleted between the save and the restore: the number
            # the cursor was saved with no longer names a line.
            if {[lsearch -exact $::fakeGone $n] >= 0} { error "No such variation!" }
            lset ::calls end [list var enter $n]
            # MoveIntoVariation and then MoveForward: entering plays the
            # variation's first move, so the cursor lands on that move.
            set ::fakeCur [lindex $vars $n]
            return ""
        }
        exit {
            set root [fakeVarRoot $::fakeCur]
            if {$root eq ""} { error "No such variation!" }
            set ::fakeCur [fakeGet $root prev]
            return ""
        }
        create {
            set id [fakeNew]
            fakeSet $id prev $::fakeCur
            fakeSet $id ply [expr {[fakeGet $::fakeCur ply] + 1}]
            set vars [fakeGet $::fakeCur vars]
            lappend vars $id
            fakeSet $::fakeCur vars $vars
            set ::fakeCur $id
            return ""
        }
        delete {
            set root [fakeVarRoot $::fakeCur]
            if {$root eq ""} { error "No such variation!" }
            lappend ::calls {var delete}
            set parent [fakeGet $root prev]
            fakeSet $parent vars [lsearch -all -inline -not -exact [fakeGet $parent vars] $root]
            set ::fakeCur $parent
            return ""
        }
    }
    return ""
}
# UCI_mainLine is the setup followed by the moves, as the real command returns
# it, so element $ply is the move played at ply $ply; a null move stands in for
# its own ply as a fresh position header.
proc sc_game {args} {
    set what [lindex $args 0]
    if {$what eq "UCI_mainLine"} {
        set out {"position startpos moves"}
        set id 0
        while {[set nxt [fakeGet $id next]] ne ""} {
            set id $nxt
            if {[fakeGet $id uci] eq ""} {
                lappend out "position fen FEN$id moves"
            } else {
                lappend out [fakeGet $id uci]
            }
        }
        return $out
    }
    if {$what eq "UCI_currentPos"} { return [fakeCurrentPos] }
    if {$what eq "info"} {
        switch -- [lindex $args 1] {
            previousMoveUCI {
                # A null move is spelled 0000 in UCI, as the real command does.
                if {$::fakeCur == 0} { return "" }
                if {[fakeGet $::fakeCur uci] eq ""} { return 0000 }
                return [fakeGet $::fakeCur uci]
            }
            previousMove { return [fakeGet $::fakeCur san] }
        }
    }
    return ""
}
namespace eval ::uci {
    proc sc_move_add {moves} {
        lappend ::calls [list add $moves]
        fakeAddMove $moves
        return 0
    }
}

# The moves of a full game, long enough for every cursor below.
set game {e2e4 e7e5 g1f3 b8c6 f1b5 a7a6 b5a4 g8f6 d7d6 e4e5 a7a6}

puts "where the board was"

# On the main line there is nothing to walk back into: the ply counter is the
# whole position.
fakeBoard $game
fakeGoto 5
set state [::review::cursorSave]
checkEq "a main-line cursor is a ply" [dict get $state loc] 5
checkEq "whose base is itself" [dict get $state base] 5
checkEq "with an empty path" [dict get $state path] {}
checkEq "and it restores exactly" [::review::cursorRestore $state] 1
checkEq "leaving the board where it was" [list [sc_pos location] [sc_var level]] {5 0}

# One variation, branched from ply 3, cursor two moves inside it.
set var [fakeVariation [fakeAtPly 3] {c7c5 g1f3 d7d6}]
fakeCursorAt [lindex $var 1]
set state [::review::cursorSave]
checkEq "one variation: the captured ply" [dict get $state loc] 5
checkEq "one variation: the main-line base" [dict get $state base] 3
checkEq "one variation: which one and how far in" [dict get $state path] {{0 2}}
checkEq "saving leaves the board on the base ply" [list [sc_pos location] [sc_var level]] {3 0}
set ::calls {}
checkEq "it restores exactly" [::review::cursorRestore $state] 1
checkEq "by walking the path" $::calls \
    {{move ply 3} {var enter 0} {move forward 1} {var level}}
checkEq "on the captured ply, in the variation" \
    [list [sc_pos location] [sc_var level] [sc_var number]] {5 1 0}

# A variation inside a variation: the path is outermost first, because that is
# the order a restore has to enter.
fakeBoard $game
fakeVariation [fakeAtPly 3] {a7a6 b5a4}
set outer [fakeVariation [fakeAtPly 3] {c7c5 g1f3 d7d6}]
set inner [fakeVariation [lindex $outer 2] {b7b6 b5c6}]
fakeCursorAt [lindex $inner 1]
set state [::review::cursorSave]
checkEq "nested: the path is innermost-first when captured, outer first when read" \
    [dict get $state path] {{1 3} {0 2}}
checkEq "nested: the base is the main-line ply" [dict get $state base] 3
set ::calls {}
checkEq "nested: it restores exactly" [::review::cursorRestore $state] 1
checkEq "nested: entering each level and walking the rest of it" $::calls \
    {{move ply 3} {var enter 1} {move forward 2} {var enter 0} {move forward 1} {var level}}
checkEq "nested: on the captured ply, both levels deep" \
    [list [sc_pos location] [sc_var level] [fakeRoute $::fakeCur]] {8 2 {1 0}}

# A cursor inside a variation that has been opened and never filled: entering
# it plays nothing, so the restore has to step back out of a move that was not
# played.
fakeBoard $game
set empty [fakeVariation [fakeAtPly 3] {}]
fakeCursorAt [lindex $empty 0]
set state [::review::cursorSave]
checkEq "a cursor in an empty variation" [dict get $state path] {{0 0}}
set ::calls {}
checkEq "it restores exactly too" [::review::cursorRestore $state] 1
checkEq "with nothing to walk inside it" $::calls \
    {{move ply 3} {var enter 0} {move back {}} {var level}}
checkEq "and is still inside the variation" [list [sc_pos location] [sc_var level]] {3 1}

# An insertion at the same branch point renumbers the siblings - writeMove does
# exactly that - so the captured number may no longer name the same line. The
# restore must say so and retreat to the base ply, never land inside the wrong
# variation.
fakeBoard $game
set first [fakeVariation [fakeAtPly 3] {c7c5 g1f3 d7d6}]
fakeVariation [fakeAtPly 3] {d7d5 e4d5 e5d4}
fakeCursorAt [lindex $first 1]
set state [::review::cursorSave]
checkEq "the first variation, two moves in" [dict get $state path] {{0 2}}
# A new variation before it: variation 0 is now a different line with the same
# move count, so the ply and level checks alone would accept it.
fakeVariation [fakeAtPly 3] {b7b6 g1f3} 0
checkEq "a renumbered sibling is not the same position" [::review::cursorRestore $state] 0
checkEq "and the board is on the base ply, not in some other line" \
    [list [sc_pos location] [sc_var level]] {3 0}
# A variation that is gone is the same fallback.
checkEq "a path into a variation that is gone falls back" \
    [::review::cursorRestore [list loc 5 base 3 path {{5 2}} fen nowhere]] 0
checkEq "and leaves the board on the base ply" \
    [list [sc_pos location] [sc_var level]] {3 0}

# A state that cannot be read is a fallback, not an exception.
checkEq "an unreadable cursor does not raise" \
    [::review::cursorRestore [list loc now base 2 path {}]] 0

puts "writing one move"

::review::reset
::review::setValue var_lines 1
# The engine's best line is the move played at ply 4, so it is not a variation.
fakeBoard {m1 m2 m3 pvBest m5 m6 m7 m8 m9 m10}
fakeGoto 5
fakeSet [fakeAtPly 4] comment "Existing note."
set ::calls {}
set err [::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt}}]
checkEq "it succeeds" $err {}
check "the comment is written at the move" \
    [expr {[lsearch -exact $::calls \
        "setComment {Existing note. [::commentcolors::wrapReview {[blunder] [%eval -1.20]}]}"] >= 0}]
set written ""
foreach c $::calls { if {[lindex $c 0] eq "setComment"} { set written [lindex $c 1] } }
check "and the verdict carries the review's green" \
    [expr {[string first $::commentcolors::reviewColor $written] >= 0}] $written
check "a variation is created" [expr {[lsearch -exact $::calls {var create}] >= 0}]
check "with the alternate line" [expr {[lsearch -exact $::calls {add pvAlt}] >= 0}]
check "and not with the line the game already played" \
    [expr {[lsearch -exact $::calls {add pvBest}] < 0}]
check "and the game is left where it was" [expr {[sc_pos location] == 5}]

# A blunder: the best line is not the move played, so it is the variation.
fakeBoard {m1 m2 m3 m5 m6}
fakeGoto 5
set ::calls {}
::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt}}
check "the best line is inserted" [expr {[lsearch -exact $::calls {add pvBest}] >= 0}]
check "and the weaker line is not" [expr {[lsearch -exact $::calls {add pvAlt}] < 0}]

# No variations when the setting is off, and none when the move is not there.
set ::calls {}
::review::setValue var_lines 0
::review::writeMove 4 good 20 {{20 pvBest} {10 pvAlt}}
check "no variation with var_lines 0" [expr {[lsearch -exact $::calls {var create}] < 0}]

fakeBoard {m1 m2 m3}
fakeGoto 2
checkEq "a ply that is not in the game is refused" \
    [::review::writeMove 4 good 20 {}] {ply 4 is not in this game}
check "and the game is left where it was, not moved to the start" \
    [expr {[sc_pos location] == 2}]

# var_lines > 1 inserts every distinct alternative, and a variation a previous
# review already wrote is not duplicated.
::review::reset
::review::setValue var_lines 2
fakeBoard {m1 m2 m3 pvBest m5}
fakeGoto 5
fakeSet [fakeAtPly 4] comment "Existing note."
::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt} {-250 pvThird}}
check "both alternates are inserted" \
    [expr {[lsearch -exact $::calls {add pvAlt}] >= 0 \
        && [lsearch -exact $::calls {add pvThird}] >= 0}] $::calls
check "two variations are created" \
    [expr {[llength [lsearch -all $::calls {var create}]] == 2}] $::calls
checkEq "the variation list is read before the move, not after it" \
    [lindex $::listAt 0] 3

# A variation a previous review already wrote is not duplicated, and a new line
# is still added: the same tree, written twice.
fakeBoard {m1 m2 m3 pvBest m5}
fakeGoto 5
fakeVariation [fakeAtPly 3] {pvAlt q1 q2}
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
fakeBoard {m1 m2 m3 pvBest m5}
set var [fakeVariation [fakeAtPly 3] {v1 v2}]
fakeCursorAt [lindex $var 1]
checkEq "a write inside a variation succeeds" \
    [::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt}}] {}
checkEq "and the variation path is restored" [list [sc_pos location] [sc_var level]] {5 1}
checkEq "in the same variation" [sc_var number] 0

# The refusal path restores it too - and a refusal is not a reason to move the
# board to the start of the line.
fakeBoard {m1 m2 m3}
set var [fakeVariation [fakeAtPly 3] {v1 v2}]
fakeCursorAt [lindex $var 1]
checkEq "a refused ply still says so" \
    [::review::writeMove 4 good 20 {}] {ply 4 is not in this game}
checkEq "and the variation path is restored" [list [sc_pos location] [sc_var level]] {5 1}
check "the board did not end up at the start of the line" \
    [expr {[sc_pos location] != 0}]

# The line the cursor stood in is gone by the time the write puts the cursor
# back - the hazard the map's anchors exist for. The comment landed, so the
# write counts as written, and the base ply it falls back to is a known
# position: keep it rather than jumping to the start of the game.
fakeBoard {m1 m2 m3 pvBest m5}
set var [fakeVariation [fakeAtPly 3] {v1 v2}]
fakeCursorAt [lindex $var 1]
set ::fakeGone {0}
checkEq "a write whose line is gone still counts as written" \
    [::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt}}] {}
checkEq "and the board is left on the base ply" \
    [list [sc_pos location] [sc_var level]] {3 0}

# A null move at the ply being written: there is no move to drop from the
# engine's lines, so the best line is inserted rather than discarded on a guess.
::review::reset
::review::setValue var_lines 1
fakeBoard {m1 m2 m3 {} m6 m7 m8 m9 m10}
fakeGoto 5
::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt}}
check "with a null move nothing is dropped" \
    [expr {[lsearch -exact $::calls {add pvBest}] >= 0}] $::calls

puts "a rejected variation move is a refusal"

# ::uci::sc_move_add answers 1 when the game refuses a move. Half a line is not a
# line: the variation is deleted and the refusal is reported, so a caller that
# counts successful writes does not count a partial one.
::review::reset
::review::setValue var_lines 1
fakeBoard {m1 m2 m3 pvBest m5}
fakeGoto 5
namespace eval ::uci {
    proc sc_move_add {moves} {
        lappend ::calls [list add $moves]
        fakeAddMove $moves
        if {$moves eq "pvAlt"} { return 1 }
        return 0
    }
}
set why [::review::writeMove 4 blunder -120 {{-120 pvBest} {-200 pvAlt}}]
check "a variation the game refuses is reported" [expr {$why ne ""}]
check "and names the move that was rejected" [string match {*pvAlt*} $why]
check "the half-written variation is deleted, not left behind" \
    [expr {[lsearch -exact $::calls {var delete}] >= 0}] $::calls
check "the comment still landed with its \[%eval\]" \
    [string match {*%eval*} [fakeGet [fakeAtPly 4] comment]]
namespace eval ::uci {
    proc sc_move_add {moves} {
        lappend ::calls [list add $moves]
        fakeAddMove $moves
        return 0
    }
}

puts "the line the cursor is on"

# The line the review walks is the line the user is looking at: the main-line
# prefix to the branch, then the variation - and any variation inside it - to
# its leaf. It is addressed by route and keyed by line-local index, the shape
# mainLineMap already has, so the plan and the verdicts need nothing new.

# A cursor on the main line: the map is that line and nothing else.
fakeBoard {e2e4 e7e5 g1f3 b8c6 f1b5}
fakeGoto 5
set before [fakeWhere]
set map [::review::currentLineMap]
set ref [::review::mainLineMap [sc_game UCI_mainLine]]
checkEq "the main line: the same plies as mainLineMap" \
    [dict get $map plies] [dict get $ref plies]
checkEq "the main line: the same indexes" \
    [lsort -integer [dict keys [dict get $map moves]]] \
    [lsort -integer [dict keys [dict get $ref moves]]]
set bad {}
foreach k [dict keys [dict get $ref moves]] {
    if {[dict get $map moves $k] ne [dict get $ref moves $k]} { lappend bad move $k }
    if {[dict get $map positions $k] ne [dict get $ref positions $k]} { lappend bad position $k }
}
checkEq "the main line: the same move and position at every index" $bad {}
checkEq "the main line: the root position too" \
    [dict get $map positions 0] [dict get $ref positions 0]
checkEq "the main line: the node table is every index, the root included" \
    [lsort -integer [dict keys [dict get $map nodes]]] {0 1 2 3 4 5}
checkEq "the main line: nothing on it is a variation" \
    [dict get [dict get $map nodes] 3 route] {}
checkEq "the main line: the line kind" [dict get $map lineKind] main
checkEq "the main line: no route and no anchors" \
    [list [dict get $map cursorRoute] [dict get $map anchors]] {{} {}}
checkEq "the main line: the cursor index is the move under the cursor" \
    [dict get $map cursorIndex] 5
checkEq "the main line: every unlabelled move is judged" [dict get $map judged] {1 2 3 4 5}
checkEq "the main line: none of them is context" [dict get $map context] {}
checkEq "the main line: the cursor is untouched" [fakeWhere] $before

# A null move stands in for its own ply with a position header. The map records
# it as no move and takes the position from the header, exactly as mainLineMap
# reads the same game - the two must not disagree about a game with a null move
# in it, because the plan and the verdict layer read either map.
fakeBoard {e2e4 e7e5 {} f1b5}
fakeGoto 3
set map [::review::currentLineMap]
set ref [::review::mainLineMap [sc_game UCI_mainLine]]
set bad {}
foreach k [dict keys [dict get $ref moves]] {
    if {[dict get $map moves $k] ne [dict get $ref moves $k]} { lappend bad move $k }
    if {[dict get $map positions $k] ne [dict get $ref positions $k]} { lappend bad position $k }
}
checkEq "a null move: the same moves and positions as mainLineMap" $bad {}
checkEq "a null move: the ply carries no move" [dict get [dict get $map nodes] 3 uci] {}

# A map is built from a cursor, never guessed: a caller that hands over
# something else is told so rather than given the start of the game.
checkEq "a cursor that is not a cursorSave dict is refused" \
    [catch { ::review::currentLineMap [list loc 3] } err] 1
checkEq "and says what it wanted" $err "the cursor is not a cursorSave dict"

# A cursor in a variation: the prefix to the branch, then the variation to its
# leaf - the cursor standing two moves in does not shorten the line.
fakeBoard $game
set var [fakeVariation [fakeAtPly 3] {c7c5 g1f3 d7d6}]
fakeCursorAt [lindex $var 1]
set before [fakeWhere]
set map [::review::currentLineMap]
checkEq "a variation: the prefix, then the variation to its leaf" [dict get $map plies] 6
checkEq "a variation: the moves" \
    [list [dict get $map moves 3] [dict get $map moves 4] \
        [dict get $map moves 5] [dict get $map moves 6]] {g1f3 c7c5 g1f3 d7d6}
checkEq "a variation: the position at the leaf" [dict get $map positions 6] \
    "position startpos moves e2e4 e7e5 g1f3 c7c5 g1f3 d7d6"
checkEq "a variation: every node past the branch is on the variation" \
    [list [llength [dict get [dict get $map nodes] 4 route]] \
        [llength [dict get [dict get $map nodes] 6 route]]] {1 1}
checkEq "a variation: the line kind" [dict get $map lineKind] variation
checkEq "a variation: the anchor is the variation's first move" [dict get $map anchors] {c7c5}
checkEq "a variation: the cursor's route" [dict get $map cursorRoute] {0}
checkEq "a variation: the cursor's index" [dict get $map cursorIndex] 5
checkEq "a variation: the ply is diagnostic, and the node carries it" \
    [dict get [dict get $map nodes] 5 ply] 5
checkEq "a variation: the cursor is untouched" [fakeWhere] $before

# A variation inside a variation: the route is outermost first and reaches
# through both levels to the innermost leaf.
fakeBoard $game
fakeVariation [fakeAtPly 3] {a7a6 b5a4}
set outer [fakeVariation [fakeAtPly 3] {c7c5 g1f3 d7d6}]
set inner [fakeVariation [lindex $outer 2] {b7b6 b5c6}]
fakeCursorAt [lindex $inner 1]
set map [::review::currentLineMap]
checkEq "nested: both levels to the innermost leaf" [dict get $map plies] 8
checkEq "nested: the cursor is in both" [dict get $map cursorRoute] {1 0}
checkEq "nested: its index" [dict get $map cursorIndex] 8
checkEq "nested: both anchors, outermost first" [dict get $map anchors] {c7c5 b7b6}
checkEq "nested: the nested nodes carry both levels" \
    [list [dict get [dict get $map nodes] 7 route] \
        [dict get [dict get $map nodes] 8 route]] {{1 0} {1 0}}
checkEq "nested: the outer nodes carry one" [dict get [dict get $map nodes] 5 route] {1}
checkEq "nested: the moves" \
    [list [dict get $map moves 4] [dict get $map moves 7] [dict get $map moves 8]] \
    {c7c5 b7b6 b5c6}

# Each level's anchor is the variation's first move, and the walk refuses a
# sibling that has taken its number: entering on the number alone would label
# another line's move.
fakeBoard $game
set first [fakeVariation [fakeAtPly 3] {c7c5 g1f3 d7d6}]
fakeVariation [fakeAtPly 3] {d7d5 e4d5 e5d4}
fakeCursorAt [lindex $first 1]
set map [::review::currentLineMap]
checkEq "the anchor is read at the branch, before entering" [dict get $map anchors] {c7c5}
fakeVariation [fakeAtPly 3] {b7b6 g1f3} 0
set ::calls {}
set ::seen {}
set r [::review::visitLine $map {4 5 6} \
    {apply {{node} { lappend ::seen [dict get $node index] }}}]
checkEq "a renumbered sibling is refused, not entered" [dict get $r restored] 0
checkEq "and the body never runs on the wrong line" $::seen {}
checkEq "and the board is left on the base ply" \
    [list [sc_pos location] [sc_var level]] {3 0}

# The walk itself: one root-to-leaf pass, the body at each named node with the
# cursor on it, and the cursor back exactly. Every node's position is the map's
# own - the string the engine will be given.
fakeBoard $game
set outer [fakeVariation [fakeAtPly 3] {c7c5 g1f3 d7d6}]
set inner [fakeVariation [lindex $outer 2] {b7b6 b5c6}]
fakeCursorAt [lindex $inner 0]
set map [::review::currentLineMap]
set before [fakeWhere]
set ::seen {}
set ::agree 1
# The body needs the map to compare positions against, and apply's body has no
# access to the harness's variables, so the map is passed in beside the node:
# visitLine appends the node to whatever command prefix it is given.
set mark [list apply {{map node} {
    set i [dict get $node index]
    lappend ::seen $i
    if {[sc_pos location] != [dict get $node ply]} { set ::agree 0 }
    if {[sc_pos fen] ne [dict get $node fen]} { set ::agree 0 }
    if {[sc_game UCI_currentPos] ne [dict get $map positions $i]} { set ::agree 0 }
}} $map]
set r [::review::visitLine $map {1 2 3 4 5 6 7 8} $mark]
checkEq "the walk visits every node in order" $::seen {1 2 3 4 5 6 7 8}
check "the cursor is on each node as the body runs" $::agree
checkEq "the walk puts the cursor back exactly" [dict get $r restored] 1
checkEq "and leaves it where the map found it" [fakeWhere] $before
# A subset of the line is walked without stopping short of it: the descent still
# goes to the leaf, only the body is selective.
set ::seen {}
set r [::review::visitLine $map {5} {apply {{node} { lappend ::seen [dict get $node index] }}}]
checkEq "a partial walk still reaches the node" $::seen {5}
checkEq "and restores the cursor" [dict get $r restored] 1

# What counts as reviewed: a verdict is the review's own label at the tail of
# the comment. A bare [%eval], the user's prose, a user NAG and a [Coach] line
# are notes, not verdicts, so the move is still judged.
fakeBoard $game
set var [fakeVariation [fakeAtPly 3] {c7c5 g1f3 d7d6}]
fakeSet [lindex $var 0] comment {[%eval +0.30]}
fakeSet [lindex $var 1] comment {A quiet developing move.}
fakeSet [lindex $var 2] comment {[Coach] This keeps the tension.}
fakeSet [lindex $var 2] nags {?!}
fakeCursorAt [lindex $var 2]
set map [::review::currentLineMap]
checkEq "a bare \[%eval\] is not a verdict" \
    [dict get [dict get $map nodes] 4 hasVerdict] 0
checkEq "the user's prose is not a verdict" \
    [dict get [dict get $map nodes] 5 hasVerdict] 0
checkEq "a \[Coach\] line is not a verdict" \
    [dict get [dict get $map nodes] 6 hasVerdict] 0
# The NAG is on the node - the stub is asked, not the map, because the map's
# nodes carry what a writer needs to read, not the whole position.
checkEq "the user's NAG is really on the node" [fakeGet [lindex $var 2] nags] {?!}
checkEq "a user NAG alone is not a verdict" \
    [dict get [dict get $map nodes] 6 hasVerdict] 0
checkEq "so the whole unlabelled line is judged" [dict get $map judged] {1 2 3 4 5 6}
checkEq "and there is no context to leave alone" [dict get $map context] {}
# A partial review: the labelled moves are context, the rest is the work.
fakeSet [fakeAtPly 1] comment "A good start. \[good\] \[%eval +0.00\]"
set map [::review::currentLineMap]
checkEq "a partly reviewed line judges only the gaps" [dict get $map judged] {2 3 4 5 6}
checkEq "and leaves the labelled move as context" [dict get $map context] {1}
# Every move labelled: the line is reviewed again rather than silently skipped.
foreach id [concat [list [fakeAtPly 1] [fakeAtPly 2] [fakeAtPly 3]] $var] {
    fakeSet $id comment {[good] [%eval +0.00]}
}
set map [::review::currentLineMap]
checkEq "a fully labelled line is judged whole, not silently skipped" \
    [dict get $map judged] {1 2 3 4 5 6}
checkEq "and has nothing left as context" [dict get $map context] {}

# The map is a read: the cursor is bit-identical after every build.
fakeBoard $game
set var [fakeVariation [fakeAtPly 3] {c7c5 g1f3 d7d6}]
set inner [fakeVariation [lindex $var 2] {b7b6 b5c6}]
set exact 1
foreach id [list [fakeAtPly 0] [fakeAtPly 5] [lindex $var 0] [lindex $var 2] [lindex $inner 1]] {
    fakeCursorAt $id
    set before [fakeWhere]
    set map [::review::currentLineMap]
    if {[fakeWhere] ne $before} { set exact 0 }
    if {![dict exists $map cursorIndex]} { set exact 0 }
}
check "the cursor is bit-identical after every build" $exact

# A variation opened and never filled contributes no move, so it contributes no
# node: the line is the prefix, and the cursor is still inside it.
fakeBoard $game
set empty [fakeVariation [fakeAtPly 3] {}]
fakeCursorAt [lindex $empty 0]
set before [fakeWhere]
set map [::review::currentLineMap]
checkEq "an empty variation contributes no node" [dict get $map plies] 3
checkEq "and no anchor" [dict get $map anchors] {}
checkEq "and no variation route on the last node" \
    [dict get [dict get $map nodes] 3 route] {}
checkEq "the line is the prefix" [dict get $map lineKind] main
checkEq "and the cursor is still in the empty variation" [fakeWhere] $before

# The node-local marks: D on the move before the node, and the previous
# verdict's marks off the node itself - both placed by route, so a variation
# node is written and its same-ply main-line move is not.
fakeBoard $game
set var [fakeVariation [fakeAtPly 3] {c7c5 g1f3 d7d6}]
fakeCursorAt [lindex $var 2]
set map [::review::currentLineMap]
set before [fakeWhere]
checkEq "a diagram is marked on the move before the node" [::review::setDiagramAt $map 6 1] 1
checkEq "the diagram is on the variation's node" [fakeGet [lindex $var 1] nags] {D}
checkEq "and not on the main-line move of the same ply" [fakeGet [fakeAtPly 5] nags] {}
checkEq "with the cursor left where it was" [fakeWhere] $before
checkEq "index 1 has no move before it" [::review::setDiagramAt $map 1 1] 0
checkEq "and the diagram can be taken off again" [::review::setDiagramAt $map 6 0] 1
checkEq "leaving nothing" [fakeGet [lindex $var 1] nags] {}

# clearMarksAt takes off what a previous verdict wrote on that node and nothing
# else: the NAG its label implies, the assessment, and the diagram before it -
# the same boundary ::reviewdriver::clearMarks keeps on the main line.
fakeSet [lindex $var 1] comment "Keep this \[blunder\] \[%eval -1.20\]"
fakeSet [lindex $var 1] nags {??}
fakeSet [lindex $var 2] nags {D}
fakeSet [lindex $var 0] nags {D}
fakeSet [lindex $var 0] comment "A note of the user's."
set map [::review::currentLineMap]
checkEq "the previous verdict's marks are cleared" [::review::clearMarksAt $map 5] 1
checkEq "the NAG the label implies is gone" [fakeGet [lindex $var 1] nags] {}
checkEq "the diagram on the move before is gone" [fakeGet [lindex $var 0] nags] {}
checkEq "a diagram that marks the move after it is left alone" \
    [fakeGet [lindex $var 2] nags] {D}
checkEq "and the user's own note is not a verdict to clear" \
    [::review::clearMarksAt $map 4] 0
checkEq "the user's note is still there" [fakeGet [lindex $var 0] comment] "A note of the user's."

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
# The coach switch is a flag like the other two, and one a user may turn on.
checkEq "the coach can be turned on" [::review::setValue coach 1] ""
checkEq "and is remembered" [::review::get coach] 1
checkEq "the coach switch refuses anything but 0 or 1" \
    [::review::setValue coach 2] "coach is 0 or 1"
checkEq "and keeps the value it had" [::review::get coach] 1
checkEq "the coach can be turned off again" [::review::setValue coach 0] ""
set ::reviewopt(coach) 3
set ::review::S [dict create]
checkEq "a coach flag saved above 1 is on, not invalid" [::review::get coach] 1
set ::review::S [dict create]
array unset ::reviewopt
::review::reset

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
