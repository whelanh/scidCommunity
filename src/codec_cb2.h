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
 * Reads the games of a ChessBase 2CBH database one by one, as Scid games,
 * for importing them into a Scid database.
 *
 * CodecCB2 has the source interface of CodecProxy::parseGames() (open(),
 * parseNext(), parseProgress(), parseErrors()), so games stream to the
 * destination database without the source ever being loaded whole. It is not
 * an ICodecDatabase: opening a .2cbh file as a database would hold all of its
 * games in memory.
 */

#pragma once

#include "cb2_format.h"
#include "cb2_moves.h"
#include "common.h"
#include "position.h"
#include <string>
#include <utility>
#include <vector>

class Game;

class CodecCB2 {
	cb2::Database db_;
	uint32_t next_ = 1;
	std::string log_;
	std::string summary_;
	size_t nLogged_ = 0;

	static constexpr uint32_t kNone = 0xffffffff;
	/// A move of the tree being read: Position::makeMove()'s arguments, and
	/// the links of a first-child/next-sibling tree. Node 0 is the start.
	struct Node {
		squareT from = 0;
		squareT to = 0;
		pieceT promo = EMPTY;
		uint32_t firstChild = kNone;
		uint32_t lastChild = kNone;
		uint32_t nextSibling = kNone;
	};
	std::vector<Node> nodes_;
	std::vector<std::pair<Position, uint32_t>> branches_;

	struct Counts {
		uint64_t games = 0;     ///< Games produced.
		uint64_t texts = 0;     ///< Guiding texts, skipped.
		uint64_t analyses = 0;  ///< Analyses, skipped.
		uint64_t deleted = 0;   ///< Deleted records, skipped.
		uint64_t unknown = 0;   ///< Records of an unknown kind, skipped.
		uint64_t damaged = 0;   ///< Games skipped: their moves are damaged.
		uint64_t incomplete = 0; ///< Games produced without some annotations.
	} counts_;

public:
	/// Most detail lines parseErrors() lists; the counts cover the rest.
	static constexpr size_t kMaxLogLines = 1000;
	/// Most variations open at once: each keeps a saved position. The
	/// deepest nesting measured in Mega Database 2026 is 74.
	static constexpr size_t kMaxVariationDepth = 1024;

	/// Opens the database whose .2cbh file is @p filename (UTF-8). Only
	/// FMODE_ReadOnly is supported.
	errorT open(const char* filename, fileModeT fmode);

	/**
	 * Reads the next game record into @p game, skipping deleted records,
	 * guiding texts, analyses and games that cannot be read.
	 * @returns ERROR_NotFound when there are no more games, OK otherwise.
	 */
	errorT parseNext(Game& game);

	/// Records read so far and the number of records.
	std::pair<size_t, size_t> parseProgress() const {
		return {next_ - 1, db_.headers.count()};
	}

	/// A summary of what was read and skipped, then one line per problem.
	const char* parseErrors();

	const Counts& counts() const { return counts_; }

private:
	void logRecord(uint32_t id, std::string_view what);
	void readTags(const cb2::Record& r, Game& game) const;
	/// Reads the moves of @p r into a tree, checking every word against the
	/// position; then gives them to @p game. nullptr or what is wrong.
	const char* readMoves(const cb2::Record& r, Game& game);
	const char* buildTree(const cb2::MoveRecord& mr, const Position& start);
	const char* writeTree(Game& game);
};
