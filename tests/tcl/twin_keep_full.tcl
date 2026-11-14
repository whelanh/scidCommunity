# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# twin_keep_full.tcl -- the Twin Checker keeps the fuller/newer copy.
#
#   xvfb-run -a ./scidCommunity tests/tcl/twin_keep_full.tcl
#
# When an old commented copy and a newer stripped copy have the same moves,
# the old copy must not make the checker delete the newer one. With different
# move counts, the shorter copy must be the one marked for deletion.

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
proc del {h g} { return [sc_base gameflag $h $g get del] }

set tmp /tmp
set stem [file join $tmp "scid_twin_keep_[pid]"]
set oldPgn "${stem}_old.pgn"
set newPgn "${stem}_new.pgn"
set tags {[Event "Let's Play!"]
[Site "Chess.com"]
[Date "2026.11.10"]
[Round "-"]
[White "alice"]
[Black "bob"]
[Result "1-0"]}

proc writePgn {path tags moves {comments 0}} {
    set fd [open $path w]
    puts $fd $tags
    puts $fd ""
    if {$comments} {
        puts $fd "1. e4 {\[%clk 0:03:00\]} e5 {\[%clk 0:03:00\]} $moves"
    } else {
        puts $fd "1. e4 e5 $moves"
    }
    close $fd
}

# Same moves, old copy has clock comments (immune), new copy is stripped.
writePgn $oldPgn $tags "2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 1-0" 1
writePgn $newPgn $tags "2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 1-0" 0
set h [sc_base create SCID5 "${stem}_equal"]
sc_base import $h $oldPgn
sc_base import $h $newPgn
set deleted [sc_base duplicates $h -colors No -event No -site Yes -round Yes \
    -year Yes -month Yes -day No -result No -eco No -moves Yes -players No \
    -skipshort Yes -setfilter No -usefilter No -comments Yes -variations Yes \
    -delete Shorter]
check "an older commented copy does not get the newer copy deleted" \
    [expr {$deleted == 0 && ![del $h 2]}] "deleted=$deleted newdel=[del $h 2]"
sc_base close $h

# Different lengths, immunity off: the shorter copy must be deleted.
writePgn $oldPgn $tags "2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 1-0" 0
writePgn $newPgn $tags "2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 1-0" 0
set h [sc_base create SCID5 "${stem}_fuller"]
sc_base import $h $oldPgn
sc_base import $h $newPgn
set deleted [sc_base duplicates $h -colors No -event No -site Yes -round Yes \
    -year Yes -month Yes -day No -result No -eco No -moves Yes -players No \
    -skipshort Yes -setfilter No -usefilter No -comments No -variations No \
    -delete Shorter]
check "the shorter copy is deleted and the fuller one is kept" \
    [expr {$deleted == 1 && [del $h 1] && ![del $h 2]}] \
    "deleted=$deleted olddel=[del $h 1] newdel=[del $h 2]"
sc_base close $h

# Equal lengths, no comments: the older copy is deleted, the newer kept.
writePgn $oldPgn $tags "2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 1-0" 0
writePgn $newPgn $tags "2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 1-0" 0
set h [sc_base create SCID5 "${stem}_newer"]
sc_base import $h $oldPgn
sc_base import $h $newPgn
set deleted [sc_base duplicates $h -colors No -event No -site Yes -round Yes \
    -year Yes -month Yes -day No -result No -eco No -moves Yes -players No \
    -skipshort Yes -setfilter No -usefilter No -comments No -variations No \
    -delete Shorter]
check "the older copy is deleted and the newer one is kept" \
    [expr {$deleted == 1 && [del $h 1] && ![del $h 2]}] \
    "deleted=$deleted olddel=[del $h 1] newdel=[del $h 2]"
sc_base close $h

foreach f [glob -nocomplain "${stem}*"] {
    catch {file delete -force $f}
}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
