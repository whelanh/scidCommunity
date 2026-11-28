/*
 * Copyright (C) 2026 Tommaso Bergamasco
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * This file is part of scidCommunity.
 */

#include "cb2_fixture.h"
#include "cb2_format.h"
#include "codec_cb2.h"
#include "date.h"
#include "game.h"
#include "misc.h"
#include <deque>
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
