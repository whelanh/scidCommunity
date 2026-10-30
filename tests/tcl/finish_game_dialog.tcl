# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# finish_game_dialog.tcl -- build the engine-window Finish Game dialog under Tk.
#
#   wish tests/tcl/finish_game_dialog.tcl
#   xvfb-run -a wish tests/tcl/finish_game_dialog.tcl   (no display)
#
# The dialog is the point of this pass: two engines, a seconds/depth pair each,
# and no annotation options. The tclsh harness covers the loop; this one builds
# the window and presses OK.

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
proc ::options.store {args} {}
proc ::button_image {args} { return "" }
proc tr {tag args} { return $tag }
namespace eval ::utils::tooltip {}
proc ::utils::tooltip::Set {args} {}
namespace eval ::win {}
proc ::win::createDialog {w} { toplevel $w }
proc ::setTitle {w t} { wm title $w $t }
proc packbuttons {where args} { foreach b $args { pack $b -side $where -padx 2 } }
namespace eval ::enginewin {}
set ::enginewin_lastengine(1) "Stockfish Deep"
proc ::enginewin::reviewWindow {id} { return .engineWin$id }
proc tk_messageBox {args} { lappend ::boxes $args ; return ok }
namespace eval ::enginecfg {}
proc ::enginecfg::names {} { return [list "Stockfish Deep" "Stockfish Quick"] }

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools finish_game.tcl]

wm withdraw .
toplevel .engineWin1

puts "\nthe finish game dialog"
set w [::finishgame::dialog 1]
update
checkEq "the dialog exists" [winfo exists $w] 1
checkEq "White defaults to the window's engine" \
    $::finishgame::whiteEngine "Stockfish Deep"
checkEq "Black does too" $::finishgame::blackEngine "Stockfish Deep"
foreach side {white black} {
    check "the $side engine box" [winfo exists $w.$side.eng]
    check "the $side seconds box" [winfo exists $w.$side.sec]
    check "the $side depth box" [winfo exists $w.$side.dep]
    checkEq "the $side engine choices" [$w.$side.eng cget -values] \
        [list "Stockfish Deep" "Stockfish Quick"]
}
check "OK is there" [winfo exists $w.buttons.ok]
check "Cancel is there" [winfo exists $w.buttons.cancel]
proc hasCheckbutton {w} {
    foreach child [winfo children $w] {
        if {[winfo class $child] eq "TCheckbutton"} { return 1 }
        if {[hasCheckbutton $child]} { return 1 }
    }
    return 0
}
checkEq "no annotation checkbox anywhere in it" [hasCheckbutton $w] 0

# OK hands the chosen values to the pass.
puts "\npressing OK"
rename ::finishgame::start ::finishgame::startSaved
proc ::finishgame::start {ownerId white black} {
    lappend ::started [list $ownerId $white $black]
}
set ::finishgame::whiteEngine "Stockfish Quick"
set ::finishgame::blackEngine "Stockfish Deep"
set ::finishgame::whiteSeconds 4
set ::finishgame::whiteDepth 12
$w.buttons.ok invoke
update
checkEq "the pass is handed the dialog's engines" $::started \
    [list [list 1 "Stockfish Quick" "Stockfish Deep"]]
checkEq "and the dialog is gone" [winfo exists $w] 0
rename ::finishgame::start {}
rename ::finishgame::startSaved ::finishgame::start

# A zero seconds value is refused and the dialog stays.
puts "\na bad value keeps the dialog open"
set w2 [::finishgame::dialog 1]
set ::finishgame::whiteSeconds 0
$w2.buttons.ok invoke
update
checkEq "the dialog is still there" [winfo exists $w2] 1
check "the reason is shown" [expr {[llength $::boxes] == 1}]
destroy $w2

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
