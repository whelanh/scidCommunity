#include "node.h"

MoveNumberNode::MoveNumberNode(Range*r):range{r}{
  uassert(range,"bad movenumber arg");
}

void MoveNumberNode::print(){
  printf("<%s ",thisclass());
  range->print();
  printf(">");
}

bool MoveNumberNode::match_position(Game*game){
  NumValue move=-1;
  return match_count(game,&move);
}

bool MoveNumberNode::match_count(Game*game, NumValue*value){
  int ply=game->GetCurrentPly();
  int mn=ply/2+1;
  if (!range->valid(mn)) return false;
  *value=mn;
  return true;
}
