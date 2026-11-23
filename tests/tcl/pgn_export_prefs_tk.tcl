# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# pgn_export_prefs_tk.tcl -- build the PGN Export preferences page under Tk.
#
#   wish tests/tcl/pgn_export_prefs_tk.tcl
#   xvfb-run -a wish tests/tcl/pgn_export_prefs_tk.tcl   (no display)
#
# A tclsh harness cannot see this: the page is made of widgets, and a body it
# cannot compile leaves half a page. The line-ending choice was added here for
# Issue #534 so that all three PGN format preferences (move-number spacing on
# the Moves page, tag order and line endings here) are editable in Preferences,
# and a compacted PGN database follows them.
#
# The scid environment is stubbed; nothing here touches a database.

set fails 0
set checks 0
proc check {label cond {detail ""}} {
    incr ::checks
    if {$cond} {
        puts "  ok   $label"
    } else {
        incr ::fails
        if {$detail eq ""} { puts "  FAIL $label" } else { puts "  FAIL $label -- $detail" }
    }
}
proc checkEq {label got want} {
    check $label [expr {$got eq $want}] "got '$got' want '$want'"
}

# --------------------------------------------------------------- environment --
proc tr {tag args} {
    if {[llength $args]} { return [lindex $args 0] }
    switch -- $tag {
        OptionsTagOrderWhite  { return "White rating" }
        OptionsTagOrderBlack  { return "Black rating" }
        OptionsTagOrderOthers { return "Other tags" }
        OptionsExportEol      { return "Line endings" }
        OptionsExportEolNative { return "Native" }
    }
    return $tag
}

set root [file normalize [file join [file dirname [info script]] .. ..]]

namespace eval ::pgn {}
set ::pgn::tagOrder {WhiteElo ECO Others}
set ::pgn::sortOtherTags 0
array set ::exportFlags {eol crlf}

set ::applied {}
proc ::pgn::applyTagOrder {} {
    lappend ::applied [list setTagOrder [join $::pgn::tagOrder]]
}

source [file join $root tcl windows preferences.tcl]

# ---------------------------------------------------------------- build page --
ttk::frame .page
::preferences::pgnExport .page
update

set lb .page.listf.lb
set cb .page.eol.c

# ------------------------------------------------------------------- tag order --
checkEq "the tag-order list is filled from the preference" [$lb size] 3
checkEq "its first entry is the first configured tag" [$lb get 0] "White rating"
check "the sort switch is bound to the preference" \
    [expr {[.page.sort cget -variable] eq "::pgn::sortOtherTags"}]

# ---------------------------------------------------------------- line endings --
checkEq "the line-ending combobox is labelled in the theme's words" \
    [$cb cget -values] [list "Native" CRLF LF]
checkEq "it starts on the stored choice" $::preferences::eolDisplay CRLF

set idx [lsearch -exact [$cb cget -values] "LF"]
$cb current $idx
::preferences::eolChanged $cb
checkEq "choosing LF stores lf" $::exportFlags(eol) lf

set idx [lsearch -exact [$cb cget -values] "Native"]
$cb current $idx
::preferences::eolChanged $cb
checkEq "choosing Native stores native" $::exportFlags(eol) native

# The Export dialog writes the same shared value; while this page is open the
# combobox must follow it rather than keep showing the old choice.
set ::exportFlags(eol) crlf
checkEq "an outside change refreshes the page" $::preferences::eolDisplay CRLF

# An options file may hold a value this build does not know; the page then
# shows Native rather than breaking.
set ::exportFlags(eol) ""
destroy .page
ttk::frame .page
::preferences::pgnExport .page
update
checkEq "an unknown stored choice shows Native" $::preferences::eolDisplay Native
destroy .page

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
