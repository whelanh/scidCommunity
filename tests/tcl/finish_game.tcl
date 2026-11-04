# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# finish_game.tcl -- the engine-window Finish Game pass, without Tk.
#
#   tclsh tests/tcl/finish_game.tcl
#
# The pass alternates two engines and plays their best moves into the game. The
# engine layer and the board are stubbed: what is checked here is which engine
# is asked for which side, with which limits, that the moves land in one commit
# at the end and in order, and that a cancel or a lost engine ends the pass and
# closes both connections.
#
# Since the progress board card, the loop collects before it writes: every move
# is played on a pure ::chessboard position, the game is not touched until the
# last move is in, and addMoveUCI - the cursor-following, animating, FICS-aware
# entry point that used to move the reader's board - is not called at all.

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

# --------------------------------------------------------------- environment --
proc ::options.store {args} {}
proc tr {tag args} { return $tag }
namespace eval ::enginewin {}
proc ::enginewin::reviewWindow {id} { return .engineWin$id }
namespace eval ::notify {}
set ::notified {}
proc ::notify::PosChanged {arg} { lappend ::notified $arg }
proc ::button_image {args} { return "" }
proc update {args} {}
proc grab {args} {}
proc updateBoard {args} {}
proc tk_messageBox {args} { lappend ::boxes $args ; return ok }
namespace eval ::pgn {}
set ::reps 0
proc ::pgn::getRepetitionCount {} { return $::reps }

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools review_progress.tcl]
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools finish_game.tcl]

# The engines: the loop asks for a Go, and the reply arrives through the after
# queue the way a real engine's line would.
namespace eval ::engineNoWin {}
set ::inited {}
set ::closed {}
proc ::engineNoWin::initEngine {id engine callback} {
    lappend ::inited [list $id $engine]
    return 1
}
proc ::engineNoWin::closeEngine {id} { lappend ::closed $id }
namespace eval ::engine {}
set ::sent {}
proc ::engine::send {id msg {data ""}} {
    if {$msg eq "Go"} {
        incr ::gos
        if {$::stopAtGo > 0 && $::gos >= $::stopAtGo} {
            after 0 [list ::finishgame::stop]
            return
        }
    }
    lappend ::sent [list $id $msg $data]
    if {$msg eq "Go"} {
        if {$::reply eq "hold"} {
            return
        } elseif {$::reply eq "gone"} {
            after 0 [list ::finishgame::message $id {InfoDisconnected {}}]
        } elseif {$::reply eq "none"} {
            after 0 [list ::finishgame::message $id [list InfoBestMove [list "(none)"]]]
        } else {
            set move [lindex $::moves $::replyIdx]
            incr ::replyIdx
            after 0 [list ::finishgame::message $id [list InfoBestMove [list $move]]]
        }
    }
    return
}

namespace eval ::tablebase {}
set ::pieces 99
set ::tb ""
proc ::tablebase::countPieces {fen} { return $::pieces }
proc ::tablebase::queryTablebaseResult {fen} { return $::tb }

# A real, short game the loop will walk: Fool's mate ends in a position with no
# legal move, so the pass ends on the game rather than asking for a fifth move.
set ::moves {f2f3 e7e5 g2g4 d8h4}
set ::fens {
    {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}
    {rnbqkbnr/pppppppp/8/8/8/5P2/PPPPP1PP/RNBQKBNR b KQkq - 0 1}
    {rnbqkbnr/pppp1ppp/8/4p3/8/5P2/PPPPP1PP/RNBQKBNR w KQkq e6 0 2}
    {rnbqkbnr/pppp1ppp/8/4p3/6P1/5P2/PPPPP2P/RNBQKBNR b KQkq g3 0 2}
    {rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3}
}
set ::idx 0
set ::cursorPly 0
set ::replyIdx 0
set ::played {}
set ::reply move
set ::calls {}
set ::comments {}
set ::results {}

# The game the reader is looking at. `::idx` counts the moves actually written
# into it, so a position read mid-pass is the position the pass found.
proc sc_pos {args} {
    switch -- [lindex $args 0] {
        fen        { return [lindex $::fens $::idx] }
        getComment { return "" }
        setComment { lappend ::comments [lindex $args 1] ; return "" }
        side       { return white }
        isCheck    { return $::inCheck }
        isAt       { return $::atEnd }
        location   { return $::cursorPly }
    }
    return ""
}
proc sc_base {args} { return 0 }
proc sc_var {args} { return 0 }
proc sc_game {args} {
    switch -- [lindex $args 0] {
        variant { return 0 }
        number  { return 7 }
        tags    { lappend ::results [lindex $args 3] ; return "" }
        info    { return "" }
    }
    return ""
}
proc sc_move {args} { lappend ::calls "move $args" ; return "" }
proc undoFeature {args} { return }
namespace eval ::uci {}
proc ::uci::sc_move_add {uci} {
    lappend ::calls "add $uci"
    lappend ::played $uci
    incr ::idx
    return 0
}
namespace eval ::review {}
proc ::review::cursorSave {} { lappend ::calls cursorsave ; return {loc 0 base 0 path {} fen {}} }
proc ::review::cursorRestore {state} { lappend ::calls cursorrestore ; return 1 }
proc ::review::mergeComment {existing new} { return [string trim "$existing $new"] }

# The entry point this card removed from the path. It is a tripwire: a pass that
# still plays moves as it searches moves the reader's board, whatever else it
# does right.
proc ::addMoveUCI {move} {
    lappend ::calls "ADDMOVEUCI $move"
    lappend ::played $move
    incr ::idx
    if {[info exists ::onMove]} { uplevel #0 $::onMove }
    return 1
}

proc resetGame {} {
    set ::idx 0
    set ::cursorPly 0
    set ::replyIdx 0
    set ::gos 0
    set ::stopAtGo 0
    set ::played {}
    set ::sent {}
    set ::inited {}
    set ::closed {}
    set ::calls {}
    set ::reply move
    set ::boxes {}
    set ::notified {}
    set ::results {}
    set ::comments {}
    set ::inCheck 0
    set ::atEnd 1
    set ::pieces 99
    set ::reps 0
    set ::tb ""
    set ::finishGameMode 0
    catch { unset ::onMove }
    set ::finishgame::active 0
    set ::finishgame::collected {}
    set ::finishgame::note ""
    set ::finishgame::whiteSeconds 5
    set ::finishgame::whiteDepth 20
    set ::finishgame::blackSeconds 7
    set ::finishgame::blackDepth 25
}

proc firstIndex {list pattern} {
    for {set i 0} {$i < [llength $list]} {incr i} {
        if {[string match $pattern [lindex $list $i]]} { return $i }
    }
    return -1
}
proc lastIndex {list pattern} {
    set at -1
    for {set i 0} {$i < [llength $list]} {incr i} {
        if {[string match $pattern [lindex $list $i]]} { set at $i }
    }
    return $at
}

# ------------------------------------------------------------------- the pass --
puts "two engines play the game out"

resetGame
::finishgame::start 1 "White Engine" "Black Engine"
checkEq "every move was played" $::played $::moves
checkEq "both engines were opened" [llength $::inited] 2
checkEq "the white engine" [lindex $::inited 0] \
    [list $::finishgame::WhiteId "White Engine"]
checkEq "and the black one" [lindex $::inited 1] \
    [list $::finishgame::BlackId "Black Engine"]
checkEq "and both were closed" [llength $::closed] 2
checkEq "the pass is over" $::finishgame::active 0
checkEq "the progress job ends with the pass" \
    [dict size [::reviewprogress::job]] 0
checkEq "and the PGN view is told" [lindex $::notified 0] -pgn
set news 0
foreach item $::sent {
    if {[lindex $item 1] eq "NewGame"} { incr news }
}
checkEq "each engine was reset for the game" $news 2
checkEq "with the variant" [lindex [lsearch -inline -index 1 $::sent NewGame] 2] \
    {analysis post_pv post_wdl 0}
checkEq "the old finish flag is restored" $::finishGameMode 0

set gos {}
foreach s $::sent {
    if {[lindex $s 1] eq "Go"} { lappend gos $s }
}
checkEq "one search per move" [llength $gos] 4
checkEq "white moves first" [lindex $gos 0 0] $::finishgame::WhiteId
checkEq "then black" [lindex $gos 1 0] $::finishgame::BlackId
checkEq "then white again" [lindex $gos 2 0] $::finishgame::WhiteId
checkEq "with White's seconds and depth" [lindex $gos 0 2 1] \
    [list [list depth 20] [list movetime 5000]]
checkEq "and Black's" [lindex $gos 1 2 1] \
    [list [list depth 25] [list movetime 7000]]
checkEq "the third search is two moves on, from the engine's own FEN" \
    [lindex $gos 2 2 0] "position fen [lindex $::fens 2]"
checkEq "nothing was reported as a failure" $::boxes {}

# The whole point of this card: the reader's board never moves while the pass is
# running, and the only thing that touches the game is the one commit.
checkEq "addMoveUCI is not on the path at all" \
    [lsearch -all -inline $::calls {ADDMOVEUCI *}] {}

set firstAdd [firstIndex $::calls {add *}]
set lastGo [lastIndex $::calls {Go}]
check "every move is written after every search" \
    [expr {$firstAdd >= 0 && ($lastGo < 0 || $firstAdd > $lastGo)}]
checkEq "the commit appends at the end of the line before the first move" \
    [lindex $::calls [expr {$firstAdd - 1}]] {move end}
check "the commit is one contiguous block of writes" \
    [expr {[lindex $::calls [expr {$firstAdd + 3}]] eq "add d8h4"}]
checkEq "the cursor is put back after the commit" \
    [lindex $::calls [expr {$firstAdd + 4}]] cursorrestore

puts "\nthe button cancels between moves"

resetGame
set ::stopAtGo 1
::finishgame::start 1 "W" "B"
checkEq "nothing was written to the game" $::played {}
checkEq "the engines was closed" [llength $::closed] 2
checkEq "and the pass is over" $::finishgame::active 0
checkEq "the search was stopped" \
    [lindex [lindex $::sent end] 1] StopGo
checkEq "a cancel is not an error" $::boxes {}
checkEq "a cancel writes nothing" [lsearch -all -inline $::calls {add *}] {}

puts "\na tablebase position is settled without a search"

resetGame
set ::pieces 7
set ::tb "Draw"
::finishgame::start 1 "W" "B"
checkEq "no engine was asked" [llength [lsearch -all -index 1 $::sent Go]] 0
checkEq "the result was written as a comment" \
    [string match "*Tablebase: Draw*" [lindex $::comments 0]] 1
checkEq "and no move was played" $::played {}
checkEq "the engines were closed" [llength $::closed] 2
checkEq "and the pass is over" $::finishgame::active 0

puts "\nthe button wakes a waiting search"

# The real cancel happens while the engine is thinking, not after its move.
# Hold the reply, press Cancel from the event loop, and the vwait has to wake
# without a bestmove ever arriving.
resetGame
set ::reply hold
after 10 { ::finishgame::stop }
::finishgame::start 1 "W" "B"
checkEq "no move was played" $::played {}
checkEq "the engines were closed" [llength $::closed] 2
checkEq "the pass is over" $::finishgame::active 0
checkEq "the search was stopped" [lindex [lindex $::sent end] 1] StopGo
checkEq "a cancel is not an error" $::boxes {}
checkEq "a cancel during a search writes nothing" [lsearch -all -inline $::calls {add *}] {}

puts "\na terminal position is a draw, not an error"

resetGame
set ::reply none
set ::inCheck 0
::finishgame::start 1 "W" "B"
checkEq "no move was played" $::played {}
checkEq "the result is a draw" $::results {1/2-1/2}
checkEq "the engines were closed" [llength $::closed] 2
checkEq "and nothing was reported" $::boxes {}

puts "\na lost engine ends the pass"

resetGame
set ::reply gone
::finishgame::start 1 "W" "B"
checkEq "no move was played" $::played {}
checkEq "the engines were closed" [llength $::closed] 2
checkEq "and the pass is over" $::finishgame::active 0
check "the failure was reported" [expr {[llength $::boxes] == 1}]

puts "\nthe progress job names the engine window, not its widget path"

# The window knows its own number; the job takes that, not the widget path the
# classic code carried around. A header reading "Engine window .engineWin3" is
# an implementation detail the reader should never see. Run last: a second pass
# here would disturb the state the checks above depend on.
set ::jobs {}
::reviewprogress::setPainter {apply {{job} {lappend ::jobs $job}}}
resetGame
::finishgame::start 3 "White Engine" "Black Engine"
set first [lindex $::jobs 0]
check "the progress job was begun" [expr {[dict size $first] > 0}]
checkEq "the job carries the window's number as its origin" \
    [dict get $first fields] \
    {source finish engine {White Engine / Black Engine} origin {enginewin 3} cancel ::finishgame::stop}
check "no widget path reaches the header" \
    [expr {[string first .engineWin [dict get $first header]] < 0}]
::reviewprogress::setPainter {}

puts "\na repetition ends the pass and is recorded as a draw"

resetGame
set ::moves {g1f3 g8f6 f3g1 f6g8 g1f3 g8f6 f3g1 f6g8}
::finishgame::start 1 "W" "B"
checkEq "the repeating move was still written once" [llength $::played] 8
checkEq "the result is a draw" [lindex $::results 0] "1/2-1/2"
checkEq "and no error was reported" $::boxes {}

puts "\na repetition through a double pawn push is counted"

# 1.e4 sets an en-passant square no pawn can use. The same position returns
# after the knights cycle, without that square; the key must treat them as one.
resetGame
set ::moves {e2e4 g8f6 g1f3 f6g8 f3g1 g8f6 g1f3 f6g8 f3g1}
::finishgame::start 1 "W" "B"
checkEq "the cycle stops at the third occurrence" [llength $::played] 9
checkEq "and is recorded as a draw" [lindex $::results 0] "1/2-1/2"
checkEq "with no error" $::boxes {}

puts "\nthe commit belongs to the game the pass started with"

resetGame
set saved $::finishgame::identity
set ::finishgame::identity [dict create base 0 number 99 fen X]
check "a changed game is refused before anything is written" \
    [expr {[::finishgame::commit end] ne ""}]
checkEq "and nothing was written" $::played {}
set ::finishgame::identity $saved

puts "\nChess960 castling is applied on the pure board"

set c [::chessboard::fromFen {r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1}]
set c [::chessboard::makeMove $c e1h1]
checkEq "the king finishes on g1" [lindex [dict get $c board] 6] K
checkEq "the rook finishes on f1" [lindex [dict get $c board] 5] R
set c [::chessboard::fromFen {r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1}]
set c [::chessboard::makeMove $c e1a1]
checkEq "queenside: the king finishes on c1" [lindex [dict get $c board] 2] K
checkEq "queenside: the rook finishes on d1" [lindex [dict get $c board] 3] R
set c [::chessboard::fromFen {r3k2r/8/8/8/8/8/8/R3K2R w HAha - 0 1}]
set c [::chessboard::makeMove $c e1h1]
checkEq "Chess960 rights: the castling side's letters are gone" \
    [dict get $c castle] ha
set c [::chessboard::fromFen {r3k2r/8/8/8/8/8/8/R3K2R w HAha - 0 1}]
set c [::chessboard::makeMove $c h1h2]
checkEq "a rook move drops only its own file's right" [dict get $c castle] Aha

puts "\nthe repetition key ignores an unusable en-passant square"

checkEq "a double push with no capturing pawn has no ep key" \
    [::finishgame::positionKey \
        {rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1}] \
    {rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq -}
checkEq "a pawn that can capture keeps it" \
    [::finishgame::positionKey \
        {rnbqkbnr/pppppppp/8/8/3pP3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1}] \
    {rnbqkbnr/pppppppp/8/8/3pP3/8/PPPP1PPP/RNBQKBNR b KQkq e3}

puts "\na midgame cursor is refused before any search"

resetGame
set ::moves {f2f3 e7e5 g2g4 d8h4}
set ::atEnd 0
::finishgame::start 1 "W" "B"
checkEq "no engine was started" $::inited {}
checkEq "nothing was written" $::played {}
check "and the reason is shown" [expr {[llength $::boxes] == 1}]
set ::atEnd 1

puts "\nthe pane's Finish Game leaves its toggle off"

resetGame
set ::moves {f2f3 e7e5 g2g4 d8h4}
set ::analysis(name1) "W"
set ::finishGameMode 1
::finishgame::startPane 1
checkEq "the pane pass leaves the toggle off" $::finishGameMode 0
checkEq "and the pass is over" $::finishgame::active 0

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
