###
### hyprland-menus.tcl: part of scidCommunity.
### Copyright (C) 2026 Hugh Whelan
### SPDX-License-Identifier: GPL-2.0-or-later
###
### Keeps Tk menus where Tk posted them on Hyprland. Everywhere else this file
### installs nothing.
###

################################################################################
# Hyprland, on a workspace switched to its "floating" layout, opens every
# window in the middle of the screen at a fixed size: Omarchy does it with a
# window rule, and any Hyprland user can write the same rule. The rule is meant
# for application windows, but it also catches Tk's menu windows, so each menu
# and submenu comes up as a large square in the middle of the screen - detached
# from the menu it belongs to, and covering the level above it. A tiled
# workspace has no such rule, which is why the menus behave everywhere except
# there.
#
# The compositor cannot be kept from applying the rule when a menu is mapped,
# but a menu's size is its own requested size and Tk leaves the position it
# posted it at alone, so the geometry can simply be put back. The position is
# remembered when the menu maps, before the compositor moves it, and restored
# if a Configure event or one of the follow-up checks finds the menu elsewhere.
# Only the first second is watched, so the Configure events that follow belong
# to a torn-off menu being dragged, and are left to the user.
################################################################################

namespace eval ::hyprMenus {
  variable want
  variable serial 0
  # The rule lands a few milliseconds after the menu maps on an idle machine,
  # and later while the machine is busy; a handful of checks catches it either
  # way, and the first one is soon enough that the move is rarely seen.
  variable watchMs {0 16 48 100 200 400 800}

  proc install {} {
    # windows.tcl is sourced before this file and defines the Hyprland check.
    if {![isHyprlandSession]} { return }
    bind Menu <Map> +[list ::hyprMenus::onMap %W]
    bind Menu <Configure> +[list ::hyprMenus::onConfigure %W]
  }

  # Tk has sized the menu and posted it where the caller asked for it; the
  # compositor moves it a moment later. Remember that geometry and check it
  # again a few times.
  proc onMap {w} {
    variable want
    variable watchMs
    variable serial
    set token [incr serial]
    set want($w) [list [winfo rootx $w] [winfo rooty $w] [clock milliseconds] $token]
    foreach ms $watchMs {
      after $ms [list ::hyprMenus::restore $w]
    }
    after [expr {[lindex $watchMs end] + 500}] [list ::hyprMenus::forget $w $token]
  }

  # The compositor's move arrives as a Configure event, so acting on it puts
  # the menu back without waiting for the next check. "wm geometry" asks Tk to
  # move the window, which Tk does once the Configure event has been handled,
  # so the restore itself is left to idle.
  proc onConfigure {w} {
    variable want
    if {![info exists want($w)]} { return }
    if {[clock milliseconds] - [lindex $want($w) 2] > 1000} { return }
    after idle [list ::hyprMenus::restore $w]
  }

  proc restore {w} {
    variable want
    if {![info exists want($w)] || ![winfo exists $w] || ![winfo ismapped $w]} {
      return
    }
    lassign $want($w) x y
    set width [winfo reqwidth $w]
    set height [winfo reqheight $w]
    if {[near [winfo width $w] $width] && [near [winfo height $w] $height]
        && [near [winfo rootx $w] $x] && [near [winfo rooty $w] $y]} {
      return
    }
    catch { wm geometry $w ${width}x${height}+${x}+${y} }
  }

  # XWayland's scaling can leave a pixel or two between the geometry Tk asks
  # for and the geometry the menu window gets. Chasing that would only fight
  # the compositor over and over, so a pixel or two counts as correct.
  proc near {a b} {
    return [expr {abs($a - $b) <= 2}]
  }

  proc forget {w token} {
    variable want
    if {[info exists want($w)] && [lindex $want($w) 3] == $token} {
      unset want($w)
    }
  }
}

::hyprMenus::install

###
### End of file: hyprland-menus.tcl
###
