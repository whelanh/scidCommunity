# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later

# Create a custom "light-sand" theme: the warm cream palette of the Omarchy
# "Kandis" color theme, available on systems that do not run Omarchy.
#
# This is the same set of style settings that ::omarchyTheme::generateScript
# (tcl/omarchy-theme.tcl) produces for that palette, so selecting this theme
# looks like selecting "Omarchy" under Kandis. It is a light theme, so it is
# deliberately not passed to registerDarkTheme; the toolbar keeps the
# dark-on-light icons.
if {[lsearch -exact [ttk::style theme names] light-sand] == -1} {
  ttk::style theme create light-sand -parent classic -settings {
    # Kandis palette, as read from colors.toml
    #   background          #f7efdf
    #   lighter_background  #fcf8ef
    #   dark_background     #eee2cc
    #   foreground          #2d1b10
    #   accent              #9a5216
    #   muted               #7f624a
    ttk::style configure . -background #f7efdf -fieldbackground #fcf8ef -foreground #2d1b10 -selectbackground #9a5216 -selectforeground #f7efdf -insertcolor #2d1b10 -insertbackground #2d1b10 -troughcolor #eee2cc
    ttk::style configure TFrame -background #f7efdf
    ttk::style configure TLabel -background #f7efdf -foreground #2d1b10
    ttk::style configure TNotebook -background #f7efdf
    ttk::style configure TNotebook.Tab -background #f7efdf -foreground #2d1b10
    ttk::style map TNotebook.Tab -background [list selected #fcf8ef]
    ttk::style configure Treeview -background #eee2cc -fieldbackground #eee2cc -foreground #2d1b10
    ttk::style map Treeview -background [list selected #9a5216] -foreground [list selected #f7efdf]
    ttk::style configure Heading -background #fcf8ef -foreground #2d1b10 -relief flat
    ttk::style map Heading -background [list active #7f624a]
    ttk::style configure TEntry -fieldbackground #fcf8ef -foreground #2d1b10
    ttk::style configure TCombobox -fieldbackground #fcf8ef -foreground #2d1b10
    ttk::style configure TSpinbox -fieldbackground #fcf8ef -foreground #2d1b10
    ttk::style configure TButton -background #fcf8ef -foreground #2d1b10 -borderwidth 1 -relief raised -padding {6 2}
    ttk::style map TButton -background [list active #7f624a pressed #eee2cc] -relief [list pressed sunken]
    ttk::style configure TMenubutton -background #fcf8ef -foreground #2d1b10 -borderwidth 1 -relief raised
    ttk::style map TMenubutton -background [list active #7f624a pressed #eee2cc]
    ttk::style configure Toolbutton -background #fcf8ef -foreground #2d1b10 -relief flat -padding 2
    ttk::style map Toolbutton -background [list active #7f624a pressed #9a5216 selected #9a5216] -relief [list {active !selected} raised]
    ttk::style configure TCheckbutton -background #f7efdf -foreground #2d1b10 -indicatorcolor #fcf8ef
    ttk::style map TCheckbutton -background [list active #f7efdf] -indicatorcolor [list pressed #7f624a selected #9a5216 alternate #9a5216]
    ttk::style configure TRadiobutton -background #f7efdf -foreground #2d1b10 -indicatorcolor #fcf8ef
    ttk::style map TRadiobutton -background [list active #f7efdf] -indicatorcolor [list pressed #7f624a selected #9a5216 alternate #9a5216]
    ttk::style configure TScale -troughcolor #eee2cc -background #f7efdf
    ttk::style configure TProgressbar -troughcolor #eee2cc -background #9a5216
    ttk::style configure TScrollbar -troughcolor #eee2cc -background #7f624a
    ttk::style map TScrollbar -background [list active #9a5216 pressed #9a5216]
    ttk::style configure TLabelframe -background #f7efdf -bordercolor #7f624a
  }
}
