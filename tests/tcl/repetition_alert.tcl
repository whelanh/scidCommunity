# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# repetition_alert.tcl -- how a repetition is announced, in tclsh.
#
#   tclsh tests/tcl/repetition_alert.tcl
#
# The detector is not under test here; only what CheckRepetition does with the
# count it is given. The three presentations (off, banner, dialog) must not
# change the count, the finish-game and autoplay passes must stay silent, and a
# second occurrence and a third must use their own message.

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

# --------------------------------------------------------------- extraction --
set root [file normalize [file join [file dirname [info script]] .. ..]]
set src [file join $root tcl windows pgn.tcl]

proc extractProc {src name} {
    set fh [open $src r]
    set lines [split [read $fh] "\n"]
    close $fh
    set text ""
    set found 0
    foreach line $lines {
        if {!$found} {
            if {[string match "proc $name *" $line]} { set found 1 } else { continue }
        }
        append text $line "\n"
        if {[info complete $text]} { return $text }
    }
    error "cannot find proc $name in $src"
}

namespace eval ::pgn {}
namespace eval ::finishgame {}

proc ::pgn::getRepetitionCount {} { return $::testCount }
proc ::pgn::showRepetitionNotice {msg} { lappend ::notices $msg }
proc tr {tag args} { return "T:$tag" }
proc tk_messageBox {args} { lappend ::dialogs $args; return ok }

foreach name {::pgn::repetitionMessage ::pgn::CheckRepetition} {
    set text [extractProc $src $name]
    eval $text
    check "$name was extracted" [expr {[llength [info procs $name]] == 1}]
}

proc reset {} {
    set ::notices {}
    set ::dialogs {}
    set ::testCount 1
    set ::pgn::repetitionAlert banner
    set ::finishgame::active 0
    unset -nocomplain ::finishGameMode ::autoplayMode
}

# ------------------------------------------------------------------- messages --
puts "\n== the message follows the occurrence =="
reset
checkEq "a second occurrence" [::pgn::repetitionMessage 2] T:RepetitionTwice
checkEq "a third occurrence" [::pgn::repetitionMessage 3] T:RepetitionThreefold
checkEq "a fourth keeps the threefold text" [::pgn::repetitionMessage 4] T:RepetitionThreefold

# ---------------------------------------------------------------- banner mode --
puts "\n== a banner is not a dialog and the count is returned =="
reset
set ::testCount 2
checkEq "the count is still returned" [::pgn::CheckRepetition] 2
checkEq "one banner" [llength $::notices] 1
checkEq "the banner carries the second-occurrence text" [lindex $::notices 0] T:RepetitionTwice
checkEq "nothing is modal" [llength $::dialogs] 0

reset
set ::testCount 3
set ::pgn::repetitionAlert dialog
checkEq "dialog mode returns the count too" [::pgn::CheckRepetition] 3
checkEq "one dialog" [llength $::dialogs] 1
checkEq "the dialog has the threefold text" \
    [lindex [lindex $::dialogs 0] [expr {[lsearch [lindex $::dialogs 0] -message] + 1}]] \
    T:RepetitionThreefold
checkEq "no banner in dialog mode" [llength $::notices] 0

# ------------------------------------------------------------------- silence --
puts "\n== off silences the presentation, not the count =="
reset
set ::testCount 3
set ::pgn::repetitionAlert off
checkEq "the count is still returned" [::pgn::CheckRepetition] 3
checkEq "no banner" [llength $::notices] 0
checkEq "no dialog" [llength $::dialogs] 0

puts "\n== a first occurrence says nothing =="
reset
set ::testCount 1
::pgn::CheckRepetition
checkEq "no banner" [llength $::notices] 0
checkEq "no dialog" [llength $::dialogs] 0

puts "\n== the game-ending passes stay silent =="
reset
set ::testCount 3
set ::finishGameMode 1
checkEq "Finish Game returns the count" [::pgn::CheckRepetition] 3
checkEq "Finish Game shows no banner" [llength $::notices] 0
checkEq "Finish Game shows no dialog" [llength $::dialogs] 0

reset
set ::testCount 3
set ::autoplayMode 1
checkEq "autoplay returns the count" [::pgn::CheckRepetition] 3
checkEq "autoplay shows no banner" [llength $::notices] 0

reset
set ::testCount 3
set ::finishgame::active 1
checkEq "the new Finish Game returns the count" [::pgn::CheckRepetition] 3
checkEq "the new Finish Game shows no banner" [llength $::notices] 0

# --------------------------------------------------------------- default mode --
puts "\n== an unset preference falls back to the banner =="
reset
set ::testCount 2
unset -nocomplain ::pgn::repetitionAlert
checkEq "the count is still returned" [::pgn::CheckRepetition] 2
checkEq "a banner is shown" [llength $::notices] 1

puts "\n$checks checks, $fails failures"
exit [expr {$fails > 0}]
