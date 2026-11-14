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

##############################################################################
puts "\na face fills its frame and keeps its aspect"
# A filling face asks for no size: its canvas takes the frame's space and the
# face is drawn to whatever that is. That is what keeps two faces in a row from
# sizing each other out of the window.
frame .box -width 400 -height 100
pack propagate .box 0
pack .box
::gameclock::new .box 1 88 0 digital 1
update
lassign [::gameclock::sizeOf 1] w h
checkEq "a filling face draws at the size its frame gives it" [list $w $h] [list 400 100]

# The digital text fits the box it is drawn in, in both directions.
set txt [lindex [.box.clock1 find all] 0]
# The rendered size is only measurable on a Tk with scalable fonts: with nothing
# but the bitmap "fixed" family, every size request collapses to ~9px and the
# check would fail for the host, not for the code. The size rule itself is
# checked above as a function of the box.
if {[llength [font families]] > 1} {
    set fname [.box.clock1 itemcget $txt -font]
    set fs [font actual $fname -size]
    if {$fs < 0} { set fs [expr {-$fs}] }
    check "the digits are allowed most of the box" [expr {$fs > $h / 3}] "size $fs in $h"
}
lassign [.box.clock1 bbox $txt] x0 y0 x1 y1
check "the drawn text is inside the canvas" [expr {$x0 >= 0 && $x1 <= $w && $y0 >= 0 && $y1 <= $h}]

# The dial is centred in a wide box, not parked in its corner: the numerals'
# bounding box is centred within a few percent of the canvas centre, and it is
# about the height of the box.
::gameclock::setDisplay 1 analog
.box configure -height 200
update
set xs {} ; set ys {}
foreach it [.box.clock1 find all] {
    lassign [.box.clock1 bbox $it] x0 y0 x1 y1
    lappend xs $x0 $x1 ; lappend ys $y0 $y1
}
set bbw [expr {[lindex [lsort -integer $xs] end] - [lindex [lsort -integer $xs] 0]}]
set bbh [expr {[lindex [lsort -integer $ys] end] - [lindex [lsort -integer $ys] 0]}]
set cx [expr {[lindex [lsort -integer $xs] 0] + $bbw / 2}]
set cy [expr {[lindex [lsort -integer $ys] 0] + $bbh / 2}]
check "the dial is centred in the box" \
    [expr {abs($cx - 200) < 30 && abs($cy - 100) < 20}] "centre $cx,$cy in 400x200"
check "the dial uses the box's height" [expr {$bbh > 120}] "dial $bbw x $bbh"

# The digits take most of the box. The rule is a function of the box, so it is
# checked as one: a live canvas in this harness has no geometry to draw into.
# It has to be there, and it has to scale: an item created without -text passes
# every size check while showing nothing.
::gameclock::setDisplay 1 analog
update
::gameclock::redraw 1
::gameclock::setDisplay 1 both
update
::gameclock::redraw 1
set inner {}
foreach it [.box.clock1 find all] {
    if {[.box.clock1 type $it] ne "text"} { continue }
    set t [.box.clock1 itemcget $it -text]
    if {[string first ":" $t] >= 0} { lappend inner $t }
}
check "the dial draws its own time" [expr {[llength $inner] == 1}] "items: $inner"

# ...and it sits midway between the hub and the numerals: the gap from it up to
# the centre equals the gap from it down to the 6, measured on the drawn boxes.
.box configure -width 420 -height 300
update
::gameclock::redraw 1
set inner_bb ""
set six_bb ""
foreach it [.box.clock1 find all] {
    if {[.box.clock1 type $it] ne "text"} { continue }
    set t [.box.clock1 itemcget $it -text]
    if {[string first ":" $t] >= 0} { set inner_bb [.box.clock1 bbox $it] }
    if {$t eq "6"} { set six_bb [.box.clock1 bbox $it] }
}
if {$inner_bb eq "" || $six_bb eq ""} {
    check "the dial's time and its 6 are both drawn" 0 "inner=$inner_bb six=$six_bb"
} else {
    lassign [::gameclock::sizeOf 1] cw ch
    set hub [expr {$ch / 2}]
    set gapUp [expr {[lindex $inner_bb 1] - $hub}]
    set gapDown [expr {[lindex $six_bb 1] - [lindex $inner_bb 3]}]
    check "the time sits midway between the hub and the numerals" \
        [expr {abs($gapUp - $gapDown) <= 3}] "up=$gapUp down=$gapDown"
}

##############################################################################
puts "\nthe arrangement is chosen by the type size it allows"
# Wide container: side by side allows the bigger dial. Tall: stacked. Square: the
# dial is the same either way, and a tie keeps the arrangement that is in force.
lassign [::sergame::clockLayout analog 1000 400] o w1
checkEq "a wide box puts the dials side by side" $o "side"
lassign [::sergame::clockLayout analog 400 900] o w2
checkEq "a tall box stacks them" $o "stacked"
lassign [::sergame::clockLayout analog 500 500] o w3
checkEq "a square box stacks them (a tie is not a reason to move)" $o "stacked"

# The dead band: from side by side, stacking must win by 4% before the layout moves.
lassign [::sergame::clockLayout analog 520 500 side] o w4
checkEq "a marginal win does not flip the arrangement" $o "side"
lassign [::sergame::clockLayout analog 300 900 side] o w5
checkEq "a clear win does" $o "stacked"
lassign [::sergame::clockLayout analog 900 300 stacked] o w6
checkEq "and back again, when side by side wins clearly" $o "side"

# The digits are rectangles, so the same box that suits a dial need not suit them:
# a wide short box is where the two modes disagree. 600x300, not 900x300: at 900
# the side-by-side cell is wide enough that the digits only just overrun it, so
# whether it shrinks below the stacked cell depends on the font the display maps
# "0:00:00" into. At 600 the side cell is width-limited and the stacked cell is
# height-limited, so the answer is the same on every font.
lassign [::sergame::clockLayout digital 600 300] d1 dsize
lassign [::sergame::clockLayout analog 600 300] a1 asize
# The two faces do not have to agree: the dials are limited by the cell's height,
# which a side-by-side cell keeps in full; the digits are seven glyphs wide, which
# a stacked cell keeps in full. The layout asks the face that is on screen.
checkEq "a wide box lays the dials side by side" $a1 "side"
checkEq "and asks the digits its own question" $d1 "stacked"
lassign [::sergame::clockLayout digital 700 700] d2 dsize2
checkEq "a tall box stacks the digits too" $d2 "stacked"
# The digits and the dial answer differently in the same box: seven glyphs need the
# width a side-by-side cell splits and a stacked cell keeps, so a 500x400 clock area
# stacks the digits where it keeps the dials side by side. This is the pair of
# answers the layout has to ask the right face for.
lassign [::sergame::clockLayout digital 500 400 side] dOri dSize
lassign [::sergame::clockLayout analog 500 400 side] aOri aSize
checkEq "the digits stack in a box the dials lay side by side" [list $dOri $aOri] [list stacked side]

# The type size a cell allows. For the digits it is the size the face is DRAWN at,
# not an estimate of it: the layout scores an arrangement by this number, and an
# estimate chose arrangements for a size that then never appeared on screen.
checkEq "the digital size the layout scores is the size the face draws" \
    [::sergame::faceTypeSize digital 400 200] [::gameclock::digitalTypeSize 1 400 200]
check "the digits are shrunk to the box's width, not merely estimated from an em" \
    [expr {[::gameclock::digitalTypeSize 1 400 200] < [::gameclock::digitalFont 400 200]}] \
    "drawn [::gameclock::digitalTypeSize 1 400 200] vs em bound [::gameclock::digitalFont 400 200]"
checkEq "a dial's numerals are a tenth of its smaller side" \
    [::sergame::faceTypeSize analog 400 200] 18
check "a bigger cell allows bigger digits" \
    [expr {[::sergame::faceTypeSize digital 400 200] > [::sergame::faceTypeSize digital 200 100]}]

checkEq "the dial's own time is a tenth of the dial" [::gameclock::innerFont 460] 50
checkEq "and shrinks with it" [::gameclock::innerFont 200] 22
check "but never below readable" [expr {[::gameclock::innerFont 40] >= 8}]
checkEq "a 400x200 box is width-limited" [::gameclock::digitalFont 400 200] 105
checkEq "a wide short box sets them from its height" [::gameclock::digitalFont 600 100] 62
checkEq "a narrow tall box sets them from its width" [::gameclock::digitalFont 120 400] 31
check "never smaller than readable" [expr {[::gameclock::digitalFont 20 20] >= 8}]

# Analog draws from the same size: the numerals sit inside a square of the box.
::gameclock::setDisplay 1 analog
.box configure -height 100
update
::gameclock::redraw 1
# Judge against the canvas's own size: the box has been resized several times by
# this point, and a constant would test the test.
lassign [::gameclock::sizeOf 1] bw bh
set ok 1
foreach it [.box.clock1 find all] {
    lassign [.box.clock1 bbox $it] x0 y0 x1 y1
    if {$x0 < 0 || $y0 < 0 || $x1 > $bw || $y1 > $bh} { set ok 0 }
}
check "an analog face draws inside the box it is given" [expr {$ok}]

# A numeral centred on the radius used to hang outside the canvas at 12 and 6; a
# tall box is where that shows.
.box configure -width 420 -height 300
::gameclock::setDisplay 1 analog
update
::gameclock::redraw 1
lassign [::gameclock::sizeOf 1] tw th
set out 0
foreach it [.box.clock1 find all] {
    if {[.box.clock1 type $it] ne "text"} { continue }
    lassign [.box.clock1 bbox $it] x0 y0 x1 y1
    if {$y0 < 0 || $y1 > $th || $x0 < 0 || $x1 > $tw} { set out 1 }
}
check "the dial's numerals stay inside a tall canvas" [expr {!$out}]

# And the digits are measured, not estimated: in a narrow box they shrink to fit
# instead of being clipped left and right.
.box configure -width 200 -height 300
::gameclock::setDisplay 1 digital
update
::gameclock::redraw 1
set txt [lindex [.box.clock1 find all] 0]
lassign [.box.clock1 bbox $txt] x0 y0 x1 y1
check "the digits fit a narrow canvas" [expr {$x0 >= 0 && $x1 <= 200}] "text ${x0}..${x1} in 200"

# The numerals take the face's own contrast colour: the black clock's were drawn
# black on black and could not be read at all.
::gameclock::setColor 1 white
::gameclock::setDisplay 1 analog
update
update
set fills {}
foreach it [.box.clock1 find all] {
    if {[.box.clock1 type $it] eq "text"} { lappend fills [.box.clock1 itemcget $it -fill] }
}
check "numerals on a white face are dark" \
    [expr {[llength $fills] > 0 && [lsearch -exact $fills black] >= 0}]
::gameclock::setColor 1 black
update
update
::gameclock::redraw 1
set fills {}
foreach it [.box.clock1 find all] {
    if {[.box.clock1 type $it] eq "text"} { lappend fills [.box.clock1 itemcget $it -fill] }
}
check "numerals on the black clock are light" \
    [expr {[llength $fills] > 0 && [lsearch -exact $fills white] >= 0}] \
    "fills: $fills"

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
