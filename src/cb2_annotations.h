/*
 * Copyright (C) 2026 Tommaso Bergamasco
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * 2CBH layout derived from oschess-cb-bridge v1.0.3 (MIT), commit bffebfc4.
 * See docs/third-party-notices.md.
 *
 * This file is part of scidCommunity.
 *
 * scidCommunity is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 2 of the License, or (at your option)
 * any later version.
 */

/** @file
 * The annotation record of a 2CBH game (`.2cba`): blocks of annotations by
 * position, each a type and its data.
 *
 * An annotation has no length field, so every type met must be understood to
 * find the next one: a type of unknown layout ends the decoding, and what
 * was decoded before it is kept.
 */

#pragma once

#include "cb2_format.h"
#include <array>
#include <string>
#include <vector>

namespace cb2 {

/// The tag of an annotation record's frame.
constexpr uint16_t kAnnotationTag = 0x2000;
/// The position of the annotations of the game as a whole.
constexpr int32_t kGamePosition = -1;

/// ChessBase's language numbers in a text annotation.
namespace language {
constexpr uint16_t English = 0, German = 1, French = 2, Spanish = 3,
                   Italian = 4, Dutch = 5, Portuguese = 6, Any = 7,
                   Polish = 12, Greek = 18;
}

struct Annotation {
	enum Kind { Text, Symbols, Squares, Arrows, Quotation, Other };
	Kind kind = Other;
	uint16_t type = 0;
	/// Text: shown before the move (type 0x82) or after it (0x02).
	bool before = false;
	uint16_t language = 0;
	/// Text: the text. Quotation: the quoted game as ChessBase writes it in
	/// its own PGN, e.g. "1-0 Last,F (2500)-Last,F (2480) Event Site 1990
	/// (3)".
	std::string text;
	/// Symbols: the NAGs on the move, on the position, and the prefix; 0
	/// for none.
	std::array<uint8_t, 3> nags{};
	/// Squares: (colour, square, 0); arrows: (colour, from, to). Colours are
	/// ChessBase's (2 green, 3 yellow, 4 red; others occur), squares count
	/// a1 = 0, b1 = 1 ... h8 = 63.
	std::vector<std::array<uint8_t, 3>> marks;
	/// Other: the data after the type, as stored.
	Bytes data;
};

struct AnnotationBlock {
	/// -1 for the game, else a move counted from 0 in PGN order: the order
	/// a PGN lists the moves, each variation right after the move it
	/// replaces.
	int32_t position = kGamePosition;
	std::vector<Annotation> items;
};

struct GameAnnotations {
	std::vector<AnnotationBlock> blocks;
	/// Set when positions count the moves in the order a classic CBH game
	/// stores them: depth first, each line before its alternatives.
	bool storedOrder = false;
	/// Set when decoding stopped before the end: why, and the type of
	/// unknown layout that stopped it (0 for damage).
	const char* stopped = nullptr;
	uint16_t stoppedType = 0;
};

/// Decodes the content of an annotation frame into @p out. Whatever can be
/// decoded is kept; GameAnnotations::stopped says why the rest could not.
void parseAnnotations(Bytes content, GameAnnotations& out);

/// The value ChessBase's own PGN writes in `[%evp]` for each entry of an
/// evaluation profile (type 0x26: `01`, an int length, a short count, then
/// per entry a short value, a depth byte and a flag byte): centipawns as they
/// are, a mate in n plies as 30000 - n (negated when Black mates), 32767 for
/// none. Empty when the data has another layout.
std::vector<int> evaluationProfile(Bytes data);

} // namespace cb2
