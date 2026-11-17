/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"

// bool operator< (const NumericVariable& lhs, const NumericVariable& rhs)
// {
//   return lhs.getValue()<rhs.getValue();
// }

NumericVariable* Variable::getNumericVariable(std::string_view nm,bool ismax){
  NumericVariable* ret=nullptr;
  Variable*v=find(nm);
  if(v) {
    ret=dynamic_cast<NumericVariable*>(v);
    uassert(ret,"cannot make square variable from tag variable",std::string(nm).c_str());
    if(ret->isMax()!=ismax){
      fprintf(stderr,"\nERROR: Attempt to locate field %s with a different max/min orientation than existing field\n",std::string(nm).c_str());
      uassert(false,"sort field max/min inconsistency");
    }
    return ret;
  }
  return createNumericVariable(nm,ismax);
}

bool  NumericVariable::getSquare(squareT* /*s*/){
  uassert(false,"Cannot get the square of numeric variable",name.c_str());
  return false;
}

NumericVariable* Variable::createNumericVariable(std::string_view nm,bool ismax){
  uassert(!nm.empty(),"invalid null variable name");
  uassert(!find(nm),"internal variable");
  NumericVariable*s=new NumericVariable(nm,ismax);
  getVariables()->push_back(s);
  return s;
}

void NumericVariable::bindNumeric(NumValue v){
  value=v;
  if(isMax()){
    extremalValue=std::max(v,extremalValue);
    uassert(v>=extremeValue(),"bindNumeric low v");
  }
    else if (isMin()){
    extremalValue=std::min(v,extremalValue);
    uassert(v<=extremeValue(),"bindNumeric high v");
    }
  else
    uassert(false,"bindNumeric internal");
};

void NumericVariable::print(){
  printf("<%s %s %d %d %d>",thisclass(),name.c_str(), getValue(),getExtremalValue(),isMax());
}

NumValue NumericVariable::getValue()const{
  return value;
}

NumValue NumericVariable::getExtremalValue(){
  return extremalValue;
}

void NumericVariable::clear(){
  bindNumeric(extremeValue());
}

NumValue NumericVariable::extremeValue()const{
  if (isMax())
    return -100000;
  else if (isMin())
    return 100000;
  else
    uassert(false,"nvev");
  return 0;
}

NumericVariable::NumericVariable(std::string_view nm, bool ismax){
  uassert(!nm.empty());
  name=nm;
  theIsMax=ismax;
  reset();
}

void NumericVariable::resetAll(){
  vector<Variable*>* vars=Variable::getVariables();
  for(Variable* vp : *vars){
    NumericVariable * var=dynamic_cast<NumericVariable*>(vp);
    if(var) var->reset();
  }
}

void NumericVariable::reset(){
  value=extremeValue();
  extremalValue=extremeValue();
}

NumericVariable* Variable::matchCountVariable(){
  // Called for every position the matcher visits, so the lookup by name (a
  // string comparison against every registered variable) is done once.
  if(!matchCountCache){
    NumericVariable* var=getNumericVariable("matchcount",true);
    uassert(var&&var->isMax(),"matchcountvar");
    matchCountCache=var;
  }
  return matchCountCache;
}

void NumericVariable::increment(){
  uassert(isMax(),"increment min");
  bindNumeric(getValue()+1);
}
