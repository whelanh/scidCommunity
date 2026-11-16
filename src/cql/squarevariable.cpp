#include "node.h"
// SquareVariable Stuff ////////

SquareVariable* Variable::getSquareVariable(const char*nm){
  SquareVariable* ret=NULL;   
  Variable*v=find(nm);
  if(v) {
    ret=dynamic_cast<SquareVariable*>(v);
    uassert(ret,"cannot make square variable from tag variable",nm);
    return ret;
  }
  return createSquareVariable(nm);
}

SquareVariable* Variable::createSquareVariable(const char*nm){
  uassert(nm,"invalid null variable name");
  uassert(!find(nm),"internal variable");
  SquareVariable*s=new SquareVariable(nm);
  getVariables()->push_back(s);
  return s;
}

void SquareVariable::bindSquare(squareT s){
  uassert(!bound,"attempt to bind variable already bound: ",name);
  uassert(square_valid(s),"internal bad square argument to bindSquare");
  square=s;
  used=false;
  bound=true;
}

void SquareVariable::print(){
  //  if(1)printf("called print on variable\n");
  printf("<%s %s used: %d ",thisclass(),name,used);
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

SquareVariable::SquareVariable(const char*nm){
  name=nm; //not sure if necessary?
}

