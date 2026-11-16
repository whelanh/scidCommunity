#include "node.h"

BetweenNode::BetweenNode(SetBase*s, SetBase*t){
  uassert(s&&t);
  source=s;
  target=t;
}

void BetweenNode::print(){
  printf("<%s ",thisclass());
  printf("\n");indent();tab();
  printf("source: ");
  source->print();
  unindent();
  printf("\n");indent();tab();
  printf("target: ");
  target->print();
  printf("> ");
  unindent();
}

SquareMask BetweenNode::getSquares(Game*game){
  SquareMask mask;
  SquareMask sm=source->getSquares(game);
  SquareMask tm=target->getSquares(game);
  for(squareT sourcesquare=0;sourcesquare<64;++sourcesquare)
    if (sm.member(sourcesquare))
      for(squareT targetsquare=0;targetsquare<64;++targetsquare)
	if(tm.member(targetsquare))
	  mask|=Direction::between(sourcesquare,targetsquare);
  return mask;
}


