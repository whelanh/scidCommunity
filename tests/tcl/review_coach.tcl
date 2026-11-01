# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_coach.tcl -- the coach's facts and prompts, without a model.
#
#   tclsh tests/tcl/review_coach.tcl
#
# A prompt is only as good as its FACTS: the model may name nothing that is not
# there, so these checks pin the facts, the report figures, the hard rules and
# the shape of a reply. No model, no network, no board.

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

# FACTS-only. The synthetic move carries a deliberately unusual SAN - a
# disambiguated knight move - and an engine line, so the prompt has something it
# may name; the check is that it names nothing else. The instruction around the
# fact block carries no move, no square and no number of its own.
set mu [mv 3 white e2e4 mistake 20 -300]
dict set mu best_uci g1f3
dict set mu best_san "Nbd7"
dict set mu best_pv {d7d5 e4e5 g8f6}
set ufacts [::reviewcoach::moveFacts $mu]
set up [::reviewcoach::movePrompt $mu]
set uinstr [string map [list $ufacts ""] $up]
check "the SAN the facts carry reaches the prompt" \
    [expr {[string first "Nbd7" $up] >= 0}]
check "and the prompt names it only inside the fact block" \
    [expr {[string first "Nbd7" $uinstr] < 0}]
check "no move the facts do not carry is named" \
    [expr {[string first "Qxh7+" $up] < 0 && [string first "Ra8" $up] < 0}]
check "the instruction names no square of its own" \
    [expr {![regexp -- {[a-h][1-8]} $uinstr]}]
check "and no number of its own" [expr {![regexp -- {[0-9]} $uinstr]}]

# The phase prompt names its phase, and the phase is in the facts it carries.
check "the phase prompt names the phase its facts carry" \
    [expr {[string first "the opening of a game" $pp] >= 0 \
        && [string first "phase: opening" $pf] >= 0}]
check "and names no square outside its facts" \
    [expr {![regexp -- {[a-h][1-8]} [string map [list $pf ""] $pp]]}]

# The summary prompt is the one prompt whose instruction carries worked
# examples, and each names a square ("... took the pawn on e4 ...") to show the
# shape of the answer. They are a shape, not a claim about this game: take the
# two of them out and the instruction names no square either.
set ex1 "the game turned on move 9, when Black's queen took the pawn on e4 and was won for a rook"
set ex2 "Black taking on e4 and losing the queen to a rook is a summary"
set sinstr [string map [list $gf ""] $sp]
check "the summary prompt carries its worked examples" \
    [expr {[string first $ex1 $sp] >= 0 && [string first $ex2 $sp] >= 0}]
check "and names no square outside them" \
    [expr {![regexp -- {[a-h][1-8]} [string map [list $ex1 "" $ex2 ""] $sinstr]]}]

puts "\nwhat a review asks for"

# The set the prompts are built from: sixteen plies, the opening ends at ply 8
# (the board is down to ten majors and minors), so two phases have moves and the
# endgame never starts; three plies carry a verdict - 3, 9 and 15.
set sparseFen "r1b1kbnr/pppppppp/8/8/8/8/PPPPPPPP/R1B1KBNR w KQkq - 0 1"
proc mvAt {ply side uci cls before after fenAfter} {
    return [dict create ply $ply side $side played $uci \
        fen_before $::startFen fen_after $fenAfter \
        classification $cls eval_before_white $before eval_after_white $after \
        eval_after_cp $after cp_loss [expr {abs($before - $after)}]]
}
set judged {}
for {set ply 1} {$ply <= 16} {incr ply} {
    set cls good
    set to 20
    set fenAfter $::afterFen
    if {$ply >= 9} { set fenAfter $::sparseFen }
    if {$ply == 3} { set cls mistake ; set to -60 }
    if {$ply == 9} { set cls miss ; set to -200 }
    if {$ply == 15} { set cls blunder ; set to -700 }
    lappend judged [mvAt $ply [expr {$ply % 2 ? "white" : "black"}] \
        e2e4 $cls 20 $to $fenAfter]
}
set game [dict create result 1-0 opening "Test Opening"]
set prompts [::reviewcoach::buildPrompts $judged $game]
set kinds {}
set keys {}
foreach item $prompts {
    lappend kinds [dict get $item kind]
    lappend keys [dict get $item key]
}
checkEq "three judged moves, two phases and a summary is six prompts" [llength $prompts] 6
checkEq "the summary comes first" [lindex $kinds 0] summary
checkEq "then one prompt for each phase, in the game's order" [lrange $kinds 1 2] {phase phase}
checkEq "with the phases those two" [lrange $keys 1 2] {opening middlegame}
checkEq "then a prompt for each judged move" [lrange $kinds 3 5] {moment moment moment}
checkEq "in ply order" [lrange $keys 3 5] {3 9 15}
set nofacts 0
foreach item $prompts {
    if {[string first "FACTS:" [dict get $item prompt]] <= 0} { incr nofacts }
}
checkEq "and every prompt carries its own facts" $nofacts 0

# A move with no verdict of its own gets no prompt: the other thirteen plies are
# "good" and none of them is a key moment.
check "a move with no verdict gets no prompt" \
    [expr {[lsearch -exact $keys 7] < 0 && [lsearch -exact $keys 12] < 0}]

# The reply that punished a move is attached from the next analysed position, so
# the move's facts can say what the move allowed.
set p0 [mv 1 white e2e4 blunder 20 -300]
dict set p0 best_uci g1f3
dict set p0 best_san "Nf3"
dict set p0 best_pv {g1f3 d7d5}
set p1 [mv 2 black e7e5 good -300 -300]
dict set p1 best_pv {b8c6 g1f3 d2d4}
set punished [::reviewcoach::buildPrompts [list $p0 $p1] {}]
set mprompt ""
foreach item $punished {
    if {[dict get $item kind] eq "moment" && [dict get $item key] == 1} {
        set mprompt [dict get $item prompt]
    }
}
check "the punishment line reaches the move prompt" \
    [expr {[string first "the line after the move played runs b8c6 g1f3 d2d4" $mprompt] >= 0}]

puts "\nthe prose markers"

checkEq "the prose markers come off together" \
    [::reviewcoach::strip "\[Best\] \[%eval +0.20\] \[Phase opening\] figs \[Coach\] words"] \
    "\[Best\] \[%eval +0.20\]"

# The header block is the coach's too: turning the coach off has to take it
# away, and the report's own header must survive.
puts "\nthe header block"

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

dict set ::comments 0 "\[Game review\]\n  White: 90% accuracy\n\nSummary: old story\nLevel: old level\nOpening: old name"
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

puts "\nthe same results set gives the same prompts"

checkEq "the prompts are byte-identical on a second build" \
    [::reviewcoach::buildPrompts $judged $game] $prompts
checkEq "and the order the game's facts were written in does not matter" \
    [::reviewcoach::buildPrompts $judged [dict create opening "Test Opening" result 1-0]] $prompts
# No clock, no random: a prompt that changed between two runs of the same game
# would be a prompt nobody could check.
foreach p {banWords gameMeta movePrompt momentPrompt phasePrompt summaryPrompt parseSummary buildPrompts} {
    set body [info body ::reviewcoach::$p]
    check "$p reads no clock and no random" \
        [expr {![regexp -- {\m(rand|srand|clock)\M} $body]}]
}

puts "\nthe summary reply"

set sm [::reviewcoach::parseSummary "summary: one line.\nLevel: club.\nOPENING: NONE"]
checkEq "the summary tag is read whatever its case" [dict get $sm summary] "one line."
checkEq "and the level" [dict get $sm level] "club."
checkEq "and NONE is no opening" [dict get $sm opening] ""
checkEq "the blocks that come back are the three the writer wants" \
    [lsort [dict keys $sm]] {level opening summary}

# A reply missing a block comes back with that block empty, so the writer writes
# no line for it; the reply is not read as if the block had been there.
set half [::reviewcoach::parseSummary "SUMMARY: a story.\nLEVEL: club player"]
checkEq "a reply missing a block keeps the blocks it has" [dict get $half summary] "a story."
checkEq "and the missing block comes back empty" [dict get $half opening] ""
checkEq "and the block it has is not the whole reply" [dict get $half level] "club player"

# An extra block is not one of the three the writer has, so it cannot land in
# one of them.
set extra [::reviewcoach::parseSummary "SUMMARY: a story.\nLEVEL: club player\nOPENING: the Italian\nMOTIFS: a fork"]
checkEq "a block the prompt never asked for is not invented" \
    [lsort [dict keys $extra]] {level opening summary}
checkEq "and the blocks that were asked for still land" [dict get $extra opening] "the Italian"

# No labels at all: the prompt asks for three labelled lines, and a reply that
# ignores the shape is still read, as one summary.
set plain [::reviewcoach::parseSummary "A single line of prose."]
checkEq "an unlabelled reply is read as the summary" [dict get $plain summary] "A single line of prose."
checkEq "and it leaves the other blocks empty" [dict get $plain level] ""

puts "\nthe game's identifying facts"

# No game open: the meta is empty rather than raising.
set gm [::reviewcoach::gameMeta]
check "with no game open the meta is empty" \
    [expr {[dict get $gm result] eq "" && [dict get $gm opening] eq ""}]
checkEq "and it carries the two facts a prompt needs" [lsort [dict keys $gm]] {opening result}

proc sc_game {what args} {
    if {$what eq "tags"} {
        switch -- [lindex $args 1] {
            Result { return " 1-0 " }
            Opening { return " Sicilian Defence " }
        }
    }
    return ""
}
set gm [::reviewcoach::gameMeta]
checkEq "the result is read off the game's tags" [dict get $gm result] "1-0"
checkEq "and the opening name" [dict get $gm opening] "Sicilian Defence"

# A header that carries only an ECO code still has a name in the opening table:
# the prose must not be told the name is missing when it can be derived.
proc sc_game {what args} {
    if {$what eq "tags"} {
        switch -- [lindex $args 1] {
            Opening { return "" }
            ECO { return "B20" }
        }
    }
    return ""
}
namespace eval ::auto_comment {}
proc ::auto_comment::getOpeningName {eco} {
    if {$eco eq "B20"} { return "Sicilian Defence" }
    return $eco
}
set gm [::reviewcoach::gameMeta]
checkEq "an ECO code alone still gives the opening its name" [dict get $gm opening] "Sicilian Defence"

# A "name" that is only the code repeated is not a name.
proc ::auto_comment::getOpeningName {eco} { return $eco }
set gm [::reviewcoach::gameMeta]
check "a name that is only the code is not a name" [expr {[dict get $gm opening] eq ""}]

puts "\nthe same input gives the same facts"

checkEq "move facts are deterministic" [::reviewcoach::moveFacts $m] $facts
checkEq "game facts are deterministic" \
    [::reviewcoach::gameFacts $moves [dict create result 1-0 opening "Test Opening"]] $gf
checkEq "so is the move prompt" [::reviewcoach::movePrompt $m] $mp

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
