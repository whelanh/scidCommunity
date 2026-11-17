/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
vnode PositionNode::children(){
  return vnode{specs.begin(),specs.end()};
}

PositionNode::PositionNode(const vector<Node*>& ss){
  for(auto s: ss){
    uassert(s,"null input to positionnode");
    MFilter* mf=dynamic_cast<MFilter*>(s);
    uassert(s,"PositionNode was passed a feature that is not an MFilter");
    specs.push_back(mf);
  }
}

void PositionNode::print(){
  printf("<%s at %p: %zu specs:",thisclass(),static_cast<const void*>(this),specs.size());
  std::size_t i=0;
  for(MFilter* spec:specs){
    printf("\n");
    indent();
    tab();
    printf("<%zu of %zu: ",i++,specs.size());
    spec->print();
    unindent();
  }
  printf(" %s> ",thisclass());
}


    
