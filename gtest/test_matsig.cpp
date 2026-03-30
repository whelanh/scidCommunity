/*
 * Copyright (C) 2024 scidCommunity contributors
 *
 * Scid is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation.
 *
 * Scid is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Scid. If not, see <http://www.gnu.org/licenses/>.
 */

#include "matsig.h"
#include <gtest/gtest.h>

// ============================================================
// matSigT bit encoding/decoding tests
// ============================================================

TEST(Test_Matsig, GetCount_EmptySignature) {
    matSigT m = MATSIG_Empty;
    EXPECT_EQ(0u, matsig_getCount(m, WQ));
    EXPECT_EQ(0u, matsig_getCount(m, WR));
    EXPECT_EQ(0u, matsig_getCount(m, WB));
    EXPECT_EQ(0u, matsig_getCount(m, WN));
    EXPECT_EQ(0u, matsig_getCount(m, WP));
    EXPECT_EQ(0u, matsig_getCount(m, BQ));
    EXPECT_EQ(0u, matsig_getCount(m, BR));
    EXPECT_EQ(0u, matsig_getCount(m, BB));
    EXPECT_EQ(0u, matsig_getCount(m, BN));
    EXPECT_EQ(0u, matsig_getCount(m, BP));
}

TEST(Test_Matsig, GetCount_StdStart) {
    matSigT m = MATSIG_StdStart;
    EXPECT_EQ(1u, matsig_getCount(m, WQ));
    EXPECT_EQ(2u, matsig_getCount(m, WR));
    EXPECT_EQ(2u, matsig_getCount(m, WB));
    EXPECT_EQ(2u, matsig_getCount(m, WN));
    EXPECT_EQ(8u, matsig_getCount(m, WP));
    EXPECT_EQ(1u, matsig_getCount(m, BQ));
    EXPECT_EQ(2u, matsig_getCount(m, BR));
    EXPECT_EQ(2u, matsig_getCount(m, BB));
    EXPECT_EQ(2u, matsig_getCount(m, BN));
    EXPECT_EQ(8u, matsig_getCount(m, BP));
}

TEST(Test_Matsig, SetCount_BasicPieces) {
    matSigT m = MATSIG_Empty;

    m = matsig_setCount(m, WQ, 1);
    EXPECT_EQ(1u, matsig_getCount(m, WQ));
    EXPECT_EQ(0u, matsig_getCount(m, WR));

    m = matsig_setCount(m, WR, 2);
    EXPECT_EQ(1u, matsig_getCount(m, WQ));
    EXPECT_EQ(2u, matsig_getCount(m, WR));

    m = matsig_setCount(m, BQ, 3);
    EXPECT_EQ(3u, matsig_getCount(m, BQ));
    EXPECT_EQ(1u, matsig_getCount(m, WQ));
}

TEST(Test_Matsig, SetCount_OverflowClamped) {
    // Non-pawn pieces saturate at 3
    matSigT m = MATSIG_Empty;
    m = matsig_setCount(m, WQ, 5);
    EXPECT_EQ(3u, matsig_getCount(m, WQ));

    m = matsig_setCount(m, BN, 100);
    EXPECT_EQ(3u, matsig_getCount(m, BN));
}

TEST(Test_Matsig, SetCount_PawnsUpTo8) {
    // matsig_setCount checks `p != PAWN` where PAWN==WP==6.
    // So WP (the piece constant 6) bypasses the saturation clamp and can
    // store values 0-8.  BP (piece constant 14) is != PAWN and therefore
    // gets clamped to 3, just like other non-pawn pieces.
    matSigT m = MATSIG_Empty;
    for (uint i = 0; i <= 8; i++) {
        m = matsig_setCount(m, WP, i);
        EXPECT_EQ(i, matsig_getCount(m, WP));
    }
    // BP via matsig_setCount is clamped at 3
    for (uint i = 0; i <= 3; i++) {
        m = matsig_setCount(m, BP, i);
        EXPECT_EQ(i, matsig_getCount(m, BP));
    }
    m = matsig_setCount(m, BP, 6);
    EXPECT_EQ(3u, matsig_getCount(m, BP));
}

TEST(Test_Matsig, SetCount_DoesNotClobberOtherFields) {
    matSigT m = MATSIG_StdStart;
    m = matsig_setCount(m, WQ, 0);
    EXPECT_EQ(0u, matsig_getCount(m, WQ));
    // Other fields unchanged
    EXPECT_EQ(2u, matsig_getCount(m, WR));
    EXPECT_EQ(2u, matsig_getCount(m, WB));
    EXPECT_EQ(2u, matsig_getCount(m, WN));
    EXPECT_EQ(8u, matsig_getCount(m, WP));
    EXPECT_EQ(1u, matsig_getCount(m, BQ));
    EXPECT_EQ(2u, matsig_getCount(m, BR));
    EXPECT_EQ(8u, matsig_getCount(m, BP));
}

// ============================================================
// matsig_Make tests
// ============================================================

TEST(Test_Matsig, Make_EmptyMaterial) {
    byte counts[18] = {};
    matSigT m = matsig_Make(counts);
    EXPECT_EQ(MATSIG_Empty, m);
}

TEST(Test_Matsig, Make_StandardStart) {
    byte counts[18] = {};
    counts[WQ] = 1; counts[WR] = 2; counts[WB] = 2; counts[WN] = 2; counts[WP] = 8;
    counts[BQ] = 1; counts[BR] = 2; counts[BB] = 2; counts[BN] = 2; counts[BP] = 8;
    matSigT m = matsig_Make(counts);
    EXPECT_EQ(MATSIG_StdStart, m);
}

TEST(Test_Matsig, Make_SaturatesNonPawnAt3) {
    byte counts[18] = {};
    counts[WR] = 5;
    matSigT m = matsig_Make(counts);
    EXPECT_EQ(3u, matsig_getCount(m, WR));
}

TEST(Test_Matsig, Make_PawnCountsPreserved) {
    byte counts[18] = {};
    counts[WP] = 7;
    counts[BP] = 3;
    matSigT m = matsig_Make(counts);
    EXPECT_EQ(7u, matsig_getCount(m, WP));
    EXPECT_EQ(3u, matsig_getCount(m, BP));
}

// ============================================================
// matsig_makeString tests
// ============================================================

TEST(Test_Matsig, MakeString_Empty) {
    EXPECT_EQ(":", matsig_makeString(MATSIG_Empty));
}

TEST(Test_Matsig, MakeString_SingleWhiteQueen) {
    matSigT m = MATSIG_Empty;
    m = matsig_setCount(m, WQ, 1);
    EXPECT_EQ("Q:", matsig_makeString(m));
}

TEST(Test_Matsig, MakeString_Pawns) {
    matSigT m = MATSIG_Empty;
    m = matsig_setCount(m, WP, 5);
    m = matsig_setCount(m, BP, 3);
    EXPECT_EQ("5:3", matsig_makeString(m));
}

TEST(Test_Matsig, MakeString_StandardStart) {
    // Standard start: Q, RR, BB, NN, 8 pawns for each side
    EXPECT_EQ("QRRBBNN8:QRRBBNN8", matsig_makeString(MATSIG_StdStart));
}

TEST(Test_Matsig, MakeString_MixedMaterial) {
    matSigT m = MATSIG_Empty;
    m = matsig_setCount(m, WQ, 1);
    m = matsig_setCount(m, WR, 2);
    m = matsig_setCount(m, BB, 1);
    m = matsig_setCount(m, BN, 2);
    // Note: matsig_setCount clamps BP at 3 (BP != PAWN type constant).
    // Use matsig_Make to store BP=4.
    byte counts[18] = {};
    counts[WQ] = 1; counts[WR] = 2;
    counts[BB] = 1; counts[BN] = 2; counts[BP] = 4;
    m = matsig_Make(counts);
    std::string s = matsig_makeString(m);
    EXPECT_NE(s.find(':'), std::string::npos);
    EXPECT_NE(s.find('Q'), std::string::npos);
    EXPECT_NE(s.find('R'), std::string::npos);
    EXPECT_NE(s.find('B'), std::string::npos);
    EXPECT_EQ("QRR:BNN4", s);
}

TEST(Test_Matsig, MakeString_NoPawns) {
    matSigT m = MATSIG_Empty;
    m = matsig_setCount(m, WQ, 1);
    m = matsig_setCount(m, BQ, 1);
    std::string s = matsig_makeString(m);
    EXPECT_EQ("Q:Q", s);
}

// ============================================================
// matsig_isReachable tests
// ============================================================

TEST(Test_Matsig, IsReachable_SameSignature) {
    EXPECT_TRUE(matsig_isReachable(MATSIG_StdStart, MATSIG_StdStart, false, false));
    EXPECT_TRUE(matsig_isReachable(MATSIG_Empty, MATSIG_Empty, false, false));
}

TEST(Test_Matsig, IsReachable_CapturePieces) {
    // Start can reach target by capturing some pieces (target has fewer)
    matSigT start = MATSIG_StdStart;
    matSigT target = MATSIG_Empty;
    // Start has 8 white pawns, target has 0 - reachable by capturing all pawns
    EXPECT_TRUE(matsig_isReachable(start, target, false, false));
}

TEST(Test_Matsig, IsReachable_TargetHasMorePawns_NotReachable) {
    matSigT start = MATSIG_Empty;
    start = matsig_setCount(start, WP, 3);
    matSigT target = MATSIG_Empty;
    target = matsig_setCount(target, WP, 5);
    // Can't add pawns without promotion
    EXPECT_FALSE(matsig_isReachable(start, target, false, false));
}

TEST(Test_Matsig, IsReachable_TargetHasMoreQueens_NoPromos_NotReachable) {
    matSigT start = MATSIG_Empty;
    start = matsig_setCount(start, WQ, 1);
    matSigT target = MATSIG_Empty;
    target = matsig_setCount(target, WQ, 2);
    EXPECT_FALSE(matsig_isReachable(start, target, false, false));
}

TEST(Test_Matsig, IsReachable_WithPromotions_QueensCanIncrease) {
    // With promos=true, queen count is not checked
    matSigT start = MATSIG_Empty;
    start = matsig_setCount(start, WQ, 1);
    start = matsig_setCount(start, WP, 5);
    matSigT target = MATSIG_Empty;
    target = matsig_setCount(target, WQ, 3);
    // Even though WQ(start)<WQ(target), promos=true skips queen check
    EXPECT_TRUE(matsig_isReachable(start, target, true, false));
}

TEST(Test_Matsig, IsReachable_WithUnderpromotions_OnlyPawnsChecked) {
    // upromo=true: only check pawn counts
    matSigT start = MATSIG_Empty;
    start = matsig_setCount(start, WP, 5);
    matSigT target = MATSIG_Empty;
    target = matsig_setCount(target, WR, 3); // more rooks than start has
    // upromo=true => only pawn check; pawn count is OK (0 <= 0)
    EXPECT_TRUE(matsig_isReachable(start, target, true, true));
}

TEST(Test_Matsig, IsReachable_PawnDecreasedIsOk) {
    matSigT start = MATSIG_StdStart;
    matSigT target = MATSIG_Empty;
    target = matsig_setCount(target, WP, 3);
    target = matsig_setCount(target, BP, 3);
    EXPECT_TRUE(matsig_isReachable(start, target, false, false));
}

// ============================================================
// matsig_isReachablePawns tests
// ============================================================

TEST(Test_Matsig, IsReachablePawns_SameCounts) {
    matSigT m = MATSIG_StdStart;
    EXPECT_TRUE(matsig_isReachablePawns(m, m));
}

TEST(Test_Matsig, IsReachablePawns_TargetFewerPawns) {
    matSigT start = MATSIG_StdStart;
    matSigT target = MATSIG_Empty;
    target = matsig_setCount(target, WP, 4);
    target = matsig_setCount(target, BP, 4);
    EXPECT_TRUE(matsig_isReachablePawns(start, target));
}

TEST(Test_Matsig, IsReachablePawns_TargetMoreWhitePawns) {
    matSigT start = MATSIG_Empty;
    start = matsig_setCount(start, WP, 3);
    matSigT target = MATSIG_Empty;
    target = matsig_setCount(target, WP, 5);
    EXPECT_FALSE(matsig_isReachablePawns(start, target));
}

TEST(Test_Matsig, IsReachablePawns_TargetMoreBlackPawns) {
    matSigT start = MATSIG_Empty;
    start = matsig_setCount(start, BP, 2);
    matSigT target = MATSIG_Empty;
    target = matsig_setCount(target, BP, 4);
    EXPECT_FALSE(matsig_isReachablePawns(start, target));
}

// ============================================================
// MATSIG_FlipColor tests
// ============================================================

TEST(Test_Matsig, FlipColor_SwapsWhiteAndBlack) {
    // Use matsig_Make so BP=5 is stored (matsig_setCount clamps BP at 3).
    byte counts[18] = {};
    counts[WQ] = 2;
    counts[BP] = 5;
    matSigT m = matsig_Make(counts);
    EXPECT_EQ(2u, matsig_getCount(m, WQ));
    EXPECT_EQ(5u, matsig_getCount(m, BP));
    matSigT flipped = MATSIG_FlipColor(m);
    // After flip, WQ becomes BQ and BP becomes WP
    EXPECT_EQ(2u, matsig_getCount(flipped, BQ));
    EXPECT_EQ(5u, matsig_getCount(flipped, WP));
    EXPECT_EQ(0u, matsig_getCount(flipped, WQ));
    EXPECT_EQ(0u, matsig_getCount(flipped, BP));
}

TEST(Test_Matsig, FlipColor_DoubleFlipIsIdentity) {
    matSigT m = MATSIG_StdStart;
    matSigT flipped = MATSIG_FlipColor(m);
    matSigT restored = MATSIG_FlipColor(flipped);
    EXPECT_EQ(m, restored);
}

TEST(Test_Matsig, FlipColor_SymmetricPosition) {
    // Standard start is symmetric
    matSigT m = MATSIG_StdStart;
    matSigT flipped = MATSIG_FlipColor(m);
    EXPECT_EQ(m, flipped);
}

// ============================================================
// MATSIG_Has_* macro tests
// ============================================================

TEST(Test_Matsig, HasMacros) {
    matSigT m = MATSIG_StdStart;
    EXPECT_TRUE(MATSIG_Has_WQ(m));
    EXPECT_TRUE(MATSIG_Has_BQ(m));
    EXPECT_TRUE(MATSIG_Has_WR(m));
    EXPECT_TRUE(MATSIG_Has_BR(m));
    EXPECT_TRUE(MATSIG_Has_WB(m));
    EXPECT_TRUE(MATSIG_Has_BB(m));
    EXPECT_TRUE(MATSIG_Has_WN(m));
    EXPECT_TRUE(MATSIG_Has_BN(m));
    EXPECT_TRUE(MATSIG_Has_WP(m));
    EXPECT_TRUE(MATSIG_Has_BP(m));
}

TEST(Test_Matsig, HasMacros_Empty) {
    matSigT m = MATSIG_Empty;
    EXPECT_FALSE(MATSIG_Has_WQ(m));
    EXPECT_FALSE(MATSIG_Has_BQ(m));
    EXPECT_FALSE(MATSIG_Has_WR(m));
    EXPECT_FALSE(MATSIG_Has_BR(m));
    EXPECT_FALSE(MATSIG_Has_WB(m));
    EXPECT_FALSE(MATSIG_Has_BB(m));
    EXPECT_FALSE(MATSIG_Has_WN(m));
    EXPECT_FALSE(MATSIG_Has_BN(m));
    EXPECT_FALSE(MATSIG_Has_WP(m));
    EXPECT_FALSE(MATSIG_Has_BP(m));
}

TEST(Test_Matsig, HasCategoryMacros) {
    matSigT m = MATSIG_Empty;
    m = matsig_setCount(m, WQ, 1);
    m = matsig_setCount(m, BR, 1);
    EXPECT_TRUE(MATSIG_HasQueens(m));
    EXPECT_TRUE(MATSIG_HasRooks(m));
    EXPECT_FALSE(MATSIG_HasBishops(m));
    EXPECT_FALSE(MATSIG_HasKnights(m));
    EXPECT_FALSE(MATSIG_HasPawns(m));
}

// ============================================================
// MATSIG_Count_* macro tests
// ============================================================

TEST(Test_Matsig, CountMacros_StdStart) {
    matSigT m = MATSIG_StdStart;
    EXPECT_EQ(1u, MATSIG_Count_WQ(m));
    EXPECT_EQ(2u, MATSIG_Count_WR(m));
    EXPECT_EQ(2u, MATSIG_Count_WB(m));
    EXPECT_EQ(2u, MATSIG_Count_WN(m));
    EXPECT_EQ(8u, MATSIG_Count_WP(m));
    EXPECT_EQ(1u, MATSIG_Count_BQ(m));
    EXPECT_EQ(2u, MATSIG_Count_BR(m));
    EXPECT_EQ(2u, MATSIG_Count_BB(m));
    EXPECT_EQ(2u, MATSIG_Count_BN(m));
    EXPECT_EQ(8u, MATSIG_Count_BP(m));
}

// ============================================================
// hpSig_AddPawn / hpSig_ClearPawn tests
// ============================================================

TEST(Test_Matsig, HpSigAddClear_WhitePawn) {
    uint hpSig = 0;
    hpSig = hpSig_AddPawn(hpSig, WHITE, A_FYLE);
    EXPECT_EQ(0x8000u, hpSig);

    hpSig = hpSig_ClearPawn(hpSig, WHITE, A_FYLE);
    EXPECT_EQ(0u, hpSig);
}

TEST(Test_Matsig, HpSigAddClear_BlackPawn) {
    uint hpSig = 0;
    hpSig = hpSig_AddPawn(hpSig, BLACK, A_FYLE);
    EXPECT_EQ(0x0080u, hpSig);

    hpSig = hpSig_ClearPawn(hpSig, BLACK, A_FYLE);
    EXPECT_EQ(0u, hpSig);
}

TEST(Test_Matsig, HpSigAddClear_AllFiles) {
    uint hpSig = 0;
    for (fyleT f = A_FYLE; f <= H_FYLE; ++f) {
        hpSig = hpSig_AddPawn(hpSig, WHITE, f);
        hpSig = hpSig_AddPawn(hpSig, BLACK, f);
    }
    EXPECT_EQ(0xFFFFu, hpSig);

    for (fyleT f = A_FYLE; f <= H_FYLE; ++f) {
        hpSig = hpSig_ClearPawn(hpSig, WHITE, f);
        hpSig = hpSig_ClearPawn(hpSig, BLACK, f);
    }
    EXPECT_EQ(0u, hpSig);
}

// ============================================================
// hpSig_make tests
// ============================================================

TEST(Test_Matsig, HpSigMake_AllPawnsHome) {
    // Build a board with all pawns on home squares
    pieceT board[64] = {};
    // White pawns on a2..h2 (squares 8..15)
    for (int i = 0; i < 8; ++i) board[A2 + i] = WP;
    // Black pawns on a7..h7 (squares 48..55)
    for (int i = 0; i < 8; ++i) board[A7 + i] = BP;

    auto [hpSig, nMoved] = hpSig_make(board);
    // All pawns home means all bits are 0 (no missing pawns)
    EXPECT_EQ(0u, hpSig);
    EXPECT_EQ(0u, nMoved);
}

TEST(Test_Matsig, HpSigMake_NoPawnsHome) {
    // Board with no pawns on home squares
    pieceT board[64] = {};

    auto [hpSig, nMoved] = hpSig_make(board);
    // All 16 pawns missing from home squares
    EXPECT_EQ(0xFFFFu, hpSig);
    EXPECT_EQ(16u, nMoved);
}

TEST(Test_Matsig, HpSigMake_OneWhitePawnMoved) {
    pieceT board[64] = {};
    // White pawns all home except a2
    for (int i = 1; i < 8; ++i) board[A2 + i] = WP; // b2..h2
    // Black pawns all home
    for (int i = 0; i < 8; ++i) board[A7 + i] = BP;

    auto [hpSig, nMoved] = hpSig_make(board);
    EXPECT_EQ(0x8000u, hpSig);
    EXPECT_EQ(1u, nMoved);
}

// ============================================================
// hpSig_PossibleMatch tests
// ============================================================

TEST(Test_Matsig, HpSigPossibleMatch_StdStartAlwaysMatches) {
    // HPSIG_StdStart should match any game
    byte changeList[] = {2, 0xFF}; // two changes
    EXPECT_TRUE(hpSig_PossibleMatch(HPSIG_StdStart, changeList));
}

TEST(Test_Matsig, HpSigPossibleMatch_EmptyChangeList) {
    // No pawn changes in game - only HPSIG_StdStart can match
    byte changeList[] = {0}; // length 0

    // The code returns false when hpSig != HPSIG_StdStart and changeList is empty
    // because the loop runs 0 times and never finds a match
    EXPECT_FALSE(hpSig_PossibleMatch(HPSIG_Empty, changeList));
    EXPECT_TRUE(hpSig_PossibleMatch(HPSIG_StdStart, changeList));
}

TEST(Test_Matsig, HpSigPossibleMatch_SinglePawnMove) {
    // Encode a single pawn move: white a2 pawn moved (bit 15 cleared)
    // changeList: length=1, change value=15
    byte changeList[] = {1, (byte)(15 << 4)}; // halfbyte: 15 in high nibble

    // After clearing bit 15: hpSig = 0xFFFF & ~(1<<15) = 0x7FFF
    uint expected = HPSIG_StdStart & ~(1u << 15);
    EXPECT_TRUE(hpSig_PossibleMatch(expected, changeList));
    // The full 0xFFFF should match at the start (always true)
    EXPECT_TRUE(hpSig_PossibleMatch(HPSIG_StdStart, changeList));
    // A mismatched sig should not match
    EXPECT_FALSE(hpSig_PossibleMatch(0x0001u, changeList));
}

// ============================================================
// hpSig_Prefix tests
// ============================================================

TEST(Test_Matsig, HpSigPrefix_EmptyListsArePrefix) {
    byte listA[] = {0};
    byte listB[] = {0};
    EXPECT_TRUE(hpSig_Prefix(listA, listB));
}

TEST(Test_Matsig, HpSigPrefix_EmptyIsPrefix_OfAny) {
    byte empty[] = {0};
    byte nonempty[] = {2, (byte)(0xAB)}; // two changes
    EXPECT_TRUE(hpSig_Prefix(empty, nonempty));
    EXPECT_TRUE(hpSig_Prefix(nonempty, empty));
}

TEST(Test_Matsig, HpSigPrefix_SameList) {
    byte list[] = {2, (byte)(0xFE)}; // changes 15, 14
    EXPECT_TRUE(hpSig_Prefix(list, list));
}

TEST(Test_Matsig, HpSigPrefix_PrefixRelationship) {
    // listA is a prefix of listB
    byte listA[] = {1, (byte)(15 << 4)}; // change: 15
    byte listB[] = {2, (byte)(0xFE)};    // changes: 15, 14
    EXPECT_TRUE(hpSig_Prefix(listA, listB));
}

TEST(Test_Matsig, HpSigPrefix_DifferentChanges_NotPrefix) {
    byte listA[] = {1, (byte)(14 << 4)}; // change: 14
    byte listB[] = {1, (byte)(15 << 4)}; // change: 15
    EXPECT_FALSE(hpSig_Prefix(listA, listB));
}

// ============================================================
// hpSig_Final tests
// ============================================================

TEST(Test_Matsig, HpSigFinal_NoChanges) {
    byte changeList[] = {0};
    EXPECT_EQ(HPSIG_StdStart, hpSig_Final(changeList));
}

TEST(Test_Matsig, HpSigFinal_OnePawnMove) {
    // Move white a2 pawn (bit 15)
    byte changeList[] = {1, (byte)(15 << 4)};
    uint expected = HPSIG_StdStart - (1u << 15);
    EXPECT_EQ(expected, hpSig_Final(changeList));
}

TEST(Test_Matsig, HpSigFinal_TwoPawnMoves) {
    // Move white a2 (bit 15) and white b2 (bit 14)
    byte changeList[] = {2, (byte)(0xFE)}; // high nibble=15, low nibble=14
    uint expected = HPSIG_StdStart - (1u << 15) - (1u << 14);
    EXPECT_EQ(expected, hpSig_Final(changeList));
}

TEST(Test_Matsig, HpSigFinal_AllPawnsMoved) {
    // Move all 16 pawns (bits 0-15)
    // Need 8 bytes after count byte: each byte has 2 halfbytes
    byte changeList[9] = {16,
        (byte)(0xFE), // bits 15, 14
        (byte)(0xDC), // bits 13, 12
        (byte)(0xBA), // bits 11, 10
        (byte)(0x98), // bits 9, 8
        (byte)(0x76), // bits 7, 6
        (byte)(0x54), // bits 5, 4
        (byte)(0x32), // bits 3, 2
        (byte)(0x10)  // bits 1, 0
    };
    EXPECT_EQ(HPSIG_Empty, hpSig_Final(changeList));
}
