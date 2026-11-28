/*
 * Copyright (C) 2026 Tommaso Bergamasco
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * CBH layout derived from oschess-cb-bridge v1.0.3 (MIT), commit bffebfc4.
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
 * The move record of a classic CBH game (`.cbg`): its start and its move
 * stream.
 *
 * Every byte of the stream is translated through the table of the game's
 * encoding mode, keyed by the number of moves decoded so far. The compact
 * encoding then names a move by piece and movement ("the second rook, three
 * squares up"), so it can only be decoded along the game: with the position
 * and the numbered lists of its pieces. Moves are given as cb2::MoveWord,
 * which the importer checks against the position as it does for 2CBH.
 */

#pragma once

#include "cb2_moves.h"
#include "common.h"
#include <array>

class Position;

namespace cbh {

using cb2::Bytes;

/// A move record split into its parts.
class MoveRecord {
	uint8_t flags_ = 0;
	Bytes start_;  ///< 28 bytes, empty for the standard start.
	Bytes stream_;

public:
	/// Splits a whole `.cbg` record, its 4-byte head included. Returns
	/// nullptr or what is wrong.
	const char* parse(Bytes record);

	unsigned mode() const { return flags_ & 0x3f; }
	/// Modes 10 and 11 are the Chess960 ones.
	bool chess960() const { return mode() == 10 || mode() == 11; }

	/// Reads the start position. Returns nullptr or what is wrong.
	const char* readStart(cb2::Start& out) const;

	Bytes stream() const { return stream_; }
};

/// Queens, rooks, bishops and knights of both sides in the order the compact
/// encoding numbers them, and the pawns by their fixed numbers. Pieces are
/// numbered as a scan of the start position meets them (a1, a2 ... h8); when
/// one other than a pawn is captured the ones above it move down.
class Pieces {
public:
	struct List {
		std::array<uint8_t, 10> square{};
		uint8_t size = 0;
	};
	static constexpr uint8_t kNoPawn = 0xff;

	/// False when a side has more pieces than the encoding can number.
	bool scan(const Position& pos);

	/// Follows move @p m, which gave position @p after. False when the lists
	/// do not match the move.
	bool update(const cb2::MoveWord& m, const Position& after);

	/// The square of piece @p index of a side's list @p kind (0 queens,
	/// 1 rooks, 2 bishops, 3 knights); -1 when there is none.
	int square(int side, int kind, unsigned index) const {
		const auto& l = lists_[side][kind];
		return index < l.size ? l.square[index] : -1;
	}
	/// The square of a side's pawn @p index, 0-7; -1 when there is none.
	int pawn(int side, unsigned index) const {
		return pawns_[side][index] == kNoPawn ? -1 : pawns_[side][index];
	}

private:
	std::array<std::array<List, 4>, 2> lists_{};
	std::array<std::array<uint8_t, 8>, 2> pawns_{};
};

/// What the next bytes of a stream say. In the compact encoding each token
/// is a branch, a move or an end of line; in the two-byte encoding a move
/// carries its branch and end of line.
struct Token {
	/// A variation starts: the position before the next move is needed again.
	bool branch = false;
	bool hasMove = false;
	bool endLine = false;
	cb2::MoveWord move;
};

/// Reads a move stream token by token.
class MoveStream {
	const std::array<uint8_t, 256>* table_ = nullptr;
	Bytes s_;
	size_t i_ = 0;
	unsigned plies_ = 0;
	unsigned mode_ = 0;

	uint8_t translate(uint8_t byte) const;

public:
	/// Returns nullptr, or why the record's encoding mode cannot be read.
	const char* open(const MoveRecord& record);

	bool atEnd() const { return i_ >= s_.size(); }

	/// Reads the next token, whose move is for position @p pos with piece
	/// lists @p pieces. Not to be called at the end. Returns nullptr or what
	/// is wrong.
	const char* next(const Position& pos, const Pieces& pieces, Token& out);
};

} // namespace cbh
