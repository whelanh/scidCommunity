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

#include <cstddef>

//////////////////////////////////////////////////////////////////////
// Game number (see cql_pgnparse_adapter.h)
//////////////////////////////////////////////////////////////////////

namespace {
unsigned cqlGameNumber = 0;
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
