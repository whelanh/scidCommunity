/*
 * Copyright (C) 2026 Tommaso Bergamasco
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * This file is part of scidCommunity.
 */

#include "cb2_fixture.h"
#include "cb2_format.h"
#include "cb2_moves.h"
#include "codec_cb2.h"
#include "date.h"
#include "game.h"
#include "misc.h"
#include "scidbase.h"
#include <deque>
#include <set>
#include <tuple>
#include <filesystem>
#include <gtest/gtest.h>

using namespace cb2test;

namespace {

RecordBytes gameRecord(int64_t movesOffset, int16_t whiteElo) {
	RecordBytes r{};
	r[2] = 1;
	Buf b(r.begin(), r.end());
	putLE(b, 0x08, movesOffset, 8);
	putLE(b, 0x60, static_cast<uint16_t>(whiteElo), 2);
	std::copy(b.begin(), b.begin() + r.size(), r.begin());
	return r;
}

} // namespace

TEST(Test_CB2Header, records_of_192_and_208_bytes_read_the_same) {
	TempDir dir;
	std::vector<RecordBytes> recs = {gameRecord(12, 2500),
	                                 gameRecord(80, 1800)};
	for (auto [rs, version] : {std::pair{192, 5u}, std::pair{208, 6u}}) {
		auto name = dir.file("db" + std::to_string(rs) + ".2cbh");
		writeFile(name, headerFile(rs, version, recs));
		cb2::HeaderTable t;
		std::string why;
		ASSERT_EQ(OK, t.open(name, why)) << why;
		EXPECT_EQ(2u, t.count());
		EXPECT_EQ(size_t(rs), t.recordSize());
		EXPECT_EQ(version, t.version());
		auto r2 = t.record(2);
		ASSERT_TRUE(r2.valid());
		EXPECT_EQ(size_t(rs), r2.bytes().size());
		EXPECT_EQ(80, r2.movesOffset());
		EXPECT_EQ(1800, r2.whiteElo());
		EXPECT_EQ(cb2::RecordKind::Game, r2.kind());
		EXPECT_EQ(2500, t.record(1).whiteElo());
	}
}

TEST(Test_CB2Header, records_out_of_range_are_invalid) {
	TempDir dir;
	auto name = dir.file("db.2cbh");
	writeFile(name, headerFile(192, 5, {gameRecord(12, 0)}));
	cb2::HeaderTable t;
	std::string why;
	ASSERT_EQ(OK, t.open(name, why));
	EXPECT_FALSE(t.record(0).valid());
	EXPECT_TRUE(t.record(1).valid());
	EXPECT_FALSE(t.record(2).valid());
}

TEST(Test_CB2Header, header_only_has_no_records) {
	TempDir dir;
	auto name = dir.file("db.2cbh");
	writeFile(name, headerFile(208, 6, {}));
	cb2::HeaderTable t;
	std::string why;
	ASSERT_EQ(OK, t.open(name, why));
	EXPECT_EQ(0u, t.count());
}

TEST(Test_CB2Header, unsupported_record_sizes_are_refused) {
	TempDir dir;
	for (int rs : {0, 1, 191, 4097, -192, 32767}) {
		auto name = dir.file("bad.2cbh");
		Buf b(256, 0);
		putLE(b, 0x0a, static_cast<uint16_t>(rs), 2);
		writeFile(name, b);
		cb2::HeaderTable t;
		std::string why;
		EXPECT_EQ(ERROR_FileVersion, t.open(name, why)) << rs;
		EXPECT_FALSE(why.empty());
		EXPECT_EQ(0u, t.count());
	}
	for (int rs : {192, 4096}) {
		auto name = dir.file("good.2cbh");
		Buf b(size_t(rs) * 2, 0);
		putLE(b, 0x0a, static_cast<uint16_t>(rs), 2);
		writeFile(name, b);
		cb2::HeaderTable t;
		std::string why;
		EXPECT_EQ(OK, t.open(name, why)) << rs;
		EXPECT_EQ(1u, t.count());
	}
}

TEST(Test_CB2Header, size_not_a_multiple_of_the_record_size_is_refused) {
	TempDir dir;
	auto name = dir.file("db.2cbh");
	auto b = headerFile(208, 6, {gameRecord(12, 0)});
	b.push_back(0);
	writeFile(name, b);
	cb2::HeaderTable t;
	std::string why;
	EXPECT_EQ(ERROR_Corrupt, t.open(name, why));

	Buf tiny(10, 0);
	writeFile(name, tiny);
	EXPECT_NE(OK, t.open(name, why));
	EXPECT_EQ(0u, t.count());

	EXPECT_EQ(ERROR_FileOpen, t.open(dir.file("missing.2cbh"), why));
}

TEST(Test_CB2Frame, checksum_and_damage_are_checked) {
	EXPECT_EQ(0x030201u, cb2::frameChecksum(Buf{1, 2, 3}));
	Buf c17;
	for (uint8_t i = 0; i < 17; ++i)
		c17.push_back(i);
	EXPECT_EQ(checksum(c17), cb2::frameChecksum(c17));

	TempDir dir;
	auto name = dir.file("f.2cbg");
	Buf content = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
	Buf file(12, 0);
	addBytes(file, frame(7, content, 3));
	writeFile(name, file);
	cb2::File f;
	ASSERT_EQ(OK, f.open(name));
	cb2::Frame fr;
	ASSERT_EQ(nullptr, cb2::readFrame(f, 12, fr));
	EXPECT_EQ(7, fr.tag);
	EXPECT_EQ(content, Buf(fr.content.begin(), fr.content.end()));
	EXPECT_NE(nullptr, cb2::readFrame(f, 11, fr));
	EXPECT_NE(nullptr, cb2::readFrame(f, -1, fr));
	EXPECT_NE(nullptr, cb2::readFrame(f, int64_t(file.size()), fr));
	EXPECT_TRUE(fr.content.empty());

	for (size_t i = 12; i < file.size(); ++i) {
		auto bad = file;
		bad[i] ^= 0x40;
		f.close(); // Windows does not rewrite a mapped file
		writeFile(name, bad);
		ASSERT_EQ(OK, f.open(name));
		auto err = cb2::readFrame(f, 12, fr);
		// The format checks neither the tag, nor the content bytes past the
		// checksum's eight runs (here 8 runs of 1 byte, 3 left over), nor the
		// spare area: only those may change without the frame failing.
		const size_t content0 = 12 + 0x1a;
		const bool unchecked =
		    i == 12 + 0x18 || i == 12 + 0x19 ||
		    (i >= content0 + 8 && i < content0 + content.size() + 3);
		EXPECT_EQ(unchecked, err == nullptr) << i;
		if (!unchecked) {
			EXPECT_TRUE(fr.content.empty());
		}
	}
}

TEST(Test_CB2Text, utf8_is_kept_and_windows_1252_converted) {
	auto text = [](std::string_view s) {
		auto p = reinterpret_cast<const unsigned char*>(s.data());
		return cb2::decodeText({p, s.size()});
	};
	EXPECT_EQ("Caruana", text("Caruana"));
	EXPECT_EQ("Ni\xc5\xa1"
	          "ev",
	          text("Ni\xc5\xa1"
	               "ev"));                 // UTF-8 kept
	EXPECT_EQ("\xc3\x85ngstr\xc3\xb6m", text("\xc5ngstr\xf6m")); // Latin-1
	EXPECT_EQ("\xe2\x82\xac", text("\x80"));         // euro sign
	EXPECT_EQ("\xc2\x81", text("\x81"));             // undefined: kept as C1
	EXPECT_EQ("\xc3\xa0\xc3\xa0", text("\xe0\xe0")); // invalid UTF-8
	EXPECT_EQ("\xc3\x83\xc2\xa9", text("\xc3\xa9\xff").substr(0, 4));
	EXPECT_EQ("", text(""));
}

namespace {

/// A database with two players, a tournament and the given games.
struct Fixture {
	TempDir dir;
	Builder b;
	int64_t carlsen, anand, event;
	Fixture() {
		carlsen = b.player("Carlsen", "Magnus");
		anand = b.player("Anand", "Viswanathan");
		event = b.tournament("World Championship", "Chennai",
		                     (2013 << 9) | (11 << 5) | 9);
	}
	std::string write(int recordSize = 192, unsigned version = 5) {
		auto stem = dir.file("db" + std::to_string(recordSize));
		b.write(stem, recordSize, version);
		return stem + ".2cbh";
	}
	GameSpec& game() {
		b.games.emplace_back();
		auto& g = b.games.back();
		g.white = anand;
		g.black = carlsen;
		g.tournament = event;
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

} // namespace

TEST(Test_CB2Entities, players_and_tournaments) {
	Fixture fx;
	fx.b.player("Polgar");
	auto name = fx.write();
	cb2::Database db;
	std::string why;
	ASSERT_EQ(OK, db.open(name, why)) << why;
	std::string p;
	EXPECT_TRUE(db.entities.player(0, p));
	EXPECT_EQ("Carlsen, Magnus", p);
	EXPECT_TRUE(db.entities.player(2, p));
	EXPECT_EQ("Polgar", p);
	EXPECT_FALSE(db.entities.player(3, p));
	EXPECT_FALSE(db.entities.player(-1, p));
	EXPECT_FALSE(db.entities.player(int64_t(1) << 62, p));
	cb2::Tournament t;
	EXPECT_TRUE(db.entities.tournament(0, t));
	EXPECT_EQ("World Championship", t.title);
	EXPECT_EQ("Chennai", t.place);
	EXPECT_EQ((2013 << 9) | (11 << 5) | 9, t.start);
	EXPECT_FALSE(db.entities.tournament(1, t));
}

TEST(Test_CB2Codec, game_tags) {
	Fixture fx;
	auto& g = fx.game();
	g.result = 1;
	g.round = 6;
	g.subround = 2;
	g.whiteElo = 2775;
	g.blackElo = 2870;
	g.eco = (88 + 1) * 128 + 3; // A88
	g.date = (2013 << 9) | (11 << 5) | 16;
	g.annotator = fx.carlsen;
	auto& g2 = fx.game();
	g2.white = 99; // missing entities
	g2.black = -1;
	g2.tournament = 7;
	g2.result = 6;          // white won by forfeit
	g2.whiteElo = 4200;     // out of Scid's range
	g2.date = (2013 << 9); // year only
	g2.round = -1;

	for (auto [rs, version] : {std::pair{192, 5u}, std::pair{208, 6u}}) {
		CodecCB2 codec;
		auto games = readAll(fx.write(rs, version), codec);
		ASSERT_EQ(2u, games.size());
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
		ASSERT_NE(nullptr, a.FindExtraTag("Annotator"));
		EXPECT_STREQ("Carlsen, Magnus", a.FindExtraTag("Annotator"));

		auto& b = games[1];
		EXPECT_STREQ("?", b.GetWhiteStr());
		EXPECT_STREQ("?", b.GetBlackStr());
		EXPECT_STREQ("?", b.GetEventStr());
		EXPECT_STREQ("?", b.GetSiteStr());
		EXPECT_STREQ("?", b.GetRoundStr());
		EXPECT_EQ(RESULT_White, b.GetResult());
		EXPECT_EQ(0, b.GetWhiteElo());
		EXPECT_EQ(ECO_None, b.GetEco());
		EXPECT_EQ(DATE_MAKE(2013, 0, 0), b.GetDate());
		EXPECT_EQ(nullptr, b.FindExtraTag("Annotator"));
	}
}

TEST(Test_CB2Codec, texts_analyses_and_deleted_records_are_skipped) {
	Fixture fx;
	fx.game().byte0 = 0x80;           // deleted
	fx.game().byte0 = 0x02;           // guiding text
	fx.game().kind = 2;               // analysis
	fx.game().kind = 9;               // unknown kind
	fx.game().round = 3;              // the one game
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(1u, games.size());
	EXPECT_STREQ("3", games[0].GetRoundStr());
	EXPECT_EQ(5u, codec.parseProgress().first);
	EXPECT_EQ(5u, codec.parseProgress().second);
	auto& c = codec.counts();
	EXPECT_EQ(1u, c.games);
	EXPECT_EQ(1u, c.deleted);
	EXPECT_EQ(1u, c.texts);
	EXPECT_EQ(1u, c.analyses);
	EXPECT_EQ(1u, c.unknown);
	std::string log = codec.parseErrors();
	EXPECT_NE(std::string::npos, log.find("5 records, 1 games read"));
	EXPECT_NE(std::string::npos, log.find("Skipped 1 guiding text"));
}

TEST(Test_CB2Codec, open_needs_all_files) {
	Fixture fx;
	fx.game();
	auto name = fx.write();
	auto stem = name.substr(0, name.size() - 5);
	{
		CodecCB2 codec;
		EXPECT_EQ(ERROR_FileMode, codec.open(name.c_str(), FMODE_Both));
		EXPECT_EQ(OK, codec.open(name.c_str(), FMODE_ReadOnly));
		EXPECT_EQ(OK, codec.open(stem.c_str(), FMODE_ReadOnly));
	}
	std::filesystem::remove(stem + ".2cba"); // optional
	{
		CodecCB2 codec;
		EXPECT_EQ(OK, codec.open(name.c_str(), FMODE_ReadOnly));
	}
	std::filesystem::remove(stem + ".2lid");
	{
		CodecCB2 codec;
		EXPECT_NE(OK, codec.open(name.c_str(), FMODE_ReadOnly));
		std::string log = codec.parseErrors();
		EXPECT_NE(std::string::npos, log.find(".2lid"));
	}
}

// ---------------------------------------------------------------------------
// Moves

namespace {

/// The square named @p s ("e4") counted a1 = 0, b1 = 1 ... h8 = 63.
uint8_t sqOf(const char* s) { return uint8_t((s[1] - '1') * 8 + (s[0] - 'a')); }

using P = cb2::Piece;
using C = cb2::Captured;

/// The move word for a move of side @p black, found by searching the
/// reader's own table; the anchors in Test_CB2Moves.table_matches_the_format
/// pin the table. From and to alone may fit several pieces: unless @p piece
/// names one, a pawn is preferred, then a knight, a bishop, a rook, a king
/// and a queen.
uint16_t mv(bool black, const char* from, const char* to,
            C captured = C::Nothing, int promo = -1, int piece = -1) {
	const P order[] = {P::Pawn, P::Knight, P::Bishop,
	                   P::Rook, P::King,   P::Queen};
	for (auto p : order) {
		if (piece >= 0 && int(p) != piece)
			continue;
		for (unsigned w = 1; w < 0xc02d; ++w) {
			auto m = cb2::decodeMove(uint16_t(w));
			if (m.kind == cb2::MoveWord::Normal && m.piece == p &&
			    m.black == black && m.from == sqOf(from) &&
			    m.to == sqOf(to) && m.captured == captured &&
			    m.promotes == (promo >= 0) &&
			    (promo < 0 || int(m.promotion) == promo))
				return uint16_t(w);
		}
	}
	ADD_FAILURE() << "no word for " << from << to;
	return 0;
}
uint16_t W(const char* f, const char* t, C c = C::Nothing, int promo = -1) {
	return mv(false, f, t, c, promo);
}
uint16_t B(const char* f, const char* t, C c = C::Nothing, int promo = -1) {
	return mv(true, f, t, c, promo);
}
/// A move of a named piece.
uint16_t Wx(P p, const char* f, const char* t, C c = C::Nothing) {
	return mv(false, f, t, c, -1, int(p));
}
uint16_t Bx(P p, const char* f, const char* t, C c = C::Nothing) {
	return mv(true, f, t, c, -1, int(p));
}
constexpr uint16_t ALT = 0xfffd, END = 0xffff, NUL = 0xfffa;
constexpr uint16_t W_OOO = 0xb129, W_OO = 0xb12a, B_OOO = 0xb12b;

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

} // namespace

TEST(Test_CB2Moves, table_matches_the_format) {
	auto first = [](P p, bool black) {
		for (unsigned w = 1; w < 0xc02d; ++w) {
			auto m = cb2::decodeMove(uint16_t(w));
			if (m.kind == cb2::MoveWord::Normal && m.piece == p &&
			    m.black == black)
				return w;
		}
		return 0u;
	};
	// Block boundaries as the format has them.
	EXPECT_EQ(0x0001u, first(P::King, false));
	EXPECT_EQ(0x09d9u, first(P::Queen, false));
	EXPECT_EQ(0x2bf9u, first(P::Knight, false));
	EXPECT_EQ(0x33d9u, first(P::Bishop, false));
	EXPECT_EQ(0x40f9u, first(P::Rook, false));
	EXPECT_EQ(0x55f9u, first(P::King, true));
	EXPECT_EQ(0x5fd1u, first(P::Queen, true));
	EXPECT_EQ(0x81f1u, first(P::Knight, true));
	EXPECT_EQ(0x89d1u, first(P::Bishop, true));
	EXPECT_EQ(0x96f1u, first(P::Rook, true));
	EXPECT_EQ(0xabf1u, first(P::Pawn, false));
	EXPECT_EQ(0xae8du, first(P::Pawn, true));
	// a1-a2 is word 1, a1-b1 word 7: six words per destination.
	auto m1 = cb2::decodeMove(1);
	EXPECT_EQ(cb2::MoveWord::Normal, m1.kind);
	EXPECT_EQ(sqOf("a1"), m1.from);
	EXPECT_EQ(sqOf("a2"), m1.to);
	EXPECT_EQ(C::Nothing, m1.captured);
	EXPECT_EQ(C::Queen, cb2::decodeMove(2).captured);
	EXPECT_EQ(sqOf("b1"), cb2::decodeMove(7).to);
	// Castling words, and the four per Chess960 start position.
	auto c = cb2::decodeMove(0xb12a);
	EXPECT_EQ(cb2::MoveWord::Castle, c.kind);
	EXPECT_FALSE(c.black);
	EXPECT_TRUE(c.kingside);
	c = cb2::decodeMove(0xb12d + 4 * 7 + 3);
	EXPECT_EQ(cb2::MoveWord::Castle, c.kind);
	EXPECT_TRUE(c.black);
	EXPECT_TRUE(c.kingside);
	EXPECT_EQ(cb2::MoveWord::Null, cb2::decodeMove(0xfffa).kind);
	for (uint16_t w : {0, 0xc02d, 0xfffb, 0xfffc, 0xfffd, 0xffff})
		EXPECT_EQ(cb2::MoveWord::Invalid, cb2::decodeMove(w).kind) << w;
	// Every normal word names a different move.
	std::set<std::tuple<int, int, int, int, int, int, int>> seen;
	for (unsigned w = 1; w < 0xb129; ++w) {
		auto m = cb2::decodeMove(uint16_t(w));
		ASSERT_EQ(cb2::MoveWord::Normal, m.kind) << w;
		EXPECT_TRUE(seen.insert({m.black, int(m.piece), m.from, m.to,
		                         int(m.captured), m.promotes,
		                         int(m.promotion)})
		                .second)
		    << w;
	}
	// Promotion captures: the captured piece first, then the promotion
	// (queen, knight, bishop, rook in both).
	const auto q = W("a7", "b8", C::Queen, int(P::Queen));
	EXPECT_EQ(q + 1, W("a7", "b8", C::Queen, int(P::Knight)));
	EXPECT_EQ(q + 4, W("a7", "b8", C::Knight, int(P::Queen)));
}

TEST(Test_CB2Moves, setup_piece_words) {
	cb2::SetupPiece p;
	ASSERT_TRUE(cb2::decodePieceWord(0xc02d, p));
	EXPECT_EQ(sqOf("a1"), p.square);
	EXPECT_FALSE(p.black);
	EXPECT_EQ(P::King, p.piece);
	ASSERT_TRUE(cb2::decodePieceWord(0xc16d, p));
	EXPECT_TRUE(p.black);
	EXPECT_EQ(P::King, p.piece);
	ASSERT_TRUE(cb2::decodePieceWord(0xc2ad, p));
	EXPECT_EQ(sqOf("a2"), p.square);
	EXPECT_EQ(P::Pawn, p.piece);
	ASSERT_TRUE(cb2::decodePieceWord(0xc2dd, p));
	EXPECT_TRUE(p.black);
	EXPECT_EQ(sqOf("a2"), p.square);
	ASSERT_TRUE(cb2::decodePieceWord(0xc02d + 4 * 64 + 6 * 8, p));
	EXPECT_EQ(P::Rook, p.piece);
	EXPECT_EQ(sqOf("g1"), p.square);
	ASSERT_TRUE(cb2::decodePieceWord(0xc30c, p));
	EXPECT_EQ(sqOf("h7"), p.square);
	EXPECT_FALSE(cb2::decodePieceWord(0xc02c, p));
	EXPECT_FALSE(cb2::decodePieceWord(0xc30d, p));
}

TEST(Test_CB2Moves, chess960_start_positions) {
	cb2::Start s;
	s.kind = cb2::Start::Chess960;
	s.chess960 = 518;
	EXPECT_EQ("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w HAha - 0 1",
	          cb2::startFen(s));
	s.chess960 = 0;
	EXPECT_EQ("bbqnnrkr/pppppppp/8/8/8/8/PPPPPPPP/BBQNNRKR w HFhf - 0 1",
	          cb2::startFen(s));
	s.chess960 = 959;
	EXPECT_EQ("rkrnnqbb/pppppppp/8/8/8/8/PPPPPPPP/RKRNNQBB w CAca - 0 1",
	          cb2::startFen(s));
	s.kind = cb2::Start::Standard;
	EXPECT_EQ("", cb2::startFen(s));
}

TEST(Test_CB2Moves, main_line_and_variations) {
	Fixture fx;
	// 1.e4 e5 2.Nf3 Nc6 (2...d6 3.d4 (3.Bc4) 3...exd4) (2...Nf6) 3.Bb5 a6
	fx.game().moves = moveContent(
	    {W("e2", "e4"), B("e7", "e5"), W("g1", "f3"), B("b8", "c6"), ALT,
	     W("f1", "b5"), B("a7", "a6"), END,
	     B("d7", "d6"), ALT, W("d2", "d4"), ALT,
	     B("e5", "d4", C::Pawn), END,
	     W("f1", "c4"), END,
	     B("g8", "f6"), END});
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(1u, games.size()) << codec.parseErrors();
	EXPECT_EQ("1.e4 e5 2.Nf3 Nc6 ( 2...d6 3.d4 ( 3.Bc4 ) 3...exd4 ) "
	          "( 2...Nf6 ) 3.Bb5 a6 1-0",
	          pgnOf(games[0]));
}

TEST(Test_CB2Moves, marker_0xfffe_is_skipped) {
	Fixture fx;
	constexpr uint16_t SKIP = 0xfffe;
	// 1.e4 e5 (1...c5) 2.Nf3, with the marker in the line, between a move
	// and its alternative marker, and before an end of line.
	auto& g = fx.game();
	g.moves = moveContent({W("e2", "e4"), SKIP, B("e7", "e5"), SKIP, ALT,
	                       W("g1", "f3"), SKIP, END, B("c7", "c5"), END});
	// Comments by position in PGN order: the marker takes none.
	g.annotations = annRecord(
	    {annBlock(2, {annText("c5.")}), annBlock(3, {annText("Last.")})});
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(1u, games.size()) << codec.parseErrors();
	EXPECT_EQ("1.e4 e5 ( 1...c5 {c5.} ) 2.Nf3 {Last.} 1-0", pgnOf(games[0]));
}

TEST(Test_CB2Moves, castling_en_passant_promotion_and_null_moves) {
	Fixture fx;
	// 1.e4 d5 2.e5 f5 3.exf6 -- 4.fxg7 Nc6 5.gxh8=N Bh3 6.Nf3 Qd7
	// 7.Be2 O-O-O 8.O-O
	fx.game().moves = moveContent(
	    {W("e2", "e4"), B("d7", "d5"), W("e4", "e5"), B("f7", "f5"),
	     W("e5", "f6", C::EnPassant), NUL, W("f6", "g7", C::Pawn),
	     B("b8", "c6"), W("g7", "h8", C::Rook, int(P::Knight)),
	     B("c8", "h3"), W("g1", "f3"), Bx(P::Queen, "d8", "d7"),
	     W("f1", "e2"), B_OOO, W_OO, END});
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(1u, games.size()) << codec.parseErrors();
	EXPECT_EQ("1.e4 d5 2.e5 f5 3.exf6 -- 4.fxg7 Nc6 5.gxh8=N Bh3 6.Nf3 Qd7 "
	          "7.Be2 O-O-O 8.O-O 1-0",
	          pgnOf(games[0]));
}

TEST(Test_CB2Moves, damaged_moves_skip_the_game_only) {
	Fixture fx;
	const auto e4 = W("e2", "e4"), e5 = B("e7", "e5");
	struct Bad {
		std::vector<uint16_t> words;
		const char* why;
	};
	const std::vector<Bad> bad = {
	    {{e4, W("d2", "d4"), END}, "move out of turn"},
	    {{W("e2", "e3"), B("d7", "d6"), W("e3", "e5"), END},
	     "no such piece on the origin square"},
	    {{W("g1", "f3"), e5, W("f3", "e5"), END},
	     "capture not named by the move word"},
	    {{e4, B("d7", "d5"), W("e4", "d5", C::Queen), END},
	     "captured piece not the one named"},
	    {{e4, B("a7", "a6"), W("e4", "e5"), B("f7", "f6"),
	      W("e5", "f6", C::EnPassant), END},
	     "en passant not available"},
	    {{W("g1", "f3"), B("b8", "c6"), W("f3", "e1"), END},
	     "move onto an own piece"},
	    {{W("f2", "f3"), e5, W("g2", "g4"), Bx(P::Queen, "d8", "h4"),
	      W("a2", "a3"), END},
	     "illegal move"},
	    {{W_OO, END}, "illegal castling"},
	    {{e4, e5, Wx(P::King, "e1", "e2"), B("b8", "c6"), W_OO, END},
	     "castling without the right"},
	    {{e4, e5, Wx(P::Queen, "d1", "h5"), B("b8", "c6"),
	      Wx(P::Queen, "h5", "f7", C::Pawn), NUL, END},
	     "null move in check"},
	    {{e4, ALT, ALT, END, END}, "alternative marker not after a move"},
	    {{ALT, e4, END}, "alternative marker not after a move"},
	    {{e4, e5}, "move tree not terminated"},
	    {{e4, END, e5}, "words after the final end of line"},
	    {{e4, 0xc02d, END}, "not a move word"},
	};
	for (auto& b : bad)
		fx.game().moves = moveContent(b.words);
	fx.game().moves = moveContent({e4, e5, END});
	fx.game().rawMoves = Buf{1, 2, 3}; // no frame at all
	fx.game().moves = Buf{0x01};        // odd length
	fx.game().moves = Buf{};            // empty
	fx.game().moves = moveContent({e4, END}, {1, 0, 0}); // set-up, no kings
	fx.game().round = 9;                // the last one is good
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(2u, games.size()) << codec.parseErrors();
	EXPECT_EQ("1.e4 e5 1-0", pgnOf(games[0]));
	EXPECT_STREQ("9", games[1].GetRoundStr());
	EXPECT_EQ("1-0", pgnOf(games[1]));
	EXPECT_EQ(bad.size() + 4, codec.counts().damaged);
	std::string log = codec.parseErrors();
	for (size_t i = 0; i < bad.size(); ++i) {
		auto line = "(record " + std::to_string(i + 1) + ") moves: " +
		            bad[i].why + "\n";
		EXPECT_NE(std::string::npos, log.find(line)) << line << log;
	}
	EXPECT_NE(std::string::npos, log.find("bad magic"));
	EXPECT_NE(std::string::npos, log.find("start position not valid"));
}

TEST(Test_CB2Moves, chess960_games) {
	Fixture fx;
	// Start 3: BQNNRKRB, king f1 and rooks e1 and g1. 1.Ne3 Ne6 2.O-O
	// (the king to g1, the rook to f1) O-O.
	auto& g = fx.game();
	g.movesTag = 2;
	g.moves = moveContent({Wx(P::Knight, "d1", "e3"),
	                       Bx(P::Knight, "d8", "e6"),
	                       uint16_t(0xb12d + 4 * 3 + 1),
	                       uint16_t(0xb12d + 4 * 3 + 3), END},
	                      {3});
	auto& std960 = fx.game(); // a Chess960 game from the standard position
	std960.movesTag = 2;
	std960.moves = moveContent({W("e2", "e4"), END});
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(2u, games.size()) << codec.parseErrors();
	char fen[256];
	ASSERT_TRUE(games[0].HasNonStandardStart(fen));
	// Scid writes Chess960 castling rights as KQkq (X-FEN).
	EXPECT_STREQ("bqnnrkrb/pppppppp/8/8/8/8/PPPPPPPP/BQNNRKRB w KQkq - 0 1",
	             fen);
	EXPECT_EQ("1.Ne3 Ne6 2.O-O O-O 1-0", pgnOf(games[0]));
	EXPECT_FALSE(games[1].HasNonStandardStart());
	EXPECT_EQ("1.e4 1-0", pgnOf(games[1]));
}

TEST(Test_CB2Moves, setup_positions) {
	Fixture fx;
	// White Ke1 Ra1 Rh1 Pe5, black Ke8 Pd5 (just played d7-d5); the
	// castling rights white O-O-O, white O-O and black O-O (which the pieces
	// do not allow); white to move, move 30, en passant on the d-file.
	const std::vector<uint16_t> start = {
	    30, uint16_t(0 | (1 | 2 | 8) << 8), 4,
	    uint16_t(0xc02d + 0 * 64 + 4 * 8 + 0), // white king e1
	    uint16_t(0xc02d + 4 * 64 + 0 * 8 + 0), // white rook a1
	    uint16_t(0xc02d + 4 * 64 + 7 * 8 + 0), // white rook h1
	    uint16_t(0xc2ad + 4 * 6 + 3),          // white pawn e5
	    uint16_t(0xc16d + 0 * 64 + 4 * 8 + 7), // black king e8
	    uint16_t(0xc2dd + 3 * 6 + 3)};         // black pawn d5
	fx.game().moves = moveContent(
	    {W("e5", "d6", C::EnPassant), Bx(P::King, "e8", "d7"), W_OOO, END},
	    start);
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(1u, games.size()) << codec.parseErrors();
	char fen[256];
	ASSERT_TRUE(games[0].HasNonStandardStart(fen));
	EXPECT_STREQ("4k3/8/8/3pP3/8/8/8/R3K2R w KQ d6 0 30", fen);
	EXPECT_EQ("30.exd6 Kd7 31.O-O-O 1-0", pgnOf(games[0]));
}

TEST(Test_CB2Moves, records_of_192_and_208_bytes_give_the_same_games) {
	Fixture fx;
	fx.game().moves = moveContent(
	    {W("d2", "d4"), B("g8", "f6"), ALT, W("c2", "c4"), END,
	     B("d7", "d5"), END});
	fx.game().moves = moveContent({W("e2", "e4"), END});
	CodecCB2 a, b;
	auto g192 = readAll(fx.write(192, 5), a);
	auto g208 = readAll(fx.write(208, 6), b);
	ASSERT_EQ(2u, g192.size()) << a.parseErrors();
	ASSERT_EQ(g192.size(), g208.size());
	for (size_t i = 0; i < g192.size(); ++i)
		EXPECT_EQ(pgnOf(g192[i]), pgnOf(g208[i]));
	EXPECT_EQ("1.d4 Nf6 ( 1...d5 ) 2.c4 1-0", pgnOf(g192[0]));
}

TEST(Test_CB2Moves, mutated_move_records_never_crash) {
	Fixture fx;
	fx.game().moves = moveContent(
	    {W("e2", "e4"), B("e7", "e5"), ALT, W("g1", "f3"), NUL, W("f1", "c4"),
	     NUL, W_OO, END, B("c7", "c5"), END});
	auto name = fx.write();
	auto stem = name.substr(0, name.size() - 5);
	std::ifstream in(stem + ".2cbg", std::ios::binary);
	Buf cbg((std::istreambuf_iterator<char>(in)), {});
	in.close();
	{
		CodecCB2 codec;
		ASSERT_EQ(1u, readAll(name, codec).size()) << codec.parseErrors();
	}
	for (size_t i = 12; i < cbg.size(); ++i) {
		for (uint8_t x : {0x01, 0x80, 0xff}) {
			auto bad = cbg;
			bad[i] ^= x;
			// Keep the checksum right, so that the mutation reaches the
			// move decoder instead of failing the frame check.
			const auto size = le32(bad, 12 + 8);
			if (size <= bad.size() - 12 - 0x1a) {
				Buf content(bad.begin() + 12 + 0x1a,
				            bad.begin() + 12 + 0x1a + size);
				putBE(bad, 12 + 0x10, checksum(content), 8);
			}
			writeFile(stem + ".2cbg", bad);
			CodecCB2 codec;
			auto games = readAll(name, codec);
			EXPECT_LE(games.size(), 1u);
		}
	}
}

// ---------------------------------------------------------------------------
// Annotations

namespace {

/// 1.e4 e5 2.Nf3 (2.f4 exf4) 2...Nc6: positions in PGN order are
/// 0 e4, 1 e5, 2 Nf3, 3 f4, 4 exf4, 5 Nc6.
std::vector<uint16_t> annotatedMoves() {
	return {W("e2", "e4"), B("e7", "e5"), W("g1", "f3"), ALT,
	        B("b8", "c6"), END, W("f2", "f4"), B("e5", "f4", C::Pawn), END};
}

} // namespace

TEST(Test_CB2Annotations, texts_nags_and_graphics) {
	Fixture fx;
	auto& g = fx.game();
	g.moves = moveContent(annotatedMoves());
	g.annotations = annRecord({
	    annBlock(-1, {annText("A {model} game."), annText("Ein Spiel.", 1)}),
	    annBlock(0, {annSymbols(1, 0, 0), annText("Best by test.")}),
	    annBlock(2, {annText("The main move.", 0, true),
	                 annMarks(0x04, {2, cbSq("e5"), 4, cbSq("d4"), 9, 1}),
	                 annMarks(0x05, {3, cbSq("f3"), cbSq("e5")})}),
	    annBlock(3, {annText("Sharp.", 7, true), annSymbols(5, 13, 0),
	                 annText("Gambit!", 0)}),
	    annBlock(5, {annText("\tDefending\r\n  e5.  ", 0)}),
	});
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(1u, games.size()) << codec.parseErrors();
	EXPECT_EQ(0u, codec.counts().incomplete) << codec.parseErrors();
	EXPECT_EQ("{A (model) game.} 1.e4 $1 {Best by test.} 1...e5 "
	          "{The main move.} 2.Nf3 {[%csl Ge5,Rd4][%cal Yf3e5]} "
	          "( {Sharp.} 2.f4 $5 $13 {Gambit!} 2...exf4 ) 2...Nc6 "
	          "{Defending e5.} 1-0",
	          pgnOf(games[0]));
}

TEST(Test_CB2Annotations, one_language_is_chosen) {
	Fixture fx;
	auto add = [&](std::vector<Buf> texts) {
		auto& g = fx.game();
		g.moves = moveContent({W("e2", "e4"), END});
		g.annotations = annRecord({annBlock(0, texts)});
	};
	add({annText("Gut.", 1), annText("Good.", 0), annText("Bene.", 4),
	     annText("!!", 7)});
	add({annText("Gut.", 1), annText("Bien.", 2)});
	{
		CodecCB2 codec;
		auto games = readAll(fx.write(), codec);
		ASSERT_EQ(2u, games.size());
		EXPECT_EQ("1.e4 {Good. !!} 1-0", pgnOf(games[0]));
		EXPECT_EQ("1.e4 {Gut.} 1-0", pgnOf(games[1]));
	}
	{
		CodecCB2 codec;
		codec.setLanguages({cb2::language::Italian, cb2::language::French});
		auto games = readAll(fx.write(), codec);
		ASSERT_EQ(2u, games.size());
		EXPECT_EQ("1.e4 {Bene. !!} 1-0", pgnOf(games[0]));
		EXPECT_EQ("1.e4 {Bien.} 1-0", pgnOf(games[1]));
	}
}

TEST(Test_CB2Annotations, past_the_end_medals_and_evaluations) {
	Fixture fx;
	auto& g = fx.game();
	g.moves = moveContent(annotatedMoves());
	Buf evp = {0x01};
	addLE(evp, 2 + 4 * 3, 4);
	addLE(evp, 3, 2);
	for (auto [v, flag] : {std::pair{25, 0}, {-3, 1}, {0, 0xff}}) {
		addLE(evp, uint16_t(int16_t(v)), 2);
		evp.push_back(20);
		evp.push_back(uint8_t(flag));
	}
	g.annotations = annRecord({
	    annBlock(-1, {annRaw(0x26, evp)}),
	    annBlock(5, {annRaw(0x22, {4, 0, 0, 0}), annText("Last.")}),
	    annBlock(6, {annText("After the end.", 0, true), annSymbols(18)}),
	    annBlock(40, {annText("Far after.")}),
	});
	auto& empty = fx.game(); // no moves: everything goes before them
	empty.annotations = annRecord({annBlock(0, {annText("Nothing.")})});
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(2u, games.size()) << codec.parseErrors();
	EXPECT_EQ("{[%evp 0,2,25,-29997,32767]} 1.e4 e5 2.Nf3 ( 2.f4 exf4 ) "
	          "2...Nc6 $18 {[%mdl 4] Last. After the end. Far after.} 1-0",
	          pgnOf(games[0]));
	EXPECT_EQ("{Nothing.} 1-0", pgnOf(games[1]));
}

TEST(Test_CB2Annotations, known_types_are_skipped_unknown_ones_stop) {
	Fixture fx;
	auto& known = fx.game();
	known.moves = moveContent({W("e2", "e4"), END});
	Buf tc = {0x01};
	tc.resize(38, 0);
	known.annotations = annRecord({annBlock(
	    0, {annRaw(0x07, {0, 5, 1, 0}), annRaw(0x24, tc), annRaw(0x18, {2}),
	        annRaw(0x21, {1, 0, 0, 0, 0, 0}), annRaw(0x27, {1, 0}),
	        annRaw(0x1c, {1, 1, 0, 0, 0, 'x', 0, 0, 0, 0}),
	        annText("Kept.")})});
	auto& unknown = fx.game();
	unknown.moves = moveContent({W("e2", "e4"), B("e7", "e5"), END});
	unknown.annotations = annRecord(
	    {annBlock(0, {annText("Before.")}),
	     annBlock(1, {annRaw(0x77, {1, 2, 3}), annText("Lost.")})});
	auto& damaged = fx.game();
	damaged.moves = moveContent({W("e2", "e4"), B("e7", "e5"), END});
	damaged.annotations = annRecord({annBlock(0, {annText("Kept too.")})});
	putLE(damaged.annotations, damaged.annotations.size() - 4, 1000, 4);
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(3u, games.size()) << codec.parseErrors();
	EXPECT_EQ("1.e4 {Kept.} 1-0", pgnOf(games[0]));
	EXPECT_EQ("1.e4 {Before.} 1...e5 1-0", pgnOf(games[1]));
	EXPECT_EQ("1.e4 {Kept too.} 1...e5 1-0", pgnOf(games[2]));
	EXPECT_EQ(2u, codec.counts().incomplete);
	std::string log = codec.parseErrors();
	EXPECT_NE(std::string::npos,
	          log.find("(record 2) annotations: annotation of unknown layout "
	                   "(type 0x77); imported with those before it"))
	    << log;
	EXPECT_NE(std::string::npos, log.find("(record 3) annotations: "));
	EXPECT_NE(std::string::npos,
	          log.find("2 game(s) imported without some of their annotations"));
}

TEST(Test_CB2Annotations, mutated_annotation_records_never_crash) {
	Fixture fx;
	auto& g = fx.game();
	g.moves = moveContent(annotatedMoves());
	g.annotations = annRecord({
	    annBlock(-1, {annText("Game.")}),
	    annBlock(0, {annSymbols(1), annText("Text.", 0, true)}),
	    annBlock(2, {annMarks(0x04, {2, cbSq("e5")}),
	                 annMarks(0x05, {3, cbSq("f3"), cbSq("e5")}),
	                 annRaw(0x22, {4, 0, 0, 0})}),
	});
	auto name = fx.write();
	auto stem = name.substr(0, name.size() - 5);
	std::ifstream in(stem + ".2cba", std::ios::binary);
	Buf cba((std::istreambuf_iterator<char>(in)), {});
	in.close();
	for (size_t i = 12 + 0x1a; i + 8 < cba.size(); ++i) {
		for (uint8_t x : {0x01, 0x80, 0xff}) {
			auto bad = cba;
			bad[i] ^= x;
			const auto size = le32(bad, 12 + 8);
			if (size <= bad.size() - 12 - 0x1a) {
				Buf content(bad.begin() + 12 + 0x1a,
				            bad.begin() + 12 + 0x1a + size);
				putBE(bad, 12 + 0x10, checksum(content), 8);
			}
			writeFile(stem + ".2cba", bad);
			CodecCB2 codec;
			auto games = readAll(name, codec);
			// The moves are untouched: the game is always imported.
			ASSERT_EQ(1u, games.size()) << i;
			const std::vector<std::string> main = {
			    "position startpos moves", "e2e4", "e7e5", "g1f3", "b8c6"};
			EXPECT_EQ(main, games[0].mainLineUCI()) << i;
		}
	}
}

TEST(Test_CB2Annotations, quotations_with_empty_and_filled_strings) {
	QuoteSpec olympiad;
	olympiad.whiteLast = "Suzuki";
	olympiad.whiteFirst = "Toshio";
	olympiad.blackLast = "Hamadto";
	olympiad.blackFirst = "Iyad";
	olympiad.site = "Novi Sad";
	olympiad.event = "Olympiad-29";
	olympiad.date = (1990 << 9) | (11 << 5) | 18;
	olympiad.result = 0;
	olympiad.round = 3;
	olympiad.moves = {{12, 28, 0, 0, 0}};

	QuoteSpec blitz; // with ratings, a speed, a sub-round, the year in
	blitz.whiteLast = " Nakamura ";
	blitz.whiteFirst = "Hikaru";
	blitz.blackLast = "Carlsen";
	blitz.blackFirst = "\xc3\x89mile"; // a first name starting with "É"
	blitz.site = "Saint Louis";
	blitz.event = "Champions Showdown 2025 Saint Louis";
	blitz.date = (2025 << 9);
	blitz.kind = 0x20;
	blitz.whiteElo = 2800;
	blitz.blackElo = 2830;
	blitz.result = 1;
	blitz.round = 2;
	blitz.subround = -1;

	QuoteSpec corr; // correspondence: a board without a round
	corr.whiteLast = "Ost";
	corr.blackLast = "Hansen";
	corr.event = "WCh Final";
	corr.kind = 0x80;
	corr.subround = 4;
	corr.result = 7;
	corr.startMarker = 0;

	const std::array<std::string, 5> filled = {
	    "ChessBase Magazine", "ChessBase GmbH", "CBM 199",
	    "Japan", "Jordan"};
	for (bool fill : {false, true}) {
		Fixture fx;
		auto& g = fx.game();
		g.moves = moveContent({W("e2", "e4"), END});
		auto q1 = olympiad, q2 = blitz, q3 = corr;
		if (fill)
			q1.inner = q2.inner = q3.inner = filled;
		g.annotations = annRecord({
		    annBlock(-1, {annQuote(q3)}),
		    annBlock(0, {annQuote(q1), annText("After it."), annQuote(q2),
		                 annSymbols(3)}),
		});
		CodecCB2 codec;
		auto games = readAll(fx.write(), codec);
		ASSERT_EQ(1u, games.size()) << codec.parseErrors();
		EXPECT_EQ(0u, codec.counts().incomplete) << codec.parseErrors();
		EXPECT_EQ("{* Ost-Hansen WCh Final [4]} 1.e4 $3 {After it. "
		          "0-1 Suzuki,T-Hamadto,I Olympiad-29 Novi Sad 1990 (3) "
		          "1/2 Nakamura,H (2800)-Carlsen,\xc3\x89 (2830) Champions "
		          "Showdown 2025 Saint Louis blitz (2.65535)} 1-0",
		          pgnOf(games[0]))
		    << (fill ? "filled" : "empty");
	}
}

TEST(Test_CB2Annotations, quotation_of_unknown_start_stops_the_decoding) {
	Fixture fx;
	auto& g = fx.game();
	g.moves = moveContent({W("e2", "e4"), END});
	QuoteSpec q;
	q.whiteLast = "A";
	q.blackLast = "B";
	q.startMarker = 2;
	g.annotations = annRecord(
	    {annBlock(0, {annText("Kept."), annQuote(q), annText("Lost.")})});
	CodecCB2 codec;
	auto games = readAll(fx.write(), codec);
	ASSERT_EQ(1u, games.size());
	EXPECT_EQ("1.e4 {Kept.} 1-0", pgnOf(games[0]));
	EXPECT_EQ(1u, codec.counts().incomplete);
}

// ---------------------------------------------------------------------------
// Import into a Scid database

TEST(Test_CB2Import, games_are_imported_and_counted) {
	Fixture fx;
	fx.game().moves = moveContent({W("e2", "e4"), B("e7", "e5"), END});
	fx.game().byte0 = 0x02; // a guiding text
	fx.game().moves = moveContent({W("e2", "e4"), W("d2", "d4"), END});
	auto& annotated = fx.game();
	annotated.moves = moveContent({W("d2", "d4"), END});
	annotated.annotations = annRecord({annBlock(0, {annText("Solid.")})});
	auto name = fx.write(208, 6);

	for (auto type : {"MEMORY", "SCID5"}) {
		TempDir out;
		scidBaseT dbase;
		ASSERT_EQ(OK, dbase.open(type, FMODE_Create,
		                         out.file("imported").c_str()));
		std::string msg;
		ASSERT_EQ(OK, dbase.importGames(ICodecDatabase::CB2, name.c_str(), {},
		                                msg));
		EXPECT_EQ(2u, dbase.numGames()) << msg;
		EXPECT_NE(std::string::npos, msg.find("4 records, 2 games read"))
		    << msg;
		EXPECT_NE(std::string::npos, msg.find("Skipped 1 guiding text"));
		EXPECT_NE(std::string::npos,
		          msg.find("(record 3) moves: move out of turn"));
		Game g;
		ASSERT_EQ(OK, dbase.getGame(*dbase.getIndexEntry(1), g));
		EXPECT_EQ("1.d4 {Solid.} 1-0", pgnOf(g));
		EXPECT_STREQ("Anand, Viswanathan", g.GetWhiteStr());
	}

	scidBaseT dbase;
	ASSERT_EQ(OK, dbase.open("MEMORY", FMODE_Create, "Memory"));
	std::string msg;
	EXPECT_EQ(ERROR_FileOpen,
	          dbase.importGames(ICodecDatabase::CB2, "missing.2cbh", {}, msg));
	EXPECT_NE(std::string::npos, msg.find("cannot open the .2cbh file"));
	EXPECT_EQ(0u, dbase.numGames());
}

TEST(Test_CB2Import, a_game_too_long_for_scid_keeps_its_moves) {
	Fixture fx;
	auto& big = fx.game();
	big.moves = moveContent({W("e2", "e4"), B("e7", "e5"), ALT,
	                         W("g1", "f3"), END, B("c7", "c5"), END});
	big.annotations = annRecord(
	    {annBlock(0, {annText(std::string(150000, 'x')), annSymbols(1)})});
	fx.game().moves = moveContent({W("d2", "d4"), END});
	auto name = fx.write();

	scidBaseT dbase;
	ASSERT_EQ(OK, dbase.open("MEMORY", FMODE_Create, "Memory"));
	std::string msg;
	ASSERT_EQ(OK,
	          dbase.importGames(ICodecDatabase::CB2, name.c_str(), {}, msg));
	ASSERT_EQ(2u, dbase.numGames()) << msg;
	EXPECT_NE(std::string::npos,
	          msg.find("1 game(s) too long for the database: imported "
	                   "without variations, comments and NAGs"))
	    << msg;
	Game g;
	ASSERT_EQ(OK, dbase.getGame(*dbase.getIndexEntry(0), g));
	EXPECT_EQ("1.e4 e5 2.Nf3 1-0", pgnOf(g));
	ASSERT_EQ(OK, dbase.getGame(*dbase.getIndexEntry(1), g));
	EXPECT_EQ("1.d4 1-0", pgnOf(g));
}
