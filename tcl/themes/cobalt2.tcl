# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later

registerDarkTheme "cobalt2"

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
