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
	::setTitle $w [::tr $title]

	grid [ttk::frame $w.refdb] -sticky news
	CreateSelectDBWidget "$w.refdb" "::search::dbase_($w)" "$ref_base"
	trace add variable ::search::dbase_($w) write ::search::use_dbfilter_
	set ::search::filter_($w) $ref_filter

	grid [ttk::frame $w.options] -sticky news
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
	
	# Create Layouts menubutton for Header Search, or disabled Save button for others
	if {$title eq "HeaderSearch"} {
		ttk::menubutton $w.buttons.layouts -text "Layouts" -menu $w.buttons.layouts.m
		menu $w.buttons.layouts.m
		$w.buttons.layouts.m add command -label [::tr Save] -command [list ::search::header::promptSaveLayout]
		$w.buttons.layouts.m add separator
		# Populate saved layouts
		if {[info exists ::searchHeader_Layouts]} {
			foreach name $::searchHeader_Layouts {
				set m [menu $w.buttons.layouts.m.ly[string map {" " _} $name]]
				$m add command -label [::tr Load] -command "::search::header::layout_load {$name}"
				$m add command -label [::tr Delete] -command "::search::header::layout_delete {$name}; ::search::header::rebuildLayoutsMenu $w"
				$w.buttons.layouts.m add cascade -label $name -menu $m
			}
		}
		set save_widget $w.buttons.layouts
	} else {
		ttk::button $w.buttons.save -text [::tr Save] -state disabled \
			-command "::search::save_ $options_cmd"
		set save_widget $w.buttons.save
	}
	
	ttk::button $w.buttons.reset_values -text [::tr Defaults] \
		-command "set ::search::filterOp_($w) reset; $options_cmd reset"
	ttk::button $w.buttons.invert -text [::tr InvertSearch] \
		-command "::search::start_ 0 $w $options_cmd 1"
	ttk::button $w.buttons.search_new -text "[tr Search] ([tr GlistNewSort] [tr Filter])" \
		-command "::search::start_ 1 $w $options_cmd"
	ttk::button $w.buttons.search -text [::tr Search] -underline 0 \
		-command "::search::start_ 0 $w $options_cmd"
	grid $save_widget $w.buttons.reset_values $w.buttons.invert $w.buttons.search_new $w.buttons.search -sticky w -padx "0 5"
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
		if {[winfo exists $w.buttons.save]} {
			grid remove $w.buttons.save
		} elseif {[winfo exists $w.buttons.layouts]} {
			grid remove $w.buttons.layouts
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
		if {[winfo exists $w.buttons.save]} {
			grid $w.buttons.save
		} elseif {[winfo exists $w.buttons.layouts]} {
			grid $w.buttons.layouts
		}
		grid $w.buttons.reset_values
		grid $w.buttons.search_new
		grid $w.buttons.search
	}
}

proc ::search::save_ {options_cmd} {
	# TODO:
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
