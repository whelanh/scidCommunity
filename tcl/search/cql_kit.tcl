# Copyright (C) 2026 David Crandall
# Copyright (C) 2026 scidCommunity contributors
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of Scid (Shane's Chess Information Database).
#
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.
#
# Scid is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Scid.  If not, see <http://www.gnu.org/licenses/>.
#
# The building blocks - the tabs, block names, their queries and their value
# ranges - are ported from Scid vs. PC's tcl/search/board.tcl. The engine they
# write for came from the same place: see src/cql/README.md.

namespace eval ::search {}

# ::search::cqlKit*
#
#   The CQL window's building blocks: a notebook of tabs, each holding groups
#   of checkboxes that write a query for the user. Clicking a block adds its
#   condition to the query box, so a user can build a query without knowing
#   the language. The blocks are ported from Scid vs. PC.
#
#   Queries are written from White's point of view. "Both colours" wraps the
#   whole query in flipcolor, which retries it with colours and the board
#   reversed; with it off only White's side is searched. If a block has values,
#   %r in its query is the chosen rank (and %s the rank above it), %f and %t are
#   the chosen file (or the two files of a value like c+d), %l and %g are the
#   files beside those, and %p is the chosen piece. The first value is the
#   default.
#
#   The labels below are deliberately English-only: the block list is large and
#   machine translation would be poor, so there are no translation catalogue
#   entries for these strings. A future translation can replace the lookup in
#   ::search::cqlKitLabel without touching the block list.
#
#   The list is: tab {group {name query values ...} ...} ...

set ::search::cqlKitList {
  CQLTabMates {
    CQLMates {
      Checkmate     {btm mate} {}
      BackRankMate  {btm mate k[a-h8] attack ([RQ][a-h8] k)} {}
      SmotheredMate {btm mate attack (N k) not [_A] on anydirection 1 k} {}
      MateBy         {btm mate attack (%p k)} {N Q R B P}
      ArabianMate    {flip {btm mate kh8 Rh7 Nf6}} {}
      EpauletteMate  {btm mate shifthorizontal {kd8 [qrbnp]c8 [qrbnp]e8}} {}
      Stalemate     {stalemate} {}
    }
    CQLTactics {
      KnightFork     {btm piece $x in N {countsquares 2 100 attack ($x [kqr]) not attack ([pbn] $x) {not attack (a $x) or attack (A $x)}}} {}
      PawnFork       {btm piece $x in P[a-h3-7] {countsquares 2 100 attack ($x [kqrbn]) {not attack (a $x) or attack (A $x)}}} {}
      PinDiagonal   {ray diagonal ([BQ] [nrq] k)} {}
      PinLine       {ray orthogonal ([RQ] [nb] k)} {}
      PinOnQueen     {ray diagonal (B [nr] q) or ray orthogonal (R [nb] q)} {}
      Skewer        {btm {ray diagonal ([BQ] k [qr]) or ray orthogonal ([RQ] k [qr])}} {}
    }
    CQLChecks {
      DoubleCheck   {btm {attack (N k) attack ([BRQ] k)} or {attack (B k) attack ([RQ] k)} or {attack (R k) attack (Q k)} or {attack (P k) attack ([BRQ] k)}} {}
      Promotion      {move promote [QRBN]} {}
      Underpromotion {move promote [RBN]} {}
    }
  }
  CQLPawns {
    CQLPassed {
      PassedPawn    {shifthorizontal {Pd%r not p[c%s-8,d%s-8,e%s-8]}} {4 5 6 7}
      ConnectedPassed {shifthorizontal {P[d%r-7] P[e%r-7] not p[c%s-8,d%s-8,e%s-8,f%s-8]}} {4 5 6}
      ProtectedPassed {shifthorizontal {Pd%r not p[c%s-8,d%s-8,e%s-8] attack (P Pd%r)}} {4 5 6 7}
      BlockadedPassed {shifthorizontal {Pd%r not p[c%s-8,d%s-8,e%s-8] [nbrqk]d%s}} {4 5 6}
      RookBehindPassed {shifthorizontal {Pd%r not p[c%s-8,d%s-8,e%s-8] ray up (R Pd%r)}} {4 5 6 7}
      PassedOnFile   {{P%f4 not p[%l5-8,%f5-8,%g5-8]} or {P%f5 not p[%l6-8,%f6-8,%g6-8]} or {P%f6 not p[%l7-8,%f7-8,%g7-8]} or {P%f7 not p[%l8,%f8,%g8]}} {a b c d e f g h}
    }
    CQLWeakPawns {
      IsolatedPawn  {P[%f2-7] not P[%l2-7,%g2-7]} {a b c d e f g h}
      DoubledPawns   {countsquares 2 8 P[%f2-7]} {a b c d e f g h}
      DoubledIsolated {countsquares 2 8 P[%f2-7] not P[%l2-7,%g2-7]} {a b c d e f g h}
      TripledPawns  {shifthorizontal countsquares 3 P[b2-7]} {}
    }
    CQLPawnPlay {
      PawnRoller     {shifthorizontal {Pc%r Pd%r Pe%r}} {4 5 6}
      PawnStorm      {k[g8,h8] K[a-c1] P[g4-6] P[h4-6]} {}
      QueensideMajority {not [Qq] countsquares 3 3 P[a-c2-7] countsquares 2 2 p[a-c2-7] movenumber 30 1000} {}
      PawnsVsPiece   {not [QRBN] countsquares 1 [qrbn] [bn] countsquares 2 8 P not p} {}
      PawnsVsQueen   {not [QRBN] countsquares 1 q not [rbn] countsquares 1 8 P} {}
    }
  }
  CQLTabStructures {
    CQLQueenPawn {
      HangingPawns  {P%f4 P%t4 not P[%l2-7,%g2-7] not p[%f2-7,%t2-7]} {b+c c+d d+e e+f}
      BlockedIQP     {Pd4 not P[c2-7,e2-7] nd5} {}
      Carlsbad       {Pd4 Pe3 pd5 pc6 not P[c2-7] not p[e2-7]} {}
      Slav           {Pc4 Pd4 pc6 pd5} {}
      ExchangeSlav   {Pd4 pd5 not [Pp][c2-7] P[e2-3] p[e6-7]} {}
      Stonewall      {Pc3 Pd4 Pe3 Pf4} {}
      NimzoDoubled   {Pc3 Pc4 Pd4} {}
    }
    CQLFrenchCaro {
      FrenchChain    {Pd4 Pe5 pd5 pe6} {}
      FrenchExchange {Pd4 pd5 not [Pp][e2-7]} {}
      CaroAdvance    {Pd4 Pe5 pc6 pd5 pe6} {}
      CaroClassical  {Pd4 pc6 pe6 not p[d2-7] not P[e2-7]} {}
      ClosedRuy      {Pd4 Pe4 pd6 pe5} {}
      RuyExchange    {countsquares 2 2 p[c2-7] Pe4 not P[d2-7] not p[d2-7]} {}
    }
    CQLSicilian {
      OpenSicilian   {Pe4 not P[d2-7] not p[c2-7] p[d6-7] p[e5-7]} {}
      Scheveningen   {Pe4 not P[d2-7] not p[c2-7] pd6 pe6} {}
      SicilianE5     {Pe4 not P[d2-7] not p[c2-7] pd6 pe5} {}
      Dragon         {Pe4 not P[d2-7] not p[c2-7] pd6 pg6} {}
      Maroczy        {Pc4 Pe4 not P[d2-7] pd6 not p[c2-7]} {}
      Hedgehog       {Pa3 Pb3 Pd3 Pe3 not P[c2-7] pc5 pe5 not p[d2-7]} {}
    }
    CQLIndianCentre {
      KIDClosed      {Pc4 Pd5 Pe4 pd6 pe5} {}
      ModernBenoni   {Pd5 Pe4 pc5 pd6 not p[e2-7] not P[c2-7]} {}
      CzechBenoni    {Pc4 Pd5 Pe4 pc5 pd6 pe5} {}
      BigCentre      {Pd4 Pe4 not p[d2-7,e2-7]} {}
      OpenCentre     {not [Pp][d2-7,e2-7]} {}
      ClosedCentre   {{Pd4 Pe5 pd5 pe6} or {Pd5 Pe4 pd6 pe5}} {}
    }
  }
  CQLPieces {
    CQLHeavy {
      RooksOnRank    {countsquares 2 R[a-h%r]} {2 3 4 5 6 7 8}
      DoubledRooks   {ray vertical (R R)} {}
      RookOpenFile   {R[%f1-8] not [Pp][%f2-7]} {a b c d e f g h}
      RookHalfOpen   {R[%f1-8] not P[%f2-7] p[%f2-7]} {a b c d e f g h}
      RookOn7King    {R[a-h7] k[a-h8]} {}
    }
    CQLMinor {
      KnightOutpost {shifthorizontal {{Nd5 attack (P Nd5) not p[c6,c7,e6,e7]} or {Nd6 attack (P Nd6) not p[c7,e7]}}} {}
      BishopPair     {countsquares 2 B not N countsquares 1 b countsquares 1 n} {}
      BishopVsKnight {countsquares 1 B not N countsquares 1 n not b} {}
      BishopsVsKnights {countsquares 2 B not N countsquares 2 n not b} {}
      Fianchetto     {Bg2 Pg3 K[g1,h1]} {}
    }
    CQLKing {
      OppCastling   {K[g1,h1] k[a8,b8,c8] movenumber 1 20} {}
      KingWalk      {K[a-h%r-8] [Qq] movenumber 1 30} {4 5 6}
      KingInCentre   {K[d1,e1,d2,e2] Q q movenumber %r 1000} {15 20 25 30}
      KingExposed    {K[g1,h1] not P[g2-3,h2-3] q} {}
      LongCastling   {K[b1,c1] movenumber 1 20} {}
    }
  }
  CQLTabEndings {
    CQLEndType {
      PawnEnding    {not [QRBNqrbn] [Pp]} {}
      KnightEnding   {countsquares 1 N countsquares 1 n not [QRBqrb]} {}
      BishopEnding   {countsquares 1 B countsquares 1 b not [QRNqrn]} {}
      RookEnding     {countsquares 1 R countsquares 1 r not [QBNqbn]} {}
      QueenEnding    {countsquares 1 Q countsquares 1 q not [RBNrbn]} {}
      MinorEnding   {[BN] [bn] not [QRqr]} {}
    }
    CQLUnequal {
      RookVsMinor   {countsquares 1 [QRBN] R countsquares 1 [qrbn] [bn]} {}
      QueenVsRook    {countsquares 1 [QRBN] Q countsquares 1 [qrbn] r} {}
      BishopVsKnightEnd {countsquares 1 B countsquares 1 n not [QRNqrb]} {}
      BishopsVsKnightsEnd {countsquares 2 B not [QRN] countsquares 2 n not [qrb]} {}
      OppBishops    {B[a1,a3,a5,a7,b2,b4,b6,b8,c1,c3,c5,c7,d2,d4,d6,d8,e1,e3,e5,e7,f2,f4,f6,f8,g1,g3,g5,g7,h2,h4,h6,h8] b[a2,a4,a6,a8,b1,b3,b5,b7,c2,c4,c6,c8,d1,d3,d5,d7,e2,e4,e6,e8,f1,f3,f5,f7,g2,g4,g6,g8,h1,h3,h5,h7] countsquares 1 B countsquares 1 b not [QRNqrn]} {}
      RookVsPawns    {countsquares 1 R not [QBN] not [qrbn] p} {}
    }
    CQLMaterial {
      MaterialPlus   {wtm not check not attack (a [QRBN]) powerdifference %r 100 (A a)} {1 2 3 5}
      ExchangeUp     {wtm not check not attack (a [QRBN]) powerdifference 5 5 (R r) powerdifference -3 -3 ([BN] [bn]) powerdifference 0 0 (Q q)} {}
      TwoRooksVsQueen {wtm not check not attack (a [QRBN]) powerdifference 10 10 (R r) powerdifference -9 -9 (Q q) powerdifference 0 0 ([BN] [bn])} {}
      RookMinorVsQueen {wtm not check not attack (a [QRBN]) powerdifference 5 5 (R r) powerdifference 3 3 ([BN] [bn]) powerdifference -9 -9 (Q q)} {}
      ThreeMinorsVsQueen {wtm not check not attack (a [QRBN]) powerdifference 9 9 ([BN] [bn]) powerdifference -9 -9 (Q q) powerdifference 0 0 (R r)} {}
      TwoMinorsVsRook {wtm not check not attack (a [QRBN]) powerdifference 6 6 ([BN] [bn]) powerdifference -5 -5 (R r) powerdifference 0 0 (Q q)} {}
    }
    CQLSpecial {
      RookPawnVsRook {countsquares 1 R countsquares 1 P countsquares 1 r not [QBNqbnp]} {}
      RookBishopVsRook {countsquares 1 R countsquares 1 B not [QNP] countsquares 1 r not [qbnp]} {}
      QueenVsPawn7   {countsquares 1 Q not [RBNP] not [qrbn] countsquares 1 p[a-h2]} {}
      KBNvK          {not [QRP] countsquares 1 B countsquares 1 N not [qrbnp]} {}
      Opposition     {not [QRBNqrbn] ray orthogonal (K _ k)} {}
    }
  }
  CQLTabGame {
    CQLResult {
      ResultWin      {result 1-0} {}
      ResultDraw     {result 1/2-1/2} {}
      ResultLoss     {result 0-1} {}
    }
    CQLToMove {
      WhiteToMove    {wtm} {}
      Check          {btm check} {}
    }
    CQLPlayers {
      EloBoth        {elo white %r 4000 elo black %r 4000} {2000 2200 2400 2500 2600}
      EloSide        {elo white %r 4000} {2000 2200 2400 2500 2600}
      EloSideBelow   {elo white 0 %r} {2000 2200 2300 2400}
      EloOpponent    {elo black %r 4000} {2000 2200 2400 2500 2600}
      YearFrom       {year %r 3000} {1980 1990 2000 2010 2020}
      YearTo         {year 0 %r} {1980 1990 2000 2010 2020}
    }
  }
}

# The English labels for the keys above. They are not translation catalogue
# entries: ::search::cqlKitLabel returns them directly.
array set ::search::cqlKitLabel {
    CQLTabMates {Mates & tactics}
    CQLMates {Mates}
    CQLCheckmate {Checkmate}
    CQLBackRankMate {Back rank mate}
    CQLSmotheredMate {Smothered mate}
    CQLMateBy {Mate by}
    CQLArabianMate {Arabian mate (R+N)}
    CQLEpauletteMate {Epaulette mate}
    CQLStalemate {Stalemate}
    CQLTactics {Tactics}
    CQLKnightFork {Knight fork}
    CQLPawnFork {Pawn fork}
    CQLPinDiagonal {Pin on a diagonal}
    CQLPinLine {Pin on a file/rank}
    CQLPinOnQueen {Pin on the queen}
    CQLSkewer {Skewer (with check)}
    CQLChecks {Checks & promotion}
    CQLDoubleCheck {Double check}
    CQLPromotion {Promotion}
    CQLUnderpromotion {Underpromotion}
    CQLPawns {Pawns}
    CQLPassed {Passed pawns}
    CQLPassedPawn {Passed pawn on rank}
    CQLConnectedPassed {Connected passers from rank}
    CQLProtectedPassed {Protected passer on rank}
    CQLBlockadedPassed {Blockaded passer on rank}
    CQLRookBehindPassed {Rook behind passer on rank}
    CQLPassedOnFile {Passed pawn on file}
    CQLWeakPawns {Pawn weaknesses}
    CQLIsolatedPawn {Isolated pawn on file}
    CQLDoubledPawns {Doubled pawns on file}
    CQLDoubledIsolated {Doubled isolated pawns on file}
    CQLTripledPawns {Tripled pawns}
    CQLPawnPlay {Pawn play}
    CQLPawnRoller {Three pawns abreast on rank}
    CQLPawnStorm {Pawn storm on g/h}
    CQLQueensideMajority {Queenside majority 3 v 2}
    CQLPawnsVsPiece {Pawns v minor piece}
    CQLPawnsVsQueen {Pawns v queen}
    CQLTabStructures {Pawn structures}
    CQLQueenPawn {Queen's pawn}
    CQLHangingPawns {Hanging pawns on}
    CQLBlockedIQP {Isolani blockaded (Nd5)}
    CQLCarlsbad {Carlsbad structure}
    CQLSlav {Slav (c4 d4/c6 d5)}
    CQLExchangeSlav {Exchange Slav}
    CQLStonewall {Stonewall}
    CQLNimzoDoubled {Doubled c-pawns (c3 c4 d4)}
    CQLFrenchCaro {French, Caro, Spanish}
    CQLFrenchChain {French advance (d4 e5)}
    CQLFrenchExchange {French exchange}
    CQLCaroAdvance {Caro-Kann advance}
    CQLCaroClassical {Caro-Kann (d4/c6 e6)}
    CQLClosedRuy {Spanish (d4 e4/d6 e5)}
    CQLRuyExchange {Spanish exchange}
    CQLSicilian {Sicilian}
    CQLOpenSicilian {Open Sicilian}
    CQLScheveningen {Scheveningen (d6 e6)}
    CQLSicilianE5 {Sicilian (d6 e5)}
    CQLDragon {Dragon (d6 g6)}
    CQLMaroczy {Maroczy bind}
    CQLHedgehog {Hedgehog}
    CQLIndianCentre {Indian & centre}
    CQLKIDClosed {King's Indian closed}
    CQLModernBenoni {Modern Benoni}
    CQLCzechBenoni {Czech Benoni}
    CQLBigCentre {Big centre (d4 e4)}
    CQLOpenCentre {Open centre}
    CQLClosedCentre {Closed centre}
    CQLPieces {Pieces}
    CQLHeavy {Rooks & queens}
    CQLRooksOnRank {Two rooks on rank}
    CQLDoubledRooks {Doubled rooks}
    CQLRookOpenFile {Rook on open file}
    CQLRookHalfOpen {Rook on half-open file}
    CQLRookOn7King {Rook on 7th, king on 8th}
    CQLMinor {Minor pieces}
    CQLKnightOutpost {Knight outpost}
    CQLBishopPair {Bishop pair v B+N}
    CQLBishopVsKnight {1 bishop v 1 knight}
    CQLBishopsVsKnights {2 bishops v 2 knights}
    CQLFianchetto {Fianchetto (Bg2, castled)}
    CQLKing {King & castling}
    CQLOppCastling {Opposite castling}
    CQLKingWalk {King walk to rank}
    CQLKingInCentre {King in centre from move}
    CQLKingExposed {Castled king without g/h pawn}
    CQLLongCastling {Long castling}
    CQLTabEndings {Endings & material}
    CQLEndType {Same pieces}
    CQLPawnEnding {Pawn ending}
    CQLKnightEnding {Knight ending (N v N)}
    CQLBishopEnding {Bishop ending (B v B)}
    CQLRookEnding {Rook ending (R v R)}
    CQLQueenEnding {Queen ending (Q v Q)}
    CQLMinorEnding {Minor piece ending}
    CQLUnequal {Different pieces}
    CQLRookVsMinor {Rook v minor piece}
    CQLQueenVsRook {Queen v rook}
    CQLBishopVsKnightEnd {1 bishop v 1 knight}
    CQLBishopsVsKnightsEnd {2 bishops v 2 knights}
    CQLOppBishops {Opposite bishops}
    CQLRookVsPawns {Rook v pawns}
    CQLMaterial {Material}
    CQLMaterialPlus {Material up by}
    CQLExchangeUp {Exchange up}
    CQLTwoRooksVsQueen {Two rooks v queen}
    CQLRookMinorVsQueen {Rook + minor piece v queen}
    CQLThreeMinorsVsQueen {3 minor pieces v queen}
    CQLTwoMinorsVsRook {2 minor pieces v rook}
    CQLSpecial {Theoretical endings}
    CQLRookPawnVsRook {Rook + pawn v rook}
    CQLRookBishopVsRook {Rook + bishop v rook}
    CQLQueenVsPawn7 {Queen v pawn on 7th}
    CQLKBNvK {Bishop + knight v king}
    CQLOpposition {Kings in opposition}
    CQLTabGame {Game}
    CQLResult {Result}
    CQLResultWin {Won}
    CQLResultDraw {Draw}
    CQLResultLoss {Lost}
    CQLToMove {Position}
    CQLWhiteToMove {To move}
    CQLCheck {Opponent in check}
    CQLPlayers {Players & year}
    CQLEloBoth {Both players rated from}
    CQLEloSide {Rated from}
    CQLEloSideBelow {Rated up to}
    CQLEloOpponent {Opponent rated from}
    CQLYearFrom {Year from}
    CQLYearTo {Year up to}
    CQLBothColours {Both colours}
    CQLMoves {Moves}
    CQLClear {Clear all}
    CQLSearching {Searching for:}
    CQLAnd {AND}
    CQLWhiteOnly {White only}
    CQLOwnQuery {Own CQL query}
    CQLReplaced {- your query was replaced; Control-Z restores it}
}

# Starting values for the blocks that have a choice. Names not listed here use
# the first value of their list; a piece block uses the first piece name.
array set ::search::cqlKitDefaultValue {
  PassedPawn 6 ConnectedPassed 5 ProtectedPassed 5 IsolatedPawn d DoubledPawns c
  HangingPawns c+d RooksOnRank 7 RookOpenFile d KingWalk 5 KingInCentre 20
  MaterialPlus 2 EloBoth 2400 BlockadedPassed 5 RookBehindPassed 6
  DoubledIsolated c RookHalfOpen c EloSide 2500 EloSideBelow 2200
  EloOpponent 2500 YearFrom 2010 YearTo 2000 PassedOnFile a PawnRoller 5
}

set ::search::cqlKitBoth 1
set ::search::cqlKitMoves 0
set ::search::cqlKitFrom {}
set ::search::cqlKitTo {}
set ::search::cqlKitText {}
set ::search::cqlKitLast {}
set ::search::cqlKitSaid {}
set ::search::cqlKitNotebook {}
# Set while the kit rewrites its own move-range variables, so the trace on them
# (::search::cqlKitMoved) does not take a reset for a user edit.
set ::search::cqlKitQuiet 0

# ::search::cqlKitLabel
#   The English label for a block, group or tab key.
proc ::search::cqlKitLabel {key} {
	if {[info exists ::search::cqlKitLabel($key)]} {
		return $::search::cqlKitLabel($key)
	}
	return $key
}

# ::search::cqlKitPieceName
#   The name shown for a piece letter. The order is Scid vs. PC's.
proc ::search::cqlKitPieceName {letter} {
	switch -- $letter {
		Q { return Queen }
		R { return Rook }
		B { return Bishop }
		N { return Knight }
		P { return Pawn }
	}
	return $letter
}

# ::search::cqlKitIsPiece
#   True when a value list is a list of piece letters.
proc ::search::cqlKitIsPiece {values} {
	return [string is upper -strict [lindex $values 0]]
}

# ::search::cqlKitChoices
#   The values a block's spinbox shows: piece names for a piece list, the
#   values themselves otherwise.
proc ::search::cqlKitChoices {name values} {
	if {[::search::cqlKitIsPiece $values]} {
		set names {}
		foreach letter $values {
			lappend names [::search::cqlKitPieceName $letter]
		}
		set ::search::cqlKitNames($name) $names
		return $names
	}
	return $values
}

# ::search::cqlKitInit
#   Puts every block back to its starting state. Called when the kit is loaded
#   and whenever the window opens, so a new window starts with no blocks ticked.
proc ::search::cqlKitInit {} {
	set ::search::cqlKitQuiet 1
	array unset ::search::cqlKit
	array unset ::search::cqlKitValue
	array unset ::search::cqlKitNames
	array set ::search::cqlKitValue [array get ::search::cqlKitDefaultValue]

	foreach {tab groups} $::search::cqlKitList {
		foreach {group items} $groups {
			foreach {name query values} $items {
				set ::search::cqlKit($name) 0
				if {$values eq ""} {
					continue
				}
				set choices [::search::cqlKitChoices $name $values]
				if {![info exists ::search::cqlKitValue($name)]} {
					set ::search::cqlKitValue($name) [lindex $choices 0]
				}
			}
		}
	}

	set ::search::cqlKitBoth 1
	set ::search::cqlKitMoves 0
	set ::search::cqlKitFrom {}
	set ::search::cqlKitTo {}
	set ::search::cqlKitText {}
	set ::search::cqlKitLast {}
	set ::search::cqlKitSaid {}
	set ::search::cqlKitQuiet 0
}

# ::search::cqlKitPieceLetter
#   The piece letter matching a name shown in a spinbox.
proc ::search::cqlKitPieceLetter {name} {
	if {[string length $name] == 1 && [string is upper -strict $name]} {
		return $name
	}
	foreach letter {Q R B N P} {
		if {[::search::cqlKitPieceName $letter] eq $name} {
			return $letter
		}
	}
	return $name
}

# ::search::cqlKitSubstitute
#   Fills the placeholders in one block's query with the current choice.
proc ::search::cqlKitSubstitute {name query values value} {
	if {[string is integer -strict $value]} {
		return [string map [list %r $value %s [expr {$value + 1}]] $query]
	}
	if {[::search::cqlKitIsPiece $values]} {
		return [string map [list %p [::search::cqlKitPieceLetter $value]] $query]
	}
	set first [string index $value 0]
	set last [string index $value end]
	set files {a b c d e f g h}
	set left [lindex {b a b c d e f g} [lsearch -exact $files $first]]
	set right [lindex {b c d e f g h g} [lsearch -exact $files $last]]
	return [string map [list %f $first %t $last %l $left %g $right] $query]
}

# ::search::cqlKitBuild
#   Builds the query the current blocks describe. Returns a two-element list:
#   the query (empty when no block is ticked) and a description of what it
#   searches for. The description is what the window shows under the blocks.
proc ::search::cqlKitBuild {} {
	set body {}
	set said {}
	set any 0

	foreach {tab groups} $::search::cqlKitList {
		foreach {group items} $groups {
			foreach {name query values} $items {
				if {![info exists ::search::cqlKit($name)]
						|| !$::search::cqlKit($name)} {
					continue
				}
				incr any
				set text [::search::cqlKitLabel CQL$name]
				if {$values ne ""} {
					set value $::search::cqlKitValue($name)
					set query [::search::cqlKitSubstitute $name $query $values $value]
					append text " $value"
				}
				append body " \{$query\}"
				lappend said $text
			}
		}
	}

	# A move-number range is a condition of its own: it needs no block.
	set from $::search::cqlKitFrom
	set to $::search::cqlKitTo
	if {$::search::cqlKitMoves
			&& ([string is integer -strict $from] || [string is integer -strict $to])} {
		if {![string is integer -strict $from]} { set from 1 }
		if {![string is integer -strict $to]} { set to 1000 }
		append body " movenumber $from $to"
		lappend said "[::search::cqlKitLabel CQLMoves] $from-$to"
		incr any
	}

	if {!$any} {
		return [list "" ""]
	}

	if {$::search::cqlKitBoth} {
		set query "cql() flipcolor \{$body \}"
		set side [::search::cqlKitLabel CQLBothColours]
	} else {
		set query "cql() \{$body \}"
		set side [::search::cqlKitLabel CQLWhiteOnly]
	}

	set text "[::search::cqlKitLabel CQLSearching] "
	append text [join $said " [::search::cqlKitLabel CQLAnd] "]
	append text " ($side)"
	return [list $query $text]
}

# ::search::cqlKitUpdateTabs
#   Puts the number of ticked blocks in each tab's label.
proc ::search::cqlKitUpdateTabs {} {
	set nb $::search::cqlKitNotebook
	if {$nb eq "" || ![winfo exists $nb]} {
		return
	}
	set i 0
	foreach {tab groups} $::search::cqlKitList {
		set n 0
		foreach {group items} $groups {
			foreach {name query values} $items {
				if {[info exists ::search::cqlKit($name)]
						&& $::search::cqlKit($name)} {
					incr n
				}
			}
		}
		set label [::search::cqlKitLabel $tab]
		if {$n} {
			$nb tab $i -text "$label ($n)"
		} else {
			$nb tab $i -text $label
		}
		incr i
	}
}

# ::search::cqlKitSay
#   Explains the query in the box, unless it is one the blocks did not write.
proc ::search::cqlKitSay {} {
	set t $::search::cqlTextWidget
	if {$t eq "" || ![winfo exists $t]} {
		return
	}
	set query [string trim [$t get 1.0 end]]
	if {$query eq ""} {
		set ::search::cqlKitSaid {}
	} elseif {$query eq $::search::cqlKitLast} {
		set ::search::cqlKitSaid $::search::cqlKitText
	} else {
		set ::search::cqlKitSaid [::search::cqlKitLabel CQLOwnQuery]
	}
}

# ::search::cqlKitWrite
#   Replaces the query in the box with the one the ticked blocks describe. An
#   empty set of blocks removes the query the blocks wrote last, but leaves a
#   query the user typed.
#
#   A hand-typed query is replaced too, because the blocks are the window's
#   builder and an arbitrary query cannot be merged into one: the engine has a
#   single cql() wrapper, and taking a user's query apart to re-wrap it would
#   guess at what it means. Scid vs. PC replaces it the same way. The
#   replacement is one undo step and the explanation line says so, so it is
#   never silent.
proc ::search::cqlKitWrite {} {
	lassign [::search::cqlKitBuild] query text
	set t $::search::cqlTextWidget
	set shown ""
	if {$t ne "" && [winfo exists $t]} {
		set shown [string trim [$t get 1.0 end]]
	}

	if {$query eq ""} {
		if {$t ne "" && [winfo exists $t] && $shown eq $::search::cqlKitLast} {
			$t delete 1.0 end
		}
		set ::search::cqlKitLast {}
		set ::search::cqlKitText {}
		set ::search::cqlKitSaid {}
		::search::cqlKitUpdateTabs
		return
	}

	# Text the blocks did not write is about to go. Say so below the query.
	set replaced [expr {$shown ne "" && $shown ne $::search::cqlKitLast}]

	# Writing the same text again would only add an undo step and move the
	# box's insertion cursor, which the blocks must not do to a query that
	# already says what they describe.
	if {$t ne "" && [winfo exists $t] && $shown ne $query} {
		# One undo step, so Control-z brings back the old text.
		$t configure -autoseparators 0
		$t edit separator
		$t delete 1.0 end
		$t insert end $query
		$t edit separator
		$t configure -autoseparators 1
	}
	set ::search::cqlKitLast $query
	set ::search::cqlKitText $text
	set ::search::cqlKitSaid $text
	if {$replaced} {
		append ::search::cqlKitSaid " [::search::cqlKitLabel CQLReplaced]"
	}
	::search::cqlKitUpdateTabs
}

# ::search::cqlKitMoved
#   A trace on the move-range variables. A value that changed means the user is
#   building a query, so tick Moves and rewrite it. The kit's own edits (a
#   reset, Clear all) are suppressed with cqlKitQuiet.
#
#   This is a variable trace rather than a <KeyRelease> binding, which is what
#   Scid vs. PC uses: <KeyRelease> fires when the cursor is merely moved
#   (ticking Moves and rewriting the query for nothing), and a middle-click
#   paste changes the value without firing it at all.
proc ::search::cqlKitMoved {args} {
	if {$::search::cqlKitQuiet} {
		return
	}
	if {$::search::cqlKitFrom ne "" || $::search::cqlKitTo ne ""} {
		set ::search::cqlKitMoves 1
	}
	::search::cqlKitWrite
}

# ::search::cqlKitSpin
#   Called when a value spinbox changes: ticking the block is what the user
#   asked for, so do that too and rewrite the query.
proc ::search::cqlKitSpin {name} {
	set ::search::cqlKit($name) 1
	::search::cqlKitWrite
}

# ::search::cqlKitClear
#   The "Clear all" button: untick every block and forget the move range, but
#   leave a query the user typed himself alone.
proc ::search::cqlKitClear {} {
	set ::search::cqlKitQuiet 1
	foreach name [array names ::search::cqlKit] {
		set ::search::cqlKit($name) 0
	}
	set ::search::cqlKitMoves 0
	set ::search::cqlKitFrom {}
	set ::search::cqlKitTo {}
	set ::search::cqlKitQuiet 0
	::search::cqlKitWrite
}

# ::search::cqlKitReset
#   The window's reset (the Defaults button and each window opening): clear the
#   blocks and the query box, and put the values back to their defaults.
proc ::search::cqlKitReset {} {
	::search::cqlKitInit
	set t $::search::cqlTextWidget
	if {$t ne "" && [winfo exists $t]} {
		$t delete 1.0 end
	}
	::search::cqlKitUpdateTabs
}

# ::search::cqlKitFrame
#   Builds the building-block frame and its options line. The caller owns the
#   frame; this proc only fills it.
proc ::search::cqlKitFrame {f} {
	set boldfont [expr {[info exists ::font_Bold] ? "font_Bold" : "TkDefaultFont"}]

	ttk::labelframe $f.kit -text "CQL Building Blocks"
	grid $f.kit -sticky new -pady "0 6"
	grid columnconfigure $f.kit 0 -weight 1

	ttk::notebook $f.kit.nb
	pack $f.kit.nb -fill x
	set ::search::cqlKitNotebook $f.kit.nb

	set i 0
	foreach {tab groups} $::search::cqlKitList {
		set page $f.kit.nb.p$i
		ttk::frame $page
		$f.kit.nb add $page -text [::search::cqlKitLabel $tab]

		set k 0
		foreach {group items} $groups {
			set g $page.g$k
			ttk::frame $g
			ttk::label $g.l -text [::search::cqlKitLabel $group] \
				-font $boldfont
			pack $g.l -anchor w

			set j 0
			foreach {name query values} $items {
				if {![info exists ::search::cqlKit($name)]} {
					set ::search::cqlKit($name) 0
				}
				set item $g.c$j
				ttk::frame $item
				ttk::checkbutton $item.b -text [::search::cqlKitLabel CQL$name] \
					-variable ::search::cqlKit($name) \
					-command ::search::cqlKitWrite
				pack $item.b -side left

				if {$values ne ""} {
					set choices [::search::cqlKitChoices $name $values]
					if {![info exists ::search::cqlKitValue($name)]} {
						set ::search::cqlKitValue($name) [lindex $choices 0]
					}
					set width 1
					foreach choice $choices {
						if {[string length $choice] > $width} {
							set width [string length $choice]
						}
					}
					ttk::spinbox $item.v -width [expr {$width + 1}] \
						-state readonly \
						-textvariable ::search::cqlKitValue($name) \
						-values $choices \
						-command [list ::search::cqlKitSpin $name]
					pack $item.v -side left -padx "4 0"
				}

				pack $item -anchor w -padx "8 0" -pady 1
				incr j
			}

			grid $g -row [expr {$k / 2}] -column [expr {$k % 2}] \
				-sticky nw -padx 4 -pady 2
			incr k
		}
		grid columnconfigure $page {0 1} -weight 1
		incr i
	}
	::search::cqlKitUpdateTabs

	ttk::frame $f.kit.opts
	pack $f.kit.opts -fill x -pady "6 0"

	ttk::checkbutton $f.kit.opts.both -text [::search::cqlKitLabel CQLBothColours] \
		-variable ::search::cqlKitBoth -command ::search::cqlKitWrite
	ttk::checkbutton $f.kit.opts.moves -text [::search::cqlKitLabel CQLMoves] \
		-variable ::search::cqlKitMoves -command ::search::cqlKitWrite
	ttk::entry $f.kit.opts.from -width 4 -textvariable ::search::cqlKitFrom
	ttk::label $f.kit.opts.dash -text "-"
	ttk::entry $f.kit.opts.to -width 4 -textvariable ::search::cqlKitTo
	ttk::button $f.kit.opts.clear -text [::search::cqlKitLabel CQLClear] \
		-command ::search::cqlKitClear

	pack $f.kit.opts.both -side left
	pack $f.kit.opts.moves -side left -padx "12 0"
	pack $f.kit.opts.from $f.kit.opts.dash $f.kit.opts.to -side left
	pack $f.kit.opts.clear -side right

	# A move number ticks Moves: see ::search::cqlKitMoved. One trace per
	# window would be enough, but registering it only when it is missing
	# keeps a rebuilt window from stacking traces.
	foreach var {::search::cqlKitFrom ::search::cqlKitTo} {
		if {[lsearch -exact [trace info variable $var] \
				"write ::search::cqlKitMoved"] < 0} {
			trace add variable $var write ::search::cqlKitMoved
		}
	}

	ttk::label $f.kit.say -textvariable ::search::cqlKitSaid -anchor w \
		-justify left -wraplength 700
	pack $f.kit.say -fill x -pady "4 0"
}

# Put the starting state in place when this file is sourced.
::search::cqlKitInit

# ----------------------------------------------------------------------
# End of file: cql_kit.tcl
# ----------------------------------------------------------------------
