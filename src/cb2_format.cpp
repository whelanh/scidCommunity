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

#include "cb2_format.h"
#include <algorithm>
#include <cctype>
#include <filesystem>
#include <limits>

namespace cb2 {

uint64_t frameChecksum(Bytes content) {
	const size_t m = content.size() / 8;
	uint64_t v = 0;
	if (m == 0) {
		for (size_t i = 0; i < content.size(); ++i)
			v |= uint64_t(content[i]) << (8 * i);
		return v;
	}
	for (size_t i = 0; i < 8; ++i) {
		uint8_t s = 0;
		for (size_t j = i * m; j < (i + 1) * m; ++j)
			s = static_cast<uint8_t>(s + content[j]);
		v |= uint64_t(s) << (8 * i);
	}
	return v;
}

const char* readFrame(const File& file, int64_t offset, Frame& out) {
	static const unsigned char magic[8] = {0x88, 0x77, 0x66, 0x55,
	                                       0x44, 0x33, 0x22, 0x11};
	out = {};
	if (offset < 0)
		return "negative offset";
	const auto head = file.view(uint64_t(offset), kFrameHeader);
	if (head.empty())
		return "offset out of range";
	if (!std::equal(magic, magic + 8, head.begin()))
		return "bad magic";
	const auto a = le_i32(head, 8);
	const auto b = le_i32(head, 12);
	if (a < 0 || b < 0)
		return "negative size";
	if (size_t(a) > kMaxFramePart || size_t(b) > kMaxFramePart)
		return "record larger than 64 MiB";
	const size_t whole = kFrameHeader + size_t(a) + size_t(b) + 8;
	const auto frame = file.view(uint64_t(offset), whole);
	if (frame.empty())
		return "runs past the end of the file";
	if (le_i64(frame, kFrameHeader + a + b) != int64_t(a) + b + 34)
		return "trailing length mismatch";
	const auto content = frame.subspan(kFrameHeader, size_t(a));
	if (be_u64(frame, 0x10) != frameChecksum(content))
		return "checksum mismatch";
	out.tag = le_u16(frame, 0x18);
	out.content = content;
	return nullptr;
}

namespace {

/// The length of the UTF-8 sequence starting at @p i, or 0 when the bytes
/// there are not valid UTF-8 (overlong forms and surrogates included).
size_t utf8Seq(Bytes b, size_t i) {
	const unsigned c = b[i];
	if (c < 0x80)
		return 1;
	size_t n;
	unsigned lo = 0x80, hi = 0xBF;
	if (c >= 0xC2 && c <= 0xDF) {
		n = 2;
	} else if (c >= 0xE0 && c <= 0xEF) {
		n = 3;
		if (c == 0xE0)
			lo = 0xA0;
		else if (c == 0xED)
			hi = 0x9F;
	} else if (c >= 0xF0 && c <= 0xF4) {
		n = 4;
		if (c == 0xF0)
			lo = 0x90;
		else if (c == 0xF4)
			hi = 0x8F;
	} else {
		return 0;
	}
	if (b.size() - i < n)
		return 0;
	if (b[i + 1] < lo || b[i + 1] > hi)
		return 0;
	for (size_t k = 2; k < n; ++k)
		if (b[i + k] < 0x80 || b[i + k] > 0xBF)
			return 0;
	return n;
}

void appendUtf8(std::string& s, unsigned cp) {
	if (cp < 0x80) {
		s.push_back(char(cp));
	} else if (cp < 0x800) {
		s.push_back(char(0xC0 | (cp >> 6)));
		s.push_back(char(0x80 | (cp & 0x3F)));
	} else {
		s.push_back(char(0xE0 | (cp >> 12)));
		s.push_back(char(0x80 | ((cp >> 6) & 0x3F)));
		s.push_back(char(0x80 | (cp & 0x3F)));
	}
}

// Windows-1252 bytes 0x80-0x9F; 0 where the page leaves a byte undefined.
// From 0xA0 on, the page is Latin-1.
const uint16_t cp1252[32] = {
    0x20AC, 0,      0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021,
    0x02C6, 0x2030, 0x0160, 0x2039, 0x0152, 0,      0x017D, 0,
    0,      0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014,
    0x02DC, 0x2122, 0x0161, 0x203A, 0x0153, 0,      0x017E, 0x0178};

} // namespace

std::string decodeText(Bytes b) {
	bool valid = true;
	for (size_t i = 0; i < b.size();) {
		auto n = utf8Seq(b, i);
		if (n == 0) {
			valid = false;
			break;
		}
		i += n;
	}
	if (valid)
		return std::string(reinterpret_cast<const char*>(b.data()), b.size());

	std::string res;
	res.reserve(b.size() + b.size() / 2);
	for (auto c : b) {
		unsigned cp = c;
		if (c >= 0x80 && c < 0xA0 && cp1252[c - 0x80])
			cp = cp1252[c - 0x80];
		appendUtf8(res, cp);
	}
	return res;
}

errorT Entities::open(std::string_view path, std::string& why) {
	close();
	types_.clear();
	headerSize_ = blockSize_ = 0;
	if (auto err = file_.open(path)) {
		why = "cannot open the .2lid file";
		return err;
	}
	const auto head = file_.view(0, 8);
	if (head.empty()) {
		why = ".2lid file too short";
		return ERROR_Corrupt;
	}
	const auto headerSize = be_i32(head, 0);
	const auto ntypes = be_i32(head, 4);
	if (ntypes < 1 || ntypes > 32 || headerSize < 8 + 20 * ntypes ||
	    uint64_t(headerSize) > file_.size() || headerSize > (64 << 10)) {
		why = ".2lid header not supported";
		return ERROR_Corrupt;
	}
	const auto d = file_.view(0, size_t(headerSize));
	for (int i = 0; i < ntypes; ++i) {
		const size_t o = 8 + 20 * size_t(i);
		const auto size = be_i32(d, o);
		const auto count = be_i64(d, o + 4);
		if (size < 0 || size > (1 << 20) || count < 0) {
			why = ".2lid entity type " + std::to_string(i) + " not supported";
			return ERROR_Corrupt;
		}
		types_.push_back({size_t(size), count, blockSize_});
		blockSize_ += size_t(size);
	}
	headerSize_ = size_t(headerSize);
	return OK;
}

Bytes Entities::raw(size_t type, int64_t id) const {
	if (type >= types_.size())
		return {};
	const auto& t = types_[type];
	if (id < 0 || id >= t.count || t.size < 4)
		return {};
	const uint64_t maxId = (std::numeric_limits<uint64_t>::max() - headerSize_ -
	                        t.offset) / std::max<size_t>(blockSize_, 1);
	if (uint64_t(id) > maxId)
		return {};
	const uint64_t o = headerSize_ + t.offset + uint64_t(id) * blockSize_;
	if (o >= file_.size())
		return {};
	const size_t want =
	    size_t(std::min<uint64_t>(t.size, file_.size() - o));
	if (want < 4)
		return {};
	const auto len = le_i32(file_.view(o, 4), 0);
	if (len <= 0 || size_t(len) > want - 4)
		return {};
	return file_.view(o + 4, size_t(len));
}

namespace {

/// Reads the fields of an entity record in order.
struct Cursor {
	Bytes b;
	size_t i = 0;

	bool i32(int32_t& v) {
		if (b.size() - i < 4)
			return false;
		v = le_i32(b, i);
		i += 4;
		return true;
	}
	/// An int32 length, then that many bytes of text.
	bool string(std::string& s) {
		int32_t n;
		if (!i32(n) || n < 0 || size_t(n) > b.size() - i)
			return false;
		s = decodeText(b.subspan(i, size_t(n)));
		i += size_t(n);
		return true;
	}
};

} // namespace

bool Entities::player(int64_t id, std::string& name) const {
	Cursor c{raw(PLAYER, id)};
	std::string last, first;
	if (c.b.empty() || !c.string(last) || !c.string(first))
		return false;
	name = std::move(last);
	if (!first.empty()) {
		name += ", ";
		name += first;
	}
	return true;
}

bool Entities::tournament(int64_t id, Tournament& t) const {
	Cursor c{raw(TOURNAMENT, id)};
	return !c.b.empty() && c.string(t.place) && c.string(t.title) &&
	       c.i32(t.start);
}

errorT Database::open(std::string_view path, std::string& why) {
	close();
	std::string stem(path);
	if (stem.size() > 5) {
		auto ext = stem.substr(stem.size() - 5);
		std::transform(ext.begin(), ext.end(), ext.begin(),
		               [](unsigned char c) { return char(std::tolower(c)); });
		if (ext == ".2cbh")
			stem.resize(stem.size() - 5);
	}
	if (auto err = headers.open(stem + ".2cbh", why))
		return err;
	if (auto err = moves.open(stem + ".2cbg")) {
		why = "cannot open the .2cbg file";
		return err;
	}
	if (auto err = entities.open(stem + ".2lid", why))
		return err;

	// A database may have no annotation file; one that is there must open.
	auto cba = stem + ".2cba";
	auto u8 = reinterpret_cast<const char8_t*>(cba.data());
	std::error_code ec;
	if (std::filesystem::exists(std::filesystem::path(u8, u8 + cba.size()),
	                            ec)) {
		if (auto err = annotations.open(cba)) {
			why = "cannot open the .2cba file";
			return err;
		}
		hasAnnotations = true;
	}
	return OK;
}

void Database::close() {
	headers.close();
	moves.close();
	annotations.close();
	hasAnnotations = false;
	entities.close();
}

errorT HeaderTable::open(std::string_view path, std::string& why) {
	close();
	count_ = 0;
	recordSize_ = 0;
	version_ = 0;
	if (auto err = file_.open(path)) {
		why = "cannot open the .2cbh file";
		return err;
	}
	const auto size = file_.size();
	const auto head = file_.view(0, 0x0e);
	if (head.empty()) {
		why = ".2cbh file too short";
		return ERROR_BadMagic;
	}
	// The record size is at 0x0a: 192 up to the 2026 databases, 208 in the
	// 2027 ones, whose version byte at 0x0d went from 5 to 6.
	const auto rs = le_i16(head, 0x0a);
	if (rs < int(kMinRecordSize) || rs > int(kMaxRecordSize)) {
		why = ".2cbh record size " + std::to_string(rs) + " not supported";
		return ERROR_FileVersion;
	}
	if (size < uint64_t(rs) || size % uint64_t(rs) != 0) {
		why = ".2cbh size " + std::to_string(size) +
		      " is not a multiple of its record size " + std::to_string(rs);
		return ERROR_Corrupt;
	}
	const auto n = size / uint64_t(rs) - 1;
	if (n > std::numeric_limits<uint32_t>::max()) {
		why = ".2cbh holds too many records";
		return ERROR_Corrupt;
	}
	count_ = static_cast<uint32_t>(n);
	recordSize_ = static_cast<size_t>(rs);
	version_ = head[0x0d];
	return OK;
}

} // namespace cb2
