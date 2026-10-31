#!/usr/bin/env tclsh
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# help_keys.tcl -- the help text describes the engine window this branch ships.
#
#   tclsh tests/tcl/help_keys.tcl
#
# The engine window's Game Comment button is gone: tcl/windows/engine.tcl lays
# out Game Review, Move Comment and Review Settings instead, and the review's
# own decisions live in tcl/tools/review_ui.tcl (kanban t_699be5ce). The help
# pages are data - arrays of page text, keyed by topic - so this harness reads
# the pages rather than line numbers: each help file is sourced in its own
# interpreter, and the assertions are about the keys it defines, the links its
# index and its Engine page carry, and the buttons engine.tcl really creates.
#
# A page that survives a deleted button is a link into nothing: the help viewer
# looks helpText(<key>) up and returns without drawing anything, so the user is
# left with a bullet that does nothing. That is what this file is for.

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

# A help file is Tcl data, nothing else: it sets helpTitle(...) and helpText(...)
# and returns. Sourcing it into an interpreter of its own keeps one language's
# pages from answering for another's, and gives the pages by name.
proc loadHelp {path} {
    set h [interp create]
    if {[catch { $h eval [list source -encoding utf-8 $path] } err]} {
        interp delete $h
        return [list "" $err]
    }
    return [list $h ""]
}
proc hasPage {h key}  { return [$h eval [list info exists helpText($key)]] }
proc hasTitle {h key} { return [$h eval [list info exists helpTitle($key)]] }
proc pageText {h key} { return [$h eval [list set helpText($key)]] }
proc pageTitle {h key} { return [$h eval [list set helpTitle($key)]] }
proc pageKeys {h} { return [lsort [$h eval {array names helpText}]] }
proc everyPage {h} {
    return [$h eval {
        set _all ""
        foreach _k [array names helpText] { append _all $helpText($_k) "\n" }
        set _all
    }]
}

# The three controls the engine window now has, and the keys their help pages
# are named after: the label the button shows is the key, which is what the old
# GameComment page did too.
set BUTTON_PAGES {ReviewGameButton ReviewMoveButton ReviewSettings}

# The English file has no namespace; the Polish one prefixes every key with
# "P," so the help viewer can find it for the selected language and fall back
# to English for the topics it does not translate.
set HELP_FILES [list \
    [list "tcl/help/help.tcl"   ""   "English help (tcl/help/help.tcl)"] \
    [list "tcl/help/helpPL.tcl" "P," "Polish help (tcl/help/helpPL.tcl)"]]

foreach spec $HELP_FILES {
    lassign $spec rel prefix label
    set path [file join $root {*}[split $rel /]]
    puts "\n$label"

    checkEq "$label: is whole Tcl" [info complete [readText $path]] 1

    lassign [loadHelp $path] h err
    check "$label: sources without error" [expr {$h ne ""}] $err
    if {$h eq ""} { continue }

    set all [everyPage $h]

    # The button the branch removed must not be documented by it.
    check "$label: no GameComment page" [expr {![hasPage $h ${prefix}GameComment]}]
    check "$label: no page links to GameComment" \
        [expr {[string first "<a GameComment>" $all] < 0}] \
        "a link whose page is gone draws nothing"

    # And the three it has must be, each a page with a title and a heading.
    foreach page $BUTTON_PAGES {
        check "$label: defines $page" [hasPage $h ${prefix}$page]
        check "$label: titles $page" [hasTitle $h ${prefix}$page]
        if {[hasPage $h ${prefix}$page]} {
            check "$label: $page is a page, not a stub" \
                [expr {[string first "<h1>" [pageText $h ${prefix}$page]] >= 0}]
        }
    }

    # A page nobody links to is a page nobody reads: the index is how a reader
    # finds one, and the Engine page is where the button is described.
    set index [pageText $h ${prefix}Index]
    set engine [expr {[hasPage $h ${prefix}Engine] ? [pageText $h ${prefix}Engine] : ""}]
    foreach page $BUTTON_PAGES {
        check "$label: the index lists $page" \
            [expr {[string first "<a $page>" $index] >= 0}]
        check "$label: the Engine page lists $page" \
            [expr {[string first "<a $page>" $engine] >= 0}]
    }

    # The classic annotator is still callable from the console even though its
    # button is gone, so its description stays where it documents the proc.
    check "$label: still documents ::analysis_auto_comment::batch_generate" \
        [expr {[string first "::analysis_auto_comment::batch_generate" $all] >= 0}]

    # Every page has a title and every title has a page, in this file: the
    # viewer needs both to draw a page, and a title without one is dead too.
    set orphans {}
    foreach k [pageKeys $h] {
        if {![hasTitle $h $k]} { lappend orphans "text-only:$k" }
    }
    foreach k [lsort [$h eval {array names helpTitle}]] {
        if {![hasPage $h $k]} { lappend orphans "title-only:$k" }
    }
    checkEq "$label: every page and title pair up" $orphans {}

    interp delete $h
}

# The help may only name buttons the window has. This reads the widget names
# engine.tcl creates, so a page added for a button that is not built fails here.
puts "\nengine window (tcl/windows/engine.tcl)"
set engineSrc [readText [file join $root tcl windows engine.tcl]]
foreach b {gamereview movecomment threat reviewsettings} {
    check "engine.tcl builds \$btn.$b" [regexp -- "\\\$btn\\.$b\\M" $engineSrc]
}
check "engine.tcl builds no \$btn.gamecomment" \
    [expr {![regexp -- "\\\$btn\\.gamecomment\\M" $engineSrc]}]

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
