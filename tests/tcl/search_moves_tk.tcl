# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# search_moves_tk.tcl -- the Moves search window under real Tk.
#
#   wish tests/tcl/search_moves_tk.tcl
#   xvfb-run -a wish tests/tcl/search_moves_tk.tcl   (no display)
#
# search_moves.tcl (run by the binary) proves the search itself. This one
# proves the window hands the search the right thing: the move list as one Tcl
# list, the side to move and the mate flag, in the order sc_search_moves reads
# them. The database is stubbed and the sc_filter call is recorded, so a change
# in the widget wiring that would silently search for the wrong moves fails
# here instead of in the game list.

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
proc ::notify::filter {args} {}
namespace eval ::windows::gamelist {}
proc ::windows::gamelist::formatFilterText {a b} { return "$a of $b" }
proc ::windows::gamelist::Open {args} {}

# Record every sc_filter call so the Search button's contract can be read back.
set ::calls {}
proc sc_filter {args} {
    lappend ::calls $args
    switch -- [lindex $args 0] {
        sizes   { return {0 0 0} }
        compose { return composed }
        new     { return newfilter }
    }
    return ""
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl search board.tcl]

# --------------------------------------------------------------------- tests --
puts "\n== the window builds =="
::search::moves
set w .wnd_SearchMoves
check "the window exists" [winfo exists $w]
check "the moves entry is there" [winfo exists $w.options.moves.text]
check "the three side buttons are there" \
    [expr {[winfo exists $w.options.side.white] && [winfo exists $w.options.side.black] && [winfo exists $w.options.side.both]}]
check "the mate checkbutton is there" [winfo exists $w.options.mate]
check "the search button is there" [winfo exists $w.buttons.search]

puts "\n== the defaults =="
checkEq "either side by default" $::search::movesOptSide_ wb
checkEq "mate not required by default" $::search::movesOptMate_ 0
checkEq "the entry starts empty" $::search::movesOptText_ ""

puts "\n== a pasted line of notation becomes a move list =="
set ::search::movesOptText_ "1. e4 e5 2. Nf3"
set ::calls {}
$w.buttons.search invoke
set call [lindex $::calls end]
checkEq "the filter is composed from the window's" [lrange [lindex $::calls 0] 0 2] {compose 1 dbfilter}
checkEq "and reset before the search" [lrange [lindex $::calls 1] 0 1] {reset 1}
checkEq "the search call" [lrange $call 0 6] {search 1 composed moves {e4 e5 Nf3} wb 0}
checkEq "the filter operation is carried" [lrange $call 7 end] {-filter AND}

puts "\n== the side to move and the mate flag reach the search =="
set ::search::movesOptSide_ b
set ::search::movesOptMate_ 1
set ::calls {}
$w.buttons.search invoke
set call [lindex $::calls end]
checkEq "black to move, mate required" [lrange $call 3 6] {moves {e4 e5 Nf3} b 1}

puts "\n== the wildcard and the check mark are passed through untouched =="
set ::search::movesOptText_ "d4 ? c4 Qh4+"
set ::calls {}
$w.buttons.search invoke
checkEq "the query is not rewritten" [lindex [lindex $::calls end] 4] {d4 ? c4 Qh4+}

puts "\n== Defaults restores the window =="
set ::search::movesOptText_ "e4"
set ::search::movesOptSide_ w
set ::search::movesOptMate_ 1
$w.buttons.reset_values invoke
checkEq "the entry is cleared" $::search::movesOptText_ ""
checkEq "either side again" $::search::movesOptSide_ wb
checkEq "mate unticked again" $::search::movesOptMate_ 0

destroy $w

puts ""
if {$fails} {
    puts "FAILED $fails of $checks checks"
    exit 1
}
puts "$checks checks, 0 failures"
exit 0
