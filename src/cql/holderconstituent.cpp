#include "node.h"
HolderConstituent::HolderConstituent(MFilter*f){
  uassert(f,"hc");
  filter=f;
}

void HolderConstituent::print(){
  printf("<%s ",thisclass());
  filter->print();
  printf(">");
}


void HolderConstituent::setOffsets(int i){
  setOffset(i);
}

bool HolderConstituent::matchesNull(){
  return false;
}
