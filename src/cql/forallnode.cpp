#include "node.h"
ForallNode::ForallNode(SquareVariable*v,SetBase*t, vector<Node*>nodes){
  uassert(v&&v->isUnbound(),"existsnode, internal");
  variable=v;
  target=t;
  for(Node*np: nodes){
    uassert(np,"internal existsnode");
    MFilter * mf=dynamic_cast<MFilter*>(np);
    uassert(mf,"AllsNode: unexpected non-mfilter");
    filters.push_back(mf);
  }
  //possibly check none of the mfilters is free in variable here
}

void ForallNode::print(){
  printf("<%s : variable: ",thisclass());
  variable->print();
  if(target){
    printf(" : ");
    target->print();
  }
  printf(" %lu filters: ",filters.size());
    for(int i=0;i<filters.size();++i){
    printf("\n");
    indent();
    tab();
    printf("<%d of %lu: ",i,filters.size());
    filters[i]->print();
    unindent();
  }
  printf(" %s> ",thisclass());
}

bool ForallNode::match_position(Game*game){
  uassert(variable->isUnbound());
  SquareMask targetmask;
  if(target) targetmask=target->getSquares(game);
  else targetmask = ~targetmask;
  if(targetmask.empty())return true;
  for(squareT square=0;square<64;++square)
    if(targetmask.member(square)){
      if(variable->isBound()) variable->unbind();
      variable->bindSquare(square);
      for(MFilter* filter:filters)
	if(!filter->match_position(game)){
	  variable->unbind();
	  return false;
	}
    }
  variable->unbind();
  return true;
}

vnode ForallNode::children(){
  vnode v;
  if(target) v.push_back(target);
  v.insert(v.end(),filters.begin(),filters.end());
  return v;
}
