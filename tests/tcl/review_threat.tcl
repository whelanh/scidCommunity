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
#
# It is also the small board the Q1 checks need: a ply the reader is on, a
# position at each ply, and the comment each move carries.
array set ::SAN {
    a1a8  {Ra8#}
    c4e5  {Ne5}
    e2e4  {e4}
}
set ::stubFen {6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1}
set ::ply 0
array set ::fenAt {0 {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}}
array set ::comment {}
# What a write would have created outside the comment: the probe must write no
# variation and no NAG, so anything recorded here is a failure.
set ::variations 0
set ::nags 0
proc sc_pos {sub args} {
    switch -- $sub {
        fen      {
            if {[info exists ::fenAt($::ply)]} { return $::fenAt($::ply) }
            return $::stubFen
        }
        location { return $::ply }
        getComment {
            if {[info exists ::comment($::ply)]} { return $::comment($::ply) }
            return ""
        }
        setComment {
            set ::comment($::ply) [lindex $args 0]
            return
        }
        addNag  { incr ::nags ; return }
        coordToSAN {
            set uci [lindex $args 1]
            if {[info exists ::SAN($uci)]} { return [list $::SAN($uci)] }
            return [list $uci]
        }
    }
    return ""
}
# sc_move ply N puts the board on the move, the way the real command walks the
# main line; sc_var is the variation cursor and must not be reached at all.
proc sc_move {sub args} {
    if {$sub eq "ply"} { set ::ply [lindex $args 0] }
    return
}
namespace eval ::notify {}
set ::notifies 0
proc ::notify::PosChanged {args} { incr ::notifies ; return }
set ::gameNumber 1
set ::gameVariant "chess960"
proc sc_game {sub args} {
    if {$sub eq "number"} { return $::gameNumber }
    if {$sub eq "variant"} { return $::gameVariant }
    return ""
}
proc sc_var {args} { incr ::variations ; return 0 }
# The review's cursor save/restore, FEN-checked exactly as game_review.tcl's is:
# the harness records the position and refuses a restore into a different one.
namespace eval ::review {}
proc ::review::cursorSave {} {
    return [dict create loc $::ply fen [sc_pos fen]]
}
proc ::review::cursorRestore {state} {
    set fen ""
    catch { set fen [sc_pos fen] }
    set ::ply [dict get $state loc]
    set back ""
    catch { set back [sc_pos fen] }
    if {[dict get $state fen] ne "" && $back ne [dict get $state fen]} { return 0 }
    return 1
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools comment_facts.tcl]
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl enginecomm.tcl]
source [file join $root tcl tools enginenowin.tcl]
source [file join $root tcl tools review_prose.tcl]
source [file join $root tcl tools review_threat.tcl]

# The search asks the review for its time cap. The stub is the shape
# ::review::effective returns; the probe must take the cap and its own depth.
namespace eval ::review {}
proc ::review::effective {cfg} {
    return [dict create threads 8 hash 512 mpv 2 depth 18 movetime 900]
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
set ::lastOptions {}
proc ::engineNoWin::initEngine {id name cb {options ""}} {
    lappend ::opened [list $id $name]
    set ::lastOptions $options
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
set ::lastNewGame {}
proc ::engine::send {id msg {data ""}} {
    if {$msg eq "NewGame"} { set ::lastNewGame $data }
    if {$msg eq "Go"} {
        set ::lastGo $data
        after 0 [list ::engine::reply $id {InfoBestMove {e7e5}}]
    }
    return
}

set ::done 0
set ::threatMove untouched
set ::threatErr untouched
set preset [list "Engine A" /bin/true {} {} 0 0 {} 1 \
    [list [list Threads 64] [list Hash 110000] [list SyzygyPath /tmp]] {}]
set err [::reviewthreat::search $preset \
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
check "the NewGame carries the variant" \
    [expr {[string first "chess960" $::lastNewGame] >= 0}]
check "the Go asks for position fen" [expr {[string first "position fen" $::lastGo] >= 0}]
check "at the probe's own quick depth" [expr {[string first "depth 14" $::lastGo] >= 0}]
check "under the review's time cap" [expr {[string first "movetime 900" $::lastGo] >= 0}]
check "not the review's full depth" [expr {[string first "depth 18" $::lastGo] < 0}]
checkEq "a short cap keeps the 30 s watchdog" [::reviewthreat::watchdogMs 900] 30000
checkEq "a long cap extends the watchdog" [::reviewthreat::watchdogMs 120000] 135000
checkEq "no cap keeps the 30 s watchdog" [::reviewthreat::watchdogMs ""] 30000
check "the probe asks for one line" \
    [expr {[string first "MultiPV 1" $::lastOptions] >= 0}]
check "and uses the review's thread budget" \
    [expr {[string first "Threads 8" $::lastOptions] >= 0}]
check "and the review's hash budget" \
    [expr {[string first "Hash 512" $::lastOptions] >= 0}]
check "the preset's non-resource options are kept" \
    [expr {[string first "SyzygyPath /tmp" $::lastOptions] >= 0}]
check "the preset's full thread reservation is not sent" \
    [expr {[string first "Threads 64" $::lastOptions] < 0}]
check "the preset's full hash reservation is not sent" \
    [expr {[string first "Hash 110000" $::lastOptions] < 0}]

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

puts "\nthe answer lands in the move comment"

# The marker the probe writes its line under. Every check below looks for this
# string, so a change to the marker fails here rather than in the docs.
set ::MARK {[Coach] Threat: }
# Readability helpers: `string first` inside expr braces is not worth the trap.
proc has {text needle} { return [expr {[string first $needle $text] >= 0}] }
proc atStart {text needle} { return [expr {[string first $needle $text] == 0}] }
proc countOf {text pattern} { return [regexp -all $pattern $text] }

# A press on move 3 of a game. The search answered Ra8#, so the facts go into
# that move's comment - and nowhere else: no variation, no NAG, and the board
# stays on the move the reader was reading.
set ::boxes {}
proc tk_messageBox {args} {
    lappend ::boxes [dict get $args -message]
    return ok
}
namespace eval ::auto_comment {}
set ::providerWhy "no model configured"
proc ::auto_comment::providerReady {} { return $::providerWhy }

set ::fenAt(3) {6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1}
set ::comment(3) "my own note about this move"
set ::ply 3
set notifiesBefore $::notifies
::reviewthreat::ready $mateFen "" 3 a1a8 ""
set wrote $::comment(3)
check "the facts land in the move's comment" [has $wrote $::MARK] "got '$wrote'"
check "and carry the answer" \
    [has $wrote [dict get $mate text]] "got '$wrote'"
check "and name the move in SAN" [has $wrote "Ra8#"]
check "the reader's own note is kept, where it was" \
    [atStart $wrote {my own note about this move}] "got '$wrote'"
checkEq "the cursor did not move" $::ply 3
checkEq "and nothing was shown: the comment is the answer" [llength $::boxes] 0
check "the comment window is told to refresh" \
    [expr {$::notifies > $notifiesBefore}]
checkEq "the probe's line is one line" [countOf $wrote {\[Coach\] Threat:}] 1
checkEq "no variation was written" $::variations 0
checkEq "and no NAG" $::nags 0

# A second press replaces the probe's line: the comment must not grow a second
# answer, and the reader's note is not taken with it.
::reviewthreat::ready $mateFen "" 3 a1a8 ""
set wrote $::comment(3)
checkEq "a second press replaces the line rather than stacking it" \
    [countOf $wrote {\[Coach\] Threat:}] 1
checkEq "and the reader's note is still there once" \
    [countOf $wrote {my own note about this move}] 1

# The coach writes "[Coach] ..." on the same move. The probe's line is marked, so
# taking its own line off does not take the coach's with it.
set ::comment(3) "\[Coach\] the coach's own sentence\nmy own note about this move"
::reviewthreat::ready $mateFen "" 3 a1a8 ""
check "the coach's note on the same move is not deleted" \
    [has $::comment(3) "the coach's own sentence"] "got '$::comment(3)'"
check "and the probe's line sits beside it" \
    [has $::comment(3) $::MARK] "got '$::comment(3)'"

# The answer can arrive after the reader has moved on. It lands on the move the
# press was made on, and the board goes back to where it was found.
set ::fenAt(7) {4k3/8/8/8/8/8/8/4K3 w - - 0 1}
set ::ply 7
set ::comment(3) "my own note about this move"
::reviewthreat::ready $mateFen "" 3 a1a8 ""
check "an answer that arrives late lands on the move that was asked about" \
    [has $::comment(3) "Ra8#"] "got '$::comment(3)'"
checkEq "and the board is put back where the reader left it" $::ply 7

# The game changed under the search: the ply now holds another position, so the
# answer is refused rather than written onto a move it was never about.
set ::ply 3
set ::fenAt(3) {4k3/8/8/8/8/8/8/4K3 b - - 0 1}
set before $::comment(3)
set boxesBefore [llength $::boxes]
::reviewthreat::ready $mateFen "" 3 a1a8 ""
check "a game that changed under the probe is refused" \
    [has [lindex $::boxes end] "the game changed while the probe was running"] \
    "got '[lindex $::boxes end]'"
checkEq "and nothing is written" $::comment(3) $before
checkEq "one message, for the refusal" [expr {[llength $::boxes] - $boxesBefore}] 1
set ::fenAt(3) $mateFen

# The same ply and FEN can exist in another game: the game number is the identity
# the ply and FEN cannot provide. The answer is refused rather than written into
# the game the reader has opened since.
set ::ply 3
set ::comment(3) "my own note about this move"
set ::gameNumber 1
set before $::comment(3)
set boxesBefore [llength $::boxes]
set ::gameNumber 2
::reviewthreat::ready $mateFen "" 3 a1a8 "" 1
check "a different game at the same ply and FEN is refused" \
    [has [lindex $::boxes end] "the game changed while the probe was running"] \
    "got '[lindex $::boxes end]'"
checkEq "and writes nothing into the other game" $::comment(3) $before
checkEq "one message for the other-game refusal" \
    [expr {[llength $::boxes] - $boxesBefore}] 1
set ::gameNumber 1

# An engine with no move - a mate or stalemate - must not be fed to the facts as
# "(none)"; it is not a move. The reply is the same "nothing forcing" answer.
set ::ply 3
set ::comment(3) "my own note about this move"
set before $::comment(3)
set boxesBefore [llength $::boxes]
::reviewthreat::ready $mateFen "" 3 "(none)" ""
check "a terminal engine reply is not treated as a move" \
    [has [lindex $::boxes end] "nothing forcing"] \
    "got '[lindex $::boxes end]'"
checkEq "and writes nothing" $::comment(3) $before
checkEq "one message for the terminal position" \
    [expr {[llength $::boxes] - $boxesBefore}] 1

# An engine move the board refuses is reported, never turned into facts.
set ::ply 3
set ::comment(3) "my own note about this move"
set before $::comment(3)
set boxesBefore [llength $::boxes]
::reviewthreat::ready $mateFen "" 3 z9z9 ""
check "an illegal engine move is reported" \
    [has [lindex $::boxes end] "not legal"] \
    "got '[lindex $::boxes end]'"
checkEq "and writes nothing" $::comment(3) $before
checkEq "one message for the illegal move" \
    [expr {[llength $::boxes] - $boxesBefore}] 1

# If the board cannot produce a legal-move list, the engine's move is not
# accepted unchecked: empty is a refusal, not permission.
set ::ply 3
set ::comment(3) "my own note about this move"
set before $::comment(3)
set boxesBefore [llength $::boxes]
rename ::chessboard::legalMoves ::chessboard::legalMoves_
proc ::chessboard::legalMoves {args} { return {} }
::reviewthreat::ready $mateFen "" 3 a1a8 ""
rename ::chessboard::legalMoves {}
rename ::chessboard::legalMoves_ ::chessboard::legalMoves
check "a board that cannot list legal moves is refused" \
    [has [lindex $::boxes end] "not legal"] \
    "got '[lindex $::boxes end]'"
checkEq "and writes nothing" $::comment(3) $before
checkEq "one message for the unverifiable move" \
    [expr {[llength $::boxes] - $boxesBefore}] 1

puts "\none sentence, through the prose queue"

# The real queue, over a stub provider: what is checked is that the probe asks it
# exactly one question, and that the answer is added to the line the facts are
# already in - never instead of them.
set ::askedPrompts {}
set ::askedMax ""
set ::acMode answer
set ::proseDone 0
proc ::auto_comment::queryAsync {prompt max cb} {
    lappend ::askedPrompts $prompt
    set ::askedMax $max
    switch -- $::acMode {
        hold  { return t1 }
        error {
            after 0 [list apply {{callback} {
                {*}$callback "ERROR: no model configured"
                set ::proseDone 1
            }} $cb]
            return t1
        }
        default {
            after 0 [list apply {{callback} {
                {*}$callback "The rook takes the back rank and it is mate."
                set ::proseDone 1
            }} $cb]
            return t1
        }
    }
}
proc ::auto_comment::cancelAsync {token} { return }
# Let the queue's own event turns run: a reply records, asks for the next item
# and finishes on `after 0`, so the answer is not in until they have all run.
proc settle {} {
    unset -nocomplain ::settled
    after 100 {set ::settled 1}
    vwait ::settled
}

set ::ply 3
set ::comment(3) "my own note about this move"
set ::providerWhy ""
::reviewthreat::ready $mateFen "" 3 a1a8 ""
set immediate $::comment(3)
check "the facts are in the comment before the model is asked" \
    [has $immediate $::MARK] "got '$immediate'"
check "and the sentence had not arrived yet" \
    [expr {![has $immediate "back rank"]}] "got '$immediate'"
set watchdog [after 5000 {set ::proseDone 1}]
if {!$::proseDone} { vwait ::proseDone }
catch { after cancel $watchdog }
settle
set wrote $::comment(3)
checkEq "exactly one question went to the queue" [llength $::askedPrompts] 1
check "the question asks for one sentence" \
    [has [lindex $::askedPrompts 0] "ONE sentence"]
check "at a short answer length" [expr {$::askedMax > 0 && $::askedMax <= 300}]
checkEq "the sentence is added to the probe's line" \
    [countOf $wrote {\[Coach\] Threat:[^\n]*back rank}] 1
check "the facts are still there, ahead of the sentence" \
    [expr {[string first $::MARK $wrote] < [string first "back rank" $wrote]}] \
    "got '$wrote'"
checkEq "the probe's line is still one line" \
    [countOf $wrote {\[Coach\] Threat:}] 1
check "the reader's own note survived the prose" \
    [has $wrote "my own note about this move"]
checkEq "the queue is idle again" [dict get [::reviewprose::status] active] 0

# No provider is a supported state: the facts line stands, the queue is not
# asked, and nothing is shown.
set ::providerWhy "no model configured"
set ::askedPrompts {}
set ::comment(3) "my own note about this move"
set boxesBefore [llength $::boxes]
::reviewthreat::ready $mateFen "" 3 a1a8 ""
checkEq "with no provider the queue is not asked" [llength $::askedPrompts] 0
check "with no provider the facts line is written" \
    [has $::comment(3) [dict get $mate text]] "got '$::comment(3)'"
checkEq "with no provider nothing is shown" [expr {[llength $::boxes] - $boxesBefore}] 0

# A request that fails is dropped: the facts are what the reader has. The queue's
# cache is cleared first, so what is answered here is this request and not the
# sentence the same question was given a moment ago.
set ::providerWhy ""
set ::acMode error
::reviewprose::clearCache
set ::comment(3) "my own note about this move"
set boxesBefore [llength $::boxes]
::reviewthreat::ready $mateFen "" 3 a1a8 ""
settle
checkEq "a failed request adds no sentence" \
    [countOf $::comment(3) {\[Coach\] Threat:[^\n]*back rank}] 0
check "and leaves the facts line exactly as written" \
    [has $::comment(3) [dict get $mate text]] "got '$::comment(3)'"
checkEq "and surfaces no error" [expr {[llength $::boxes] - $boxesBefore}] 0
checkEq "and leaves the queue idle" [dict get [::reviewprose::status] active] 0

# A cancelled run is the same: what was written stays.
set ::acMode hold
set ::comment(3) "my own note about this move"
set boxesBefore [llength $::boxes]
::reviewthreat::ready $mateFen "" 3 a1a8 ""
set factsOnly $::comment(3)
checkEq "a press does not wait for the model" [dict get [::reviewprose::status] active] 1
::reviewprose::cancel
settle
checkEq "a cancelled run leaves the facts line untouched" $::comment(3) $factsOnly
checkEq "and surfaces no error" [expr {[llength $::boxes] - $boxesBefore}] 0

# A queue that is already busy (a review is running) is not disturbed, and the
# press does not wait for it: the facts line is the answer.
set ::acMode hold
::reviewprose::run [list [dict create kind review key 1 prompt "a review's own question" max 10]] "" ""
set ::comment(3) "my own note about this move"
::reviewthreat::ready $mateFen "" 3 a1a8 ""
check "a busy queue still gets the facts into the comment" \
    [has $::comment(3) "Ra8#"] "got '$::comment(3)'"
checkEq "and the press adds no question to it" \
    [dict get [::reviewprose::status] total] 1
::reviewprose::cancel
set ::acMode answer

# A build without the queue writes the facts and says nothing.
rename ::reviewprose::run ::reviewprose::run_
set ::comment(3) "my own note about this move"
set boxesBefore [llength $::boxes]
::reviewthreat::ready $mateFen "" 3 a1a8 ""
check "with no queue at all the facts line is still written" \
    [has $::comment(3) "Ra8#"] "got '$::comment(3)'"
checkEq "and nothing is shown" [expr {[llength $::boxes] - $boxesBefore}] 0
rename ::reviewprose::run_ ::reviewprose::run

puts "\nwhat the menu entry asks for"

# ask: no engine configured, a board with no position, and a board at the start
# of the line. Each says what is wrong and writes nothing.
set ::ply 0
set ::comment(0) ""
proc ::reviewthreat::defaultEngine {} { return "" }
set before [llength $::boxes]
::reviewthreat::ask ""
check "ask with no engine says what to do about it" \
    [has [lindex $::boxes end] "Tools -> Configure Engines"]
set ::fenAt(0) ""
::reviewthreat::ask [list "Engine A" /bin/true {} {} 0 0 {} 1 {} {}]
check "ask with no position says there is nothing to look at" \
    [has [lindex $::boxes end] "no position"]
set ::fenAt(0) {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}
::reviewthreat::ask [list "Engine A" /bin/true {} {} 0 0 {} 1 {} {}]
check "ask at the start of the line says there is no move to comment on" \
    [has [lindex $::boxes end] "no move here to comment on"]
checkEq "and the game's own comment is untouched" $::comment(0) ""
checkEq "one box per refusal" [expr {[llength $::boxes] - $before}] 3

# A press while a probe is already running is refused before anything opens.
set ::reviewthreat::job [dict create onDone "" watch ""]
set before [llength $::boxes]
::reviewthreat::ask [list "Engine A" /bin/true {} {} 0 0 {} 1 {} {}]
check "a press while a probe runs says one is already running" \
    [has [lindex $::boxes end] "already running"]
checkEq "and writes nothing" $::comment(0) ""
set ::reviewthreat::job {}

# The whole press, from the menu to the comment: the engine stub answers e5, the
# answer lands on the move that was under the cursor, and the sentence follows.
set ::SAN(e7e5) {e5}
set ::fenAt(4) {rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1}
set ::comment(4) "my own note about this move"
set ::ply 4
set ::acMode answer
set ::proseDone 0
set ::askedPrompts {}
::reviewthreat::ask [list "Engine A" /bin/true {} {} 0 0 {} 1 {} {}]
set watchdog [after 5000 {set ::proseDone 1}]
if {!$::proseDone} { vwait ::proseDone }
catch { after cancel $watchdog }
settle
check "the menu press writes the threat line into the move's comment" \
    [has $::comment(4) $::MARK] "got '$::comment(4)'"
checkEq "and one line only" [countOf $::comment(4) {\[Coach\] Threat:}] 1
check "and the answer is the position's" \
    [has $::comment(4) "no immediate threat"] "got '$::comment(4)'"
check "and the sentence followed it" \
    [has $::comment(4) "back rank"] "got '$::comment(4)'"
check "and the reader's own note is still there" \
    [atStart $::comment(4) {my own note about this move}] "got '$::comment(4)'"
checkEq "and the board is where it was" $::ply 4
checkEq "and no variation was written" $::variations 0

puts ""
puts "$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
