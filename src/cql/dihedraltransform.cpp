#include "node.h"

squareT DihedralTransform::transform(squareT s){
  uassert(square_valid(s));
  int x=square_file(s);
  int y=square_rank(s);
  uassert(file_valid(x)&&rank_valid(y));
  int nx=x, ny=y;
  if (reflectx) nx= 7-nx;
  if (reflecty) ny= 7-ny;
  if(swap) std::swap(nx,ny);
  uassert(file_valid(nx)&&rank_valid(ny));
  squareT ret=square_make(nx,ny);
  uassert(square_valid(ret));
  return ret;
}

DihedralTransform::DihedralTransform(bool rx, bool ry, bool sw)
  : reflectx{rx}, reflecty{ry}, swap{sw}{}

vector<Transform*>DihedralTransform::allDihedral(){
  vector<Transform*> v;
  vector<bool> bools{false,true};
  for(bool rx:bools)
    for(bool ry:bools)
      for(bool sw:bools)
	v.push_back(new DihedralTransform(rx,ry,sw));
  return v;
}

Direction DihedralTransform::transform(Direction d){
  squareT d4=square_make(3,3);
  squareT sd4=d.apply(d4);
  uassert(square_valid(sd4)&&sd4!=d4);
  uassert(d.reachable(d4,sd4));
  uassert(!d.reachable(sd4,d4));
  squareT td4=transform(d4);
  squareT tsd4=transform(sd4);
  Direction ret=Direction(0,1);
  int count=0;
  for(auto candidate : Direction::allDirections())
    if(candidate.reachable(td4,tsd4)){
      ret=candidate;
      ++count;}
  uassert(count==1,"bad count in reflect direction");
  return ret;
}

DihedralTransform* DihedralTransform::flipVertical(){
  return new DihedralTransform(true,false,false);
}

DihedralTransform* DihedralTransform::flipHorizontal(){
  return new DihedralTransform(false,true,false);
}

vector<Transform*> DihedralTransform::rotations(){
  return  vector<Transform*>{
      new DihedralTransform(false, true, true),
      new DihedralTransform(true, true, false),
      new DihedralTransform(true, false, true)};
}

void DihedralTransform::print(){
  printf("<%s %d %d %d>",thisclass(),reflectx,reflecty,swap);
}

SquareMask DihedralTransform::transform(SquareMask mask){
  SquareMask ret;
  for(int sq=0;sq<64;++sq)
    if(mask.member(sq)){
      squareT newsq=transform(sq);
      if(square_valid(newsq)) ret.insert(newsq);
      else uassert(false, "transform mask");
    }
  return ret;
}

