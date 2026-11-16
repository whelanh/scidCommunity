#include "node.h"
RepeatConstituent::RepeatConstituent(SeqConstituent*c,int tmin, int tmax){
  uassert(c,"nullscsc");
  constituent=c;
  uassert (tmin>=0 && tmax >=0);
  min=tmin;
  max=tmax;
}

void RepeatConstituent::print(){
  printf("<%s ",thisclass());
  constituent->print();
  printf("{%d %d}",min,max);
  printf(">");
}

void RepeatConstituent::setOffsets(int i){
  setOffset(i);
  constituent->setOffsets(i);
}

bool RepeatConstituent::matchesNull(){
  return min==0 ||
    constituent->matchesNull();
}
