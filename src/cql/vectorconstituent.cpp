#include "node.h"

VectorConstituent::VectorConstituent(vector<SeqConstituent*>&cs){
  uassert(!cs.empty(),"invalid null size vector constituent");
  constituents=cs;
  for(auto c:constituents)
    uassert(c,"vcvc");
}

vnode VectorConstituent::children(){
  vnode v{constituents.begin(),constituents.end()};
  return v;
}

void VectorConstituent::setOffsets(int i){
  setOffset(i);
  for(auto c:constituents)
    c->setOffsets(i);
}


void VectorConstituent::print(){
  printf("\n");tab();
  printf("<%s %lu constituents: ",thisclass(),constituents.size());
  indent();
  for(int i=0;i<constituents.size();++i){
    printf("\n");
    tab();
    printf("%s %d of %lu: ",thisclass(),i,constituents.size());
    constituents[i]->print();
  }
  unindent();
  printf(">");
}

bool VectorConstituent::matchesNull(){
  for(auto c:constituents)
    if(!c->matchesNull())return false;
  return true;
}
