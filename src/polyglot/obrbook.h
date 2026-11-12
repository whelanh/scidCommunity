// obrbook.h
// Reader for OpenBook Rich (.obr) opening books.
// Format: OBR v1, see docs/obr_format.md. Read-only.

#ifndef OBRBOOK_H
#define OBRBOOK_H

#include <cstdint>
#include <vector>

#include "board.h"

struct obr_stats_t {
	uint32_t games = 0;
	uint32_t white_wins = 0;
	uint32_t draws = 0;
	uint32_t black_wins = 0;
	uint32_t rating_games = 0;
	uint32_t rating_sum = 0;
	uint32_t perf_games = 0;
	uint32_t perf_sum = 0;
	uint8_t recommendation = 0;
	uint8_t flags = 0;
};

struct obr_move_t {
	int move = 0;           // polyglot move, already transformed for this position
	uint8_t annotation = 0; // bits 0-4 NAG, bits 5-7 source flags
	uint8_t status = 0;
	bool has_child = false;
	obr_stats_t child;      // stats of the resulting position (absolute colours)
};

// Return value of obr_open. A distinct "rejected" state lets the caller fail
// the load for a file that claims to be OBR but is corrupt, rather than
// mis-reading it as a writable Polyglot book.
enum obr_open_result {
	OBR_NOT_OBR = 0,   // not an OpenBook Rich file (e.g. a Polyglot .bin)
	OBR_OPENED = 1,    // opened successfully (read-only)
	OBR_REJECTED = -1, // OBR magic but invalid header or table layout
};

// Opens the file if it is a valid .obr book. Returns one of obr_open_result.
int obr_open(const char file_name[], const int BookNumber);
void obr_close(const int BookNumber);
bool obr_is_open(const int BookNumber);

// Looks up a position. Returns false if not in book.
bool obr_probe(const board_t* board, const int BookNumber, obr_stats_t& pos,
               std::vector<obr_move_t>& moves, int& transform);

bool obr_contains(const board_t* board, const int BookNumber);

#endif
