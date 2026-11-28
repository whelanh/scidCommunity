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

#include "codec_cb2.h"
#include "date.h"
#include "game.h"
#include "indexentry.h"
#include "misc.h"
#include "movelist.h"
#include <algorithm>

namespace {

/// A ChessBase date (year << 9 | month << 5 | day, 0 for an unknown part) as
/// a Scid date; a part out of Scid's range reads as unknown.
dateT scidDate(int32_t cb) {
	const uint32_t day = cb & 31;
	uint32_t month = (cb >> 5) & 15;
	uint32_t year = (cb >> 9) & 0xfff;
	if (year > YEAR_MAX)
		return ZERO_DATE;
	if (month > 12)
		month = 0;
	return DATE_MAKE(year, month, day);
}

resultT scidResult(unsigned cb) {
	switch (cb) {
	case 0: // black won
	case 4: // black won by forfeit
		return RESULT_Black;
	case 1:
	case 5:
		return RESULT_Draw;
	case 2:
	case 6:
		return RESULT_White;
	}
	return RESULT_None; // a line, both players lost, or unknown
}

eloT scidElo(int16_t cb) { return (cb > 0 && cb <= MAX_ELO) ? eloT(cb) : 0; }

/// The basic opening code of an ECO field (128 to 64127), else none.
ecoT scidEco(uint16_t cb) {
	if (cb < 128 || cb > 64127)
		return ECO_None;
	const unsigned code = cb / 128 - 1; // 0-499: A00-E99
	const char str[4] = {char('A' + code / 100), char('0' + code / 10 % 10),
	                     char('0' + code % 10), 0};
	return eco_FromString(str);
}

/// "5", "5.2" with a sub-round, or "?" when there is no round: a round or a
/// sub-round of 0 or less is none. ChessBase writes "5.2" in its own PGN.
std::string roundText(int16_t round, int16_t sub) {
	if (round <= 0)
		return "?";
	auto res = std::to_string(round);
	if (sub > 0) {
		res += '.';
		res += std::to_string(sub);
	}
	return res;
}

} // namespace

errorT CodecCB2::open(const char* filename, fileModeT fmode) {
	if (fmode != FMODE_ReadOnly)
		return ERROR_FileMode;

	next_ = 1;
	counts_ = {};
	log_.clear();
	nLogged_ = 0;
	std::string why;
	if (auto err = db_.open(filename ? filename : "", why)) {
		log_ = why + '\n';
		return err;
	}
	db_.headers.sequential(true);
	db_.moves.sequential(true);
	if (db_.hasAnnotations)
		db_.annotations.sequential(true);
	return OK;
}

void CodecCB2::logRecord(uint32_t id, std::string_view what) {
	if (++nLogged_ > kMaxLogLines)
		return;
	log_ += "(record ";
	log_ += std::to_string(id);
	log_ += ") ";
	log_ += what;
	log_ += '\n';
}

void CodecCB2::readTags(const cb2::Record& r, Game& game) const {
	const auto& e = db_.entities;
	std::string name;
	game.SetWhiteStr(e.player(r.white(), name) && !name.empty() ? name.c_str()
	                                                            : "?");
	name.clear();
	game.SetBlackStr(e.player(r.black(), name) && !name.empty() ? name.c_str()
	                                                            : "?");
	cb2::Tournament t;
	if (e.tournament(r.tournament(), t)) {
		game.SetEventStr(t.title.empty() ? "?" : t.title.c_str());
		game.SetSiteStr(t.place.empty() ? "?" : t.place.c_str());
		game.SetEventDate(scidDate(t.start));
	} else {
		game.SetEventStr("?");
		game.SetSiteStr("?");
	}
	game.SetDate(scidDate(r.date()));
	game.SetRoundStr(roundText(r.round(), r.subround()).c_str());
	game.SetResult(scidResult(r.result()));
	game.SetWhiteElo(scidElo(r.whiteElo()));
	game.SetBlackElo(scidElo(r.blackElo()));
	game.SetEco(scidEco(r.eco()));
	name.clear();
	if (e.player(r.annotator(), name) && !name.empty())
		game.addTag("Annotator", name);
}

namespace {

pieceT scidPiece(cb2::Piece p) {
	switch (p) {
	case cb2::Piece::King:
		return KING;
	case cb2::Piece::Queen:
		return QUEEN;
	case cb2::Piece::Knight:
		return KNIGHT;
	case cb2::Piece::Bishop:
		return BISHOP;
	case cb2::Piece::Rook:
		return ROOK;
	case cb2::Piece::Pawn:
		break;
	}
	return PAWN;
}

/// Checks that move word @p m agrees with @p pos: the side to move, the
/// named piece on the origin, the named piece (or nothing) on the
/// destination, en passant available, a castling right; then that the move
/// is legal. Gives Position::makeMove()'s arguments.
const char* toScidMove(Position& pos, const cb2::MoveWord& m,
                       squareT& from, squareT& to, pieceT& promo) {
	const colorT side = pos.GetToMove();
	if (m.kind == cb2::MoveWord::Null) {
		if (pos.CalcNumChecks() > 0)
			return "null move in check";
		from = to = pos.GetKingSquare();
		promo = PAWN; // makeMove()'s null move
		return nullptr;
	}
	if (m.kind == cb2::MoveWord::Invalid)
		return "not a move word";
	if ((m.black ? BLACK : WHITE) != side)
		return "move out of turn";
	if (m.kind == cb2::MoveWord::Castle) {
		if (!pos.GetCastling(side, m.kingside ? KSIDE : QSIDE))
			return "castling without the right";
		// Rare enough to look for among the legal moves, which hold castling
		// only when it is legal (Chess960 included).
		MoveList legal;
		pos.GenerateMoves(&legal);
		const int wanted = m.kingside ? 2 : -2;
		if (std::none_of(legal.begin(), legal.end(), [&](const auto& sm) {
			    return sm.isCastle() == wanted;
		    }))
			return "illegal castling";
		from = to = pos.GetKingSquare();
		promo = m.kingside ? KING : QUEEN; // makeMove()'s castling
		return nullptr;
	}
	from = m.from;
	to = m.to;
	promo = m.promotes ? scidPiece(m.promotion) : EMPTY;
	if (pos.GetPiece(from) != piece_Make(side, scidPiece(m.piece)))
		return "no such piece on the origin square";
	const auto target = pos.GetPiece(to);
	// Castling is a king taking its own rook in Scid's moves: a normal move
	// word onto an own piece must not be played as castling.
	if (target != EMPTY && piece_Color(target) == side)
		return "move onto an own piece";
	switch (m.captured) {
	case cb2::Captured::Nothing:
		if (target != EMPTY)
			return "capture not named by the move word";
		break;
	case cb2::Captured::EnPassant:
		if (target != EMPTY || pos.GetEPTarget() != to)
			return "en passant not available";
		break;
	default: {
		const auto named = piece_Make(
		    color_Flip(side),
		    scidPiece(static_cast<cb2::Piece>(int(m.captured))));
		if (target != named)
			return "captured piece not the one named";
	}
	}
	if (pos.IsLegalMove(from, to, promo) != 1)
		return "illegal move";
	return nullptr;
}

} // namespace

const char* CodecCB2::buildTree(const cb2::MoveRecord& mr,
                                const Position& start) {
	nodes_.assign(1, Node{});
	branches_.clear();
	Position pos = start;
	uint32_t cur = 0;
	bool ended = false;
	bool lastWasMove = false;
	const size_t n = mr.size();
	for (size_t i = 0; i < n; ++i) {
		const auto w = mr.word(i);
		if (ended)
			return "words after the final end of line";
		if (w == cb2::kAlternative) {
			// The move just played has an alternative, stored after the
			// line that it starts: come back to the position before it.
			if (!lastWasMove)
				return "alternative marker not after a move";
			if (branches_.size() >= kMaxVariationDepth)
				return "variations nested too deeply";
			// The position before the last move was saved in the slot that
			// the move left at the end of branches_ (see below).
			lastWasMove = false;
			continue;
		}
		if (w == cb2::kEndOfLine) {
			lastWasMove = false;
			if (branches_.empty()) {
				ended = true;
				continue;
			}
			pos = branches_.back().first;
			cur = branches_.back().second;
			branches_.pop_back();
			continue;
		}
		Node node;
		if (auto why = toScidMove(pos, cb2::decodeMove(w), node.from, node.to,
		                          node.promo))
			return why;
		// The position before a move is needed again only when an
		// alternative to it follows: save it then.
		if (i + 1 < n && mr.word(i + 1) == cb2::kAlternative) {
			if (branches_.size() >= kMaxVariationDepth)
				return "variations nested too deeply";
			branches_.emplace_back(pos, cur);
		}
		simpleMoveT sm;
		pos.makeMove(node.from, node.to, node.promo, sm);
		pos.DoSimpleMove(sm);

		const auto id = static_cast<uint32_t>(nodes_.size());
		nodes_.push_back(node);
		auto& parent = nodes_[cur];
		if (parent.lastChild == kNone)
			parent.firstChild = id;
		else
			nodes_[parent.lastChild].nextSibling = id;
		parent.lastChild = id;
		cur = id;
		lastWasMove = true;
	}
	if (!ended)
		return "move tree not terminated";
	return nullptr;
}

const char* CodecCB2::writeTree(Game& game) {
	// The moves in PGN order, as the PGN reader would add them: each
	// alternative, with everything after it, right after the move it
	// replaces. Iterative, so that deep nesting costs heap, not stack.
	struct Step {
		enum { Line, Alternatives, Close } kind;
		uint32_t node;
		uint32_t alt;
	};
	std::vector<Step> steps = {{Step::Line, 0, kNone}};
	auto add = [&](uint32_t id) {
		const auto& n = nodes_[id];
		simpleMoveT sm;
		game.GetCurrentPos()->makeMove(n.from, n.to, n.promo, sm);
		return game.AddMove(sm) == OK;
	};
	while (!steps.empty()) {
		const auto step = steps.back();
		steps.pop_back();
		switch (step.kind) {
		case Step::Line: {
			const auto main = nodes_[step.node].firstChild;
			if (main == kNone)
				break;
			if (!add(main))
				return "cannot add a move";
			const auto alt = nodes_[main].nextSibling;
			if (alt == kNone)
				steps.push_back({Step::Line, main, kNone});
			else
				steps.push_back({Step::Alternatives, main, alt});
			break;
		}
		case Step::Alternatives:
			if (step.alt == kNone) {
				steps.push_back({Step::Line, step.node, kNone});
				break;
			}
			steps.push_back(
			    {Step::Alternatives, step.node, nodes_[step.alt].nextSibling});
			steps.push_back({Step::Close, 0, kNone});
			if (game.AddVariation() != OK || !add(step.alt))
				return "cannot add a variation";
			steps.push_back({Step::Line, step.alt, kNone});
			break;
		case Step::Close:
			if (game.MoveExitVariation() != OK || game.MoveForward() != OK)
				return "cannot leave a variation";
			break;
		}
	}
	return nullptr;
}

const char* CodecCB2::readMoves(const cb2::Record& r, Game& game) {
	cb2::Frame frame;
	if (auto why = cb2::readFrame(db_.moves, r.movesOffset(), frame))
		return why;
	cb2::MoveRecord mr;
	if (auto why = mr.parse(frame.tag, frame.content))
		return why;
	cb2::Start start;
	if (auto why = mr.readStart(start))
		return why;
	const auto fen = cb2::startFen(start);
	if (!fen.empty() && game.SetStartFen(fen.c_str()) != OK)
		return "start position not valid";
	if (auto why = buildTree(mr, *game.GetCurrentPos()))
		return why;
	return writeTree(game);
}

errorT CodecCB2::parseNext(Game& game) {
	while (next_ <= db_.headers.count()) {
		const auto id = next_++;
		const auto r = db_.headers.record(id);
		if (!r.valid()) {
			++counts_.damaged;
			logRecord(id, "cannot be read");
			continue;
		}
		if (r.deleted()) {
			++counts_.deleted;
			continue;
		}
		switch (r.kind()) {
		case cb2::RecordKind::Game:
			break;
		case cb2::RecordKind::Text:
			++counts_.texts;
			continue;
		case cb2::RecordKind::Analysis:
			++counts_.analyses;
			continue;
		case cb2::RecordKind::Unknown:
			++counts_.unknown;
			continue;
		}

		game.Clear();
		if (auto why = readMoves(r, game)) {
			++counts_.damaged;
			logRecord(id, std::string("moves: ") + why);
			continue;
		}
		readTags(r, game);
		++counts_.games;
		return OK;
	}
	return ERROR_NotFound;
}

const char* CodecCB2::parseErrors() {
	summary_ = "ChessBase 2CBH database: " +
	           std::to_string(db_.headers.count()) + " records, " +
	           std::to_string(counts_.games) + " games read.\n";
	auto skipped = [&](uint64_t n, const char* what) {
		if (n)
			summary_ += "Skipped " + std::to_string(n) + ' ' + what + ".\n";
	};
	skipped(counts_.deleted, "deleted record(s)");
	skipped(counts_.texts, "guiding text(s)");
	skipped(counts_.analyses, "analysis record(s)");
	skipped(counts_.unknown, "record(s) of an unknown kind");
	skipped(counts_.damaged, "game(s) whose moves are damaged");
	if (counts_.incomplete)
		summary_ += std::to_string(counts_.incomplete) +
		            " game(s) imported without some of their annotations.\n";
	summary_ += log_;
	if (nLogged_ > kMaxLogLines)
		summary_ += "... " + std::to_string(nLogged_ - kMaxLogLines) +
		            " more problem(s) not listed.\n";
	return summary_.c_str();
}
