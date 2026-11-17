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
# A square designator may be followed by variables ("a1$x"). The C++20 pass
# briefly moved match_variables() inside the "no leading square" branch, which
# made the lexer reject these; keep one query exercising that path.
run "cql() a1\$x"
check "a variable after a square designator parses" \
    [expr {[llength $::dialogs] == 0}]
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
# The four ways a query can fail its caller without failing the window. Each
# one used to leave the database filter - which is what the game list shows -
# in a state the window did not report: a runtime error applied the results it
# had, a cancel and a reset error left the filter reset, and a non-ASCII byte
# ended the lexer early so the rest of the query was silently dropped.
# ---------------------------------------------------------------------------
puts "\n== a failed or cancelled query leaves the filter alone ==\n"

# A runtime error (not a syntax error): the engine only supports transforms on
# square specifiers, so this parses and then fails on the first game examined.
checkEq "two games to stand on" [run "cql(:gamenumber 1 2) K"] 2
set err [catch {run "cql() relation \[K\] echoflip (ancestor)"} msg]
checkEq "the runtime error does not throw" $err 0
check "the status line carries the runtime message" \
    [expr {[string first "An echo transform can only operator" \
        [$w.options.query.status cget -text]] >= 0}] \
    [$w.options.query.status cget -text]
checkEq "the filter is still the two games" [sc_filter count $id dbfilter] 2

# 'extension' has no legal-move generator in this build, so it is refused while
# the query is parsed, not once per game examined.
set err [catch {run "cql() extension"} msg]
checkEq "extension is refused without throwing" $err 0
check "the message says the keyword is unsupported" \
    [expr {[string first "the 'extension' keyword is not supported in this build" \
        [$w.options.query.status cget -text]] >= 0}] \
    [$w.options.query.status cget -text]
check "and it is a parse error, not a per-game error" \
    [expr {[string first "CQL error in game" \
        [$w.options.query.status cget -text]] < 0}] \
    [$w.options.query.status cget -text]
checkEq "the filter is still the two games" [sc_filter count $id dbfilter] 2

# A cancel is the progress callback refusing to continue. sc_search reports at
# most one game in 1024, so the base has to hold enough games for the callback
# to be reached at all (and for the report to be more than 30 ms of work, which
# the UI throttle needs). The filter is narrowed first: a reset operation that
# is cancelled must not have reset it.
puts "\n== a cancelled query leaves the filter alone ==\n"
set manyPgn [file join [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] \
                  "search_cql_many[pid].pgn"]
set fh [open $manyPgn w]
set shuffle {}
for {set n 1} {$n <= 50} {incr n} {
    append shuffle "$n. " [expr {$n % 2 ? "Nf3 Nf6" : "Ng1 Ng8"}] " "
}
for {set g 1} {$g <= 2100} {incr g} {
    puts $fh "\[Event \"G$g\"\]\n\[White \"W$g\"\]\n\[Black \"B$g\"\]\n\[Result \"*\"\]\n\n${shuffle}51. Nf3 *\n"
}
close $fh
set manyId [sc_base create MEMORY search_cql_many]
sc_base switch $manyId
sc_base import $manyId $manyPgn
file delete $manyPgn
checkEq "the many-game base imported" [sc_base numGames $manyId] 2100
# The window stays the one the harness already has; it is pointed at the new
# base the way ::search::cqlRun_ leaves it after a search there.
set savedId $id
set id $manyId
set ::search::dbase_($w) $manyId
set ::search::filter_($w) dbfilter
# Two games in the filter, then a reset query the user cancels.
checkEq "a filter to lose" [run "cql(:gamenumber 1 2) K"] 2
rename ::progressCallBack ::search_cql_progress_
proc ::progressCallBack {args} {
    if {[lindex $args 0] eq "init"} { return 1 }
    return -code break ;# the user pressed Cancel
}
set ::dialogs {}
set err [catch {
    set ::search::filterOp_($w) reset
    $w.options.query.text delete 1.0 end
    $w.options.query.text insert 1.0 "cql() qh4"
    $w.buttons.search invoke
} msg]
checkEq "the cancel does not throw" $err 0
checkEq "no dialog for a cancel" [llength $::dialogs] 0
checkEq "the cancelled query left the filter alone" \
    [sc_filter count $manyId dbfilter] 2
rename ::progressCallBack {}
rename ::search_cql_progress_ ::progressCallBack
set id $savedId
sc_base switch $id

# ---------------------------------------------------------------------------
# A Stop clicked during the final progress report. A search over fewer than
# 1024 candidates delivers one report only - the final progress.report(1, 1) -
# so on a small database that is where the queued click is processed. The
# filter is narrowed first and the reset query below matches a different game,
# so a discarded cancel is visible as a filter that moved.
# ---------------------------------------------------------------------------
puts "\n== a Stop during the final progress report cancels ==\n"
checkEq "two games to stand on" [run "cql(:gamenumber 1 2) K"] 2
rename ::progressCallBack ::search_cql_progress_final_
set ::reports {}
proc ::progressCallBack {args} {
    lappend ::reports $args
    if {[lindex $args 0] eq "init"} { return 1 }
    if {[lindex $args 0] == 1.0} { return -code break } ;# Stop on the last one
    return 1 ;# a mid-loop report is not the path under test
}
set ::dialogs {}
set err [catch {
    set ::search::filterOp_($w) reset
    $w.options.query.text delete 1.0 end
    $w.options.query.text insert 1.0 "cql(:gamenumber 3) K"
    $w.buttons.search invoke
} msg]
checkEq "the cancel does not throw" $err 0
check "the final report reached the callback" \
    [expr {[lsearch -exact $::reports 1.0] >= 0}] $::reports
checkEq "no dialog for a cancel" [llength $::dialogs] 0
checkEq "the cancelled query left the filter alone" \
    [sc_filter count $id dbfilter] 2
rename ::progressCallBack {}
rename ::search_cql_progress_final_ ::progressCallBack

# ---------------------------------------------------------------------------
# An integer in the query text is user input. `:gamenumber 4294967297` used to
# wrap to 1 on the usual build - the parser multiplied without a bound - and
# quietly searched game 1, so the answer was a match the user never asked for
# rather than the parse error the query deserves.
# ---------------------------------------------------------------------------
puts "\n== an out-of-range number is refused, not wrapped ==\n"
checkEq "two games to stand on" [run "cql(:gamenumber 1 2) K"] 2
set ::dialogs {}
set err [catch {run "cql(:gamenumber 4294967297) K"} msg]
checkEq "the wrapped range does not throw" $err 0
checkEq "one dialog" [llength $::dialogs] 1
check "the dialog carries the engine's message" \
    [expr {[string first "The CQL search failed:" [lindex $::dialogs 0]] >= 0}] \
    [lindex $::dialogs 0]
check "the status line is the parse error, not a count" \
    [expr {[string first "CQL error" [$w.options.query.status cget -text]] >= 0}] \
    [$w.options.query.status cget -text]
checkEq "the filter is still the two games" [sc_filter count $id dbfilter] 2
# The negative form goes through the same accumulation before the sign is
# applied; a magnitude no int can hold must be refused there too.
set ::dialogs {}
set err [catch {run "cql(:gamenumber -9999999999) K"} msg]
checkEq "the negative out-of-range does not throw" $err 0
checkEq "one dialog" [llength $::dialogs] 1
checkEq "and it left the filter alone" [sc_filter count $id dbfilter] 2

# ---------------------------------------------------------------------------
# A relation annotates every matching source/target pair of a game into a
# comment. With a source whose target list runs to a few hundred positions the
# text is well over the fixed 2000-byte stack buffer it used to be built in:
# under ASan, the 560-position game below reports a stack-buffer-overflow
# (echomatchinfo.cpp:84, writing past 'buffer' at echomatchinfo.cpp:80) before
# this fix, and the same query is clean after it. The engine is driven directly
# because the window always searches silently, and a silent search never
# annotates.
puts "\n== a relation over hundreds of targets does not overflow ==\n"
set relPgn [file join [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] \
                 "search_cql_relation[pid].pgn"]
set fh [open $relPgn w]
set shuffle {}
for {set n 1} {$n <= 280} {incr n} {
    append shuffle "$n. " [expr {$n % 2 ? "Nf3 Nf6" : "Ng1 Ng8"}] " "
}
puts $fh "\[Event \"Long shuffle\"\]\n\[Result \"*\"\]\n\n${shuffle}281. Nf3 *"
close $fh
set relId [sc_base create MEMORY search_cql_relation]
sc_base switch $relId
sc_base import $relId $relPgn
file delete $relPgn
checkEq "the long game imported" [sc_base numGames $relId] 1
set err [catch {sc_search cql reset 0 1 {cql() relation [K] (ancestor)}} msg]
checkEq "the annotation does not overflow" $err 0
checkEq "the game is the match" [sc_filter count $relId dbfilter] 1
sc_base switch $id

puts "\n== a non-ASCII byte does not end the query ==\n"
# The lexer read the query bytes as signed chars, so the accented byte in the
# comment ended readstring() and everything after it - the actual filter - was
# dropped: the engine saw just "cql()" and rejected the query.
checkEq "the plain query matches one game" [run "cql() qh4"] 1
checkEq "the accented comment is skipped, not the query" \
    [run "cql() ; Z\u00fcrich\nqh4"] 1

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

puts "\n== the search says how many games it could not read ==\n"
# The result is the statistics line plus the count of games whose record could
# not be read: the window words that count in the user's language, so the count
# has to arrive separately rather than baked into an English sentence.
set report [sc_search cql reset 0 1 {cql() qh4}]
checkEq "the report has two elements" [llength $report] 2
checkEq "the statistics line keeps its shape" \
    [regexp {^[0-9]+ / [0-9]+  \([0-9]+[.:][0-9][0-9] s\)$} [lindex $report 0]] 1
checkEq "no game was skipped" [lindex $report 1] 0

destroy $w

puts ""
if {$fails} {
    puts "FAILED $fails of $checks checks"
    exit 1
}
puts "$checks checks, 0 failures"
exit 0
