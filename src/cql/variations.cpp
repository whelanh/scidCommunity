#include "node.h"
bool VariationFlags::getSearchVariations(){
  uassert(theisset,"variations flags are not yet set on this node");
  return thesearchvariations;
}

void VariationFlags::setSearchVariations(bool arg){
  uassert(!theisset,"attempt to set variations on flag that was already set");
  thesearchvariations=arg;
  theisset=true;
}

void VariationFlags::printVariationFlags(){
  if(theisset&&thesearchvariations)printf(" variations ");
}

void Node::setVariations(bool arg){
  if(0)  printf("Node::setvariations called with arg: %d on \n",arg);
  if(0) print();
  if(0) printf("\n");
  vector<Node*>c=children();
  for(Node* n:c){
    if(!n){
      printf("Internal error in node: %s\n",thisclass());
      printf("Got a null child among nchildren of: %lu\n",c.size());
      printf("bad node is: ");
      this->print();
      uassert(false,"unexpected null child in setVariations");
    }
    VariationFlags*vf=dynamic_cast<VariationFlags*>(n);
    if(vf){
      uassert(!vf->isVariationsSet(),"unexpected set variation"); //change later when add features
      vf->setSearchVariations(arg);
    }
    n->setVariations(arg);
  }
}

void VariationFlags::setVariations(bool arg){
  Node*n=dynamic_cast<Node*>(this);
  if(0)printf("VariationsFlags::setVariations called with arg: %d on:\n",arg);
  n->print();
  setSearchVariations(arg);
  if(0)printf("after calling, myisset is: %d\n",theisset);
  uassert(n,"internal casting issue setVariations");
  n->Node::setVariations(arg);
}

void CqlNode::setChildVariations(){
  uassert(isVariationsSet(),"internal cqlnode variations");
  bool varflag=getSearchVariations();
  Node::setVariations(varflag);
}
