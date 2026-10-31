# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_verify.tcl -- the second opinion on Brilliant and Great.
#
# The label ladder can call a move Brilliant or Great from one engine's lines.
# Those are the two labels a reader will look at, so a different engine
# re-searches only those candidate positions. It runs under the pass's own
# limits - the same depth floor and time ceiling - so a capped review stays
# capped in its second opinion too. If it disagrees about the best move, or a
# Great move's gap to the second line is not there, the move falls back to Best.
#
# The verifier never runs on the analysis engine: a second engine is the point.
# It is off unless Review Settings names one.

# The Go builder is shared with the review pass and the engine window. Load it
# when the caller has not, so the verifier can be driven from a tclsh harness.
if {[llength [info commands ::enginelimits::goLimits]] == 0} {
    set limitFiles {}
    catch { lappend limitFiles [file join $::scidTclDir tools engine_limits.tcl] }
    lappend limitFiles [file join [file dirname [info script]] engine_limits.tcl]
    foreach f $limitFiles {
        if {[file exists $f]} { catch { source -encoding utf-8 $f } ; break }
    }
    unset -nocomplain limitFiles
}

namespace eval ::reviewverify {
    variable id reviewVerify
    variable job
}

# The first move of a MultiPV line dict, or "".
proc ::reviewverify::topMove {lines} {
    if {![dict exists $lines 1]} { return "" }
    set line [dict get $lines 1]
    set pv [lindex $line 3]
    return [lindex $pv 0]
}

# Work out which positions to re-search from the labels the pass produced.
proc ::reviewverify::jobs {map results labels} {
    set out {}
    foreach ply [lsort -integer [dict keys $labels]] {
        set label [dict get $labels $ply]
        if {[lsearch -exact {brilliant great} $label] < 0} { continue }
        set k [expr {$ply - 1}]
        set spec ""
        catch { set spec [dict get [dict get $map positions] $k] }
        if {$spec eq ""} { continue }
        set best ""
        catch { set best [topMove [dict get $results $k]] }
        lappend out [list $ply $k $spec $best $label]
    }
    return $out
}

# The labels the verifier withdraws, from its results. Pure: jobs + verifier
# lines in, corrections dict out.
proc ::reviewverify::corrections {jobs vres} {
    set out [dict create]
    foreach job $jobs {
        lassign $job ply k spec best label
        set lines ""
        catch { set lines [dict get $vres $k] }
        set down 0
        if {$lines eq ""} {
            set down 1
        } else {
            set top [topMove $lines]
            if {$top eq "" || $best eq "" || $top ne $best} { set down 1 }
            if {!$down && $label eq "great"} {
                set cp1 ""
                set cp2 ""
                catch { set cp1 [::reviewdriver::lineScore [dict get $lines 1]] }
                catch { set cp2 [::reviewdriver::lineScore [dict get $lines 2]] }
                if {$cp1 eq "" || $cp2 eq "" || ($cp1 - $cp2) < 200} { set down 1 }
            }
        }
        if {$down} { dict set out $ply best }
    }
    return $out
}

# Re-search the candidates and answer the corrections through `onDone`.
# A missing/broken verifier is a skipped verification, never a failed review.
proc ::reviewverify::start {enginecfg map results labels lim onDone} {
    variable id
    variable job
    set jobs [jobs $map $results $labels]
    # No candidates (or no engine) is "nothing to verify", not a callback:
    # the caller writes the review itself when start answers 0.
    if {![llength $jobs]} { return 0 }
    set name [lindex $enginecfg 0]
    if {$name eq ""} { return 0 }
    # A verifier is a UCI engine like the analysis pass; an XBoard preset would
    # never answer the handshake.
    if {[lindex $enginecfg 7] eq "" || [lindex $enginecfg 7] eq 0} { return 0 }
    set job [dict create onDone $onDone jobs $jobs index 0 results {} lines {} \
        limits $lim]
    dict set job watch [after 240000 [list ::reviewverify::timeout]]
    if {[catch {
        ::engineNoWin::initEngine $id $name [list ::reviewverify::message]
    }]} {
        catch { after cancel [dict get $job watch] }
        set job {}
        return 0
    }
    ::engine::send $id SetOptions [list [list MultiPV 3]]
    ::reviewverify::next
    return 1
}

proc ::reviewverify::next {} {
    variable id
    variable job
    if {![dict size $job]} { return }
    set jobs [dict get $job jobs]
    set i [dict get $job index]
    if {$i >= [llength $jobs]} {
        set out [corrections $jobs [dict get $job results]]
        set cb [dict get $job onDone]
        catch { after cancel [dict get $job watch] }
        set job {}
        catch { ::engineNoWin::closeEngine $id }
        {*}$cb $out
        return
    }
    lassign [lindex $jobs $i] ply k spec best label
    catch { after cancel [dict get $job watch] }
    dict set job watch [after 240000 [list ::reviewverify::timeout]]
    # Both bounds in one Go, exactly as the review pass sends them: the verifier
    # is a second opinion, not a deeper search, so it must not outrun the cap.
    ::engine::send $id Go [list $spec [::enginelimits::goLimits [dict get $job limits]]]
    return
}

proc ::reviewverify::message {msg} {
    variable job
    if {![dict size $job]} { return }
    lassign $msg type data
    switch -- $type {
        InfoPV {
            ::reviewverify::collect $data
        }
        InfoBestMove {
            set jobs [dict get $job jobs]
            lassign [lindex $jobs [dict get $job index]] ply k spec best label
            dict set job results $k [dict get $job lines]
            dict set job lines {}
            dict incr job index
            ::reviewverify::next
        }
        InfoDisconnected {
            set cb [dict get $job onDone]
            catch { after cancel [dict get $job watch] }
            set job {}
            catch { ::engineNoWin::closeEngine $::reviewverify::id }
            {*}$cb [dict create]
        }
    }
    return
}

proc ::reviewverify::collect {data} {
    variable job
    lassign $data multipv depth seldepth nodes nps hashfull tbhits time \
        score score_type score_wdl pv
    if {$multipv eq "" || $score eq "" || $pv eq ""} { return }
    if {[lsearch -exact {cp mate} $score_type] < 0} { return }
    set lines [dict get $job lines]
    if {[dict exists $lines $multipv] &&
        [lindex [dict get $lines $multipv] 0] >= $depth} { return }
    dict set lines $multipv [list $depth $score $score_type $pv]
    dict set job lines $lines
    return
}

proc ::reviewverify::timeout {} {
    variable id
    variable job
    if {![dict size $job]} { return }
    set cb [dict get $job onDone]
    set job {}
    catch { ::engine::send $id StopGo }
    catch { ::engineNoWin::closeEngine $id }
    {*}$cb [dict create]
    return
}

proc ::reviewverify::stop {} {
    variable id
    variable job
    if {[dict size $job]} {
        catch { after cancel [dict get $job watch] }
        set job {}
        catch { ::engine::send $id StopGo }
        catch { ::engineNoWin::closeEngine $id }
    }
    return
}
