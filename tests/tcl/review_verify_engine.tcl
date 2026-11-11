#!/usr/bin/env tclsh
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_verify_engine.tcl -- the verifier's searches, driven by a scripted engine.
#
#   tclsh tests/tcl/review_verify_engine.tcl
#
# tests/tcl/review_verify.tcl pins what a second engine's answer means; this one
# drives the loop that gets the answer. The verifier must use the driver's own
# connection and its per-position queue - one place decides how an engine is
# opened, configured, fed and closed - and it must ask for the pass's own depth
# floor and time ceiling, so a capped review stays capped in its second opinion.
#
# Nothing here waits: every reply is fed as an engine message, exactly as
# ::engine::reply delivers one, and the write is a callback. There is no vwait in
# the module - a caller inside an engine reply or a button press is never
# blocked on the verifier.

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

proc ::options.store {args} {}
set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools score_seed.tcl]
source [file join $root tcl enginecfg.tcl]
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools game_review.tcl]
source [file join $root tcl tools review_driver.tcl]
source [file join $root tcl tools review_verify.tcl]

# The engine layer, stubbed: what the verifier's job is here is which messages it
# sends and what it does with the replies, not how a pipe to Stockfish works.
set ::sent {}
set ::closed {}
set ::engines_started {}
namespace eval ::engine {}
proc ::engine::setLogCmd {id args} {}
proc ::engine::connect {id callback exe args {protocols {uci xboard}}} {
    set ::engconn(channel_$id) chan[incr ::connseq]
    set ::engconn(callback_$id) $callback
    set ::engine_callback $callback
    lappend ::sent [list connect $id $exe $args $protocols]
    lappend ::engines_started $exe
}
proc ::engine::send {id msg args} {
    lappend ::sent [list send $id $msg [lindex $args 0]]
}
proc ::engine::close {id} {
    unset -nocomplain ::engconn(channel_$id)
    unset -nocomplain ::engconn(callback_$id)
    lappend ::closed $id
}
set ::connseq 0

proc feed {msgType msgData} {
    {*}$::engine_callback [list $msgType $msgData]
}

# ::reviewdriver::finish queues the close rather than closing inside the reply
# (a close there unset the arrays ::engine::reply walks next), so a test that
# wants to see it has to run the event loop.
proc pump {} {
    after idle {set ::pumped 1}
    vwait ::pumped
    unset -nocomplain ::pumped
}

# The analysis engine and the verifier, as ::enginecfg::get returns them: name,
# exe, args, wdir, elo, time, url, uci, options, limits. The verifier's preset is
# a different engine on purpose - a label re-confirmed by the engine that produced
# it proves nothing.
set ::analysisCfg {Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {{MultiPV 3 spin 1 1 10}}}
set ::verifierCfg {Komodo /usr/bin/komodo {} {} 0 0 {} 1 {{
    {MultiPV 1 spin 1 1 10}
}}}
set ::xboardCfg {Old /usr/bin/old {} {} 0 0 {} 0 {}}

set ::map [dict create plies 4 \
    moves [dict create 1 e2e4 2 e7e5 3 g1f3 4 b8c6] \
    positions [dict create \
        0 {position startpos} \
        1 {position startpos moves e2e4} \
        2 {position startpos moves e2e4 e7e5} \
        3 {position startpos moves e2e4 e7e5 g1f3} \
        4 {position startpos moves e2e4 e7e5 g1f3 b8c6}]]
# The analysis engine preferred e7e5 at position 1 and b8c6 at position 3.
set ::results [dict create \
    0 [dict create 1 [list 20 30 cp {e2e4 e7e5}]] \
    1 [dict create 1 [list 20 20 cp {e7e5 g1f3}]] \
    2 [dict create 1 [list 20 25 cp {g1f3 b8c6}]] \
    3 [dict create 1 [list 20 10 cp {b8c6 d2d4}]]]

proc reset {} {
    set ::sent {}
    set ::closed {}
    set ::engines_started {}
    set ::got ""
    set ::done 0
}
proc onCorrections {corr} { set ::got $corr ; set ::done 1 }

##############################################################################
puts "\nnothing to verify is not a search"

reset
set ::review::S [::review::reset]
set labels [dict create 1 best 2 good]
set jobs [::reviewverify::jobs $::map $::results $labels 0]
checkEq "no candidates, no jobs" $jobs {}
checkEq "and no engine is opened" \
    [::reviewverify::start $::verifierCfg $jobs 2 {depth 18} ::onCorrections] ""
checkEq "nothing was sent" $::sent {}

puts "\nan XBoard preset would never answer the handshake"

set jobs [::reviewverify::jobs $::map $::results [dict create 2 brilliant] 0]
checkEq "the verifier refuses a preset that is not UCI" \
    [::reviewverify::start $::xboardCfg $jobs 2 {depth 18} ::onCorrections] ""
checkEq "and opens nothing" $::sent {}

##############################################################################
puts "\nthe search runs on the driver's own connection"

reset
set labels [dict create 2 brilliant 4 great]
set jobs [::reviewverify::jobs $::map $::results $labels 0]
set lim [dict create depth 22 movetime 400]
set token [::reviewverify::start $::verifierCfg $jobs 2 $lim ::onCorrections]
check "the verifier has a job" [expr {$token ne ""}]
checkEq "on the pass's own connection id" [lindex $::sent 0] \
    {connect 20 /usr/bin/komodo {} uci}
checkEq "with the verifier's own engine, not the analysis one" \
    $::engines_started {/usr/bin/komodo}
check "the verifier is active" [::reviewverify::active]

feed InfoConfig {MultiPV 2}
set opt [lsearch -inline $::sent {send 20 SetOptions*}]
check "it asks for two lines: a Great claim is a gap" [string match {*MultiPV 2*} $opt]
checkEq "the first candidate position is searched at the pass's depth and cap" \
    [lindex $::sent end] {send 20 Go {{position startpos moves e2e4} {{depth 22} {movetime 400}}}}

puts "\nthe second engine disagrees about the best move"

feed InfoPV {1 22 24 900 400 0 0 120 30 cp 0 g1f3 e7e5}
feed InfoPV {2 22 24 800 400 0 0 120 10 cp 0 e7e5 g1f3}
feed InfoBestMove {}
checkEq "the next candidate is searched" [lindex $::sent end] \
    {send 20 Go {{position startpos moves e2e4 e7e5 g1f3} {{depth 22} {movetime 400}}}}

feed InfoPV {1 22 24 900 400 0 0 120 30 cp 0 b8c6 d2d4}
feed InfoPV {2 22 24 850 400 0 0 120 -20 cp 0 d2d4 b8c6}
feed InfoBestMove {}
checkEq "the verifier answered" $::done 1
checkEq "the Brilliant move the second engine did not prefer falls to Best" \
    [dict get $::got 2] best
checkEq "and the Great move whose gap is 50 cp falls too" [dict get $::got 4] best
check "the verifier is no longer active" [expr {![::reviewverify::active]}]
checkEq "the engine is not closed from inside the last reply" $::closed {}
pump
checkEq "and is closed once the reply has returned" $::closed {20}

##############################################################################
puts "\nwhen the second engine agrees"

reset
set jobs [::reviewverify::jobs $::map $::results [dict create 2 brilliant] 0]
::reviewverify::start $::verifierCfg $jobs 2 {depth 18} ::onCorrections
feed InfoConfig {MultiPV 2}
feed InfoPV {1 20 22 900 400 0 0 120 30 cp 0 e7e5 g1f3}
feed InfoPV {2 20 22 800 400 0 0 120 10 cp 0 g1f3 e7e5}
feed InfoBestMove {}
checkEq "the verifier answered" $::done 1
checkEq "there is nothing to correct" $::got {}
pump

##############################################################################
puts "\na search that returns nothing corrects nothing"

reset
set jobs [::reviewverify::jobs $::map $::results [dict create 2 brilliant] 0]
::reviewverify::start $::verifierCfg $jobs 2 {depth 18} ::onCorrections
feed InfoConfig {MultiPV 2}
# Bounds are not a measurement, and a line with no PV is not an answer.
feed InfoPV {1 20 22 900 400 0 0 120 30 lowerbound 0}
feed InfoBestMove {}
checkEq "the verifier answered" $::done 1
checkEq "and the label is left exactly as the search produced it" $::got {}
pump

##############################################################################
puts "\nan engine that dies mid-search is a skipped verification"

reset
set jobs [::reviewverify::jobs $::map $::results [dict create 2 brilliant] 0]
::reviewverify::start $::verifierCfg $jobs 2 {depth 18} ::onCorrections
feed InfoConfig {MultiPV 2}
feed InfoDisconnected {}
checkEq "the write still happens, with no corrections" $::done 1
checkEq "and nothing is changed" $::got {}
checkEq "nothing is closed, because there is nothing left to close" $::closed {}
check "the verifier is no longer active" [expr {![::reviewverify::active]}]

##############################################################################
puts "\ncancelling the run drops the search"

reset
set jobs [::reviewverify::jobs $::map $::results [dict create 2 brilliant] 0]
::reviewverify::start $::verifierCfg $jobs 2 {depth 18} ::onCorrections
feed InfoConfig {MultiPV 2}
checkEq "stop answers that there was a search" [::reviewverify::stop] 1
check "the verifier is no longer active" [expr {![::reviewverify::active]}]
checkEq "and it never answered the write" $::done 0
pump
checkEq "the engine is closed" $::closed {20}
checkEq "a second stop has nothing to do" [::reviewverify::stop] 0

##############################################################################
puts "\nand it never waits on the caller's thread"

# The rule the design turns on: the searches answer through the event loop, so a
# caller inside an engine reply (the pass) or a button press (Rapid Annotate) is
# never blocked. A vwait here would be exactly that block. Comments are stripped
# first: this file's own prose names the thing it forbids.
proc codeOnly {path} {
    set fh [open $path r]
    set out {}
    foreach line [split [read $fh] "\n"] {
        set t [string trim $line]
        if {[string index $t 0] eq "#"} { continue }
        lappend out $t
    }
    close $fh
    return [join $out "\n"]
}
set src [codeOnly [file join $root tcl tools review_verify.tcl]]
check "review_verify.tcl contains no vwait" [expr {[string first vwait $src] < 0}]
check "nor does it create a nested event loop" \
    [expr {[string first "tkwait" $src] < 0}]
set drv [codeOnly [file join $root tcl tools review_driver.tcl]]
check "the driver's verifier seam contains no vwait" \
    [expr {[string first vwait $drv] < 0}]

##############################################################################
puts "\nthe seam hands the pass's own bounds to the search"

# ::reviewdriver::verifyWrite is what every caller arrives at; the checks above
# drive ::reviewverify::start directly. This pins the hand-off itself: the
# verifier searches under the same limits the pass had (not a deeper search of
# its own, so a capped review stays capped), and asks for two lines whatever the
# pass asked for, because a Great claim is a gap. The verdicts are stubbed: which
# labels are candidates is review_verify.tcl's subject.
reset
set ::review::S [::review::reset]
proc ::enginecfg::get {name} { return $::verifierCfg }
rename ::reviewdriver::verdicts ::reviewdriver_verdicts_real_
proc ::reviewdriver::verdicts {map results} { return [dict create 2 {brilliant 0 1}] }
set p [dict create map $::map plan {1 2 3 4} plies 4 bookEnd 0 mpv 1 \
    verifier Komodo limits [dict create depth 28 movetime 900]]
set ::wrote 0
set ::wroteCorr ""
proc seamWrite {results corrections} { set ::wrote 1 ; set ::wroteCorr $corrections }
checkEq "the seam starts a search" \
    [::reviewdriver::verifyWrite $p $::results [list seamWrite]] 1
checkEq "and writes nothing until it answers" $::wrote 0
checkEq "the search is the verifier's own engine" $::engines_started {/usr/bin/komodo}
feed InfoConfig {MultiPV 2}
checkEq "two lines, whatever the pass asked for" \
    [lsearch -inline $::sent {send 20 SetOptions*}] {send 20 SetOptions {{MultiPV 2}}}
checkEq "the pass's own depth and cap, not a deeper search" \
    [lindex $::sent end] {send 20 Go {{position startpos moves e2e4} {{depth 28} {movetime 900}}}}
feed InfoPV {1 28 30 900 400 0 0 120 30 cp 0 g1f3 e7e5}
feed InfoBestMove {}
checkEq "the answer writes the review" $::wrote 1
# The seam hands the writer the raw results plus the corrections; folding them in
# is the writer's own step (::reviewdriver::verified, tested in review_verify.tcl),
# so the correction is what this check looks at.
checkEq "with the withdrawal handed to the writer" $::wroteCorr [dict create 2 best]
rename ::reviewdriver::verdicts {}
rename ::reviewdriver_verdicts_real_ ::reviewdriver::verdicts

##############################################################################
puts "\nthe analysis engine is not its own verifier"

reset
set ::review::S [::review::reset]
proc ::enginecfg::get {name} { return $::verifierCfg }
rename ::reviewdriver::verdicts ::reviewdriver_verdicts_real_
proc ::reviewdriver::verdicts {map results} { return [dict create 2 {brilliant 0 1}] }
set same [dict create map $::map plan {1 2 3 4} plies 4 bookEnd 0 mpv 3 \
    engine [list Komodo /usr/bin/komodo {} {} 0 0 {} 1 {} {}] \
    verifier Komodo limits [dict create depth 20]]
set ::wroteSame 0
proc sameWrite {results corrections} { set ::wroteSame 1 }
checkEq "the same preset writes unverified" \
    [::reviewdriver::verifyWrite $same $::results [list sameWrite]] 0
checkEq "and starts no second search" $::sent {}
checkEq "but the write still happens" $::wroteSame 1
rename ::reviewdriver::verdicts {}
rename ::reviewdriver_verdicts_real_ ::reviewdriver::verdicts

##############################################################################
puts "\ntwo callers take turns on the one connection"

# The batch annotator finishes a second game while the first game's second
# opinion is still running; both want connection 20. The later search waits its
# turn rather than being skipped (which would write a label nobody verified) or
# taking the connection from the search in flight.
reset
set ::review::S [::review::reset]
# Nothing from the sections above is left in flight: the connection is free and
# this module has no search and nothing queued.
::reviewverify::stop
set ::reviewverify::token ""
set ::reviewverify::queue {}
while {[::reviewdriver::busy $::reviewdriver::ENGINE_ID]} { pump }
proc ::enginecfg::get {name} { return $::verifierCfg }
rename ::reviewdriver::verdicts ::reviewdriver_verdicts_real_
proc ::reviewdriver::verdicts {map results} { return [dict create 2 {brilliant 0 1}] }
set p [dict create map $::map plan {1 2 3 4} plies 4 bookEnd 0 mpv 3 \
    verifier Komodo limits [dict create depth 20]]
set ::writes {}
proc seamWrite {results corrections} { lappend ::writes $corrections }
set first [::reviewdriver::verifyWrite $p $::results [list seamWrite]]
checkEq "the first caller searches" $first 1
set second [::reviewdriver::verifyWrite $p $::results [list seamWrite]]
check "the second caller is queued, not refused" \
    [expr {$second eq "1" && [llength $::reviewverify::queue] == 1}]
checkEq "and has written nothing yet" $::writes {}
feed InfoConfig {MultiPV 2}
feed InfoPV {1 20 30 900 400 0 0 120 30 cp 0 g1f3 e7e5}
feed InfoBestMove {}
checkEq "the first search answers and writes once" [llength $::writes] 1
checkEq "with its withdrawal" [lindex $::writes 0] [dict create 2 best]
pump
feed InfoConfig {MultiPV 2}
checkEq "the waiting search runs on the same connection and position" \
    [lindex $::sent end] {send 20 Go {{position startpos moves e2e4} {{depth 20}}}}
feed InfoPV {1 20 30 900 400 0 0 120 30 cp 0 e7e5 g1f3}
feed InfoBestMove {}
checkEq "the second search writes its own result" [llength $::writes] 2
checkEq "with no correction, because it agreed" [lindex $::writes 1] {}
rename ::reviewdriver::verdicts {}
rename ::reviewdriver_verdicts_real_ ::reviewdriver::verdicts

puts "\ncancelling a queued token leaves the active search alone"

# One run is searching, a second is queued behind it. Cancelling the second by
# the token verifyWrite recorded must remove only that queue entry; the active
# search has to answer and write normally.
reset
set ::review::S [::review::reset]
::reviewverify::stop
set ::reviewverify::token ""
set ::reviewverify::queue {}
while {[::reviewdriver::busy $::reviewdriver::ENGINE_ID]} { pump }
proc ::enginecfg::get {name} { return $::verifierCfg }
rename ::reviewdriver::verdicts ::reviewdriver_verdicts_real_
proc ::reviewdriver::verdicts {map results} { return [dict create 2 {brilliant 0 1}] }
set p [dict create map $::map plan {1 2 3 4} plies 4 bookEnd 0 mpv 3 \
    verifier Komodo limits [dict create depth 20]]
set ::writes {}
proc seamWrite {results corrections} { lappend ::writes $corrections }
::reviewdriver::verifyWrite $p $::results [list seamWrite]
::reviewdriver::verifyWrite $p $::results [list seamWrite]
set queued [lindex $::reviewverify::queue 0 5]
checkEq "the queued token can be named" [::reviewverify::stop $queued] 1
checkEq "and only it is removed" [llength $::reviewverify::queue] 0
feed InfoConfig {MultiPV 2}
feed InfoPV {1 20 30 900 400 0 0 120 30 cp 0 g1f3 e7e5}
feed InfoBestMove {}
checkEq "the active search still writes" [llength $::writes] 1
checkEq "and the cancelled queued search writes nothing" [llength $::writes] 1
rename ::reviewdriver::verdicts {}
rename ::reviewdriver_verdicts_real_ ::reviewdriver::verdicts

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
