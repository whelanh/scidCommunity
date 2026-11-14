#!/usr/bin/env wish
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# sergame_ui.tcl -- what a reader of the Play-versus-Engine window sees, when it
# is not about the engine at all: the blunder dialog's best-move line and the
# clock face the game asks the shared widget for.
#
#   wish tests/tcl/sergame_ui.tcl
#   xvfb-run -a wish tests/tcl/sergame_ui.tcl     (no display)
#
# These are findings from David's manual play-test of the ported module (#437
# §4) that are not port fixes: pre-existing contrast debt, and a preference the
# port was the first chance to add.
#
#   1. the best-move line was written in a hardcoded #1a1aff, ~1.4:1 on a dark
#      theme (it predates the port, commit c3c0659b). The tree's coach blue is
#      the documented theme-safe one.
#   2. the two clock faces were stacked one above the other; the row they make
#      is checked as geometry in tests/tcl/sergame_engine.tcl, where the real
#      game window is built.
#   3. there was no digital clock option, and a digital face is what David
#      prefers. ::gameclock is shared with FICS and Tactics, so the choice is
#      the caller's and the default is the face everyone had before.
#
# What is real here: tcl/misc.tcl's own ::gameclock namespace (the widget, run
# for real on a canvas), tcl/tools/comment_colors.tcl (the colour layer), and
# tcl/tools/sergame.tcl's own procs -- the dialog is built by the shipped
# blunderDialog, driven by a scheduled answer to its modal wait, and read back.
# What is stubbed: the application frame around the dialog (the theme paint and
# the saved window position), because this file owns neither.

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
proc checkEq {label got want {detail ""}} {
    if {$detail eq ""} { set detail "got '$got' want '$want'" }
    check $label [expr {$got eq $want}] $detail
}
proc checkIn {label haystack needle} {
    check $label [expr {[string first $needle $haystack] >= 0}] \
        "in '$haystack' want '$needle'"
}
proc checkNotIn {label haystack needle} {
    check $label [expr {[string first $needle $haystack] < 0}] \
        "in '$haystack' want no '$needle'"
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
proc readText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation auto
    set text [read $f]
    close $f
    return $text
}

set sergameSrc [readText [file join $root tcl tools sergame.tcl]]
set optionsSrc [readText [file join $root tcl options.tcl]]

# ------------------------------------------------------------------ the set-up --
# The strings: tcl/tools/sergame.tcl builds its opening list at source time, so
# the catalogue has to be there before it is loaded. As in
# tests/tcl/sergame_engine.tcl, english.tcl is sourced with translate/menuText
# stubbed into the ::tr array -- the shipped catalogue, read for its keys.
array set ::tr {}
proc translate {lang key args} { set ::tr($key) [lindex $args 0] }
proc menuText {lang key text args} { set ::tr($key) $text }
source -encoding utf-8 [file join $root tcl lang english.tcl]
set ::optionsFile ""
setLanguage_E

# The widget and the colour layer, from the shipped bytes. The dialog needs the
# application's frame around a toplevel; here a theme paint and a saved window
# position are worth nothing, and saying so keeps the dialog's own code real.
source -encoding utf-8 [file join $root tcl tools comment_colors.tcl]
source -encoding utf-8 [file join $root tcl misc.tcl]
source -encoding utf-8 [file join $root tcl tools sergame.tcl]
proc applyThemeColor_background {w} { return }
proc setWinLocation {w} { return }

# =============================================================================
puts "\nthe clock face is the caller's choice, and the default is today's face"
# =============================================================================
# FICS and Tactics call ::gameclock::new with no face at all, so the default has
# to stay exactly the face they have always drawn: the numerals, the hands, and
# the small digital text inside the analog face.
frame .faces
pack .faces

proc itemTypes {canvas tag} {
    set out {}
    foreach item [$canvas find withtag $tag] { lappend out [$canvas type $item] }
    return $out
}
proc dynamicTypes {n} { return [itemTypes .faces.clock$n aig$n] }

::gameclock::new .faces 1 88 0
::gameclock::new .faces 2 88 0 analog
::gameclock::new .faces 3 88 0 digital
update idletasks

checkEq "the default face keeps its numerals" \
    [llength [.faces.clock1 find withtag clock1]] 12
set both [dynamicTypes 1]
check "the default face draws hands" \
    [expr {[lsearch -exact $both line] >= 0}] "items: $both"
check "and the small digital text inside it" \
    [expr {[lsearch -exact $both text] >= 0}] "items: $both"
check "so the default face is unchanged" [expr {[llength $both] == 4}] "items: $both"

set analog [dynamicTypes 2]
check "the analog face has numerals" \
    [expr {[llength [.faces.clock2 find withtag clock2]] == 12}]
check "and hands" [expr {[lsearch -exact $analog line] >= 0}] "items: $analog"
checkEq "and no digital text at all" [lsearch -exact $analog text] -1

set digital [dynamicTypes 3]
checkEq "the digital face draws no numerals" \
    [llength [.faces.clock3 find withtag clock3]] 0
checkEq "no analog hands" [lsearch -exact $digital line] -1
checkEq "and one text, the clock" [llength $digital] 1
set textItem [lindex [.faces.clock3 find withtag aig3] 0]
checkEq "which reads h:mm:ss" [.faces.clock3 itemcget $textItem -text] "0:00:00"
check "the digital face is wider than it is tall" \
    [expr {[.faces.clock3 cget -width] > [.faces.clock3 cget -height]}] \
    "width [.faces.clock3 cget -width], height [.faces.clock3 cget -height]"
checkEq "and the analog face is still a square" \
    [list [.faces.clock2 cget -width] [.faces.clock2 cget -height]] [list 88 88]

# A face can change while the clock runs: the game window's preference is a
# checkbox, not a restart.
::gameclock::setSec 1 3599
::gameclock::setDisplay 1 digital
set switched [dynamicTypes 1]
checkEq "switching to the digital face leaves one text and no hands" \
    [llength $switched] 1
check "which is the text" [expr {[lindex $switched 0] eq "text"}]
checkEq "and carries the hours the analog face hides" \
    [.faces.clock1 itemcget [lindex [.faces.clock1 find withtag aig1] 0] -text] "0:59:59"
::gameclock::setDisplay 1 analog
set back [dynamicTypes 1]
checkEq "switching back restores the hands and drops the text" \
    [lsearch -exact $back text] -1
checkEq "with the numerals" [llength [.faces.clock1 find withtag clock1]] 12

# =============================================================================
puts "\nthe blunder dialog's best-move line is the theme-safe blue"
# =============================================================================
# The dialog is a real modal window (it waits on a variable), so the scenario
# answers it: show the best move, read the label back, then choose "Use my move".
set ::uiFg ""
set ::uiText ""
proc answerDialog {} {
    set w .blunderDialog
    if {[winfo exists $w]} {
        catch { $w.btns.show invoke }
        set ::uiFg [$w.best.l cget -foreground]
        set ::uiText [$w.best.l cget -text]
    }
    set ::blunderResult 2
}
after 100 answerDialog
set rc [catch { ::sergame::blunderDialog "Bad move played, do you want to take back ?" "Nf3" } err]
checkEq "the dialog answered" $rc 0 $err
checkEq "and was closed" [winfo exists .blunderDialog] 0

checkEq "the best-move line is the colour layer's coach blue" \
    $::uiFg $::commentcolors::coachColor
checkEq "which is the documented theme-safe blue" $::uiFg "#3B82F6"
checkIn "the line still shows the move" $::uiText "Best move: Nf3"

# The old hardcoded blue is gone from the module, and the fallback the dialog
# uses when the colour layer is not loaded is the same blue -- never a third.
check "the old hardcoded blue is no longer a value in the module" \
    [expr {[string first {"#1a1aff"} $sergameSrc] < 0}] \
    "a quoted \"#1a1aff\" is still in the module"
set savedCoach $::commentcolors::coachColor
unset ::commentcolors::coachColor
checkEq "with no colour layer the module falls back to the same blue" \
    [::sergame::bestMoveColor] "#3B82F6"
set ::commentcolors::coachColor $savedCoach
checkEq "and the fallback is the layer's own value, not a coincidence" \
    [::sergame::bestMoveColor] $::commentcolors::coachColor

# The reason it is the right blue, measured rather than believed: WCAG relative
# luminance against the darkest bundled background.
proc relLum {hex} {
    set out 0.0
    set weights {0.2126 0.7152 0.0722}
    set i 0
    foreach w $weights {
        set c [expr {[scan [string range $hex [expr {1 + $i * 2}] [expr {2 + $i * 2}]] %x] / 255.0}]
        if {$c <= 0.03928} {
            set c [expr {$c / 12.92}]
        } else {
            set c [expr {pow(($c + 0.055) / 1.055, 2.4)}]
        }
        set out [expr {$out + $w * $c}]
        incr i
    }
    return $out
}
proc contrast {a b} {
    set la [relLum $a]
    set lb [relLum $b]
    if {$la < $lb} { lassign [list $lb $la] la lb }
    return [expr {($la + 0.05) / ($lb + 0.05)}]
}
set ratio [contrast "#3B82F6" "#1e1e2e"]
check "the coach blue clears 4.4:1 on the darkest bundled background" \
    [expr {$ratio >= 4.4}] [format "%.2f:1" $ratio]
set oldRatio [contrast "#1a1aff" "#1e1e2e"]
check "and is at least twice as legible as the blue it replaces" \
    [expr {$ratio >= 2 * $oldRatio}] \
    [format "new %.2f:1, old %.2f:1" $ratio $oldRatio]

# =============================================================================
puts "\nthe two preferences are saved, and they default the way the card says"
# =============================================================================
# options.tcl is the persistence mechanism: a default set before the options
# file is loaded, and the name in the list the save proc writes out. This reads
# both, which is what "survives a restart" means for a preference.
proc firstLine {text pattern} {
    set i 0
    foreach line [split $text "\n"] {
        if {[regexp -- $pattern $line]} { return $i }
        incr i
    }
    return -1
}
set loadAt [firstLine $optionsSrc {safeLoadConfig \$optionsFile}]
check "the options file is loaded in tcl/options.tcl" [expr {$loadAt > 0}]

# The list the save proc writes out, as the block of lines it is.
set saveAt [firstLine $optionsSrc {puts \$optionF "set \$i \[list \[set \$i\]\]"}]
check "the options save loop was found" [expr {$saveAt > 0}]
set savedList [join [lrange [split $optionsSrc "\n"] [expr {$saveAt - 60}] $saveAt] "\n"]

foreach {name want} {showDigitalClock 1 clockFromGame 1} {
    set defAt [firstLine $optionsSrc "^set ::sergame::$name "]
    check "::sergame::$name has a default" [expr {$defAt > 0}]
    check "and the default is set before the options file is loaded" \
        [expr {$defAt > 0 && $defAt < $loadAt}] "default at $defAt, load at $loadAt"
    checkEq "::sergame::$name defaults to $want" \
        [string trim [lindex [split [lindex [split $optionsSrc "\n"] $defAt] " "] end]] $want
    checkIn "::sergame::$name is in the list the options file saves" \
        $savedList "::sergame::$name"
    # And the module's own default, for a harness that sources it alone.
    checkEq "::sergame::$name defaults to $want in the module too" \
        [set ::sergame::$name] $want
}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
