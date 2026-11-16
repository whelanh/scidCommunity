#include "node.h"

VectorNode::VectorNode(DirectionParameter dp, SetBase*s):parameter{dp}{
  uassert(s);
  source=s;
}

vnode VectorNode::children(){
  vnode v{source};
  return v;
}

void VectorNode::print(){
  printf("<%s Parameter: ",thisclass());
  parameter.print();
  indent();
  printf("\n");tab();
  printf("source: ");
  source->print();
  printf("\n");tab();
  printf(" %s>",thisclass());
  unindent();
}

bool VectorNode::match_position(Game*game){
  return getSquares(game).nonempty();
}

SquareMask VectorNode::getSquares(Game*game){
  if(!neighborhoodsvalid){
    makeNeighborhoods();
    uassert(neighborhoodsvalid);}
  SquareMask ret;
  SquareMask sourcemask=source->getSquares(game);
  for (int sq=0;sq<64;++sq)
    if(sourcemask.member(sq))
      ret|=neighborhoods[sq];
  return ret;
}
  

void VectorNode::makeNeighborhoods(){
  uassert(!neighborhoodsvalid,"vector internal");
  for (int sq=0;sq<64;++sq){
    SquareMask mask=parameter.neighborhood(sq);
    neighborhoods[sq]=mask;
  }
  neighborhoodsvalid=true;
}
    
