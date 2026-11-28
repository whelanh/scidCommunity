/*
 * Copyright (C) 2026 Tommaso Bergamasco
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * This file is part of scidCommunity.
 */

/** @file
 * Builds small 2CBH databases byte by byte for the tests: no real database,
 * and nothing derived from one, is ever needed.
 */

#pragma once

#include <algorithm>
#include <array>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <random>
#include <string>
#include <vector>

namespace cb2test {

using Buf = std::vector<uint8_t>;

/// A directory removed with everything in it when the object goes.
struct TempDir {
	std::filesystem::path path;
	TempDir() {
		std::random_device rd;
		path = std::filesystem::temp_directory_path() /
		       ("scid_cb2_" + std::to_string(rd()) + std::to_string(rd()));
		std::filesystem::create_directories(path);
	}
	~TempDir() {
		std::error_code ec;
		std::filesystem::remove_all(path, ec);
	}
	std::string file(const std::string& name) const {
		return (path / name).string();
	}
};

inline void writeFile(const std::string& name, const Buf& data) {
	std::ofstream f(name, std::ios::binary | std::ios::trunc);
	f.write(reinterpret_cast<const char*>(data.data()), data.size());
}

inline void putLE(Buf& b, size_t at, uint64_t v, int n) {
	if (b.size() < at + n)
		b.resize(at + n);
	for (int i = 0; i < n; ++i)
		b[at + i] = static_cast<uint8_t>(v >> (8 * i));
}
inline void putBE(Buf& b, size_t at, uint64_t v, int n) {
	if (b.size() < at + n)
		b.resize(at + n);
	for (int i = 0; i < n; ++i)
		b[at + i] = static_cast<uint8_t>(v >> (8 * (n - 1 - i)));
}
inline uint32_t le32(const Buf& b, size_t at) {
	return uint32_t(b[at]) | uint32_t(b[at + 1]) << 8 | uint32_t(b[at + 2]) << 16 |
	       uint32_t(b[at + 3]) << 24;
}
inline void addLE(Buf& b, uint64_t v, int n) { putLE(b, b.size(), v, n); }
inline void addBE(Buf& b, uint64_t v, int n) { putBE(b, b.size(), v, n); }
inline void addBytes(Buf& b, const Buf& v) {
	b.insert(b.end(), v.begin(), v.end());
}

/// The 192 bytes of a header record that the reader uses.
using RecordBytes = std::array<uint8_t, 192>;

/// A `.2cbh` file: a header record, then @p records, each padded to
/// @p recordSize. A 208-byte record carries 16 trailing bytes as ChessBase
/// 2027 writes them: an i64 -1, then a small i64.
inline Buf headerFile(int recordSize, unsigned version,
                      const std::vector<RecordBytes>& records) {
	const size_t rs = recordSize > 0 ? size_t(recordSize) : 192;
	Buf out(rs, 0);
	putLE(out, 0x0a, static_cast<uint16_t>(recordSize), 2);
	out[0x0d] = static_cast<uint8_t>(version);
	for (auto& r : records) {
		auto at = out.size();
		out.insert(out.end(), r.begin(), r.end());
		out.resize(at + rs, 0);
		if (rs >= 208) {
			putLE(out, at + 192, uint64_t(-1), 8);
			putLE(out, at + 200, 3, 8);
		}
	}
	return out;
}

/// The checksum of a frame's content, written independently of the reader:
/// byte i is the sum of the i-th of eight equal runs.
inline uint64_t checksum(const Buf& c) {
	const size_t m = c.size() / 8;
	uint64_t v = 0;
	if (m == 0) {
		for (size_t i = 0; i < c.size(); ++i)
			v |= uint64_t(c[i]) << (8 * i);
		return v;
	}
	for (size_t i = 0; i < 8; ++i) {
		uint8_t s = 0;
		for (size_t j = 0; j < m; ++j)
			s = uint8_t(s + c[i * m + j]);
		v |= uint64_t(s) << (8 * i);
	}
	return v;
}

/// One framed record of `.2cbg` or `.2cba`.
inline Buf frame(uint16_t tag, const Buf& content, size_t spare = 0) {
	Buf f = {0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11};
	addLE(f, content.size(), 4);
	addLE(f, spare, 4);
	addBE(f, checksum(content), 8);
	addLE(f, tag, 2);
	addBytes(f, content);
	f.resize(f.size() + spare, 0xAA);
	addLE(f, content.size() + spare + 34, 8);
	return f;
}

/// Move-record words: the optional start section, the move marker, the
/// tree's words.
inline Buf moveContent(const std::vector<uint16_t>& tree,
                       const std::vector<uint16_t>& start = {}) {
	Buf b;
	if (!start.empty()) {
		addLE(b, 0xfffb, 2);
		for (auto w : start)
			addLE(b, w, 2);
	}
	addLE(b, 0xfffc, 2);
	for (auto w : tree)
		addLE(b, w, 2);
	return b;
}

/// @name Annotation records: blocks of (position, count, annotations),
/// ended by 0x7fffffff.
///@{
inline Buf annText(const std::string& text, uint16_t language = 0,
                   bool before = false) {
	Buf b;
	addLE(b, before ? 0x82 : 0x02, 2);
	addLE(b, 0, 2);
	addLE(b, language, 2);
	addLE(b, text.size(), 4);
	b.insert(b.end(), text.begin(), text.end());
	return b;
}
inline Buf annSymbols(uint8_t move, uint8_t position = 0, uint8_t prefix = 0) {
	return {0x03, 0x00, move, position, prefix};
}
/// Squares as (colour, ChessBase square from 1, file by file).
inline Buf annMarks(uint16_t type, const Buf& items) {
	Buf b;
	addLE(b, type, 2);
	addLE(b, items.size(), 4);
	addBytes(b, items);
	return b;
}
/// The square numbered from 1, file by file, that ChessBase uses: a1 1, a2 2.
inline uint8_t cbSq(const char* s) {
	return uint8_t((s[0] - 'a') * 8 + (s[1] - '1') + 1);
}
inline Buf annRaw(uint16_t type, const Buf& data) {
	Buf b;
	addLE(b, type, 2);
	addBytes(b, data);
	return b;
}
inline Buf annBlock(int32_t position, const std::vector<Buf>& items) {
	Buf b;
	addLE(b, uint32_t(position), 4);
	addLE(b, items.size(), 4);
	for (auto& i : items)
		addBytes(b, i);
	return b;
}
inline Buf annRecord(const std::vector<Buf>& blocks) {
	Buf b;
	for (auto& bl : blocks)
		addBytes(b, bl);
	addLE(b, 0x7fffffff, 4);
	return b;
}
///@}

/// A game (or another record) of a fixture database.
struct GameSpec {
	uint8_t byte0 = 0; ///< 0x80 deleted, 0x02 text (with kind 1)
	uint8_t kind = 1;  ///< 1 game or text, 2 analysis
	int64_t white = -1, black = -1, tournament = -1, annotator = -1;
	uint8_t result = 2;
	int16_t round = 0, subround = 0, whiteElo = 0, blackElo = 0;
	uint16_t eco = 0;
	int32_t date = 0;
	uint16_t movesTag = 1; ///< 2 for Chess960
	Buf moves = moveContent({0xffff});
	/// An annotation record's content; empty for none.
	Buf annotations;
	/// Raw bytes for the move record in place of a frame (for damage).
	Buf rawMoves;
};

/// Writes a small 2CBH database: `.2cbh`, `.2cbg`, `.2cba` and `.2lid`.
struct Builder {
	std::vector<std::pair<std::string, std::string>> players;
	struct T {
		std::string title, place;
		int32_t date;
	};
	std::vector<T> tournaments;
	std::vector<GameSpec> games;

	int64_t player(const std::string& last, const std::string& first = "") {
		players.emplace_back(last, first);
		return int64_t(players.size()) - 1;
	}
	int64_t tournament(const std::string& title, const std::string& place,
	                   int32_t date = 0) {
		tournaments.push_back({title, place, date});
		return int64_t(tournaments.size()) - 1;
	}

	static constexpr size_t kPlayerSize = 96, kTournamentSize = 160,
	                        kOtherSize = 16;

	static void str(Buf& b, const std::string& s) {
		addLE(b, s.size(), 4);
		b.insert(b.end(), s.begin(), s.end());
	}

	Buf lid() const {
		const int ntypes = 6;
		const size_t header = 8 + 20 * ntypes + 4; // a few spare bytes
		Buf b;
		addBE(b, header, 4);
		addBE(b, ntypes, 4);
		const size_t sizes[ntypes] = {kPlayerSize, kTournamentSize, kOtherSize,
		                              kOtherSize,  kOtherSize,      kOtherSize};
		const size_t counts[ntypes] = {players.size(), tournaments.size(), 0,
		                               0, 0, 0};
		for (int i = 0; i < ntypes; ++i) {
			addBE(b, sizes[i], 4);
			addBE(b, counts[i], 8);
			addBE(b, uint64_t(-1), 8);
		}
		b.resize(header, 0);
		const size_t n = std::max(players.size(), tournaments.size());
		for (size_t id = 0; id < n; ++id) {
			for (int t = 0; t < ntypes; ++t) {
				Buf rec;
				if (t == 0 && id < players.size()) {
					str(rec, players[id].first);
					str(rec, players[id].second);
				} else if (t == 1 && id < tournaments.size()) {
					str(rec, tournaments[id].place);
					str(rec, tournaments[id].title);
					addLE(rec, uint32_t(tournaments[id].date), 4);
				}
				Buf c;
				addLE(c, rec.size(), 4);
				addBytes(c, rec);
				c.resize(sizes[t], 0);
				addBytes(b, c);
			}
		}
		return b;
	}

	static RecordBytes record(const GameSpec& g, int64_t moves,
	                          int64_t annotations) {
		Buf b(192, 0);
		b[0] = g.byte0;
		b[2] = g.kind;
		putLE(b, 0x08, moves, 8);
		putLE(b, 0x10, annotations, 8);
		putLE(b, 0x18, g.white, 8);
		putLE(b, 0x20, g.black, 8);
		putLE(b, 0x28, g.tournament, 8);
		putLE(b, 0x30, g.annotator, 8);
		putLE(b, 0x38, -1, 8);
		b[0x58] = g.result;
		putLE(b, 0x5a, uint16_t(g.round), 2);
		putLE(b, 0x5c, uint16_t(g.subround), 2);
		putLE(b, 0x60, uint16_t(g.whiteElo), 2);
		putLE(b, 0x70, uint16_t(g.blackElo), 2);
		putLE(b, 0x80, g.eco, 2);
		putLE(b, 0xbc, uint32_t(g.date), 4);
		RecordBytes r;
		std::copy(b.begin(), b.end(), r.begin());
		return r;
	}

	/// Writes the files of database @p stem (a path without extension).
	void write(const std::string& stem, int recordSize = 192,
	           unsigned version = 5, bool withAnnotationFile = true) const {
		Buf cbg(12, 0), cba(12, 0);
		std::vector<RecordBytes> recs;
		for (auto& g : games) {
			const int64_t mo = int64_t(cbg.size());
			addBytes(cbg, g.rawMoves.empty() ? frame(g.movesTag, g.moves, 2)
			                                 : g.rawMoves);
			int64_t ao = -1;
			if (!g.annotations.empty()) {
				ao = int64_t(cba.size());
				addBytes(cba, frame(0x2000, g.annotations));
			}
			recs.push_back(record(g, mo, ao));
		}
		writeFile(stem + ".2cbh", headerFile(recordSize, version, recs));
		writeFile(stem + ".2cbg", cbg);
		if (withAnnotationFile)
			writeFile(stem + ".2cba", cba);
		writeFile(stem + ".2lid", lid());
	}
};

} // namespace cb2test
