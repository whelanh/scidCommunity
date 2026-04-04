registerDarkTheme "dracula"

#
# Copyright (C) 2020 Uwe Klimmek
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

### Implements a "dracula" theme.

namespace eval ttk::theme::dracula {
    array set colors {
        background     "#282a36"
        foreground     "#f8f8f2"
        disabledfg     "#6272a4"
        buttonbg       "#44475a"
        buttonbgdark   "#343746"
        buttonbglight  "#54576a"
        labelframe     "#6272a4"
        fieldbg        "#1e1f29"
        fieldborder    "#44475a"
        darkcolor      "#21222c"
        lightcolor     "#6272a4"
        notebookborder "#44475a"
        selectbg       "#44475a"
        selectfg       "#f8f8f2"
        through        "#21222c"
    }

    ttk::style theme create dracula -parent clam -settings {
        set basecol "#bd93f9" ;# Alternative: #ff79c6 Basecolor, change here to have new topic for the theme
        # -----------------------------------------------------------------------------
        # Theme defaults
        ttk::style configure "." \
            -foreground $colors(foreground) \
            -background $colors(background) \
            -darkcolor $colors(darkcolor) \
            -lightcolor $colors(lightcolor) \
            -troughcolor $colors(through) \
            -selectbackground $basecol \
            -selectforeground $colors(selectfg) \
            -activebackground $basecol \
            -activeforeground $colors(selectfg) \
            -indicatorbackground $colors(fieldbg) \
            -indicatorforeground $colors(foreground) \
            -fieldbackground $colors(fieldbg) \
            -bordercolor $colors(fieldborder) \
            -selectborderwidth 0 \
            -arrowcolor $colors(foreground) \
            -insertcolor $colors(foreground) \
            -insertbackground $colors(foreground) \
        ;

        ttk::style map "." \
            -foreground [list \
                disabled $colors(disabledfg)] \
            -background [list \
                active $basecol] \
            -fieldbackground [list \
                disabled $colors(background)] \
            -indicatorbackground [list \
                pressed $colors(background) \
                alternate $colors(disabledfg) \
                disabled $colors(background)] \
            -indicatorforeground [list \
                disabled $colors(disabledfg)] \
            -arrowcolor [list \
                disabled $colors(disabledfg)] \
        ;

        set borders [list disabled $colors(fieldborder) {active pressed} $basecol \
                    {disabled selected} $colors(fieldborder) {pressed selected} $basecol pressed $basecol \
                    {active selected} $basecol active $basecol selected $basecol focus $basecol ]
        set buttonborder [list disabled $colors(fieldborder) {active pressed} $basecol \
                    {disabled selected} $colors(fieldborder) {pressed selected} $basecol pressed $basecol \
                    {active selected} $basecol active $basecol selected $basecol ]
        set buttonsbg [list disabled $colors(through) pressed $colors(buttonbgdark) \
                    active $colors(buttonbglight) ]

        ttk::style configure TButton \
            -anchor center \
            -relief raised \
            -padding 4 \
            -background $colors(buttonbg) \
        ;
        ttk::style map TButton \
            -bordercolor $buttonborder \
            -background $buttonsbg \
        ;

        ttk::style configure TMenubutton \
            -anchor center \
            -padding 4 \
            -relief raised \
            -background $colors(buttonbg) \
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
                disabled $colors(disabledfg)] \
            -background [list \
                pressed $basecol \
                selected $basecol \
                active $colors(darkcolor)] \
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
            -foreground $colors(selectfg) \
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
                disabled $colors(disabledfg)] \
        ;

        ttk::style configure TScale \
            -troughcolor $colors(through) \
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
                selected $colors(background) \
                {} $colors(fieldbg)] \
            -lightcolor [list \
                selected $colors(lightcolor) \
                {} $colors(notebookborder)] \
        ;

        ttk::style configure TPanedwindow \
            -sashrelief raised \
        ;

        ttk::style configure TLabelframe \
            -bordercolor $colors(labelframe) \
            -relief raised \
            -padding 4 \
        ;

        ttk::style configure TProgressbar \
            -background $basecol \
        ;

        ttk::style configure TScrollbar \
            -arrowsize 10 -width 10 \
            -troughcolor $colors(fieldbg) \
            -bordercolor $colors(fieldbg) \
            -background $colors(through) \
        ;
        ttk::style map TScrollbar \
            -background [list \
                pressed $colors(lightcolor) \
                active $colors(lightcolor) \
                disabled $colors(through) \
                !pressed $colors(buttonbglight)] \
            -lightcolor [list \
                pressed $colors(darkcolor) \
                active $colors(lightcolor) \
                disabled $colors(through) \
                !pressed $colors(buttonbglight)] \
            -darkcolor [list \
                pressed $colors(lightcolor) \
                active $colors(darkcolor) \
                disabled $colors(through) \
                !pressed $colors(buttonbglight)] \
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
            -bordercolor $colors(fieldbg) \
            -lightcolor $colors(fieldbg) \
            -background $colors(fieldbg) \
        ;
        ttk::style map Treeview \
            -background [list \
                selected $basecol \
                disabled $colors(darkcolor)] \
            -foreground [list \
                selected $colors(selectfg)] \
        ;
    }
}
