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
  // NULL MOVE CONTRIVED EXCEPTION... testing purposes only
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
  else if (ptype==KING && square_Fyle(fromsquare)==E_FYLE&&
	   (square_Fyle(tosquare)==C_FYLE||square_Fyle(tosquare)==G_FYLE)){
    int rookfromsquare,rooktosquare;

    if(square_Fyle(tosquare)==C_FYLE){
      rookfromsquare=tosquare-2;
      rooktosquare=tosquare+1;
    }
    else{
      rookfromsquare=tosquare+1;
      rooktosquare=tosquare-1;
    }
    uassert(rookfromsquare!=rooktosquare&&
	    square_valid(rookfromsquare)&&
	    square_valid(rooktosquare),
	    "mark makemove bad rook");
    markT rookfrommark=squares_to_marks[rookfromsquare];
    uassert(mark_valid(rookfrommark));
    squares_to_marks[rooktosquare]=rookfrommark;
    squares_to_marks[rookfromsquare]=-1;
    marks_to_squares[rookfrommark]=rooktosquare;
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
  
