registerDarkTheme "dark"

#
# Copyright (C) 2020 Uwe Klimmek
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

### Implements a "dark" theme.

if {[lsearch -exact [ttk::style theme names] dark] == -1} {
  ttk::style theme create dark -parent clam -settings {
    set basecol DodgerBlue3 ;# Alternative: #3b6dce Basecolor, change here to have new topic for the theme
    # -------------------------------------------------------------------------
    # Theme defaults
    ttk::style configure "." \
        -foreground #e0e0e0 \
        -background #323232 \
        -darkcolor #222222 \
        -lightcolor #656669 \
        -troughcolor #353639 \
        -selectbackground $basecol \
        -selectforeground #ffffff \
        -activebackground $basecol \
        -activeforeground #ffffff \
        -indicatorbackground #1e1e1e \
        -indicatorforeground #e0e0e0 \
        -fieldbackground #1e1e1e \
        -bordercolor #292929 \
        -selectborderwidth 0 \
        -arrowcolor #e0e0e0 \
        -insertcolor #e0e0e0 \
        -insertbackground #e0e0e0 \
    ;

    ttk::style map "." \
        -foreground [list \
            disabled #a0a0a0] \
        -background [list \
            active $basecol] \
        -fieldbackground [list \
            disabled #323232] \
        -indicatorbackground [list \
            pressed #323232 \
            alternate #a0a0a0 \
            disabled #323232] \
        -indicatorforeground [list \
            disabled #a0a0a0] \
        -arrowcolor [list \
            disabled #a0a0a0] \
    ;

    set borders [list disabled #292929 {active pressed} $basecol \
                {disabled selected} #292929 {pressed selected} $basecol pressed $basecol \
                {active selected} $basecol active $basecol selected $basecol focus $basecol ]
    set buttonborder [list disabled #292929 {active pressed} $basecol \
                {disabled selected} #292929 {pressed selected} $basecol pressed $basecol \
                {active selected} $basecol active $basecol selected $basecol ]
    set buttonsbg [list disabled #353639 pressed #2b2b2e \
                active #4b4b4e ]

    ttk::style configure TButton \
        -anchor center \
        -relief raised \
        -padding 4 \
        -background #3b3b3e \
    ;
    ttk::style map TButton \
        -bordercolor $buttonborder \
        -background $buttonsbg \
    ;

    ttk::style configure TMenubutton \
        -anchor center \
        -padding 4 \
        -relief raised \
        -background #3b3b3e \
    ;
    ttk::style map TMenubutton \
        -bordercolor $borders \
        -background $buttonsbg \
    ;

    ttk::style configure Toolbutton \
        -anchor center \
        -padding 2 \
        -relief flat \
    ;
    ttk::style map Toolbutton \
        -relief [list \
            {active !selected} raised] \
        -bordercolor $borders \
        -foreground [list \
            disabled #a0a0a0] \
        -background [list \
            pressed $basecol \
            selected $basecol \
            active #222222] \
        -lightcolor [list pressed $basecol] \
        -darkcolor [list pressed $basecol] \
    ;

    ttk::style configure TCheckbutton \
        -padding 2
    ;
    ttk::style configure TRadiobutton \
        -padding 2
    ;

    ttk::style configure TCombobox \
        -anchor center \
        -padding 1 \
        -insertwidth 1 \
        -relief raised \
        -borderwidth 1 \
    ;
    ttk::style map TCombobox \
        -bordercolor $borders \
        -background $buttonsbg \
        -lightcolor $borders \
    ;

    ttk::style configure TEntry \
        -foreground #ffffff \
        -padding 1 \
        -insertwidth 1 \
    ;
    ttk::style map TEntry \
        -bordercolor $borders \
        -lightcolor $borders \
    ;

    ttk::style configure TSpinbox \
        -arrowsize 12 \
        -padding {2 0 10 0} \
    ;
    ttk::style map TSpinbox \
        -bordercolor $borders \
        -background $buttonsbg \
        -arrowcolor [list \
            disabled #a0a0a0] \
    ;

    ttk::style configure TScale \
        -troughcolor #353639 \
    ;
    ttk::style map TScale \
        -bordercolor [list \
            active $basecol] \
    ;

    ttk::style configure TNotebook.Tab \
        -padding {6 2 6 2} \
    ;
    ttk::style map TNotebook.Tab \
        -padding [list \
            selected {6 4 6 2}] \
        -background [list \
            selected #323232 \
            {} #1e1e1e] \
        -lightcolor [list \
            selected #656669 \
            {} #555659] \
    ;

    ttk::style configure TPanedwindow \
        -sashrelief raised \
    ;

    ttk::style configure TLabelframe \
        -bordercolor #a5a6a9 \
        -relief raised \
        -padding 4 \
    ;

    ttk::style configure TProgressbar \
        -background $basecol \
    ;

    ttk::style configure TScrollbar \
        -arrowsize 10 -width 10 \
        -troughcolor #1e1e1e \
        -bordercolor #1e1e1e \
        -background #353639 \
    ;
    ttk::style map TScrollbar \
        -background [list \
            pressed #656669 \
            active #656669 \
            disabled #353639 \
            !pressed #4b4b4e] \
        -lightcolor [list \
            pressed #222222 \
            active #656669 \
            disabled #353639 \
            !pressed #4b4b4e] \
        -darkcolor [list \
            pressed #656669 \
            active #222222 \
            disabled #353639 \
            !pressed #4b4b4e] \
    ;
    # Remove arrows
    ttk::style layout Vertical.TScrollbar {
        Vertical.Scrollbar.trough -sticky news -children {
            Vertical.Scrollbar.thumb -expand true
        }
    }
    ttk::style layout Horizontal.TScrollbar {
        Horizontal.Scrollbar.trough -sticky news -children {
            Horizontal.Scrollbar.thumb -expand true
        }
    }

    ttk::style configure Heading \
        -relief raised \
    ;
    ttk::style map Heading \
        -bordercolor $buttonborder \
        -background $buttonsbg \
    ;

    ttk::style configure Treeview \
        -relief flat \
        -bordercolor #1e1e1e \
        -lightcolor #1e1e1e \
        -background #1e1e1e \
    ;
    ttk::style map Treeview \
        -background [list \
            selected $basecol \
            disabled #222222] \
        -foreground [list \
            selected #ffffff] \
    ;
  }
}
