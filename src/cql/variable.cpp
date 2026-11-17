/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
thread_local vector<Variable*>* Variable::theVariables;
thread_local vector<TagVariable*> Variable::tagVariables;
thread_local NumericVariable* Variable::matchCountCache=nullptr;

vector<Variable*>* Variable::getVariables(){
  if(!theVariables)
    theVariables=new vector<Variable*>;
  return theVariables;
}

// Every variable the parser declared lives in the shared registry for the
// lifetime of the process; a query's variables must not leak into the next
// query, or a later ?x of a different kind would find the old one and fail the
// dynamic_cast in getTagVariable/getSquareVariable. CqlReset() drops them.
void Variable::clearAll(){
  if(theVariables){
    for(Variable* v:*theVariables)
      delete v;
    theVariables->clear();
  }
  // These point into the registry just emptied, so they must not survive it.
  tagVariables.clear();
  matchCountCache=nullptr;
}

Variable* Variable::find(std::string_view nm){
  for(Variable* v:*(getVariables()))
    if (v->eq(nm))
      return v;
  return nullptr;
}

void Variable::unbindTags(){
  // Only the tag variables can be bound at a position, and a query without one
  // (the common case) does not walk the registry at all.
  for(TagVariable* tv : tagVariables){
    if(tv->bound){
      //     printf("variable: unbinding variable: ");
      //      tv->print();
      //      printf("\n");
      tv->unbind();
      uassert(!tv->isBound());
    }
  }
}

void Variable::unbind(){
  uassert(bound,"attempt to unbind unbound variable: ",name.c_str());
  bound=false;
}

bool Variable::eq(std::string_view n) const{
  uassert(!n.empty(),"bad arg to variable eq");
  return name==n;
}

