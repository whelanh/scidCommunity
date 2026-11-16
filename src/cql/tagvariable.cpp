#include "node.h"

TagVariable* Variable::createTagVariable(const char*nm){
  uassert(nm,"invalid null var name in tag create");
  uassert(!find(nm),"internal variable tag");
  TagVariable*t=new TagVariable(nm);
  getVariables()->push_back(t);
  return t;
}

TagVariable* Variable::getTagVariable(const char*nm){
  TagVariable * ret=NULL;
  Variable *v=find(nm);
  if(v){
    ret=dynamic_cast<TagVariable*>(v);
    uassert(ret,"expected ID but got already declared square variable: ",nm);
    return ret;
  }
  return createTagVariable(nm);
}

TagVariable::TagVariable(const char*nm){
  name=nm;
  uassert(nm);
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
  printf("<%s %s ",thisclass(),name);
  if(bound){
    printf("tag: %d",tag);
  }
  else printf("unbound");
  printf(">");
}


