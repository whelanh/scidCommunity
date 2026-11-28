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
#include <cctype>
#include <cstdio>
#include <optional>

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

/// The header tags of record @p r of @p db, a cb2:: or cbh:: database.
template <class Db, class Record>
void readTags(const Db& db, const Record& r, Game& game) {
	const auto& e = db.entities;
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
	if (e.annotatorName(r.annotator(), name) && !name.empty())
		game.addTag("Annotator", name);
}

} // namespace

errorT CodecCB2::open(const char* filename, fileModeT fmode) {
	if (fmode != FMODE_ReadOnly)
		return ERROR_FileMode;

	next_ = 1;
	counts_ = {};
	log_.clear();
	nLogged_ = 0;
	db_.close();
	cbh_.close();
	const std::string_view path(filename ? filename : "");
	std::string ext(path.substr(path.size() > 4 ? path.size() - 4 : 0));
	for (auto& ch : ext)
		ch = char(std::tolower(static_cast<unsigned char>(ch)));
	classic_ = ext == ".cbh";

	std::string why;
	if (auto err = classic_ ? cbh_.open(path, why) : db_.open(path, why)) {
		log_ = why + '\n';
		return err;
	}
	if (classic_) {
		cbh_.sequential(true);
		return OK;
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

uint32_t CodecCB2::addNode(uint32_t parent, const Node& node) {
	const auto id = static_cast<uint32_t>(nodes_.size());
	nodes_.push_back(node);
	auto& p = nodes_[parent];
	if (p.lastChild == kNone)
		p.firstChild = id;
	else
		nodes_[p.lastChild].nextSibling = id;
	p.lastChild = id;
	return id;
}

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
		if (w == cb2::kSkipped)
			continue;
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
		size_t next = i + 1;
		while (next < n && mr.word(next) == cb2::kSkipped)
			++next;
		if (next < n && mr.word(next) == cb2::kAlternative) {
			if (branches_.size() >= kMaxVariationDepth)
				return "variations nested too deeply";
			branches_.emplace_back(pos, cur);
		}
		simpleMoveT sm;
		pos.makeMove(node.from, node.to, node.promo, sm);
		pos.DoSimpleMove(sm);

		cur = addNode(cur, node);
		lastWasMove = true;
	}
	if (!ended)
		return "move tree not terminated";
	return nullptr;
}

const char* CodecCB2::buildClassicTree(const cbh::MoveRecord& mr,
                                       const Position& start,
                                       unsigned& missingRight) {
	missingRight = 0;
	nodes_.assign(1, Node{});
	branches_.clear();
	branchPieces_.clear();
	Position pos = start;
	cbh::Pieces pieces;
	if (!pieces.scan(pos))
		return "too many pieces of a kind";
	cbh::MoveStream stream;
	if (auto why = stream.open(mr))
		return why;
	uint32_t cur = 0;
	bool branchNext = false;
	// Bytes after the final end of line, which some records carry, are left.
	bool ended = false;
	while (!ended && !stream.atEnd()) {
		cbh::Token t;
		if (auto why = stream.next(pos, pieces, t))
			return why;
		if (t.branch) {
			if (branchNext)
				return "two variation starts in a row";
			if (branches_.size() >= kMaxVariationDepth)
				return "variations nested too deeply";
			branchNext = true;
		}
		if (t.hasMove) {
			// After the line that this move starts comes an alternative to
			// it, from the position before it.
			if (branchNext) {
				branches_.emplace_back(pos, cur);
				branchPieces_.push_back(pieces);
				branchNext = false;
			}
			Node node;
			if (auto why = toScidMove(pos, t.move, node.from, node.to,
			                          node.promo)) {
				if (t.move.kind == cb2::MoveWord::Castle &&
				    !pos.GetCastling(pos.GetToMove(),
				                     t.move.kingside ? KSIDE : QSIDE))
					missingRight = (t.move.kingside ? 2u : 1u)
					               << (t.move.black ? 2 : 0);
				return why;
			}
			simpleMoveT sm;
			pos.makeMove(node.from, node.to, node.promo, sm);
			pos.DoSimpleMove(sm);
			if (!pieces.update(t.move, pos))
				return "piece lists do not match the board";
			cur = addNode(cur, node);
		}
		if (t.endLine) {
			if (branchNext)
				return "variation start before the end of a line";
			if (branches_.empty()) {
				ended = true;
				continue;
			}
			pos = branches_.back().first;
			cur = branches_.back().second;
			pieces = branchPieces_.back();
			branches_.pop_back();
			branchPieces_.pop_back();
		}
	}
	// A game without moves may be stored with no bytes at all.
	if (!ended && !mr.stream().empty())
		return "move tree not terminated";
	return nullptr;
}

namespace {

/// A text fit for a PGN comment: no braces, no control characters, single
/// spaces.
std::string cleanText(std::string_view text) {
	std::string res;
	res.reserve(text.size());
	bool space = false;
	for (unsigned char c : text) {
		if (c == '{')
			c = '(';
		else if (c == '}')
			c = ')';
		if (c < 0x20 || c == 0x7f || c == ' ') {
			space = !res.empty();
			continue;
		}
		if (space)
			res += ' ';
		space = false;
		res += char(c);
	}
	return res;
}

void appendPart(std::string& dest, std::string_view part) {
	if (part.empty())
		return;
	if (!dest.empty())
		dest += ' ';
	dest += part;
}

using Anns = std::vector<const cb2::Annotation*>;

/// A game's annotations by position, written as Scid comments and NAGs the
/// way ChessBase writes them in its own PGN: one language for the texts,
/// `[%csl]`/`[%cal]` for coloured squares and arrows, `[%mdl]` for medals,
/// `[%evp]` for the evaluation profile, and game quotations as text.
class Commentary {
	std::vector<Anns> byPosition_;
	Anns game_;
	/// Annotations past the last move, in order: they follow the main line's
	/// last move.
	Anns pastEnd_;
	int language_ = -1;

public:
	Commentary(const cb2::GameAnnotations& a, size_t plies,
	           const std::vector<uint16_t>& preferred) {
		byPosition_.resize(plies);
		std::vector<uint16_t> languages;
		for (const auto& b : a.blocks) {
			for (const auto& item : b.items) {
				if (b.position == cb2::kGamePosition)
					game_.push_back(&item);
				else if (size_t(b.position) < plies)
					byPosition_[b.position].push_back(&item);
				else
					pastEnd_.push_back(&item);
				if (item.kind == cb2::Annotation::Text &&
				    item.language != cb2::language::Any)
					languages.push_back(item.language);
			}
		}
		// The first preferred language the game has, else English, else the
		// first one stored. Texts for any language are always written.
		auto has = [&](uint16_t l) {
			return std::find(languages.begin(), languages.end(), l) !=
			       languages.end();
		};
		for (auto l : preferred)
			if (language_ < 0 && has(l))
				language_ = l;
		if (language_ < 0 && has(cb2::language::English))
			language_ = cb2::language::English;
		if (language_ < 0 && !languages.empty())
			language_ = languages.front();
	}

	/// The comment before the first move: the evaluation profile, then the
	/// game's medals, graphics and texts; and, in a game without moves, what
	/// would follow its last move.
	std::string gameComment() const {
		std::string res;
		for (auto a : game_) {
			if (a->kind == cb2::Annotation::Other && a->type == 0x26) {
				auto values = cb2::evaluationProfile(a->data);
				if (!values.empty()) {
					res = "[%evp 0," + std::to_string(values.size() - 1);
					for (auto v : values)
						res += ',' + std::to_string(v);
					res += ']';
				}
				break;
			}
		}
		Anns all = game_;
		if (byPosition_.empty())
			all.insert(all.end(), pastEnd_.begin(), pastEnd_.end());
		appendPart(res, medals(all));
		appendPart(res, graphics(all));
		appendPart(res, texts(all, true));
		appendPart(res, texts(all, false));
		appendPart(res, quotes(all));
		return res;
	}

	/// The texts meant to precede move @p k (PGN order).
	std::string before(uint32_t k) const {
		return k < byPosition_.size() ? texts(byPosition_[k], true) : "";
	}

	/// Adds the NAGs and the comment that follow move @p k; @p lastMain
	/// when it is the main line's last move.
	void after(uint32_t k, bool lastMain, Game& game) const {
		if (k >= byPosition_.size())
			return;
		const auto& own = byPosition_[k];
		Anns all = own;
		if (lastMain)
			all.insert(all.end(), pastEnd_.begin(), pastEnd_.end());
		for (auto a : all)
			if (a->kind == cb2::Annotation::Symbols)
				for (auto nag : a->nags)
					if (nag)
						game.AddNag(nag);
		std::string res = medals(all);
		appendPart(res, graphics(all));
		appendPart(res, texts(own, false));
		if (lastMain) {
			appendPart(res, texts(pastEnd_, true));
			appendPart(res, texts(pastEnd_, false));
		}
		appendPart(res, quotes(all));
		appendPart(game.accessMoveComment(), res);
	}

private:
	std::string texts(const Anns& anns, bool before) const {
		std::string res;
		for (auto a : anns) {
			if (a->kind == cb2::Annotation::Text && a->before == before &&
			    (a->language == cb2::language::Any ||
			     a->language == language_))
				appendPart(res, cleanText(a->text));
		}
		return res;
	}

	static std::string quotes(const Anns& anns) {
		std::string res;
		for (auto a : anns)
			if (a->kind == cb2::Annotation::Quotation)
				appendPart(res, cleanText(a->text));
		return res;
	}

	static std::string medals(const Anns& anns) {
		std::string res;
		for (auto a : anns)
			if (a->kind == cb2::Annotation::Other && a->type == 0x22 &&
			    a->data.size() == 4)
				appendPart(res, "[%mdl " + std::to_string(cb2::le_u32(a->data, 0)) +
				                    "]");
		return res;
	}

	/// `[%csl ...]` and `[%cal ...]`, as one token when both are there.
	/// ChessBase's colours 2, 3 and 4 are green, yellow and red; the others
	/// have no known meaning and are left out.
	static std::string graphics(const Anns& anns) {
		auto colour = [](uint8_t c) -> char {
			switch (c) {
			case 2:
				return 'G';
			case 3:
				return 'Y';
			case 4:
				return 'R';
			}
			return 0;
		};
		auto name = [](std::string& s, uint8_t sq) {
			s += char('a' + sq % 8);
			s += char('1' + sq / 8);
		};
		std::string squares, arrows;
		for (auto a : anns) {
			if (a->kind != cb2::Annotation::Squares &&
			    a->kind != cb2::Annotation::Arrows)
				continue;
			const bool isArrow = a->kind == cb2::Annotation::Arrows;
			auto& dest = isArrow ? arrows : squares;
			for (const auto& m : a->marks) {
				const char c = colour(m[0]);
				if (!c)
					continue;
				if (!dest.empty())
					dest += ',';
				dest += c;
				name(dest, m[1]);
				if (isArrow)
					name(dest, m[2]);
			}
		}
		std::string res;
		if (!squares.empty())
			res = "[%csl " + squares + "]";
		if (!arrows.empty())
			res += "[%cal " + arrows + "]";
		return res;
	}
};

} // namespace

const char* CodecCB2::writeTree(Game& game,
                                const cb2::GameAnnotations* annotations) {
	// The moves in PGN order, as the PGN reader would add them: each
	// alternative, with everything after it, right after the move it
	// replaces. Iterative, so that deep nesting costs heap, not stack.
	struct Step {
		enum { Line, Alternatives, Close } kind;
		uint32_t node;
		uint32_t alt;
	};
	std::vector<Step> steps = {{Step::Line, 0, kNone}};

	std::optional<Commentary> notes;
	uint32_t lastMain = kNone;
	if (annotations) {
		notes.emplace(*annotations, nodes_.size() - 1, preferredLanguages_);
		for (auto n = nodes_[0].firstChild; n != kNone;
		     n = nodes_[n].firstChild)
			lastMain = n;
		appendPart(game.accessMoveComment(), notes->gameComment());
	}
	const bool storedOrder = annotations && annotations->storedOrder;
	uint32_t index = 0; // the move's position in PGN order
	auto add = [&](uint32_t id) {
		// Nodes are numbered in stored order, after the start.
		const uint32_t key = storedOrder ? id - 1 : index;
		if (notes)
			appendPart(game.accessMoveComment(), notes->before(key));
		const auto& n = nodes_[id];
		simpleMoveT sm;
		game.GetCurrentPos()->makeMove(n.from, n.to, n.promo, sm);
		if (game.AddMove(sm) != OK)
			return false;
		if (notes)
			notes->after(key, id == lastMain, game);
		++index;
		return true;
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

	// Every game record of a database with a .2cba file names an
	// annotation record, most of them empty.
	const auto ao = r.annotationsOffset();
	if (!db_.hasAnnotations || ao < 12)
		return writeTree(game, nullptr);
	cb2::GameAnnotations ann;
	if (auto why = cb2::readFrame(db_.annotations, ao, frame)) {
		ann.stopped = why;
	} else if (frame.tag != cb2::kAnnotationTag) {
		ann.stopped = "not an annotation record";
	} else {
		cb2::parseAnnotations(frame.content, ann);
	}
	return writeAnnotated(game, ann);
}

const char* CodecCB2::readMoves(const cbh::Record& r, Game& game) {
	cb2::Bytes record;
	if (auto why = cbh_.readMoveRecord(r.movesOffset(), record))
		return why;
	cbh::MoveRecord mr;
	if (auto why = mr.parse(record))
		return why;
	cb2::Start start;
	if (auto why = mr.readStart(start))
		return why;
	// ChessBase castles in set-up games whose stored rights lack it, and old
	// databases store none: add each right a castling move needs and read
	// the game again. startFen() keeps only a right that the king and rook
	// can have, and none is added twice, so at most five rounds.
	for (;;) {
		const auto fen = cb2::startFen(start);
		if (!fen.empty() && game.SetStartFen(fen.c_str()) != OK)
			return "start position not valid";
		unsigned missing = 0;
		const auto why = buildClassicTree(mr, *game.GetCurrentPos(), missing);
		if (!why)
			break;
		if (start.kind != cb2::Start::Setup || !missing ||
		    (start.castling & missing))
			return why;
		start.castling |= missing;
	}

	const auto ao = r.annotationsOffset();
	if (!cbh_.hasAnnotations() || ao == 0)
		return writeTree(game, nullptr);
	cb2::GameAnnotations ann;
	if (auto why = cbh_.readAnnotationRecord(ao, record))
		ann.stopped = why;
	else
		cbh::parseAnnotations(record, currentId_, ann);
	return writeAnnotated(game, ann);
}

const char* CodecCB2::writeAnnotated(Game& game,
                                     const cb2::GameAnnotations& ann) {
	if (ann.stopped) {
		++counts_.incomplete;
		std::string what = "annotations: ";
		what += ann.stopped;
		if (ann.stoppedType) {
			char type[16];
			snprintf(type, sizeof type, " (type 0x%02x)", ann.stoppedType);
			what += type;
		}
		logRecord(currentId_, what + "; imported with those before it");
	}
	return writeTree(game, &ann);
}

errorT CodecCB2::parseNext(Game& game) {
	return classic_ ? parseNextIn(cbh_, game) : parseNextIn(db_, game);
}

template <class Db>
errorT CodecCB2::parseNextIn(const Db& db, Game& game) {
	while (next_ <= db.count()) {
		const auto id = next_++;
		const auto r = db.record(id);
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
		currentId_ = id;
		if (auto why = readMoves(r, game)) {
			++counts_.damaged;
			logRecord(id, std::string("moves: ") + why);
			continue;
		}
		readTags(db, r, game);
		++counts_.games;
		return OK;
	}
	return ERROR_NotFound;
}

const char* CodecCB2::parseErrors() {
	summary_ = std::string("ChessBase ") + (classic_ ? "CBH" : "2CBH") +
	           " database: " + std::to_string(recordCount()) + " records, " +
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
