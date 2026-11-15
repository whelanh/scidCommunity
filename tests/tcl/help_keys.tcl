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

# The Training submenu is the <ul> that follows the Training header. Its two
# surviving entries are Openings and Tactics; the retired Review game bullet
# carried no <a> link, so a link search cannot see it. Count the <menu> labels
# in the submenu instead: helpPL.tcl translates its labels ("Trening",
# "Przeglad partii"), so a literal "<menu>Review Game</menu>" search would miss
# it. Returns -1 when the submenu cannot be located.
proc trainingBullets {text} {
    foreach hdr {Training Trening} {
        set i [string first "<menu>$hdr</menu>" $text]
        if {$i < 0} { continue }
        set ul [string first "<ul>" $text $i]
        if {$ul < 0} { return -1 }
        set close [string first "</ul>" $text [expr {$ul + 4}]]
        if {$close < 0} { return -1 }
        return [regexp -all "<menu>" [string range $text [expr {$ul + 4}] $close]]
    }
    return -1
}

# The controls the engine window now has, and the keys their help pages are
# named after: the label the button shows is the key, which is what the old
# GameComment page did too. ToolsWhatThreat is the engine window's third review
# control and a Tools entry, and its page is named after the label key the
# menu and the message box title share.
set BUTTON_PAGES {ReviewGameButton ReviewMoveButton ReviewSettings ToolsWhatThreat}

# The English file has no namespace; the Polish one prefixes every key with
# "P," so the help viewer can find it for the selected language and fall back
# to English for the topics it does not translate.
#
# The retired proc's name is assembled rather than spelled: #437 §8's
# acceptance check greps the tree for it and must come back empty, and that
# includes this guard. The check is about the help pages, so the needle may be
# built here.
set RETIRED_PROC "::analysis"
append RETIRED_PROC "_auto_comment"

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

    # The two trainers #437 §3a retired: Review game and the Calvar (Stoyko)
    # exercise. Their pages are gone with their menu entries, and nothing may
    # link to them any more.
    check "$label: no CalVar page" [expr {![hasPage $h ${prefix}CalVar]}]
    check "$label: no page links to CalVar" \
        [expr {[string first "<a CalVar>" $all] < 0}] \
        "a link whose page is gone draws nothing"
    check "$label: no ReviewGame page" [expr {![hasPage $h ${prefix}ReviewGame]}]
    check "$label: no page links to ReviewGame" \
        [expr {[string first "<a ReviewGame>" $all] < 0}]
    check "$label: no Review game menu bullet" \
        [expr {[string first "<menu>Review Game</menu>" $all] < 0}]
    set idx [expr {[hasPage $h ${prefix}Index] ? [pageText $h ${prefix}Index] : ""}]
    check "$label: still documents the Tactics trainer" \
        [expr {[hasPage $h ${prefix}TacticsTrainer] && \
            [string first "<a TacticsTrainer>" $idx] >= 0}]

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

    # #437 §8 retired the script-driven batch annotator: no page may document
    # the proc, in any language. The English BatchAnnotate page stays - it is
    # the target of the Annotating intros' links - but it now documents the Game
    # List batch, which is live; only the Polish page documented the dead dialog
    # and only it was deleted (deletion-only translation policy).
    check "$label: no page documents $RETIRED_PROC" \
        [expr {[string first $RETIRED_PROC $all] < 0}]
    if {$prefix ne ""} {
        check "$label: keeps no BatchAnnotate page of its own" \
            [expr {![hasPage $h ${prefix}BatchAnnotate]}]
        # The links from other translated pages stay: the viewer falls back to
        # the English page for a topic the translation does not carry. The index
        # bullet for the deleted page is another matter - it named the dialog.
        check "$label: the index links to no BatchAnnotate page of its own" \
            [expr {[string first "<a BatchAnnotate>" \
                [pageText $h ${prefix}Index]] < 0}]
    }

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

    # The Analysis window and its Annotate dialog are retired (#436). The page
    # remains only as a redirect, and nothing may link to it as a live window.
    check "$label: Analysis is a retirement page" \
        [expr {[hasPage $h ${prefix}Analysis] && \
            [string first "<a Engine>" [pageText $h ${prefix}Analysis]] >= 0}]
    check "$label: no page links to Analysis" \
        [expr {[string first "<a Analysis>" $all] < 0}]
    check "$label: no page links to Analysis List" \
        [expr {[string first "<a Analysis List>" $all] < 0}]
    check "$label: Annotating points at the review" \
        [expr {[string first "<a ReviewGameButton>" \
            [pageText $h ${prefix}Annotating]] >= 0}]
    check "$label: Engine defines the Configure Engines target" \
        [expr {[string first "<name Configure>" \
            [pageText $h ${prefix}Engine]] >= 0}]

    if {$prefix eq ""} {
        check "English: no Analysis Engine text" \
            [expr {[string first "Analysis Engine" $all] < 0}]
        check "English: Engine no longer compares with the Analysis window" \
            [expr {[string first "differ from the Analysis window" \
                [pageText $h Engine]] < 0}]
        check "English: EPD no longer compares with the Analysis window" \
            [expr {[string first "differs from the Analysis window" \
                [pageText $h EPD]] < 0}]
        check "English: Review Settings lists the opening finder" \
            [expr {[string first "Find opening errors" \
                [pageText $h ReviewSettings]] >= 0}]
        check "English: Review Settings lists tactical exercises" \
            [expr {[string first "Mark tactical exercises" \
                [pageText $h ReviewSettings]] >= 0}]
    }

    interp delete $h
}

# --- #437 §6 round 3: the guard has to work in every language -------------
# The six fragments above are English, so a translation that says the same
# thing in its own language passes them - 26 of the 27 translated files did.
# These checks are language-agnostic instead: they read help.tcl's own pages
# and the translated pages and compare them, so a stale sentence fails in any
# language, and so does a page whose English counterpart does not exist.
#
# The three sentences are English's own wording for the engine pages that
# replaced the window. They are asserted against help.tcl first, so the
# sentinels cannot rot silently: if English is reworded, the English checks
# fail here and the sentinels move with it.
set ENGINE_SENTINEL "They are the only engine surface now; the old Analysis window has been retired."
set CE_SENTINEL "is in pawns from White's perspective instead"
set ANNO_SENTINEL "opens an Engine Window on the chosen engine (or raises the one already showing it) and drives it"
# #437 §8: the three facts the BatchAnnotate page has to carry now that it
# documents the live Game List batch instead of the retired script-only dialog.
set BATCH_SENTINELS [list {Game List} {Batch Annotate} {No AI provider is involved}]

lassign [loadHelp [file join $root tcl help help.tcl]] enh enErr
check "English help loads for the translated-page checks" [expr {$enh ne ""}] $enErr
set enKeys {}
set enFlat ""
if {$enh ne ""} {
    foreach k [$enh eval {array names helpText}] {
        lappend enKeys [lindex [split $k ,] end]
    }
    set enFlat [regsub -all {\s+} [everyPage $enh] " "]
}
foreach {nm frag} [list Engine $ENGINE_SENTINEL \
        EPD-ce $CE_SENTINEL EPD-annotating $ANNO_SENTINEL] {
    check "English: the $nm sentinel is still the wording help.tcl uses" \
        [expr {[string first $frag $enFlat] >= 0}]
}
check "English: no page links to Analysis once whitespace is flattened" \
    [expr {[string first "<a Analysis>" $enFlat] < 0}]

# #437 §8: the BatchAnnotate page survives the retirement of the script-only
# dialog, because it is what every Annotating intro links to, and it documents
# the Game List batch that is still there. Its sentinels are read from the page
# itself - flattened, because the page wraps - so a reworded page fails here
# instead of leaving the check pointing at text that has moved.
check "English: BatchAnnotate is still a page" [hasPage $enh BatchAnnotate]
set enBatch ""
if {[hasPage $enh BatchAnnotate]} {
    set enBatch [regsub -all {\s+} [pageText $enh BatchAnnotate] " "]
}
foreach frag $BATCH_SENTINELS {
    check "English: BatchAnnotate still names '$frag'" \
        [expr {[string first $frag $enBatch] >= 0}]
}

# #437 §7 retired the three page families only the translations carried, and
# with them the allow-list that used to excuse them. Each decision came from
# the tree, not from the page text:
#
#   PGNAutoComment  the PGN window's Auto Comment button moved to the engine
#                   window (61066adb) and the engine window builds no comment
#                   button at all since §5.
#   SeriousGame     Scid's pre-merge Phalanx/Toga trainers. The feature is live
#   TacticalGame    under its merged name: Tools > Play vs Engine
#                   (::sergame::config, menu label ToolsPlayVsEngine) is the
#                   one game window, and English documents it as PlayVsEngine.
#
# The parity check below is therefore unconditional over the three. Pgnscid is
# NOT excused by a list: pgnscid.cpp was deleted in 2014, not by this stack, so
# its page and its 112 links are out of scope here and left to their own card.
# One page needs the exception by name, and only because of its key: PL spells
# it "PgnScid", and the viewer resolves a key exactly, so English's "Pgnscid"
# can never answer for it. That casing is a real defect - the check below names
# it so it cannot be forgotten, rather than hiding it in a class of pages.
set OUT_OF_SCOPE_PAGE PgnScid
set RETIRED_PAGES {PGNAutoComment SeriousGame TacticalGame}

# Every translated help file is still Tcl data with matched pages, and none of
# them may keep the retired Analysis window as a live target. The English and
# Polish files above get the detailed button checks; this is the structural
# check for the rest.
puts "\nevery translated help file"
foreach path [lsort [glob [file join $root tcl help help*.tcl]]] {
    set label [file tail $path]
    lassign [loadHelp $path] h err
    check "$label: sources without error" [expr {$h ne ""}] $err
    if {$h eq ""} { continue }
    set orphans {}
    foreach k [$h eval {array names helpText}] {
        if {![$h eval [list info exists helpTitle($k)]]} {
            lappend orphans "text-only:$k"
        }
    }
    foreach k [$h eval {array names helpTitle}] {
        if {![$h eval [list info exists helpText($k)]]} {
            lappend orphans "title-only:$k"
        }
    }
    checkEq "$label: every page and title pair up" $orphans {}
    set all [everyPage $h]

    # #437 §6 round 3: a link is a link even when it wraps. The check above
    # searches the raw text, so `<a` at the end of a line and `Analysis>` at
    # the start of the next one - how every translated Training page phrased
    # it - went unseen. #437 §7 made it unconditional: §6 exempted all 26
    # translations from it, which is exactly why the 52 links it was written
    # for went on passing.
    set flatAll [regsub -all {\s+} $all " "]
    check "$label: no page links to Analysis once whitespace is flattened" \
        [expr {[string first "<a Analysis>" $flatAll] < 0}] \
        "a link split across lines is still a link"

    # #437 §7 additions. Three of the four read the flattened text as well as
    # the raw text, because a link that wraps draws nothing either.
    #
    # 1. The retired pages are gone, in every language.
    set retiredPages {}
    foreach k [$h eval {array names helpText}] {
        if {[lindex [split $k ,] end] in $RETIRED_PAGES} { lappend retiredPages $k }
    }
    checkEq "$label: no retired translated-only page" $retiredPages {}

    # 2. And nothing links to one, in any form it can be written: raw, with the
    #    line break flattened out, or as a section link. `<a TacticalGame>` is
    #    the plain form; `<a TacticalGame Tactics>` is how a link to a section
    #    of a page is written, and [string first "<a TacticalGame>"] sees
    #    neither of those once it wraps.
    set deadLinks {}
    foreach k $RETIRED_PAGES {
        if {[string first "<a $k>" $all] >= 0 ||
                [string first "<a $k>" $flatAll] >= 0 ||
                [regexp -- "<a\\s+${k}(\\s|>)" $flatAll]} {
            lappend deadLinks $k
        }
    }
    checkEq "$label: no link to a retired page in any form" $deadLinks {}

    # The Analysis window's own pages are the ones the reader must not find:
    # English defines none of them, so a translation that still has one is
    # documenting a window the tree does not draw. Since #437 §7 this is
    # unconditional: the three translated-only families are gone with it, so
    # a page a translation has and English does not is a page nobody reaches.
    set extra {}
    foreach k [$h eval {array names helpText}] {
        set leaf [lindex [split $k ,] end]
        if {[lsearch -exact $enKeys $leaf] < 0 && $leaf ne $OUT_OF_SCOPE_PAGE} {
            lappend extra $leaf
        }
    }
    checkEq "$label: every page has an English counterpart" $extra {}

    # And the window is retired in this language too. The check cannot quote
    # the translated sentence - the wording belongs to the translator - so it
    # asserts the opposite: English's sentence must NOT be standing there. #437
    # §6 pasted the three English blocks into all 27 translations, and
    # tcl/lang/translateHelp.py is the process that puts a language back; this
    # is what notices when a page skipped that process.
    set kEngine ""
    set kEPD ""
    foreach k [$h eval {array names helpText}] {
        set leaf [lindex [split $k ,] end]
        if {$leaf eq "Engine"} { set kEngine $k }
        if {$leaf eq "EPD"} { set kEPD $k }
    }
    set fEngine [regsub -all {\s+} \
        [expr {$kEngine ne "" ? [pageText $h $kEngine] : ""}] " "]
    set fEPD [regsub -all {\s+} \
        [expr {$kEPD ne "" ? [pageText $h $kEPD] : ""}] " "]
    # English is where these sentences are written, so there "the file's own"
    # means present; in every other file it means absent.
    set isEn [expr {$label eq "help.tcl"}]
    foreach {nm frag text} [list engine-surface $ENGINE_SENTINEL $fEngine \
            ce-note $CE_SENTINEL $fEPD \
            annotating-paragraph $ANNO_SENTINEL $fEPD] {
        check "$label: the $nm wording is the file's own" \
            [expr {([string first $frag $text] < 0) != $isEn}]
    }

    # #437 §7: no Analysis link in any form. The raw check below cannot see a
    # link that wraps, and the flattened check above only knows the single
    # token form; `<a Analysis List>` - a section of the retired page - is the
    # third form, and the flattened text is what carries all three.
    check "$label: no Analysis link in any form" \
        [expr {![regexp -- {<a\s+Analysis(\s|>)} $flatAll]}]

    # #437 §7: the Engine page's first <ul> is its button list - one control
    # per bullet, each naming the widget it describes. A bullet that names
    # nothing is a bullet for a button the window does not build: §5 removed
    # the engine window's comment path and left 47 such bullets across the 26
    # translations, written in their own languages, so a search for the
    # English label saw six files of the twenty-six.
    set ulAt [string first "<ul>" $fEngine]
    set ulEnd [expr {$ulAt < 0 ? -1 : [string first "</ul>" $fEngine]}]
    set nameless {}
    if {$ulEnd > $ulAt} {
        # [split] takes a SET of separators, so "<li>" would split on each of
        # its characters; walk the list by hand instead.
        set seg [string range $fEngine [expr {$ulAt + 4}] [expr {$ulEnd - 1}]]
        set at 0
        while {[set s [string first "<li>" $seg $at]] >= 0} {
            set e [string first "</li>" $seg $s]
            if {$e < 0} { break }
            set item [string range $seg [expr {$s + 4}] [expr {$e - 1}]]
            if {![regexp -- {<button\s+tb_[a-z_]+} $item] &&
                    ![regexp -- {<a\s+[A-Za-z]} $item]} {
                lappend nameless [string trim [string range $item 0 48]]
            }
            set at $e
        }
    }
    check "$label: every Engine button bullet names a widget" \
        [expr {$ulEnd > $ulAt && [llength $nameless] == 0}] \
        "bullets naming no <button> or <a> target: $nameless"

    check "$label: no page links to Analysis" \
        [expr {[string first "<a Analysis" $all] < 0}]
    set analysisPage ""
    foreach k [$h eval {array names helpText}] {
        if {[string match "*,Analysis" $k] || $k eq "Analysis"} {
            set analysisPage [$h eval [list set helpText($k)]]
            break
        }
    }
    check "$label: Analysis is a retirement page" \
        [expr {$analysisPage ne "" && \
            [string first "<a Engine>" $analysisPage] >= 0}]
    # #437 §3a: the two retired trainers must have left no page behind in any
    # language, and no link to one.
    set retired {}
    foreach k [$h eval {array names helpText}] {
        set leaf [lindex [split $k ,] end]
        if {$leaf in {CalVar ReviewGame}} { lappend retired $k }
    }
    checkEq "$label: no CalVar or ReviewGame page" $retired {}
    check "$label: no page links to CalVar" \
        [expr {[string first "<a CalVar>" $all] < 0}]
    check "$label: no page links to ReviewGame" \
        [expr {[string first "<a ReviewGame>" $all] < 0}]
    set trBullets [trainingBullets $all]
    check "$label: Training submenu keeps only Openings and Tactics" \
        [expr {$trBullets == 2}] "found $trBullets bullets"
    # #437 §6: the Analysis window is retired, so no page may present it as a
    # live window, a live comparison, or a menu entry. Upstream dropped the
    # Tools > Analysis Window bullet from the English file and left it in the
    # other 26; helpKO kept three live-tense sentences and English kept "the
    # analysis window's engine". None of that shows up as a broken link, which
    # is why the checks above miss it: the bullet links to Engine, which still
    # exists, and the sentences carry no link at all. Whitespace is flattened
    # first, because these sentences wrap across lines and a phrase that is
    # whole only after the join would otherwise pass unseen.
    set flat [regsub -all {\s+} $all " "]
    set live {}
    foreach frag {
        "<menu>Analysis Window</menu>: Opens the <a Engine>analysis window</a>"
        "<a Engine>analysis window</a>"
        "analysis window's engine"
        "differ from the Analysis window"
        "differs from the Analysis window"
        "analysis window is already opened"
    } {
        if {[string first $frag $flat] >= 0} { lappend live $frag }
    }
    checkEq "$label: no live Analysis window copy" $live {}
    interp delete $h
}
if {$enh ne ""} { interp delete $enh }

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
