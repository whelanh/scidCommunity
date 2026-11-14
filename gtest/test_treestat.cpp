/*
 * Copyright (C) 2026 Hugh Whelan
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

#include "scidbase.h"
#include "searchpos.h"

#include <algorithm>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <string>
#include <string_view>
#include <vector>

#include <gtest/gtest.h>

namespace {

void setThreads(const char* value) {
#ifdef _WIN32
	_putenv_s("SCID_TREE_THREADS", value ? value : "");
#else
	if (value)
		setenv("SCID_TREE_THREADS", value, 1);
	else
		unsetenv("SCID_TREE_THREADS");
#endif
}

Position positionFromSan(const char* san) {
	Position pos;
	pos.StdStart();
	if (san == nullptr) return pos;
	std::string_view sv(san);
	size_t p = 0;
	while (p < sv.size()) {
		size_t q = sv.find(' ', p);
		if (q == std::string_view::npos) q = sv.size();
		simpleMoveT sm {};
		EXPECT_EQ(OK, pos.ParseMove(&sm, sv.data() + p, sv.data() + q));
		pos.DoSimpleMove(sm);
		p = q + 1;
	}
	return pos;
}

// Canonical, order-independent description of a statistics result.
std::string repr(const std::vector<TreeNode>& nodes) {
	std::vector<std::string> lines;
	lines.reserve(nodes.size());
	for (const auto& n : nodes) {
		std::string s;
		for (const auto& m : n.moves) {
			s += m.getSAN();
			s += ' ';
		}
		s += '|';
		for (int i = 0; i < NUM_RESULT_TYPES; ++i) {
			s += std::to_string(n.freq[i]);
			s += ',';
		}
		s += std::to_string(n.eloWhiteSum) + ',' +
		     std::to_string(n.eloBlackSum) + ',' + std::to_string(n.yearSum) +
		     ',' + std::to_string(n.eloCount) + ',' +
		     std::to_string(n.yearCount) + ',' + std::to_string(n.lengthSum) +
		     ',' + std::to_string(n.lengthCount);
		lines.push_back(std::move(s));
	}
	std::sort(lines.begin(), lines.end());
	std::string out;
	for (const auto& l : lines) {
		out += l;
		out += '\n';
	}
	return out;
}

const char* const kOpenings[] = {
    "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7",
    "1. e4 c5 2. Nf3 d6 3. d4 cxd4 4. Nxd4 Nf6 5. Nc3 a6",
    "1. d4 d5 2. c4 e6 3. Nc3 Nf6 4. Bg5 Be7",
    "1. d4 Nf6 2. c4 g6 3. Nc3 Bg7 4. e4 d6",
    "1. c4 e5 2. Nc3 Nf6 3. Nf3 Nc6",
    "1. Nf3 d5 2. g3 c5 3. Bg2 Nc6",
    "1. e4 e6 2. d4 d5 3. Nc3 Nf6",
    "1. a3 e5 2. b4 Bxb4", // no stored line: exercises the game-read fallback
};

class Test_TreeStat : public ::testing::Test {
protected:
	void SetUp() override {
		pgnPath_ = std::filesystem::temp_directory_path() /
		           "scid_treestat_test.pgn";
		std::ofstream pgn(pgnPath_);
		ASSERT_TRUE(pgn.good());
		const char* results[] = {"1-0", "0-1", "1/2-1/2"};
		int g = 0;
		for (const char* opening : kOpenings) {
			for (int copy = 0; copy < 4; ++copy, ++g) {
				pgn << "[Event \"Test\"]\n[Site \"Here\"]\n"
				    << "[Date \"2020.01.0" << (g % 9) + 1 << "\"]\n"
				    << "[Round \"" << g + 1 << "\"]\n"
				    << "[White \"White " << g << "\"]\n"
				    << "[Black \"Black " << g << "\"]\n"
				    << "[Result \"" << results[g % 3] << "\"]\n"
				    << "[WhiteElo \"" << 2300 + g << "\"]\n"
				    << "[BlackElo \"" << 2200 + g << "\"]\n\n"
				    << opening << " " << results[g % 3] << "\n\n";
			}
		}
		pgn.close();

		ASSERT_EQ(OK, dbase_.open("MEMORY", FMODE_Create, "Memory"));
		std::string errMsg;
		ASSERT_EQ(OK, dbase_.importGames(ICodecDatabase::PGN,
		                                 pgnPath_.string().c_str(), Progress(),
		                                 errMsg));
		ASSERT_EQ(32u, dbase_.numGames());
	}

	void TearDown() override {
		setThreads(nullptr);
		dbase_.Close();
		std::filesystem::remove(pgnPath_);
	}

	std::vector<TreeNode> statsFor(const char* san, int depth) {
		const Position pos = positionFromSan(san);
		const std::string name = dbase_.newFilter();
		HFilter filter = dbase_.getFilter(name);
		EXPECT_TRUE(SearchPos(pos).setFilter(dbase_, filter, Progress()));
		EXPECT_GT(filter->size(), 0u);
		return dbase_.getTreeStat(filter, depth);
	}

	scidBaseT dbase_;
	std::filesystem::path pgnPath_;
};

} // namespace

TEST_F(Test_TreeStat, parallel_matches_serial) {
	const char* positions[] = {"", "e4", "e4 c5", "d4", "a3"};
	for (const char* san : positions) {
		for (int depth = 1; depth <= 4; ++depth) {
			setThreads("1");
			const auto serial = statsFor(san, depth);
			setThreads("4");
			const auto parallel = statsFor(san, depth);
			EXPECT_EQ(repr(serial), repr(parallel))
			    << "position '" << san << "' depth " << depth;
			EXPECT_FALSE(serial.empty());
		}
	}
	setThreads(nullptr);
}

TEST_F(Test_TreeStat, reports_counts_and_totals) {
	const auto stats = statsFor("", 1);
	// Five distinct first moves among the 32 games (e4 and d4 are each
	// shared by several openings).
	ASSERT_EQ(5u, stats.size());
	gamenumT total = 0;
	for (const auto& n : stats) total += n.freq[0];
	EXPECT_EQ(32u, total);

	// Most games first.
	for (size_t i = 1; i < stats.size(); ++i)
		EXPECT_GE(stats[i - 1].freq[0], stats[i].freq[0]);
}

TEST_F(Test_TreeStat, cancellation_reports_and_returns_empty) {
	struct Cancel : Progress::Impl {
		bool report(size_t, size_t, const char*) override { return false; }
	};
	setThreads("4");
	const Position pos = positionFromSan("");
	const std::string name = dbase_.newFilter();
	HFilter filter = dbase_.getFilter(name);
	ASSERT_TRUE(SearchPos(pos).setFilter(dbase_, filter, Progress()));

	bool cancelled = false;
	Progress progress(new Cancel());
	const auto res = dbase_.getTreeStat(filter, 1, progress, &cancelled);
	EXPECT_TRUE(cancelled);
	EXPECT_TRUE(res.empty());
	setThreads(nullptr);
}
