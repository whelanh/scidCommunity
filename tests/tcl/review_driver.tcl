#!/usr/bin/env tclsh
# The engine pass behind Game Review / Move Comment, driven by a stub engine.

set fails 0
set checks 0

proc check {name cond} {
    global fails checks
    incr checks
    if {![uplevel 1 [list expr $cond]]} {
        incr fails
        puts "FAIL $name"
    }
}

proc checkEq {name got want} {
    global fails checks
    incr checks
    if {$got ne $want} {
        incr fails
        puts "FAIL $name -- got '$got' want '$want'"
    }
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools score_seed.tcl]
source [file join $root tcl enginecfg.tcl]
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools game_review.tcl]
source [file join $root tcl tools review_driver.tcl]

# The engine layer, stubbed: the driver's job is which messages it sends and
# what it does with the replies, not how a pipe to Stockfish works. The stub keeps
# ::engine::connect's own parameter list and records the argv that list would build,
# because whether "uci" is the protocol or the engine's first argument is decided
# there.
set ::sent {}
set ::closed {}
set ::argv_seen {}
set ::connseq 0
namespace eval ::engine {}
proc ::engine::setLogCmd {id args} {}
proc ::engine::connect {id callback exe args {protocols {uci xboard}}} {
    incr ::connseq
    set ::engconn(channel_$id) chan$::connseq
    set ::engconn(callback_$id) $callback
    set ::engine_callback $callback
    lappend ::sent [list connect $id $exe $args $protocols]
    # What the real connect hands the OS: the engine, then the args list.
    lappend ::argv_seen [concat [list $exe] $args]
}
proc ::engine::send {id msg args} {
    lappend ::sent [list send $id $msg [lindex $args 0]]
}
proc ::engine::close {id} {
    unset -nocomplain ::engconn(channel_$id)
    unset -nocomplain ::engconn(callback_$id)
    lappend ::closed $id
}

# The board notification the write phase ends with. What it is called with decides
# whether the game text is regenerated (the review changed comments all through
# the game) or only the current move is refreshed.
namespace eval ::notify {}
set ::notified {}
proc ::notify::PosChanged {arg} { lappend ::notified $arg }

proc feed {msgType msgData} {
    {*}$::engine_callback [list $msgType $msgData]
}

# The driver queues its close instead of closing inside the engine's reply (a close
# there unset the arrays ::engine::reply walks next), so a test that wants to see the
# close has to run the event loop.
proc pump {} {
    after idle {set ::pumped 1}
    vwait ::pumped
    unset -nocomplain ::pumped
}

set enginecfg {Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {
    {Threads 8 integer 1 1 128}
    {Hash 256 spin 16 1 4096}
    {MultiPV 1 spin 1 1 10}
}}

puts "what a pass runs with"
::review::reset
checkEq "threads come from the engine's config" [dict get [::review::effective $enginecfg] threads] 8
checkEq "and so does hash" [dict get [::review::effective $enginecfg] hash] 256
checkEq "a review always asks for two lines" [dict get [::review::effective $enginecfg] mpv] 3
::review::setValue threads 2
checkEq "the preset still wins over a ::review value" \
    [dict get [::review::effective $enginecfg] threads] 8
::review::setValue mpv 1
checkEq "one line is raised to two" [dict get [::review::effective $enginecfg] mpv] 2
set wide {Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {{MultiPV 5 spin 1 1 10}}}
checkEq "a preset asking for more lines is respected" \
    [dict get [::review::effective $wide] mpv] 5
::review::reset
::review::setValue threads 4
::review::setValue hash_mb 64
checkEq "an engine that advertises nothing leaves them unset" \
    [dict get [::review::engineDefaults {X /x {} {} 0 0 {} 1 {}}] threads] {}
checkEq "and a pass cannot borrow ::review's threads for it" \
    [dict get [::review::effective {X /x {} {} 0 0 {} 1 {}}] threads] {}
checkEq "nor its hash" \
    [dict get [::review::effective {X /x {} {} 0 0 {} 1 {}}] hash] {}

# The pass is a second engine process: the preset's reservation is allocated
# again beside the window's own engine. A preset sized for an interactive search
# on a 128 GB machine (Threads 64, Hash 110000) put two ~107 GB searches in RAM
# and systemd-oomd killed the session 28 positions into a 90-position review.
set huge {Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {{Threads 64} {Hash 110000}}}
checkEq "a pass takes at most its share of the preset's threads" \
    [dict get [::review::effective $huge] threads] 8
checkEq "and at most a TT a batch search can use" \
    [dict get [::review::effective $huge] hash] 512
checkEq "a preset below the thread ceiling keeps its threads" \
    [dict get [::review::effective $enginecfg] threads] 8
set modest {Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {{Threads 4} {Hash 128}}}
checkEq "and one below both keeps its hash" \
    [dict get [::review::effective $modest] hash] 128
::review::reset

puts "where the depth comes from"
set ::engines(list) [list \
    [list Plain /x {} {} 0 0 {} 1 {} {}] \
    [list Deep /x {} {} 0 0 {} 1 {} [dict create depth 30]] \
    [list Shallow /x {} {} 0 0 {} 1 {} [dict create depth 12]]]
::review::reset
checkEq "a preset with no limits leaves the review depth alone" \
    [dict get [::review::effective [::enginecfg::get Plain]] depth] 18
checkEq "a deeper preset raises it" \
    [dict get [::review::effective [::enginecfg::get Deep]] depth] 30
checkEq "a shallower preset does not lower it" \
    [dict get [::review::effective [::enginecfg::get Shallow]] depth] 18

puts "a pass over three positions"
set ::progress {}
set ::done ""
proc onProgress {n total ply lines} { lappend ::progress [list $n $total $ply] }
proc onDone {results} { set ::done $results }
set positions {{4 {fen A}} {5 {fen B}} {6 {fen C}}}
set token [::reviewdriver::start $enginecfg $positions 3 18 ::onProgress ::onDone]
checkEq "the engine was opened on the pass's own id" [lindex $::sent 0] {connect 20 /usr/bin/stockfish {} uci}
checkEq "with uci as the protocol, never as the engine's argument" \
    [lindex $::argv_seen 0] {/usr/bin/stockfish}

# Engine windows are allocated their ids from this same pool, and
# ::engine::connect closes whatever connection already holds the id it is given -
# so a window opened on 20 would take the pass's engine. ::enginewin::Open asks
# this before it hands out an id.
check "the pass's id is kept for the pass" [::reviewdriver::reservedId 20]
checkEq "and asking is the id the pass really uses" \
    [::reviewdriver::reservedId $::reviewdriver::ENGINE_ID] 1
check "a window id is not reserved" [expr {![::reviewdriver::reservedId 1]}]
check "nor is the next one up" [expr {![::reviewdriver::reservedId 21]}]
feed InfoConfig {Threads 8 Hash 256 MultiPV 3}
set opt [lsearch -inline $::sent {send 20 SetOptions*}]
check "the pass asks for its own MultiPV" [string match {*MultiPV 3*} $opt]
check "and passes the engine's threads" [string match {*Threads 8*} $opt]
checkEq "the first position is searched at the review depth" [lindex $::sent end] {send 20 Go {{fen A} {depth 18}}}

feed InfoPV {1 10 12 500 200 0 0 90 cp 0 e2e4 e7e5}
feed InfoPV {1 12 15 900 300 0 0 120 cp 0 d2d4 d7d5}
# A shallower line for the same slot must not overwrite the deeper one: an
# engine can report depths out of order between PV updates.
feed InfoPV {1 9 9 100 50 0 0 30 cp 0 d2d4 d7d5}
feed InfoPV {2 8 9 300 100 0 0 60 cp 0 c2c4 c7c5}
feed InfoBestMove {}
checkEq "progress reports the position just finished" [lindex $::progress 0] {1 3 4}
checkEq "the next position is searched" [lindex $::sent end] {send 20 Go {{fen B} {depth 18}}}

feed InfoPV {1 9 10 400 100 0 0 70 cp 0 g1f3 g8f6}
feed InfoBestMove {}
feed InfoPV {1 11 11 500 100 0 0 80 cp 0 b1c3 b8c6}
feed InfoBestMove {}

checkEq "the engine is not closed from inside the last reply" $::closed {}
pump
checkEq "the engine is closed once the reply has returned" $::closed {20}
check "the result carries every ply" [expr {[llength [dict keys $::done]] == 3}]
set first [dict get $::done 4]
checkEq "the deepest line is kept, not the last" [lindex [dict get $first 1] 0] 12
checkEq "and the second MultiPV slot too" [lindex [dict get $first 2] 0] 8
checkEq "positions after the first are recorded" [lindex [dict get [dict get $::done 6] 1] 0] 11

# The preset's reservation is not allocated a second time: a pass asks for the
# bounded values ::review::effective returns, which is what keeps a 110 GB preset
# from doubling the machine's memory use.
puts "a pass over a preset set up for a long analysis"
set ::sent {}
::reviewdriver::stop $token
pump
set huge {Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {{Threads 64} {Hash 110000}}}
set token [::reviewdriver::start $huge {{4 {fen A}}} 3 18 ::onProgress ::onDone]
feed InfoConfig {}
set opt [lsearch -inline $::sent {send 20 SetOptions*}]
check "the pass takes only its share of the threads" [string match {*Threads 8*} $opt]
check "and only a table it can use" [string match {*Hash 512*} $opt]
check "the preset's own numbers never reach the second engine" \
    [expr {![string match {*Threads 64*} $opt] && ![string match {*Hash 110000*} $opt]}]
feed InfoBestMove {}
pump

puts "stopping a pass"
set ::sent {}
set ::done ""
set token [::reviewdriver::start $enginecfg {{4 {fen A}} {5 {fen B}}} 3 18 ::onProgress ::onDone]
feed InfoConfig {}
feed InfoPV {1 10 10 0 0 0 0 10 cp 0 e2e4}
set searches [lsearch -all -inline -glob $::sent {send 20 Go*}]
checkEq "stop reports it did something" [::reviewdriver::stop $token] 1
checkEq "no further search is started" [lsearch -all -inline -glob $::sent {send 20 Go*}] $searches
pump
checkEq "the engine is closed" [lindex $::closed end] 20
checkEq "and the pass is forgotten" [::reviewdriver::stop $token] 0

puts "a preset that passes arguments to its engine"
set ::sent {}
set ::argv_seen {}
set ::closed {}
set withargs {Stockfish /usr/bin/stockfish {-t 4 --no-smp} {} 0 0 {} 1 {}}
set code [catch { ::reviewdriver::start $withargs {{4 {fen A}}} 2 18 {} {} } token]
checkEq "the preset's arguments do not overflow the connect call" $code 0
if {$code == 0} {
    checkEq "the preset's arguments reach the engine" \
        [lindex $::argv_seen 0] {/usr/bin/stockfish -t 4 --no-smp}
    checkEq "and uci is still the protocol" [lindex $::sent 0] \
        {connect 20 /usr/bin/stockfish {-t 4 --no-smp} uci}
    ::reviewdriver::stop $token
    pump
}

puts "a pass stopped from its own progress handler"
set ::sent {}
set ::closed {}
set ::stopped ""
proc onProgressStop {n total ply lines} {
    if {$n == 1} {
        set ::stopped [::reviewdriver::stop $::stopToken]
    }
}
set ::stopToken [::reviewdriver::start $enginecfg {{4 {fen A}} {5 {fen B}}} 2 18 ::onProgressStop ::onDone]
feed InfoConfig {}
feed InfoBestMove {}
checkEq "the handler stopped the pass" $::stopped 1
check "and no position after it is started" \
    [expr {[llength [lsearch -all -inline -glob $::sent {send 20 Go*}]] == 1}]
pump
checkEq "the engine is closed once the loop runs" $::closed {20}

puts "an engine that dies mid-pass"
set ::sent {}
set ::closed {}
set ::done {}
set ::progress {}
set token [::reviewdriver::start $enginecfg {{4 {fen A}} {5 {fen B}} {6 {fen C}}} 3 18 ::onProgress ::onDone]
feed InfoConfig {}
feed InfoPV {1 10 11 0 0 0 0 10 cp 0 e2e4}
feed InfoBestMove {}
feed InfoPV {1 9 9 0 0 0 0 20 cp 0 d2d4}
feed InfoDisconnected {}
checkEq "the pass still completes, with what it had" [dict keys $::done] {4}
checkEq "no position after the loss is started" \
    [lsearch -all -inline -glob $::sent {send 20 Go*}] \
    [list {send 20 Go {{fen A} {depth 18}}} {send 20 Go {{fen B} {depth 18}}}]
checkEq "nothing is closed: the connection is already gone" $::closed {}
checkEq "and the dead pass is forgotten" [::reviewdriver::stop $token] 0

puts "a close queued by one pass does not close the next"
set ::sent {}
set ::closed {}
set first [::reviewdriver::start $enginecfg {{4 {fen A}}} 2 18 ::onProgress ::onDone]
feed InfoConfig {}
feed InfoBestMove {}
checkEq "the id is free the moment the last reply is in" [::reviewdriver::busy 20] 0
set second [::reviewdriver::start $enginecfg {{4 {fen A}}} 2 18 ::onProgress ::onDone]
pump
checkEq "the queued close leaves the new connection alone" $::closed {}
feed InfoConfig {}
feed InfoBestMove {}
pump
checkEq "and the pass that owns it still closes it" $::closed {20}

puts "the caller-side procs are there"

# Asserted by absence on the pre-change module: every section below needs one of
# these, so naming them first makes the RED side report each missing anchor
# instead of stopping at the first call. `lineScore`/`blankState` and friends are
# internal and are exercised through the five public ones.
foreach helper {positions lines verdicts run status cancel} {
    check "::reviewdriver::$helper exists" \
        [expr {[llength [info commands ::reviewdriver::$helper]] > 0}]
}

puts "the positions a pass searches"

# The game commands do not exist yet in this harness, so a `positions` that read
# the board to build a position string would fail here rather than quietly pass:
# every position has to come out of the map it is handed.
set ::engines(list) {}
set map [::review::mainLineMap [list {position startpos moves} e2e4 e7e5 g1f3 b8c6]]
checkEq "one pair per searched position, in search order" \
    [::reviewdriver::positions $map 4 0] [list \
        [list 0 "position startpos moves"] \
        [list 1 "position startpos moves e2e4"] \
        [list 2 "position startpos moves e2e4 e7e5"] \
        [list 3 "position startpos moves e2e4 e7e5 g1f3"] \
        [list 4 "position startpos moves e2e4 e7e5 g1f3 b8c6"]]
::review::reset
checkEq "a book end starts the pass one position earlier" \
    [::reviewdriver::positions $map 4 3] [list \
        [list 2 "position startpos moves e2e4 e7e5"] \
        [list 3 "position startpos moves e2e4 e7e5 g1f3"] \
        [list 4 "position startpos moves e2e4 e7e5 g1f3 b8c6"]]
checkEq "an empty plan asks for no position" [::reviewdriver::positions $map 0 0] {}
checkEq "a book that covers the game asks for none either" \
    [::reviewdriver::positions $map 4 5] {}

# A caller that judges only some moves still needs each one's successor: the
# engine may not rank the move played, and the successor is then the only score
# the verdict can compare against.
checkEq "each selected move brings its own successor" \
    [::reviewdriver::planPositions $map {1 3}] [list \
        [list 0 "position startpos moves"] \
        [list 1 "position startpos moves e2e4"] \
        [list 2 "position startpos moves e2e4 e7e5"] \
        [list 3 "position startpos moves e2e4 e7e5 g1f3"]]

puts "the lines a pass keeps"

# MultiPV index order, never sorted by score: the third slot here is the worst
# one, and it stays third. The `cp` is the engine's own number for the side to
# move, which is the mover of the move this position precedes.
set r [dict create 0 [dict create \
    1 {20 34 cp {e2e4 e7e5}} \
    2 {19 12 cp {d2d4 d7d5}} \
    3 {18 -8 cp {c2c4}}]]
checkEq "index order, not score order" [::reviewdriver::lines $r 0 3] \
    [list [list 34 {e2e4 e7e5}] [list 12 {d2d4 d7d5}] [list -8 {c2c4}]]
checkEq "trimmed to the mpv the pass asked for" [::reviewdriver::lines $r 0 2] \
    [list [list 34 {e2e4 e7e5}] [list 12 {d2d4 d7d5}]]
checkEq "a position nobody searched has no lines" [::reviewdriver::lines $r 9 3] {}
checkEq "and no mpv means no lines" [::reviewdriver::lines $r 0 0] {}

set sparse [dict create 0 [dict create \
    1 {20 34 cp {e2e4}} \
    3 {18 5 cp {c2c4}}]]
checkEq "a missing slot is absent, not renumbered" \
    [::reviewdriver::lines $sparse 0 3] [list [list 34 {e2e4}] [list 5 {c2c4}]]

set odd [dict create 0 [dict create \
    1 {20 34 cp {e2e4}} \
    2 {20 90 lowerbound {d2d4}} \
    3 {20 90 upperbound {c2c4}} \
    4 {20 34 cp {}} \
    5 {20 "" cp {g1f3}}]]
checkEq "a bound, an empty pv and an empty score are not lines" \
    [::reviewdriver::lines $odd 0 5] [list [list 34 {e2e4}]]

set mate [dict create 0 [dict create 1 {20 3 mate {e2e4 e7e5}}]]
checkEq "a mate becomes the encoding the labels and the graph share" \
    [::reviewdriver::lines $mate 0 1] [list [list 99700 {e2e4 e7e5}]]

puts "what the engine's lines say about each move"

set vmap [::review::mainLineMap [list {position startpos moves} e2e4 e7e5 g1f3 b8c6]]
set vres [dict create \
    0 [dict create \
        1 {20 30 cp {e2e4 e7e5}} \
        2 {20 20 cp {d2d4 d7d5}}] \
    1 [dict create \
        1 {20 40 cp {c7c5}} \
        2 {20 25 cp {e7e5 g1f3}} \
        3 {20 10 cp {d7d5}}] \
    2 [dict create \
        1 {20 50 cp {d2d4}} \
        2 {20 40 cp {b1c3}}] \
    3 [dict create \
        1 {20 -120 cp {e7e6}}] \
    4 [dict create \
        1 {20 800 cp {g8f6}}]]
set verd [::reviewdriver::verdicts $vmap $vres]
checkEq "every move whose reference position was searched has a verdict" \
    [dict keys $verd] {1 2 3 4}
# The move the engine preferred is best; the [%eval] is the successor's own
# search (-40: Black to move there, +40 for Black), not the root line's +30.
checkEq "the move the engine preferred is best" [dict get $verd 1] {best -40}
# Ranked second by the engine: its own line is what the label compares against
# (no search noise), while the token still comes from the searched successor.
checkEq "a ranked move is judged against its own line" [dict get $verd 2] {excellent 50}
# Nowhere in the MultiPV window: the searched successor answers instead, negated
# because the side to move there is the opponent.
checkEq "a move outside the window falls back to its successor" \
    [dict get $verd 3] {excellent 120}
checkEq "a big drop past the window is a blunder" [dict get $verd 4] {blunder 800}

# A move with no successor and not the engine's choice has no measurement to
# support a label: no verdict, rather than an "excellent" nothing measured.
set short [dict remove $vres 4]
check "an unmeasured move gets no verdict" \
    [expr {![dict exists [::reviewdriver::verdicts $vmap $short] 4]}]
checkEq "and the moves that were measured keep theirs" \
    [dict keys [::reviewdriver::verdicts $vmap $short]] {1 2 3}

puts "a null move is a header, not a move to judge"

# A null move costs a ply in the map but is not a move: there is nothing to
# label, and writing a comment and variations into it would corrupt the game.
set nmap [::review::mainLineMap [list \
    {position startpos moves} e2e4 \
    {position fen rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1 moves} \
    d7d5]]
set nres [dict create \
    0 [dict create 1 {20 30 cp {e2e4}}] \
    1 [dict create 1 {20 20 cp {g1f3}}] \
    2 [dict create 1 {20 15 cp {d7d5}}]]
set nverd [::reviewdriver::verdicts $nmap $nres]
checkEq "the null move gets no verdict" [dict keys $nverd] {1 3}
# The header says who moves next, so the comment after a null move still carries
# White's point of view rather than a ply-parity guess.
checkEq "and the move after it is still judged from the right side" \
    [dict get $nverd 3] {best -15}

puts "a game that starts with Black to move"
set fmap [::review::mainLineMap [list \
    {position fen 4k3/8/8/8/8/8/8/4K2R b - - 0 1 moves} e8d8]]
set fres [dict create \
    0 [dict create 1 {20 120 cp {e8d8}}] \
    1 [dict create 1 {20 60 cp {e1e2}}]]
checkEq {[%eval] is White's point of view, not the ply's parity} \
    [dict get [::reviewdriver::verdicts $fmap $fres] 1] {best 60}

puts "a pass over a game: search first, write after"

# The sc_* layer, stubbed the way tests/tcl/game_review.tcl stubs it: what is
# under test is which calls are made and in what order.
set ::events {}
set ::fakeMainLine [list {position startpos moves} e2e4 e7e5 g1f3 b8c6]
set ::fakeLen 4
set ::fakeLoc 2
set ::fakeLevel 0
set ::fakeNums {}
set ::fakeExit {}
set ::fakeVars {}
set ::fakeVarAt ""
set ::fakeVarFirst ""
set ::fakeComments {}
set ::fakeComment ""
set ::fakeNags {}
proc sc_pos {args} {
    set what [lindex $args 0]
    # Recorded so a test can see every board command the pass reaches for: a NAG
    # is invisible to a caller that never asks for it.
    lappend ::events [list pos $what]
    switch -- $what {
        location { return $::fakeLoc }
        fen { return "$::fakeLoc/$::fakeLevel" }
        getComment {
            if {[dict exists $::fakeComments $::fakeLoc]} {
                return [dict get $::fakeComments $::fakeLoc]
            }
            return $::fakeComment
        }
        setComment {
            lappend ::events [list setComment [lindex $args 1]]
            dict set ::fakeComments $::fakeLoc [lindex $args 1]
            return ""
        }
        getNags {
            if {[dict exists $::fakeNags $::fakeLoc]} {
                return [dict get $::fakeNags $::fakeLoc]
            }
            return ""
        }
        addNag {
            set nags ""
            if {[dict exists $::fakeNags $::fakeLoc]} {
                set nags [dict get $::fakeNags $::fakeLoc]
            }
            lappend nags [lindex $args 1]
            dict set ::fakeNags $::fakeLoc $nags
            return ""
        }
    }
    return ""
}
proc sc_move {args} {
    set what [lindex $args 0]
    set n [lindex $args 1]
    switch -- $what {
        ply {
            if {$n <= $::fakeLen} {
                set ::fakeLoc $n
                set ::fakeLevel 0
                set ::fakeNums {}
                set ::fakeExit {}
            }
        }
        forward {
            if {$n eq ""} { set n 1 }
            incr ::fakeLoc $n
        }
        back { incr ::fakeLoc -1 }
    }
    return ""
}
proc sc_var {args} {
    switch -- [lindex $args 0] {
        level  { return $::fakeLevel }
        number { return [lindex $::fakeNums end] }
        count  { return 0 }
        list   {
            if {[dict exists $::fakeVars $::fakeLoc]} {
                return [dict get $::fakeVars $::fakeLoc]
            }
            return {}
        }
        enter {
            lappend ::fakeExit $::fakeLoc
            lappend ::fakeNums [lindex $args 1]
            incr ::fakeLevel
            incr ::fakeLoc
            return ""
        }
        exit {
            if {$::fakeLevel == 0} { error "No such variation!" }
            # A variation that was inserted whole is one the game now holds: its
            # first move is what a second review has to find and not repeat.
            if {$::fakeVarFirst ne "" && $::fakeVarAt ne ""} {
                dict lappend ::fakeVars $::fakeVarAt $::fakeVarFirst
            }
            set ::fakeVarFirst ""
            set ::fakeLoc [lindex $::fakeExit end]
            set ::fakeExit [lrange $::fakeExit 0 end-1]
            set ::fakeNums [lrange $::fakeNums 0 end-1]
            incr ::fakeLevel -1
            return ""
        }
        create {
            lappend ::events {var create}
            set ::fakeVarAt $::fakeLoc
            set ::fakeVarFirst ""
            lappend ::fakeExit $::fakeLoc
            lappend ::fakeNums 0
            incr ::fakeLevel
            return ""
        }
    }
    return ""
}
proc sc_game {args} {
    if {[lindex $args 0] eq "UCI_mainLine"} { return $::fakeMainLine }
    return ""
}
namespace eval ::uci {
    proc sc_move_add {moves} {
        if {!$::fakeLevel} { return 0 }
        if {$::fakeVarFirst eq ""} { set ::fakeVarFirst $moves }
        return 0
    }
}

# Every engine message and every write lands in one log, so the order they
# happened in is a fact about the run rather than an assumption.
proc writesSoFar {} {
    set out {}
    foreach e $::events {
        if {[lindex $e 0] eq "setComment" || [string equal $e {var create}]} {
            lappend out $e
        }
    }
    return $out
}
proc feedEvent {msgType msgData} {
    lappend ::events [list msg $msgType]
    {*}$::engine_callback [list $msgType $msgData]
}
proc onRunProgress {done total} { lappend ::runProgress [list $done $total] }

::review::reset
::review::setValue var_lines 1
set runcfg {Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {
    {Threads 8 integer 1 1 128}
    {Hash 256 spin 16 1 4096}
    {MultiPV 3 spin 1 1 10}
}}
set ::sent {}
set ::closed {}
set ::runProgress {}
set ::events {}

checkEq "a pass over the whole line starts" \
    [::reviewdriver::run $runcfg -progress ::onRunProgress] ""
checkEq "and reports that it is searching" [dict get [::reviewdriver::status] state] searching
checkEq "with every position of the line to search" \
    [dict get [::reviewdriver::status] total] 5
checkEq "nothing is written before the engine has answered" [writesSoFar] {}

feedEvent InfoConfig {Threads 8 Hash 256 MultiPV 3}
checkEq "the first position searched is the start of the line" \
    [lindex $::sent end] {send 20 Go {{position startpos moves} {depth 18}}}

feedEvent InfoPV {1 20 22 900 300 0 0 120 30 cp 0 e2e4 e7e5}
feedEvent InfoPV {2 20 22 900 300 0 0 120 20 cp 0 d2d4 d7d5}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 40 cp 0 c7c5}
feedEvent InfoPV {2 20 22 900 300 0 0 120 25 cp 0 e7e5 g1f3}
feedEvent InfoPV {3 20 22 900 300 0 0 120 10 cp 0 d7d5}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 50 cp 0 d2d4}
feedEvent InfoPV {2 20 22 900 300 0 0 120 40 cp 0 b1c3}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 -120 cp 0 e7e6}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 800 cp 0 g8f6}
feedEvent InfoBestMove {}
pump

set st [::reviewdriver::status]
checkEq "the pass finished" [dict get $st state] done
checkEq "every position answered" [dict get $st searched] 5
checkEq "every move was written" [dict get $st written] 4
checkEq "none was refused" [dict get $st failed] 0
checkEq "the cursor was verified back where the pass found it" [dict get $st restored] 1
checkEq "which is where the reader left it" [list $::fakeLoc $::fakeLevel] {2 0}
checkEq "progress reports each finished position" [lindex $::runProgress 0] {1 5}
checkEq "all of them" [llength $::runProgress] 5

# The write phase may only begin once the engine is done with the game: a write
# moves the board, and the position strings came from a snapshot of it.
set lastBest -1
set firstWrite -1
set i 0
foreach e $::events {
    if {[lindex $e 0] eq "msg" && [lindex $e 1] eq "InfoBestMove"} { set lastBest $i }
    if {$firstWrite < 0 && ([lindex $e 0] eq "setComment" || [string equal $e {var create}])} {
        set firstWrite $i
    }
    incr i
}
check "nothing is written until the last InfoBestMove" \
    [expr {$lastBest >= 0 && $firstWrite > $lastBest}]

set comments {}
foreach e $::events {
    if {[lindex $e 0] eq "setComment"} { lappend comments [lindex $e 1] }
}
checkEq "the verdicts are written once each, in ply order" $comments [list \
    {[best] [%eval -0.40]} \
    {[excellent] [%eval +0.50]} \
    {[excellent] [%eval +1.20]} \
    {[blunder] [%eval +8.00]}]
checkEq {and the [%eval] token reads back as the score that was written} \
    [::seed::score [lindex $comments 2]] 120
checkEq "a mate round-trips through the same token" \
    [::seed::score [::review::commentText best [::movelabels::mateToCp 3]]] \
    [::movelabels::mateToCp 3]

puts "a refused write is collected, not fatal"

# The board has two plies but the map says four: the last two writes are refused
# and the first two still land.
set ::fakeLen 2
set ::events {}
set ::runProgress {}
::review::reset
::review::setValue var_lines 0
checkEq "a second pass starts" [::reviewdriver::run $runcfg] ""
feedEvent InfoConfig {Threads 8 Hash 256 MultiPV 3}
feedEvent InfoPV {1 20 22 900 300 0 0 120 30 cp 0 e2e4 e7e5}
feedEvent InfoPV {2 20 22 900 300 0 0 120 40 cp 0 c7c5}
feedEvent InfoPV {3 20 22 900 300 0 0 120 25 cp 0 e7e5}
feedEvent InfoPV {4 20 22 900 300 0 0 120 10 cp 0 d7d5}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 40 cp 0 c7c5}
feedEvent InfoPV {2 20 22 900 300 0 0 120 25 cp 0 e7e5 g1f3}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 50 cp 0 d2d4}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 -120 cp 0 e7e6}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 800 cp 0 g8f6}
feedEvent InfoBestMove {}
pump

set st [::reviewdriver::status]
checkEq "the pass still finished" [dict get $st state] done
checkEq "the moves that fit were written" [dict get $st written] 2
checkEq "the ones that did not are counted, not fatal" [dict get $st failed] 2
checkEq "and their reasons are kept" [dict get $st errors] \
    {{ply 3 is not in this game} {ply 4 is not in this game}}
set ::fakeLen 4

puts "one move at a time: -plies"

# Move Comment is a review of one move: the same pass, told which moves to
# judge. Without that a comment would write the rest of the game as well.
::review::reset
::review::setValue var_lines 0
set ::fakeLoc 2
set ::fakeLevel 0
set ::fakeNums {}
set ::fakeExit {}
set ::fakeVars {}
set ::fakeComments {}
set ::fakeComment ""
set ::events {}
set ::runProgress {}
set ::fakeLen 4
set ::sent {}
checkEq "a single move starts" [::reviewdriver::run $runcfg -plies {3}] ""
checkEq "and only the two positions that judge it" \
    [dict get [::reviewdriver::status] total] 2
feedEvent InfoConfig {Threads 8 Hash 256 MultiPV 3}
checkEq "the first Go is the position before the move" [lindex $::sent end] \
    {send 20 Go {{position startpos moves e2e4 e7e5} {depth 18}}}
feedEvent InfoPV {1 20 22 900 300 0 0 120 50 cp 0 d2d4}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 20 cp 0 b8c6}
feedEvent InfoBestMove {}
pump
set st [::reviewdriver::status]
set comments {}
foreach e $::events {
    if {[lindex $e 0] eq "setComment"} { lappend comments [lindex $e 1] }
}
checkEq "the pass finished" [dict get $st state] done
checkEq "only the move asked for was written" [llength $comments] 1
check "and its comment carries the score the pass measured" \
    [expr {[string first {%eval -0.20} [lindex $comments 0]] >= 0}]

# The depth is the caller's answer too: a comment has to be the one a review
# would have written, so the window searches at the review's depth, and a
# shallow window analysis is not that depth.
::review::reset
set ::events {}
set ::sent {}
checkEq "a caller's depth starts" [::reviewdriver::run $runcfg -depth 8 -plies {1}] ""
feedEvent InfoConfig {Threads 8 Hash 256 MultiPV 3}
checkEq "and the Go carries it, not the setting's 18" [lindex $::sent end] \
    {send 20 Go {{position startpos moves} {depth 8}}}
::reviewdriver::cancel
pump
set ::sent {}
checkEq "a list of moves is what -plies takes" \
    [::reviewdriver::run $runcfg -plies {1 two}] {-plies must be a list of move numbers}
checkEq "nothing was opened for it" $::sent {}
checkEq "a depth must be a whole number" \
    [::reviewdriver::run $runcfg -depth deep] {-depth must be a whole number}
checkEq "and neither was that" $::sent {}

puts "a second review replaces the first"

# The point of writing into the open game: the user presses Game Review twice,
# and the second run replaces its labels, its [%eval]s and its variations instead
# of stacking a second copy of each. ::review::writeMove strips the old verdict
# and dedupes variations by first move; this proves it through the whole pass,
# on a board that remembers what was written.
::review::reset
::review::setValue var_lines 1
set ::fakeMainLine [list {position startpos moves} e2e4 e7e5 g1f3 b8c6]
set ::fakeLen 4
set ::fakeLoc 2
set ::fakeLevel 0
set ::fakeNums {}
set ::fakeExit {}
set ::fakeVars {}
set ::fakeComments {}
set ::fakeComment ""
set ::fakeNags {}
set ::events {}
set ::runProgress {}
# The move at ply 2 already carries the user's own note and a NAG; the pass must
# add its verdict to the comment and leave the NAG alone, and the second pass
# must replace only the verdict.
dict set ::fakeComments 2 "A fine move."
dict set ::fakeNags 2 "?!"

checkEq "the first review starts" [::reviewdriver::run $runcfg] ""
feedEvent InfoConfig {Threads 8 Hash 256 MultiPV 3}
feedEvent InfoPV {1 20 22 900 300 0 0 120 30 cp 0 e2e4 e7e5}
feedEvent InfoPV {2 20 22 900 300 0 0 120 20 cp 0 d2d4 d7d5}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 40 cp 0 c7c5}
feedEvent InfoPV {2 20 22 900 300 0 0 120 25 cp 0 e7e5 g1f3}
feedEvent InfoPV {3 20 22 900 300 0 0 120 10 cp 0 d7d5}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 50 cp 0 d2d4}
feedEvent InfoPV {2 20 22 900 300 0 0 120 40 cp 0 b1c3}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 -120 cp 0 e7e6}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 800 cp 0 g8f6}
feedEvent InfoBestMove {}
pump
checkEq "the first review wrote every move" \
    [dict get [::reviewdriver::status] written] 4
checkEq "and left the user's own note in front of its verdict" \
    [dict get $::fakeComments 2] {A fine move. [excellent] [%eval +0.50]}
checkEq "and its NAG alone" [dict get $::fakeNags 2] "?!"
checkEq "the first review's variations are in the game" \
    $::fakeVars {0 d2d4 1 c7c5 2 d2d4 3 e7e6}
checkEq "the labels the first review gave" [list \
    [dict get $::fakeComments 1] [dict get $::fakeComments 3] [dict get $::fakeComments 4]] \
    [list {[best] [%eval -0.40]} {[excellent] [%eval +1.20]} {[blunder] [%eval +8.00]}]

# The same game, different answers.
set ::events {}
set ::runProgress {}
set ::notified {}
checkEq "the second review starts" [::reviewdriver::run $runcfg -notify 1] ""
feedEvent InfoConfig {Threads 8 Hash 256 MultiPV 3}
feedEvent InfoPV {1 20 22 900 300 0 0 120 10 cp 0 e2e4 d7d5}
feedEvent InfoPV {2 20 22 900 300 0 0 120 5 cp 0 d2d4}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 8 cp 0 e7e5 g1f3}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 6 cp 0 g1f3 b8c6}
feedEvent InfoPV {2 20 22 900 300 0 0 120 4 cp 0 d2d4}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 4 cp 0 b8c6 g1f3}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 3 cp 0 g1f3}
feedEvent InfoBestMove {}
pump
set st [::reviewdriver::status]
checkEq "the second review finished" [dict get $st state] done
checkEq "writing into the game it found" [dict get $st written] 4
checkEq "the old verdict is gone, not stacked" \
    [dict get $::fakeComments 1] {[best] [%eval -0.08]}
checkEq "one verdict and one score per move" \
    [regexp -all {\[%eval [^\]]*\]} [dict get $::fakeComments 1]] 1
checkEq "the user's note and the new verdict, in that order" \
    [dict get $::fakeComments 2] {A fine move. [best] [%eval +0.06]}
checkEq "and the NAG survived both runs" [dict get $::fakeNags 2] "?!" 
checkEq "a finished review regenerates the game text" \
    [lindex $::notified end] -pgn
checkEq "a verdict from the first run is replaced, not appended" \
    [dict get $::fakeComments 3] {[best] [%eval -0.04]}
checkEq "and so is the last one" [dict get $::fakeComments 4] {[best] [%eval +0.03]}
checkEq "the variations were not inserted a second time" \
    $::fakeVars {0 d2d4 1 c7c5 2 d2d4 3 e7e6}
checkEq "so no variation was created at all" [lsearch -all $::events {var create}] {}
# A NAG is not the pass's to touch: it writes comments and moves the cursor, and
# asks the board for nothing else. A NAG already on the move cannot be eaten.
set asked {}
foreach e $::events {
    if {[lindex $e 0] eq "pos"} { lappend asked [lindex $e 1] }
}
checkEq "the board calls are reads, the comment, and the cursor" \
    [lsort -unique $asked] {fen getComment location setComment}
checkEq "the board ends where the user left it" [list $::fakeLoc $::fakeLevel] {2 0}
checkEq "and the driver says the restore was exact" [dict get $st restored] 1

puts "the opening book is labelled, not judged"

# The window tells the pass where the book ends. Book moves are written [Book]
# with no [%eval] and no variation; the move that leaves the book is judged
# normally. The early book positions are not even searched.
::review::reset
::review::setValue var_lines 1
set ::fakeMainLine [list {position startpos moves} e2e4 e7e5 g1f3 b8c6]
set ::fakeLen 4
set ::fakeLoc 2
set ::fakeLevel 0
set ::fakeNums {}
set ::fakeExit {}
set ::fakeVars {}
set ::fakeComments {}
set ::fakeNags {}
set ::events {}
set ::runProgress {}
checkEq "a pass with a book end starts" [::reviewdriver::run $runcfg -bookEnd 2] ""
feedEvent InfoConfig {Threads 8 Hash 256 MultiPV 3}
checkEq "the early book positions are not searched" \
    [lindex $::sent end] {send 20 Go {{position startpos moves e2e4} {depth 18}}}
feedEvent InfoPV {1 20 22 900 300 0 0 120 30 cp 0 e2e4 e7e5}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 20 cp 0 d2d4 d7d5}
feedEvent InfoPV {2 20 22 900 300 0 0 120 10 cp 0 c2c4}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 -120 cp 0 e7e6}
feedEvent InfoBestMove {}
feedEvent InfoPV {1 20 22 900 300 0 0 120 800 cp 0 g8f6}
feedEvent InfoBestMove {}
pump
set st [::reviewdriver::status]
checkEq "every move was written" [dict get $st written] 4
checkEq "the two book moves are labelled as book" \
    [list [dict get $::fakeComments 1] [dict get $::fakeComments 2]] \
    [list {[book]} {[book]}]
check "and carry no evaluation" \
    [expr {[string first {[%eval} [dict get $::fakeComments 1]] < 0}]
check "the move that leaves the book is judged" \
    [regexp {\[(best|excellent|good|inaccuracy|mistake|blunder)\]} \
        [dict get $::fakeComments 3]]

puts "refusing to start"

set ::sent {}
checkEq "no engine is a refusal, not a silent choice" [::reviewdriver::run ""] \
    {no engine selected}
checkEq "and nothing was opened" $::sent {}
# ::enginecfg::save drops an option sitting at its default, so a preset that
# never overrode MultiPV carries no mpv key - that is not evidence the engine
# cannot do it. The pass asks for MultiPV on its own connection, and a one-line
# engine ignores the option and answers with one line.
checkEq "a preset that never set MultiPV still starts" \
    [::reviewdriver::run {Plain /usr/bin/plain {} {} 0 0 {} 1 {{Threads 2}}}] ""
check "and a connection was opened for it" [expr {[llength $::sent] > 0}]
::reviewdriver::cancel
pump
set ::sent {}
# The pass pins the protocol to uci, so an XBoard preset would never answer the
# handshake and the run would sit in `searching` until the user cancelled. The
# preset here advertises MultiPV on purpose: without the protocol check it would
# pass every other gate and open a connection nothing can answer.
checkEq "an XBoard preset that advertises MultiPV is refused, not left waiting" \
    [::reviewdriver::run {Phalanx /usr/bin/phalanx {} {} 0 0 {} 0 {{MultiPV 3}}}] \
    {the review needs a UCI engine}
checkEq "and nothing was opened for it either" $::sent {}

::review::reset
checkEq "the first of two passes starts" [::reviewdriver::run $runcfg] ""
# Give the running pass one position, so a second call that read the map before
# refusing would visibly rewrite its counts.
feedEvent InfoConfig {Threads 8 Hash 256 MultiPV 3}
feedEvent InfoPV {1 20 22 900 300 0 0 120 30 cp 0 e2e4 e7e5}
feedEvent InfoBestMove {}
checkEq "the running pass has searched a position" \
    [dict get [::reviewdriver::status] searched] 1
set ::fakeMainLine [list {position startpos moves} e2e4]
checkEq "a second pass over the same connection is refused" \
    [::reviewdriver::run $runcfg] {engine 20 is already running a pass}
checkEq "and the running pass keeps its state and counts" \
    [list [dict get [::reviewdriver::status] state] \
          [dict get [::reviewdriver::status] total] \
          [dict get [::reviewdriver::status] searched]] {searching 5 1}
set ::fakeMainLine [list {position startpos moves} e2e4 e7e5 g1f3 b8c6]

puts "a cancelled pass writes nothing"

feedEvent InfoConfig {Threads 8 Hash 256 MultiPV 3}
feedEvent InfoPV {1 20 22 900 300 0 0 120 30 cp 0 e2e4 e7e5}
feedEvent InfoBestMove {}
set ::events {}
checkEq "cancelling the run stops it" [::reviewdriver::cancel] 1
checkEq "the pass is cancelled" [dict get [::reviewdriver::status] state] cancelled
checkEq "nothing is written" [writesSoFar] {}
checkEq "and the reader is left where the pass found them" \
    [list $::fakeLoc $::fakeLevel] {2 0}
pump

puts "an exact restore is the position, not the ply"

# cursorRestore compares the saved FEN, because a ply counter can land on a
# different position when the game changed during the asynchronous search.
set exact [dict create cursor [dict create loc 2 base 2 path {} fen {2/0}]]
checkEq "the same position is an exact restore" [::reviewdriver::restoreRun $exact] 1
set moved [dict create cursor [dict create loc 2 base 2 path {} fen {9/0}]]
checkEq "a different position at the same ply is not" [::reviewdriver::restoreRun $moved] 0

puts "\nthe engine window's hand-off to the driver (tcl/windows/engine.tcl)"

# The window's widgets cannot be exercised from tclsh, but who owns a run is not a
# widget: it is what happens when a second engine window presses Game Review while
# the first one's pass is still in flight. One pass exists at a time, so the
# refused press must leave the window that started it with its Cancel button and
# its status line. The file is loaded here on top of the fake board and the stub
# engine, with the widget commands it reaches for stubbed out. This is the last
# section in the file because those stubs are global.
set ::scidTclDir [file join $root tcl]
set ::scidShareDir [file join $root share]
set ::scidVersion test
set ::scidName Scid
set ::language english
set ::initialdir $root
set ::windowsOS 0
set ::macOS 0
set ::unixOS 1
set ::showGameInfo 0
# The status line's words, as a tclsh test has no language files: an untranslated
# key is what Scid itself shows, but a label with an argument needs its template.
array set ::EN {
    ReviewProgress {Reviewing position %s of %s}
    ReviewFailed   {Review failed: %s}
}
proc ::tr {key args} {
    if {![info exists ::EN($key)]} { return $key }
    if {[llength $args] == 0} { return $::EN($key) }
    return [eval [list format $::EN($key)] $args]
}
namespace eval ::utils {}
namespace eval ::utils::tooltip {}
proc ::utils::tooltip::Set {args} {}
proc button_image {args} { return "" }
proc addBindtagToTree {args} {}
proc collapseMenubuttons {args} {}
namespace eval ::win {}
proc ::win::add {args} {}
namespace eval ::pgn {}
proc ::pgn::Refresh {args} {}
namespace eval ::board {}
proc ::board::update {args} {}
proc ::board::setmarks {args} {}
namespace eval ::chart {}
proc ::chart::clear {args} {}
# Every widget is there: ::enginewin::reviewStart's first guard is that its button
# exists, and a harness that has no window should still reach the hand-off.
proc winfo {args} { return 1 }
proc unknown {args} { return "" }

source [file join $root tcl misc.tcl]
source [file join $root tcl tools review_ui.tcl]
if {[catch { source [file join $root tcl windows engine.tcl] } err]} {
    puts "LOAD ERROR: $err"
}

# Two engine windows on the same fake board, both analysing with the stub engine's
# preset. ::enginecfg::get reads ::engines(list), which an earlier section emptied.
set ::engines(list) [list \
    [list Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {} {}]]
set ::enginewin::engState(1) 1
set ::enginewin::engState(2) 1
set ::enginewin_lastengine(1) Stockfish
set ::enginewin_lastengine(2) Stockfish
set ::enginewin::reviewstatus(1) ""
set ::enginewin::reviewstatus(2) ""
set ::fakeLoc 2
set ::fakeLevel 0
set ::events {}

checkEq "the first window's press starts the pass" \
    [::enginewin::reviewStart 1 [::enginewin::reviewRunState 1]] 1
checkEq "and the window owns it" $::enginewin::reviewowner 1
checkEq "so its Cancel is live" [::enginewin::reviewPass 1] searching
checkEq "and its status line is the driver's" \
    [regexp {^Reviewing position 0 of [0-9]+$} $::enginewin::reviewstatus(1)] 1

# The second window presses Game Review while that pass is still searching. The
# driver refuses it, and the refusal is the second window's business only.
checkEq "a second window's press starts nothing" \
    [::enginewin::reviewStart 2 [::enginewin::reviewRunState 2]] ""
checkEq "the second window is told why" \
    [regexp {already running a pass} $::enginewin::reviewstatus(2)] 1
checkEq "the window that started the pass still owns it" $::enginewin::reviewowner 1
checkEq "so its Cancel is still live" [::enginewin::reviewPass 1] searching
checkEq "and the second window cannot cancel another window's pass" \
    [dict get [::reviewui::buttons [dict create game 4 engine $::enginecfg \
        move e2e4 pass [::enginewin::reviewPass 2]]] cancel] disabled

# The pass is still searching: its progress still reaches the window that owns it,
# and stopping it from there still stops it. One position of the five is searched.
feedEvent InfoConfig {Threads 8 Hash 256 MultiPV 3}
feedEvent InfoPV {1 20 22 900 300 0 0 120 30 cp 0 e2e4 e7e5}
feedEvent InfoBestMove {}
checkEq "the owning window's status line still follows the pass" \
    $::enginewin::reviewstatus(1) {Reviewing position 1 of 5}
checkEq "the refusing window's line is not overwritten by it" \
    [regexp {already running a pass} $::enginewin::reviewstatus(2)] 1
::enginewin::reviewCancel 1
checkEq "Cancel still stops the pass" [dict get [::reviewdriver::status] state] cancelled
checkEq "and nothing was written" [writesSoFar] {}
checkEq "the window is handed back" $::enginewin::reviewowner ""
pump

# A new game is a new board: the pass's saved cursor belongs to the game that
# is going away, and putting it back would move the new game to that ply.
set ::fakeLoc 2
set ::fakeLevel 0
checkEq "a second press starts a pass again" \
    [::enginewin::reviewStart 1 [::enginewin::reviewRunState 1]] 1
set ::fakeLoc 0
set ::fakeLen 4
::enginewin::reviewStopAll
checkEq "the new game stops the pass" [dict get [::reviewdriver::status] state] cancelled
checkEq "and the old cursor is not put back into it" $::fakeLoc 0
checkEq "and the window is handed back" $::enginewin::reviewowner ""
pump

# Game Review asks the first book where the opening ends; Move Comment names its
# move and is not skipped by the book.
namespace eval ::book {}
set ::book::lastBook1 testbook.bin
set ::scidBooksDir /books
checkEq "the window's book is the first one in the Book window" \
    [::enginewin::reviewBook] /books/testbook.bin
rename ::review::bookEnd ::review::bookEndSaved
proc ::review::bookEnd {file args} { return 2 }
set reviewState [::enginewin::reviewRunState 1]
checkEq "Game Review asks the book where the opening ends" \
    [dict get $reviewState bookEnd] 2
set call [::reviewui::runCall $reviewState]
set at [lsearch -exact [dict get $call args] -bookEnd]
checkEq "and tells the driver" [lindex [dict get $call args] [expr {$at + 1}]] 2
checkEq "Move Comment judges the move it names" \
    [dict get [::enginewin::reviewRunState 1 {2}] bookEnd] 0
rename ::review::bookEnd {}
rename ::review::bookEndSaved ::review::bookEnd
unset ::book::lastBook1
unset ::scidBooksDir

# A pass started outside a window (annotate mode calls the same driver) is not a
# window's to cancel: closing an engine window must not stop it.
checkEq "a script-started pass begins" [::reviewdriver::run $::runcfg] ""
::enginewin::reviewCancel 1
checkEq "closing a window does not cancel it" \
    [dict get [::reviewdriver::status] state] searching
::reviewdriver::cancel
pump

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
