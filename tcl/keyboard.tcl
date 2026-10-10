#
# Copyright (C) 2014 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.


# CUSTOMIZATION:
# By editing this file you can customize the keyboard shortcuts,
# in order to best suit your preferences.
# It is not necessary to recompile scid after changing this file.

proc keyboardShortcuts {w} {
	# Go back/forward
	bind $w <Left>  { excludeTextWidget %W; ::move::Back }
	bind $w <Right> { excludeTextWidget %W; ::move::Forward }
	bind $w <Up>    { excludeTextWidget %W; ::move::ExitVariationToMainline }
	bind $w <Down>  { excludeTextWidget %W; ::move::EnterFirstVariation }
	bind $w <Home>  { excludeTextWidget %W; ::move::ExitVarOrStart }
	bind $w <End>   { excludeTextWidget %W; ::move::End }

	# Load game
	bind $w <Control-Up>   { excludeTextWidget %W; ::game::LoadNextPrev previous }
	bind $w <Control-Down> { excludeTextWidget %W; ::game::LoadNextPrev next }
	bind $w <Control-question> { excludeTextWidget %W; ::game::LoadRandom }

	# Rotate the chess board
	bind $w <period> { excludeTextWidget %W; toggleRotateBoard }

	# Open "Setup Board" dialog
	bind $w <s> { excludeTextWidget %W; ::setupBoard }

	# Open a database
	bind $w <Control-o> { ::file::Open }

	# Close the current database
	# TODO: is better to use control-w to close the focused window?
	bind $w <Control-w> { ::file::Close }

	# Undo
	bind $w <Control-z> { undoFeature undo }

	# Redo
	bind $w <Control-y> { undoFeature redo }

	# New game
	bind $w <Control-n> { ::game::Clear }

	# Save current game
	bind $w <Control-s> { ::gameReplace }

	# Save current game as new
	bind $w <Control-S> { ::gameAdd }

	# Toggle fullscreen
	bind $w <F11> { wm attributes . -fullscreen [expr ![wm attributes . -fullscreen]] }

	# Open the enter/create variation dialog
	# TODO: <v> is not intuitive: <space> or <up> <down> may be better
	bind $w <KeyPress-v> {
		excludeTextWidget %W
		::showVars
	}

	# Change current database
	set totalBaseSlots [sc_info limit bases]
	for {set i 1} { $i <= $totalBaseSlots} {incr i} {
		bind $w <Control-Key-$i> "::file::SwitchToBase $i"
	}

	# Open the help window
	bind $w <F1> { helpWindowPertinent %W }

	# Engines
	bind $w <F2> "::enginewin::toggleStartStop 1"
	bind $w <F3> "::enginewin::toggleStartStop 2"

	# Toggle the active window between docked/undocked
	bind $w <F9> { ::win::toggleDocked %W }

	#TODO: to be checked
	bind $w <F6>	::book::open
	bind $w <Control-Key-3> ::windows::game3d::toggle
	bind $w <Control-d> ::windows::switcher::Open
	bind $w <Control-e> "::makeCommentWin toggle"
	bind $w <Control-i> ::windows::stats::Open
	bind $w <Control-l> ::windows::gamelist::Open
	bind $w <Control-m> ::maint::OpenClose
	bind $w <Control-p> ::pgn::OpenClose
	bind $w <Control-t> ::tree::make
	bind $w <Control-E> ::windows::eco::OpenClose
	bind $w <Control-K> ::ptrack::make
	bind $w <Control-O> ::optable::makeReportWin
	bind $w <Control-P> ::plist::toggle
	bind $w <Control-T> ::tourney::toggle
	bind $w <Control-X> ::crosstab::Open
	bind $w <Control-equal> ::tablebase::window::Open
	bind $w <Control-x> { if {![excludeTextWidget %W]} { ::game::ToggleDeleteFlag } }


	#TODO: to be improved
	bind $w <Control-a> {
		excludeTextWidget %W
		sc_var create
		::notify::PosChanged -pgn
	}

	#TODO: are these shortcuts useful?
	bind $w <Control-B> ::search::board
	bind $w <Control-H> ::search::header
	bind $w <Control-M> ::search::material
	bind $w <Control-KeyPress-U> ::search:::usefile

	bind $w <Control-C> ::copyFEN
	bind $w <Control-V> ::pasteFEN
	bind $w <Control-I> importPgnGame
	bind $w <Control-D> {sc_move ply [sc_eco game ply]; updateBoard}
	bind $w <Control-G> tools::graphs::filter::Open
	bind $w <Control-J> tools::graphs::absfilter::Open
	bind $w <Control-u> ::game::GotoMoveNumber
	bind $w <Control-Y> findNovelty
	bind $w <Control-N> nameEditor
}

proc excludeTextWidget {w} {
	if { [regexp ".*(Entry|Text|Combobox|Spinbox)" [winfo class $w] ] } {
		# HACK: enable binding for .pgnWin
		# TODO: replace this using the new %M (available since Tk 8.6.4)
		if {$w ne ".pgnWin.text"} {
			return -code continue
		}
	}
}

# spaceTriggersEngineMove:
#   Returns true when a <space> keypress in widget $w should trigger the
#   "play the engine's best move" action. Controls where <space> has its own
#   meaning keep it: check/radio buttons toggle, menu buttons open their menu,
#   and single-line editable fields insert a space. Text widgets are treated
#   as display areas (the engine and analysis windows only show read-only
#   information there).
#   Plain push buttons are deliberately NOT excluded: if the engine Start/Stop
#   button (or a toolbar button) still has the keyboard focus, <space> must
#   still play the move instead of toggling the engine.
proc spaceTriggersEngineMove {w} {
	set cls [winfo class $w]
	# Use -nocase so the lower-case class names (Checkbutton, TMenubutton...)
	# are matched as well.
	if {[regexp -nocase {Checkbutton$|Radiobutton$|Menubutton$|Entry$|Combobox$|Spinbox$} $cls] || $cls eq "Menu"} {
		return 0
	}
	return 1
}

# Global fallback for the Lichess-style spacebar shortcut. The window-specific
# bind tags only fire when the keyboard focus happens to be on one of their
# widgets; right after opening a window (or when the focus is empty) the event
# reaches the toplevel instead. This plays the move of the board / engine
# window / analysis window the mouse pointer is over.
bind all <space> { if {[::spacePlayGlobal]} { break } }

# Editable fields keep the spacebar for typing, EXCEPT when the mouse pointer
# is over the board / an engine window / an analysis window, in which case
# <space> plays that engine's move. These specific bindings replace the
# generic <Key> class binding for <space>; the "break" prevents a space from
# also being inserted when a move was played.
bind TEntry <space> { if {[::spacePlayPointer]} { break } else { ttk::entry::Insert %W " "; break } }
bind Entry  <space> { if {[::spacePlayPointer]} { break } else { tk::EntryInsert %W " "; break } }
bind Text   <space> { if {[::spacePlayPointer]} { break } else { tk::TextInsert %W " "; break } }

# addBindtagToTree:
#   Add $tag to the bind tags of $w and every descendant widget.
#   A window created with ::win::createWindow is a plain frame, which can be
#   docked inside a notebook. In that case the widgets inside it do not have
#   the window itself in their bind tags, so a binding on the window widget
#   would not fire for its children. Adding an explicit tag to the whole tree
#   makes keyboard bindings work whether the window is docked or not.
proc addBindtagToTree {w tag} {
	set stack [list $w]
	while {[llength $stack]} {
		set cur [lindex $stack 0]
		set stack [lrange $stack 1 end]
		set tags [bindtags $cur]
		# bindtags may be empty for widgets using the default dynamic tags.
		if {[llength $tags] == 0} {
			set tags [list $cur [winfo class $cur] [winfo toplevel $cur] all]
		}
		if {$tag ni $tags} {
			bindtags $cur [linsert $tags 0 $tag]
		}
		set stack [concat $stack [winfo children $cur]]
	}
}
