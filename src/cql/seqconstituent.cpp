#include "node.h"

void SeqConstituent::setOffset(int off){
  uassert(off>=0&&theOffset<0,"offset setoffset internal");
  theOffset=off;
}

