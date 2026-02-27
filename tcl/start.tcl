#!/bin/sh

# Scid (Shane's Chess Information Database)
#
# Copyright (C) 1999-2004 Shane Hudson
# Copyright (C) 2006-2009 Pascal Georges
# Copyright (C) 2008-2011 Alexander Wagner
# Copyright (C) 2013-2015 Fulvio Benini
#
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

#
# The following few comments are only for Unix versions of Scid:
#

# The "\" at the end of the comment line below is necessary! It means
#   that the "exec" line is a comment to Tcl/Tk, but not to /bin/sh.
# The next line restarts using tkscid: \
exec `dirname $0`/tkscid "$0" "$@"
# exec tkscid "$0" "$@"

# The above launches tkscid from the same directory that this startup
# script was launched from (which feels as a suitable default scenario).
# Alternatively, you can change the top line of this startup script
# to start tkscid directly from a specific location, e.g.:

# For the above to work, tkscid must be in a directory in your PATH.
# Alternatively, you can set the first line to start tkscid directly
# by specifying the full name of tkscid, eg:
# #!/home/myname/bin/tkscid

############################################################

# Support both Tcl/Tk 8.6 and 9.0+
if {[catch {package require Tk 8.6}]} {
    package require Tk 9.0
}
set useLocalTooltip [catch {package require tooltip 2.0}]

# Tcl 8.6/9.0 compatibility: trace variable -> trace add variable
if {[package vcompare [info patchlevel] 9.0] >= 0} {
    # Tcl 9.0+: create wrapper for old trace variable syntax
    rename trace _trace_orig
    proc trace {op args} {
        if {$op eq "variable"} {
            # Map old single-letter ops to new full names: w->write, r->read, u->unset
            set varName [lindex $args 0]
            set opsList [lindex $args 1]
            set command [lindex $args 2]
            set newOps ""
            foreach char [split $opsList ""] {
                switch $char {
                    w { append newOps "write " }
                    r { append newOps "read " }
                    u { append newOps "unset " }
                }
            }
            return [_trace_orig add variable $varName [string trim $newOps] $command]
        } elseif {$op eq "vdelete"} {
            set varName [lindex $args 0]
            set opsList [lindex $args 1]
            set command [lindex $args 2]
            set newOps ""
            foreach char [split $opsList ""] {
                switch $char {
                    w { append newOps "write " }
                    r { append newOps "read " }
                    u { append newOps "unset " }
                }
            }
            return [_trace_orig remove variable $varName [string trim $newOps] $command]
        } else {
            return [_trace_orig $op {*}$args]
        }
    }
}

set scidVersion [sc_info version]
set scidVersionDate [sc_info version date]
set scidVersionExpected "5.1.1"

# Check that the version of c++ code matches the version of tcl code
# Only check the major and minor numbers to allow for different patch/git versions
regexp {^(\d+\.\d+).*} $::scidVersion -> scidVersionShort
regexp {^(\d+\.\d+).*} $::scidVersionExpected -> scidVersionExpectedShort

if {[string compare $scidVersionShort $scidVersionExpectedShort]} {
  set msg "This is Scid version $::scidVersion, but the scid GUI (tcl/tk code)\n"
  append msg "has the version number $scidVersionExpected.\n"
  tk_messageBox -type ok -icon error -title "scidCommunity: Version Error" -message $msg
  exit 1
}

# Helper function for issuing debug messages:
# trace add execution some_fn {enter leave} trace_log
# trace add variable some_var {read write array unset} trace_log
proc trace_log {args} {
  set bt "::"
  catch {set bt [info level -1]}
  if {[lindex $bt 0] eq "trace_log"} { return }

  set msg "\[[clock format [clock seconds] -format {%H:%M:%S}]\]"
  set op [lindex $args end]
  if {$op in "read write array"} {
    lassign $args var_name elem
    upvar $var_name var
    if {[array exists var]} { set value $var($elem)} { set value $var}
    append msg "   $op: $value [list $args]"
  } else {
    append msg " $op $args"
  }
  puts stderr "$msg - bt: [list $bt]"
}

# Determine operating system platform: unix, windows or macos
#
set windowsOS 0
set unixOS 0
set macOS 0
if {[tk windowingsystem] == "aqua"} {
  set macOS 1
} elseif {$tcl_platform(platform) == "unix"} {
  set unixOS 1
} elseif {$tcl_platform(platform) == "windows"} {
  set windowsOS 1
}

proc InitDirs {} {
  global scidExeDir scidUserDir scidConfigDir scidDataDir scidLogDir scidShareDir scidImgDir scidTclDir
  global scidBooksDir scidBasesDir ecoFile

  # scidExeDir: contains the directory of the Scid executable program.
  # Used to determine the location of various relative data directories.
  set scidExecutable [info nameofexecutable]
  if {[file type $scidExecutable] == "link"} {
    set scidExeDir [file dirname [file readlink $scidExecutable]]
    if {[file pathtype $scidExeDir] == "relative"} {
      set scidExeDir [file dirname [file join [file dirname $scidExecutable]\
        [file readlink $scidExecutable]]]
    }
  } else {
    set scidExeDir [file dirname $scidExecutable]
  }

  # scidUserDir: location of user-specific Scid files.
  # This is "~/.scid" on Unix, and the Scid executable dir on Windows.
  if {$::windowsOS} {
    set scidUserDir $scidExeDir
  } else {
    regexp {(\d+\.\d+).*} $::scidVersion -> version
    set scidUserDir [file join $::env(HOME) ".scid$version"]
  }

  # scidConfigDir, scidDataDir, scidLogDir:
  # Location of Scid configuration, data and log files.
  set scidConfigDir [file nativename [file join $scidUserDir "config"]]
  set scidDataDir [file nativename [file join $scidUserDir "data"]]
  set scidLogDir [file nativename [file join $scidUserDir "log"]]

  # scidShareDir, scidImgDir, scidTclDir, scidBooksDir, scidBasesDir, ecoFile:
  # Location of Scid resources
  set scidShareDir [file normalize [file join $scidExeDir "../share/scid"]]
  if {! [file isdirectory $::scidShareDir]} {
    set scidShareDir $::scidExeDir
  }
  set scidTclDir [file nativename [file join $scidShareDir "tcl"]]
  if {! [file isdirectory $scidTclDir]} {
    set scidTclDir [file dirname [info script]]
    set scidShareDir [file normalize "$scidTclDir/../"]
  }
  set scidImgDir [file nativename [file join $scidShareDir "img"]]

  #Default values, can be overwritten by file option
  set scidBooksDir [file nativename [file join $scidShareDir "books"]]
  set scidBasesDir [file nativename [file join $scidShareDir "bases"]]
  set ecoFile [file nativename [file join $scidShareDir "scid.eco"]]

  set ::scidEnginesDir [file normalize [file join $::scidExeDir "../engines"]]
  if {! [file isdirectory $::scidEnginesDir]} {
    set ::scidEnginesDir $::scidExeDir
  }

  # Create the config, data and log directories if they do not exist:
  proc makeScidDir {dir} {
    if {! [file isdirectory $dir]} {
      file mkdir $dir
    }
  }
  makeScidDir $scidUserDir
  makeScidDir $scidConfigDir
  makeScidDir $scidDataDir
  makeScidDir $scidLogDir
}
InitDirs


proc InitImg {} {
  global scidImgDir boardStyle boardStyles textureSquare

  #Set app icon (prefer PNG, fallback to GIF)
  set scidIconFile [file nativename [file join $scidImgDir "scid.png"]]
  if {![file readable $scidIconFile]} {
    set scidIconFile [file nativename [file join $scidImgDir "scid.gif"]]
  }
  if {[file readable $scidIconFile]} {
    wm iconphoto . -default [image create photo -file "$scidIconFile"]
  }

  #Load all img/buttons/_filename_.gif
  set dname [file join $::scidImgDir buttons]
  foreach {fname} [glob -directory $dname *.gif] {
    set iname [string range [file tail $fname] 0 end-4]
    image create photo $iname -file $fname
  }

  #Load all img/buttons/_filename_.png
  set dname [file join $::scidImgDir buttons]
  foreach {fname} [glob -directory $dname *.png] {
    set iname [string range [file tail $fname] 0 end-4]
    image create photo $iname -format png -file $fname
  }

  #Load all img/boards/_filename_.gif
  set textureSquare {}
  set dname [file join $::scidImgDir boards]
  foreach {fname} [glob -directory $dname *.gif] {
    set iname [string range [file tail $fname] 0 end-4]
    image create photo $iname -file $fname
    if {[string range $iname end-1 end] == "-l"} {
      lappend textureSquare [string range $iname 0 end-2]
    }
  }

  #Search available piece sets
  set boardStyles {}
  set dname [file join $::scidImgDir pieces]
  foreach {piecetype} [glob -directory $dname *] {
    if {[file isdirectory $piecetype] == 1} {
      lappend boardStyles [file tail $piecetype]
    }
  }
}
if {[catch {InitImg}]} {
  tk_messageBox -type ok -icon error -title "scidCommunity: Error" \
    -message "Cannot load images.\n$::errorCode\n\n$::errorInfo"
  exit
}

proc InitTooltip {} {
  if {$::useLocalTooltip} {
    source [file nativename [file join $::scidTclDir "utils/tklib_tooltip.tcl"]]
  }
  namespace eval ::utils::tooltip {
    proc Set {args} { tooltip::tooltip {*}$args }
  }
}
InitTooltip

# Helper function to get the correct button image name for the current theme
# For dark themes (dark, cobalt2), returns the _white variant if it exists
proc ::button_image {buttonName} {
  set theme [ttk::style theme use]
  if {[string first "dark" $theme] != -1 || $theme eq "cobalt2"} {
    set whiteName "${buttonName}_white"
    if {[lsearch [image names] $whiteName] != -1} {
      return $whiteName
    }
  }
  return $buttonName
}

#############################################################
#
# NAMESPACES
#
# The main Tcl/Tk namespaces used in the Scid application are
# initialized here, so that default values can be set up and
# altered when the user options file is loaded.
#
foreach ns {
  ::icon
  ::splash
  ::utils
  ::utils::date ::utils::font ::utils::history ::utils::pane ::utils::string
  ::utils::sound ::utils::validate ::utils::win
  ::file
  ::file::finder ::file::maint ::maint
  ::bookmarks
  ::edit
  ::game
  ::gbrowser
  ::search
  ::search::filter ::search::board ::search::header ::search::material
  ::windows
  ::windows::gamelist ::windows::stats ::tree ::tree::mask ::windows::tree
  ::windows::switcher ::windows::eco ::crosstab ::pgn ::book
  ::windows::commenteditor
  ::tools
  ::tools::analysis
  ::tools::graphs
  ::tools::graphs::filter ::tools::graphs::absfilter ::tools::graphs::rating ::tools::graphs::score
  ::tb ::optable ::tablebase
  ::board ::move
  ::tacgame ::sergame ::opening ::tactics ::calvar ::uci ::fics ::reviewgame ::novag
  ::config ::docking
  ::pinfo
  ::unsafe
} {
  namespace eval $ns {}
}

proc ::splash::add {text} {
#TODO: decide what to do with all the splash messages (delete?)
}

# Platform specific operations
if { $unixOS } {
  # adds a checkbox to show hidden files
  catch {tk_getOpenFile -with-invalid-argument}
  namespace eval ::tk::dialog::file {
    variable showHiddenBtn 1
    variable showHiddenVar 0
  }
}

# Reversed mouse buttons in mac (::MB2 and ::MB3 are middle and right mouse buttons respectively.):
if { $macOS } {
  set ::MB2 3
  set ::MB3 2
  set ::COMMAND Command
} else {
  set ::MB2 2
  set ::MB3 3
  set ::COMMAND Control
}


####################################################
# safeSource() - source a file using a safe interpreter
# @filename:  the absolute path to the file to source (load and execute)
# @args:      pairs of varname value that are visible to the sourced code
#
# This function execute the code inside a safe tcl interpreter and override
# "set" to import the variables of the executed code in the ::unsafe namespace.
# Attention must be paid to not evaluate ::unsafe vars, for example:
# set ::unsafe::badcode {tk_messageBox -message executeme}
# eval $::unsafe::badcode
# after idle $::unsafe::badcode

proc safeSource {filename args} {
  if {![info exists ::safeInterp]} {
    set ::safeInterp [::safe::interpCreate]
    interp hide $::safeInterp set
    interp alias $::safeInterp set {} ::safeSet $::safeInterp
  }
  set f [file nativename "$filename"]
  set d [file dirname $f]
  set n [file tail $f]
  set vdir [::safe::interpAddToAccessPath $::safeInterp $d]
  interp alias $::safeInterp image {} ::safeImage $::safeInterp [list $vdir $d]
  foreach {varname value} $args {
    $::safeInterp eval [list set $varname $value]
  }
  $::safeInterp eval [list set vdir $vdir]
  $::safeInterp eval "source \$vdir/$n"
  foreach {varname value} $args {
    $::safeInterp eval [list unset $varname]
  }
}
proc safeSet {i args} {
  #TODO: do not import local variables
  #if {[$::safeInterp eval info level] == 0}
  foreach {varname value} $args {
    set ::unsafe::$varname $value
  }
  interp invokehidden $i set {*}$args
}

# Use a ::safe::interp to evaluate a file containing ttk::style and image commands.
# The evaluated script can only read the files inside its directory or direct subdirectories.
# @param filename:  the absolute path to the file

# recursiv identify all subdirs
proc safeAddSubDirsToAccessPath { safeInterp dir } {
  foreach subdir [glob -nocomplain -directory $dir -type d *] {
    ::safe::interpAddToAccessPath $safeInterp $subdir
    safeAddSubDirsToAccessPath $safeInterp $subdir
  }
}

proc safeSourceStyle {filename} {
  set filename [file nativename "$filename"]
  set dir [file dirname $filename]

  set safeInterp [::safe::interpCreate]

  set vdir [::safe::interpAddToAccessPath $safeInterp $dir]
  safeAddSubDirsToAccessPath $safeInterp $dir

  interp alias $safeInterp pwd {} ::safePwd
  interp alias $safeInterp package {} ::safePackage $safeInterp
  interp alias $safeInterp image {} ::safeImage $safeInterp [list $vdir $dir]
  interp alias $safeInterp ttk::style {} ::safeStyle $safeInterp
  interp alias $safeInterp ::styleOption {} ::safeStyleOption $safeInterp

  $safeInterp eval [list set vdir $vdir]
  $safeInterp eval "source \$vdir/[file tail $filename]"
  ::safe::interpDelete $safeInterp
}

proc safePwd {} {}

proc safePackage { interp args } {
  set args [lassign $args command]
  catch {
    switch -- $command {
      "require" { package require {*}$args }
      "vsatisfies" { package vsatisfies {*}$args }
      "provide" { package provide {*}$args }
    }
  }
}

proc safeImage {interp dir_map args} {
  set filename [lsearch -exact $args -file]
  if {$filename != -1} {
    incr filename
    set real_filename [string map $dir_map [lindex $args $filename]]
    set args [lreplace $args $filename $filename $real_filename]
  }
  return [image {*}$args]
}

proc safeStyleOption {interp args} {
    styleOption {*}$args
}

# Evaluate ttk::style commands invoked inside the restricted script.
# If the command includes a script (ttk::style theme settings or ttk::style theme create)
# it is evaluated using the safe interpreter.
proc safeStyle {interp args} {
  lassign $args theme settings themeName script
  if {$theme eq "theme"} {
    if { $settings eq "settings"} {
      set curr_theme [ttk::style theme use]
      ttk::style theme use $themeName
      $interp eval $script
      ttk::style theme use $curr_theme
      return
    }

    set script_i [lsearch -exact $args -settings]
    if {$script_i != -1} {
      set script_j [expr $script_i + 1]
      ttk::style {*}[lreplace $args $script_i $script_j]
      $interp eval [list ttk::style theme settings $themeName [lindex $args $script_j]]
      return
    }
  }

  return [ttk::style {*}$args]
}

####################################################
# Load default/saved values
source [file nativename [file join $::scidTclDir "options.tcl"]]

# Create a custom "sand" theme that inherits from classic and adjusts background
if {[lsearch -exact [ttk::style theme names] sand] == -1} {
  ttk::style theme create sand -parent classic -settings {
    # Sand theme based on Chess_Manager_Web palette
    # Base/UI background and text
    ttk::style configure . \
      -background #D2B48C \
      -fieldbackground #F4E1C6 \
      -foreground #3B2F2F \
      -selectbackground #B08968 \
      -selectforeground #1E1A19
    ttk::style configure TFrame -background #D2B48C
    ttk::style configure TLabel -background #D2B48C -foreground #3B2F2F
    ttk::style configure TNotebook -background #D2B48C
    # Content windows (Tree view, Game List, PGN text via applyThemeStyle)
    ttk::style configure Treeview -background #F4E1C6 -fieldbackground #F4E1C6 -foreground #3B2F2F
    ttk::style map Treeview \
      -background [list selected #B08968] \
      -foreground [list selected #1E1A19]
    # Inputs
    ttk::style configure TEntry -fieldbackground #F4E1C6 -foreground #3B2F2F
    ttk::style configure TCombobox -fieldbackground #F4E1C6 -foreground #3B2F2F
    # Buttons
    ttk::style configure TButton -background #C19A6B -foreground #1E1A19 -borderwidth 1 -relief raised -padding {6 2}
    ttk::style map TButton -background [list active #CFB080 pressed #A67C52] -relief [list pressed sunken]
    # Menubuttons
    ttk::style configure TMenubutton -background #C19A6B -foreground #1E1A19 -borderwidth 1 -relief raised
    # Checkboxes and radiobuttons: explicit indicator colors for visibility
    ttk::style configure TCheckbutton -background #D2B48C -foreground #3B2F2F -indicatorcolor #F4E1C6
    ttk::style map TCheckbutton \
      -background [list active #D2B48C] \
      -indicatorcolor [list pressed #F4E1C6 selected #4a90d9 alternate #4a90d9]
    ttk::style configure TRadiobutton -background #D2B48C -foreground #3B2F2F -indicatorcolor #F4E1C6
    ttk::style map TRadiobutton \
      -background [list active #D2B48C] \
      -indicatorcolor [list pressed #F4E1C6 selected #4a90d9 alternate #4a90d9]
  }
}

# Create a custom "cobalt2" theme inspired by Wes Bos's popular VSCode theme
if {[lsearch -exact [ttk::style theme names] cobalt2] == -1} {
  ttk::style theme create cobalt2 -parent classic -settings {
    # Cobalt2 theme - dark blue theme inspired by Wes Bos's VSCode theme
    # Color palette: Blue #193549, Blue Dark #122738, Highlight #1F4662, Yellow #ffc600, Hot Pink #ff0088, Orange #ff9d00
    # Base/UI background and text
    ttk::style configure . \
      -background #193549 \
      -fieldbackground #122738 \
      -foreground #ffffff \
      -selectbackground #1F4662 \
      -selectforeground #ffc600
    ttk::style configure TFrame -background #193549
    ttk::style configure TLabel -background #193549 -foreground #ffffff
    ttk::style configure TNotebook -background #193549
    # Content windows (Tree view, Game List, PGN text via applyThemeStyle)
    ttk::style configure Treeview -background #122738 -fieldbackground #122738 -foreground #ffffff
    ttk::style map Treeview \
      -background [list selected #1F4662] \
      -foreground [list selected #ffc600]
    # Inputs
    ttk::style configure TEntry -fieldbackground #122738 -foreground #ffc600
    ttk::style configure TCombobox -fieldbackground #122738 -foreground #ffc600
    # Buttons
    ttk::style configure TButton -background #1F4662 -foreground #ffc600 -borderwidth 1 -relief raised -padding {6 2}
    ttk::style map TButton -background [list active #234E6D pressed #122738] -relief [list pressed sunken]
    # Menubuttons
    ttk::style configure TMenubutton -background #1F4662 -foreground #ffc600 -borderwidth 1 -relief raised
    # Checkboxes and radiobuttons: explicit indicator colors for visibility
    ttk::style configure TCheckbutton -background #193549 -foreground #ffffff -indicatorcolor #122738
    ttk::style map TCheckbutton \
      -background [list active #193549] \
      -indicatorcolor [list pressed #122738 selected #ff9d00 alternate #ff9d00]
    ttk::style configure TRadiobutton -background #193549 -foreground #ffffff -indicatorcolor #122738
    ttk::style map TRadiobutton \
      -background [list active #193549] \
      -indicatorcolor [list pressed #122738 selected #ff9d00 alternate #ff9d00]
  }
}

proc calculateTreeviewRowHeight { } {
  set row_height [expr { round(1.1 * [font metrics font_Regular -linespace]) }]
  ttk::style configure Treeview -rowheight $row_height

  set ::glistRowHeight [expr { round(1.4 * [font metrics font_Small -linespace]) }]
  ttk::style configure Gamelist.Treeview -rowheight $::glistRowHeight
}

proc updateFonts {font_name} {
  switch $font_name {
    {font_Regular} {
      set font [font actual $font_name -family]
      set fontsize [font actual $font_name -size]
      font configure font_Bold       -family $font -size $fontsize -weight bold
      font configure font_Italic     -family $font -size $fontsize -slant italic
      font configure font_BoldItalic -family $font -size $fontsize -weight bold -slant italic
      font configure font_H1 -family $font -size [expr {$fontsize + 8} ] -weight bold
      font configure font_H2 -family $font -size [expr {$fontsize + 6} ] -weight bold
      font configure font_H3 -family $font -size [expr {$fontsize + 4} ] -weight bold
      font configure font_H4 -family $font -size [expr {$fontsize + 2} ] -weight bold
      font configure font_H5 -family $font -size [expr {$fontsize + 0} ] -weight bold
    }
    {font_Small} {
      set font [font actual $font_name -family]
      set fontsize [font actual $font_name -size]
      font configure font_SmallBold -family $font -size $fontsize -weight bold
      font configure font_SmallItalic -family $font -size $fontsize -slant italic
    }
  }
  calculateTreeviewRowHeight
}

proc createFonts {} {
  font create font_Bold
  font create font_BoldItalic
  font create font_Italic
  font create font_H1
  font create font_H2
  font create font_H3
  font create font_H4
  font create font_H5

  font create font_SmallBold
  font create font_SmallItalic

  foreach {name value} [array get ::fontOptions] {
    lassign $value f sz w s
    if {$f ne ""} {
      font create font_$name -family $f -size $sz -weight $w -slant $s
    } else {
      font create font_$name {*}[font configure TkDefaultFont]
      if {$name eq "Small"} {
        font configure font_$name -size [expr {int([font actual font_$name -size] * 0.85)}]
      } elseif {$name eq "Tiny"} {
        font configure font_$name -size [expr {int([font actual font_$name -size] * 0.7)}]
      }
    }
    updateFonts font_$name
  }

  set ::utils::tooltip::font font_Small
}
createFonts

# Workaround: set the options of ttkEntry.c widgets that don't work with ttk::style
set ::themeOptions {}
proc styleOption {themeName pattern value} {
  lappend ::themeOptions [list $themeName $pattern $value]
}

# Load darktheme, must load here to have it in place if used
source -encoding utf-8 [file nativename [file join $::scidTclDir "darktheme.tcl"]]
# Load more theme
if { [file exists $::ThemePackageFile] } {
  catch { ::safeSourceStyle $::ThemePackageFile }
}

# The font for ttkEntry.c widgets cannot be set with ttk::style
option add *TCombobox*font font_Regular
option add *TEntry.font font_Regular
option add *TSpinbox.font font_Regular

# Set the menu options
# This options are used when a menu is created and when the theme is changed.
proc configure_menus {} {
  option add *Menu*TearOff 0
  if {[llength $::fontOptions(Menu)] == 4} { option add *Menu*Font font_Menu }

  if {$::unixOS} {
    set bg [ttk::style lookup . -background]
    set activeBg [ttk::style lookup . -background active]
    set disabledBg [ttk::style lookup . -background disabled]
    set fg [ttk::style lookup . -foreground]
    set activeFg [ttk::style lookup . -foreground active]
    set disabledFg [ttk::style lookup . -foreground disabled]
    
    option add *Menu.background $bg startupFile
    option add *Menu.activeBackground $activeBg startupFile
    option add *Menu.disabledBackground $disabledBg startupFile
    option add *Menu.foreground $fg startupFile
    option add *Menu.selectColor $fg startupFile
    option add *Menu.activeForeground $activeFg startupFile
    option add *Menu.disabledForeground $disabledFg startupFile
    
    # Also update existing menus (only if .menu exists)
    if {[winfo exists .menu]} {
      # Update the main menubar
      catch {
        .menu configure -background $bg -foreground $fg \
          -activebackground $activeBg -activeforeground $activeFg
      }
      
      # Update all menu widgets (recursively find all menus)
      proc update_menu_colors {menuPath bg fg activeBg activeFg disabledFg} {
        if {[winfo exists $menuPath] && [winfo class $menuPath] eq "Menu"} {
          catch {
            $menuPath configure -background $bg -foreground $fg \
              -activebackground $activeBg -activeforeground $activeFg \
              -disabledforeground $disabledFg
          }
          # Check for submenus by iterating through menu entries
          set lastIndex [$menuPath index end]
          if {$lastIndex ne "none"} {
            for {set i 0} {$i <= $lastIndex} {incr i} {
              set type [$menuPath type $i]
              if {$type eq "cascade"} {
                set submenu [$menuPath entrycget $i -menu]
                if {$submenu ne ""} {
                  update_menu_colors $submenu $bg $fg $activeBg $activeFg $disabledFg
                }
              }
            }
          }
        }
      }
      
      # Start from .menu and recurse through all submenus
      update_menu_colors .menu $bg $fg $activeBg $activeFg $disabledFg
    }
  }
}

proc configure_style {} {
  # Use default font everywhere
  ttk::style configure . -font font_Regular
  ttk::style configure Heading -font font_Regular

  # Style definitions
  ttk::style configure Bold.TCheckbutton -font font_Bold
  ttk::style configure Small.TCheckbutton -font font_Small

  ttk::style configure Small.TButton -font font_Small
  ttk::style configure Bold.TButton -font font_Bold
  ttk::style configure Pad0.Small.TButton -padding 0

  ttk::style configure Small.TRadiobutton -font font_Small
  ttk::style configure Bold.TRadiobutton -font font_Bold
  ttk::style configure SmallBold.TRadiobutton -font font_SmallBold

  ttk::style configure pad0.TMenubutton -padding 0 -indicatorwidth 0 -indicatorheight 0  -font font_Small

  ttk::style configure fieldbg.TLabel -background [ttk::style lookup . -fieldbackground "" white]

  ttk::style configure Switch.Toolbutton -padding 0

  # Some themes (e.g. vista and xpnative) use custom field elements and ignore -fieldbackground
  if {[regexp {(Combobox|Entry|Spinbox)\.(field|background)} [ttk::style element names]]} {
    ttk::style configure Error.TCombobox -foreground #b80f0a
    ttk::style configure Error.TEntry -foreground #b80f0a
    ttk::style configure Error.TSpinbox -foreground #b80f0a
  } else {
    ttk::style configure Error.TCombobox -fieldbackground #b80f0a
    ttk::style configure Error.TEntry -fieldbackground #b80f0a
    ttk::style configure Error.TSpinbox -fieldbackground #b80f0a
  }

  calculateTreeviewRowHeight

  # The ttk::combobox popdown listbox cannot be configured using ttk::style
  option add *TCombobox*Listbox.background [ttk::style lookup . -fieldbackground "" white] startupFile
  option add *TCombobox*Listbox.foreground [ttk::style lookup . -foreground] startupFile
  option add *TCombobox*Listbox.selectBackground [ttk::style lookup . -selectbackground] startupFile
  option add *TCombobox*Listbox.selectForeground [ttk::style lookup . -selectforeground] startupFile

  # Configure tooltips appearance
  ::tooltip::tooltip configure \
    -background [ttk::style lookup . -fieldbackground "" white] \
    -foreground [ttk::style lookup . -foreground]

  # Add the theme's specific options
  foreach elem [lsearch -all -inline -exact -index 0 $::themeOptions [ttk::style theme use]] {
    option add [lindex $elem 1] [lindex $elem 2]
  }

  #Load light or dark icons (if the theme name contains "dark" or is cobalt2)
  set icons_dir "icons_light"
  set theme [ttk::style theme use]
  if {[string first "dark" $theme] != -1 || $theme eq "cobalt2"} {
    set icons_dir "icons_dark"
  }
  set dname [file join $::scidImgDir $icons_dir]
  foreach {fname} [glob -directory $dname *.png] {
    set iname [string range [file tail $fname] 0 end-4]
    image create photo ::icon::$iname -format png -file $fname
  }
}
bind . <<ThemeChanged>> { if {"%W" eq "."} { configure_style } }

catch { ttk::style theme use $::lookTheme }
configure_menus


# Uses the circle and full circle unicode characters to simulate a switch button.
# Based on a ttk::checkbutton, update -text to reflect its state.
# Example:
#     ttk::checkbutton widget_name -style Switch.Toolbutton \
#         -command "::update_switch_btn widget_name"
#     ::update_switch_btn widget_name initial_value
# Return the value of the variable associated with the widget.
proc ::update_switch_btn {widget {set_value ""}} {
  set varname [$widget cget -variable]
  if {$set_value ne ""} {
    set ::$varname $set_value
  }
  if {[$widget instate selected]} {
    set full_circle [expr $::windowsOS ?"\u2B24":"\u25CF"]
    $widget configure -text "       $full_circle"
  } else {
    $widget configure -text "\u25EF       "
  }
  return [set ::$varname]
}

proc autoscrollText {bars frame widget style} {
  ttk::frame $frame
  text $widget -cursor arrow -state disabled -highlightthickness 0 -font font_Regular
  $widget tag configure header -font font_Bold
  applyThemeStyle $style $widget
  autoscrollBars $bars $frame $widget
}

# Create a text widget and apply to it the current ttk style.
# It also creates a tag "header" in the text widget.
proc ttk_text {pathName {args ""}} {
  set style Treeview
  if {[set idx [lsearch $args "-style"]] >=0} {
    set style [lindex $args [expr $idx + 1]]
    set args [lreplace $args $idx [expr $idx + 1]]
  }
  set res [text $pathName -cursor arrow -highlightthickness 0 -font font_Regular]
  if {[llength $args] > 0} {
    $pathName configure {*}$args
  }
  $pathName tag configure header -font font_Bold
  ::applyThemeStyle $style $pathName
  return $res
}

# Create a canvas and apply to it the current ttk style.
proc ttk_canvas {pathName args} {
  set res [canvas $pathName {*}$args]
  ::applyThemeStyle Treeview $pathName
  return $res
}

# Create an item into a widget (i.e. a canvas) and apply to it the current ttk style.
# TODO: find a better way to do this and re-apply when <<ThemeChanged>>
proc ttk_create {pathName type x y args} {
  if {"-fill" ni $args} {
    lappend args "-fill"
    lappend args [ttk::style lookup Treeview -foreground "" black]
  }
  $pathName create $type $x $y {*}$args
}

# Apply the theme's background color to a widget
proc applyThemeColor_background { widget } {
  set bgcolor [ttk::style lookup . -background "" #d9d9d9]
  $widget configure -background $bgcolor
  bind $widget <<ThemeChanged>> "::applyThemeColor_background $widget"
}

# Apply a ttk style to a tk widget
proc applyThemeStyle {style widget} {
  set exclude [list "-font"]
  set options [ttk::style configure .]
  lappend options {*}[ttk::style configure $style]

  foreach {option value} $options {
    if {$option in $exclude} { continue }
    catch { $widget configure $option $value }
  }
  bind $widget <<ThemeChanged>> "::applyThemeStyle $style $widget"
}

image create photo flag_unknown -data {
      iVBORw0KGgoAAAANSUhEUgAAABgAAAAMCAYAAAB4MH11AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAC4jAAAuIw
      F4pT92AAAAB3RJTUUH4wQHCTMzcDliXAAAABJJREFUOMtjYBgFo2AUjIKBBwAEjAABIobxpQAAAABJRU5ErkJggg==
}

proc getFlagImage { countryID { returnUnknowFlag no } } {
  set cflag "flag_[string tolower [string range $countryID 0 2]]"
  # preset unkown flag (empty transparent image 24x12)
  set country flag_unknown
  if { $cflag eq [info commands $cflag] } {
    # flag exists, use it
    set country $cflag
  } else {
    # flag does not exist, try to load it
    set dname [file join $::scidImgDir flags $cflag.gif]
    if { [file exists $dname] } {
      image create photo $cflag -file $dname
      set country $cflag
    } elseif { $returnUnknowFlag == "no" } {
      #no flag is needed, return nothing
      set country ""
    }
  }
  return $country
}

# Set numeric format
sc_info decimal $::locale(numeric)

# Start in the clipbase, if no database is loaded at startup.
set ::clipbase_db [sc_info clipbase]
sc_base switch $::clipbase_db
set ::curr_db [sc_base current]


set tcl_files {
language.tcl
errors.tcl
utils.tcl
utils/date.tcl
utils/font.tcl
utils/graph.tcl
utils/history.tcl
utils/pane.tcl
utils/sound.tcl
utils/string.tcl
utils/validate.tcl
utils/win.tcl
enginecfg.tcl
enginecomm.tcl
misc.tcl
htext.tcl
file.tcl
file/finder.tcl
file/bookmark.tcl
file/recent.tcl
file/spellchk.tcl
file/maint.tcl
edit.tcl
game.tcl
windows.tcl
windows/browser.tcl
windows/gamelist.tcl
windows/pgn.tcl
windows/preferences.tcl
windows/book.tcl
windows/comment.tcl
windows/eco.tcl
windows/engine.tcl
windows/stats.tcl
windows/tree.tcl
windows/crosstab.tcl
windows/pfinder.tcl
windows/tourney.tcl
windows/switcher.tcl
search/search.tcl
search/board.tcl
search/header.tcl
search/material.tcl
contrib/ezsmtp/ezsmtp.tcl
tools/import.tcl
tools/optable.tcl
tools/preport.tcl
tools/pinfo.tcl
tools/analysis.tcl
tools/wbdetect.tcl
tools/graphs.tcl
tools/ptracker.tcl
tools/twic.tcl
tools/lichess.tcl
tools/lichess_tournament.tcl
tools/chesscom.tcl
help/help.tcl
help/tips.tcl
keyboard.tcl
menus.tcl
board.tcl
move.tcl
main.tcl
tools/uci.tcl
end.tcl
tools/tacgame.tcl
tools/sergame.tcl
tools/calvar.tcl
tools/fics.tcl
tools/opening.tcl
tools/tactics.tcl
tools/reviewgame.tcl
tools/inputengine.tcl
tools/novag.tcl
tools/tablebase.tcl
tools/lichess_eval.tcl
}

foreach f $tcl_files {
  source -encoding utf-8 [file nativename [file join $::scidTclDir "$f"]]
}

###
### End of file: start.tcl
