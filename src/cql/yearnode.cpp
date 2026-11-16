#include "node.h"
YearNode::YearNode(Range* r):range{r}{
  uassert(r&&range,"yearnode internal");
}

bool YearNode::match_game(Game*game){
  NumValue n= -1;
  return match_count(game,&n);
}

bool YearNode::match_count(Game*game, NumValue*value){
  int year=(int)(date_GetYear(game->GetDate()));
  if (range->valid(year)){
    *value=(NumValue)year;
    return true;
  }
  return false;
}
  
  
void YearNode::print(){
  printf("<%s ",thisclass());
  range->print();
  printf(">");
}

  
