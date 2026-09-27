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
###   Windows:                     PowerShell click-capture + GDI GetPixel
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

    # A backend returns a color on success, "" on user cancellation, and
    # raises on tool failure. Only a normal return settles the chain ("" = the
    # user cancelled, so do not fall through to another picker); raised errors
    # move on to the next backend.
    set result ""
    set lastError ""
    set settled 0
    foreach backend $backendList {
      if {[catch { _pick_$backend } result]} {
        set lastError $result
        continue
      }
      set settled 1
      break
    }

    foreach entry $hidden {
      lassign $entry top state
      catch { wm deiconify $top }
      if {$state eq "zoomed"} { catch { wm state $top zoomed } }
    }
    catch { update }

    if {! $settled && $lastError ne ""} { error $lastError }
    return $result
  }

  #############################################################################
  # Backends
  #############################################################################

  proc _pick_hyprpicker {} {
    # NOTE: do not pass -q: hyprpicker prints the picked color through the
    # same logging function, and quiet mode would suppress it as well.
    # -u 20 shrinks the zoom lens circle (default radius is 100).
    # hyprpicker exits 2 when the user cancels and 1 on failure.
    set out ""
    if {[catch { set out [exec hyprpicker -f hex -b -u 20 2>@1] } err]} {
      if {[lindex $::errorCode 0] eq "CHILDSTATUS" \
          && [lindex $::errorCode 2] == 2} { return "" }
      error $err
    }
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
    # color as a struct holding one ARGB uint. gdbus prints replies with type
    # annotations, so this comes back as "(uint32 4294901760,)".
    # Cancelling raises org.kde.kwin.ColorPicker.Error.Cancelled.
    set out ""
    if {[catch {
      set out [exec gdbus call --session \
        --dest org.kde.KWin --object-path /ColorPicker \
        --method org.kde.kwin.ColorPicker.pick 2>@1]
    } err]} {
      if {[string match -nocase {*cancel*} $err]} { return "" }
      error $err
    }
    if {[regexp {uint32\s+([0-9]+)} $out -> argb] \
        || [regexp {\(\s*(-?[0-9]+)\s*,?\s*\)} $out -> argb]} {
      set argb [expr {$argb & 0xffffffff}]
      return [format "#%02x%02x%02x" \
        [expr {($argb >> 16) & 0xff}] \
        [expr {($argb >> 8) & 0xff}] \
        [expr {$argb & 0xff}]]
    }
    error "Could not parse KWin color picker output: $out"
  }

  proc _pick_gnome {} {
    # gnome-shell's interactive color picker returns a{sv} with "color" as a
    # (ddd) tuple of RGB values in [0,1]; gdbus prints e.g.
    # "({'color': <(0.2, 0.50196, 0.30196)>},)".
    set out ""
    if {[catch {
      set out [exec gdbus call --session \
        --dest org.gnome.Shell.Screenshot \
        --object-path /org/gnome/Shell/Screenshot \
        --method org.gnome.Shell.Screenshot.PickColor 2>@1]
    } err]} {
      if {[string match -nocase {*cancel*} $err]} { return "" }
      error $err
    }
    if {[regexp {\(([0-9.]+),\s*([0-9.]+),\s*([0-9.]+)\)} $out -> r g b]} {
      return [format "#%02x%02x%02x" \
        [expr {int($r * 255 + 0.5)}] \
        [expr {int($g * 255 + 0.5)}] \
        [expr {int($b * 255 + 0.5)}]]
    }
    error "Could not parse GNOME color picker output: $out"
  }

  proc _pick_grim {} {
    # slurp cannot distinguish a user cancellation from a failure (both exit
    # non-zero), so any slurp failure is treated as a cancellation. Once a
    # point has been chosen, a grim failure is unambiguous.
    set point ""
    if {[catch { set point [exec -ignorestderr slurp -p] }]} { return "" }
    if {![regexp {(-?[0-9]+)\s*,\s*(-?[0-9]+)} $point -> x y]} { return "" }
    set file [_tempFile png]
    if {[catch { exec -ignorestderr grim -g "$x,$y 1x1" $file } err]} {
      catch { file delete $file }
      error $err
    }
    set hex [_hexFromFile $file]
    if {$hex eq ""} { error "grim produced no readable image" }
    return $hex
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
    if {[catch { exec -ignorestderr {*}$cmd } err]} {
      catch { file delete $file }
      error $err
    }
    set hex [_hexFromFile $file]
    if {$hex eq ""} { error "screenshot tool produced no readable image" }
    return $hex
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
    if {[catch { exec -ignorestderr xwd -root -silent | {*}$filter } err]} {
      catch { file delete $file }
      error $err
    }
    set hex [_hexFromFile $file]
    if {$hex eq ""} { error "xwd produced no readable image" }
    return $hex
  }

  proc _pick_mac {} {
    lassign [_pickPoint] x y
    if {$x eq ""} { return "" }
    set file [_tempFile png]
    if {[catch { exec -ignorestderr screencapture -x -R${x},${y},1,1 $file } err]} {
      catch { file delete $file }
      error $err
    }
    set hex [_hexFromFile $file]
    if {$hex eq ""} { error "screencapture produced no readable image" }
    return $hex
  }

  proc _pick_windows {} {
    # scidCommunity is already hidden, so the desktop is visible. PowerShell
    # waits for the user's click, then reads the pixel under the cursor with GDI
    # GetPixel (CopyFromScreen returned black in a VM). It is launched hidden
    # through a WScript.Shell wrapper, because a bare .bat/cmd launch popped up
    # a console window that covered the screen.
    set psFile  [_tempFile ps1]
    set vbsFile [_tempFile vbs]
    set batFile [_tempFile bat]
    set result  [_tempFile txt]
    set outLog  [_tempFile txt]
    set log     [file join [_tempDir] "scid_colorpicker_debug.txt"]
    catch { file delete $result }
    catch { file delete $outLog }

    set script {$ErrorActionPreference = 'Stop'
$out = $args[0]
try {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class ScidPick {
    [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern int ReleaseDC(IntPtr hWnd, IntPtr hDC);
    [DllImport("gdi32.dll")] public static extern uint GetPixel(IntPtr hDC, int nXPos, int nYPos);
    [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int vKey);
}
"@
    Add-Type -AssemblyName System.Windows.Forms
    [System.IO.File]::WriteAllText($out, 'S1')
    # Ignore the click that opened the picker (its button may still be held).
    while (([ScidPick]::GetAsyncKeyState(0x01) -band 0x8000) -ne 0) { Start-Sleep -Milliseconds 15 }
    [System.IO.File]::WriteAllText($out, 'S2')
    $deadline = (Get-Date).AddSeconds(120)
    while ($true) {
        if (([ScidPick]::GetAsyncKeyState(0x1B) -band 0x8000) -ne 0) { [System.IO.File]::WriteAllText($out, 'CANCEL'); exit 2 }
        if (([ScidPick]::GetAsyncKeyState(0x01) -band 0x8000) -ne 0) { break }
        if ((Get-Date) -gt $deadline) { [System.IO.File]::WriteAllText($out, 'CANCEL'); exit 2 }
        Start-Sleep -Milliseconds 15
    }
    $p = [System.Windows.Forms.Cursor]::Position
    $hdc = [ScidPick]::GetDC([IntPtr]::Zero)
    $c = [ScidPick]::GetPixel($hdc, $p.X, $p.Y)
    [ScidPick]::ReleaseDC([IntPtr]::Zero, $hdc) | Out-Null
    $hex = "#{0:x2}{1:x2}{2:x2}" -f ($c -band 0xff), (($c -shr 8) -band 0xff), (($c -shr 16) -band 0xff)
    [System.IO.File]::WriteAllText($out, $hex)
} catch {
    [System.IO.File]::WriteAllText($out, "ERR " + $_.Exception.GetType().Name + ": " + $_.Exception.Message)
    exit 1
}
}
    set fd [open $psFile w]; puts $fd $script; close $fd

    set psExe [auto_execok powershell]
    if {$psExe eq ""} { set psExe [auto_execok pwsh] }
    set psNative [file nativename $psExe]
    set psCmd "\"$psNative\" -NoLogo -NoProfile -ExecutionPolicy Bypass \
      -File \"[file nativename $psFile]\" \"[file nativename $result]\""

    # WScript.Shell.Run with window style 0 starts PowerShell with no console
    # window; wscript itself is a GUI app, so nothing appears on screen.
    set vbsCmd [string map [list "\"" "\"\""] $psCmd]
    set vf [open $vbsFile w]
    puts $vf "Set sh = CreateObject(\"WScript.Shell\")"
    puts $vf "sh.Run \"$vbsCmd\", 0, True"
    close $vf

    set runErr ""
    set runFailed [catch { exec wscript //Nologo //B [file nativename $vbsFile] 2>@1 } runErr]

    set body ""
    if {[file exists $result]} {
      set fh [open $result r]; set body [string trim [read $fh]]; close $fh
    }

    # Fallback: plain cmd /c (works, but shows a console window). Only used if
    # the hidden launch never ran the script at all.
    if {[_parseColor $body] eq "" && ! [file exists $result]} {
      set bf [open $batFile w]
      puts $bf "@echo off"
      puts $bf "$psCmd > \"[file nativename $outLog]\" 2>&1"
      close $bf
      catch { exec cmd /c [file nativename $batFile] 2>@1 }
      if {[file exists $result]} {
        set fh [open $result r]; set body [string trim [read $fh]]; close $fh
      }
    }

    set diag "runFailed=$runFailed runErr='[string range $runErr 0 80]' result='[string range $body 0 40]'"
    catch {
      set lf [open $log w]
      puts $lf $diag
      puts $lf "ps='$psNative'"
      puts $lf "--- vbs ---"
      set vfh [open $vbsFile r]; puts $lf [read $vfh]; close $vfh
      puts $lf "--- script ---"
      set sfh [open $psFile r]; puts $lf [read $sfh]; close $sfh
      close $lf
    }
    catch { file delete $psFile }
    catch { file delete $vbsFile }
    catch { file delete $batFile }
    catch { file delete $result }
    catch { file delete $outLog }

    if {$body eq "CANCEL"} { return "" }
    set hex [_parseColor $body]
    if {$hex eq ""} {
      error "Windows color picker did not return a color.\n$diag\n\nDebug log: $log"
    }
    return $hex
  }

  #############################################################################
  # Helpers
  #############################################################################

  # Let the user click a point anywhere on the (X11/macOS) screen.
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
    # Make the overlay see-through so the desktop is visible. Must be set after
    # the window is mapped (X11 ignores it otherwise) and is a no-op where alpha
    # is unsupported, e.g. X11 without a compositor.
    catch { wm attributes $w -alpha 0.01 }
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
