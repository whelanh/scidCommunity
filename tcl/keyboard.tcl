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

# Quit the application. The File menu advertises Ctrl+Q; a Tk menu accelerator
# is display-only, so the key must be bound explicitly. The binding is on the
# "all" tag rather than on the main window so that it also works from undocked
# windows (e.g. an undocked board) and from dialog boxes, whose bindtags do not
# include ".". Ctrl+Q is not used for text editing.
bind all <Control-q> { ::file::Exit }

proc keyboardShortcuts {w} {
	# Go back/forward
	bind $w <Left>  { excludeTextWidget %W; ::move::Back }
	bind $w <Right> { excludeTextWidget %W; ::move::Forward }
	bind $w <Up>    { excludeTextWidget %W; ::move::ExitVariationToMainline }
	bind $w <Down>  { excludeTextWidget %W; ::move::EnterFirstVariation }
	bind $w <Home>  { excludeTextWidget %W; ::move::ExitVarOrStart }
	bind $w <End>   { excludeTextWidget %W; ::move::End }

	# Load game
	bind $w <Control-Shift-Up>   { excludeTextWidget %W; ::game::LoadNextPrev first }
	bind $w <Control-Up>         { excludeTextWidget %W; ::game::LoadNextPrev previous }
	bind $w <Control-Down>       { excludeTextWidget %W; ::game::LoadNextPrev next }
	bind $w <Control-Shift-Down> { excludeTextWidget %W; ::game::LoadNextPrev last }
	bind $w <Control-question>   { excludeTextWidget %W; ::game::LoadRandom }

	# Rotate the chess board
	bind $w <period> { excludeTextWidget %W; toggleRotateBoard }

	# Insert a null move (pass), the same shortcut as ChessBase
	bind $w <Control-Alt-Key-0> { excludeTextWidget %W; addMoveUCI 0000 }

	# Open "Setup Board" dialog
	bind $w <s> { excludeTextWidget %W; ::setupBoard }

	# Open a database
	bind $w <Control-o> { ::file::Open }

	# Open the file finder
	bind $w <Control-slash> { excludeTextWidget %W; ::file::finder::Open }

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

	# Write the engine score graph and the annotations it implies into the
	# current game. Engine windows bind the same key to their own widgets.
	# Shift is named explicitly: <Control-A> also matches Ctrl+A with Caps Lock
	# on, which belongs to the create-variation binding (<Control-a>).
	bind $w <Control-Shift-A> { excludeTextWidget %W; ::rapid_annotate::commit }

	# Toggle the active window between docked/undocked
	bind $w <F9> { ::win::toggleDocked %W }

	#TODO: to be checked
	bind $w <F6>	::book::open
	bind $w <F12> ::windows::game3d::toggle

	# Presentation board: a board-only window for a projector or second
	# screen. Ctrl+Shift+W toggles the window, Ctrl+Shift+F freezes it so the
	# game can be navigated without revealing the move to the audience.
	# (Ctrl+Shift+B is Search Current Board and must stay so.)
	bind $w <Control-Shift-W> ::windows::present::toggle
	bind $w <Control-Shift-F> ::windows::present::toggleFreeze
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
	set cls [winfo class $w]

	# Editable single-line / value widgets keep the key for themselves, so that
	# typing (and value selection) is not disturbed.
	if {[regexp {Entry$|Combobox$|Spinbox$} $cls]} {
		return -code continue
	}

	# A Text widget keeps the key only while it is editable (e.g. the comment
	# editor, the import window). Read-only display panes (the engine and
	# analysis output, the PGN window, ...) let the key through so the game
	# still navigates without having to click the moves pane first.
	if {[regexp {Text$} $cls]} {
		# HACK: enable binding for .pgnWin
		# TODO: replace this using the new %M (available since Tk 8.6.4)
		if {$w eq ".pgnWin.text"} {
			return 0
		}
		if {[catch {$w cget -state} state] == 0 && $state eq "normal"} {
			return -code continue
		}
	}

	# Return an explicit boolean when the key is not excluded: the <Control-x>
	# binding (keyboard.tcl) tests the result with "if {![excludeTextWidget %W]}",
	# and an empty string would raise "expected boolean value but got """.
	return 0
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
# reaches the toplevel instead. This plays the move of the board's engine, or
# of the engine window the mouse pointer is over.
bind all <space> { if {[::spacePlayGlobal]} { break } }

# Editable fields keep the spacebar for typing; in every other case <space>
# plays the engine move (see ::spacePlayGlobal). Read-only displays count as
# play areas, so the mouse pointer only chooses which engine to use - it no
# longer decides whether the key is handled. These specific bindings replace
# the generic <Key> class binding for <space>; the "break" prevents a space
# from also being inserted when a move was played.
bind TEntry <space> { if {[::spacePlayGlobal]} { break } else { ttk::entry::Insert %W " "; break } }
bind Entry  <space> { if {[::spacePlayGlobal]} { break } else { tk::EntryInsert %W " "; break } }
bind Text   <space> { if {[::spacePlayGlobal]} { break } else { tk::TextInsert %W " "; break } }

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
