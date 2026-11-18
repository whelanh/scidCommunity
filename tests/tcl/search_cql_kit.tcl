# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# search_cql_kit.tcl -- every query the CQL building blocks can write, run by
# the real engine.
#
#   xvfb-run -a ./scidCommunity tests/tcl/search_cql_kit.tcl
#
# tests/tcl/search_cql_tk.tcl checks the widgets and the query text. This one
# checks the part only the engine can answer: the query each block writes - for
# every value in every spinbox - must parse and run. A block that writes a
# query the engine rejects is worse than no block, because the user cannot see
# what went wrong.
#
# The fixture is the five-game search_moves.pgn: a query may find nothing in it,
# but it must not raise. The last section runs one generated query through the
# window's Search button and checks the filter it leaves.

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
set pgn [file join [file dirname [info script]] search_moves.pgn]

# A script argument runs on a bare interpreter, so source the application the
# way it sources itself: the kit and the CQL window are not loaded otherwise.
if {[catch {source [file join $root tcl start.tcl]} err]} {
    puts "FAILED to source tcl/start.tcl: $err"
    exit 1
}

set id [sc_base create MEMORY cql_kit_test]
sc_base switch $id
sc_base import $id $pgn
checkEq "the fixture holds five games" [sc_base numGames $id] 5

puts "\n== every block writes a query the engine accepts ==\n"
set total 0
set errors {}
proc tryQuery {query label} {
    incr ::total
    if {$query eq ""} {
        lappend ::errors "$label: empty query"
        return
    }
    if {[string first "%" $query] >= 0} {
        lappend ::errors "$label: unsubstituted placeholder: $query"
        return
    }
    if {[catch {sc_search cql reset 0 0 $query} err]} {
        lappend ::errors "$label: $err\n    $query"
    }
}

foreach {tab groups} $::search::cqlKitList {
    foreach {group items} $groups {
        foreach {name query values} $items {
            ::search::cqlKitInit
            set ::search::cqlKit($name) 1
            set label [::search::cqlKitLabel CQL$name]
            if {$values eq ""} {
                lassign [::search::cqlKitBuild] q said
                tryQuery $q $label
            } else {
                foreach value [::search::cqlKitChoices $name $values] {
                    set ::search::cqlKitValue($name) $value
                    lassign [::search::cqlKitBuild] q said
                    tryQuery $q "$label = $value"
                }
            }
        }
    }
}

# The two wrappers and the move range are the only conditions that do not come
# from a block.
::search::cqlKitInit
set ::search::cqlKit(Checkmate) 1
set ::search::cqlKitBoth 0
lassign [::search::cqlKitBuild] q said
tryQuery $q "Checkmate, White only"
::search::cqlKitInit
set ::search::cqlKitMoves 1
set ::search::cqlKitFrom 10
set ::search::cqlKitTo 20
lassign [::search::cqlKitBuild] q said
tryQuery $q "Moves 10-20"

checkEq "no generated query failed" $errors ""
check "the set is a real catalogue (more than a hundred queries)" \
    [expr {$total > 100}] "only $total"

puts "\n== a generated query searches from the window ==\n"
::search::cql
set w .wnd_SearchCQL
$w.buttons.reset_values invoke
set ::search::cqlKit(Checkmate) 1
::search::cqlKitWrite
set query [$w.options.query.text get 1.0 end-1c]
checkEq "the block filled the box" $query "cql() flipcolor { {btm mate} }"

set ::search::filterOp_($w) reset
$w.buttons.search invoke
check "the status line is not an error" \
    [expr {[string first "error" [$w.options.query.status cget -text]] < 0}] \
    [$w.options.query.status cget -text]
check "the mate in the fixture is found" [expr {[sc_filter count $id dbfilter] > 0}]

puts "\n[expr {$fails ? "FAILED $fails" : "all checks passed"}]"
exit [expr {$fails ? 1 : 0}]
