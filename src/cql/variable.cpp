#include "node.h"
vector<Variable*>* Variable::theVariables;

vector<Variable*>* Variable::getVariables(){
  if(!theVariables)
    theVariables=new vector<Variable*>;
  return theVariables;
}

Variable* Variable::find(const char*nm){
  for(Variable* v:*(getVariables()))
    if (v->eq(nm))
      return v;
  return NULL;
}

void Variable::unbindTags(){
  for(Variable* v : *(getVariables())){
    TagVariable* tv=dynamic_cast<TagVariable*>(v);
    if(tv&&tv->bound){
      //     printf("variable: unbinding variable: ");
      //      tv->print();
      //      printf("\n");
      tv->unbind();
      uassert(!tv->isBound());
    }
  }
}

void Variable::unbind(){
  uassert(bound,"attempt to unbind unbound variable: ",name);
  bound=false;
}

bool Variable::eq(const char*n){
  uassert(n,"bad arg to variable eq");
  return strcmp(name,n)==0;
}

