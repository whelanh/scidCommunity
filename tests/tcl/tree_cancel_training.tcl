# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# tree_cancel_training.tcl -- training flags after a cancelled Tree refresh.
#
#   tclsh tests/tcl/tree_cancel_training.tcl
#
# ::tree::cancelPendingTraining is called when sc_tree stats is cancelled (the
# Stop button). A human move sets userMovePending in tcl/main.tcl *before*
# trainingReplyBase is known, while trainingReplyBase is only set when an
# automatic training reply is the last move of the line. Cancelling the
# training base must clear the pending human move; cancelling another base
# must leave it alone, so that the training base's own refresh can answer it.

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl windows tree.tcl]

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

# A human move is pending on the training base; there is no reply flag yet.
set ::tree::trainingBase 2
set ::tree::trainingReplyBase 0
set ::tree::userMovePending 1
::tree::cancelPendingTraining 2
checkEq "pending human move cleared on the training base" \
    $::tree::userMovePending 0
checkEq "no reply flag to clear" $::tree::trainingReplyBase 0

# Cancelling a refresh on another base must keep the pending human move.
set ::tree::trainingBase 2
set ::tree::trainingReplyBase 0
set ::tree::userMovePending 1
::tree::cancelPendingTraining 1
checkEq "pending human move kept for another base" \
    $::tree::userMovePending 1

# A reply flag that belongs to a different base is not touched.
set ::tree::trainingBase 2
set ::tree::trainingReplyBase 3
set ::tree::userMovePending 0
::tree::cancelPendingTraining 2
checkEq "reply flag of another base kept" $::tree::trainingReplyBase 3

# With training off nothing is pending for this base.
set ::tree::trainingBase 0
set ::tree::trainingReplyBase 0
set ::tree::userMovePending 1
::tree::cancelPendingTraining 2
checkEq "training off leaves the move pending" $::tree::userMovePending 1

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
