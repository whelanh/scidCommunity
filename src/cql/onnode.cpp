#include "node.h"
OnNode::OnNode(SetBase*s1, SetBase*s2){
  clause1=s1;
  clause2=s2;
  uassert(clause1&&clause2&&clause1->isSet()&&clause2->isSet(),"OnNode constructor: invalid args");
}


void OnNode::print(){
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

SquareMask OnNode::getSquares(Game*game){
  SquareMask ret1=clause1->getSquares(game);
  SquareMask ret2=clause2->getSquares(game);
  SquareMask ret=ret1&ret2;
  return ret;
}



