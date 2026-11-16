#include "node.h"
StarConstituent::StarConstituent(SeqConstituent*c){
  uassert(c,"nullscsc");
  constituent=c;
}

void StarConstituent::print(){
  printf("<%s ",thisclass());
  constituent->print();
  printf(">");
}

void StarConstituent::setOffsets(int i){
  setOffset(i);
  constituent->setOffsets(i);
}


