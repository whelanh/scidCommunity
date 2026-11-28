# Copyright (C) 2026 Tommaso Bergamasco
# SPDX-License-Identifier: GPL-2.0-or-later
#
# cb2_import.tcl -- sc_base import reads a ChessBase 2CBH database.
#
#   xvfb-run -a ./scidCommunity tests/tcl/cb2_import.tcl
#
# Builds a two-record 2CBH database byte by byte (2027 layout: 208-byte
# header records), imports it into a new SCID5 database with sc_base import,
# and checks the counts, the tags, a variation and a comment. The format
# details are covered by gtest/test_codec_cb2.cpp; this checks the binary's
# own command, which chooses the reader by the .2cbh extension.

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

# Move words of ChessBase's enumeration (pinned in gtest/test_codec_cb2.cpp).
set W(e2e4) 0xad3f
set W(e7e5) 0xb02d
set W(g1f3) 0x325f
set W(c7c5) 0xaf71
set ALT 0xfffd
set END 0xffff

# The checksum of a frame's content: byte i is the sum of the i-th of eight
# equal runs, a remainder ignored; content under 8 bytes is its own value.
proc checksum {content} {
    binary scan $content cu* bytes
    set n [llength $bytes]
    set m [expr {$n / 8}]
    set sums {}
    if {$m == 0} {
        set sums [concat $bytes [lrepeat [expr {8 - $n}] 0]]
    } else {
        for {set i 0} {$i < 8} {incr i} {
            set s 0
            foreach b [lrange $bytes [expr {$i * $m}] [expr {($i + 1) * $m - 1}]] {
                incr s $b
            }
            lappend sums [expr {$s & 0xff}]
        }
    }
    # Little-endian value, written big-endian: reverse the bytes.
    return [binary format c* [lreverse $sums]]
}

# A frame: magic, content size, spare size, checksum (big-endian), tag,
# content, trailing length.
proc frame {tag content} {
    set a [string length $content]
    return [binary format c8ii {0x88 0x77 0x66 0x55 0x44 0x33 0x22 0x11} $a 0][checksum $content][binary format s $tag]${content}[binary format w [expr {$a + 34}]]
}

proc words {list} {
    set out ""
    foreach w $list { append out [binary format s $w] }
    return $out
}

proc str {s} {
    set b [encoding convertto utf-8 $s]
    return [binary format i [string length $b]]$b
}
proc container {data size} {
    set c [binary format i [string length $data]]$data
    return $c[string repeat \0 [expr {$size - [string length $c]}]]
}

set stem [file join [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] "scid_cb2_import_[pid]"]

# .2lid: players 0 Anand, 1 Carlsen; tournament 0. Six entity types.
set sizes {96 160 16 16 16 16}
set counts {2 1 0 0 0 0}
set lid [binary format II 132 6]
foreach size $sizes count $counts {
    append lid [binary format IWW $size $count -1]
}
append lid [string repeat \0 [expr {132 - [string length $lid]}]]
set players [list [str Anand][str Viswanathan] [str Carlsen][str Magnus]]
set tournaments [list [str Chennai][str "World Championship"][binary format i [expr {(2013 << 9) | (11 << 5) | 9}]]]
for {set id 0} {$id < 2} {incr id} {
    append lid [container [lindex $players $id] 96]
    append lid [container [expr {$id < 1 ? [lindex $tournaments $id] : ""}] 160]
    foreach size {16 16 16 16} { append lid [container "" $size] }
}

# .2cbg and .2cba: 12-byte headers, then the frames.
# Game 1: 1.e4 e5 (1...c5) 2.Nf3 with "Open game." after 1.e4.
set cbg [string repeat \0 12]
set cba [string repeat \0 12]
set moves1 [string length $cbg]
append cbg [frame 1 [words [list 0xfffc $W(e2e4) $W(e7e5) $ALT $W(g1f3) $END $W(c7c5) $END]]]
set moves2 [string length $cbg]
append cbg [frame 1 [words [list 0xfffc $W(e2e4) $END]]]
set ann1 [string length $cba]
append cba [frame 0x2000 [binary format iisss 0 1 0x02 0 0][str "Open game."][binary format i 0x7fffffff]]

# .2cbh: 208-byte records (Mega Database 2027), version 6.
proc record {byte0 moves ann white black tournament result round elo1 elo2 date} {
    set r [binary format ccc $byte0 0 1][string repeat \0 5]
    append r [binary format wwwwwwww $moves $ann $white $black $tournament -1 -1 -1]
    append r [string repeat \0 [expr {0x58 - [string length $r]}]]
    append r [binary format cc $result 0][binary format ss $round 0]
    append r [string repeat \0 [expr {0x60 - [string length $r]}]]
    append r [binary format s $elo1][string repeat \0 14][binary format s $elo2]
    append r [string repeat \0 [expr {0xbc - [string length $r]}]]
    append r [binary format i $date]
    # The 16 bytes that 2027 records add: an i64 -1, then a small i64.
    append r [binary format ww -1 3]
    return $r[string repeat \0 [expr {208 - [string length $r]}]]
}
set head [string repeat \0 208]
set head [string replace $head 10 11 [binary format s 208]]
set head [string replace $head 13 13 [binary format c 6]]
set cbh $head
append cbh [record 0x00 $moves1 $ann1 0 1 0 1 6 2775 2870 [expr {(2013 << 9) | (11 << 5) | 16}]]
append cbh [record 0x80 $moves2 -1 1 0 0 2 7 0 0 0]

foreach {ext data} [list .2cbh $cbh .2cbg $cbg .2cba $cba .2lid $lid] {
    set fd [open $stem$ext wb]
    puts -nonewline $fd $data
    close $fd
}

set h [sc_base create SCID5 "${stem}_db"]
set res [sc_base import $h "${stem}.2cbh"]
lassign $res count messages
check "one game is imported, the deleted record is skipped" [expr {$count == 1}] $res
check "the summary counts the records" [string match "*2 records, 1 games read*" $messages] $messages
check "the summary names the skipped record" [string match "*Skipped 1 deleted record*" $messages] $messages
check "the database holds the game" [expr {[sc_base numGames $h] == 1}]

sc_game load 1
check "White" [expr {[sc_game tags get White] eq "Anand, Viswanathan"}] [sc_game tags get White]
check "Black" [expr {[sc_game tags get Black] eq "Carlsen, Magnus"}] [sc_game tags get Black]
check "Event" [expr {[sc_game tags get Event] eq "World Championship"}] [sc_game tags get Event]
check "Site" [expr {[sc_game tags get Site] eq "Chennai"}] [sc_game tags get Site]
check "Round" [expr {[sc_game tags get Round] eq "6"}] [sc_game tags get Round]
check "WhiteElo" [expr {[sc_game tags get WhiteElo] == 2775}] [sc_game tags get WhiteElo]
check "Date" [expr {[sc_game tags get Date] eq "2013.11.16"}] [sc_game tags get Date]
set pgn [sc_game pgn -tags 0]
check "the moves, the variation and the comment" \
    [expr {[string first "1.e4 \{Open game.\} 1...e5 ( 1...c5 ) 2.Nf3" [string map {"\n" " "} $pgn]] >= 0}] $pgn

# A .2cbh name whose files are missing is an error, not an empty import.
set h2 [sc_base create SCID5 "${stem}_db2"]
check "a missing database is an error" [catch {sc_base import $h2 "${stem}_missing.2cbh"}]
sc_base close $h2
sc_base close $h

foreach f [glob -nocomplain "${stem}*"] {
    catch {file delete -force $f}
}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
