
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
#include "move_gen.h"
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
  res = scid_book_open(BookFile, BookNumber);

	return res;
}
/////////////////////////////////////////////////////////////////////
int polyglot_close(const int BookNumber) {
  int res = 0;
	res = scid_book_close(BookNumber);
  book_clear(BookNumber);
	return res;
}
/////////////////////////////////////////////////////////////////////
// fill parameter moves with opening book moves
std::vector<std::tuple<int16_t, uint8_t, uint8_t>>
polyglot_moves(char *moves, const char *fen, const int BookNumber) {
  board_t board;
  board_from_fen(&board, fen);
  return scid_book_disp(&board, moves, BookNumber);
}
/////////////////////////////////////////////////////////////////////
// find moves to positions in the book
int polyglot_positions (char *moves, const char *fen, const int BookNumber) {
  board_t board[1];
  board_from_fen(board, fen);
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

