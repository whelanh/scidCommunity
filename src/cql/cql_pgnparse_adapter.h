//////////////////////////////////////////////////////////////////////
//
//  FILE:       cql_pgnparse_adapter.h
//
//  Part of:    Scid (Shane's Chess Information Database) / scidCommunity
//
//  Notice:     This file is scidCommunity's own code: it is NOT part of
//              the imported Chess Query Language engine from Scid vs. PC.
//
//  Purpose:    The imported CQL engine (src/cql/*.cpp) is written against
//              Scid vs. PC's file oriented PGN reader:
//
//                MFile      *input = new MFile;
//                input->Open(name, FMODE_ReadOnly);
//                input->skipNonAscii();
//                PgnParser parser(input);
//                while (parser.ParseGame(game) != ERROR_NotFound) ...
//
//              scidCommunity has neither class: its PGN reader is the
//              buffer oriented pgnParseGame() of src/pgnparse.h, and the
//              MFile abstraction was retired.  This adapter re-creates
//              exactly the members the engine uses on top of our parser,
//              so the imported tree stays recognizable and no upstream
//              file has to be rewritten to fit our API.
//
//////////////////////////////////////////////////////////////////////

#ifndef CQL_PGNPARSE_ADAPTER_H
#define CQL_PGNPARSE_ADAPTER_H

#include <cstdio>
#include <string>

#include "common.h" // fileModeT
#include "error.h"  // errorT

class Game;

// ---------------------------------------------------------------------
// Type compatibility for the imported engine.
// scidvspc's common.h exports the position board as the array typedef
//   typedef pieceT boardT[66];
// scidCommunity has no boardT: Position::GetBoard() returns a const
// pieceT* over the 64 squares followed by the COLOR_SQUARE/NULL_SQUARE
// sentinels.  The engine only reads through it (util::my_dump_board()).
// ---------------------------------------------------------------------
using boardT = const pieceT *;

// ---------------------------------------------------------------------
// Game number.
// scidvspc's Game carries a GameNumber field (GetNumber()/SetNumber());
// scidCommunity's Game does not - the game number belongs to the database
// IndexEntry / GameView.  The imported engine uses the number only to label
// and de-duplicate the game it is currently examining (echoes, debug output,
// :gamenumber ranges), so it is kept here instead, and the search driver
// sets it once per game before calling CqlMatchGame().
// ---------------------------------------------------------------------
unsigned CqlGameNumber();
void CqlSetGameNumber(unsigned number);

// ---------------------------------------------------------------------
// Current move node.
// scidvspc's Game exposed the raw moveT* node of the current position
// (GetCurrentMoveCQL()), which the engine uses as an opaque identity handle.
// scidCommunity keeps that pointer private but hands it out inside
// currentLocation(); this returns the same thing.
// ---------------------------------------------------------------------
struct moveT;
moveT *CqlCurrentMove(Game *game);

// ---------------------------------------------------------------------
// Stalemate.
// scidCommunity's Position has IsKingInMate() but no IsStaleMate(); this
// reproduces scidvspc's Position::IsStaleMate() with our own move generator.
// ---------------------------------------------------------------------
class Position;
bool CqlIsStaleMate(Position *position);

// ---------------------------------------------------------------------
// Square arithmetic.
// scidCommunity has no sqMove[][] table; this reproduces scidvspc's
// square_Move(sq, dir), returning NULL_SQUARE when the step leaves the board.
// ---------------------------------------------------------------------
squareT CqlSquareMove(squareT square, directionT direction);

// ---------------------------------------------------------------------
// Query driver surface.
// src/tkscid.cpp implements the Tcl side of "sc_search cql" but cannot see
// the engine itself: the imported headers are not self contained enough to
// be included from another translation unit (see the note in
// cqlnodematch.cpp), and every engine error is reported with longjmp() to a
// jmp_buf, so the jump has to be set in the frame that calls the engine.
// These four functions are the whole of src/cql/ that the search driver sees.
// ---------------------------------------------------------------------

/**
 * Parses a CQL query, discarding any previously parsed one.
 * @param query:         the CQL source, as typed by the user.
 * @param silent:        run the engine in silent mode (upstream's CqlSilent):
 *                       matched moves are not annotated with "MATCH" and the
 *                       engine may cache a little less. Scid vs. PC derives
 *                       this from its "Allow Comments" option; the driver
 *                       passes Scid vs. PC's silentSwitch. Annotations, when
 *                       enabled, only exist in the Game passed to
 *                       CqlQueryMatchGame() and are never written back.
 * @param error:         set to the engine's message when parsing fails.
 * @returns true when the query parsed, false on a syntax error (which is a
 *          normal, reportable failure - the engine longjmp()s out of its own
 *          parser and the jump is caught here).
 */
bool CqlQueryParse(const char *query, bool silent, std::string *error);

/// Outcome of matching one game; Error means the engine raised an error and
/// the search cannot continue.
enum class CqlMatchResult { Error = -1, NoMatch = 0, Match = 1 };

/**
 * Matches one game against the parsed query.
 * The caller must set the game number with CqlSetGameNumber() first: the
 * engine keys its per game caches on it.
 * @param game:     the game to match; its position and variation stack are
 *                  reset to the start of the game before matching.
 * @param firstPly: set to the ply of the first match (0 = the start position)
 *                  when the result is Match.
 * @param error:    set to the engine's message when the result is Error.
 */
CqlMatchResult CqlQueryMatchGame(Game *game, unsigned *firstPly,
                                 std::string *error);

/// Releases the parsed query and resets the engine's global state, so the next
/// CqlQueryParse() starts from a clean engine. Safe to call at any time and
/// after a failed parse or match.
void CqlQueryReset();

/**
 * Minimal replacement for Scid vs. PC's MFile: a read-only regular file
 * handle, with the extra skipNonAscii() member scidvspc added for CQL.
 */
class MFile {
public:
	MFile() = default;
	MFile(const MFile &) = delete;
	MFile &operator=(const MFile &) = delete;
	~MFile();

	errorT Open(const char *name, fileModeT fmode);
	/// Discard leading non ASCII bytes (a UTF-8 BOM, typically) so the
	/// parser starts on a '[' of the first tag section.
	void skipNonAscii();

	/// The bytes left in the file after skipNonAscii(); read on first use.
	const std::string &remainingContent();

private:
	std::FILE *handle = nullptr;
	std::string content;
	bool contentLoaded = false;
};

/**
 * Minimal replacement for Scid vs. PC's PgnParser: reads the games of the
 * file owned by the MFile, one Game per ParseGame() call, by running
 * scidCommunity's own pgn::parse_game() on the remaining buffer.
 */
class PgnParser {
public:
	explicit PgnParser(MFile *inputFile);
	PgnParser(const PgnParser &) = delete;
	PgnParser &operator=(const PgnParser &) = delete;
	~PgnParser();

	/// Parse the next game of the file into @e game.
	/// @returns OK when a game was read, ERROR_NotFound at end of input.
	errorT ParseGame(Game *game);

private:
	struct Impl;
	Impl *impl;
};

#endif // CQL_PGNPARSE_ADAPTER_H
