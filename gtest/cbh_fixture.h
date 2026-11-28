/*
 * Copyright (C) 2026 Tommaso Bergamasco
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * This file is part of scidCommunity.
 */

/** @file
 * Builds small classic CBH databases byte by byte for the tests: no real
 * database, and nothing derived from one, is ever needed.
 */

#pragma once

#include "cb2_fixture.h"
#include "cbh_tables.h"

namespace cbhtest {

using cb2test::addBE;
using cb2test::addBytes;
using cb2test::addLE;
using cb2test::Buf;
using cb2test::putBE;
using cb2test::putLE;
using cb2test::TempDir;
using cb2test::writeFile;

/// The square named @p s as the two-byte moves count it: a1 0, a2 1.
inline unsigned sq(const char* s) {
	return unsigned((s[0] - 'a') * 8 + (s[1] - '1'));
}
/// A two-byte move; @p promotion is 0 queen, 1 rook, 2 bishop, 3 knight.
inline uint16_t word(const char* from, const char* to, unsigned promotion = 0) {
	return uint16_t(sq(from) | sq(to) << 6 | promotion << 12);
}

/// @name The values of a move stream, before encryption.
///@{
constexpr int kTwoByte = 235, kFiller = 236, kBranch = 254, kEnd = 255;
///@}

/// The byte that stands for value @p v after @p plies moves.
inline uint8_t encrypt(unsigned mode, uint8_t v, unsigned plies) {
	const auto& t = mode == 0   ? cbh::kMode0
	                : mode == 4 ? cbh::kMode4
	                : mode == 5 ? cbh::kMode5
	                            : cbh::kMode10;
	const auto inverse = [&](uint8_t x) {
		return uint8_t(std::find(t.begin(), t.end(), x) - t.begin());
	};
	return mode == 0 ? uint8_t(inverse(v) + plies)
	                 : inverse(uint8_t(v + plies));
}

/// A compact stream (modes 0, 4 and 10): codes and markers; kTwoByte is
/// followed by its move word().
inline Buf compact(const std::vector<int>& values, unsigned mode = 0) {
	Buf b;
	unsigned plies = 0;
	for (size_t i = 0; i < values.size(); ++i) {
		const int v = values[i];
		b.push_back(encrypt(mode, uint8_t(v), plies));
		if (v == kTwoByte) {
			const int w = values[++i];
			b.push_back(encrypt(mode, uint8_t(w >> 8), plies));
			b.push_back(encrypt(mode, uint8_t(w & 0xff), plies));
		}
		if (v <= kTwoByte)
			++plies;
	}
	return b;
}

/// A mode 5 stream: two bytes a move, 0x8000 starting a variation and 0x4000
/// ending a line.
inline Buf simple(const std::vector<int>& words) {
	Buf b;
	unsigned plies = 0;
	for (const int w : words) {
		b.push_back(encrypt(5, uint8_t(w >> 8), plies));
		b.push_back(encrypt(5, uint8_t(w & 0xff), plies));
		++plies;
	}
	return b;
}

/// A piece of a set-up position: its square, colour and code (1 king,
/// 2 queen, 3 knight, 4 bishop, 5 rook, 6 pawn).
struct Placed {
	const char* square;
	bool black;
	unsigned code;
};

/// The 28 bytes of an explicit start position.
inline Buf startPosition(const std::vector<Placed>& pieces, bool blackToMove,
                         unsigned castling, unsigned moveNumber,
                         unsigned epFile = 0) {
	Buf b = {1, uint8_t((blackToMove ? 0x10 : 0) | epFile), uint8_t(castling),
	         uint8_t(moveNumber)};
	Buf bits(24, 0);
	size_t at = 0;
	auto put = [&](unsigned v, int n) {
		for (int i = n - 1; i >= 0; --i, ++at)
			if ((v >> i) & 1)
				bits[at / 8] |= uint8_t(0x80 >> (at % 8));
	};
	for (unsigned s = 0; s < 64; ++s) {
		const Placed* found = nullptr;
		for (auto& p : pieces)
			if (sq(p.square) == s)
				found = &p;
		if (!found) {
			put(0, 1);
			continue;
		}
		put(1, 1);
		put(found->black, 1);
		put(found->code, 3);
	}
	addBytes(b, bits);
	return b;
}

/// A whole `.cbg` record. Modes 10 and 11 carry the Chess960 bytes.
inline Buf moveRecord(const Buf& stream, unsigned mode = 0,
                      const Buf& start = {}) {
	Buf body = start;
	if (mode == 10 || mode == 11)
		addBytes(body, Buf(8, 0));
	addBytes(body, stream);
	Buf r = {uint8_t(mode | (start.empty() ? 0 : 0x40))};
	addBE(r, body.size() + 4, 3);
	addBytes(r, body);
	return r;
}

/// @name Annotations: position, type, size, data.
///@{
inline Buf annotation(int32_t position, uint8_t type, const Buf& data) {
	Buf b;
	addBE(b, uint32_t(position) & 0xffffff, 3);
	b.push_back(type);
	addBE(b, data.size() + 6, 2);
	addBytes(b, data);
	return b;
}
inline Buf text(int32_t position, const std::string& s, uint8_t nation = 0,
                bool before = false) {
	Buf d = {0, nation};
	d.insert(d.end(), s.begin(), s.end());
	return annotation(position, before ? 0x82 : 0x02, d);
}
///@}

/// A game (or another record) of a fixture database.
struct GameSpec {
	uint8_t byte0 = 0x01; ///< 0x80 deleted, 0x03 text, 0 unused
	uint32_t white = 0xffffff, black = 0xffffff, tournament = 0xffffff,
	         annotator = 0xffffff;
	uint8_t result = 2, round = 0, subround = 0;
	uint16_t whiteElo = 0, blackElo = 0, eco = 0;
	uint32_t date = 0;
	Buf moves = moveRecord(compact({kEnd}));
	/// annotation()s; none for a game without annotations.
	std::vector<Buf> annotations;
};

/// Writes a small classic database: `.cbh`, `.cbg`, `.cba` and the entity
/// files.
struct Builder {
	std::vector<std::pair<std::string, std::string>> players;
	std::vector<std::string> annotators;
	struct T {
		std::string title, place;
		uint32_t date;
	};
	std::vector<T> tournaments;
	std::vector<GameSpec> games;

	/// An entity file with @p records of @p size data bytes.
	static Buf entityFile(const std::vector<Buf>& records, size_t size) {
		Buf b(32, 0);
		putLE(b, 0x00, records.size(), 4);
		putLE(b, 0x08, 1234567890, 4);
		putLE(b, 0x0c, size, 4);
		putLE(b, 0x18, 4, 4); // four more header bytes
		for (auto data : records) {
			data.resize(size, 0);
			addBytes(b, Buf(9, 0));
			addBytes(b, data);
		}
		return b;
	}

	/// A zero-padded text field of @p width bytes, cut when longer.
	static void field(Buf& b, const std::string& s, size_t width) {
		Buf f(s.begin(), s.end());
		f.resize(width, 0);
		addBytes(b, f);
	}

	/// Writes the files of database @p stem (a path without extension).
	void write(const std::string& stem) const {
		Buf cbh(46, 0), cbg(26, 0), cba(26, 0);
		putBE(cbh, 0x03, 46, 2);
		cbh.resize(46);
		for (size_t i = 0; i < games.size(); ++i) {
			const auto& g = games[i];
			Buf r(46, 0);
			r[0] = g.byte0;
			putBE(r, 0x01, cbg.size(), 4);
			addBytes(cbg, g.moves);
			if (!g.annotations.empty()) {
				putBE(r, 0x05, cba.size(), 4);
				Buf items;
				for (auto& a : g.annotations)
					addBytes(items, a);
				addBE(cba, i + 1, 3);
				addBytes(cba, {1, 0, 0x0e, 0x0e});
				addBE(cba, g.annotations.size() + 1, 3);
				addBE(cba, items.size() + 14, 4);
				addBytes(cba, items);
			}
			putBE(r, 0x09, g.white, 3);
			putBE(r, 0x0c, g.black, 3);
			putBE(r, 0x0f, g.tournament, 3);
			putBE(r, 0x12, g.annotator, 3);
			putBE(r, 0x18, g.date, 3);
			r[0x1b] = g.result;
			r[0x1d] = g.round;
			r[0x1e] = g.subround;
			putBE(r, 0x1f, g.whiteElo, 2);
			putBE(r, 0x21, g.blackElo, 2);
			putBE(r, 0x23, g.eco, 2);
			addBytes(cbh, r);
		}
		std::vector<Buf> p, t, c;
		for (auto& [last, first] : players) {
			p.emplace_back();
			field(p.back(), last, 30);
			field(p.back(), first, 20);
		}
		for (auto& x : tournaments) {
			t.emplace_back();
			field(t.back(), x.title, 40);
			field(t.back(), x.place, 30);
			putLE(t.back(), 0x46, x.date, 4);
		}
		for (auto& name : annotators) {
			c.emplace_back();
			field(c.back(), name, 45);
		}
		writeFile(stem + ".cbh", cbh);
		writeFile(stem + ".cbg", cbg);
		writeFile(stem + ".cba", cba);
		writeFile(stem + ".cbp", entityFile(p, 58));
		writeFile(stem + ".cbt", entityFile(t, 90));
		writeFile(stem + ".cbc", entityFile(c, 53));
	}
};

} // namespace cbhtest
