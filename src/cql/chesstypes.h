#pragma once
#include "common.h"
#include "game.h"
#include "util.h"
typedef int markT;

inline bool color_valid(colorT c) {return c==WHITE || c==BLACK;}
const char* color_string(colorT c);
bool file_valid(int f);
bool rank_valid(int r);
char file_to_char_cql(int f);
char rank_to_char_cql(int r);
bool piece_valid(pieceT p);
inline bool square_valid(int s){return s>=0&&s<64;}
bool direction_valid(directionT d);
inline squareT square_make(int f, int r){return square_Make((fyleT)f,(rankT)r);}
squareT square_make(int f, int r);
void square_print(squareT);
char piece_to_char(pieceT);
bool piece_valid(pieceT);
inline int square_rank(int s){return square_Rank(s);}
inline int square_file(int s){return square_Fyle(s);}
char* square_to_string(squareT);
const char * direction_to_string(directionT);
const char * result_to_string(resultT);
bool mark_valid(markT mark);
