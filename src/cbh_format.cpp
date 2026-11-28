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
#include <cctype>
#include <filesystem>
#include <limits>

namespace cbh {

namespace {

/// The smallest file header of `.cbg` and `.cba`: no record starts earlier.
constexpr int64_t kMinFileHeader = 10;
constexpr size_t kAnnotationHead = 14;
constexpr uint64_t kWideHeader = 32;
/// The bytes of a `.cbj` record that hold both offsets.
constexpr size_t kWideLayout = 0x1e + 8;

bool exists(const std::string& name) {
	auto u8 = reinterpret_cast<const char8_t*>(name.data());
	std::error_code ec;
	return std::filesystem::exists(std::filesystem::path(u8, u8 + name.size()),
	                               ec);
}

} // namespace

std::string fieldText(Bytes field) {
	const auto zero = std::find(field.begin(), field.end(), 0);
	auto b = field.first(size_t(zero - field.begin()));
	if (zero == field.end()) {
		// Drop the start of a character that the width cut off, when what
		// precedes it is UTF-8 with non-ASCII characters.
		for (size_t back = 1; back <= 3 && back <= b.size(); ++back) {
			const auto c = b[b.size() - back];
			if (c < 0x80)
				break;
			if (c < 0xc0)
				continue; // a continuation byte
			const size_t length = c >= 0xf0 ? 4 : c >= 0xe0 ? 3 : 2;
			if (length <= back)
				break;
			const auto head = b.first(b.size() - back);
			const std::string_view raw(
			    reinterpret_cast<const char*>(head.data()), head.size());
			const bool nonAscii = std::any_of(
			    head.begin(), head.end(), [](auto x) { return x >= 0x80; });
			if (nonAscii && cb2::decodeText(head) == raw)
				return std::string(raw);
			break;
		}
	}
	return cb2::decodeText(b);
}

errorT EntityFile::open(const std::string& path, size_t minData,
                        std::string& why) {
	close();
	count_ = 0;
	const auto name = path.substr(path.size() - 4);
	if (auto err = file_.open(path)) {
		why = "cannot open the " + name + " file";
		return err;
	}
	const auto h = file_.view(0, 28);
	if (h.empty() || cb2::le_i32(h, 0x08) != 1234567890) {
		why = name + " is not an entity file";
		return ERROR_BadMagic;
	}
	const auto data = cb2::le_i32(h, 0x0c);
	const auto extra = cb2::le_i32(h, 0x18);
	if (data < int32_t(minData) || data > (64 << 10) ||
	    (extra != 0 && extra != 4)) {
		why = name + " layout not supported";
		return ERROR_Corrupt;
	}
	header_ = 28 + uint64_t(extra);
	record_ = 9 + size_t(data);
	count_ = file_.size() > header_ ? (file_.size() - header_) / record_ : 0;
	return OK;
}

Bytes EntityFile::data(int64_t id) const {
	if (id < 0 || uint64_t(id) >= count_)
		return {};
	const auto r = file_.view(header_ + uint64_t(id) * record_, record_);
	// A deleted record has -999 as the left child of its search tree.
	if (r.empty() || cb2::le_i32(r, 0) == -999)
		return {};
	return r.subspan(9);
}

errorT Entities::open(const std::string& stem, std::string& why) {
	if (auto err = players_.open(stem + ".cbp", 50, why))
		return err;
	if (auto err = tournaments_.open(stem + ".cbt", 0x4a, why))
		return err;
	return annotators_.open(stem + ".cbc", 45, why);
}

void Entities::close() {
	players_.close();
	tournaments_.close();
	annotators_.close();
}

bool Entities::player(int64_t id, std::string& name) const {
	const auto d = players_.data(id);
	if (d.empty())
		return false;
	name = fieldText(d.first(30));
	const auto first = fieldText(d.subspan(30, 20));
	if (!first.empty()) {
		name += ", ";
		name += first;
	}
	return true;
}

bool Entities::tournament(int64_t id, cb2::Tournament& t) const {
	const auto d = tournaments_.data(id);
	if (d.empty())
		return false;
	t.title = fieldText(d.first(40));
	t.place = fieldText(d.subspan(40, 30));
	t.start = cb2::le_i32(d, 0x46);
	return true;
}

bool Entities::annotatorName(int64_t id, std::string& name) const {
	const auto d = annotators_.data(id);
	if (d.empty())
		return false;
	name = fieldText(d.first(45));
	return true;
}

bool wideOffsets(Bytes record, uint32_t shortMoves, uint32_t shortAnnotations,
                 int64_t& moves, int64_t& annotations) {
	if (record.size() < kWideLayout)
		return false;
	moves = cb2::be_i64(record, 0x1e);
	annotations = std::max<int64_t>(cb2::be_i64(record, 0x0c), 0);
	return moves >= 0 && uint32_t(moves) == shortMoves &&
	       uint32_t(annotations) == shortAnnotations;
}

errorT Database::open(std::string_view path, std::string& why) {
	close();
	std::string stem(path);
	if (stem.size() > 4) {
		auto ext = stem.substr(stem.size() - 4);
		std::transform(ext.begin(), ext.end(), ext.begin(),
		               [](unsigned char c) { return char(std::tolower(c)); });
		if (ext == ".cbh")
			stem.resize(stem.size() - 4);
	}

	if (auto err = headers_.open(stem + ".cbh")) {
		why = "cannot open the .cbh file";
		return err;
	}
	const auto size = headers_.size();
	if (size < Record::kSize || size % Record::kSize != 0 ||
	    size / Record::kSize - 1 > std::numeric_limits<uint32_t>::max()) {
		why = ".cbh size " + std::to_string(size) + " is not valid";
		return ERROR_Corrupt;
	}
	if (be_u16(headers_.view(0, Record::kSize), 0x03) != Record::kSize) {
		why = ".cbh record size not supported";
		return ERROR_FileVersion;
	}
	if (auto err = moves_.open(stem + ".cbg")) {
		why = "cannot open the .cbg file";
		return err;
	}
	if (auto err = entities.open(stem, why))
		return err;
	// A database may have no annotation file; one that is there must open.
	if (exists(stem + ".cba")) {
		if (auto err = annotations_.open(stem + ".cba")) {
			why = "cannot open the .cba file";
			return err;
		}
		hasAnnotations_ = true;
	}

	// The 32-bit offsets of .cbh do not reach past 4 GiB: .cbj has them.
	constexpr uint64_t limit = std::numeric_limits<uint32_t>::max();
	if (moves_.size() > limit ||
	    (hasAnnotations_ && annotations_.size() > limit)) {
		if (auto err = wide_.open(stem + ".cbj")) {
			why = "cannot open the .cbj file, needed over 4 GiB";
			return err;
		}
		const auto h = wide_.view(0, kWideHeader);
		const auto rs = h.empty() ? 0 : cb2::le_i32(h, 4);
		if (rs < int32_t(kWideLayout) || rs > 4096) {
			why = ".cbj layout not supported";
			return ERROR_Corrupt;
		}
		wideRecord_ = uint64_t(rs);
		wideCount_ = uint32_t(std::max(cb2::le_i32(h, 8), 0));
		hasWide_ = true;
	}
	count_ = uint32_t(size / Record::kSize - 1);
	return OK;
}

void Database::close() {
	headers_.close();
	wide_.close();
	moves_.close();
	annotations_.close();
	entities.close();
	count_ = wideCount_ = 0;
	hasWide_ = hasAnnotations_ = false;
}

Record Database::record(uint32_t id) const {
	if (id == 0 || id > count_)
		return {};
	const auto b = headers_.view(uint64_t(id) * Record::kSize, Record::kSize);
	if (b.empty())
		return {};
	const auto moves = cb2::be_u32(b, 0x01);
	const auto annotations = cb2::be_u32(b, 0x05);
	// A record past those .cbj holds keeps the .cbh offsets.
	if (!hasWide_ || id > wideCount_)
		return Record(b, moves, annotations);
	int64_t mo, ao;
	const auto w = wide_.view(kWideHeader + wideRecord_ * (id - 1),
	                          kWideLayout);
	// A guiding text keeps other fields where a game has its annotations.
	const bool text = b[0] & 2;
	if (!wideOffsets(w, moves, text ? 0 : annotations, mo, ao))
		return {};
	return Record(b, mo, ao);
}

const char* Database::readMoveRecord(int64_t offset, Bytes& out) const {
	if (offset < kMinFileHeader)
		return "move offset out of range";
	// A byte of flags, then the record's size.
	const auto head = moves_.view(uint64_t(offset), 4);
	if (head.empty())
		return "move offset out of range";
	const auto size = be_u24(head, 1);
	if (size < 4)
		return "move record too short";
	out = moves_.view(uint64_t(offset), size);
	return out.empty() ? "move record runs past the end of the file" : nullptr;
}

const char* Database::readAnnotationRecord(int64_t offset, Bytes& out) const {
	if (offset < kMinFileHeader)
		return "annotation offset out of range";
	const auto head = annotations_.view(uint64_t(offset), kAnnotationHead);
	if (head.empty())
		return "annotation offset out of range";
	const size_t size = cb2::be_u32(head, 0x0a);
	if (size < kAnnotationHead || size > kMaxAnnotationRecord)
		return "annotation record size out of range";
	out = annotations_.view(uint64_t(offset), size);
	return out.empty() ? "annotation record runs past the end of the file"
	                   : nullptr;
}

void Database::sequential(bool on) {
	headers_.sequential(on);
	moves_.sequential(on);
	if (hasAnnotations_)
		annotations_.sequential(on);
}

} // namespace cbh
