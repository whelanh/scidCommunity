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

#include "cb2_moves.h"
#include <algorithm>
#include <array>

namespace cb2 {

namespace {

constexpr uint16_t kFirstCastle = 0xb129;
constexpr uint16_t kFirstCastle960 = 0xb12d;
constexpr uint16_t kFirstPieceWord = 0xc02d;
constexpr uint16_t kLastPieceWord = 0xc30c;

/// ChessBase squares count file by file (a1 = 0, a2 = 1).
uint8_t fromCbSquare(unsigned cb) {
	return static_cast<uint8_t>((cb % 8) * 8 + cb / 8);
}

struct Dir {
	int8_t df, dr;
};
constexpr Dir kKingDirs[] = {{-1, -1}, {-1, 0}, {-1, 1}, {0, -1},
                             {0, 1},   {1, -1}, {1, 0},  {1, 1}};
constexpr Dir kKnightDirs[] = {{-2, -1}, {-2, 1}, {2, -1}, {2, 1},
                               {-1, -2}, {-1, 2}, {1, -2}, {1, 2}};
constexpr Dir kBishopDirs[] = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}};
constexpr Dir kRookDirs[] = {{-1, 0}, {0, -1}, {1, 0}, {0, 1}};
constexpr Dir kQueenDirs[] = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1},
                              {-1, 0},  {0, -1}, {1, 0}, {0, 1}};

constexpr Captured kCaptureOrder[] = {Captured::Nothing, Captured::Queen,
                                      Captured::Knight,  Captured::Bishop,
                                      Captured::Rook,    Captured::Pawn};
constexpr Piece kPromotionOrder[] = {Piece::Queen, Piece::Knight,
                                     Piece::Bishop, Piece::Rook};
constexpr Captured kPromotionCaptures[] = {Captured::Queen, Captured::Knight,
                                           Captured::Bishop, Captured::Rook};

uint8_t sq(int file, int rank) { return static_cast<uint8_t>(rank * 8 + file); }

/// The enumeration of the move words below the castling words, rebuilt from
/// its generating rules: for each side, the pieces king, queen, knight,
/// bishop, rook, each from every ChessBase square in order, along each
/// direction, nearest square first, each destination once per thing that
/// may stand on it; then the pawns of each side, file by file.
std::vector<MoveWord> buildTable() {
	std::vector<MoveWord> t;
	t.reserve(kFirstCastle960);
	t.emplace_back(); // word 0 is unused
	auto normal = [&](bool black, Piece p, uint8_t from, uint8_t to,
	                  Captured c, bool promotes = false,
	                  Piece promo = Piece::Queen) {
		MoveWord m;
		m.kind = MoveWord::Normal;
		m.black = black;
		m.piece = p;
		m.from = from;
		m.to = to;
		m.captured = c;
		m.promotes = promotes;
		m.promotion = promo;
		t.push_back(m);
	};
	struct PieceDirs {
		Piece piece;
		const Dir* dirs;
		size_t n;
		bool slides;
	};
	const PieceDirs pieces[] = {
	    {Piece::King, kKingDirs, std::size(kKingDirs), false},
	    {Piece::Queen, kQueenDirs, std::size(kQueenDirs), true},
	    {Piece::Knight, kKnightDirs, std::size(kKnightDirs), false},
	    {Piece::Bishop, kBishopDirs, std::size(kBishopDirs), true},
	    {Piece::Rook, kRookDirs, std::size(kRookDirs), true}};
	for (bool black : {false, true}) {
		for (const auto& pd : pieces) {
			for (int cb = 0; cb < 64; ++cb) {
				const int f = cb / 8, r = cb % 8;
				for (size_t d = 0; d < pd.n; ++d) {
					for (int step = 1;; ++step) {
						const int nf = f + pd.dirs[d].df * step;
						const int nr = r + pd.dirs[d].dr * step;
						if (nf < 0 || nf > 7 || nr < 0 || nr > 7)
							break;
						for (auto c : kCaptureOrder)
							normal(black, pd.piece, sq(f, r), sq(nf, nr), c);
						if (!pd.slides)
							break;
					}
				}
			}
		}
	}
	for (bool black : {false, true}) {
		// Direction, start rank, rank before promotion, en passant rank
		// (ranks counted from 1).
		const int d = black ? -1 : 1;
		const int start = black ? 7 : 2, pre = black ? 2 : 7,
		          ep = black ? 4 : 5;
		for (int f = 0; f < 8; ++f) {
			for (int rank = 2; rank <= 7; ++rank) {
				const int r = rank - 1;
				const auto from = sq(f, r);
				if (rank == start) {
					normal(black, Piece::Pawn, from, sq(f, r + 2 * d),
					       Captured::Nothing);
					normal(black, Piece::Pawn, from, sq(f, r + d),
					       Captured::Nothing);
				} else if (rank == pre) {
					for (auto p : kPromotionOrder)
						normal(black, Piece::Pawn, from, sq(f, r + d),
						       Captured::Nothing, true, p);
				} else {
					normal(black, Piece::Pawn, from, sq(f, r + d),
					       Captured::Nothing);
				}
				for (int df : {-1, 1}) {
					const int nf = f + df;
					if (nf < 0 || nf > 7)
						continue;
					const auto to = sq(nf, r + d);
					if (rank == pre) {
						// The captured piece first, then the promotion.
						for (auto c : kPromotionCaptures)
							for (auto p : kPromotionOrder)
								normal(black, Piece::Pawn, from, to, c, true, p);
					} else {
						for (size_t c = 1; c < std::size(kCaptureOrder); ++c)
							normal(black, Piece::Pawn, from, to,
							       kCaptureOrder[c]);
						if (rank == ep)
							normal(black, Piece::Pawn, from, to,
							       Captured::EnPassant);
					}
				}
			}
		}
	}
	// White O-O-O, white O-O, black O-O-O, black O-O.
	for (int i = 0; i < 4; ++i) {
		MoveWord m;
		m.kind = MoveWord::Castle;
		m.black = i >= 2;
		m.piece = Piece::King;
		m.kingside = i % 2 == 1;
		t.push_back(m);
	}
	return t;
}

const std::vector<MoveWord>& table() {
	static const std::vector<MoveWord> t = buildTable();
	return t;
}

} // namespace

MoveWord decodeMove(uint16_t word) {
	if (word == kNullMove) {
		MoveWord m;
		m.kind = MoveWord::Null;
		return m;
	}
	if (word == 0 || word >= kFirstPieceWord)
		return {};
	const auto& t = table();
	if (word < t.size())
		return t[word];
	// Castling in a Chess960 game: four words per start position, which the
	// game's start already gives, so only the side and the wing are kept.
	const unsigned n = word - kFirstCastle960;
	MoveWord m;
	m.kind = MoveWord::Castle;
	m.piece = Piece::King;
	m.black = (n % 4) >= 2;
	m.kingside = (n % 2) == 1;
	return m;
}

bool decodePieceWord(uint16_t word, SetupPiece& out) {
	constexpr uint16_t whitePieces = kFirstPieceWord;
	constexpr uint16_t blackPieces = whitePieces + 5 * 64;
	constexpr uint16_t whitePawns = blackPieces + 5 * 64;
	constexpr uint16_t blackPawns = whitePawns + 48;
	static_assert(blackPawns + 48 - 1 == kLastPieceWord);
	constexpr Piece order[] = {Piece::King, Piece::Queen, Piece::Knight,
	                           Piece::Bishop, Piece::Rook};
	if (word < whitePieces || word > kLastPieceWord)
		return false;
	if (word < whitePawns) {
		out.black = word >= blackPieces;
		const unsigned i = word - (out.black ? blackPieces : whitePieces);
		out.piece = order[i / 64];
		out.square = fromCbSquare(i % 64);
	} else {
		out.black = word >= blackPawns;
		const unsigned i = word - (out.black ? blackPawns : whitePawns);
		out.piece = Piece::Pawn;
		out.square = fromCbSquare((i / 6) * 8 + i % 6 + 1);
	}
	return true;
}

const char* MoveRecord::parse(uint16_t tag, Bytes content) {
	tag_ = tag;
	start_ = tree_ = {};
	if (content.size() % 2)
		return "odd move record length";
	const size_t n = content.size() / 2;
	if (n == 0)
		return "empty move record";
	size_t i = 0;
	if (le_u16(content, 0) == kStartPosition) {
		i = 1;
		while (i < n && le_u16(content, 2 * i) != kMoves)
			++i;
	}
	if (i >= n || le_u16(content, 2 * i) != kMoves)
		return "no move section";
	if (i > 0)
		start_ = content.subspan(2, 2 * (i - 1));
	tree_ = content.subspan(2 * (i + 1));
	return nullptr;
}

const char* MoveRecord::readStart(Start& out) const {
	out = {};
	if (start_.empty())
		return nullptr; // also a Chess960 game from the standard position
	const size_t n = start_.size() / 2;
	auto w = [&](size_t i) { return le_u16(start_, 2 * i); };
	if (chess960() && n == 1) {
		if (w(0) >= 960)
			return "Chess960 start position out of range";
		out.kind = Start::Chess960;
		out.chess960 = w(0);
		return nullptr;
	}
	size_t s = 0;
	out.setupChess960 = chess960();
	if (chess960() && w(0) == 1000)
		s = 1;
	if (n - s < 3)
		return "short set-up section";
	out.kind = Start::Setup;
	// The move number; the side to move in the low byte and the castling
	// rights in the high byte; the en passant file 1-8, when there is one.
	out.moveNumber = std::max<unsigned>(w(s), 1);
	out.blackToMove = (w(s + 1) & 0xff) != 0;
	out.castling = (w(s + 1) >> 8) & 0x0f;
	const auto ep = w(s + 2);
	out.epFile = (ep >= 1 && ep <= 8) ? int(ep) - 1 : -1;
	for (size_t i = s + 3; i < n; ++i) {
		SetupPiece p;
		if (!decodePieceWord(w(i), p))
			return "bad set-up piece word";
		out.pieces.push_back(p);
	}
	return nullptr;
}

namespace {

char pieceChar(Piece p, bool black) {
	static const char white[] = "KQNBRP";
	const char c = white[static_cast<int>(p)];
	return black ? char(c - 'A' + 'a') : c;
}

/// The back rank of Chess960 start position @p n (Scharnagl's numbering;
/// 518 is the standard position).
std::array<Piece, 8> chess960Rank(unsigned n) {
	std::array<Piece, 8> r;
	std::array<bool, 8> used{};
	auto place = [&](int file, Piece p) {
		r[file] = p;
		used[file] = true;
	};
	place(2 * int(n % 4) + 1, Piece::Bishop);
	n /= 4;
	place(2 * int(n % 4), Piece::Bishop);
	n /= 4;
	auto nthFree = [&](unsigned k) {
		for (int f = 0; f < 8; ++f)
			if (!used[f] && k-- == 0)
				return f;
		return -1;
	};
	place(nthFree(n % 6), Piece::Queen);
	n /= 6;
	static const uint8_t knights[10][2] = {{0, 1}, {0, 2}, {0, 3}, {0, 4},
	                                       {1, 2}, {1, 3}, {1, 4}, {2, 3},
	                                       {2, 4}, {3, 4}};
	const int k1 = nthFree(knights[n][0]);
	const int k2 = nthFree(knights[n][1]);
	place(k1, Piece::Knight);
	place(k2, Piece::Knight);
	place(nthFree(0), Piece::Rook);
	place(nthFree(0), Piece::King);
	place(nthFree(0), Piece::Rook);
	return r;
}

std::string boardFen(const std::array<char, 64>& board) {
	std::string fen;
	for (int rank = 7; rank >= 0; --rank) {
		int empty = 0;
		for (int file = 0; file < 8; ++file) {
			const char c = board[rank * 8 + file];
			if (c == 0) {
				++empty;
				continue;
			}
			if (empty)
				fen += char('0' + empty);
			empty = 0;
			fen += c;
		}
		if (empty)
			fen += char('0' + empty);
		if (rank)
			fen += '/';
	}
	return fen;
}

} // namespace

std::string startFen(const Start& s) {
	std::array<char, 64> board{};
	std::string castling;
	std::string ep = "-";
	bool black = false;
	unsigned moveNumber = 1;
	if (s.kind == Start::Standard)
		return {};
	if (s.kind == Start::Chess960) {
		const auto rank = chess960Rank(s.chess960 % 960);
		for (int f = 0; f < 8; ++f) {
			board[f] = pieceChar(rank[f], false);
			board[8 + f] = 'P';
			board[48 + f] = 'p';
			board[56 + f] = pieceChar(rank[f], true);
		}
		std::string rooksW, rooksB;
		for (int f = 7; f >= 0; --f) {
			if (rank[f] == Piece::Rook) {
				rooksW += char('A' + f);
				rooksB += char('a' + f);
			}
		}
		castling = rooksW + rooksB;
	} else {
		for (auto& p : s.pieces)
			board[p.square] = pieceChar(p.piece, p.black);
		black = s.blackToMove;
		moveNumber = s.moveNumber;
		for (int side = 0; side < 2; ++side) {
			const int back = side ? 56 : 0;
			const char king = side ? 'k' : 'K', rook = side ? 'r' : 'R';
			int kf = -1;
			for (int f = 0; f < 8; ++f)
				if (board[back + f] == king)
					kf = f;
			if (kf < 0)
				continue;
			const bool oo = s.castling & (side ? 8 : 2);
			const bool ooo = s.castling & (side ? 4 : 1);
			auto letter = [&](int f) {
				return char((side ? 'a' : 'A') + f);
			};
			if (s.setupChess960) {
				// The outermost rook on each wing of the king.
				if (oo) {
					for (int f = 7; f > kf; --f)
						if (board[back + f] == rook) {
							castling += letter(f);
							break;
						}
				}
				if (ooo) {
					for (int f = 0; f < kf; ++f)
						if (board[back + f] == rook) {
							castling += letter(f);
							break;
						}
				}
			} else if (kf == 4) {
				if (oo && board[back + 7] == rook)
					castling += side ? 'k' : 'K';
				if (ooo && board[back] == rook)
					castling += side ? 'q' : 'Q';
			}
		}
		if (s.epFile >= 0) {
			// Black to move: a white pawn on the 4th rank just advanced
			// from the 2nd. White to move: a black pawn on the 5th.
			const int f = s.epFile;
			const char pawn = black ? 'P' : 'p';
			const int on = black ? 24 + f : 32 + f;
			const int over = black ? 16 + f : 40 + f;
			const int from = black ? 8 + f : 48 + f;
			if (board[on] == pawn && board[over] == 0 && board[from] == 0) {
				ep = char('a' + f);
				ep += black ? '3' : '6';
			}
		}
	}
	if (castling.empty())
		castling = "-";
	return boardFen(board) + (black ? " b " : " w ") + castling + ' ' + ep +
	       " 0 " + std::to_string(moveNumber);
}

} // namespace cb2
