#include "node.h"

NotNode::NotNode(Node*np){
  filter=dynamic_cast<MFilter*>(np);
  uassert(filter,"Missing or illegal argument to :not specification");
}

void NotNode::print(){
  printf("\n");
  tab();
  printf("<not ");
  indent();
  filter->print();
  printf(" not>");
  unindent();
}

bool NotNode::match_position(Game*game){
  return !filter->match_position(game);
}


SquareMask NotNode::getSquares(Game*game){
  SetBase*set=dynamic_cast<SetBase*>(filter);
  uassert(set,"NotNode: attempt to use a non-set as a set");
  uassert(set->isSet(),"NotNode: attempt to use a non-set-filter in this instance as set filter");
  return ~(set->getSquares(game));
}

bool NotNode::isSet(){
  return filter->isSet();
};

