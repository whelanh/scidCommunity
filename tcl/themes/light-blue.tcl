# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later

# Create a custom "light-blue" theme: the cool blue-grey palette of the
# Omarchy "cryogenic-orchard" color theme, available on systems that do not
# run Omarchy.
#
# This is the same set of style settings that ::omarchyTheme::generateScript
# (tcl/omarchy-theme.tcl) produces for that palette, so selecting this theme
# looks like selecting "Omarchy" under cryogenic-orchard. It is a light theme,
# so it is deliberately not passed to registerDarkTheme; the toolbar keeps the
# dark-on-light icons.
if {[lsearch -exact [ttk::style theme names] light-blue] == -1} {
  ttk::style theme create light-blue -parent classic -settings {
    ttk::style configure . -background #e4f2f2 -fieldbackground #f3fafa -foreground #233c46 -selectbackground #2a8f9a -selectforeground #e4f2f2 -insertcolor #233c46 -insertbackground #233c46 -troughcolor #d1e7e8
    ttk::style configure TFrame -background #e4f2f2
    ttk::style configure TLabel -background #e4f2f2 -foreground #233c46
    ttk::style configure TNotebook -background #e4f2f2
    ttk::style configure TNotebook.Tab -background #e4f2f2 -foreground #233c46
    ttk::style map TNotebook.Tab -background [list selected #f3fafa]
    ttk::style configure Treeview -background #d1e7e8 -fieldbackground #d1e7e8 -foreground #233c46
    ttk::style map Treeview -background [list selected #2a8f9a] -foreground [list selected #e4f2f2]
    ttk::style configure Heading -background #f3fafa -foreground #233c46 -relief flat
    ttk::style map Heading -background [list active #95b5b9]
    ttk::style configure TEntry -fieldbackground #f3fafa -foreground #233c46
    ttk::style configure TCombobox -fieldbackground #f3fafa -foreground #233c46
    ttk::style configure TSpinbox -fieldbackground #f3fafa -foreground #233c46
    ttk::style configure TButton -background #f3fafa -foreground #233c46 -borderwidth 1 -relief raised -padding {6 2}
    ttk::style map TButton -background [list active #95b5b9 pressed #d1e7e8] -relief [list pressed sunken]
    ttk::style configure TMenubutton -background #f3fafa -foreground #233c46 -borderwidth 1 -relief raised
    ttk::style map TMenubutton -background [list active #95b5b9 pressed #d1e7e8]
    ttk::style configure Toolbutton -background #f3fafa -foreground #233c46 -relief flat -padding 2
    ttk::style map Toolbutton -background [list active #95b5b9 pressed #2a8f9a selected #2a8f9a] -relief [list {active !selected} raised]
    ttk::style configure TCheckbutton -background #e4f2f2 -foreground #233c46 -indicatorcolor #f3fafa
    ttk::style map TCheckbutton -background [list active #e4f2f2] -indicatorcolor [list pressed #95b5b9 selected #2a8f9a alternate #2a8f9a]
    ttk::style configure TRadiobutton -background #e4f2f2 -foreground #233c46 -indicatorcolor #f3fafa
    ttk::style map TRadiobutton -background [list active #e4f2f2] -indicatorcolor [list pressed #95b5b9 selected #2a8f9a alternate #2a8f9a]
    ttk::style configure TScale -troughcolor #d1e7e8 -background #e4f2f2
    ttk::style configure TProgressbar -troughcolor #d1e7e8 -background #2a8f9a
    ttk::style configure TScrollbar -troughcolor #d1e7e8 -background #95b5b9
    ttk::style map TScrollbar -background [list active #2a8f9a pressed #2a8f9a]
    ttk::style configure TLabelframe -background #e4f2f2 -bordercolor #95b5b9
  }
}
