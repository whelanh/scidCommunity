# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# name_editor_wildcard.tcl -- the Name Editor's '*' wildcard.
#
#   xvfb-run -a ./scidCommunity tests/tcl/name_editor_wildcard.tcl
#
# The Name Editor replaces one exact name at a time.  A '*' in the Replace
# field is now a wildcard, so "1*" matches a prefix and "*Whelan" a suffix,
# and one Replace call changes every matching name.  This drives the built
# binary's own sc_name match/edit, including the "Games to edit" selection.

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

proc ::progressCallBack {args} {}

set tmpRoot [expr {
    [info exists ::env(TMPDIR)] ? $::env(TMPDIR) :
    ([info exists ::env(TEMP)] ? $::env(TEMP) : ".")
}]
set tmp [file join $tmpRoot "scid-wildcard-[pid]"]
catch {file delete -force $tmp}
file mkdir $tmp

set pgn [file join $tmp in.pgn]
set fh [open $pgn w]
puts $fh {[Event "Test Event"]
[Site "Dublin"]
[Date "2024.01.01"]
[Round "1"]
[White "Whelan,John"]
[Black "Smith,Alice"]
[Result "1-0"]

1. e4 e5 1-0

[Event "Test Event"]
[Site "Cork"]
[Date "2024.01.02"]
[Round "1060.1.1000"]
[White "Whelan,Peter"]
[Black "Jones,Bob"]
[Result "0-1"]

1. d4 d5 0-1

[Event "Other"]
[Site "Dublin"]
[Date "2024.01.03"]
[Round "1060.1.761"]
[White "Smith,Alice"]
[Black "Whelan,John"]
[Result "1/2-1/2"]

1. e4 c5 1/2-1/2

[Event "Test Event 2"]
[Site "Belfast"]
[Date "2024.01.04"]
[Round "2"]
[White "John Whelan"]
[Black "Bob"]
[Result "1-0"]

1. e4 e6 1-0}
close $fh

proc names {type pattern} {
    set res {}
    foreach {freq name} [sc_name match $type $pattern 1000] {
        lappend res $name
    }
    return [lsort $res]
}

proc newBase {name} {
    set file [file join $::tmp $name.si5]
    return [sc_base create SCID5 $file]
}

proc gameTag {gnum tag} {
    sc_game load $gnum
    return [sc_game tags get $tag]
}

set base [newBase main]
checkEq "imported 4 games" [sc_base import $base $pgn] "4 {}"

# ---------------------------------------------------------------- match list --
checkEq "1* is a prefix match" [names round "1*"] [lsort [list "1" "1060.1.1000" "1060.1.761"]]
checkEq "1060* narrows the prefix" [names round "1060*"] [lsort [list "1060.1.1000" "1060.1.761"]]
checkEq "*Whelan is a suffix match" [names player "*Whelan"] [list "John Whelan"]
checkEq "*Whelan* is a substring match" \
    [names player "*Whelan*"] [lsort [list "John Whelan" "Whelan,John" "Whelan,Peter"]]
checkEq "matching is case-sensitive" [names player "whelan*"] {}
checkEq "* matches every name" [expr {[llength [names event "*"]]}] 3

# ------------------------------------------------------------- player rename --
checkEq "Whelan* changes 3 games" [sc_name edit player all "Whelan*" "Whelan,Unknown"] 3
checkEq "game 1 White" [gameTag 1 White] "Whelan,Unknown"
checkEq "game 2 White" [gameTag 2 White] "Whelan,Unknown"
checkEq "game 3 Black" [gameTag 3 Black] "Whelan,Unknown"
checkEq "game 4 is untouched" [gameTag 4 White] "John Whelan"
checkEq "old names remain with zero frequency" \
    [sc_name match player "Whelan,John" 100] "0 Whelan,John"

# -------------------------------------------------------------- event rename --
checkEq "Test* changes 3 games" [sc_name edit event all "Test*" "Fixed"] 3
checkEq "game 1 Event" [gameTag 1 Event] "Fixed"
checkEq "game 4 Event" [gameTag 4 Event] "Fixed"
checkEq "game 3 Event untouched" [gameTag 3 Event] "Other"

# -------------------------------------------------------------- round rename --
checkEq "1060* changes 2 games" [sc_name edit round all "1060*" "1"] 2
checkEq "game 2 Round" [gameTag 2 Round] "1"
checkEq "game 3 Round" [gameTag 3 Round] "1"
checkEq "game 4 Round untouched" [gameTag 4 Round] "2"

# ------------------------------------------------------------ no match at all --
checkEq "a pattern with no match changes nothing" [sc_name edit event all "NoSuch*" "X"] 0
checkEq "and does not create the new name" [sc_name match event "X" 100] ""

# --------------------------------------------------- only games in the filter --
set filtered [newBase filtered]
sc_base import $filtered $pgn
sc_filter reset $filtered dbfilter full
foreach g {2 3 4} {
    sc_filter remove $filtered dbfilter $g
}
checkEq "one game in the filter" [sc_filter count] 1
checkEq "filtered wildcard changes 1 game" \
    [sc_name edit player filter "Whelan*" "OnlyOne"] 1
checkEq "filtered game changed" [gameTag 1 White] "OnlyOne"
checkEq "game outside the filter is untouched" [gameTag 2 White] "Whelan,Peter"

# -------------------------------------------- wildcard on the Rating tab's name --
set rated [newBase rated]
sc_base import $rated $pgn
checkEq "rating wildcard changes 3 games" \
    [sc_name edit rating all "Whelan*" 2500 Elo] 3
sc_game load 1
checkEq "game 1 WhiteElo" [sc_game tags get WhiteElo] 2500
sc_game load 2
checkEq "game 2 WhiteElo" [sc_game tags get WhiteElo] 2500
sc_game load 3
checkEq "game 3 BlackElo" [sc_game tags get BlackElo] 2500
sc_game load 4
checkEq "game 4 was not rated" [sc_game tags get WhiteElo] 0

foreach b {main filtered rated} {
    catch {sc_base close [set $b]}
}
catch {file delete -force $tmp}
puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
