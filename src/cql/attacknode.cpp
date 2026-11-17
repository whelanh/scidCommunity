/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"

void AttackNode::addcounts(pieceT piece, const pieceT*board, squareT square){
  switch(piece){
  case WR: case BR:
    addslidingcounts(UP,board,square);
    addslidingcounts(DOWN,board,square);
    addslidingcounts(LEFT,board,square);
    addslidingcounts(RIGHT,board,square);
    return;
  case WB: case BB:
    addslidingcounts(UP_LEFT,board,square);
    addslidingcounts(DOWN_LEFT,board,square);
    addslidingcounts(UP_RIGHT,board,square);
    addslidingcounts(DOWN_RIGHT,board,square);
    return;
  case WQ: case BQ:
    addcounts(WR,board,square);
    addcounts(WB,board,square);
    return;
  case WN: case BN:
    addknightcounts(board,square);
    return;
  case WP: case BP:
    addpawncounts(piece,board,square);
    return;
  case WK: case BK:
    addkingcounts(board,square);
    return;
  case EMPTY: return;
  default: uassert(false,"attacknode bad switch");
  }
}
	     
void AttackNode::addslidingcounts(directionT direction,const pieceT*board,squareT square){
  int current=square;
  do {
    current=util::squareShiftDirection(current,direction);
    if (current<0)return;
    squarecounts[current]++;
    if (board[current]!=EMPTY)return;
  }
  while (current>=0&&current<64);
}

void AttackNode::addknightcounts(const pieceT*board, squareT square){
  int fileoffsets[8]={1,2,2,1,-1,-2,-2,-1};
  int rankoffsets[8]={2,1,-1,-2,-2,-1,1,2};
  for (int i=0;i<8;++i) addnonsliding(fileoffsets[i],rankoffsets[i],board,square);
}

void AttackNode::addpawncounts(pieceT pawn, const pieceT*board,squareT square){
  uassert(pawn==WP||pawn==BP,"addpawncounts internal");
  int rankoff=pawn==WP?1:-1;
  addnonsliding(-1,rankoff,board,square);
  addnonsliding(1,rankoff,board,square);
}

void AttackNode::addkingcounts(const pieceT*board,squareT square){
  int fileoffsets[8]={0,1,1,1,0,-1,-1,-1};
  int rankoffsets[8]={1,1,0,-1,-1,-1,0,1};
  for (int i=0;i<8;++i) addnonsliding(fileoffsets[i],rankoffsets[i],board,square);
}

void AttackNode::addnonsliding(int fileoff,int rankoff, const pieceT* /*board*/, squareT square){
  int file=square_Fyle(square)+fileoff;
  int rank=square_Rank(square)+rankoff;
  if (file<0||file>7||rank<0||rank>7) return;
  squarecounts[square_Make(file,rank)]++;
}

AttackNode::AttackNode(SetBase*s, SetBase*t, Range*r){
  uassert(s && t);
  attacking=s;
  attacked=t;
  range=r;
}

void AttackNode::print(){
  printf("<%s ",thisclass());
  attacking->print();
  printf(" ");
  attacked->print();
  if(range) range->print();
  printf("> ");
}

vnode AttackNode::children(){
  return vnode{attacking,attacked};
}

bool AttackNode::match_count(Game*game,NumValue*value){
  uassert(isCountable()&&!isSet(), "Attempt to count an attack filter without a range");
  if(match_position(game)){
    *value=(NumValue)(count);
    return true;
  }
  return false;
}

//Below is highly inefficient: it computes all attacks of all pieces in attacking
//Should be fixed later.

bool AttackNode::match_position(Game *game){ //This also MUST SET THE COUNTS
  const pieceT * board=game->GetCurrentPos()->GetBoard();
  for (int i=0;i<64;++i) squarecounts[i]=0;
  SquareMask attackingsquares=attacking->getSquares(game);
  SquareMask attackedsquares=attacked->getSquares(game);
  for (int sq=0;sq<64;++sq)
    if (attackingsquares.member(sq))
      addcounts(board[sq],board,sq);
  count=0;
  for (int sq=0;sq<64;++sq)
    if (attackedsquares.member(sq))
      count+=squarecounts[sq];
  if(!range) return count;
  else return range->valid(count);
}

SquareMask AttackNode::getSquares(Game*game){
  SquareMask mask;
  uassert(isSet(),"Attack filter has a range, but is used as a square set");
  if(!match_position(game)) return mask;
  SquareMask attackedsquares=attacked->getSquares(game); //computed here and in match_position
  for(int sq=0;sq<64;++sq)
    if(attackedsquares.member(sq)&&squarecounts[sq])
      mask.insert(sq);
  return mask;
}

bool AttackNode::isSet(){
  return range==nullptr;
}

bool AttackNode::isCountable(){
  return range!=nullptr;
}

