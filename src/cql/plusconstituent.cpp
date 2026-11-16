#include "node.h"
PlusConstituent::PlusConstituent(SeqConstituent*c){
  uassert(c,"nullscsc");
  theStarConstituent=new StarConstituent(c);
}

void PlusConstituent::print(){
  printf("<%s ",thisclass());
  getConstituent()->print();
  printf(">");
}

void PlusConstituent::setOffsets(int i){
  setOffset(i);
  theStarConstituent->setOffsets(i);
}

bool PlusConstituent::matchesNull(){
  return getConstituent()->matchesNull();
}

SeqConstituent* PlusConstituent::getConstituent(){
  return theStarConstituent->constituent;
}


