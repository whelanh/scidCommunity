/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"

SquareMask PieceLoc::getSquares(Game*game){
  SquareMask ret=SquareMask::all();
  for(Variable*v:variables){
    uassert(v->isBound(),"Unexpected unbound variable: may be undeclared: ",v->name.c_str());
    squareT s=65;
    bool b=v->getSquare(&s);
    if(!b) return {};
    uassert(square_valid(s));
    ret&=SquareMask::fromSquare(s);
  }
  ret&=squaremask;
  if(ret.empty())return ret;
  return ret&getPieceMask(game);
}

SquareMask PieceLoc::getPieceMask(Game*game){
  int gamenumber=CqlGameNumber();
  auto me=MarkBoard::identity(game);
  if(lastid==me&&lastgamenumber==gamenumber)
    return lastmask;
  lastmask.clear();
  lastid=me;
  Position*position=game->GetCurrentPos();
  const pieceT*board=position->GetBoard();
  for(squareT sq=0;sq<64;++sq){
    pieceT piece=board[sq];
    if (match_piece(piece))
      lastmask.insert(sq);
  }
  return lastmask;
}

bool PieceLoc::match_piece(pieceT piece){
  //  uassert(piece_valid(piece));
  return pieces.member(piece);
}

