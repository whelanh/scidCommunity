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

#include "cb2_annotations.h"

namespace cb2 {

namespace {

constexpr int32_t kEndMarker = 0x7fffffff;

/// Reads an annotation record in order. Every read is bounds-checked; the
/// first failure is remembered and makes every later read fail.
struct Reader {
	Bytes b;
	size_t i = 0;
	const char* error = nullptr;

	size_t left() const { return b.size() - i; }
	bool fail(const char* why) {
		if (!error)
			error = why;
		return false;
	}
	bool take(size_t n, Bytes& out) {
		if (error)
			return false;
		if (n > left())
			return fail("runs past the end of the record");
		out = b.subspan(i, n);
		i += n;
		return true;
	}
	bool skip(size_t n) {
		Bytes tmp;
		return n == 0 ? !error : take(n, tmp);
	}
	bool u8(uint8_t& v) {
		Bytes t;
		if (!take(1, t))
			return false;
		v = t[0];
		return true;
	}
	bool u16(uint16_t& v) {
		Bytes t;
		if (!take(2, t))
			return false;
		v = le_u16(t, 0);
		return true;
	}
	bool i32(int32_t& v) {
		Bytes t;
		if (!take(4, t))
			return false;
		v = le_i32(t, 0);
		return true;
	}
	/// A non-negative int32 length that fits in what is left.
	bool len(size_t& n) {
		int32_t v;
		if (!i32(v))
			return false;
		if (v < 0 || size_t(v) > left())
			return fail("length out of range");
		n = size_t(v);
		return true;
	}
	bool expectOne() {
		uint8_t v;
		if (!u8(v))
			return false;
		return v == 1 || fail("unexpected byte in an annotation");
	}
	/// An int32 length and that many bytes, skipped.
	bool skipCounted() {
		size_t n;
		return len(n) && skip(n);
	}
};

/// A square numbered from 1, file by file (a1 1, a2 2, b1 9).
bool square(Reader& r, uint8_t v, uint8_t& sq) {
	if (v < 1 || v > 64)
		return r.fail("square out of range");
	const unsigned cb = v - 1;
	sq = static_cast<uint8_t>((cb % 8) * 8 + cb / 8);
	return true;
}

bool trainingList(Reader& r) {
	uint16_t items;
	if (!r.u16(items))
		return false;
	for (unsigned k = 0; k < items; ++k)
		if (!r.skip(2) || !r.skipCounted())
			return false;
	return true;
}

/// A training question: a header whose third byte is the variant, time
/// and points, four lists (the question and three responses), then the
/// solutions. Variant 1 solutions are two squares, two unknown bytes and a
/// list; variant 2 solutions are points and two lists. 0 for another variant.
int training(Reader& r) {
	Bytes head;
	if (!r.take(6, head))
		return -1;
	const auto variant = head[2];
	if (variant != 1 && variant != 2)
		return 0;
	if (!r.skip(6))
		return -1;
	for (int k = 0; k < 4; ++k)
		if (!trainingList(r))
			return -1;
	uint8_t solutions;
	if (!r.u8(solutions))
		return -1;
	for (unsigned k = 0; k < solutions; ++k) {
		if (variant == 1) {
			if (!r.skip(4) || !trainingList(r))
				return -1;
		} else if (!r.skip(1) || !trainingList(r) || !trainingList(r)) {
			return -1;
		}
	}
	return 1;
}

/// Reads one annotation of type @p t. Returns 1 when read, 0 for a type of
/// unknown layout, -1 for damage.
int annotation(Reader& r, uint16_t t, Annotation& a) {
	a = {};
	a.type = t;
	const size_t start = r.i;
	switch (t) {
	case 0x02:
	case 0x82: {
		uint16_t language;
		size_t n;
		Bytes text;
		if (!r.skip(2) || !r.u16(language) || !r.len(n) || !r.take(n, text))
			return -1;
		a.kind = Annotation::Text;
		a.before = t == 0x82;
		a.language = language;
		a.text = decodeText(text);
		return 1;
	}
	case 0x03: {
		Bytes b;
		if (!r.take(3, b))
			return -1;
		a.kind = Annotation::Symbols;
		a.nags = {b[0], b[1], b[2]};
		return 1;
	}
	case 0x04:
	case 0x05: {
		const size_t width = t == 0x04 ? 2 : 3;
		size_t n;
		Bytes items;
		if (!r.len(n) || !r.take(n, items))
			return -1;
		if (n % width)
			return r.fail("coloured squares or arrows of a bad length"), -1;
		a.kind = t == 0x04 ? Annotation::Squares : Annotation::Arrows;
		for (size_t k = 0; k < n; k += width) {
			std::array<uint8_t, 3> m{items[k], 0, 0};
			for (size_t s = 1; s < width; ++s)
				if (!square(r, items[k + s], m[s]))
					return -1;
			a.marks.push_back(m);
		}
		return 1;
	}
	case 0x15: // a piece path: a length and that many bytes
		if (!r.skipCounted())
			return -1;
		break;
	// Time spent, an unknown type, the clocks, medals, the variation colour,
	// a video's stream time: 4 bytes.
	case 0x07:
	case 0x08:
	case 0x16:
	case 0x17:
	case 0x22:
	case 0x23:
	case 0x25:
		if (!r.skip(4))
			return -1;
		break;
	case 0x27: // unknown, 2 bytes
		if (!r.skip(2))
			return -1;
		break;
	case 0x14: // pawn structure
	case 0x18: // critical position
		if (!r.skip(1))
			return -1;
		break;
	case 0x21: // an engine's evaluation
		if (!r.skip(6))
			return -1;
		break;
	case 0x24: // the time control
		if (!r.skip(38))
			return -1;
		break;
	case 0x26: // the evaluation profile
		if (!r.expectOne() || !r.skipCounted())
			return -1;
		break;
	case 0x09:
		switch (training(r)) {
		case 0:
			return 0;
		case -1:
			return -1;
		}
		break;
	case 0x20: // a video: 01 00, a language, a length and that many bytes
		if (!r.skip(4) || !r.skipCounted())
			return -1;
		break;
	case 0x1c: // a web link: 01, the URL and the caption
		if (!r.expectOne() || !r.skipCounted() || !r.skipCounted())
			return -1;
		break;
	default:
		return 0;
	}
	a.kind = Annotation::Other;
	a.data = r.b.subspan(start, r.i - start);
	return 1;
}

} // namespace

void parseAnnotations(Bytes content, GameAnnotations& out) {
	out = {};
	Reader r{content};
	while (true) {
		int32_t position;
		if (!r.i32(position))
			break;
		if (position == kEndMarker) {
			if (r.left() != 0)
				r.fail("bytes after the end marker");
			break;
		}
		if (position < kGamePosition) {
			r.fail("position out of range");
			break;
		}
		int32_t count;
		if (!r.i32(count))
			break;
		// Each annotation is at least its 2-byte type.
		if (count < 0 || size_t(count) > r.left() / 2) {
			r.fail("annotation count out of range");
			break;
		}
		out.blocks.push_back({position, {}});
		auto& items = out.blocks.back().items;
		for (int32_t k = 0; k < count; ++k) {
			uint16_t type;
			Annotation a;
			if (!r.u16(type))
				break;
			const int res = annotation(r, type, a);
			if (res == 0) {
				out.stopped = "annotation of unknown layout";
				out.stoppedType = type;
				return;
			}
			if (res < 0)
				break;
			items.push_back(std::move(a));
		}
		if (r.error)
			break;
	}
	out.stopped = r.error;
}

std::vector<int> evaluationProfile(Bytes data) {
	if (data.size() < 7 || data[0] != 1)
		return {};
	const auto len = le_i32(data, 1);
	const size_t count = le_u16(data, 5);
	if (len < 0 || size_t(len) != 2 + 4 * count ||
	    data.size() - 7 != 4 * count)
		return {};
	std::vector<int> res;
	res.reserve(count);
	for (size_t k = 0; k < count; ++k) {
		const size_t o = 7 + 4 * k;
		const int value = le_i16(data, o);
		const auto flag = data[o + 3];
		if (flag == 0)
			res.push_back(value);
		else if (flag == 1 && value > 0)
			res.push_back(30000 - value);
		else if (flag == 1 && value < 0)
			res.push_back(-30000 - value);
		else
			res.push_back(32767);
	}
	return res;
}

} // namespace cb2
