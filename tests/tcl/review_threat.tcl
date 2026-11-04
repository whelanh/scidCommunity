#!/usr/bin/env tclsh
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_threat.tcl -- the "What's the threat?" probe without a board.
#
#   tclsh tests/tcl/review_threat.tcl
#
# The probe is three decisions: one short search on a connection of its own, the
# deterministic facts that answer the question from the position, and one
# sentence of prose the model may add. The answer is the facts; the prose is an
# enrichment that may be absent, so "no model configured" is a state and not a
# failure.
#
# The engine is stubbed here, except for the close path: that one drives the real
# ::engine::reply over a real (pipe) channel, because the whole point of a
# one-shot connection is that closing it inside the reply must not leave the
# reply walking state ::engine::destroy_ has already unset.

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

# A tclsh harness has no options array, no language files and no C moves: each
# stand-in answers the way the real command would in the one place the probe
# calls it.
proc options.store {varname {default ""}} {
    if {![info exists $varname]} { set $varname $default }
}
proc tr {tag} { return $tag }

# sc_pos is the board's own SAN conversion (tcl/tools/comment_facts.tcl uses the
# same command). The harness answers coordToSAN from a table, so what is checked
# is that the probe carries the SAN of the engine's move, not that SAN itself is
# spelled correctly - that is the C command's job.
array set ::SAN {
    a1a8  {Ra8#}
    c4e5  {Ne5}
    e2e4  {e4}
}
set ::stubFen {6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1}
proc sc_pos {sub args} {
    switch -- $sub {
        fen      { return $::stubFen }
        location { return 0 }
        coordToSAN {
            set uci [lindex $args 1]
            if {[info exists ::SAN($uci)]} { return [list $::SAN($uci)] }
            return [list $uci]
        }
    }
    return ""
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools comment_facts.tcl]
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl enginecomm.tcl]
source [file join $root tcl tools enginenowin.tcl]
source [file join $root tcl tools review_threat.tcl]

# The search asks the review for its time cap. The stub is the shape
# ::review::effective returns; the probe must take the cap and its own depth.
namespace eval ::review {}
proc ::review::effective {cfg} {
    return [dict create threads {} hash {} mpv 2 depth 18 movetime 900]
}

puts "\nthe threat, from the position"

# A back-rank mate: the answer names the move in SAN, says it is mate, and never
# echoes the engine's coordinates.
set mateFen {6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1}
set mate [::reviewthreat::answer $mateFen a1a8]
checkEq "the side to move is White" [dict get $mate side] White
checkEq "the move is named in SAN" [dict get $mate san] {Ra8#}
check "the answer names the threat in SAN" \
    [expr {[string first "Ra8#" [dict get $mate text]] >= 0}]
check "a mating move is a threat" [dict get $mate forcing]
check "the mate is stated" \
    [expr {[string first "checkmate" [dict get $mate text]] >= 0}]
check "the answer never spells the move in coordinates" \
    [expr {[string first "a1a8" [dict get $mate text]] < 0}]

# A fork: the knight lands on a square that attacks the queen (undefended) and
# the pawn on f7, which the rook on f8 defends. The queen is a threat; the
# defended pawn is not a hanging piece and must not be called one.
set forkFen {5r1k/3q1p2/8/8/2N5/8/8/4K3 w - - 0 1}
set fork [::reviewthreat::answer $forkFen c4e5]
checkEq "the fork is named in SAN" [dict get $fork san] {Ne5}
check "a fork is a threat" [dict get $fork forcing]
check "the fork names the piece it wins" \
    [expr {[string first "queen" [dict get $fork text]] >= 0}]
check "a defended piece is not called hanging" \
    [expr {[string first "pawn" [dict get $fork text]] < 0}]
check "the fork answer never spells the move in coordinates" \
    [expr {[string first "c4e5" [dict get $fork text]] < 0}]

# A quiet best move is still the strongest move, but calling it a threat is
# wrong: the answer says there is no immediate threat, deterministically.
set quietFen {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}
set quiet [::reviewthreat::answer $quietFen e2e4]
check "a pawn push is not forcing" [expr {![dict get $quiet forcing]}]
check "the quiet answer says there is no immediate threat" \
    [expr {[string first "no immediate threat" [dict get $quiet text]] >= 0}]
check "and names no threat it cannot prove" \
    [expr {[string first "threatens" [dict get $quiet text]] < 0}]
check "and still names the strongest move in SAN" \
    [expr {[string first "e4" [dict get $quiet text]] >= 0}]
checkEq "black is named from the FEN" \
    [::reviewthreat::sideName {4k3/8/8/8/8/8/8/4K3 b - - 0 1}] Black

puts "\nthe facts the model reads"

set block [::reviewthreat::factsBlock $mateFen a1a8]
foreach want {white\ is\ to\ move castling: en\ passant: fifty-move\ rule: {The strongest move:}} {
    check "the block carries $want" [expr {[string first $want $block] >= 0}]
}
check "the block never spells the move in coordinates" \
    [expr {[string first "a1a8" $block] < 0}]
set quietBlock [::reviewthreat::factsBlock $quietFen e2e4]
check "a quiet block says the strongest move is not forcing" \
    [expr {[string first "not forcing" $quietBlock] >= 0}]

set p [::reviewthreat::prompt White $block]
check "the prompt names the side" [expr {[string first "White" $p] >= 0}]
check "and carries the facts last" [expr {[string first $block $p] > 0}]
check "and asks for one sentence" [expr {[string first "ONE sentence" $p] >= 0}]
check "and forbids coordinates" [expr {[string first "coordinates" $p] >= 0}]

puts "\nthe engine search"

# The one-shot connection: ::engineNoWin opens it, the probe sends one Go, and
# the reply carries the move back. A pipe channel stands in for the process, so
# the close path is real while nothing is ever written to an engine.
namespace eval ::engineNoWin {}
set ::opened {}
set ::closes 0
proc ::engineNoWin::initEngine {id name cb} {
    lappend ::opened [list $id $name]
    lassign [chan pipe] r w
    set ::fakeWrite $w
    ::engine::init_ $id $r $cb
    # A network connection never writes a "quit" on close: the channel is a
    # pipe, and the path under test is the close, not the protocol.
    set ::engconn(protocol_$id) network
    set ::engconn(logRecv_$id) {}
    set ::engconn(logSend_$id) {}
    return 1
}
# Count the closes, and keep the real close underneath: the test asserts that a
# one-shot probe closes once, not that close is called once for every reason.
rename ::engine::close ::engine::close_
proc ::engine::close {id} {
    incr ::closes
    uplevel 1 [list ::engine::close_ $id]
}
set ::lastGo {}
proc ::engine::send {id msg {data ""}} {
    if {$msg eq "Go"} {
        set ::lastGo $data
        after 0 [list ::engine::reply $id {InfoBestMove {e7e5}}]
    }
    return
}

set ::done 0
set ::threatMove untouched
set ::threatErr untouched
set err [::reviewthreat::search [list "Engine A" /bin/true {} {} 0 0 {} 1 {} {}] \
    {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1} \
    [list apply {{move e} {set ::threatMove $move ; set ::threatErr $e ; set ::done 1}}]]
checkEq "the search starts without an error" $err ""
# A bounded wait: a probe that never replies must fail a check, not hang the
# harness.
set watchdog [after 5000 {set ::done 1}]
if {!$::done} { vwait ::done }
catch { after cancel $watchdog }
checkEq "the engine's move comes back" $::threatMove e7e5
checkEq "without an error" $::threatErr ""
checkEq "the engine was opened for this probe" [lindex $::opened 0] {reviewThreat {Engine A}}
check "the Go asks for position fen" [expr {[string first "position fen" $::lastGo] >= 0}]
check "at the probe's own quick depth" [expr {[string first "depth 14" $::lastGo] >= 0}]
check "under the review's time cap" [expr {[string first "movetime 900" $::lastGo] >= 0}]
check "not the review's full depth" [expr {[string first "depth 18" $::lastGo] < 0}]

puts "\nthe connection closes in the reply, exactly once"

checkEq "the engine was closed once" $::closes 1
check "and the connection is gone" [expr {![info exists ::engconn(channel_reviewThreat)]}]
# The reply the close happened in has already returned; a second one is a late
# message the probe no longer has a job for, and it must be a no-op rather than
# a walk over state that is gone.
set late [catch { ::engine::reply reviewThreat {InfoBestMove {e7e5}} } lateErr]
checkEq "a late reply after the close does not error" $late 0
check "and does not close anything a second time" [expr {$::closes == 1}]
check "the job is finished" [expr {![dict size $::reviewthreat::job]}]

puts "\nno engine means no search"

checkEq "a non-UCI preset is refused in words" \
    [::reviewthreat::search [list "Engine A" /bin/true {} {} 0 0 {} 0 {} {}] \
        {8/8/8/8/8/8/8/K6k w - - 0 1} {list}] \
    "the threat probe needs a UCI engine"
checkEq "and a missing preset is refused in words" \
    [::reviewthreat::search {} {8/8/8/8/8/8/8/K6k w - - 0 1} {list}] \
    "no UCI engine is configured"

puts "\nthe deterministic answer is the whole answer"

set ::boxes {}
proc tk_messageBox {args} {
    lappend ::boxes [dict get $args -message]
    return ok
}
namespace eval ::auto_comment {}
set ::providerWhy "no model configured"
proc ::auto_comment::providerReady {} { return $::providerWhy }
set ::askedPrompt ""
set ::askedMax ""
proc ::auto_comment::queryAsync {prompt max cb} {
    set ::askedPrompt $prompt
    set ::askedMax $max
    after 0 [list apply {{callback} {
        {*}$callback "White's rook takes the back rank and it is mate."
        set ::proseDone 1
    }} $cb]
    return t1
}

# No provider: the box is exactly the deterministic answer, not a stub of it.
::reviewthreat::ready $mateFen "" a1a8 ""
checkEq "with no model the box is the deterministic answer" \
    [lindex $::boxes end] [dict get $mate text]

# With a provider the facts still lead; the prose is added after them.
set ::providerWhy ""
set ::proseDone 0
::reviewthreat::ready $mateFen "" a1a8 ""
set watchdog [after 5000 {set ::proseDone 1}]
if {!$::proseDone} { vwait ::proseDone }
catch { after cancel $watchdog }
set msg [lindex $::boxes end]
check "with a model the facts still lead" \
    [expr {[string first [dict get $mate text] $msg] == 0}] "got '$msg'"
check "and the prose follows them" [expr {[string first "back rank" $msg] > 0}]
check "the prompt asked for one sentence" [expr {[string first "ONE sentence" $::askedPrompt] >= 0}]
check "at a short answer length" [expr {$::askedMax > 0 && $::askedMax <= 300}]

# What the box says when the search cannot answer at all.
set before [llength $::boxes]
::reviewthreat::ready $mateFen "" "" "the threat search timed out"
check "a failed search says so, and what failed" \
    [expr {[string first "the threat search timed out" [lindex $::boxes end]] >= 0}]
::reviewthreat::ready $mateFen "" 0000 ""
check "no move at all means nothing forcing" \
    [expr {[string first "nothing forcing" [lindex $::boxes end]] >= 0}]
checkEq "two more boxes, one per case" [expr {[llength $::boxes] - $before}] 2

puts "\nwhat the menu entry asks for"

# ask: no engine configured, and a board with no position.
proc ::reviewthreat::defaultEngine {} { return "" }
set before [llength $::boxes]
::reviewthreat::ask ""
check "ask with no engine says what to do about it" \
    [expr {[string first "Tools -> Engine List" [lindex $::boxes end]] >= 0}]
set ::stubFen ""
::reviewthreat::ask [list "Engine A" /bin/true {} {} 0 0 {} 1 {} {}]
check "ask with no position says there is nothing to look at" \
    [expr {[string first "no position" [lindex $::boxes end]] >= 0}]
checkEq "one box per refusal" [expr {[llength $::boxes] - $before}] 2

puts ""
puts "$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
