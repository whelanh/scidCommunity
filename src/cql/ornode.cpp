#include "node.h"
OrNode::OrNode(MFilter*c1,MFilter*c2){
  uassert(c1&&c2,"internal OrNode, null args to constructor");
  clause1=c1;
  clause2=c2;
}

bool OrNode::isSet(){
  return clause1->isSet()&&clause2->isSet();
}

void OrNode::print(){
  printf("<%s",thisclass());
  printf("\n");indent();tab();
  printf("clause1: ");
  clause1->print();
  printf("clause1: ");
  printf("\n");tab();
  clause2->print();
  printf(" %s>",thisclass());
  unindent();
}

bool OrNode::match_position(Game*game){
  if(clause1->match_position(game)) return true;
  return clause2->match_position(game);
}

SquareMask OrNode::getSquares(Game*game){
  uassert(isSet(),"attempt to get squares from and Or Node that is not a Set Filter");
  SetBase*s1=dynamic_cast<SetBase*>(clause1);
  SetBase*s2=dynamic_cast<SetBase*>(clause2);
  uassert(s1&&s2,"OrNode internal: expected sets here");
  uassert(s1->isSet()&&s2->isSet(), "OrNode internal: expected actual sets");
  SquareMask m1=s1->getSquares(game);
  SquareMask m2=s2->getSquares(game);
  return m1|m2;
}

