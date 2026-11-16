#include "node.h"
bool CountSquaresNode::match_position(Game*game){
  SquareMask mask=set->getSquares(game);
  count=mask.size();
  return range->valid(count);
}

bool CountSquaresNode::match_count(Game*game,NumValue*value){
  if(match_position(game)){
    *value=(NumValue)(getCount());
    return true;
  }
  return false;
}

CountSquaresNode::CountSquaresNode(SetBase* dp, Range*rp){
  uassert(dp);
  set=dp;
  range=rp;
  uassert(range);
}

void CountSquaresNode::print(){
  printf("<%s ",thisclass());
  range->print();
  indent();
  set->print();
  printf(">");
}

// for CountSquaresNode::match_count, see coutable.cpp
