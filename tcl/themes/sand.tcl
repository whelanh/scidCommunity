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
