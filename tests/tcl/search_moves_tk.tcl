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
set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl misc.tcl]
proc tr {tag args} { return $tag }
namespace eval ::win {}
proc ::win::createDialog {w {y 10}} { toplevel $w }
proc ::setTitle {w title} { wm title $w $title }
namespace eval ::file {}
proc ::file::BaseName {id} { return "Base $id" }
proc sc_base {command} {
    switch -- $command {
        current { return 1 }
        list { return {1 12} }
        default { error "Unexpected sc_base call: $command" }
    }
}
proc autoscrollBars {axis parent canvas} {
    grid $canvas -sticky news
    grid columnconfigure $parent 0 -weight 1
    grid rowconfigure $parent 0 -weight 1
}
proc ::applyThemeColor_background {w} {}
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

puts "\n== search target =="
set box $w.refdb.lb
checkEq "last database option is all open databases" [lindex [$box cget -values] end] SearchAllOpenDatabases
$box current 2
event generate $box <<ComboboxSelected>>
checkEq "selecting all sets the search target" $::search::dbase_($w) all
check "new-filter search is disabled for all databases" [$w.buttons.search_new instate disabled]
check "ordinary search is enabled for all databases" [$w.buttons.search instate !disabled]
$box current 1
event generate $box <<ComboboxSelected>>
checkEq "switching back selects the individual database" $::search::dbase_($w) 12
check "new-filter search is re-enabled for one database" [$w.buttons.search_new instate !disabled]

puts "\n== a pasted line of notation becomes a move list =="
set ::search::movesOptText_ "1. e4 e5 2. Nf3"
set ::calls {}
$w.buttons.search invoke
set call [lindex $::calls end]
checkEq "the filter is composed from the window's" [lrange [lindex $::calls 0] 0 2] {compose 12 dbfilter}
checkEq "and reset before the search" [lrange [lindex $::calls 1] 0 1] {reset 12}
checkEq "the search call" [lrange $call 0 6] {search 12 composed moves {e4 e5 Nf3} wb 0}
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
