registerDarkTheme "dracula"

if {[lsearch -exact [ttk::style theme names] dracula] == -1} {
  ttk::style theme create dracula -parent classic -settings {
    # Base/UI background and text
    ttk::style configure . -background #282a36 -fieldbackground #44475a -foreground #f8f8f2 -selectbackground #bd93f9 -selectforeground #282a36
    ttk::style configure TFrame -background #282a36
    ttk::style configure TLabel -background #282a36 -foreground #f8f8f2
    ttk::style configure TNotebook -background #282a36

    # Content windows
    ttk::style configure Treeview -background #21222c -fieldbackground #21222c -foreground #f8f8f2
    ttk::style map Treeview -background [list selected #bd93f9] -foreground [list selected #282a36]

    # Inputs
    ttk::style configure TEntry -fieldbackground #44475a -foreground #f8f8f2
    ttk::style configure TCombobox -fieldbackground #44475a -foreground #f8f8f2

    # Buttons
    ttk::style configure TButton -background #44475a -foreground #f8f8f2 -borderwidth 1 -relief raised -padding {6 2}
    ttk::style map TButton -background [list active #6272a4 pressed #ff79c6] -relief [list pressed sunken]

    # Menubuttons
    ttk::style configure TMenubutton -background #44475a -foreground #f8f8f2 -borderwidth 1 -relief raised

    # Checkboxes & Radiobuttons
    ttk::style configure TCheckbutton -background #282a36 -foreground #f8f8f2 -indicatorcolor #44475a
    ttk::style map TCheckbutton -background [list active #282a36] -indicatorcolor [list pressed #6272a4 selected #bd93f9 alternate #bd93f9]
    ttk::style configure TRadiobutton -background #282a36 -foreground #f8f8f2 -indicatorcolor #44475a
    ttk::style map TRadiobutton -background [list active #282a36] -indicatorcolor [list pressed #6272a4 selected #bd93f9 alternate #bd93f9]
  }
}
