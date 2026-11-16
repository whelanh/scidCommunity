#include "node.h"

squareT PiOver4Transform::transform(squareT s){
  uassert(false,"An attempt to transform a particular square by 45 degrees was made. The rotate45 filter cannnot be used on individual squares");
  return 0;
}

PiOver4Transform::PiOver4Transform(int t):times{t}{
  uassert(times>=0&&times<8,"PiOver4transform arg");
}

vector<Transform*>PiOver4Transform::rotations(){
  vector<Transform*> v;
  for (int t=1;t<8;++t)
    v.push_back(new PiOver4Transform(t));
  return v;
}

Direction PiOver4Transform::transform(Direction d){
  Direction ret=d;
  for (int i=0;i<times;++i)
    ret=rotate45(ret);
  return ret;
}

Direction PiOver4Transform::rotate45(Direction d){
  static vector<Direction> directions{
      Direction (1,0),
      Direction (1,1),
      Direction (0,1),
      Direction (-1,1),
      Direction (-1,0),
      Direction (-1,-1),
      Direction (0,-1),
      Direction (1,-1),
      };
  uassert(directions.size()==8);
  for(int i=0;i<8;++i)
    if (d.eq(directions[i]))
      return directions[(i+1)%8];
  uassert(false,"rotate45 internal loop");
  return Direction(0,1);
}
void PiOver4Transform::print(){
  printf("<%s times: %d>",thisclass(),times);
}

SquareMask PiOver4Transform::transform(SquareMask mask){
  if (mask.full()) return mask;
  if (mask.empty())return mask;
  uassert(false,"rotate45 cannot be applied to a particular square");
  return mask;
}

