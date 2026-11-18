# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# search_cql_tk.tcl -- the CQL search window under real Tk.
#
#   wish tests/tcl/search_cql_tk.tcl
#   xvfb-run -a wish tests/tcl/search_cql_tk.tcl   (no display)
#
# search_cql.tcl (run by the binary) proves the query reaches the engine and
# fills the filter. This one proves the window hands the search the right
# thing: the query as one string, the chosen filter operation, and no search at
# all when the box is empty. sc_search is stubbed, so a change in the widget
# wiring that would silently search for something else fails here instead of in
# the game list.

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
proc tr {tag args} { return $tag }
namespace eval ::win {}
proc ::win::createDialog {w {y 10}} { toplevel $w }
proc ::setTitle {w title} { wm title $w $title }
proc CreateSelectDBWidget {parent varname refbase} {
    ttk::frame $parent.db
    grid $parent.db -sticky news
    set $varname 1
}
proc autoscrollBars {axis parent canvas} {
    grid $canvas -sticky news
    grid columnconfigure $parent 0 -weight 1
    grid rowconfigure $parent 0 -weight 1
}
proc ::applyThemeColor_background {w} {}
proc progressBarCancel {} {}
proc progressBarSet {args} {}
namespace eval ::notify {}
set ::notified {}
proc ::notify::filter {args} { lappend ::notified $args }
namespace eval ::windows::gamelist {}
proc ::windows::gamelist::formatFilterText {a b} { return "$a of $b" }
set ::opened {}
proc ::windows::gamelist::Open {args} { lappend ::opened $args }
namespace eval ERROR { set UserCancel 2 }

# Record every sc_search and sc_filter call so the button's contract can be read
# back. ::sc_searchError turns the failure path on.
set ::searchCalls {}
set ::filterCalls {}
set ::sc_searchError ""
set ::sc_searchSkipped 0
proc sc_search {args} {
    lappend ::searchCalls $args
    if {$::sc_searchError ne ""} { error $::sc_searchError }
    return [list "1 / 5 (0:00)" $::sc_searchSkipped]
}
proc sc_filter {args} {
    lappend ::filterCalls $args
    switch -- [lindex $args 0] {
        sizes { return {1 5 5} }
        new   { return newfilter }
    }
    return ""
}
proc sc_base {args} {
    switch -- [lindex $args 0] {
        current { return 1 }
        inUse   { return 1 }
    }
    return ""
}

# Record background errors instead of printing them: a binding that mishandles
# its return code (e.g. the old `break` inside an apply body) surfaces here and
# nowhere else.
set ::bgerrors {}
proc bgerror {msg} { lappend ::bgerrors $msg }

# The dialogs the window raises, recorded instead of shown.
set ::dialogs {}
proc tk_messageBox {args} {
    lappend ::dialogs $args
    return ok
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl search board.tcl]
source [file join $root tcl search cql_kit.tcl]
source [file join $root tcl search cql.tcl]

# --------------------------------------------------------------------- tests --
puts "\n== the window builds ==\n"
::search::cql
set w .wnd_SearchCQL
check "the window exists" [winfo exists $w]
check "the query box is there" [winfo exists $w.options.query.text]
check "the hint line is there" [winfo exists $w.options.query.hint]
check "the status line is there" [winfo exists $w.options.query.status]
check "the search button is there" [winfo exists $w.buttons.search]
check "the filter operation buttons are there" \
    [expr {[winfo exists $w.filterOp.and] && [winfo exists $w.filterOp.reset]}]
check "the query box takes several lines" \
    [expr {[$w.options.query.text cget -height] > 1}]
check "the query box remembers what was typed" \
    [expr {[$w.options.query.text cget -undo] eq "1"}]

puts "\n== the building blocks are there ==\n"
set nb $w.options.kit.nb
check "the kit frame is there" [winfo exists $w.options.kit]
check "the notebook is there" [winfo exists $nb]
checkEq "six tabs" [llength [$nb tabs]] 6
checkEq "the first tab is named" [$nb tab 0 -text] "Mates & tactics"
checkEq "the last tab is named" [$nb tab 5 -text] "Game"

# Every block in the list must have a widget. Counting by class catches a block
# that was dropped while the tabs were being laid out, which no single path
# check would.
proc countClass {w class} {
    set n 0
    foreach c [winfo children $w] {
        if {[winfo class $c] eq $class} { incr n }
        incr n [countClass $c $class]
    }
    return $n
}
checkEq "one checkbutton per block" [countClass $nb TCheckbutton] 105
checkEq "one spinbox per block with values" [countClass $nb TSpinbox] 24
checkEq "the Mate by block has its values" \
    [lrange [$nb.p0.g0.c3.v cget -values] 0 4] \
    {Knight Queen Rook Bishop Pawn}

puts "\n== clicking blocks writes a query ==\n"
$w.buttons.reset_values invoke
set ::search::cqlKit(Checkmate) 1
::search::cqlKitWrite
checkEq "one block is a complete query" \
    [$w.options.query.text get 1.0 end-1c] \
    "cql() flipcolor { {btm mate} }"
checkEq "the tab counts its blocks" [$nb tab 0 -text] "Mates & tactics (1)"
checkEq "the explanation names it" $::search::cqlKitSaid \
    "Searching for: Checkmate (Both colours)"

set ::search::cqlKit(PawnFork) 1
::search::cqlKitWrite
check "another block is ANDed in" \
    [expr {[string first "Pawn fork" $::search::cqlKitSaid] > 0}] \
    $::search::cqlKitSaid
checkEq "the AND is spelled out" \
    [regexp {Checkmate AND Pawn fork} $::search::cqlKitSaid] 1

set ::search::cqlKitBoth 0
::search::cqlKitWrite
set q [$w.options.query.text get 1.0 end-1c]
check "White only drops flipcolor" [string match "cql() {*" $q]
check "both blocks are in the query" \
    [expr {[string first "{btm mate}" $q] >= 0
        && [string first "Pawn fork" $::search::cqlKitSaid] >= 0}] $q
check "the explanation says White only" \
    [expr {[string first "White only" $::search::cqlKitSaid] > 0}]

puts "\n== values and a move range join the query ==\n"
::search::cqlKitReset
set ::search::cqlKit(PassedPawn) 1
::search::cqlKitWrite
check "the chosen rank is substituted" \
    [expr {[string first "Pd6 not p\[c7-8,d7-8,e7-8\]" [$w.options.query.text get 1.0 end-1c]] >= 0}] \
    [$w.options.query.text get 1.0 end-1c]
set ::search::cqlKitValue(PassedPawn) 7
::search::cqlKitSpin PassedPawn
checkEq "changing a value ticks its block" $::search::cqlKit(PassedPawn) 1
check "the new rank is substituted too" \
    [expr {[string first "Pd7 not p\[c8-8,d8-8,e8-8\]" [$w.options.query.text get 1.0 end-1c]] >= 0}] \
    [$w.options.query.text get 1.0 end-1c]

set ::search::cqlKitMoves 1
set ::search::cqlKitFrom 10
set ::search::cqlKitTo 20
::search::cqlKitWrite
check "the move range is a condition" \
    [expr {[string first "movenumber 10 20" [$w.options.query.text get 1.0 end-1c]] >= 0}] \
    [$w.options.query.text get 1.0 end-1c]
check "the explanation mentions the range" \
    [expr {[string first "Moves 10-20" $::search::cqlKitSaid] >= 0}] \
    $::search::cqlKitSaid

# The range is driven by a variable trace, not by a key binding: a value that
# changes ticks Moves and rewrites the query on its own, and rewriting a query
# that is already there must leave the box alone (Scid vs. PC's <KeyRelease>
# binding did neither).
::search::cqlKitReset
set ::search::cqlKitFrom 30
checkEq "a move number ticks Moves by itself" $::search::cqlKitMoves 1
check "and the open-ended range is in the query" \
    [expr {[string first "movenumber 30 1000" [$w.options.query.text get 1.0 end-1c]] >= 0}] \
    [$w.options.query.text get 1.0 end-1c]
set ::search::cqlKitTo 40
check "the end of the range follows" \
    [expr {[string first "movenumber 30 40" [$w.options.query.text get 1.0 end-1c]] >= 0}] \
    [$w.options.query.text get 1.0 end-1c]
$w.options.query.text mark set insert 1.0
::search::cqlKitWrite
checkEq "writing the same query again leaves the cursor alone" \
    [$w.options.query.text index insert] 1.0

puts "\n== a typed query is not silently discarded ==\n"
$w.options.query.text delete 1.0 end
$w.options.query.text insert 1.0 "cql() K"
::search::cqlKitSay
checkEq "a typed query is named as the user's own" \
    $::search::cqlKitSaid "Own CQL query"
$w.options.kit.opts.clear invoke
checkEq "Clear all leaves a typed query alone" \
    [$w.options.query.text get 1.0 end-1c] "cql() K"
checkEq "Clear all unticks the blocks" $::search::cqlKit(PassedPawn) 0
checkEq "Clear all forgets the range" $::search::cqlKitMoves 0

# A block does replace a hand-typed query: the engine has one cql() wrapper,
# and the builder cannot merge an arbitrary query into it. It must say so, and
# the replacement must be recoverable.
set ::search::cqlKit(Checkmate) 1
::search::cqlKitWrite
check "a block replaces a typed query" \
    [expr {[$w.options.query.text get 1.0 end-1c] ne "cql() K"}]
check "the explanation says the old query is recoverable" \
    [expr {[string first "Control-Z" $::search::cqlKitSaid] >= 0}] \
    $::search::cqlKitSaid
$w.options.query.text edit undo
checkEq "Control-Z brings the typed query back" \
    [$w.options.query.text get 1.0 end-1c] "cql() K"

$w.buttons.reset_values invoke
checkEq "Defaults clears a typed query too" \
    [$w.options.query.text get 1.0 end-1c] ""
checkEq "Defaults restores white and both colours" $::search::cqlKitBoth 1
checkEq "Defaults restores a block's value" $::search::cqlKitValue(PassedPawn) 6

puts "\n== the controls that do not apply are not shown ==\n"
check "no database chooser" \
    [expr {[winfo manager $w.refdb] eq ""}]
check "no invert button" \
    [expr {[winfo manager $w.buttons.invert] eq ""}]
check "no search on a bare Return (it is a newline in the box)" \
    [expr {[bind $w <Return>] eq ""}]

puts "\n== an empty box searches nothing and says so ==\n"
set ::dialogs {}
set ::searchCalls {}
$w.buttons.search invoke
checkEq "sc_search was not called" [llength $::searchCalls] 0
checkEq "one dialog" [llength $::dialogs] 1
check "the dialog names the empty query" \
    [expr {[string first CQLQueryEmpty [lindex $::dialogs 0]] >= 0}] \
    [lindex $::dialogs 0]
checkEq "the status line says it too" \
    [$w.options.query.status cget -text] CQLQueryEmpty

puts "\n== a box of blanks is empty too ==\n"
$w.options.query.text insert 1.0 "   \n\n  "
set ::dialogs {}
set ::searchCalls {}
$w.buttons.search invoke
checkEq "sc_search was not called" [llength $::searchCalls] 0
checkEq "a dialog was shown" [llength $::dialogs] 1

puts "\n== a query reaches the engine with the filter operation ==\n"
$w.options.query.text delete 1.0 end
$w.options.query.text insert 1.0 "mate"
set ::searchCalls {}
set ::filterCalls {}
$w.buttons.search invoke
checkEq "one search" [llength $::searchCalls] 1
checkEq "sc_search cql <op> <strip> <silent> <query>" \
    [lindex $::searchCalls 0] {cql reset 0 0 mate}
checkEq "the database filter is the window's filter" \
    $::search::filter_($w) dbfilter
check "the game list was told the filter changed" \
    [expr {[llength $::notified] > 0}]
checkEq "and with the database filter" [lindex $::notified end] {1 dbfilter}
checkEq "the result is reported" \
    [$w.options.query.status cget -text] "1 / 5 (0:00)"

puts "\n== games the search could not read are named in the result ==\n"
# A damaged record is skipped rather than failing the search, so the window has
# to say how many games it did not look at; otherwise a large database quietly
# comes back with a smaller count.
set ::sc_searchSkipped 2
$w.buttons.search invoke
checkEq "the skipped games are part of the result" \
    [$w.options.query.status cget -text] \
    "1 / 5 (0:00)  ([format [::tr CQLUnreadableGames] 2])"
set ::sc_searchSkipped 0

puts "\n== a multi-line query is passed whole, and AND is carried over ==\n"
$w.options.query.text delete 1.0 end
$w.options.query.text insert 1.0 "cql(:gamenumber 3 3)\n  qh4"
set ::search::filterOp_($w) and
set ::searchCalls {}
$w.buttons.search invoke
checkEq "the newline is kept, the outer blanks are not" \
    [lindex [lindex $::searchCalls 0] 4] "cql(:gamenumber 3 3)\n  qh4"
checkEq "the filter operation is the radio's" \
    [lindex [lindex $::searchCalls 0] 1] and

puts "\n== Ctrl+Return runs the query, with no background error ==\n"
$w.options.query.text delete 1.0 end
$w.options.query.text insert 1.0 "cql() mate"
set ::search::filterOp_($w) reset
set ::searchCalls {}
set ::bgerrors {}
wm deiconify $w
update
focus -force $w.options.query.text
event generate $w.options.query.text <Control-Return> -when now
update
checkEq "the shortcut runs one search" [llength $::searchCalls] 1
checkEq "with the query as typed" [lindex $::searchCalls 0] \
    {cql reset 0 0 {cql() mate}}
checkEq "no background error (a break in a proc body would land here)" \
    $::bgerrors ""
checkEq "and no newline left in the box" \
    [$w.options.query.text get 1.0 end-1c] "cql() mate"

puts "\n== a failed query is reported, not raised ==\n"
set ::sc_searchError "error (line 1) Unrecognized filter"
set ::dialogs {}
set ::notified {}
set err [catch {$w.buttons.search invoke} msg]
checkEq "the button does not throw" $err 0
checkEq "the status line carries the engine's message" \
    [$w.options.query.status cget -text] "error (line 1) Unrecognized filter"
checkEq "one dialog" [llength $::dialogs] 1
check "the dialog carries the engine's message" \
    [expr {[string first "Unrecognized filter" [lindex $::dialogs 0]] >= 0}] \
    [lindex $::dialogs 0]
# The database filter is what the game list shows: report it even when the
# search failed, so a window can never keep showing a filter the database no
# longer has.
check "the game list is told the filter after a failure" \
    [expr {[llength $::notified] > 0}] $::notified
checkEq "and with the database filter" [lindex $::notified end] {1 dbfilter}
set ::sc_searchError ""

puts "\n== a cancelled query says nothing ==\n"
proc sc_search {args} {
    lappend ::searchCalls $args
    return -code error -errorcode 2 "cancelled"
}
set ::dialogs {}
set ::notified {}
$w.buttons.search invoke
checkEq "no dialog for a cancel" [llength $::dialogs] 0
check "the game list is told the filter after a cancel" \
    [expr {[llength $::notified] > 0}] $::notified
checkEq "and with the database filter" [lindex $::notified end] {1 dbfilter}
proc sc_search {args} {
    lappend ::searchCalls $args
    if {$::sc_searchError ne ""} { error $::sc_searchError }
    return [list "1 / 5 (0:00)" $::sc_searchSkipped]
}

puts "\n== Search (new filter) opens a list of its own ==\n"
set ::filterCalls {}
set ::opened {}
$w.options.query.text delete 1.0 end
$w.options.query.text insert 1.0 "mate"
$w.buttons.search_new invoke
check "a filter was made for the new list" \
    [expr {[lsearch -exact [lindex $::filterCalls 0] new] >= 0}] \
    [lindex $::filterCalls 0]
checkEq "dbfilter was copied into it" \
    [lrange [lindex $::filterCalls 1] 0 3] {copy 1 newfilter dbfilter}
checkEq "the list opens on it" [lindex $::opened 0] {1 newfilter}

puts "\n== Defaults clears the box and the operation ==\n"
set ::search::filterOp_($w) or
$w.buttons.reset_values invoke
checkEq "the box is empty" [::search::cqlQuery] ""
checkEq "the operation is reset" $::search::filterOp_($w) reset

puts "\n== the window's option list ==\n"
$w.options.query.text insert 1.0 "  Qh4  "
checkEq "one cql option holding the trimmed query" \
    [::search::cqlOptions] {{cql Qh4}}

puts "\n== every catalogue carries the window's strings ==\n"
set missing {}
foreach f [lsort [glob -nocomplain -directory [file join $root tcl lang] *.tcl]] {
    set name [file tail $f]
    if {$name in {checklangs.tcl propagatelang.tcl removedeadlang.tcl removetoken.tcl}} {
        continue
    }
    set fh [open $f r]
    fconfigure $fh -encoding utf-8
    set text [read $fh]
    close $fh
    foreach key {SearchCQL CQLQuery CQLQueryHint CQLQueryEmpty CQLSearchFailed} {
        if {[string first $key $text] < 0} { lappend missing "$name:$key" }
    }
}
checkEq "no catalogue is missing a key" $missing ""

destroy $w

puts ""
if {$fails} {
    puts "FAILED $fails of $checks checks"
    exit 1
}
puts "$checks checks, 0 failures"
exit 0
