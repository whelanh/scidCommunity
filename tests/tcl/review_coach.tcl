# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_coach.tcl -- the coach's facts and prompts, without a model.
#
#   tclsh tests/tcl/review_coach.tcl
#
# A prompt is only as good as its FACTS: the model may name nothing that is not
# there, so these checks pin the facts, the report figures and the hard rules.

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
set ::scidTclDir [file join $root tcl]
source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools comment_facts.tcl]
source [file join $root tcl tools review_report.tcl]
source [file join $root tcl tools review_coach.tcl]

set startFen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
set afterFen [::chessboard::toFen \
    [::chessboard::makeMove [::chessboard::fromFen $startFen] e2e4]]

proc mv {ply side uci cls before after} {
    return [dict create ply $ply side $side played $uci \
        fen_before $::startFen fen_after $::afterFen \
        classification $cls eval_before_white $before eval_after_white $after \
        eval_after_cp $after cp_loss [expr {abs($before - $after)}]]
}

set m [mv 1 white e2e4 good 20 20]
set moves {}
for {set ply 1} {$ply <= 16} {incr ply} {
    lappend moves [mv $ply [expr {$ply % 2 ? "white" : "black"}] \
        e2e4 [expr {$ply == 9 ? "inaccuracy" : "good"}] 20 \
        [expr {$ply == 9 ? -40 : 20}]]
}

puts "\nthe move facts"

set facts [::reviewcoach::moveFacts $m]
check "the move is described, not just named" \
    [expr {[string first "played:" $facts] >= 0}]
check "the verdict is in the facts" \
    [expr {[string first "verdict: good" $facts] >= 0}]
check "and the engine's line is available" \
    [expr {[string first "FACTS" $facts] < 0}]
check "each fact stays on its own line" \
    [expr {[regexp -line {^played: \S+.*\s\S+.*\s\S+} $facts] \
        && [llength [split $facts "\n"]] < 40}]

puts "\nthe game facts"

set gf [::reviewcoach::gameFacts $moves [dict create result 1-0 opening "Test Opening"]]
foreach want {{result: White won} {opening: Test Opening} {measured level:} {the game turned here} {weakest phase}} {
    check "it carries $want" [expr {[string first $want $gf] >= 0}]
}
check "and the moves that changed the result" \
    [expr {[string first "errors by" $gf] >= 0 || [string first "chances offered" $gf] >= 0}]

# The turning point is the error that began the collapse, not the later move
# that crossed a threshold. The shape is a real game: the queen blunder leaves
# Black on 13%, and a second error three moves later drops it under 10%.
puts "\nthe move the game turned on"

proc turningMove {ply side cls before after} {
    set pb [expr {$side eq "white" ? $before : -$before}]
    set pa [expr {$side eq "white" ? $after : -$after}]
    return [dict create ply $ply side $side classification $cls \
        eval_before_white $before eval_after_white $after \
        eval_before_cp $before eval_after_cp $after \
        player_before $pb player_after $pa]
}
set story {}
for {set ply 1} {$ply <= 32} {incr ply} {
    lappend story [turningMove $ply [expr {$ply % 2 ? "white" : "black"}] best 0 0]
}
lappend story [turningMove 33 black blunder 0 504]
lappend story [turningMove 34 white best 504 552]
lappend story [turningMove 35 black best 552 538]
lappend story [turningMove 36 white best 538 586]
lappend story [turningMove 37 black inaccuracy 586 772]
lappend story [turningMove 38 white best 772 815]
set turn [::reviewcoach::turningMove $story]
checkEq "the turning move is the blunder that started the collapse" \
    [dict get $turn ply] 33
checkEq "and it is the loser's move" [dict get $turn side] black

set pf [::reviewcoach::phaseFacts $moves opening]
check "a phase has its figures" \
    [expr {[string first "phase: opening" $pf] >= 0 && [string first "accuracy:" $pf] >= 0}]
check "and the state at its ends" \
    [expr {[string first "state at the start of this phase:" $pf] >= 0 \
        && [string first "state at the end of this phase:" $pf] >= 0}]

puts "\nthe prompts"

set mp [::reviewcoach::movePrompt $m]
check "the move prompt ends with its facts" \
    [expr {[string first "FACTS:" $mp] > 0 && [string first $facts $mp] > 0}]
check "and bans the labels it is not" \
    [expr {[string first {"inaccuracy"} $mp] >= 0}]
set mmp [::reviewcoach::momentPrompt $m]
check "the moment prompt is the move prompt with facts" \
    [expr {[string first "FACTS:" $mmp] > 0 && [string first "judged a good" $mmp] > 0}]
set pp [::reviewcoach::phasePrompt opening $pf]
check "the phase prompt carries the facts" \
    [expr {[string first $pf $pp] > 0 && [string first "Never name a piece" $pp] > 0}]
set sp [::reviewcoach::summaryPrompt $gf]
check "the summary prompt carries the facts" \
    [expr {[string first $gf $sp] > 0 && [string first "at most three sentences" $sp] > 0}]

# The reply that punished a move is attached from the next analysed position,
# so the move's facts can say what the move allowed.
set p0 [mv 1 white e2e4 blunder 20 -300]
dict set p0 best_pv [list d2d4 e7e5]
set p1 [mv 2 black e7e5 good -300 -300]
dict set p1 best_pv [list g1f3 b8c6 d2d4]
set punished [list $p0 $p1]
set mprompts [::reviewcoach::buildPrompts $punished {}]
set mprompt ""
foreach item $mprompts {
    if {[dict get $item kind] eq "moment" && [dict get $item key] == 1} {
        set mprompt [dict get $item prompt]
    }
}
check "the punishment line reaches the move prompt" \
    [expr {[string first "the line after the move played runs" $mprompt] >= 0}]

set sm [::reviewcoach::parseSummary "summary: one line.\nLevel: club.\nOPENING: NONE"]
checkEq "the summary tags are read whatever their case" [dict get $sm summary] "one line."
checkEq "and the level" [dict get $sm level] "club."
checkEq "and NONE is no opening" [dict get $sm opening] ""

puts "\nwhat a review asks for"

set prompts [::reviewcoach::buildPrompts $moves [dict create result 1-0 opening "Test Opening"]]
set kinds [dict create]
foreach item $prompts { dict incr kinds [dict get $item kind] }
check "there is one summary" [expr {[dict get $kinds summary] == 1}]
check "and one prompt for each phase with figures" [expr {[dict get $kinds phase] >= 1}]
check "and the blunder is a moment" [expr {[dict get $kinds moment] >= 1}]
check "all of them carry facts" \
    [expr {[string first "FACTS:" [dict get [lindex $prompts 0] prompt]] >= 0}]
checkEq "the prose markers come off together" \
    [::reviewcoach::strip "\[Best\] \[%eval +0.20\] \[Phase opening\] figs \[Coach\] words"] \
    "\[Best\] \[%eval +0.20\]"

puts "\nplacement and replacement"

# A tiny board for ::reviewcoach::place: comments keyed by ply, and a cursor.
set ::loc 0
set ::comments [dict create]
proc sc_move {what {n 0}} {
    if {$what eq "ply"} { set ::loc $n }
    return ""
}
proc sc_pos {what args} {
    switch -- $what {
        location { return $::loc }
        getComment { return [expr {[dict exists $::comments $::loc] ? [dict get $::comments $::loc] : ""}] }
        setComment { dict set ::comments $::loc [lindex $args 0] ; return "" }
    }
    return ""
}
namespace eval ::review {}
proc ::review::cursorSave {} { return [list $::loc 0] }
proc ::review::cursorRestore {c} { set ::loc [lindex $c 0] ; return 1 }

set phases [::reviewreport::phaseSplit $moves]
set anchor [dict get $phases opening to]
set items [list \
    [dict create kind summary key 0 prompt "S"] \
    [dict create kind phase key opening prompt "P"] \
    [dict create kind moment key 9 prompt "M"]]
set res [dict create \
    [list summary 0 "S"] "the story" \
    [list phase opening "P"] "the opening paragraph" \
    [list moment 9 "M"] "the move note"]
::reviewcoach::place {} $moves $items $res
check "the summary lands in the header" \
    [expr {[string first "Summary: the story" [dict get $::comments 0]] >= 0}]
check "the phase lands at its end" \
    [expr {[string first "\[Phase opening\] moves" [dict get $::comments $anchor]] >= 0 \
        && [string first "the opening paragraph" [dict get $::comments $anchor]] >= 0}]
check "the move note lands on the move" \
    [expr {[string first "\[Coach\] the move note" [dict get $::comments 9]] >= 0}]

# The summary answer is three labelled lines; each lands on its own line.
::reviewcoach::place {} $moves $items [dict create \
    [list summary 0 "S"] "SUMMARY: the story\nLEVEL: club player\nOPENING: the Italian"]
set header [dict get $::comments 0]
check "the level is a line of the header" \
    [expr {[string first "Level: club player" $header] >= 0}]
check "and so is the opening" \
    [expr {[string first "Opening: the Italian" $header] >= 0}]
::reviewcoach::place {} $moves $items [dict create \
    [list summary 0 "S"] "SUMMARY: the story\nOPENING: NONE"]
check "NONE writes no opening line" \
    [expr {[string first "Opening:" [dict get $::comments 0]] < 0}]
::reviewcoach::place {} $moves $items [dict create]
check "a second run takes the phase prose off" \
    [expr {[string first "the opening paragraph" [dict get $::comments $anchor]] < 0}]
check "and the coach note too" \
    [expr {[string first "\[Coach\]" [dict get $::comments 9]] < 0}]

# The header block is the coach's too: turning the coach off has to take it
# away, and the report's own header must survive.
dict set ::comments 0 "\[Game review\]\n  White: 90% CAPS accuracy\n\nSummary: old story\nLevel: old level\nOpening: old name"
::reviewcoach::stripHeaderAtStart
check "the header summary comes off" \
    [expr {[string first "old story" [dict get $::comments 0]] < 0 \
        && [string first "old level" [dict get $::comments 0]] < 0 \
        && [string first "old name" [dict get $::comments 0]] < 0}]
check "and the report header stays" \
    [expr {[string first "\[Game review\]" [dict get $::comments 0]] >= 0}]

# The report's own lines are indented under [Game review] and say "White:" and
# "Phases:", so a label at the start of a line is the coach's and nobody else's.
checkEq "an indented report line is not a header block" \
    [::reviewcoach::stripHeader "\[Game review\]\n  White: 90%\n  Phases: opening"] \
    "\[Game review\]\n  White: 90%\n  Phases: opening"

# Prose arrives asynchronously. If the user moved to another game while the
# model was writing, it must not be written into that game.
proc sc_game {what args} {
    if {$what eq "number"} { return $::scidGameNumber }
    return ""
}
set ::scidGameNumber 2
set ::reviewcoach::game 1
checkEq "prose written while another game is open is dropped" \
    [::reviewcoach::place {} $moves $items [dict create \
        [list summary 0 "S"] "late story"]] 0
check "so the header is unchanged" \
    [expr {[string first "late story" [dict get $::comments 0]] < 0}]

puts "\nthe same input gives the same prompt"

checkEq "move facts are deterministic" [::reviewcoach::moveFacts $m] $facts
checkEq "game facts are deterministic" \
    [::reviewcoach::gameFacts $moves [dict create result 1-0 opening "Test Opening"]] $gf
checkEq "so is the move prompt" [::reviewcoach::movePrompt $m] $mp

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
