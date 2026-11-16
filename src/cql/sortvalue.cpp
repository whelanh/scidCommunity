#include "node.h"
SortValue::SortValue(NumValue v, bool ismax){
  theIsMax=ismax;
  theValue=v;
}

void SortValue::print(){
  printf("<%s value: %d ismax: %d>",thisclass(),getValue(),isMax());
}
bool operator< (const SortValue& a, const SortValue& b){
  uassert(a.isMax()&&b.isMax()||a.isMin()&&b.isMin(),
	  "< sortvalue internal");
  if(a.isMax())
    return a.getValue()<b.getValue();
  else
    return a.getValue()>b.getValue();
}
  
