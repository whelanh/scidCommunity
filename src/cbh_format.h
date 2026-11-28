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

/** @file
 * Read-only access to a classic ChessBase database (`.cbh`, ChessBase 6 to
 * 16): 46-byte big-endian header records, the move and annotation records
 * they point at, and the entity files. The result, ECO, date and text
 * encodings are those of 2CBH, and the accessors have the names of the
 * cb2:: ones, so that CodecCB2 reads both formats with the same code.
 *
 * A database file is untrusted input, as in cb2_format.h.
 *
 * shortcut: guiding texts (skipped by the importer), the source and team
 * files, and the medals of the header record are not read; add them if the
 * importer ever has a use for them.
 */

#pragma once

#include "cb2_annotations.h"
#include "cb2_format.h"
#include <string>
#include <string_view>

namespace cbh {

using cb2::Bytes;
using cb2::File;

inline uint16_t be_u16(Bytes b, size_t o) {
	return static_cast<uint16_t>((b[o] << 8) | b[o + 1]);
}
inline uint32_t be_u24(Bytes b, size_t o) {
	return (uint32_t(b[o]) << 16) | (uint32_t(b[o + 1]) << 8) | b[o + 2];
}

/// A header record. The offsets of the moves and annotations are given apart:
/// in databases over 4 GiB they come from `.cbj`.
class Record {
	Bytes b_;
	int64_t moves_ = 0;
	int64_t annotations_ = 0;

public:
	static constexpr size_t kSize = 46;

	Record() = default;
	Record(Bytes b, int64_t moves, int64_t annotations)
	    : b_(b), moves_(moves), annotations_(annotations) {}

	bool valid() const { return b_.size() == kSize; }

	bool deleted() const { return b_[0] & 0x80; }
	/// Bit 0 marks a used record, bit 1 a guiding text.
	cb2::RecordKind kind() const {
		if (!(b_[0] & 1))
			return cb2::RecordKind::Unknown;
		return (b_[0] & 2) ? cb2::RecordKind::Text : cb2::RecordKind::Game;
	}
	int64_t movesOffset() const { return moves_; }
	/// 0 when the game has no annotations.
	int64_t annotationsOffset() const { return annotations_; }
	/// @name Entity ids, of games only.
	///@{
	int64_t white() const { return be_u24(b_, 0x09); }
	int64_t black() const { return be_u24(b_, 0x0c); }
	int64_t tournament() const { return be_u24(b_, 0x0f); }
	int64_t annotator() const { return be_u24(b_, 0x12); }
	///@}
	int32_t date() const { return int32_t(be_u24(b_, 0x18)); }
	unsigned result() const { return b_[0x1b]; }
	int16_t round() const { return b_[0x1d]; }
	int16_t subround() const { return b_[0x1e]; }
	int16_t whiteElo() const { return int16_t(be_u16(b_, 0x1f)); }
	int16_t blackElo() const { return int16_t(be_u16(b_, 0x21)); }
	uint16_t eco() const { return be_u16(b_, 0x23); }
};

/// A text field of fixed width: the bytes up to the first zero. A UTF-8 text
/// cut at the width loses its incomplete last character.
std::string fieldText(Bytes field);

/// An entity file (`.cbp`, `.cbt`, `.cbc`): a little-endian header, then
/// records of one size; an id is a record's position, counted from 0.
class EntityFile {
	File file_;
	uint64_t header_ = 0;
	size_t record_ = 0;
	uint64_t count_ = 0;

public:
	/// Opens @p path, whose records must hold at least @p minData bytes.
	errorT open(const std::string& path, size_t minData, std::string& why);
	void close() { file_.close(); }
	/// The data of record @p id; empty for a deleted or missing one.
	Bytes data(int64_t id) const;
};

/// The entity files, with the lookups of cb2::Entities.
class Entities {
	EntityFile players_, tournaments_, annotators_;

public:
	/// Opens the entity files of the database whose stem is @p stem.
	errorT open(const std::string& stem, std::string& why);
	void close();

	/// Player @p id as "Last, First" (or "Last"); false when there is none.
	bool player(int64_t id, std::string& name) const;
	bool tournament(int64_t id, cb2::Tournament& t) const;
	bool annotatorName(int64_t id, std::string& name) const;
};

/// The offsets of a game in a `.cbj` record (at least 38 bytes), checked
/// against the low 32 bits that `.cbh` holds. False when they disagree.
bool wideOffsets(Bytes record, uint32_t shortMoves, uint32_t shortAnnotations,
                 int64_t& moves, int64_t& annotations);

/// An open classic database: `.cbh`, `.cbg`, the entity files and, when
/// present, `.cba`; `.cbj` when the others are over 4 GiB.
class Database {
	File headers_;
	uint32_t count_ = 0;
	File wide_;
	bool hasWide_ = false;
	uint64_t wideRecord_ = 0;
	uint32_t wideCount_ = 0;
	File moves_;
	File annotations_;
	bool hasAnnotations_ = false;

public:
	Entities entities;

	/// Largest annotation record read.
	static constexpr size_t kMaxAnnotationRecord = size_t(16) << 20;

	/// Opens the database whose `.cbh` file is @p path (UTF-8); the other
	/// files share its name. On failure, @p why says what is wrong.
	errorT open(std::string_view path, std::string& why);
	void close();

	/// Number of records after the header record.
	uint32_t count() const { return count_; }
	/// Record @p id, counted from 1; invalid when out of range or when its
	/// offsets cannot be read.
	Record record(uint32_t id) const;
	bool hasAnnotations() const { return hasAnnotations_; }

	/// The whole move record at @p offset. Returns nullptr or what is wrong.
	const char* readMoveRecord(int64_t offset, Bytes& out) const;
	/// The whole annotation record at @p offset.
	const char* readAnnotationRecord(int64_t offset, Bytes& out) const;

	void sequential(bool on);
};

/// Decodes the annotation record of game @p gameId. Texts, symbols, coloured
/// squares and arrows are kept; other types, each with its own size, are
/// skipped: their codes may mean something else in 2CBH. Positions count the
/// moves in stored order (GameAnnotations::storedOrder). On damage, what was
/// decoded before it is kept and GameAnnotations::stopped says why.
void parseAnnotations(Bytes record, uint32_t gameId,
                      cb2::GameAnnotations& out);

} // namespace cbh
