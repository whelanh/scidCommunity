# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# search_cql.tcl -- the CQL search window against the real engine.
#
#   xvfb-run -a ./scidCommunity tests/tcl/search_cql.tcl
#
# The query is parsed and run by the CQL engine (src/cql) through sc_search
# cql, so a stub would test nothing: this builds a real MEMORY base, imports a
# PGN, opens the window the Search menu opens, types queries into it and checks
# the filter the game list is left with. The dialogs are recorded rather than
# shown, and the last section reads the Search menu the way the user sees it.

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

# A script argument runs on a bare interpreter - the application only sources
# tcl/start.tcl when it is given no script - and this test needs the window and
# the Search menu, so it starts the application the way the application does.
if {[catch {source [file join $root tcl start.tcl]} err]} {
    puts "FAILED to source tcl/start.tcl: $err"
    exit 1
}
check "the application's menus are up" [winfo exists .menu.search]

set id [sc_base create MEMORY search_cql_test]
sc_base switch $id
sc_base import $id $pgn
checkEq "the base holds the five games" [sc_base numGames $id] 5

# The dialogs, recorded instead of shown: the empty and the failed query both
# end in one, and a modal box would stop the harness.
set ::dialogs {}
proc tk_messageBox {args} {
    lappend ::dialogs $args
    return ok
}

# ------------------------------------------------------------------ the menu --
puts "\n== the entry sits beside the moves entry ==\n"
set m .menu.search
set cmds {}
set labels {}
for {set i 0} {$i <= [$m index end]} {incr i} {
    if {[$m type $i] eq "command"} {
        lappend cmds [$m entrycget $i -command]
        lappend labels [$m entrycget $i -label]
    }
}
set im [lsearch -exact $cmds "::search::moves"]
set ic [lsearch -exact $cmds "::search::cql"]
check "the moves entry is in the Search menu" [expr {$im >= 0}]
check "the CQL entry is in the Search menu" [expr {$ic >= 0}]
checkEq "and it is the next entry" $ic [expr {$im + 1}]
checkEq "its label" [lindex $labels $ic] "CQL..."

# ---------------------------------------------------------------- the window --
puts "\n== the window opens on the current database ==\n"
::search::cql
set w .wnd_SearchCQL
check "the window exists" [winfo exists $w]
check "the query box is there" [winfo exists $w.options.query.text]
check "the status line is there" [winfo exists $w.options.query.status]
checkEq "it searches the database filter" $::search::filter_($w) dbfilter
checkEq "of the current database" $::search::dbase_($w) $id

# Run the query in the box the way the Search button does, and leave the filter
# count in ::count.
proc run {query {op reset}} {
    global w id
    set ::dialogs {}
    set ::search::filterOp_($w) $op
    $w.options.query.text delete 1.0 end
    $w.options.query.text insert 1.0 $query
    $w.buttons.search invoke
    return [sc_filter count $id dbfilter]
}

puts "\n== an empty box says so and leaves the filter alone ==\n"
checkEq "the filter is still all five games" [run ""] 5
checkEq "one dialog" [llength $::dialogs] 1
checkEq "the status line names the empty query" \
    [$w.options.query.status cget -text] "Enter a CQL query before searching."

puts "\n== a query fills the filter ==\n"
checkEq "mate is the fool's mate game" [run "cql() mate"] 1
check "the status line reports the run" \
    [expr {[$w.options.query.status cget -text] ne ""}] \
    [$w.options.query.status cget -text]
checkEq "no dialog for a good query" [llength $::dialogs] 0

checkEq "check is the same game" [run "cql() check"] 1
checkEq "a plain piece designator matches every game" [run "cql() K"] 5
checkEq "a game number range narrows it" [run "cql(:gamenumber 1 1) K"] 1
checkEq "a two-game range" [run "cql(:gamenumber 1 2) K"] 2
checkEq "a multi-line query is one query" \
    [run "cql(:gamenumber 4 4)\n   mate"] 1

puts "\n== the filter operation applies to the filter that was there ==\n"
checkEq "two games to start from" [run "cql(:gamenumber 1 2) K"] 2
checkEq "and the fool's mate do not meet" \
    [run "cql(:gamenumber 4 4) mate" and] 0
checkEq "two games again" [run "cql(:gamenumber 1 2) K"] 2
checkEq "or the fool's mate" [run "cql(:gamenumber 4 4) mate" or] 3
checkEq "reset starts again" [run "cql(:gamenumber 4 4) mate" reset] 1

puts "\n== Ctrl+Return runs the query, with no background error ==\n"
# The shipped bgerror (tcl/file.tcl) prints a trace; record instead, so a
# binding that mishandles its return code fails this check instead of the user.
catch { rename bgerror ::search_cql_bgerror_ }
set ::bgerrors {}
proc bgerror {msg} { lappend ::bgerrors $msg }
$w.options.query.text delete 1.0 end
$w.options.query.text insert 1.0 "cql(:gamenumber 1 2) K"
set ::search::filterOp_($w) reset
wm deiconify $w
update
focus -force $w.options.query.text
event generate $w.options.query.text <Control-Return> -when now
update
checkEq "the shortcut ran the query" [sc_filter count $id dbfilter] 2
checkEq "no background error" $::bgerrors ""
checkEq "and no newline added to the box" \
    [$w.options.query.text get 1.0 end-1c] "cql(:gamenumber 1 2) K"

puts "\n== a query the engine rejects is reported, not raised ==\n"
set before [sc_filter count $id dbfilter]
set err [catch {run "cql(no paren"} msg]
checkEq "the button does not throw" $err 0
check "the status line carries the engine's message" \
    [expr {[string length [$w.options.query.status cget -text]] > 0 \
        && [$w.options.query.status cget -text] ne "Enter a CQL query before searching."}] \
    [$w.options.query.status cget -text]
checkEq "one dialog" [llength $::dialogs] 1
check "the dialog carries the engine's message" \
    [expr {[string first "The CQL search failed:" [lindex $::dialogs 0]] >= 0}] \
    [lindex $::dialogs 0]
checkEq "the filter is what it was" [sc_filter count $id dbfilter] $before

puts "\n== an empty specification is the engine's error too ==\n"
checkEq "cql() alone does not search" [run "cql()"] $before
checkEq "and it is reported" [llength $::dialogs] 1

puts "\n== a good query after a bad one ==\n"
checkEq "a good query after a bad one" [run "cql(:gamenumber 1 2) K"] 2

# ---------------------------------------------------------------------------
# The three query shapes the port has to answer, on a fixture that can tell
# them apart. The moves fixture has no variation and no material change: the
# fixture below is 1.e4 e5 2.Nf3 (2.Qh5 Nc6) 2...Nc6 3.Bb5, so Qh5 exists only
# inside the variation and Bb5 only on the mainline. Every count here was
# measured through this same window before it was written down.
# ---------------------------------------------------------------------------
puts "\n== a second fixture: a variation and a material difference ==\n"
destroy $w
set id [sc_base create MEMORY search_cql_fixture]
sc_base import $id [file join [file dirname [info script]] search_cql.pgn]
sc_base switch $id
::search::cql
set w .wnd_SearchCQL
checkEq "the fixture holds three games" [sc_base numGames $id] 3

puts "\n== a board pattern ==\n"
checkEq "a piece on a square: Bb5" [run "cql() Bb5"] 1
checkEq "a piece that is only in the variation is not in the mainline" \
    [run "cql() Qh5"] 0

puts "\n== a material query ==\n"
checkEq "every game has pawns on the board" [run "cql() countsquares 1 8 \[P\]"] 3
checkEq "no game reaches a pawnless position" \
    [run "cql() countsquares 0 0 \[P\]"] 0

puts "\n== a query that matches inside a variation ==\n"
checkEq ":variations searches the side line" [run "cql(:variations) Qh5"] 1

puts "\n== board, comments, header and material still dispatch ==\n"
# The CQL slice appended one entry to sc_search's option list. If the enum had
# moved, one of the four older searches would stop routing, so check the list
# the dispatcher itself prints and then drive two of them for real.
set err [catch {sc_search bogus} msg]
checkEq "an unknown subcommand is refused" $err 1
foreach opt {board comments header material cql} {
    check "the option list still names $opt" \
        [expr {[string first $opt $msg] >= 0}] $msg
}
checkEq "comments still takes a text and a filter" \
    [catch {sc_search comments zzzz dbfilter}] 0
check "comments still reports its usage" \
    [expr {[catch {sc_search comments} m] == 1 \
        && [string first "Usage: sc_search comments" $m] == 0}] $m
# A fresh base, so the board search starts from a filter nothing else touched.
set idd [sc_base create MEMORY search_cql_dispatch]
sc_base import $idd [file join [file dirname [info script]] search_moves.pgn]
sc_base switch $idd
sc_game load 1
checkEq "board still searches the current position" \
    [catch {sc_search board reset E false false}] 0
checkEq "and fills the filter with the matching games" \
    [sc_filter count $idd dbfilter] 5
check "material still routes" \
    [expr {[catch {sc_search material} m] == 0 && [string first " / " $m] >= 0}] $m

destroy $w

puts ""
if {$fails} {
    puts "FAILED $fails of $checks checks"
    exit 1
}
puts "$checks checks, 0 failures"
exit 0
