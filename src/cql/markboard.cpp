/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "util.h"
#include "markboard.h"
#include "variable.h"

MarkBoard * MarkBoard::globalMarkBoard=nullptr;

MarkBoard::MarkBoard(Game*game){
  initialize(game);
  Variable::unbindTags();
}

//This should be called by external routines to begin marking a game.

void MarkBoard::mark(Game*game){
  if (!globalMarkBoard) globalMarkBoard=new MarkBoard(game);
  globalMarkBoard->initialize(game);
}

MarkBoard*MarkBoard::global(){
  return globalMarkBoard;
}

bool MarkBoard::myIsNullMove(simpleMoveT* sm){
  uassert(sm,"myIsNullMove: null parameter");
  return sm->isNullMove();
}

void MarkBoard::print(){
  printf("%s stacksize: %lu printing the markmap\n",
	 thisclass(),
	 stack.size());

  map.print();
  printf("MarkBoard: Printing the underlying board:\n");
  util::my_dump_board(game->GetCurrentPos()->GetBoard());
}

void MarkBoard::verify(){
  map.verify(game);
}

void MarkBoard::MoveForward(){
  verify();
  pushstate();
  
  simpleMoveT * currentmove=game->GetCurrentMove();
  uassert(currentmove!=nullptr);
  squareT from=currentmove->from;
  squareT to=currentmove->to;
  bool isnull=myIsNullMove(currentmove);
  uassert(isnull || (square_valid(from)&&square_valid(to)&&from!=to),"mark forward internal");
  Position * position=game->GetCurrentPos();
  const pieceT * board=position->GetBoard();
  colorT color=position->GetToMove();
  map.make_move(from,to,board,color);
  game->MoveForward();
  verify();
}
    
void MarkBoard::MoveBackup(){ 
  popstate();
  game->MoveBackup();
  while(atVarStart(game)&&inVariation(game))
    game->MoveExitVariation();
  verify();
}
  

void MarkBoard::initialize(Game * newgame){
  game=newgame;
  uassert(game->GetCurrentPly()==0,"expected game at start in markboard");
  stack.clear();
  map.initialize(newgame);
}

void MarkBoardMap::initialize(Game*game){
  int nmarks=0;
  for(markT& m : squares_to_marks)
    m=-1;
  for(int& i : marks_to_squares)
    i=65;
  uassert(game->GetCurrentPly()==0,"expected game at start in markboard2");
  const pieceT * board=game->GetCurrentPos()->GetBoard();
  for (int sq=0;sq<64;++sq)
    if (board[sq]!=EMPTY){
      uassert(mark_valid(nmarks));
      squares_to_marks[sq]=nmarks;
      marks_to_squares[nmarks]=sq;
      nmarks++;
    }
    else // square is empty
      squares_to_marks[sq]=-1;
  verify(game);
}

void MarkBoard::popstate(){
  uassert(!stack.empty());
  map=stack.back();
  stack.pop_back();
}

void MarkBoard::pushstate(){
  stack.push_back(map);
}

void MarkBoard::MoveToPly(int n){
  uassert(n==0,"impl movetoply");
  while(game->GetCurrentPly())
    MoveBackup();
  uassert(game->GetCurrentPly()==0);
  uassert(game->AtStart(),"movetoply");
}
