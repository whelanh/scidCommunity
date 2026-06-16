
# game3d.tcl: part of Scid
# Copyright (C) 2021-2026
#
# 3D board window wrapper using the board3d renderer.

namespace eval ::windows::game3d {
  set isOpen 0
}

# ::windows::game3d::toggle --
#   Called from the menu checkbutton.
#   IMPORTANT: The menu checkbutton toggles the -variable BEFORE calling -command,
#   so this proc acts as a simple open/close switch: if window exists, destroy it;
#   if not, create it. Same pattern as ::tree::make and ::book::open.
#
proc ::windows::game3d::toggle {} {
  set w .game3dWin
  if {[winfo exists $w]} {
    destroy $w
    return
  }

  if {[catch { ::windows::game3d::_create $w } err]} {
    tk_messageBox -title ScidCommunity -type ok -icon error \
        -message "Failed to open 3D board:\n$err\n\n$::errorInfo"
    set ::windows::game3d::isOpen 0
    return
  }
}

# ::windows::game3d::Close --
#   Closes the 3D board window explicitly.
#
proc ::windows::game3d::Close {} {
  set w .game3dWin
  if {[winfo exists $w]} {
    destroy $w
  }
}

# ::windows::game3d::_create --
#   Internal: builds the window contents.
#
proc ::windows::game3d::_create {w} {
  toplevel $w
  wm title $w "scidCommunity: [tr Board3D]"
  wm minsize $w 400 400
  wm geometry $w 1040x1080

  bind $w <Destroy> {
    if {[string equal %W .game3dWin]} {
      set ::windows::game3d::isOpen 0
    }
  }

  # Main frame
  ttk::frame $w.f -padding 2
  pack $w.f -expand 1 -fill both

  # Create the 3D board
  set bd $w.f.board3d
  ::board3d::new $bd $::boardSize
  ::board3d::showMarks $bd $::gameInfo(showMarks)
  pack $bd -expand 1 -fill both

  # --- Toolbar ---
  set tb $w.f.toolbar
  ttk::frame $tb
  pack $tb -side bottom -fill x -pady {4 0}

  ttk::button $tb.flip -image ::icon::tb_flip -style Toolbutton \
      -command [list ::board3d::flip $bd]
  ::utils::tooltip::Set $tb.flip "$::tr(FlipBoard)"

  ttk::button $tb.reset -text [tr Board3DReset] -style Toolbutton \
      -command [list ::board3d::reset $bd]

  ttk::button $tb.zoomin -text "+" -style Toolbutton \
      -command [list ::board3d::zoom $bd 1]

  ttk::button $tb.zoomout -text "-" -style Toolbutton \
      -command [list ::board3d::zoom $bd -1]

  ttk::label $tb.info -text "[tr Board3DDragToRotate]  [tr Board3DScrollToZoom]"
  pack $tb.flip $tb.reset $tb.zoomin $tb.zoomout $tb.info \
      -side left -padx 2

  # Resize binding — use the canvas's own configure event
  bind $bd.bd <Configure> [list ::board3d::resize $bd %w %h]

  # Initial position data
  ::board3d::setmarks $bd [sc_pos getComment]
  ::board3d::update $bd [sc_pos board]

  ::update idletasks
}

# ::windows::game3d::update --
#   Called from the position-changed notification.
#   Safe to call even if window is not open.
#
proc ::windows::game3d::update {} {
  if {!$::windows::game3d::isOpen} { return }
  if {![winfo exists .game3dWin.f.board3d]} { return }
  ::board3d::setmarks .game3dWin.f.board3d [sc_pos getComment]
  ::board3d::update .game3dWin.f.board3d [sc_pos board]
  ::update idletasks
}

# ----------------------------------------------------------------------
# End of file: game3d.tcl
# ----------------------------------------------------------------------
