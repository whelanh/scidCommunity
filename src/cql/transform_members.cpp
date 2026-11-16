#include "node.h"
void ResultNode::transform_members(Transform*t){
  if(t->flipsColor()){
    switch(result){
    case RESULT_White: result=RESULT_Black; break;
    case RESULT_Black: result=RESULT_White; break;
    case RESULT_Draw: break;
    default: uassert(false, "bad result");
    }
  }
}
    

void PieceLoc::transform_members(Transform*t){
  SquareMask newpieces;
  for(int i=0;i<64;++i)if (pieces.member(i)){
      pieceT p = (pieceT) i;
      uassert (piece_valid(p));
      pieceT newp=t->transformPiece(p);
      newpieces.insert((int)newp);
    }
  pieces=newpieces;
  squaremask=t->transform(squaremask);
}

void ColorNode::transform_members(Transform*t){
  color=t->transformColor(color);
}

void PlayerNode::transform_members(Transform*t){
  color=t->transformColor(color);
}

void EloNode::transform_members(Transform*t){
  color=t->transformColor(color);
}

void RayNode::transform_members(Transform*t){
  for(int i=0;i<directions.size();++i)
    directions[i]=t->transform(directions[i]);
}

void VectorNode::transform_members(Transform*t){
  parameter=t->transform(parameter);
}

void TransformNode::transform_in_place(Transform*t){
  uassert(!expanded(),"transform_in_place on expanded node");
  Node::transform_in_place(t);
}


      

