/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"

TagVariable* Variable::createTagVariable(std::string_view nm){
  uassert(!nm.empty(),"invalid null var name in tag create");
  uassert(!find(nm),"internal variable tag");
  TagVariable*t=new TagVariable(nm);
  getVariables()->push_back(t);
  return t;
}

TagVariable* Variable::getTagVariable(std::string_view nm){
  TagVariable * ret=nullptr;
  Variable *v=find(nm);
  if(v){
    ret=dynamic_cast<TagVariable*>(v);
    uassert(ret,"expected ID but got already declared square variable: ",std::string(nm).c_str());
    return ret;
  }
  return createTagVariable(nm);
}

TagVariable::TagVariable(std::string_view nm){
  uassert(!nm.empty());
  name=nm;
}

bool TagVariable::getSquare(squareT*s){
  uassert(MarkBoard::global(),"internal tags not turned on");
  uassert(bound,"internal tag get");
  uassert(mark_valid(tag));
  int soption=MarkBoard::getSquare(tag);
  if (!square_valid(soption)) return false;
  *s=soption;
  return true;
}

void TagVariable::bindTag(markT val){
  uassert(mark_valid(val));
  uassert(isUnbound(),"attempt to bind ID when it is already bound");
  tag=val;
  squareT neworigin=MarkBoard::getSquare(tag);
  uassert(square_valid(neworigin),"TagVariable: binding failure: cannot find origin");
  origin=neworigin;
  bound=true;
}

squareT TagVariable::getOrigin(){
  uassert(isBound(),"TagVariable: getOrigin: not bound");
  uassert(square_valid(origin),"TagVariable: bad origin");
  return origin;
}

void TagVariable::print(){
  //  if(1)printf("called print on variable\n");
  printf("<%s %s ",thisclass(),name.c_str());
  if(bound){
    printf("tag: %d",tag);
  }
  else printf("unbound");
  printf(">");
}


