#include "node.h"
void MatchCountNode::print(){
  printf("<%s ",thisclass());
  if(sort) printf("sort ");
  range->print();
  printf(">");
}

MatchCountNode::MatchCountNode(Range*r,bool s) : range{r},sort{s} {
  uassert(range);
  uassert(range->min>=0);
}

