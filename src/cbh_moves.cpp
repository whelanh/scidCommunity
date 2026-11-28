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

#include "cbh_moves.h"
#include "cbh_format.h"
#include "cbh_tables.h"
#include "position.h"
#include <algorithm>
#include <utility>

namespace cbh {

namespace {

/// Size of an explicit start position, and of the Chess960 squares and start
/// number that follow it in modes 10 and 11.
constexpr size_t kStartSize = 28;
constexpr size_t kChess960Size = 8;

/// ChessBase counts squares file by file (a1 0, a2 1); here a1 0, b1 1.
constexpr uint8_t fromCbSquare(unsigned cb) {
	return uint8_t(cb % 8 * 8 + cb / 8);
}

cb2::Piece cbPiece(pieceT type) {
	switch (type) {
	case KING:
		return cb2::Piece::King;
	case QUEEN:
		return cb2::Piece::Queen;
	case KNIGHT:
		return cb2::Piece::Knight;
	case BISHOP:
		return cb2::Piece::Bishop;
	case ROOK:
		return cb2::Piece::Rook;
	}
	return cb2::Piece::Pawn;
}

/// The list of a piece kind, or -1 for kings and pawns.
int listOf(cb2::Piece p) {
	switch (p) {
	case cb2::Piece::Queen:
		return 0;
	case cb2::Piece::Rook:
		return 1;
	case cb2::Piece::Bishop:
		return 2;
	case cb2::Piece::Knight:
		return 3;
	default:
		return -1;
	}
}

/// The move word for a move from @p from to @p to in @p pos: what stands on
/// the two squares. Whether it can be played is the importer's check.
cb2::MoveWord moveWord(const Position& pos, unsigned from, unsigned to) {
	cb2::MoveWord m;
	m.kind = cb2::MoveWord::Normal;
	m.black = pos.GetToMove() == BLACK;
	m.from = uint8_t(from);
	m.to = uint8_t(to);
	const pieceT moving = pos.GetPiece(squareT(from));
	m.piece = cbPiece(piece_Type(moving));
	const pieceT target = pos.GetPiece(squareT(to));
	if (target != EMPTY) {
		// A king is never captured: naming nothing makes the check fail.
		if (piece_Color(target) != pos.GetToMove() &&
		    piece_Type(target) != KING)
			m.captured = static_cast<cb2::Captured>(
			    int(cbPiece(piece_Type(target))));
	} else if (m.piece == cb2::Piece::Pawn && from % 8 != to % 8) {
		m.captured = cb2::Captured::EnPassant;
	}
	return m;
}

cb2::MoveWord castling(const Position& pos, bool kingside) {
	cb2::MoveWord m;
	m.kind = cb2::MoveWord::Castle;
	m.black = pos.GetToMove() == BLACK;
	m.piece = cb2::Piece::King;
	m.kingside = kingside;
	return m;
}

cb2::MoveWord nullMove(const Position& pos) {
	cb2::MoveWord m;
	m.kind = cb2::MoveWord::Null;
	m.black = pos.GetToMove() == BLACK;
	return m;
}

/// A move given by its squares: the two-byte move of the compact encoding
/// and every move of the simple one. Castling is the king's move from e1 or
/// e8 to the g or c file; in a Chess960 game it is the king's destination as
/// both squares.
const char* bySquares(const Position& pos, unsigned v, bool chess960,
                      cb2::MoveWord& out) {
	const unsigned from = fromCbSquare(v & 63);
	const unsigned to = fromCbSquare((v >> 6) & 63);
	const unsigned back = pos.GetToMove() == BLACK ? 7 : 0;
	const bool toBack = to / 8 == back;
	if (from == to) {
		if ((v & 0x0fff) == 0)
			out = nullMove(pos);
		else if (chess960 && toBack && (to % 8 == 6 || to % 8 == 2))
			out = castling(pos, to % 8 == 6);
		else
			return "a move from a square to itself";
		return nullptr;
	}
	if (!chess960 && from == back * 8 + 4 && toBack &&
	    (to % 8 == 6 || to % 8 == 2) &&
	    pos.GetPiece(squareT(from)) == piece_Make(pos.GetToMove(), KING)) {
		out = castling(pos, to % 8 == 6);
		return nullptr;
	}
	out = moveWord(pos, from, to);
	if (out.piece == cb2::Piece::Pawn && (to / 8 == 0 || to / 8 == 7)) {
		static constexpr cb2::Piece promotions[] = {
		    cb2::Piece::Queen, cb2::Piece::Rook, cb2::Piece::Bishop,
		    cb2::Piece::Knight};
		out.promotes = true;
		out.promotion = promotions[(v >> 12) & 3];
	}
	return nullptr;
}

/// A one-byte code of the compact encoding other than the markers.
const char* byCode(const Position& pos, const Pieces& pieces, unsigned code,
                   cb2::MoveWord& out) {
	/// Steps of (files, ranks).
	using Step = std::pair<int, int>;
	static constexpr Step kKing[] = {{0, 1},  {1, 1},   {1, 0},  {1, -1},
	                                 {0, -1}, {-1, -1}, {-1, 0}, {-1, 1}};
	static constexpr Step kKnight[] = {{2, 1},   {1, 2},   {-1, 2}, {-2, 1},
	                                   {-2, -1}, {-1, -2}, {1, -2}, {2, -1}};
	// A sliding piece's codes: seven distances in each of its directions,
	// every step wrapping round the board.
	static constexpr Step kQueen[] = {{0, 1}, {1, 0}, {1, 1}, {1, -1}};
	static constexpr Step kRook[] = {{0, 1}, {1, 0}};
	static constexpr Step kBishop[] = {{1, 1}, {1, -1}};
	/// The codes of one numbered piece: from @p first, in list @p list.
	struct Range {
		uint8_t first, last, list, index;
	};
	static constexpr Range kRanges[] = {
	    {11, 38, 0, 0},   {39, 52, 1, 0},   {53, 66, 1, 1},
	    {67, 80, 2, 0},   {81, 94, 2, 1},   {95, 102, 3, 0},
	    {103, 110, 3, 1}, {143, 170, 0, 1}, {171, 198, 0, 2},
	    {199, 212, 1, 2}, {213, 226, 2, 2}, {227, 234, 3, 2}};

	const int side = pos.GetToMove() == BLACK ? 1 : 0;
	auto step = [&](int from, Step d) {
		const unsigned file = unsigned(from % 8 + d.first) & 7;
		const unsigned rank = unsigned(from / 8 + d.second) & 7;
		out = moveWord(pos, unsigned(from), rank * 8 + file);
	};

	if (code == 0) {
		out = nullMove(pos);
	} else if (code <= 8) {
		step(pos.GetKingSquare(), kKing[code - 1]);
	} else if (code <= 10) {
		out = castling(pos, code == 9);
	} else if (code >= 111 && code <= 142) {
		const unsigned n = (code - 111) / 4;
		const int from = pieces.pawn(side, n);
		if (from < 0)
			return "no pawn of that number";
		const int f = side ? -1 : 1;
		const Step how[] = {{0, f}, {0, 2 * f}, {f, f}, {-f, f}};
		step(from, how[(code - 111) % 4]);
		if (out.to / 8 == 0 || out.to / 8 == 7)
			return "a promotion in a one-byte move";
	} else {
		for (const auto& r : kRanges) {
			if (code < r.first || code > r.last)
				continue;
			const int from = pieces.square(side, r.list, r.index);
			if (from < 0)
				return "no piece of that number";
			const unsigned k = code - r.first;
			if (r.list == 3) {
				step(from, kKnight[k]);
				return nullptr;
			}
			const Step* dirs = r.list == 0   ? kQueen
			                   : r.list == 1 ? kRook
			                                 : kBishop;
			const Step d = dirs[k / 7];
			const int distance = int(k % 7) + 1;
			step(from, {d.first * distance, d.second * distance});
			return nullptr;
		}
		return "code is not a move";
	}
	return nullptr;
}

} // namespace

const char* MoveRecord::parse(Bytes record) {
	flags_ = 0;
	start_ = stream_ = {};
	if (record.size() < 4 || be_u24(record, 1) != record.size())
		return "move record size does not match";
	flags_ = record[0];
	size_t at = 4;
	if (flags_ & 0x40) {
		if (record.size() - at < kStartSize)
			return "start position runs past the record";
		start_ = record.subspan(at, kStartSize);
		at += kStartSize;
	}
	if (chess960()) {
		if (start_.empty() || record.size() - at < kChess960Size)
			return "Chess960 game without a start position";
		// shortcut: the king and rook squares these bytes name are not
		// read; castling uses the outermost rook, as cb2::startFen does.
		// Read them if a game with an inner castling rook turns up.
		at += kChess960Size;
	}
	stream_ = record.subspan(at);
	return nullptr;
}

const char* MoveRecord::readStart(cb2::Start& out) const {
	out = {};
	if (start_.empty())
		return nullptr;
	out.kind = cb2::Start::Setup;
	out.setupChess960 = chess960();
	out.blackToMove = start_[1] & 0x10;
	const int ep = start_[1] & 0x0f;
	out.epFile = (ep >= 1 && ep <= 8) ? ep - 1 : -1;
	out.castling = start_[2] & 0x0f;
	out.moveNumber = std::max<unsigned>(start_[3], 1);
	// 24 bytes of bits, per square from a1, file by file: 0 for an empty
	// square, else 1, a colour bit and three bits of piece.
	const auto bits = start_.subspan(4);
	size_t pos = 0;
	bool overrun = false;
	auto bit = [&]() -> unsigned {
		if (pos >= bits.size() * 8) {
			overrun = true;
			return 0;
		}
		const unsigned b = (bits[pos / 8] >> (7 - pos % 8)) & 1;
		++pos;
		return b;
	};
	for (unsigned sq = 0; sq < 64; ++sq) {
		if (!bit())
			continue;
		const bool black = bit();
		unsigned code = bit() << 2;
		code |= bit() << 1;
		code |= bit();
		static constexpr cb2::Piece order[] = {
		    cb2::Piece::King,   cb2::Piece::Queen, cb2::Piece::Knight,
		    cb2::Piece::Bishop, cb2::Piece::Rook,  cb2::Piece::Pawn};
		if (overrun)
			return "start position runs past its board";
		if (code < 1 || code > 6)
			return "bad piece in the start position";
		out.pieces.push_back({fromCbSquare(sq), black, order[code - 1]});
	}
	return nullptr;
}

bool Pieces::scan(const Position& pos) {
	lists_ = {};
	for (auto& side : pawns_)
		side.fill(kNoPawn);
	std::array<unsigned, 2> pawns{};
	for (unsigned cb = 0; cb < 64; ++cb) {
		const auto sq = fromCbSquare(cb);
		const pieceT p = pos.GetPiece(sq);
		if (p == EMPTY)
			continue;
		const int side = piece_Color(p) == BLACK ? 1 : 0;
		const auto type = cbPiece(piece_Type(p));
		if (type == cb2::Piece::Pawn) {
			if (pawns[side] >= 8)
				return false;
			pawns_[side][pawns[side]++] = sq;
		} else if (const int k = listOf(type); k >= 0) {
			auto& l = lists_[side][k];
			if (l.size >= l.square.size())
				return false;
			l.square[l.size++] = sq;
		}
	}
	return true;
}

bool Pieces::update(const cb2::MoveWord& m, const Position& after) {
	if (m.kind == cb2::MoveWord::Null)
		return true;
	const int side = m.black ? 1 : 0;
	if (m.kind == cb2::MoveWord::Castle) {
		// The one rook that left its square stands next to the king now.
		const pieceT rook = piece_Make(m.black ? BLACK : WHITE, ROOK);
		const unsigned to = (m.black ? 56 : 0) + (m.kingside ? 5 : 3);
		auto& l = lists_[side][listOf(cb2::Piece::Rook)];
		for (unsigned i = 0; i < l.size; ++i)
			if (after.GetPiece(l.square[i]) != rook)
				l.square[i] = uint8_t(to);
		return true;
	}

	auto pawnOn = [&](int s, unsigned sq) {
		return std::find(pawns_[s].begin(), pawns_[s].end(), uint8_t(sq));
	};
	if (m.captured != cb2::Captured::Nothing) {
		const int them = 1 - side;
		const bool enPassant = m.captured == cb2::Captured::EnPassant;
		const unsigned at = enPassant ? m.from / 8 * 8 + m.to % 8 : m.to;
		const auto taken =
		    enPassant ? cb2::Piece::Pawn
		              : static_cast<cb2::Piece>(int(m.captured));
		if (taken == cb2::Piece::Pawn) {
			const auto it = pawnOn(them, at);
			if (it == pawns_[them].end())
				return false;
			*it = kNoPawn;
		} else {
			auto& l = lists_[them][listOf(taken)];
			const auto end = l.square.begin() + l.size;
			const auto it = std::find(l.square.begin(), end, uint8_t(at));
			if (it == end)
				return false;
			std::copy(it + 1, end, it);
			--l.size;
		}
	}

	if (m.piece == cb2::Piece::King)
		return true;
	if (m.piece == cb2::Piece::Pawn) {
		const auto it = pawnOn(side, m.from);
		if (it == pawns_[side].end())
			return false;
		if (!m.promotes) {
			*it = m.to;
			return true;
		}
		*it = kNoPawn;
		auto& l = lists_[side][listOf(m.promotion)];
		if (l.size >= l.square.size())
			return false;
		l.square[l.size++] = m.to;
		return true;
	}
	auto& l = lists_[side][listOf(m.piece)];
	const auto end = l.square.begin() + l.size;
	const auto it = std::find(l.square.begin(), end, m.from);
	if (it == end)
		return false;
	*it = m.to;
	return true;
}

const char* MoveStream::open(const MoveRecord& record) {
	mode_ = record.mode();
	switch (mode_) {
	case 0:
		table_ = &kMode0;
		break;
	case 4:
		table_ = &kMode4;
		break;
	case 5:
		table_ = &kMode5;
		break;
	case 10:
		table_ = &kMode10;
		break;
	default:
		return "move encoding mode not supported";
	}
	s_ = record.stream();
	i_ = 0;
	plies_ = 0;
	return nullptr;
}

uint8_t MoveStream::translate(uint8_t byte) const {
	// Mode 0 takes the number of moves off before the table, the others
	// after it.
	if (mode_ == 0)
		return (*table_)[uint8_t(byte - plies_)];
	return uint8_t((*table_)[byte] - plies_);
}

const char* MoveStream::next(const Position& pos, const Pieces& pieces,
                             Token& out) {
	out = {};
	auto word = [&]() {
		const unsigned hi = translate(s_[i_]);
		const unsigned lo = translate(s_[i_ + 1]);
		i_ += 2;
		return (hi << 8) | lo;
	};
	if (mode_ == 5) { // two bytes a move
		if (s_.size() - i_ < 2)
			return "odd length for two-byte moves";
		const unsigned v = word();
		out.branch = v & 0x8000;
		out.endLine = v & 0x4000;
		if (auto why = bySquares(pos, v & 0x3fff, false, out.move))
			return why;
	} else {
		const unsigned code = translate(s_[i_++]);
		switch (code) {
		case 236: // filler
			return nullptr;
		case 254:
			out.branch = true;
			return nullptr;
		case 255:
			out.endLine = true;
			return nullptr;
		case 235:
			if (s_.size() - i_ < 2)
				return "a two-byte move runs past the record";
			if (auto why = bySquares(pos, word(), mode_ == 10, out.move))
				return why;
			break;
		default:
			if (code > 235)
				return "code is not used";
			if (auto why = byCode(pos, pieces, code, out.move))
				return why;
		}
	}
	out.hasMove = true;
	++plies_;
	return nullptr;
}

} // namespace cbh
