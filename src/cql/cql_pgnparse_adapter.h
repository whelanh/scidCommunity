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
