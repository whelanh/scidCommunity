#include "node.h"
EloNode::EloNode(Range* r,colorT c):range{r},color{c}{
  uassert(r&&range,"elonode internal");
  uassert(color==WHITE||color==BLACK||color==NOCOLOR,"playernode color");
}

bool EloNode::match_count(Game*game,NumValue*value){
  int maxelo=0;
  int whiteelo=game->GetWhiteElo();
  int blackelo=game->GetBlackElo();
  bool matched=false;
  if( (color==WHITE||color==NOCOLOR)
      && range->valid(whiteelo)){
    matched=true;
    maxelo=std::max(maxelo,whiteelo);
  }
  if ((color==BLACK||color==NOCOLOR)
      && range->valid(blackelo)){
    matched=true;
    maxelo=std::max(maxelo,whiteelo);
  }
  if(!matched)return false;
  *value=(NumValue)maxelo;
  return true;
}

bool EloNode::match_game(Game*game){
  NumValue n= -1;
  return match_count(game,&n);
}

void EloNode::print(){
  printf("<%s %s",thisclass(),color_string(color));
  range->print();
  printf(">");
}
  
