#include "node.h"
OptionalConstituent::OptionalConstituent(SeqConstituent*c){
  uassert(c,"oc");
  constituent=c;
}

void OptionalConstituent::print(){
  printf("<%s ",thisclass());
  constituent->print();
  printf(">");
}

void OptionalConstituent::setOffsets(int i){
  setOffset(i);
  constituent->setOffsets(i);
}

bool OptionalConstituent::matchesNull(){
  return true;
}
