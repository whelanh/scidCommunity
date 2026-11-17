# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# move_labels.tcl -- the label ladder, in tclsh.
#
#   tclsh tests/tcl/move_labels.tcl
#
# The ladder is a threshold table, so the tests are a table too: one row per
# boundary that decides a label, plus the mate transitions that no centipawn
# table can express. A property check pins the one thing a table cannot: a
# bigger loss never earns a better label.

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
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools move_labels.tcl]

puts "labels"

# The best move is best whatever the score did: the label says the move was the
# engine's choice, not that the position stayed good.
checkEq "the engine's own move is best" [::movelabels::label -900 -900 1] best

# Table: {before after expected drop expected}, both from the mover's point of
# view. The drop is pinned with the label so a threshold cannot drift silently:
# each pair sits just inside or just outside a boundary of the ladder.
set table {
    {20   18    excellent  0.18}
    {20   0     excellent  1.84}
    {20   -10   good       2.76}
    {20   -30   good       4.60}
    {20   -50   inaccuracy 6.43}
    {0    -49   good       4.50}
    {0    -99   inaccuracy 9.01}
    {0    -110  inaccuracy 9.99}
    {0    -111  mistake   10.08}
    {0    -230  mistake   19.99}
    {0    -240  blunder   20.76}
    {900  880   excellent  0.26}
    {900  850   good       0.68}
    {-900 -950   good       0.57}
}
foreach row $table {
    lassign $row b a want wantDrop
    checkEq "label $b -> $a" [::movelabels::label $b $a] $want
    set drop [::movelabels::winDrop $b $a]
    check "drop $b -> $a is $wantDrop" \
        [expr {abs($drop - $wantDrop) < 0.02}] "got [format %.2f $drop]"
}

# The two labels that also test the centipawn loss: a small win-percentage drop
# with a big loss is not "excellent". 900 -> 850 gives up half a pawn but the
# position was already won, so the curve barely moves - the loss guard decides.
check "a won position keeps a 50cp loss out of excellent" \
    [expr {[::movelabels::label 900 850] eq "good"}]
check "the same drop with a 20cp loss is excellent" \
    [expr {[::movelabels::label 900 880] eq "excellent"}]

# The boundaries themselves, in both directions.
check "a 1.93 point drop is still excellent" \
    [expr {[::movelabels::winDrop 0 -21] < 2 && [::movelabels::label 0 -21] eq "excellent"}]
check "a 2.02 point drop is not" \
    [expr {[::movelabels::winDrop 0 -22] >= 2 && [::movelabels::label 0 -22] eq "good"}]
check "a 4.95 point drop is still good" \
    [expr {[::movelabels::label 0 -54] eq "good"}]
check "a 5.05 point drop is an inaccuracy" \
    [expr {[::movelabels::label 0 -55] eq "inaccuracy"}]

# A mate is worth 100%, so losing one is the biggest drop there is; keeping the
# same mate is no loss at all.
set m3 [::movelabels::mateToCp 3]
set m2 [::movelabels::mateToCp 2]
set mNeg [::movelabels::mateToCp -3]
checkEq "delivering a mate stays excellent" [::movelabels::label $m3 $m2] excellent
checkEq "walking into a mate is a blunder" [::movelabels::label 0 $mNeg] blunder
checkEq "losing a won mate is a blunder" [::movelabels::label $m3 0] blunder
check "a mate score is recognised as a mate" [::movelabels::isMate $m3]
check "a tablebase centipawn score is not a mate" \
    [expr {![::movelabels::isMate 9165]}]

# UCI's `mate 0` is the side to move already mated, so it is the largest loss
# for that side - and the largest win for the mover who delivered it. Read as a
# win for the side to move, it made the move that delivered the mate a blunder.
set m0 [::movelabels::mateToCp 0]
check "mate 0 is a loss for the side to move" \
    [expr {$m0 == -100000}] "got $m0"
checkEq "mate 0 from the mover's own side is a loss" \
    [::movelabels::forMover {} 0 w w] -100000
checkEq "mate 0 delivered to the opponent is a win for the mover" \
    [::movelabels::forMover {} 0 b w] 100000
checkEq "the move that delivers mate is not blamed for it" \
    [::movelabels::label $m3 [::movelabels::forMover {} 0 b w]] excellent
checkEq "being mated by the opponent's move is a blunder" \
    [::movelabels::label 0 [::movelabels::forMover {} 0 w w]] blunder

# Opposite signs are the mover going from being mated to mating. A legal move
# cannot produce that pair - a mover already mated has no move to play - but
# cpLoss and winDrop are public and are documented as the amount given up, so an
# improvement must not read as the maximum loss. The reverse direction, throwing
# a mate away, still does.
set mLost [::movelabels::mateToCp -3]
set mWon [::movelabels::mateToCp 3]
checkEq "an improvement between mate scores loses nothing" \
    [::movelabels::cpLoss $mLost $mWon] 0
checkEq "an improvement between mate scores is no drop" \
    [::movelabels::winDrop $mLost $mWon] 0.0
checkEq "and is not labelled a blunder" \
    [::movelabels::label $mLost $mWon] excellent
checkEq "losing a mate in a mate-to-mate pair is still a blunder" \
    [::movelabels::label $mWon $mLost] blunder

# Every mate, however far off, has to stay outside MATE_CP_THRESHOLD: a mate in
# 101 used to encode to 89900 and be scored on the centipawn curve as if it were
# an ordinary evaluation.
set farMates 1
foreach d {1 2 3 50 99 100 101 102 200 1000 -100 -101 -1000} {
    set cp [::movelabels::mateToCp $d]
    if {![::movelabels::isMate $cp]} {
        set farMates 0
        puts "    (mate $d encodes to $cp, under the threshold)"
    }
}
check "every mate distance encodes past the mate threshold" $farMates
set m101 [::movelabels::mateToCp 101]
check "a mate in 101 is still a mate" [::movelabels::isMate $m101]
check "a mate in 101 keeps the sign of the mate" \
    [expr {$m101 > 0 && [::movelabels::mateToCp -101] < 0}]
checkEq "delivering a mate in 101 is still excellent" \
    [::movelabels::label [::movelabels::mateToCp 102] $m101] excellent
checkEq "walking into a mate in 101 is still a blunder" \
    [::movelabels::label 0 [::movelabels::mateToCp -101]] blunder

# The reported symptom, end to end: the last move of a game delivers mate. The
# evaluations are White's view, so the position after it is a win of 100% for
# White - the side to move, Black, is mated, which is UCI's `mate 0` from
# Black's side of the board.
set mateGame [list 0 0 0 0 0 0 [::movelabels::mateToCp 2] \
                  [expr {-[::movelabels::mateToCp 0]}]]
set mateLabels [::movelabels::game $mateGame]
checkEq "the move that delivers mate is not blamed" [lindex $mateLabels 6] excellent
checkEq "the mating move is best when the engine chose it" \
    [lindex [::movelabels::game $mateGame {6}] 6] best

# UCI scores are from the side to move; the ladder wants the mover's view.
checkEq "black's move takes the negated score" \
    [::movelabels::forMover 120 {} b b] 120
checkEq "white's score is negated for a black mover" \
    [::movelabels::forMover 120 {} w b] -120
checkEq "mate scores are negated too" \
    [::movelabels::forMover {} 3 w b] [expr {-1 * [::movelabels::mateToCp 3]}]

# Monotonicity: for one starting score, a bigger drop never earns a better
# label. This is the property the threshold table exists to keep.
set order {best excellent good inaccuracy mistake blunder}
set prev -1
set monotone 1
foreach after {0 -20 -49 -50 -80 -99 -100 -200 -300 -500 -900} {
    set l [::movelabels::label 50 $after]
    set idx [lsearch -exact $order $l]
    if {$idx < $prev} { set monotone 0 }
    set prev $idx
}
check "a bigger loss never earns a better label" $monotone

# A whole game: White's evaluations in, one label per move out. Black's plies
# are judged from Black's side, so the same centipawn sequence reads differently
# for the two players.
set cps {0 0 0 0 0 -300 -300}
set labels [::movelabels::game $cps]
checkEq "one label per move" [llength $labels] 6
checkEq "white's quiet move is excellent" [lindex $labels 0] excellent
checkEq "black's quiet reply is excellent" [lindex $labels 1] excellent
checkEq "white blunders the eval" [lindex $labels 4] blunder
checkEq "black's reply is not blamed for it" [lindex $labels 5] excellent

# The engine's chosen plies are labelled best.
set chosen [::movelabels::game $cps {1 4}]
checkEq "a chosen ply is best" [lindex $chosen 1] best
checkEq "and the other plies are not" [lindex $chosen 0] excellent

# ---- refinements ---------------------------------------------------------
puts "refinements"

proc rctx {args} {
    set d [dict create is_best 0 cp_before 0 cp_after 0 cp_loss 0 win_drop 0.0 \
        ply 20 legal_moves 30 candidates {} played "" fen_before "" fen_after "" \
        pv_after_played {}]
    dict for {k v} $args { dict set d $k $v }
    return $d
}

# The board a claim has to be tested on. `great` and `brilliant` both exclude a
# move that simply takes what was left hanging, and that exclusion is a question
# about the position before the move: without the board the question is
# unanswerable, and an unanswerable question is not a pass. a1a2 is quiet, so it
# is not a free capture - the board below is the evidence, not the move.
set quietFen {4k3/8/8/8/8/8/8/R3K3 w - - 0 1}
check "the great board's move is not a free capture" \
    [expr {![::movelabels::isFreeCapture $quietFen a1a2]}]

# One legal move is not a choice.
checkEq "a forced move is forced, whatever it costs" \
    [::movelabels::refine blunder [rctx legal_moves 1 cp_loss 900]] forced

# Opening moves are book, not judgement - but a blunder in the opening is still
# a blunder, and the caller can say a position is out of book.
checkEq "an opening move is book" [::movelabels::refine excellent [rctx ply 5]] book
checkEq "a blunder in the opening stays a blunder" \
    [::movelabels::refine blunder [rctx ply 5]] blunder
checkEq "the caller can override the book boundary" \
    [::movelabels::refine excellent [rctx ply 5 in_book 0]] excellent
# ... and the override reaches the refinements: an early move the caller has
# taken out of book can still be great, which the raw ply check prevented.
checkEq "an early move taken out of book can be great" \
    [::movelabels::refine good [rctx ply 5 in_book 0 is_best 1 cp_before 0 cp_after -10 \
        candidates {300 50} played a1a2 fen_before $quietFen]] great

# The only move that keeps the game: a wide MultiPV gap.
checkEq "the only move that holds is great" \
    [::movelabels::refine good [rctx is_best 1 cp_before 0 cp_after -10 candidates {300 50} \
        played a1a2 fen_before $quietFen]] great
checkEq "a wide gap in a lost position is a forced retreat, not great" \
    [::movelabels::refine good [rctx is_best 1 cp_before -400 cp_after -350 candidates {300 -350} \
        played a1a2 fen_before $quietFen]] good
checkEq "a rescue from a lost position is great" \
    [::movelabels::refine good [rctx is_best 1 cp_before -200 cp_after -50 \
        played a1a2 fen_before $quietFen]] great

# A missing board is not evidence that the move did not simply take what was
# left hanging, so it cannot stand as a pass: both routes to great fail closed,
# and an unprovable claim falls through to the ladder rather than being made.
# The rescue needs no candidates at all, which is why the caller's round-2 gate
# (withhold `candidates` when the replay failed) left this one open.
checkEq "a rescue with no board is best, not great" \
    [::movelabels::refine best [rctx is_best 1 cp_before -400 cp_after -20 \
        played e1e2]] best
checkEq "the same rescue beside a board it did not take on is great" \
    [::movelabels::refine best [rctx is_best 1 cp_before -400 cp_after -20 \
        played a1a2 fen_before $quietFen]] great

# ... but not when it simply takes what the opponent left hanging.
set freeFen {4k2r/8/8/8/8/8/8/R3K2R w - - 0 1}
checkEq "taking a piece left hanging is not great" \
    [::movelabels::refine good [rctx is_best 1 cp_before 0 cp_after -50 \
        candidates {300 50} fen_before $freeFen played h1h8]] good
check "a free rook capture is recognised" [::movelabels::isFreeCapture $freeFen h1h8]

# The board loss is the fact that does not move when the two scales disagree.
checkEq "a three-pawn loss is a blunder even if the curve rounds under" \
    [::movelabels::refine mistake [rctx cp_loss 350 win_drop 15.0 cp_before 100]] blunder
checkEq "the same loss in a decided game is not" \
    [::movelabels::refine mistake [rctx cp_loss 350 win_drop 15.0 cp_before 900 cp_after 850]] mistake

# A miss gave up a win, not just a better position.
checkEq "throwing away a winning advantage is a miss" \
    [::movelabels::refine mistake [rctx cp_before 200 cp_after 20]] miss
checkEq "throwing away a mate is a miss" \
    [::movelabels::refine blunder [rctx cp_before [::movelabels::mateToCp 3] cp_after 0]] miss
checkEq "a small concession is not a miss" \
    [::movelabels::refine mistake [rctx cp_before 100 cp_after 40]] mistake

# A sound sacrifice is brilliant: the piece given up is worth two or more after
# the move, the engine likes it, and the line does not simply trade back.
set sacFen {r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/2N2N2/PPPP1PPP/R1BQK2R w KQkq - 6 5}
set sacAfter {r1bqk2r/pppp1ppp/2n2n2/2b1N3/2B1P3/2N5/PPPP1PPP/R1BQK2R b KQkq - 0 5}
check "the sacrifice costs two" \
    [expr {[::chessboard::hangingMaterial $sacFen $sacAfter w] == 2}]
checkEq "a sound sacrifice is brilliant" \
    [::movelabels::refine good [rctx is_best 1 cp_before 20 cp_after 10 ply 14 \
        fen_before $sacFen fen_after $sacAfter played f3e5 pv_after_played {c6e5}]] brilliant
checkEq "without the board it cannot be called brilliant" \
    [::movelabels::refine good [rctx is_best 1 cp_before 20 cp_after 10 ply 14]] good
# Brilliant is the label that most needs evidence: the rule is that the line
# does not simply trade the piece back, and with no line there is nothing to
# check. An absent PV used to read as "not a trade-back" and was promoted.
checkEq "a sacrifice with no line is not called brilliant" \
    [::movelabels::refine good [rctx is_best 1 cp_before 20 cp_after 10 ply 14 \
        fen_before $sacFen fen_after $sacAfter played f3e5]] good
# ... and a line that cannot be replayed is a failed check, not a pass. Nxe5 in
# SAN instead of UCI made makeMove throw, and the empty catch handler read 0 as
# "not a trade-back".
checkEq "a line that cannot be replayed is not proof either" \
    [::movelabels::refine good [rctx is_best 1 cp_before 20 cp_after 10 ply 14 \
        fen_before $sacFen fen_after $sacAfter played f3e5 pv_after_played {Nxe5}]] good
# ... and "replayable" means legal here, not merely parseable: a2a3 lands on an
# empty square and, with Black to move, moves the wrong side's pawn, so it used
# to stand as proof that the sacrifice is not traded back.
checkEq "a line that is not legal there is not proof" \
    [::movelabels::refine good [rctx is_best 1 cp_before 20 cp_after 10 ply 14 \
        fen_before $sacFen fen_after $sacAfter played f3e5 pv_after_played {a2a3}]] good
# The same override applies to brilliant: "out of book" is the caller's
# judgement (in_book), not the ply number.
checkEq "an early sacrifice taken out of book can be brilliant" \
    [::movelabels::refine good [rctx ply 5 in_book 0 is_best 1 cp_before 20 cp_after 10 \
        fen_before $sacFen fen_after $sacAfter played f3e5 pv_after_played {c6e5}]] brilliant
# A legal quiet reply is a different matter: the piece is not being taken back,
# which is what the rule asks about.
checkEq "a legal quiet reply leaves the sacrifice sound" \
    [::movelabels::refine good [rctx is_best 1 cp_before 20 cp_after 10 ply 14 \
        fen_before $sacFen fen_after $sacAfter played f3e5 pv_after_played {a7a6}]] brilliant

# A line that trades straight back is not a sacrifice.
set tradeFen {rnbqkbnr/ppp2ppp/8/3pp3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 0 4}
set tradeAfter {rnbqkbnr/ppp2ppp/8/3pN3/4P3/8/PPPP1PPP/RNBQKB1R b KQkq - 0 4}
check "a recapture that restores the material is trivial" \
    [::movelabels::isTrivialRecapture w $tradeFen {d5e4} $tradeAfter]
check "a recapture that leaves material behind is not" \
    [expr {![::movelabels::isTrivialRecapture w $sacFen {c6e5} $sacAfter]}]

# The free-capture exclusion applies to BOTH routes to great, not just the
# MultiPV gap: a rescue that only grabs a piece the opponent left hanging is
# still the obvious move.
checkEq "a rescue that just takes a hanging piece is not great" \
    [::movelabels::refine good [rctx is_best 1 cp_before -200 cp_after -50 \
        fen_before $freeFen played h1h8]] good
checkEq "the same rescue without the free capture is great" \
    [::movelabels::refine good [rctx is_best 1 cp_before -200 cp_after -50 \
        played a1a2 fen_before $quietFen]] great
# The board question has to be answerable in both helpers: a position the core
# rejects used to leave the answer at 0 ("not a free capture") and let a wide
# gap stand as great.
checkEq "an unreadable position does not make a move great" \
    [::movelabels::refine good [rctx is_best 1 cp_before 0 cp_after -10 \
        candidates {300 50} fen_before {not/a/fen w} played e2e4]] good

# A defended pawn is not a free capture; an undefended one is.
check "a defended pawn is not free" \
    [expr {![::movelabels::isFreeCapture {4k3/8/2p5/3p4/4P3/8/8/4K3 w - - 0 1} e4d5]}]
check "an undefended pawn is free" \
    [::movelabels::isFreeCapture {4k3/8/8/3p4/4P3/8/8/4K3 w - - 0 1} e4d5]
# An en-passant capture lands on an empty square: the pawn is taken beside the
# destination, and that is the victim the exchange is priced from.
check "an undefended en passant capture is free" \
    [::movelabels::isFreeCapture {4k3/8/8/3pP3/8/8/8/4K3 w - d6 0 1} e5d6]
check "a recaptured en passant capture is not" \
    [expr {![::movelabels::isFreeCapture {4k3/2p5/8/3pP3/8/8/8/4K3 w - d6 0 1} e5d6]}]
checkEq "an en passant capture of a hanging pawn is not great" \
    [::movelabels::refine good [rctx is_best 1 cp_before 0 cp_after -10 \
        candidates {300 50} played e5d6 \
        fen_before {4k3/8/8/3pP3/8/8/8/4K3 w - d6 0 1}]] good

# "Trades back" is two-sided: a line that wins a rook on the way is not a
# trade, and must not be read as one.
# The opponent takes a pawn, the mover then takes a rook: the line is +4 for
# the mover, so it is not a trade-back however the difference is signed.
set winFen {4k2r/8/8/3p4/2P1P3/8/8/4K2R w - - 0 1}
set winAfter {4k2r/8/8/3p4/2P1P3/8/8/4K2R b - - 0 1}
check "a line that wins material is not a trade-back" \
    [expr {![::movelabels::isTrivialRecapture w $winFen {d5e4 h1h8} $winAfter]}]

# Precedence: giving up a win is a miss, not a blunder, even though the board
# loss also trips the blunder upgrade.
checkEq "a move from +3 to 0 is a miss, not a blunder" \
    [::movelabels::refine mistake [rctx cp_before 300 cp_after 0 cp_loss 300 win_drop 20.0]] miss
# The book override has to reach every guard, not just the labels: an early
# novelty marked out of book is judged, and one still in book is not.
checkEq "a big loss in an early novelty is a blunder" \
    [::movelabels::refine mistake [rctx ply 5 in_book 0 cp_before 100 cp_after -200 cp_loss 300 win_drop 20.0]] blunder
checkEq "the same loss in book is not upgraded" \
    [::movelabels::refine mistake [rctx ply 5 cp_before 100 cp_after -200 cp_loss 300 win_drop 20.0]] mistake
checkEq "a big loss in a level position is still a blunder" \
    [::movelabels::refine mistake [rctx cp_before 100 cp_after -200 cp_loss 300 win_drop 20.0]] blunder

# An ordinary move is left alone.
checkEq "nothing to refine" [::movelabels::refine good [rctx]] good

# The label tokens are identifiers; the words a reader sees come from the
# translation table, and every label must have an entry there.
checkEq "without a translation table the token is returned" \
    [::movelabels::text blunder] blunder
proc tr {tag} { return "T<$tag>" }
checkEq "the display text comes from the translation table" \
    [::movelabels::text blunder] {T<MoveLabelBlunder>}
checkEq "the key is the label in title case" \
    [::movelabels::text inaccuracy] {T<MoveLabelInaccuracy>}
rename tr {}

# Translation completeness. A missing key falls back to English through tr(),
# which is correct behaviour but would silently ship an untranslated label, so
# every language file is checked for all six. The language tables are procs
# (setLanguage_<code>) that read application globals, so the keys are read from
# the files rather than by executing them.
set langDir [file join $root tcl lang]
set langFiles {
    E english.tcl   K catalan.tcl   C czech.tcl     D deutsch.tcl
    F francais.tcl  G greek.tcl     H hungary.tcl   I italian.tcl
    N nederlan.tcl  O norsk.tcl     P polish.tcl    B portbr.tcl
    R russian.tcl   Y serbian.tcl   S spanish.tcl   U suomi.tcl
    W swedish.tcl   M chinese.tcl   T turkish.tcl   J SerbCyr.tcl
    A japanese.tcl  L romanian.tcl  V hebrew.tcl    Z swahili.tcl
    h hindi.tcl     Q ukrainian.tcl b bengali.tcl   k korean.tcl
    g bulgarian.tcl
}
proc langText {file} {
    set fh [open $file r]
    fconfigure $fh -encoding utf-8
    set text [read $fh]
    close $fh
    return $text
}
set missingAll {}
foreach {code file} $langFiles {
    set text [langText [file join $langDir $file]]
    set missing {}
    foreach l {Best Excellent Good Inaccuracy Mistake Blunder \
               Brilliant Great Miss Forced Book} {
        if {![regexp "translate $code MoveLabel$l \{(.+?)\}" $text -> word]
            || [string trim $word] eq ""} {
            lappend missing $l
        }
    }
    check "$file defines all eleven label keys" [expr {![llength $missing]}] "missing: $missing"
    if {[llength $missing]} { lappend missingAll $file }
}
check "no language file is missing a label key" [expr {![llength $missingAll]}] "files: $missingAll"

# Spot checks that the entries are translations and not the English word left
# behind by a propagation run.
regexp {translate D MoveLabelBlunder \{(.+?)\}} [langText [file join $langDir deutsch.tcl]] -> de
checkEq "german blunder" $de {Grober Fehler}
regexp {translate F MoveLabelMistake \{(.+?)\}} [langText [file join $langDir francais.tcl]] -> fr
checkEq "french mistake" $fr {Erreur}
regexp {translate M MoveLabelBlunder \{(.+?)\}} [langText [file join $langDir chinese.tcl]] -> zh
checkEq "chinese blunder" $zh {严重失误}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
