/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "util.h"
#include "markboard.h"

void MarkBoardMap::verify(Game*game){
  //return;
  if(0)return;
  const pieceT* board=game->GetCurrentPos()->GetBoard();
  int marksseen=0;
  for (int square=0;square<64;++square){
    markT mark=squares_to_marks[square];
    pieceT piece=board[square];
    if(mark<0) {
      uassert(piece==EMPTY,"no mark on nonempty");
      continue;}
    uassert(piece!=EMPTY,"mark on empty");
    uassert(mark_valid(mark),"bad mark");
    uassert(marks_to_squares[mark]==square);
    marksseen++;
  }
  int marksinlist=0;
  for (int sq:marks_to_squares)
    if(square_valid(sq))++marksinlist;
  uassert(marksseen==marksinlist);
}

void MarkBoardMap::print(){
  FILE * fp=stdout;
  squareT s;
  printf("%s printing marked board: \n",thisclass());
    for (int i=7; i>=0; i--) {
    fputs ("   ", fp);
    for (int j=0; j<8; j++) {
      s = (i*8) + j;
      markT val=squares_to_marks[s];
      if (val<0){
	char c= (i%2)==(j%2) ? '+':'-';
	printf("%3c",c);
      }
      else printf("%3d",val);
    }
    putc ('\n', fp);
    }
}

void MarkBoardMap::make_null_move(squareT fromsquare, squareT tosquare, const pieceT*board, colorT color){
  // nullptr MOVE CONTRIVED EXCEPTION... testing purposes only
  //uassert(false, "contrived null move markboard exception");
  uassert(square_valid(fromsquare)&&
	  square_valid(tosquare)&&
	  fromsquare==tosquare&&
	  (color==WHITE||color==BLACK),
	  "make_null_move internal 1");
  pieceT p = piece_Type(board[fromsquare]);
  uassert(p==KING,"expecting a king on the null move from square");
  return;
}
  
			
void MarkBoardMap::make_castle(squareT kingfrom, squareT kingto,
			       squareT rookfrom, squareT rookto){
  // Castling moves two pieces at once. It cannot be spotted from the squares
  // alone: in Chess960 (or any FEN start) the king does not have to begin on
  // the e-file, and either piece can end up on the square the other left, so
  // the caller passes the four real squares (Position::castleRookSq() knows
  // them). Copy both marks aside, empty both origin squares, then place them,
  // which makes the overlapping-square cases work.
  uassert(square_valid(kingfrom)&&square_valid(kingto)&&
	  square_valid(rookfrom)&&square_valid(rookto),
	  "make_castle bad square");
  uassert(kingfrom!=rookfrom,"make_castle king and rook on same square");
  markT kingmark=squares_to_marks[kingfrom];
  markT rookmark=squares_to_marks[rookfrom];
  uassert(mark_valid(kingmark),"make_castle bad king mark");
  uassert(mark_valid(rookmark),"make_castle bad rook mark");
  uassert(kingto!=rookto,"make_castle king and rook to same square");

  squares_to_marks[kingfrom]=-1;
  squares_to_marks[rookfrom]=-1;
  uassert(squares_to_marks[kingto]<0,"make_castle occupied king target");
  uassert(squares_to_marks[rookto]<0,"make_castle occupied rook target");
  squares_to_marks[kingto]=kingmark;
  marks_to_squares[kingmark]=kingto;
  squares_to_marks[rookto]=rookmark;
  marks_to_squares[rookmark]=rookto;
}

void MarkBoardMap::make_move(squareT fromsquare,
			     squareT tosquare,
			     const pieceT*board,
			     colorT color){
  if(fromsquare==tosquare){
    make_null_move(fromsquare,tosquare,board,color);
    return;}
  
  uassert(square_valid(fromsquare)&&
	  square_valid(tosquare)&&
	  fromsquare!=tosquare &&
	  (color==WHITE || color==BLACK),
	  "map args");
  markT frommark=squares_to_marks[fromsquare];
  uassert(mark_valid(frommark),"bad from mark");
  
  pieceT ptype=piece_Type(board[fromsquare]);
  bool ep=(ptype==PAWN)&&board[tosquare]==EMPTY&&(square_Fyle(fromsquare)!=square_Fyle(tosquare));
  if (ep){
    int capturedsquare=(color==WHITE) ? (tosquare-8) : (tosquare+8);
    uassert(square_valid(capturedsquare),"map mark pawn bad");
    uassert(piece_Type(board[capturedsquare])==PAWN);
    markT capturedpawn=squares_to_marks[capturedsquare];
    uassert(mark_valid(capturedpawn));
    marks_to_squares[capturedpawn]=65;
    squares_to_marks[capturedsquare]=-1;
  }
	  //handle the general case
  markT capturedmark=squares_to_marks[tosquare];
  if(mark_valid(capturedmark)){
      uassert(board[tosquare]!=EMPTY);
      marks_to_squares[capturedmark]= -1;
    };
  markT movingmark=squares_to_marks[fromsquare];
  uassert(movingmark>=0);
  squares_to_marks[tosquare]=movingmark;
  squares_to_marks[fromsquare]=-1;
  marks_to_squares[movingmark]=tosquare;
}
  
