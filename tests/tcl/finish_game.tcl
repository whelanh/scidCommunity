# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# finish_game.tcl -- the engine-window Finish Game pass, without Tk.
#
#   tclsh tests/tcl/finish_game.tcl
#
# The pass alternates two engines and plays their best moves into the game. The
# engine layer and the board are stubbed: what is checked here is
# which engine is asked for which side, with which limits, that the moves land
# in order, and that a cancel or a lost engine ends the pass and closes both
# connections.

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
proc ::button_image {args} { return "" }
proc update {args} {}
proc grab {args} {}
proc updateBoard {args} {}
proc tk_messageBox {args} { lappend ::boxes $args ; return ok }
namespace eval ::pgn {}
proc ::pgn::getRepetitionCount {} { return 0 }

set root [file normalize [file join [file dirname [info script]] .. ..]]
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
    lappend ::sent [list $id $msg $data]
    if {$msg eq "Go"} {
        if {$::reply eq "hold"} {
            return
        } elseif {$::reply eq "gone"} {
            after 0 [list ::finishgame::message $id {InfoDisconnected {}}]
        } elseif {$::reply eq "none"} {
            after 0 [list ::finishgame::message $id [list InfoBestMove [list "(none)"]]]
        } else {
            set move [lindex $::moves $::idx]
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

# A one-line game the loop will walk.
set ::moves {e2e4 e7e5 g1f3 b8c6}
set ::idx 0
set ::played {}
set ::reply move
# The real cursor sits on the last move as soon as one is added, which is what
# sc_pos isAt vend answers. The loop must not mistake that for "the game is
# over": it has to keep playing.
proc sc_pos {args} {
    switch -- [lindex $args 0] {
        isAt   { return [expr {$::idx > 0}] }
        isCheck { return $::inCheck }
        side   { return [expr {$::idx % 2 == 0 ? "white" : "black"}] }
        fen    { return "FEN$::idx" }
        getComment { return "" }
        setComment { lappend ::comments [lindex $args 1] ; return "" }
    }
    return ""
}
# The last scripted move mates, so the pass ends with the game rather than
# asking for a fifth move that does not exist.
proc sc_game {args} {
    switch -- [lindex $args 0] {
        UCI_currentPos { return "position startpos moves [join $::played]" }
        variant        { return 0 }
        info {
            if {[lindex $args 1] eq "previousMove" && $::idx >= [llength $::moves]} {
                return "Qh7#"
            }
            return ""
        }
        tags { lappend ::results [lindex $args 3] ; return "" }
    }
    return ""
}
proc ::addMoveUCI {move} {
    lappend ::played $move
    incr ::idx
    if {[info exists ::onMove]} { uplevel #0 $::onMove }
    return 1
}

proc resetGame {} {
    set ::idx 0
    set ::played {}
    set ::sent {}
    set ::inited {}
    set ::closed {}
    set ::reply move
    set ::boxes {}
    set ::results {}
    set ::comments {}
    set ::inCheck 0
    set ::pieces 99
    set ::tb ""
    set ::finishGameMode 0
    catch { unset ::onMove }
    set ::finishgame::active 0
    set ::finishgame::whiteSeconds 5
    set ::finishgame::whiteDepth 20
    set ::finishgame::blackSeconds 7
    set ::finishgame::blackDepth 25
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
checkEq "the position sent is the game so far" \
    [lindex $gos 2 2 0] "position startpos moves e2e4 e7e5"
checkEq "nothing was reported as a failure" $::boxes {}

puts "\nthe button cancels between moves"

resetGame
set ::onMove {::finishgame::stop}
::finishgame::start 1 "W" "B"
checkEq "only the move in flight was played" $::played {e2e4}
checkEq "the engines were closed" [llength $::closed] 2
checkEq "and the pass is over" $::finishgame::active 0
checkEq "the search was stopped" \
    [lindex [lindex $::sent end] 1] StopGo
checkEq "a cancel is not an error" $::boxes {}

puts "\na tablebase position is settled without a search"

resetGame
set ::pieces 7
set ::tb "Draw"
::finishgame::start 1 "W" "B"
checkEq "no engine was asked" [llength [lsearch -all -index 1 $::sent Go]] 0
checkEq "the result was written as a comment" \
    [string match "*Tablebase: Draw*" [lindex $::comments 0]] 1
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

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
