/*
 * Copyright (C) 2026 Tommaso Bergamasco
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * This file is part of scidCommunity.
 */

#include "cbh_fixture.h"
#include "cbh_format.h"
#include "codec_cb2.h"
#include "date.h"
#include "game.h"
#include "misc.h"
#include <deque>
#include <filesystem>
#include <gtest/gtest.h>

using namespace cbhtest;

namespace {

/// A database with two players, a tournament and the given games.
struct Fixture {
	TempDir dir;
	Builder b;
	Fixture() {
		b.players = {{"Anand", "Viswanathan"}, {"Carlsen", "Magnus"}};
		b.tournaments = {{"World Championship", "Chennai",
		                  (2013 << 9) | (11 << 5) | 9}};
		b.annotators = {"Kramnik, Vladimir"};
	}
	std::string write() {
		const auto stem = dir.file("db");
		b.write(stem);
		return stem + ".cbh";
	}
	GameSpec& game(const Buf& moves = moveRecord(compact({kEnd}))) {
		b.games.emplace_back();
		auto& g = b.games.back();
		g.white = 0;
		g.black = 1;
		g.tournament = 0;
		g.moves = moves;
		return g;
	}
};

std::deque<Game> readAll(const std::string& name, CodecCB2& codec) {
	std::deque<Game> res;
	EXPECT_EQ(OK, codec.open(name.c_str(), FMODE_ReadOnly));
	while (true) {
		res.emplace_back();
		if (codec.parseNext(res.back()) == ERROR_NotFound) {
			res.pop_back();
			break;
		}
	}
	return res;
}

std::string pgnOf(Game& g) {
	g.ResetPgnStyle(PGN_STYLE_VARS | PGN_STYLE_COMMENTS);
	g.SetPgnFormat(PGN_FORMAT_Plain);
	auto pgn = g.WriteToPGN();
	std::string s(pgn.first, pgn.second);
	auto body = s.find("\n\n");
	s = body == std::string::npos ? s : s.substr(body + 2);
	std::string res;
	for (auto c : s) {
		if (c == '\n')
			c = ' ';
		if (c != ' ' || (!res.empty() && res.back() != ' '))
			res += c;
	}
	while (!res.empty() && res.back() == ' ')
		res.pop_back();
	return res;
}

/// 1.e4 e5 2.Nf3 Nc6 (2...d6 3.d4 (3.Bc4) 3...exd4) (2...Nf6) 3.Bb5 a6, as
/// compact codes: a pawn's code is 111 + 4 * its number + how it moves, a
/// piece's names its number and its step.
const std::vector<int> kVariations = {
    128, 128, 105,           // e4 e5 Nf3
    kBranch, 101, 84, 111,   // Nc6 Bb5 a6
    kEnd, kBranch, 123,      // d6
    kBranch, 124, 129,       // d4 exd4
    kEnd, 92,                // Bc4
    kEnd, 108,               // Nf6
    kEnd};

constexpr const char* kVariationsPgn =
    "1.e4 e5 2.Nf3 Nc6 ( 2...d6 3.d4 ( 3.Bc4 ) 3...exd4 ) "
    "( 2...Nf6 ) 3.Bb5 a6 1-0";

} // namespace

TEST(Test_CBHCodec, game_tags) {
	Fixture fx;
	auto& g = fx.game();
	g.result = 1;
	g.round = 6;
	g.subround = 2;
	g.whiteElo = 2775;
	g.blackElo = 2870;
	g.eco = (88 + 1) * 128 + 3; // A88
	g.date = (2013 << 9) | (11 << 5) | 16;
	g.annotator = 0;
	auto& g2 = fx.game();
	g2.white = 99; // missing entities
	g2.black = 0xffffff;
	g2.tournament = 7;
	g2.annotator = 99;

	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(2u, games.size()) << codec.parseErrors();
	auto& a = games[0];
	EXPECT_STREQ("Anand, Viswanathan", a.GetWhiteStr());
	EXPECT_STREQ("Carlsen, Magnus", a.GetBlackStr());
	EXPECT_STREQ("World Championship", a.GetEventStr());
	EXPECT_STREQ("Chennai", a.GetSiteStr());
	EXPECT_STREQ("6.2", a.GetRoundStr());
	EXPECT_EQ(RESULT_Draw, a.GetResult());
	EXPECT_EQ(2775, a.GetWhiteElo());
	EXPECT_EQ(2870, a.GetBlackElo());
	EXPECT_EQ(eco_FromString("A88"), a.GetEco());
	EXPECT_EQ(DATE_MAKE(2013, 11, 16), a.GetDate());
	EXPECT_EQ(DATE_MAKE(2013, 11, 9), a.GetEventDate());
	// The annotator comes from .cbc, not from the players.
	ASSERT_NE(nullptr, a.FindExtraTag("Annotator"));
	EXPECT_STREQ("Kramnik, Vladimir", a.FindExtraTag("Annotator"));
	auto& b = games[1];
	EXPECT_STREQ("?", b.GetWhiteStr());
	EXPECT_STREQ("?", b.GetBlackStr());
	EXPECT_STREQ("?", b.GetEventStr());
	EXPECT_EQ(nullptr, b.FindExtraTag("Annotator"));
	EXPECT_NE(std::string::npos,
	          std::string(codec.parseErrors())
	              .find("ChessBase CBH database: 2 records, 2 games read."));
}

TEST(Test_CBHCodec, texts_deleted_and_unused_records_are_skipped) {
	Fixture fx;
	fx.game().byte0 = 0x03;
	fx.game().byte0 = 0x81;
	fx.game().byte0 = 0x00;
	fx.game();
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	EXPECT_EQ(1u, games.size()) << codec.parseErrors();
	EXPECT_EQ(1u, codec.counts().texts);
	EXPECT_EQ(1u, codec.counts().deleted);
	EXPECT_EQ(1u, codec.counts().unknown);
	EXPECT_EQ((std::pair<size_t, size_t>{4, 4}), codec.parseProgress());
}

TEST(Test_CBHCodec, open_checks_its_files) {
	Fixture fx;
	fx.game();
	const auto name = fx.write();
	const auto stem = name.substr(0, name.size() - 4);
	std::filesystem::remove(stem + ".cba"); // optional
	{
		CodecCB2 codec;
		EXPECT_EQ(1u, readAll(name, codec).size()) << codec.parseErrors();
	}
	for (const char* ext : {".cbg", ".cbp", ".cbt", ".cbc"}) {
		fx.b.write(stem);
		std::filesystem::remove(stem + ext);
		CodecCB2 codec;
		EXPECT_NE(OK, codec.open(name.c_str(), FMODE_ReadOnly)) << ext;
		EXPECT_NE(std::string::npos,
		          std::string(codec.parseErrors()).find(ext))
		    << codec.parseErrors();
	}
	fx.b.write(stem);
	writeFile(name, Buf(47, 0)); // not a multiple of 46
	CodecCB2 codec;
	EXPECT_NE(OK, codec.open(name.c_str(), FMODE_ReadOnly));
}

TEST(Test_CBHText, a_character_cut_by_the_field_width_is_dropped) {
	const auto field = [](const std::string& s) {
		return cbh::fieldText(
		    {reinterpret_cast<const unsigned char*>(s.data()), s.size()});
	};
	EXPECT_EQ("Anand", field(std::string("Anand\0junk", 10)));
	EXPECT_EQ("M\xc3\xbcller", field(std::string("M\xfcller\0", 7)));
	EXPECT_EQ("\xc3\xbc" "A", field("\xc3\xbc" "A\xc5"));
	// A single-byte text is not taken for cut UTF-8.
	EXPECT_EQ("A\xc3\xa2", field("A\xe2"));
}

TEST(Test_CBHWide, offsets_must_agree_with_the_header) {
	Buf r(40, 0);
	putBE(r, 0x1e, 0x100000010ull, 8);
	putBE(r, 0x0c, 0x200000020ull, 8);
	int64_t moves = 0, annotations = 0;
	ASSERT_TRUE(cbh::wideOffsets(r, 0x10, 0x20, moves, annotations));
	EXPECT_EQ(0x100000010, moves);
	EXPECT_EQ(0x200000020, annotations);
	EXPECT_FALSE(cbh::wideOffsets(r, 0x11, 0x20, moves, annotations));
	EXPECT_FALSE(cbh::wideOffsets(r, 0x10, 0x21, moves, annotations));
	EXPECT_FALSE(cbh::wideOffsets(cb2::Bytes(r).first(37), 0x10, 0x20, moves,
	                              annotations));
}

TEST(Test_CBHMoves, tables_are_permutations) {
	for (const auto* t :
	     {&cbh::kMode0, &cbh::kMode4, &cbh::kMode5, &cbh::kMode10}) {
		auto sorted = *t;
		std::sort(sorted.begin(), sorted.end());
		for (int i = 0; i < 256; ++i)
			ASSERT_EQ(i, sorted[i]);
	}
}

TEST(Test_CBHMoves, variations_in_every_encoding) {
	Fixture fx;
	fx.game(moveRecord(compact(kVariations, 0), 0));
	fx.game(moveRecord(compact(kVariations, 4), 4));
	constexpr int B = 0x8000, E = 0x4000;
	fx.game(moveRecord(
	    simple({word("e2", "e4"), word("e7", "e5"), word("g1", "f3"),
	            B | word("b8", "c6"), word("f1", "b5"), E | word("a7", "a6"),
	            B | word("d7", "d6"), B | word("d2", "d4"),
	            E | word("e5", "d4"), E | word("f1", "c4"),
	            E | word("g8", "f6")}),
	    5));
	// Filler values and bytes after the final end of line are ignored.
	auto filled = kVariations;
	filled.insert(filled.begin() + 2, kFiller);
	filled.push_back(1);
	fx.game(moveRecord(compact(filled)));
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(4u, games.size()) << codec.parseErrors();
	for (auto& g : games)
		EXPECT_EQ(kVariationsPgn, pgnOf(g));
}

TEST(Test_CBHMoves, castling_en_passant_promotion_and_the_piece_lists) {
	Fixture fx;
	// 1.e4 d5 2.e5 f5 3.exf6 -- 4.fxg7 Nc6 5.gxh8=N Bh3 6.Nf3 Qd7 7.Be2
	// O-O-O 8.O-O Na5 9.Ng6 (the promoted knight is number 3) Re8
	// 10.Re1 (the rooks castling moved).
	fx.game(moveRecord(compact(
	    {128, 124, 127, 132, 129, 0, 129, 101, kTwoByte,
	     word("g7", "h8", 3), 78, 105, 17, 94, 10, 9, 99, 232, 46, 66, kEnd})));
	// 1.Nc3 d5 2.Nxd5 Qxd5 3.Nf3: after the capture of knight 1, the knight
	// left is number 1.
	fx.game(moveRecord(compact({96, 124, 96, 15, 97, kEnd})));
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(2u, games.size()) << codec.parseErrors();
	EXPECT_EQ("1.e4 d5 2.e5 f5 3.exf6 -- 4.fxg7 Nc6 5.gxh8=N Bh3 6.Nf3 Qd7 "
	          "7.Be2 O-O-O 8.O-O Na5 9.Ng6 Re8 10.Re1 1-0",
	          pgnOf(games[0]));
	EXPECT_EQ("1.Nc3 d5 2.Nxd5 Qxd5 3.Nf3 1-0", pgnOf(games[1]));
}

TEST(Test_CBHMoves, setup_positions_and_missing_castling_rights) {
	Fixture fx;
	const std::vector<Placed> pieces = {{"e1", false, 1}, {"h1", false, 5},
	                                    {"a1", false, 5}, {"e8", true, 1},
	                                    {"a8", true, 5}};
	// With the rights stored: 20...Kd7 21.O-O.
	fx.game(moveRecord(compact({kTwoByte, word("e8", "d7"), 9, kEnd}), 0,
	                   startPosition(pieces, true, 3, 20)));
	// Without them: the rights the castling moves need are added.
	fx.game(moveRecord(compact({9, 10, kEnd}), 0,
	                   startPosition(pieces, false, 0, 1)));
	// The simple encoding castles by the king's two squares.
	fx.game(moveRecord(simple({word("e1", "g1"), 0x4000 | word("e8", "c8")}),
	                   5, startPosition(pieces, false, 0, 1)));
	// A castling that no right could allow still fails.
	fx.game(moveRecord(compact({9, kEnd}), 0,
	                   startPosition({{"d1", false, 1},
	                                  {"h1", false, 5},
	                                  {"e8", true, 1}},
	                                 false, 0, 1)));
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(3u, games.size()) << codec.parseErrors();
	char fen[256];
	ASSERT_TRUE(games[0].HasNonStandardStart(fen));
	EXPECT_STREQ("r3k3/8/8/8/8/8/8/R3K2R b KQ - 0 20", fen);
	EXPECT_EQ("20...Kd7 21.O-O 1-0", pgnOf(games[0]));
	EXPECT_EQ("1.O-O O-O-O 1-0", pgnOf(games[1]));
	EXPECT_EQ("1.O-O O-O-O 1-0", pgnOf(games[2]));
	EXPECT_NE(std::string::npos,
	          std::string(codec.parseErrors())
	              .find("(record 4) moves: castling without the right"));
}

TEST(Test_CBHMoves, chess960_games) {
	Fixture fx;
	// BQNNRKRB: king f1, rooks e1 and g1. 1.Ne3 Ne6 2.O-O (the king to g1,
	// the rook to f1). Knights are numbered c1, d1.
	std::vector<Placed> pieces;
	const unsigned back[8] = {4, 2, 3, 3, 5, 1, 5, 4};
	std::vector<std::string> names;
	names.reserve(32);
	for (int f = 0; f < 8; ++f)
		for (int r : {1, 2, 7, 8})
			names.push_back({char('a' + f), char('0' + r)});
	for (int f = 0; f < 8; ++f) {
		pieces.push_back({names[f * 4].c_str(), false, back[f]});
		pieces.push_back({names[f * 4 + 1].c_str(), false, 6});
		pieces.push_back({names[f * 4 + 2].c_str(), true, 6});
		pieces.push_back({names[f * 4 + 3].c_str(), true, 4});
		pieces.back().code = back[f];
	}
	fx.game(moveRecord(
	    compact({kTwoByte, word("d1", "e3"), kTwoByte, word("d8", "e6"),
	             kTwoByte, word("g1", "g1"), 9, kEnd},
	            10),
	    10, startPosition(pieces, false, 0x0f, 1)));
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(1u, games.size()) << codec.parseErrors();
	EXPECT_EQ("1.Ne3 Ne6 2.O-O O-O 1-0", pgnOf(games[0]));
}

TEST(Test_CBHMoves, damaged_moves_skip_the_game_only) {
	Fixture fx;
	struct Bad {
		Buf record;
		const char* why;
	};
	const std::vector<Bad> bad = {
	    {moveRecord(compact({128})), "move tree not terminated"},
	    {moveRecord(compact({kBranch, kBranch})),
	     "two variation starts in a row"},
	    {moveRecord(compact({kBranch, kEnd})),
	     "variation start before the end of a line"},
	    {moveRecord(compact({240, kEnd})), "code is not used"},
	    {moveRecord(compact({227, kEnd})), "no piece of that number"},
	    {moveRecord(compact({9, kEnd})), "illegal castling"},
	    {moveRecord(compact({1, kEnd})), "move onto an own piece"},
	    {moveRecord(compact({kTwoByte, word("e4", "e5"), kEnd})),
	     "no such piece on the origin square"},
	    {moveRecord(compact({kTwoByte, word("e2", "e2"), kEnd})),
	     "a move from a square to itself"},
	    {moveRecord(compact({kEnd}), 1), "move encoding mode not supported"},
	    {moveRecord(simple({word("e2", "e4")}), 5), "move tree not terminated"},
	    {Buf{0, 0, 0, 9, 1}, "move record runs past the end of the file"},
	};
	for (auto& b : bad)
		fx.game(b.record);
	fx.game(moveRecord(compact({128, kEnd})));
	fx.game(moveRecord({})); // a game without moves may have no bytes
	// The record that claims more bytes than it has must be the last one.
	std::swap(fx.b.games[bad.size() - 1], fx.b.games.back());
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(2u, games.size()) << codec.parseErrors();
	const std::string log = codec.parseErrors();
	for (size_t i = 0; i + 1 < bad.size(); ++i) {
		const auto line = "(record " + std::to_string(i + 1) +
		                  ") moves: " + bad[i].why + "\n";
		EXPECT_NE(std::string::npos, log.find(line)) << line << log;
	}
	EXPECT_NE(std::string::npos, log.find(bad.back().why)) << log;
	EXPECT_EQ(bad.size(), codec.counts().damaged);
}

TEST(Test_CBHAnnotations, positions_count_the_moves_in_stored_order) {
	Fixture fx;
	auto& g = fx.game(moveRecord(compact(kVariations)));
	// Stored order: 0 e4, 1 e5, 2 Nf3, 3 Nc6, 4 Bb5, 5 a6, 6 d6, 7 d4,
	// 8 exd4, 9 Bc4, 10 Nf6.
	g.annotations = {
	    text(-1, "About the game."),
	    text(0, "Italiano.", 70),
	    text(0, "English.", 42),
	    // A type that is not read, here a medal list, is skipped by its size.
	    annotation(0, 0x22, {0, 0, 0, 1}),
	    annotation(2, 0x03, {1}),
	    text(4, "four"),
	    text(6, "six"),
	    annotation(7, 0x04, {2, 29}),    // d5: file 3, rank 4
	    annotation(9, 0x05, {4, 17, 25}), // c1 to d1
	    text(10, "before ten", 0, true),
	};
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(1u, games.size()) << codec.parseErrors();
	EXPECT_EQ(0u, codec.counts().incomplete) << codec.parseErrors();
	EXPECT_EQ("{About the game.} 1.e4 {English.} 1...e5 2.Nf3 $1 Nc6 "
	          "( 2...d6 {six} 3.d4 {[%csl Gd5]} ( 3.Bc4 {[%cal Rc1d1]} ) "
	          "3...exd4 ) ( {before ten} 2...Nf6 ) 3.Bb5 {four} 3...a6 1-0",
	          pgnOf(games[0]));

	CodecCB2 italian;
	italian.setLanguages({cb2::language::Italian});
	auto it = readAll(fx.write(), italian);
	ASSERT_EQ(1u, it.size());
	EXPECT_NE(std::string::npos, pgnOf(it[0]).find("1.e4 {Italiano.}"));
}

TEST(Test_CBHAnnotations, damage_keeps_what_was_read) {
	Fixture fx;
	auto& g = fx.game(moveRecord(compact({128, kEnd})));
	g.annotations = {text(0, "kept"), annotation(0, 0x04, {2, 65})};
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(1u, games.size());
	EXPECT_EQ("1.e4 {kept} 1-0", pgnOf(games[0]));
	EXPECT_EQ(1u, codec.counts().incomplete);
	EXPECT_NE(std::string::npos,
	          std::string(codec.parseErrors()).find("square out of range"));
}

TEST(Test_CBHCodec, mutated_records_never_crash) {
	Fixture fx;
	auto& g = fx.game(moveRecord(compact(kVariations)));
	g.annotations = {text(0, "a"), annotation(2, 0x03, {1}),
	                 annotation(3, 0x05, {4, 17, 25})};
	fx.game(moveRecord(compact({10, kEnd}), 0,
	                   startPosition({{"e1", false, 1},
	                                  {"a1", false, 5},
	                                  {"e8", true, 1}},
	                                 false, 0, 1)));
	const auto name = fx.write();
	const auto stem = name.substr(0, name.size() - 4);
	for (const char* ext : {".cbh", ".cbg", ".cba", ".cbp", ".cbt", ".cbc"}) {
		fx.b.write(stem);
		std::ifstream in(stem + ext, std::ios::binary);
		const Buf good((std::istreambuf_iterator<char>(in)), {});
		in.close();
		for (size_t i = 0; i < good.size(); ++i) {
			for (uint8_t x : {0x01, 0x40, 0x80, 0xff}) {
				auto bad = good;
				bad[i] ^= x;
				writeFile(stem + ext, bad);
				CodecCB2 codec;
				if (codec.open(name.c_str(), FMODE_ReadOnly) != OK)
					continue;
				Game game;
				for (int n = 0; n < 100; ++n)
					if (codec.parseNext(game) == ERROR_NotFound)
						break;
			}
		}
	}
}
