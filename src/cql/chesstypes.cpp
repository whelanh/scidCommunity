#include "chesstypes.h"
const char * direction_to_string(directionT d){
  switch(d){
  case UP: return "U";
  case DOWN: return "D";
  case LEFT: return "L";
  case RIGHT: return "R";
  case UP_LEFT: return "UL";
  case DOWN_LEFT: return "DL";
  case UP_RIGHT: return "UR";
  case DOWN_RIGHT: return "DR";
      };
  uassert(false, "unknown direction");
  return NULL;
}

const char* color_string(colorT c){
  if(c==WHITE)return "White";
  if(c==BLACK)return "Black";
  if(c==NOCOLOR)return " ";
  uassert(false,"bad color color_string");
  return "illegal";
}

bool file_valid(int f){
  return f>=0&&f<8;
}

bool rank_valid(int r){
  return file_valid(r);
}

char file_to_char_cql(int f){
  uassert(file_valid(f));
  return (char)(f+'a');
}


char rank_to_char_cql(int r){
  uassert(rank_valid(r));
  return (char)(r+'1');
}

bool piece_valid(pieceT p){
  static vector<pieceT>valid{
      WK,WQ,WR,WB,WN,WP,
      BK,BQ,BR,BB,BN,BP,
      EMPTY
      };
  for(pieceT x : valid) if(x==p)return true;
  return false;
}


char piece_to_char(pieceT p){
  switch(p){
  case BR: return 'r';
  case BN: return 'n';
  case BB: return 'b';
  case BQ: return 'q';
  case BK: return 'k';
  case BP: return 'p';

  case WR: return 'R';
  case WN: return 'N';
  case WB: return 'B';
  case WQ: return 'Q';
  case WK: return 'K';
  case WP: return 'P';

  case EMPTY: return '.';
  }
  uassert(false,"bad piece");
  return 0;
}

///square related functions

char* square_to_string(squareT square){
  char buffer[100];
  uassert(square_valid(square));
  int f=square_file(square);
  int r=square_rank(square);
  char fc=file_to_char_cql(f);
  char rc=rank_to_char_cql(r);
  sprintf(buffer,"%c%c",fc,rc);
  return util::copy(buffer);
}
  
void square_print(squareT square){
  uassert(square_valid(square));
  int f=square_file(square);
  int r=square_rank(square);
  char fc=file_to_char_cql(f);
  char rc=rank_to_char_cql(r);
  printf("%c%c",fc,rc);
}

// squareT square_make(int f , int r){
//   uassert(rank_valid(r)&&file_valid(f));
//   return square_Make((fyleT)f, (rankT)r);
// }

// int square_rank(int s){
//   uassert(square_valid(s));
//   int r=square_Rank(s);
//   uassert(rank_valid(r));
//   return r;
// }

// int square_file(int s){
//   uassert(square_valid(s));
//   int f=square_Fyle(s);
//   uassert(file_valid(f));
//   return f;
// }

////end square-related functions

const char * result_to_string(resultT rc){
  switch(rc){
  case RESULT_White: return "1-0";
  case RESULT_Black: return "0-1";
  case RESULT_Draw: return "1/2-1/2";
  case RESULT_None: return "No_Result";
  }
  uassert(false,"bad result");
  return NULL;
}

bool direction_valid(directionT d){
  static vector<directionT> allds{
      UP, DOWN, LEFT, RIGHT,
	UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT};
  for(auto dir:allds) if(dir==d)return true;
  return false;
}
      

  
		      
bool mark_valid(markT mark){
  return mark>=0&&mark<=31;
}
