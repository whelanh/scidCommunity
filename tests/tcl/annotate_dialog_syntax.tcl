#!/usr/bin/env tclsh
# The two procs this change edits in tcl/tools/analysis.tcl, checked without a
# display.
#
# ::configAnnotation builds a Tk dialog and ::configAnnotateOK starts the pass, so
# neither can be *run* here. What can be checked is that both are whole scripts -
# a braced proc body is only parsed when the proc is defined, so a broken edit in
# one is a bug that shows up as a missing widget rather than a load error - and
# that the new translated string exists for the label the dialog now shows.
#
# This is a syntax gate, not an acceptance test. It is itself one of the 21 tclsh
# steps of the tcl-harnesses job, as is tests/tcl/annotate_dialog.tcl (the
# decision). No CI job builds the dialog's widgets: the tk-dialogs job runs only
# the three xvfb-run wish harnesses - auto_comment_dialogs,
# review_settings_dialog, finish_game_dialog - and none of them builds
# ::configAnnotation.
set fails 0
set checks 0
set root [file normalize [file join [file dirname [info script]] .. ..]]

namespace eval ::book {}
set ::book::lastBook1 ""
# analysis.tcl asks sc_info for the engine-priority trace at load time, and
# updateBoard runs at the end of a game: the same stub game the other harnesses
# use answers both.
source [file join $root tests tcl game_stub.tcl]
if {[catch {source [file join $root tcl tools analysis.tcl]} err]} {
    puts "FAIL cannot load tcl/tools/analysis.tcl: $err"
    puts "checks $checks fails [expr {$fails + 1}]"
    exit 1
}

foreach name {::configAnnotation ::configAnnotateOK} {
    incr checks
    if {[llength [info commands $name]] == 0} {
        incr fails
        puts "FAIL $name is not defined"
        continue
    }
    set body [info body $name]
    incr checks
    if {![info complete $body]} {
        incr fails
        puts "FAIL $name is not a whole script (a block is left open)"
    }
}

# The check has teeth: a body that does not parse is reported. The broken script
# is built with escapes so this file itself still parses.
set broken "if \x7b1\x7d \x7b"
incr checks
if {[info complete $broken]} {
    incr fails
    puts "FAIL the structural check accepts a truncated body"
}

# The dialog's new note is translated, so the key has to be in the fallback
# language or the label shows a tag name.
incr checks
set fh [open [file join $root tcl lang english.tcl] r]
set english [read $fh]
close $fh
if {[string first "translate E AnnotateVariationsMainLineOnly" $english] < 0} {
    incr fails
    puts "FAIL the AnnotateVariationsMainLineOnly string is missing from english.tcl"
}

puts "checks $checks fails $fails"
exit [expr {$fails ? 1 : 0}]
