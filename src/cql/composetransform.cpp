#include "node.h"
squareT ComposeTransform::transform(squareT square){
  uassert(square_valid(square));
  squareT current=square;
  for(auto t: transforms){
    current=t->transform(current);
    if(!square_valid(current)) return current;
  }
  return current;
}

SquareMask ComposeTransform::transform(SquareMask mask){
  SquareMask m=mask;
  for(auto t:transforms) m=t->transform(m);
  return m;
}


void ComposeTransform::print(){
  printf("<%s ",thisclass());
  for(auto t:transforms) t->print();
  printf(">");
}

ComposeTransform::ComposeTransform(vector<Transform*>ts) :transforms{ts}{
  for(auto t:transforms) uassert(t);
  uassert(transforms.size()>=2);
}

ComposeTransform::ComposeTransform(Transform*t, Transform*s){
  uassert(t&&s);
  transforms.push_back(s);
  transforms.push_back(t);
}

Direction ComposeTransform::transform(Direction d){
  Direction current(d);
  for(auto t:transforms) current=t->transform(current);
  return current;
}

bool ComposeTransform::flipsColor(){
  bool flips=false;
  for(auto t:transforms) if (t->flipsColor()) flips= !flips;
  return flips;
}

vector<Transform*> ComposeTransform::composeVectors(vector<Transform*>a, vector<Transform*>b){
  vector<Transform*>ret;
  for(auto at:a)
    for (auto bt:b)
      ret.push_back(new ComposeTransform(at,bt));
  return ret;
}
