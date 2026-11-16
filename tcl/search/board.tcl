# Copyright (C) 2018-2019 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
#
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.
#
# Scid is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Scid.  If not, see <http://www.gnu.org/licenses/>.

namespace eval ::search {}

# Create a search window using a common framework.
# It manages the database, the filter and the and/or/reset combination of the
# results with the previous filter's values.
# @param create_subwnd: a function that creates all the specific widgets of a
#                       search window. Should return a valid command that when
#                       evaluated returns a list of the search's options.
proc ::search::Open {ref_base ref_filter title create_subwnd} {
	set w ".wnd_$title"
	if {[winfo exists $w]} { destroy $w }
	::win::createDialog $w
	# Remove the transient/dialog hints so that tiling window managers (e.g. Niri)
	# treat this as a normal peer window: no forced float above the main window,
	# and a full title bar with close button is shown.
	catch { wm transient $w {} }
	catch { wm attributes $w -type normal }
	::setTitle $w [::tr $title]

	grid [ttk::frame $w.refdb] -sticky news
	CreateSelectDBWidget "$w.refdb" "::search::dbase_($w)" "$ref_base"
	trace add variable ::search::dbase_($w) write ::search::use_dbfilter_
	set ::search::filter_($w) $ref_filter

	# Put the search options on a vertically scrollable canvas. Some search
	# windows (notably Header Search with its "Find Games With" flags grid)
	# can grow taller than the screen; scrolling keeps the bottom buttons
	# reachable instead of having them pushed off-screen.
	grid [ttk::frame $w.optbox] -sticky news
	grid rowconfigure $w 1 -weight 1
	autoscrollBars y $w.optbox [canvas $w.optbox.canvas -highlightthickness 0 -borderwidth 0]
	::applyThemeColor_background $w.optbox.canvas
	ttk::frame $w.options
	$w.optbox.canvas create window 0 0 -window $w.options -anchor nw -tags optwin
	bind $w.options <Configure> [list ::search::updateScroll_ $w]
	bind $w.optbox.canvas <Configure> [list ::search::updateScroll_ $w]
	set options_cmd [$create_subwnd $w.options]

	grid [ttk::labelframe $w.filterOp] -sticky news -pady 8
	if {![info exists ::search::filterOp_($w)]} {
		set ::search::filterOp_($w) reset
	}
	ttk::radiobutton $w.filterOp.and   -text [::tr FilterAnd]    -variable ::search::filterOp_($w) -value and
	ttk::radiobutton $w.filterOp.or    -text [::tr FilterOr]     -variable ::search::filterOp_($w) -value or
	ttk::radiobutton $w.filterOp.reset -text [::tr FilterIgnore] -variable ::search::filterOp_($w) -value reset
	grid $w.filterOp.and $w.filterOp.or $w.filterOp.reset -ipadx 8

	grid [ttk::frame $w.buttons] -sticky news
	
	# The Header search's fields can be saved and recalled by name. The other
	# search windows have no such fields, so they get no save control at all
	# rather than a button that is permanently disabled.
	if {$title eq "HeaderSearch"} {
		ttk::menubutton $w.buttons.presets -text [::tr Presets] -menu $w.buttons.presets.m
		menu $w.buttons.presets.m -tearoff 0
		$w.buttons.presets.m add command -label [::tr Save] -command [list ::search::header::prompt_save_preset]
		$w.buttons.presets.m add separator
		::search::header::rebuild_presets_menu $w
		set save_widget $w.buttons.presets
	} else {
		set save_widget ""
	}
	
	ttk::button $w.buttons.reset_values -text [::tr Defaults] \
		-command "set ::search::filterOp_($w) reset; $options_cmd reset"
	ttk::button $w.buttons.invert -text [::tr InvertSearch] \
		-command "::search::start_ 0 $w $options_cmd 1"
	ttk::button $w.buttons.search_new -text "[tr Search] ([tr GlistNewSort] [tr Filter])" \
		-command "::search::start_ 1 $w $options_cmd"
	ttk::button $w.buttons.search -text [::tr Search] -underline 0 \
		-command "::search::start_ 0 $w $options_cmd"
	if {$save_widget eq ""} {
		grid $w.buttons.reset_values $w.buttons.invert $w.buttons.search_new $w.buttons.search -sticky w -padx "0 5"
	} else {
		grid $save_widget $w.buttons.reset_values $w.buttons.invert $w.buttons.search_new $w.buttons.search -sticky w -padx "0 5"
	}
	grid columnconfigure $w.buttons 2 -weight 1

	ttk::button $w.buttons.stop -text [::tr Stop] -command progressBarCancel
	canvas $w.progressbar -width 300 -height 20 -bg white -relief solid -border 1 -highlightthickness 0
	$w.progressbar create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
	$w.progressbar create text 295 10 -anchor e -font font_Regular -tags time
	grid $w.buttons.stop -row 0 -column 0
	grid $w.progressbar -in $w.buttons -row 0 -column 1 -columnspan 4
	progressbar_ $w hide

	bind $w <Return> "$w.buttons.search invoke"
	bind $w <Alt-s> "$w.buttons.search invoke"
	bind $w.buttons.search <Destroy> "unset ::search::dbase_($w)"
	bind $w <<NotifyFilter>> [list apply {{w} {
		lassign %d dbase filter
		if {$dbase eq $::search::dbase_($w) && $filter eq $::search::filter_($w)} {
			::search::refresh_ $w
		}
	}} $w]

	::search::refresh_ $w
	::search::updateScroll_ $w
}

# ::search::updateScroll_
#
#   Keeps the scrollable search-options canvas in sync with its content. The
#   canvas is sized to the options' natural width and, when it fits, to their
#   natural height. If the dialog would be taller than the screen the canvas is
#   capped so the whole dialog (including the buttons below it) stays visible
#   and the excess options are reached by scrolling.
proc ::search::updateScroll_ {w} {
	if {![winfo exists $w.options] || ![winfo exists $w.optbox.canvas]} { return }
	set c $w.optbox.canvas
	set cw [winfo reqwidth $w.options]
	set ch [winfo reqheight $w.options]
	if {$cw < 1} { set cw 1 }
	if {$ch < 1} { set ch 1 }
	$c configure -scrollregion [list 0 0 $cw $ch]

	# The screen-fit calculation needs every fixed widget to be laid out; the
	# configuration callbacks during construction may fire before that.
	foreach part {refdb filterOp buttons} {
		if {![winfo exists $w.$part]} { return }
	}

	# Height taken up by everything that is not the scrollable canvas
	# (including the toplevel padding and the inter-row spacing).
	set non_canvas [expr {[winfo reqheight $w] - [winfo reqheight $c]}]
	if {$non_canvas < 40} {
		# The toplevel's requested size has not been recomputed yet; fall
		# back to measuring the fixed widgets directly.
		set non_canvas 60
		foreach part {refdb filterOp buttons} {
			incr non_canvas [winfo reqheight $w.$part]
		}
	}
	set avail [expr {[winfo vrootheight $w] - $non_canvas - 40}]
	if {$avail < 120} { set avail 120 }
	if {$ch > $avail} { set ch $avail }
	$c configure -width $cw -height $ch
}

proc ::search::CloseAll {} {
	foreach {w} [array names ::search::dbase_] {
		destroy $w
	}
}

proc ::search::DatabaseModified {dbase} {
	foreach {w w_base} [array get ::search::dbase_] {
		if {$dbase == $w_base} {
			::search::refresh_ $w
		}
	}
}

proc ::search::refresh_ {w} {
	if {[catch {
		lassign [sc_filter sizes $::search::dbase_($w) $::search::filter_($w)] filterSz gameSz
	}]} {
		destroy $w
		return
	}
	set n_games [::windows::gamelist::formatFilterText $filterSz $gameSz]
	$w.filterOp configure -text "[::tr FilterOperation] ($n_games)"
}

proc ::search::use_dbfilter_ { unused1 w {unused2 ""} } {
	set ::search::filter_($w) dbfilter
}

proc ::search::progressbar_ {w show_hide} {
	if {$show_hide eq "show"} {
		if {[winfo exists $w.buttons.presets]} {
			grid remove $w.buttons.presets
		}
		grid remove $w.buttons.reset_values
		grid remove $w.buttons.search_new
		grid remove $w.buttons.search
		grid $w.progressbar
		progressBarSet $w.progressbar 301 21
		grid $w.buttons.stop
		grab $w.buttons.stop
	} else {
		grab release $w.buttons.stop
		grid remove $w.buttons.stop
		grid remove $w.progressbar
		if {[winfo exists $w.buttons.presets]} {
			grid $w.buttons.presets
		}
		grid $w.buttons.reset_values
		grid $w.buttons.search_new
		grid $w.buttons.search
	}
}

proc ::search::start_ {new_filter w options_cmd {invert_search 0}} {
	set dbase $::search::dbase_($w)
	set src_filter $::search::filter_($w)
	set src_op $::search::filterOp_($w)

	lassign [$options_cmd] options ignore_color_hack

	if {$invert_search} {
		set temp_filter [sc_filter new $dbase]
		
		# do_search_ with 'reset' computes the exact pure match into temp_filter
		set err [catch {::search::do_search_ $dbase $temp_filter "reset" $options "::search::progressbar_ $w show"}]
		if {$err} {
			sc_filter release $dbase $temp_filter
			::search::progressbar_ $w hide
			if {$::errorCode != $::ERROR::UserCancel} { ERROR::MessageBox }
			return
		}

		if {$ignore_color_hack ne ""} {
			set filter_hack [sc_filter new $dbase]
			set err [catch {::search::do_search_ $dbase $filter_hack "reset" $ignore_color_hack "::search::progressbar_ $w show"}]
			if {$err} {
				sc_filter release $dbase $filter_hack
				sc_filter release $dbase $temp_filter
				::search::progressbar_ $w hide
				if {$::errorCode != $::ERROR::UserCancel} { ERROR::MessageBox }
				return
			}
			sc_filter or $dbase $temp_filter $filter_hack
			sc_filter release $dbase $filter_hack
		}
		
		::search::progressbar_ $w hide

		# Invert the pure match
		sc_filter negate $dbase $temp_filter

		# Now combine temp_filter with src_filter into dest_filter
		if {$new_filter} {
			set dest_filter [sc_filter new $dbase]
		} else {
			set dest_filter [sc_filter compose $dbase $src_filter ""]
		}

		switch $src_op {
			reset {
				sc_filter copy $dbase $dest_filter $temp_filter
			}
			and {
				sc_filter copy $dbase $dest_filter $src_filter
				sc_filter and $dbase $dest_filter $temp_filter
			}
			or {
				sc_filter copy $dbase $dest_filter $src_filter
				sc_filter or $dbase $dest_filter $temp_filter
			}
		}

		sc_filter release $dbase $temp_filter

	} else {
		if {$new_filter} {
			set dest_filter [sc_filter new $dbase]
		} else {
			set dest_filter [sc_filter compose $dbase $src_filter ""]
		}
		if {$dest_filter ne $src_filter && $src_op ne "reset"} {
			sc_filter copy $dbase $dest_filter $src_filter
		}

		if {$ignore_color_hack ne ""} {
			set filter_hack [sc_filter new $dbase]
			sc_filter copy $dbase $filter_hack $dest_filter
		}

		set err [catch {::search::do_search_ $dbase $dest_filter $src_op $options "::search::progressbar_ $w show"}]
		::search::progressbar_ $w hide
		if {$err} {
			if {$::errorCode != $::ERROR::UserCancel} { ERROR::MessageBox }
		}

		if {!$err && $ignore_color_hack ne ""} {
			set err [catch {::search::do_search_ $dbase $filter_hack $src_op $ignore_color_hack "::search::progressbar_ $w show"}]
			::search::progressbar_ $w hide
			if {$err} {
				if {$::errorCode != $::ERROR::UserCancel} { ERROR::MessageBox }
			} else {
				sc_filter or $dbase $dest_filter $filter_hack
			}
		}
		if {$ignore_color_hack ne ""} {
			sc_filter release $dbase $filter_hack
		}
	}


	set ::search::filter_($w) $dest_filter
	::notify::filter $dbase $dest_filter

	if {$new_filter} {
		::windows::gamelist::Open $dbase $dest_filter
	}
}

proc ::search::do_search_ {dbase filter filter_op options reset_progressbar} {
	switch $filter_op {
		reset {
			sc_filter reset $dbase $filter full
		}
		and {
		}
		or {
			set or_filter [sc_filter new $dbase]
			sc_filter copy $dbase $or_filter $filter
			sc_filter negate $dbase $filter
		}
	}

	set tag_pairs [lsearch -all -inline -index 0 -exact $options "-tag_pair"]
	if {[llength tag_pairs] > 0} {
		set options [lsearch -all -inline -index 0 -not -exact $options "-tag_pair"]
	}

	{*}$reset_progressbar
	sc_filter search $dbase $filter {*}$options -filter AND
	foreach {elem} $tag_pairs {
		{*}$reset_progressbar
		lassign $elem -> tagName tagValue
		sc_filter search $dbase $filter tags $tagName $tagValue
	}

	if {[info exists or_filter]} {
		sc_filter or $dbase $filter $or_filter
		sc_filter release $dbase $or_filter
	}
}


# ::search::board
#   Opens the search window for the current board position.
#
proc ::search::board {{ref_base ""} {ref_filter "dbfilter"}} {
	::search::Open $ref_base $ref_filter BoardSearch ::search::boardCreateFrame
}

proc ::search::boardCreateFrame {w} {
	if {![info exists ::search::boardOptType_]} {
		::search::boardOptions reset
	}

	ttk::labelframe $w.pos -text [::tr SearchType]
	grid $w.pos -sticky news -pady 6
	grid columnconfigure $w 0 -weight 1

	ttk::radiobutton $w.pos.exact -textvar ::tr(SearchBoardExact)  -variable ::search::boardOptType_ -value Exact
	ttk::radiobutton $w.pos.pawns -textvar ::tr(SearchBoardPawns)  -variable ::search::boardOptType_ -value Pawns
	ttk::radiobutton $w.pos.files -textvar ::tr(SearchBoardFiles)  -variable ::search::boardOptType_ -value Fyles
	ttk::radiobutton $w.pos.material -textvar ::tr(SearchBoardAny) -variable ::search::boardOptType_ -value Material
	grid $w.pos.exact -sticky w
	grid $w.pos.pawns -sticky w
	grid $w.pos.files -sticky w
	grid $w.pos.material -sticky w

	ttk::checkbutton $w.vars -text [::tr LookInVars] -variable ::search::boardOptInVars_ -onvalue 1 -offvalue 0
	grid $w.vars -sticky w

	ttk::checkbutton $w.flip -text [::tr IgnoreColors] -variable ::search::boardOptIgnoreCol_ -onvalue 1 -offvalue 0
	grid $w.flip -sticky w

	return "::search::boardOptions"
}

proc ::search::boardOptions {{cmd ""}} {
	if {$cmd eq "reset"} {
		set ::search::boardOptType_ Exact
		set ::search::boardOptInVars_ 0
		set ::search::boardOptIgnoreCol_ 0
		return
	}

	set options {board}
	lappend options $::search::boardOptType_
	lappend options $::search::boardOptInVars_
	lappend options $::search::boardOptIgnoreCol_
	return [list $options]
}

# ::search::moves
#   Opens the search window for a sequence of moves: the games whose main line
#   contains the moves, in order, from a position where the chosen side is to
#   move. "?" matches any single move, and the query may be pasted as notation
#   ("1. e4 e5 2. Nf3") -- the move numbers are stripped.
#
proc ::search::moves {{ref_base ""} {ref_filter "dbfilter"}} {
	::search::Open $ref_base $ref_filter SearchMoves ::search::movesCreateFrame
}

proc ::search::movesCreateFrame {w} {
	if {![info exists ::search::movesOptText_]} {
		::search::movesOptions reset
	}

	ttk::labelframe $w.moves -text [::tr Moves]
	grid $w.moves -sticky news -pady 6
	grid columnconfigure $w.moves 0 -weight 1
	ttk::entry $w.moves.text -textvariable ::search::movesOptText_
	grid $w.moves.text -sticky news -padx 4 -pady 4
	ttk::label $w.moves.hint -text [::tr MovesSearchHint] -justify left \
		-wraplength 380
	grid $w.moves.hint -sticky w -padx 4 -pady "0 4"

	ttk::labelframe $w.side -text [::tr SideToMove]
	grid $w.side -sticky news -pady 6
	ttk::radiobutton $w.side.white -text [::tr White] \
		-variable ::search::movesOptSide_ -value w
	ttk::radiobutton $w.side.black -text [::tr Black] \
		-variable ::search::movesOptSide_ -value b
	ttk::radiobutton $w.side.both -text [::tr Both] \
		-variable ::search::movesOptSide_ -value wb
	grid $w.side.white $w.side.black $w.side.both -sticky w -padx 4

	ttk::checkbutton $w.mate -text [::tr LastMoveIsMate] \
		-variable ::search::movesOptMate_ -onvalue 1 -offvalue 0
	grid $w.mate -sticky w

	return "::search::movesOptions"
}

proc ::search::movesOptions {{cmd ""}} {
	if {$cmd eq "reset"} {
		set ::search::movesOptText_ ""
		set ::search::movesOptSide_ wb
		set ::search::movesOptMate_ 0
		return
	}

	# Accept a pasted line of notation: drop the move numbers ("1." "2..."),
	# brace comments, evaluation NAGs ("$1") and the result token ("1-0", "*"),
	# which are not moves and would otherwise make the search find nothing.
	set text [regsub -all {\{[^\}]*\}} $::search::movesOptText_ ""]
	set moves {}
	foreach token [regexp -all -inline {\S+} [string trim $text]] {
		regsub {^\d+\.+} $token {} token
		if {$token eq "" || $token eq "*" || [regexp {^\d+(?:/\d+)?-\d+(?:/\d+)?$|^\$\d+$} $token]} {
			continue
		}
		lappend moves $token
	}

	set options [list moves $moves $::search::movesOptSide_ $::search::movesOptMate_]
	return [list $options]
}
