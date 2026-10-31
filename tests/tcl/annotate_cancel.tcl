#!/usr/bin/env tclsh
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# annotate_cancel.tcl -- a cancelled annotate pass saves nothing and does not
# advance the batch.
#
#   tclsh tests/tcl/annotate_cancel.tcl
#
# Opening another game stops every review that is running: ::enginewin::onNewGame
# (tcl/windows/engine.tcl:171) calls ::enginewin::reviewStopAll, which calls
# ::reviewdriver::cancel 0. The driver stops the pass, marks its status
# `cancelled`, and fires the pass's done hook with that status
# (tcl/tools/review_driver.tcl:88-110, :116).
#
# In a batch - more than one game - ::reviewannotate::done must read that as the
# end of the run: give the borrowed game back and stop. What it must not do is
# run the finished-game step, because that step saves the game that is loaded
# *now* - the one the user just opened - into the batch's own slot, and then
# loads the next game of the range, annotating games nobody asked for any more.
#
# Only the game commands and the chain's next step are stubbed; the cancel is
# driven through the driver's own ::reviewdriver::cancel, and the finish through
# its own ::reviewdriver::endRun, so `done` receives exactly the status dict the
# application hands it and no engine, book or Tk code is reached.

set fails 0
set checks 0

proc check {label cond {detail ""}} {
    incr ::checks
    if {$cond} {
        puts "  ok   $label"
    } else {
        incr ::fails
        if {$detail eq ""} {
            puts "  FAIL $label"
        } else {
            puts "  FAIL $label -- $detail"
        }
    }
}

proc checkEq {label got want} {
    check $label [expr {$got eq $want}] "got '$got' want '$want'"
}

proc ::tr {tag} { return $tag }
set ::messages {}
proc tk_messageBox {args} {
    lappend ::messages [dict get $args -message]
    return ok
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools review_driver.tcl]
source [file join $root tcl tools review_annotate.tcl]

########################################################################
### The stubs: the game commands, the chain's next step, the engine

set ::saves {}
set ::loads {}
set ::pops 0
set ::pushes 0
set ::nextGames 0
set ::sent {}
set ::currentGame 3

# sc_game save is the one this test is about, so it is a counter rather than a
# no-op: a saved game is recorded by number, and the numbers say which game the
# batch wrote into.
proc sc_game {sub args} {
    switch -- $sub {
        save { lappend ::saves [lindex $args 0] ; return "" }
        load { lappend ::loads [lindex $args 0] ; set ::currentGame [lindex $args 0] ; return "" }
        number { return $::currentGame }
        push { incr ::pushes ; return "" }
        pop  { incr ::pops ; return "" }
    }
    return ""
}

proc sc_base {sub args} {
    if {$sub eq "current"} { return 0 }
    return ""
}

namespace eval ::notify {}
proc ::notify::DatabaseModified {args} { return }
proc ::notify::PosChanged {args} { return }

# The driver closes its connection on the way out; nothing here owns one.
namespace eval ::engine {}
proc ::engine::send {id msg args} { lappend ::sent [list $id $msg] ; return }
proc ::engine::close {id} { return }

# Advancing the batch is the step a cancelled run must not take. Stubbed, and
# renamed out of the way first, so the count is the whole of what happened: no
# pass is started, no engine is opened.
rename ::reviewannotate::nextGame ::reviewannotate::nextGameReal
proc ::reviewannotate::nextGame {} {
    incr ::nextGames
    return ""
}

########################################################################
### The run state, and the two ways a pass ends

proc resetAll {} {
    set ::saves {}
    set ::loads {}
    set ::pops 0
    set ::pushes 0
    set ::nextGames 0
    set ::sent {}
    set ::reviewannotate::run {}
    set ::reviewannotate::progressText ""
    set ::reviewdriver::state {}
    set ::reviewdriver::pass {}
    set ::currentGame 3
    catch { unset ::reviewdriver::job }
    return
}

# The run a two-game batch is in once the first game's pass is under way: the
# state ::reviewannotate::nextGame leaves behind after `sc_game push copy` and
# `sc_game load` have put game 3 on the board, so the borrowed marker is set and
# game 3's copy is the one that has to be given back.
proc startBatch {} {
    set plan [dict create \
        refuse "" from 3 to 4 game 3 batch 1 \
        engine {Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {} {}} \
        tier label bookEnd 0 white 1 black 1 varPlies 0]
    set ::reviewannotate::run [dict create \
        plan $plan games {3 4} index 0 stopAfter 0 last {0 3} borrowed 1 game 3]
    return
}

# A pass is running on the driver's connection, and the user opens another game:
# ::enginewin::reviewStopAll's own call, ::reviewdriver::cancel 0. The driver
# stops the pass, sets state=cancelled and calls the done hook with
# ::reviewdriver::status - the cancelled dict, which is what this test asserts on.
proc cancelPass {} {
    set ::reviewdriver::state [dict merge [::reviewdriver::blankState searching] \
        [dict create total 3]]
    set ::reviewdriver::job(20) [dict create id 20 index 1 positions {{1 w KQkq}} \
        lines {} results {} onprogress {} limits {}]
    set ::reviewdriver::pass [dict create token 20 done ::reviewannotate::done \
        notify 0 positions {{1 w}} cursor {} map {} plies {1} engine {} \
        progress "" writer "" mpv 1]
    return [::reviewdriver::cancel 0]
}

# The other end: a pass that searched and wrote its game, so the driver reports a
# final status and fires the same hook through ::reviewdriver::endRun.
proc finishPass {} {
    set ::reviewdriver::state [dict merge [::reviewdriver::blankState done] \
        [dict create searched 3 total 3 written 3]]
    return [::reviewdriver::endRun \
        [dict create token 20 done ::reviewannotate::done notify 0 cursor {}]]
}

########################################################################
### A cancelled pass: no save, no advance, the borrowed game given back

puts "\na cancelled batch pass writes nothing and stops the batch"

resetAll
startBatch
checkEq "the batch is in flight" [::reviewannotate::running] 1
checkEq "Cancel stops the pass" [cancelPass] 1
checkEq "the status the driver hands done is cancelled" \
    [dict get [::reviewdriver::status] state] cancelled

checkEq "nothing is saved" [llength $::saves] 0
checkEq "and the game loaded now is not written into the batch's slot" \
    $::saves {}
checkEq "the batch does not advance" $::nextGames 0
checkEq "no other game is loaded" $::loads {}
checkEq "the run is emptied" $::reviewannotate::run {}
checkEq "the borrowed game is given back, once" $::pops 1
checkEq "and nothing is left running" [::reviewannotate::running] 0

########################################################################
### Opening another game must not hand the batch's copy back over it

puts "\nwhen the board moved on, the batch does not pop over it"

resetAll
startBatch
set ::currentGame 9
set ::nextGames 0
checkEq "Cancel stops the pass" [cancelPass] 1
checkEq "nothing is saved" $::saves {}
checkEq "the user's game is not replaced" $::pops 0
checkEq "the batch does not advance" $::nextGames 0
checkEq "the run is emptied" $::reviewannotate::run {}

########################################################################
### A failed pass is reported, not saved as a completed game

puts "\na failed pass is not saved and does not advance"

resetAll
startBatch
set ::reviewdriver::state [dict merge [::reviewdriver::blankState failed] \
    [dict create reason {the engine stopped after 1 of 3 positions} failed 1]]
set ::reviewdriver::pass {}
checkEq "the failed pass gives the game back" \
    [::reviewdriver::endRun [dict create token 20 done ::reviewannotate::done \
        notify 0 cursor {}]] ""
checkEq "nothing is saved" $::saves {}
check "the failure is reported" \
    [expr {[string first "engine stopped" [lindex $::messages end]] >= 0}]
checkEq "the batch does not advance" $::nextGames 0
checkEq "and nothing is left running" [::reviewannotate::running] 0

########################################################################
### The inverse: a pass that finished still saves its game and advances

puts "\na finished batch pass still saves and advances"

resetAll
startBatch
checkEq "the pass finishes" [finishPass] ""
checkEq "the status the driver hands done is done" \
    [dict get [::reviewdriver::status] state] done
checkEq "the game in flight is saved, once" $::saves {3}
checkEq "the batch advances" $::nextGames 1
checkEq "the borrowed game is given back, once" $::pops 1
check "the run is left for the next game" [expr {
    [dict size $::reviewannotate::run] > 0 && ![dict exists $::reviewannotate::run borrowed]
}]

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
