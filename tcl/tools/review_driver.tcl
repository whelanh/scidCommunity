# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
########################################################################
### The engine pass behind Game Review and Move Comment.
###
### The pass runs on its own engine connection (id 20) so it never disturbs the
### analysis window's search: changing MultiPV on a window's engine restarts what
### the user is watching (::enginewin::changeOption), and a review that borrowed
### that connection would do the same.
###
### The driver is deliberately dumb about positions: the caller hands it
### {ply positionSpec} pairs, the same shape ::engine::send Go takes, because
### turning a game into position specs needs the game commands and this module
### must stay testable without them.
###
### onprogress {done total ply lines} reports each finished position, and ondone
### {results} fires exactly once per pass: on the last reply, or when the engine
### is lost. A results dict with fewer plies than the positions handed in is how a
### pass that was cut short is reported.

namespace eval reviewdriver {}

variable job
variable seq 0

# The pass ::reviewdriver::run has in flight (token, snapshot, cursor, options),
# and the public half of it that ::reviewdriver::status reports. Declared here so
# that a fresh session and a refused run start from the same empty state.
namespace eval ::reviewdriver {
    variable pass {}
    variable state {}
    # The coach's queue, while a run is waiting on it: the answers are the last
    # thing a review writes, so this is the one part of a run that outlives the
    # engine.
    variable proseJob {}
}

set ::reviewdriver::ENGINE_ID 20

# Whether an engine window may take this connection id. Window ids come from the
# same pool as every other engine connection, and ::engine::connect closes
# whatever already holds the id it is given, so a window opened on the pass's id
# would take the pass's engine - and the pass would take the window's.
# ::enginewin::Open asks this before it takes an id.
proc ::reviewdriver::reservedId {id} {
    return [expr {[string equal $id $::reviewdriver::ENGINE_ID]}]
}

proc ::reviewdriver::start {enginecfg positions mpv lim onprogress ondone} {
    variable job
    variable seq
    set id $::reviewdriver::ENGINE_ID
    if {[::reviewdriver::busy $id]} {
        error "engine $id is already running a pass"
    }
    incr seq
    set token "pass$seq"
    set job($token) [dict create \
        id $id enginecfg $enginecfg positions $positions index -1 \
        mpv $mpv limits $lim results {} lines {} configured 0 \
        stopped 0 onprogress $onprogress ondone $ondone]
    set exe [lindex $enginecfg 1]
    set args [lindex $enginecfg 2]
    ::engine::setLogCmd $id {}
    if {[catch {
        # The preset's args go in as one element, the way ::enginewin and
        # ::engineNoWin pass them: ::engine::connect takes the protocol from its
        # last positional, so splatting here either swallows "uci" into the
        # engine's own argv (Stockfish runs it as a command and exits) or gives
        # connect more positionals than it has parameters.
        ::engine::connect $id [list ::reviewdriver::callback $token] $exe $args uci
    } err]} {
        unset -nocomplain job($token)
        error $err
    }
    return $token
}

# Is a pass using this engine id? A finished pass leaves its connection open
# until the queued close runs, so the id can be occupied with nothing to run.
proc ::reviewdriver::busy {id} {
    variable job
    foreach token [array names job] {
        if {[dict get $job($token) id] eq $id} {
            return 1
        }
    }
    return 0
}

# Stop a pass: no further positions are started and the engine is closed.
# `restore` is 0 when the game the pass was reading has gone (a new game was
# loaded): putting the old cursor back would move the board in the new game.
proc ::reviewdriver::stop {token {restore 1}} {
    variable job
    variable pass
    variable state
    if {![info exists job($token)]} {
        return 0
    }
    set id [dict get $job($token) id]
    unset job($token)
    catch { ::engine::send $id StopGo }
    ::reviewdriver::closeSoon $id
    # A run of ours that is stopped here writes nothing - the write phase only
    # ever runs once the search has finished - and puts the reader back where
    # the pass found them, which cursorSave has already walked out of.
    if {[dict size $pass] && [dict get $pass token] eq $token} {
        set p $pass
        set pass {}
        dict set state state cancelled
        # A cancelled run is over too: the pane must not freeze on the last
        # position of a pass that no longer exists.
        if {[dict exists $p progressToken] \
                && [llength [info commands ::reviewprogress::finish]]} {
            catch { ::reviewprogress::finish [dict get $p progressToken] }
        }
        if {$restore} { ::reviewdriver::restoreRun $p }
        ::reviewdriver::runDoneHook $p
    }
    return 1
}

# The caller's completion hook, if it gave one: called exactly once per pass,
# with the run's status. `stop` calls it for a cancelled run and `endRun` for one
# that finished or failed, so a caller that chains passes (annotate mode's batch)
# has one place to advance from and a cancel is not a pass it waits forever for.
proc ::reviewdriver::runDoneHook {p} {
    set done ""
    catch { set done [dict get $p done] }
    if {$done eq ""} { return }
    catch { {*}$done [::reviewdriver::status] }
    return
}

# Nothing may close a connection from inside an engine reply. ::engine::close runs
# ::engine::destroy_, which unsets the arrays ::engine::reply walks *after* the
# callback returns, so a close in finish, or in an onprogress handler that stops the
# pass, throws on every completed pass. Queue the close instead, and take the channel
# it was queued for: a pass that starts in the meantime has its own connection and
# must keep it.
proc ::reviewdriver::closeSoon {id} {
    set channel ""
    catch { set channel $::engconn(channel_$id) }
    if {$channel eq ""} {
        return
    }
    after idle [list ::reviewdriver::closeConn $id $channel]
}

proc ::reviewdriver::closeConn {id channel} {
    if {![info exists ::engconn(channel_$id)]} {
        return
    }
    if {$::engconn(channel_$id) ne $channel} {
        return
    }
    catch { ::engine::close $id }
    # The connection is free, and this is the one point where the old one is
    # known to be gone: a verification queued behind it can start now. A queued
    # search would otherwise wait for an event that has already been and gone.
    if {[llength [info commands ::reviewverify::advance]]} {
        catch { ::reviewverify::advance }
    }
}

# The engine messages for a pass.
proc ::reviewdriver::callback {token msg} {
    variable job
    if {![info exists job($token)]} {
        return
    }
    lassign $msg msgType msgData
    switch -- $msgType {
        "InfoConfig" {
            # SetOptions answers with another InfoConfig: configure once.
            if {[dict get $job($token) configured]} {
                return
            }
            dict set job($token) configured 1
            ::reviewdriver::configure $token
            ::reviewdriver::next $token
        }
        "InfoPV" {
            ::reviewdriver::collect $token $msgData
        }
        "InfoBestMove" {
            ::reviewdriver::next $token
        }
        "InfoDisconnected" {
            # The process died mid-pass: its connection is already gone, and the
            # caller would otherwise wait forever for a pass nobody will finish.
            ::reviewdriver::lost $token
        }
    }
}

proc ::reviewdriver::configure {token} {
    variable job
    set id [dict get $job($token) id]
    set opts [list [list MultiPV [dict get $job($token) mpv]]]
    # ::review::effective, not the preset itself: a pass is a second engine, and
    # that is where the ceiling on the threads and hash it may take lives. Ask
    # the preset here and a 110 GB transposition table is allocated twice.
    set eff [::review::effective [dict get $job($token) enginecfg]]
    foreach key {threads hash} {
        set value [dict get $eff $key]
        if {$value ne ""} {
            lappend opts [list [expr {$key eq "threads" ? "Threads" : "Hash"}] $value]
        }
    }
    ::engine::send $id SetOptions $opts
}

# Whether a line's score is something ::reviewdriver::lineScore would use.
# `cp` and `mate` are measurements; `lowerbound`/`upperbound` are how far a search
# had got when it stopped, which is not a verdict - so a bound must never take a
# MultiPV slot from a line that can be judged, however deep it got.
proc ::reviewdriver::exactScore {score_type} {
    return [expr {$score_type eq "cp" || $score_type eq "mate"}]
}

# Keep the best line seen for each MultiPV slot of the current position: a
# verdict first, then the deepest one, and the later line when two are equally
# good.
#
# The order matters only since a pass can be cut off by time. A capped search
# reports a slot as a bound at the depth it had reached, then finishes the line;
# ranking by depth alone let the bound hold the slot - the exact line at the same
# depth was "not deeper" and was dropped, and a deeper bound overwrote an exact
# line already in hand. Either way ::reviewdriver::lineScore refuses what was
# kept and the ply gets no verdict at all.
#
# Two lines at the same depth and the same kind are the engine repeating itself,
# or finishing an iteration: the later one is the fresher reading of the same
# search, so it takes the slot rather than leaving a stale line in hand.
#
# A line with no depth at all is still a line: an engine may omit `depth`, and
# ::uci::parseline leaves the slot empty when it does. Dropping those recorded
# every such ply as unjudged. With no depth the line ranks below any measured
# one - zero against the -1 "nothing yet" sentinel - so it fills an empty slot
# and loses to a real depth, which is what the collector did before this ranking
# was written.
proc ::reviewdriver::collect {token msgData} {
    variable job
    lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time \
        score score_type score_wdl pv
    if {$multipv eq "" || $score eq ""} {
        return
    }
    if {![string is integer -strict $depth]} {
        set depth 0
    }
    set lines [dict get $job($token) lines]
    set oldDepth -1
    set oldExact 0
    if {[dict exists $lines $multipv]} {
        lassign [dict get $lines $multipv] oldDepth oldScore oldType oldPv
        set oldExact [::reviewdriver::exactScore $oldType]
    }
    set exact [::reviewdriver::exactScore $score_type]
    if {$exact < $oldExact} {
        return
    }
    if {$exact == $oldExact && $depth < $oldDepth} {
        return
    }
    dict set lines $multipv [list $depth $score $score_type $pv]
    dict set job($token) lines $lines
}

proc ::reviewdriver::next {token} {
    variable job
    if {![info exists job($token)]} {
        return
    }
    set j $job($token)
    set positions [dict get $j positions]
    set index [dict get $j index]
    if {$index >= 0} {
        # The position we were searching has finished: keep what it found.
        lassign [lindex $positions $index] ply spec
        set lines [dict get $j lines]
        set results [dict get $j results]
        dict set results $ply $lines
        dict set job($token) results $results
        dict set job($token) lines {}
        if {[dict get $j onprogress] ne ""} {
            catch { {*}[dict get $j onprogress] [expr {$index + 1}] [llength $positions] $ply $lines }
            # The handler may have stopped the pass. Then there is no job to
            # advance and no engine left to search the next position.
            if {![info exists job($token)]} {
                return
            }
        }
    }
    incr index
    if {$index >= [llength $positions]} {
        ::reviewdriver::finish $token
        return
    }
    dict set job($token) index $index
    dict set job($token) lines {}
    lassign [lindex $positions $index] ply spec
    set id [dict get $j id]
    # Both bounds in one Go, built by ::enginelimits::goLimits from the dict
    # ::review::passLimits decided: a depth floor and (when one is set) a time
    # ceiling. The engine stops at whichever comes first.
    ::engine::send $id Go [list $spec [::enginelimits::goLimits [dict get $j limits]]]
}

proc ::reviewdriver::finish {token} {
    variable job
    if {![info exists job($token)]} {
        return
    }
    set j $job($token)
    set id [dict get $j id]
    set results [dict get $j results]
    set done [dict get $j ondone]
    unset job($token)
    # finish runs inside the last InfoBestMove reply, so the close is queued rather
    # than done here; ondone still sees the whole result.
    ::reviewdriver::closeSoon $id
    if {$done ne ""} {
        catch { {*}$done $results }
    }
    return $results
}

# The engine is gone: report what finished and forget the pass. Nothing is closed,
# because there is nothing left to close.
proc ::reviewdriver::lost {token} {
    variable job
    if {![info exists job($token)]} {
        return
    }
    set j $job($token)
    unset job($token)
    set results [dict get $j results]
    set done [dict get $j ondone]
    if {$done ne ""} {
        catch { {*}$done $results }
    }
    # A lost connection is free in the same way a closed one is, but this runs
    # inside InfoDisconnected while ::engine::destroy_ is still tearing the old
    # connection down. Advancing synchronously would open the replacement on the
    # same id before destroy_ finished and then lose its callback. Wait a turn,
    # as the close path does.
    if {[llength [info commands ::reviewverify::advance]]} {
        catch { after idle ::reviewverify::advance }
    }
    return $results
}

########################################################################
### The half the caller owns: the plan, the verdicts, and the write.
###
### Everything above only searches positions it is handed. What turns the
### engine's messages into a review is three decisions that need the game and
### the settings:
###
###   * which positions to search, read from the snapshot map - the board is
###     never moved to build them, and never read again once the pass is over;
###   * what the engine's lines mean for one move: a label, and the White's-POV
###     [%eval] of the position after the move;
###   * searching the whole line first and writing afterwards, because a write
###     navigates the game, and an open engine window would re-enter its
###     sendPosition from the middle of the pass.

# The positions a pass searches, as the {ply positionSpec} pairs
# ::reviewdriver::start takes. ::review::searchPlies decides which positions and
# in what order; this only reads where each one is from the snapshot map.
# A position the map cannot name, and an empty spec, are dropped: an empty
# positional argument is a Go with no position in it.
proc ::reviewdriver::positions {map plies bookEnd} {
    return [::reviewdriver::planPositions $map [::review::plan $plies $bookEnd]]
}

# The positions a list of moves needs searched: the reference position before
# each move it judges, plus the position after each one, so the move can still be
# judged when the engine did not rank the move played (judge falls back to the
# searched successor).
#
# The plan is the caller's: ::review::plan is the whole line, but a single move
# has to be reviewable on its own (Move Comment writes one move and no others),
# and the positions follow from the moves rather than being worked out again.
# A position the map cannot name, and an empty spec, are dropped: an empty
# positional argument is a Go with no position in it.
proc ::reviewdriver::planPositions {map plan} {
    if {![llength $plan]} { return {} }
    set want {}
    foreach ply $plan { lappend want [expr {$ply - 1}] $ply }
    set out {}
    foreach ply [lsort -unique -integer $want] {
        if {$ply < 0} { continue }
        set spec ""
        if {[catch { set spec [dict get [dict get $map positions] $ply] }]} {
            continue
        }
        if {[string trim $spec] eq ""} {
            continue
        }
        lappend out [list $ply $spec]
    }
    return $out
}

# One engine line's score as centipawns from the mover's point of view, or ""
# when the line carries no score this pass may use.
#
# The searched position is the one BEFORE the move, so its side to move is the
# mover: no colour flip. `mate` is a distance to mate and becomes the encoding
# the label ladder and the graph share. `lowerbound`/`upperbound` are bounds on a
# score the engine never finished, which is not a verdict.
proc ::reviewdriver::lineScore {line} {
    if {[llength $line] < 4} { return "" }
    lassign $line depth score score_type pv
    if {$score eq "" || ![string is integer -strict $score]} { return "" }
    switch -- $score_type {
        cp   { return $score }
        mate { return [::movelabels::mateToCp $score] }
    }
    return ""
}

# The lines at searched position `ply` - the key ::reviewdriver::start records
# its results under - in ::review::writeMove's `{cp pv}` shape.
#
# MultiPV index order, never sorted by score: index 1 is the engine's best line
# and ::review::selectLines reads element 0 as the best line. A slot the engine
# never reported is simply absent rather than renumbered, and nothing past `mpv`
# is kept.
proc ::reviewdriver::lines {results ply mpv} {
    set out {}
    if {![string is integer -strict $mpv] || $mpv < 1} { return $out }
    if {![dict exists $results $ply]} { return $out }
    set got [dict get $results $ply]
    for {set i 1} {$i <= $mpv} {incr i} {
        if {![dict exists $got $i]} { continue }
        set line [dict get $got $i]
        set cp [::reviewdriver::lineScore $line]
        if {$cp eq ""} { continue }
        set pv [lindex $line 3]
        if {![llength $pv]} { continue }
        lappend out [list $cp $pv]
    }
    return $out
}

# The side to move at every position of the snapshot, from the map itself.
#
# Parity cannot answer this: a game may start from a FEN with Black to move, and
# a null move is a fresh `position fen ... moves` header that leaves the same side
# to move without advancing the ply counter. The header of each position says who
# starts, and only a real move flips the side.
proc ::reviewdriver::sides {map} {
    set sides {}
    set side ""
    catch {
        set words [split [dict get [dict get $map positions] 0]]
        if {[lindex $words 1] eq "startpos"} {
            set side w
        } elseif {[lindex $words 1] eq "fen"} {
            set side [lindex $words 3]
        }
    }
    if {$side ne "w" && $side ne "b"} { set side w }
    dict set sides 0 $side
    set plies 0
    catch { set plies [dict get $map plies] }
    for {set p 1} {$p <= $plies} {incr p} {
        set move ""
        catch { set move [dict get [dict get $map moves] $p] }
        if {$move eq ""} {
            # A null move's own header: it names the side to move, and the ply
            # counter is not a move.
            catch {
                set words [split [dict get [dict get $map positions] $p]]
                if {[lindex $words 1] eq "fen"} {
                    set side [lindex $words 3]
                } elseif {[lindex $words 1] eq "startpos"} {
                    set side w
                }
            }
        } else {
            set side [expr {$side eq "w" ? "b" : "w"}]
        }
        dict set sides $p $side
    }
    return $sides
}

# One move's verdict, as a dict: `label`, `eval_cp`, the two figures the label
# ladder used (`before` = the best line's score at the position before the move,
# `after` = what the ladder compared it with), and `isBest`.
#
# Returned as a dict rather than the {label eval_cp} pair ::reviewdriver::verdicts
# publishes because annotate mode needs the pair the ladder measured - the NAG
# and difficulty comments are written from the same drop the label came from -
# and recomputing it elsewhere would be a second, drifting copy of this
# reasoning. `before`/`after` are centipawns from the mover's point of view.
proc ::reviewdriver::judge {map results sides ply} {
    set before [expr {$ply - 1}]
    if {![dict exists $results $before]} { return "" }
    set lines [dict get $results $before]
    if {![dict exists $lines 1]} { return "" }
    set best [dict get $lines 1]
    set cp1 [::reviewdriver::lineScore $best]
    if {$cp1 eq ""} { return "" }
    set pv1 [lindex $best 3]
    set played [::review::playedMove $map $ply]
    # No move, no verdict: a null move is a header, not a move to label, and
    # writing a comment and variations into it would corrupt the game.
    if {$played eq ""} { return "" }
    set isBest [expr {[string equal [lindex $pv1 0] $played]}]
    # The line the move owns at this root, when the engine ranked it: one
    # search for both figures, so the drop it measures is not search noise.
    set ranked ""
    foreach idx [lsort -integer [dict keys $lines]] {
        set line [dict get $lines $idx]
        if {[string equal [lindex [lindex $line 3] 0] $played]} {
            set ranked [::reviewdriver::lineScore $line]
            break
        }
    }
    # The searched successor is the engine's own evaluation of the position
    # the move reaches, from the opponent's point of view; negate it to the
    # mover's. This is the figure the comment's [%eval] carries, whatever the
    # move's rank at the root: the unranked case already had to use it, and
    # one source for the token beats two.
    set successor ""
    if {[dict exists $results $ply] && [dict exists [dict get $results $ply] 1]} {
        set successor [::reviewdriver::lineScore [dict get [dict get $results $ply] 1]]
        if {$successor ne ""} { set successor [expr {-$successor}] }
    }
    set after $ranked
    if {$after eq ""} { set after $successor }
    # The ladder needs a pair of evaluations. A move the engine measured -
    # the best line, or the line the move owns, or the searched successor -
    # has one; a move it never measured does not, and "no drop measured" is
    # not the same as "excellent". Only the engine's own move is judged
    # without a successor (it is `best` by definition); anything else is
    # left unlabelled rather than given a verdict nothing supports.
    if {$after eq "" && !$isBest} { return "" }
    set judged $after
    if {$judged eq ""} { set judged $cp1 }
    # [%eval] is White's point of view. The figure is the mover's, and the
    # mover is whoever is to move in the position before the move - read from
    # the snapshot, not from ply parity.
    set shown $successor
    if {$shown eq ""} { set shown $ranked }
    set eval_cp ""
    if {$shown ne ""} {
        set mover ""
        catch { set mover [dict get $sides $before] }
        set eval_cp [expr {$mover eq "b" ? -$shown : $shown}]
    }
    set label [::movelabels::label $cp1 $judged $isBest]
    # The second engine's verdict, when it withdrew this label: ::reviewdriver::
    # verified folds the verifier's corrections into the results, so every writer
    # that judges a move sees the same label the verifier agreed with. A
    # correction only ever moves a label DOWN (see ::reviewdriver::labelRank):
    # whatever a corrections dict carries, nothing here can promote a move.
    if {[dict exists $results corrections]} {
        set corrections [dict get $results corrections]
        if {[dict exists $corrections $ply]} {
            set want [dict get $corrections $ply]
            set mine [::reviewdriver::labelRank $label]
            set theirs [::reviewdriver::labelRank $want]
            if {$mine ne "" && $theirs ne "" && $theirs < $mine} { set label $want }
        }
    }
    return [dict create label $label \
        eval_cp $eval_cp before $cp1 after $judged isBest $isBest]
}

# Where a label sits on the ladder, higher meaning better. A label not named here
# (book, forced - both position facts rather than judgements) has no rank and is
# never replaced by a correction.
#
# This is the guard that makes a verifier safe: the second engine's answer is a
# subtraction, so its corrections can only ever withdraw the two labels it was
# asked about, never write a better one.
proc ::reviewdriver::labelRank {label} {
    switch -- $label {
        brilliant  { return 5 }
        great      { return 4 }
        best       { return 3 }
        excellent  { return 2 }
        good       { return 1 }
        inaccuracy { return 0 }
        mistake    { return -1 }
        miss       { return -1 }
        blunder    { return -2 }
    }
    return ""
}

# ply -> {label eval_cp} for every move the pass can judge, from the results of
# the positions it searched.
#
# For move `ply` the reference position is `ply - 1`: its best line gives the
# evaluation before the move (cp1) and the engine's preferred move (the first
# move of that line, pv1). The evaluation after the move is the score of the line
# the game's own move owns, when the engine ranked that move at all; when it did
# not, the searched successor position `ply` answers instead, negated because its
# side to move is the opponent.
#
# `label` is ::movelabels::label's, both figures from the mover's point of view.
# `eval_cp` is White's-POV centipawns of the position AFTER the move - never the
# best-line score - because that is what a [%eval] token means to the graph. When
# there is no successor to compare against, eval_cp is "" and ::review::commentText
# omits the token.
proc ::reviewdriver::verdicts {map results} {
    set out {}
    set sides [::reviewdriver::sides $map]
    set plies 0
    catch { set plies [dict get $map plies] }
    for {set ply 1} {$ply <= $plies} {incr ply} {
        set v [::reviewdriver::judge $map $results $sides $ply]
        if {$v eq ""} { continue }
        dict set out $ply [list [dict get $v label] [dict get $v eval_cp]]
    }
    return $out
}

# A run's public state as ::reviewdriver::status answers it. `reason` is why a run
# failed ("" otherwise) and `restored` is 1 when the cursor was verified back where
# the pass found it - a restore that fell back to a known position is not a failed
# review, because the comments landed.
proc ::reviewdriver::blankState {{state idle}} {
    return [dict create state $state searched 0 total 0 written 0 failed 0 \
        coachDone 0 coachTotal 0 errors {} reason "" restored 0]
}

proc ::reviewdriver::status {} {
    variable state
    if {![dict size $state]} { return [::reviewdriver::blankState] }
    return $state
}

# Search the whole main line and then write the verdicts into the game.
#
# `engine` is the preset (::enginecfg::get's shape); "" is a refusal rather than a
# silent choice of some other engine. Returns "" when the pass started, otherwise
# the reason it did not - and in that case nothing was started, nothing was moved
# and nothing was written.
#
#   -bookEnd N      where the opening book ends (default 0)
#   -plies {list}   the moves to judge (default: every move the plan covers), so
#                   that Move Comment can review one move and no others
#   -depth N        the depth to search (default: ::review::effective's, which is
#                   the review's own floor over the preset's)
#   -progress cmd   called as {*}$cmd <done> <total> as positions finish
#   -notify 0|1     refresh the board when the write phase ends (default 0)
#   -coach 0|1      override the ::review::coach setting for this pass; annotate
#                   mode passes 0 because its dialog ships tier 1 without prose
#   -line <map>     the line to review, when the reader is not on the main line:
#                   a ::review::currentLineMap dict. The plan is its `judged`
#                   set, the board is not read for a map of its own, bookEnd is
#                   0 whatever -bookEnd says, and the pass writes the move
#                   layer only (see ::reviewdriver::writeLine)
#   -force 0|1      judge every node of the line, not just the unlabelled ones
#                   (the driver half of the skip rule; no UI row sets it)
#
# There is no -movetime: the time cap is ::review::movetime or the preset's
# Limits.movetime (::review::passLimits), so the pass and the settings dialog
# cannot disagree about it.
proc ::reviewdriver::run {engine args} {
    variable pass
    variable state
    set bookEnd 0
    set plies ""
    set want ""
    set progress ""
    set notify 0
    set coachOpt ""
    # The line map a variation pass is handed, and whether it judges every node
    # of it. Both empty on the main-line path, which is unchanged (D1).
    set line ""
    set force 0
    # The progress board's header fields, composed by the caller: the source,
    # the engine name and where the run came from. The driver begins the job
    # and feeds it the position it is on; it never composes the header itself.
    set header ""
    # The caller's completion hook: annotate mode chains one pass per game, so
    # the chain lives in the pass dict rather than in a module variable.
    set done ""
    # The write phase, and the one place a caller can change it: annotate mode
    # (tcl/tools/review_annotate.tcl) writes the classic annotator's marks beside
    # the label, and it must not carry a second copy of the plan ::review::plan
    # already decided. Same contract as writeResults: called as
    # {*}$writer <pass> <results>, returning {written failed errors}.
    set writer ::reviewdriver::writeResults
    for {set i 0} {$i < [llength $args]} {incr i} {
        set opt [lindex $args $i]
        switch -- $opt {
            -bookEnd  { incr i ; set bookEnd [lindex $args $i] }
            -plies    { incr i ; set plies [lindex $args $i] }
            -depth    { incr i ; set want [lindex $args $i] }
            -progress { incr i ; set progress [lindex $args $i] }
            -notify   { incr i ; set notify [lindex $args $i] }
            -done     { incr i ; set done [lindex $args $i] }
            -writer   { incr i ; set writer [lindex $args $i] }
            -coach    { incr i ; set coachOpt [lindex $args $i] }
            -header   { incr i ; set header [lindex $args $i] }
            -line     { incr i ; set line [lindex $args $i] }
            -force    { incr i ; set force [lindex $args $i] }
            default   { return "unknown option: $opt" }
        }
    }
    if {![string is integer -strict $bookEnd]} { return "-bookEnd must be a whole number" }
    if {$force ne 0 && $force ne 1} { return "-force must be 0 or 1" }
    # A line map is a snapshot, and this pass reads only what is in it: a map
    # missing one of its tables would be searched as if the line ended early, so
    # it is refused rather than half-trusted.
    if {$line ne ""} {
        foreach key {plies moves positions nodes judged} {
            if {![dict exists $line $key]} {
                return "the line map has no $key"
            }
        }
    }
    if {[llength $plies]} {
        foreach ply $plies {
            if {![string is integer -strict $ply] || $ply < 1} {
                return "-plies must be a list of move numbers"
            }
        }
        set plies [lsort -unique -integer $plies]
        # A caller that names the moves is asking for those moves, whatever the
        # book says: Move Comment on a book move still gets its comment.
        set bookEnd 0
    }
    if {$want ne "" && (![string is integer -strict $want] || $want < 1)} {
        return "-depth must be a whole number"
    }
    if {$coachOpt ne "" && $coachOpt ni {0 1}} {
        return "-coach must be 0 or 1"
    }
    if {[llength $engine] == 0} { return "no engine selected" }
    # The pass pins the protocol to uci: an XBoard preset would never answer the
    # handshake, and the run would sit in `searching` until the user cancelled.
    if {[lindex $engine 7] eq "" || [lindex $engine 7] eq 0} {
        return "the review needs a UCI engine"
    }
    # One run at a time, and refusal before anything is read: a second call must
    # not rewrite the counts of the pass that is already searching.
    if {[dict size $pass]} {
        return "engine 20 is already running a pass"
    }
    # What the pass may spend is ::review::effective's answer, not a second set of
    # defaults here: the preset wins Threads/Hash, MultiPV is at least two, and
    # ::review::passLimits owns the depth floor and the time ceiling.
    set eff [::review::effective $engine]
    set mpv [dict get $eff mpv]
    set lim [dict create depth [dict get $eff depth] movetime [dict get $eff movetime]]
    # A caller that knows the depth (Move Comment: the window's analysis, or the
    # review's own when the setting says to wait for it) is the depth searched.
    # The time cap is not the caller's: it bounds the pass, and a caller lowering
    # the depth is asking for a shallower search anyway.
    if {$want ne ""} { dict set lim depth $want }
    # MultiPV is asked for on the pass's own connection and an engine that does
    # not offer it ignores the option, so a preset that never overrode it is not
    # evidence of anything: ::enginecfg::save drops options sitting at their
    # default, so most presets have no mpv key at all. A one-line engine simply
    # returns one line and the verdicts fall back to the searched successor.
    set map ""
    if {$line ne ""} {
        # A variation pass is handed the map the caller built from the cursor
        # (::review::currentLineMap). Building mainLineMap here is exactly the
        # failure this card closes: the reader is looking at a variation, and
        # the main line would be searched and labelled instead.
        set map $line
    } elseif {[catch { set map [::review::mainLineMap [sc_game UCI_mainLine]] } err]} {
        return $err
    }
    set plan $plies
    if {$line eq ""} {
        # The whole line, not the plan minus the book: the book moves are written
        # (as [Book]) rather than searched, and the writer needs them in the plan.
        if {![llength $plan]} { set plan [::review::plan [dict get $map plies] 0] }
    } else {
        # D6: the map's judged set - the nodes no verdict is on - unless the
        # caller names moves (-plies) or asks for every node (-force 1).
        if {![llength $plan]} {
            if {$force} {
                set plan [::review::plan [dict get $map plies] 0]
            } else {
                set plan [dict get $map judged]
            }
        }
        # D7: the book is a main-line concept. A line pass starts at the first
        # move of the line whatever -bookEnd said, so a prefix node already
        # labelled [Book] is skipped by the judged set and never by the book gate.
        set bookEnd 0
    }
    # The positions to search: from the last book move on, so the move that
    # leaves the book has its reference position, and the early opening is not
    # searched for moves that are only going to be labelled Book.
    set search $plan
    if {$bookEnd > 0} {
        set search {}
        foreach ply $plan {
            if {$ply >= $bookEnd} { lappend search $ply }
        }
    }
    set positions [::reviewdriver::planPositions $map $search]
    if {![llength $positions]} {
        # Nothing to search is a pass that finished, not a failure: the book
        # covered the game.
        set state [::reviewdriver::blankState done]
        return ""
    }
    # Before anything touches the board and before the engine starts: the restore
    # at the end is the only thing that puts the reader back where the pass found
    # them.
    set cursor [::review::cursorSave]
    # Not published until the pass has started: a refusal must leave the status
    # of a run that is already in flight alone.
    set starting [dict merge [::reviewdriver::blankState searching] \
        [dict create total [llength $positions]]]
    set token ""
    if {[catch {
        set token [::reviewdriver::start $engine $positions $mpv $lim \
            ::reviewdriver::runProgress ::reviewdriver::runDone]
    } err]} {
        # id 20 is already running a pass, or the engine could not be opened. A
        # pass that is already running keeps its own state: this refusal is the
        # caller's answer, not a report about that run.
        catch { ::review::cursorRestore $cursor }
        if {![dict size $pass]} {
            set state [dict merge [::reviewdriver::blankState failed] \
                [dict create total [llength $positions] reason $err]]
        }
        return $err
    }
    set state $starting
    # `plan` is the moves this run judges (all of them, or -plies); `plies` and
    # `bookEnd` are kept for a writer that derives its own plan (annotate mode).
    #
    # `report` is 1 for a whole-game pass with the default writer (Game Review):
    # it owns the prose on its moves, so a run with the coach off still takes the
    # last run's blocks off. An annotate pass uses its own writer and leaves the
    # coach's blocks alone; a pass over named moves (Move Comment) is not a
    # review. `coach` is the setting read once, here, so a mid-run edit cannot
    # split one run in two.
    set coach 0
    catch { set coach [::review::get coach] }
    if {$coachOpt ne ""} { set coach $coachOpt }
    if {[llength $plies]} { set coach 0 }
    # D5, and the boundary this card exists to draw: ::reviewcoach::place and
    # ::reviewcoach::clear read $p map + $p plan through sc_move ply and write
    # prose about the game. A line map is a variation; there is no whole game
    # under it for them to read, so a line pass never asks for prose.
    if {$line ne ""} { set coach 0 }
    # The verifier is read once, here, like the coach: an engine picked (or
    # cleared) mid-run must not split one run in two. "" is Off - the default -
    # and then no second search happens and every label stays as it was.
    set verifier ""
    catch { set verifier [::review::verifier] }
    # `report` is the whole-game switch, and a variation line is not a whole
    # game: ::reviewreport::collect reads $p map + $p plan through sc_move ply and
    # would write the main-line report from a variation's nodes. Off for a line
    # pass, which is why writeResults' report, opening mark and Annotator tag are
    # never reached (D5).
    set report [expr {[llength $plies] ? 0 : [string equal $writer ::reviewdriver::writeResults]}]
    if {$line ne ""} { set report 0 }
    set pass [dict create token $token map $map plan $plan \
        plies [dict get $map plies] bookEnd $bookEnd mpv $mpv \
        positions $positions cursor $cursor engine $engine done $done \
        progress $progress notify $notify writer $writer \
        verifier $verifier limits $lim \
        coach $coach report $report]
    if {$line ne ""} {
        # What makes this pass a line pass for everything downstream: the writer
        # branch, and the route and anchors the map was addressed by, kept with
        # the run so a failure can say which line it was.
        dict set pass lineKind variation
        dict set pass lineRoute [dict get $map cursorRoute]
        dict set pass lineAnchors [dict get $map anchors]
    }
    # The board is decoration over this run: it starts when the run does, and it
    # is told nothing the pass has not already decided.
    if {$header ne "" && [llength [info commands ::reviewprogress::begin]]} {
        catch { dict set pass progressToken [::reviewprogress::begin $header] }
        # The run's first position, before the first search finishes: otherwise
        # the pane shows no board at all until position one has been searched.
        if {[dict exists $pass progressToken] && [llength $positions]} {
            catch {
                ::reviewprogress::setSpec [dict get $pass progressToken] \
                    [lindex $positions 0 1] 0 [llength $positions]
            }
        }
    }
    return ""
}

# Stop the run ::reviewdriver::run started. The search writes nothing when it is
# cancelled - the write phase only ever runs once the search has finished - and
# the prose phase has already written the game, so cancelling it keeps what the
# model had answered and drops the rest.
proc ::reviewdriver::cancel {{restore 1}} {
    variable pass
    variable state
    if {![dict size $pass]} { return 0 }
    set token [dict get $pass token]
    if {[::reviewdriver::proseActive $token]} {
        catch { ::reviewprose::cancel }
        return 1
    }
    # Waiting on a second opinion is still a run in flight, and the main pass's
    # job is already gone - ::reviewdriver::stop would find no token to stop and
    # leave the run open. Stop the verification instead and close the run here:
    # nothing has been written yet, so the reader goes back where the pass found
    # them and no label is written at all.
    set pending ""
    catch { set pending [dict get $pass verifyPending] }
    if {$pending ne ""} {
        set p $pass
        set pass {}
        dict set state state cancelled
        if {[dict exists $p progressToken] \
                && [llength [info commands ::reviewprogress::finish]]} {
            catch { ::reviewprogress::finish [dict get $p progressToken] }
        }
        if {$restore} { ::reviewdriver::restoreRun $p }
        ::reviewdriver::runDoneHook $p
        return 1
    }
    set verify ""
    catch { set verify [dict get $pass verifyToken] }
    if {$verify ne ""} {
        set p $pass
        set pass {}
        catch { ::reviewverify::stop $verify }
        dict set state state cancelled
        if {[dict exists $p progressToken] \
                && [llength [info commands ::reviewprogress::finish]]} {
            catch { ::reviewprogress::finish [dict get $p progressToken] }
        }
        if {$restore} { ::reviewdriver::restoreRun $p }
        ::reviewdriver::runDoneHook $p
        return 1
    }
    return [::reviewdriver::stop $token $restore]
}

# The coach's progress, in the caller's own vocabulary: {*}$cmd <done> <total>.
# The window's status line reads the counts through ::reviewdriver::status, so a
# review that is waiting for a model says so instead of going quiet.
proc ::reviewdriver::proseProgress {done total args} {
    variable pass
    variable state
    if {![dict size $pass]} { return }
    dict set state coachDone $done
    dict set state coachTotal $total
    # The pane's second measure: the search bar is full by now, and the prose
    # bar is what says the model is still working.
    if {[dict exists $pass progressToken] \
            && [llength [info commands ::reviewprogress::setProse]]} {
        catch { ::reviewprogress::setProse [dict get $pass progressToken] $done $total }
    }
    set cmd [dict get $pass progress]
    if {$cmd ne ""} { catch { {*}$cmd $done $total } }
    return
}

# Between searches a run reports progress only, and the caller's command hears
# about it in its own vocabulary: {*}$cmd <done> <total>.
proc ::reviewdriver::runProgress {done total ply lines} {
    variable pass
    variable state
    if {![dict size $pass]} { return }
    dict set state searched $done
    # The progress board follows the search: the position the pass is on now,
    # replayed from the spec the driver queued, never from the game.
    if {[dict exists $pass progressToken]} {
        set spec ""
        catch {
            # The position that just finished is not the one being searched
            # now: show the next queued position, and keep the last one at the
            # end of the run.
            set queue [dict get $pass positions]
            set at [lsearch -index 0 $queue $ply]
            if {$at >= 0} {
                if {$at + 1 < [llength $queue]} { incr at }
                set spec [lindex [lindex $queue $at] 1]
            }
        }
        if {$spec ne ""} {
            catch {
                ::reviewprogress::setSpec [dict get $pass progressToken] $spec \
                    $done $total
            }
        }
    }
    set cmd [dict get $pass progress]
    if {$cmd ne ""} { catch { {*}$cmd $done $total } }
}

# Whether two presets are the same engine: the same executable with the same
# arguments. A duplicate preset has a different name but the same engine, and a
# second opinion from it is not independent either.
proc ::reviewdriver::sameEngine {a b} {
    if {[llength $a] < 2 || [llength $b] < 2} { return 0 }
    return [expr {[lindex $a 1] eq [lindex $b 1] \
        && [lindex $a 2] eq [lindex $b 2]}]
}

# The shared transform every writer runs before it writes: the verifier's
# corrections folded into the results, so the label each move is written with is
# the one the second engine agreed with.
#
# Pure, and the identity when there is nothing to correct - a review with the
# verifier off (the default) gets back exactly the results the search produced.
# `corrections` is the ply -> label map ::reviewverify::corrections answers, and
# the writer's label comes through ::reviewdriver::judge, which reads it from the
# results: no writer has to know the verifier exists.
proc ::reviewdriver::verified {results corrections} {
    if {![dict size $corrections]} { return $results }
    return [dict set results corrections $corrections]
}

# Get the verifier's corrections for this pass, then write - or write at once
# when there is nothing to verify.
#
# This is the seam #380 and #422 call ::reviewdriver::verified: the verifier feeds
# the verdicts and does not run inside the write, so every path that writes a
# review comes through here with its own writer - the pass, the batch annotator
# and Rapid Annotate alike. `write` is called as `{*}$write <results>
# <corrections>`, and the writer folds the corrections in with
# ::reviewdriver::verified immediately before it writes.
#
# The search goes through ::reviewdriver::start - the pass's own connection and
# per-position queue - and answers through the event loop: nothing here waits,
# so a caller inside an engine reply or a button press is not blocked.
#
# Returns 1 when the search is in flight (the write happens in its answer), 0
# when it has already happened.
proc ::reviewdriver::verifyWrite {p results write} {
    variable pass
    variable state
    set none [dict create]
    set name ""
    catch { set name [dict get $p verifier] }
    # A second opinion from the same engine is not a second opinion. The UI lists
    # every preset; a run whose verifier names the engine that produced the labels
    # - or a duplicate preset of the same executable and arguments - writes them
    # unverified rather than letting the engine confirm itself.
    set analysisCfg ""
    catch { set analysisCfg [dict get $p engine] }
    set cfg ""
    if {$name ne ""} { catch { set cfg [::enginecfg::get $name] } }
    if {$name ne "" && [::reviewdriver::sameEngine $analysisCfg $cfg]} {
        set name ""
        set cfg ""
    }
    set jobs {}
    if {$name ne "" && [llength [info commands ::reviewverify::jobs]]} {
        set labels [dict create]
        # The labels the pass decided, from the same results the writer will
        # read: Brilliant and Great are the only labels a verifier has an opinion
        # about, and the ladder is the only place those words come from.
        catch {
            set verdicts [::reviewdriver::verdicts [dict get $p map] $results]
            dict for {ply v} $verdicts { dict set labels $ply [lindex $v 0] }
        }
        set bookEnd 0
        catch { set bookEnd [dict get $p bookEnd] }
        catch {
            set jobs [::reviewverify::jobs [dict get $p map] $results $labels $bookEnd]
        }
    }
    if {![llength $jobs]} {
        {*}$write $results $none
        return 0
    }
    # Two lines whatever the pass asked for: a Great claim is the gap between the
    # best and the second line, and one line cannot measure it.
    set mpv 2
    catch {
        set passMpv [dict get $p mpv]
        if {$passMpv > $mpv} { set mpv $passMpv }
    }
    set lim [dict create]
    catch { set lim [dict get $p limits] }
    set token ""
    if {[llength $cfg]} {
        catch {
            set token [::reviewverify::start $cfg $jobs $mpv $lim \
                [list ::reviewdriver::verifiedDone $p $write $results]]
        }
    }
    if {$token eq ""} {
        # No verifier, a preset this tree cannot open, or a connection already
        # taken: a skipped second opinion, not a failed review. The labels are
        # written exactly as the search produced them.
        {*}$write $results $none
        return 0
    }
    # The run stays open while it is searched: Cancel reads this.
    if {[dict size $pass] && [dict exists $p token] &&
        [dict get $pass token] eq [dict get $p token]} {
        dict set pass verifyToken $token
    }
    return 1
}

# The verifier answered: write the review with what it agreed to.
#
# The second engine's answer is only ever a subtraction, so an empty corrections
# dict - nothing verified, or nothing usable came back - writes the labels the
# search itself produced.
proc ::reviewdriver::verifiedDone {p write results corrections} {
    variable pass
    if {[dict size $pass] && [dict exists $p token] &&
        [dict get $pass token] eq [dict get $p token]} {
        dict set pass verifyToken ""
    }
    {*}$write $results $corrections
}

# The runner finished: now, and only now, the game is written.
proc ::reviewdriver::runDone {results} {
    variable pass
    variable state
    if {![dict size $pass]} { return }
    set p $pass
    set total [llength [dict get $p positions]]
    dict set state searched [dict size $results]
    if {[dict size $results] < $total} {
        # A pass that lost its engine reports what it had through the same
        # callback. Half a review is worse than none: nothing is written.
        dict set state state failed
        dict set state reason \
            "the engine stopped after [dict size $results] of $total positions"
        ::reviewdriver::endRun $p
        return
    }
    dict set state state writing
    # The verifier, when Review Settings names one, gets the last word on
    # Brilliant and Great before anything is written: it is a second engine and a
    # second search, so it runs here - after the pass, before the game changes.
    #
    # Start it one event turn later. runDone is called inside the main engine's
    # reply, and ::reviewverify::start opens a new connection on the same id; the
    # old connection's close is already queued, and starting a replacement before
    # that close has run would let the old reader walk the new connection's
    # handshake. The batch and Rapid Annotate are not inside a reply and call
    # verifyWrite directly.
    set verifier ""
    catch { set verifier [dict get $p verifier] }
    if {$verifier ne ""} {
        # The idle callback is a pending part of this run: Cancel has to see it
        # before verifyWrite has a verifyToken to stop.
        dict set pass verifyPending 1
        after idle [list ::reviewdriver::verifyAfterIdle $p $results]
    } else {
        ::reviewdriver::verifyWrite $p $results [list ::reviewdriver::writeRun $p]
    }
}

# The verifier start, one event turn after the main pass answered. The pass may
# have been cancelled or replaced while that turn waited; then there is nothing
# to verify and nothing to write.
proc ::reviewdriver::verifyAfterIdle {p results} {
    variable pass
    if {![dict size $pass] || [dict get $pass token] ne [dict get $p token]} {
        return
    }
    if {![dict exists $pass verifyPending]} { return }
    dict unset pass verifyPending
    ::reviewdriver::verifyWrite $p $results [list ::reviewdriver::writeRun $p]
}

# The one write phase, after the search. The coach is started from here, after
# the labels are in the game: prose is the last layer, and it must not be written
# into a game the writer is still changing.
proc ::reviewdriver::writeRun {p results {corrections ""}} {
    variable pass
    variable state
    # The verifier's corrections travel with the pass as well as with the
    # results: the deterministic report reads the verdicts the write was made
    # from, and a report that tallied the labels the verifier withdrew would
    # describe a game that is not the one in front of the reader.
    if {[dict size $corrections]} { dict set p corrections $corrections }
    # The shared transform, immediately before the writer: the label the game is
    # written with is the one the second engine agreed with. Identity when there
    # is no verifier or nothing was corrected.
    set results [::reviewdriver::verified $results $corrections]
    # A full review owns the coach blocks on its moves: take the previous run's
    # prose off first, whether or not this run has a provider.
    set report 0
    catch { set report [dict get $p report] }
    if {$report && [llength [info commands ::reviewcoach::clear]]} {
        catch { ::reviewcoach::clear $p $results }
    }
    set counts ""
    if {[catch { set counts [{*}[dict get $p writer] $p $results] } err]} {
        # A writer that blew up wrote part of a review: report it rather than
        # calling the pass clean, and still put the cursor back.
        dict incr state failed
        dict lappend state errors "write phase: $err"
    } else {
        foreach key {written failed} {
            if {[dict exists $counts $key]} {
                dict set state $key [dict get $counts $key]
            }
        }
        if {[dict exists $counts errors]} {
            dict set state errors [dict get $counts errors]
        }
    }
    # The labels and the report are in the game now. Put the reader back and
    # redraw before the coach starts: prose can take minutes, and a review the
    # user cannot see reads as one that never ran at all.
    ::reviewdriver::restoreRun $p
    ::reviewdriver::notifyBoard $p
    # The coach is the last layer: it reads the written game and says nothing
    # about where the moves are. A switch with no provider behind it is a no-op,
    # not an error, and a queue that cannot start must not hold the run open.
    set coach 0
    catch { set coach [dict get $p coach] }
    if {$coach && [llength [info commands ::reviewcoach::start]]} {
        variable proseJob
        set proseJob [dict create token [dict get $p token] p $p]
        set started 0
        catch {
            set started [::reviewcoach::start $p $results \
                [list ::reviewdriver::proseDone [dict get $p token]] \
                ::reviewdriver::proseProgress]
        }
        if {$started} { return }
        set proseJob {}
    }
    dict set state state done
    ::reviewdriver::endRun $p 0
}

# The queue is live for the pass `token`: what Cancel has to drop, and what keeps
# the run open.
proc ::reviewdriver::proseActive {token} {
    variable proseJob
    if {![dict size $proseJob]} { return 0 }
    if {[dict get $proseJob token] ne $token} { return 0 }
    if {[llength [info commands ::reviewprose::status]] == 0} { return 0 }
    set st [dict create active 0]
    catch { set st [::reviewprose::status] }
    if {[dict get $st active]} { return 1 }
    return 0
}

# Prose finished, failed or was cancelled: the answers are in the game and the
# pass can close. `restore 0` because the write phase already put the reader
# back before the coach started, and moving them again would drag a board they
# have since browsed back to where the pass began.
#
# `cancelled` is the queue's own report of how it ended (::reviewcoach::finish
# passes it through from ::reviewprose::finish), and it is what the state says.
# A stopped review closed as `done` is a lie a caller cannot see through: the
# window, the annotate batch and any hook all read this one word, and Cancel
# emptied the run before the driver here, so nothing else would correct it.
proc ::reviewdriver::proseDone {token {cancelled 0}} {
    variable pass
    variable state
    variable proseJob
    if {![dict size $pass] || [dict get $pass token] ne $token} { return }
    set p ""
    catch { set p [dict get $proseJob p] }
    set proseJob {}
    dict set state state [expr {$cancelled ? "cancelled" : "done"}]
    if {$p ne ""} { ::reviewdriver::endRun $p 0 }
}

# Write one move at a time, ascending, from the verdicts the search produced.
# A writeMove refusal is collected and the next move is still written: writeMove
# leaves the game where it found it on every path, so one refusal cannot corrupt
# the rest.
# Take off what the previous review wrote on the move at `ply` beside the
# comment tokens: the NAG its label implies, and the diagram it put on the move
# before. A mark the user put there is kept unless it is the same symbol this
# review wrote - the label token is what says the mark was ours.
proc ::reviewdriver::clearMarks {ply} {
    set old ""
    # sc_move answers OK even when the ply is past the end (MoveToPly stops at
    # the last move), so the location has to be checked: a plan made before the
    # game was shortened must not clear marks off a different move.
    if {[catch { sc_move ply $ply }]} { return }
    if {[catch { sc_pos location } loc] || $loc != $ply} { return }
    catch { set old [::review::labelOfComment [sc_pos getComment]] }
    if {$old eq ""} { return }
    set nag [::review::nagForLabel $old]
    if {$nag ne ""} { catch { ::review::dropNag $nag } }
    # The assessment was the old score's; the new verdict replaces it.
    catch { ::review::dropAssessment }
    if {$old eq "mistake" || $old eq "blunder"} {
        catch { ::review::setDiagram $ply 0 }
    }
    return
}

proc ::reviewdriver::writeResults {p results} {
    # A variation pass writes nodes, not the game. Everything below this line -
    # the loop, the deterministic report, the opening mark, the Annotator tag and
    # the whole-game fallback - reads $p map and $p plan as main-line plies
    # through sc_move ply, so a line pass returns to its own writer before any of
    # it runs.
    if {[dict exists $p lineKind] && [dict get $p lineKind] eq "variation"} {
        return [::reviewdriver::writeLine $p $results]
    }
    set map [dict get $p map]
    set mpv [dict get $p mpv]
    set bookEnd 0
    catch { set bookEnd [dict get $p bookEnd] }
    set diagram 0
    catch { set diagram [::review::get diagram] }
    set written 0
    set failed 0
    set errors {}
    set engineName ""
    catch { set engineName [lindex [dict get $p engine] 0] }
    set verdicts [::reviewdriver::verdicts $map $results]
    set sides [::reviewdriver::sides $map]
    foreach ply [dict get $p plan] {
        if {$ply <= $bookEnd} {
            # In the book: theory, not a verdict. No [%eval] and no variation,
            # because there was no search behind either.
            ::reviewdriver::clearMarks $ply
            catch { sc_move ply $ply }
            set err [::review::writeMove $ply book "" {} $engineName]
            if {$err eq ""} {
                incr written
            } else {
                incr failed
                lappend errors $err
            }
            continue
        }
        # A ply with no verdict was not measured: leave the previous review's
        # comment and marks exactly as they were rather than half-clearing it.
        if {![dict exists $verdicts $ply]} { continue }
        # The previous verdict's marks are ours to replace; the comment tokens
        # go with writeMove below.
        ::reviewdriver::clearMarks $ply
        # clearMarks may have moved to the move before this one to take off a
        # diagram; put the cursor back so the write and its marks land here.
        catch { sc_move ply $ply }
        lassign [dict get $verdicts $ply] label eval_cp
        # Only a move the label says could have been better carries a line: a
        # best/excellent/good move's "variation" would be the next-best line,
        # which is not an improvement and only fills the game.
        set lines {}
        if {[::review::variationWanted $label]} {
            set lines [::reviewdriver::lines $results [expr {$ply - 1}] $mpv]
        }
        set err [::review::writeMove $ply $label $eval_cp $lines $engineName]
        # writeMove writes the comment before it tries the variations. A refused
        # variation returns an error but leaves the verdict comment behind, and
        # that comment must still get the marks it promises.
        # writeMove accumulates variation failures in a list, so the message can
        # arrive braced ({the variation move x was rejected}); look for the text
        # rather than matching the first word.
        set commentLanded [expr {$err eq "" || [string first "the variation" $err] >= 0}]
        if {$commentLanded} {
            # The mark beside the word, and a diagram where the mistake was
            # played. writeMove leaves the cursor where it found it, which is
            # this move. AddNag has a fixed capacity and sc_pos ignores its
            # refusal, so the mark is read back: a comment without the mark it
            # promises is a partial write, not a clean one.
            catch { sc_move ply $ply }
            set markErr {}
            # A move mark the user put there is theirs: AddNag would replace
            # it in place, so only write ours when the move has none (the one a
            # previous review wrote has just been taken off by clearMarks).
            set nag [::review::nagForLabel $label]
            if {$nag ne "" && ![::review::hasMoveNag]} {
                catch { ::review::addNagIfAbsent $nag }
                if {[lsearch -exact [::review::nags] $nag] < 0} {
                    lappend markErr "ply $ply: no room for the $nag mark"
                }
            }
            # The position assessment, from the same score the [%eval] shows.
            # It belongs beside a move the review marks, not on every move: it
            # is the second symbol that says which side stands better, and on a
            # quiet move it is noise. An assessment already there is replaced:
            # it belongs to the score this verdict is replacing.
            set assess ""
            if {$nag ne ""} { set assess [::review::assessmentNag $eval_cp] }
            if {$assess ne ""} {
                catch { ::review::setAssessment $assess }
                if {[lsearch -exact [::review::nags] $assess] < 0} {
                    lappend markErr "ply $ply: no room for the $assess assessment"
                }
            } else {
                # A quiet verdict carries no assessment. One already on the move
                # - a user's, or a mark whose label token has since gone - would
                # contradict the [%eval] just written, and it would disappear on
                # the next run when the label is there to identify it. Take it
                # off now so the first and second run agree.
                catch { ::review::dropAssessment }
            }
            # A first move has no predecessor to hang D on (::review::setDiagram
            # refuses ply < 2), so there is nothing to verify and nothing to
            # report: it is not a capacity failure.
            if {$diagram && $ply >= 2 && ($label eq "mistake" || $label eq "blunder")} {
                catch { ::review::setDiagram $ply 1 }
                if {[catch { sc_move ply [expr {$ply - 1}] }] ||
                    [lsearch -exact [::review::nags] D] < 0} {
                    lappend markErr "ply $ply: no room for the diagram mark"
                }
            }
            # The tactical-exercise marks are Review Settings' own, and the same
            # helper writes them for the annotate pass and the Game List batch.
            # The D mark above may have left the cursor on the previous move, so
            # put it back before the exercise reads the position. The verdict is
            # the full judge record (verdicts keeps only the written pair), and
            # it is needed only for a move the label already marks ? or ??.
            if {($nag eq "?" || $nag eq "??")
                && [llength [info commands ::reviewannotate::writeTactical]]} {
                if {[catch {
                    sc_move ply $ply
                    set verdict [::reviewdriver::judge $map $results $sides $ply]
                    if {$verdict ne ""} {
                        set mover ""
                        catch { set mover [dict get $sides [expr {$ply - 1}]] }
                        if {$mover eq ""} { set mover w }
                        ::reviewannotate::writeTactical $ply $verdict $mover \
                            $results $mpv $nag
                    }
                } ex]} {
                    lappend markErr "ply $ply: $ex"
                }
            }
            foreach e $markErr { lappend errors $e }
            if {$err ne ""} { lappend errors $err }
            if {[llength $markErr] || $err ne ""} {
                incr failed
            } else {
                incr written
            }
        } else {
            incr failed
            lappend errors $err
        }
    }
    # A whole-game pass is the only one that owns the game's tags. Move Comment
    # names one ply (report 0), and the Game List batch hands the writer a
    # hand-built pass without `report`, so the plan is the fallback: a plan that
    # covers every ply is a whole-game pass. An explicit report 0 stays 0.
    set hasReport [dict exists $p report]
    set isReport 0
    if {$hasReport} { catch { set isReport [dict get $p report] } }
    set wholeGame $isReport
    if {!$hasReport} {
        set mapPlies 0
        catch { set mapPlies [dict get $map plies] }
        set planPlies 0
        catch { set planPlies [llength [dict get $p plan]] }
        if {$mapPlies > 0 && $planPlies >= $mapPlies} { set wholeGame 1 }
    }
    # The opening-errors entry is Review Settings' own: write it from the same
    # helper the annotate pass uses, at the ply the opening book ended.
    if {$wholeGame && [llength [info commands ::reviewannotate::openingMark]]} {
        catch { ::reviewannotate::openingMark $p }
    }
    # A whole-game review records what produced it. Move Comment names one ply
    # (report 0) and the classic annotate pass has its own tag; both keep their
    # hands off it. The model is part of the record when coach prose was asked
    # for and a provider was configured, whether or not a later request failed:
    # the tag says what was used, not what answered.
    set coachOn 0
    catch { set coachOn [dict get $p coach] }
    if {$engineName ne "" && $isReport && $written > 0} {
        catch { ::review::appendAnnotator [::review::annotatorRecord $engineName $coachOn] }
    }
    # The deterministic report belongs to the pass, not to a caller: it is
    # written once, from the same results, after the moves are in the game.
    # ::reviewreport::write returns at once for a pass that asked for no report
    # (Move Comment names one ply), so this is the whole-game switch.
    if {[llength [info commands ::reviewreport::write]]} {
        catch { ::reviewreport::write $p $results }
    }
    # The counts, not the state: runDone owns the status dict, so a -writer that
    # is not this proc reports in the same vocabulary.
    return [dict create written $written failed $failed errors $errors]
}

# Write a variation line, one node at a time, ascending, from the verdicts the
# search produced. The node-local twin of writeResults' loop, and the only writer
# a variation pass reaches.
#
# ::review::writeNode stands on the node by route, so the verdict lands on the
# variation move at that index and the main-line move at the same ply is not
# touched. It also writes the marks beside the verdict - the label's NAG only
# when the move has none, the assessment from the same score the [%eval] shows,
# and D on the move before, at index-1 - all with the cursor on the node. They
# are deliberately not written again from here: ::review::addNag,
# ::review::setAssessment and ::review::setDiagram address a move with
# sc_move ply, which walks the main line.
#
# There is no tactical write either. ::reviewannotate::writeTactical sets the
# database game flag T and navigates by ply: it describes a whole game's
# exercise, and it is the main-line writer's to call.
#
# Nothing after writeResults' loop is reached on this path, and the report,
# opening mark, Annotator tag and coach are off in ::reviewdriver::run for the
# same reason one level up: ::reviewreport::collect and ::reviewcoach::place /
# clear read $p map and $p plan through sc_move ply and describe the whole game -
# feeding them a variation map would write the main-line report from the wrong
# nodes.
#
# The cursor is left where it was found on every path by ::review::visitLine, and
# ::reviewdriver::restoreRun remains the single restore: a node that is no longer
# where the map said writes nothing further and leaves the board on the base ply,
# which is what cursorRestore falls back to when the line has gone.
proc ::reviewdriver::writeLine {p results} {
    set map [dict get $p map]
    set mpv 0
    catch { set mpv [dict get $p mpv] }
    set written 0
    set failed 0
    set errors {}
    set engineName ""
    catch { set engineName [lindex [dict get $p engine] 0] }
    set verdicts [::reviewdriver::verdicts $map $results]
    foreach i [dict get $p plan] {
        # The previous verdict's marks on this node are ours to replace; the
        # comment tokens go with writeNode. clearMarksAt reads the label from the
        # map, so an unlabelled node costs no walk.
        catch { ::review::clearMarksAt $map $i }
        # A node with no verdict was not measured: leave the previous review's
        # comment and marks exactly as they were rather than half-clearing it.
        if {![dict exists $verdicts $i]} { continue }
        lassign [dict get $verdicts $i] label eval_cp
        # Only a move the label says could have been better carries a line: a
        # best/excellent/good move's "variation" would be the next-best line.
        set lines {}
        if {[::review::variationWanted $label]} {
            set lines [::reviewdriver::lines $results [expr {$i - 1}] $mpv]
        }
        set err [::review::writeNode $map $i $label $eval_cp $lines $engineName]
        if {$err eq ""} {
            incr written
            continue
        }
        # writeNode answers with a list of reasons: one move's verdict can land
        # while its alternatives are refused, and each reason is kept as its own
        # entry in the count (the same vocabulary writeResults reports in).
        incr failed
        set stale 0
        foreach why $err {
            lappend errors $why
            # The line is not the one the map described - an anchor renumbered
            # under the write - so this node cannot be addressed, and neither can
            # any node after it on the same line: nothing further is written.
            if {[string first "is not on this line" $why] >= 0} { set stale 1 }
        }
        if {$stale} { break }
    }
    return [dict create written $written failed $failed errors $errors]
}

# Put the cursor back and say whether it landed exactly. Never raises: a restore
# that could not be verified leaves the board on a known position.
proc ::reviewdriver::restoreRun {p} {
    variable state
    # cursorRestore's own answer, not a loc/level comparison: a game that changed
    # while the pass ran can put the same ply on a different position, and only
    # the FEN check inside cursorRestore tells the two apart. 1 is exact, 0 is a
    # known fallback, -1 an unknown one.
    set restored 0
    catch { set restored [::review::cursorRestore [dict get $p cursor]] }
    if {![string is integer -strict $restored] || $restored != 1} {
        set restored 0
    }
    dict set state restored $restored
    return $restored
}

# Tell the board the game text changed, when the caller asked for it. The driver
# itself has no Tk, so a missing notification is a no-op.
proc ::reviewdriver::notifyBoard {p} {
    if {[dict get $p notify] && [llength [info commands ::notify::PosChanged]]} {
        # -pgn, not "": the write phase changed comments and variations across
        # the whole game, so the game text has to be regenerated. An empty
        # argument only refreshes the current move, which left the review
        # invisible in the PGN pane until something else redrew it.
        catch { ::notify::PosChanged -pgn }
    }
    return
}

# The end of a run: the cursor goes back once, unless the caller says the game
# has gone, and the board is told the game changed when the caller asked for it.
# `restore 0` is for a run that already put the reader back before the coach
# started: moving them again would drag a board they have since browsed back to
# where the pass began.
#
# The caller's completion hook fires last, with the run's status: it is the only
# point at which a chained run (annotate mode's batch) knows the game it just
# searched has been written.
proc ::reviewdriver::endRun {p {restore 1}} {
    variable pass
    set pass {}
    # The progress pane is decoration over this run: when the run ends, the
    # window says so and falls back to the pane's position rather than leaving
    # the last position of a pass that is over on screen.
    if {[dict exists $p progressToken]} {
        catch { ::reviewprogress::finish [dict get $p progressToken] }
    }
    if {$restore} { ::reviewdriver::restoreRun $p }
    ::reviewdriver::notifyBoard $p
    ::reviewdriver::runDoneHook $p
}
