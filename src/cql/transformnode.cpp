#include "node.h"
// for TransformNode::transform_in_place(Transform*t) see the file transform_members.cpp

TransformNode* TransformNode::create(vector<Transform*> ts,Node*n,Range*r){
  uassert(n);
  TransformNode* nbasenode=dynamic_cast<TransformNode*>(n);
  Range*subrange=NULL;
  if(nbasenode)subrange=nbasenode->range;
  if(!r&&nbasenode&&!subrange){
    uassert(!nbasenode->expanded());
    vector<Transform*>basets=nbasenode->getTransforms();
    vector<Transform*>composedts=
      ComposeTransform::composeVectors(ts,basets);
    Node* source=nbasenode->getSource();
    return create(composedts,source,r);
  }
  MFilter* mf=dynamic_cast<MFilter*>(n);
  uassert(mf, "tb::create: invalid node");
  return new TransformNode(ts,mf,r);
}

bool TransformNode::isSet(){
  if (range)return false;
  if(expanded()){
    uassert(filter==NULL,"TransformNode:isSet i1");
    uassert(transformedFilters.size(),"TransformNode:isSet i2");
    for (auto tf:transformedFilters) // We actually only need to check the 0'th element
      if(!tf->isSet()) return false;
    return true;
  }
  uassert(filter,"TransformNode::isSet i3");
  return filter->isSet();
}

bool TransformNode::isCountable(){
  return range!=NULL;
}

SquareMask TransformNode::getSquares(Game*game){
  uassert(isSet(),"Attempt to use a transform node as a square set when its argument is not a set");
    uassert(expanded(),"tsn not expanded");
  SquareMask mask;
  for(auto set : transformedFilters){
    SetBase* converted=dynamic_cast<SetBase*>(set);
    uassert(converted,"Internal error in transformnode.getSquares: a transformed filter is not a setbase");
    uassert(converted->isSet(),"internal error in TransforNode::getSquares: converted transformed filter is not a set");
    mask|=converted->getSquares(game);
  }
  return mask;
}


void TransformNode::expand(){
  uassert(transformedFilters.empty()&&filter);
  for(auto transform : transforms){
    MFilter* transformednode=dynamic_cast<MFilter*>(filter->transform(transform));
    uassert(transformednode,"null transform or wrong type in expand()");
    if(!transformednode->hasEmptySquareMaskDescendant())
      transformedFilters.push_back(transformednode);
  }
  for(auto transformedfilter : transformedFilters)
    transformedfilter->expand();
  filter=NULL;
}


vnode TransformNode::children(){
  vnode v;
  if(expanded())
    v.insert(v.end(),transformedFilters.begin(),transformedFilters.end());
  else
    v.push_back(filter);
  return v;
}
  
TransformNode::TransformNode(vector<Transform*>ts,MFilter*f,Range*r){
  uassert(f);
  for(auto t:ts) uassert(t);
  transforms=ts;
  filter=f;
  range=r;
}

void TransformNode::print(){
  int ntransforms=transforms.size();
  int nfilters=transformedFilters.size();
  printf("<%s ntransforms: %d nfilters: %d",thisclass(),ntransforms,nfilters);
  if(range) {
    printf("range: ");
    range->print();
  }
  for(int i=0;i<ntransforms;++i){
    auto t=transforms[i];
    printf("\n");indent();tab();
    printf("Transform %d of %d: ",i,ntransforms);
    t->print();
    unindent();
  }
  if(filter){
    uassert (!nfilters);
    printf("\n");indent();tab();
    printf("Filter: ");
    filter->print();
    unindent();
  }
  else{
    uassert (nfilters);
    for(int i=0;i<nfilters;++i){
      auto tfilter=transformedFilters[i];
      printf("\n");indent();tab();
      printf("TransformedFilter %d of %d: ",i,nfilters);
      tfilter->print();
      unindent();
    }
  }
  printf(" %s>",thisclass());
}

void TransformNode::deepify(){
  uassert(!expanded(),"TransformNode: deepify: internal");
  filter=filter->clone();
}
    
bool TransformNode::expanded(){
  uassert(!filter&&transformedFilters.size() ||
	  filter&&transformedFilters.empty(),"TransformNode::expanded internal");
  return filter==NULL;
}

TransformNode* TransformNode::clone(){
  uassert(!expanded(),"cannot clone expanded transformnode");
  TransformNode*ret=new TransformNode(*this);
  ret->deepify();
  cloneverify(this,ret);
  return ret;
}

bool TransformNode::match_position(Game*game){
  uassert(expanded(),"tn not expanded");
  count=0;
  for(auto f:transformedFilters){
    if(f->match_position(game))++count;
    if(count&& !range)return true;
  }
  if(!range)return false;
  return range->valid(count);
}

bool TransformNode::match_count(Game*game,NumValue*value){
  uassert(range,"Attempt to sort or count transform that lacks a range. Only transforms with ranges can be sorted or counted");
  if(match_position(game)){
    *value=(NumValue)count;
    return true;
  }
  return false;
}

bool Node::hasEmptySquareMaskDescendant(){
  vector<Node*>ds=descendants();
  for(auto d:ds){
    uassert(d);
    if(d->hasEmptySquareMask()) return true;
  }
  return false;
}
