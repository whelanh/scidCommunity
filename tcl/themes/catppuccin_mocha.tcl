registerDarkTheme "catppuccin_mocha"

if {[lsearch -exact [ttk::style theme names] catppuccin_mocha] == -1} {
  ttk::style theme create catppuccin_mocha -parent classic -settings {
    # Base/UI background and text
    ttk::style configure . -background #1e1e2e -fieldbackground #313244 -foreground #cdd6f4 -selectbackground #cba6f7 -selectforeground #1e1e2e
    ttk::style configure TFrame -background #1e1e2e
    ttk::style configure TLabel -background #1e1e2e -foreground #cdd6f4
    ttk::style configure TNotebook -background #1e1e2e
    
    # Content windows
    ttk::style configure Treeview -background #181825 -fieldbackground #181825 -foreground #cdd6f4
    ttk::style map Treeview -background [list selected #cba6f7] -foreground [list selected #1e1e2e]
    
    # Inputs
    ttk::style configure TEntry -fieldbackground #313244 -foreground #cdd6f4
    ttk::style configure TCombobox -fieldbackground #313244 -foreground #cdd6f4
    
    # Buttons
    ttk::style configure TButton -background #313244 -foreground #cdd6f4 -borderwidth 1 -relief raised -padding {6 2}
    ttk::style map TButton -background [list active #45475a pressed #585b70] -relief [list pressed sunken]
    
    # Menubuttons
    ttk::style configure TMenubutton -background #313244 -foreground #cdd6f4 -borderwidth 1 -relief raised
    
    # Checkboxes & Radiobuttons
    ttk::style configure TCheckbutton -background #1e1e2e -foreground #cdd6f4 -indicatorcolor #313244
    ttk::style map TCheckbutton -background [list active #1e1e2e] -indicatorcolor [list pressed #45475a selected #cba6f7 alternate #cba6f7]
    ttk::style configure TRadiobutton -background #1e1e2e -foreground #cdd6f4 -indicatorcolor #313244
    ttk::style map TRadiobutton -background [list active #1e1e2e] -indicatorcolor [list pressed #45475a selected #cba6f7 alternate #cba6f7]
  }
}
