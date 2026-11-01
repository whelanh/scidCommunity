# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_threat.tcl -- the "What's the threat?" probe without a board.
#
#   tclsh tests/tcl/review_threat.tcl
#
# The probe is three decisions: one short search for the strongest move, the
# deterministic facts that describe it, and one sentence of prose over those
# facts. The engine is stubbed here; the search is the only part that touches it.

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

proc options.store {varname {default ""}} {
    if {![info exists $varname]} { set $varname $default }
}
proc tr {tag} { return $tag }
set root [file normalize [file join [file dirname [info script]] .. ..]]
set ::scidTclDir [file join $root tcl]
source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools comment_facts.tcl]
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools game_review.tcl]
source [file join $root tcl tools review_threat.tcl]

puts "\nthe strongest move in words"

# A back-rank mate: the move is a threat and the answer must not echo "a1a8".
set mateFen {6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1}
set facts [::reviewthreat::threatFacts $mateFen a1a8]
check "the move is described, not spelled" \
    [expr {[string first "rook" $facts] >= 0 && [string first "a1a8" $facts] < 0}]
check "the mate is stated" [expr {[string first "mate" $facts] >= 0}]
checkEq "and the achievement is checkmate" \
    [::reviewthreat::threatAchieves $mateFen a1a8] "what it achieves: checkmate"

# A capture threat: the pawn takes a queen, and that is the threat.
set capFen {4k3/8/8/3q4/4P3/8/8/4K3 w - - 0 1}
set facts [::reviewthreat::threatFacts $capFen e4d5]
check "a capture is named in words" \
    [expr {[string first "queen" $facts] >= 0 && [string first "e4d5" $facts] < 0}]
check "and what it wins is in the achievement" \
    [expr {[string first "queen" [::reviewthreat::threatAchieves $capFen e4d5]] >= 0}]

puts "\nthe facts the model reads"

set block [::reviewthreat::factsBlock $mateFen a1a8]
foreach want {white\ is\ to\ move castling: en\ passant: fifty-move\ rule: {The strongest move:} {what it achieves:}} {
    check "the block carries $want" [expr {[string first $want $block] >= 0}]
}
check "the block does not spell the move in coordinates" \
    [expr {[string first "a1a8" $block] < 0}]
set p [::reviewthreat::prompt White $block]
check "the prompt names the side" [expr {[string first "White" $p] >= 0}]
check "and carries the facts last" [expr {[string first $block $p] > 0}]
check "and asks for one sentence" [expr {[string first "ONE sentence" $p] >= 0}]
check "and forbids coordinates" [expr {[string first "coordinates" $p] >= 0}]
checkEq "the fallback is one sentence about the side" \
    [::reviewthreat::fallback $mateFen a1a8] \
    "White's threat: [::reviewthreat::threatFacts $mateFen a1a8]."
checkEq "black is named from the FEN" \
    [::reviewthreat::sideName {4k3/8/8/8/8/8/8/4K3 b - - 0 1}] Black

# A quiet best move is not a threat, and the answer says so rather than calling
# castling or a pawn push a threat.
set quietFen {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}
check "a pawn push is not forcing" [expr {![::reviewthreat::forcing $quietFen e2e4]}]
check "the fallback says there is no immediate threat" \
    [expr {[string first "no immediate threat" [::reviewthreat::fallback $quietFen e2e4]] >= 0}]
check "the facts say the strongest move is not forcing" \
    [expr {[string first "not forcing" [::reviewthreat::factsBlock $quietFen e2e4]] >= 0}]

puts "\nthe engine search"

namespace eval ::engineNoWin {}
set ::threatInit {}
set ::threatClosed {}
proc ::engineNoWin::initEngine {id name cb} { set ::threatInit [list $id $name] ; return 1 }
proc ::engineNoWin::closeEngine {id} { lappend ::threatClosed $id }
namespace eval ::engine {}
set ::lastGo {}
proc ::engine::send {id msg {data ""}} {
    if {$msg eq "Go"} {
        set ::lastGo $data
        after 0 [list ::reviewthreat::message {InfoBestMove {e2e4}}]
    }
    return
}
namespace eval ::review {}
proc ::review::effective {cfg} { return [dict create depth 18 movetime 900] }

set cfg [list "Engine A" /bin/true {} {} 0 0 {} 1 {} {}]
set ::done 0
set ::threatMove ""
set ::threatErr "untouched"
::reviewthreat::search $cfg {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1} \
    [list apply {{move err} {set ::threatMove $move ; set ::threatErr $err ; set ::done 1}}]
if {!$::done} { vwait ::done }
update
checkEq "the engine's move comes back" $::threatMove e2e4
checkEq "without an error" $::threatErr ""
checkEq "the engine was opened for this probe" [lindex $::threatInit 1] {Engine A}
checkEq "and closed again" [lindex $::threatClosed end] reviewThreat
check "the Go asks for position fen" [expr {[string first "position fen" $::lastGo] >= 0}]
check "at the quick depth" [expr {[string first "depth 14" $::lastGo] >= 0}]
check "under the review's time cap" [expr {[string first "movetime 900" $::lastGo] >= 0}]
check "not the review's full depth" [expr {[string first "depth 18" $::lastGo] < 0}]

puts "\nno engine means no search"

checkEq "a non-UCI preset is refused in words" \
    [::reviewthreat::search {Engine A /bin/true {} {} 0 0 {} 0 {} {}} {8/8/8/8/8/8/8/K6k w - - 0 1} {list}] \
    "the threat probe needs a UCI engine"

puts "\nthe fallback and the model answer"

set ::boxes {}
proc tk_messageBox {args} {
    lappend ::boxes [dict get $args -message]
    return ok
}
namespace eval ::auto_comment {}
set ::providerWhy "no model configured"
proc ::auto_comment::providerReady {} { return $::providerWhy }
proc ::auto_comment::queryAsync {prompt max cb} {
    set ::askedPrompt $prompt
    set ::askedMax $max
    after 0 [list {*}$cb "White's rook takes the back rank and it is mate."]
    return t1
}
::reviewthreat::ready $mateFen "" a1a8 ""
check "no model shows the deterministic sentence" \
    [expr {[string first "White's threat:" [lindex $::boxes end]] >= 0}]
set ::providerWhy ""
set ::askedPrompt ""
set ::askedMax ""
::reviewthreat::ready $mateFen "" a1a8 ""
if {[llength [info commands ::vwait]]} { after 50 { set ::waited 1 } ; vwait ::waited }
check "with a model it asks the coach" [expr {[string first "ONE sentence" $::askedPrompt] >= 0}]
checkEq "at the short answer length" $::askedMax 220
check "and shows the cleaned answer" \
    [expr {[string first "back rank" [lindex $::boxes end]] >= 0}]

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
