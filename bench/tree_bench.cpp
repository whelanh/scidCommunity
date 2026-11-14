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

// tree_bench - measures the two phases of a Tree-window refresh:
//   1. the search that builds the per-position filter,
//   2. the move statistics over the matching games.
//
// It is deliberately small and links only the core (no Tcl/Tk), so the same
// measurement can be built from any revision.
//
// Build:
//   cmake -S . -B build-bench -DTREE_BENCH=ON -DCMAKE_BUILD_TYPE=Release
//   cmake --build build-bench --target tree_bench -j
//
// Create a synthetic database:
//   build-bench/bench/tree_bench --create /tmp/bench/base --games 1000000
//
// Measure (--cold drops the page cache of the base files before every run):
//   build-bench/bench/tree_bench --db /tmp/bench/base --cold --repeat 3
//   SCID_TREE_THREADS=1 build-bench/bench/tree_bench --db /tmp/bench/base
//
// The page-fault counters are the cache-independent signal: they show how
// many pages an operation touches, which is what a cold start must read.
// read_bytes is what actually came from the device (0 on a warm cache).

#include "misc.h"
#include "position.h"
#include "scidbase.h"
#include "searchpos.h"
#include "tree.h"

#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <filesystem>
#include <fstream>
#include <random>
#include <string>
#include <string_view>
#include <vector>

#ifdef __linux__
#include <fcntl.h>
#include <sys/resource.h>
#include <unistd.h>
#endif

namespace {

struct Metrics {
	double wall_ms = 0;
	double cpu_ms = 0;
	long minflt = 0;
	long majflt = 0;
	long long read_bytes = 0;
};

struct Snapshot {
	long minflt = 0;
	long majflt = 0;
	long long read_bytes = 0;
};

static Snapshot snapshot() {
	Snapshot s;
#ifdef __linux__
	struct rusage ru {};
	getrusage(RUSAGE_SELF, &ru);
	s.minflt = ru.ru_minflt;
	s.majflt = ru.ru_majflt;
	if (FILE* f = fopen("/proc/self/io", "r")) {
		char key[32];
		long long val;
		while (fscanf(f, "%31s %lld", key, &val) == 2) {
			if (strcmp(key, "read_bytes:") == 0) s.read_bytes = val;
		}
		fclose(f);
	}
#endif
	return s;
}

static Metrics elapsed(const Snapshot& a, double cpu0,
                       std::chrono::steady_clock::time_point t0) {
	const auto b = snapshot();
	const auto t1 = std::chrono::steady_clock::now();
	Metrics m;
	m.minflt = b.minflt - a.minflt;
	m.majflt = b.majflt - a.majflt;
	m.read_bytes = b.read_bytes - a.read_bytes;
	m.cpu_ms = double(clock()) * 1000.0 / double(CLOCKS_PER_SEC) - cpu0;
	m.wall_ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
	return m;
}

// Drop the page cache of the three database files. Works unprivileged and
// only affects these files, unlike /proc/sys/vm/drop_caches.
static void coldify(const std::string& dbpath) {
#ifdef __linux__
	const std::filesystem::path base(dbpath);
	for (const char* ext : {".si5", ".sg5", ".sn5", ".si4", ".sg4", ".sn4"}) {
		auto p = base;
		p.replace_extension(ext);
		int fd = ::open(p.c_str(), O_RDONLY);
		if (fd < 0) continue;
		::posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED);
		::close(fd);
	}
#else
	(void)dbpath;
#endif
}

// ---------------------------------------------------------------- generation

struct Opening {
	const char* moves;
	int weight;
};

// A small weighted opening pool. The weights only need to produce a realistic
// shape: a few huge root branches, many moderate ones, a long tail.
static const Opening kOpenings[] = {
    {"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 a6", 11},
    {"e4 c5 Nf3 Nc6 d4 cxd4 Nxd4 g6", 7},
    {"e4 c5 Nc3 Nc6 g3 g6 Bg2 Bg7", 3},
    {"e4 e5 Nf3 Nc6 Bb5 a6 Ba4 Nf6 O-O Be7", 10},
    {"e4 e5 Nf3 Nc6 Bc4 Bc5 c3 Nf6 d3 d6", 5},
    {"e4 e5 Nf3 Nc6 d4 exd4 Nxd4 Nf6", 4},
    {"e4 e5 Nf3 Nf6 Nxe5 d6 Nf3 Nxe4", 3},
    {"e4 e6 d4 d5 Nc3 Nf6 e5 Nfd7 f4 c5", 6},
    {"e4 e6 d4 d5 Nd2 Nf6 e5 Nfd7 Bd3 c5", 4},
    {"e4 c6 d4 d5 Nc3 dxe4 Nxe4 Bf5", 6},
    {"e4 c6 d4 d5 e5 Bf5 Nf3 e6", 3},
    {"e4 d5 exd5 Qxd5 Nc3 Qa5 d4 Nf6", 4},
    {"e4 d6 d4 Nf6 Nc3 g6 Nf3 Bg7", 4},
    {"e4 Nf6 e5 Nd5 d4 d6 Nf3 g6", 3},
    {"e4 g6 d4 Bg7 Nc3 d6 Nf3 Nf6", 2},
    {"d4 Nf6 c4 e6 Nc3 Bb4 e3 O-O Bd3 d5", 9},
    {"d4 Nf6 c4 e6 Nf3 b6 g3 Bb7 Bg2 Be7", 6},
    {"d4 Nf6 c4 g6 Nc3 Bg7 e4 d6 Nf3 O-O", 9},
    {"d4 Nf6 c4 c5 d5 b5 cxb5 a6", 4},
    {"d4 d5 c4 e6 Nc3 Nf6 Bg5 Be7 e3 O-O", 7},
    {"d4 d5 c4 c6 Nf3 Nf6 Nc3 e6 Bg5 h6", 5},
    {"d4 d5 c4 dxc4 Nf3 Nf6 e3 e6 Bxc4 c5", 4},
    {"d4 d5 Nf3 Nf6 c4 e6 Nc3 Be7", 3},
    {"d4 f5 g3 Nf6 Bg2 g6 Nf3 Bg7", 2},
    {"d4 e6 c4 f5 Nc3 Nf6 g3 Bb4", 2},
    {"Nf3 Nf6 c4 e6 Nc3 d5 d4 Be7", 5},
    {"Nf3 d5 g3 c5 Bg2 Nc6 O-O e5", 3},
    {"c4 e5 Nc3 Nf6 Nf3 Nc6 g3 d5", 4},
    {"c4 c5 Nf3 Nf6 Nc3 Nc6 g3 g6", 3},
    {"c4 Nf6 Nc3 e6 Nf3 d5 d4 Be7", 2},
    {"g3 d5 Bg2 e5 d4 exd4 Nf3 Nc6", 2},
    {"b3 e5 Bb2 Nc6 e3 Nf6 Bb5 Bd6", 1},
    {"f4 d5 Nf3 g6 e3 Bg7 Be2 Nf6", 1},
    {"d4 Nf6 Bg5 e6 e4 h6 Bxf6 Qxf6", 2},
    {"e4 e5 f4 exf4 Nf3 g5 h4 g4", 1},
    {"e4 e5 Nc3 Nf6 f4 d5 fxe5 Nxe4", 1},
};

// First moves that are (mostly) outside the stored-line dictionary, so the
// stats fallback that reads the game body is exercised.
static const char* kUnusualFirstMoves[] = {"a3", "h3", "a4", "h4",
                                           "Na3", "Nh3", "b4", "g4"};

static const char* kPlayers[] = {
    "Carlsen, Magnus",          "Nakamura, Hikaru",
    "Ding, Liren",              "Firouzja, Alireza",
    "Caruana, Fabiano",         "Nepomniachtchi, Ian",
    "So, Wesley",               "Giri, Anish",
    "Aronian, Levon",           "Mamedyarov, Shakhriyar",
    "Rapport, Richard",         "Duda, Jan-Krzysztof",
    "Vachier-Lagrave, Maxime",  "Anand, Viswanathan",
    "Kramnik, Vladimir",        "Topalov, Veselin",
    "Svidler, Peter",           "Grischuk, Alexander",
};

static std::string moveNumber(int ply) {
	if (ply % 2 == 0) {
		return (ply ? " " : "") + std::to_string(ply / 2 + 1) + ". ";
	}
	return " ";
}

static bool appendSan(Position& pos, const char* begin, const char* end,
                      std::string& out, int ply) {
	simpleMoveT sm {};
	if (pos.ParseMove(&sm, begin, end) != OK) return false;
	char san[16];
	pos.MakeSANString(&sm, san, SAN_CHECKTEST);
	out += moveNumber(ply);
	out += san;
	pos.DoSimpleMove(sm);
	return true;
}

static bool playLine(Position& pos, const char* line, std::string& out,
                     int& ply) {
	std::string_view sv(line);
	size_t p = 0;
	while (p < sv.size()) {
		size_t q = sv.find(' ', p);
		if (q == std::string_view::npos) q = sv.size();
		if (!appendSan(pos, sv.data() + p, sv.data() + q, out, ply)) {
			return false;
		}
		++ply;
		p = q + 1;
	}
	return true;
}

static std::string randomGame(std::mt19937_64& rng, int unusualPct) {
	Position pos;
	pos.StdStart();
	std::string out;
	int ply = 0;

	const bool unusual = (int(rng() % 100) < unusualPct);
	if (unusual) {
		const char* m = kUnusualFirstMoves[rng() % (sizeof(kUnusualFirstMoves) /
		                                           sizeof(*kUnusualFirstMoves))];
		if (!playLine(pos, m, out, ply)) return {};
	} else {
		int total = 0;
		for (const auto& op : kOpenings) total += op.weight;
		int r = int(rng() % unsigned(total));
		const char* line = kOpenings[0].moves;
		for (const auto& op : kOpenings) {
			if (r < op.weight) {
				line = op.moves;
				break;
			}
			r -= op.weight;
		}
		if (!playLine(pos, line, out, ply)) return {};
	}

	const int target = 24 + int(rng() % 60); // 12-42 full moves
	while (ply < target) {
		MoveList ml;
		pos.GenerateMoves(&ml);
		if (ml.Size() == 0) break;
		simpleMoveT sm = *ml.Get(rng() % ml.Size());
		char san[16];
		pos.MakeSANString(&sm, san, SAN_CHECKTEST);
		out += moveNumber(ply);
		out += san;
		pos.DoSimpleMove(sm);
		++ply;
	}

	static const char* results[] = {"1-0", "0-1", "1/2-1/2"};
	return out + " " + results[rng() % 3];
}

static int createBase(const std::string& dbpath, gamenumT nGames,
                      int unusualPct) {
	const std::filesystem::path base(dbpath);
	if (base.has_parent_path()) {
		std::filesystem::create_directories(base.parent_path());
	}
	auto pgnPath = base;
	pgnPath.replace_extension(".bench.pgn");
	{
		std::ofstream pgn(pgnPath, std::ios::binary);
		if (!pgn) {
			std::fprintf(stderr, "cannot write %s\n", pgnPath.c_str());
			return 1;
		}
		std::mt19937_64 rng(123456789);
		const auto t0 = std::chrono::steady_clock::now();
		gamenumT made = 0;
		while (made < nGames) {
			std::string game = randomGame(rng, unusualPct);
			if (game.empty()) continue;
			const char* white =
			    kPlayers[rng() % (sizeof(kPlayers) / sizeof(*kPlayers))];
			const char* black =
			    kPlayers[rng() % (sizeof(kPlayers) / sizeof(*kPlayers))];
			size_t lastSpace = game.rfind(' ');
			std::string result = game.substr(lastSpace + 1);
			int whiteElo = 2100 + int(rng() % 700);
			int blackElo = 2100 + int(rng() % 700);
			int year = 1990 + int(rng() % 36);
			char buf[512];
			std::snprintf(buf, sizeof(buf),
			              "[Event \"Synthetic %u\"]\n[Site \"Bench\"]\n"
			              "[Date \"%04d.01.01\"]\n[Round \"%u\"]\n"
			              "[White \"%s\"]\n[Black \"%s\"]\n[Result \"%s\"]\n"
			              "[WhiteElo \"%d\"]\n[BlackElo \"%d\"]\n\n",
			              unsigned(made / 100), year, unsigned(made % 13) + 1,
			              white, black, result.c_str(), whiteElo, blackElo);
			pgn << buf << game << "\n\n";
			++made;
			if (made % 100000 == 0) {
				const auto dt = std::chrono::duration<double>(
				    std::chrono::steady_clock::now() - t0).count();
				std::fprintf(stderr, "generated %u games (%.0f/s)\n",
				             unsigned(made), made / dt);
			}
		}
	}
	std::fprintf(stderr, "importing %s ...\n", pgnPath.c_str());
	scidBaseT dbase;
	if (dbase.open("SCID5", FMODE_Create, dbpath.c_str()) != OK) {
		std::fprintf(stderr, "cannot create %s\n", dbpath.c_str());
		return 1;
	}
	std::string errMsg;
	const auto t0 = std::chrono::steady_clock::now();
	const errorT err = dbase.importGames(ICodecDatabase::PGN, pgnPath.c_str(),
	                                     Progress(), errMsg);
	if (err != OK) {
		std::fprintf(stderr, "import failed: %s\n", errMsg.c_str());
		return 1;
	}
	const auto dt = std::chrono::duration<double>(
	    std::chrono::steady_clock::now() - t0).count();
	std::fprintf(stderr, "imported %u games in %.1f s\n", dbase.numGames(), dt);
	dbase.Close();
	if (std::getenv("TREE_BENCH_KEEP_PGN") == nullptr) {
		std::filesystem::remove(pgnPath);
	}
	return 0;
}

// ------------------------------------------------------------------ measuring

struct Scenario {
	const char* name;
	const char* san;
};

static const Scenario kScenarios[] = {
    {"start", ""},  {"e4", "e4"}, {"e4c5", "e4 c5"},
    {"d4", "d4"},   {"d4Nf6c4", "d4 Nf6 c4"},
};

static Position positionFromSan(const char* san) {
	Position pos;
	pos.StdStart();
	if (san == nullptr || *san == '\0') return pos;
	std::string_view sv(san);
	size_t p = 0;
	while (p < sv.size()) {
		size_t q = sv.find(' ', p);
		if (q == std::string_view::npos) q = sv.size();
		simpleMoveT sm {};
		if (pos.ParseMove(&sm, sv.data() + p, sv.data() + q) != OK) {
			std::fprintf(stderr, "bad position '%s'\n", san);
			std::exit(2);
		}
		pos.DoSimpleMove(sm);
		p = q + 1;
	}
	return pos;
}

// Order-independent digest of the statistics: two implementations agree if
// and only if they produced the same multiset of nodes with the same totals.
static uint64_t digestStats(const std::vector<TreeNode>& nodes) {
	uint64_t acc = 0;
	for (auto const& n : nodes) {
		uint64_t h = 1469598103934665603ULL;
		auto mix = [&](uint64_t v) {
			h ^= v;
			h *= 1099511628211ULL;
		};
		for (int i = 0; i < NUM_RESULT_TYPES; ++i) mix(n.freq[i]);
		mix(n.eloWhiteSum);
		mix(n.eloBlackSum);
		mix(n.yearSum);
		mix(n.eloCount);
		mix(n.yearCount);
		mix(n.lengthSum);
		mix(n.lengthCount);
		for (auto const& m : n.moves) {
			for (char c : m.getSAN()) mix(uint64_t(static_cast<unsigned char>(c)));
			mix(0xFF);
		}
		acc += h * 0x9E3779B97F4A7C15ULL;
	}
	return acc;
}

static bool g_digest = false;

static void runBench(const std::string& dbpath, int depth, int repeat,
                     bool cold, const std::vector<Scenario>& scenarios) {
	if (g_digest) {
		std::printf("%-9s %5s %9s %18s\n", "scenario", "depth", "nodes",
		            "digest");
	} else {
		std::printf("%-9s %5s | %10s %9s %9s %9s %11s | %10s %9s %9s %9s "
		            "%11s | %9s %7s\n",
		            "scenario", "depth", "search_ms", "cpu_ms", "minflt",
		            "majflt", "disk_bytes", "stats_ms", "cpu_ms", "minflt",
		            "majflt", "disk_bytes", "matches", "nodes");
	}

	scidBaseT dbase;
	for (int it = 0; it < repeat; ++it) {
		for (const auto& sc : scenarios) {
			if (cold) coldify(dbpath);
			if (dbase.open("SCID5", FMODE_ReadOnly, dbpath.c_str()) != OK) {
				std::fprintf(stderr, "cannot open %s\n", dbpath.c_str());
				std::exit(1);
			}
			const Position pos = positionFromSan(sc.san);
			const std::string filterName = dbase.newFilter();
			HFilter filter = dbase.getFilter(filterName);

			auto s0 = snapshot();
			double cpu0 = double(clock()) * 1000.0 / double(CLOCKS_PER_SEC);
			auto t0 = std::chrono::steady_clock::now();
			if (!SearchPos(pos).setFilter(dbase, filter, Progress())) {
				std::fprintf(stderr, "search cancelled\n");
				std::exit(1);
			}
			const Metrics search = elapsed(s0, cpu0, t0);
			const gamenumT matches = filter->size();

			s0 = snapshot();
			cpu0 = double(clock()) * 1000.0 / double(CLOCKS_PER_SEC);
			t0 = std::chrono::steady_clock::now();
			const auto stats = dbase.getTreeStat(filter, depth);
			const Metrics st = elapsed(s0, cpu0, t0);

			if (g_digest) {
				std::printf("%-9s %5d %9zu %18llx\n", sc.name, depth,
				            stats.size(),
				            (unsigned long long)digestStats(stats));
			} else {
				std::printf("%-9s %5d | %10.1f %9.1f %9ld %9ld %11lld | "
				            "%10.1f %9.1f %9ld %9ld %11lld | %9u %7zu\n",
				            sc.name, depth, search.wall_ms, search.cpu_ms,
				            search.minflt, search.majflt, search.read_bytes,
				            st.wall_ms, st.cpu_ms, st.minflt, st.majflt,
				            st.read_bytes, matches, stats.size());
			}
			std::fflush(stdout);
			dbase.Close();
		}
	}
}

} // namespace

int main(int argc, char** argv) {
	std::string dbpath;
	gamenumT games = 0;
	int depth = 1;
	int repeat = 1;
	bool cold = false;
	bool create = false;
	int unusualPct = 5;
	std::vector<Scenario> scenarios;

	for (int i = 1; i < argc; ++i) {
		std::string_view a(argv[i]);
		auto next = [&](const char* what) -> const char* {
			if (i + 1 >= argc) {
				std::fprintf(stderr, "%s needs a value\n", what);
				std::exit(2);
			}
			return argv[++i];
		};
		if (a == "--create") {
			create = true;
			dbpath = next("--create");
		} else if (a == "--db") {
			dbpath = next("--db");
		} else if (a == "--unusual-fraction") {
			unusualPct = atoi(next("--unusual-fraction"));
			if (unusualPct < 0) unusualPct = 0;
			if (unusualPct > 100) unusualPct = 100;
		} else if (a == "--games") {
			games = gamenumT(strtoul(next("--games"), nullptr, 10));
		} else if (a == "--depth") {
			depth = atoi(next("--depth"));
		} else if (a == "--repeat") {
			repeat = atoi(next("--repeat"));
		} else if (a == "--cold") {
			cold = true;
		} else if (a == "--digest") {
			g_digest = true;
		} else if (a == "--scenario") {
			const char* name = next("--scenario");
			bool found = false;
			for (const auto& sc : kScenarios) {
				if (strcmp(sc.name, name) == 0) {
					scenarios.push_back(sc);
					found = true;
				}
			}
			if (!found) {
				std::fprintf(stderr, "unknown scenario %s\n", name);
				return 2;
			}
		} else if (a == "--help" || a == "-h") {
			std::printf(
			    "usage: tree_bench --create <base> --games N\n"
			    "       tree_bench --db <base> [--depth D] [--repeat R] "
			    "[--cold] [--scenario name]...\n"
			    "       tree_bench --create <base> --games N "
			    "[--unusual-fraction 0-100]\n"
			    "scenarios: start e4 e4c5 d4 d4Nf6c4\n"
			    "env: SCID_TREE_THREADS=N (0 = automatic)\n");
			return 0;
		} else {
			std::fprintf(stderr, "unknown option %s\n", a.data());
			return 2;
		}
	}

	if (dbpath.empty()) {
		std::fprintf(stderr, "need --db or --create\n");
		return 2;
	}
	if (create) {
		if (games == 0) games = 1000000;
		return createBase(dbpath, games, unusualPct);
	}
	if (scenarios.empty()) {
		for (const auto& sc : kScenarios) scenarios.push_back(sc);
	}
	runBench(dbpath, depth, repeat, cold, scenarios);
	return 0;
}
