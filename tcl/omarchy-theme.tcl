###
### omarchy-theme.tcl: part of scidCommunity.
### Copyright (C) 2026 Hugh Whelan
### SPDX-License-Identifier: GPL-2.0-or-later
###
### Auto-generate a scidCommunity ttk theme from the active Omarchy color
### theme (colors.toml). This is only active on Omarchy Linux systems;
### everywhere else (other distros, Windows, macOS) it is a no-op.
###
### The generated theme is cached under scidDataDir and only rebuilt when the
### Omarchy theme actually changes, detected by fingerprinting colors.toml.
###

namespace eval ::omarchyTheme {

  variable themeName "omarchy"

  # --- Detection -----------------------------------------------------------
  proc isOmarchy {} {
    if {$::windowsOS || $::macOS} { return 0 }
    if {![info exists ::env(HOME)] || $::env(HOME) eq ""} { return 0 }
    if {[info exists ::env(DESKTOP_SESSION)] && $::env(DESKTOP_SESSION) eq "omarchy"} {
      return 1
    }
    if {[colorsFile] ne ""} { return 1 }
    return 0
  }

  proc currentThemeDir {} {
    return [file join $::env(HOME) ".local" "state" "omarchy" "current" "theme"]
  }

  proc colorsFile {} {
    set f [file join [currentThemeDir] "colors.toml"]
    if {![file readable $f]} { return "" }
    return $f
  }

  proc themeNameFile {} {
    return [file join $::env(HOME) ".local" "state" "omarchy" "current" "theme.name"]
  }

  # --- Fingerprint ---------------------------------------------------------
  # 32-bit FNV-1a over the combined theme name + colors.toml content. No
  # external packages required. Deterministic, so the same palette always
  # yields the same fingerprint.
  proc hashString {s} {
    set h 2166136261
    foreach c [split $s ""] {
      set h [expr {($h ^ [scan $c %c]) * 16777619}]
      set h [expr {$h & 0xffffffff}]
    }
    return [format %08x $h]
  }

  proc readFile {f} {
    if {![file readable $f]} { return "" }
    if {[catch {set fd [open $f r]; set c [read $fd]; close $fd}]} {
      return ""
    }
    return $c
  }

  proc fingerprint {} {
    set cf [colorsFile]
    if {$cf eq ""} { return "" }
    set colors [readFile $cf]
    if {$colors eq ""} { return "" }
    set name [string trim [readFile [themeNameFile]]]
    return [hashString "$name\n$colors"]
  }

  # --- Cache ---------------------------------------------------------------
  proc cacheFile {} {
    return [file nativename [file join $::scidDataDir "omarchy-theme.tcl"]]
  }

  proc cacheValid {file fp} {
    if {$fp eq "" || ![file readable $file]} { return 0 }
    if {[catch {set fd [open $file r]; set line [gets $fd]; close $fd}]} {
      return 0
    }
    if {![regexp {^#\s*OmarchyTheme\s+([0-9a-fA-F]{8})} $line -> stored]} {
      return 0
    }
    return [expr {[string tolower $stored] eq [string tolower $fp]}]
  }

  # --- colors.toml parsing -------------------------------------------------
  proc readColors {} {
    set cf [colorsFile]
    if {$cf eq ""} { return "" }
    set content [readFile $cf]
    if {$content eq ""} { return "" }
    set colors [dict create]
    foreach line [split $content "\n"] {
      set line [string trim $line]
      if {$line eq "" || [string index $line 0] eq "#"} { continue }
      if {![regexp {^(\w+)\s*=\s*"?([^"]*)"?} $line -> key val]} { continue }
      dict set colors $key [string trim $val]
    }
    return $colors
  }

  # Resolve a palette key, with a fallback value. Returns a valid #rrggbb or "".
  proc color {colors key {fallback ""}} {
    if {[dict exists $colors $key]} {
      set v [dict get $colors $key]
      if {[regexp {^#[0-9a-fA-F]{6}$} $v]} { return [string tolower $v] }
    }
    return $fallback
  }

  # --- Theme generation ----------------------------------------------------
  proc generateScript {colors fp} {
    set bg  [color $colors background          "#1e1e2e"]
    set fg  [color $colors foreground          "#cdd6f4"]
    set acc [color $colors accent              [color $colors blue "#7aa2f7"]]
    set mut [color $colors muted               "#45475a"]
    set lbr [color $colors lighter_background  "#313244"]
    set dbr [color $colors dark_background     "#181825"]

    set dark 1
    if {[dict exists $colors mode]} {
      if {[string tolower [dict get $colors mode]] eq "light"} { set dark 0 }
    }
    set darkReg {registerDarkTheme "omarchy"}
    if {!$dark} { set darkReg "" }

    # Button/surface backgrounds use lighter_background (a surface color) rather
    # than selection, which some themes (e.g. Aether-generated ones) set to a
    # light text-selection color. Toolbutton and the other control styles are
    # configured explicitly so they don't fall back to the parent's gray.
    set template {# OmarchyTheme @FP@
@DARKREG@
if {[lsearch -exact [ttk::style theme names] omarchy] == -1} {
  ttk::style theme create omarchy -parent classic -settings {
    ttk::style configure . -background @BG@ -fieldbackground @LBR@ -foreground @FG@ -selectbackground @ACC@ -selectforeground @BG@ -insertcolor @FG@ -insertbackground @FG@ -troughcolor @DBR@
    ttk::style configure TFrame -background @BG@
    ttk::style configure TLabel -background @BG@ -foreground @FG@
    ttk::style configure TNotebook -background @BG@
    ttk::style configure TNotebook.Tab -background @BG@ -foreground @FG@
    ttk::style map TNotebook.Tab -background [list selected @LBR@]
    ttk::style configure Treeview -background @DBR@ -fieldbackground @DBR@ -foreground @FG@
    ttk::style map Treeview -background [list selected @ACC@] -foreground [list selected @BG@]
    ttk::style configure Heading -background @LBR@ -foreground @FG@ -relief flat
    ttk::style map Heading -background [list active @MUT@]
    ttk::style configure TEntry -fieldbackground @LBR@ -foreground @FG@
    ttk::style configure TCombobox -fieldbackground @LBR@ -foreground @FG@
    ttk::style configure TSpinbox -fieldbackground @LBR@ -foreground @FG@
    ttk::style configure TButton -background @LBR@ -foreground @FG@ -borderwidth 1 -relief raised -padding {6 2}
    ttk::style map TButton -background [list active @MUT@ pressed @DBR@] -relief [list pressed sunken]
    ttk::style configure TMenubutton -background @LBR@ -foreground @FG@ -borderwidth 1 -relief raised
    ttk::style map TMenubutton -background [list active @MUT@ pressed @DBR@]
    ttk::style configure Toolbutton -background @LBR@ -foreground @FG@ -relief flat -padding 2
    ttk::style map Toolbutton -background [list active @MUT@ pressed @ACC@ selected @ACC@] -relief [list {active !selected} raised]
    ttk::style configure TCheckbutton -background @BG@ -foreground @FG@ -indicatorcolor @LBR@
    ttk::style map TCheckbutton -background [list active @BG@] -indicatorcolor [list pressed @MUT@ selected @ACC@ alternate @ACC@]
    ttk::style configure TRadiobutton -background @BG@ -foreground @FG@ -indicatorcolor @LBR@
    ttk::style map TRadiobutton -background [list active @BG@] -indicatorcolor [list pressed @MUT@ selected @ACC@ alternate @ACC@]
    ttk::style configure TScale -troughcolor @DBR@ -background @BG@
    ttk::style configure TProgressbar -troughcolor @DBR@ -background @ACC@
    ttk::style configure TScrollbar -troughcolor @DBR@ -background @MUT@
    ttk::style map TScrollbar -background [list active @ACC@ pressed @ACC@]
    ttk::style configure TLabelframe -background @BG@ -bordercolor @MUT@
  }
}
}
    return [string map [list \
        @FP@     $fp \
        @DARKREG@ $darkReg \
        @BG@     $bg \
        @FG@     $fg \
        @ACC@    $acc \
        @MUT@    $mut \
        @LBR@    $lbr \
        @DBR@    $dbr \
      ] $template]
  }

  proc writeCache {file script} {
    file mkdir [file dirname $file]
    set tmp "$file.tmp.[pid]"
    set fd ""
    if {[catch {
      set fd [open $tmp w]
      puts -nonewline $fd $script
      close $fd
      set fd ""
      file rename -force -- $tmp $file
    }]} {
      catch { close $fd }
      catch { file delete -force -- $tmp }
      return 0
    }
    return 1
  }

  # --- Entry point ---------------------------------------------------------
  # Ensures the "omarchy" ttk theme exists, rebuilding it from colors.toml only
  # when necessary. Returns the theme name, or "" if this is not an Omarchy
  # system or the palette could not be read.
  proc ensure {} {
    variable themeName
    if {![isOmarchy]} { return "" }
    set fp [fingerprint]
    if {$fp eq ""} { return "" }

    set cache [cacheFile]
    if {![cacheValid $cache $fp]} {
      set colors [readColors]
      if {$colors eq ""} { return "" }
      set script [generateScript $colors $fp]
      if {![writeCache $cache $script]} { return "" }
    }

    catch { safeSourceStyle $cache }
    if {[lsearch -exact [ttk::style theme names] $themeName] == -1} {
      return ""
    }
    return $themeName
  }
}
