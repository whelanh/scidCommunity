# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_prose.tcl -- the coach queue, with a stub provider.
#
#   tclsh tests/tcl/review_prose.tcl
#
# The runner must send one prompt at a time and in order, keep the answers, drop
# a failed request without failing the run, answer a repeat from the cache, and
# cancel without asking for another. Nothing here touches a network or a board:
# ::auto_comment::queryAsync is replaced by a stub that hands the test the
# callback it was given, so a reply can arrive when the test says so - including
# a reply for the wrong question, and a reply from a run that was cancelled.

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

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools review_prose.tcl]

# The stub provider: every request is recorded, and its callback is kept so the
# test decides when (and whether) an answer arrives.
namespace eval ::auto_comment {}
set ::asked {}
set ::asks {}
set ::cancelled {}
set ::seq 0
proc ::auto_comment::queryAsync {prompt {max 300} cb} {
    lappend ::asked [list $prompt $max]
    lappend ::asks [list $prompt $max $cb]
    incr ::seq
    return "tok$::seq"
}
proc ::auto_comment::cancelAsync {token} { lappend ::cancelled $token }
proc ::auto_comment::cleanupText {text} { return [string trim $text] }

# Answer the oldest outstanding request.
proc answer {text} {
    set ask [lindex $::asks 0]
    set ::asks [lrange $::asks 1 end]
    {*}[lindex $ask 2] $text
}
proc answersQueued {} { return [llength $::asks] }

proc item {kind key prompt {max ""}} {
    set d [dict create kind $kind key $key prompt $prompt]
    if {$max ne ""} { dict set d max $max }
    return $d
}

proc runIt {prompts} {
    set ::done 0
    set ::results {}
    set ::errors {}
    set ::progress {}
    set ::wasCancelled 0
    # A run starts with no outstanding question. Anything still here belongs to
    # a run that was cancelled, and is captured by name where a test needs it.
    set ::asks {}
    ::reviewprose::run $prompts \
        [list apply {{d t k key text err} {
            lappend ::progress [list $d $t $k $key $text $err]
        }}] \
        [list apply {{r e c} {
            set ::results $r ; set ::errors $e ; set ::wasCancelled $c ; set ::done 1
        }}]
    return
}
# Let the queue advance (every answer schedules the next request with `after 0`)
# and stop when the run says it is finished.
proc settle {} {
    for {set i 0} {$i < 200} {incr i} {
        if {$::done} { return }
        after 5 {set ::tick 1}
        vwait ::tick
        unset -nocomplain ::tick
    }
}

puts "\none prompt at a time, in order"

set prompts [list [item move 1 "move prompt"] [item phase opening "phase prompt"]]
runIt $prompts
checkEq "the first prompt is sent before any answer" [llength $::asked] 1
checkEq "and it is the first one" [lindex $::asked 0 0] "move prompt"
checkEq "progress starts at zero, before the first answer" [lindex $::progress 0 0] 0
checkEq "the run is not finished while a question is open" $::done 0
answer "the move"
settle
checkEq "the second prompt follows the first answer" [lindex $::asked 1 0] "phase prompt"
checkEq "one request at a time, never two" [llength $::asked] 2
checkEq "nothing is outstanding once the reply landed" [answersQueued] 1
answer "the phase"
settle
checkEq "the run finishes when the queue is empty" $::done 1
checkEq "the first answer is kept under its own key" \
    [dict get $::results [list move 1 "move prompt"]] "the move"
checkEq "and the second under its own" \
    [dict get $::results [list phase opening "phase prompt"]] "the phase"
checkEq "progress counts the start and both answers" [llength $::progress] 3
checkEq "and ends at two" [lindex $::progress end 0] 2
checkEq "each answer is reported with its own subject" \
    [lindex $::progress end 2] "phase"

puts "\nthe item's own token budget reaches the provider"

set ::asked {}
runIt [list [item summary 0 "sum" 800] [item move 3 "moment" 320]]
answer "S"
settle
answer "M"
settle
checkEq "the summary asks for its own budget" [lindex $::asked 0 1] 800
checkEq "and a move for its own" [lindex $::asked 1 1] 320

puts "\nthe cache answers the second run"

::reviewprose::clearCache
set ::asked {}
runIt $prompts
answer "again"
settle
answer "again too"
settle
set ::asked {}
runIt $prompts
settle
checkEq "nothing was sent again" [llength $::asked] 0
checkEq "and the run still finished" $::done 1
checkEq "with the cached answer under its key" \
    [dict get $::results [list move 1 "move prompt"]] "again"

puts "\na failed request is dropped, not fatal"

::reviewprose::clearCache
set ::asked {}
runIt $prompts
answer "ERROR: no model"
settle
checkEq "the next prompt still ran" [llength $::asked] 2
answer "the phase"
settle
checkEq "the good answer is written" [dict size $::results] 1
checkEq "the failure is recorded" [dict size $::errors] 1
checkEq "and the run finished" $::done 1
checkEq "the failure is not text" [dict get $::results [list phase opening "phase prompt"]] "the phase"

puts "\na reply for a question that is no longer outstanding is ignored"

::reviewprose::clearCache
set ::asked {}
runIt $prompts
set firstCb [lindex $::asks 0 2]
answer "right"
settle
checkEq "the first answer moved the queue on" \
    [dict get [::reviewprose::status] done] 1
checkEq "and the second question was asked" [lindex $::asked 1 0] "phase prompt"
# The same callback again: a duplicated or retried delivery of a question that
# is already answered. It must not advance the queue past the question that is
# now outstanding, and it must not replace the answer that landed.
{*}$firstCb "duplicate"
settle
checkEq "a repeated answer does not advance the queue again" \
    [dict get [::reviewprose::status] done] 1
answer "the phase"
settle
checkEq "the recorded answer is still the first one" \
    [dict get $::results [list move 1 "move prompt"]] "right"
checkEq "both answers landed" [dict size $::results] 2
checkEq "and the run finished" $::done 1

puts "\ncancel stops before the next prompt"

::reviewprose::clearCache
set ::asked {}
set ::cancelled {}
runIt [list [item move 4 "slow"] [item move 5 "never"]]
::reviewprose::cancel
settle
checkEq "the outstanding request was cancelled" [llength $::cancelled] 1
checkEq "and the next prompt was never sent" [llength $::asked] 1
checkEq "the run says it was cancelled" $::wasCancelled 1
checkEq "and it finished" $::done 1
checkEq "keeping nothing, because nothing had arrived" [dict size $::results] 0

puts "\na cancelled answer cannot land in the next run"

::reviewprose::clearCache
set ::asked {}
runIt [list [item move 6 "first run"]]
set stale [lindex $::asks 0 2]
set ::asks [lrange $::asks 1 end]
::reviewprose::cancel
settle
# A new run, then the old request's reply. It belongs to no live question.
runIt [list [item move 7 "second run"]]
{*}$stale "answer to a dead run"
settle
checkEq "the dead run's answer is not given to the live one" [dict size $::results] 0
checkEq "and the live run is still waiting" $::done 0
answer "fresh"
settle
checkEq "its own answer is recorded" \
    [dict get $::results [list move 7 "second run"]] "fresh"
checkEq "and the run finished" $::done 1

puts "\nthe prose the model writes"

# The summary answers in three labelled lines. Cleaning must not fold them
# together, or LEVEL and OPENING become part of the summary.
set three "SUMMARY: one.\nLEVEL: two.\nOPENING: three."
checkEq "the summary keeps its labelled lines" [::reviewprose::clean $three] $three
checkEq "a typographic dash becomes ascii" \
    [::reviewprose::clean "a [format %c 8211] b"] "a - b"
checkEq "a curly quote becomes ascii" \
    [::reviewprose::clean "it[format %c 8217]s"] "it's"
checkEq "brackets cannot open a token of ours" \
    [::reviewprose::clean "text \[Coach\] more"] "text Coach more"
checkEq "surrounding quotes come off" \
    [::reviewprose::clean "\"a note\""] "a note"
check "a runaway answer is cut" \
    [expr {[string length [::reviewprose::clean [string repeat "x" 900]]] == 600}]
checkEq "an empty answer stays empty" [::reviewprose::clean "   "] ""

puts "\nthe status a caller can ask for"

check "an idle queue says so" \
    [expr {[dict get [::reviewprose::status] active] == 0}]
::reviewprose::clearCache
runIt [list [item move 8 "a"] [item move 9 "b"]]
checkEq "a running queue knows its place" \
    [list [dict get [::reviewprose::status] active] [dict get [::reviewprose::status] done] \
          [dict get [::reviewprose::status] total]] {1 0 2}
::reviewprose::cancel
settle

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
