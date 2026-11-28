/*
 * Copyright (C) 2026 Tommaso Bergamasco
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * This file is part of scidCommunity.
 */

#include "cb2_fixture.h"
#include "cb2_format.h"
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
