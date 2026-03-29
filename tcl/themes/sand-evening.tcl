# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later

# Create a custom "sand-evening" theme optimized for evening viewing
# Warmer color temperature, reduced blue light, gentler contrast
if {[lsearch -exact [ttk::style theme names] sand-evening] == -1} {
  ttk::style theme create sand-evening -parent classic -settings {
    # Sand Evening theme - optimized for low-light/evening use
    # Warmer tones, eliminated blue light, reduced contrast
    
    # Base/UI background and text
    ttk::style configure . \
      -background #CDA876 \
      -fieldbackground #F0DCC0 \
      -foreground #4A3D3D \
      -selectbackground #B8906A \
      -selectforeground #2A2220
    
    ttk::style configure TFrame -background #CDA876
    ttk::style configure TLabel -background #CDA876 -foreground #4A3D3D
    ttk::style configure TNotebook -background #CDA876
    
    # Content windows (Tree view, Game List, PGN text via applyThemeStyle)
    ttk::style configure Treeview -background #F0DCC0 -fieldbackground #F0DCC0 -foreground #4A3D3D
    ttk::style map Treeview \
      -background [list selected #B8906A] \
      -foreground [list selected #2A2220]
    
    # Inputs
    ttk::style configure TEntry -fieldbackground #F0DCC0 -foreground #4A3D3D
    ttk::style configure TCombobox -fieldbackground #F0DCC0 -foreground #4A3D3D
    
    # Buttons - warmer, softer states
    ttk::style configure TButton -background #BD9364 -foreground #2A2220 -borderwidth 1 -relief raised -padding {6 2}
    ttk::style map TButton -background [list active #CBA478 pressed #AA8158] -relief [list pressed sunken]
    
    # Menubuttons
    ttk::style configure TMenubutton -background #BD9364 -foreground #2A2220 -borderwidth 1 -relief raised
    
    # Checkboxes and radiobuttons: warm amber indicator instead of blue
    ttk::style configure TCheckbutton -background #CDA876 -foreground #4A3D3D -indicatorcolor #F0DCC0
    ttk::style map TCheckbutton \
      -background [list active #CDA876] \
      -indicatorcolor [list pressed #F0DCC0 selected #D9904A alternate #D9904A]
    
    ttk::style configure TRadiobutton -background #CDA876 -foreground #4A3D3D -indicatorcolor #F0DCC0
    ttk::style map TRadiobutton \
      -background [list active #CDA876] \
      -indicatorcolor [list pressed #F0DCC0 selected #D9904A alternate #D9904A]
  }
}
