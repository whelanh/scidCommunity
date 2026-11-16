#include "node.h"
PowerNode::PowerNode(SetBase*s,Range*r){
  uassert(s&&r);
  set=s;
  range=r;
}

void PowerNode::print(){
  printf("\n");tab();
  printf("<%s Set: ",thisclass());
  set->print();
  printf(" Range:");
  range->print();
  printf(" >");
}

bool PowerNode::match_count(Game*game,NumValue*value){
  if (match_position(game)){
    *value=(NumValue)power;
    return true;
  }
  return false;
}
    
  
bool PowerNode::match_position(Game*game){
  SquareMask mask=set->getSquares(game);
  power=0;
  const pieceT*board=game->GetCurrentPos()->GetBoard();
  for (int square=0;square<64;++square)
    if(mask.member(square))
      power+= pieceValue(board[square]);
  return range->valid(power);
}

int PowerNode::pieceValue(pieceT p){
  switch (p){
  case BR: case WR: return 5;
  case BN: case WN: return 3;
  case BB: case WB: return 3;
  case BQ: case WQ: return 9;
  case BK: case WK: return 0;
  case BP: case WP: return 1;
  case EMPTY: return 0;
  }
  uassert(false,"piecevalue");
  return 0;
}

    
      
  

  
