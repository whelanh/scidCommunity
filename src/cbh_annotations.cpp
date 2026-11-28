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

#include "cbh_format.h"
#include <algorithm>

namespace cbh {

namespace {

/// The position, type and size that start each annotation.
constexpr size_t kItemHead = 6;

/// The 2CBH language number of a text's nation code; a nation ChessBase does
/// not offer as a text language keeps a number of its own.
uint16_t languageOf(uint8_t nation) {
	namespace L = cb2::language;
	switch (nation) {
	case 0:
		return L::Any;
	case 42:
		return L::English;
	case 53:
		return L::German;
	case 49:
		return L::French;
	case 43:
		return L::Spanish;
	case 70:
		return L::Italian;
	case 103:
		return L::Dutch;
	case 117:
		return L::Portuguese;
	case 116:
		return L::Polish;
	case 55:
		return L::Greek;
	}
	return uint16_t(0x100 + nation);
}

/// Squares are numbered from 1, file by file; here a1 = 0, b1 = 1.
bool square(uint8_t n, uint8_t& out) {
	if (n < 1 || n > 64)
		return false;
	out = uint8_t((n - 1) % 8 * 8 + (n - 1) / 8);
	return true;
}

/// Decodes one annotation's data. Returns nullptr or what is wrong; a type
/// that is not read leaves @p a as Other.
const char* annotation(uint8_t type, Bytes d, cb2::Annotation& a) {
	a.type = type;
	switch (type) {
	case 0x02:
	case 0x82:
		if (d.size() < 2)
			return "text without its language";
		a.kind = cb2::Annotation::Text;
		a.before = type == 0x82;
		a.language = languageOf(d[1]);
		a.text = cb2::decodeText(d.subspan(2));
		break;
	case 0x03:
		if (d.empty() || d.size() > 3)
			return "symbols of unexpected length";
		a.kind = cb2::Annotation::Symbols;
		std::copy(d.begin(), d.end(), a.nags.begin());
		break;
	case 0x04:
	case 0x05: {
		const bool arrows = type == 0x05;
		const size_t step = arrows ? 3 : 2;
		if (d.size() % step)
			return "coloured marks of unexpected length";
		a.kind = arrows ? cb2::Annotation::Arrows : cb2::Annotation::Squares;
		for (size_t i = 0; i < d.size(); i += step) {
			std::array<uint8_t, 3> m{d[i], 0, 0};
			if (!square(d[i + 1], m[1]) ||
			    (arrows && !square(d[i + 2], m[2])))
				return "square out of range";
			a.marks.push_back(m);
		}
		break;
	}
	}
	return nullptr;
}

} // namespace

void parseAnnotations(Bytes record, uint32_t gameId,
                      cb2::GameAnnotations& out) {
	out = {};
	out.storedOrder = true;
	// The game id, the fixed bytes 01 00 0e 0e, the annotation count plus
	// one, and the record's size.
	static constexpr uint8_t mark[4] = {1, 0, 0x0e, 0x0e};
	if (record.size() < 14 || be_u24(record, 0) != gameId ||
	    !std::equal(mark, mark + 4, record.begin() + 3) ||
	    cb2::be_u32(record, 0x0a) != record.size()) {
		out.stopped = "not the annotation record of this game";
		return;
	}
	for (size_t i = 14; i < record.size();) {
		if (record.size() - i < kItemHead) {
			out.stopped = "annotation head runs past the record";
			return;
		}
		// A signed 24-bit move number; -1 is the game.
		const auto position = int32_t(be_u24(record, i) << 8) >> 8;
		const auto type = record[i + 3];
		const size_t size = be_u16(record, i + 4);
		if (size < kItemHead || size > record.size() - i ||
		    position < cb2::kGamePosition) {
			out.stopped = "annotation out of range";
			return;
		}
		cb2::Annotation a;
		if (auto why = annotation(type, record.subspan(i + kItemHead,
		                                               size - kItemHead),
		                          a)) {
			out.stopped = why;
			return;
		}
		i += size;
		if (a.kind == cb2::Annotation::Other)
			continue;
		if (out.blocks.empty() || out.blocks.back().position != position)
			out.blocks.push_back({position, {}});
		out.blocks.back().items.push_back(std::move(a));
	}
}

} // namespace cbh
