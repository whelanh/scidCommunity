/*
 * Copyright (C) 2026  Fulvio Benini
 *
 * This file is part of Scid (Shane's Chess Information Database).
 *
 * Scid is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Scid is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Scid.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "pgnparse.h"
#include "scidbase.h"
#include "searchboard.h"
#include <gtest/gtest.h>
#include <memory>
#include <string>
#include <vector>

namespace {

/// In-memory database built from a list of PGN games.
struct TestDb {
	scidBaseT base;

	explicit TestDb(const std::vector<std::string>& pgnGames) {
		EXPECT_EQ(OK, base.open("MEMORY", FMODE_Create, "Memory"));
		for (const auto& pgn : pgnGames) {
			Game game;
			PgnParseLog log;
			EXPECT_TRUE(pgnParseGame(pgn.c_str(), pgn.size(), game, log))
			    << log.log;
			EXPECT_EQ(OK, base.saveGame(&game));
		}
	}

	std::vector<gamenumT> allGames() const {
		std::vector<gamenumT> res(base.numGames());
		for (gamenumT i = 0; i < base.numGames(); ++i)
			res[i] = i;
		return res;
	}
};

Position parseFen(const char* str) {
	Position pos;
	EXPECT_EQ(OK, pos.ReadFromFEN(str)) << str;
	return pos;
}

/// Mirror a position: swap the colors and rotate the board by 180 degrees.
Position mirror(const Position& src) {
	Position res;
	res.Clear();
	for (squareT sq = A1; sq <= H8; ++sq) {
		const pieceT piece = src.GetPiece(sq);
		if (piece != EMPTY)
			res.AddPiece(PIECE_FLIP[piece], square_Relative(BLACK, sq));
	}
	res.SetToMove(color_Flip(src.GetToMove()));
	return res;
}

BoardSearchResult search(const TestDb& db, const Position& pos,
                         BoardSearchOptions options = {},
                         std::vector<gamenumT> candidates = {},
                         const Progress& progress = Progress()) {
	if (candidates.empty())
		candidates = db.allGames();
	return boardSearch(db.base, candidates, {pos}, options, progress);
}

const char* PGN_NAJDORF =
    "[Event \"Najdorf\"]\n[White \"Alice\"]\n[Black \"Bob\"]\n"
    "[Result \"1-0\"]\n\n"
    "1. e4 c5 2. Nf3 d6 3. d4 cxd4 4. Nxd4 Nf6 5. Nc3 a6 6. Be3 e5 1-0";

const char* PGN_BERLIN =
    "[Event \"Berlin\"]\n[White \"Carol\"]\n[Black \"Dave\"]\n"
    "[Result \"1/2-1/2\"]\n\n"
    "1. e4 e5 2. Nf3 Nc6 3. Bb5 Nf6 4. O-O Nxe4 1/2-1/2";

/// After 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6, White to move.
const char* FEN_NAJDORF =
    "rnbqkb1r/1p2pppp/p2p1n2/8/3NP3/2N5/PPP2PPP/R1BQKB1R w KQkq - 0 7";

/// Same board as FEN_NAJDORF, Black to move.
const char* FEN_NAJDORF_BLACK =
    "rnbqkb1r/1p2pppp/p2p1n2/8/3NP3/2N5/PPP2PPP/R1BQKB1R b KQkq - 0 7";

/// Same pawns as FEN_NAJDORF, but the white knight is back on b1.
const char* FEN_NAJDORF_KNIGHT_MOVED =
    "rnbqkb1r/1p2pppp/p2p1n2/8/3NP3/8/PPP2PPP/RNBQKB1R w KQkq - 0 7";

/// Same pawns-per-file as FEN_NAJDORF, but the e and d pawns are one rank
/// further: White pawns on a2-b2-c2-e5-f2-g2-h2, Black on a6-b7-d5-e7-f7-g7-h7.
const char* FEN_NAJDORF_FILES_SHIFTED =
    "rnbqkb1r/1p2pppp/p4n2/3pP3/3N4/2N5/PPP2PPP/R1BQKB1R w KQkq - 0 7";

} // namespace

TEST(SearchBoard, exactMainLine) {
	TestDb db({PGN_NAJDORF, PGN_BERLIN});

	auto res = search(db, parseFen(FEN_NAJDORF));
	ASSERT_EQ(BoardSearchStatus::Ok, res.status);
	ASSERT_EQ(2u, res.ply.size());
	EXPECT_EQ(11, res.ply[0]); // reached after 10 plies (5...a6)
	EXPECT_EQ(0, res.ply[1]);
}

TEST(SearchBoard, sideToMoveMustMatch) {
	TestDb db({PGN_NAJDORF, PGN_BERLIN});

	auto res = search(db, parseFen(FEN_NAJDORF_BLACK));
	ASSERT_EQ(BoardSearchStatus::Ok, res.status);
	EXPECT_EQ(0, res.ply[0]);
	EXPECT_EQ(0, res.ply[1]);
}

TEST(SearchBoard, candidateSubset) {
	TestDb db({PGN_NAJDORF, PGN_BERLIN});

	auto res = search(db, parseFen(FEN_NAJDORF), {}, {1});
	ASSERT_EQ(BoardSearchStatus::Ok, res.status);
	ASSERT_EQ(1u, res.ply.size());
	EXPECT_EQ(0, res.ply[0]);
}

TEST(SearchBoard, exactIgnoresSamePawnsElsewhere) {
	TestDb db({PGN_NAJDORF, PGN_BERLIN});

	auto res = search(db, parseFen(FEN_NAJDORF_KNIGHT_MOVED));
	ASSERT_EQ(BoardSearchStatus::Ok, res.status);
	EXPECT_EQ(0, res.ply[0]);
}

TEST(SearchBoard, matchPawns) {
	TestDb db({PGN_NAJDORF, PGN_BERLIN});

	BoardSearchOptions options;
	options.matchType = GAME_EXACT_MATCH_Pawns;
	options.useIndexOptimizations = true;

	auto res = search(db, parseFen(FEN_NAJDORF_KNIGHT_MOVED), options);
	ASSERT_EQ(BoardSearchStatus::Ok, res.status);
	EXPECT_EQ(11, res.ply[0]); // same pawns as after 5...a6

	auto shifted = search(db, parseFen(FEN_NAJDORF_FILES_SHIFTED), options);
	EXPECT_EQ(0, shifted.ply[0]); // the pawns are on different squares
}

TEST(SearchBoard, matchFiles) {
	TestDb db({PGN_NAJDORF, PGN_BERLIN});

	BoardSearchOptions options;
	options.matchType = GAME_EXACT_MATCH_Fyles;
	options.useIndexOptimizations = false;

	auto res = search(db, parseFen(FEN_NAJDORF_FILES_SHIFTED), options);
	ASSERT_EQ(BoardSearchStatus::Ok, res.status);
	// The pawn files match from 4...Nf6 on (White to move); after 3...cxd4
	// Black still had two pawns on the d-file.
	EXPECT_EQ(9, res.ply[0]);
}

TEST(SearchBoard, matchMaterial) {
	TestDb db({PGN_NAJDORF, PGN_BERLIN});

	BoardSearchOptions options;
	options.matchType = GAME_EXACT_MATCH_Material;
	options.useIndexOptimizations = false;

	// The searched position has 15 pieces per side. Only the Najdorf game
	// reaches that material, for the first time after 4...Nf6 (ply 8).
	auto res = search(db, parseFen(FEN_NAJDORF), options);
	ASSERT_EQ(BoardSearchStatus::Ok, res.status);
	EXPECT_EQ(9, res.ply[0]);
	EXPECT_EQ(0, res.ply[1]);
}

TEST(SearchBoard, variations) {
	TestDb db({"[Event \"Var\"]\n[White \"A\"]\n[Black \"B\"]\n"
	           "[Result \"1-0\"]\n\n"
	           "1. e4 (1. d4 d5 2. c4 e6) 1... e5 2. Nf3 1-0"});

	// Position after 2...e6, i.e. the last position of the variation.
	auto pos = parseFen("rnbqkbnr/ppp2ppp/4p3/3p4/2PP4/8/PP2PPPP/"
	                    "RNBQKBNR w KQkq - 0 4");

	auto mainLineOnly = search(db, pos);
	ASSERT_EQ(BoardSearchStatus::Ok, mainLineOnly.status);
	EXPECT_EQ(0, mainLineOnly.ply[0]);

	BoardSearchOptions options;
	options.searchInVariations = true;
	auto res = search(db, pos, options);
	ASSERT_EQ(BoardSearchStatus::Ok, res.status);
	// 1.d4 d5 2.c4 e6: ply 4 of the variation, not the branch point.
	EXPECT_EQ(5, res.ply[0]);
}

TEST(SearchBoard, matchBeyondPly255IsNotAReadError) {
	// 65 knight-shuffle cycles (260 plies), then a3 at ply 261: a position
	// reached only once, beyond the 255 cap.
	std::string pgn = "[Event \"Long\"]\n[White \"A\"]\n[Black \"B\"]\n"
	                  "[Result \"*\"]\n\n";
	for (int i = 0; i < 65; ++i)
		pgn += "Nf3 Nf6 Ng1 Ng8 ";
	pgn += "a3 *";

	TestDb db({pgn});
	auto res = search(db, parseFen("rnbqkbnr/pppppppp/8/8/8/P7/1PPPPPPP/"
	                               "RNBQKBNR b KQkq - 0 1"));
	ASSERT_EQ(BoardSearchStatus::Ok, res.status);
	EXPECT_FALSE(res.readError);
	ASSERT_EQ(1u, res.ply.size());
	EXPECT_EQ(255, res.ply[0]);
}

TEST(SearchBoard, ignoreColors) {
	TestDb db({PGN_NAJDORF, PGN_BERLIN});

	// Position after 3.Bb5 in the Berlin game, with the colors reversed:
	// it does not occur in any game.
	auto pos = mirror(parseFen("r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/"
	                           "PPPP1PPP/RNBQK2R b KQkq - 3 3"));

	auto noFlip = search(db, pos);
	ASSERT_EQ(BoardSearchStatus::Ok, noFlip.status);
	EXPECT_EQ(0, noFlip.ply[0]);

	BoardSearchOptions options;
	options.ignoreColors = true;
	auto res = search(db, pos, options);
	ASSERT_EQ(BoardSearchStatus::Ok, res.status);
	EXPECT_EQ(0, res.ply[0]);    // the Najdorf game does not contain it
	EXPECT_NE(0, res.ply[1]);    // the Berlin game does, with the colors swapped
}

TEST(SearchBoard, startPosition) {
	TestDb db({PGN_NAJDORF, PGN_BERLIN});

	auto res = search(db, parseFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/"
	                               "RNBQKBNR w KQkq - 0 1"));
	ASSERT_EQ(BoardSearchStatus::Ok, res.status);
	ASSERT_EQ(2u, res.ply.size());
	EXPECT_EQ(1, res.ply[0]);
	EXPECT_EQ(1, res.ply[1]);
}

namespace {

struct CancelProgress : Progress::Impl {
	bool report(size_t, size_t, const char*) override { return false; }
};

/// Cancels only in the final report (1 of 1), which runs once the search
/// has finished.
struct CancelAtEnd : Progress::Impl {
	bool report(size_t done, size_t total, const char*) override {
		return !(done == 1 && total == 1);
	}
};

} // namespace

TEST(SearchBoard, cancellation) {
	TestDb db({PGN_NAJDORF, PGN_BERLIN});

	Progress progress(new CancelProgress);
	auto res = search(db, parseFen(FEN_NAJDORF), {}, {}, progress);
	EXPECT_EQ(BoardSearchStatus::Cancelled, res.status);
}

TEST(SearchBoard, cancellationInFinalProgress) {
	TestDb db({PGN_NAJDORF, PGN_BERLIN});

	Progress progress(new CancelAtEnd);
	auto res = search(db, parseFen(FEN_NAJDORF), {}, {}, progress);
	EXPECT_EQ(BoardSearchStatus::Cancelled, res.status);
}
