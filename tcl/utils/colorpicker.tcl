###
### colorpicker.tcl: part of scidCommunity.
###
### Screen eyedropper: lets the user pick a color from anywhere on the
### screen (including outside scidCommunity) and returns it as "#rrggbb".
###
### This is a best-effort, cross-platform helper. A screen pixel can only be
### read through OS/compositor specific tooling, so several backends are
### probed in order of preference:
###
###   Wayland (wlroots/Hyprland):  hyprpicker, then grim + slurp
###   KDE Plasma:                  org.kde.KWin.ColorPicker D-Bus (gdbus)
###   GNOME:                       org.gnome.Shell.Screenshot.PickColor (gdbus)
###   X11:                         ImageMagick (import/magick)
###   Windows:                     PowerShell + GDI GetPixel
###   macOS:                       screencapture -R
###
### When no backend is available ::colorPicker::pick reports an error so the
### caller can show a helpful message instead of silently failing.
###

namespace eval ::colorPicker {

  # Return true when running on a Wayland session.
  proc isWayland {} {
    if {[info exists ::env(XDG_SESSION_TYPE)] && $::env(XDG_SESSION_TYPE) eq "wayland"} {
      return 1
    }
    if {[info exists ::env(WAYLAND_DISPLAY)] && $::env(WAYLAND_DISPLAY) ne ""} {
      return 1
    }
    return 0
  }

  proc isHyprland {} {
    return [info exists ::env(HYPRLAND_INSTANCE_SIGNATURE)]
  }

  # Classify the current desktop environment: kde, gnome, hyprland, wlroots or "".
  proc desktopEnv {} {
    set d ""
    if {[info exists ::env(XDG_CURRENT_DESKTOP)]} {
      set d [string tolower $::env(XDG_CURRENT_DESKTOP)]
    }
    if {[string match *kde* $d] || [string match *plasma* $d]} { return kde }
    if {[string match *gnome* $d]} { return gnome }
    if {[string match *hyprland* $d] || [isHyprland]} { return hyprland }
    if {[string match *sway* $d] || [string match *wlroots* $d]} { return wlroots }
    return ""
  }

  proc hasGrim {} {
    return [expr {[auto_execok grim] ne "" && [auto_execok slurp] ne ""}]
  }

  proc hasGdbus {} {
    return [expr {[auto_execok gdbus] ne ""}]
  }

  # Return true if a session D-Bus service exports the given object path.
  # Fails fast (a few ms) when the service is not running.
  proc dbusAvailable { name path } {
    if {! [hasGdbus]} { return 0 }
    return [expr {! [catch {
      exec gdbus introspect --session --dest $name --object-path $path 2>@1
    }]}]
  }

  # Return the ordered list of usable backends for this system.
  proc backends {} {
    set list {}
    if {$::macOS} {
      if {[auto_execok screencapture] ne ""} { lappend list mac }
      return $list
    }
    if {$::windowsOS} {
      if {[auto_execok powershell] ne "" || [auto_execok pwsh] ne ""} {
        lappend list windows
      }
      return $list
    }

    set de [desktopEnv]

    # Only offer a D-Bus backend when its service is actually running, so an
    # absent one cannot shadow the remaining fallbacks (cancel is reported as
    # an empty result, which stops the chain, so "available" must be checked
    # up front rather than relying on a failed call).
    set kdeOK   [expr {($de eq "kde"   || $de eq "") && [dbusAvailable org.kde.KWin /ColorPicker]}]
    set gnomeOK [expr {($de eq "gnome" || $de eq "") && [dbusAvailable org.gnome.Shell.Screenshot /org/gnome/Shell/Screenshot]}]

    if {$de eq "hyprland"} {
      if {[auto_execok hyprpicker] ne ""} { lappend list hyprpicker }
      if {[hasGrim]} { lappend list grim }
    }

    if {[isWayland]} {
      # wlroots compositors that are not Hyprland (e.g. sway), and any
      # unrecognised Wayland desktop, can use grim + slurp.
      if {($de eq "wlroots" || $de eq "") && [hasGrim]} { lappend list grim }
    }

    if {$kdeOK} { lappend list kde }
    if {$gnomeOK} { lappend list gnome }

    # X11 fallback (KDE/GNOME also run X11 sessions).
    if {! [isWayland]} {
      if {[auto_execok import] ne "" || [auto_execok magick] ne ""} {
        lappend list x11
      } elseif {[auto_execok xwd] ne "" \
                && ([auto_execok convert] ne "" || [auto_execok magick] ne "")} {
        lappend list x11xwd
      }
    }
    return $list
  }

  # Return a "#rrggbb" color string (lowercase), or "" if none can be found.
  proc pick { widget } {
    set backendList [backends]
    if {[llength $backendList] == 0} {
      error "Picking a color from the screen is not available on this system.\n\
Wayland: install 'hyprpicker' (Hyprland) or 'grim' + 'slurp' (wlroots).\n\
Other desktops: make sure 'gdbus' (KDE/GNOME), ImageMagick (X11) or\n\
PowerShell (Windows) is available, then try again."
    }

    # Hide scidCommunity while picking so it does not cover the target.
    set hidden {}
    set tops [list [winfo toplevel $widget]]
    if {[lsearch -exact $tops .] < 0} { lappend tops . }
    foreach top $tops {
      if {[winfo exists $top] && [wm state $top] in {normal zoomed}} {
        lappend hidden [list $top [wm state $top]]
        catch { wm withdraw $top }
      }
    }
    catch { update }
    if {[llength $hidden]} { _sleep 80 }

    set result ""
    set lastError ""
    foreach backend $backendList {
      if {[catch { _pick_$backend } result]} {
        set lastError $result
        continue
      }
      break
    }

    foreach entry $hidden {
      lassign $entry top state
      catch { wm deiconify $top }
      if {$state eq "zoomed"} { catch { wm state $top zoomed } }
    }
    catch { update }

    if {$result eq "" && $lastError ne ""} { error $lastError }
    return $result
  }

  #############################################################################
  # Backends
  #############################################################################

  proc _pick_hyprpicker {} {
    # NOTE: do not pass -q: hyprpicker prints the picked color through the
    # same logging function, and quiet mode would suppress it as well.
    # -u 20 shrinks the zoom lens circle (default radius is 100).
    set out ""
    catch { set out [exec -ignorestderr hyprpicker -f hex -b -u 20] }
    foreach line [split $out "\n"] {
      set line [string trim $line]
      if {[regexp {^#?([0-9a-fA-F]{6})$} $line -> hex]} {
        return [string tolower "#$hex"]
      }
    }
    return ""
  }

  proc _pick_kde {} {
    # KWin exposes an interactive color picker over D-Bus. It returns the
    # color as a struct holding one ARGB uint, e.g. gdbus prints "(4294901760,)".
    # Cancelling raises org.kde.kwin.ColorPicker.Error.Cancelled -> nonzero exit.
    set out ""
    if {[catch {
      set out [exec -ignorestderr gdbus call --session \
        --dest org.kde.KWin --object-path /ColorPicker \
        --method org.kde.kwin.ColorPicker.pick]
    }]} { return "" }
    if {[regexp {(-?[0-9]+)} $out -> argb]} {
      set argb [expr {$argb & 0xffffffff}]
      return [format "#%02x%02x%02x" \
        [expr {($argb >> 16) & 0xff}] \
        [expr {($argb >> 8) & 0xff}] \
        [expr {$argb & 0xff}]]
    }
    return ""
  }

  proc _pick_gnome {} {
    # gnome-shell's interactive color picker returns a{sv} with "color" as a
    # (ddd) tuple of RGB values in [0,1]; gdbus prints e.g.
    # "({'color': <(0.2, 0.50196, 0.30196)>},)".
    set out ""
    if {[catch {
      set out [exec -ignorestderr gdbus call --session \
        --dest org.gnome.Shell.Screenshot \
        --object-path /org/gnome/Shell/Screenshot \
        --method org.gnome.Shell.Screenshot.PickColor]
    }]} { return "" }
    if {[regexp {\(([0-9.]+),\s*([0-9.]+),\s*([0-9.]+)\)} $out -> r g b]} {
      return [format "#%02x%02x%02x" \
        [expr {int($r * 255 + 0.5)}] \
        [expr {int($g * 255 + 0.5)}] \
        [expr {int($b * 255 + 0.5)}]]
    }
    return ""
  }

  proc _pick_grim {} {
    set point ""
    if {[catch { set point [exec -ignorestderr slurp -p] }]} { return "" }
    if {![regexp {(-?[0-9]+)\s*,\s*(-?[0-9]+)} $point -> x y]} { return "" }
    set file [_tempFile png]
    if {[catch { exec -ignorestderr grim -g "$x,$y 1x1" $file }]} {
      catch { file delete $file }
      return ""
    }
    return [_hexFromFile $file]
  }

  proc _pick_x11 {} {
    lassign [_pickPoint] x y
    if {$x eq ""} { return "" }
    set file [_tempFile png]
    if {[auto_execok import] ne ""} {
      set cmd [list import -screen -crop 1x1+$x+$y +repage $file]
    } else {
      set cmd [list magick import -screen -crop 1x1+$x+$y +repage $file]
    }
    if {[catch { exec -ignorestderr {*}$cmd }]} {
      catch { file delete $file }
      return ""
    }
    return [_hexFromFile $file]
  }

  proc _pick_x11xwd {} {
    lassign [_pickPoint] x y
    if {$x eq ""} { return "" }
    set file [_tempFile png]
    if {[auto_execok convert] ne ""} {
      set filter [list convert xwd:- -crop 1x1+$x+$y +repage $file]
    } else {
      set filter [list magick xwd:- -crop 1x1+$x+$y +repage $file]
    }
    if {[catch { exec -ignorestderr xwd -root -silent | {*}$filter }]} {
      catch { file delete $file }
      return ""
    }
    return [_hexFromFile $file]
  }

  proc _pick_mac {} {
    lassign [_pickPoint] x y
    if {$x eq ""} { return "" }
    set file [_tempFile png]
    if {[catch { exec -ignorestderr screencapture -x -R${x},${y},1,1 $file }]} {
      catch { file delete $file }
      return ""
    }
    return [_hexFromFile $file]
  }

  proc _pick_windows {} {
    lassign [_pickPoint] x y
    if {$x eq ""} { return "" }

    set script {param([int]$X, [int]$Y)
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class ScidPixelPicker {
    [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern int ReleaseDC(IntPtr hWnd, IntPtr hDC);
    [DllImport("gdi32.dll")] public static extern uint GetPixel(IntPtr hDC, int nXPos, int nYPos);
}
"@
$hdc = [ScidPixelPicker]::GetDC([IntPtr]::Zero)
$color = [ScidPixelPicker]::GetPixel($hdc, $X, $Y)
[ScidPixelPicker]::ReleaseDC([IntPtr]::Zero, $hdc) | Out-Null
"#{0:x2}{1:x2}{2:x2}" -f ($color -band 0xff), (($color -shr 8) -band 0xff), (($color -shr 16) -band 0xff)
}
    set file [_tempFile ps1]
    if {[catch {
      set fd [open $file w]
      puts $fd $script
      close $fd
    }]} {
      catch { file delete $file }
      return ""
    }

    set exe [auto_execok powershell]
    if {$exe eq ""} { set exe [auto_execok pwsh] }
    set out ""
    catch {
      set out [exec -ignorestderr {*}$exe -NoLogo -NoProfile \
        -ExecutionPolicy Bypass -File $file $x $y]
    }
    catch { file delete $file }
    return [_parseColor $out]
  }

  #############################################################################
  # Helpers
  #############################################################################

  # Let the user click a point anywhere on the (X11/Windows/macOS) screen.
  # Returns {x y} in root coordinates, or {} when cancelled. Wayland uses the
  # dedicated pickers instead, since a Tk overlay cannot see native windows.
  proc _pickPoint {} {
    set w .colorPickerOverlay
    catch { destroy $w }
    toplevel $w
    wm overrideredirect $w 1
    catch { wm attributes $w -topmost 1 }
    set sw [winfo screenwidth .]
    set sh [winfo screenheight .]
    catch {
      set sw [winfo vrootwidth .]
      set sh [winfo vrootheight .]
    }
    wm geometry $w ${sw}x${sh}+0+0
    catch { $w configure -cursor crosshair }
    set ::colorPicker::point ""
    bind $w <Button-1> { set ::colorPicker::point [list %X %Y]; destroy .colorPickerOverlay }
    bind $w <Button-2> { set ::colorPicker::point ""; destroy .colorPickerOverlay }
    bind $w <Button-3> { set ::colorPicker::point ""; destroy .colorPickerOverlay }
    bind $w <Escape>   { set ::colorPicker::point ""; destroy .colorPickerOverlay }
    catch { grab set $w }
    catch { focus -force $w }
    catch { update }
    catch { vwait ::colorPicker::point }
    catch { grab release $w }
    catch { destroy $w }
    catch { update }
    return $::colorPicker::point
  }

  proc _hexFromFile { file } {
    set hex ""
    if {[catch { set img [image create photo -file $file] }]} {
      catch { file delete $file }
      return ""
    }
    if {![catch { lassign [$img get 0 0] r g b }]} {
      set hex [format "#%02x%02x%02x" $r $g $b]
    }
    catch { image delete $img }
    catch { file delete $file }
    return $hex
  }

  proc _parseColor { out } {
    if {[regexp {#([0-9a-fA-F]{6})} $out -> hex]} {
      return [string tolower "#$hex"]
    }
    if {[regexp {#([0-9a-fA-F]{3})\M} $out -> hex]} {
      lassign [split $hex ""] r g b
      return [string tolower "#$r$r$g$g$b$b"]
    }
    if {[regexp {rgba?\(\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)} $out -> r g b]} {
      return [format "#%02x%02x%02x" $r $g $b]
    }
    return ""
  }

  proc _tempFile { ext } {
    return [file join [_tempDir] "scid_colorpicker_[pid]_[clock microseconds].$ext"]
  }

  proc _tempDir {} {
    foreach var {TMPDIR TEMP TMP} {
      if {[info exists ::env($var)] && $::env($var) ne "" \
          && [file isdirectory $::env($var)]} {
        return $::env($var)
      }
    }
    if {!$::windowsOS && [file isdirectory /tmp]} { return /tmp }
    return [pwd]
  }

  # Pump the event loop for ms milliseconds.
  proc _sleep { ms } {
    set ::colorPicker::_sleepDone 0
    after $ms [list set ::colorPicker::_sleepDone 1]
    catch { vwait ::colorPicker::_sleepDone }
  }
}
