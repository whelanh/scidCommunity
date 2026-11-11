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
# Nothing here writes either, beyond one move's comment, its variations and the
# marks that go beside them.

namespace eval ::review {
    variable DEFAULTS {
        mpv 3
        depth 18
        movetime 0
        var_lines 1
        var_cp 0
        move_comment_wait 1
        diagram 1
        opening_errors 0
        opening_window 12
        tactical_exercises 0
        coach 0
        threads 0
        hash_mb 128
        skip_book 1
        verifier ""
    }
    variable S [dict create]
    variable MAX_MPV 5
    variable MIN_DEPTH 6
    variable MAX_DEPTH 60
    # The old annotate dialog offered 10-20 moves for the opening-errors finder,
    # and 12 by default. A hand-edited options file is held to the same range.
    variable MIN_OPENING_WINDOW 10
    variable MAX_OPENING_WINDOW 20
    # A pass's time ceiling is milliseconds per position, and 0 is the review
    # saying "no ceiling of my own" - ::review::passLimits then takes the
    # preset's. The upper bound is ::enginelimits' own ceiling for a preset's
    # movetime, so a value the engine-layer spinbox could store is a value this
    # one can, and neither layer can hand the pass a number the other refuses.
    variable MIN_MOVETIME 0
    variable MAX_MOVETIME 3600000
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
    variable MIN_MOVETIME
    variable MAX_MOVETIME
    variable MIN_OPENING_WINDOW
    variable MAX_OPENING_WINDOW
    set S $DEFAULTS
    foreach key [dict keys $DEFAULTS] {
        if {[info exists ::reviewopt($key)] &&
            [string is integer -strict $::reviewopt($key)]} {
            dict set S $key $::reviewopt($key)
        }
    }
    # The verifier is a preset NAME, not a number, so it is read as a string:
    # "" is Off, the default, and anything else names the second engine. A name
    # whose preset has since gone is Off at the point of use
    # (::review::verifier), not an error at load - the session must still start
    # with an engines.dat that no longer carries it.
    set name ""
    if {[info exists ::reviewopt(verifier)]} { set name [string trim $::reviewopt(verifier)] }
    dict set S verifier $name
    if {[dict get $S mpv] < 1} { dict set S mpv 1 }
    if {[dict get $S mpv] > $MAX_MPV} { dict set S mpv $MAX_MPV }
    if {[dict get $S depth] < $MIN_DEPTH} { dict set S depth $MIN_DEPTH }
    if {[dict get $S depth] > $MAX_DEPTH} { dict set S depth $MAX_DEPTH }
    if {[dict get $S movetime] < $MIN_MOVETIME} { dict set S movetime $MIN_MOVETIME }
    if {[dict get $S movetime] > $MAX_MOVETIME} { dict set S movetime $MAX_MOVETIME }
    if {[dict get $S var_lines] < 0} { dict set S var_lines 0 }
    if {[dict get $S mpv] < 2} {
        dict set S var_lines 0
    } elseif {[dict get $S var_lines] > [dict get $S mpv]} {
        dict set S var_lines [dict get $S mpv]
    }
    if {[dict get $S var_cp] < 0} { dict set S var_cp 0 }
    if {[dict get $S opening_window] < $MIN_OPENING_WINDOW} {
        dict set S opening_window $MIN_OPENING_WINDOW
    }
    if {[dict get $S opening_window] > $MAX_OPENING_WINDOW} {
        dict set S opening_window $MAX_OPENING_WINDOW
    }
    # The flags are on or off, and setValue takes only 0 or 1: a file that says 2
    # must not open the dialog on a value pressing OK would refuse.
    foreach flag {move_comment_wait skip_book diagram opening_errors tactical_exercises coach} {
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

# The engine preset a review's second opinion runs on, or "" for Off.
#
# The setting is a preset name, so it is checked against the presets this session
# actually has: a name whose preset was deleted, or an engines.dat that has not
# been read yet, is Off - a review still runs, it just has no second opinion.
# Nothing here throws: a verifier is never an error path.
proc ::review::verifier {} {
    variable S
    if {![dict size $S]} { catch { set S [::review::saved] } }
    set name ""
    catch { set name [dict get $S verifier] }
    if {$name eq ""} { return "" }
    set names {}
    catch { set names [::enginecfg::names] }
    if {[lsearch -exact $names $name] < 0} { return "" }
    return $name
}

# Set one setting, refusing values the pass cannot honour. Returns "" on
# success or the reason it was refused; the old value is kept either way.
proc ::review::setValue {key value} {
    variable S
    variable MAX_MPV
    variable MIN_DEPTH
    variable MAX_DEPTH
    variable MIN_MOVETIME
    variable MAX_MOVETIME
    variable MIN_OPENING_WINDOW
    variable MAX_OPENING_WINDOW
    if {![dict size $S]} { reset }
    if {![dict exists $S $key]} { return "unknown setting: $key" }
    # The verifier names an engine preset, so it is the one setting that is not a
    # whole number. "" is Off. A name that is not a preset this session has is
    # refused: the pass would open nothing and quietly skip its second opinion,
    # which reads as "the verifier said yes" when it never ran.
    if {$key eq "verifier"} {
        set name [string trim $value]
        if {$name ne ""} {
            set names {}
            catch { set names [::enginecfg::names] }
            if {[llength $names] && [lsearch -exact $names $name] < 0} {
                return "no engine preset called $name"
            }
        }
        dict set S verifier $name
        ::review::save
        return ""
    }
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
        movetime {
            if {$value < $MIN_MOVETIME || $value > $MAX_MOVETIME} {
                return "movetime must be $MIN_MOVETIME..$MAX_MOVETIME"
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
        diagram {
            if {$value < 0 || $value > 1} { return "diagram is 0 or 1" }
        }
        opening_errors {
            if {$value < 0 || $value > 1} { return "opening_errors is 0 or 1" }
        }
        opening_window {
            if {$value < $MIN_OPENING_WINDOW || $value > $MAX_OPENING_WINDOW} {
                return "opening_window must be $MIN_OPENING_WINDOW..$MAX_OPENING_WINDOW"
            }
        }
        tactical_exercises {
            if {$value < 0 || $value > 1} { return "tactical_exercises is 0 or 1" }
        }
        coach {
            if {$value < 0 || $value > 1} { return "coach is 0 or 1" }
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

# The limits one position of a pass is searched under, from the review's own
# settings and from the engine preset's Limits.
#
# Depth and time point in opposite directions on purpose. The preset may only
# DEEPEN a pass: a preset set up to browse at depth 12 must not shallow out a
# verdict, so the deeper of the two wins. The time cap is a CEILING with one
# owner: the review's value when it has one, otherwise the preset's, otherwise
# none - never the smaller of the two, which would search shallower than either
# setting asked for.
#
# `review` and `preset` are dicts carrying `depth` and `movetime`; "" is "not
# set", and a review movetime of 0 says the same. Answers {depth N movetime M},
# which is the shape ::enginelimits::goLimits turns into a Go message, so the
# precedence is decided once instead of in each caller.
proc ::review::passLimits {review preset} {
    set depth [dict get $review depth]
    if {[dict exists $preset depth]} {
        set presetDepth [dict get $preset depth]
        if {[string is integer -strict $presetDepth] && $presetDepth > $depth} {
            set depth $presetDepth
        }
    }
    set movetime 0
    if {[dict exists $review movetime]} { set movetime [dict get $review movetime] }
    if {![string is integer -strict $movetime] || $movetime <= 0} {
        set movetime ""
        if {[dict exists $preset movetime]} {
            set presetTime [dict get $preset movetime]
            if {[string is integer -strict $presetTime] && $presetTime > 0} {
                set movetime $presetTime
            }
        }
    }
    return [dict create depth $depth movetime $movetime]
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
    # The preset's own search limits apply here too, and ::review::passLimits is
    # the whole precedence: the depth is a floor, the time cap a ceiling with one
    # owner. A preset that has no Limits element falls back to the review's
    # values, which is what an engines.dat from an older version is.
    set preset [dict create depth {} movetime {}]
    if {[llength $enginecfg] >= 1 && [info exists ::engines(list)] &&
        [info commands ::enginelimits::forName] ne ""} {
        set preset [::enginelimits::forName [lindex $enginecfg 0]]
    }
    set lim [::review::passLimits [all] $preset]
    return [dict create threads $threads hash $hash mpv $mpv \
        depth [dict get $lim depth] movetime [dict get $lim movetime]]
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

# ── the line the cursor stands on ───────────────────────────────────────────
#
# Game Review judges the line the user is looking at. A line is addressed by
# ROUTE - the main-line prefix up to the branch, then the variation number
# entered at each level, outermost first - and keyed by line-local index, the
# shape mainLineMap already has: index 0 is the start position and 1..N are the
# moves. The plan, the searched positions and the verdict layer therefore read
# either map without changing.
#
# `ply` - the absolute sc_pos location - is carried per node for diagnostics and
# for the diagram check. It is never a key: the same ply is on every line that
# passes through it.

# The move that led to the position the board is on, as UCI; "" at the start of
# the game and at a null move. A null move is spelled 0000 in UCI and stands in
# for its own ply with a position header, so it is recorded as no move - the
# same thing mainLineMap does with the header it sees there.
proc ::review::nodeMove {} {
    set move ""
    catch { set move [sc_game info previousMoveUCI] }
    if {$move eq "0000"} { set move "" }
    return $move
}

# And its SAN, for the node's readable name.
proc ::review::nodeSan {} {
    set san ""
    catch { set san [sc_game info previousMove] }
    return $san
}

# Everything the map and the writer need about the position the board is on.
# `move` is passed in when the caller already knows it - the anchor that
# sc_var enter played - so the node and the anchor cannot disagree.
proc ::review::lineNode {index route {move ""}} {
    set ply 0
    catch { set ply [sc_pos location] }
    set fen ""
    catch { set fen [sc_pos fen] }
    set comment ""
    catch { set comment [sc_pos getComment] }
    if {$move eq ""} { set move [nodeMove] }
    return [dict create index $index route $route ply $ply fen $fen \
        uci $move san [nodeSan] comment $comment \
        hasVerdict [expr {[labelOfComment $comment] ne ""}]]
}

# The line the cursor is on, as a route-addressed map.
#
#   cursor   a ::review::cursorSave dict, or one taken now
#
# Returns a dict:
#   plies       N, moves on the line
#   moves       index -> UCI played there ("" for a null move)
#   positions   index -> "position ..." spec of the position AFTER that index
#   nodes       index -> {index route ply fen uci san comment hasVerdict}
#   judged      indices to search and write (see below)
#   context     the indices left alone because they already carry a verdict
#   cursor      the captured cursor
#   cursorRoute variation numbers of the cursor, outermost first
#   cursorIndex base + sum of the route's depths: the move under the cursor
#   anchors     the first move of each route level, outermost first
#   lineKind    "main" | "variation"
#
# A variation line is the main-line prefix 1..base, then each route level's
# moves up to the next branch, then the innermost variation to its leaf. Either
# way the line runs to its end, not to the point the cursor stands on: on the
# main line that makes the map exactly mainLineMap's, inside a variation it makes
# the map the whole of that variation.
#
# The anchors exist because cursorSave records numbers and depths but not
# first moves, and `sc_var enter` both moves into a variation and plays its
# first move: the first move of each level has to be read before entering, or a
# sibling renumbered by an insertion would send the walk into another line.
#
# `judged` is the moves whose comment carries no verdict, so a review completes
# a partly labelled line node by node. A line whose every move is already
# labelled is judged whole rather than silently writing nothing - the main line
# already behaves so - and `context` is then empty.
#
# The board is left exactly where the cursor was; a restore that is not exact
# aborts the map with an error, so a caller that cannot trust the board never
# gets a map to write from.
proc ::review::currentLineMap {{cursor ""}} {
    if {$cursor eq ""} { set cursor [cursorSave] }
    # A map is only worth building from a cursor it can describe: a caller that
    # hands over something else would otherwise get a one-node map that looks
    # like the start of the game.
    set base 0
    set path {}
    if {[catch {
        set base [dict get $cursor base]
        set path [dict get $cursor path]
    }]} {
        error "the cursor is not a cursorSave dict"
    }
    set cursorRoute {}
    foreach step $path { lappend cursorRoute [lindex $step 0] }
    set nodes [dict create]
    set moves [dict create]
    set positions [dict create]
    set anchors {}
    set plies 0
    set why ""
    if {[catch {
        # cursorSave walked out of every variation to the main-line base ply.
        # The walk starts at the root and reads every position off the board
        # itself, so a line map and a game map cannot disagree about where a
        # move leaves the position.
        sc_move ply 0
        dict set positions 0 [sc_game UCI_currentPos]
        dict set nodes 0 [lineNode 0 {} ""]
        for {set i 1} {$i <= $base} {incr i} {
            if {[sc_move forward 1] < 1} {
                error "the main line is shorter than the cursor's base ply"
            }
            set plies $i
            set node [lineNode $i {}]
            dict set nodes $i $node
            dict set moves $i [dict get $node uci]
            dict set positions $i [sc_game UCI_currentPos]
        }
        # One level at a time: read the anchors at the branch point, enter,
        # then walk the moves the cursor had played inside that variation.
        set level 0
        set extend 1
        foreach step $path {
            lassign $step number depth
            # `moves 0` in cursorSave can only be an empty variation: there is no
            # move to record and nothing to descend into, so the line ends at
            # the branch point and the level contributes no node and no anchor.
            if {$depth < 1} {
                set extend 0
                break
            }
            set sibs {}
            catch { set sibs [sc_var list UCI] }
            set anchor [lindex $sibs $number]
            if {$anchor eq ""} {
                error "variation $number is not on this line"
            }
            lappend anchors $anchor
            sc_var enter $number
            incr plies
            set route [lrange $cursorRoute 0 $level]
            set node [lineNode $plies $route $anchor]
            dict set nodes $plies $node
            dict set moves $plies $anchor
            dict set positions $plies [sc_game UCI_currentPos]
            for {set k 1} {$k < $depth} {incr k} {
                if {[sc_move forward 1] < 1} {
                    error "the variation is shorter than the cursor"
                }
                incr plies
                set node [lineNode $plies $route]
                dict set nodes $plies $node
                dict set moves $plies [dict get $node uci]
                dict set positions $plies [sc_game UCI_currentPos]
            }
            incr level
        }
        # To the leaf: the line is reviewed to its end, not to the point the
        # cursor happens to stand on. On the main line that is the whole game, so
        # a main-line map is mainLineMap's; inside a variation it is that
        # variation's leaf. `sc_move forward` answers 0 at the end of the line,
        # which is the loop `sc_move endVar` runs - kept explicit because every
        # position on the way is a node of the map.
        if {$extend} {
            set route $cursorRoute
            while {[sc_move forward 1] > 0} {
                incr plies
                set node [lineNode $plies $route]
                dict set nodes $plies $node
                dict set moves $plies [dict get $node uci]
                dict set positions $plies [sc_game UCI_currentPos]
            }
        }
    } err]} {
        set why $err
    }
    # The board goes back before anything else is decided: a map that moves the
    # cursor is a map the caller cannot trust to have changed nothing.
    if {[cursorRestore $cursor] != 1 && $why eq ""} {
        set why "the cursor could not be put back on its line"
    }
    if {$why ne ""} { error $why }
    set unlabelled {}
    set labelled {}
    for {set i 1} {$i <= $plies} {incr i} {
        if {[dict get $nodes $i hasVerdict]} {
            lappend labelled $i
        } else {
            lappend unlabelled $i
        }
    }
    if {[llength $unlabelled]} {
        set judged $unlabelled
        set context $labelled
    } else {
        set judged $labelled
        set context {}
    }
    set lastRoute {}
    if {$plies > 0} { set lastRoute [dict get $nodes $plies route] }
    set cursorIndex $base
    foreach step $path { incr cursorIndex [lindex $step 1] }
    return [dict create plies $plies moves $moves positions $positions \
        nodes $nodes judged $judged context $context cursor $cursor \
        cursorRoute $cursorRoute cursorIndex $cursorIndex anchors $anchors \
        lineKind [expr {[llength $lastRoute] ? "variation" : "main"}]]
}

# Walk the line once with the cursor, running `body` at each named index.
#
# This is the only proc that moves the board imperatively for a line: one
# cursorSave, one root-to-leaf walk, one cursorRestore. `indices` are line
# indexes (1..plies); `body` is called as `{*}$body <node>` with the cursor on
# that node and receives the node's dict from the map.
#
# The descent uses the primitives cursorRestore uses - `sc_move ply` for the
# prefix, `sc_move forward` inside a line, `sc_var enter` at a branch - plus the
# anchor: the variation number alone cannot say which branch is meant, because
# an insertion renumbers the siblings. The first move is therefore confirmed
# before every enter, and a mismatch aborts to the base ply - a known position -
# rather than entering the wrong branch.
#
# Returns {restored <1|0|-1>}: 1 the walk ran and the cursor is back exactly,
# 0 the line was not what the map described and the board is on the base ply,
# -1 the cursor could not even be read.
proc ::review::visitLine {map indices body} {
    set nodes [dict create]
    catch { set nodes [dict get $map nodes] }
    set plies 0
    catch { set plies [dict get $map plies] }
    set want {}
    foreach i $indices {
        if {[string is integer -strict $i] && $i >= 1 && $i <= $plies} { lappend want $i }
    }
    set want [lsort -unique -integer $want]
    # The prefix's last index: where an abort leaves the board.
    set base 0
    for {set i 1} {$i <= $plies} {incr i} {
        if {![llength [dict get $nodes $i route]]} { set base $i }
    }
    set cursor ""
    if {[catch { set cursor [cursorSave] }]} { return [list restored -1] }
    set stopped 0
    set failed ""
    set failedInfo ""
    if {[catch {
        sc_move ply 0
        set prev {}
        for {set i 1} {$i <= $plies} {incr i} {
            set node [dict get $nodes $i]
            set route [dict get $node route]
            if {[llength $route] > [llength $prev]} {
                set number [lindex $route end]
                set anchor [dict get $node uci]
                set sibs {}
                catch { set sibs [sc_var list UCI] }
                if {$number >= [llength $sibs] || [lindex $sibs $number] ne $anchor} {
                    set stopped 1
                    break
                }
                sc_var enter $number
            } elseif {[sc_move forward 1] < 1} {
                set stopped 1
                break
            }
            if {[sc_pos location] != [dict get $node ply]} { set stopped 1 ; break }
            if {[lsearch -exact $want $i] >= 0} { {*}$body $node }
            set prev $route
        }
    } err]} {
        set failed $err
        set failedInfo $::errorInfo
    }
    if {$failed ne ""} {
        # The body failed part-way: put the cursor back and let the caller see
        # why, with the body's own trace. The walk decides nothing else.
        catch { cursorRestore $cursor }
        error $failed $failedInfo
    }
    if {$stopped} {
        catch { sc_move ply $base }
        return [list restored 0]
    }
    return [list restored [cursorRestore $cursor]]
}

# The diagram tag D on the move BEFORE `index`: the NAGs of a position belong to
# the move that led to it, and the exporter draws the position after that move -
# which is where the mistake was played. Node-local ::review::setDiagram: the
# cursor is placed by route, not by ply, and the main-line original is
# untouched. Returns 1 when the mark was set or cleared, 0 when it was not.
proc ::review::setDiagramAt {map index on} {
    if {![string is integer -strict $index] || $index < 2} { return 0 }
    variable atResult
    set atResult 0
    set r {}
    catch {
        set r [visitLine $map [list [expr {$index - 1}]] [list ::review::diagramNode $on]]
    }
    if {![dict exists $r restored] || [dict get $r restored] != 1} { return 0 }
    return $atResult
}

# The node the diagram mark goes on. The cursor is on it, so the check
# setDiagram makes - is this the position the mark names - is the node's own
# ply.
proc ::review::diagramNode {on node} {
    variable atResult
    set atResult 0
    if {[catch { sc_pos location } loc] || $loc != [dict get $node ply]} { return }
    if {$on} {
        set atResult [addNagIfAbsent D]
    } else {
        set atResult [dropNag D]
    }
    return
}

# Node-local ::reviewdriver::clearMarks: take off what a previous verdict wrote
# on the move at `index` - the NAG its label implies, the assessment, and the
# diagram it put on the move before. The label is read from the map, so the
# caller does not have to walk the line to find out what was there. Returns 1
# when a mark of a previous verdict was actually removed, 0 when there was none
# or the line could not be walked.
proc ::review::clearMarksAt {map index} {
    if {![string is integer -strict $index] || $index < 1} { return 0 }
    set node ""
    catch { set node [dict get [dict get $map nodes] $index] }
    if {$node eq ""} { return 0 }
    set old [labelOfComment [dict get $node comment]]
    if {$old eq ""} { return 0 }
    # D sits on the move before, so one walk covers both nodes.
    set want [list $index]
    set at 0
    if {($old eq "mistake" || $old eq "blunder") && $index >= 2} {
        set at [expr {$index - 1}]
        lappend want $at
    }
    variable atResult
    set atResult 0
    set r {}
    catch { set r [visitLine $map $want [list ::review::marksNode $index $at]] }
    if {![dict exists $r restored] || [dict get $r restored] != 1} { return 0 }
    return $atResult
}

# The body clearMarksAt walks with: the verdict's own marks off the move, and
# the diagram off the move before it. `index` and `at` are the two nodes, passed
# in rather than remembered: the body runs with the cursor on one node at a time
# and the line's own index says which.
proc ::review::marksNode {index at node} {
    variable atResult
    set i [dict get $node index]
    if {$i == $index} {
        set old [labelOfComment [dict get $node comment]]
        if {$old eq ""} { return }
        set nag [nagForLabel $old]
        if {$nag ne "" && [dropNag $nag]} { set atResult 1 }
        if {[dropAssessment]} { set atResult 1 }
    } elseif {$at != 0 && $i == $at} {
        if {[dropNag D]} { set atResult 1 }
    }
    return
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

# The NAG that stands beside a label, if any. A label is the review's word; a
# NAG is the mark a PGN reader and the board's annotation display show, so the
# two have to agree. best/excellent/good are unmarked, as in the classic ladder.
proc ::review::nagForLabel {label} {
    switch -- $label {
        blunder    { return "??" }
        mistake - miss { return "?" }
        inaccuracy { return "?!" }
        brilliant  { return "!!" }
        great      { return "!" }
    }
    return ""
}

# The position-assessment marks: "=" for a level position, "+="/"+/-" for a
# small and a clear White advantage, "+-"/"+--" for a winning one, and the
# mirrored half for Black. They are NAGs 10-21, a different slot from the six
# move marks, so a move can carry both. The Informant thresholds are the ones in
# options.tcl; the fallbacks keep this callable in a tclsh that has not loaded
# them.
variable ::review::ASSESSMENT_KEYS {+= +/- +- +--}
variable ::review::ASSESSMENT_DEFAULTS {0.5 1.5 2.5 4.0}
variable ::review::ASSESSMENT_TABLE {= += +/- +- +-- = =+ -/+ -+ --+}

# The assessment for one score in pawns from White's point of view - the same
# figure [%eval] shows. The comparison is strict, as in the classic annotator:
# 0.5 exactly is already "+=".
proc ::review::scoreToNag {score} {
    variable ASSESSMENT_KEYS
    variable ASSESSMENT_DEFAULTS
    variable ASSESSMENT_TABLE
    if {![string is double -strict $score]} { return "" }
    set tmp [expr {abs($score)}]
    set i 0
    foreach key $ASSESSMENT_KEYS fallback $ASSESSMENT_DEFAULTS {
        set limit $fallback
        if {[info exists ::informant($key)]} { set limit $::informant($key) }
        if {$tmp < $limit} { break }
        incr i
    }
    if {$score < 0.0} { set i [expr {$i + 5}] }
    return [lindex $ASSESSMENT_TABLE $i]
}

# The assessment a verdict carries, from the position's [%eval]: "" when the
# pass had no score to show, so the mark can never disagree with the number in
# the comment.
proc ::review::assessmentNag {eval_cp} {
    if {$eval_cp eq "" || ![string is double -strict $eval_cp]} { return "" }
    return [::review::scoreToNag [expr {$eval_cp / 100.0}]]
}

# The symbols an assessment can be, for taking one off the move.
proc ::review::assessmentNags {} {
    return {= += +/- +- +-- =+ -/+ -+ --+}
}

# Put `nag` on the move as its one assessment, keeping every other NAG. AddNag
# replaces the first position NAG and appends when there is none, so any second
# one is cleared first: a move is not meant to carry two assessments.
proc ::review::setAssessment {nag} {
    if {$nag eq ""} { return 0 }
    set marks [::review::assessmentNags]
    set keep {}
    set replacing 0
    foreach n [::review::nags] {
        if {[lsearch -exact $marks $n] >= 0} {
            set replacing 1
        } else {
            lappend keep $n
        }
    }
    # With nothing in the assessment slot AddNag appends and leaves the other
    # marks alone; only a second assessment has to be cleared first.
    if {!$replacing} {
        sc_pos addNag $nag
        return 1
    }
    sc_pos clearNags
    foreach n $keep { sc_pos addNag $n }
    sc_pos addNag $nag
    return 1
}

# Take every assessment off the move and keep the rest. A review replaces its
# own verdict with this before writing the new score's assessment.
proc ::review::dropAssessment {} {
    set marks [::review::assessmentNags]
    set keep {}
    set dropped 0
    foreach n [::review::nags] {
        if {[lsearch -exact $marks $n] >= 0} {
            set dropped 1
        } else {
            lappend keep $n
        }
    }
    if {!$dropped} { return 0 }
    sc_pos clearNags
    foreach n $keep { sc_pos addNag $n }
    return 1
}

# The label a comment already carries, in the current language or in English, or
# "" when it carries none. Used to replace the previous review's mark rather
# than stack a second one.
proc ::review::labelOfComment {comment} {
    # Our token is at the end of the comment - [Label] or [Label] [%eval ...] -
    # because writeMove appends it to whatever was there. A label word in the
    # middle of the user's prose must not be mistaken for a previous verdict.
    # The verdict lives inside the review's colour span, so the tail is compared
    # with the span tags removed.
    set tail [regsub -all {</?span[^>]*>} [string trim $comment] ""]
    regsub {\s*\[%eval [^\]]*\]\s*$} $tail {} tail
    foreach label {best excellent good inaccuracy mistake blunder brilliant great miss forced book} {
        foreach word [list [::movelabels::text $label] [string totitle $label]] {
            set token "\[$word\]"
            set n [string length $token]
            if {$word ne "" && [string length $tail] >= $n &&
                [string equal [string range $tail end-[expr {$n - 1}] end] $token]} {
                return $label
            }
        }
    }
    return ""
}

# The move's NAGs as a list; "0" is what sc_pos reports for none.
proc ::review::nags {} {
    set nags [sc_pos getNags]
    if {$nags eq "0"} { return {} }
    return $nags
}

# True when the move already carries one of the six move marks. Scid's AddNag
# REPLACES the first move mark rather than appending, so the review must not
# write its own over one the user put there; only the mark the previous review
# wrote (which clearMarks takes off) is replaced. A user mark that is the same
# symbol the label implies cannot be told from ours: it is kept on the first run
# and replaced by a later one.
proc ::review::hasMoveNag {} {
    foreach n {! ? !! ?? !? ?!} {
        if {[lsearch -exact [::review::nags] $n] >= 0} { return 1 }
    }
    return 0
}

proc ::review::addNagIfAbsent {nag} {
    if {$nag eq ""} { return 0 }
    if {[lsearch -exact [::review::nags] $nag] >= 0} { return 0 }
    sc_pos addNag $nag
    return 1
}

# Remove one NAG and keep the rest. There is no remove-Nag command; clear and
# re-add the ones that stay. A NAG the user put on the move is kept unless it is
# the same symbol the review wrote.
proc ::review::dropNag {nag} {
    set nags [::review::nags]
    if {[lsearch -exact $nags $nag] < 0} { return 0 }
    set keep [lsearch -all -inline -not -exact $nags $nag]
    sc_pos clearNags
    foreach n $keep { sc_pos addNag $n }
    return 1
}

# The diagram tag D sits on the move BEFORE `ply`: the NAGs of a position belong
# to the move that led to it, and the exporter draws the position after that
# move - which is where the mistake was played. A D on the move before a move the
# last review labelled mistake/blunder is treated as the review's and replaced;
# one anywhere else is left alone.
proc ::review::setDiagram {ply on} {
    if {![string is integer -strict $ply] || $ply < 2} { return 0 }
    if {[catch { sc_move ply [expr {$ply - 1}] }]} { return 0 }
    if {[catch { sc_pos location } loc] || $loc != [expr {$ply - 1}]} { return 0 }
    if {$on} {
        return [::review::addNagIfAbsent D]
    }
    return [::review::dropNag D]
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
    # The verdict is written in one span. Removing its tokens can leave the
    # wrapper behind; a second review must not stack empty spans.
    set out [::commentcolors::stripEmpty $out]
    # Collapse the gap the tokens left, but not the line breaks of a comment
    # the user wrote themselves.
    return [string trim [regsub -all {[ \t]{2,}} $out " "]]
}

# Mark the variation the cursor is on as the engine's. The comment is plain
# text, not a review span: it says where the line came from, and a variation the
# reader adds later has no such comment.
proc ::review::markVariation {engine} {
    if {$engine eq ""} { return }
    set old [sc_pos getComment]
    if {[string first $engine $old] >= 0} { return }
    sc_pos setComment [string trim "$old $engine"]
}

# What a whole-game review records: the engine, and the provider/model when the
# coach was asked to write prose and a provider is configured. The tag says what
# was used, not what answered.
proc ::review::annotatorRecord {engine {coach 0}} {
    set tag $engine
    if {$coach && [llength [info commands ::auto_comment::activeModelLabel]]} {
        set model ""
        catch { set model [::auto_comment::activeModelLabel] }
        if {$model ne ""} { append tag "; $model" }
    }
    return $tag
}

# Append to the game's Annotator tag, keeping whatever is there. Unlike the
# classic annotator's helper this does not append the same text twice: a second
# Game Review of the same game with the same engine must not grow the tag.
proc ::review::appendAnnotator {text} {
    if {$text eq ""} { return 0 }
    # PGN writes an extra tag as Name "value"; a quote inside the value would
    # close the header string and leave the tag unreadable. A name is not
    # prose, so a straight apostrophe is a safe replacement.
    set text [string map {"\"" "'"} $text]
    if {[catch { set extra [sc_game tags get "Extra"] }]} { return 0 }
    # The engine is the part before the model separator. Replacing an entry
    # with the same engine rather than appending keeps a review that toggles
    # coach prose from writing the engine twice.
    set engine [string trim [lindex [split $text ";"] 0]]
    set nExtra {}
    set seen 0
    set other ""
    foreach line $extra {
        if {$seen == 1} {
            set entries {}
            set replaced 0
            foreach entry [split $line ","] {
                set entry [string trim $entry]
                if {$entry eq ""} { continue }
                set entryEngine [string trim [lindex [split $entry ";"] 0]]
                if {$entryEngine eq $engine} {
                    lappend entries $text
                    set replaced 1
                } else {
                    lappend entries $entry
                }
            }
            if {!$replaced} { lappend entries $text }
            # A two-element Tcl list survives a quote or a brace in either
            # value; building the quoted line by hand did not, and the tag
            # setter silently drops an entry that is not a pair.
            lappend nExtra [list Annotator [join $entries ", "]]
            set seen 2
        } elseif {$other ne ""} {
            lappend nExtra [list $other $line]
            set other ""
        } elseif {[string match "Annotator" $line]} {
            set seen 1
        } else {
            set other $line
        }
    }
    if {$seen == 0} {
        lappend nExtra [list Annotator $text]
    }
    if {[catch { sc_game tags set -extra $nExtra }]} { return 0 }
    return 1
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
proc ::review::writeMove {ply label eval_cp lines {engine ""}} {
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
            set want [::commentcolors::wrapReview [commentText $label $eval_cp]]
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
                set firstMove 1
                if {[catch {
                    sc_var create
                    foreach uci $pv {
                        if {[::uci::sc_move_add $uci]} {
                            set bad "the variation move $uci was rejected"
                            break
                        }
                        # The engine's name belongs to the variation it opened,
                        # not to the played move: a later variation of the
                        # reader's own carries no such comment.
                        if {$firstMove && $engine ne ""} {
                            ::review::markVariation $engine
                            set firstMove 0
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

# ── the node writer ─────────────────────────────────────────────────────────
#
# ::review::writeMove writes the move at a main-line ply: it finds that ply with
# `sc_move ply`, which walks the game's own line and leaves every variation. A
# line map is a different address space - its indexes are line-local, and the
# same index is a different move on every line through the position. writeNode is
# writeMove addressed by index, standing on the node with ::review::visitLine,
# and it writes the same three things: the comment, the alternatives branching
# from the position before the move, and the marks that go beside them.
#
# The move played at the index is the map's own `uci`. Asking the game for it -
# `playedMove [mainLineMap [sc_game UCI_mainLine]] $index` - is the hazard this
# writer exists to close: at the same index the main line plays something else,
# and the played move's own line would then be inserted as an alternative.

# Write one node of a line map.
#
#   map      a ::review::currentLineMap dict
#   index    the line-local index of the move to write (1..plies)
#   label    the ladder's label for the move
#   eval_cp  the position's score in centipawns, from the mover's view, or ""
#   lines    the engine's lines for the position BEFORE the move, as writeMove
#            takes them, best first
#   engine   the engine's name for the alternatives' own comment
#
# Nothing is cleared and nothing is decided here that belongs to the caller: the
# previous verdict's marks are ::review::clearMarksAt's, and whether a variation
# is wanted at all is ::review::variationWanted's.
#
# The cursor is left where it was found on every path, refusals included, and the
# game is never pushed or copied. Returns "" or the reasons nothing, or not
# everything, was written - a refused alternative is a reason, not a failure of
# the verdict, exactly as writeMove reports it.
proc ::review::writeNode {map index label eval_cp lines {engine ""}} {
    variable nodeReasons
    set nodeReasons {}
    set out ""
    if {![string is integer -strict $index] || $index < 1} {
        return "index $index is not a move on this line"
    }
    set node ""
    catch { set node [dict get [dict get $map nodes] $index] }
    if {$node eq ""} {
        return "index $index is not on this line"
    }
    # The move the game played here, as the map records it.
    set played ""
    catch { set played [dict get $node uci] }
    # 1. The node: the verdict comment and the marks that go beside it. Each
    # phase below stands on the board through visitLine, which saves the cursor
    # once, walks, and restores it: this proc takes no save of its own, because
    # cursorSave leaves the board on the base ply and a save taken here would be
    # the wrong position for the walk to put back.
    set r {}
    set exact 1
    if {[catch {
        set r [visitLine $map [list $index] \
            [list ::review::writeNodeVerdict $label $eval_cp]]
    } err]} {
        lappend out "index $index: $err"
        set exact 0
    } elseif {![dict exists $r restored] || [dict get $r restored] != 1} {
        lappend out "index $index is not on this line"
        set exact 0
    }
    # 2. The diagram on the move before, where the mistake was played. 0 is also
    # what setDiagramAt answers for a diagram that is already there, so its
    # answer cannot tell a refusal from a mark that was ours already: it is not
    # read as one.
    set diagram 0
    catch { set diagram [::review::get diagram] }
    if {$exact && $diagram && $index >= 2 &&
            ($label eq "mistake" || $label eq "blunder")} {
        catch { setDiagramAt $map $index 1 }
    }
    # 3. The alternatives, from the position before the move. Last, because an
    # insertion renumbers the siblings at that branch point and every walk to the
    # node above has already been made.
    if {$exact && [llength $lines]} {
        if {[writeNodeAlternatives $map $index $engine $lines $played] != 1} {
            lappend nodeReasons "index $index: the alternatives could not be written"
        }
    }
    foreach why $nodeReasons { lappend out $why }
    # Nothing else puts the board back: the walks do it themselves, and a walk
    # that stopped because the line is not what the map described leaves it on
    # the base ply - a known position, which is the same fallback ::review::cursorRestore
    # takes when the line it recorded is gone.
    return $out
}

# The body writeNode's first walk runs with the cursor on the node: the comment
# the main-line writer writes, then the marks the driver keeps beside it. A
# refusal is a reason in ::review::nodeReasons, never an exception - an
# exception aborts the walk.
proc ::review::writeNodeVerdict {label eval_cp node} {
    variable nodeReasons
    # stripReviewTokens is the review's own strip: it takes our label, in the
    # language it was written in, and the [%eval] beside it, and keeps the
    # reader's prose - a [Coach] line among it. ::reviewcoach::strip is the
    # coach's own strip and would take that line with ours, so it is not used
    # here.
    sc_pos setComment [mergeComment \
        [stripReviewTokens [sc_pos getComment]] \
        [::commentcolors::wrapReview [commentText $label $eval_cp]]]
    set i [dict get $node index]
    # A move mark the user put there is theirs: AddNag replaces it in place, so
    # ours is written only when the move has none. AddNag has a fixed capacity
    # and sc_pos ignores its refusal, so the mark is read back.
    set nag [nagForLabel $label]
    if {$nag ne "" && ![hasMoveNag]} {
        addNagIfAbsent $nag
        if {[lsearch -exact [nags] $nag] < 0} {
            lappend nodeReasons "index $i: no room for the $nag mark"
        }
    }
    # The position assessment, from the same score the [%eval] shows. A quiet
    # verdict carries none, and one already on the move would contradict the
    # score just written.
    set assess ""
    if {$nag ne ""} { set assess [assessmentNag $eval_cp] }
    if {$assess ne ""} {
        setAssessment $assess
        if {[lsearch -exact [nags] $assess] < 0} {
            lappend nodeReasons "index $i: no room for the $assess assessment"
        }
    } else {
        dropAssessment
    }
    return
}

# The alternatives for the node at `index`, from the position before it. Returns
# the walk's own report, as visitLine does: 1 the cursor is back exactly, 0 the
# line is not what the map described, -1 the cursor could not be read.
proc ::review::writeNodeAlternatives {map index engine lines played} {
    variable nodeReasons
    if {$index >= 2} {
        set r {}
        if {[catch {
            set r [visitLine $map [list [expr {$index - 1}]] \
                [list ::review::writeNodeBranch $index $engine $lines $played]]
        } err]} {
            lappend nodeReasons \
                "index $index: the alternatives could not be inserted: $err"
            return -1
        }
        if {[dict exists $r restored]} { return [dict get $r restored] }
        return -1
    }
    # index 1: the position before the first move is the start of the line. The
    # map records it as node 0, but visitLine's walk begins at the first move and
    # never visits it - `sc_move ply 0` is where that walk starts, and it is the
    # same position however deep the line's branch is.
    set cursor ""
    if {[catch { set cursor [cursorSave] }]} { return -1 }
    set exact 1
    if {[catch {
        sc_move ply 0
        writeNodeBranch $index $engine $lines $played \
            [dict create index 0 ply 0 route {}]
    } err]} {
        lappend nodeReasons "index 1: the alternatives could not be inserted: $err"
        set exact 0
    }
    if {[cursorRestore $cursor] != 1} { set exact 0 }
    return $exact
}

# The body the alternatives walk runs with the cursor on the position the
# variations branch from: the move at `index` has been played, so this is the
# position before it and `sc_var create` adds a sibling of the line the reader is
# on rather than a variation of the move itself.
proc ::review::writeNodeBranch {index engine lines played node} {
    variable nodeReasons
    # The variations already here, by their first move: a second review must not
    # duplicate one, and var_lines > 1 must still add each distinct line. The list
    # is read before the first create, and again from the map each time a line is
    # added, so a line is never inserted twice by one write.
    set existing {}
    catch { set existing [sc_var list UCI] }
    foreach pv [selectLines $lines $played] {
        set first [lindex $pv 0]
        if {$first eq "" || [lsearch -exact $existing $first] >= 0} { continue }
        # A variation the game refuses part-way is not a variation: the engine's
        # line is inserted whole or dropped whole, and a half-written one is
        # deleted rather than left behind.
        set bad ""
        set firstMove 1
        if {[catch {
            sc_var create
            foreach uci $pv {
                if {[::uci::sc_move_add $uci]} {
                    set bad "the variation move $uci was rejected"
                    break
                }
                # The engine's name belongs to the variation it opened, not to
                # the line beside it.
                if {$firstMove && $engine ne ""} {
                    markVariation $engine
                    set firstMove 0
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
            if {$bad eq ""} { set bad "the variation could not be inserted: $err" }
        }
        if {$bad ne ""} {
            lappend nodeReasons "index $index: $bad"
            # A body that lost the board cannot write the next line: another
            # create here would branch from the wrong position.
            set here ""
            catch { set here [sc_pos location] }
            if {$here ne "" && [dict exists $node ply] &&
                    $here != [dict get $node ply]} {
                return
            }
            continue
        }
        lappend existing $first
    }
    return
}

# Whether a verdict should carry a variation at all. A variation is the move
# that should have been played, so it belongs where the label says one existed:
# a mistake, a blunder, or a missed win. Best, excellent and good moves have no
# better move to show, and the next-best line at one of those would be noise;
# an inaccuracy is deliberately left out too, because the gain is small and the
# variations would outnumber the interesting ones.
proc ::review::variationWanted {label} {
    return [expr {[lsearch -exact {mistake blunder miss} $label] >= 0}]
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
