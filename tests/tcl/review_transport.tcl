# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_transport.tcl -- the review path's request must not block the event loop.
#
#   tclsh tests/tcl/review_transport.tcl
#
# ::auto_comment::query runs curl with exec, so every request stops Tk dead until
# the model answers. The coach asks for up to fourteen answers per game, which on
# a slow endpoint is minutes of a frozen board. ::auto_comment::queryAsync is the
# same request with the reply read by fileevent instead.
#
# The proof is a real child process: a `curl` script on PATH that sleeps before
# it answers. A blocking implementation cannot pass this file - its caller does
# not return until the sleep is over, and the control check below measures
# exactly that through the blocking entry point, so the timer is known good.

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
# of its own. The dialogs are not under test here; the transport is.
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

# A temp tree of our own: the stub curl, its reply files, and the request files
# the transport writes. Nothing here touches the user's options or /tmp.
set sysTmp [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) \
              : [info exists ::env(TEMP)] ? $::env(TEMP) : "/tmp"}]
set tmproot [file join $sysTmp "auto_comment_transport_[pid]"]
catch { file delete -force $tmproot }
file mkdir [file join $tmproot bin]
set ::env(TMPDIR) $tmproot

# The stub: curl that takes its time. It answers --version immediately, because
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

# The one provider whose request shape is shared with the async path.
set ::auto_comment::provider openai
set ::auto_comment::openaiUrl "https://api.example.com"
set ::auto_comment::openaiKey "***"
set ::auto_comment::openaiModel "m"
# post303Flag's probe is a blocking exec of curl. It is answered once, here, so
# the measurement below is the request and nothing else.
set ::auto_comment::post303 ""

# Wait for a global to be given a value, with a deadline: a callback that never
# fires must fail the check rather than hang the harness. A value that is already
# there - two requests in flight, answered while the first was being waited for -
# is the answer, not a reason to wait for another.
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

# ------------------------------------------------------------ the async call --
puts "\nthe caller returns before the model answers"

unset -nocomplain ::got
set t0 [clock milliseconds]
set token [::auto_comment::queryAsync "one prompt" 50 {apply {{text} {set ::got $text}}}]
set elapsed [expr {[clock milliseconds] - $t0}]
check "queryAsync answers with a token" [expr {$token ne ""}] $token
check "the caller came back while curl was still running" [expr {$elapsed < 500}] \
    "took ${elapsed} ms against a 1000 ms stub"
checkEq "and the model's text arrives by callback" [waitFor ::got 8000] "stub says hi"
check "the token is gone once the reply landed" \
    [expr {![info exists ::auto_comment::async($token)]}]

puts "\nthe blocking entry point is the thing this replaces"

# The control: the same request, the same stub, through queryChat. If this is
# fast, the stub is not sleeping and the measurement above proves nothing.
set t0 [clock milliseconds]
set reply [::auto_comment::queryChat "one prompt" 50]
set blocking [expr {[clock milliseconds] - $t0}]
checkEq "the blocking path still returns the text" $reply "stub says hi"
check "and it holds the caller for the stub's whole sleep" [expr {$blocking >= 900}] \
    "took ${blocking} ms; the stub slept 1000 ms"

puts "\ntwo requests in flight do not cross"

unset -nocomplain ::one ::two
set tokA [::auto_comment::queryAsync "a" 50 {apply {{text} {set ::one $text}}}]
set tokB [::auto_comment::queryAsync "b" 50 {apply {{text} {set ::two $text}}}]
check "each request gets its own token" [expr {$tokA ne $tokB && $tokA ne "" && $tokB ne ""}]
checkEq "the first callback fires" [waitFor ::one 8000] "stub says hi"
checkEq "and so does the second" [waitFor ::two 8000] "stub says hi"

puts "\na refused provider never starts a process"

set savedProvider $::auto_comment::provider
set ::auto_comment::provider none
unset -nocomplain ::got
set token [::auto_comment::queryAsync "hello" 50 {apply {{text} {set ::got $text}}}]
checkEq "the refusal is reported as an error, not raised" [waitFor ::got 2000] \
    "ERROR: no model selected"
checkEq "and there is no child to cancel" $token ""
set ::auto_comment::provider $savedProvider

puts "\na failed request is an ERROR string, never an exception"

set ::env(STUB_CURL_STATUS) 500
set ::env(STUB_CURL_BODY) {{"error":{"message":"bad key"}}}
unset -nocomplain ::got
set token [::auto_comment::queryAsync "hello" 50 {apply {{text} {set ::got $text}}}]
set text [waitFor ::got 8000]
check "the failure arrives as ERROR:" [expr {[string match "ERROR:*" $text]}] $text
check "and it names the provider's own reason" \
    [expr {[string first "bad key" $text] >= 0}] $text
set ::env(STUB_CURL_STATUS) 200
set ::env(STUB_CURL_BODY) {{"choices":[{"message":{"content":"stub says hi"}}]}}

puts "\ncancel stops the child and drops the reply"

unset -nocomplain ::got
set token [::auto_comment::queryAsync "slow" 50 {apply {{text} {set ::got $text}}}]
check "the request is in flight" [expr {[info exists ::auto_comment::async($token)]}]
::auto_comment::cancelAsync $token
check "cancel forgets it" [expr {![info exists ::auto_comment::async($token)]}]
# The child was killed: its callback must never run. Give it longer than the stub
# would have taken, so a live child would have answered by now.
after 1600 {set ::got "__waited__"}
vwait ::got
checkEq "and no callback runs afterwards" $::got "__waited__"

puts "\nnothing is left behind in the temp directory"

# The request file, the reply file and the auth file are the transport's own
# litter: a review of forty moves writes four of them per request.
after 200
set left [glob -nocomplain -directory $tmproot auto_comment_*]
checkEq "no request or reply files survive the run" $left ""

file delete -force $tmproot

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
