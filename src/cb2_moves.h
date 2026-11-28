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
 * The move record of a 2CBH game: its start (standard, Chess960 or set-up)
 * and its move tree as 16-bit words.
 *
 * A move word below 0xb12d names one move from an enumeration of every move
 * each piece can make on an empty board: the side, the piece, both squares,
 * what stands on the destination and the promotion. A word therefore means
 * the same in any position and can be checked against the board it is
 * played on.
 */

#pragma once

#include "cb2_format.h"
#include <string>
#include <vector>

namespace cb2 {

enum class Piece : uint8_t { King, Queen, Knight, Bishop, Rook, Pawn };

/// What a move word says stands on the destination square.
enum class Captured : uint8_t {
	Nothing,
	Queen,
	Knight,
	Bishop,
	Rook,
	Pawn,
	EnPassant
};

/// A decoded move word. Squares count the usual way: a1 = 0, b1 = 1 ...
/// h8 = 63 (ChessBase counts file by file; the conversion is done here).
struct MoveWord {
	enum Kind : uint8_t { Invalid, Normal, Castle, Null };
	Kind kind = Invalid;
	bool black = false;
	Piece piece = Piece::King;
	uint8_t from = 0;
	uint8_t to = 0;
	Captured captured = Captured::Nothing;
	bool promotes = false;
	Piece promotion = Piece::Queen;
	bool kingside = false; ///< Castling only.
};

/// @name Marker words of a move record.
///@{
constexpr uint16_t kNullMove = 0xfffa;
constexpr uint16_t kStartPosition = 0xfffb;
constexpr uint16_t kMoves = 0xfffc;
constexpr uint16_t kAlternative = 0xfffd;
/// A marker of unknown meaning that ChessBase writes between moves. It is
/// not a move and takes no annotation position: in the 18 games of real
/// databases that hold it, the last comment falls on the last move only when
/// it is skipped.
constexpr uint16_t kSkipped = 0xfffe;
constexpr uint16_t kEndOfLine = 0xffff;
///@}

/// Decodes a move word; markers other than the null move, set-up piece words
/// and unused words give MoveWord::Invalid.
MoveWord decodeMove(uint16_t word);

/// A piece of a set-up position.
struct SetupPiece {
	uint8_t square; ///< a1 = 0 ... h8 = 63
	bool black;
	Piece piece;
};

/// Decodes a set-up piece word (0xc02d to 0xc30c).
bool decodePieceWord(uint16_t word, SetupPiece& out);

/// Where a game starts.
struct Start {
	enum Kind { Standard, Chess960, Setup };
	Kind kind = Standard;
	/// Chess960: the start position, 0-959.
	unsigned chess960 = 0;
	/// @name Setup only.
	///@{
	bool setupChess960 = false;
	unsigned moveNumber = 1;
	bool blackToMove = false;
	/// 1 white O-O-O, 2 white O-O, 4 black O-O-O, 8 black O-O.
	unsigned castling = 0;
	int epFile = -1; ///< 0-7 when the record names one.
	std::vector<SetupPiece> pieces;
	///@}
};

/// The FEN of a start, empty for the standard position. A castling right is
/// kept only where the king and a rook stand as it needs them, and an en
/// passant file only when a pawn can just have made the double step. Chess960
/// rights are written as rook files (Shredder-FEN), which Scid reads.
std::string startFen(const Start& s);

/// A move record split into its start section and its move tree.
class MoveRecord {
	uint16_t tag_ = 0;
	Bytes start_; ///< The words between the start and moves markers.
	Bytes tree_;

public:
	/// Splits the content of a move frame. Returns nullptr or what is wrong.
	const char* parse(uint16_t tag, Bytes content);

	/// The variant, from the frame tag: 1 normal chess, 2 Chess960.
	bool chess960() const { return (tag_ & 0xff) == 2; }

	/// Reads the start section. Returns nullptr or what is wrong.
	const char* readStart(Start& out) const;

	size_t size() const { return tree_.size() / 2; }
	uint16_t word(size_t i) const { return le_u16(tree_, 2 * i); }
};

} // namespace cb2
