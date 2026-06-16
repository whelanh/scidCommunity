# board3d.tcl: part of Scid
# Copyright (C) 2021-2026
#
# 3D perspective board renderer using software projection onto a Tk canvas.
# Uses existing 2D piece sprites (e.g. Eboard) as images placed at
# perspective-projected positions. No external dependencies.

namespace eval ::board3d {
  namespace export new update flip orbit zoom reset resize

  # Precomputed 3D coordinates for each square (0-63)
  variable _square3d
  # Ordered square indices from far to near for depth sorting
  variable _depthOrder

  # Per-board state
  variable _camera    ;# dict per board: azim elev radius focal viewW viewH
  variable _data      ;# board position string per board
  variable _size      ;# piece image size per board
  variable _flip      ;# flip state per board
  variable _marks     ;# marks per board
  variable _showMarks ;# show marks flag per board

  # Initialise the 3D square coordinates and depth ordering
  for {set sq 0} {$sq < 64} {incr sq} {
    set col [expr {$sq % 8}]
    set row [expr {$sq / 8}]
    set x [expr {$col - 3.5}]
    set y [expr {$row - 3.5}]
    # Square corners: bottom-left, bottom-right, top-right, top-left
    set h 0.5
    lappend ::board3d::_square3d($sq) \
        [list [expr {$x-$h}] [expr {$y-$h}] 0] \
        [list [expr {$x+$h}] [expr {$y-$h}] 0] \
        [list [expr {$x+$h}] [expr {$y+$h}] 0] \
        [list [expr {$x-$h}] [expr {$y+$h}] 0]
    # Square center for piece placement:
    lappend ::board3d::_square3d($sq) [list $x $y 0]
  }

  # Depth order: far to near. Camera behind white means white (row 0) is near, black (row 7) is far.
  # So draw row 7 first, row 6 next, ..., row 0 last.
  for {set row 7} {$row >= 0} {incr row -1} {
    for {set col 0} {$col < 8} {incr col} {
      lappend ::board3d::_depthOrder [expr {$row * 8 + $col}]
    }
  }
}

# ::board3d::new --
#   Creates a new 3D board widget within the given frame.
#   w      - parent widget path
#   psize  - piece size (defaults to $::boardSize)
#
proc ::board3d::new {w {psize 40}} {
  if {[winfo exists $w]} { return }

  foreach size $::boardSizes {
    if {$size >= $psize} { break }
  }
  if {![info exists size] || $size == ""} { set size $psize }
  set psize $size

  set ::board3d::_size($w) $psize
  set ::board3d::_flip($w) 0
  set ::board3d::_showMarks($w) 0
  set ::board3d::_marks($w) {}
  set ::board3d::_data($w) [sc_pos board]

  # Default camera: behind white (azim=pi), 30 degree elevation, distance 10
  # viewW/viewH are canvas dimensions; focal controls zoom
  set cw 1040
  set ch 1040
  set azimVal [expr {atan2(0.0, -1.0)}]
  set ::board3d::_camera($w) [dict create azim $azimVal elev 0.733 radius 10.0 focal [expr {$cw * 0.8}] viewW $cw viewH $ch]

  ttk::frame $w -class Board3D
  canvas $w.bd -cursor hand1 \
      -borderwidth 0 -highlightthickness 0 \
      -background #3e4540
  ::applyThemeColor_background $w.bd
  pack $w.bd -expand 1 -fill both

  $w.bd create rectangle -100 -100 0 0 -tag bg -fill #3e4540 -outline ""

  ::board3d::redraw3d $w

  # Mouse bindings:
  # Left-drag on empty area: orbit camera
  # Left-drag on piece: move piece
  # Right-click: identify square
  # Scroll: zoom
  bind $w.bd <ButtonPress-1>   [list ::board3d::_startClick $w %x %y]
  bind $w.bd <B1-Motion>       [list ::board3d::_dragMotion $w %x %y]
  bind $w.bd <ButtonRelease-1> [list ::board3d::_endClick $w %x %y]
  bind $w.bd <MouseWheel>      { ::board3d::_onWheel %W %D }
  bind $w.bd <Button-4>        [list ::board3d::zoom $w  0.3]
  bind $w.bd <Button-5>        [list ::board3d::zoom $w -0.3]
  bind $w.bd <KeyPress-r>      [list ::board3d::reset $w]
  bind $w.bd <KeyPress-f>      [list ::board3d::flip $w]
  bind $w.bd <ButtonPress-3>   [list ::board3d::_clickSquare $w %x %y]

  return $w
}

# ::board3d::update --
#   Updates the board display with new position data.
#
proc ::board3d::update {w {board ""} args} {
  if {![winfo exists $w]} { return }
  if {$board eq ""} {
    set board $::board3d::_data($w)
  } else {
    set ::board3d::_data($w) $board
  }
  ::board3d::redraw3d $w
}

# ::board3d::redraw3d --
#   Recomputes all 3D projections and redraws the entire board.
#
proc ::board3d::redraw3d {w} {
  if {![winfo exists $w]} { return }

  set bd $w.bd
  set cam $::board3d::_camera($w)
  set flip $::board3d::_flip($w)
  set board $::board3d::_data($w)
  set psize $::board3d::_size($w)

  # Adjust depth ordering and azimuth for flip
  if {$flip} {
    set azim [expr {[dict get $cam azim] + 3.1415926535}]
    set cam [dict replace $cam azim $azim]
  }

  # --- Compute projected 2D positions for all 64 squares ---
  # For each square, project both corners and midpoint.
  set projCorners {}    ;# list of {sq cornerlist}
  set projCenters {}    ;# list of {sq cx cy}
  set depths {}         ;# list of {sq depth} for sorting

  for {set sq 0} {$sq < 64} {incr sq} {
    set corners {}
    foreach pt [lrange $::board3d::_square3d($sq) 0 3] {
      lassign $pt px py pz
      lassign [::board3d::_project $cam $px $py $pz] sx sy
      lappend corners $sx $sy
    }
    lappend projCorners $corners

    # Project center point for piece placement
    lassign [lindex $::board3d::_square3d($sq) 4] cx cy cz
    lassign [::board3d::_project $cam $cx $cy $cz] scx scy
    lappend projCenters [list $scx $scy]

    # Compute depth (camera-space Z) for depth sorting
    lassign [lindex $::board3d::_square3d($sq) 4] cx cy cz
    set depth [::board3d::_depth $cam $cx $cy $cz]
    lappend depths $depth
  }

  # --- Determine drawing order ---
  # Sort squares by depth: FAR squares first (drawn behind), NEAR squares last (on top)
  set drawOrder {}
  for {set sq 0} {$sq < 64} {incr sq} {
    lappend drawOrder $sq
  }
  set drawOrder [lsort -integer -decreasing -index 0 \
      [lmap sq $drawOrder dep $depths { list [expr {int($dep * 1000)}] $sq }]]
  set drawOrder [lmap pair $drawOrder { lindex $pair 1 }]

  # --- Compute apparent square size for piece sizing ---
  # Use the diagonal of the nearest square to estimate a good size scale
  set nearSq [lindex $drawOrder end]
  set nearCorners [lindex $projCorners $nearSq]
  lassign $nearCorners nx0 ny0 nx1 ny1 nx2 ny2 nx3 ny3
  set nearDiag [expr {sqrt(($nx2-$nx0)*($nx2-$nx0) + ($ny2-$ny0)*($ny2-$ny0))}]
  # Pick a "base" piece size from mid-board, not the near edge
  set midSq 27;  # d4, near center
  set midCorners [lindex $projCorners $midSq]
  lassign $midCorners mx0 my0 mx1 my1 mx2 my2 mx3 my3
  set midDiag [expr {sqrt(($mx2-$mx0)*($mx2-$mx0) + ($my2-$my0)*($my2-$my0))}]
  set baseSize 0
  foreach s $::boardSizes {
    if {$s <= $midDiag && $s > $baseSize} { set baseSize $s }
  }
  if {$baseSize == 0} { set baseSize [lindex $::boardSizes end] }

  # --- Draw ---
  $bd delete board3d

  # Draw background
  set cw [dict get $cam viewW]
  set ch [dict get $cam viewH]
  $bd coords bg -100 -100 [expr {$cw + 100}] [expr {$ch + 100}]

  # Draw board squares
  foreach sq $drawOrder {
    set corners [lindex $projCorners $sq]
    if {[lindex $corners 0] < -10000} { continue }

    # Determine color
    set isLight [expr {($sq + ($sq / 8)) % 2}]
    if {$flip} { set isLight [expr {!$isLight}] }
    if {$isLight} {
      set color $::squareColor_lite
    } else {
      set color $::squareColor_dark
    }

    $bd create polygon {*}$corners -fill $color -outline "" -tag board3d
  }

  # Draw pieces — size each piece to its own projected square
  foreach sq $drawOrder {
    set piece [string index $board $sq]
    if {$piece eq "."} { continue }

    lassign [lindex $projCenters $sq] cx cy
    if {$cx < -10000} { continue }

    # Compute piece size from this square's projected width
    set corners [lindex $projCorners $sq]
    lassign $corners sx0 sy0 sx1 sy1 sx2 sy2 sx3 sy3
    set sqW [expr {abs($sx1 - $sx0) * 0.85}]
    set pieceSize 0
    foreach s $::boardSizes {
      if {$s <= $sqW && $s > $pieceSize} { set pieceSize $s }
    }
    if {$pieceSize == 0} { set pieceSize [lindex $::boardSizes end] }

    # Row-progressive y-shift: far pieces need to be pushed back into their
    # squares to compensate for perspective foreshortening.
    # Row 0 (nearest): 0%, row 1: 5%, ..., row 7: 35% of square height.
    set row [expr {$sq / 8}]
    if {$flip} { set row [expr {7 - $row}] }
    set sqH [expr {abs($sy3 - $sy0)}]
    set shift [expr {$row * 0.05 * $sqH}]
    set cy [expr {$cy - $shift}]

    set pieceImg $::board::letterToPiece($piece)$pieceSize
    set tags [list board3d p$sq]
    if {[catch { $bd create image $cx $cy -image $pieceImg -tag $tags -anchor c }]} {
      foreach s $::boardSizes {
        set pieceImg $::board::letterToPiece($piece)$s
        if {![catch {image width $pieceImg}]} {
          $bd create image $cx $cy -image $pieceImg -tag $tags -anchor c
          break
        }
      }
    }
  }

  # Draw last move highlight
  ::board3d::_drawLastMoveHighlight $w $projCorners $projCenters

  # Draw marks and arrows
  if {$::board3d::_showMarks($w)} {
    ::board3d::_drawMarks $w $projCorners $projCenters $drawOrder
  }
}

# ::board3d::flip --
#   Flips the 3D board 180 degrees.
#
proc ::board3d::flip {w} {
  if {![info exists ::board3d::_flip($w)]} { return }
  set ::board3d::_flip($w) [expr {1 - $::board3d::_flip($w)}]
  ::board3d::redraw3d $w
}

# ::board3d::orbit --
#   Orbits the camera by (dazim, delev) in radians.
#
proc ::board3d::orbit {w dazim delev} {
  set cam $::board3d::_camera($w)
  set azim [expr {[dict get $cam azim] + $dazim}]
  set elev [expr {[dict get $cam elev] + $delev}]
  # Clamp elevation
  set maxElev 1.4
  if {$elev > $maxElev}  { set elev $maxElev }
  if {$elev < 0.05}      { set elev 0.05 }
  dict set cam azim $azim
  dict set cam elev $elev
  set ::board3d::_camera($w) $cam
  ::board3d::redraw3d $w
}

# ::board3d::_onWheel --
#   Mousewheel handler. %W is the canvas; strip .bd to get the board frame.
#   %D is the raw delta (typically ±120 per click), scaled down.
#
proc ::board3d::_onWheel {canvasPath rawDelta} {
  set w [string range $canvasPath 0 end-3]
  set delta [expr {$rawDelta / 40.0}]
  ::board3d::zoom $w $delta
}

# ::board3d::zoom --
#   Zooms the camera in/out.
#
proc ::board3d::zoom {w delta} {
  set cam $::board3d::_camera($w)
  set radius [expr {[dict get $cam radius] - $delta * 0.5}]
  if {$radius < 4}  { set radius 4 }
  if {$radius > 30} { set radius 30 }
  dict set cam radius $radius
  set ::board3d::_camera($w) $cam
  ::board3d::redraw3d $w
}

# ::board3d::reset --
#   Resets the camera to the default position.
#
proc ::board3d::reset {w} {
  set cw [dict get $::board3d::_camera($w) viewW]
  set ch [dict get $::board3d::_camera($w) viewH]
  set azimVal [expr {atan2(0.0, -1.0)}]
  set ::board3d::_camera($w) [dict create azim $azimVal elev 0.733 radius 10.0 focal [expr {$cw * 0.8}] viewW $cw viewH $ch]
  ::board3d::redraw3d $w
}

# ::board3d::resize --
#   Resizes the 3D board canvas.
#
proc ::board3d::resize {w neww newh} {
  set cam $::board3d::_camera($w)
  if {$neww < 200} { set neww 200 }
  if {$newh < 200} { set newh 200 }
  dict set cam viewW $neww
  dict set cam viewH $newh
  dict set cam focal [expr {$neww * 0.8}]
  set ::board3d::_camera($w) $cam
  ::board3d::redraw3d $w
}

# ::board3d::showMarks --
#   Turns marks display on/off.
#
proc ::board3d::showMarks {w value} {
  set ::board3d::_showMarks($w) $value
}

# ::board3d::setmarks --
#   Sets marks from embedded commands.
#
proc ::board3d::setmarks {w cmds} {
  set ::board3d::_marks($w) {}
  if {$cmds eq ""} { return }
  set ::board3d::_marks($w) [lmap elem [::board::mark::getEmbeddedCmds $cmds] {
    lassign $elem type arg1 arg2 color
    switch -glob $type {
      ""     {set type [expr {[string length $arg2] ? "arrow" : "circle"}]}
      "mark" {set type "full"}
      ?      {set arg2 $type ; set type "text"}
    }
    set arg1 [::board::sq $arg1]
    set sq2 [::board::sq $arg2]
    if {$sq2 != -1} { set arg2 $sq2 }
    switch -nocase $color {
      "" - "R" {set color "#ff3030"}
      "G"      {set color "#30c030"}
      "Y"      {set color "#ffff30"}
      "B"      {set color "#3030ff"}
      "O"      {set color "#ff8030"}
      "C"      {set color "#30ffff"}
    }
    list $type $arg1 $arg2 $color
  }]
}

# ----------------------------------------------------------------------
# Internal: Camera projection
# ----------------------------------------------------------------------

# ::board3d::_project --
#   Projects a 3D point to 2D screen coordinates using perspective.
#   Returns {screenX screenY} or {-10000 -10000} if behind camera.
#
proc ::board3d::_project {cam px py pz} {
  set azim  [dict get $cam azim]
  set elev  [dict get $cam elev]
  set radius [dict get $cam radius]
  set focal [dict get $cam focal]
  set cw    [dict get $cam viewW]
  set ch    [dict get $cam viewH]

  # Camera position in world space
  set cosE [expr {cos($elev)}]
  set sinE [expr {sin($elev)}]
  set cosA [expr {cos($azim)}]
  set sinA [expr {sin($azim)}]
  set camX [expr {$radius * $cosE * $sinA}]
  set camY [expr {$radius * $cosE * $cosA}]
  set camZ [expr {$radius * $sinE}]

  # Forward vector (target - camera, normalized)
  set fX [expr {-$camX}]
  set fY [expr {-$camY}]
  set fZ [expr {-$camZ}]
  set fLen [expr {sqrt($fX*$fX + $fY*$fY + $fZ*$fZ)}]
  if {$fLen < 0.0001} { return {-10000 -10000} }
  set fX [expr {$fX / $fLen}]
  set fY [expr {$fY / $fLen}]
  set fZ [expr {$fZ / $fLen}]

  # Right vector: cross(worldUp, forward)
  # worldUp = (0,0,1) unless forward is parallel to it
  set rX [expr {$fY}]
  set rY [expr {-$fX}]
  set rZ 0.0
  set rLen [expr {sqrt($rX*$rX + $rY*$rY)}]
  if {$rLen < 0.0001} {
    set rX 1.0; set rY 0.0; set rZ 0.0
  } else {
    set rX [expr {$rX / $rLen}]
    set rY [expr {$rY / $rLen}]
  }

  # Up' vector: cross(right, forward)
  set uX [expr {$rY*$fZ - 0*$fY}]
  set uY [expr {0*$fX - $rX*$fZ}]
  set uZ [expr {$rX*$fY - $rY*$fX}]

  # Transform point to camera space
  set dx [expr {$px - $camX}]
  set dy [expr {$py - $camY}]
  set dz [expr {$pz - $camZ}]
  set cx [expr {$dx*$rX + $dy*$rY + $dz*0}]
  set cy [expr {$dx*$uX + $dy*$uY + $dz*$uZ}]
  set cz [expr {$dx*$fX + $dy*$fY + $dz*$fZ}]

  # Perspective divide
  if {$cz <= 0.001} {
    return {-10000 -10000}
  }
  set sx [expr {$focal * $cx / $cz}]
  set sy [expr {$focal * $cy / $cz}]

  # Screen coordinates
  set screenX [expr {$cw / 2.0 + $sx}]
  set screenY [expr {$ch / 2.0 - $sy}]

  return [list $screenX $screenY]
}

# ::board3d::_depth --
#   Returns the camera-space Z of a point (for depth sorting).
#
proc ::board3d::_depth {cam px py pz} {
  set azim  [dict get $cam azim]
  set elev  [dict get $cam elev]
  set radius [dict get $cam radius]
  set cosE [expr {cos($elev)}]
  set sinE [expr {sin($elev)}]
  set cosA [expr {cos($azim)}]
  set sinA [expr {sin($azim)}]
  set camX [expr {$radius * $cosE * $sinA}]
  set camY [expr {$radius * $cosE * $cosA}]
  set camZ [expr {$radius * $sinE}]

  set dx [expr {$px - $camX}]
  set dy [expr {$py - $camY}]
  set dz [expr {$pz - $camZ}]

  set fX [expr {-$camX}]
  set fY [expr {-$camY}]
  set fZ [expr {-$camZ}]
  set fLen [expr {sqrt($fX*$fX + $fY*$fY + $fZ*$fZ)}]
  if {$fLen < 0.0001} { return 0 }
  set fX [expr {$fX / $fLen}]
  set fY [expr {$fY / $fLen}]
  set fZ [expr {$fZ / $fLen}]

  return [expr {$dx*$fX + $dy*$fY + $dz*$fZ}]
}

# ----------------------------------------------------------------------
# Internal: Mouse interaction
# ----------------------------------------------------------------------

# ::board3d::_findSquare --
#   Returns the square number (0-63) at screen coordinates (x, y), or -1.
#
proc ::board3d::_findSquare {w x y} {
  set bestDist 100000
  set bestSq -1
  set cam $::board3d::_camera($w)
  for {set sq 0} {$sq < 64} {incr sq} {
    lassign [lindex $::board3d::_square3d($sq) 4] sx sy sz
    lassign [::board3d::_project $cam $sx $sy $sz] px py
    set dist [expr {($x-$px)*($x-$px) + ($y-$py)*($y-$py)}]
    if {$dist < $bestDist} {
      set bestDist $dist
      set bestSq $sq
    }
  }
  if {$::board3d::_flip($w)} { set bestSq [expr {63 - $bestSq}] }
  if {$bestSq < 0 || $bestSq >= 64} { return -1 }
  return $bestSq
}

proc ::board3d::_startClick {w x y} {
  set sq [::board3d::_findSquare $w $x $y]
  if {$sq >= 0} {
    set piece [string index $::board3d::_data($w) $sq]
    if {$piece ne "."} {
      # Start piece drag: hide the original piece on board, show a floating copy
      set ::board3d::_dragMode($w) "piece"
      set ::board3d::_dragOrig($w) $sq
      set ::board3d::_dragX($w) $x
      set ::board3d::_dragY($w) $y

      $w.bd itemconfigure p$sq -state hidden
      set psize $::board3d::_size($w)
      set pieceImg $::board::letterToPiece($piece)$psize
      if {[catch {image width $pieceImg}]} {
        foreach s $::boardSizes {
          set pieceImg $::board::letterToPiece($piece)$s
          if {![catch {image width $pieceImg}]} { break }
        }
      }
      $w.bd create image $x $y -image $pieceImg -tag floating_piece -anchor c
      $w.bd raise floating_piece
      return
    }
  }

  # Otherwise: start camera orbit
  set ::board3d::_dragMode($w) "orbit"
  set ::board3d::_dragX($w) $x
  set ::board3d::_dragY($w) $y
}

proc ::board3d::_dragMotion {w x y} {
  if {![info exists ::board3d::_dragMode($w)]} { return }

  if {$::board3d::_dragMode($w) eq "piece"} {
    $w.bd coords floating_piece $x $y
    $w.bd raise floating_piece
    set ::board3d::_dragX($w) $x
    set ::board3d::_dragY($w) $y
    return
  }

  if {$::board3d::_dragMode($w) eq "orbit"} {
    set dx [expr {$x - $::board3d::_dragX($w)}]
    set dy [expr {$y - $::board3d::_dragY($w)}]
    set ::board3d::_dragX($w) $x
    set ::board3d::_dragY($w) $y
    set sensitivity 0.005
    ::board3d::orbit $w [expr {-$dx * $sensitivity}] [expr {$dy * $sensitivity}]
    return
  }
}

proc ::board3d::_endClick {w x y} {
  if {![info exists ::board3d::_dragMode($w)]} { return }

  if {$::board3d::_dragMode($w) eq "piece"} {
    $w.bd delete floating_piece
    set fromSq $::board3d::_dragOrig($w)
    set toSq [::board3d::_findSquare $w $x $y]
    if {$toSq >= 0 && $toSq != $fromSq} {
      # Use addMove which handles promotions, variations, and follow-moves
      addMove $toSq $fromSq
    }
    catch { unset ::board3d::_dragMode($w) ::board3d::_dragOrig($w) }
    # addMove calls updateBoard internally, but also redraw for safety
    ::board3d::redraw3d $w
    return
  }

  catch { unset ::board3d::_dragMode($w) ::board3d::_dragOrig($w) }
  ::board3d::redraw3d $w
}

# Approximate square click using inverse projection (right-click)
proc ::board3d::_clickSquare {w x y} {
  set sq [::board3d::_findSquare $w $x $y]
  if {$sq >= 0 && $sq < 64} {
    event generate $w.bd <<SquareClick>> -data $sq
  }
}

# ----------------------------------------------------------------------
# Internal: Last move highlight
# ----------------------------------------------------------------------

proc ::board3d::_drawLastMoveHighlight {w projCorners projCenters} {
  set bd $w.bd
  if {!$::highlightLastMove && !$::arrowLastMove} { return }

  if {[catch { sc_game info previousMoveUCI } moveuci]} { return }
  if {[string length $moveuci] < 4} { return }

  set sq1 [::board::sq [string range $moveuci 0 1]]
  set sq2 [::board::sq [string range $moveuci 2 3]]
  if {$sq1 < 0 || $sq2 < 0} { return }

  # Draw highlight rectangles
  if {$::highlightLastMove} {
    foreach sq [list $sq1 $sq2] {
      set corners [lindex $projCorners $sq]
      if {[lindex $corners 0] < -10000} { continue }
      set pad 2
      lassign $corners x0 y0 x1 y1 x2 y2 x3 y3
      $bd create polygon $x0 $y0 $x1 $y1 $x2 $y2 $x3 $y3 \
          -fill "" -outline $::highlightLastMoveColor \
          -width $::highlightLastMoveWidth -tag board3d
    }
  }

  # Draw arrow
  if {$::arrowLastMove} {
    # Recompute the arrow in 3D and project
    set pt1 [lindex $::board3d::_square3d($sq1) 4]   ;# center of sq1
    set pt2 [lindex $::board3d::_square3d($sq2) 4]   ;# center of sq2
    lassign $pt1 x1 y1 z1
    lassign $pt2 x2 y2 z2
    set cam $::board3d::_camera($w)

    # Arrow start: 80% of the way from sq1 toward sq2
    set ax [expr {$x1 + 0.2 * ($x2 - $x1)}]
    set ay [expr {$y1 + 0.2 * ($y2 - $y1)}]
    set az 0.0
    # Arrow end: at sq2
    set bx $x2
    set by $y2
    set bz 0.0

    lassign [::board3d::_project $cam $ax $ay $az] asx asy
    lassign [::board3d::_project $cam $bx $by $bz] bsx bsy
    if {$asx > -10000 && $bsx > -10000} {
      $bd create line $asx $asy $bsx $bsy \
          -fill $::highlightLastMoveColor -width 3 -arrow last \
          -arrowshape {10 12 4} -tag board3d
    }
  }
}

# ----------------------------------------------------------------------
# Internal: Draw marks and arrows
# ----------------------------------------------------------------------

proc ::board3d::_drawMarks {w projCorners projCenters drawOrder} {
  set bd $w.bd
  set cam $::board3d::_camera($w)

  foreach mark $::board3d::_marks($w) {
    lassign $mark type sq1 sq2 color

    if {$type eq "full"} {
      set corners [lindex $projCorners $sq1]
      if {[lindex $corners 0] < -10000} { continue }
      lassign $corners x0 y0 x1 y1 x2 y2 x3 y3
      $bd create polygon $x0 $y0 $x1 $y1 $x2 $y2 $x3 $y3 \
          -fill $color -stipple "" -outline "" -tag board3d
    } elseif {$type eq "circle"} {
      lassign [lindex $projCenters $sq1] cx cy
      if {$cx < -10000} { continue }
      # Estimate radius from projected square size
      set corners [lindex $projCorners $sq1]
      if {[lindex $corners 0] < -10000} { continue }
      set diam [expr {abs([lindex $corners 2] - [lindex $corners 0]) * 0.8}]
      set r [expr {$diam / 2.0}]
      $bd create oval [expr {$cx-$r}] [expr {$cy-$r}] \
          [expr {$cx+$r}] [expr {$cy+$r}] \
          -fill "" -outline $color -width 3 -tag board3d
    } elseif {$type eq "arrow"} {
      if {$sq2 < 0} { continue }
      set pt1 [lindex $::board3d::_square3d($sq1) 4]
      set pt2 [lindex $::board3d::_square3d($sq2) 4]
      lassign $pt1 x1 y1 z1
      lassign $pt2 x2 y2 z2
      set ax [expr {$x1 + 0.15 * ($x2 - $x1)}]
      set ay [expr {$y1 + 0.15 * ($y2 - $y1)}]
      set az 0.0
      set bx [expr {$x2 - 0.15 * ($x2 - $x1)}]
      set by [expr {$y2 - 0.15 * ($y2 - $y1)}]
      set bz 0.0
      lassign [::board3d::_project $cam $ax $ay $az] asx asy
      lassign [::board3d::_project $cam $bx $by $bz] bsx bsy
      if {$asx > -10000 && $bsx > -10000} {
        $bd create line $asx $asy $bsx $bsy \
            -fill $color -width 2 -arrow last \
            -arrowshape {8 10 4} -tag board3d
      }
    }
  }
}

# ----------------------------------------------------------------------
# End of file: board3d.tcl
# ----------------------------------------------------------------------
