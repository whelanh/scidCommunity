# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# A pure-Tcl chess position, for the code that has to reason about a position
# that is not on the board: the engine's alternative move, the reply it expects,
# and the null move that asks "what would the other side do?" all need move
# generation and a static exchange evaluation, and sc_pos can only answer about
# the game's current position. No Tk, no sc_* commands: this file runs in tclsh.
#
# A position is a dict:
#   board    list of 64 squares, a1=0 .. h8=63, "" for empty, piece letters
#   side     w | b
#   castle   string subset of KQkq
#   ep       en-passant target square index, or -1
#   half     halfmove clock
#   full     fullmove number
#
# Only what the comment facts need: legal move generation, make-move, material
# counting, and a static exchange evaluation.
#
# The static exchange evaluation follows Patzer's chess/classifier.ts
# (staticExchange), MIT licence, (c) Arsen Apostolov and contributors:
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions: The above copyright
#   notice and this permission notice shall be included in all copies or
#   substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS",
#   WITHOUT WARRANTY OF ANY KIND.

namespace eval ::chessboard {
    variable PIECE_VALUE
    array set PIECE_VALUE {p 1 n 3 b 3 r 5 q 9 k 0}
}

proc ::chessboard::fromFen {fen} {
    set parts [split [string trim $fen]]
    set rows [split [lindex $parts 0] /]
    if {[llength $rows] != 8} { error "bad FEN board: $fen" }
    set board {}
    # FEN lists rank 8 first; our index 0 is a1, so append rank 1 first.
    for {set r 0} {$r <= 7} {incr r} {
        set row [lindex $rows [expr {7 - $r}]]
        set file 0
        foreach ch [split $row ""] {
            if {[string is digit -strict $ch]} {
                for {set k 0} {$k < $ch} {incr k} { lappend board "" ; incr file }
            } else {
                lappend board $ch
                incr file
            }
        }
        if {$file != 8} { error "bad FEN rank in: $fen" }
    }
    set side [lindex $parts 1]
    if {$side eq ""} { set side w }
    set castle [lindex $parts 2]
    if {$castle eq "-" || $castle eq ""} { set castle "" }
    set ep -1
    set epStr [lindex $parts 3]
    if {$epStr ne "-" && [string length $epStr] == 2} {
        set ep [expr {[scan [string index $epStr 0] %c] - 97 + 8 * ([string index $epStr 1] - 1)}]
    }
    set half 0 ; set full 1
    if {[llength $parts] > 4 && [string is integer -strict [lindex $parts 4]]} { set half [lindex $parts 4] }
    if {[llength $parts] > 5 && [string is integer -strict [lindex $parts 5]]} { set full [lindex $parts 5] }
    return [dict create board $board side $side castle $castle ep $ep half $half full $full]
}

proc ::chessboard::toFen {pos} {
    set board [dict get $pos board]
    set out {}
    for {set r 7} {$r >= 0} {incr r -1} {
        set row {}
        set empty 0
        for {set f 0} {$f < 8} {incr f} {
            set p [lindex $board [expr {$r * 8 + $f}]]
            if {$p eq ""} {
                incr empty
            } else {
                if {$empty} { append row $empty ; set empty 0 }
                append row $p
            }
        }
        if {$empty} { append row $empty }
        lappend out $row
    }
    set ep "-"
    if {[dict get $pos ep] >= 0} {
        set sq [dict get $pos ep]
        set ep "[sqName $sq]"
    }
    set castle [dict get $pos castle]
    if {$castle eq ""} { set castle "-" }
    return "[join $out /] [dict get $pos side] $castle $ep [dict get $pos half] [dict get $pos full]"
}

proc ::chessboard::pieceAt {board sq} {
    if {$sq < 0 || $sq > 63} { return "" }
    return [lindex $board $sq]
}

proc ::chessboard::colorOf {piece} {
    if {$piece eq ""} { return "" }
    if {[string is upper $piece]} { return w }
    return b
}

proc ::chessboard::fileOf {sq} { return [expr {$sq % 8}] }
proc ::chessboard::rankOf {sq} { return [expr {$sq / 8}] }

proc ::chessboard::sqName {sq} {
    return "[format %c [expr {97 + $sq % 8}]][expr {$sq / 8 + 1}]"
}

proc ::chessboard::sqIndex {name} {
    return [expr {[scan [string index $name 0] %c] - 97 + 8 * ([string index $name 1] - 1)}]
}

# Does `byColor` attack square `sq` in this position?
proc ::chessboard::attacked {pos sq byColor} {
    set board [dict get $pos board]
    set f [fileOf $sq]
    set r [rankOf $sq]

    # Pawns.
    if {$byColor eq "w"} {
        foreach df {-1 1} {
            set pf [expr {$f + $df}]
            set pr [expr {$r - 1}]
            if {$pf >= 0 && $pf < 8 && $pr >= 0 && $pr < 8} {
                if {[pieceAt $board [expr {$pr * 8 + $pf}]] eq "P"} { return 1 }
            }
        }
    } else {
        foreach df {-1 1} {
            set pf [expr {$f + $df}]
            set pr [expr {$r + 1}]
            if {$pf >= 0 && $pf < 8 && $pr >= 0 && $pr < 8} {
                if {[pieceAt $board [expr {$pr * 8 + $pf}]] eq "p"} { return 1 }
            }
        }
    }

    # Knights.
    set N [expr {$byColor eq "w" ? "N" : "n"}]
    foreach {df dr} {1 2 2 1 2 -1 1 -2 -1 -2 -2 -1 -2 1 -1 2} {
        set pf [expr {$f + $df}]
        set pr [expr {$r + $dr}]
        if {$pf >= 0 && $pf < 8 && $pr >= 0 && $pr < 8} {
            if {[pieceAt $board [expr {$pr * 8 + $pf}]] eq $N} { return 1 }
        }
    }

    # King.
    set K [expr {$byColor eq "w" ? "K" : "k"}]
    foreach {df dr} {1 0 1 1 0 1 -1 1 -1 0 -1 -1 0 -1 1 -1} {
        set pf [expr {$f + $df}]
        set pr [expr {$r + $dr}]
        if {$pf >= 0 && $pf < 8 && $pr >= 0 && $pr < 8} {
            if {[pieceAt $board [expr {$pr * 8 + $pf}]] eq $K} { return 1 }
        }
    }

    # Sliders.
    set R [expr {$byColor eq "w" ? "R" : "r"}]
    set Q [expr {$byColor eq "w" ? "Q" : "q"}]
    set B [expr {$byColor eq "w" ? "B" : "b"}]
    foreach {df dr kind} {1 0 rook -1 0 rook 0 1 rook 0 -1 rook \
                          1 1 bishop 1 -1 bishop -1 1 bishop -1 -1 bishop} {
        set pf [expr {$f + $df}]
        set pr [expr {$r + $dr}]
        while {$pf >= 0 && $pf < 8 && $pr >= 0 && $pr < 8} {
            set p [pieceAt $board [expr {$pr * 8 + $pf}]]
            if {$p ne ""} {
                if {$kind eq "rook"} {
                    if {$p eq $R || $p eq $Q} { return 1 }
                } else {
                    if {$p eq $B || $p eq $Q} { return 1 }
                }
                break
            }
            incr pf $df
            incr pr $dr
        }
    }
    return 0
}

proc ::chessboard::kingSquare {pos color} {
    set board [dict get $pos board]
    set K [expr {$color eq "w" ? "K" : "k"}]
    set i 0
    foreach p $board {
        if {$p eq $K} { return $i }
        incr i
    }
    return -1
}

proc ::chessboard::inCheck {pos color} {
    set ks [kingSquare $pos $color]
    if {$ks < 0} { return 0 }
    return [attacked $pos $ks [expr {$color eq "w" ? "b" : "w"}]]
}

proc ::chessboard::pseudoMoves {pos} {
    set board [dict get $pos board]
    set side [dict get $pos side]
    set moves {}
    set up [expr {$side eq "w" ? 8 : -8}]
    set startRank [expr {$side eq "w" ? 1 : 6}]
    set promoRank [expr {$side eq "w" ? 7 : 0}]

    for {set sq 0} {$sq < 64} {incr sq} {
        set p [lindex $board $sq]
        if {$p eq "" || [colorOf $p] ne $side} continue
        set f [fileOf $sq]
        set r [rankOf $sq]
        set lower [string tolower $p]

        if {$lower eq "p"} {
            set to [expr {$sq + $up}]
            if {$to >= 0 && $to < 64 && [pieceAt $board $to] eq ""} {
                if {[rankOf $to] == $promoRank} {
                    foreach pr {q r b n} { lappend moves "[sqName $sq][sqName $to]$pr" }
                } else {
                    lappend moves "[sqName $sq][sqName $to]"
                    if {$r == $startRank} {
                        set to2 [expr {$to + $up}]
                        if {[pieceAt $board $to2] eq ""} { lappend moves "[sqName $sq][sqName $to2]" }
                    }
                }
            }
            foreach df {-1 1} {
                set pf [expr {$f + $df}]
                set pr [expr {$r + ($side eq "w" ? 1 : -1)}]
                if {$pf < 0 || $pf > 7 || $pr < 0 || $pr > 7} continue
                set to [expr {$pr * 8 + $pf}]
                set tp [pieceAt $board $to]
                if {$tp ne "" && [colorOf $tp] ne $side} {
                    if {[rankOf $to] == $promoRank} {
                        foreach pr {q r b n} { lappend moves "[sqName $sq][sqName $to]$pr" }
                    } else {
                        lappend moves "[sqName $sq][sqName $to]"
                    }
                } elseif {$to == [dict get $pos ep] && $tp eq ""} {
                    lappend moves "[sqName $sq][sqName $to]"
                }
            }
            continue
        }

        if {$lower eq "n"} {
            foreach {df dr} {1 2 2 1 2 -1 1 -2 -1 -2 -2 -1 -2 1 -1 2} {
                set pf [expr {$f + $df}]
                set pr [expr {$r + $dr}]
                if {$pf < 0 || $pf > 7 || $pr < 0 || $pr > 7} continue
                set to [expr {$pr * 8 + $pf}]
                set tp [pieceAt $board $to]
                if {$tp eq "" || [colorOf $tp] ne $side} { lappend moves "[sqName $sq][sqName $to]" }
            }
            continue
        }

        if {$lower eq "k"} {
            foreach {df dr} {1 0 1 1 0 1 -1 1 -1 0 -1 -1 0 -1 1 -1} {
                set pf [expr {$f + $df}]
                set pr [expr {$r + $dr}]
                if {$pf < 0 || $pf > 7 || $pr < 0 || $pr > 7} continue
                set to [expr {$pr * 8 + $pf}]
                set tp [pieceAt $board $to]
                if {$tp eq "" || [colorOf $tp] ne $side} { lappend moves "[sqName $sq][sqName $to]" }
            }
            set castle [dict get $pos castle]
            set them [expr {$side eq "w" ? "b" : "w"}]
            if {$side eq "w" && $sq == 4} {
                if {[string first "K" $castle] >= 0 && [pieceAt $board 7] eq "R" &&
                    [pieceAt $board 5] eq "" && [pieceAt $board 6] eq "" &&
                    ![attacked $pos 4 $them] && ![attacked $pos 5 $them] && ![attacked $pos 6 $them]} {
                    lappend moves "e1g1"
                }
                if {[string first "Q" $castle] >= 0 && [pieceAt $board 0] eq "R" &&
                    [pieceAt $board 1] eq "" && [pieceAt $board 2] eq "" && [pieceAt $board 3] eq "" &&
                    ![attacked $pos 4 $them] && ![attacked $pos 3 $them] && ![attacked $pos 2 $them]} {
                    lappend moves "e1c1"
                }
            } elseif {$side eq "b" && $sq == 60} {
                if {[string first "k" $castle] >= 0 && [pieceAt $board 63] eq "r" &&
                    [pieceAt $board 61] eq "" && [pieceAt $board 62] eq "" &&
                    ![attacked $pos 60 $them] && ![attacked $pos 61 $them] && ![attacked $pos 62 $them]} {
                    lappend moves "e8g8"
                }
                if {[string first "q" $castle] >= 0 && [pieceAt $board 56] eq "r" &&
                    [pieceAt $board 57] eq "" && [pieceAt $board 58] eq "" && [pieceAt $board 59] eq "" &&
                    ![attacked $pos 60 $them] && ![attacked $pos 59 $them] && ![attacked $pos 58 $them]} {
                    lappend moves "e8c8"
                }
            }
            continue
        }

        set dirs {}
        if {$lower eq "r" || $lower eq "q"} { set dirs [concat $dirs {1 0 -1 0 0 1 0 -1}] }
        if {$lower eq "b" || $lower eq "q"} { set dirs [concat $dirs {1 1 1 -1 -1 1 -1 -1}] }
        foreach {df dr} $dirs {
            set pf [expr {$f + $df}]
            set pr [expr {$r + $dr}]
            while {$pf >= 0 && $pf < 8 && $pr >= 0 && $pr < 8} {
                set to [expr {$pr * 8 + $pf}]
                set tp [pieceAt $board $to]
                if {$tp eq ""} {
                    lappend moves "[sqName $sq][sqName $to]"
                } else {
                    if {[colorOf $tp] ne $side} { lappend moves "[sqName $sq][sqName $to]" }
                    break
                }
                incr pf $df
                incr pr $dr
            }
        }
    }
    return $moves
}

# Apply a UCI move (e2e4 / e7e8q). Returns the new position.
# Remove the castling right a rook on `file` carries. `upper` is the colour
# (white rights are upper case). Scid writes Chess960 rights as rook-file
# letters; the classic KQkq spelling is removed as well.
proc ::chessboard::dropRookRight {castle file upper} {
    set letter [string index "ABCDEFGH" $file]
    if {!$upper} { set letter [string tolower $letter] }
    set out [string map [list $letter ""] $castle]
    if {$upper} {
        if {$file == 7} { set out [string map {K ""} $out] }
        if {$file == 0} { set out [string map {Q ""} $out] }
    } else {
        if {$file == 7} { set out [string map {k ""} $out] }
        if {$file == 0} { set out [string map {q ""} $out] }
    }
    return $out
}

proc ::chessboard::makeMove {pos uci} {
    set uci [string range $uci 0 3][string tolower [string range $uci 4 end]]
    set board [dict get $pos board]
    set side [dict get $pos side]
    set from [sqIndex [string range $uci 0 1]]
    set to [sqIndex [string range $uci 2 3]]
    set promo ""
    if {[string length $uci] > 4} { set promo [string index $uci 4] }

    set piece [lindex $board $from]
    if {$piece eq ""} { error "no piece on $uci" }
    set captured [lindex $board $to]
    set lower [string tolower $piece]
    set castle [dict get $pos castle]
    set ep -1

    if {$lower eq "p" && $to == [dict get $pos ep] && $captured eq ""} {
        set capSq [expr {$to + ($side eq "w" ? -8 : 8)}]
        lset board $capSq ""
        set captured p
    }

    if {$lower eq "p" && abs($to - $from) == 16} {
        set ep [expr {($from + $to) / 2}]
    }

    # Castling, including Chess960's king-to-rook encoding. The destination
    # square decides the side; the rook is found on that side of the king, so
    # the orthodox h1/a1 assumption is gone. In Chess960 the engine sends the
    # king onto its own rook (e1h1), which is a capture only in the encoding.
    set ownRook [expr {$side eq "w" ? "R" : "r"}]
    set castled 0
    if {$lower eq "k" && $captured eq $ownRook} {
        set rank [expr {$from / 8}]
        set kingside [expr {($to % 8) > ($from % 8)}]
        set rookSq $to
        set castled 1
    } elseif {$lower eq "k" && abs(($to % 8) - ($from % 8)) == 2} {
        set rank [expr {$from / 8}]
        set kingside [expr {($to % 8) > ($from % 8)}]
        set rookSq -1
        set step [expr {$kingside ? 1 : -1}]
        for {set f [expr {($from % 8) + $step}]} {$f >= 0 && $f <= 7} {incr f $step} {
            set sq [expr {$rank * 8 + $f}]
            if {[lindex $board $sq] eq $ownRook} { set rookSq $sq ; break }
        }
        if {$rookSq >= 0} { set castled 1 }
    }
    if {$castled} {
        set kingTo [expr {$rank * 8 + ($kingside ? 6 : 2)}]
        set rookTo [expr {$rank * 8 + ($kingside ? 5 : 3)}]
        lset board $from ""
        lset board $rookSq ""
        lset board $kingTo $piece
        lset board $rookTo $ownRook
        # The king moved: both of that side's rights are gone. The field may be
        # the classic KQkq or Scid's Chess960 rook-file letters (HAha).
        if {$side eq "w"} {
            set castle [regsub -all {[A-HKQ]} $castle ""]
        } else {
            set castle [regsub -all {[a-hkq]} $castle ""]
        }
        set half [expr {[dict get $pos half] + 1}]
        set full [expr {[dict get $pos full] + ($side eq "b" ? 1 : 0)}]
        return [dict create board $board side [expr {$side eq "w" ? "b" : "w"}] \
            castle $castle ep -1 half $half full $full]
    }

    lset board $to $piece
    lset board $from ""

    if {$promo ne ""} {
        lset board $to [expr {$side eq "w" ? [string toupper $promo] : [string tolower $promo]}]
    }

    # castling rights: a king move drops both of its side's rights; a rook move
    # or a rook captured on its square drops the right for that file. The field
    # can be KQkq or Chess960 file letters, so both spellings are removed.
    if {$lower eq "k"} {
        if {$side eq "w"} {
            set castle [regsub -all {[A-HKQ]} $castle ""]
        } else {
            set castle [regsub -all {[a-hkq]} $castle ""]
        }
    } elseif {$lower eq "r"} {
        set castle [::chessboard::dropRookRight $castle [expr {$from % 8}] \
            [expr {$piece eq "R"}]]
    }
    if {[string tolower $captured] eq "r"} {
        set castle [::chessboard::dropRookRight $castle [expr {$to % 8}] \
            [expr {$captured eq "R"}]]
    }

    set half [expr {($lower eq "p" || $captured ne "") ? 0 : [dict get $pos half] + 1}]
    set full [expr {[dict get $pos full] + ($side eq "b" ? 1 : 0)}]
    return [dict create board $board side [expr {$side eq "w" ? "b" : "w"}] \
        castle $castle ep $ep half $half full $full]
}

proc ::chessboard::legalMoves {pos} {
    set side [dict get $pos side]
    set out {}
    foreach m [pseudoMoves $pos] {
        set after [makeMove $pos $m]
        if {![inCheck $after $side]} { lappend out $m }
    }
    return $out
}

proc ::chessboard::material {pos} {
    variable PIECE_VALUE
    set w 0 ; set b 0
    foreach p [dict get $pos board] {
        if {$p eq ""} continue
        set v $PIECE_VALUE([string tolower $p])
        if {[string is upper $p]} { incr w $v } else { incr b $v }
    }
    return [list $w $b]
}

# Static exchange evaluation on one square, matching Patzer's
# chess/classifier.ts:staticExchange: the side to move may start a capture
# sequence there, the opponent may recapture or decline, and the value is
# never negative for the initiator. Legality (pins, checks) is enforced
# because legalMoves is used.
proc ::chessboard::see {pos sq} {
    variable PIECE_VALUE
    set best ""
    set bestVal 99
    set bestPromo 0
    set board [dict get $pos board]
    set ep [dict get $pos ep]
    foreach m [legalMoves $pos] {
        set to [sqIndex [string range $m 2 3]]
        if {$to != $sq} continue
        set victim [lindex $board $to]
        set mover [lindex $board [sqIndex [string range $m 0 1]]]
        if {$victim eq ""} {
            # only an en-passant capture lands on an empty square
            if {$to != $ep || [string tolower $mover] ne "p"} continue
            set victim p
        }
        set val $PIECE_VALUE([string tolower $mover])
        # Among equally cheap capturers, a promotion is worth more: the side
        # to move would choose the queen.
        set promo 0
        if {[string length $m] > 4} {
            set promo $PIECE_VALUE([string tolower [string index $m 4]])
        }
        if {$val < $bestVal || ($val == $bestVal && $promo > $bestPromo)} {
            set bestVal $val
            set bestPromo $promo
            set best $m
        }
    }
    if {$best eq ""} { return 0 }
    set victim [lindex $board [sqIndex [string range $best 2 3]]]
    if {$victim eq ""} { set victim p }
    set gain $PIECE_VALUE([string tolower $victim])
    # A pawn that promotes while capturing gains the promoted piece as well as
    # the victim; without this a promoting recapture is undervalued (Patzer's
    # staticExchange does not price it, so this is a deliberate difference).
    if {$bestPromo > 0} {
        incr gain [expr {$bestPromo - $PIECE_VALUE(p)}]
    }
    return [expr {max(0, $gain - [see [makeMove $pos $best] $sq])}]
}

# Material the side that just moved left en prise, net of what it captured.
# What a sacrifice costs, as a number: positive means the mover gave up that
# much, and zero means it gave up nothing (the opponent's best capture wins no
# more than the move already took).
proc ::chessboard::hangingMaterial {fenBefore fenAfter stm} {
    variable PIECE_VALUE
    set before [fromFen $fenBefore]
    set after [fromFen $fenAfter]
    lassign [material $before] wb bb
    lassign [material $after] wa ba
    set gained [expr {[string index $stm 0] eq "w" ? $bb - $ba : $wb - $wa}]
    set ab [dict get $after board]
    set epA [dict get $after ep]
    set targets {}
    foreach m [legalMoves $after] {
        set to [sqIndex [string range $m 2 3]]
        if {[lindex $ab $to] ne ""} { lappend targets $to ; continue }
        if {$to == $epA && [string tolower [lindex $ab [sqIndex [string range $m 0 1]]]] eq "p"} {
            lappend targets $to
        }
    }
    set biggest 0
    foreach sq [lsort -unique $targets] {
        set v [see $after $sq]
        if {$v > $biggest} { set biggest $v }
    }
    return [expr {$biggest - $gained}]
}
