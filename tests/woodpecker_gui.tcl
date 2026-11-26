# Copyright (C) 2026 Tommaso Bergamasco
# SPDX-License-Identifier: GPL-2.0-or-later
#
# woodpecker_gui.tcl -- a Woodpecker session in the real GUI. It is loaded as a
# plugin, so it runs after scidCommunity has started, and drives the board the
# way a user does (addMoveUCI, the same entry point as a dropped piece):
#
#   exercise 1: right, wrong                -> failed (one attempt), solution on the board
#   exercise 2: wrong                       -> failed, solution on the board
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
    # As it goes, too: if the GUI hangs, the last line says where.
    catch { puts stderr [lindex $out end] }
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
    check "today's plan is shown" [expr {$::woodpecker::ui::txt(hCycle.now) eq "0" && [string trim $::woodpecker::ui::txt(hCycle.unit)] eq "/ 3"}] \
        "$::woodpecker::ui::txt(hCycle.now)$::woodpecker::ui::txt(hCycle.unit)"
    # A pane too short for the page: the sets stay reachable by a scrollbar.
    set cv .woodpeckerWin.homeWrap.cv
    set big [$cv cget -height]
    pack propagate .woodpeckerWin.homeWrap 0
    $cv configure -height 120
    pack configure $cv -expand 0 -fill x
    update
    ::woodpecker::ui::homeFit .woodpeckerWin.homeWrap
    check "a short window gets a scrollbar" [winfo ismapped .woodpeckerWin.homeWrap.vs]
    pack configure $cv -expand 1 -fill both
    pack propagate .woodpeckerWin.homeWrap 1
    $cv configure -height $big
    update
    ::woodpecker::ui::homeFit .woodpeckerWin.homeWrap
    # A game is open in the clipbase: the session must leave it as it was.
    # Its players' names must not stay on the session's board either.
    sc_base switch $::clipbase_db
    sc_game new
    sc_game tags set -white Alice -black Bob
    sc_move addSan e4
    ::notify::GameChanged
    set openFen [sc_pos fen]
    set undocked [expr {[info exists ::env(WOODPECKER_GUI_UNDOCKED)] && $::env(WOODPECKER_GUI_UNDOCKED) eq "1"}]
    if {$undocked} {
        ::win::toggleDocked .pgnWin
        wait 300
        checkEq "the PGN window floats in the user's layout" [lindex [::win::isDocked .pgnWin] 0] ""
    }
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
    check "the session board does not show the open game's player names" \
        [expr {$::gamePlayers(nameW) eq "" && $::gamePlayers(nameB) eq ""
               && $::gamePlayers(eloW) eq "" && $::gamePlayers(eloB) eq ""}] \
        "$::gamePlayers(nameW)/$::gamePlayers(nameB)/$::gamePlayers(eloW)/$::gamePlayers(eloB)"
    set card [.woodpeckerWin.sess.card.t get 1.0 end]
    check "the card hides the solution" [expr {[string first [tr WoodpeckerHidden] $card] >= 0 && [string first "Re1" $card] < 0}] $card
    checkEq "training gives the board the keyboard" [focus] .main
    ::woodpecker::ui::bindBoardFocus
    ::woodpecker::ui::bindBoardFocus
    checkEq "the board focus binding stays single" \
        [regexp -all {focusBoard} [bind WoodpeckerBoardFocus <ButtonRelease-1>]] 1
    ::woodpecker::ui::focusBoard
    ::woodpecker::ui::focusBoard 0
    checkEq "a plain focus cancels the forced retry" $::woodpecker::ui::focusRetry ""
    # A click on the board must recover the keyboard from the panel.
    focus -force .woodpeckerWin.sess.card.t
    event generate .main.board.bd <ButtonRelease-1> -x 5 -y 5
    wait 100
    checkEq "a board click gives the keyboard back" [focus] .main

    # The default: two idle minutes pause the session, and the time away is
    # given back on resume. Shorten the fake gap before resuming so the timed
    # exercise is not distorted.
    set ::woodpecker::ui::run(lastInput) [expr {[clock milliseconds] - $::woodpecker::P(idleMs) - 100}]
    wait 800
    checkEq "two idle minutes pause the session" [list $::woodpecker::ui::run(paused) $::woodpecker::ui::run(wait)] {1 ask}
    checkEq "and say why" $::woodpecker::ui::txt(status) [tr WoodpeckerAutoPaused]
    set ::woodpecker::ui::run(pauseT) [expr {[clock milliseconds] - 100}]
    ::woodpecker::ui::pause
    checkEq "resuming clears the pause" [list $::woodpecker::ui::run(paused) $::woodpecker::ui::txt(status)] {0 {}}

    # Exercise 1: e6e1 (right), reply, then a wrong move: one attempt, so it fails.
    addMoveUCI e6e1
    wait 600
    checkEq "the opponent replied by itself" [sc_game info previousMoveUCI] g1f2
    shot session
    check "the board is not moved back by the arrows" \
        [expr {[::woodpecker::ui::callback moveBack] == 0}]
    set bad [wrongMove e1f1]
    set fenBefore [sc_pos fen]
    addMoveUCI $bad
    wait 500
    checkEq "the first error fails the exercise: the solution is shown" $::woodpecker::ui::run(wait) solution
    checkEq "the wrong move is not on the board" [sc_pos fen] $fenBefore
    set card [.woodpeckerWin.sess.card.t get 1.0 end]
    check "the card shows the result and the marked line" [string match "*Re1+!*" $card] $card
    # Pausing hides the Continue button; Enter must still go on, and it must
    # leave the session running rather than paused on the next exercise.
    ::woodpecker::ui::pause
    update
    check "pausing after a failure says so" \
        [expr {$::woodpecker::ui::txt(status) eq [tr WoodpeckerPaused]}]
    check "and hides the Continue button" \
        [expr {![winfo ismapped .woodpeckerWin.sess.line.cont]}]
    ::woodpecker::ui::keyContinue
    wait 300
    checkEq "Enter goes on after a paused failure" [sc_pos fen] [dict get [::woodpecker::readExercises $dir] 2 fen]
    check "and the next exercise is not left paused" [expr {!$::woodpecker::ui::run(paused)}]

    # Exercise 2: a wrong first move.
    set bad [wrongMove b8c7]
    addMoveUCI $bad
    wait 500
    checkEq "after the error the solution is shown" $::woodpecker::ui::run(wait) solution
    check "the solution is in the game" [expr {[sc_pos isAt start] && ![sc_pos isAt end]}]
    check "and can be stepped through" [expr {[::woodpecker::ui::callback moveForward] == 1}]
    ::move::Forward
    wait 100
    check "the arrow moves the highlight on the card" [expr {[llength [.woodpeckerWin.sess.card.t tag ranges cur]] == 2 && [.woodpeckerWin.sess.card.t tag nextrange cur 1.0 end] eq [.woodpeckerWin.sess.card.t tag nextrange ply[sc_pos location] 1.0 end]}]
    checkEq "the first solution move carries its !!" [string trim [sc_pos getNags]] "!!"
    ::woodpecker::ui::gotoPly 3
    wait 100
    checkEq "a click on the card shows that move's position" [sc_pos location] 3
    # A real click on a move of the card, then the arrow: the click must not
    # leave the focus where the arrows are not bound. Force the application's
    # focus first: on a shared desktop the window manager may not have given it.
    focus -force .main
    update
    set t .woodpeckerWin.sess.card.t
    set bb [$t bbox [lindex [$t tag ranges ply2] 0]]
    set cx [expr {[lindex $bb 0] + 3}]; set cy [expr {[lindex $bb 1] + 3}]
    event generate $t <Motion> -x $cx -y $cy
    event generate $t <ButtonPress-1> -x $cx -y $cy
    event generate $t <ButtonRelease-1> -x $cx -y $cy
    wait 100
    checkEq "a real click on a card move shows it" [sc_pos location] 2
    checkEq "the panel gives the focus back to the board" [focus] .main
    event generate [focus] <Key-Left>
    wait 100
    checkEq "and the arrow still steps back after it" [sc_pos location] 1
    shot solution
    # Pausing and resuming must give back the Continue button, not just the key.
    ::woodpecker::ui::pause
    update
    check "a paused solution hides the Continue button" \
        [expr {![winfo ismapped .woodpeckerWin.sess.line.cont]}]
    ::woodpecker::ui::pause
    update
    check "resuming brings the Continue button back" \
        [winfo ismapped .woodpeckerWin.sess.line.cont]
    checkEq "with the solution's line" $::woodpecker::ui::txt(status) [tr WoodpeckerSolutionShown]
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
    checkEq "and so are its player names" "$::gamePlayers(nameW) / $::gamePlayers(nameB)" "Alice / Bob"
    checkEq "the summary stays in the focus layout" [lsort [::win::getWindows]] [lsort {.main .fdockwoodpeckerWin}]
    check "a finished cycle offers no more exercises" [expr {![winfo ismapped .woodpeckerWin.sum.b.more]}]
    shot summary

    lassign [::woodpecker::readLog $dir] xs ss
    checkEq "three exercises logged" [lmap x $xs { dict get $x result }] {failed failed clean}
    checkEq "what was found" [lmap x $xs { dict get $x found }] {100 00 11}
    checkEq "one session row" [llength $ss] 1
    checkEq "the summary counts three exercises" $::woodpecker::ui::txt(sumEx.now) 3
    check "the summary lists the failed exercises" [string match "*1, 2*" $::woodpecker::ui::txt(sumNotes)] $::woodpecker::ui::txt(sumNotes)
    # Points: ex1 failed after finding its "!" = (1 - 0.5) * 1466/1500; ex2 failed with
    # nothing found = 0; ex3 clean = (1 + 1 + 1) * 1597/1500.
    set st [lindex [::woodpecker::sessionStats $xs $ss [::woodpecker::readExercises $dir] \
        [::woodpecker::marksAt [::woodpecker::readMarks $dir] 1]] 0]
    set want [expr {0.5 * 1466 / 1500.0 + 0.0 + 3.0 * 1597 / 1500.0}]
    check "session points" [expr {abs([dict get $st points] - $want) < 1e-6}] "[dict get $st points] vs $want"

    ::woodpecker::ui::exitSession
    wait 800
    checkEq "leaving the session restores the user's layout" [lsort -unique [::win::getWindows]] \
        [lsort -unique [concat $userWindows .fdockwoodpeckerWin]]
    checkEq "and gives the board the keyboard" [focus] .main
    check "the user's board has no session focus tag" \
        [expr {"WoodpeckerBoardFocus" ni [bindtags .main.board.bd]}]
    check "the Woodpecker window is back on its sets" [winfo ismapped .woodpeckerWin.home]
    if {$undocked} {
        check "the PGN window is back" [winfo exists .pgnWin]
        checkEq "and floats again" [lindex [::win::isDocked .pgnWin] 0] ""
    }
    checkEq "the open game is still there" [sc_pos fen] $openFen

    # A second set, abandoned half-way by closing the panel: the session ends,
    # the exercise played is kept, the user's layout and game come back.
    set dir2 [::woodpecker::set::newDir "GUI test two"]
    ::woodpecker::set::buildFromExercises $dir2 [::woodpecker::set::newMeta "GUI test two" lichess 7 1 [clock seconds]] $exs
    ::woodpecker::ui::refresh
    ::woodpecker::ui::selectSet $dir2
    set userWindows2 [lsort -unique [::win::getWindows]]
    ::woodpecker::ui::train
    wait 500
    checkEq "the second session is in the focus layout" [lsort [::win::getWindows]] [lsort {.main .fdockwoodpeckerWin}]
    addMoveUCI e6e1
    wait 600
    addMoveUCI e1f1
    wait 600
    addMoveUCI f1f8
    wait 1600
    ::win::closeWindow .fdockwoodpeckerWin
    wait 800
    check "closing the panel ends the session" [expr {![info exists ::playMode] && !$::woodpecker::ui::run(on)}]
    checkEq "the exercise played is kept" [llength [lindex [::woodpecker::readLog $dir2] 0]] 1
    checkEq "the user's layout is back, without the closed panel" [lsort -unique [::win::getWindows]] \
        [lsearch -all -inline -not -exact $userWindows2 .fdockwoodpeckerWin]
    checkEq "and so is the open game" [sc_pos fen] $openFen
    ::woodpecker::ui::open
    wait 300

    # Options > Resources: the data folder row, and a folder that holds no set.
    ::preferences::resources
    wait 300
    set found 0
    foreach c [winfo children .resDialog] {
        if {[winfo class $c] eq "TLabel" && [string match "[tr WoodpeckerDataDir]*" [$c cget -text]]} { set found 1 }
    }
    check "Options > Resources has the Woodpecker data folder" $found
    catch { grab release .resDialog }
    destroy .resDialog
    set cloud [file join [file dirname $::scidUserDir] cloudsync]
    file mkdir $cloud
    set ::woodpecker::usedDir [file join $cloud woodpecker]
    ::woodpecker::ui::setDataDir $cloud
    wait 1900
    checkEq "another data folder shows its own sets" [llength [.woodpeckerWin.home.sets children {}]] 0
    set ::woodpecker::usedDir [::woodpecker::set::localDir]
    ::woodpecker::ui::setDataDir ""
    wait 1900
    checkEq "back to Scid's folder, the sets are there" [llength [.woodpeckerWin.home.sets children {}]] 2

    ::woodpecker::ui::newDialog
    wait 300
    check "the new-set dialog opens" [winfo exists .woodpeckerNew]
    checkEq "it proposes the puzzles shipped with Scid" $::woodpecker::ui::newCfg(source) puzzles
    checkEq "Lichess is opt-in" $::woodpecker::ui::newCfg(useLichess) 0
    check "it offers the five Lichess levels" [winfo exists .woodpeckerNew.f.lich.diff.shardest]
    check "it asks for the Lichess puzzle rating" [winfo ismapped .woodpeckerNew.f.lich.rating]
    check "the token stays hidden under Advanced" [expr {![winfo ismapped .woodpeckerNew.f.lich.adv.tok]}]
    .woodpeckerNew.f.lich.adv.use invoke
    wait 200
    check "ticking Lichess shows the token" [winfo ismapped .woodpeckerNew.f.lich.adv.tok]
    shot newset-lichess
    .woodpeckerNew.f.lich.adv.use invoke
    wait 200
    check "the presets explain themselves with that rating" \
        [string match "*1500*" $::woodpecker::ui::newCfg(presetHelp)] $::woodpecker::ui::newCfg(presetHelp)
    shot newset
    destroy .woodpeckerNew

    ::woodpecker::ui::stats
    wait 300
    check "the statistics window opens" [winfo exists .woodpeckerStats]
    shot stats
    checkEq "one cycle row" [llength [.woodpeckerStats.cyc children {}]] 1
    checkEq "one session row in the table" [llength [.woodpeckerStats.ses children {}]] 1

    # Open Puzzle Database: a puzzle deleted or added in the set's own database
    # must change exercises.tsv, without renumbering the exercises that stay.
    set dir3 [::woodpecker::set::newDir "GUI test three"]
    ::woodpecker::set::buildFromExercises $dir3 \
        [::woodpecker::set::newMeta "GUI test three" lichess 7 1 [clock seconds]] $exs
    ::woodpecker::marksAppend $dir3 [dict create \
        1 [dict create marks {"!" ""} source review] \
        2 [dict create marks {"!!"} source review]]
    ::woodpecker::ui::refresh
    ::woodpecker::ui::selectSet $dir3
    check "the sets page has the Open Puzzle Database button" [winfo exists .woodpeckerWin.home.b.db]
    checkEq "with the translated label" [.woodpeckerWin.home.b.db cget -text] [tr WoodpeckerOpenDatabase]
    ::woodpecker::ui::openDatabase
    wait 300
    set want [file normalize [::woodpecker::set::basePath $dir3]]
    set b 0
    foreach x [sc_base list] {
        if {[file normalize [file rootname [sc_base filename $x]]] eq $want} { set b $x }
    }
    check "the button opens the set's database" [expr {$b != 0 && [sc_base current] == $b}] \
        "bases [sc_base list], current [sc_base current], want $want"
    set basesBefore [llength [sc_base list]]
    ::woodpecker::ui::openDatabase
    wait 300
    check "opening it again switches instead of opening a second copy" \
        [expr {[llength [sc_base list]] == $basesBefore && [sc_base current] == $b}]
    # Delete puzzle 2 as the game list does, then add a one-move puzzle.
    sc_base gameflag $b 2 set D
    ::notify::DatabaseModified $b
    sc_base switch $b
    sc_game new
    set startFen {rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1}
    sc_game startBoard $startFen
    sc_move addSan e5
    sc_pos addNag "!"
    sc_game tags set -extra [list {PuzzleId "syncnew"} {PuzzleRating "1500"}]
    sc_game save 0 $b
    ::notify::DatabaseModified $b
    ::woodpecker::ui::refresh
    wait 300
    set synced [::woodpecker::readExercises $dir3]
    checkEq "the deleted puzzle leaves the set" [lsort -integer [dict keys $synced]] {1 3 4}
    checkEq "the exercise numbers that stay do not move" \
        [list [dict get $synced 1 puzzleId] [dict get $synced 3 puzzleId]] \
        [list [dict get [lindex $exs 0] id] [dict get [lindex $exs 2] id]]
    checkEq "the added puzzle is an exercise" [dict get $synced 4 fen] $startFen
    set marks [::woodpecker::readMarks $dir3]
    check "the sync does not rewrite the marks file" \
        [expr {[dict exists $marks 1 2] && [dict get $marks 1 2 marks] eq "!!"}]
    set table [::woodpecker::marksAt $marks [::woodpecker::marksLatest $marks]]
    checkEq "the added puzzle keeps its author's mark" [dict get $table 4 marks] !
    checkEq "and an existing exercise keeps its own" [dict get $table 2 marks] !!

    # An unsaved game in the set base is not disturbed by a sync; the sync is
    # deferred instead of loading games over it.
    ::file::SwitchToBase $b
    sc_game load 1
    set solution [dict get $synced 1 solution]
    set bad [::wpgui::wrongMove [lindex $solution 0]]
    set pos [::chessboard::fromFen [sc_pos fen]]
    sc_move addSan [::woodpecker::uciToSan $pos $bad]
    set unsaved [list [sc_game altered] [sc_game number] [sc_pos location]]
    ::notify::DatabaseModified $b
    checkEq "an unsaved game defers the sync" [::woodpecker::set::syncFromBase $dir3] 3
    checkEq "and the game stays as the user left it" \
        [list [sc_game altered] [sc_game number] [sc_pos location]] $unsaved
    checkEq "with the old exercises kept" \
        [lsort -integer [dict keys [::woodpecker::readExercises $dir3]]] {1 3 4}
    # Discard it and leave the game at a ply: a sync from another base must
    # give the set base back its game and place.
    sc_game load 1
    sc_move ply 1
    set keep [list [sc_game number] [sc_pos location]]
    ::file::SwitchToBase $::clipbase_db
    ::notify::DatabaseModified $b
    ::woodpecker::ui::refresh
    wait 300
    ::file::SwitchToBase $b
    checkEq "a sync from another base restores the set base's game" \
        [list [sc_game number] [sc_pos location]] $keep

    # A stale log row for the deleted puzzle must not count or hide the next one.
    set t [clock seconds]
    ::woodpecker::logExercise $dir3 $t 1 1 1 clean 11 1000
    ::woodpecker::logExercise $dir3 $t 1 1 3 clean 11 1000
    ::woodpecker::logExercise $dir3 $t 1 1 2 failed 0 1000
    set info [::woodpecker::ui::dayPlan $dir3]
    checkEq "the deleted puzzle does not count" [dict get $info done] 2
    checkEq "the added puzzle is next" [list [dict get $info next] [dict get $info n]] {3 3}
    ::woodpecker::ui::train
    wait 500
    checkEq "the session skips the deleted number" \
        [list $::woodpecker::ui::run(next) $::woodpecker::ui::run(ex) $::woodpecker::ui::run(n)] {3 4 3}
    checkEq "and shows its position, not its number" \
        $::woodpecker::ui::txt(title) [::woodpecker::ui::T WoodpeckerExercise 3 3]
    addMoveUCI e7e5
    wait 1800
    checkEq "the added puzzle completes the cycle" [winfo ismapped .woodpeckerWin.sum] 1
    ::woodpecker::ui::exitSession
    wait 800

    # Auto-pause: stop after every exercise, right or wrong, and let a solved
    # solution be reviewed before Continue. The clock stops too.
    check "the sets page offers auto-pause" [winfo exists .woodpeckerWin.home.opts.autoPause]
    checkEq "with the translated label" [.woodpeckerWin.home.opts.autoPause cget -text] [tr WoodpeckerAutoPause]
    check "the sets page offers the idle pause switch" [winfo exists .woodpeckerWin.home.opts.noIdlePause]
    checkEq "with its translated label" [.woodpeckerWin.home.opts.noIdlePause cget -text] [tr WoodpeckerNoIdlePause]
    checkEq "both start off" [list $::woodpecker::ui::autoPause $::woodpecker::ui::noIdlePause] {0 0}
    .woodpeckerWin.home.opts.autoPause invoke
    .woodpeckerWin.home.opts.noIdlePause invoke
    checkEq "ticking them turns them on" [list $::woodpecker::ui::autoPause $::woodpecker::ui::noIdlePause] {1 1}
    set dir4 [::woodpecker::set::newDir "GUI test four"]
    # A two-ply solution: the trainee's e5 solves it, and the trailing Nf3 is
    # the opponent reply that the solved review must still be able to reach.
    set even [dict create id even1 rating 1500 plays "" themes {} gameId "" \
        fen {rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1} \
        solution {e7e5 g1f3} lastMove e2e4 white "Even White" black "Even Black"]
    ::woodpecker::set::buildFromExercises $dir4 \
        [::woodpecker::set::newMeta "GUI test four" lichess 7 1 [clock seconds]] \
        [list [lindex $exs 0] $even]
    ::woodpecker::ui::refresh
    ::woodpecker::ui::selectSet $dir4
    ::woodpecker::ui::train
    wait 500
    checkEq "the session reads both options" \
        [list $::woodpecker::ui::run(autoPause) $::woodpecker::ui::run(noIdlePause)] {1 1}
    # With no idle pause, an old lastInput must not stop the clock.
    set ::woodpecker::ui::run(lastInput) [expr {[clock milliseconds] - $::woodpecker::P(idleMs) - 100}]
    wait 800
    checkEq "no idle pause when the switch is on" \
        [list $::woodpecker::ui::run(paused) $::woodpecker::ui::run(wait)] {0 ask}
    # A wrong first move: the failure pauses and asks for Continue.
    set bad [::wpgui::wrongMove [lindex [dict get [lindex $exs 0] solution] 0]]
    addMoveUCI $bad
    wait 600
    checkEq "a failed exercise pauses" [list $::woodpecker::ui::run(wait) $::woodpecker::ui::run(paused)] {solution 1}
    check "the auto-pause keeps Continue" [winfo ismapped .woodpeckerWin.sess.line.cont]
    checkEq "and says why" $::woodpecker::ui::txt(status) [tr WoodpeckerPausedAfter]
    check "the auto-pause hides the pause button" [expr {![winfo ismapped .woodpeckerWin.sess.b.pause]}]
    set before [::woodpecker::ui::elapsedMs]
    wait 1200
    check "the review time is not counted" [expr {[::woodpecker::ui::elapsedMs] - $before <= 5}]
    ::woodpecker::ui::keyContinue
    wait 300
    checkEq "Continue starts the next exercise" [sc_pos fen] [dict get [::woodpecker::readExercises $dir4] 2 fen]
    checkEq "and resumes the clock" $::woodpecker::ui::run(paused) 0
    check "the pause button returns on the next exercise" [winfo ismapped .woodpeckerWin.sess.b.pause]
    checkEq "as Pause" [.woodpeckerWin.sess.b.pause cget -text] [tr WoodpeckerPause]
    # Solve the second: the success pauses too, and the trailing opponent reply
    # is in the game so the whole line can be stepped through.
    addMoveUCI e7e5
    wait 600
    checkEq "a solved exercise pauses too" [list $::woodpecker::ui::run(wait) $::woodpecker::ui::run(paused)] {solution 1}
    check "Continue stays for a solved exercise" [winfo ismapped .woodpeckerWin.sess.line.cont]
    check "the solved pause hides the pause button too" [expr {![winfo ismapped .woodpeckerWin.sess.b.pause]}]
    checkEq "the board is on the trainee's last move" [sc_pos location] 1
    check "the solved line can be stepped forward" [expr {[::woodpecker::ui::callback moveForward] == 1}]
    ::move::Forward
    wait 100
    checkEq "to the trailing opponent reply" [sc_pos location] 2
    ::woodpecker::ui::gotoPly 2
    wait 100
    checkEq "a card click reaches the last ply" [sc_pos location] 2
    ::woodpecker::ui::gotoPly 1
    wait 100
    checkEq "and back to the trainee's move" [sc_pos location] 1
    set before [::woodpecker::ui::elapsedMs]
    wait 1200
    check "the solved review time is not counted either" [expr {[::woodpecker::ui::elapsedMs] - $before <= 5}]
    ::woodpecker::ui::keyContinue
    wait 800
    checkEq "Continue completes the auto-paused cycle" [winfo ismapped .woodpeckerWin.sum] 1
    ::woodpecker::ui::exitSession
    wait 800
    .woodpeckerWin.home.opts.autoPause invoke
    .woodpeckerWin.home.opts.noIdlePause invoke
    checkEq "both options can be turned off again" \
        [list $::woodpecker::ui::autoPause $::woodpecker::ui::noIdlePause] {0 0}
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
