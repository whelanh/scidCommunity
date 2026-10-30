# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# game_review.tcl -- the review pass's settings and decisions.
#
# The engine work lives with the engine layer; this file owns the choices that
# decide what the pass does and what it writes back, so they can be tested
# without an engine and without Tk:
#
#   * how deep and how many lines the pass searches (mpv, depth);
#   * where the pass starts, given the opening book (bookEnd - 1, so the move
#     that leaves the book has the reference position it needs);
#   * which of the engine's lines become variations in the game, and how far
#     behind the best line a variation may be before it is noise (var_lines,
#     var_cp);
#   * the snapshot of the main line the pass searches from, and the positions it
#     asks about (the board itself never moves while the engine runs);
#   * where the board was, so that a write can leave it there exactly, variation
#     path included.
#
# Nothing here searches: the caller supplies the results and does the sc_* work.
# Nothing here writes either, beyond one move's comment and variations.

namespace eval ::review {
    variable DEFAULTS {
        mpv 3
        depth 18
        var_lines 0
        var_cp 0
        move_comment_wait 1
        threads 0
        hash_mb 128
        skip_book 1
    }
    variable S [dict create]
    variable MAX_MPV 5
    variable MIN_DEPTH 6
    variable MAX_DEPTH 60
    # The pass is a second engine process, so every resource it is given is
    # allocated again beside the window's own engine. A preset sized for a long
    # interactive search - Threads 64 and Hash 110000 MB on a 128 GB machine -
    # then puts two of those in memory, and the machine swaps itself to death
    # before the review is half done. A batch of short, fixed-depth searches
    # cannot use a TT that size anyway, so the pass has a ceiling. It is a
    # ceiling, not a setting: a preset that asks for less keeps what it asks for.
    variable MAX_PASS_THREADS 8
    variable MAX_PASS_HASH 512
}

proc ::review::defaults {} {
    variable DEFAULTS
    return $DEFAULTS
}

# Settings start at the defaults and are then whatever the caller saved.
proc ::review::reset {} {
    variable S
    variable DEFAULTS
    set S $DEFAULTS
    return $S
}

# The settings in force at the start of a session: the defaults, with whatever
# the user saved over the top. Each setting is an ordinary option variable
# (::reviewopt(key), registered at the end of this file), so Review Settings
# behaves like every other preference - an edit is written to the options file
# with the rest of them and read back at the next start.
#
# A hand-edited options file must not decide how deep a pass searches, so the
# loaded values are clamped here as well as in setValue.
proc ::review::saved {} {
    variable DEFAULTS
    variable MAX_MPV
    variable MIN_DEPTH
    variable MAX_DEPTH
    set S $DEFAULTS
    foreach key [dict keys $DEFAULTS] {
        if {[info exists ::reviewopt($key)] &&
            [string is integer -strict $::reviewopt($key)]} {
            dict set S $key $::reviewopt($key)
        }
    }
    if {[dict get $S mpv] < 1} { dict set S mpv 1 }
    if {[dict get $S mpv] > $MAX_MPV} { dict set S mpv $MAX_MPV }
    if {[dict get $S depth] < $MIN_DEPTH} { dict set S depth $MIN_DEPTH }
    if {[dict get $S depth] > $MAX_DEPTH} { dict set S depth $MAX_DEPTH }
    if {[dict get $S var_lines] < 0} { dict set S var_lines 0 }
    if {[dict get $S mpv] < 2} {
        dict set S var_lines 0
    } elseif {[dict get $S var_lines] > [dict get $S mpv]} {
        dict set S var_lines [dict get $S mpv]
    }
    if {[dict get $S var_cp] < 0} { dict set S var_cp 0 }
    # The flags are on or off, and setValue takes only 0 or 1: a file that says 2
    # must not open the dialog on a value pressing OK would refuse.
    foreach flag {move_comment_wait skip_book} {
        if {[dict get $S $flag] != 0} { dict set S $flag 1 }
    }
    return $S
}

# Write the working copy where the options file reads it. Called by setValue, so
# a value the setter refused is never saved.
proc ::review::save {} {
    variable S
    if {![dict size $S]} { return }
    foreach {key value} $S { set ::reviewopt($key) $value }
}

proc ::review::all {} {
    variable S
    if {![dict size $S]} { set S [::review::saved] }
    return $S
}

proc ::review::get {key} {
    variable S
    if {![dict size $S]} { set S [::review::saved] }
    if {![dict exists $S $key]} { error "unknown review setting: $key" }
    return [dict get $S $key]
}

# Set one setting, refusing values the pass cannot honour. Returns "" on
# success or the reason it was refused; the old value is kept either way.
proc ::review::setValue {key value} {
    variable S
    variable MAX_MPV
    variable MIN_DEPTH
    variable MAX_DEPTH
    if {![dict size $S]} { reset }
    if {![dict exists $S $key]} { return "unknown setting: $key" }
    if {![string is integer -strict $value]} { return "$key must be a whole number" }
    set previous [dict get $S $key]
    set value [expr {$value}]
    switch -- $key {
        mpv {
            if {$value < 1 || $value > $MAX_MPV} { return "mpv must be 1..$MAX_MPV" }
        }
        depth {
            if {$value < $MIN_DEPTH || $value > $MAX_DEPTH} {
                return "depth must be $MIN_DEPTH..$MAX_DEPTH"
            }
        }
        var_lines {
            if {$value < 0} { return "var_lines cannot be negative" }
            if {$value > 0 && [dict get $S mpv] < 2} {
                return "var_lines needs mpv of at least 2"
            }
        }
        var_cp {
            if {$value < 0} { return "var_cp cannot be negative" }
        }
        move_comment_wait {
            if {$value < 0 || $value > 1} { return "move_comment_wait is 0 or 1" }
        }
        threads {
            if {$value < 0} { return "threads cannot be negative" }
        }
        hash_mb {
            if {$value < 16} { return "hash_mb must be at least 16" }
        }
        skip_book {
            if {$value < 0 || $value > 1} { return "skip_book is 0 or 1" }
        }
        default { return "unknown setting: $key" }
    }
    dict set S $key $value
    # var_lines is capped by mpv, and needs mpv of at least 2: lowering mpv to 1
    # turns variations off rather than leaving a state ::review::problems would
    # report against a setting the setter accepted.
    if {[dict get $S mpv] < 2} {
        dict set S var_lines 0
    } elseif {[dict get $S var_lines] > [dict get $S mpv]} {
        if {$key eq "mpv"} {
            dict set S var_lines [dict get $S mpv]
        } else {
            dict set S $key $previous
            return "var_lines cannot exceed mpv ([dict get $S mpv])"
        }
    }
    ::review::save
    return ""
}

# The resources a pass should use, read from the engine's own config: Threads
# and Hash are properties of that preset, and MultiPV is the preset's own value.
# A key the engine does not advertise comes back empty.
proc ::review::engineDefaults {enginecfg} {
    set out [dict create threads "" hash "" mpv ""]
    foreach elem [lindex $enginecfg 8] {
        lassign $elem name value
        switch -nocase -- $name {
            threads { dict set out threads $value }
            hash    { dict set out hash $value }
            multipv { dict set out mpv $value }
        }
    }
    return $out
}

# The settings a pass actually runs with. Threads and Hash are the engine's: the
# preset wins whenever it advertises them, and a second place to set them is a
# second place to get them wrong - the window's controls already write the preset.
# An engine that advertises neither leaves them empty rather than borrowing
# ::review's own values, because a pass can only set what the engine announced: a
# setoption for an option the engine never sent is ignored at best. MultiPV is
# raised to 2 regardless, because a verdict without a second line cannot tell a
# mistake from the only move available.
proc ::review::effective {enginecfg} {
    variable MAX_PASS_THREADS
    variable MAX_PASS_HASH
    set defaults [::review::engineDefaults $enginecfg]
    set threads [dict get $defaults threads]
    set hash [dict get $defaults hash]
    if {$threads ne "" && $threads > $MAX_PASS_THREADS} {
        set threads $MAX_PASS_THREADS
    }
    if {$hash ne "" && $hash > $MAX_PASS_HASH} {
        set hash $MAX_PASS_HASH
    }
    set mpv [get mpv]
    if {[dict get $defaults mpv] ne "" && [dict get $defaults mpv] > $mpv} {
        set mpv [dict get $defaults mpv]
    }
    if {$mpv < 2} {
        set mpv 2
    }
    # The preset's own search limits apply here too, but the review's depth is a
    # floor rather than a default: a preset set up to browse at depth 12 must not
    # shallow out a verdict. A preset that has no Limits element falls back to
    # the review's values, which is what an engines.dat from an older version is.
    set depth [get depth]
    if {[llength $enginecfg] >= 1 && [info exists ::engines(list)] &&
        [info commands ::enginelimits::forName] ne ""} {
        set preset [::enginelimits::forName [lindex $enginecfg 0]]
        if {[dict get $preset depth] ne "" && [dict get $preset depth] > $depth} {
            set depth [dict get $preset depth]
        }
    }
    return [dict create threads $threads hash $hash mpv $mpv depth $depth]
}

# Cross-field problems, for a dialog that wants to show them all at once.
proc ::review::problems {} {
    set s [all]
    set out {}
    if {[dict get $s var_lines] > [dict get $s mpv]} {
        lappend out "var_lines ([dict get $s var_lines]) exceeds mpv ([dict get $s mpv])"
    }
    if {[dict get $s var_lines] > 0 && [dict get $s mpv] < 2} {
        lappend out "var_lines needs mpv of at least 2"
    }
    return $out
}

# Position index the engine pass starts at.
#
# `bookEnd` is the first position that is no longer in the book (0 when the
# game never leaves it, or when book skipping is off). The pass starts one
# position EARLIER: the label for the move that leaves the book is judged from
# the evaluations and the alternative lines of the position before it, so
# starting at bookEnd would leave that move unjudgeable - the exact case an
# early novelty needs.
proc ::review::startPly {bookEnd} {
    set s [all]
    if {![dict get $s skip_book]} { return 0 }
    if {$bookEnd <= 0} { return 0 }
    return [expr {$bookEnd - 1}]
}

# The plies to search: every move from `startPly` to the end of the line.
# `plies` is the number of moves in the main line.
# How many plies of the open game follow `bookFile` from the first move: the
# moves that are in the book. `allBook` decides a game that never leaves the
# book: 1 answers the whole line (every move is a book move), 0 answers 0 (the
# classic annotator's "there is nothing to skip").
#
# The walk uses a book slot of its own so the Book window's and the annotator's
# books are not disturbed, and puts the board back where it found it.
proc ::review::bookEnd {bookFile {slot 5} {allBook 0}} {
    set end 0
    set plies 0
    catch { set plies [dict get [mainLineMap [sc_game UCI_mainLine]] plies] }
    set cursor [cursorSave]
    # The opening starts at the first move, not wherever the cursor is.
    catch { sc_move ply 0 }
    if {[catch {
        sc_book load $bookFile $slot
        set end 0
        # Step only while the move the game played is one the book offers from
        # this position. Merely asking whether the book has any move here would
        # step past a deviation: a game that plays 1.a3 against a book offering
        # 1.e4 would count the a3 itself as a book move and never judge it.
        while {![sc_pos isAt vend]} {
            lassign [sc_book moves $slot] bookmoves
            if {![string length $bookmoves]} { break }
            ::move::Forward
            set played [sc_game info previousMoveNT]
            if {[lsearch -nocase -exact $bookmoves $played] < 0} {
                # The game left the book here: the move is not a book ply.
                catch { sc_move back 1 }
                break
            }
            incr end
        }
        sc_book close $slot
        if {$end >= $plies && !$allBook} {
            # The game never leaves the book: the annotator has nothing to skip.
            set end 0
        }
    }]} {
        catch { sc_book close $slot }
        set end 0
    }
    catch { cursorRestore $cursor }
    return $end
}

proc ::review::plan {plies bookEnd} {
    set out {}
    set start [startPly $bookEnd]
    for {set i [expr {$start + 1}]} {$i <= $plies} {incr i} { lappend out $i }
    return $out
}

# The positions (not moves) the engine pass searches: the reference position
# for each planned move - the position before it - plus the position after the
# last move, so that move can still be judged when its played move is not among
# the engine's lines. Ascending, so the pass walks the game forwards in the
# order a human reads it; `{}` when there is nothing to search, and never a
# negative position.
proc ::review::searchPlies {plies bookEnd} {
    set moves [plan $plies $bookEnd]
    if {![llength $moves]} { return {} }
    set out {}
    foreach m $moves { lappend out [expr {$m - 1}] }
    lappend out $plies
    return [lsort -unique -integer $out]
}

# The main line as `sc_game UCI_mainLine` returns it, indexed the way the rest
# of the pass needs it.
#
# Element 0 is the setup every position string starts from; every later element
# is one ply. A null move is not a token: it is emitted as a fresh
# "position fen ... moves" header IN PLACE OF that ply's move, so the indexes do
# not shift - the element at a null-move ply is simply not a move. Hence:
#
#   plies      the number of moves (null moves included)
#   moves      ply -> the UCI move played there, "" for a null move
#   positions  ply -> the "position ... moves" string of the position AFTER
#              that ply, restarted at every mid-list header
#
# `positions` is what spares the pass the board's own navigation while the
# engine runs: the strings are read once, before anything is written.
proc ::review::mainLineMap {ml} {
    set moves [dict create]
    set positions [dict create]
    if {[llength $ml] < 1} {
        return [list plies 0 moves $moves positions $positions]
    }
    set plies 0
    set acc [lindex $ml 0]
    dict set positions 0 $acc
    for {set ply 1} {$ply < [llength $ml]} {incr ply} {
        set token [lindex $ml $ply]
        if {[string match "position *" $token]} {
            # A null move: the header stands in for the move, and becomes the
            # base every position after it is built from.
            set acc $token
            dict set moves $ply ""
        } else {
            set acc "$acc $token"
            dict set moves $ply $token
        }
        dict set positions $ply $acc
        set plies $ply
    }
    return [list plies $plies moves $moves positions $positions]
}

# The move the game played at `ply`: the UCI token, or "" when there is none -
# a null move, a ply past the end of the line, or a ply the map does not have.
# It never returns a `position ...` header: that is a setup string, not a move,
# and a caller that treated it as one would look for a variation that cannot
# exist.
proc ::review::playedMove {map ply} {
    if {![string is integer -strict $ply]} { return "" }
    if {[catch { set moves [dict get $map moves] }]} { return "" }
    if {![dict exists $moves $ply]} { return "" }
    set token [dict get $moves $ply]
    if {$token eq "" || [string match "position *" $token]} { return "" }
    return $token
}

# Where the board is, in a form that can be put back exactly.
#
# `sc_move ply N` walks the MAIN line (`MoveToPly` is `MoveToStart` then N
# `MoveForward`s), so it always lands outside any variation, and `sc_pos
# location` is a ply counter: inside a variation it keeps counting but cannot
# say which line the board is in. What identifies a position is the ply counter
# plus the variation numbers walked to reach it, each with the number of moves
# played inside that variation.
#
#   {loc <absolute ply> base <main-line ply> path {{<var> <moves inside>} ...}}
#
# The path is outermost first, which is the order a restore has to enter.
proc ::review::cursorSave {} {
    set loc 0
    set base 0
    set path {}
    set fen ""
    if {[catch {
        # The position identity has to be read before walking out: the walk
        # leaves the cursor on the base ply, which is a different position.
        set fen [sc_pos fen]
        set loc [sc_pos location]
        set inner $loc
        # Exit one level at a time. `sc_var exit` returns to the position the
        # variation branched from, so the ply counter difference across the two
        # is how many moves were played inside that variation.
        while {[sc_var level] > 0} {
            set number [sc_var number]
            sc_var exit
            set outer [sc_pos location]
            lappend path [list $number [expr {$inner - $outer}]]
            set inner $outer
        }
        set base $inner
    }]} {
        # A cursor that cannot be read cannot be described; the ply counter
        # alone is still an honest answer, and it is on the main line.
        set base $loc
        set path {}
    }
    # The FEN identifies the position itself: a sibling renumbered by an
    # insertion can reach the same ply at the same level on a different line,
    # and the counter/level checks alone would call that an exact restore.
    return [list loc $loc base $base path [lreverse $path] fen $fen]
}

# Put the board back where `cursorSave` found it. Returns 1 when it landed
# exactly, or 0 when it could not and left the board on the main line at the
# saved base ply.
#
# `sc_var enter n` moves into the variation AND plays its first move, so the
# moves still to walk are `moves inside - 1`; 0 means the board was at the
# variation's own start, before its first move.
#
# A restore never raises and never lands inside the wrong variation. The
# realistic failure is a sibling renumbered by an insertion at the same branch
# point (`::review::writeMove` does exactly that), so the path it entered is
# checked against the recorded ply counter and level, and a mismatch retreats to
# the base ply rather than guessing.
# 1 when the exact path is restored; 0 when the line is gone and the board is
# left on the main-line base ply, which is still a known position; -1 when even
# that could not be done and the caller has to choose a safe position.
proc ::review::cursorRestore {state} {
    set exact 0
    if {[catch {
        set base [dict get $state base]
        sc_move ply $base
        foreach step [dict get $state path] {
            lassign $step number moves
            sc_var enter $number
            if {$moves == 0} {
                sc_move back
            } else {
                sc_move forward [expr {$moves - 1}]
            }
        }
        set wantFen ""
        if {[dict exists $state fen]} { set wantFen [dict get $state fen] }
        set gotFen ""
        catch { set gotFen [sc_pos fen] }
        if {[sc_pos location] == [dict get $state loc]
                && [sc_var level] == [llength [dict get $state path]]
                && ($wantFen eq "" || $gotFen eq $wantFen)} {
            set exact 1
        } elseif {[catch { sc_move ply $base }]} {
            set exact -1
        }
    }]} {
        set exact -1
        if {![catch { sc_move ply [dict get $state base] }]} { set exact 0 }
    }
    return $exact
}

# When the Move Comment button may write.
#
# The current analysis may be shallower than a review, and a comment written
# from a depth-12 result is not the comment the user asked for. With
# move_comment_wait set (the default), the button waits until the running
# analysis reaches the review depth; without it, it writes whatever the engine
# has now. Returns "now", or the depth it is waiting for.
proc ::review::moveCommentPlan {depth_now {depth ""}} {
    set s [all]
    set target $depth
    if {$target eq ""} { set target [dict get $s depth] }
    if {![dict get $s move_comment_wait]} { return now }
    if {$depth_now ne "" && [string is integer -strict $depth_now] && $depth_now >= $target} {
        return now
    }
    return $target
}

# The comment a move carries: our label, then the evaluation as [%eval] so the
# graph and other tools read it back.
proc ::review::commentText {label eval_cp} {
    set txt "\[[::movelabels::text $label]\]"
    if {$eval_cp ne ""} { append txt " " "\[%eval [::seed::label $eval_cp]\]" }
    return $txt
}

# Drop what a previous review wrote: our label, in the language it was written
# in, and the [%eval] beside it. A re-review has to replace them rather than
# stack a second verdict, and ::seed::score reads the first [%eval] it finds, so
# leaving the old one makes the graph show the score that was just replaced.
# Other tokens ([%clk], [%emt]) and the user's prose are kept.
# The words the label ladder can have written, in the current language and in
# English (always loaded as the fallback). Only these brackets are ours: a
# positional rule ("anything in front of an evaluation") also deletes a user's
# [Source] tag, and a verdict written under a language this session never
# loaded is left alone rather than guessed at.
proc ::review::labelWords {} {
    set words {}
    foreach label {best excellent good inaccuracy mistake blunder brilliant great miss forced book} {
        lappend words [::movelabels::text $label]
        set key "MoveLabel[string totitle $label]"
        if {[info exists ::translations(E,$key)]} {
            lappend words $::translations(E,$key)
        }
    }
    return [lsort -unique $words]
}

proc ::review::stripReviewTokens {comment} {
    set out [regsub -all {\[%eval\s+[^\]]*\]} $comment ""]
    foreach word [labelWords] {
        set out [string map [list "\[$word\]" ""] $out]
    }
    # Collapse the gap the tokens left, but not the line breaks of a comment
    # the user wrote themselves.
    return [string trim [regsub -all {[ \t]{2,}} $out " "]]
}

# Add `new` to a comment unless it is already there, so a second run does not
# stack labels.
proc ::review::mergeComment {existing new} {
    set existing [string trim $existing]
    if {$new eq ""} { return $existing }
    if {[string first $new $existing] >= 0} { return $existing }
    return [string trim "$existing $new"]
}

# Write one move's comment and its variations into the game. `ply` is the move
# number in the main line (1-based), `lines` are the engine's lines for the
# position before it, best first, in centipawns from the mover's view. The line
# the played move owns is not inserted as a variation of itself; the others are.
#
# Nothing else in the game is touched: the move's own comment is merged, the
# variations branch from the position before it, and the game is left where it
# was found. Returns "" or the reason nothing was written.
proc ::review::writeMove {ply label eval_cp lines} {
    # No `return` inside the catch body: Tcl turns it into TCL_RETURN, the catch
    # reports a failure and the handler would undo a write that succeeded.
    set out ""
    # The restore result: 1 exact, 0 left on the base ply (known), -1 unknown.
    # The refusal path and the write path both restore the cursor; only -1 needs
    # the start of the line as a position that is always valid.
    set restore 1
    if {[catch {
        set cursor [cursorSave]
        sc_move ply $ply
        if {[sc_pos location] != $ply} {
            set out "ply $ply is not in this game"
            set restore [cursorRestore $cursor]
        } else {
            # Which line is the game's own move, so it is not inserted as a
            # variation of itself. "" when the move cannot be read - a null move
            # has no token in the map at all: selectLines then keeps the best
            # line rather than dropping it on a guess.
            set played ""
            catch {
                set played [playedMove [mainLineMap [sc_game UCI_mainLine]] $ply]
            }
            set want [commentText $label $eval_cp]
            sc_pos setComment [mergeComment \
                [stripReviewTokens [sc_pos getComment]] $want]
            # The variations already at the position BEFORE the move, by their
            # first move: a second review must not duplicate one, and var_lines
            # > 1 must still add each distinct line. sc_var list reads the first
            # move of every variation and leaves the cursor where it found it.
            sc_move ply $ply
            sc_move back
            set existing {}
            catch { set existing [sc_var list UCI] }
            foreach pv [selectLines $lines $played] {
                set first [lindex $pv 0]
                if {$first eq "" || [lsearch -exact $existing $first] >= 0} { continue }
                sc_move ply $ply
                sc_move back
                # A variation the game refuses part-way is not a variation: the
                # engine's line is inserted whole or dropped whole, and a
                # half-written one is deleted rather than left behind. The
                # refusal is reported, so the caller does not count a partial
                # line as written.
                set bad ""
                if {[catch {
                    sc_var create
                    foreach uci $pv {
                        if {[::uci::sc_move_add $uci]} {
                            set bad "the variation move $uci was rejected"
                            break
                        }
                    }
                    if {$bad eq ""} {
                        sc_var exit
                    } else {
                        catch { sc_var delete }
                    }
                } err]} {
                    catch { sc_var delete }
                    catch { sc_var exit }
                    if {$bad eq ""} {
                        set bad "the variation could not be inserted: $err"
                    }
                }
                if {$bad ne ""} {
                    lappend out $bad
                } else {
                    lappend existing $first
                }
            }
            set restore [cursorRestore $cursor]
        }
    } err]} {
        set out $err
        set restore -1
    }
    # A restore that fell back to the base ply did not fail the write, and that
    # base is a known position: leave it. Only when the cursor could not be
    # placed at all does the start of the line become the safe choice.
    if {$restore < 0} { catch { sc_move ply 0 } }
    return $out
}

# Which of the engine's lines become variations.
#
# `lines` is a list of {cp pv}, best first, in centipawns from the mover's point
# of view - the same figure the label ladder uses. `played` is the move the game
# actually played, in UCI, and the one line it owns is never a variation: the
# engine's best line is the played move's own line when that move was best, and
# on a blunder it is the strongest alternative and belongs in the game. A
# `played` of "" means the caller cannot say which move was played, and then
# nothing is dropped - the best line is kept rather than discarded on a guess.
#
# var_cp is a noise filter: a line that is further behind the best line than
# var_cp centipawns is not worth inserting. The comparison is strict, so a
# threshold of 50 excludes a line exactly 50cp worse - "3.0 or more" in the
# worked example. var_cp 0 means no filter at all.
proc ::review::selectLines {lines {played ""}} {
    set s [all]
    set want [dict get $s var_lines]
    set limit [dict get $s var_cp]
    if {$want < 1 || ![llength $lines]} { return {} }
    # Drop the played move's own line wherever it ranks: the best line is an
    # alternative worth inserting whenever the game played something else, and
    # when the game move is a lower MultiPV root its line is not an alternative
    # to itself either.
    set candidates {}
    foreach line $lines {
        if {$played ne "" && [string equal [lindex [lindex $line] 1 0] $played]} {
            continue
        }
        lappend candidates $line
    }
    set best [lindex [lindex $lines 0] 0]
    set out {}
    foreach line $candidates {
        if {[llength $out] >= $want} { break }
        lassign $line cp pv
        if {![llength $pv]} { continue }
        # An alternative that is ahead of the "best" line means the caller
        # mis-ordered the lines; it is not a reason to insert a variation.
        if {$cp > $best} { continue }
        if {$limit > 0 && ($best - $cp) >= $limit} { continue }
        lappend out $pv
    }
    return $out
}


# Every setting is a saved option. options.store keeps a value the options file
# already carried and writes the default for one that is new; the array element
# is the variable options.write saves, like ::showEvalBar($w) in main.tcl.
if {[llength [info commands options.store]]} {
    foreach key [dict keys [::review::defaults]] {
        options.store ::reviewopt($key) [dict get [::review::defaults] $key]
    }
}
