#!/usr/bin/env tclsh
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_cdb.tcl -- ChessDB as the review pre-pass's second provider: one
# depth-bearing line, the deeper reply wins, Lichess keeps the tie, and a reply
# that states no depth is not used at all.
#
#   tclsh tests/tcl/review_cdb.tcl
#
# Both transports are stubbed and neither ever touches a network: Lichess's async
# entry point records a request and holds its callback, and ::cdbeval's transport
# does the same for the one call that answers a position. The test decides when
# (and whether) each reply lands, which is the property the driver has to have -
# the pass must never wait on either provider.
#
# Every reply body is the shape measured on the real endpoint (see
# tcl/tools/cdb_eval.tcl): querypv carries score, depth and pv in one response,
# White-relative. `queryall` and `queryscore` state no depth and are never asked;
# the harness records every URL, so that is an assertion rather than a promise.

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
source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools score_seed.tcl]
source [file join $root tcl enginecfg.tcl]
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools game_review.tcl]
source [file join $root tcl tools cdb_eval.tcl]
source [file join $root tcl tools review_cloud.tcl]
source [file join $root tcl tools review_driver.tcl]
source [file join $root tcl tools review_verify.tcl]

# ------------------------------------------------------------------ stubs --
# The engine layer, as tests/tcl/review_cloud.tcl stubs it: what the driver
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

# Lichess's transport, stubbed as review_cloud.tcl stubs it: a request is
# recorded and its callback held.
namespace eval ::lichess_eval {}
set ::cloudRequests {}
set ::cloudCallbacks {}
# Set to 1 to make the transport fail to start, as ::cloudThrow does in
# tests/tcl/review_cloud.tcl.
set ::cloudThrow 0
proc ::lichess_eval::cloudEvalAsync {fen variant mpv callback} {
    if {$::cloudThrow} {
        error {couldn't execute "curl": no such file or directory}
    }
    lappend ::cloudRequests [list $fen $variant $mpv]
    lappend ::cloudCallbacks $callback
    return "stubfd[llength $::cloudCallbacks]"
}

# The reply lands. `ok 0` is a transport failure.
proc cloudAnswer {json {ok 1}} {
    if {![llength $::cloudCallbacks]} { error "no lichess request in flight" }
    set cb [lindex $::cloudCallbacks end]
    set ::cloudCallbacks [lrange $::cloudCallbacks 0 end-1]
    {*}$cb $ok $json ""
}

# One Lichess reply body. `pvs` is {{moves score kind} ...}.
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

# ChessDB's transport, stubbed: the request is recorded with its action and its
# callback held, so the test says when - and whether - it answers.
set ::cdbRequests {}
# Set to 1 to make the transport fail to start: ::reviewcloud::ask's catch
# branch, which is what a client with no curl and no http package looks like
# from the module above it.
set ::cdbThrow 0
proc ::cdbeval::transport {url callback} {
    if {$::cdbThrow} {
        error {couldn't execute "curl": no such file or directory}
    }
    set action ""
    regsub {.*action=([a-z]+).*} $url {\1} action
    lappend ::cdbRequests [list $action $url $callback]
    return "stubcdb[llength $::cdbRequests]"
}

# The reply lands. `ok 0` is a transport failure - an empty body at EOF.
proc cdbAnswer {body {ok 1}} {
    if {![llength $::cdbRequests]} { error "no chessdb request in flight" }
    lassign [lindex $::cdbRequests end] action url cb
    set ::cdbRequests [lrange $::cdbRequests 0 end-1]
    {*}$cb $ok $body ""
}

proc cdbFail {} {
    cdbAnswer "" 0
}

# A querypv body, in the measured shape: score and depth White-relative, the pv
# and its SAN list.
proc pvJson {depth score {pv {e2e4 e7e5 g1f3}}} {
    set items {}
    foreach move $pv { lappend items "\"$move\"" }
    return "{\"status\":\"ok\",\"score\":$score,\"depth\":$depth,\"pv\":\[[join $items ,]\],\"pvSAN\":\[\]}"
}

proc statusJson {status} { return "{\"status\":\"$status\"}" }

# Every action a cdb URL has been asked for this session.
proc cdbActions {} {
    set out {}
    foreach req $::cdbRequests { lappend out [lindex $req 0] }
    return $out
}

# How many of one engine message the pass has sent.
proc sentCount {msg} {
    set n 0
    foreach e $::sent {
        if {[lindex $e 2] eq $msg} { incr n }
    }
    return $n
}

set ::enginecfg {Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {}}
set ::START {position startpos}
set ::BLACK {position fen rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1}
set ::BLACK2 {position fen rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 7 12}
# A queen offer: Qxh7+ gives the queen for a pawn, which is the shape the
# ladder's brilliant branch asks about.
set ::SAC {position fen 6k1/7p/8/7Q/8/8/8/K7 w - - 0 1}
set ::blackFen [::reviewcloud::fenForSpec $::BLACK]
set ::whiteFen {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}

set ::results ""
set ::doneCalls 0
proc onDone {results} {
    set ::results $results
    incr ::doneCalls
}

# Every pass-level block starts from both modules' own clean state. A latch that
# outlives the pass it was set in is ::reviewcloud::newPass's to clear, not this
# helper's: the block that proves it leaves ::cdbeval's latch alone on purpose.
proc resetAll {} {
    ::reviewcloud::reset
    ::cdbeval::reset
}

# Start a pass over `positions`, hand it the handshake, and stop: whatever the
# driver does next (wait for the providers, or send Go) has happened by the
# return.
proc newPass {positions mpv lim {cloud 1} {variant standard}} {
    set ::sent {}
    set ::results ""
    set ::doneCalls 0
    set ::cloudRequests {}
    set ::cloudCallbacks {}
    set ::cdbRequests {}
    ::reviewdriver::start $::enginecfg $positions $mpv $lim {} ::onDone $cloud $variant
    feed InfoConfig {}
    return ""
}

# A local search at `depth`, in the driver's own line shape.
proc localLines {depth} {
    localScores $depth {20 10 5}
}

# A local search whose lines score as given, in the driver's line shape.
proc localScores {depth scores} {
    set pvs {{e2e4 e7e5} {d2d4 d5} {c2c4 e5}}
    set index 0
    foreach score $scores {
        incr index
        set pv [lindex $pvs [expr {$index - 1}]]
        feed InfoPV [list $index $depth $depth 900 300 0 0 120 $score cp 0 {*}$pv]
    }
}

# A local search whose best line is `pv`, at `depth` and `score`, with
# `secondScore` for the runner-up.
proc localBest {depth score pv secondScore} {
    feed InfoPV [list 1 $depth $depth 900 300 0 0 120 $score cp 0 {*}$pv]
    feed InfoPV [list 2 $depth $depth 900 300 0 0 120 $secondScore cp 0 d2d4 d5]
    feed InfoPV [list 3 $depth $depth 900 300 0 0 120 -100 cp 0 c2c4 e5]
}

proc provenance {index} {
    return [dict get [dict get [::reviewdriver::status] sources] $index]
}

puts "one position, one depth-bearing call"

checkEq "the cache key drops the move counters" \
    [::cdbeval::key [::reviewcloud::fenForSpec $::BLACK]] \
    [::cdbeval::key [::reviewcloud::fenForSpec $::BLACK2]]
checkEq "and it is the same key the lichess path uses" \
    [::cdbeval::key $::blackFen] [::reviewcloud::key $::blackFen]

# A cdb call measured ~1.5 s; --max-time 3 is what keeps it from holding a
# depth-only pass.
set argv [::cdbeval::command [::cdbeval::url querypv $::whiteFen]]
checkEq "the child is capped at 3 s" \
    [lindex $argv [expr {[lsearch -exact $argv --max-time] + 1}]] 3
check "and not at curl's own default" [expr {[lsearch -exact $argv --max-time] >= 0}]
check "the app names itself to the endpoint" \
    [expr {[string first "scidCommunity" [join $argv " "]] >= 0}]
check "the HTTP status is asked for, so a dead reply is not an empty one" \
    [expr {[lsearch -exact $argv {-w}] > 0}]
checkEq "the one endpoint that states a depth" \
    [::cdbeval::url querypv $::whiteFen] \
    "https://www.chessdb.cn/cdb.php?action=querypv&board=rnbqkbnr%2Fpppppppp%2F8%2F8%2F8%2F8%2FPPPPPPPP%2FRNBQKBNR%20w%20KQkq%20-%200%201&json=1&learn=0"
checkEq "a stored read, so the server's learning stays out of it" \
    [expr {[string first "&learn=0" [::cdbeval::url querypv $::whiteFen]] > 0}] 1
checkEq "and no action that requests analysis" \
    [expr {[string first "action=queue" [::cdbeval::url querypv $::whiteFen]] > 0}] 0

::cdbeval::reset
set ::cdbGot ""
proc cdbCollect {ok entry err} { set ::cdbGot [list $ok $entry] }
check "the question is asked" \
    [expr {[::cdbeval::evaluateAsync $::whiteFen 3 ::cdbCollect] ne ""}]
checkEq "exactly one child, and it is querypv" [cdbActions] querypv
checkEq "nothing is answered before it speaks" $::cdbGot ""
cdbAnswer [pvJson 30 40]
lassign $::cdbGot ok entry
checkEq "the reply is an evaluation" $ok 1
checkEq "its depth is the reply's own" [dict get $entry depth] 30
checkEq "and the provider is named" [dict get $entry provider] chessdb
set lines [::reviewcloud::adoptable $entry 3]
checkEq "ChessDB carries one line, adopted as one" [dict size $lines] 1
checkEq "White to move: the score is already the mover's" \
    [lindex [dict get $lines 1] 1] 40
checkEq "the line is the reply's whole pv" \
    [lindex [dict get $lines 1] 3] {e2e4 e7e5 g1f3}

puts "\na stored evaluation is used only when it states its depth"

# The queryscore shape: a score and no depth. It is not an evaluation.
checkEq "a reply with no depth is not an evaluation" \
    [::cdbeval::parse "{\"status\":\"ok\",\"eval\":24988}" $::whiteFen] ""
checkEq "a reply with a depth and no score is not one either" \
    [::cdbeval::parse "{\"status\":\"ok\",\"depth\":30}" $::whiteFen] ""
checkEq "and a reply with a depth, a score and no line is not one" \
    [::cdbeval::parse "{\"status\":\"ok\",\"depth\":30,\"score\":12}" $::whiteFen] ""

# The unvisited position, measured: status ok, a score, a line, and depth 0. It
# looks like an answer and is the "quality unknown" case.
set unvisited [::cdbeval::parse \
    "{\"status\":\"ok\",\"score\":0,\"depth\":0,\"pv\":\[\"g1h1\"\]}" $::whiteFen]
checkEq "a depth-0 reply is not an evaluation" $unvisited ""
::cdbeval::reset
set ::cdbGot ""
::cdbeval::evaluateAsync $::whiteFen 3 ::cdbCollect
cdbAnswer "{\"status\":\"ok\",\"score\":0,\"depth\":0,\"pv\":\[\"g1h1\"\]}"
lassign $::cdbGot ok entry
checkEq "and it is no evaluation on the wire either" [list $ok $entry] {1 {}}
checkEq "with the provider still askable" [::cdbeval::enabled] 1

# A resolved position can answer a negative depth, which is a marker rather than
# a search depth: refused, on the same rule, and not a failure either.
checkEq "a negative depth is not a search depth" \
    [::cdbeval::parse [pvJson -12 24988 {b1g1}] {7k/8/8/8/8/8/8/KQ6 w - - 0 1}] ""

# A decisive position's SCORE is a large number, not material centipawns and not
# a mate distance: the pass keeps it as a cp line and winPercent saturates.
set mateish [::cdbeval::parse [pvJson 40 24988 {b1g1}] {7k/8/8/8/8/8/8/KQ6 w - - 0 1}]
checkEq "a won position is a cp line, not a mate" \
    [lindex [dict get [::reviewcloud::adoptable $mateish 1] 1] 2] cp
checkEq "at the score cdb reported" \
    [::reviewcloud::lineCp [dict get [::reviewcloud::adoptable $mateish 1] 1]] 24988
check "which winPercent saturates rather than overflowing" \
    [expr {[::accuracy::winPercent 24988] >= 99.99 &&
           [::accuracy::winPercent 24988] <= 100.0}]

set entry [::cdbeval::parse [pvJson 36 -1 {c7c5 g1f3}] $::blackFen]
checkEq "Black to move: cdb's White-relative score is negated to the mover" \
    [lindex [dict get [::reviewcloud::adoptable $entry 1] 1] 1] 1

puts "\nthe status is the provider's answer, not the transport's"

foreach status [list {invalid board} unknown checkmate stalemate] {
    check "a '$status' status is understood" [::cdbeval::knownStatus $status]
}
check "a status this client has never seen is not" \
    [expr {![::cdbeval::knownStatus "server on fire"]}]

::cdbeval::reset
set ::cdbGot ""
::cdbeval::evaluateAsync $::whiteFen 3 ::cdbCollect
cdbAnswer [statusJson "invalid board"]
lassign $::cdbGot ok entry
checkEq "an invalid board is no evaluation, not a failure" [list $ok $entry] {1 {}}
checkEq "and it does not latch the provider off" [::cdbeval::enabled] 1

::cdbeval::reset
set ::cdbGot ""
::cdbeval::evaluateAsync $::whiteFen 3 ::cdbCollect
cdbAnswer [statusJson unknown]
lassign $::cdbGot ok entry
checkEq "an unknown position is no evaluation either" [list $ok $entry] {1 {}}
checkEq "and that does not latch it off either" [::cdbeval::enabled] 1

::cdbeval::reset
set ::cdbGot ""
::cdbeval::evaluateAsync $::whiteFen 3 ::cdbCollect
cdbAnswer "{\"status\":\"overloaded\"}"
lassign $::cdbGot ok entry
checkEq "a reply nobody understands is a failed reply" [list $ok $entry] {0 {}}
checkEq "and it stops the provider asking this session" [::cdbeval::enabled] 0

::cdbeval::reset
set ::cdbGot ""
::cdbeval::evaluateAsync $::whiteFen 3 ::cdbCollect
cdbFail
lassign $::cdbGot ok entry
checkEq "a dead connection is a transport failure, not an empty answer" \
    [list $ok $entry] {0 {}}
checkEq "and it latches the provider off" [::cdbeval::enabled] 0
checkEq "nothing is cached for the position" [llength [array names ::cdbeval::cache]] 0

puts "\nthe cache is the position, not the move counters"

::cdbeval::reset
set ::cdbGot ""
::cdbeval::evaluateAsync [::reviewcloud::fenForSpec $::BLACK2] 3 ::cdbCollect
checkEq "a new position asks" [llength $::cdbRequests] 1
cdbAnswer [pvJson 28 12]
set ::cdbGot ""
set ::cdbRequests {}
::cdbeval::evaluateAsync [::reviewcloud::fenForSpec $::BLACK] 3 ::cdbCollect
update
lassign $::cdbGot ok entry
checkEq "the same placement with other counters is answered from the cache" $ok 1
checkEq "with no child started" [llength $::cdbRequests] 0
checkEq "and the cached evaluation is the one that landed" [dict get $entry depth] 28

puts "\na timed pass: the deeper reply wins when the search ends"

resetAll
checkEq "the capped pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
checkEq "lichess is asked" [llength $::cloudRequests] 1
checkEq "and chessdb is asked beside it" [llength $::cdbRequests] 1
checkEq "with the one endpoint that states a depth" [cdbActions] querypv
checkEq "the local search runs beside both" [sentCount Go] 1

cloudAnswer [cloudJson 24 $::WIDE]
checkEq "a lichess reply at the bound stops the search" [sentCount StopGo] 1
cdbAnswer [pvJson 30 40]
checkEq "the second provider reaching the bound stops nothing twice" [sentCount StopGo] 1
localLines 18
feed InfoBestMove {}
checkEq "chessdb's deeper reply is adopted" \
    [lindex [dict get [dict get $::results 0] 1] 0] 30
checkEq "and the run says which provider answered" [provenance 0] {source cloud-chessdb depth 30}
checkEq "the pass finishes" $::doneCalls 1

resetAll
checkEq "a second capped pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
cloudAnswer [cloudJson 34 $::WIDE]
cdbAnswer [pvJson 26 40]
localLines 18
feed InfoBestMove {}
checkEq "lichess deeper: its lines are what the position keeps" \
    [lindex [dict get [dict get $::results 0] 1] 0] 34
checkEq "and lichess is named" [provenance 0] {source cloud-lichess depth 34}

resetAll
checkEq "a third capped pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
cloudAnswer [cloudJson 28 $::WIDE]
cdbAnswer [pvJson 28 40]
localLines 18
feed InfoBestMove {}
checkEq "equal depths: the tie is lichess's" \
    [lindex [dict get [dict get $::results 0] 1] 0] 28
checkEq "and so is the provenance" [provenance 0] {source cloud-lichess depth 28}

puts "\none provider down is not both providers down"

resetAll
checkEq "the capped pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
cloudAnswer [cloudJson 24 $::WIDE]
cdbFail
checkEq "a chessdb transport failure is that provider's answer" \
    [::cdbeval::enabled] 0
localLines 18
feed InfoBestMove {}
checkEq "and the other provider is still used" \
    [lindex [dict get [dict get $::results 0] 1] 0] 24
checkEq "named as the source" [provenance 0] {source cloud-lichess depth 24}

::reviewcloud::reset
checkEq "a pass after the failure starts" \
    [newPass [list [list 0 $::START] [list 1 $::BLACK]] 3 {depth 20 movetime 900}] ""
# The failure ended with the pass that saw it: the next cloud-enabled pass
# clears every provider's latch (::reviewcloud::newPass, from
# ::reviewdriver::start), so one timeout does not disable ChessDB for the rest of
# the session while the setting still shows it on.
checkEq "chessdb asks again, because the latch belonged to the pass" \
    [llength $::cdbRequests] 1
checkEq "and lichess is asked beside it" [llength $::cloudRequests] 1
cdbAnswer [pvJson 12 40]
cloudAnswer [cloudJson 21 $::WIDE]
localLines 18
feed InfoBestMove {}
# ::cloudRequests records every request; ::cdbRequests is the queue of ones
# still waiting for a reply, so one of each is in flight for the second position
# and two lichess requests have been made in all.
checkEq "the second position is asked about too" \
    [list [llength $::cloudRequests] [llength $::cdbRequests]] {2 1}
cdbAnswer [pvJson 12 40]
cloudAnswer [cloudJson 21 $::WIDE]
localLines 18
feed InfoBestMove {}
checkEq "both positions are lichess's" \
    [list [dict get [provenance 0] source] [dict get [provenance 1] source]] \
    {cloud-lichess cloud-lichess}

resetAll
checkEq "both providers down: the pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
cloudAnswer "" 0
cdbFail
localLines 18
feed InfoBestMove {}
checkEq "with neither reply the search's lines are kept" \
    [lindex [dict get [dict get $::results 0] 1] 0] 18
checkEq "and the source is local" [provenance 0] {source local depth 18}
checkEq "with the whole pre-pass off for the session" [::reviewcloud::enabled] 0

# A transport that will not even start is not a reply that never lands. Both
# entry points threw instead of returning a handle: nothing is in flight, so
# waiting for an answer that cannot come would hang the pass - and a callback
# made from inside the begin that started the query would arrive before the
# driver had been told to wait, and be dropped.
resetAll
set ::cloudThrow 1
set ::cdbThrow 1
checkEq "a pass whose transports cannot start still starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
checkEq "nothing is asked of transports that are not there" \
    [list [llength $::cloudRequests] [llength $::cdbRequests]] {0 0}
checkEq "both providers are off for the pass" [::reviewcloud::enabled] 0
checkEq "and the position is searched at once" [sentCount Go] 1
localLines 18
feed InfoBestMove {}
checkEq "the pass finishes instead of waiting for a reply" $::doneCalls 1
set ::cloudThrow 0
set ::cdbThrow 0

# One transport down is still one provider to hear from: the pass waits for the
# one that started and for nothing else.
resetAll
set ::cdbThrow 1
checkEq "a pass where chessdb cannot start still starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
checkEq "lichess is asked" [llength $::cloudRequests] 1
checkEq "and chessdb started nothing to wait for" [llength $::cdbRequests] 0
cloudAnswer [cloudJson 16 $::WIDE]
checkEq "a shallow reply leaves the position to the search" [sentCount Go] 1
localLines 20
feed InfoBestMove {}
checkEq "which finishes without waiting for the dead provider" $::doneCalls 1
checkEq "on the local lines" [provenance 0] {source local depth 20}
set ::cdbThrow 0

puts "\na reply the verdict cannot use is no reply from that provider"

# The predicate the guard rests on, on its own: the alternatives decide `great`
# by the gap, and `brilliant` by the sacrifice the best move gives up.
checkEq "a gap of GREAT_GAP asks for the alternatives" \
    [::movelabels::needsAlternatives {400 50 -100} $::whiteFen e2e4] 1
checkEq "a queen offered for a pawn asks for them too" \
    [::movelabels::needsAlternatives {150 130 -100} \
        {6k1/7p/8/7Q/8/8/8/K7 w - - 0 1} h5h7] 1
checkEq "an ordinary position does not" \
    [::movelabels::needsAlternatives {150 130 120} $::whiteFen e2e4] 0
checkEq "and the sacrifice is measured on the board, not guessed" \
    [::chessboard::hangingMaterial {6k1/7p/8/7Q/8/8/8/K7 w - - 0 1} \
        [::chessboard::toFen [::chessboard::makeMove \
            [::chessboard::fromFen {6k1/7p/8/7Q/8/8/8/K7 w - - 0 1}] h5h7]] w] 8

# Lichess carrying one line is not a candidate list; the reply is unusable, and
# the provider that states a depth decides.
resetAll
checkEq "the capped pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
cloudAnswer [cloudJson 32 {{{e2e4 e7e5} 20 cp}}]
cdbAnswer [pvJson 26 40]
localLines 18
feed InfoBestMove {}
checkEq "a one-line lichess reply leaves chessdb to decide" \
    [lindex [dict get [dict get $::results 0] 1] 0] 26
checkEq "named as the source" [provenance 0] {source cloud-chessdb depth 26}

# And a reply that carries alternatives but fewer than `mpv` of them is not a
# short evaluation either. Adopting it as one line would let a one-line ladder
# stand in for the alternatives the pass asked for, so it is refused outright -
# only a one-line reply is adopted as one line.
set short [::reviewcloud::parse [cloudJson 24 {{{e2e4 e7e5} 20 cp}}] $::whiteFen]
checkEq "a multi-line reply shorter than mpv is readable" [dict get $short depth] 24
checkEq "and is refused rather than read as one line" \
    [dict size [::reviewcloud::adoptable $short 3]] 0

# And a cdb reply is held back where the verdict needs the alternatives the reply
# does not carry: the gap to the second line is what `great` reads.
resetAll
checkEq "a great-shaped pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
cdbAnswer [pvJson 30 400]
localScores 18 {400 50 -100}
feed InfoBestMove {}
checkEq "a great-shaped position is not scored from one line" \
    [lindex [dict get [dict get $::results 0] 1] 0] 18
checkEq "the source with the alternatives decided it" [provenance 0] {source local depth 18}

# The same guard for the sacrifice the ladder's brilliant branch asks about:
# Qxh7 gives the queen for a pawn, and the two lines are close enough that the
# gap alone would not have held the reply back.
resetAll
checkEq "a brilliant-shaped pass starts" \
    [newPass [list [list 0 $::SAC]] 3 {depth 20 movetime 900}] ""
cdbAnswer [pvJson 30 150]
localBest 18 150 {h5h7} 130
feed InfoBestMove {}
checkEq "a sacrifice is not scored from one line either" \
    [lindex [dict get [dict get $::results 0] 1] 0] 18
checkEq "so the search's own lines are kept" [provenance 0] {source local depth 18}

# An ordinary position in the same pass is chessdb's: the guard is about the
# verdict, not about the provider.
resetAll
checkEq "an ordinary capped pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
cdbAnswer [pvJson 30 150]
localScores 12 {150 130 120}
feed InfoBestMove {}
checkEq "chessdb's depth beats a shallow search for an ordinary label" \
    [lindex [dict get [dict get $::results 0] 1] 0] 30
checkEq "and it is adopted" [provenance 0] {source cloud-chessdb depth 30}

# A reply under the search is not adopted, whichever provider sent it.
resetAll
checkEq "a capped pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
cdbAnswer [pvJson 12 40]
localLines 18
feed InfoBestMove {}
checkEq "a shallower chessdb reply loses to the search" \
    [lindex [dict get [dict get $::results 0] 1] 0] 18

puts "\na one-line reply is never chosen without a candidate-bearing reply"

# The path vortex's finding was about: a depth-only pass, ChessDB at or above the
# depth bound, and Lichess holding nothing for the position (a 404), so there is no
# candidate-bearing reply - and no local lines either, because a depth-only pass
# does not search until this decision says it must. The one line cannot settle the
# alternatives question, so no evaluation is adopted: the position is searched
# locally, exactly as it was before the second provider existed, and the reply is
# kept in the cache for a later pass.
resetAll
checkEq "the depth-only pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
checkEq "both providers are asked" \
    [list [llength $::cloudRequests] [llength $::cdbRequests]] {1 1}
cloudAnswer "{\"error\":\"No cloud evaluation available for the given position\"}"
checkEq "lichess holding nothing leaves the position open" [sentCount Go] 0
cdbAnswer [pvJson 30 400]
checkEq "chessdb's one line does not settle it: the position is searched" \
    [sentCount Go] 1
localLines 20
feed InfoBestMove {}
checkEq "the pass finishes" $::doneCalls 1
checkEq "on the search's own lines" [provenance 0] {source local depth 20}
set ck [::reviewcloud::cacheKey $::whiteFen 3]
checkEq "and the reply is kept for a later pass" \
    [::reviewcloud::depth [set ::reviewcloud::cache(chessdb,$ck)]] 30

# The guard still runs where the alternatives exist, and the order of the replies
# is what makes it the deciding step: chessdb's deeper line lands first and cannot
# settle the position on its own, then lichess's candidate-bearing reply arrives
# and the drop's shape gives the position to it.
resetAll
checkEq "a great-shaped depth-only pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
cdbAnswer [pvJson 30 400]
checkEq "the deeper one line is held while the alternatives are out" [sentCount Go] 0
cloudAnswer [cloudJson 24 \
    {{{e2e4 e7e5} 400 cp} {{d2d4 d5} 50 cp} {{c2c4 e5} -100 cp}}]
checkEq "a qualifying gap hands the position to the alternatives" [sentCount Go] 0
checkEq "and the pass finishes on them" $::doneCalls 1
checkEq "with lichess named as the source" [provenance 0] {source cloud-lichess depth 24}
# The label that needs the second line is readable on that ply, which is what the
# hand-back is for.
set kept [dict get $::results 0]
checkEq "the adopted reply's alternatives are the ply's" [dict size $kept] 3
checkEq "so the great branch can fire on them" \
    [::movelabels::refine best [dict create is_best 1 cp_before 400 cp_after 400 \
        cp_loss 0 win_drop 0.0 ply 10 in_book 0 \
        candidates {400 50 -100}]] great

# The same shape with a non-qualifying gap: the guard answers no, and the deeper
# stored score is what the position keeps.
resetAll
checkEq "an ordinary depth-only pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
cdbAnswer [pvJson 30 150]
cloudAnswer [cloudJson 24 $::WIDE]
checkEq "no qualifying gap leaves chessdb's deeper reply in place" [sentCount Go] 0
checkEq "and the pass finishes" $::doneCalls 1
checkEq "on chessdb's evaluation" [provenance 0] {source cloud-chessdb depth 30}
checkEq "and one line kept for the score" [dict size [dict get $::results 0]] 1
# The guard is one proc, asked by the candidate-bearing path and the local-lines
# path alike - not an inline copy in one of them.
checkEq "the guard has one home, not a copy per caller" \
    [llength [info commands ::reviewcloud::qualifies]] 1
if {[llength [info commands ::reviewcloud::qualifies]]} {
    set wl [::reviewcloud::lines \
        [::reviewcloud::parse [cloudJson 24 $::WIDE] $::whiteFen] 3]
    checkEq "and it answers no on lichess's ordinary lines" \
        [::reviewcloud::qualifies $wl $::whiteFen] 0
    set gl [::reviewcloud::lines \
        [::reviewcloud::parse [cloudJson 24 \
            {{{e2e4 e7e5} 400 cp} {{d2d4 d5} 50 cp} {{c2c4 e5} -100 cp}}] \
            $::whiteFen] 3]
    checkEq "and yes on a great-shaped set" \
        [::reviewcloud::qualifies $gl $::whiteFen] 1
}

puts "\na cached one-line reply does not settle a timed pass without a bearer"

# A warm cache reaches the same decision through the same door. The first pass
# leaves chessdb's one line in the cache with no candidate-bearing reply beside it;
# the second, timed, cannot adopt it at `begin` and cannot stop the search for it -
# a search cut short cannot supply the alternatives either.
resetAll
checkEq "a depth-only pass warms the cache" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
cloudAnswer "{\"error\":\"No cloud evaluation available for the given position\"}"
cdbAnswer [pvJson 30 40]
checkEq "by searching the position, not adopting the one line" [sentCount Go] 1
localLines 20
feed InfoBestMove {}
checkEq "the pass is over" $::doneCalls 1
checkEq "on the search's lines" [provenance 0] {source local depth 20}

checkEq "a timed pass over the same position starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
checkEq "the cached one line neither settles the pass nor stops a search" \
    [list [sentCount Go] [sentCount StopGo]] {1 0}
checkEq "with nothing asked of either provider" \
    [list [llength $::cloudRequests] [llength $::cdbRequests]] {0 0}
localLines 20
feed InfoBestMove {}
checkEq "the guard runs on the search's lines and the deeper score wins" \
    [provenance 0] {source cloud-chessdb depth 30}
checkEq "and the pass finishes" $::doneCalls 1

# With a candidate-bearing reply in the cache the same timed pass may settle
# without a search: the guard has the alternatives it needs to answer.
resetAll
checkEq "a depth-only pass warms both replies" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
cloudAnswer [cloudJson 16 $::WIDE]
cdbAnswer [pvJson 30 40]
checkEq "on chessdb's deeper reply" [provenance 0] {source cloud-chessdb depth 30}
checkEq "and the pass is over" $::doneCalls 1

checkEq "the timed pass over the same position starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
checkEq "a cached reply deeper than the bound settles it, with a bearer present" \
    [list [sentCount Go] [sentCount StopGo]] {0 0}
checkEq "and no provider is asked again" \
    [list [llength $::cloudRequests] [llength $::cdbRequests]] {0 0}
checkEq "on the cached evaluation" [provenance 0] {source cloud-chessdb depth 30}

# The same cached reply AT the bound is held instead: the search can still reach
# D and the tie goes to the local engine.
checkEq "a timed pass at the cached reply's own depth starts" \
    [newPass [list [list 0 $::START]] 3 {depth 30 movetime 900}] ""
checkEq "a reply at the bound does not settle the position" [sentCount Go] 1
checkEq "and nothing is stopped" [sentCount StopGo] 0
localLines 30
feed InfoBestMove {}
checkEq "the search's own lines win the tie" [provenance 0] {source local depth 30}

# `lost` mid-position: the engine went away before the alternatives could arrive,
# and the only reply held is chessdb's one line. A half-finished search is not a
# result, and a one-line reply is not one either here, so the position is not
# reported at all - the pass reports what it finished, which is nothing.
resetAll
checkEq "a depth-only pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
cdbAnswer [pvJson 30 40]
checkEq "chessdb's one line is held, not adopted" [sentCount Go] 0
feed InfoDisconnected {}
checkEq "the engine going away ends the pass" $::doneCalls 1
checkEq "with nothing reported from the cloud line" [llength $::results] 0
checkEq "and no source claimed for the position" \
    [dict size [dict get [::reviewdriver::status] sources]] 0

# mpv 1: the pass itself asked for one line, so a one-line reply is exactly what
# the verdict needs and no alternatives question arises at all.
resetAll
checkEq "a one-line pass starts" \
    [newPass [list [list 0 $::START]] 1 {depth 20 movetime {}}] ""
checkEq "lichess is asked for one line too" \
    [lindex [lindex $::cloudRequests 0] 2] 1
cloudAnswer "{\"error\":\"No cloud evaluation available for the given position\"}"
cdbAnswer [pvJson 30 400]
checkEq "a one-line reply is adopted when one line is what was asked for" \
    [sentCount Go] 0
checkEq "the pass finishes on it" $::doneCalls 1
checkEq "named as chessdb's" [provenance 0] {source cloud-chessdb depth 30}
checkEq "and it is the one line asked for" \
    [dict size [dict get $::results 0]] 1

puts "\na reply that never lands does not extend the run"

resetAll
checkEq "the capped pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
cloudAnswer [cloudJson 22 $::WIDE]
checkEq "chessdb is still out" [llength $::cdbRequests] 1
localLines 18
feed InfoBestMove {}
checkEq "the search completes without chessdb" $::doneCalls 1
checkEq "and the pass is over, not waiting" \
    [llength [array names ::reviewdriver::job]] 0
cdbAnswer [pvJson 40 40]
checkEq "a late chessdb reply changes nothing" \
    [lindex [dict get [dict get $::results 0] 1] 0] 22

puts "\na depth-only pass is not held by the second provider"

resetAll
checkEq "the depth-only pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
checkEq "both providers are asked" \
    [list [llength $::cloudRequests] [llength $::cdbRequests]] {1 1}
checkEq "and no search is sent while they are out" [sentCount Go] 0
cloudAnswer [cloudJson 25 $::WIDE]
checkEq "a lichess reply at the depth asked for settles the position" [sentCount Go] 0
checkEq "and the pass finishes without waiting for chessdb" $::doneCalls 1
checkEq "on lichess's evaluation" [provenance 0] {source cloud-lichess depth 25}
cdbAnswer [pvJson 46 40]
checkEq "chessdb arriving later changes nothing" [provenance 0] {source cloud-lichess depth 25}

# The case the second provider exists for: Lichess too shallow, ChessDB holds the
# deeper evaluation of the same position.
resetAll
checkEq "a depth-only pass starts" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
cloudAnswer [cloudJson 16 $::WIDE]
checkEq "a shallow lichess reply holds the position open" [sentCount Go] 0
cdbAnswer [pvJson 41 40]
checkEq "chessdb's deeper reply is adopted with no search" [sentCount Go] 0
checkEq "and it is named" [provenance 0] {source cloud-chessdb depth 41}

resetAll
checkEq "and when neither is deep enough" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime {}}] ""
cloudAnswer [cloudJson 16 $::WIDE]
cdbAnswer [pvJson 18 40]
checkEq "the position is searched after all" [sentCount Go] 1
localLines 20
feed InfoBestMove {}
checkEq "on the local lines" [provenance 0] {source local depth 20}

puts "\nthe cache is the position, not the move counters"

resetAll
checkEq "a two-position pass starts" \
    [newPass [list [list 0 $::BLACK] [list 1 $::BLACK2]] 3 {depth 20 movetime {}}] ""
checkEq "both providers are asked about the first position" \
    [list [llength $::cloudRequests] [llength $::cdbRequests]] {1 1}
# The one line may decide the position only beside a candidate-bearing reply, so
# both are answered and both are cached - keyed by the position, not its counters.
cloudAnswer [cloudJson 16 $::WIDE]
cdbAnswer [pvJson 30 40]
checkEq "the first position keeps chessdb's evaluation" [provenance 0] {source cloud-chessdb depth 30}
checkEq "and Black's score is the mover's" \
    [lindex [dict get [dict get $::results 0] 1] 1] -40
checkEq "the second position asks the provider nothing" [llength $::cdbRequests] 0
checkEq "and needs no second lichess reply either" [llength $::cloudRequests] 1
checkEq "the pass finishes on the cached evaluation" $::doneCalls 1
checkEq "for both positions" \
    [list [dict get [provenance 1] source] [dict get [provenance 1] depth]] \
    {cloud-chessdb 30}

puts "\nthe toggles"

resetAll
::review::reset
checkEq "the second provider is on by default" [::review::get chessdb_eval] 1
checkEq "and it is a switch, not a number" [::review::setValue chessdb_eval 2] \
    "chessdb_eval is 0 or 1"
::review::setValue chessdb_eval 0
checkEq "the capped pass starts with chessdb off" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
checkEq "no chessdb request is made" [llength $::cdbRequests] 0
checkEq "while lichess is still asked" [llength $::cloudRequests] 1
cloudAnswer [cloudJson 24 $::WIDE]
localLines 18
feed InfoBestMove {}
checkEq "and its evaluation is adopted" [provenance 0] {source cloud-lichess depth 24}

::review::setValue chessdb_eval 1
::review::setValue cloud_eval 0
resetAll
checkEq "the master switch off" \
    [newPass [list [list 0 $::START]] 3 {depth 20 movetime 900}] ""
checkEq "asks neither provider" \
    [list [llength $::cloudRequests] [llength $::cdbRequests]] {0 0}
checkEq "and searches the position" [sentCount Go] 1
localLines 18
feed InfoBestMove {}
checkEq "on the local lines" [provenance 0] {source local depth 18}

::review::reset
resetAll

puts "\nno curl: the cdb client falls back to the Tcl http package"

# The stub above is the module's contract. This section replaces it with the
# REAL ::cdbeval::transport, because the finding is in the transport: with no
# curl on PATH the stored read must still be answered - by ::http::geturl, from
# the event loop - rather than reported as a dead connection, and a reply that
# never arrived must not read as "ChessDB holds nothing here".
source [file join $root tcl tools cdb_eval.tcl]

# A loopback server stands in for chessdb.cn: nothing here leaves the machine,
# and the status and body it answers are the test's to set. Non-blocking on
# purpose - the http package connects asynchronously, and a blocking `gets` in
# an accept handler would hold the event loop until the request line arrived.
set ::httpCode 200
set ::httpBody ""
set ::httpHits 0
proc httpAccept {chan addr port} {
    fconfigure $chan -blocking 0 -translation binary
    set ::httpBuf($chan) ""
    fileevent $chan readable [list httpServed $chan]
}
proc httpServed {chan} {
    if {[catch { append ::httpBuf($chan) [read $chan] }]} {
        fileevent $chan readable {}
        unset -nocomplain ::httpBuf($chan)
        catch { close $chan }
        return
    }
    if {[string first "\n\n" [string map {"\r\n" "\n"} $::httpBuf($chan)]] < 0} {
        if {[eof $chan]} {
            fileevent $chan readable {}
            unset -nocomplain ::httpBuf($chan)
            catch { close $chan }
        }
        return
    }
    fileevent $chan readable {}
    unset -nocomplain ::httpBuf($chan)
    incr ::httpHits
    set body $::httpBody
    puts -nonewline $chan "HTTP/1.1 $::httpCode X\r\nContent-Type: application/json\r\nContent-Length: [string length $body]\r\nConnection: close\r\n\r\n$body"
    flush $chan
    after 100 [list catch [list close $chan]]
}
set server [socket -server httpAccept 0]
set ::httpPort [lindex [fconfigure $server -sockname] 2]

set savedUrl $::cdbeval::apiUrl
set ::cdbeval::apiUrl "http://127.0.0.1:$::httpPort/cdb.php"
# No curl, and no shell to find one with: the pipeline cannot start.
set savedPath $::env(PATH)
set ::env(PATH) /nonexistent

# A reply that has to be waited for must fail the check, not hang the harness.
proc waitFor {varName ms} {
    upvar #0 $varName var
    set deadline [expr {[clock milliseconds] + $ms}]
    while {![info exists var] && [clock milliseconds] < $deadline} {
        after 20 {set ::tick 1}
        vwait ::tick
        unset -nocomplain ::tick
    }
    if {![info exists var]} { return "__timeout__" }
    return $var
}

::cdbeval::reset
unset -nocomplain ::cdbReply
set ::httpBody [pvJson 30 40]
set ::httpCode 200
set t0 [clock milliseconds]
::cdbeval::evaluateAsync $::whiteFen 3 \
    {apply {{ok entry err} {set ::cdbReply [list $ok $entry $err]}}}
set elapsed [expr {[clock milliseconds] - $t0}]
check "the caller is not held while the fallback request runs" [expr {$elapsed < 500}]
set got [waitFor ::cdbReply 8000]
checkEq "the fallback answers with the stored read" [lindex $got 0] 1
checkEq "parsed to the reply's own depth" [dict get [lindex $got 1] depth] 30
checkEq "and named as chessdb's" [dict get [lindex $got 1] provider] chessdb
checkEq "over http, not a child" $::httpHits 1

# A 500 is the transport failing, with the same reason the curl path gives: the
# reply did not arrive - never an empty evaluation.
set ::httpCode 500
set ::httpBody "{\"error\":\"boom\"}"
unset -nocomplain ::cdbReply
::cdbeval::reset
::cdbeval::evaluateAsync $::whiteFen 3 \
    {apply {{ok entry err} {set ::cdbReply [list $ok $entry $err]}}}
lassign [waitFor ::cdbReply 8000] ok entry err
checkEq "a 500 is a failure, not an empty answer" $ok 0
checkEq "and it names the status" $err \
    "the chessdb reply did not arrive (HTTP 500)"
checkEq "which latches the provider for the pass" [::cdbeval::enabled] 0
::cdbeval::newPass
checkEq "and the next pass asks again" [::cdbeval::enabled] 1

set ::env(PATH) $savedPath
set ::cdbeval::apiUrl $savedUrl
catch { close $server }

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
