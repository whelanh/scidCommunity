/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Part of scidCommunity (Shane's Chess Information Database).
 * scidCommunity's own code, not imported from Scid vs. PC: see the notice below.
 */
//////////////////////////////////////////////////////////////////////
//
//  FILE:       cql_pgnparse_adapter.cpp
//
//  Part of:    Scid (Shane's Chess Information Database) / scidCommunity
//
//  Notice:     This file is scidCommunity's own code: it is NOT part of
//              the imported Chess Query Language engine from Scid vs. PC.
//              See cql_pgnparse_adapter.h for what it is and why it exists.
//
//////////////////////////////////////////////////////////////////////

#include "cql_pgnparse_adapter.h"

#include "game.h"
#include "pgnparse.h" // scidCommunity's own buffer oriented PGN parser

#include <csetjmp>
#include <cstddef>

//////////////////////////////////////////////////////////////////////
// Game number (see cql_pgnparse_adapter.h)
//////////////////////////////////////////////////////////////////////

namespace {
/// Per thread: each thread matches its own games, so the game number the
/// engine reads (for :gamenumber, echoes and its per-game caches) must not be
/// shared (see cqlglobals.h). sc_search_cql() sets it per game in every thread.
thread_local unsigned cqlGameNumber = 0;
} // namespace

unsigned CqlGameNumber() { return cqlGameNumber; }

void CqlSetGameNumber(unsigned number) { cqlGameNumber = number; }

//////////////////////////////////////////////////////////////////////
// Current move / stalemate (see cql_pgnparse_adapter.h)
//////////////////////////////////////////////////////////////////////

moveT *CqlCurrentMove(Game *game) { return game->currentLocation().move; }

bool CqlIsStaleMate(Position *position) {
	if (position->IsKingInCheck())
		return false;
	MoveList mlist;
	position->GenerateMoves(&mlist);
	return mlist.Size() == 0;
}

squareT CqlSquareMove(squareT square, directionT direction) {
	int fyle = square_Fyle(square) + ((direction & RIGHT) ? 1 : 0) -
	           ((direction & LEFT) ? 1 : 0);
	int rank = square_Rank(square) + ((direction & UP) ? 1 : 0) -
	           ((direction & DOWN) ? 1 : 0);
	if (fyle < 0 || fyle > 7 || rank < 0 || rank > 7)
		return NULL_SQUARE;
	return square_Make(fyle, rank);
}

//////////////////////////////////////////////////////////////////////
// MFile
//////////////////////////////////////////////////////////////////////

MFile::~MFile() {
	if (handle)
		std::fclose(handle);
}

errorT MFile::Open(const char *name, fileModeT fmode) {
	if (!name || fmode != FMODE_ReadOnly)
		return ERROR_FileMode;
	if (handle) {
		std::fclose(handle);
		handle = nullptr;
	}
	content.clear();
	contentLoaded = false;
	handle = std::fopen(name, "rb");
	return handle ? OK : ERROR_FileOpen;
}

void MFile::skipNonAscii() {
	if (!handle)
		return;
	int ch;
	while ((ch = std::fgetc(handle)) != EOF) {
		if (static_cast<unsigned char>(ch) > 127)
			continue;
		std::ungetc(ch, handle);
		return;
	}
}

const std::string &MFile::remainingContent() {
	if (!contentLoaded && handle) {
		char buffer[64 * 1024];
		std::size_t got;
		while ((got = std::fread(buffer, 1, sizeof(buffer), handle)) > 0)
			content.append(buffer, got);
		contentLoaded = true;
	}
	return content;
}

//////////////////////////////////////////////////////////////////////
// PgnParser
//////////////////////////////////////////////////////////////////////

struct PgnParser::Impl {
	MFile *file;
	std::size_t pos = 0;
};

namespace {

/// Same trick as pgnParseGame(): do not warn about a missing result at the
/// end of the input, we are called once per game and stop on ERROR_NotFound.
struct VisitorNoEOF : public PgnVisitor {
	explicit VisitorNoEOF(Game &g) : PgnVisitor(g) {}
	void visitPGN_inputEOF() {}
};

} // namespace

PgnParser::PgnParser(MFile *inputFile) : impl(new Impl{inputFile}) {}

PgnParser::~PgnParser() { delete impl; }

errorT PgnParser::ParseGame(Game *game) {
	if (!impl || !impl->file || !game)
		return ERROR_BadArg;

	const std::string &input = impl->file->remainingContent();
	const char *begin = input.data();
	const char *end = begin + input.size();

	while (impl->pos < input.size()) {
		VisitorNoEOF visitor(*game);
		auto parsed =
		    pgn::parse_game({begin + impl->pos, end}, visitor);
		const bool gameStarted = parsed.second;
		const std::size_t consumed = parsed.first;
		impl->pos += consumed;
		if (gameStarted && consumed > 0)
			return OK;
		if (consumed == 0) // no progress: nothing left to parse
			break;
	}
	return ERROR_NotFound;
}

//////////////////////////////////////////////////////////////////////
// Query driver (see cql_pgnparse_adapter.h)
//
// The engine reports every error - syntax and runtime alike - with
// longjmp(), so each call into it is guarded by its own setjmp() here. The
// imported functions below are declared rather than included for the reason
// given in cqlnodematch.cpp: the engine's own headers cannot be pulled into
// another translation unit.
//////////////////////////////////////////////////////////////////////

extern thread_local std::jmp_buf jump_buffer;   // cqlexit.cpp
extern thread_local const char* cqlErrMsg;      // cqlexit.h
extern thread_local bool CqlSilent;             // cqlglobals.h
bool CqlParseBuffer(const char *buffer); // parser.cpp
void CqlReset();                   // parser.cpp
bool CqlMatchGame(Game *game);     // cqlnodematch.cpp
extern thread_local uint CqlMatchPlyFirst;      // cqlnodematch.cpp

namespace {

/// The engine's message for the error it last raised, or a generic one: not
/// every path to longjmp() sets cqlErrMsg.
std::string engineError() {
	if (cqlErrMsg)
		return {cqlErrMsg};
	return {"Error reported back from CQL engine"};
}

} // namespace

bool CqlQueryParse(const char *query, bool silent, std::string *error) {
	if (!query) {
		if (error)
			*error = "No CQL query given";
		return false;
	}

	// Guard the reset as well: it drives the engine's own cleanup, which can
	// raise an error of its own (and so longjmp()), and a longjmp() to a frame
	// that has already returned would take the application down.
	cqlErrMsg = nullptr;
	if (setjmp(jump_buffer) != 0) {
		if (error)
			*error = engineError();
		return false;
	}

	// Start from a known-clean engine: a previous query - including one that
	// was abandoned by an error - may still hold a parse tree, tokens and
	// mark state.
	CqlReset();

	// The engine reads CqlSilent while it builds the parse tree (CqlNode's
	// constructor decides whether matched moves get a "MATCH" comment), so it
	// has to be set before parsing, not per game. The polarity is upstream's:
	// silent means no annotations.
	CqlSilent = silent;

	CqlParseBuffer(query);

	// The parse tree is complete: flatten the game-level filters the search
	// driver can answer from an index entry instead of decoding the game.
	CqlQueryPrepareIndexFilters();

	// A syntax error never reaches this point: it longjmp()s to the setjmp()
	// above.
	return true;
}

CqlMatchResult CqlQueryMatchGame(Game *game, unsigned *firstPly,
                                 std::string *error) {
	if (!game)
		return CqlMatchResult::Error;
	if (firstPly)
		*firstPly = 0;

	// Reset the game position and the variation stack the engine walks before
	// every game, so nothing from the previous game can leak into this one.
	// The engine's own per-game state (match count, bound variables, cached
	// legal moves) is keyed on the game number (see MarkBoard::getLegalMoves())
	// and reset by CqlNode::match_game(), so the caller only has to have set
	// the number with CqlSetGameNumber().
	game->MoveToStart();

	cqlErrMsg = nullptr;
	if (setjmp(jump_buffer) != 0) {
		if (error)
			*error = engineError();
		return CqlMatchResult::Error;
	}

	if (!CqlMatchGame(game))
		return CqlMatchResult::NoMatch;

	if (firstPly)
		*firstPly = CqlMatchPlyFirst;
	return CqlMatchResult::Match;
}

void CqlQueryReset() {
	cqlErrMsg = nullptr;
	if (setjmp(jump_buffer) != 0)
		return; // the engine could not clean up; the next parse tries again

	CqlReset();
	CqlQueryPrepareIndexFilters(); // the parse tree is gone: forget its filters
	CqlSetGameNumber(0);
}
