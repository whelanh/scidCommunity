#include "node.h"
EchoTransformSpec::EchoTransformSpec(vector<Transform*>ts, EchoSpec*s){
  uassert(ts.size()&&s);
  transforms=ts;
  spec=s;
}

void EchoTransformSpec::print(){
  int ntransforms=transforms.size();
  printf("<%s ntransforms: %d",thisclass(),ntransforms);
  for(int i=0;i<ntransforms;++i){
    auto t=transforms[i];
    printf("\n");indent();tab();
    printf("Transform %d of %d: ",i,ntransforms);
    t->print();
    unindent();
  }
  printf("\n");indent();tab();
  printf("Spec:");
  spec->print();
  printf(" EchoTransformSpec>");
}

bool EchoTransformSpec::match_target(){
  matchedTransform=NULL;
  for(Transform* t : transforms)
    if (spec->match_target(t)){
      matchedTransform=t;
      return true;
    }
  return false;
}
  
void EchoTransformSpec::start_new_search(Game*game){
  EchoSpec::start_new_search(game);
  uassert(insearch&&game==theGame);
  spec->start_new_search(game);
}

void EchoTransformSpec::end_search(){
  spec->end_search();
  EchoSpec::end_search();
}
