#!/usr/bin/env tclsh
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_cloud.tcl -- the Lichess cloud pre-pass, decided and driven without a
# network and without a real engine.
#
#   tclsh tests/tcl/review_cloud.tcl
#
# ::lichess_eval's async entry point is stubbed: a request is recorded and its
# callback held, and the test decides when (and whether) the reply lands. That is
# the property the driver has to have - the pass must never wait on the network -
# so the stub is the assertion, not a convenience.

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
source [file join $root tcl tools review_cloud.tcl]
source [file join $root tcl tools review_driver.tcl]
source [file join $root tcl tools review_verify.tcl]

# ------------------------------------------------------------------ stubs --
# The engine layer, as tests/tcl/review_driver.tcl stubs it: what the driver
# sends, not how a pipe to Stockfish works.
set ::sent {}
set ::closed {}
set ::connseq 0
namespace eval ::engine {}
proc ::engine::setLogCmd {id args} {}
proc ::engine::connect {id callback exe args {protocols {uci xboard}}} {
    incr ::connseq
    set ::engconn(channel_$id) chan$::connseq
    set ::engconn(callback_$id) $callback
    set ::engine_callback $callback
    lappend ::sent [list connect $id $exe $args $protocols]
}
proc ::engine::send {id msg args} {
    lappend ::sent [list send $id $msg [lindex $args 0]]
}
proc ::engine::close {id} {
    unset -nocomplain ::engconn(channel_$id)
    unset -nocomplain ::engconn(callback_$id)
    lappend ::closed $id
}

proc feed {msgType msgData} {
    {*}$::engine_callback [list $msgType $msgData]
}

# ::lichess_eval's transport, stubbed. A request is recorded and the callback is
# held: nothing answers until the test says so, which is exactly the "never block
# the run on the cloud" contract.
namespace eval ::lichess_eval {}
set ::cloudRequests {}
set ::cloudCallbacks {}
proc ::lichess_eval::cloudEvalAsync {fen variant mpv callback} {
    lappend ::cloudRequests [list $fen $variant $mpv]
    lappend ::cloudCallbacks $callback
    return "stubfd[llength $::cloudCallbacks]"
}

# The reply lands. `ok 0` is a transport failure.
proc cloudAnswer {json {ok 1}} {
    if {![llength $::cloudCallbacks]} { error "no cloud request in flight" }
    set cb [lindex $::cloudCallbacks end]
    set ::cloudCallbacks [lrange $::cloudCallbacks 0 end-1]
    {*}$cb $ok $json ""
}

# One cloud reply body. `pvs` is {{moves score kind} ...}, kind cp or mate.
proc cloudJson {depth pvs} {
    set items {}
    foreach pv $pvs {
        lassign $pv moves score kind
        if {$kind eq "mate"} {
            lappend items "{\"moves\":\"$moves\",\"mate\":$score}"
        } else {
            lappend items "{\"moves\":\"$moves\",\"cp\":$score}"
        }
    }
    return "{\"fen\":\"stub\",\"knodes\":100,\"depth\":$depth,\"pvs\":\[[join $items ,]\]}"
}

set ::WIDE {
    {{e2e4 e7e5 g1f3} 20 cp}
    {{d2d4 d5 c2c4} 10 cp}
    {{c2c4 e5} 5 cp}
}

# How many of one engine message the pass has sent.
proc sentCount {msg} {
    set n 0
    foreach e $::sent {
        if {[lindex $e 2] eq $msg} { incr n }
    }
    return $n
}

# One position per pass unless a test asks for more: the interesting decision is
# per position, and a pass that finishes is the simplest thing to assert on.
set ::enginecfg {Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {}}
set ::START {position startpos}
set ::BLACK {position fen rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1}
set ::BLACK2 {position fen rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 7 12}

set ::results ""
set ::doneCalls 0
proc onDone {results} {
    set ::results $results
    incr ::doneCalls
}

# Start a pass over `positions`, hand it the handshake, and stop: whatever the
# driver does next (wait for the cloud, or send Go) has happened by the return.
proc newPass {positions mpv lim {cloud 1} {variant standard}} {
    set ::sent {}
    set ::results ""
    set ::doneCalls 0
    set ::cloudRequests {}
    set ::cloudCallbacks {}
    set err [::reviewdriver::start $::enginecfg $positions $mpv $lim {} ::onDone $cloud $variant]
    feed InfoConfig {}
    return ""
}

# A local search that reached `depth`, in the driver's own line shape.
proc localLines {depth} {
    feed InfoPV [list 1 $depth $depth 900 300 0 0 120 20 cp 0 e2e4 e7e5]
    feed InfoPV [list 2 $depth $depth 900 300 0 0 120 10 cp 0 d2d4 d5]
    feed InfoPV [list 3 $depth $depth 900 300 0 0 120 5 cp 0 c2c4 e5]
}

puts "the comparison"

checkEq "a depth bound with the cloud at the bound is the cloud" \
    [::reviewcloud::decide 18 0 18 0] cloud
checkEq "a depth bound the cloud beats is the cloud" \
    [::reviewcloud::decide 18 0 22 0] cloud
checkEq "a cloud shallower than the depth bound is local" \
    [::reviewcloud::decide 18 0 17 0] local
checkEq "with a time cap the deeper evaluation wins" \
    [::reviewcloud::decide 18 900 22 20] cloud
checkEq "and a tie goes to the local engine" \
    [::reviewcloud::decide 18 900 20 20] local
checkEq "a cloud under the local depth loses even under a depth bound" \
    [::reviewcloud::decide 30 900 20 22] local
checkEq "the cloud matches the depth bound the local search cannot pass" \
    [::reviewcloud::reaches 18 18] 1
checkEq "and a shallower one does not" [::reviewcloud::reaches 18 17] 0
checkEq "no depth bound means no ceiling to match" [::reviewcloud::reaches 0 40] 0

puts "\nthe FEN the cloud is asked about"

checkEq "startpos is the standard start position" \
    [lrange [split [::reviewcloud::fenForSpec {position startpos}] " "] 0 3] \
    {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -}
checkEq "and its moves are played out" \
    [lrange [split [::reviewcloud::fenForSpec {position startpos moves e2e4}] " "] 0 3] \
    {rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3}
checkEq "a FEN header is replayed too" \
    [lrange [split [::reviewcloud::fenForSpec $::BLACK2] " "] 0 3] \
    {rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3}
checkEq "a spec that cannot be followed has no FEN" \
    [::reviewcloud::fenForSpec {position startpos moves e2e4 e2e4}] ""
checkEq "and neither has a header this cannot read" \
    [::reviewcloud::fenForSpec {position nowhere}] ""
set blackFen [::reviewcloud::fenForSpec $::BLACK]
set blackFen2 [::reviewcloud::fenForSpec $::BLACK2]
checkEq "the cache key drops the move counters" \
    [::reviewcloud::key $blackFen] [::reviewcloud::key $blackFen2]
checkEq "but keeps the en-passant square" \
    [::reviewcloud::key $blackFen] \
    "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3"

puts "\nnormalisation to the driver's convention"

set entry [::reviewcloud::parse [cloudJson 30 $::WIDE] \
    {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}]
checkEq "the reply's depth is kept" [::reviewcloud::depth $entry] 30
set white [::reviewcloud::lines $entry 3]
checkEq "White to move: the cloud's score is already the mover's" \
    [lindex [dict get $white 1] 1] 20
checkEq "and the primary line's moves are kept" \
    [lindex [dict get $white 1] 3] {e2e4 e7e5 g1f3}
checkEq "the second line keeps its slot" [lindex [dict get $white 2] 1] 10

set entry [::reviewcloud::parse [cloudJson 30 $::WIDE] $blackFen]
set black [::reviewcloud::lines $entry 3]
checkEq "Black to move: the cloud's score is negated to the mover" \
    [lindex [dict get $black 1] 1] -20
checkEq "and so is the second line" [lindex [dict get $black 2] 1] -10

set mateJson [cloudJson 24 {
    {{e2e4 e7e5} 3 mate}
    {{d2d4 d5} 10 cp}
    {{c2c4 e5} 5 cp}
}]
set entry [::reviewcloud::parse $mateJson $blackFen]
set lines [::reviewcloud::lines $entry 3]
checkEq "a mate distance is the app's mate line" [lindex [dict get $lines 1] 2] mate
checkEq "and it is negated for the side that is being mated" \
    [lindex [dict get $lines 1] 1] -3
checkEq "which the driver scores with its own mate encoding" \
    [::reviewdriver::lineScore [dict get $lines 1]] [::movelabels::mateToCp -3]
set entry [::reviewcloud::parse $mateJson {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}]
checkEq "and left alone for the side that is mating" \
    [lindex [dict get [::reviewcloud::lines $entry 3] 1] 1] 3

puts "\na reply the verdict cannot use"

set thin [::reviewcloud::parse [cloudJson 30 {{{e2e4 e7e5} 20 cp}}] $blackFen]
checkEq "one line for a three-line verdict is not a shortcut" \
    [::reviewcloud::lines $thin 3] ""
checkEq "a reply with no evaluation is no evaluation" \
    [::reviewcloud::parse "{\"error\":\"No cloud evaluation available\"}" $blackFen] ""
checkEq "and a reply with no depth is unusable too" \
    [::reviewcloud::parse "{\"pvs\":\[{\"moves\":\"e2e4\",\"cp\":3}\]}" $blackFen] ""

puts "\ndepth bound only: the cloud at the depth asked for skips the search"

::reviewcloud::reset
checkEq "the pass starts" [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
checkEq "the cloud is asked about the position" [llength $::cloudRequests] 1
checkEq "and no search is sent while the answer is out" [sentCount Go] 0
# The stub has not answered: this is the "no synchronous network call" property.
checkEq "the pass has produced nothing yet" $::doneCalls 0
cloudAnswer [cloudJson 25 $::WIDE]
checkEq "a reply at the depth asked for is adopted with no Go at all" [sentCount Go] 0
checkEq "and the pass finishes" $::doneCalls 1
checkEq "the cloud's lines are the position's result" \
    [lindex [dict get [dict get $::results 0] 1] 1] 20
checkEq "the evaluation says where it came from" \
    [dict get [dict get [::reviewdriver::status] sources] 0] {source cloud depth 25}

::reviewcloud::reset
checkEq "a shallower cloud starts a pass too" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
cloudAnswer [cloudJson 16 $::WIDE]
checkEq "a cloud under the depth bound is not adopted" [sentCount Go] 1
checkEq "and the position is searched locally" \
    [lindex [lindex $::sent end] 3 1] {{depth 20}}
localLines 20
feed InfoBestMove {}
checkEq "the pass finishes on the local lines" \
    [dict get [dict get [::reviewdriver::status] sources] 0] {source local depth 20}

puts "\na time cap: the deeper evaluation wins when the search ends"

::reviewcloud::reset
checkEq "the search runs beside the query" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
checkEq "the cloud is asked" [llength $::cloudRequests] 1
checkEq "and the local search is sent at once" [sentCount Go] 1
cloudAnswer [cloudJson 25 $::WIDE]
localLines 18
feed InfoBestMove {}
checkEq "a deeper cloud wins" \
    [lindex [dict get [dict get $::results 0] 1] 0] 25
checkEq "and the run says the cloud answered it" \
    [dict get [dict get [::reviewdriver::status] sources] 0] {source cloud depth 25}

::reviewcloud::reset
checkEq "a second capped pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
cloudAnswer [cloudJson 12 $::WIDE]
localLines 18
feed InfoBestMove {}
checkEq "a shallower cloud loses to the search" \
    [lindex [dict get [dict get $::results 0] 1] 0] 18
checkEq "and the run says local" \
    [dict get [dict get [::reviewdriver::status] sources] 0] {source local depth 18}

::reviewcloud::reset
checkEq "a tie is the local engine's" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
cloudAnswer [cloudJson 18 $::WIDE]
localLines 18
feed InfoBestMove {}
checkEq "at the same depth the local lines are kept" \
    [lindex [dict get [dict get $::results 0] 1] 1] 20
checkEq "and the source is local" \
    [dict get [dict get [::reviewdriver::status] sources] 0] {source local depth 18}

# D > C > L: the cloud is under the depth bound and still beats the search the
# time cap cut short. This is why the comparison cannot happen before the search.
::reviewcloud::reset
checkEq "a capped pass with a depth bound starts" \
    [newPass [list [list 0 $::START]] 3 {depth 30 movetime 900}] ""
cloudAnswer [cloudJson 20 $::WIDE]
localLines 12
feed InfoBestMove {}
checkEq "the cloud wins though it is under the depth bound" \
    [lindex [dict get [dict get $::results 0] 1] 0] 20

puts "\na depth bound and a time cap: the cloud at the bound stops the search"

::reviewcloud::reset
checkEq "the capped pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
checkEq "the local search is running" [sentCount Go] 1
cloudAnswer [cloudJson 22 $::WIDE]
checkEq "a cloud at least as deep as the bound cancels it" [sentCount StopGo] 1
localLines 15
feed InfoBestMove {}
checkEq "and the cloud's lines are what the position keeps" \
    [lindex [dict get [dict get $::results 0] 1] 0] 22
checkEq "with the cloud named as the source" \
    [dict get [dict get [::reviewdriver::status] sources] 0] {source cloud depth 22}

::reviewcloud::reset
checkEq "a capped pass under the bound starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
cloudAnswer [cloudJson 14 $::WIDE]
checkEq "a cloud under the bound lets the search run" [sentCount StopGo] 0
localLines 18
feed InfoBestMove {}
checkEq "and a deeper local result is kept" \
    [lindex [dict get [dict get $::results 0] 1] 0] 18

puts "\na reply that never lands does not extend the run"

::reviewcloud::reset
checkEq "the capped pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
checkEq "the query is out" [llength $::cloudRequests] 1
localLines 18
feed InfoBestMove {}
checkEq "the search completes with no cloud answer" $::doneCalls 1
checkEq "and the local lines are adopted" \
    [lindex [dict get [dict get $::results 0] 1] 0] 18
checkEq "the run is over, not waiting" \
    [llength [array names ::reviewdriver::job]] 0
cloudAnswer [cloudJson 30 $::WIDE]
checkEq "a late reply changes nothing" \
    [lindex [dict get [dict get $::results 0] 1] 0] 18

puts "\na reply the verdict cannot use falls back to the search"

::reviewcloud::reset
checkEq "the capped pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
cloudAnswer [cloudJson 30 {{{e2e4 e7e5} 20 cp}}]
localLines 18
feed InfoBestMove {}
checkEq "a one-line reply does not feed a three-line verdict" \
    [lindex [dict get [dict get $::results 0] 1] 0] 18

::reviewcloud::reset
checkEq "a depth-only pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
cloudAnswer [cloudJson 30 {{{e2e4 e7e5} 20 cp}}]
checkEq "and a one-line reply sends the search after all" [sentCount Go] 1
localLines 18
feed InfoBestMove {}
checkEq "which then finishes the pass" $::doneCalls 1

puts "\nno network is not a slow pass"

::reviewcloud::reset
set ::cloudRequests {}
checkEq "the depth-only pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
cloudAnswer "" 0
checkEq "a transport failure searches the position" [sentCount Go] 1
localLines 18
feed InfoBestMove {}
checkEq "and the pass finishes" $::doneCalls 1
checkEq "the cloud is not asked again this session" \
    [::reviewcloud::enabled] 0
::reviewcloud::reset
checkEq "a reset makes it usable again" [::reviewcloud::enabled] 1

# The shape the real transport produces on an outage before the status check:
# ok 1 with an empty body. It is not "Lichess holds nothing for this FEN", and
# mistaking it for one is what made an offline pass re-ask at every position.
::reviewcloud::reset
checkEq "a two-position pass starts" \
    [newPass [list [list 0 $::START] [list 1 $::BLACK]] 3 {depth 20 movetime {}}] ""
cloudAnswer "" 1
checkEq "an empty reply is a failure to answer, not an empty answer" [sentCount Go] 1
checkEq "and it stops the pass asking" [::reviewcloud::enabled] 0
localLines 18
feed InfoBestMove {}
checkEq "the next position is not asked about" [llength $::cloudRequests] 1
checkEq "it is searched instead" [sentCount Go] 2
localLines 18
feed InfoBestMove {}
checkEq "and the pass finishes" $::doneCalls 1

puts "\nthe cache is the position, not the move counters"

::reviewcloud::reset
checkEq "a two-position pass starts" \
    [newPass [list [list 0 $::BLACK] [list 1 $::BLACK2]] 3 {depth 20 movetime {}}] ""
checkEq "the first position is asked about" [llength $::cloudRequests] 1
cloudAnswer [cloudJson 25 $::WIDE]
# The second position has the same placement, side, castling and en-passant
# square; only its counters differ, so it is the same evaluation.
checkEq "the second position hits the cache" [llength $::cloudRequests] 1
checkEq "and the pass finishes on it" $::doneCalls 1
checkEq "both positions carry a cloud evaluation" \
    [list [dict get [dict get [::reviewdriver::status] sources] 0 source] \
          [dict get [dict get [::reviewdriver::status] sources] 1 source]] \
    {cloud cloud}
checkEq "Black's score is the mover's" \
    [lindex [dict get [dict get $::results 0] 1] 1] -20

# The other answer Lichess gives: a 404 body saying it holds nothing for the FEN.
# That one IS remembered - it is a fact about the position, not a failed request
# - so the same position is not asked about twice.
::reviewcloud::reset
checkEq "a two-position pass starts" \
    [newPass [list [list 0 $::BLACK] [list 1 $::BLACK2]] 3 {depth 20 movetime {}}] ""
cloudAnswer "{\"error\":\"No cloud evaluation available for the given position\"}"
checkEq "a position Lichess holds nothing for is searched" [sentCount Go] 1
checkEq "and the pass is still asking" [::reviewcloud::enabled] 1
localLines 18
feed InfoBestMove {}
checkEq "the same position is not asked about again" [llength $::cloudRequests] 1
localLines 18
feed InfoBestMove {}
checkEq "and that position is searched too" $::doneCalls 1
checkEq "neither position came from the cloud" \
    [list [dict get [dict get [::reviewdriver::status] sources] 0 source] \
          [dict get [dict get [::reviewdriver::status] sources] 1 source]] \
    {local local}

puts "\nthe toggle"

::reviewcloud::reset
::review::reset
checkEq "the cloud pre-pass is on by default" [::review::get cloud_eval] 1
checkEq "and it is a switch, not a number" [::review::setValue cloud_eval 2] \
    "cloud_eval is 0 or 1"
::review::setValue cloud_eval 0
checkEq "turning it off stores" [::review::get cloud_eval] 0
::review::reset
checkEq "a pass with it off asks nothing" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}} 0] ""
checkEq "no request is made" [llength $::cloudRequests] 0
checkEq "and the position is searched" [sentCount Go] 1
localLines 18
feed InfoBestMove {}
checkEq "the pass finishes on the local lines" \
    [dict get [dict get [::reviewdriver::status] sources] 0] {source local depth 18}

# A variant whose FEN this module cannot replay is searched locally rather than
# asked about: the cloud is a standard-chess shortcut.
::reviewcloud::reset
checkEq "a chess960 pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}} 1 chess960] ""
checkEq "and asks the cloud nothing" [llength $::cloudRequests] 0
checkEq "with the search sent instead" [sentCount Go] 1
localLines 18
feed InfoBestMove {}

puts "\nthe verifier never re-uses a cloud value"

# The verifier's pass starts from ::reviewverify::begin, which asks the driver
# for a pass of its own. That pass must have the pre-pass off: the cache is
# process-wide, so a verifier that asked would be handed the very evaluation the
# pass just adopted, and the label it exists to withdraw could never move. The
# request is the assertion - the cloud module and its stub are loaded here, so a
# pass that asked would show up in this count.
::reviewcloud::reset
set ::sent {}
checkEq "the verifier starts" \
    [expr {[::reviewverify::begin $::enginecfg \
        [list [list 2 1 $::START e2e4 brilliant]] 3 {depth 20 movetime {}} \
        ::verifierAnswered] ne ""}] 1
feed InfoConfig {}
checkEq "it asks the cloud nothing" [llength $::cloudRequests] 0
checkEq "and searches the position on its own engine" [sentCount Go] 1

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
