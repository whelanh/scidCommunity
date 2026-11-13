#!/usr/bin/env wish
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# sergame_engine.tcl -- Play versus Engine on its own engine connections
# (#437 §4a): the substrate half of the port, and (#437 §4b) the game the ported
# module still plays -- its clocks, a takeback, the coach's judgement and its
# dialog, ponder, the evaluation written on a move, and the four ways a game
# ends, each followed by a second session after an abnormal one.
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
#   stub    the chess database and the game clock (this file owns neither), and
#           the blunder dialog itself: it is a modal window (tkwait on a
#           variable) and a harness cannot click it, so the scenario chooses the
#           button and reads back what the module asked.
#
# §4b adds the behaviour half to the same fake: the clock and increments the go
# line carries, a takeback in a real game, the coach's threshold and the value
# it shows, a ponder hit and a declined ponder line, the [%eval] comment on the
# move it belongs to, and mate / resignation / draw / a dead engine.
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

# One proc's source text, from the bytes on disk: the module under test is read
# as well as run, and a check about what a proc *resets* has to look inside it
# rather than at the file around it.
proc matchBrace {src open} {
    set depth 0
    for {set i $open} {$i < [string length $src]} {incr i} {
        set c [string index $src $i]
        if {$c eq "\{"} { incr depth
        } elseif {$c eq "\}"} { incr depth -1 ; if {$depth == 0} { return $i } }
    }
    return [expr {[string length $src] - 1}]
}
proc procText {src name} {
    set start [string first "proc $name " $src]
    if {$start < 0} { return "" }
    # The argument list first, then the body: the body is the brace that closes
    # second, and a proc that returns only its arg list is not a proc.
    set args [string first "\{" $src $start]
    set close [matchBrace $src $args]
    set body [string first "\{" $src $close]
    return [string range $src $start [matchBrace $src $body]]
}

# A proc lifted by name out of another module, run from the shipped bytes: the
# harness proves the writer that ships, not a copy of it.
proc liftProc {path name} {
    uplevel #0 [procText [readText $path] $name]
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
    variable comments        ;# cursor -> the move's comment (the real writer's)
    variable nags {}         ;# NAGs added to the current position
    variable blunder ""      ;# the last blunder dialog's {message bestMove}, if any
    variable blunderChoice 2 ;# what the dialog returns: 2 keep, 1 take back
    variable fenDigest 0     ;# 1: the fen identifies the line, not just the ply
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

# The line's own name, so two different move orders at the same ply are two
# different positions. The fake board moves no pieces: without this, "e4 e5 h4"
# and "e4 e5 Nf3" would have the same fen, and a takeback could not be seen to
# have re-searched anything.
proc fake::digest {} {
    set sum 0
    foreach m $::fake::moves {
        foreach c [split $m ""] { incr sum [scan $c %c] }
        incr sum [string length $m]
    }
    return $sum
}

# The comments the game has written, as a dict of ply -> text.
proc fake::comments {} { return [array get ::fake::comments] }

# Let the event loop run for a fixed time: a deferred write (the 500 ms coach
# evaluation) needs the clock to pass, not just the transport to be quiet.
proc pause {ms} {
    set ::paused 0
    after $ms set ::paused 1
    vwait ::paused
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
    array unset ::fake::comments
    set ::fake::nags {}
    set ::fake::blunder ""
    set ::fake::blunderChoice 2
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
        fen         {
            # The fake board does not move pieces; it names a position. At the
            # first ply that name is the classic string the transport checks pin.
            # A scenario that needs two different lines at the same ply to be two
            # different positions (a takeback) asks for the line's own name.
            set key "6k1/5ppp/8/8/8/8/5PPP/R5K1"
            if {$::fake::fenDigest && $::fake::cursor > 1} {
                set key "line[fake::digest]"
            }
            return "$key [string index $::fake::side 0] - - 0 $::fake::cursor"
        }
        hash        { return [expr {1000 + $::fake::cursor}] }
        moveNumber  { return [expr {1 + $::fake::cursor / 2}] }
        previousMove - previousMoveNT { return $::fake::prevSAN }
        previousMoveUCI               { return $::fake::prevUCI }
        getComment  {
            if {[info exists ::fake::comments($::fake::cursor)]} {
                return $::fake::comments($::fake::cursor)
            }
            return ""
        }
        setComment  {
            set ::fake::comments($::fake::cursor) [lindex $args 0]
            return 1
        }
        removeNag   { set ::fake::nags {} ; return 1 }
        addNag      { lappend ::fake::nags [lindex $args 0] ; return 1 }
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
namespace eval ::enginelist {}
proc ::enginelist::choose {} { return }
proc tk_messageBox {args} {
    set i [lsearch $args -message]
    if {$i >= 0} { set ::fake::box [lindex $args [expr {$i + 1}]] }
    return ok
}
proc createToplevel {w args} {
    # Model the contract that matters here: createToplevel builds a docking
    # container named .fdock<win> before the toplevel, and createToplevelFinalize
    # removes it on idle. A second play destroys the window and rebuilds it
    # inside one call, so without that idle being pumped the container is still
    # there and the rebuild dies with "window name ... already exists in parent".
    if {[winfo exists $w]} { return $w }
    frame ".fdock[string range $w 1 end]" -container 1
    toplevel $w
    return $w
}
proc applyThemeColor_background {w} { return }
proc setTitle {w title} { catch { wm title $w $title } }
proc createToplevelFinalize {w} {
    bind $w <Destroy> "+if {\[string equal $w %W\]} {
      after idle \"catch { destroy .fdock\[string range $w 1 end\] }\"
    }"
}
proc setWinLocation {w} { return }
proc recordWinSize {w} { return }
array set ::informant {!? 0.3 ?! 0.3 ? 0.8 ?? 1.5 += 0.5 +/- 1.5 +- 2.5 +-- 4.0}

# ------------------------------------------------------------------- the module --
source -encoding utf-8 [file join $root tcl enginecomm.tcl]
source -encoding utf-8 [file join $root tcl tools uci_format.tcl]
source -encoding utf-8 [file join $root tcl tools sergame.tcl]

# storeEvalComment is not the module's: it is tcl/misc.tcl's writer for the
# [%eval x] token, and it is where "the comment written on the move" actually
# happens. It is lifted out of misc.tcl by name rather than sourced with it --
# misc.tcl builds menus and wants the whole application -- and the bytes are the
# shipped ones. The wrapper keeps the record of what the module asked for.
liftProc [file join $root tcl misc.tcl] storeEvalComment
rename storeEvalComment ::fake::realStoreEvalComment
proc storeEvalComment {value} {
    lappend ::fake::stored $value
    ::fake::realStoreEvalComment $value
}

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
# cannot click it. The choice is the scenario's, and what it was asked is kept.
proc ::sergame::blunderDialog {msg bestMoveText} {
    set ::fake::blunder [list $msg $bestMoveText]
    return $::fake::blunderChoice
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

# =============================================================================
# §4b — the game the ported module still plays
#
# §4a proved the substrate: two connections, a reply that continues the game, no
# wait of any kind. What follows is the other half — the behaviour the module
# shipped with, driven through the same fake engine and a fake board: the clock
# the search is given, a takeback, the coach's judgement and its dialog, ponder,
# the comment written on a move, and the four ways a game ends. The last section
# is the second-session rule: an abnormal session, then a normal one on the same
# module.
# =============================================================================

# The fake board names a position by the line that reaches it from here on, so
# three moves that keep the same position would not be three occurrences of it.
# (The draw scenario says so where it seeds the game's history.)
set ::fake::fenDigest 1

# The settings tcl/options.tcl ships, which is what a game starts from: the
# scenarios below change one of them at a time and must not inherit the last.
proc gameDefaults {} {
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
    set ::sergame::wtime 300000
    set ::sergame::btime 300000
    set ::sergame::winc 10000
    set ::sergame::binc 10000
}

# One move by the player, as the game's own loop would see it: the 200 ms poll
# has already set the flag that says it is the player's turn.
proc playerTurn {uci san} {
    set ::sergame::waitPlayerMove 1
    fake::playerMove $uci $san
}

# =============================================================================
puts "\nclocks: the go line, and what each move does to the game clock"
# =============================================================================
gameDefaults
fake::reset
::sergame::play 0
quiet
checkEq "a clock game starts the clocks from the game's own time" \
    [list [::gameclock::getSec 1] [::gameclock::getSec 2]] [list 300 300]

# Three seconds run off White's clock before White moves: the widget counts, and
# the game's record of the clock is the widget's seconds.
set ::fake::gc(c1) [expr {$::fake::gc(c1) - 3}]
playerTurn e2e4 e4
::sergame::engineGo 1
drain 30
checkEq "the search is given the clock as it stands, both sides and both increments" \
    [lindex $::fake::goes(sergamePlayer) end] \
    "go wtime 313000 btime 300000 winc 10000 binc 10000"
checkEq "the mover's increment went on the mover's own clock" \
    [lindex $::fake::added end] "1 10"
checkEq "so White's clock is 3 s of thinking and 10 s of increment on" \
    [::gameclock::getSec 1] 313
checkEq "and the clock that was started for the reply is Black's, untouched" \
    [list [::gameclock::getSec 2] [lindex $::fake::started end]] [list 300 2]

fake::infoLine sergamePlayer 20 "e7e5 g1f3"
set ::fake::gc(c2) [expr {$::fake::gc(c2) - 2}]
fake::best sergamePlayer e7e5 g1f3
drain 60
checkEq "the engine's move went on the board" [lindex $::fake::moves end] "e5"
checkEq "the reply put Black's increment on Black's clock" \
    [lindex $::fake::added end] "2 10"
checkEq "and gave the move back to White, whose clock runs again" \
    [list [::gameclock::getSec 2] [lindex $::fake::started end]] [list 312 1]

playerTurn g1f3 Nf3
::sergame::engineGo 1
drain 30
checkEq "the next search carries both clocks as the game has them" \
    [lindex $::fake::goes(sergamePlayer) end] \
    "go wtime 323000 btime 312000 winc 10000 binc 10000"
endGame

# Each side's own increment, in its own place: the game's clocks are not a
# single number, and the engine must not be told the player's.
gameDefaults
fake::reset
set ::sergame::wtime 180000
set ::sergame::btime 240000
set ::sergame::winc 2000
set ::sergame::binc 3000
::sergame::play 0
quiet
playerTurn e2e4 e4
::sergame::engineGo 1
drain 30
checkEq "two clocks, two increments, one go line" \
    [lindex $::fake::goes(sergamePlayer) end] \
    "go wtime 182000 btime 240000 winc 2000 binc 3000"
checkEq "White's move added White's increment" [lindex $::fake::added end] "1 2"
fake::best sergamePlayer e7e5
drain 60
checkEq "Black's move added Black's increment" [lindex $::fake::added end] "2 3"
checkEq "and Black's clock reads the game's own time plus it" \
    [::gameclock::getSec 2] 243
endGame

# Without a chess clock the game counts up instead, and the search is not given a
# clock at all: it is given the game's seconds per move.
gameDefaults
set ::sergame::useChessClock 0
fake::reset
::sergame::play 0
quiet
checkEq "a game with no chess clock starts its clocks from zero" \
    [list [::gameclock::getSec 1] [::gameclock::getSec 2]] [list 0 0]
playerTurn e2e4 e4
::sergame::engineGo 1
drain 30
checkEq "and the search asks for a fixed time instead of a clock" \
    [lindex $::fake::goes(sergamePlayer) end] "go movetime 3000"
checkEq "with no increment taken, because there is no clock to give one" \
    [llength $::fake::added] 0
endGame

set ::sergame::movetime 1500
fake::reset
::sergame::play 0
quiet
playerTurn e2e4 e4
::sergame::engineGo 1
drain 30
checkEq "and the seconds per move are the game's own" \
    [lindex $::fake::goes(sergamePlayer) end] "go movetime 1500"
endGame

# =============================================================================
puts "\na takeback: the move comes back, and the engine is asked again"
# =============================================================================
gameDefaults
fake::reset
::sergame::play 0
quiet
playerTurn e2e4 e4
::sergame::engineGo 1
drain 30
fake::best sergamePlayer e7e5
drain 60
set movesBefore [llength $::fake::moves]
::sergame::takeBack 290 305
drain 20
checkEq "the move came off the board" [llength $::fake::moves] [expr {$movesBefore - 1}]
checkEq "both clocks came back to the values the caller kept" \
    [list [::gameclock::getSec 1] [::gameclock::getSec 2]] [list 290 305]
checkEq "and the clock of the side to move is the one running" \
    [lindex $::fake::started end] 2
endGame

# The dialog's takeback, in a game with a coach: the move the player should not
# have played comes back, the clocks it used are restored, and the engine is
# asked about the position the corrected line reaches -- not the blunder's.
gameDefaults
fake::reset
set ::sergame::coachIsWatching 1
::sergame::play 0
quiet
playerTurn e2e4 e4
::sergame::engineGo 1
drain 30
fake::infoLine sergamePlayer 0 "e7e5 g1f3"
fake::best sergamePlayer e7e5 g1f3
drain 80
checkEq "the engine's first move is on the board" [lindex $::fake::moves end] "e5"

playerTurn h2h4 h4
::sergame::engineGo 1
drain 30
set blunderFen [sc_pos fen]
set clockAfterToggle [::gameclock::getSec 1]
set ::sergame::livePv "g1f3 d7d5"
fake::infoLine sergamePlayer 180 "d7d5 b1c3"
set ::fake::blunderChoice 1
set ::fake::blunder ""
fake::best sergamePlayer d7d5
drain 80
checkEq "the dialog offered the takeback" [lindex $::fake::blunder 0] \
    [::tr BadMovePlayedTakeBack]
checkEq "and the move went back off the board" [llength $::fake::moves] 2
check "the clock the blunder used was given back" \
    [expr {[::gameclock::getSec 1] < $clockAfterToggle}] \
    "now [::gameclock::getSec 1], was $clockAfterToggle"
checkEq "to the values the game kept when the move was made" \
    [::gameclock::getSec 1] 310
checkEq "the coach was started again on the position that is on the board" \
    [lindex $::fake::goes(sergameCoach) end] "go infinite"
checkEq "and the game is waiting for the player's replacement move" \
    $::sergame::waitPlayerMove 1

# The player plays something else. The engine is asked about the corrected line.
quiet
playerTurn g1f3 Nf3
set correctedFen [sc_pos fen]
set goesBefore [llength $::fake::goes(sergamePlayer)]
::sergame::engineGo 1
drain 30
check "the blunder's position and the corrected one are not the same position" \
    [expr {$correctedFen ne $blunderFen}] "both '$correctedFen'"
checkEq "the engine was asked about the position on the board, not the one it answered before" \
    [lindex [fake::sentMatching sergamePlayer "position fen *"] end] \
    "position fen $correctedFen"
checkEq "and a search really was started from it" \
    [llength $::fake::goes(sergamePlayer)] [expr {$goesBefore + 1}]
endGame

# =============================================================================
puts "\nthe blunder dialog: the threshold it uses, and the move it offers"
# =============================================================================
gameDefaults
fake::reset
set ::sergame::coachIsWatching 1
::sergame::play 0
quiet

# One turn of judgement: the player has just moved, and the engine has answered
# with a score for the position that move reached. The connection's state is what
# the search would have written; what the module does with it is the subject.
proc blunderTurn {prev score {choice 2}} {
    fake::playerMove e2e4 e4
    ::sergame::stSet 1 prevscore $prev
    ::sergame::stSet 1 score $score
    ::sergame::stSet 1 bestmove e7e5
    set ::sergame::playerMoved 1
    set ::sergame::livePv "e5 Nf3 Bc4"
    set ::fake::blunder ""
    set ::fake::blunderChoice $choice
    ::sergame::answer 1
    drain 20
    return $::fake::blunder
}

# The thresholds are the ones the Annotator settings ship: !? 0.3, ? 0.8, ?? 1.5.
set d [blunderTurn 0.0 -0.4]
checkEq "a swing past !? opens the dialog as a dubious move" \
    [lindex $d 0] [::tr DubiousMovePlayedTakeBack]
checkEq "and it offers the first move of the coach's line" [lindex $d 1] "e5"
checkEq "keeping the move plays it" [lindex $::fake::moves end] "e5"

set d [blunderTurn 0.0 -1.0]
checkEq "a swing past ? is a weak move" [lindex $d 0] [::tr WeakMovePlayedTakeBack]
set d [blunderTurn 0.0 -1.8]
checkEq "a swing past ?? is a bad move" [lindex $d 0] [::tr BadMovePlayedTakeBack]
set d [blunderTurn 0.0 -0.2]
checkEq "a swing under the first threshold opens no dialog at all" $d ""
checkEq "and the move is played without a word" [lindex $::fake::moves end] "e5"
endGame

# The same judgement with the colours the other way round: the player is Black,
# so the score that falls is White's, and a *rise* is the player's blunder.
gameDefaults
fake::reset
set ::sergame::playerColor "black"
set ::sergame::coachIsWatching 1
::sergame::play 0
quiet
set ::fake::side black
fake::playerMove d7d5 d5
::sergame::stSet 1 prevscore 0.0
::sergame::stSet 1 score 1.2
::sergame::stSet 1 bestmove e2e4
set ::sergame::playerMoved 1
set ::sergame::livePv "d2d4 g1f3"
set ::fake::blunder ""
set ::fake::blunderChoice 2
::sergame::answer 1
drain 20
checkEq "with the engine playing White, a rise is the player's blunder" \
    [lindex $::fake::blunder 0] [::tr WeakMovePlayedTakeBack]
checkEq "and the move offered is White's, from the coach's line" \
    [lindex $::fake::blunder 1] "d2d4"
endGame

# =============================================================================
puts "\nthe coach's warning and the live score follow its reply"
# =============================================================================
gameDefaults
fake::reset
set ::sergame::coachIsWatching 1
::sergame::play 0
quiet
::sergame::stSet 2 score ""
set ::sergame::lscore {}
::sergame::updateAnalysisText
checkEq "with no coach line yet the row says so" \
    $::sergame::blunderWarningLabel [::tr Noinfo]
checkEq "and there is no score to show" $::sergame::scoreLabel ""

# The coach has evaluated the position the engine's last move reached, and the
# game's own record of the one before it is 0.0. This row is about the *engine's*
# move: with the engine playing Black, a score that rises for White is a move the
# engine should not have played. (The dialog in the section above is the mirror
# of it -- the player's own move -- so the signs are opposite, as they must be.)
::sergame::stSet 2 score 1.2
set ::sergame::lscore {0.0}
::sergame::updateAnalysisText
checkEq "a swing past the threshold is a blunder, with its value" \
    $::sergame::blunderWarningLabel "blunder    +1.20"
checkEq "the value is pending, which is what the label is for" \
    $::sergame::blunderpending 1
checkEq "and the NAG it picked for the engine's move" $::sergame::coachNag "?"
checkEq "the NAG reached the move" $::fake::nags {?}
checkEq "the row is coloured for it" \
    [.coachWin.finformations.l1 cget -background] "LightCoral"
checkEq "the live score is the coach's" $::sergame::scoreLabel "Score : 1.2"

::sergame::stSet 2 score 0.4
::sergame::updateAnalysisText
checkEq "a swing under the threshold is no blunder" \
    $::sergame::blunderWarningLabel [::tr Noblunder]
checkEq "the row goes back to its own colour" \
    [.coachWin.finformations.l1 cget -background] "linen"
checkEq "and the NAG comes off the move" $::sergame::coachNag ""
checkEq "so the move has no NAGs left" $::fake::nags {}

# The game's own slider, not a constant: at 1.5 the same 1.2 swing is no blunder.
set ::sergame::threshold 1.5
::sergame::stSet 2 score 1.2
::sergame::updateAnalysisText
checkEq "the warning uses the game's own threshold" \
    $::sergame::blunderWarningLabel [::tr Noblunder]
set ::sergame::threshold 0.9

set ::sergame::showblundervalue 0
::sergame::stSet 2 score 1.2
::sergame::updateAnalysisText
checkEq "with the value switched off the label is the word alone" \
    $::sergame::blunderWarningLabel "[::tr blunder] !"
set ::sergame::showevaluation 0
::sergame::updateAnalysisText
checkEq "and the score line goes with its setting" $::sergame::scoreLabel ""

# The label is not set by the harness here: it is what the coach's own reply
# wrote on its connection, read back through the display's own code.
gameDefaults
fake::reset
set ::sergame::coachIsWatching 1
::sergame::play 0
quiet
::sergame::startAnalyze
drain 20
fake::infoLine sergameCoach -95 "g1f3 d7d5"
drain 20
checkEq "the coach's reply is the score on its connection" \
    [::sergame::st 2 score] -0.95
::sergame::updateAnalysisText
checkEq "and the one the display shows" $::sergame::scoreLabel "Score : -0.95"
endGame

# =============================================================================
puts "\nponder: a hit reuses the line, and a line the player declines does not"
# =============================================================================
gameDefaults
set ::sergame::ponder 1
fake::reset
::sergame::play 0
quiet
playerTurn e2e4 e4
::sergame::engineGo 1
drain 30
fake::infoLine sergamePlayer 25 "e7e5 g1f3"
fake::best sergamePlayer e7e5 g1f3
drain 80
checkEq "the engine's move, and the move it expects back" \
    [list [lindex $::fake::moves end] [::sergame::st 1 ponder]] [list e5 g1f3]
checkEq "a search was started from the move it expects" \
    [llength [fake::sentMatching sergamePlayer "go ponder *"]] 1
checkEq "with the same limits, in the same places" \
    [lindex [fake::sentMatching sergamePlayer "go ponder *"] end] \
    "go ponder wtime 310000 btime 310000 winc 10000 binc 10000"
checkIn "from the line it named" $::fake::sent(sergamePlayer) "moves g1f3"

# The player plays exactly the move it pondered: the search in flight is that
# move's, so there is nothing to start.
playerTurn g1f3 Nf3
set goesBefore [llength $::fake::goes(sergamePlayer)]
::sergame::engineGo 1
drain 30
checkIn "the engine was told the line it pondered is the one played" \
    $::fake::sent(sergamePlayer) "ponderhit"
checkEq "and no second search was sent" \
    [llength $::fake::goes(sergamePlayer)] $goesBefore
fake::best sergamePlayer b8c6 g8f6
drain 80
checkEq "the answer to the ponder search is the move the game plays" \
    [lindex $::fake::moves end] "Nc6"

# The player declines the line. A search replaces the ponder search, and the
# answer it produces is the game's move -- not the abandoned one.
playerTurn d2d4 d4
set goesBefore [llength $::fake::goes(sergamePlayer)]
set pondersBefore [llength [fake::sentMatching sergamePlayer "go ponder *"]]
::sergame::engineGo 1
drain 60
checkEq "a new search was started instead of a hit" \
    [llength $::fake::goes(sergamePlayer)] [expr {$goesBefore + 1}]
checkEq "and no ponder search was started for a move nobody played" \
    [llength [fake::sentMatching sergamePlayer "go ponder *"]] $pondersBefore
checkEq "the move it did not play was not played" [lindex $::fake::moves end] "d4"
endGame

# =============================================================================
puts "\nstoring evaluations: the comment written, on the move it belongs to"
# =============================================================================
gameDefaults
set ::sergame::storeEval 1
fake::reset
set ::sergame::coachIsWatching 1
::sergame::play 0
quiet
::sergame::startAnalyze
drain 20
fake::infoLine sergameCoach -40 "g1f3 d7d5"
drain 20
checkEq "the coach's line reached its connection" [::sergame::st 2 score] -0.4

playerTurn e2e4 e4
checkEq "the move freezes the coach's line before the board changes" \
    [::sergame::callback premove] 0
checkEq "and keeps it" $::sergame::liveScore -0.4
::sergame::engineGo 1
drain 30
fake::best sergamePlayer e7e5
drain 80
checkEq "the player's move carries the coach's evaluation, written by tcl/misc.tcl" \
    [dict get [::fake::comments] 1] "\[%eval -0.4\]"

# The engine's move is written half a second later, once the coach has had time
# to evaluate the position the move reached.
fake::infoLine sergameCoach -25 "g1f3 d7d5"
drain 20
pause 600
checkEq "and the engine's move its own, from the coach's new line" \
    [dict get [::fake::comments] 2] "\[%eval -0.25\]"
endGame

# Nothing is written unless the game was asked to write something.
gameDefaults
set ::sergame::showevaluation 0
fake::reset
::sergame::play 0
quiet
playerTurn e2e4 e4
::sergame::engineGo 1
drain 30
fake::best sergamePlayer e7e5
drain 80
checkEq "with no evaluation setting, no comment is written at all" \
    [::fake::comments] {}

# All-moves mode writes on both, and it does not need the coach.
gameDefaults
set ::sergame::storeEvalAll 1
set ::sergame::showevaluation 0
fake::reset
::sergame::play 0
quiet
playerTurn e2e4 e4
::sergame::engineGo 1
drain 30
fake::infoLine sergamePlayer 35 "e7e5"
fake::best sergamePlayer e7e5
drain 80
# A score is White's, so a black-to-move +35 is -0.35: both comments carry the
# engine's own evaluation of the position the move reached.
checkEq "all-moves mode writes on the player's move" \
    [dict get [::fake::comments] 1] "\[%eval -0.35\]"
checkEq "and on the engine's" [dict get [::fake::comments] 2] "\[%eval -0.35\]"
endGame

# =============================================================================
puts "\nan engine that answers without a line still gets its move played"
# =============================================================================
# Found by this card: a connection's score is cleared when its search starts,
# which the old shared array never did, so an engine that answers with no info
# line (or only a bound, or only multiPV lines -- all filtered before the score)
# left "" where the old code left the previous number, and the blunder comparison
# subtracted it. The answer, and the game, went with it.
gameDefaults
fake::reset
set ::sergame::coachIsWatching 1
set bgerrors [llength $::background]
::sergame::play 0
quiet
playerTurn e2e4 e4
::sergame::engineGo 1
drain 30
fake::best sergamePlayer e7e5
drain 80
checkEq "the move was played with no line to judge" [lindex $::fake::moves end] "e5"
checkEq "and nothing failed in the background" [llength $::background] $bgerrors
endGame

# =============================================================================
puts "\nhow a game ends: mate, resignation, a draw (and a dead engine, above)"
# =============================================================================
gameDefaults
fake::reset
::sergame::play 0
quiet
# Mate: the move just played ends in '#', and there is no move to ask for. (§4a's
# "an engine that dies mid-search" section is the fourth way a game ends.)
set ::fake::prevSAN "Ra8#"
set goesBefore [llength $::fake::goes(sergamePlayer)]
set stoppedBefore $::fake::stopped
checkEq "a mating move is the end of the game" [::sergame::endOfGame] 1
::sergame::engineGo 1
drain 20
checkEq "so the engine is not asked for a move" \
    [llength $::fake::goes(sergamePlayer)] $goesBefore
check "and the clocks stopped with the game" [expr {$::fake::stopped > $stoppedBefore}]
endGame

# Resignation: the coach says the player is winning by more than the resign
# threshold move after move, and on the fourth the game calls it a resignation.
gameDefaults
fake::reset
set ::sergame::coachIsWatching 1
::sergame::play 0
quiet
set ::fake::box ""
for {set i 0} {$i < 4} {incr i} {
    fake::playerMove e2e4 e4
    set ::sergame::liveScore 5.0
    ::sergame::stSet 1 score 0.0
    ::sergame::stSet 1 prevscore 0.0
    ::sergame::stSet 1 bestmove e7e5
    set ::sergame::playerMoved 0
    ::sergame::answer 1
    drain 20
}
checkEq "the fourth winning score is the engine's resignation" \
    $::fake::box "[::tr Iresign] - [::tr ResultSaved]"
checkEq "the game records the result it was won by" [lindex $::fake::tags end] "1-0"
checkEq "and saves it" [llength $::fake::saved] 1
checkEq "with the count ready for the next game" $::sergame::resignCount 0
endGame

# A draw by threefold repetition. The fake board names a position by the line
# that reached it, so a repetition cannot be played into; the game's own history
# is seeded instead: the position the next move reaches has occurred twice
# already, with another position between the occurrences.
gameDefaults
fake::reset
::sergame::play 0
quiet
playerTurn e2e4 e4
set elt [lrange [split [sc_pos fen]] 0 3]
set ::sergame::lFen [list $elt $elt "some other position w - -"]
set ::fake::box ""
set goesBefore [llength $::fake::goes(sergamePlayer)]
::sergame::engineGo 1
drain 20
checkEq "a third occurrence of a position is a draw, and the player is told" \
    $::fake::box [::tr Draw]
checkEq "and no search is started for a drawn game" \
    [llength $::fake::goes(sergamePlayer)] $goesBefore
endGame

# =============================================================================
puts "\nthe second session: after an abnormal one, the module is still a game"
# =============================================================================
gameDefaults
fake::reset
::sergame::play 0
quiet
playerTurn e2e4 e4
::sergame::engineGo 1
drain 20
fake::die sergamePlayer
drain 100
checkEq "the abnormal session ended the way one does" $::fake::playMode ""

# A normal session on the same module, the same connection ids, opened straight
# after it. Everything below is what a poisoned module would fail: a connection
# that will not hold, a state left over from the dead engine, a search that is
# never sent, a coach that never analyses, a judgement that never runs.
fake::reset
set ::sergame::coachIsWatching 1
set rc [catch { ::sergame::play 0 } err]
checkEq "a later session opens" $rc 0 $err
quiet
drain 80
check "the opponent's connection is open again" [::engine::connected sergamePlayer]
check "and the coach's" [::engine::connected sergameCoach]
checkEq "on a connection with no score from the dead engine" \
    [::sergame::st 1 score] 0.0
checkEq "no move it never made" [::sergame::st 1 bestmove] ""
checkEq "no ponder flag" [::sergame::st 1 ponder] ""
checkEq "and a search counter of its own" [::sergame::st 1 searches] 0

::sergame::startAnalyze
drain 20
fake::infoLine sergameCoach -60 "g1f3"
drain 20
checkEq "it analyses the position on the board" [::sergame::st 2 score] -0.6

playerTurn e2e4 e4
::sergame::engineGo 1
drain 30
fake::infoLine sergamePlayer 200 "e7e5"
set ::fake::blunder ""
set ::fake::blunderChoice 2
fake::best sergamePlayer e7e5
drain 80
checkEq "it plays the engine's move" [lindex $::fake::moves end] "e5"
checkEq "and judges the player's" [lindex $::fake::blunder 0] \
    [::tr BadMovePlayedTakeBack]
endGame

# The other abnormal start: a preset that cannot start at all. The id is the
# same one, and it must be usable afterwards.
gameDefaults
fake::reset
set ::fake::box ""
::sergame::play 2
quiet
check "a session whose engine never started holds no connection" \
    [expr {![::engine::connected sergamePlayer]}]
set rc [catch { ::sergame::play 0 } err]
checkEq "and the next session opens on the same id" $rc 0 $err
quiet
drain 40
check "connected" [::engine::connected sergamePlayer]
playerTurn e2e4 e4
::sergame::engineGo 1
drain 30
checkEq "and asks it for a move" [llength $::fake::goes(sergamePlayer)] 1
fake::best sergamePlayer e7e5
drain 60
checkEq "which is played" [lindex $::fake::moves end] "e5"
endGame

# The shape the second-session rule is really about (#437 §3b shipped it as
# `engineLost`): a reset that lands in a procedure-local -- a `set` with no
# `::sergame::` in front, in a proc that declares no `variable` -- passes every
# single-session test and poisons the module for the rest of the process. Each
# name a game accumulates is reset by the proc that starts one, by name.
set playSrc [procText $sergameSrc play]
check "the module's play proc was found to read" [expr {[string length $playSrc] > 0}]
foreach name {lFen lscore liveScore livePv playerMoved resignCount \
              lastblundervalue blunderpending blunderWarningLabel scoreLabel coachNag} {
    check "play resets ::sergame::$name" [regexp -- "set ::sergame::$name " $playSrc]
}

# Nothing in the run failed where a failure would be silent: a background error
# is a callback (a reply, a timer) that raised, which is how this card's own bug
# showed up before it was a failed check.
checkEq "no background error anywhere in this run" $::background {}

##############################################################################
puts "\na close always drops the connection's config (the bug after a crash)"
# The stub door above is one door wide and keeps no ::enginecfg entry, so it
# cannot see this one. The real door answers 1 without connecting while
# engConfig_$id exists, and a close that threw before its unset left that entry
# behind: the game after an engine crash had no engine until a second Play.
rename ::engineNoWin::initEngine  ::engineNoWin_initEngine_stub
rename ::engineNoWin::closeEngine ::engineNoWin_closeEngine_stub
source -encoding utf-8 [file join $root tcl tools enginenowin.tcl]
# The harness stubs the engine list, not the config array: create its namespace.
namespace eval ::enginecfg {}
set ::enginecfg::engConfig_probe {Stockfish /usr/games/stockfish {} {} 0 0 1 {} {}}
rename ::engine::close ::engine_close_real
proc ::engine::close {id} { error "can not find channel named file9" }
set err [catch { ::engineNoWin::closeEngine probe } msg]
check "a close whose channel is already gone returns cleanly" [expr {$err == 0}]
check "and still leaves no config behind" \
    [expr {![info exists ::enginecfg::engConfig_probe]}]
rename ::engine::close {}
rename ::engine_close_real ::engine::close
rename ::engineNoWin::closeEngine {}
rename ::engineNoWin_closeEngine_stub ::engineNoWin::closeEngine
rename ::engineNoWin::initEngine {}
rename ::engineNoWin_initEngine_stub ::engineNoWin::initEngine

##############################################################################
puts "\na second Play in one session finds its window"
# createToplevel builds a docking container and createToplevelFinalize removes
# it on idle. play destroys the old game window and rebuilds it inside one
# call, so the idle never ran between them and the rebuild died with
#   window name ".fdockcoachWin" already exists in parent
# - engine up, no interface, clocks never armed. Two Plays in a row prove it.
catch { destroy .coachWin }
catch { destroy .fdockcoachWin }
set playErr1 [catch { ::sergame::play 1 } e1]
check "the first Play builds the game window" \
    [expr {$playErr1 == 0 && [winfo exists .coachWin]}]
set playErr2 [catch { ::sergame::play 1 } e2]
check "a second Play in the same session builds it again" \
    [expr {$playErr2 == 0 && [winfo exists .coachWin]}]
if {$playErr2} { puts "    (second Play said: $e2)" }
check "and leaves exactly one game window" \
    [expr {[llength [winfo children .]] == [llength [lsort -unique [winfo children .]]]}]
catch { destroy .coachWin }
catch { destroy .fdockcoachWin }

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
