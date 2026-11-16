#include "node.h"
EchoDistanceSpec::EchoDistanceSpec(Range*r,NumericVariable*v){
  uassert(r,"missing range to distancespec");
  range=r;
  assignee=v;
}

  
void EchoDistanceSpec::print(){
  printf("<%s Range:",thisclass());
  range->print();
  printf(">");
}

bool EchoDistanceSpec::match_distance(int sourcedistance,int targetdistance){
  computeCount(sourcedistance,targetdistance);
  int val=getCount();
  uassert(val>=0,"internal echodistancespec");
  return range->valid(val);
}

bool EchoDistanceSpec::match_lca(const vector<moveT*>& sourcepath,
				 const vector<moveT*>& targetpath){
  uassert(sourcepath.size()&&targetpath.size()&&sourcepath[0]==targetpath[0]);
  uassert(targetpath.back()==MarkBoard::identity(theGame));
  int sourcedistance=(int)(sourcepath.size()-1);
  int targetdistance=(int)(targetpath.size()-1);
  if(!match_distance(sourcedistance,targetdistance))return false;
  return true;
}


void EchoMaxDistanceSpec::computeCount(int sourced, int targetd){
  setCount(std::max(sourced,targetd));
}

void EchoSourceDistanceSpec::computeCount(int sourced,int targetd){
  setCount(sourced);
}

void EchoTargetDistanceSpec::computeCount(int sourced, int targetd){
  setCount(targetd);
}

void EchoSumDistanceSpec::computeCount(int sourced,int targetd){
  setCount(sourced+targetd);
}
  
