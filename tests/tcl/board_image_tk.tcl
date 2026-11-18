#!/usr/bin/env wish
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Saving the board as a PNG image:
#
#   xvfb-run -a wish tests/tcl/board_image_tk.tcl
#
# The image is composed from the board's own square and piece photos, so it
# must work without TkImg (libtk-img).  The checks cover a valid PNG of the
# expected size, solid-colour squares, both board orientations, the coordinate
# labels, the last-move arrow, the marks from the position's comment, the
# annotation and evaluation badges, and the automatic position-N.png
# numbering.

set fails 0
set checks 0
proc check {name cond {detail ""}} {
    global fails checks
    incr checks
    if {![uplevel 1 [list expr $cond]]} {
        incr fails
        if {$detail eq ""} { puts "FAIL $name" } else { puts "FAIL $name -- $detail" }
    } else { puts "ok   $name" }
}

# The stubs tcl/board.tcl's load-time InitBoard needs: a piece sheet set, board
# textures, the theme hook, a colour pair, and sc_pos for ::board::new.
namespace eval ::board {}
set root [file normalize [file join [file dirname [info script]] .. ..]]
set ::scidImgDir [file join $root img]
set ::boardStyles {Default}
set ::boardStyle Default
set ::boardSize 40
image create photo texLite -width 20 -height 20
image create photo texDark -width 20 -height 20
set ::boardfile_lite texLite
set ::boardfile_dark texDark
set ::borderwidth 5
set ::squareColor_lite "#ffffff"
set ::squareColor_dark "#888888"
set ::glossOfDanger 0
set ::arrowLastMove 0
set ::highlightLastMoveColor "#ff0000"
set ::highlightLastMoveNag 0
set ::highlightLastMoveEval 0
set ::START "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr"
set ::NAG ""
set ::MATE 0
set ::ATEND 0
set ::RESULT "*"
set ::MOVEUCI "e2e4"
set ::BOARD $::START
proc tr {s} { return $s }
proc ::applyThemeColor_background {args} {}
proc sc_pos {args} {
    switch -- [lindex $args 0] {
        getNags { return $::NAG }
        isMate  { return $::MATE }
        isAt    { return $::ATEND }
        attacks { return {} }
    }
    return $::BOARD
}
proc sc_game {args} {
    if {[lindex $args 0] eq "tag"} { return $::RESULT }
    if {[lindex $args 1] eq "previousMoveUCI"} { return $::MOVEUCI }
    return ""
}

source [file join $root tcl board.tcl]

set dir [file join [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] \
    "board_image_test_[pid]"]
catch {file delete -force $dir}
file mkdir $dir

::board::new .b 40

# A position with one piece on e1, so the orientation can be checked by
# looking at which square has more than its flat texture colour.
set board [string repeat . 64]
set board [string replace $board 4 4 k]
::board::update .b $board 0

set psize  [::board::imageSize 160]
set border $::board::_border(.b)
set poffset [expr {[image height $::board::letterToPiece(K)$psize] - $psize}]
set boardSize [expr {$psize * 8 + $border * 9}]
set scale [expr {max(2, $psize / 45)}]
set glyphW [expr {5 * $scale}]
set glyphH [expr {7 * $scale}]
set margin [expr {$glyphH + 14}]

# Sample a small grid inside one square.  A square with no piece is a single
# flat colour; a piece adds its own colours.
proc squareColours {img sq psize border poffset margin flip} {
    if {$flip} {
        set col [expr {7 - ($sq % 8)}]
        set row [expr {$sq / 8}]
    } else {
        set col [expr {$sq % 8}]
        set row [expr {7 - $sq / 8}]
    }
    set x [expr {$margin + $border + $col * ($psize + $border)}]
    set y [expr {$margin + $poffset + $border + $row * ($psize + $border)}]
    set step [expr {[expr {$psize / 8}] > 1 ? [expr {$psize / 8}] : 2}]
    set colours {}
    for {set dx 3} {$dx < $psize - 3} {incr dx $step} {
        for {set dy 3} {$dy < $psize - 3} {incr dy $step} {
            lappend colours [$img get [expr {$x + $dx}] [expr {$y + $dy}]]
        }
    }
    return [lsort -unique $colours]
}

proc rectColours {img x y w h} {
    set colours {}
    for {set dx 0} {$dx < $w} {incr dx} {
        for {set dy 0} {$dy < $h} {incr dy} {
            lappend colours [$img get [expr {$x + $dx}] [expr {$y + $dy}]]
        }
    }
    return [lsort -unique $colours]
}

proc readFile {path} {
    set fh [open $path r]
    set data [read $fh]
    close $fh
    return $data
}

puts "\nthe PNG itself"
set f [file join $dir "notflipped.png"]
check "saveImage returns the filename" [expr {[::board::saveImage .b $f] eq $f}]
check "the file exists" [file exists $f]
set fh [open $f rb]
set sig [read $fh 8]
close $fh
check "the file starts with the PNG signature" [expr {$sig eq "\x89PNG\r\n\x1a\n"}]
set png [image create photo -file $f]
check "the width includes the coordinate margins" \
    [expr {[image width $png] == $boardSize + 2 * $margin}] \
    "got [image width $png] want [expr {$boardSize + 2 * $margin}]"
check "the height includes the margins and piece headroom" \
    [expr {[image height $png] == $boardSize + $poffset + 2 * $margin}] \
    "got [image height $png] want [expr {$boardSize + $poffset + 2 * $margin}]"

puts "\nthe squares"
# The test textures are empty, as they are on a solid-colour board: the fill
# underneath the transparent texture must still show the two square colours.
set d1 [squareColours $png 3 $psize $border $poffset $margin 0]
set c1 [squareColours $png 2 $psize $border $poffset $margin 0]
check "an empty square is flat" [expr {[llength $d1] == 1}] "d1=$d1"
check "light and dark squares differ" \
    [expr {[lindex $d1 0] ne [lindex $c1 0]}] "d1=$d1 c1=$c1"

puts "\nthe coordinates"
set fileX [expr {$margin + $border + 3 * ($psize + $border) + ($psize - $glyphW) / 2}]
set fileY [expr {$margin + $poffset + $boardSize + ($margin - $glyphH) / 2}]
set fileColours [rectColours $png $fileX $fileY $glyphW $glyphH]
check "the file letters are in the bottom margin" \
    [expr {[llength $fileColours] > 1}] "colours=$fileColours"
set rankX [expr {($margin - $glyphW) / 2}]
set rankY [expr {$margin + $poffset + $border + 6 * ($psize + $border) +
                 ($psize - $glyphH) / 2}]
set rankColours [rectColours $png $rankX $rankY $glyphW $glyphH]
check "the rank numbers are in the left margin" \
    [expr {[llength $rankColours] > 1}] "colours=$rankColours"

set fNo [file join $dir "nocoords.png"]
::board::saveImage .b $fNo $psize 0
set pngNo [image create photo -file $fNo]
check "coordinates can be turned off" \
    [expr {[image width $pngNo] == $boardSize}] \
    "got [image width $pngNo] want $boardSize"
image delete $pngNo

puts "\nthe last-move arrow"
set ::arrowLastMove 1
set fArrow [file join $dir "arrow.png"]
::board::saveImage .b $fArrow
set pngArrow [image create photo -file $fArrow]
# e2 and e4 are both on the e-file, so the arrow is vertical and its shaft
# crosses the midpoint between their centres.
set e2x [expr {$margin + $border + 4 * ($psize + $border) + $psize / 2}]
set e2y [expr {$margin + $poffset + $border + 6 * ($psize + $border) + $psize / 2}]
set e4y [expr {$margin + $poffset + $border + 4 * ($psize + $border) + $psize / 2}]
set midY [expr {($e2y + $e4y) / 2}]
set arrowColours [rectColours $pngArrow [expr {$e2x - 3}] [expr {$midY - 3}] 6 6]
check "the last-move arrow follows the preference" \
    [expr {[lsearch -exact $arrowColours "255 0 0"] >= 0}] \
    "colours=$arrowColours"
# e4 is above e2, so the arrow points up and its tip is just below the e4
# centre.  The shaft must stop at the head, not poke out above the point.
set tipY [expr {int($e4y + 0.05 * $psize)}]
set aboveColours [rectColours $pngArrow [expr {$e2x - 2}] [expr {$tipY - 8}] 5 6]
check "the shaft does not extend past the arrow point" \
    [expr {[lsearch -exact $aboveColours "255 0 0"] < 0}] \
    "colours=$aboveColours"
image delete $pngArrow
set ::arrowLastMove 0

# Top-left corner of a square in the exported image, for the unflipped board.
proc sqOrigin {sq psize border poffset margin} {
    set col [expr {$sq % 8}]
    set row [expr {7 - $sq / 8}]
    return [list [expr {$margin + $border + $col * ($psize + $border)}] \
                 [expr {$margin + $poffset + $border + $row * ($psize + $border)}]]
}

puts "\nthe marks recorded in the comment"
::board::setmarks .b {
    [%csl Rd4] [%draw full,e5,blue] [%cal Yb1b8] [%draw disk,f2,green]
    [%draw square,c3,orange] [%draw circle,f7,cyan] [%draw X,d5,cyan]
    [%draw arrow,a3,a7,red]
}
::board::showMarks .b 1
set fMarks [file join $dir "marks.png"]
::board::saveImage .b $fMarks
set pngM [image create photo -file $fMarks]

# A full mark paints the whole square, and the square texture is not laid
# over it.
lassign [sqOrigin 36 $psize $border $poffset $margin] x y
set fill [rectColours $pngM [expr {$x + 4}] [expr {$y + 4}] \
    [expr {$psize - 8}] [expr {$psize - 8}]]
check "a full-square mark paints its square" \
    [expr {[llength $fill] == 1 && [lindex $fill 0] eq "0 0 255"}] \
    "colours=$fill"

# A %csl square is the rounded outline the board draws, inset from the edge.
lassign [sqOrigin 27 $psize $border $poffset $margin] x y
set inset [expr {int($psize * 0.03)}]
set cols [rectColours $pngM [expr {$x + $inset - 2}] [expr {$y + $psize / 4}] \
    5 [expr {$psize / 2}]]
check "a csl square rings its square" \
    [expr {[lsearch -exact $cols "255 0 0"] >= 0}] "colours=$cols"

# A %cal arrow runs from the middle of one square to the other.
lassign [sqOrigin 1 $psize $border $poffset $margin] ax ay
lassign [sqOrigin 57 $psize $border $poffset $margin] hx hy
set midX [expr {$ax + $psize / 2}]
set midY [expr {($ay + $hy) / 2 + $psize / 2}]
set cols [rectColours $pngM [expr {$midX - 3}] [expr {$midY - 3}] 6 6]
check "a csl arrow is drawn" \
    [expr {[lsearch -exact $cols "255 255 0"] >= 0}] "colours=$cols"

lassign [sqOrigin 13 $psize $border $poffset $margin] x y
set cols [rectColours $pngM [expr {$x + $psize / 2 - 3}] \
    [expr {$y + $psize / 2 - 3}] 6 6]
check "a disk fills its square" \
    [expr {[lsearch -exact $cols "0 128 0"] >= 0}] "colours=$cols"

lassign [sqOrigin 53 $psize $border $poffset $margin] x y
set cols [rectColours $pngM [expr {$x + $psize / 2 - 2}] \
    [expr {$y + $psize / 2 - int($psize * 0.47)}] 5 5]
check "a circle rings its square" \
    [expr {[lsearch -exact $cols "0 255 255"] >= 0}] "colours=$cols"

lassign [sqOrigin 18 $psize $border $poffset $margin] x y
set cols [rectColours $pngM [expr {$x + $inset - 2}] [expr {$y + $psize / 4}] \
    5 [expr {$psize / 2}]]
check "a square mark rings its square" \
    [expr {[lsearch -exact $cols "255 165 0"] >= 0}] "colours=$cols"

# A text mark is the single character the comment names.
lassign [sqOrigin 35 $psize $border $poffset $margin] x y
set cols [rectColours $pngM [expr {$x + $psize / 4}] [expr {$y + $psize / 4}] \
    [expr {$psize / 2}] [expr {$psize / 2}]]
check "a text mark draws its character" \
    [expr {[lsearch -exact $cols "0 255 255"] >= 0}] "colours=$cols"

# The old [%draw arrow,from,to,color] syntax is an arrow too.
lassign [sqOrigin 16 $psize $border $poffset $margin] ax ay
lassign [sqOrigin 48 $psize $border $poffset $margin] hx hy
set midX [expr {$ax + $psize / 2}]
set midY [expr {($ay + $hy) / 2 + $psize / 2}]
set cols [rectColours $pngM [expr {$midX - 3}] [expr {$midY - 3}] 6 6]
check "a draw arrow is drawn with the arrow colour" \
    [expr {[lsearch -exact $cols "255 0 0"] >= 0}] "colours=$cols"

# Show Marks off hides all of them, as it does on the board.
::board::showMarks .b 0
set fHidden [file join $dir "marks-hidden.png"]
::board::saveImage .b $fHidden
set pngH [image create photo -file $fHidden]
lassign [sqOrigin 36 $psize $border $poffset $margin] x y
check "Show Marks off leaves the square plain" \
    [expr {[lsearch -exact [rectColours $pngH $x $y $psize $psize] "0 0 255"] < 0}]
::board::showMarks .b 1
image delete $pngM $pngH

puts "\nthe annotation and evaluation badges"
foreach c {! ? + - = / # 0 1 2 3 4 5 6 7 8 9} {
    check "the badge font has '$c'" [expr {[llength [::board::_glyph $c]] == 7}]
}

# e2-e4 is the last move, its NAG carries both badge kinds, and e4's top
# corners are where the board puts them.
set ::NAG "!? +-"
set ::MOVEUCI "e2e4"
set ::highlightLastMoveNag 1
set ::highlightLastMoveEval 1
set fBadge [file join $dir "badges.png"]
::board::saveImage .b $fBadge
set pngB [image create photo -file $fBadge]
lassign [sqOrigin 28 $psize $border $poffset $margin] x y
set annotation [rectColours $pngB [expr {$x + $psize - 20}] \
    [expr {$y - 20}] 40 40]
check "the annotation badge is at the top right" \
    [expr {[lsearch -exact $annotation "48 192 48"] >= 0}] "colours=$annotation"
set evaluation [rectColours $pngB [expr {$x - 20}] [expr {$y - 20}] 40 40]
check "the evaluation badge is at the top left" \
    [expr {[lsearch -exact $evaluation "32 112 32"] >= 0}] "colours=$evaluation"

set ::highlightLastMoveNag 0
set fEval [file join $dir "eval-only.png"]
::board::saveImage .b $fEval
set pngE [image create photo -file $fEval]
set annotation [rectColours $pngE [expr {$x + $psize - 20}] [expr {$y - 20}] 40 40]
check "the annotation badge follows its preference" \
    [expr {[lsearch -exact $annotation "48 192 48"] < 0}] "colours=$annotation"
set evaluation [rectColours $pngE [expr {$x - 20}] [expr {$y - 20}] 40 40]
check "the evaluation badge stays on" \
    [expr {[lsearch -exact $evaluation "32 112 32"] >= 0}] "colours=$evaluation"

# A badge on the top rank is pushed down into the board.
set ::highlightLastMoveNag 1
set ::MOVEUCI "g7h8"
set ::NAG "?!"
set fEdge [file join $dir "edge-badge.png"]
::board::saveImage .b $fEdge
set pngEdge [image create photo -file $fEdge]
lassign [sqOrigin 63 $psize $border $poffset $margin] x y
set badge [rectColours $pngEdge [expr {$x + $psize - 15}] \
    [expr {$y + $psize / 5 - 15}] 30 30]
check "a badge on the top rank moves down" \
    [expr {[lsearch -exact $badge "255 48 48"] >= 0}] "colours=$badge"
image delete $pngB $pngE $pngEdge

puts "\nthe game result beside the kings"
set resBoard [string repeat . 64]
set resBoard [string replace $resBoard 4 4 K]
set resBoard [string replace $resBoard 60 60 k]
set ::BOARD "$resBoard w"
::board::update .b "$resBoard w" 0
set ::MATE 1
set ::RESULT "1-0"
set ::NAG ""
set ::MOVEUCI "e2e4"
set fResult [file join $dir "result.png"]
::board::saveImage .b $fResult
set pngR [image create photo -file $fResult]
lassign [sqOrigin 4 $psize $border $poffset $margin] x y
set white [rectColours $pngR [expr {$x + $psize - 25}] [expr {$y - 25}] 50 50]
check "the winner's badge is beside its king" \
    [expr {[lsearch -exact $white "208 208 208"] >= 0}] "colours=$white"
set glyph [rectColours $pngR [expr {$x + $psize - 8}] [expr {$y - 8}] 16 16]
check "the winner's badge carries a symbol" \
    [expr {[lsearch -exact $glyph "48 48 48"] >= 0}] "colours=$glyph"
lassign [sqOrigin 60 $psize $border $poffset $margin] x y
set black [rectColours $pngR [expr {$x + $psize - 25}] \
    [expr {$y - 25 + $psize / 5}] 50 50]
check "the loser's badge is beside its king" \
    [expr {[lsearch -exact $black "48 48 48"] >= 0}] "colours=$black"
set glyph [rectColours $pngR [expr {$x + $psize - 8}] \
    [expr {$y + $psize / 5 - 8}] 16 16]
check "the loser's badge carries a symbol" \
    [expr {[lsearch -exact $glyph "208 208 208"] >= 0}] "colours=$glyph"

# A drawn game shows a half beside each king, drawn as 1/2 because the
# bitmap font has no half glyph.
set ::MATE 0
set ::ATEND 1
set ::RESULT "="
set fDraw [file join $dir "draw.png"]
::board::saveImage .b $fDraw
set pngD [image create photo -file $fDraw]
lassign [sqOrigin 4 $psize $border $poffset $margin] x y
set glyph [rectColours $pngD [expr {$x + $psize - 12}] [expr {$y - 12}] 24 24]
check "a drawn game draws its half" \
    [expr {[lsearch -exact $glyph "48 48 48"] >= 0}] "colours=$glyph"
image delete $pngR $pngD
set ::ATEND 0

# Leave the board as the following checks expect it.
set ::MATE 0
set ::RESULT "*"
set ::NAG ""
set ::MOVEUCI "e2e4"
set ::highlightLastMoveNag 0
set ::highlightLastMoveEval 0
::board::setmarks .b {}
::board::update .b $board 0

puts "\nthe orientation"
# Not flipped: e1 (square 4) is bottom-left; d1 (square 3) is empty.
check "white starts at the bottom" \
    [expr {[llength [squareColours $png 4 $psize $border $poffset $margin 0]] > 1}] \
    "e1 should hold the black king"

::board::flip .b
set f2 [file join $dir "flipped.png"]
::board::saveImage .b $f2
set png2 [image create photo -file $f2]
check "flipping moves e1 to the top" \
    [expr {[llength [squareColours $png2 4 $psize $border $poffset $margin 1]] > 1}] \
    "e1 should still hold the black king"
check "flipping leaves an empty square flat" \
    [expr {[llength [squareColours $png2 3 $psize $border $poffset $margin 1]] == 1}] \
    "d1 should be empty after the flip"
image delete $png $png2

puts "\nautomatic numbering"
set ndir [file join $dir "numbers"]
file mkdir $ndir
foreach n {1 2 4} {
    close [open [file join $ndir "position-$n.png"] w]
}
foreach name {other-99.png position-x.png position-10.PNG position-08.png} {
    close [open [file join $ndir $name] w]
}
check "the next free number is used" \
    [expr {[file tail [::board::nextImageFile $ndir]] eq "position-11.png"}] \
    "got [file tail [::board::nextImageFile $ndir]]"
check "a different prefix is independent" \
    [expr {[file tail [::board::nextImageFile $ndir "diagram"]] eq "diagram-1.png"}]
check "an empty directory starts at one" \
    [expr {[file tail [::board::nextImageFile [file join $dir "fresh"]]] eq "position-1.png"}]

set odir [file join $dir "octal"]
file mkdir $odir
close [open [file join $odir "position-010.png"] w]
check "a leading-zero suffix is decimal" \
    [expr {[file tail [::board::nextImageFile $odir]] eq "position-11.png"}] \
    "got [file tail [::board::nextImageFile $odir]]"
set pdir [file join $dir "padded"]
file mkdir $pdir
close [open [file join $pdir "position-08.png"] w]
check "an invalid-octal-looking suffix does not stop the dialog" \
    [expr {[file tail [::board::nextImageFile $pdir]] eq "position-9.png"}] \
    "got [file tail [::board::nextImageFile $pdir]]"

puts "\nthe save dialog helper"
set ::dialogDir [file join $dir "dialog"]
file mkdir $::dialogDir
set ::dialogArgs {}
proc tk_getSaveFile {args} {
    set ::dialogArgs $args
    return [file join $::dialogDir "typed.jpg"]
}
set ::initialDir(image) $::dialogDir
set saved [::board::saveImageDialog .b]
check "a typed image extension becomes .png" \
    [expr {[file extension $saved] eq ".png"}] "got $saved"
check "the dialog file was written" [expr {[file exists $saved]}]
check "the dialog offers the next number" \
    [expr {[lindex $::dialogArgs [expr {[lsearch -exact $::dialogArgs "-initialfile"] + 1}]] eq "position-1.png"}] \
    "args=$::dialogArgs"
check "the chosen directory is remembered" \
    [expr {$::initialDir(image) eq $::dialogDir}]

# A typed extension is normalized before the file is written.  Tk confirmed
# the typed name, not the normalized one, so the normalized destination needs
# its own confirmation when it already exists.
set existing [file join $::dialogDir "existing.png"]
set fh [open $existing w]
puts -nonewline $fh "old"
close $fh
proc tk_getSaveFile {args} { return [file join $::dialogDir "existing.jpg"] }
set ::overwriteAsked 0
proc tk_messageBox {args} { incr ::overwriteAsked; return "no" }
set result [::board::saveImageDialog .b]
check "an existing normalized destination is confirmed" \
    [expr {$::overwriteAsked == 1}]
check "cancelling the overwrite writes nothing" \
    [expr {$result eq "" && [readFile $existing] eq "old"}] \
    "result='$result' content='[readFile $existing]'"
proc tk_messageBox {args} { return "yes" }
set result [::board::saveImageDialog .b]
check "confirming the overwrite saves the image" \
    [expr {$result eq $existing && [file size $existing] > 10}] \
    "result='$result' size='[file size $existing]'"

proc tk_getSaveFile {args} { return "" }
check "cancel saves nothing" [expr {[::board::saveImageDialog .b] eq ""}]

file delete -force $dir
puts "\n$checks checks, $fails failures"
exit [expr {$fails > 0}]
