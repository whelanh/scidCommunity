#!/usr/bin/env wish
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# sergame_engine.tcl -- Play versus Engine on its own engine connections
# (#437 §4a): the substrate half of the port.
#
#   wish tests/tcl/sergame_engine.tcl
#   xvfb-run -a wish tests/tcl/sergame_engine.tcl     (no display)
#
# Before this card the module played on the old Analysis engine mode: two
# numeric slots in that mode's shared array, a flag it waited on for "ready",
# and a blocking wait for the bestmove -- so the window froze while an engine
# thought, and a second engine (the coach) wrote into the same array. Now each
# engine owns a ::engineNoWin connection under its own id and keeps what the
# engine answers in that connection's state.
#
# What is real here and what is stubbed, and why:
#
#   real    tcl/enginecomm.tcl -- the transport, the reply contract, the search
#           queue (a second Go stops the first before it is sent), and the
#           per-connection state this card added. The scenarios are about that
#           contract, so it runs for real over a socket pair, the way
#           tests/tcl/engine_reply.tcl runs the close paths over one.
#   real    tcl/tools/uci_format.tcl -- the move/PV formatter the module plays
#           the engine's move through.
#   real    tcl/tools/sergame.tcl -- the module under test.
#   stub    the engine process: a fake engine on the far end of the socket that
#           records every line Scid sends and answers when the test tells it to
#           (and answers "stop" the way a real engine does, with a bestmove).
#           A preset's process cannot be started in CI, and what matters here is
#           what Scid sends and what it does with the answer.
#   stub    the chess database and the game clock (this file owns neither).
#
# wish, not tclsh, because play builds the game window and its controls; the
# engine layer itself needs no display. tests/tcl/tactics_trainer.tcl is the
# same shape for the same reason.

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
proc checkEq {label got want {detail ""}} {
    if {$detail eq ""} { set detail "got '$got' want '$want'" }
    check $label [expr {$got eq $want}] $detail
}
proc checkIn {label haystack needle} {
    check $label [expr {[string first $needle $haystack] >= 0}] \
        "in '$haystack' want '$needle'"
}
proc checkNotIn {label haystack needle} {
    check $label [expr {[string first $needle $haystack] < 0}] \
        "in '$haystack' want no '$needle'"
}

# A background error in a channel handler is how a transport bug shows up in
# this harness; wish's default is a modal dialog, which would hang CI quietly.
set ::background {}
proc bgerror {msg} {
    lappend ::background $msg
    puts "  BGERROR $msg"
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
proc readText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation auto
    set text [read $f]
    close $f
    return $text
}

# --------------------------------------------------------------- event loop --
# Let the loop run for a while: sockets are read and timers fire. `after N`
# alone would sleep without processing anything, which would hide exactly the
# bug this harness is about.
proc drain {{ms 20} {quiet 2}} {
    # Pump the loop until the transport is quiet: no new line has arrived for
    # $quiet rounds. A fixed sleep is either slower than the sockets or faster
    # than them, and a fixed count of rounds was both (::enginecomm writes one
    # message as two lines, and a non-blocking read can take the first before
    # the second has arrived).
    set still 0
    for {set rounds 0} {$rounds < 60} {incr rounds} {
        set before [fake::wire]
        set ::drained 0
        after $ms set ::drained 1
        vwait ::drained
        update
        if {[fake::wire] == $before} {
            if {[incr still] >= $quiet} { break }
        } else {
            set still 0
        }
    }
}

# How many lines the fake engines have received: the harness's measure of
# "nothing more is in flight".
namespace eval fake {}

# The timers still queued for a script.
proc scheduled {pattern} {
    set out {}
    foreach id [after info] {
        set detail [after info $id]
        if {[string match $pattern [lindex $detail 0]]} { lappend out $id }
    }
    return $out
}

# The game loop's own 200 ms poll of the player's turn. A real game keeps it;
# the harness drives engineGo itself, so it is cancelled to keep the sequence
# of a scenario deterministic.
proc quiet {} {
    catch { after cancel ::sergame::engineGo 1 }
    catch { after cancel ::sergame::engineGo 2 }
}

# ---------------------------------------------------------------- the strings --
array set ::tr {}
proc translate {lang key args} { set ::tr($key) [lindex $args 0] }
proc menuText {lang key text args} { set ::tr($key) $text }
source -encoding utf-8 [file join $root tcl lang english.tcl]
set ::optionsFile ""
setLanguage_E
proc tr {tag args} {
    if {[info exists ::tr($tag)]} { return $::tr($tag) }
    if {[llength $args]} { return [lindex $args 0] }
    return $tag
}
# The module reads $::tr(Key) directly too, which bypasses the proc and errors
# on a key the catalogue does not carry; the C layer falls back to the key.
set sergameSrc [readText [file join $root tcl tools sergame.tcl]]
foreach {all key} [regexp -all -inline {\$::tr\((\w+)\)} $sergameSrc] {
    if {![info exists ::tr($key)]} { set ::tr($key) $key }
}

# -------------------------------------------------------------- the fake game --
namespace eval fake {
    variable moves {}        ;# SAN of the line on the board
    variable cursor 0
    variable side white
    variable prevSAN ""
    variable prevUCI ""
    variable pushed 0        ;# the formatter's temporary copy is in front
    variable tags {}
    variable saved {}
    variable box ""          ;# the last message box's text
    variable playMode ""
    variable started {}      ;# clocks started, in order
    variable added {}        ;# {n seconds} added to a clock, in order
    variable stopped 0       ;# how many times a clock was stopped
    variable stored {}       ;# storeEvalComment values
    variable peer           ;# id -> the fake engine's end of the socket (array)
    variable sent           ;# id -> every line Scid put on the wire (array)
    variable goes           ;# id -> the "go ..." lines (array)
    variable refuses        ;# preset name -> initEngine raises
    variable gc             ;# clock counters, as the real widget keeps them (array)
    variable gcRun          ;# which clock is running (array)
}
set ::fake::refuses(Broken) 1
array set ::fake::gc {c1 0 c2 0}
array set ::fake::gcRun {r1 0 r2 0}
array set ::fake::sent {}
array set ::fake::goes {}
array set ::fake::peer {}

proc fake::log {what} { lappend ::fake::log $what }

# How many lines the fake engines have received, in all: the harness's measure
# of "nothing more is in flight".
proc fake::wire {} {
    set n 0
    foreach id [array names ::fake::sent] { incr n [llength $::fake::sent($id)] }
    return $n
}

# A connected pair of sockets: ::enginecomm needs a real channel (chan event,
# chan puts, chan close), and the test needs to read what Scid wrote.
proc fake::pair {} {
    set ::fake::accepted ""
    set server [socket -server {apply {{chan addr port} {set ::fake::accepted $chan}}} \
        -myaddr 127.0.0.1 0]
    set port [lindex [chan configure $server -sockname] 2]
    set client [socket 127.0.0.1 $port]
    vwait ::fake::accepted
    chan close $server
    return [list $client $::fake::accepted]
}

proc fake::say {id line} {
    if {![::info exists ::fake::peer($id)]} { return }
    catch { puts $::fake::peer($id) $line }
    catch { flush $::fake::peer($id) }
}

proc fake::readable {id} {
    if {![::info exists ::fake::peer($id)]} { return }
    set chan $::fake::peer($id)
    if {[catch { chan eof $chan } eof]} { return }
    if {$eof} { catch { chan event $chan readable {} } ; return }
    while {[catch { gets $chan line } n] == 0 && $n >= 0} {
        lappend ::fake::sent($id) $line
        fake::onLine $id $line
    }
}

# What the engine answers on its own. A search's info lines and its move are
# sent by the test, so the timing of an answer is the test's to choose; "stop"
# is answered the way a real engine answers it.
proc fake::onLine {id line} {
    switch -glob -- $line {
        "uci"        { fake::say $id "uciok" }
        "isready"    { fake::say $id "readyok" }
        "stop"       { fake::best $id [fake::stopMove $id] }
        "go *"       { lappend ::fake::goes($id) $line }
        "ucinewgame" - "setoption *" - "ponderhit" - "quit" { }
    }
}

# The move the engine had decided on when a search is stopped. A real engine
# always names one; the test does not care which.
proc fake::stopMove {id} {
    if {[info exists ::fake::stopmove($id)]} { return $::fake::stopmove($id) }
    return "a7a6"
}

proc fake::infoLine {id {score 30} {pv "e7e5 g1f3"} {multipv 1}} {
    fake::say $id "info depth 12 seldepth 15 multipv $multipv score cp $score nodes 1200 nps 60000 time 20 pv $pv"
}
proc fake::mateLine {id {in 3} {pv "e7e5 g1f3"}} {
    fake::say $id "info depth 12 seldepth 15 multipv 1 score mate $in nodes 1200 nps 60000 time 20 pv $pv"
}
proc fake::best {id move {ponder ""}} {
    if {$ponder eq ""} {
        fake::say $id "bestmove $move"
    } else {
        fake::say $id "bestmove $move ponder $ponder"
    }
}
proc fake::die {id} {
    chan close $::fake::peer($id)
    unset ::fake::peer($id)
}

# Every line Scid sent of a kind, in order.
proc fake::sentMatching {id pattern} {
    set out {}
    if {![info exists ::fake::sent($id)]} { return $out }
    foreach line $::fake::sent($id) {
        if {[string match $pattern $line]} { lappend out $line }
    }
    return $out
}

# A move the player plays: the side changes and the engine's turn starts.
proc fake::playerMove {uci san} {
    lappend ::fake::moves $san
    incr ::fake::cursor
    set ::fake::prevSAN $san
    set ::fake::prevUCI $uci
    set ::fake::side [expr {$::fake::side eq "white" ? "black" : "white"}]
}

proc fake::reset {} {
    foreach id [array names ::fake::peer] {
        catch { chan close $::fake::peer($id) }
        unset ::fake::peer($id)
    }
    array unset ::fake::sent
    array unset ::fake::goes
    array set ::fake::sent {}
    array set ::fake::goes {}
    array unset ::fake::stopmove
    set ::fake::moves {}
    set ::fake::cursor 0
    set ::fake::side white
    set ::fake::prevSAN ""
    set ::fake::prevUCI ""
    set ::fake::pushed 0
    set ::fake::tags {}
    set ::fake::saved {}
    set ::fake::box ""
    set ::fake::playMode ""
    set ::fake::started {}
    set ::fake::added {}
    set ::fake::stopped 0
    set ::fake::stored {}
}

# --------------------------------------------------------------- the engine --
# The transport under test. ::engineNoWin is the module's door to it, so the
# stub is one door wide: it opens a socket pair and hands the connection to
# ::enginecomm, which then runs its real handshake and reply contract.
namespace eval ::engineNoWin {}
proc ::engineNoWin::initEngine {id name cb {options ""}} {
    if {[info exists ::fake::refuses($name)]} { error "could not start $name" }
    lassign [fake::pair] scidSide engineSide
    set ::fake::peer($id) $engineSide
    set ::fake::sent($id) {}
    set ::fake::goes($id) {}
    set ::engconn(logSend_$id) ""
    ::engine::init_ $id $scidSide $cb
    chan configure $scidSide -buffering line -blocking 0
    chan configure $engineSide -buffering line -blocking 0
    ::engine::handshake_ $id {uci}
    chan event $scidSide readable [list ::engine::onMessages_ $id $scidSide]
    chan event $engineSide readable [list fake::readable $id]
    return 1
}
proc ::engineNoWin::closeEngine {id} { ::engine::close $id }

# The preset list the dialog builds; the module reads the name at index 0 and
# the command at index 1 (for the message it shows when a preset will not start).
set ::engines(list) [list \
    [list "Stockfish" "/usr/games/stockfish" "" "/usr/share/stockfish" "" 0 0 1] \
    [list "Coach" "/usr/games/coach" "" "/usr/share/coach" "" 0 0 1] \
    [list "Broken" "/nonexistent/engine" "" "" "" 0 0 1]]

# ------------------------------------------------------------ the chess rules --
# A tiny board: squares as strings, moves as SAN through a map, and a push/pop
# pair so the formatter's temporary line does not become the game.
set ::curr_db 1
array set ::fake::uciSan {
    e2e4 e4 e7e5 e5 g1f3 Nf3 d2d4 d4 d7d5 d5 b1c3 Nc3 g8f6 Nf6 f1c4 Bc4
    b8c6 Nc6 c2c4 c4 c7c5 c5 h2h4 h4 g7g6 g6 a7a6 a6
}
proc sc_pos {sub args} {
    switch -- $sub {
        isAt {
            switch -- [lindex $args 0] {
                start { return [expr {$::fake::cursor == 0}] }
                end   { return [expr {$::fake::cursor >= [llength $::fake::moves]}] }
            }
        }
        side        { return $::fake::side }
        fen         { return "6k1/5ppp/8/8/8/8/5PPP/R5K1 [string index $::fake::side 0] - - 0 $::fake::cursor" }
        hash        { return [expr {1000 + $::fake::cursor}] }
        moveNumber  { return [expr {1 + $::fake::cursor / 2}] }
        previousMove - previousMoveNT { return $::fake::prevSAN }
        previousMoveUCI               { return $::fake::prevUCI }
        getComment  { return "" }
        removeNag   { return 1 }
        addNag      { return 1 }
    }
    return ""
}
proc sc_move {sub args} {
    switch -- $sub {
        add {
            # ::ucifmt::sc_move_add passes squares, not SAN.
            lassign $args s1 s2 promo
            set uci "$s1$s2"
            set san $uci
            if {[info exists ::fake::uciSan($uci)]} { set san $::fake::uciSan($uci) }
            set ::fake::prevSAN $san
            set ::fake::prevUCI $uci
            if {$::fake::pushed} { return 1 }
            lappend ::fake::moves $san
            incr ::fake::cursor
            set ::fake::side [expr {$::fake::side eq "white" ? "black" : "white"}]
            return 1
        }
        addSan {
            lappend ::fake::moves [lindex $args 0]
            incr ::fake::cursor
            set ::fake::prevSAN [lindex $args 0]
            set ::fake::side [expr {$::fake::side eq "white" ? "black" : "white"}]
            return 1
        }
        back {
            if {[llength $::fake::moves] == 0} { return 1 }
            set ::fake::moves [lrange $::fake::moves 0 end-1]
            incr ::fake::cursor -1
            if {$::fake::cursor < 0} { set ::fake::cursor 0 }
            set ::fake::side [expr {$::fake::side eq "white" ? "black" : "white"}]
            set ::fake::prevSAN [lindex $::fake::moves end]
            return 1
        }
        start { set ::fake::cursor 0 ; set ::fake::moves {} ; return 1 }
        forward { incr ::fake::cursor ; return 1 }
    }
    return 1
}
proc sc_game {sub args} {
    switch -- $sub {
        info {
            switch -- [lindex $args 0] {
                previousMove   { return $::fake::prevSAN }
                previousMoveNT { return $::fake::prevSAN }
                previousMoveUCI { return $::fake::prevUCI }
                number         { return 1 }
            }
        }
        tags  { set ::fake::tags [lrange $args 0 end] }
        push  { incr ::fake::pushed ; return 1 }
        pop   { if {$::fake::pushed > 0} { incr ::fake::pushed -1 } ; return 1 }
        startBoard { return 1 }
        save  { lappend ::fake::saved [lindex $args 0] }
        load  { return 1 }
    }
    return 1
}
proc sc_var {args} { return "" }
proc toAbsPath {path} { return $path }
proc sc_base {args} { return 1 }
namespace eval ::game {}
proc ::game::Clear {} { return "" }
namespace eval ::board {}
proc ::board::sq {sq} { return $sq }
proc ::board::flip {w args} { return }
namespace eval ::book {}
proc ::book::getMove {args} { return "" }
namespace eval ::utils {}
namespace eval ::utils::sound {}
proc ::utils::sound::AnnounceNewMove {args} { return }
namespace eval ::utils::date {}
proc ::utils::date::today {} { return "2026.01.11" }
namespace eval ::utils::validate {}
proc ::utils::validate::floatScale {args} { return }

# The game clock, with the real one's contract: getSec is the time left (the
# counter runs upwards from -wtime), stop answers 1 only for a clock that was
# running, and add takes seconds off the counter.
namespace eval ::gameclock {}
proc ::gameclock::new {parent n {size 100} {showfall 0}} { set ::fake::gc(c$n) 0 ; return }
proc ::gameclock::setColor {args} { return }
proc ::gameclock::reset {n} { set ::fake::gcRun(r$n) 0 ; set ::fake::gc(c$n) 0 }
proc ::gameclock::getSec {n} { return [expr {0 - $::fake::gc(c$n)}] }
proc ::gameclock::setSec {n value} { set ::fake::gc(c$n) $value }
proc ::gameclock::add {n value} {
    set ::fake::gc(c$n) [expr {$::fake::gc(c$n) - $value}]
    lappend ::fake::added [list $n $value]
}
proc ::gameclock::start {n} {
    set ::fake::gcRun(r$n) 1
    lappend ::fake::started $n
}
proc ::gameclock::stop {n} {
    if {$::fake::gcRun(r$n)} {
        set ::fake::gcRun(r$n) 0
        incr ::fake::stopped
        return 1
    }
    return 0
}
proc ::gameclock::storeTimeComment {n} { return }

namespace eval ::notify {}
proc ::notify::GameChanged {args} { return }
proc ::notify::PosChanged {args} { return }
proc ::setPlayMode {mode} { set ::fake::playMode $mode }
proc updateBoard {args} { return }
proc helpWindow {args} { return }
proc storeEvalComment {value} { lappend ::fake::stored $value }
namespace eval ::enginelist {}
proc ::enginelist::choose {} { return }
proc tk_messageBox {args} {
    set i [lsearch $args -message]
    if {$i >= 0} { set ::fake::box [lindex $args [expr {$i + 1}]] }
    return ok
}
proc createToplevel {w args} {
    if {![winfo exists $w]} { toplevel $w }
    return $w
}
proc applyThemeColor_background {w} { return }
proc setTitle {w title} { catch { wm title $w $title } }
proc createToplevelFinalize {w} { return }
proc setWinLocation {w} { return }
proc recordWinSize {w} { return }
array set ::informant {!? 0.3 ?! 0.3 ? 0.8 ?? 1.5 += 0.5 +/- 1.5 +- 2.5 +-- 4.0}

# ------------------------------------------------------------------- the module --
source -encoding utf-8 [file join $root tcl enginecomm.tcl]
source -encoding utf-8 [file join $root tcl tools uci_format.tcl]
source -encoding utf-8 [file join $root tcl tools sergame.tcl]

# The defaults live in tcl/options.tcl, which cannot be sourced on its own.
set ::sergame::isOpening 0
set ::sergame::chosenOpening 0
set ::sergame::chosenEngine 0
set ::sergame::useBook 0
set ::sergame::bookToUse ""
set ::sergame::startFromCurrent 0
set ::sergame::coachIsWatching 0
set ::sergame::timeMode "timebonus"
set ::sergame::depth 3
set ::sergame::movetime 0
set ::sergame::nodes 10000
set ::sergame::ponder 0
set ::sergame::useChessClock 1
set ::sergame::showblunder 1
set ::sergame::showblundervalue 1
set ::sergame::showevaluation 1
set ::sergame::threshold 0.9
set ::sergame::isLimitedAnalysisTime 0
set ::sergame::analysisTime 10
set ::sergame::storeEval 0
set ::sergame::storeEvalAll 0
set ::sergame::coachIndex 1
set ::sergame::playerColor "white"

# The blunder dialog is a real modal window (tkwait on a variable): a harness
# cannot click it. Keeping the move is what the "Use My Move" button returns,
# and what it was asked is recorded.
proc ::sergame::blunderDialog {msg bestMoveText} {
    set ::fake::blunder [list $msg $bestMoveText]
    return 2
}

# A game that must not be left running between scenarios.
proc endGame {} {
    quiet
    if {[winfo exists .coachWin]} {
        catch { ::sergame::abortGame }
        catch { destroy .coachWin }
    }
    drain 20
    fake::reset
}

# =============================================================================
puts "\nthe module does not reach for the old engine mode"
# =============================================================================
# The card's acceptance greps, as checks rather than as a reviewer's memory.
checkNotIn "no old engine-slot state in the module" $sergameSrc "::uci::uciInfo"
checkNotIn "nothing in the module waits on the engine" $sergameSrc "vwait"
checkNotIn "no old engine mode call of any kind" $sergameSrc "::uci::"
check "the presets' own formatter plays the engine's move" \
    [expr {[string first "::ucifmt::sc_move_add" $sergameSrc] >= 0}]
check "and formats the coach's line" \
    [expr {[string first "::ucifmt::formatPv" $sergameSrc] >= 0}]
foreach name {config play abortGame clocks takeBack callback startAnalyze stopAnalyze \
        changePVSize updateAnalysisText endOfGame engineGo logEngine} {
    check "the module still offers ::sergame::$name" \
        [expr {[llength [info commands ::sergame::$name]] == 1}]
}
checkEq "the opponent's connection id" [::sergame::connId 1] "sergamePlayer"
checkEq "the coach's connection id" [::sergame::connId 2] "sergameCoach"
check "the old shared slot array is never created" [expr {![info exists ::uci::uciInfo]}]

# =============================================================================
puts "\na go answered by a reply, and the window stays live while it thinks"
# =============================================================================
fake::reset
set rc [catch { ::sergame::play 0 } err]
checkEq "play starts the game" $rc 0 $err
quiet
drain 60
check "the game window is up" [expr {[winfo exists .coachWin]}]
check "the opponent's own connection is open" [::engine::connected sergamePlayer]
check "the coach is not connected when it is not watching" \
    [expr {![::engine::connected sergameCoach]}]
checkIn "the handshake reached the fake engine" $::fake::sent(sergamePlayer) "uci"
checkIn "the game's ponder setting travelled with the connection, not by hand" \
    $::fake::sent(sergamePlayer) "setoption name Ponder value false"
checkEq "no search is sent before the player moves" \
    [llength $::fake::goes(sergamePlayer)] 0
# The clocks the connection was given: five minutes each, counting up from
# five minutes left, exactly as the widget does.
checkEq "the white clock was set from the connection's wtime" $::fake::gc(c1) -300
checkEq "the black clock was set from the connection's btime" $::fake::gc(c2) -300
checkEq "the clock of the side to move started" [lindex $::fake::started end] 1

# The player moves; now it is the engine's turn.
fake::playerMove e2e4 e4
set ::live 0
set rc [catch { ::sergame::engineGo 1 } err]
checkEq "engineGo returns without waiting for the move" $rc 0 $err
drain 30
checkEq "nothing has been answered yet" [::sergame::st 1 bestmove] ""
checkEq "the search reached the engine" \
    [lindex [fake::sentMatching sergamePlayer "position fen *"] end] \
    "position fen 6k1/5ppp/8/8/8/8/5PPP/R5K1 b - - 0 1"
checkEq "and the go line carries the game's clock, in the game's order" \
    [lindex $::fake::goes(sergamePlayer) end] \
    "go wtime 310000 btime 300000 winc 10000 binc 10000"

# While the engine thinks, the event loop is free: a timer set after the search
# was sent runs before the answer exists. This is the whole point of the card.
after 20 {incr ::live}
drain 60
checkEq "a timer ran while the engine was thinking" $::live 1
checkEq "and no move was played in the meantime" [llength $::fake::moves] 1

fake::infoLine sergamePlayer 30 "e7e5 g1f3"
drain 20
# The score is White's, from the engine's own point of view turned round: +30 cp
# for Black is -0.30 for White.
checkEq "the line's score is kept on the connection, White's way round" \
    [::sergame::st 1 score] -0.3
checkEq "the line is kept as SAN" [::sergame::st 1 pv] "e5 Nf3"

fake::best sergamePlayer e7e5 g1f3
drain 60
checkEq "the engine's move went on the board" [lindex $::fake::moves end] "e5"
checkEq "and the board's side turned" $::fake::side white
checkEq "the move it expects back is kept" [::sergame::st 1 ponder] "g1f3"
checkEq "the search it answered is closed" [::sergame::st 1 search] ""
checkEq "the clock turned over with the move, with the increment" \
    [lindex $::fake::added 0] "1 10"
checkEq "the opponent's score is its own, still White's" [::sergame::st 1 score] -0.3

# =============================================================================
puts "\na second go replaces the first, and the first one's answer is not a move"
# =============================================================================
fake::playerMove g1f3 Nf3
::sergame::engineGo 1
drain 20
set goesBefore [llength $::fake::goes(sergamePlayer)]
fake::infoLine sergamePlayer 900 "b8c6 f1c4"
drain 20
checkEq "the first search's score is on the connection" [::sergame::st 1 score] -9.0

# The search is replaced. ::enginecomm stops the one in flight, waits for its
# bestmove (which a real engine always sends), and only then sends the queued
# search; the stopped search's answer is not the game's move.
::sergame::engineGo 1
drain 60
checkIn "the search in flight was stopped" $::fake::sent(sergamePlayer) "stop"
checkEq "and the replacement cleared the old search's score" [::sergame::st 1 score] ""
checkEq "the stopped search's move was not played" [lindex $::fake::moves end] "Nf3"
checkEq "the replacement go reached the engine" \
    [llength $::fake::goes(sergamePlayer)] [expr {$goesBefore + 1}]
checkEq "with the same limits" \
    [string match "go wtime * winc 10000 binc 10000" [lindex $::fake::goes(sergamePlayer) end]] 1

fake::infoLine sergamePlayer 20 "b8c6 f1c4"
fake::best sergamePlayer b8c6
drain 60
checkEq "the replacement's move went on the board" [lindex $::fake::moves end] "Nc6"
checkEq "with its own score, not the stopped search's" [::sergame::st 1 prevscore] -0.2

# =============================================================================
puts "\nthe coach has its own connection and cannot overwrite the player's"
# =============================================================================
fake::reset
set ::sergame::coachIsWatching 1
set rc [catch { ::sergame::play 0 } err]
checkEq "a game with a coach starts" $rc 0 $err
quiet
drain 80
check "the opponent's connection is open" [::engine::connected sergamePlayer]
check "the coach's connection is open" [::engine::connected sergameCoach]
check "the two engines are two connections, not two slots" \
    [expr {[set ::engconn(channel_sergamePlayer)] ne [set ::engconn(channel_sergameCoach)]}]
checkEq "the coach was asked for one line" \
    [fake::sentMatching sergameCoach "setoption name MultiPV value 1"] \
    [list "setoption name MultiPV value 1"]
checkEq "and searches the position on the board" \
    [lindex $::fake::goes(sergameCoach) end] "go infinite"

# Both engines are thinking at once, which the old shared slots could not do.
fake::playerMove e2e4 e4
::sergame::engineGo 1
drain 20
fake::infoLine sergamePlayer 40 "e7e5 g1f3"
drain 20
checkEq "the opponent's score is on the opponent's connection" [::sergame::st 1 score] -0.4

fake::infoLine sergameCoach 250 "d2d4 d7d5"
drain 20
checkEq "the coach's score is on the coach's connection" [::sergame::st 2 score] 2.5
checkEq "and it did not touch the opponent's score" [::sergame::st 1 score] -0.4
checkEq "nor the opponent's move" [::sergame::st 1 bestmove] ""
checkEq "nor the opponent's ponder flag" [::sergame::st 1 ponder] ""
checkEq "the coach's own ponder flag is not the opponent's" [::sergame::st 2 ponder] ""

fake::best sergamePlayer e7e5 g1f3
drain 80
checkEq "the opponent's move is still the game's" [lindex $::fake::moves end] "e5"
checkEq "and the coach was asked for the new position" \
    [lindex $::fake::goes(sergameCoach) end] "go infinite"
checkEq "with the new search's score, not the old one's" [::sergame::st 2 score] ""

fake::infoLine sergameCoach 120 "d2d4 d7d5"
drain 20
checkEq "the coach's new line is kept" [::sergame::st 2 score] 1.2

# A stopped coach search keeps the line it reached, and never plays a move.
set movesBefore [llength $::fake::moves]
::sergame::stopAnalyze
drain 60
checkIn "the coach was stopped" $::fake::sent(sergameCoach) "stop"
checkEq "a coach answer never becomes a move" [llength $::fake::moves] $movesBefore
checkEq "the coach's line is kept for the display" [::sergame::st 2 score] 1.2

# Watching again: a new search on the same connection.
::sergame::startAnalyze
drain 20
checkEq "the coach resumed with a new search" \
    [lindex $::fake::goes(sergameCoach) end] "go infinite"

# =============================================================================
puts "\ncancelled before the reply: nothing is left waiting"
# =============================================================================
set ::sergame::coachIsWatching 0
endGame
::sergame::play 0
quiet
fake::playerMove e2e4 e4
::sergame::engineGo 1
drain 20
check "the engine is thinking" \
    [expr {[::engine::connected sergamePlayer] && [::sergame::st 1 search] ne ""}]
set ::sergame::playerMoved 1
set ::sergame::waitPlayerMove 1
check "the game is running" [expr {$::fake::playMode ne ""}]

::sergame::abortGame
drain 60
checkEq "the game is no longer playing" $::fake::playMode ""
check "the opponent's connection is closed" [expr {![::engine::connected sergamePlayer]}]
check "the search is gone with it" [expr {[::sergame::st 1 search] eq ""}]
check "no score of that search is left behind" [expr {[::sergame::st 1 score] eq ""}]
check "the clocks stopped" [expr {$::fake::stopped > 0}]
checkEq "nothing is still scheduled for the game loop" [scheduled *engineGo*] ""

# A reply that arrives after the cancel (the engine was already writing one)
# must not put a move on the board either.
set movesBefore [llength $::fake::moves]
::sergame::onBestMove 1 {g8f6 {}}
drain 20
checkEq "a late answer is not a move" [llength $::fake::moves] $movesBefore
endGame

# =============================================================================
puts "\nan engine that dies mid-search leaves no waiter and no stale score"
# =============================================================================
fake::reset
::sergame::play 0
quiet
fake::playerMove e2e4 e4
::sergame::engineGo 1
drain 20
fake::infoLine sergamePlayer 55 "e7e5 g1f3"
drain 20
checkEq "the engine had a line" [::sergame::st 1 score] -0.55

set ::fake::box ""
set movesBefore [llength $::fake::moves]
set rc [catch { fake::die sergamePlayer } err]
checkEq "the engine's death does not raise here" $rc 0 $err
drain 100
checkEq "the game was told, and stopped" $::fake::playMode ""
checkEq "the player was told the engine disconnected" \
    $::fake::box [::tr EpdEngineDisconnected]
check "the connection is gone" [expr {![::engine::connected sergamePlayer]}]
check "the dead engine's score went with it" [expr {[::sergame::st 1 score] eq ""}]
checkEq "no move was played" [llength $::fake::moves] $movesBefore
checkEq "nothing is left scheduled for the game loop" [scheduled *engineGo*] ""
endGame

# =============================================================================
puts "\nan engine that will not start is reported, and nothing is left holding it"
# =============================================================================
fake::reset
set ::fake::box ""
set rc [catch { ::sergame::play 2 } err]
checkEq "play survives a preset that cannot start" $rc 0 $err
quiet
checkIn "and says which program failed" $::fake::box "Unable to start the program"
checkIn "with the preset's command" $::fake::box "/nonexistent/engine"
check "no connection was left open" [expr {![::engine::connected sergamePlayer]}]
# The game does not sit waiting for a move an engine that never started cannot
# give: its first turn stops it, with the message the old mode gave after a
# five-second wait for "ready".
fake::playerMove e2e4 e4
set ::fake::box ""
set rc [catch { ::sergame::engineGo 1 } err]
checkEq "the first turn of a game with no engine does not raise" $rc 0 $err
drain 40
checkEq "the game stops instead of waiting for a move that cannot come" \
    $::fake::playMode ""
checkEq "and says the engine is gone" $::fake::box [::tr EpdEngineDisconnected]
endGame

# =============================================================================
puts "\nthe game's settings are the game's, and they reach the engine"
# =============================================================================
fake::reset
set ::sergame::wtime 180000
set ::sergame::btime 240000
set ::sergame::winc 2000
set ::sergame::binc 3000
::sergame::play 0
quiet
checkEq "the clocks came from the game's own settings" $::fake::gc(c1) -180
checkEq "and so did the other side's" $::fake::gc(c2) -240
fake::playerMove e2e4 e4
::sergame::engineGo 1
drain 30
checkEq "and they reach the engine in its own window" \
    [lindex $::fake::goes(sergamePlayer) end] \
    "go wtime 182000 btime 240000 winc 2000 binc 3000"
endGame

# A limit mode other than the clock asks for its own limit, and the limit is
# the connection's, taken when the game opened it.
set ::sergame::timeMode "depth"
set ::sergame::depth 7
::sergame::play 0
quiet
fake::playerMove e2e4 e4
::sergame::engineGo 1
drain 30
checkEq "a fixed-depth game asks for that depth" \
    [lindex $::fake::goes(sergamePlayer) end] "go depth 7"
endGame

set ::sergame::timeMode "timebonus"
set ::sergame::depth 3

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
