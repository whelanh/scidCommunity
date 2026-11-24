# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later

# Create a custom "paper" theme: the warm ink-and-paper palette of the
# Omarchy "papier" color theme, available on systems that do not run Omarchy.
#
# This is the same set of style settings that ::omarchyTheme::generateScript
# (tcl/omarchy-theme.tcl) produces for that palette, so selecting this theme
# looks like selecting "Omarchy" under papier. It is a light theme, so it is
# deliberately not passed to registerDarkTheme; the toolbar keeps the
# dark-on-light icons.
if {[lsearch -exact [ttk::style theme names] paper] == -1} {
  ttk::style theme create paper -parent classic -settings {
    ttk::style configure . -background #dfdacb -fieldbackground #ebe7dc -foreground #2b2924 -selectbackground #111111 -selectforeground #dfdacb -insertcolor #2b2924 -insertbackground #2b2924 -troughcolor #d0cab7
    ttk::style configure TFrame -background #dfdacb
    ttk::style configure TLabel -background #dfdacb -foreground #2b2924
    ttk::style configure TNotebook -background #dfdacb
    ttk::style configure TNotebook.Tab -background #dfdacb -foreground #2b2924
    ttk::style map TNotebook.Tab -background [list selected #ebe7dc]
    ttk::style configure Treeview -background #d0cab7 -fieldbackground #d0cab7 -foreground #2b2924
    ttk::style map Treeview -background [list selected #111111] -foreground [list selected #dfdacb]
    ttk::style configure Heading -background #ebe7dc -foreground #2b2924 -relief flat
    ttk::style map Heading -background [list active #6b6558]
    ttk::style configure TEntry -fieldbackground #ebe7dc -foreground #2b2924
    ttk::style configure TCombobox -fieldbackground #ebe7dc -foreground #2b2924
    ttk::style configure TSpinbox -fieldbackground #ebe7dc -foreground #2b2924
    ttk::style configure TButton -background #ebe7dc -foreground #2b2924 -borderwidth 1 -relief raised -padding {6 2}
    ttk::style map TButton -background [list active #6b6558 pressed #d0cab7] -relief [list pressed sunken]
    ttk::style configure TMenubutton -background #ebe7dc -foreground #2b2924 -borderwidth 1 -relief raised
    ttk::style map TMenubutton -background [list active #6b6558 pressed #d0cab7]
    ttk::style configure Toolbutton -background #ebe7dc -foreground #2b2924 -relief flat -padding 2
    ttk::style map Toolbutton -background [list active #6b6558 pressed #111111 selected #111111] -relief [list {active !selected} raised]
    ttk::style configure TCheckbutton -background #dfdacb -foreground #2b2924 -indicatorcolor #ebe7dc
    ttk::style map TCheckbutton -background [list active #dfdacb] -indicatorcolor [list pressed #6b6558 selected #111111 alternate #111111]
    ttk::style configure TRadiobutton -background #dfdacb -foreground #2b2924 -indicatorcolor #ebe7dc
    ttk::style map TRadiobutton -background [list active #dfdacb] -indicatorcolor [list pressed #6b6558 selected #111111 alternate #111111]
    ttk::style configure TScale -troughcolor #d0cab7 -background #dfdacb
    ttk::style configure TProgressbar -troughcolor #d0cab7 -background #111111
    ttk::style configure TScrollbar -troughcolor #d0cab7 -background #6b6558
    ttk::style map TScrollbar -background [list active #111111 pressed #111111]
    ttk::style configure TLabelframe -background #dfdacb -bordercolor #6b6558
  }
}
