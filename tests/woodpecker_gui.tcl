# Copyright (C) 2026 Tommaso Bergamasco
# SPDX-License-Identifier: GPL-2.0-or-later
#
# woodpecker_gui.tcl -- a Woodpecker session in the real GUI. It is loaded as a
# plugin, so it runs after scidCommunity has started, and drives the board the
# way a user does (addMoveUCI, the same entry point as a dropped piece):
#
#   exercise 1: right, wrong, right, right  -> solved at the second attempt
#   exercise 2: wrong, wrong                -> failed, solution on the board
#   exercise 3: right, right                -> solved cleanly
#
# Run it with tests/woodpecker_gui.sh, which gives it a clean profile and reads
# the result file it writes ($::env(WOODPECKER_GUI_RESULT)).

namespace eval ::wpgui {
    variable out {}
    variable fails 0
    variable checks 0
    variable errors {}
}

proc ::wpgui::check {label cond {detail ""}} {
    variable out
    incr ::wpgui::checks
    if {$cond} {
        lappend out "  ok   $label"
    } else {
        incr ::wpgui::fails
        lappend out "  FAIL $label[expr {$detail eq "" ? "" : " -- $detail"}]"
    }
}
proc ::wpgui::checkEq {label got want} { check $label [expr {$got eq $want}] "got '$got' want '$want'" }

proc ::wpgui::wait {ms} {
    set ::wpgui::tick 0
    after $ms { set ::wpgui::tick 1 }
    vwait ::wpgui::tick
}

# A legal move of the board's position that is neither `avoid` nor a mate.
proc ::wpgui::wrongMove {avoid} {
    set fen [sc_pos fen]
    foreach m [::chessboard::legalMoves [::chessboard::fromFen $fen]] {
        if {[::woodpecker::sameMove $m $avoid]} continue
        if {[::woodpecker::isMateMove $fen $m]} continue
        return $m
    }
    return ""
}

# With WOODPECKER_GUI_SHOTS set to a directory, a screenshot of the screen at
# the named moment (ImageMagick's import), to look at the layout.
proc ::wpgui::shot {name} {
    if {![info exists ::env(WOODPECKER_GUI_SHOTS)]} { return }
    update
    catch { exec import -window root [file join $::env(WOODPECKER_GUI_SHOTS) $name.png] }
}

proc ::wpgui::finishTest {} {
    variable out
    lappend out "$::wpgui::checks checks, $::wpgui::fails failures"
    foreach e $::wpgui::errors { lappend out "  background error: $e" }
    set f [open $::env(WOODPECKER_GUI_RESULT) w]
    puts $f [join $out "\n"]
    close $f
    exit 0
}

proc bgerror {msg} { lappend ::wpgui::errors $msg }

proc ::wpgui::run {} {
    set batch {{"puzzles":[{"game":{"id":"oMbgzh8N","players":[{"name":"keorine2","color":"white"},{"name":"WaterChamp","color":"black"}],"pgn":"d4 f5 c4 Nf6 Nc3 e6 Nf3 Bb4 e3 b6 Bd3 Bb7 O-O O-O d5 Bxc3 bxc3 Qe7 Qb3 exd5 cxd5 d6 Ba3 Nbd7 Bxf5 Nc5 Be6+ Nxe6 dxe6 Rfe8 Ne5 Qxe6 Qxe6+ Rxe6 Nc4 Bd5 Nd2 Ne4 Nxe4 Bxe4 f3 Bd3 Rfe1 Rae8 e4 d5 Rad1 dxe4 fxe4 Bxe4 Re3 Bc2 Rxe6 Rxe6 Rd8+ Kf7 Rf8+ Kg6 Rc8 Bb1 Rxc7 Bxa2 Rxa7 b5 Bb4 Bc4 Bf8"},"puzzle":{"id":"vussK","rating":1466,"plays":981,"solution":["e6e1","g1f2","e1f1","f2e3","f1f8"],"themes":["endgame"],"initialPly":66}},{"game":{"id":"u7vhp33E","players":[{"name":"gchessm1","color":"white"},{"name":"TiberijuBrankovic","color":"black"}],"pgn":"e4 e5 Nf3 Nc6 d4 exd4 Nxd4 Nxd4 Qxd4 c5 Qd1 d6 Bd3 Be6 O-O Qc7 c4 O-O-O Nc3 Nf6 Bf4 h6 h3 g5 Bh2 g4 Qa4 a6 Nd5 Bxd5 cxd5 gxh3 b4 hxg2 Rfc1 Qd7 bxc5 Qxa4 cxd6+ Kb8 d7+ Ka7 Rc8 Be7 Bb8+ Kb6 Rb1+ Ka5"},"puzzle":{"id":"ZXkNc","rating":1547,"plays":22644,"solution":["b8c7","b7b6","c7b6"],"themes":["mateIn2"],"initialPly":47}},{"game":{"id":"ogkxNF5j","players":[{"name":"ItsMe-Cyril","color":"white"},{"name":"jladeshara","color":"black"}],"pgn":"e4 e6 Nf3 a6 d4 c5 d5 d6 c4 e5 Nc3 Nf6 b4 b6 Qa4+ Nbd7 Qc6 Rb8 Qa4 Be7 Bd3 O-O b5 a5 Qc2 h6 h4 Nh5 g4 Nf4 Bxf4 exf4 g5 hxg5 hxg5 Ne5 O-O-O Nxf3 e5 Nxg5 Bh7+ Kh8 Rdg1 dxe5 Rxg5 Bxg5"},"puzzle":{"id":"TzjD2","rating":1597,"plays":4239,"solution":["h7g8","g5h4","c2h7"],"themes":["mateIn2"],"initialPly":45}}]}}
    check "the Play menu has the Woodpecker entry" \
        [expr {![catch {.menu.play index [tr Woodpecker]}]}]
    set exs [lmap e [dict get [::woodpecker::jsonParse $batch] puzzles] { ::woodpecker::lichessExercise $e }]
    set dir [::woodpecker::set::newDir "GUI test"]
    set before [sc_base current]
    ::woodpecker::set::buildFromExercises $dir [::woodpecker::set::newMeta "GUI test" lichess 7 1 [clock seconds]] $exs
    ::woodpecker::marksAppend $dir [dict create 1 [dict create marks {"!" "" "!!"} source review] \
        2 [dict create marks {"!!" ""} source review] 3 [dict create marks {"" "!"} source review]]
    checkEq "building a set leaves the current database alone" [sc_base current] $before
    check "the set folder starts with its date" [string match "[clock format [clock seconds] -format %Y-%m-%d]-gui-test*" [file tail $dir]] [file tail $dir]
    check "no PGN is left behind" [expr {![file exists [file join $dir set.pgn]]}]
    check "the folder explains itself" [file exists [file join [file dirname $dir] README.txt]]

    ::woodpecker::ui::open
    wait 300
    check "the window opens on the sets" [winfo ismapped .woodpeckerWin.home]
    ::woodpecker::ui::selectSet $dir
    check "today's plan is shown" [string match "*0/3*" $::woodpecker::ui::txt(info)] $::woodpecker::ui::txt(info)
    # A game is open in the clipbase: the session must leave it as it was.
    sc_base switch $::clipbase_db
    sc_game new
    sc_move addSan e4
    ::notify::GameChanged
    set openFen [sc_pos fen]
    set userWindows [lsort [::win::getWindows]]
    check "the user's layout has more than the board" [expr {[llength $userWindows] > 2}] $userWindows
    ::woodpecker::ui::train
    wait 500
    checkEq "the session drives the board" $::playMode ::woodpecker::ui::callback
    checkEq "the focus layout: the board and the panel only" [lsort [::win::getWindows]] [lsort {.main .fdockwoodpeckerWin}]
    shot focus
    ::docking::layout_save auto
    checkEq "an options save in a session keeps the user's layout as auto" \
        $::docking::layout_list(auto) $::docking::layout_list(woodpecker_user)
    checkEq "exercise 1 is on the board" [sc_pos fen] [dict get [::woodpecker::readExercises $dir] 1 fen]
    checkEq "two attempts" [::woodpecker::ui::attemptsLeft] 2
    set card [.woodpeckerWin.sess.card.t get 1.0 end]
    check "the card hides the solution" [expr {[string first [tr WoodpeckerHidden] $card] >= 0 && [string first "Re1" $card] < 0}] $card

    # Exercise 1: e6e1 (right), reply, a wrong move, e1f1, reply, f1f8.
    addMoveUCI e6e1
    wait 600
    checkEq "the opponent replied by itself" [sc_game info previousMoveUCI] g1f2
    set bad [wrongMove e1f1]
    set fenBefore [sc_pos fen]
    addMoveUCI $bad
    wait 200
    checkEq "a wrong move is taken back" [sc_pos fen] $fenBefore
    checkEq "one attempt left" [::woodpecker::ui::attemptsLeft] 1
    check "the card says so" [string match "*[tr WoodpeckerWrong]*" [.woodpeckerWin.sess.card.t get 1.0 end]]
    shot session
    check "the board is not moved back by the arrows" \
        [expr {[::woodpecker::ui::callback moveBack] == 0}]
    addMoveUCI e1f1
    wait 600
    addMoveUCI f1f8
    wait 300
    set card [.woodpeckerWin.sess.card.t get 1.0 end]
    check "the card shows the result and the marked line" [string match "*Re1+!*" $card] $card
    wait 1500
    checkEq "exercise 2 follows by itself" [sc_pos fen] [dict get [::woodpecker::readExercises $dir] 2 fen]

    # Exercise 2: two wrong moves.
    set bad [wrongMove b8c7]
    addMoveUCI $bad
    wait 200
    set bad [wrongMove b8c7]
    addMoveUCI $bad
    wait 500
    checkEq "after two errors the solution is shown" $::woodpecker::ui::run(wait) solution
    check "the solution is in the game" [expr {[sc_pos isAt start] && ![sc_pos isAt end]}]
    check "and can be stepped through" [expr {[::woodpecker::ui::callback moveForward] == 1}]
    ::move::Forward
    wait 100
    checkEq "the first solution move carries its !!" [string trim [sc_pos getNags]] "!!"
    ::woodpecker::ui::gotoPly 3
    wait 100
    checkEq "a click on the card shows that move's position" [sc_pos location] 3
    shot solution
    ::woodpecker::ui::keyContinue
    wait 300

    # Exercise 3: h7g8, reply, c2h7 mate.
    checkEq "exercise 3 is on the board" [sc_pos fen] [dict get [::woodpecker::readExercises $dir] 3 fen]
    addMoveUCI h7g8
    wait 600
    addMoveUCI c2h7
    wait 1800
    checkEq "the cycle is over: the summary is shown" [winfo ismapped .woodpeckerWin.sum] 1
    check "the board is free again" [expr {![info exists ::playMode]}]
    checkEq "the game that was open is back" [sc_pos fen] $openFen
    checkEq "the open database is back" [sc_base current] $::clipbase_db
    checkEq "the summary stays in the focus layout" [lsort [::win::getWindows]] [lsort {.main .fdockwoodpeckerWin}]
    check "a finished cycle offers no more exercises" [expr {![winfo ismapped .woodpeckerWin.sum.b.more]}]
    shot summary

    lassign [::woodpecker::readLog $dir] xs ss
    checkEq "three exercises logged" [lmap x $xs { dict get $x result }] {second failed clean}
    checkEq "what was found" [lmap x $xs { dict get $x found }] {111 00 11}
    checkEq "one session row" [llength $ss] 1
    checkEq "the summary counts three exercises" [.woodpeckerWin.sum.grid.v2 cget -text] 3
    check "the summary lists the failed exercise" [string match "*2*" $::woodpecker::ui::txt(sumNotes)] $::woodpecker::ui::txt(sumNotes)
    # Points: ex1 second = (0.75 + 1 + 2) * 1466/1500; ex2 failed with nothing found = 0;
    # ex3 clean = (1 + 1 + 1) * 1597/1500.
    set st [lindex [::woodpecker::sessionStats $xs $ss [::woodpecker::readExercises $dir] \
        [::woodpecker::marksAt [::woodpecker::readMarks $dir] 1]] 0]
    set want [expr {3.75 * 1466 / 1500.0 + 0.0 + 3.0 * 1597 / 1500.0}]
    check "session points" [expr {abs([dict get $st points] - $want) < 1e-6}] "[dict get $st points] vs $want"

    ::woodpecker::ui::exitSession
    wait 800
    checkEq "leaving the session restores the user's layout" [lsort -unique [::win::getWindows]] \
        [lsort -unique [concat $userWindows .fdockwoodpeckerWin]]
    check "the Woodpecker window is back on its sets" [winfo ismapped .woodpeckerWin.home]
    checkEq "the open game is still there" [sc_pos fen] $openFen

    ::woodpecker::ui::newDialog
    wait 300
    check "the new-set dialog opens" [winfo exists .woodpeckerNew]
    checkEq "it proposes the Lichess source" $::woodpecker::ui::newCfg(source) lichess
    check "it offers the five Lichess levels" [winfo exists .woodpeckerNew.f.lich.diff.shardest]
    shot newset
    destroy .woodpeckerNew

    ::woodpecker::ui::stats
    wait 300
    check "the statistics window opens" [winfo exists .woodpeckerStats]
    shot stats
    checkEq "one cycle row" [llength [.woodpeckerStats.cyc children {}]] 1
    checkEq "one session row in the table" [llength [.woodpeckerStats.ses children {}]] 1
    finishTest
}

after 3000 {
    if {[catch { ::wpgui::run } err]} {
        lappend ::wpgui::out "  FAIL the test stopped: $err"
        incr ::wpgui::fails
        lappend ::wpgui::out $::errorInfo
        ::wpgui::finishTest
    }
}
