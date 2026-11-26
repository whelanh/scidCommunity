/*
 * Copyright (C) 2026  Fulvio Benini
 *
 * This file is part of Scid (Shane's Chess Information Database).
 *
 * Scid is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Scid is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Scid.  If not, see <http://www.gnu.org/licenses/>.
 */

/** @file
 * Defines the engine used to search for a position (or a set of positions)
 * in the main line and/or in the variations of a set of games.
 */

#ifndef SEARCHBOARD_H
#define SEARCHBOARD_H

#include "common.h"
#include "game.h"
#include "position.h"
#include <cstdint>
#include <vector>

class Progress;
class scidBaseT;

/// Criteria used to search a position.
struct BoardSearchOptions {
	/// How strictly a position must match.
	gameExactMatchT matchType = GAME_EXACT_MATCH_Exact;
	/// Also search the variations, not just the main line.
	bool searchInVariations = false;
	/// Match the position with the colors reversed as well.
	bool ignoreColors = false;
	/// Use the home pawns signature stored in the index to skip games.
	/// Only meaningful for @c matchType Exact and Pawns; ignored otherwise.
	bool useIndexOptimizations = true;
};

enum class BoardSearchStatus {
	Ok,       ///< The search completed.
	Cancelled ///< The search was interrupted by the Progress object.
};

struct BoardSearchResult {
	BoardSearchStatus status = BoardSearchStatus::Ok;
	/// One element for each searched game: 0 if the position was not found,
	/// otherwise the 1-based ply of the match, capped to 255. The main line
	/// is preferred; if the position is found only in a variation, the ply is
	/// the one along that variation.
	std::vector<uint8_t> ply;
	/// True if at least one game could not be read.
	bool readError = false;
};

/**
 * Search @e positions in the games listed in @e candidates.
 *
 * Games are searched in parallel. The searched positions are OR-ed together:
 * a game matches as soon as one of them is reached. The side to move must
 * match as well; castling and en-passant rights are ignored.
 *
 * @param base:       the database that contains the games.
 * @param candidates: the game numbers to search.
 * @param positions:  the positions to search for (must not be empty).
 * @param options:    the search criteria.
 * @param progress:   used to report the search progress and to cancel it.
 * @returns the match ply (1-based) of each game, in the same order as
 *          @e candidates, and the search status.
 */
BoardSearchResult boardSearch(const scidBaseT& base,
                              const std::vector<gamenumT>& candidates,
                              const std::vector<Position>& positions,
                              const BoardSearchOptions& options,
                              const Progress& progress);

#endif
