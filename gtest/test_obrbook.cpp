/*
 * Copyright (C) 2026 scidCommunity contributors
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

// Reader for OpenBook Rich (.obr) books, see docs/obr_format.md.
// The tests write a tiny .obr file byte by byte, so they also pin the format.

#include <gtest/gtest.h>

#include "polyglot/obrbook.h"

#include <chrono>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <string>
#include <vector>

namespace {

constexpr int SLOT = 0;
constexpr uint64_t ROOT = 100, ALIAS = 150, CHILD = 200, MISSING = 300;
constexpr int E2E4 = (12 << 6) | 28; // Polyglot move: from e2 (12) to e4 (28)
constexpr int D2D4 = (11 << 6) | 27;
constexpr int E7E5 = (52 << 6) | 36; // e2e4 seen with colours reversed

void put(std::string& s, uint64_t v, int n) {
	for (int i = 0; i < n; ++i)
		s.push_back(char((v >> (8 * i)) & 0xFF));
}

void add_position(std::string& s, uint64_t key, uint32_t games, uint32_t ww,
              uint32_t dd, uint32_t bw, uint32_t first, uint16_t n_moves,
              uint8_t rec) {
	put(s, key, 8);
	for (uint32_t v : {games, ww, dd, bw})
		put(s, v, 4);
	put(s, 2, 4);    // rating_games
	put(s, 5000, 4); // rating_sum
	put(s, 0, 4);    // perf_games
	put(s, 0, 4);    // perf_sum
	put(s, first, 4);
	put(s, n_moves, 2);
	put(s, rec, 1);
	put(s, 0, 1); // flags: White to move
}

void add_move(std::string& s, int mv, uint8_t annotation, uint8_t status,
          uint32_t child) {
	put(s, mv, 2);
	put(s, annotation, 1);
	put(s, status, 1);
	put(s, child, 4);
}

// Root (key 100) with 1.e4 (-> child, key 200) and 1.d4 (legal, no child),
// plus an alias (key 150) answering the root with colours reversed.
std::string sample_book() {
	std::string pos, mov, ali;
	add_position(pos, ROOT, 10, 5, 3, 2, 0, 2, 0);
	add_position(pos, CHILD, 6, 4, 1, 1, 2, 0, 0x80);
	add_move(mov, E2E4, 0xE0 | 1, 0, 1); // flags 0xE0, NAG "!"
	add_move(mov, D2D4, 0, 3, 0xFFFFFFFFu);
	put(ali, ALIAS, 8);
	put(ali, 0u | (1u << 30), 4); // position 0, transform 1
	const std::string meta = "{}";

	const uint64_t pos_off = 64, move_off = pos_off + pos.size(),
	               alias_off = move_off + mov.size(),
	               meta_off = alias_off + ali.size();
	std::string h = "OBR1";
	put(h, 1, 2);  // version
	put(h, 64, 2); // header_size
	put(h, 2, 4);  // n_positions
	put(h, 2, 4);  // n_moves
	put(h, 1, 4);  // n_aliases
	put(h, 48, 2);
	put(h, 8, 2);
	put(h, pos_off, 8);
	put(h, move_off, 8);
	put(h, alias_off, 8);
	put(h, meta_off, 8);
	put(h, meta.size(), 4);
	put(h, 0, 4);
	return h + pos + mov + ali + meta;
}

class Test_ObrBook : public ::testing::Test {
protected:
	std::filesystem::path path_;

	void SetUp() override {
		const auto stamp =
		    std::chrono::steady_clock::now().time_since_epoch().count();
		path_ = std::filesystem::temp_directory_path() /
		        ("scid-obrbook-" + std::to_string(stamp) + ".obr");
	}
	void TearDown() override {
		obr_close(SLOT);
		std::error_code ec;
		std::filesystem::remove(path_, ec);
	}
	bool open(const std::string& bytes) {
		{
			std::ofstream out(path_, std::ios::binary);
			out << bytes;
		}
		return obr_open(path_.string().c_str(), SLOT);
	}
	static board_t board(uint64_t key) {
		board_t b{};
		b.key = key;
		return b;
	}
};

} // namespace

TEST_F(Test_ObrBook, ProbePositionAndMoves) {
	ASSERT_TRUE(open(sample_book()));
	EXPECT_TRUE(obr_is_open(SLOT));

	const board_t b = board(ROOT);
	obr_stats_t pos;
	std::vector<obr_move_t> moves;
	int transform = -1;
	ASSERT_TRUE(obr_probe(&b, SLOT, pos, moves, transform));
	EXPECT_EQ(0, transform);
	EXPECT_EQ(10u, pos.games);
	EXPECT_EQ(5u, pos.white_wins);
	EXPECT_EQ(3u, pos.draws);
	EXPECT_EQ(2u, pos.black_wins);
	EXPECT_EQ(2u, pos.rating_games);
	EXPECT_EQ(5000u, pos.rating_sum);

	ASSERT_EQ(2u, moves.size());
	EXPECT_EQ(E2E4, moves[0].move);
	EXPECT_EQ(0xE1, moves[0].annotation);
	ASSERT_TRUE(moves[0].has_child);
	EXPECT_EQ(6u, moves[0].child.games);
	EXPECT_EQ(4u, moves[0].child.white_wins);
	EXPECT_EQ(0x80, moves[0].child.recommendation);

	EXPECT_EQ(D2D4, moves[1].move);
	EXPECT_EQ(3, moves[1].status);
	EXPECT_FALSE(moves[1].has_child);
}

TEST_F(Test_ObrBook, AliasReversesColours) {
	ASSERT_TRUE(open(sample_book()));

	const board_t b = board(ALIAS);
	obr_stats_t pos;
	std::vector<obr_move_t> moves;
	int transform = -1;
	ASSERT_TRUE(obr_probe(&b, SLOT, pos, moves, transform));
	EXPECT_EQ(1, transform);
	EXPECT_EQ(2u, pos.white_wins); // swapped with black_wins
	EXPECT_EQ(5u, pos.black_wins);
	EXPECT_EQ(1, pos.flags & 1); // now Black to move

	ASSERT_EQ(2u, moves.size());
	EXPECT_EQ(E7E5, moves[0].move);
	EXPECT_EQ(1u, moves[0].child.white_wins);
	EXPECT_EQ(4u, moves[0].child.black_wins);
}

TEST_F(Test_ObrBook, MissingPosition) {
	ASSERT_TRUE(open(sample_book()));

	const board_t b = board(MISSING);
	obr_stats_t pos;
	std::vector<obr_move_t> moves;
	int transform;
	EXPECT_FALSE(obr_probe(&b, SLOT, pos, moves, transform));
	EXPECT_TRUE(moves.empty());
	EXPECT_FALSE(obr_contains(&b, SLOT));
	const board_t child = board(CHILD);
	EXPECT_TRUE(obr_contains(&child, SLOT));
}

TEST_F(Test_ObrBook, RejectsInvalidFiles) {
	const std::string good = sample_book();

	EXPECT_FALSE(open(good.substr(0, good.size() - 8))) << "truncated";
	EXPECT_FALSE(obr_is_open(SLOT));

	std::string bad_magic = good;
	bad_magic[3] = '2';
	EXPECT_FALSE(open(bad_magic));

	std::string empty = good;
	empty[8] = 0; // n_positions = 0
	EXPECT_FALSE(open(empty));
	EXPECT_FALSE(obr_is_open(SLOT));

	EXPECT_FALSE(open(std::string(16, '\0'))) << "Polyglot-sized entry";
}

TEST_F(Test_ObrBook, CloseReleasesSlot) {
	ASSERT_TRUE(open(sample_book()));
	obr_close(SLOT);
	EXPECT_FALSE(obr_is_open(SLOT));
	const board_t b = board(ROOT);
	EXPECT_FALSE(obr_contains(&b, SLOT));
}
