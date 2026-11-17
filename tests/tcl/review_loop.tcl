# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_loop.tcl -- the review's model call runs ON the event loop, not over it.
#
#   tclsh tests/tcl/review_loop.tcl
#
# The provider transport (::auto_comment::queryAsync) is a child process whose
# reply is read by fileevent; the review's queue (::reviewprose) asks one
# question at a time through it. Two files already pin the two halves apart:
# review_transport.tcl the transport, review_prose.tcl the queue against a stub
# provider. Neither measures the thing the review actually needs - that while a
# request is in flight the Tk event loop keeps turning, so a pending `after`
# fires, the board redraws, and Cancel is answered - because a stub provider
# never has a request in flight at all.
#
# This file puts a real slow child on PATH and measures the loop directly:
#
#   1. an `after` scheduled before the request fires while it is in flight, and
#      the reply has NOT landed when it does;
#   2. forty questions through the queue keep the loop turning, and the same
#      forty through the blocking entry point turn it zero times - the control
#      that proves the measurement is sensitive, and the before/after figure the
#      PR body quotes;
#   3. Cancel pressed mid-flight closes the run at once, without waiting for the
#      answer it will never use;
#   4. no file on the review path reaches for the blocking entry point.

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

# --------------------------------------------------------------- environment --
# What auto_comment.tcl reaches for at load time, with no Tk and no preferences
# of its own. Same preamble as review_transport.tcl: the dialogs are not under
# test, the transport is.
proc options.store {varname {default ""}} {
    if {![info exists $varname]} { set $varname $default }
}
namespace eval ttk {}
namespace eval ::auto_comment {}
proc winfo {args} { return 0 }
proc tk_messageBox {args} { return ok }
proc raise {w} {}
proc focus {args} {}
proc ttk::label {args} {}
proc ttk::labelframe {args} {}
proc ttk::entry {args} {}
proc ttk::button {args} {}
proc ttk::combobox {args} {}
proc ttk::frame {args} {}
proc ttk::checkbutton {args} {}
proc pack {args} {}
proc bind {args} {}
proc font {{args ""}} { return "" }
proc openURL {args} {}
set ::language E
set ::translatePieces 0

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools auto_comment.tcl]
source [file join $root tcl tools review_prose.tcl]

# A temp tree of our own: the stub curl, its reply files, and the request files
# the transport writes. Nothing here touches the user's options or /tmp.
set sysTmp [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) \
              : [info exists ::env(TEMP)] ? $::env(TEMP) : "/tmp"}]
set tmproot [file join $sysTmp "review_loop_[pid]"]
catch { file delete -force $tmproot }
file mkdir [file join $tmproot bin]
set ::env(TMPDIR) $tmproot

# The stub: curl that takes its time. --version answers immediately, because
# post303Flag probes curl once and a slow probe is not the request under test.
set stub [file join $tmproot bin curl]
set fh [open $stub w]
fconfigure $fh -encoding utf-8
# Braced, so Tcl substitutes nothing: every $ below belongs to the shell.
puts $fh {
#!/bin/sh
for a in "$@"; do
  case "$a" in --version) echo "curl 8.23.0 (stub)"; exit 0;; esac
done
sleep "$STUB_CURL_SLEEP"
out=""
prev=""
for a in "$@"; do
  if [ "$prev" = "-o" ]; then out="$a"; fi
  prev="$a"
done
if [ -n "$out" ]; then printf '%s' "$STUB_CURL_BODY" > "$out"; fi
if [ -n "$STUB_CURL_FAIL" ]; then echo "$STUB_CURL_FAIL" >&2; exit 7; fi
printf '%s' "$STUB_CURL_STATUS"
}
close $fh
file attributes $stub -permissions 0755
set ::env(PATH) "[file join $tmproot bin]:$::env(PATH)"
set ::env(STUB_CURL_SLEEP) 1
set ::env(STUB_CURL_STATUS) 200
set ::env(STUB_CURL_BODY) {{"choices":[{"message":{"content":"stub says hi"}}]}}
set ::env(STUB_CURL_STDERR) ""
set ::env(STUB_CURL_FAIL) ""

set ::auto_comment::provider openai
set ::auto_comment::openaiUrl "https://api.example.com"
set ::auto_comment::openaiKey "***"
set ::auto_comment::openaiModel "m"
# post303Flag's probe is answered once here: the measurement below is the
# request and nothing else.
set ::auto_comment::post303 ""

# --------------------------------------------------------------- the clock --
# A heartbeat on the event loop. `tick` is an `after` chain, so the count is the
# number of times Tk came back for work while something else was happening. A
# blocking call runs the loop zero times, which is the whole point.
set ::beats 0
set ::beatTimes {}
set ::beating 0
proc beat {ms} {
    incr ::beats
    lappend ::beatTimes [clock milliseconds]
    set ::beating [after $ms beat $ms]
}
proc beatsStart {ms} {
    beatsStop
    set ::beats 0
    set ::beatTimes {}
    set ::beating [after $ms beat $ms]
}
proc beatsStop {} {
    if {$::beating ne ""} { catch { after cancel $::beating } }
    set ::beating ""
}

# The longest stretch between one turn of the loop and the next, between $from
# and $to: the freeze a user feels, measured where they feel it. The first gap is
# taken from $from and the last from the final beat to $to, so a stall that spans
# the whole window is one gap rather than none.
proc maxGap {from to} {
    set prev $from
    set worst 0
    foreach t $::beatTimes {
        if {$t < $from || $t > $to} { continue }
        set gap [expr {$t - $prev}]
        if {$gap > $worst} { set worst $gap }
        set prev $t
    }
    set tail [expr {$to - $prev}]
    if {$tail > $worst} { set worst $tail }
    return $worst
}

# Run the loop for ms without a condition to wait on: vwait on an `after`.
proc turn {ms} {
    set ::turned 0
    after $ms {set ::turned 1}
    vwait ::turned
    unset -nocomplain ::turned
}

# Wait for a global to be given a value, with a deadline. A value that is
# already there is the answer, not a reason to wait for another.
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

# ------------------------------------------------- 1. a timer during a call --
puts "\nthe event loop keeps turning while a request is in flight"

set ::env(STUB_CURL_SLEEP) 1.5
unset -nocomplain ::got ::fired
set t0 [clock milliseconds]
set token [::auto_comment::queryAsync "in flight" 50 {apply {{text} {set ::got $text}}}]
check "the request started" [expr {$token ne ""}] $token
# A timer set BEFORE the answer can arrive. If the transport blocked, it would
# run after the reply (or not at all until the caller returned).
after 100 {set ::fired [clock milliseconds]}
vwait ::fired
set waited [expr {$::fired - $t0}]
check "the pending after fired while the request was still running" \
    [expr {$waited >= 80 && $waited < 1000}] "fired after ${waited} ms of a 1500 ms stub"
check "the request is still in flight at that moment" \
    [expr {[info exists ::auto_comment::async($token)]}] "the token is already gone"
check "and the reply has not landed yet" [expr {![info exists ::got]}]
checkEq "the answer arrives afterwards, on the loop" [waitFor ::got 8000] "stub says hi"

# ---------------------------- 1b. the two native providers use the same pipe --
puts "\nthe native providers answer on the loop too"

# Gemini and DeepSeek build their own curl argv (their own --max-time: 60 s and
# 180 s). They must reach the same fileevent read - a blocking branch left in
# one of them would freeze the loop for that provider only, which is the kind of
# hole a test of the generic channel would never see.
set ::env(STUB_CURL_SLEEP) 1
set savedProvider $::auto_comment::provider
set savedBody $::env(STUB_CURL_BODY)

set ::auto_comment::provider gemini
set ::auto_comment::apiKey "***"
set ::auto_comment::model "m"
set ::env(STUB_CURL_BODY) {{"candidates":[{"content":{"parts":[{"text":"stub says hi"}]}}]}}
unset -nocomplain ::got
set t0 [clock milliseconds]
set token [::auto_comment::queryAsync "gemini prompt" 50 {apply {{text} {set ::got $text}}}]
set elapsed [expr {[clock milliseconds] - $t0}]
check "gemini answers with a token" [expr {$token ne ""}] $token
check "and its caller came back before the model did" [expr {$elapsed < 500}] \
    "took ${elapsed} ms against a 1000 ms stub"
checkEq "its text arrives by callback" [waitFor ::got 8000] "stub says hi"

set ::auto_comment::provider deepseek
set ::auto_comment::deepseekApiKey "***"
set ::auto_comment::deepseekModel "m"
set ::env(STUB_CURL_BODY) {{"choices":[{"message":{"content":"stub says hi"}}]}}
unset -nocomplain ::got
set t0 [clock milliseconds]
set token [::auto_comment::queryAsync "deepseek prompt" 50 {apply {{text} {set ::got $text}}}]
set elapsed [expr {[clock milliseconds] - $t0}]
check "deepseek answers with a token" [expr {$token ne ""}] $token
check "and its caller came back before the model did" [expr {$elapsed < 500}] \
    "took ${elapsed} ms against a 1000 ms stub"
checkEq "its text arrives by callback" [waitFor ::got 8000] "stub says hi"

set ::auto_comment::provider $savedProvider
set ::env(STUB_CURL_BODY) $savedBody

# ------------------------------------ 2. twenty questions, before and after --
puts "\ntwenty questions keep the loop turning"

# 250 ms per answer: long enough that a blocking implementation is visible as a
# gap in the heartbeat, short enough that the suite stays quick. The figure that
# matters is not the total wall time - the two arms cost the same - but the
# longest stretch in which the loop did not run at all: that is the freeze the
# user sees, multiplied by every question the review asks.
set ::env(STUB_CURL_SLEEP) 0.25
set prompts {}
for {set i 1} {$i <= 20} {incr i} {
    lappend prompts [dict create kind move key $i prompt "question $i" max 60]
}
set ::done 0
set ::results {}
set ::progress {}
set ::beatTimes {}
beatsStart 25
set t0 [clock milliseconds]
::reviewprose::run $prompts \
    [list apply {{d t k key text err} {lappend ::progress [list $d $t]}}] \
    [list apply {{r e c} {set ::results $r ; set ::done 1}}]
for {set i 0} {$i < 4000 && !$::done} {incr i} { turn 10 }
set asyncMs [expr {[clock milliseconds] - $t0}]
beatsStop
set asyncBeats $::beats
set asyncGap [maxGap $t0 [clock milliseconds]]
check "the run finished" $::done 1
checkEq "every question was answered" [dict size $::results] 20
check "the loop kept turning during the run" [expr {$asyncBeats >= 40}] \
    "$asyncBeats heartbeats in ${asyncMs} ms"
# One request is 250 ms; a loaded CI runner can miss a beat or two, and a gap of
# a whole request is what the blocking control below produces for every question
# (~5000 ms over the twenty). A bound of 500 ms absorbs the scheduler hiccup and
# still fails a blocking implementation.
check "and never stalled for a whole request" [expr {$asyncGap < 500}] \
    "the loop went ${asyncGap} ms without running, against a 25 ms heartbeat and a 250 ms request"

# The control: the same twenty questions through the blocking entry point. Its
# gap is what makes the number above evidence rather than a coincidence.
set ::auto_beats $asyncBeats
set ::auto_ms $asyncMs
set ::auto_gap $asyncGap
beatsStart 25
set t0 [clock milliseconds]
for {set i 1} {$i <= 20} {incr i} {
    catch { ::auto_comment::queryChat "control $i" 60 }
}
set blockingMs [expr {[clock milliseconds] - $t0}]
beatsStop
set blockingBeats $::beats
set blockingGap [maxGap $t0 [clock milliseconds]]
check "the blocking entry point answers the same twenty questions" \
    [expr {$blockingMs >= 2500}] "took ${blockingMs} ms for 20 x 250 ms"
check "and the loop went the length of a request without running" \
    [expr {$blockingGap >= 200}] \
    "the longest gap was ${blockingGap} ms in ${blockingMs} ms"
check "the two costs are comparable, so the gap is the difference" \
    [expr {abs($blockingMs - $::auto_ms) < 4000}] \
    "queue ${::auto_ms} ms / ${::auto_gap} ms gap, blocking ${blockingMs} ms / ${blockingGap} ms gap"
puts "  ..  20 questions: queue ${::auto_ms} ms with a longest stall of ${::auto_gap} ms; blocking ${blockingMs} ms with a longest stall of ${blockingGap} ms"

# ------------------------------- 3. Cancel mid-flight, before the answer ----
puts "\nCancel pressed mid-flight closes the run without waiting for the reply"

::reviewprose::clearCache
set ::env(STUB_CURL_SLEEP) 1.5
set ::done 0
set ::results {}
set ::errors {}
set ::cancelled 0
set ::progress {}
::reviewprose::run [list [dict create kind move key 90 prompt "cancel me" max 60] \
                          [dict create kind move key 91 prompt "never asked" max 60]] \
    [list apply {{d t k key text err} {lappend ::progress [list $d $t]}}] \
    [list apply {{r e c} {set ::results $r ; set ::errors $e ; set ::cancelled $c ; set ::done 1}}]
# The child is running: give the loop long enough to have started it and be
# certain the answer is 1.5 s away.
turn 300
check "the request is in flight" \
    [expr {[dict get [::reviewprose::status] active] == 1}]
set t0 [clock milliseconds]
::reviewprose::cancel
set cancelMs [expr {[clock milliseconds] - $t0}]
check "Cancel returned at once, not after the model" [expr {$cancelMs < 400}] \
    "took ${cancelMs} ms against a 1500 ms request"
puts "  ..  Cancel returned in ${cancelMs} ms with a 1500 ms request in flight"
check "the run is over" $::done 1
check "and it says it was cancelled" $::cancelled 1
checkEq "nothing was kept, because nothing had arrived" [dict size $::results] 0
checkEq "the second question was never asked" [llength $::progress] 1
check "the queue is idle" [expr {[dict get [::reviewprose::status] active] == 0}]

# The reply the child would have written must never become prose. Wait past the
# stub's own sleep, so a live child would have answered by now.
turn 1800
checkEq "the answer never lands after the cancel" [dict size $::results] 0
check "and the run is still the cancelled one" $::cancelled 1

# ------------------------------- 4. the blocking entry point is not a review --
puts "\nthe review asks the queue, never the blocking entry point"

# At the code level: a review-path file that reaches for ::auto_comment::query
# would block the loop exactly as this file describes, and no test above would
# see it - the queue is what the review calls, so the trap has to be caught by
# reading the sources.
set blocked {}
# Every review-path file, not a hand-picked list: a name missing from a list
# (review_report.tcl was) lets a blocking call through the guard without a word.
# review*.tcl names them all; game_review.tcl is the one review file that does
# not match that pattern.
set reviewFiles [lsort [glob -nocomplain [file join $root tcl tools review*.tcl]]]
lappend reviewFiles [file join $root tcl tools game_review.tcl]
foreach path $reviewFiles {
    if {![file exists $path]} { continue }
    set fh [open $path r]
    fconfigure $fh -encoding utf-8
    set text [read $fh]
    close $fh
    # `query` followed by whitespace is the blocking entry point; queryAsync and
    # queryChat are the two names that must not match.
    if {[regexp {auto_comment::query\s} $text]} { lappend blocked [file tail $path] }
}
checkEq "no review-path file calls the blocking entry point" $blocked ""

# At run time: the queue's request reaches the async transport and not the
# blocking one, with both instrumented.
set ::blockingCalls 0
set ::asyncCalls 0
set savedQuery [info commands ::auto_comment::query]
set savedAsync [info commands ::auto_comment::queryAsync]
rename ::auto_comment::query ::auto_comment::querySaved
rename ::auto_comment::queryAsync ::auto_comment::queryAsyncSaved
proc ::auto_comment::query {args} { incr ::blockingCalls ; return "blocking" }
proc ::auto_comment::queryAsync {prompt {max 300} cb} {
    incr ::asyncCalls
    return [::auto_comment::queryAsyncSaved $prompt $max $cb]
}
::reviewprose::clearCache
set ::done 0
set ::results {}
set ::env(STUB_CURL_SLEEP) 0.05
::reviewprose::run [list [dict create kind move key 70 prompt "one" max 60]] \
    "" [list apply {{r e c} {set ::results $r ; set ::done 1}}]
for {set i 0} {$i < 800 && !$::done} {incr i} { turn 10 }
checkEq "the queue asked the async transport" $::asyncCalls 1
checkEq "and never the blocking one" $::blockingCalls 0
checkEq "with the answer it got" [dict size $::results] 1
rename ::auto_comment::query {}
rename ::auto_comment::queryAsync {}
rename ::auto_comment::querySaved ::auto_comment::query
rename ::auto_comment::queryAsyncSaved ::auto_comment::queryAsync

# ------------------------------------------------------------- the litter --
puts "\nnothing is left behind in the temp directory"

after 300
set left [glob -nocomplain -directory $tmproot auto_comment_*]
checkEq "no request or reply files survive the runs" $left ""

beatsStop
file delete -force $tmproot

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
