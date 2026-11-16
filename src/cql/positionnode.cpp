#include "node.h"
vnode PositionNode::children(){
  return vnode{specs.begin(),specs.end()};
}

PositionNode::PositionNode(vector<Node*> ss){
  for(auto s: ss){
    uassert(s,"null input to positionnode");
    MFilter* mf=dynamic_cast<MFilter*>(s);
    uassert(s,"PositionNode was passed a feature that is not an MFilter");
    specs.push_back(mf);
  }
}

void PositionNode::print(){
  printf("<%s at %p: %lu specs:",thisclass(),this,specs.size());
  for(int i=0;i<specs.size();++i){
    printf("\n");
    indent();
    tab();
    printf("<%d of %lu: ",i,specs.size());
    specs[i]->print();
    unindent();
  }
  printf(" %s> ",thisclass());
}


    
