# Run with ./scidCommunity tests/tcl/search_all_databases.tcl
# Exercise the dialogs and their real filters, including the Clipbase.
set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl start.tcl]
# Startup opens these on the first event loop iteration. Use only the test bases.
set ::autoLoadBases {}

proc check {label got expected} {
    if {$got ne $expected} { error "$label: expected '$expected', got '$got'" }
    puts "  ok   $label"
}

proc selectAll {w} {
    set box $w.refdb.lb
    $box current [lsearch -exact [$box cget -values] [tr SearchAllOpenDatabases]]
    event generate $box <<ComboboxSelected>>
    check "all databases selected in $w" $::search::dbase_($w) all
}

proc counts {} {
    return [lmap db $::databases {sc_filter count $db dbfilter}]
}

# Catch a modal error dialog without blocking the test.
proc tk_messageBox {args} { lappend ::dialogs $args; return ok }
set dialogs {}

sc_base create MEMORY search_all_first
sc_base create MEMORY search_all_second
set databases [sc_base list]
check "two databases and the Clipbase" [llength $databases] 3
check "Clipbase is among the targets" [expr {[sc_info clipbase] in $databases}] 1
foreach db $databases {
    sc_base import $db [file join $root tests tcl search_moves.pgn]
}
lassign $databases first second third
sc_base switch $third

::search::moves
set w .wnd_SearchMoves
selectAll $w
set ::search::movesOptText_ e4
$w.buttons.search invoke
check "Moves finds both e4 games in each database" [counts] {2 2 2}

# Each database starts AND and OR with its own previous results.
sc_filter reset $first dbfilter empty
sc_filter reset $third dbfilter full
set ::search::filterOp_($w) and
set ::search::movesOptText_ Nf3
$w.buttons.search invoke
check "AND uses each database's filter" [counts] {0 2 3}
set ::search::filterOp_($w) or
set ::search::movesOptText_ d4
$w.buttons.search invoke
check "OR uses each database's filter" [counts] {1 3 4}

# Deliver Stop through the Tk event loop during database two's backend call.
proc stopOnSecond {command op} {
    if {[lindex $command 1] ne "search"} { return }
    set db [lindex $command 2]
    lappend ::searched $db
    if {$db eq $::second} {
        set ::interruptedFilter [lindex $command 3]
        set ::progressText [$::w.filterOp cget -text]
        after 0 [list $::w.buttons.stop invoke]
    }
}
set searched {}
set ::search::filterOp_($w) reset
set ::search::movesOptText_ e4
trace add execution sc_filter enter stopOnSecond
try {
    $w.buttons.search invoke
} finally {
    trace remove execution sc_filter enter stopOnSecond
}
check "Stop ends the loop in the second database" $searched [list $first $second]
check "only the completed database was updated" [counts] {2 3 4}
check "the interrupted temporary filter was released" \
    [catch {sc_filter sizes $second $interruptedFilter}] 1
check "progress identifies the interrupted database" $progressText "2/3 — [::file::BaseName $second]"

# Stop should return the dialog to its search controls.
update idletasks
check "Search is visible after Stop" [winfo ismapped $w.buttons.search] 1
check "Search is enabled after Stop" [$w.buttons.search instate !disabled] 1
check "Stop is hidden after cancellation" [winfo ismapped $w.buttons.stop] 0

# Retry the same e4 query in this dialog and compare with the uninterrupted run.
$w.buttons.search invoke
check "retry after Stop finds both e4 games in every database" [counts] {2 2 2}
destroy $w

# Start Board Search with full filters so it must find the two matches itself.
.menu.search invoke [tr SearchResetAll]
::search::board
set w .wnd_BoardSearch
selectAll $w
sc_game load 1
sc_move start
sc_move forward 1
set position [sc_pos fen]
$w.buttons.search invoke
check "all targets use the active e4 position" [counts] {2 2 2}
check "the same database remains active" [sc_base current] $third
check "the active board is preserved" [sc_pos fen] $position
destroy $w

::search::header
set w .wnd_HeaderSearch
selectAll $w
set ::sWhite Beta
set ::sIgnoreCol Yes
$w.buttons.search invoke
check "Header includes the swapped-color match" [counts] {1 1 1}
$w.buttons.invert invoke
check "Invert excludes the match in either color" [counts] {4 4 4}
destroy $w

.menu.search invoke [tr SearchResetAll]
check "the Search menu resets all filters" [counts] {5 5 5}

# Single-database Search (New Filter) opens a separate Game List.
foreach db $databases {
    ::windows::gamelist::Open $db dbfilter
    set originalList($db) [lindex $::windows::gamelist::wins end]
}
::search::moves $first
set w .wnd_SearchMoves
set ::search::filterOp_($w) reset
set ::search::movesOptText_ e4
$w.buttons.search invoke
update
set firstTree $originalList($first).games.glist
check "ordinary search shows two games in A's original list" [llength [$firstTree children {}]] 2

set listsBefore $::windows::gamelist::wins
set ::search::filterOp_($w) and
set ::search::movesOptText_ {e4 e5}
$w.buttons.search_new invoke
update
set newLists {}
foreach listWin $::windows::gamelist::wins {
    if {$listWin ni $listsBefore} { lappend newLists $listWin }
}
check "New Filter opens exactly one Game List" [llength $newLists] 1
set newList [lindex $newLists 0]
check "the new list belongs to A" [::windows::gamelist::GetBase $newList] $first
set resultTree $newList.games.glist
check "the new list shows only Ruy Lopez" \
    [lmap row [$resultTree children {}] { $resultTree set $row GlistEvent }] {{Ruy Lopez}}
check "the original lists still show 2, 5, and 5 games" [lmap db $databases {
    llength [$originalList($db).games.glist children {}]
}] {2 5 5}
destroy $w

::search::material
check "Material lists only individual databases" \
    [llength [.sm.refdb.lb cget -values]] [llength $databases]
destroy .sm
check "no search errors" $dialogs {}
exit 0
