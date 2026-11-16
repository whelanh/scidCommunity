#include "util.h"
void DirectionParameter::print(){
  printf("<%s",thisclass());
  for(Direction d : directions){
    printf(" ");
    d.print();
  }
  range->print();
  printf(">");
}

SquareMask DirectionParameter::neighborhood(squareT square){
  SquareMask mask;
  for (Direction direction:directions)
    for(int i=range->min;i<=range->max;++i){
      squareT newsquare=direction.apply(square,i);
      if(square_valid(newsquare))
	mask.insert(newsquare);
    }
  return mask;
}

SquareMask DirectionParameter::neighborhood(SquareMask mask){
  SquareMask m;
  for (squareT square : mask.getSquares())
    m|=neighborhood(square);
  return m;
}

DirectionParameter::DirectionParameter(vector<Direction> ds,Range *r){
  uassert(r&&r->min>=-7&&r->max<=7,"dp invalid range");
  directions=ds;
  range=r;
}




    
