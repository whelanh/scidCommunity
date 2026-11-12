#!/usr/bin/env tclsh
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# training_menu.tcl -- the Training menu after #437 §3a retired two trainers.
#
#   tclsh tests/tcl/training_menu.tcl
#
# Review game and the Calvar (Stoyko) exercise were retired: their menu entries,
# their modules, their engine slots, their help pages and their translation keys
# are gone. Tactics, the third Training entry, stays and must still be wired.
#
# This harness reads the sources rather than line numbers, because the point of
# the retirement is what is absent: a leftover `::calvar::pressSquare` in
# main.tcl is a call into a namespace that no longer exists - `tclsh` never runs
# it at startup, so nothing else in the tree would fail, and the click would
# throw the first time a user pressed a square. The menu itself is data in
# tcl/menus.tcl, and its -command strings are checked against the procs the
# modules really define.

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

proc readText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation auto
    set text [read $f]
    close $f
    return $text
}

# Every .tcl under a directory, recursively: the retirement is only complete if
# no file anywhere in the tree still calls into the two modules.
proc tclFiles {dir} {
    set out {}
    foreach name [lsort [glob -nocomplain -directory $dir *]] {
        if {[file isdirectory $name]} {
            foreach f [tclFiles $name] { lappend out $f }
        } elseif {[string equal [file extension $name] ".tcl"]} {
            lappend out $name
        }
    }
    return $out
}

# ------------------------------------------------------------- the menu itself --
puts "\nTraining menu (tcl/menus.tcl)"
set menus [readText [file join $root tcl menus.tcl]]
set block ""
if {[regexp {menu \$m\.training\n(.*?)\n\$m add cascade -label ToolsTraining} $menus -> block]} {
    check "the Training submenu is built" 1
} else {
    check "the Training submenu is built" 0 "no 'menu \$m.training ... ToolsTraining' block"
}

check "Training keeps Openings" \
    [expr {[string first "-label ToolsTrainOpenings -command ::opening::config" $block] >= 0}]
check "Training keeps Tactics" \
    [expr {[string first "-label ToolsTrainTactics -command ::tactics::config" $block] >= 0}]
check "Training no longer offers Review game" \
    [expr {[string first "ToolsTrainReviewGame" $block] < 0}]
check "Training no longer offers Calvar" \
    [expr {[string first "ToolsTrainCalvar" $block] < 0}]

# The -command strings above must name procs the modules define. Tactics is
# sourced in an interpreter of its own: sourcing only defines procs and
# namespace variables, so no Tk, database or engine is needed.
set tacticsSrc [file join $root tcl tools tactics.tcl]
set th [interp create]
set terr ""
if {[catch { $th eval [list source -encoding utf-8 $tacticsSrc] } terr]} {
    check "tcl/tools/tactics.tcl sources" 0 $terr
} else {
    check "tcl/tools/tactics.tcl sources" 1
    check "::tactics::config is defined (the menu command resolves)" \
        [expr {[$th eval {info commands ::tactics::config}] ne ""}]
    check "::tactics::createWin is defined (the start of a session)" \
        [expr {[$th eval {info commands ::tactics::createWin}] ne ""}]
}
interp delete $th

# --------------------------------------------------------------- the modules --
puts "\nretired modules"
foreach rel {tcl/tools/reviewgame.tcl tcl/tools/calvar.tcl} {
    check "$rel is deleted" [expr {![file exists [file join $root {*}[split $rel /]]]}]
}

set startSrc [readText [file join $root tcl start.tcl]]
check "start.tcl still sources tools/tactics.tcl" \
    [expr {[string first "tools/tactics.tcl" $startSrc] >= 0}]
check "start.tcl no longer sources tools/reviewgame.tcl" \
    [expr {[string first "tools/reviewgame.tcl" $startSrc] < 0}]
check "start.tcl no longer sources tools/calvar.tcl" \
    [expr {[string first "tools/calvar.tcl" $startSrc] < 0}]
check "start.tcl still namespaces ::tactics" \
    [expr {[string first "::tactics" $startSrc] >= 0}]
check "start.tcl no longer namespaces ::reviewgame" \
    [expr {[string first "::reviewgame" $startSrc] < 0}]
check "start.tcl no longer namespaces ::calvar" \
    [expr {[string first "::calvar" $startSrc] < 0}]

# ------------------------------------------------------------ no residue left --
# A survivor here is a call into a namespace nobody defines any more.
puts "\nno call site survives the retirement"
set RESIDUE {
    ::reviewgame:: ::calvar:: .calvarWin .reviewgame
    ToolsTrainReviewGame ToolsTrainCalvar ConfigureCalvar DoneWithPosition
    GameReviewTimeExtended GameReviewMargin GameReviewAutoContinue
    GameReviewReCalculate GameReviewAnalyzingMovePlayedDuringTheGame
    GameReviewAnalyzingThePosition GameReviewEnterYourMove GameReviewCheckingYourMove
    GameReviewYourMoveWasAnalyzed GameReviewYouPlayedSameMove GameReviewScoreOfYourMove
    GameReviewGameMoveScore GameReviewEngineScore GameReviewYouPlayedLikeTheEngine
    GameReviewNotEngineMoveButGoodMove GameReviewMoveNotGood GameReviewMovesPlayedLike
    GameReviewMovesPlayedEngine
}
foreach token $RESIDUE {
    set hits {}
    foreach f [tclFiles [file join $root tcl]] {
        if {[string first $token [readText $f]] >= 0} {
            lappend hits [file tail $f]
        }
    }
    check "no file mentions $token" [expr {[llength $hits] == 0}] $hits
}

# The static menu page in help/ lists the same entries as menus.tcl.
set menusHtml [readText [file join $root help Menus.html]]
check "help/Menus.html no longer lists Review Game" \
    [expr {[string first "\[Review Game\]" $menusHtml] < 0}]
check "help/Menus.html no longer lists Calvar Training" \
    [expr {[string first "\[Calvar Training\]" $menusHtml] < 0}]
check "help/Menus.html still lists Tactics Training" \
    [expr {[string first "\[Tactics Training\]" $menusHtml] >= 0}]

# ------------------------------------------------------------- the catalogues --
# The two surviving entries must stay translated in every catalogue, and no
# catalogue may keep a key whose text was retired (a key nothing reads is dead
# weight in 29 files).
puts "\nlanguage catalogues"
set catalogs {}
foreach f [lsort [glob [file join $root tcl lang *.tcl]]] {
    switch -- [file tail $f] {
        checklangs.tcl - propagatelang.tcl - removedeadlang.tcl - removetoken.tcl { continue }
    }
    lappend catalogs $f
}
checkEq "there are 29 catalogues" [llength $catalogs] 29
set missing {}
foreach f $catalogs {
    set text [readText $f]
    foreach key {ToolsTrainTactics ToolsTrainOpenings} {
        if {[string first $key $text] < 0} { lappend missing "[file tail $f]:$key" }
    }
}
checkEq "every catalogue carries the surviving Training keys" $missing {}
set dead {}
foreach f $catalogs {
    set text [readText $f]
    foreach key $RESIDUE {
        if {[string first $key $text] >= 0} { lappend dead "[file tail $f]:$key" }
    }
}
checkEq "no catalogue carries a retired key" $dead {}

# ------------------------------------------------------------------- the help --
puts "\nhelp index"
foreach rel {tcl/help/help.tcl tcl/help/helpPL.tcl} {
    set text [readText [file join $root {*}[split $rel /]]]
    check "$rel lists Tactics Training" \
        [expr {[string first "<a TacticsTrainer>" $text] >= 0}]
    check "$rel has no CalVar link" [expr {[string first "<a CalVar>" $text] < 0}]
    check "$rel has no ReviewGame link" [expr {[string first "<a ReviewGame>" $text] < 0}]
    check "$rel has no Review game menu bullet" \
        [expr {[string first "<menu>Review Game</menu>" $text] < 0}]
}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
