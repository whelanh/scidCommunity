
# getClipboardText:
#   Returns the text currently on the system clipboard, with surrounding
#   whitespace removed. If the CLIPBOARD selection is unavailable, the
#   PRIMARY selection (the X11 middle-click buffer) is tried. Returns the
#   empty string if no text could be read. If varName is given, the text is
#   also stored in that variable, but only when text was found, so callers
#   can keep an existing value when the clipboard is empty.
#
#   Tk's "selection get" asks the clipboard owner for the STRING target by
#   default, and its man page warns that it never asks for UTF8_STRING
#   unless told to. On Wayland desktops the clipboard is usually owned by
#   the compositor or a clipboard manager through XWayland, and those
#   owners commonly offer UTF8_STRING only and refuse STRING, so a plain
#   "selection get -selection CLIPBOARD" fails there. Asking for both
#   targets keeps paste working on those systems. Windows and macOS have a
#   single native clipboard that answers any target, so STRING is always
#   tried first and the extra attempt changes nothing there.
#
proc ::utils::getClipboardText {{varName ""}} {
  foreach selection {CLIPBOARD PRIMARY} {
    foreach type {STRING UTF8_STRING} {
      if {![catch {selection get -selection $selection -type $type} text]
            && $text ne ""} {
        set text [string trim $text]
        if {$varName ne ""} {
          upvar 1 $varName var
          set var $text
        }
        return $text
      }
    }
  }
  return ""
}

# isWayland:
#   True when the app is running under a Wayland compositor. Tk itself is an
#   X11 toolkit, so on those desktops it runs through XWayland and its
#   "clipboard"/"selection" commands only touch the X11 selections.
proc ::utils::isWayland {} {
  if {[info exists ::env(XDG_SESSION_TYPE)] &&
      $::env(XDG_SESSION_TYPE) eq "wayland"} { return 1 }
  if {[info exists ::env(WAYLAND_DISPLAY)] && $::env(WAYLAND_DISPLAY) ne ""} {
    return 1
  }
  return 0
}

# setClipboardText:
#   Writes text to the system clipboard. On Wayland, Tk's "clipboard"
#   command writes to the X11 CLIPBOARD selection through XWayland, and the
#   compositor's bridge back to the Wayland clipboard is unreliable: the
#   write can silently never arrive, so a paste shows stale contents. wl-copy
#   (from wl-clipboard) talks to the Wayland clipboard directly and is used
#   there when available; elsewhere the Tk command is used.
proc ::utils::setClipboardText {text} {
  if {[::utils::isWayland] && [auto_execok wl-copy] ne ""} {
    if {![catch {exec wl-copy << $text}]} { return }
    # wl-copy failed for some reason; fall through to the Tk command.
  }
  clipboard clear
  clipboard append $text
}

# thousands, percentFormat:
#   Functions to format integer numbers.
#   thousands inserts the thousands separator (usually "," or ".") for
#   every three digits before the decimal separator in the number.
#   percentFormat does the same as thousands, but also adds a percentage.
#   If "kilo" is true, numbers >= 100,000 are divided by 1000 and have
#   the unit "K" appended while values over 1 million appear as "1.00M"
#
proc ::utils::thousands {n {kilo 0}} {
  global locale
  set commaChar [string index $locale(numeric) 1]
  set unit ""
  if {$kilo} {
    if {$n >= 1000000} {
      set decimalChar [string index $locale(numeric) 0]
      set decimalPart [format "%02d" [expr {(int($n / 10000)) % 100}]]
      set n [expr {int($n) / 1000000}]
      set unit "${decimalChar}${decimalPart}M"
    } elseif {$n >= 100000} {
      set unit "K"
      set n [expr {int($n / 1000)} ]
    }
  }
  if {$commaChar == ""} { return "$n$unit" }
  while {[regsub {^([-+]?[0-9]+)([0-9][0-9][0-9])} $n "\\1$commaChar\\2" n]} {}
  return "$n$unit"
}

proc ::utils::percentFormat {num denom} {
  # Ensure denominator is not zero:
  if {$denom == 0} {set denom 1}
  return "[::utils::thousands $num] ([expr $num * 100 / $denom]%)"
}

