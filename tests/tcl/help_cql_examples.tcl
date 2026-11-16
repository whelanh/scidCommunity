# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# help_cql_examples.tcl -- every CQL sample on the help page, run by the engine.
#
#   xvfb-run -a ./scidCommunity tests/tcl/help_cql_examples.tcl
#
# The CQL help page (set helpText(CQL) in tcl/help/help.tcl) prints queries for
# the user to copy into the CQL window. A page whose samples do not run is worse
# than no page: the user copies one and the engine rejects it. So the samples
# are executable here.
#
# The convention that makes them extractable: every runnable query on the page
# is written as <term>cql(...) ...</term> and nothing else is. A sample is
# therefore a <term> whose text starts with "cql", and two checks below hold the
# page to that - the first sample that does not start with "cql" fails, and a
# query written outside <term> (in <b>, say) fails the "no query escapes" check.
#
# Each sample is run the way the CQL window runs it - sc_search cql
# <filterOp> 0 0 <query> (tcl/search/cql.tcl) - with the filter operation forced
# to "reset" so that one sample cannot be measured through another's filter.
# A sample must both parse and match at least one game of the fixture: a query
# that runs but finds nothing teaches the user a pattern that is not there.

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
set pgn [file join [file dirname [info script]] help_cql_examples.pgn]
set helpFile [file join $root tcl help help.tcl]

# ---------------------------------------------------------- the page is there --
puts "\n== the page is registered where the help window looks for it ==\n"

# tcl/start.tcl sources help/help.tcl, so sourcing the one file is what the
# application does for the page's title and text.
source $helpFile
check "the page defines helpTitle(CQL)" [info exists ::helpTitle(CQL)]
check "the page defines helpText(CQL)" [info exists ::helpText(CQL)]
if {[info exists ::helpTitle(CQL)]} {
    checkEq "the page's title" $::helpTitle(CQL) "Chess Query Language (CQL)"
}

set fh [open $helpFile r]
set helpSource [read $fh]
close $fh

# An <a CQL> that no page answers draws nothing (updateHelpWindow falls through
# its else), so each entry point is checked by name: Contents, the Index, and
# the Searches page the Search window's help opens.
set contentsLink [string match "*<li><a CQL><b>Chess Query Language (CQL)</b></a></li>*" $helpSource]
set indexLink [string match "*<h3>C</h3>*<a CQL>Chess Query Language (CQL)</a>*" $helpSource]
set searchesHasLink [expr {[info exists ::helpText(Searches)]
    && [string first "<a CQL>" $::helpText(Searches)] >= 0}]
check "the Contents links to the page" $contentsLink
check "the Index links to the page" $indexLink
check "the Searches page links to the page" $searchesHasLink

# ------------------------------------------------------- extract the samples --
puts "\n== every sample is a <term> that begins with cql ==\n"

set samples {}
set notQueries {}
foreach {- text} [regexp -all -inline {<term>(.*?)</term>} $::helpText(CQL)] {
    set text [string trim $text]
    if {[string match "cql(*" $text]} {
        lappend samples $text
    } else {
        lappend notQueries $text
    }
}
check "the page has samples" [expr {[llength $samples] >= 6}] \
    "found [llength $samples]"
check "every <term> is a runnable query" [expr {[llength $notQueries] == 0}] \
    "not a query: $notQueries"

# A query written outside <term> would be invisible to this harness and so
# never run; the page keeps its queries in <term> only. The word cql on its own
# ("begin with the word <b>cql</b>") is prose, not a query.
set escaped [regexp -all {<b>cql\(} $::helpText(CQL)]
check "no query is written outside <term>" [expr {$escaped == 0}] \
    "found $escaped in <b>"

# -------------------------------------------------------------- run them all --
puts "\n== the engine runs every sample ==\n"

set id [sc_base create MEMORY help_cql_examples]
sc_base switch $id
sc_base import $id $pgn
set total [sc_base numGames $id]
checkEq "the fixture holds the nine games" $total 9

foreach query $samples {
    set err [catch {sc_search cql reset 0 0 $query} message]
    if {$err} {
        check "  $query" 0 "the engine rejected it: $message"
        continue
    }
    set matched [sc_filter count $id dbfilter]
    check "  $query" [expr {$matched > 0}] "matched no game"
    puts "         $query -> $matched games"
}

# The samples above only mean something if the engine is really parsing them:
# this is the query a user gets wrong first, and it must be rejected.
puts "\n== a query without the cql prefix is still rejected ==\n"
set err [catch {sc_search cql reset 0 0 {qh4}} message]
check "qh4 is rejected" [expr {$err != 0}]
check "and the message names the missing word" \
    [expr {$err != 0 && [string match "*Expected 'cql' word*" $message]}] $message

puts "\n[expr {$::checks - $::fails}] checks, $::fails failures"
exit [expr {$::fails == 0 ? 0 : 1}]
