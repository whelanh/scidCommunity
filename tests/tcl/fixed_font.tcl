# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# fixed_font.tcl -- font_Fixed has to stay fixed-width (#568).
#
#   xvfb-run -a wish tests/tcl/fixed_font.tcl
#
# The Tree window and both report windows lay their tables out by padding
# strings with spaces, so one character has to be one cell. A fontconfig
# substitution can answer "monospace" with a proportional face - the whole
# desktop then draws in one serif - and every column of those tables drifts.
# repairFixedFont measures the font the app actually got and swaps in the
# first family that measures equal for ten spaces and ten digits.
#
# The guard lives in tcl/start.tcl, which cannot be sourced on its own (it
# builds the application), so the two procedures are lifted out of it by
# name. A rename or a move fails the extraction loudly rather than passing.

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

# --------------------------------------------------------------- extraction --
set root [file normalize [file join [file dirname [info script]] .. ..]]
set src [file join $root tcl start.tcl]
set fh [open $src r]
set lines [split [read $fh] "\n"]
close $fh

foreach procName {repairFixedFont isFixedWidthFont} {
    # Braces in the needle would be counted by this braced body, so the
    # argument list is left to a glob instead of being spelled out.
    set start [lsearch -exact $lines "proc $procName \{\} \{"]
    if {$start < 0} {
        set start [lsearch -glob $lines "proc $procName *"]
    }
    if {$start < 0} {
        puts "FAIL cannot find $procName in $src"
        exit 1
    }
    set text ""
    for {set i $start} {$i < [llength $lines]} {incr i} {
        append text [lindex $lines $i] "\n"
        if {[info complete $text]} break
    }
    eval $text
    check "$procName was extracted" [expr {[llength [info procs $procName]] == 1}]
}

# -------------------------------------------------------------------- set-up --
# Find a family that is definitely not fixed-width, so the test does not
# depend on which fonts this display happens to have.
set proportional ""
foreach family [font families] {
    set probe [font create ::probe -family $family -size 12]
    set fixed [isFixedWidthFont ::probe]
    catch {font delete ::probe}
    if {!$fixed} {
        set proportional $family
        break
    }
}
check "a proportional family exists" [expr {$proportional ne ""}] \
    "no proportional font on this display"

if {$proportional ne ""} {
    set ::fontOptions(Fixed) [list $proportional 12 normal roman]
    font create font_Fixed -family $proportional -size 12 -weight normal -slant roman
    check "the broken font really is proportional" \
        [expr {![isFixedWidthFont font_Fixed]}]

    # What the reporter's screen looked like: a space is narrower than a digit.
    set digits [font measure font_Fixed "0000000000"]
    set spaces [font measure font_Fixed "          "]
    check "a digit is wider than a space in it" [expr {$digits > $spaces}] \
        "digits $digits spaces $spaces"

    # ---------------------------------------------------------------- repair --
    repairFixedFont
    check "font_Fixed is fixed-width after the repair" \
        [expr {[isFixedWidthFont font_Fixed]}]
    checkEq "the size came through the repair" \
        [font actual font_Fixed -size] 12
    checkEq "the weight came through the repair" \
        [font actual font_Fixed -weight] normal

    # The repair must not keep re-picking a family on every call: a second
    # pass over an already fixed font has to be a no-op.
    set chosen [font actual font_Fixed -family]
    repairFixedFont
    checkEq "a second repair keeps the chosen family" \
        [font actual font_Fixed -family] $chosen
}

# A display with no font at all, or no ::fontOptions(Fixed): nothing to do,
# and it must not raise.
catch {font delete font_Fixed}
font create font_Fixed -family [font actual TkDefaultFont -family] -size 10
unset -nocomplain ::fontOptions(Fixed)
check "no fontOptions(Fixed) is a silent no-op" [expr {[catch {repairFixedFont}] == 0}]

puts [format "%d checks, %d failures" $::checks $::fails]
exit [expr {$::fails > 0}]
