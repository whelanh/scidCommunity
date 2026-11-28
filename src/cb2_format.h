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
 * Read-only access to a ChessBase 2CBH database (ChessBase 17 and later):
 * the files, the header-record table of `.2cbh` and its records.
 *
 * A database file is untrusted input. Every read is bounds-checked against
 * the mapped file, no size read from a file allocates memory unchecked, and
 * a damaged file yields an error, never a crash.
 */

#pragma once

#include "common.h"
#include "filemap.h"
#include <cstdint>
#include <span>
#include <string>
#include <string_view>
#include <vector>

namespace cb2 {

using Bytes = std::span<const unsigned char>;

/// @name Little- and big-endian integers at fixed offsets.
/// The caller has checked that the bytes are there.
///@{
inline uint16_t le_u16(Bytes b, size_t o) {
	return static_cast<uint16_t>(b[o] | (b[o + 1] << 8));
}
inline int16_t le_i16(Bytes b, size_t o) {
	return static_cast<int16_t>(le_u16(b, o));
}
inline uint32_t le_u32(Bytes b, size_t o) {
	return uint32_t(b[o]) | (uint32_t(b[o + 1]) << 8) |
	       (uint32_t(b[o + 2]) << 16) | (uint32_t(b[o + 3]) << 24);
}
inline int32_t le_i32(Bytes b, size_t o) {
	return static_cast<int32_t>(le_u32(b, o));
}
inline int64_t le_i64(Bytes b, size_t o) {
	return static_cast<int64_t>(uint64_t(le_u32(b, o)) |
	                            (uint64_t(le_u32(b, o + 4)) << 32));
}
inline uint32_t be_u32(Bytes b, size_t o) {
	return (uint32_t(b[o]) << 24) | (uint32_t(b[o + 1]) << 16) |
	       (uint32_t(b[o + 2]) << 8) | uint32_t(b[o + 3]);
}
inline int32_t be_i32(Bytes b, size_t o) {
	return static_cast<int32_t>(be_u32(b, o));
}
inline uint64_t be_u64(Bytes b, size_t o) {
	return (uint64_t(be_u32(b, o)) << 32) | be_u32(b, o + 4);
}
inline int64_t be_i64(Bytes b, size_t o) {
	return static_cast<int64_t>(be_u64(b, o));
}
///@}

/// A database file mapped read-only.
class File {
	FileMap<> map_;

public:
	/// Opens @p path (UTF-8). Returns OK or ERROR_FileOpen.
	errorT open(std::string_view path) {
		return map_.open_utf8(path, FMODE_ReadOnly);
	}
	void close() { map_.close(); }
	uint64_t size() const { return map_.size(); }

	/// The @p count bytes at @p offset, or an empty span when they do not all
	/// lie inside the file.
	Bytes view(uint64_t offset, size_t count) const {
		const auto size = map_.size();
		if (offset > size || count > size - offset || count == 0)
			return {};
		auto v = map_.view_at(static_cast<size_t>(offset), count);
		if (v.size() != count)
			return {};
		return {reinterpret_cast<const unsigned char*>(v.data()), v.size()};
	}

	/// Hints that the file will be read front to back.
	void sequential(bool on) { map_.setSequentialAccess(on); }
};

/// What a header record holds.
enum class RecordKind { Game, Text, Analysis, Unknown };

/// The fields of a 2CBH header record used by the importer. Records are 192
/// bytes up to the 2026 databases and 208 bytes from 2027 on; the first 192
/// bytes have the same layout in both, and only those are read.
class Record {
	Bytes b_;

public:
	/// Bytes of a record that are read; a record has at least this many.
	static constexpr size_t kLayoutSize = 192;

	Record() = default;
	explicit Record(Bytes b) : b_(b) {}

	bool valid() const { return b_.size() >= kLayoutSize; }
	Bytes bytes() const { return b_; }

	bool deleted() const { return b_[0] & 0x80; }
	RecordKind kind() const {
		switch (b_[2]) {
		case 1:
			return (b_[0] & 2) ? RecordKind::Text : RecordKind::Game;
		case 2:
			return RecordKind::Analysis;
		}
		return RecordKind::Unknown;
	}
	/// Offset of the move record in `.2cbg`.
	int64_t movesOffset() const { return le_i64(b_, 0x08); }
	/// Offset of the annotation record in `.2cba`.
	int64_t annotationsOffset() const { return le_i64(b_, 0x10); }
	/// @name Ids of the `.2lid` entities the game names.
	///@{
	int64_t white() const { return le_i64(b_, 0x18); }
	int64_t black() const { return le_i64(b_, 0x20); }
	int64_t tournament() const { return le_i64(b_, 0x28); }
	/// A player id.
	int64_t annotator() const { return le_i64(b_, 0x30); }
	int64_t source() const { return le_i64(b_, 0x38); }
	///@}
	/// 0 black won, 1 draw, 2 white won, 3 line, 4-6 the same by forfeit,
	/// 7 both lost.
	unsigned result() const { return b_[0x58]; }
	int16_t round() const { return le_i16(b_, 0x5a); }
	int16_t subround() const { return le_i16(b_, 0x5c); }
	int16_t whiteElo() const { return le_i16(b_, 0x60); }
	int16_t blackElo() const { return le_i16(b_, 0x70); }
	/// 0 none; 128-64127 an opening code (code / 128 - 1 is A00-E99);
	/// 64576 and above a Chess960 start position.
	uint16_t eco() const { return le_u16(b_, 0x80); }
	/// Number of full moves of the main line.
	int16_t moveCount() const { return le_i16(b_, 0x8a); }
	/// Packed as year << 9 | month << 5 | day; a part may be 0 (unknown).
	int32_t date() const { return le_i32(b_, 0xbc); }
};

/// The `.2cbh` file: a header record, then one record per game, text or
/// analysis, all of the size the header gives.
class HeaderTable {
	File file_;
	uint32_t count_ = 0;
	size_t recordSize_ = 0;
	unsigned version_ = 0;

public:
	/// Smallest and largest record size accepted.
	static constexpr size_t kMinRecordSize = Record::kLayoutSize;
	static constexpr size_t kMaxRecordSize = 4096;

	/// Opens @p path (UTF-8). On failure, @p why says what is wrong.
	errorT open(std::string_view path, std::string& why);
	void close() { file_.close(); }

	/// Number of records after the header record.
	uint32_t count() const { return count_; }
	size_t recordSize() const { return recordSize_; }
	/// The format version byte of the header record.
	unsigned version() const { return version_; }

	/// Record @p id, counted from 1; invalid when out of range.
	Record record(uint32_t id) const {
		if (id == 0 || id > count_)
			return {};
		return Record(file_.view(uint64_t(id) * recordSize_, recordSize_));
	}

	void sequential(bool on) { file_.sequential(on); }
};

/// @name Records of `.2cbg` (moves) and `.2cba` (annotations).
/// A frame is the magic `88 77 66 55 44 33 22 11`, the content size and the
/// spare size (int32), a big-endian checksum (u64), a tag (u16), the
/// content, the spare area and a trailing int64 equal to
/// content + spare + 34.
///@{
constexpr size_t kFrameHeader = 0x1a;
/// Largest content or spare area accepted; the largest seen in a Mega
/// Database is about 1.2 MB, a guiding text.
constexpr size_t kMaxFramePart = size_t(64) << 20;

struct Frame {
	uint16_t tag = 0;
	Bytes content;
};

/// Byte @e i of the checksum is the sum, modulo 256, of the @e i-th of eight
/// equal runs of the content; a trailing remainder is ignored. Content
/// shorter than eight bytes is its own checksum, little-endian.
uint64_t frameChecksum(Bytes content);

/// Reads and checks the frame at @p offset of @p file. Returns nullptr on
/// success, else what is wrong.
const char* readFrame(const File& file, int64_t offset, Frame& out);
///@}

/// Text as ChessBase stores it: UTF-8 when the bytes are valid UTF-8, else
/// Windows-1252 (a byte the page leaves undefined keeps its value as a C1
/// control), so no byte is lost and the result is always valid UTF-8.
std::string decodeText(Bytes b);

/// A tournament of `.2lid`.
struct Tournament {
	std::string title;
	std::string place;
	int32_t start = 0; ///< A packed date, as Record::date().
};

/// The `.2lid` entity file: players, tournaments and others, each type in
/// fixed-size containers of its own, interleaved by id.
class Entities {
	File file_;
	size_t headerSize_ = 0;
	size_t blockSize_ = 0;
	struct Type {
		size_t size;
		int64_t count;
		size_t offset; ///< Of the type's container within an id's block.
	};
	std::vector<Type> types_;

public:
	enum { PLAYER = 0, TOURNAMENT = 1 };

	errorT open(std::string_view path, std::string& why);
	void close() { file_.close(); }

	/// The bytes stored for @p id of @p type, without their length field;
	/// empty for an unused id or one the file does not hold.
	Bytes raw(size_t type, int64_t id) const;

	/// Player @p id as "Last, First" (or "Last"); false when there is none.
	bool player(int64_t id, std::string& name) const;
	bool tournament(int64_t id, Tournament& t) const;
};

/// An open 2CBH database: `.2cbh`, `.2cbg`, `.2lid` and, when present,
/// `.2cba`.
class Database {
public:
	HeaderTable headers;
	File moves;
	File annotations;
	bool hasAnnotations = false;
	Entities entities;

	/// Opens the database whose `.2cbh` file is @p path (UTF-8); the other
	/// files share its name. On failure, @p why says what is wrong.
	errorT open(std::string_view path, std::string& why);
	void close();
};

} // namespace cb2
