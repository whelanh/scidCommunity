/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
OriginNode::OriginNode(TagVariable* v){
  uassert(v);
  variable=v;
}

SquareMask OriginNode::getSquares(Game* /*game*/){
  uassert(variable->isBound(),"Attempt to access unbound ID variable: ",variable->name);
  squareT origin=variable->getOrigin();
  uassert(square_valid(origin),"originnode origin");
  SquareMask ret;
  ret.insert(origin);
  return ret;
}

void OriginNode::print(){
  printf("<%s ",thisclass());
  variable->print();
  printf(">");
}
  
