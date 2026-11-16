#include "node.h"
#include <utility>

Transform* Transform::transform(Transform*t){
  uassert(t);
  return new ComposeTransform(this,t);
}

Node* Transform::transform(Node*filter){
  uassert(filter);
  return filter->transform(this);
}

  
DirectionParameter Transform::transform(DirectionParameter directionparameter){
  vector<Direction>v;
  for(auto d:directionparameter.directions)
    v.push_back(transform(d));
  return DirectionParameter(v,directionparameter.range);
}


pieceT Transform::transformPiece(pieceT piece){
  uassert(piece_valid(piece));
  pieceT ret=50;
  if(flipsColor()) 
    ret= PIECE_FLIP[piece]; //copied from egs/pieceLoc.cpp:385, cleaner ways exist
  else
    ret=piece;
  uassert(piece_valid(ret));
  return ret;
}

colorT Transform::transformColor(colorT color){
  if(!flipsColor())return color;
  if(color==WHITE)return BLACK;
  if(color==BLACK) return WHITE;
  if(color==NOCOLOR) return NOCOLOR;
  uassert(false,"bad color transformcolor");
  return NOCOLOR;
}

void Transform::print(){
  printf("<%s>",thisclass());
}

Transform* Transform::compose(Transform * t){
  uassert(t);
  return new ComposeTransform(this,t);
}

vector<Transform*> Transform::nonidentity(const vector<Transform*>& transforms){
  vector<Transform*> ret;
  for(auto t:transforms)
    if (!dynamic_cast<IdentityTransform*>(t))
      ret.push_back(t);
  return ret;
}


