# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# comment_facts.tcl -- the board core and the fact lines, in tclsh.
#
#   tclsh tests/tcl/comment_facts.tcl
#
# Two layers are checked here, and the order matters: the facts are only as
# trustworthy as the position they are computed from, so move generation is
# pinned against the published perft counts before any fact line is compared.
# Every fact test uses a move dict of the shape a caller has after an engine
# pass, so what is checked is the contract other code will use.

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

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools comment_facts.tcl]

# ------------------------------------------------------------------- board --

proc perft {pos depth} {
    if {$depth == 0} { return 1 }
    set n 0
    foreach m [::chessboard::legalMoves $pos] {
        if {$depth == 1} {
            incr n
        } else {
            incr n [perft [::chessboard::makeMove $pos $m] [expr {$depth - 1}]]
        }
    }
    return $n
}

puts "board"

set fens {
    {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}
    {r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1}
    {8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1}
    {rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 3}
}
foreach fen $fens {
    checkEq "FEN round trip: $fen" \
        [::chessboard::toFen [::chessboard::fromFen $fen]] $fen
}

# Published perft counts. They are the only cheap proof that move generation,
# castling rights, en passant and promotion are all right at the same time.
set startpos [::chessboard::fromFen {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}]
checkEq "start position perft 1" [perft $startpos 1] 20
checkEq "start position perft 2" [perft $startpos 2] 400
checkEq "start position perft 3" [perft $startpos 3] 8902

set kiwipete [::chessboard::fromFen {r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1}]
checkEq "Kiwipete perft 1" [perft $kiwipete 1] 48
checkEq "Kiwipete perft 2" [perft $kiwipete 2] 2039

set pos3 [::chessboard::fromFen {8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1}]
checkEq "position 3 perft 1" [perft $pos3 1] 14
checkEq "position 3 perft 2" [perft $pos3 2] 191

proc seeOf {fen sq} {
    return [::chessboard::see [::chessboard::fromFen $fen] [::chessboard::sqIndex $sq]]
}
checkEq "SEE of an undefended rook" [seeOf {4k2r/8/8/8/8/8/8/R6R w - - 0 1} h8] 5
checkEq "SEE of a rook the king defends" [seeOf {6kr/8/8/8/8/8/8/R6R w - - 0 1} h8] 0
checkEq "SEE of a pawn capture" [seeOf {4k3/8/8/3n4/4P3/8/8/4K3 w - - 0 1} d5] 3
checkEq "SEE nets the recapture" [seeOf {3qk3/8/8/3n4/4P3/8/8/4K3 w - - 0 1} d5] 2
# A pawn that takes on the last rank promotes while capturing: the rook is
# worth 5 to the pawn, plus the 8 it becomes, less the queen taken back.
checkEq "SEE counts a promoting recapture" [seeOf {4k3/8/8/8/8/8/1pN5/R3K3 b - - 0 1} a1] 4

# ------------------------------------------------------------------- facts --

puts "facts"

# The move dict a caller has after an engine pass. fen_after is left out on
# purpose: it is a function of fen_before and the move, and the module derives
# it, so a caller that only has the game does not have to build it.
proc moveDict {fen played args} {
    set pos [::chessboard::fromFen $fen]
    set m [dict create fen_before $fen played $played \
        side [expr {[dict get $pos side] eq "w" ? "white" : "black"}] \
        ply 13 classification mistake]
    dict for {k v} $args { dict set m $k $v }
    return $m
}

set mate [::facts::forMove [moveDict {6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1} a1a8]]
checkEq "a mating move is reported as mate, and the block stops there" $mate \
{played: White's rook moves from a1 to a8 with check
it is checkmate
White has rook on a1, king on g1, and 3 pawns
Black has king on g8, and 3 pawns
castling: White has no castling rights; Black has no castling rights
en passant: none available
fifty-move rule: 0 of 50 moves have passed since the last capture or pawn move; 50 more would allow a draw claim
repetition: not available for this position
material: White is 5 points up, and Black is missing a rook}

# Rule state is stated in the negative too: a fact that is merely absent is
# what lets a comment invent it.
set bare [::facts::forMove [moveDict {4k3/8/8/8/8/8/8/4K3 w - - 99 80} e1d2]]
foreach prefix {castling: en\ passant: fifty-move\ rule: material} {
    check "every block states '$prefix'" \
        [regexp "(?m)^$prefix" $bare]
}
check "no castling rights is said, not implied" \
    [string match {*White has no castling rights; Black has no castling rights*} $bare]
check "the remaining fifty-move moves are counted" \
    [expr {[string match {*49 of 50 moves have passed*} $bare] \
        && [string match {*1 more would allow a draw claim*} $bare]}]

set complete [::facts::forMove [moveDict {4k3/8/8/8/8/8/8/4K3 w - - 100 80} e1d2]]
check "a complete fifty-move count is a claim" \
    [string match {*fifty-move rule: fifty moves have passed*} $complete]

set rep3 [::facts::forMove [moveDict {4k3/8/8/8/8/8/8/4K3 w - - 0 80} e1d2 rep_count 3]]
check "the caller's repetition count is used verbatim" \
    [string match {*repetition: this position has occurred 3 times*} $rep3]
set rep1 [::facts::forMove [moveDict {4k3/8/8/8/8/8/8/4K3 w - - 0 80} e1d2 rep_count 1]]
check "a first occurrence is stated, not omitted" \
    [string match {*repetition: this position has not occurred before*} $rep1]

set ep [::facts::forMove [moveDict {rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 3} e5d6]]
check "an available en passant capture is named" \
    [string match {*en passant: a pawn can be captured on d6*} $ep]

# An en passant capture takes a pawn that never stood on the landing square, so
# naming the destination as the victim's square is a false fact: the pawn taken
# from e5 to d6 is the one on d5.
check "an en passant capture names the square the pawn was taken from" \
    [string match {*takes the pawn on d5*} $ep]
check "and not the landing square" [expr {![string match {*takes the pawn on d6*} $ep]}]

# Same claim where the capture is a real gain, so "wins the pawn" is emitted.
set epWin [::facts::forMove [moveDict {4k3/8/8/3pP3/8/8/8/4K3 w - d6 0 1} e5d6]]
check "a won en passant pawn is named on its own square" \
    [string match {*wins the pawn on d5*} $epWin]

# The engine's alternative is described the same way.
set epAlt [::facts::forMove [moveDict \
    {4k3/8/8/3pP3/8/8/8/4K3 w - d6 0 1} e1d1 best_uci e5d6 best_san exd6]]
check "an en passant alternative names the captured pawn's square" \
    [string match {*takes the pawn on d5*} $epAlt]

# A normal capture still names the square it lands on.
set plain [::facts::forMove [moveDict {4k3/8/8/3p4/4P3/8/8/4K3 w - - 0 1} e4d5]]
check "a normal capture names the destination square" \
    [string match {*takes the pawn on d5*} $plain]

# Repetition from the game requires sc_game. The real command returns a Tcl
# list whose first element is the whole header, not a flat command string; the
# position before move N is reached after N-1 plies.
set startpos {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}
proc sc_game {args} {
    if {[lindex $args 0] eq "UCI_mainLine"} {
        return [list "position startpos moves" \
            g1f3 g8f6 f3g1 f6g8 g1f3 g8f6 f3g1 f6g8 e2e4]
    }
    return ""
}
checkEq "repetition counts the position the move was played in" \
    [::facts::repFromMainline $startpos 8] 3
set repMove [dict create fen_before $startpos played e2e4 side white ply 9 classification good]
check "the block states a repetition it can count" \
    [string match {*repetition: this position has occurred 3 times*} [::facts::forMove $repMove]]
set offLine [dict create fen_before {4k3/8/8/8/8/8/8/4K3 w - - 0 1} played e1d2 side white ply 9 classification good]
check "an uncountable repetition is stated, not omitted" \
    [string match {*repetition: not available for this position*} [::facts::forMove $offLine]]
check "without ply the repetition is not guessed" \
    [string match {*repetition: not available for this position*} \
        [::facts::forMove [dict create fen_before $startpos played e2e4 side white classification good]]]

# A game played from a set-up board carries its FEN in the header.
proc sc_game {args} {
    if {[lindex $args 0] eq "UCI_mainLine"} {
        return [list "position fen 4k3/8/8/8/8/8/8/4K3 w - - 0 1 moves" e1d2 e8d7 d2e1]
    }
    return ""
}
checkEq "a set-up board is replayed from its own FEN" \
    [::facts::repFromMainline {4k3/8/8/8/8/8/8/4K3 w - - 0 1} 0] 1

# A ply beyond the main line cannot be reached on it: the replay must not stop
# early and accept a coincidental match at the end of the line.
proc sc_game {args} {
    if {[lindex $args 0] eq "UCI_mainLine"} {
        return [list "position startpos moves" g1f3 g8f6 f3g1 f6g8]
    }
    return ""
}
checkEq "a ply on the main line is counted" [::facts::repFromMainline $startpos 4] 2
checkEq "a ply past the main line is not counted" [::facts::repFromMainline $startpos 8] {}
check "a position past the main line says not available" \
    [string match {*repetition: not available for this position*} \
        [::facts::forMove [dict create fen_before $startpos played e2e4 side white ply 8 classification good]]]

# An en passant square no pawn can use does not make a new position: after
# 1.e4 e5 2.Nf3 Nf6 3.Ng1 Ng8 the position repeats the one from ply 2.
proc sc_game {args} {
    if {[lindex $args 0] eq "UCI_mainLine"} {
        return [list "position startpos moves" e2e4 e7e5 g1f3 g8f6 f3g1 f6g8]
    }
    return ""
}
set afterE5 {rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2}
set sameLater {rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 6}
checkEq "an unusable ep square is not part of the position" \
    [::facts::sig $afterE5] [::facts::sig $sameLater]
checkEq "both occurrences of that position are counted" \
    [::facts::repFromMainline $afterE5 6] 2
check "a usable ep square still distinguishes positions" \
    [expr {[::facts::sig {rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 3}] ne \
           [::facts::sig {rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq - 0 3}]}]
rename sc_game {}

# En passant is only available to a pawn, even when another piece can reach the
# ep square.
checkEq "a rook reaching the ep square is not an en passant capture" \
    [::facts::epLine {4k3/8/8/8/4P3/r7/8/4K3 b - e3 0 1}] {en passant: none available}

# A king can only take an undefended piece; counting it as a cheap attacker
# called every defended piece beside the enemy king hanging.
checkEq "a defended piece beside the enemy king is not hanging" \
    [::facts::hangingPieces {8/8/8/8/8/6k1/5R2/4K3 w - - 0 1} w] {}
checkEq "an undefended piece beside the enemy king is hanging" \
    [::facts::hangingPieces {8/8/8/8/8/8/6k1/4K2R b - - 0 1} w] [list [list rook h1]]
# A pinned attacker attacks geometrically but cannot capture.
checkEq "a pinned attacker does not threaten a piece" \
    [::facts::hangingPieces {4k3/4n3/8/5R2/8/8/8/K3R3 b - - 0 1} w] {}
checkEq "the same attacker unpinned does threaten it" \
    [::facts::hangingPieces {4k3/4n3/8/5R2/8/8/8/K1R5 b - - 0 1} w] [list [list rook f5]]
# A king defending a piece does not make a cheaper attack safe: Bxf2 Kxf2 is a
# rook won for a bishop, so the rook is still hanging (SEE = 2). This is the
# opposite of the review suggestion, which would have hidden a real loss.
checkEq "SEE wins the rook for a bishop" \
    [seeOf {4k3/8/1b6/8/8/3N4/5R2/4K3 b - - 1 1} f2] 2
check "a piece defended only by its king can still be won" \
    [string match {*it leaves the rook on f2 hanging*} \
        [::facts::motifLines [dict create fen_before {4k3/8/1b6/2N5/8/8/5R2/4K3 w - - 0 1} \
            played c5d3 side white ply 13 classification mistake]]]

# A capture is judged by what the move played nets, not by the cheapest
# attacker on that square.
set lost {8/4k3/5n2/3p4/2P5/8/8/3RK3 w - - 0 1}
checkEq "the rook capture loses a point" [::facts::captureNet $lost d1d5] -1
check "it is not reported as winning the pawn" \
    [expr {[lsearch -exact [::facts::gainsOf $lost d1d5 w] {wins the pawn on d5}] < 0}]
set clean {4k3/8/8/8/4p3/8/8/4R1K1 w - - 0 1}
checkEq "a clean capture still nets the pawn" [::facts::captureNet $clean e1e4] 1
checkEq "moving a rook to the ep square is not a capture" \
    [::facts::captureNet {4k3/8/8/8/4P3/r7/8/4K3 b - e3 0 1} a3e3] 0
# Rxa1 wins a bishop, but bxa1=Q and Nxa1 make the whole sequence lose a point.
checkEq "a capture that lets a pawn promote and be taken back loses" \
    [::facts::captureNet {4k3/8/8/8/8/8/1pN5/b3K2R w - - 0 1} h1a1] -1
# A promotion gains material even though the capture is recaptured: rook (+5)
# plus queen for pawn (+8) less the queen taken back (-9) is +4.
checkEq "a promoting capture counts the new piece" \
    [::facts::captureNet {r3k3/1Pn5/8/8/8/8/8/7K w - - 0 1} b7a8q] 4
checkEq "a promoting capture into a defended square still nets" \
    [::facts::captureNet {4k1rr/6P1/8/8/8/8/8/4K3 w - - 0 1} g7h8q] 4
checkEq "a quiet promotion that is taken back loses the pawn" \
    [::facts::captureNet {4k3/6P1/8/8/8/7K/8/6r1 w - - 0 1} g7g8q] -1

# An exchange that wins material is not "left hanging"; one that loses it is.
set good {6kr/8/8/4B3/8/8/8/4K3 w - - 0 1}
set mGood [dict create fen_before $good played e5h8 side white ply 13 classification good]
checkEq "Bxh8 Kxh8 wins two points" [::facts::captureNet $good e5h8] 2
check "a winning exchange is not called hanging" \
    [expr {![string match {*hanging*} [::facts::motifLines $mGood]]}]
set bad {4k3/8/3p4/4p3/8/8/8/4R1K1 w - - 0 1}
set mBad [dict create fen_before $bad played e1e5 side white ply 13 classification mistake]
checkEq "Rxe5 dxe5 loses four points" [::facts::captureNet $bad e1e5] -4
check "a losing exchange is still called hanging" \
    [string match {*it leaves the rook on e5 hanging*} [::facts::motifLines $mBad]]

# Material is stated as what is missing from the board, not as an arithmetic
# difference the reader has to reconcile with the position.
set mat [::facts::forMove [moveDict {rnbqkb1r/ppp2ppp/5n2/3pp3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 0 5} e4d5]]
check "one point of material is not \"1 points\"" \
    [string match {*material: White is 1 point up, and Black is missing a pawn*} $mat]
check "material names only what the trailing side lost that the leader did not" \
    [string match {*material: White is 1 point up, and Black is missing a pawn*} \
        [::facts::materialLine {4k3/pppp1ppp/8/8/8/8/PPPPPPPP/4K3 w - - 0 1}]]
# White has a promoted second queen and Black still has its own: Black has not
# lost a queen, so no queen may be named.
set promoted {{materialLine} {4k2q/8/8/8/8/8/8/QQ2K3 w - - 0 1}}
checkEq "an extra queen from promotion is not a loss for the opponent" \
    [::facts::materialLine {4k2q/8/8/8/8/8/8/QQ2K3 w - - 0 1}] \
    {material: White is 9 points up}

set alt [::facts::forMove [moveDict \
    {rnbqkb1r/ppp2ppp/5n2/3pp3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 0 5} e4d5 \
    best_uci b1c3 best_san Nc3 best_pv {b1c3 e7e5 g1f3}]]
check "the move played is credited with what it achieved" \
    [string match {*what the move played achieved: it takes the pressure off*} $alt]
check "the engine's alternative names the mover and the difference" \
    [string match {*better was Nc3 - White's knight on b1 moves to c3: it also*} $alt]
check "the engine's line is included, starting after the better move" \
    [string match {*the line after that better move runs 7... e7e5 8. g1f3*} $alt]
check "the better move is not repeated in its own continuation" \
    [expr {![string match {*runs b1c3*} $alt]}]

puts "\nengine lines in scoresheet notation"

checkEq "a line with no ply is unnumbered" \
    [::facts::numberedLine 0 {Nf3 Nc6}] {Nf3 Nc6}
checkEq "a line is numbered from the ply it starts on" \
    [::facts::numberedLine 14 {Nxd6 Qa5}] {7... Nxd6 8. Qa5}
checkEq "without sc_pos the engine's own notation is kept" \
    [::facts::sanLine {8/8/8/8/8/8/8/K6k w - - 0 1} {a1a2 h1h2}] {a1a2 h1h2}
proc sc_pos {what args} {
    if {$what eq "coordToSAN"} { return {Nf3 Nc6} }
    return ""
}
checkEq "with sc_pos the line is SAN" \
    [::facts::sanLine {8/8/8/8/8/8/8/K6k w - - 0 1} {g1f3 b8c6}] {Nf3 Nc6}
# The whole line is converted from the position before the move, then the move
# it replaced is dropped: converting the tail on its own would ask for SAN of a
# move that is not legal on that board.
proc sc_pos {what args} {
    if {$what eq "coordToSAN"} { return {Bc4 Nf6 O-O} }
    return ""
}
set sanAlt [::facts::forMove [moveDict \
    {rnbqkb1r/ppp2ppp/5n2/3pp3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 0 5} e4d5 \
    best_uci b1c3 best_san Bc4 best_pv {b1c3 e7e5 g1f3}]]
check "a SAN line starts after the move it replaced" \
    [string match {*7... Nf6 8. O-O*} $sanAlt]
rename sc_pos {}

set dis [::facts::forMove [moveDict \
    {r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/2N2N2/PPPP1PPP/R1BQK2R w KQkq - 6 5} f3e5 \
    best_uci c3d5 best_san Nd5 best_pv {c3d5} eval_after_cp -250]]
check "material and the engine disagreeing is stated, with the reason" \
    [string match {*material says White is 1 point up, yet the engine still has Black ahead*} $dis]
# A two-point swing is the exchange only when the pieces say so.
checkEq "a rook for a knight is the exchange" \
    [::facts::materialSwing {r3k3/8/8/8/8/8/4N3/R3K3 w - - 0 1} {4k3/8/8/8/8/8/8/R3K3 w - - 0 1}] \
    {White won the exchange (a rook for a knight)}
checkEq "two pawns are not the exchange" \
    [::facts::materialSwing {4k3/pppppppp/8/8/8/8/PPPPPPPP/4K3 w - - 0 1} \
                            {4k3/pppppp2/8/8/8/8/PPPPPPPP/4K3 w - - 0 1}] \
    {White won 2 pawns}
checkEq "a promotion is points, not a trade" \
    [::facts::materialSwing {4k3/1P6/8/8/8/8/8/4K3 w - - 0 1} {1Q2k3/8/8/8/8/8/8/4K3 w - - 0 1}] \
    {White came out 8 points of material ahead}

# A king on g1 is not proof of castling: the note may not claim it.
set castledNote [::facts::materialEvalNote [dict create \
    fen_after {4k3/8/8/8/8/8/PPPP1PPP/6K1 w - - 0 1} eval_after_cp -300]]
check "the material/eval note does not claim a side has castled" \
    [expr {[string first "castled" $castledNote] < 0}] $castledNote

# A caller with nothing but the game must still get a usable block.
set minimal [::facts::forMove [dict create \
    fen_before {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1} \
    played e2e4 side white]]
check "a dict without fen_after, best_* or classification still works" \
    [string match {played: White's pawn moves from e2 to e4*} $minimal]
check "material is stated when the position is level" \
    [string match {*material is level*} $minimal]

# The inventory is the guard against invented pieces: nothing that is not on
# the board may be named in it.
set inv [lsearch -all -inline -regexp [split $bare "\n"] {^(White|Black) has }]
checkEq "the inventory names only what is on the board" [join $inv "|"] \
    {White has king on e1|Black has king on e8}

# A fork built on a discovered check belongs to the piece that gives the check,
# not to the piece that moved.
set discovered [::facts::forkLine {k7/1R6/2B5/4q3/8/8/8/7K w - - 0 1} b7b5]
check "a discovered check is not credited to the moved piece" \
    [string match {*discovered check*} $discovered] $discovered
check "the moved piece's target is still named" \
    [string match {*rook on b5 attacks the queen on e5*} $discovered] $discovered
check "the piece giving the check is named" \
    [string match {*bishop on c6 checks the king*} $discovered] $discovered
set direct [::facts::forkLine {7k/8/8/8/8/8/K7/3qR3 w - - 0 1} e1h1]
check "a direct check and attack is still a fork" \
    [string match {*fork: the rook on h1 checks the king and attacks the queen on d1*} $direct] $direct

# A piece that lands pinned attacks geometrically but cannot take, so it has
# no target to report (and no fork to claim).
set pinAttack {4r1k1/5q2/8/8/8/3N4/8/4K3 w - - 0 1}
check "a pinned piece does not attack a piece" \
    [expr {![string match {*attacks the queen on f7*} \
        [::facts::motifLines [dict create fen_before $pinAttack played d3e5 side white ply 13 classification mistake]]]}]
set freeAttack {4r1k1/5q2/8/8/8/3N4/4P3/4K3 w - - 0 1}
check "the same piece unpinned attacks it" \
    [string match {*attacks the queen on f7*} \
        [::facts::motifLines [dict create fen_before $freeAttack played d3e5 side white ply 13 classification mistake]]]
checkEq "a pinned checking piece is not a fork" \
    [::facts::forkLine {4r3/3k1q2/8/8/8/3N4/8/4K3 w - - 0 1} d3e5] {}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
