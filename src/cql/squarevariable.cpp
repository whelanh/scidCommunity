/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
// SquareVariable Stuff ////////

SquareVariable* Variable::getSquareVariable(std::string_view nm){
  SquareVariable* ret=nullptr;
  Variable*v=find(nm);
  if(v) {
    ret=dynamic_cast<SquareVariable*>(v);
    uassert(ret,"cannot make square variable from tag variable",std::string(nm).c_str());
    return ret;
  }
  return createSquareVariable(nm);
}

SquareVariable* Variable::createSquareVariable(std::string_view nm){
  uassert(!nm.empty(),"invalid null variable name");
  uassert(!find(nm),"internal variable");
  SquareVariable*s=new SquareVariable(nm);
  getVariables()->push_back(s);
  return s;
}

void SquareVariable::bindSquare(squareT s){
  uassert(!bound,"attempt to bind variable already bound: ",name.c_str());
  uassert(square_valid(s),"internal bad square argument to bindSquare");
  square=s;
  used=false;
  bound=true;
}

void SquareVariable::print(){
  //  if(1)printf("called print on variable\n");
  printf("<%s %s used: %d ",thisclass(),name.c_str(),used);
  if(bound){
    printf("square: ");
    square_print(square);
  }
  else printf("unbound");
  printf(">");
}

bool SquareVariable::getSquare(squareT*s){
  used=true;
  uassert(bound,"internal, getsquare");
  uassert(square_valid(square));
  *s=square;
  return true;
}

SquareVariable::SquareVariable(std::string_view nm){
  name=nm; //not sure if necessary?
}

