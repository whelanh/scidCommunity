# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Deterministic chess facts for a move comment.
#
# The model never analyses: everything it may say about the board comes from
# here. One call builds the whole block for a move - what the move did, what it
# attacked, what it left hanging, the piece inventory, the rule state stated
# positively AND in the negative, and material against the engine's score. The
# prose layer is then free to write English, and has nothing left to invent.
#
# Every line is computed from the FEN and the move. Nothing here searches, and
# nothing calls an engine. Rule state (castling rights, en passant, the
# fifty-move clock, repetition) is always stated, including when the answer is
# "none": a fact that is merely absent is what lets a model invent it.
#
# The motif vocabulary follows Patzer's coach/tactics.ts (moveMotifs), MIT
# licence, (c) Arsen Apostolov and contributors:
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions: The above copyright
#   notice and this permission notice shall be included in all copies or
#   substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS",
#   WITHOUT WARRANTY OF ANY KIND.
#
# Entry point: ::facts::forMove, which takes a move dict and returns the fact
# block as newline-separated lines.
#   required   fen_before, played (UCI), side ("white"/"black")
#   optional   fen_after, ply, best_uci, best_san, best_pv, best_pv_long,
#              classification, eval_after_cp, punish_pv, rep_count
# fen_after is derived from fen_before and played when it is not given, and the
# engine's alternative is only described when best_uci names one.

namespace eval ::facts {
    variable NAME
    array set NAME {p pawn n knight b bishop r rook q queen k king}
    variable VALUE
    array set VALUE {p 1 n 3 b 3 r 5 q 9 k 0}
}

proc ::facts::pieceName {p} {
    variable NAME
    if {$p eq ""} { return "" }
    return $NAME([string tolower $p])
}

proc ::facts::valueOf {p} {
    variable VALUE
    if {$p eq ""} { return 0 }
    return $VALUE([string tolower $p])
}

proc ::facts::sideWord {color} {
    return [expr {$color eq "w" ? "White" : "Black"}]
}

proc ::facts::other {color} {
    return [expr {$color eq "w" ? "b" : "w"}]
}

# Does the piece on `from` attack `target`? Geometric, like chess.js
# attackers(): pins are ignored, which is what the motif vocabulary wants.
proc ::facts::attacksFrom {pos from target} {
    if {$from == $target} { return 0 }
    set board [dict get $pos board]
    set p [lindex $board $from]
    if {$p eq ""} { return 0 }
    set kind [string tolower $p]
    set df [expr {[::chessboard::fileOf $target] - [::chessboard::fileOf $from]}]
    set dr [expr {[::chessboard::rankOf $target] - [::chessboard::rankOf $from]}]
    set adf [expr {abs($df)}]
    set adr [expr {abs($dr)}]
    switch -- $kind {
        p {
            set fwd [expr {[string is upper $p] ? 1 : -1}]
            return [expr {$adf == 1 && $dr == $fwd}]
        }
        n { return [expr {($adf == 1 && $adr == 2) || ($adf == 2 && $adr == 1)}] }
        k { return [expr {$adf <= 1 && $adr <= 1}] }
    }
    set diag [expr {$adf == $adr && $adf > 0}]
    set straight [expr {($df == 0) != ($dr == 0)}]
    if {$kind eq "b" && !$diag} { return 0 }
    if {$kind eq "r" && !$straight} { return 0 }
    if {$kind eq "q" && !($diag || $straight)} { return 0 }
    if {!($diag || $straight)} { return 0 }
    set sf [expr {$df == 0 ? 0 : ($df > 0 ? 1 : -1)}]
    set sr [expr {$dr == 0 ? 0 : ($dr > 0 ? 1 : -1)}]
    set pf [expr {[::chessboard::fileOf $from] + $sf}]
    set pr [expr {[::chessboard::rankOf $from] + $sr}]
    while {$pf != [::chessboard::fileOf $target] || $pr != [::chessboard::rankOf $target]} {
        if {[lindex $board [expr {$pr * 8 + $pf}]] ne ""} { return 0 }
        incr pf $sf
        incr pr $sr
    }
    return 1
}

proc ::facts::attackersOf {pos sq byColor} {
    set board [dict get $pos board]
    set out {}
    for {set i 0} {$i < 64} {incr i} {
        set p [lindex $board $i]
        if {$p eq ""} continue
        if {[::chessboard::colorOf $p] ne $byColor} continue
        if {[attacksFrom $pos $i $sq]} {
            lappend out [list [pieceName $p] [valueOf $p] $i]
        }
    }
    return $out
}

# Can the piece on `from` legally capture on `to`? A pinned piece attacks
# geometrically but cannot take, and a claim that a piece is hanging is a claim
# about captures, so the legality of the move matters here.
proc ::facts::legalCapture {pos from to side} {
    set out 0
    if {![catch {
        set after [::chessboard::makeMove $pos \
            "[::chessboard::sqName $from][::chessboard::sqName $to]"]
        set out [expr {![::chessboard::inCheck $after $side]}]
    }]} {}
    return $out
}

# Pieces of `color` that are attacked and either undefended or attacked by
# something cheaper. Returns a list of {piece square}.
proc ::facts::hangingPieces {fen color} {
    set pos [::chessboard::fromFen $fen]
    set board [dict get $pos board]
    set them [other $color]
    set out {}
    for {set i 0} {$i < 64} {incr i} {
        set p [lindex $board $i]
        if {$p eq ""} continue
        if {[::chessboard::colorOf $p] ne $color} continue
        if {[string tolower $p] eq "k"} continue
        # Only a legal capture threatens a piece: a pinned attacker attacks
        # geometrically but cannot take it. Defenders stay geometric - the
        # square still holds our piece here, so a defender's recapture can only
        # be judged after the capture, and counting a pinned defender merely
        # leaves a piece unmentioned instead of calling it hanging wrongly.
        set att {}
        foreach a [attackersOf $pos $i $them] {
            if {[legalCapture $pos [lindex $a 2] $i $them]} { lappend att $a }
        }
        if {![llength $att]} continue
        set def [attackersOf $pos $i $color]
        # A king (value 0) can only take an undefended piece; counting it as a
        # cheap attacker would call every defended piece beside the enemy king
        # hanging. Undefended pieces are covered by the first test below.
        set minAtt 99
        foreach a $att {
            set v [lindex $a 1]
            if {$v == 0} continue
            if {$v < $minAtt} { set minAtt $v }
        }
        if {![llength $def] || $minAtt < [valueOf $p]} {
            lappend out [list [pieceName $p] [::chessboard::sqName $i]]
        }
    }
    return $out
}

# Flip the side to move (a null move) so we can ask "what would they do?".
proc ::facts::passTurn {fen} {
    set parts [split $fen]
    lset parts 1 [other [lindex $parts 1]]
    lset parts 3 "-"
    return [join $parts " "]
}

# First mating move for the side to move: {uci san} or "".
proc ::facts::mateInOne {fen} {
    set pos [::chessboard::fromFen $fen]
    set them [other [dict get $pos side]]
    foreach m [::chessboard::legalMoves $pos] {
        set after [::chessboard::makeMove $pos $m]
        if {![::chessboard::inCheck $after $them]} continue
        if {[llength [::chessboard::legalMoves $after]] == 0} {
            set san ""
            if {[llength [info commands sc_pos]]} {
                catch { set san [sc_pos coordToSAN $fen $m] }
            }
            return [list $m $san]
        }
    }
    return ""
}

# Everything about a single move, from the position it was played in.
proc ::facts::describeMove {fen uci} {
    set pos [::chessboard::fromFen $fen]
    set from [::chessboard::sqIndex [string range $uci 0 1]]
    set to   [::chessboard::sqIndex [string range $uci 2 3]]
    set board [dict get $pos board]
    set piece [lindex $board $from]
    set victim [lindex $board $to]
    set ep [dict get $pos ep]
    # The captured piece usually stands on the destination square, but an en
    # passant capture takes a pawn that never stood there: it is beside the
    # landing square, one rank back for the capturing pawn.
    set capSq $to
    if {$victim eq "" && $to == $ep && [string tolower $piece] eq "p"} {
        set victim "p"
        set capSq [expr {[dict get $pos side] eq "w" ? $to - 8 : $to + 8}]
    }
    set after [::chessboard::makeMove $pos $uci]
    set mover [dict get $pos side]
    set them [other $mover]
    set home [expr {$mover eq "w" ? 0 : 7}]
    set kind [string tolower $piece]
    set check [::chessboard::inCheck $after $them]
    return [dict create \
        piece [pieceName $piece] \
        from [::chessboard::sqName $from] to [::chessboard::sqName $to] \
        capture [pieceName $victim] capture_value [valueOf $victim] \
        capture_sq [::chessboard::sqName $capSq] \
        check $check \
        mate [expr {$check && [llength [::chessboard::legalMoves $after]] == 0}] \
        castle [expr {$kind eq "k" && abs($to - $from) == 2}] \
        promo [expr {[string length $uci] > 4}] \
        develops [expr {($kind eq "n" || $kind eq "b") && [::chessboard::rankOf $from] == $home && [::chessboard::rankOf $to] != $home}] \
        side [sideWord $mover]]
}

# The most valuable thing the side to move can win (piece, square, value).
proc ::facts::biggestTarget {fen} {
    set pos [::chessboard::fromFen $fen]
    set board [dict get $pos board]
    set best ""
    set bestVal 0
    set seen {}
    foreach m [::chessboard::legalMoves $pos] {
        set to [::chessboard::sqIndex [string range $m 2 3]]
        set victim [lindex $board $to]
        set capSq $to
        if {$victim eq ""} {
            if {$to != [dict get $pos ep]} continue
            # en passant: the pawn taken stands beside the landing square
            set victim p
            set capSq [expr {[dict get $pos side] eq "w" ? $to - 8 : $to + 8}]
        }
        if {[lsearch -exact $seen $to] >= 0} continue
        lappend seen $to
        set v [::chessboard::see $pos $to]
        if {$v > $bestVal} {
            set bestVal $v
            set best [dict create square [::chessboard::sqName $to] \
                capture_sq [::chessboard::sqName $capSq] \
                piece [pieceName $victim] value $v]
        }
    }
    return $best
}


# The piece set, so the model cannot invent a piece that isn't there. Pawns are
# counted, not located - a full pawn list is noise a comment never needs.
proc ::facts::inventoryLine {fen color} {
    set pos [::chessboard::fromFen $fen]
    set board [dict get $pos board]
    set pieces {}
    set pawns 0
    for {set i 0} {$i < 64} {incr i} {
        set p [lindex $board $i]
        if {$p eq ""} continue
        if {[::chessboard::colorOf $p] ne $color} continue
        if {[string tolower $p] eq "p"} { incr pawns; continue }
        lappend pieces [list [valueOf $p] $i "[pieceName $p] on [::chessboard::sqName $i]"]
    }
    # king, queen, rooks, bishops, knights - the way a player would list them
    set pieces [lsort -command {apply {{a b} {
        set va [lindex $a 0]; set vb [lindex $b 0]
        if {$va != $vb} { return [expr {$vb - $va}] }
        return [expr {[lindex $a 1] - [lindex $b 1]}]
    }}} $pieces]
    set named {}
    foreach e $pieces { lappend named [lindex $e 2] }
    set pieces $named
    set s "[sideWord $color] has [join $pieces {, }]"
    if {$pawns == 1} {
        append s ", and one pawn"
    } elseif {$pawns > 1} {
        append s ", and $pawns pawns"
    } elseif {![llength $pieces]} {
        set s "[sideWord $color] has only the king"
    }
    return $s
}


# Who may still castle, so the text cannot invent a castling plan for a side
# that lost the right twenty moves ago.

# ---- rule-state facts ------------------------------------------------------
# Three things a comment can invent and cannot see: en passant, repetition and
# the fifty-move clock. All three are computed, never inferred.

# Is a legal en-passant capture available in this position? The ep square
# alone is not enough: after most double pushes no pawn can use it.
proc ::facts::epCaptureAvailable {fen} {
    set ep [lindex [split $fen] 3]
    if {$ep eq "" || $ep eq "-"} { return 0 }
    set out 0
    if {![catch {
        set pos [::chessboard::fromFen $fen]
        set to [::chessboard::sqIndex $ep]
        set board [dict get $pos board]
        if {[lindex $board $to] eq ""} {
            set side [dict get $pos side]
            foreach m [::chessboard::legalMoves $pos] {
                if {[string range $m 2 3] ne $ep} continue
                set from [::chessboard::sqIndex [string range $m 0 1]]
                set p [lindex $board $from]
                if {$p ne "" && [string tolower $p] eq "p" &&
                    [::chessboard::colorOf $p] eq $side} {
                    set out 1
                    break
                }
            }
        }
    }]} {}
    return $out
}

# A position signature: everything that makes two positions "the same" for
# repetition. The move counters are deliberately dropped, and so is an en
# passant square no pawn can use: two positions repeat only when the same en
# passant captures are available (FIDE 9.2), so a double push nobody can answer
# does not make a new position.
proc ::facts::sig {fen} {
    lassign [split $fen] board side castle ep
    if {![epCaptureAvailable $fen]} { set ep "-" }
    return "$board $side $castle $ep"
}

# Always stated, positive or negative: the absence of the line is what let the
# model invent rule states in the first place.
proc ::facts::epLine {fen} {
    set ep [lindex [split $fen] 3]
    if {$ep ne "" && $ep ne "-" && [epCaptureAvailable $fen]} {
        return "en passant: a pawn can be captured on $ep"
    }
    return "en passant: none available"
}

# Always stated, with the remainder, so the model can tell how far away it is.
# The halfmove clock counts plies; a scoresheet counts moves. One move is two
# plies, so an odd clock is half a move in progress and rounds up: the pawn move
# was made in this move.
proc ::facts::clockLine {fen} {
    set half [lindex [split $fen] 4]
    if {![string is integer -strict $half]} { set half 0 }
    if {$half >= 100} {
        return "fifty-move rule: fifty moves have passed since the last capture or pawn move, either side may claim a draw"
    }
    set moves [expr {$half / 2}]
    set left [expr {50 - $moves}]
    return "fifty-move rule: $moves of 50 moves have passed since the last capture or pawn move; $left more would allow a draw claim"
}

proc ::facts::repetitionLine {count} {
    if {$count eq ""} { return "repetition: not available for this position" }
    if {$count <= 1} { return "repetition: this position has not occurred before" }
    if {$count == 2} { return "repetition: this position has now occurred twice" }
    return "repetition: this position has occurred $count times, so a draw can be claimed"
}

# Repetition count for the position on the board, from the game's main line.
# Returns "" when the board is on a variation (the main line no longer matches)
# so the caller can say "not available" instead of guessing.
proc ::facts::repFromMainline {fen ply} {
    if {[llength [info commands sc_game]] == 0} { return "" }
    # sc_game UCI_mainLine returns a Tcl list whose first element is the whole
    # header ("position startpos moves" or "position fen <fen> moves") and whose
    # remaining elements are the moves. Splitting it as a string breaks that
    # first element into tokens, so ["moves"] was never found and the count was
    # always "not available".
    if {[catch { set ml [sc_game UCI_mainLine] }]} { return "" }
    if {![llength $ml]} { return "" }
    # A null move in the game re-emits a header in the middle of the list; the
    # replay below stops on it (makeMove rejects it) and reports "not available"
    # rather than counting plies that do not exist on the board.
    set header [lindex $ml 0]
    set moves [lrange $ml 1 end]
    if {[regexp {^position fen (.+) moves$} $header -> startFen]} {
        # played from a set-up board
    } elseif {$header eq "position startpos moves"} {
        set startFen {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}
    } else {
        return ""
    }
    # The position after $ply plies can only be on the main line if the main
    # line is at least that long. Without this check the loop below stops at the
    # end of the line and a coincidental match there (a variation returning to
    # the same position, say) was counted as if the ply had been reached.
    if {$ply > [llength $moves]} { return "" }
    set pos [::chessboard::fromFen $startFen]
    set seen [dict create]
    dict incr seen [sig [::chessboard::toFen $pos]]
    for {set k 0} {$k < $ply} {incr k} {
        if {[catch { set pos [::chessboard::makeMove $pos [lindex $moves $k]] }]} { return "" }
        dict incr seen [sig [::chessboard::toFen $pos]]
    }
    if {[sig [::chessboard::toFen $pos]] ne [sig $fen]} { return "" }
    return [dict get $seen [sig $fen]]
}

proc ::facts::castlingLine {fen} {
    set rights [lindex [split $fen] 2]
    set w {} ; set b {}
    if {[string first "K" $rights] >= 0} { lappend w kingside }
    if {[string first "Q" $rights] >= 0} { lappend w queenside }
    if {[string first "k" $rights] >= 0} { lappend b kingside }
    if {[string first "q" $rights] >= 0} { lappend b queenside }
    # Always stated, in the negative when it applies: a fact that is absent
    # leaves the model free to invent the right, which is exactly what it did.
    set out {}
    foreach {who lst} [list White $w Black $b] {
        if {[llength $lst]} {
            lappend out "$who may still castle [join $lst { and }]"
        } else {
            lappend out "$who has no castling rights"
        }
    }
    return "castling: [join $out {; }]"
}

proc ::facts::materialLine {fen} {
    lassign [::chessboard::material [::chessboard::fromFen $fen]] w b
    if {$w == $b} { return "material is level" }
    set diff [expr {abs($w - $b)}]
    set who [expr {$w > $b ? "White" : "Black"}]
    # "Black is 8 pawns up" is arithmetic the reader reads as a bug when the
    # queen is simply gone, so name the pieces instead of the points.
    set behind [expr {$w > $b ? "Black" : "White"}]
    set board [dict get [::chessboard::fromFen $fen] board]
    # Naming only the trailing side's losses blames it for pieces the leader
    # has also traded ("Black has lost a queen" when White's queen is gone too
    # reads as a queen lost for nothing), so report the surplus it lost alone.
    array set onBoardW {q 0 r 0 b 0 n 0 p 0}
    array set onBoardB {q 0 r 0 b 0 n 0 p 0}
    foreach p $board {
        if {$p eq ""} continue
        set k [string tolower $p]
        if {![info exists onBoardW($k)]} continue
        if {[::chessboard::colorOf $p] eq "w"} {
            incr onBoardW($k)
        } else {
            incr onBoardB($k)
        }
    }
    set gone {}
    foreach {k n full} {q 1 queen r 2 rook b 2 bishop n 2 knight p 8 pawn} {
        # More than a full set of a type means a promotion, and then the other
        # side's deficit of that type proves nothing about a capture.
        if {($w > $b ? $onBoardW($k) : $onBoardB($k)) > $n} { continue }
        # missing = full set minus what is on the board, so the trailing side's
        # surplus loss for this type is what the leader still has.
        set short [expr {$w > $b ? $onBoardW($k) - $onBoardB($k)
                                 : $onBoardB($k) - $onBoardW($k)}]
        if {$short <= 0} continue
        if {$short == 1} {
            lappend gone "a $full"
        } else {
            lappend gone "$short ${full}s"
        }
    }
    set pts [expr {$diff == 1 ? "point" : "points"}]
    if {[llength $gone]} {
        # "is missing", not "has lost": a game may start from a set-up board, and
        # then the pieces were never on the board to be lost.
        return "material: $who is $diff $pts up, and $behind is missing [join [lrange $gone 0 1] { and }]"
    }
    return "material: $who is $diff $pts up"
}

proc ::facts::namesOf {list} {
    set out {}
    foreach e $list { lappend out "the [lindex $e 0] on [lindex $e 1]" }
    return $out
}


# What the engine's move achieves, in the same vocabulary - so the facts can
# say "better was Rc1, which defends the bishop" rather than naming a move.
proc ::facts::castleAfter {fen uci mover} {
    if {[catch { set after [::chessboard::makeMove [::chessboard::fromFen $fen] $uci] }]} { return 0 }
    # after the move it is the opponent's turn: pass it back to ask "can I castle?"
    set mine [::chessboard::fromFen [passTurn [::chessboard::toFen $after]]]
    set king [expr {$mover eq "w" ? "e1" : "e8"}]
    set short "$king[expr {$mover eq "w" ? "g1" : "g8"}]"
    set long  "$king[expr {$mover eq "w" ? "c1" : "c8"}]"
    foreach m [::chessboard::legalMoves $mine] {
        if {$m eq $short || $m eq $long} { return 1 }
    }
    return 0
}


# Pieces off their home squares: the cheap, checkable proxy for development.
proc ::facts::development {fen color} {
    set pos [::chessboard::fromFen $fen]
    set board [dict get $pos board]
    # a1 b1 c1 d1 f1 g1 h1 / a8 .. h8, minus the king's square (e1/e8)
    set home [expr {$color eq "w" ? {0 1 2 3 5 6 7} : {56 57 58 59 61 62 63}}]
    set n 0
    # a piece counts as developed once it has left a home square
    for {set i 0} {$i < 64} {incr i} {
        set p [lindex $board $i]
        if {$p eq ""} continue
        if {[::chessboard::colorOf $p] ne $color} continue
        set k [string tolower $p]
        if {$k ne "n" && $k ne "b" && $k ne "r" && $k ne "q"} continue
        if {[lsearch -exact $home $i] >= 0} continue
        incr n
    }
    return $n
}


# Legal-move count for a colour, as a rough activity score. For the side not to
# move the position is flipped with a null move; if that leaves the flipped side
# in check the count would only be check evasions, so it returns -1 (unknown).
proc ::facts::mobility {fen color} {
    # No `return` inside the catch body: Tcl swallows TCL_RETURN, and the proc
    # would answer -1 every time (this bit twice already in this file).
    set out -1
    if {[catch {
        set pos [::chessboard::fromFen $fen]
        if {[dict get $pos side] ne $color} {
            set pos [::chessboard::fromFen [passTurn $fen]]
            if {[::chessboard::inCheck $pos $color]} {
                set out -1
            } else {
                set out [llength [::chessboard::legalMoves $pos]]
            }
        } else {
            set out [llength [::chessboard::legalMoves $pos]]
        }
    } err]} {
        set out -1
    }
    return $out
}

# When material and the engine disagree about who is better, say so and say
# why: a two-pawn lead that the engine scores against you is development and
# king safety, and that is exactly the kind of thing a reader cannot see from
# the material count alone.
proc ::facts::materialEvalNote {m} {
    if {![dict exists $m eval_after_cp] || ![dict exists $m fen_after]} { return "" }
    set ea [dict get $m eval_after_cp]
    if {[catch { lassign [::chessboard::material [::chessboard::fromFen [dict get $m fen_after]]] w b }]} { return "" }
    set diff [expr {$w - $b}]
    if {$diff == 0 || $ea == 0} { return "" }
    # both expressed from White's side; opposite signs means a real disagreement
    if {(($diff > 0) && ($ea > 0)) || (($diff < 0) && ($ea < 0))} { return "" }
    if {abs($ea) < 100} { return "" }
    set matWho [expr {$diff > 0 ? "White" : "Black"}]
    set matAmt [expr {abs($diff)}]
    set evWho [expr {$ea > 0 ? "White" : "Black"}]
    set dw [development [dict get $m fen_after] w]
    set db [development [dict get $m fen_after] b]
    set why {}
    if {$dw != $db} {
        set ahead [expr {$dw > $db ? "White" : "Black"}]
        set gap [expr {abs($dw - $db)}]
        lappend why "$ahead has $gap more pieces developed"
    }
    # No castling clause: a king on g1 may have walked there after losing the
    # right to castle, and a FEN cannot tell the two apart.
    # Activity: the part development and castling do not cover.
    if {[dict exists $m fen_after]} {
        set mw [mobility [dict get $m fen_after] w]
        set mb [mobility [dict get $m fen_after] b]
        if {$mw >= 0 && $mb >= 0 && abs($mw - $mb) >= 5} {
            set ahead [expr {$mw > $mb ? "White" : "Black"}]
            lappend why "$ahead has [expr {abs($mw - $mb)}] more legal moves"
        }
    }
    # Material is counted in pawn units, but a five-point lead is a rook, not
    # five pawns; say points, as materialLine does.
    set pointWord [expr {$matAmt == 1 ? "point" : "points"}]
    set note "material says $matWho is $matAmt $pointWord up, yet the engine still has $evWho ahead"
    if {[llength $why] == 1} {
        append note " - [lindex $why 0]"
    } elseif {[llength $why] > 1} {
        append note " - [join [lrange $why 0 end-1] {, }], and [lindex $why end]"
    }
    return $note
}

# What the move played nets on its destination square: the piece it took, less
# what the opponent's best continuation takes back. Negative when the exchange
# loses material. ::chessboard::see answers "what can be won on this square by
# whoever is to move", starting with its cheapest attacker - which, after the
# move, is the opponent, and may be a different capture from the one played.
proc ::facts::captureNet {fen uci} {
    set net 0
    if {[catch {
        set before [::chessboard::fromFen $fen]
        set to [::chessboard::sqIndex [string range $uci 2 3]]
        set board [dict get $before board]
        set victim [lindex $board $to]
        set gained 0
        if {$victim ne ""} {
            set gained [valueOf $victim]
        } else {
            # the ep square is empty; only a pawn moving there captures
            set from [::chessboard::sqIndex [string range $uci 0 1]]
            set mover [lindex $board $from]
            if {$to == [dict get $before ep] && $mover ne "" &&
                [string tolower $mover] eq "p"} {
                set gained 1
            }
        }
        # A promotion is material gained even though nothing was captured, and
        # SEE values the promoted piece when it is taken back. The pawn leaves
        # the board, the promoted piece arrives: count the difference.
        set promoted 0
        if {[string length $uci] > 4} {
            set promoted [expr {[valueOf [string index $uci 4]] - [valueOf p]}]
        }
        set after [::chessboard::makeMove $before $uci]
        set net [expr {$gained + $promoted - [::chessboard::see $after $to]}]
    }]} {}
    return $net
}

# What a move achieves, as a short list of phrases. Used for the engine's move
# ("better was X: it protects ... and develops ...") and, by difference, for the
# contrast with the move that was actually played.
proc ::facts::gainsOf {fen uci mover} {
    set them [other $mover]
    set before [::chessboard::fromFen $fen]
    if {[catch { set after [::chessboard::makeMove $before $uci] }]} { return {} }
    set fa [::chessboard::toFen $after]
    set d [describeMove $fen $uci]
    set out {}

    set mineBefore [hangingPieces $fen $mover]
    set mineAfter [hangingPieces $fa $mover]
    set theirsBefore [hangingPieces $fen $them]
    set theirsAfter [hangingPieces $fa $them]

    # Material won by the capture that was played, not by whichever capture on
    # that square would be cheapest for a hypothetical mover.
    if {[dict get $d capture] ne ""} {
        if {[captureNet $fen $uci] >= 1} {
            lappend out "wins the [dict get $d capture] on [dict get $d capture_sq]"
        }
    }

    # pieces of ours that stop being hangable
    set fromSq [dict get $d from]
    set toSq [dict get $d to]
    foreach e $mineBefore {
        if {[lindex $e 1] eq $fromSq} continue
        if {[lsearch -exact $mineAfter $e] >= 0} continue
        set sq [::chessboard::sqIndex [lindex $e 1]]
        set stillAttacked 0
        foreach a [attackersOf $after $sq $them] {
            if {[legalCapture $after [lindex $a 2] $sq $them]} {
                set stillAttacked 1
                break
            }
        }
        if {$stillAttacked} {
            lappend out "protects the [lindex $e 0] on [lindex $e 1]"
        } else {
            lappend out "takes the pressure off the [lindex $e 0] on [lindex $e 1]"
        }
    }
    # the piece that moved is not "protected" by itself: it walked away
    set wasHanging [expr {[lsearch -exact $mineBefore [list [dict get $d piece] $fromSq]] >= 0}]
    set stillHanging [expr {[lsearch -exact $mineAfter [list [dict get $d piece] $toSq]] >= 0}]
    if {$wasHanging && !$stillHanging} {
        lappend out "moves the [dict get $d piece] out of danger"
    }

    # enemy pieces that become takeable or attacked
    set hits {}
    foreach e $theirsAfter {
        if {[lsearch -exact $theirsBefore $e] >= 0} continue
        lappend hits $e
    }
    if {[llength $hits]} {
        lappend out "threatens [join [namesOf $hits] { and }]"
    }

    if {[dict get $d develops]} { lappend out "develops a piece" }
    # Only with the right still on the board: the legality test alone has been
    # wrong in the wild, and a false "can castle" is what the reader noticed.
    set rights [lindex [split $fen] 2]
    set hasRight [expr {$mover eq "w" ? ([string first "K" $rights] >= 0 || [string first "Q" $rights] >= 0) : ([string first "k" $rights] >= 0 || [string first "q" $rights] >= 0)}]
    if {$hasRight && ![dict get $d castle] && [castleAfter $fen $uci $mover]} {
        lappend out "lets [sideWord $mover] castle next move"
    }
    if {[dict get $d mate]} {
        lappend out "is checkmate"
        return $out
    }

    set allowsMate [mateInOne $fa]
    if {$allowsMate eq ""} {
        set mt [mateInOne [passTurn $fa]]
        if {$mt ne ""} {
            set san [lindex $mt 1]
            lappend out [expr {$san ne "" ? "threatens mate with $san" : "threatens mate"}]
        }
    }
    return $out
}

# Legal destinations per square for one side's bishops, rooks and queens.
# Claims like "this frees the bishop" are checkable against this map: a piece
# that was boxed in and now has moves was genuinely freed; a piece that gains
# one square beside the pawn that stepped aside was not.
proc ::facts::sliderMap {fen color} {
    set stm [lindex [split $fen] 1]
    if {$stm ne $color} { set fen [::facts::passTurn $fen] }
    if {[catch { set pos [::chessboard::fromFen $fen] }]} { return {} }
    set board [dict get $pos board]
    array set cnt {}
    for {set i 0} {$i < 64} {incr i} {
        set p [lindex $board $i]
        if {$p eq ""} continue
        if {[::chessboard::colorOf $p] ne $color} continue
        set k [string tolower $p]
        if {$k ne "b" && $k ne "r" && $k ne "q"} continue
        set cnt($i) 0
    }
    if {[catch {
        foreach m [::chessboard::legalMoves $pos] {
            set f [::chessboard::sqIndex [string range $m 0 1]]
            if {[info exists cnt($f)]} { incr cnt($f) }
        }
    }]} { return {} }
    array get cnt
}

# Pieces of the mover's that the move genuinely frees: boxed in before, with
# real scope after. The piece that moved is not counted - it freed itself.
proc ::facts::freedPieces {fen uci mover} {
    set d [::facts::describeMove $fen $uci]
    set fromSq [::chessboard::sqIndex [dict get $d from]]
    set before [::facts::sliderMap $fen $mover]
    if {![llength $before]} { return {} }
    if {[catch { set after [::chessboard::makeMove [::chessboard::fromFen $fen] $uci] }]} { return {} }
    set fa [::facts::passTurn [::chessboard::toFen $after]]
    set amap [::facts::sliderMap $fa $mover]
    if {![llength $amap]} { return {} }
    array set a $amap
    array set b $before
    set out {}
    foreach {sq n} $before {
        if {$sq == $fromSq} continue
        if {![info exists a($sq)]} continue
        set gain [expr {$a($sq) - $n}]
        if {($n == 0 && $a($sq) >= 3) || ($gain >= 5 && $a($sq) >= 5)} {
            set name [::facts::pieceOn $fen $sq]
            if {$name ne ""} { lappend out "the $name" }
        }
    }
    return $out
}

# `sq` is a board index, as produced by sliderMap.
proc ::facts::pieceOn {fen sq} {
    if {[catch { set pos [::chessboard::fromFen $fen] }]} { return "" }
    set p [lindex [dict get $pos board] $sq]
    if {$p eq ""} { return "" }
    return "[::facts::pieceName $p] on [::chessboard::sqName $sq]"
}

# ---- the motif block -------------------------------------------------------

proc ::facts::motifLines {m} {
    set fb [dict get $m fen_before]
    set played [dict get $m played]
    set mover [expr {[dict get $m side] eq "white" ? "w" : "b"}]
    set them [other $mover]
    set lines {}

    set p [describeMove $fb $played]
    set after [::chessboard::makeMove [::chessboard::fromFen $fb] $played]

    # A mating move needs no other explanation, and the motif pass below would
    # report the mated king as an attacked piece and a fresh "mate threat".
    if {[dict get $p mate]} {
        lappend lines "it is checkmate"
        return $lines
    }
    if {[dict get $p develops]} { lappend lines "it develops a minor piece" }

    # what the moved piece hits from its new square
    set to [::chessboard::sqIndex [dict get $p to]]
    set hits {}
    set board [dict get $after board]
    for {set i 0} {$i < 64} {incr i} {
        set q [lindex $board $i]
        if {$q eq ""} continue
        if {[::chessboard::colorOf $q] ne $them} continue
        if {![attacksFrom $after $to $i]} continue
        # A piece can land on a square where it is pinned; it still attacks
        # geometrically, but it cannot take. The king is the exception: the
        # check itself is legal and is reported as a check.
        if {[string tolower $q] ne "k" &&
            ![legalCapture $after $to $i $mover]} continue
        set defended [expr {[llength [attackersOf $after $i $them]] > 0}]
        if {[string tolower $q] eq "k" || [valueOf $q] > [valueOf [lindex $board $to]] || !$defended} {
            lappend hits [list [pieceName $q] [::chessboard::sqName $i]]
        }
    }
    if {[llength $hits] >= 2} {
        lappend lines "it attacks [join [namesOf $hits] { and }] at the same time - a fork"
    } elseif {[llength $hits] == 1 && [dict get $p check]} {
        lappend lines "it attacks [lindex [namesOf $hits] 0] while giving check"
    } elseif {[llength $hits] == 1} {
        lappend lines "it attacks [lindex [namesOf $hits] 0]"
    }

    # hanging before vs after, for both sides
    set mineBefore [hangingPieces $fb $mover]
    set mineAfter [hangingPieces [::chessboard::toFen $after] $mover]
    set theirsBefore [hangingPieces $fb $them]
    set theirsAfter [hangingPieces [::chessboard::toFen $after] $them]

    # The piece that moved is special: it did not "save" itself by leaving a
    # square, and it is not "left hanging" on a square it never stood on.
    set fromSq [dict get $p from]
    set toSq [dict get $p to]
    set wasHangingAtFrom [expr {[lsearch -exact $mineBefore [list [dict get $p piece] $fromSq]] >= 0}]
    set isHangingAtTo [expr {[lsearch -exact $mineAfter [list [dict get $p piece] $toSq]] >= 0}]
    set newHangs {}
    foreach e $mineAfter {
        if {[lindex $e 1] eq $toSq} continue
        if {[lsearch -exact $mineBefore $e] < 0} { lappend newHangs $e }
    }
    set newSaves {}
    foreach e $mineBefore {
        if {[lindex $e 1] eq $fromSq} continue
        if {[lsearch -exact $mineAfter $e] < 0} { lappend newSaves $e }
    }
    if {$wasHangingAtFrom && !$isHangingAtTo} {
        set escapes [list [list [dict get $p piece] $fromSq]]
    } else {
        set escapes {}
    }
    # A piece that took something of equal or greater value is not "left
    # hanging" when the recapture only trades it back.
    set net [captureNet $fb $played]
    if {$isHangingAtTo && !$wasHangingAtFrom && $net < 0} {
        lappend newHangs [list [dict get $p piece] $toSq]
    }
    set hitSquares {}
    foreach h $hits { lappend hitSquares [lindex $h 1] }
    set newThreats {}
    foreach e $theirsAfter {
        if {[lsearch -exact $theirsBefore $e] >= 0} continue
        # already reported as a fork/attack target above
        if {[lsearch -exact $hitSquares [lindex $e 1]] >= 0} continue
        lappend newThreats $e
    }

    if {[llength $newHangs]} {
        lappend lines "it leaves [join [namesOf $newHangs] { and }] hanging"
    }
    foreach e $escapes {
        lassign $e epiece esq
        lappend lines "it moves the $epiece on $esq out of danger"
    }
    if {[llength $newSaves]} {
        set afterPos [::chessboard::fromFen [::chessboard::toFen $after]]
        set stillHit 0
        foreach e $newSaves {
            set sq [::chessboard::sqIndex [lindex $e 1]]
            foreach a [attackersOf $afterPos $sq $them] {
                if {[legalCapture $afterPos [lindex $a 2] $sq $them]} {
                    set stillHit 1
                    break
                }
            }
            if {$stillHit} break
        }
        if {$stillHit} {
            lappend lines "it protects [join [namesOf $newSaves] { and }]"
        } else {
            lappend lines "it takes the pressure off [join [namesOf $newSaves] { and }]"
        }
    }
    if {[llength $newThreats]} {
        lappend lines "it now threatens [join [namesOf $newThreats] { and }]"
    }

    # mate motifs
    set fa [::chessboard::toFen $after]
    set allowsMate [mateInOne $fa]
    if {$allowsMate ne ""} {
        set san [lindex $allowsMate 1]
        if {$san ne ""} {
            lappend lines "the opponent can now mate in one with $san"
        } else {
            lappend lines "the opponent can now mate in one"
        }
    }
    set theyThreatened [mateInOne [passTurn $fb]]
    if {$theyThreatened ne "" && $allowsMate eq ""} {
        lappend lines "it stops the opponent's mate threat"
    }
    # A move that is already mate does not also "create a mate threat".
    set mateThreat [expr {[dict get $p mate] ? "" : [mateInOne [passTurn $fa]]}]
    if {$mateThreat ne ""} {
        set san [lindex $mateThreat 1]
        if {$san ne ""} {
            lappend lines "it creates a mate threat with $san"
        } else {
            lappend lines "it creates a mate threat"
        }
    }
    return $lines
}



# The one thing that best explains a move, from the board alone. Deliberately
# conservative: only claims we can prove without deep search.

# "the bishop takes the knight on f6" / "the rook moves from f1 to e1".
# `gerund` gives "taking"/"moving" for sentences that already have a subject.
proc ::facts::movePhrase {d {gerund 0}} {
    if {[dict get $d castle]} { return "the king castles" }
    set piece [dict get $d piece]
    set verb [expr {$gerund ? "taking" : "takes"}]
    if {[dict get $d capture] ne ""} {
        return "the $piece $verb the [dict get $d capture] on [dict get $d capture_sq]"
    }
    if {$gerund} { return "the $piece moving from [dict get $d from] to [dict get $d to]" }
    return "the $piece moves from [dict get $d from] to [dict get $d to]"
}

proc ::facts::moveWhy {m} {
    set fb [dict get $m fen_before]
    set fa [expr {[dict exists $m fen_after] ? [dict get $m fen_after] : ""}]
    if {$fa eq ""} {
        if {[catch { set fa [::chessboard::toFen [::chessboard::makeMove [::chessboard::fromFen $fb] [dict get $m played]]] }]} {
            return ""
        }
    }
    set d [describeMove $fb [dict get $m played]]
    if {[dict get $d mate]} { return "it is checkmate" }
    # A trade that gives back what the move took is not "left for the opponent":
    # only a negative net makes the destination square a mistake.
    set net [captureNet $fb [dict get $m played]]
    # what the side to move can win now that the move is on the board
    set t [biggestTarget $fa]
    if {$t ne "" && [dict get $t value] >= 3} {
        if {[dict get $t square] ne [dict get $d to] || $net < 0} {
            return "it leaves the [dict get $t piece] on [dict get $t capture_sq] for the opponent to take"
        }
    }
    set mover [expr {[dict get $d side] eq "White" ? "w" : "b"}]
    set mine [hangingPieces $fa $mover]
    foreach e $mine {
        if {[lindex $e 1] eq [dict get $d to] && $net < 0} {
            return "it puts the [lindex $e 0] on [lindex $e 1] where it can be taken"
        }
    }
    return ""
}

# One line about a move for the phase paragraph: what it was, how it was
# judged, and (when it was bad) what the engine wanted instead.
proc ::facts::phaseMoveLine {m {opts ""}} {
    set noclass [expr {[lsearch -exact $opts "-noclass"] >= 0}]
    set d [describeMove [dict get $m fen_before] [dict get $m played]]
    set what [movePhrase $d]
    if {[dict get $d check]} { append what " with check" }
    if {[dict get $d promo]} { append what " and promotes" }
    set ply [dict get $m ply]
    set mv [expr {($ply + 1) / 2}]
    set cls [dict get $m classification]
    set line "move $mv, [dict get $d side]: $what"

    set why [moveWhy $m]
    if {$why ne ""} { append line ", and $why" }
    # Only bad moves carry their severity. A good move does not need to be
    # called "great" - the facts have to say what it achieved instead.
    if {!$noclass && [lsearch -exact {inaccuracy mistake miss blunder} $cls] >= 0} {
        append line " ($cls)"
    }

    if {[lsearch -exact {inaccuracy mistake miss blunder} $cls] >= 0} {
        set bs [expr {[dict exists $m best_san] ? [dict get $m best_san] : ""}]
        set bu [expr {[dict exists $m best_uci] ? [dict get $m best_uci] : ""}]
        set mover [expr {[dict get $d side] eq "White" ? "w" : "b"}]
        set bg [expr {$bu ne "" ? [gainsOf [dict get $m fen_before] $bu $mover] : {}}]
        set pg [gainsOf [dict get $m fen_before] [dict get $m played] $mover]
        set bg [lrange $bg 0 2]
        # The reason the engine's move is better is what it does that the play
        # did not. Shared gains are acknowledged ("also") so a reader is not
        # told that only one move protects the pawn when both do.
        set shared {}
        set extras {}
        foreach g $bg { if {[lsearch -exact $pg $g] >= 0} { lappend shared $g } else { lappend extras $g } }
        set phrase ""
        if {[llength $shared] && [llength $extras]} {
            append phrase ": it also [join $shared { and }], and unlike the move played it [join $extras { and }]"
        } elseif {[llength $bg]} {
            append phrase ": it [join $bg {, }]"
        }
        if {$bs ne ""} {
            append line ". Better was $bs$phrase"
        } elseif {$phrase ne ""} {
            append line ". Better was the engine's move$phrase"
        }
        set pv [expr {[dict exists $m best_pv] ? [dict get $m best_pv] : {}}]
        if {[llength $pv] >= 2} {
            append line ". The engine's line: [lineText [dict get $m fen_before] [lrange $pv 0 4] $ply]"
        }
    }
    return $line
}

# Engine lines arrive as UCI. The facts are read by a model told to narrate in
# words and by a human reading the scoresheet, so the line is converted to SAN
# when scid can do it. A tclsh test has no sc_pos: the UCI list is returned
# rather than an empty line.
proc ::facts::sanLine {fen moves} {
    if {![llength $moves]} { return {} }
    set out {}
    if {[llength [info commands sc_pos]]} {
        catch { set out [sc_pos coordToSAN $fen $moves] }
        if {[llength $out] == [llength $moves]} { return $out }
    }
    return $moves
}

# A line as a scoresheet writes it: "12... Nxd6 13. Nxd6 Qa5". With no ply to
# start from, the moves are still SAN but unnumbered.
proc ::facts::numberedLine {startPly moves} {
    if {![string is integer -strict $startPly] || $startPly < 1} {
        return [join $moves { }]
    }
    set out {}
    set ply $startPly
    foreach one $moves {
        if {$ply % 2 == 1} {
            lappend out "[expr {($ply + 1) / 2}]."
        } else {
            lappend out "[expr {$ply / 2}]..."
        }
        lappend out $one
        incr ply
    }
    return [join $out { }]
}

proc ::facts::lineText {fen moves {startPly 0}} {
    return [numberedLine $startPly [sanLine $fen $moves]]
}

# Build the FACTS block for one flagged move.
proc ::facts::forMove {m} {
    set lines {}
    set played [dict get $m played]
    set best [expr {[dict exists $m best_uci] ? [dict get $m best_uci] : ""}]
    set fb [dict get $m fen_before]
    # The position after the move is a function of the position before it, so a
    # caller that has only the game can leave it out.
    set fa [expr {[dict exists $m fen_after] ? [dict get $m fen_after]
        : [::chessboard::toFen [::chessboard::makeMove [::chessboard::fromFen $fb] $played]]}]
    # Downstream helpers ask for the position after the move; give it to them
    # whether the caller passed it or we derived it.
    dict set m fen_after $fa

    set p [describeMove $fb $played]
    set what [movePhrase $p]
    if {[dict get $p check]} { append what " with check" }
    if {[dict get $p promo]} { append what " and promotes" }
    # strip only the leading article: "the queen takes the pawn" -> "queen takes the pawn"
    regsub {^the } $what "" what
    lappend lines "played: [dict get $p side]'s $what"

    foreach l [motifLines $m] { lappend lines $l }

    # What the move actually achieved, stated before any alternative. Without
    # this the reader (and the model) infers from "the better move wins the
    # pawn" that the played move did not - which is how a queen capture came to
    # be described as "leaving the pawn untouched".
    set mover [expr {[dict get $m side] eq "white" ? "w" : "b"}]
    set pg [gainsOf $fb $played $mover]
    if {[llength $pg] && ![dict get $p mate]} {
        lappend lines "what the move played achieved: it [join $pg {, }]"
    }

    # The engine's answer, and its line - for a mistake/miss/blunder the line
    # IS the explanation, so it is always included.
    set line [expr {[dict exists $m best_pv_long] ? [dict get $m best_pv_long]
        : ([dict exists $m best_pv] ? [dict get $m best_pv] : {})}]
    # The move played is ply; the continuation starts on the next one. Without a
    # ply the line is still SAN, just not numbered.
    set ply 0
    if {[dict exists $m ply] && [string is integer -strict [dict get $m ply]]} {
        set ply [dict get $m ply]
    }
    set nextPly [expr {$ply > 0 ? $ply + 1 : 0}]
    if {$best ne "" && $best ne $played} {
        set b [describeMove $fb $best]
        # Name the side that makes the alternative. "the pawn taking the knight
        # on e5" left two of three models reading the pawn as White's and
        # asserting a recapture White cannot make.
        set bside [dict get $b side]
        set bpiece [dict get $b piece]
        set bfrom [dict get $b from]
        set bto [dict get $b to]
        if {[dict get $b castle]} {
            set bwhat "$bside's king castles"
        } elseif {[dict get $b capture] ne ""} {
            set bwhat "$bside's $bpiece on $bfrom takes the [dict get $b capture] on [dict get $b capture_sq]"
        } else {
            set bwhat "$bside's $bpiece on $bfrom moves to $bto"
        }
        if {[dict get $b check]} { append bwhat " with check" }
        set bsan [expr {[dict exists $m best_san] ? [dict get $m best_san] : ""}]
        set bg [gainsOf $fb $best $mover]
        set shared {}
        set extra {}
        foreach g [lrange $bg 0 2] {
            if {[lsearch -exact $pg $g] >= 0} { lappend shared $g } else { lappend extra $g }
        }
        # The tail must not leave the model to invent a reason. Two cases give
        # it nothing to work with, and both used to produce one: "failed to
        # develop as Nc6 would have" was written for a move that develops, and
        # "would have prevented Ng5" for a pawn push whose own line plays Ng5.
        set tail ""
        if {[llength $shared] && [llength $extra]} {
            set tail ": it also [join $shared { and }], and unlike the move played it [join $extra { and }]"
        } elseif {![llength $bg]} {
            set tail ": the facts here give no reason for the engine's preference"
        } elseif {![llength $extra]} {
            set tail ": it [join [lrange $bg 0 2] {, }], which the move played also does, so the engine's preference is positional and not captured by these facts"
        } else {
            set tail ": it [join [lrange $bg 0 2] {, }]"
        }
        if {$bsan ne ""} {
            lappend lines "better was $bsan - $bwhat$tail"
        } else {
            lappend lines "better was $bwhat$tail"
        }
        if {[llength $line] > 1} {
            # Convert the whole line from the position before the move: the
            # second move is only legal after the first, so slicing first would
            # ask for SAN of a move that is not on this board.
            set sans [sanLine $fb $line]
            lappend lines "the line after that better move runs [numberedLine $nextPly [lrange $sans 1 end]]"
        }
    } elseif {[llength $line] > 1} {
        set sans [sanLine $fb $line]
        lappend lines "the line after the move played runs [numberedLine $nextPly [lrange $sans 1 end]]"
    }

    # The punishment: what the opponent forces after the move played. It comes
    # from the next analysed position (the caller attaches it), because
    # the engine line from before this move only describes the alternative - and
    # when a blunder ends in mate, the mate IS the reason the label exists.
    if {$best ne "" && $best ne $played && [dict exists $m punish_pv]} {
        set ppv [dict get $m punish_pv]
        if {[llength $ppv]} {
            set pline [lineText $fa $ppv $nextPly]
            if {[string match {*#} [string trim [lindex $pline end]]]} {
                lappend lines "the line after the move played runs $pline and it ends in checkmate"
            } else {
                lappend lines "the line after the move played runs $pline"
            }
        }
    }

    lappend lines [inventoryLine $fb "w"]
    lappend lines [inventoryLine $fb "b"]
    set ruleLines {}
    lappend ruleLines [castlingLine $fb]
    lappend ruleLines [epLine $fb]
    lappend ruleLines [clockLine $fb]
    if {[dict exists $m rep_count]} {
        lappend ruleLines [repetitionLine [dict get $m rep_count]]
    } else {
        # ply counts the move being commented, one-based (phaseMoveLine derives
        # the move number from it), so the position before it is ply-1 plies
        # into the game. Replaying $ply would reach the position after the move,
        # whose side to move never matches. Without ply there is no way to know
        # where the position is in the game, and replaying zero moves would
        # answer for the start position instead.
        if {[dict exists $m ply] && [dict get $m ply] > 0} {
            set ply [dict get $m ply]
            lappend ruleLines [repetitionLine [repFromMainline $fb [expr {$ply - 1}]]]
        } else {
            lappend ruleLines [repetitionLine ""]
        }
    }
    foreach l $ruleLines { if {$l ne ""} { lappend lines $l } }
    # (rule lines are all non-empty by construction now)
    lappend lines [materialLine $fa]
    set note [materialEvalNote $m]
    if {$note ne ""} { lappend lines $note }
    return [join $lines "\n"]
}

# ---- material swing and forks ----------------------------------------------
# What an error actually cost, and whether the punishment was a fork. A comment
# that says "the rook was taken" when the sequence was a fork winning the
# exchange teaches the wrong lesson: the capture was not the point.

# Pieces per type and side, as {w,q 1 w,r 2 ... b,p 8}: the raw material of a
# position, from which a swing can name what actually changed hands.
proc ::facts::pieceCounts {fen} {
    array set c {w,q 0 w,r 0 w,b 0 w,n 0 w,p 0 b,q 0 b,r 0 b,b 0 b,n 0 b,p 0}
    foreach p [dict get [::chessboard::fromFen $fen] board] {
        if {$p eq ""} continue
        set k [string tolower $p]
        set side [expr {[string is upper $p] ? "w" : "b"}]
        if {[info exists c($side,$k)]} { incr c($side,$k) }
    }
    return [array get c]
}

proc ::facts::_countPhrase {pairs} {
    set words {}
    foreach {k n} $pairs {
        set name [pieceName $k]
        if {$n == 1} { lappend words "a $name" } else { lappend words "$n ${name}s" }
    }
    if {![llength $words]} { return "" }
    if {[llength $words] == 1} { return [lindex $words 0] }
    return "[join [lrange $words 0 end-1] {, }] and [lindex $words end]"
}

# Net material won and lost between two positions, from the point of view of
# the side that came out ahead. The value difference is always reported; the
# pieces are named only from the counts, because a two-point swing is not
# necessarily a rook for a knight - it can be two pawns.
proc ::facts::materialSwing {fenA fenB} {
    # The value difference comes from total material, which a promotion changes
    # correctly (a pawn becomes a queen); the piece lists below only describe
    # what left the board.
    set wa 0 ; set ba 0 ; set wb 0 ; set bb 0
    set ok 1
    if {[catch {
        lassign [::chessboard::material [::chessboard::fromFen $fenA]] wa ba
        lassign [::chessboard::material [::chessboard::fromFen $fenB]] wb bb
    }]} { set ok 0 }
    if {!$ok} { return "" }
    set delta [expr {($ba - $bb) - ($wa - $wb)}]
    if {$delta == 0} { return "" }

    set a "" ; set b ""
    catch { set a [pieceCounts $fenA] }
    catch { set b [pieceCounts $fenB] }
    if {$a eq "" || $b eq ""} { return "" }
    array set A $a ; array set B $b

    set lostW {} ; set lostB {} ; set appeared 0
    foreach k {q r b n p} {
        set d [expr {$A(w,$k) - $B(w,$k)}]
        if {$d > 0} { lappend lostW $k $d } elseif {$d < 0} { set appeared 1 }
        set d [expr {$A(b,$k) - $B(b,$k)}]
        if {$d > 0} { lappend lostB $k $d } elseif {$d < 0} { set appeared 1 }
    }
    set side [expr {$delta > 0 ? "White" : "Black"}]
    set points [expr {abs($delta)}]

    # A piece that appeared where a pawn used to be was promoted, not won, so
    # "won X for Y" would name the wrong pieces; the points are still right.
    if {$appeared} {
        set word [expr {$points == 1 ? "point" : "points"}]
        return "$side came out $points $word of material ahead"
    }

    set won  [expr {$delta > 0 ? $lostB : $lostW}]
    set gave [expr {$delta > 0 ? $lostW : $lostB}]

    # A rook for a knight is worth exactly two points and is the common shape,
    # but name it only when the counts show that trade.
    if {[llength $won] == 2 && [llength $gave] == 2 &&
        [lindex $won 0] eq "r" && [lindex $gave 0] eq "n" &&
        [lindex $won 1] == 1 && [lindex $gave 1] == 1} {
        return "$side won the exchange (a rook for a knight)"
    }
    if {![llength $gave]} { return "$side won [_countPhrase $won]" }
    return "$side won [_countPhrase $won] for [_countPhrase $gave]"
}

# A fork in its useful sense: the move gives check AND attacks another piece
# worth a minor piece or more. Returns "" for anything else.
proc ::facts::forkLine {fenBefore uci} {
    if {[string length $uci] < 4} { return "" }
    set pos ""
    catch { set pos [::chessboard::fromFen $fenBefore] }
    if {$pos eq ""} { return "" }
    set pos2 ""
    catch { set pos2 [::chessboard::makeMove $pos $uci] }
    if {$pos2 eq ""} { return "" }
    set toSq [::chessboard::sqIndex [string range $uci 2 3]]
    set bd2 [dict get $pos2 board]
    set piece [::chessboard::pieceAt $bd2 $toSq]
    if {$piece eq ""} { return "" }
    set mover [::chessboard::colorOf $piece]
    set other [expr {$mover eq "w" ? "b" : "w"}]
    set ksq -1
    catch { set ksq [::chessboard::kingSquare $pos2 $other] }
    if {$ksq < 0} { return "" }
    # the move must give check, or it is not a fork in the sense that matters
    set check 0
    catch { set check [::chessboard::attacked $pos2 $ksq $mover] }
    if {!$check} { return "" }
    set targets {}
    for {set sq 0} {$sq < 64} {incr sq} {
        if {$sq == $ksq} continue
        set p [::chessboard::pieceAt $bd2 $sq]
        if {$p eq ""} continue
        if {[::chessboard::colorOf $p] ne $other} continue
        set v 0
        catch { set v [::facts::valueOf $p] }
        if {$v < 3} continue
        set hit 0
        catch { set hit [::facts::attacksFrom $pos2 $toSq $sq] }
        if {!$hit} continue
        # A moved piece that is itself pinned cannot take the target.
        if {![::facts::legalCapture $pos2 $toSq $sq $mover]} continue
        lappend targets "the [string tolower [::facts::pieceName $p]] on [::chessboard::sqName $sq]"
        if {[llength $targets] >= 2} break
    }
    if {![llength $targets]} { return "" }
    set me "[string tolower [::facts::pieceName $piece]] on [::chessboard::sqName $toSq]"
    # The check may be the moved piece's own, or a discovered one from a piece
    # it uncovered; crediting the moved piece with a check it does not give is
    # a false fact either way.
    set direct 0
    catch { set direct [::facts::attacksFrom $pos2 $toSq $ksq] }
    if {$direct} {
        return "the punishment is a fork: the $me checks the king and attacks [join $targets { and }]"
    }
    set checker ""
    for {set sq 0} {$sq < 64} {incr sq} {
        if {$sq == $toSq} continue
        set p [::chessboard::pieceAt $bd2 $sq]
        if {$p eq ""} continue
        if {[::chessboard::colorOf $p] ne $mover} continue
        set hit 0
        catch { set hit [::facts::attacksFrom $pos2 $sq $ksq] }
        if {!$hit} continue
        set checker "the [string tolower [::facts::pieceName $p]] on [::chessboard::sqName $sq]"
        break
    }
    if {$checker eq ""} { return "" }
    return "the punishment is a discovered check: the $me attacks [join $targets { and }] while $checker checks the king"
}
