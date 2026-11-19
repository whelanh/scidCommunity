# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
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

# The text widget of the open CQL window (there is at most one: ::search::Open
# destroys a window it is asked to open again). ::search::cqlCreateFrame sets
# it.
set ::search::cqlTextWidget ""

# ::search::cql
#   Opens the search window for a Chess Query Language query: the query typed
#   in the box is run by the CQL engine (sc_search cql, src/tkscid.cpp) and the
#   games it matches become the filter the game list shows.
#
#   The window follows the Moves search window (::search::moves in board.tcl):
#   it is built by ::search::Open, so it carries the same filter-operation
#   radiobuttons, progress bar, Defaults and Search buttons. Two consequences of
#   the engine's interface shape it:
#
#   - sc_search cql takes neither a base nor a filter. It always searches the
#     database that is current when the query runs, and it leaves its result in
#     that database's own filter ("dbfilter", the one the game list displays),
#     applying the chosen filter operation to it. The window therefore shows no
#     database combobox - one that could be set to another database would
#     silently search the wrong one - and it follows the current database even
#     if that changes while the window is open.
#   - the query is not an sc_filter option list, so the shared search path
#     (::search::start_ and ::search::do_search_) does not apply. The Search
#     buttons run ::search::cqlRun_ instead.
#
#   Defaults clears the building blocks and the query box and puts the filter
#   operation back to reset, as the other search windows do.
proc ::search::cql {{ref_base ""} {ref_filter "dbfilter"}} {
	::search::Open $ref_base $ref_filter SearchCQL ::search::cqlCreateFrame

	set w .wnd_SearchCQL

	# The window is always built fresh, so it starts with no blocks ticked and
	# an empty query even if the last window was closed with a query in it.
	::search::cqlKitReset

	# See the comment above: the query runs against the current database.
	grid remove $w.refdb

	# The shared frame's Invert would have to negate a CQL match, which the
	# engine cannot do (it only ever adds the games a query matches), and its
	# "Search (new filter)" means the same search into a new game list.
	grid remove $w.buttons.invert
	$w.buttons.search configure -command [list ::search::cqlRun_ $w 0]
	$w.buttons.search_new configure -command [list ::search::cqlRun_ $w 1]

	# A query spans several lines, so Return must insert a newline in the box
	# rather than press Search from the toplevel binding ::search::Open set.
	bind $w <Return> {}
	# The break must sit at the top level of the binding script: inside a proc
	# (or apply) body it raises "invoked \"break\" outside of a loop", which Tk
	# routes to bgerror. Its job is to stop the Text class binding inserting a
	# newline.
	bind $w.options.query.text <Control-Return> \
		"[list ::search::cqlRun_ $w 0]; break"

	focus $w.options.query.text
}

# ::search::cqlCreateFrame
#   Builds the window's own widgets: the query box and the line that reports
#   how the last query ended. Returns the command ::search::Open evaluates for
#   the window's options.
proc ::search::cqlCreateFrame {w} {
	grid columnconfigure $w 0 -weight 1

	# The building blocks write the query into the box below. They are the
	# window's main control surface, so they sit above it.
	::search::cqlKitFrame $w

	ttk::labelframe $w.query -text [::tr CQLQuery]
	grid $w.query -row 1 -column 0 -sticky news -pady 6
	grid columnconfigure $w.query 0 -weight 1
	grid rowconfigure $w.query 0 -weight 1

	text $w.query.text -height 10 -width 52 -wrap word -undo 1 \
		-yscrollcommand [list $w.query.ys set]
	ttk::scrollbar $w.query.ys -orient vertical \
		-command [list $w.query.text yview]
	grid $w.query.text -row 0 -column 0 -sticky nsew -padx 4 -pady 4
	grid $w.query.ys -row 0 -column 1 -sticky ns -pady 4

	ttk::label $w.query.hint -text [::tr CQLQueryHint] -justify left \
		-wraplength 380
	grid $w.query.hint -row 1 -column 0 -columnspan 2 -sticky w -padx 4 \
		-pady "0 4"

	ttk::label $w.query.status -text "" -anchor w -wraplength 380
	grid $w.query.status -row 2 -column 0 -columnspan 2 -sticky w -padx 4 \
		-pady "0 4"

	set ::search::cqlTextWidget $w.query.text
	bind $w.query.text <<Modified>> {::search::cqlKitSay; %W edit modified 0}
	return "::search::cqlOptions"
}

# ::search::cqlOptions
#   The window's option list - the query as the engine reads it - and, with
#   "reset" (what the window's Defaults button evaluates), the window's own
#   reset: an empty query box.
proc ::search::cqlOptions {{cmd ""}} {
	if {$cmd eq "reset"} {
		::search::cqlKitReset
		return
	}
	return [list [list cql [::search::cqlQuery]]]
}

# ::search::cqlQuery
#   The query currently in the box, without the surrounding blank space (the
#   Text widget always ends in a newline).
proc ::search::cqlQuery {} {
	if {$::search::cqlTextWidget eq ""
			|| ![winfo exists $::search::cqlTextWidget]} {
		return ""
	}
	return [string trim [$::search::cqlTextWidget get 1.0 end]]
}

# ::search::cqlRun_
#   Runs the query in the box. @new_filter opens the result in a new game list
#   instead of updating the one the database filter belongs to.
#
#   An empty box and a query the engine rejects are both reported: the first in
#   a message box because there is nothing to search, the second with the
#   engine's own message ("error (line N) ..."), never with a Tcl trace.
proc ::search::cqlRun_ {w {new_filter 0}} {
	set status $w.options.query.status
	set query [::search::cqlQuery]

	if {$query eq ""} {
		$status configure -text [::tr CQLQueryEmpty]
		tk_messageBox -parent $w -title [::tr SearchCQL] -type ok -icon info \
			-message [::tr CQLQueryEmpty]
		focus $w.options.query.text
		return
	}

	# sc_search cql searches the current database and fills its filter.
	set dbase [sc_base current]
	set err [catch {
		::search::progressbar_ $w show
		set result [sc_search cql $::search::filterOp_($w) 0 0 $query]
	} result]
	catch { ::search::progressbar_ $w hide }

	if {$err} {
		$status configure -text $result
		# The database filter is what this window shows. Report it even when
		# the search failed: sc_search cql leaves the filter untouched on a
		# failed or cancelled query, but the window must follow the database
		# wherever it ends up rather than keep showing the filter it had
		# before the query ran.
		set ::search::dbase_($w) $dbase
		set ::search::filter_($w) dbfilter
		::notify::filter $dbase dbfilter
		::search::refresh_ $w
		if {$::errorCode ne $::ERROR::UserCancel} {
			tk_messageBox -parent $w -title [::tr SearchCQL] -type ok \
				-icon warning \
				-message "[::tr CQLSearchFailed]\n$result"
		}
		return
	}

	# The result is in the database's own filter, so that is the filter this
	# window searches and the one ::notify::filter hands to the game list.
	# The current database may have changed since the window was opened.
	set ::search::dbase_($w) $dbase
	set ::search::filter_($w) dbfilter
	::notify::filter $dbase dbfilter

	if {$new_filter} {
		# A list of its own, so the next query - which rewrites the database
		# filter - leaves this result alone.
		set dest [sc_filter new $dbase]
		sc_filter copy $dbase $dest dbfilter
		::windows::gamelist::Open $dbase $dest
	}

	# sc_search cql returns its statistics line and the number of games whose
	# record could not be read. Say so rather than losing them silently: on a
	# large database a few damaged games would otherwise just shrink the count.
	lassign $result stats skipped
	set result $stats
	if {$skipped > 0} {
		append result "  ([format [::tr CQLUnreadableGames] $skipped])"
	}

	$status configure -text $result
	::search::refresh_ $w
}

# ----------------------------------------------------------------------
# End of file: cql.tcl
# ----------------------------------------------------------------------
