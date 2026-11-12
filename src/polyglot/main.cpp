
// main.cpp

// includes

#include <cerrno>
#include <csignal>
#include <cstdio>
#ifdef WINCE
#include <stdlib.h>
#else
#include <cstdlib>
#endif
#include <cstring>

//#include "adapter.h"
#include "attack.h"
#include "board.h"
#include "book.h"
// #include "engine.h"
// #include "epd.h"
#include "fen.h"
#include "hash.h"
#include "list.h"
#include "main.h"
#include "move.h"
#include "move_do.h"
#include "move_gen.h"
#include "move_legal.h"
#include "obrbook.h"
#include "san.h"
#include "../polyglot.h"
#include <string>
#include <utility>
#include <vector>
#include "option.h"
#include "piece.h"
#include "square.h"
// #include "uci.h"
#include "util.h"

// variables

static bool Init;

// prototypes

// static void parse_option ();
// static bool parse_line   (char line[], char * * name_ptr, char * * value_ptr);

// functions
/////////////////////////////////////////////////////////////////////
int polyglot_open(const char * BookFile, const int BookNumber) {
	int res = 0;

	// init
   Init = false;

   util_init();
   option_init();

   square_init();
   piece_init();
   attack_init();

   hash_init();

   // opening book
  book_clear(BookNumber);
  obr_close(BookNumber);
  // OpenBook Rich files are detected by their magic number (read-only).
  if (obr_open(BookFile, BookNumber)) {
    return 1;
  }
  res = scid_book_open(BookFile, BookNumber);

	return res;
}
/////////////////////////////////////////////////////////////////////
int polyglot_close(const int BookNumber) {
  int res = 0;
  if (obr_is_open(BookNumber)) {
    obr_close(BookNumber);
    book_clear(BookNumber);
    return 0;
  }
	res = scid_book_close(BookNumber);
  book_clear(BookNumber);
	return res;
}
/////////////////////////////////////////////////////////////////////
bool polyglot_is_obr(const int BookNumber) { return obr_is_open(BookNumber); }
/////////////////////////////////////////////////////////////////////
// legal moves of an .obr position, with their SAN
static void obr_legal_moves(const board_t* board,
                            const std::vector<obr_move_t>& in,
                            std::vector<std::pair<const obr_move_t*, std::string>>& out) {
  out.clear();
  for (const auto& m : in) {
    if (m.status != 0 || m.move == MoveNone || !move_is_legal(m.move, board))
      continue;
    char san[256];
    if (!move_to_san(m.move, board, san, sizeof(san)))
      continue;
    out.emplace_back(&m, san);
  }
}
/////////////////////////////////////////////////////////////////////
// fill parameter moves with opening book moves
std::vector<std::tuple<int16_t, uint8_t, uint8_t>>
polyglot_moves(char *moves, const char *fen, const int BookNumber) {
  board_t board;
  board_from_fen(&board, fen);
  if (obr_is_open(BookNumber)) {
    // Same output as for Polyglot books: " SAN pct%" with the share of games,
    // so every existing caller of "sc_book moves" works with .obr files too.
    std::vector<std::tuple<int16_t, uint8_t, uint8_t>> extra;
    moves[0] = '\0';
    obr_stats_t pos;
    std::vector<obr_move_t> raw;
    int t;
    if (!obr_probe(&board, BookNumber, pos, raw, t))
      return extra;
    std::vector<std::pair<const obr_move_t*, std::string>> legal;
    obr_legal_moves(&board, raw, legal);
    double sum = 0;
    for (auto& [m, san] : legal)
      sum += m->has_child ? m->child.games : 0;
    size_t used = 0;
    for (auto& [m, san] : legal) {
      double share = (sum > 0 && m->has_child) ? 100.0 * m->child.games / sum : 0;
      if (share < 0.5) share = 1; // keep every book move selectable
      char tmp[300];
      int n = std::snprintf(tmp, sizeof(tmp), " %s %.0f%%", san.c_str(), share);
      if (n < 0 || used + n >= 1000) break;
      std::strcat(moves, tmp);
      used += n;
      extra.emplace_back(0, 0, 0);
    }
    return extra;
  }
  return scid_book_disp(&board, moves, BookNumber);
}
/////////////////////////////////////////////////////////////////////
// detailed .obr information for the current position
bool polyglot_obr_moves(const char* fen, const int BookNumber, PolyglotObrPos& pos,
                        std::vector<PolyglotObrMove>& out) {
  out.clear();
  pos = PolyglotObrPos{};
  if (!obr_is_open(BookNumber))
    return false;
  board_t board;
  board_from_fen(&board, fen);
  obr_stats_t ps;
  std::vector<obr_move_t> raw;
  int t;
  if (!obr_probe(&board, BookNumber, ps, raw, t))
    return false;
  auto fill = [](const obr_stats_t& s, PolyglotObrStats& d) {
    d.games = s.games;
    d.white_wins = s.white_wins;
    d.draws = s.draws;
    d.black_wins = s.black_wins;
    d.avg_rating = s.rating_games ? int(double(s.rating_sum) / s.rating_games + 0.5) : 0;
    d.performance = s.perf_games ? int(double(s.perf_sum) / s.perf_games + 0.5) : 0;
    d.recommendation = s.recommendation;
  };
  pos.found = true;
  pos.transform = t;
  fill(ps, pos.stats);
  std::vector<std::pair<const obr_move_t*, std::string>> legal;
  obr_legal_moves(&board, raw, legal);
  const bool black_moves = board.turn == Black;
  for (auto& [m, san] : legal) {
    PolyglotObrMove r;
    r.san = san;
    r.nag = m->annotation & 0x1F;
    r.flags = m->annotation & 0xE0;
    r.has_stats = m->has_child;
    if (m->has_child) {
      fill(m->child, r.stats);
      uint32_t mover = black_moves ? m->child.black_wins : m->child.white_wins;
      r.score = m->child.games ? 100.0 * (mover + 0.5 * m->child.draws) / m->child.games : 0;
    }
    out.push_back(r);
  }
  return true;
}
/////////////////////////////////////////////////////////////////////
// find moves to positions in the book
int polyglot_positions (char *moves, const char *fen, const int BookNumber) {
  board_t board[1];
  board_from_fen(board, fen);
  if (obr_is_open(BookNumber)) {
    moves[0] = '\0';
    list_t legal[1];
    gen_legal_moves(legal, board);
    size_t used = 0;
    for (int i = 0; i < list_size(legal); i++) {
      int move = list_move(legal, i);
      board_t next = *board;
      move_do(&next, move);
      if (!obr_contains(&next, BookNumber))
        continue;
      char tmp[256] = {' '};
      move_to_san(move, board, tmp + 1, 255);
      size_t n = std::strlen(tmp);
      if (used + n >= 190) break; // caller buffer is 200 bytes
      std::strcat(moves, tmp);
      used += n;
    }
    return 0;
  }
  scid_position_book_disp(board,moves, BookNumber);
  return 0;
}


// quit()

void quit() {

//    char string[StringSize];

   my_log("POLYGLOT *** QUIT ***\n");

   if (Init) {

//       engine_send(Engine,"quit");

      // wait for the engine to quit

      while (true) {
//          engine_get(Engine,string,StringSize); // HACK: calls exit() on receiving EOF
      }

//       uci_close(Uci);
   }

   exit(EXIT_SUCCESS);
}

// end of main.cpp

