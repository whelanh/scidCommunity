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
