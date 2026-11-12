#!/usr/bin/env wish
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# tactics_trainer.tcl -- the Tactics puzzle trainer after #437 §3b, on its own
# ::engineNoWin connection.
#
#   wish tests/tcl/tactics_trainer.tcl
#   xvfb-run -a wish tests/tcl/tactics_trainer.tcl     (no display)
#
# §3a kept the Tactics entry in the Training submenu and proved the trainer
# still starts, loads a puzzle, referees an answer and stops. It did that with
# the old engine layer stubbed: ::uci::startEngine on slot 5, ::uci::sendToEngine
# and the Analysis window's ::analysis(multiPV5) row. §3b takes that layer away
# from the trainer -- it owns a ::engineNoWin connection under the literal id
# tacticsTrainer, asks for one line on it, streams the line out of
# ::enginecomm's replies and converts it with the tree's formatter. This harness
# drives exactly that: the engine layer is stubbed, but what the trainer sends,
# what it keeps out of the replies and what it does with the line are real.
#
# The chess database is stubbed too (this file owns neither layer). The preset
# is shaped like the ones the engine dialog builds (name, command, args, dir,
# ..., UCI flag at index 7, which is the field ::tactics::config filters on), so
# the trainer is started the way the menu starts it, by preset index.

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
proc checkIn {label haystack needle} {
    check $label [expr {[string first $needle $haystack] >= 0}] "in '$haystack' want '$needle'"
}

set root [file normalize [file join [file dirname [info script]] .. ..]]

# ------------------------------------------------------------------ harness state --
namespace eval fake {
    variable log {}          ;# one line per stubbed engine/core call
    variable cursor 0
    variable moves {}        ;# SAN of the line the fake game holds
    variable side white
    variable flipped 0
    variable comment ""
    variable tags {}
    variable saved {}
    variable previousMove ""
    variable nextGame 1
    variable box ""
    variable playMode ""
    variable flips {}
    variable filterReset 0
    variable analysisTime 1
}
proc fake::log {what} { lappend ::fake::log $what }
proc fake::count {pattern} {
    set n 0
    foreach e $::fake::log { if {[string match $pattern $e]} { incr n } }
    return $n
}

# ---------------------------------------------------------------- the strings --
# english.tcl is the catalogue: the harness reads the real labels, so a page or
# a menu key renamed by another change shows up here rather than as an error.
array set ::tr {}
proc translate {lang key args} {
    set ::tr($key) [lindex $args 0]
}
proc menuText {lang key text args} { set ::tr($key) $text }
source -encoding utf-8 [file join $root tcl lang english.tcl]
# The catalogue is a proc (setLanguage_E): sourcing it only defines the strings.
# A couple of its messages interpolate application globals.
set ::optionsFile ""
setLanguage_E
proc tr {tag args} {
    if {[info exists ::tr($tag)]} { return $::tr($tag) }
    if {[llength $args]} { return [lindex $args 0] }
    return $tag
}

# The trainer also reads $::tr(Key) directly, which bypasses the proc above and
# errors on a key the catalogue does not carry. The C translation layer falls
# back to the key's own name; fill the same default here for every key
# tactics.tcl actually reads, so a newly added label shows as a bare key in a
# check rather than as a startup error.
proc readText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation auto
    set text [read $f]
    close $f
    return $text
}
set tacticsSrc [readText [file join $root tcl tools tactics.tcl]]
foreach {all key} [regexp -all -inline {\$::tr\((\w+)\)} $tacticsSrc] {
    if {![info exists ::tr($key)]} { set ::tr($key) $key }
}

# ------------------------------------------------------------- the engine layer --
# ::engineNoWin is the layer this phase keeps: the trainer opens its own
# connection on it, sends Go/StopGo/SetOptions and reads InfoPV,
# InfoDisconnected. What the trainer owns is which connection it opens, which
# messages it sends and what it makes of the replies, so that is what is
# recorded.
namespace eval ::engineNoWin {}
namespace eval ::engine {}
namespace eval ::enginecfg {}
namespace eval ::uci {}

set ::engConn {}          ;# {id preset} of the connection the trainer opened
set ::engSent {}          ;# one {id message data} per ::engine::send
set ::engClosed 0         ;# times the trainer closed a connection
set ::engCb ""            ;# the callback ::engineNoWin was given
set ::engCfgWrites 0      ;# ::enginecfg::setOption calls (must stay 0)
set ::engFail ""          ;# preset whose initEngine raises

proc ::engineNoWin::initEngine {id name cb {options ""}} {
    if {$name eq $::engFail} { error "the preset $name cannot be started" }
    set ::engConn [list $id $name]
    set ::engCb $cb
    fake::log "initEngine $id $name"
    return 1
}
proc ::engineNoWin::closeEngine {id} {
    incr ::engClosed
    fake::log "closeEngine $id"
    return
}
proc ::engine::send {id msg {data ""}} {
    lappend ::engSent [list $id $msg $data]
    fake::log "send $id $msg"
    return
}
# ::enginecfg::setOption writes the preset and restarts the user's own search:
# the trainer's MultiPV belongs to its own connection.
proc ::enginecfg::setOption {args} { incr ::engCfgWrites }

# The tree's PV formatter (::ucifmt:: after #437 §6). The trainer hands it the
# engine's UCI line and the position it searched; the map below is the SAN the
# real formatter produces for those moves.
array set ::SAN {
    e2e4 e4 e7e5 e5 d1h5 Qh5 g8f6 Nf6 h5f7 Qxf7 f1c4 Bc4 b8c6 Nc6 a2a3 a3
}
proc ::uci::formatPv {pv fen} {
    fake::log "formatPv [join $pv] | $fen"
    set out {}
    foreach u $pv {
        if {[info exists ::SAN($u)]} { lappend out $::SAN($u) } else { lappend out $u }
    }
    return [join $out " "]
}

# What the trainer sent of a kind, in order.
proc engSent {msg} {
    set out {}
    foreach e $::engSent {
        if {[lindex $e 1] eq $msg} { lappend out [lindex $e 2] }
    }
    return $out
}
# One ::enginecomm reply, as the connection would deliver it.
proc engReply {msg} { {*}$::engCb $msg }
# An InfoPV line in ::enginecomm's shape:
#   multipv depth seldepth nodes nps hashfull tbhits time score scoreType wdl pv
proc engInfo {multipv depth score scoreType pv} {
    engReply [list InfoPV [list $multipv $depth "" "" "" "" "" 100 \
        $score $scoreType "" $pv]]
}

# ----------------------------------------------------------------- the presets --
# The engine dialog builds these entries from the engine configuration; the
# trainer only ever sees the list. Field 7 is "is UCI", which ::tactics::config
# filters on, and field 3 is the working directory initEngine would cd into.
set ::engines(list) [list \
    [list "Stockfish" "/usr/games/stockfish" "" "/usr/share/stockfish" "" 0 0 1] \
    [list "Not-UCI" "/usr/games/xboard" "" "/usr/share/xboard" "" 0 0 0] \
    [list "Broken" "/nonexistent/engine" "" "" "" 0 0 1]]

# ------------------------------------------------------------ the chess database --
set ::curr_db 1
proc main_isFlipped {} { return $::fake::flipped }
proc sc_pos {sub args} {
    switch -- $sub {
        isAt {
            switch -- [lindex $args 0] {
                start { return [expr {$::fake::cursor == 0}] }
                end   { return [expr {$::fake::cursor >= [llength $::fake::moves]}] }
            }
        }
        side { return $::fake::side }
        fen {
            # The trainer compares FENs to notice a move it did not expect. The
            # side to move is in it: a score is turned for White by that field.
            return "6k1/5ppp/8/8/8/8/5PPP/R5K1 $::fake::side - - 0 $::fake::cursor"
        }
        getComment { return $::fake::comment }
        previousMove - previousMoveNT { return $::fake::previousMove }
    }
    return ""
}
proc sc_move {sub args} {
    switch -- $sub {
        forward { incr ::fake::cursor }
        back {
            incr ::fake::cursor -1
            if {$::fake::cursor < 0} { set ::fake::cursor 0 }
            set ::fake::previousMove ""
            fake::log "move back"
        }
        addSan {
            lappend ::fake::moves [lindex $args 0]
            set ::fake::cursor [llength $::fake::moves]
            fake::log "addSan [lindex $args 0]"
        }
    }
    return 1
}
proc sc_var {args} { return "" }
proc sc_game {sub args} {
    switch -- $sub {
        info {
            switch -- [lindex $args 0] {
                previousMove   { return $::fake::previousMove }
                previousMoveNT { return $::fake::previousMove }
                number         { return 1 }
            }
        }
        tags {
            # tags set -site <text>
            set ::fake::tags [lindex $args 2]
            fake::log "tags site=[lindex $args 2]"
        }
        save { lappend ::fake::saved [lindex $args 0] ; fake::log "save" }
        load { fake::log "load [lindex $args 0]" }
    }
    return 1
}
proc sc_filter {sub args} {
    switch -- $sub {
        search { fake::log "filter search" }
        next   { set n $::fake::nextGame ; set ::fake::nextGame 0 ; return $n }
        reset  { set ::fake::filterReset 1 ; fake::log "filter reset" }
    }
    return 0
}
proc sc_base {sub args} { return 1 }
namespace eval ::notify {}
proc ::notify::GameChanged {args} {}
proc ::notify::filter {args} {}
namespace eval ::board {}
proc ::board::flipAuto {w args} {
    # The trainer flips the board so the player is at the bottom; that flag is
    # what ::tactics::isPlayerTurn reads through main_isFlipped.
    set ::fake::flipped [expr {[string is true -strict [lindex $args 0]]}]
    lappend ::fake::flips auto
    fake::log "flipAuto $args"
}
proc ::board::flip {w} {
    set ::fake::flipped [expr {!$::fake::flipped}]
    lappend ::fake::flips flip
}
namespace eval ::gameclock {}
proc ::gameclock::new {args} {}
proc ::gameclock::reset {n} {}
proc ::gameclock::start {n} {}
proc ::gameclock::stop {n} {}
namespace eval ::file {}
proc ::file::OpenOrSwitch {fname} {
    fake::log "openBase $fname"
    # A connect can fail asynchronously; if the test asked for it, the engine is
    # declared gone while createWin is still loading the base.
    if {[info exists ::fake::dropDuringLoad] && $::fake::dropDuringLoad} {
        set ::fake::dropDuringLoad 0
        engReply {InfoDisconnected {}}
    }
    return 0
}
proc ::setPlayMode {mode} { set ::fake::playMode $mode ; fake::log "playMode '$mode'" }
proc progressWindow {args} {}
proc closeProgressWindow {} {}
proc updateBoard {args} {}
proc updateStatusBar {} {}
proc updateTitle {} {}
proc helpWindow {args} {}
proc tk_messageBox {args} {
    set i [lsearch $args -message]
    if {$i >= 0} { set ::fake::box [lindex $args [expr {$i + 1}]] }
    fake::log "messageBox $::fake::box"
    return ok
}
proc createToplevel {w args} {
    # The docking container is not built here; the trainer only needs a real
    # window whose Destroy binding fires ::tactics::endTraining.
    if {![winfo exists $w]} { toplevel $w }
    fake::log "createToplevel $w"
}
proc setTitle {w title} { wm title $w $title }
proc createToplevelFinalize {w} {}

# ------------------------------------------------------------------- the module --
source -encoding utf-8 [file join $root tcl tools tactics.tcl]

# The main window the trainer takes focus back to, and the analysis time it
# arms its timer with.
frame .main
set ::tactics::analysisTime 1

# A helper: run the event loop for a while so after-timers can fire.
proc pump {ms} {
    set ::pump_done 0
    after $ms { set ::pump_done 1 }
    vwait ::pump_done
}

puts "\nstart (::tactics::createWin, preset 0)"
set ::fake::moves {}
set ::fake::cursor 0
set ::fake::side white
::tactics::createWin 1 0
check "the trainer window exists" [winfo exists .tacticsWin]
checkEq "the engine was opened by its preset's name" [lindex $::engConn 1] Stockfish
checkEq "on the trainer's own connection" [lindex $::engConn 0] tacticsTrainer
checkEq "the connection id is the documented literal" $::tactics::engineId tacticsTrainer
checkEq "and it is not an engine slot" [string is digit -strict $::tactics::engineId] 0
check "one line was asked for on that connection" \
    [expr {[string first "MultiPV 1" [lindex [engSent SetOptions] 0]] >= 0}]
check "and never through the preset" [expr {$::engCfgWrites == 0}]
check "the game was searched for unsolved puzzles" \
    [expr {[fake::count "filter search"] == 1}]
check "the play mode is the trainer's callback" \
    [expr {$::fake::playMode eq "::tactics::callback"}]
set go [engSent Go]
check "one Go was sent" [expr {[llength $go] == 1}]
check "it carries the position it searches" \
    [expr {[string first "position fen 6k1/5ppp/8/8/8/8/5PPP/R5K1 white" [lindex $go 0]] >= 0}]
check "and the infinite limit, in the same message" \
    [expr {[string first "infinite" [lindex $go 0]] >= 0}]
checkEq "the trainer clock label is the thinking text" \
    $::tactics::infoEngineLabel "[::tr Thinking] ..."
check "the analysis timer is armed (analyse mode on)" \
    [expr {$::tactics::analysisEngine(analyzeMode) == 1}]

puts "\nthe live line, then the timer (::tactics::stopAnalyze)"
engInfo 1 20 35 cp {e2e4 e7e5 d1h5}
engInfo 1 24 2 mate {e2e4 e7e5 d1h5 g8f6 h5f7}
check "the connection's line is kept while it streams" \
    [expr {[dict get $::tactics::search pv] eq "e2e4 e7e5 d1h5 g8f6 h5f7"}]
pump 1400
check "the analysis timer expired and stopped the engine" \
    [expr {$::tactics::analysisEngine(analyzeMode) == 0}]
check "the engine was told to stop" [expr {[llength [engSent StopGo]] == 1}]
checkEq "the score of the last line was kept, a mate as White sees it" \
    $::tactics::analysisEngine(score) 327.64
checkEq "the line was converted with the tree's formatter" \
    $::tactics::analysisEngine(moves) {e4 e5 Qh5 Nf6 Qxf7}
check "the formatter got the UCI line and the searched position" \
    [expr {[fake::count "formatPv e2e4 e7e5 d1h5 g8f6 h5f7 | 6k1/5ppp/8/8/8/8/5PPP/R5K1 white*"] == 1}]
checkEq "the timer expiry is shown to the user" \
    $::tactics::infoEngineLabel $::tr(AnalyzeDone)

puts "\na score is White's, as the referee reads it"
checkEq "a cp score is the engine's own" \
    [::tactics::whiteScore 30 cp {6k1/8/8/8/8/8/5PPP/R5K1 w - - 0 1}] 0.3
checkEq "a Black-to-move cp score is mirrored" \
    [::tactics::whiteScore 30 cp {6k1/8/8/8/8/8/5PPP/R5K1 b - - 0 1}] -0.3
checkEq "a mate for the side to move is the sentinel" \
    [::tactics::whiteScore 2 mate {6k1/8/8/8/8/8/5PPP/R5K1 w - - 0 1}] 327.64
checkEq "a mate against the side to move is negative" \
    [::tactics::whiteScore -2 mate {6k1/8/8/8/8/8/5PPP/R5K1 w - - 0 1}] -327.63
checkEq "and a Black-to-move mate is White's" \
    [::tactics::whiteScore -2 mate {6k1/8/8/8/8/8/5PPP/R5K1 b - - 0 1}] 327.63
# MultiPV 2 is not the line the referee reads.
set ::tactics::prevFen [sc_pos fen]
engInfo 2 26 900 cp {b8c6 f1c4}
check "a second MultiPV slot does not replace the best line" \
    [expr {[dict get $::tactics::search pv] eq "e2e4 e7e5 d1h5 g8f6 h5f7"}]

puts "\nright answer (::tactics::mainLoop -> solved)"
# The player played what the engine expected: prevLine's reply move.
set ::tactics::prevLine "Qh5 Nf6 Qxf7"
set ::tactics::prevScore 35
set ::fake::previousMove "Nf6"
set ::fake::side black
set ::fake::moves {Nf6}
set ::fake::cursor 1
set ::fake::tags ""
set ::fake::box ""
set ::fake::saved {}
set ::tactics::analysisEngine(moves) "Qh5 Nf6 Qxf7"
set ::tactics::analysisEngine(score) 35
set ::tactics::solved "problem solved"
set ::tactics::failed "problem failed"
# The reply to the player's move arrives while mainLoop waits for the timer.
after 200 { engInfo 1 22 900 cp {h5f7} }
::tactics::mainLoop
# mainLoop polls: it arms itself again for the next second. The verdict is in,
# so stop the poll before it judges the same position twice.
catch { after cancel ::tactics::mainLoop }
pump 100
checkEq "the puzzle is marked solved" $::fake::tags $::tactics::solved
check "the solved game was saved" [expr {[llength $::fake::saved] >= 1}]
check "the engine's next move was played on the board" \
    [expr {[fake::count "addSan *"] >= 1}]
checkEq "no complaint was shown" $::fake::box ""

puts "\nwrong answer (::tactics::mainLoop -> failed)"
set ::fake::tags ""
set ::fake::box ""
set ::fake::saved {}
set ::tactics::prevLine "Qh5 Nf6 Qxf7#"
set ::tactics::prevScore 35
set ::fake::previousMove "a3"
set ::fake::side black
set ::fake::moves {a3}
set ::fake::cursor 1
set ::tactics::analysisEngine(moves) "Qh5 Nf6 Qxf7#"
set ::tactics::analysisEngine(score) 35
after 200 { engInfo 1 22 900 cp {g8f6 h5f7} }
::tactics::mainLoop
catch { after cancel ::tactics::mainLoop }
pump 100
checkEq "the puzzle is marked failed" $::fake::tags $::tactics::failed
checkIn "the missed line was reported to the user" $::fake::box $::tr(BestSolutionNotFound)
check "the bad move was taken back" [expr {[fake::count "move back"] >= 1}]
check "the failed game was not saved" [expr {[llength $::fake::saved] == 0}]

puts "\nstop (destroy the window)"
# createWin opened by closing the id it is about to reuse, so count from here.
set closedBefore [fake::count "closeEngine tacticsTrainer"]
destroy .tacticsWin
pump 200
check "the window is gone" [expr {![winfo exists .tacticsWin]}]
check "the trainer's connection was closed, not an engine slot" \
    [expr {[fake::count "closeEngine tacticsTrainer"] == $closedBefore + 1}]
checkEq "the play mode was released" $::fake::playMode ""
check "the database filter was reset" [expr {$::fake::filterReset == 1}]

puts "\nthe engine dies under the puzzle"
set ::fake::box ""
set closedBefore [fake::count "closeEngine tacticsTrainer"]
::tactics::createWin 1 0
check "a second session opens a second connection" \
    [expr {[winfo exists .tacticsWin] && [fake::count "initEngine tacticsTrainer Stockfish"] == 2}]
engReply {InfoDisconnected {}}
pump 100
check "the window closes rather than wait for a line that is over" \
    [expr {![winfo exists .tacticsWin]}]
checkIn "the user is told which engine stopped" $::fake::box Stockfish
checkIn "with the message the catalogues carry" $::fake::box \
    [format [::tr TacticsEngineGone] Stockfish]
check "the engine that died is closed too" \
    [expr {[fake::count "closeEngine tacticsTrainer"] == $closedBefore + 2}]
checkEq "the play mode is released again" $::fake::playMode ""

puts "\na preset that cannot start"
set ::fake::box ""
set ::engFail Broken
set ::engSent {}
::tactics::createWin 1 2
check "no training window is built" [expr {![winfo exists .tacticsWin]}]
checkIn "the failure names the reason" $::fake::box "the preset Broken cannot be started"
checkIn "with the message the catalogues carry" $::fake::box \
    [format [::tr TacticsEngineStartFail] "the preset Broken cannot be started"]
set ::engFail ""

puts "\nthe trainer no longer drives the legacy engine layer"
set uciUses {}
set analysisUses 0
set slotUses 0
foreach line [split $tacticsSrc "\n"] {
    if {[string first "::uci::" $line] >= 0} { lappend uciUses [string trim $line] }
    if {[string first "::analysis(" $line] >= 0} { incr analysisUses }
    if {[string first "engineSlot" $line] >= 0} { incr slotUses }
}
check "the only ::uci:: call left is the PV formatter" \
    [expr {[llength $uciUses] == 1 && [string first "::uci::formatPv" [lindex $uciUses 0]] >= 0}]
checkEq "nothing reads the Analysis window's array" $analysisUses 0
checkEq "the engine slot is gone" $slotUses 0
check "no engine-slot state is read" [expr {[string first "uciInfo" $tacticsSrc] < 0}]
check "the trainer starts its engine through ::engineNoWin" \
    [expr {[string first "::engineNoWin::initEngine" $tacticsSrc] >= 0}]
check "and asks for its own line instead of the preset's" \
    [expr {[string first "SetOptions" $tacticsSrc] >= 0}]

puts "\nthe new messages are translated everywhere"
set langCount 0
foreach path [lsort [glob -nocomplain -directory [file join $root tcl lang] *.tcl]] {
    set name [file tail $path]
    if {$name in {checklangs.tcl propagatelang.tcl removedeadlang.tcl removetoken.tcl}} { continue }
    set text [readText $path]
    check "$name carries every tactics message" \
        [expr {[string first "TacticsEngineStartFail" $text] >= 0
            && [string first "TacticsEngineGone" $text] >= 0
            && [string first "TacticsNoAssessment" $text] >= 0}]
    incr langCount
}
checkEq "all 29 catalogues were checked" $langCount 29

##############################################################################
##############################################################################
puts "\nthe timer beats the first info line (no measurement, no verdict)"
# The dict that carries a search is non-empty the moment it is created, so a
# timer that expires before any InfoPV used to publish the empty initial score
# and hand the referee a value `expr` raises on. Drive stopAnalyze directly:
# it is the proc that decides what a finished search publishes, and it needs no
# window to do it.
set before $::tactics::analysisEngine(score)
set ::tactics::search [dict create on 1 fen "6k1/8/8/8/8/8/5PPP/R5K1 w - - 0 1" \
    depth "" scoreType "" score "" pv "" time ""]
set ::tactics::analysisEngine(analyzeMode) 1
::tactics::stopAnalyze
check "a search with no line is not a measurement" \
    [expr {$::tactics::analysisEngine(noLine) == 1}]
checkEq "no empty score was published" $::tactics::analysisEngine(score) $before
checkEq "and no line either" $::tactics::analysisEngine(moves) ""
check "a measured search clears that flag again" \
    [expr {[catch {
        set ::tactics::search [dict create on 1 fen "6k1/8/8/8/8/8/5PPP/R5K1 w - - 0 1" \
            depth 20 scoreType cp score 30 pv {e2e4} time 100]
        set ::tactics::analysisEngine(analyzeMode) 1
        ::tactics::stopAnalyze
    }] == 0 && $::tactics::analysisEngine(noLine) == 0}]
checkEq "and publishes the score it measured" $::tactics::analysisEngine(score) 30

##############################################################################
puts "\nthe engine dies while the base loads (no window for a dead connection)"
# engineGone cannot destroy a window that does not exist yet, so it records the
# loss and createWin must not build one: a trainer that cannot analyse anything
# is worse than no trainer at all.
catch { destroy .tacticsWin }
set ::fake::dropDuringLoad 1
::tactics::createWin 1 0
check "the disconnect during the load is recorded" \
    [expr {$::tactics::engineLost == 1}]
check "no window was built for a dead connection" \
    [expr {![winfo exists .tacticsWin]}]
set ::fake::dropDuringLoad 0

puts "\n"
puts "$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
