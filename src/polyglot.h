#ifndef POLYGLOT_H
#define POLYGLOT_H

#include <cstdint>
#include <string>
#include <tuple>
#include <vector>

int polyglot_open			(const char * BookFile, const int BookNumber);
int polyglot_close		(const int BookNumber);

std::vector<std::tuple<int16_t, uint8_t, uint8_t>>
polyglot_moves(char* moves, const char* fen, const int BookNumber);

int polyglot_positions	(char *moves, const char *fen, const int BookNumber);
void scid_book_update	(char * probs, const int BookNumber);
int scid_book_movesupdate  (char *moves, char * probs, const int BookNumber, char *tempfile);

// OpenBook Rich (.obr) books: statistics-rich, read-only.
struct PolyglotObrStats {
	uint32_t games = 0;
	uint32_t white_wins = 0;
	uint32_t draws = 0;
	uint32_t black_wins = 0;
	int avg_rating = 0;     // 0 = unknown
	int performance = 0;    // 0 = unknown
	int recommendation = 0; // 0x80 green, 0x40 red, 0 none
};

struct PolyglotObrPos {
	bool found = false;
	int transform = 0; // != 0 when answered through an alias
	PolyglotObrStats stats;
};

struct PolyglotObrMove {
	std::string san;
	int nag = 0;   // 1 !, 2 ?, 3 !!, 4 ??, 5 !?, 6 ?!, 7/8 forced/only ...
	int flags = 0; // source book preference bits (0x20..0xE0)
	bool has_stats = false;
	PolyglotObrStats stats; // of the position reached by the move
	double score = 0;       // % scored by the side that plays the move
};

bool polyglot_is_obr(const int BookNumber);
bool polyglot_obr_moves(const char* fen, const int BookNumber, PolyglotObrPos& pos,
                        std::vector<PolyglotObrMove>& moves);

#endif
