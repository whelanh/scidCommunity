# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_prose.tcl -- the coach queue, with a stub provider.
#
#   tclsh tests/tcl/review_prose.tcl
#
# The runner must send one prompt at a time, keep the answers, drop a failed
# request, cache by prompt, and cancel without calling the model again.

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

namespace eval ::auto_comment {}
set ::asked {}
set ::replies {}
set ::delay 0
proc ::auto_comment::queryAsync {prompt {max 300} cb} {
    lappend ::asked $prompt
    set text [lindex $::replies [expr {[llength $::asked] - 1}]]
    if {$text eq ""} { set text "answer [llength $::asked]" }
    after $::delay [list {*}$cb $text]
    return "tok[llength $::asked]"
}
proc ::auto_comment::cancelAsync {token} { lappend ::cancelled $token }
proc ::auto_comment::cleanupText {text} { return [string trim $text] }

proc item {kind key prompt} {
    return [dict create kind $kind key $key prompt $prompt]
}
proc runIt {prompts} {
    set ::done 0
    set ::results {}
    set ::errors {}
    set ::progress {}
    set ::cancelled 0
    ::reviewprose::run $prompts \
        [list apply {{d t k key text err} {lappend ::progress [list $d $t $k $key $text $err]}}] \
        [list apply {{r e c} {set ::results $r ; set ::errors $e ; set ::cancelled $c ; set ::done 1}}]
    if {!$::done} { vwait ::done }
}

puts "\none prompt at a time"

set prompts [list [item move 1 "move prompt"] [item phase opening "phase prompt"]]
set ::asked {}
set ::replies [list "the move" "the phase"]
runIt $prompts
checkEq "both prompts were sent" [llength $::asked] 2
checkEq "the first answer is kept" [dict get $::results [list move 1 "move prompt"]] "the move"
checkEq "the second too" [dict get $::results [list phase opening "phase prompt"]] "the phase"
checkEq "progress starts at zero, before the first answer" [lindex $::progress 0 0] 0
checkEq "progress counts both" [llength $::progress] 3
checkEq "and ends at two" [lindex $::progress end 0] 2

puts "\nthe cache answers the second run"

set ::asked {}
runIt $prompts
checkEq "nothing was sent again" [llength $::asked] 0
checkEq "the cached answer is still there" [dict get $::results [list move 1 "move prompt"]] "the move"

puts "\na failed request is dropped, not fatal"

::reviewprose::clearCache
set ::asked {}
set ::replies [list "ERROR: no model" "the phase"]
runIt $prompts
checkEq "the good answer is written" [dict size $::results] 1
checkEq "the failure is recorded" [dict size $::errors] 1
checkEq "and the next prompt still ran" [llength $::asked] 2

puts "\ncancel stops before the next prompt"

::reviewprose::clearCache
set ::asked {}
set ::replies [list "slow"]
set ::delay 60
set prompts [list [item move 2 "slow"] [item move 3 "never"]]
set ::done 0
set ::results {} ; set ::errors {} ; set ::progress {}
::reviewprose::run $prompts {} [list apply {{r e c} {set ::results $r ; set ::errors $e ; set ::cancelled $c ; set ::done 1}}]
after 5 ::reviewprose::cancel
vwait ::done
checkEq "the outstanding request was cancelled" [llength $::cancelled] 1
checkEq "and the second prompt was never sent" [llength $::asked] 1
checkEq "the run says it was cancelled" $::cancelled 1

puts "\nthe prose the model writes"

# The summary answers in three labelled lines. Cleaning must not fold them
# together, or LEVEL and OPENING become part of the summary.
set three "SUMMARY: one.\nLEVEL: two.\nOPENING: three."
checkEq "the summary keeps its labelled lines" [::reviewprose::clean $three] $three
checkEq "a typographic dash becomes ascii" \
    [::reviewprose::clean "a [format %c 8211] b"] "a - b"
checkEq "brackets cannot open a token of ours" \
    [::reviewprose::clean "text \[Coach\] more"] "text Coach more"

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
