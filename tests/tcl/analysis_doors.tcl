#!/usr/bin/env tclsh
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# analysis_doors.tcl -- no UI path opens an Analysis window, and the module is gone.
#
#   tclsh tests/tcl/analysis_doors.tcl
#
# Item 3 of #436 removed the doors: the Tools menu entry, the engine chooser's
# Open path, the saved-layout restore clause, and the spacebar branches. #437 §5
# then deleted the room behind them - tcl/tools/analysis.tcl and the legacy
# Annotate dialog it held - so this harness now also proves the file is gone and
# that nothing in the tree names its procs.

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

proc procText {path name} {
    set src [readText $path]
    set from [string first "proc $name " $src]
    if {$from < 0} { return "" }
    set text ""
    foreach line [split [string range $src $from end] "\n"] {
        append text $line "\n"
        if {[info complete $text]} { break }
    }
    return $text
}

# Every .tcl under tcl/, so the "no caller" check cannot miss a new file.
proc tclFiles {dir} {
    set out {}
    foreach f [glob -nocomplain -directory $dir *] {
        if {[file isdirectory $f]} {
            lappend out {*}[tclFiles $f]
        } elseif {[string match *.tcl $f]} {
            lappend out $f
        }
    }
    return $out
}

puts "\nthe UI doors are gone"

set menu [readText [file join $root tcl menus.tcl]]
check "the Tools menu has no Analysis Engine entry" \
    [expr {[string first "-label ToolsAnalysis" $menu] < 0}]

set enginelist [readText [file join $root tcl tools enginelist.tcl]]
check "the engine chooser does not create an Analysis window" \
    [expr {[string first "makeAnalysisWin" $enginelist] < 0}]
check "it opens an Engine Window instead" \
    [expr {[string first "::enginewin::start" $enginelist] >= 0}]
check "and its button is the new label" \
    [expr {[string first "EngineOpenWindow" $enginelist] >= 0}]

set win [readText [file join $root tcl utils win.tcl]]
check "a saved layout does not restore an Analysis window" \
    [expr {[string first "makeAnalysisWin" $win] < 0}]
check "the restore path filters Analysis windows out" \
    [expr {[string first "layoutRestorableWindows" $win] >= 0}]
check "and prunes emptied containers and their sash entries" \
    [expr {[string first "layoutPrune" $win] >= 0}]

set main [readText [file join $root tcl main.tcl]]
check "the spacebar has no Analysis window branch" \
    [expr {[string first "analysisWin" $main] < 0}]
check "the toolbar names an Engine Window" \
    [expr {[string first "ToolsEngineWindow" $main] >= 0}]

# No UI file calls makeAnalysisWin, and the module that defined it is gone
# (#437 §5): a new file that reaches for either fails here.
set callers {}
foreach file [tclFiles [file join $root tcl]] {
    if {[string first "makeAnalysisWin" [readText $file]] >= 0} {
        lappend callers [string range $file [string length $root] end]
    }
}
checkEq "no UI file calls makeAnalysisWin" $callers {}
checkEq "tcl/tools/analysis.tcl is gone" \
    [file exists [file join $root tcl tools analysis.tcl]] 0

# The procs the deletion took: everything analysis.tcl defined, plus the ones
# that shared its ::analysis(...) array (the old pipe mode in uci.tcl, the
# WinBoard detector). A call to one of them is a runtime error where the user
# is - on every move, or on Exit - and #437 round 1 found three that a
# reference count had missed: updateAnalysis from ::notify::privPosChanged,
# toAbsPath from ::sergame::openEngine, and the five globals uci.tcl's dead
# block still reached for. So this scans for CALLS over every .tcl in tcl/:
#
#  - a comment-only line is not a call, and the name must not be part of a
#    longer name (so ::sergame::updateAnalysisText is not a hit for
#    updateAnalysis, and $w.b.autoplay is not one for autoplay);
#  - a file that defines the bare name itself (inputengine's logEngine) makes
#    its own unqualified calls resolve locally, so those are skipped;
#  - a ::name call is always a hit, because it can only reach the global.
set retired {
    resetEngine calculateNodes resetAnalysis autoplay startAutoplay cancelAutoplay
    configAnnotation configAnnotateOK bookAnnotation markExercise addAnnotation
    scoreToNag appendAnnotator pushAnalysisData popAnalysisData addAnalysisVariation
    addAllVariations analysisSpaceKey makeAnalysisMove destroyAnalysisWin sendToEngine
    sendMoveToEngine logEngine logEngineNote makeAnalysisWin onUciOk toggleMovesDisplay
    changePVSize setAnalysisPriority checkAnalysisStarted initialAnalysisStart
    processAnalysisInput checkEngineIsAlive formatAnalysisMoves toggleFinishGame
    autoplayFinishGame autoplayFinishGameCheck startEngineAnalysis stopEngineAnalysis
    toggleEngineAnalysis startAnalyzeMode stopAnalyzeMode toggleLockEngine
    updateAnalysisText scoreToMate addMoveNumbers toggleAnalysisBoard toggleEngineInfo
    updateAnalysisBoard updateAnalysis setAutomoveTime toggleAutomove cancelAutomove
    automove automove_go sc_move_add toAbsPath
}

proc callsRetired {root retired} {
    set hits {}
    set pre {(?:^|[^A-Za-z0-9_:.$/-])[ \t]*}
    set post {(?:[^A-Za-z0-9_:]|$)}
    # One cheap test per line, then the per-name work only on the lines that
    # can hold a hit: the tree is 12,000 lines and this harness runs often.
    set alts {}
    foreach name $retired {
        lappend alts "(?:::)?[string map {\( \\\( \) \\\)} $name]"
    }
    set any [format {%s(?:%s)%s} $pre [join $alts |] $post]
    foreach file [tclFiles [file join $root tcl]] {
        # tcl/lang/ is catalogue text - prose that may name a retired feature
        # ("the time delay for autoplay mode") and never a call.
        if {[string match */lang/* $file]} { continue }
        set text [readText $file]
        set short [string range $file [string length $root] end]
        set found {}
        set n 0
        foreach line [split $text "\n"] {
            incr n
            if {[string index [string trimleft $line] 0] eq "#"} { continue }
            if {![regexp -- $any $line]} { continue }
            foreach name $retired {
                if {[regexp -- [format {%s(?:::)?%s%s} $pre $name $post] $line]} {
                    lappend found [list $n $name $line]
                }
            }
        }
        foreach hit $found {
            lassign $hit n name line
            # A file that defines the bare name makes its own unqualified calls
            # resolve inside its namespace (inputengine's logEngine); only a
            # ::name call in such a file can reach the deleted global.
            if {[regexp -line "^\[ \t\]*proc\[ \t\]+$name\[ \t\{]" $text] &&
                ![regexp -- [format {%s::%s%s} $pre $name $post] $line]} {
                continue
            }
            lappend hits "$short:$n $name"
        }
    }
    return $hits
}

set dangling [callsRetired $root $retired]
checkEq "nothing in tcl/ calls a proc the deletion took" $dangling {}
foreach hit [lrange $dangling 0 9] { puts "       $hit" }

puts "\nthe position-change chain still runs to the end"

# The scan above says no call is spelled with a retired name; this runs one of
# them. #437 round 1: ::notify::privPosChanged kept two calls to updateAnalysis,
# so every move, edit and comment aborted there - before the comment editor,
# tablebase, book, novelty, tree-filter and EPD refreshes - and nothing caught
# it because no harness ran the proc. It is lifted and run here with every
# sibling stubbed: the chain has to reach the end.
set text [procText [file join $root tcl game.tcl] privPosChanged]
if {$text eq ""} {
    check "::notify::privPosChanged can be lifted out of game.tcl" 0
} else {
    set ::ran {}
    # tclsh has no windows: every "if {[winfo exists .w]}" takes its branch.
    proc winfo {sub args} { return 1 }
    set ::showGameInfo 0
    foreach name {moveEntry_Clear updateStatusBar updateMainToolbar updateTitle
                  updateTwinChecker updateNoveltyWin} {
        proc $name {} [format {lappend ::ran %s} $name]
    }
    foreach name {::windows::commenteditor::Refresh ::tablebase::window::results
                  ::book::refresh ::book::refreshTuning ::lichess_eval::refresh
                  ::updateTreeFilter ::epd::updateEpdWins} {
        namespace eval [namespace qualifiers $name] {}
        proc $name {} [format {lappend ::ran %s} $name]
    }
    eval $text
    # The lifted body was defined at global scope; the app's is in ::notify, so
    # give it the name the rest of the tree calls.
    rename privPosChanged ::notify::privPosChanged
    set rc [catch { ::notify::privPosChanged } err]
    check "the chain runs without error" [expr {$rc == 0}] $err
    checkEq "and reaches the last refresh" [lindex $::ran end] ::epd::updateEpdWins
    check "the whole chain ran" \
        [expr {[llength $::ran] == 13}] "ran: $::ran"
}

set english [readText [file join $root tcl lang english.tcl]]
check "the new Open label is in English" \
    [expr {[string first "translate E EngineOpenWindow {Open Engine Window}" $english] >= 0}]
check "and the toolbar's Engine Window label too" \
    [expr {[string first "menuText E ToolsEngineWindow" $english] >= 0}]

puts "\nthe engine chooser opens an Engine Window"

# The proc is lifted out: sourcing enginelist.tcl reads the user's engine file
# and builds dialogs. The stubs are the window and the preset list.
namespace eval enginelist {}
set ::engines(list) {{TestEngine /bin/true}}
set text [procText [file join $root tcl tools enginelist.tcl] \
    ::enginelist::openSelected]
if {$text eq ""} {
    check "::enginelist::openSelected can be lifted" 0
} else {
    eval $text
    proc {.enginelist.list.list} {args} { return 0 }
    set ::destroyed {}
    proc destroy {args} { set ::destroyed [lindex $args 0] }
    proc ::enginelist::setTime {args} {}
    set ::started {}
    namespace eval enginewin {}
    proc ::enginewin::start {id name} { set ::started [list $id $name] }

    ::enginelist::openSelected 1
    checkEq "Open starts an Engine Window for the preset" \
        $::started {{} TestEngine}
    checkEq "and closes the chooser" $::destroyed .enginelist

    set ::started {}
    set ::destroyed {}
    ::enginelist::openSelected 0
    checkEq "a double-click also starts the Engine Window" \
        $::started {{} TestEngine}
    checkEq "and leaves the chooser open" $::destroyed {}
}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
