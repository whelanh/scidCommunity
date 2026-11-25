# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later

# Create a custom "green-tones" theme: the celadon and carved-jade palette of
# the Omarchy "jade-crane-light" color theme, available on systems that do not
# run Omarchy.
#
# This is the same set of style settings that ::omarchyTheme::generateScript
# (tcl/omarchy-theme.tcl) produces for that palette, so selecting this theme
# looks like selecting "Omarchy" under jade-crane-light. It is a light theme,
# so it is deliberately not passed to registerDarkTheme; the toolbar keeps the
# dark-on-light icons.
if {[lsearch -exact [ttk::style theme names] green-tones] == -1} {
  ttk::style theme create green-tones -parent classic -settings {
    ttk::style configure . -background #f0efe6 -fieldbackground #e8ebe3 -foreground #1e3a2f -selectbackground #2f7a56 -selectforeground #f0efe6 -insertcolor #1e3a2f -insertbackground #1e3a2f -troughcolor #e3e2d6
    ttk::style configure TFrame -background #f0efe6
    ttk::style configure TLabel -background #f0efe6 -foreground #1e3a2f
    ttk::style configure TNotebook -background #f0efe6
    ttk::style configure TNotebook.Tab -background #f0efe6 -foreground #1e3a2f
    ttk::style map TNotebook.Tab -background [list selected #e8ebe3]
    ttk::style configure Treeview -background #e3e2d6 -fieldbackground #e3e2d6 -foreground #1e3a2f
    ttk::style map Treeview -background [list selected #2f7a56] -foreground [list selected #f0efe6]
    ttk::style configure Heading -background #e8ebe3 -foreground #1e3a2f -relief flat
    ttk::style map Heading -background [list active #7a8e83]
    ttk::style configure TEntry -fieldbackground #e8ebe3 -foreground #1e3a2f
    ttk::style configure TCombobox -fieldbackground #e8ebe3 -foreground #1e3a2f
    ttk::style configure TSpinbox -fieldbackground #e8ebe3 -foreground #1e3a2f
    ttk::style configure TButton -background #e8ebe3 -foreground #1e3a2f -borderwidth 1 -relief raised -padding {6 2}
    ttk::style map TButton -background [list active #7a8e83 pressed #e3e2d6] -relief [list pressed sunken]
    ttk::style configure TMenubutton -background #e8ebe3 -foreground #1e3a2f -borderwidth 1 -relief raised
    ttk::style map TMenubutton -background [list active #7a8e83 pressed #e3e2d6]
    ttk::style configure Toolbutton -background #e8ebe3 -foreground #1e3a2f -relief flat -padding 2
    ttk::style map Toolbutton -background [list active #7a8e83 pressed #2f7a56 selected #2f7a56] -relief [list {active !selected} raised]
    ttk::style configure TCheckbutton -background #f0efe6 -foreground #1e3a2f -indicatorcolor #e8ebe3
    ttk::style map TCheckbutton -background [list active #f0efe6] -indicatorcolor [list pressed #7a8e83 selected #2f7a56 alternate #2f7a56]
    ttk::style configure TRadiobutton -background #f0efe6 -foreground #1e3a2f -indicatorcolor #e8ebe3
    ttk::style map TRadiobutton -background [list active #f0efe6] -indicatorcolor [list pressed #7a8e83 selected #2f7a56 alternate #2f7a56]
    ttk::style configure TScale -troughcolor #e3e2d6 -background #f0efe6
    ttk::style configure TProgressbar -troughcolor #e3e2d6 -background #2f7a56
    ttk::style configure TScrollbar -troughcolor #e3e2d6 -background #7a8e83
    ttk::style map TScrollbar -background [list active #2f7a56 pressed #2f7a56]
    ttk::style configure TLabelframe -background #f0efe6 -bordercolor #7a8e83
  }
}
