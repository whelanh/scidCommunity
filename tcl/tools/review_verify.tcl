# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_verify.tcl -- the second opinion on the two labels a reader trusts.
#
# The label ladder (tcl/tools/move_labels.tcl) can call a move Brilliant or
# Great from one engine's search. Those are the two labels a reader will look
# at, and a label re-confirmed by the engine that produced it proves nothing: a
# second engine re-searches only those candidate positions, under the pass's own
# depth floor and time ceiling, so a capped review stays capped in its second
# opinion too.
#
# Where the verification plugs in matters more than what it computes. The
# verifier feeds the verdicts; it does not run inside the write (issue #380).
# ::reviewdriver::run is plan -> search -> verdicts -> write, and the batch
# annotator and Rapid Annotate call ::reviewdriver::writeResults directly,
# skipping run - so a hook on run would leave both of them without a verifier.
# The seam is therefore ::reviewdriver::verified, the one named transform every
# writer calls before it writes, and this file supplies the corrections it folds
# in.
#
# The searches are queued through the driver's own per-position queue
# (::reviewdriver::start, the pass's connection): never on a UI engine, never on
# the caller's thread with a vwait. A missing, misconfigured or failing verifier
# is a skipped verification, never a failed review - the labels are then written
# exactly as the search produced them, with no upgrade and no downgrade.
#
# Re-derived from the verifier on the review-coach-prototype branch (5556eb44),
# which is a design reference and not a merge candidate (#404). The prototype's
# shape - jobs from the labels, a pure corrections step, a scripted second engine
# - is what was taken; the details differ where this tree does: the searches go
# through ::reviewdriver::start rather than ::engineNoWin, and a verification
# that finds no usable evidence changes nothing (the prototype downgraded on an
# empty answer, which is a verdict without evidence). Provenance is recorded in
# docs/third-party-notices.md.

namespace eval ::reviewverify {
    # The label the verifier withdraws a move to when the second engine
    # disagrees. Brilliant and Great both sit above Best on the ladder, so Best
    # is the next one down - no new vocabulary, no "unverified" state.
    variable DEMOTION best
    # The gap a Great move needs between the best and the second line, as the
    # ladder measured it (::movelabels::GREAT_GAP). Read from the ladder rather
    # than copied, so the verifier cannot confirm a gap the writer would not
    # have called Great.
    variable GAP ""
    # The search in flight: the token ::reviewdriver::start answered, or "".
    variable token ""
    # Searches waiting for that one connection, oldest first: {cfg jobs mpv lim
    # onDone id}. The batch annotator can finish a second game while the first
    # game's second opinion is still running, and the driver has one connection
    # (id 20) - so the later search waits its turn instead of being skipped, and
    # instead of taking the connection from the search in flight.
    variable queue {}
    # Names for queued searches, so a caller that cancels one can name it.
    variable seq 0
    # The token of the job being answered, so the callback that closes it can
    # clear the module's own state even though ::reviewdriver::finish has already
    # forgotten the job.
    variable answering ""
}

# The Great gap, from the ladder. A separate proc so a test can pin it without
# reaching into ::movelabels' variable, and so a tree whose ladder has no such
# variable cannot make this module throw.
proc ::reviewverify::greatGap {} {
    variable GAP
    if {$GAP eq ""} {
        set GAP 200
        catch { set GAP $::movelabels::GREAT_GAP }
    }
    return $GAP
}

# The first move of a MultiPV line dict, or "" when the slot is empty.
proc ::reviewverify::topMove {lines} {
    if {![dict exists $lines 1]} { return "" }
    set pv [lindex [dict get $lines 1] 3]
    return [lindex $pv 0]
}

# The positions the verifier has to re-search, one job per Brilliant/Great move.
#
# Pure: `labels` is the ply -> label map the pass decided, `results` the engine
# lines it decided them from. A job is {ply k spec best label}, where k is the
# reference position (the one before the move), spec is that position in the
# form ::engine::send Go takes, and best is the move the analysis engine
# preferred there - the second engine has to agree with that move, so the job
# carries it rather than re-deriving it.
#
# Book wins: a move inside the opening is theory, and it is written as Book
# whether or not a second engine would call it something else (#377). The caller
# that names plies (-plies, Move Comment) passes bookEnd 0, so a book move the
# reader asked about is still verified.
proc ::reviewverify::jobs {map results labels bookEnd} {
    set out {}
    if {![string is integer -strict $bookEnd]} { set bookEnd 0 }
    foreach ply [lsort -integer [dict keys $labels]] {
        if {![string is integer -strict $ply]} { continue }
        set label [dict get $labels $ply]
        if {[lsearch -exact {brilliant great} $label] < 0} { continue }
        if {$bookEnd > 0 && $ply <= $bookEnd} { continue }
        set k [expr {$ply - 1}]
        set spec ""
        catch { set spec [dict get [dict get $map positions] $k] }
        if {[string trim $spec] eq ""} { continue }
        set best ""
        catch { set best [::reviewverify::topMove [dict get $results $k]] }
        if {$best eq ""} { continue }
        lappend out [list $ply $k $spec $best $label]
    }
    return $out
}

# Which labels the verifier withdraws, from the answers it collected.
#
# Pure: jobs plus the verifier's results in, a ply -> label dict out. A label
# only ever moves down, to ::reviewverify::DEMOTION; there is no path here that
# raises one, so a verifier can never talk a search into a better word.
#
# Fail closed, per position: a position the verifier did not answer, or answered
# with nothing usable, leaves the label exactly as the search produced it. The
# rule is that a verifier must never upgrade on absent evidence - and never
# downgrade either, because "no answer" is not a disagreement. A position it did
# answer is judged on that answer: a different best move disagrees, and a Great
# move whose two lines are closer than the ladder's gap no longer qualifies.
proc ::reviewverify::corrections {jobs vres} {
    variable DEMOTION
    set out [dict create]
    foreach job $jobs {
        lassign $job ply k spec best label
        if {![dict exists $vres $k]} { continue }
        set lines [dict get $vres $k]
        if {![dict exists $lines 1]} { continue }
        set top [::reviewverify::topMove $lines]
        if {$top eq ""} { continue }
        set down [expr {$top ne $best}]
        if {!$down && $label eq "great"} {
            set cp1 [::reviewdriver::lineScore [dict get $lines 1]]
            set cp2 ""
            if {[dict exists $lines 2]} {
                set cp2 [::reviewdriver::lineScore [dict get $lines 2]]
            }
            if {$cp1 eq "" || $cp2 eq ""} {
                # The gap is the whole claim and this search did not measure it:
                # no evidence, no correction.
                continue
            }
            if {($cp1 - $cp2) < [::reviewverify::greatGap]} { set down 1 }
        }
        if {$down} { dict set out $ply $DEMOTION }
    }
    return $out
}

# Re-search the candidates on the driver's own connection and answer the
# corrections through `onDone`.
#
# Answers the token ::reviewdriver::start gave, or "" when there is nothing to
# do (no jobs, no engine, an XBoard preset that would never answer the UCI
# handshake) - the caller writes the review itself in that case. Never raises: a
# verifier that cannot start is a skipped verification.
proc ::reviewverify::start {enginecfg jobs mpv lim onDone} {
    variable queue
    variable seq
    if {![llength $jobs]} { return "" }
    if {[llength $enginecfg] < 8} { return "" }
    if {[lindex $enginecfg 0] eq ""} { return "" }
    # A verifier is a UCI engine like the analysis pass; an XBoard preset would
    # never answer the handshake and the write would wait forever.
    if {[lindex $enginecfg 7] eq "" || [lindex $enginecfg 7] eq 0} { return "" }
    if {![string is integer -strict $mpv] || $mpv < 2} { set mpv 2 }
    # The driver has one connection and one queue on it. A caller that arrives
    # while it is busy waits its turn: the batch annotator finishing a second
    # game before the first game's second opinion has answered must not take the
    # connection from the search in flight, and must not be skipped either - the
    # card that made this a shared seam exists because the batch has to get it.
    if {[::reviewdriver::busy $::reviewdriver::ENGINE_ID]} {
        incr seq
        set id "verifyq$seq"
        lappend queue [list $enginecfg $jobs $mpv $lim $onDone $id]
        return $id
    }
    return [::reviewverify::begin $enginecfg $jobs $mpv $lim $onDone]
}

# Start one search on the driver's connection. The caller has already decided
# that there is something to search and that the connection is free; this is the
# part that talks to the driver, and the one place a queued search enters too.
proc ::reviewverify::begin {enginecfg jobs mpv lim onDone} {
    variable token
    set positions {}
    foreach job $jobs {
        lappend positions [list [lindex $job 1] [lindex $job 2]]
    }
    set started ""
    set previous $token
    if {[catch {
        # The driver's own queue, on the driver's own connection: the same
        # per-position machinery the pass uses, so there is one place that
        # decides how an engine is opened, configured, fed and closed.
        set started [::reviewdriver::start $enginecfg $positions $mpv $lim \
            "" [list ::reviewverify::answer $jobs $onDone]]
    } err]} {
        set token $previous
        return ""
    }
    set token $started
    return $started
}

# The next queued search, once the connection is free. Queued from the answer
# (the driver's close is already queued ahead of it, so the connection is gone by
# the time this runs) and from a cancel.
proc ::reviewverify::advance {} {
    variable queue
    variable token
    if {![llength $queue]} { return }
    if {$token ne ""} { return }
    if {[::reviewdriver::busy $::reviewdriver::ENGINE_ID]} { return }
    set item [lindex $queue 0]
    set queue [lrange $queue 1 end]
    lassign $item enginecfg jobs mpv lim onDone id
    if {[::reviewverify::begin $enginecfg $jobs $mpv $lim $onDone] eq ""} {
        # It cannot start after all. The caller's write still has to happen,
        # with no corrections, exactly as a verifier that never opened.
        catch { {*}$onDone [dict create] }
    }
    return
}

# The queue finished (or the engine was lost): work out the corrections and hand
# them back. Runs inside the engine's reply, so nothing here closes the engine -
# ::reviewdriver::finish has already queued that.
proc ::reviewverify::answer {jobs onDone vres} {
    variable token
    variable answering
    set answering $token
    set token ""
    set corrections [::reviewverify::corrections $jobs $vres]
    if {$onDone ne ""} { catch { {*}$onDone $corrections } }
    # The next caller waiting for this one connection goes now: the driver
    # queued the close before this callback ran, so the connection is free.
    after idle ::reviewverify::advance
    return $corrections
}

# Is a verification search in flight?
proc ::reviewverify::active {} {
    variable token
    return [expr {$token ne ""}]
}

# Drop the search. What has already been answered is not written: a cancelled
# verification belongs to a cancelled run, and the callback it would have called
# writes nothing.
proc ::reviewverify::stop {} {
    variable token
    variable queue
    set was $token
    # A queued search is cancelled by taking it out of the queue; the search in
    # flight by stopping the driver's job. Whatever else is queued stays: it
    # belongs to another caller's write, which would otherwise never happen.
    if {[string match "verifyq*" $was]} {
        set kept {}
        set dropped 0
        foreach item $queue {
            if {!$dropped && [lindex $item 5] eq $was} { set dropped 1 ; continue }
            lappend kept $item
        }
        set queue $kept
        return $dropped
    }
    set token ""
    if {$was ne ""} { catch { ::reviewdriver::stop $was 0 } }
    # The connection is free now (or will be once the driver's close runs).
    if {$was ne ""} { after idle ::reviewverify::advance }
    return [expr {$was ne ""}]
}
