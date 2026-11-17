/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
ExistsNode::ExistsNode(SquareVariable*v, SetBase*trgt, const vector<Node*>& nodes){
  uassert(v&&v->isUnbound(),"existsnode, internal");
  variable=v;
  target=trgt;
  uassert(!nodes.empty(),"Expected nonzero number of nodes");
  for(Node*np: nodes){
    uassert(np,"internal existsnode");
    MFilter * mf=dynamic_cast<MFilter*>(np);
    uassert(mf,"ExistsNode: unexpected non-mfilter");
    filters.push_back(mf);
  }
  //possibly check none of the mfilters is free in variable here
}

void ExistsNode::print(){
  printf("<%s : variable: ",thisclass());
  variable->print();
  if(target){
    printf("\n");indent();tab();
    printf("target: ");
    target->print();
    unindent();
  }
  printf(" %zu filters: ",filters.size());
  std::size_t i=0;
  for(MFilter* filter:filters){
    printf("\n");
    indent();
    tab();
    printf("<%zu of %zu: ",i++,filters.size());
    filter->print();
    unindent();
  }
  printf(" %s> ",thisclass());
}

SquareMask ExistsNode::getSquares(Game*game){
  SquareMask ret;
  SquareMask targetmask;
  if(target) targetmask=target->getSquares(game);
  else targetmask=SquareMask::all();
  for(int sq=0;sq<64;++sq)
    if(targetmask.member(sq)&&match_filters(sq,game))
      ret.insert(sq);
  return ret;
}
      
    
bool ExistsNode::match_filters(squareT square, Game* game){
  uassert(square_valid(square)&&!filters.empty());
  uassert(variable->isUnbound(),"ExistsNode: Attempting to match a square but am bound");
  variable->bindSquare(square);
  for(MFilter* filter:filters)
    if(!filter->match_position(game)){
      variable->unbind();
      return false;
    }
  variable->unbind();
  return true;
}

vnode ExistsNode::children(){
  vnode v{filters.begin(),filters.end()};
  if(target) v.push_back(target);
  return v;
}
