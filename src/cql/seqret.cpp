#include "node.h"
SeqRet::SeqRet(bool b){
  success=b;
};

SeqRet::SeqRet(Game*game,int offset){
  uassert(offset>=0,"seqret");
  success=true;
  ids.push_back(MarkBoard::identity(game));
  offsets.push_back(offset);
}

int SeqRet::getOffset(int index)const{
  int trueindex=getTrueIndex(index);
  return offsets.at(trueindex);
}

moveT* SeqRet::getId(int index)const{
  int trueindex=getTrueIndex(index);
  return ids.at(trueindex);
}

int SeqRet::getTrueIndex(int index)const{
  int len=getLength();
  uassert(index>=0&&index<len);
  int ret=len-index-1;
  uassert(ret>=0&&ret<len);
  return ret;
}
  
void SeqRet::print(){
  printf("<%s %d",thisclass(),success);
  indent();
  for(int i=0;i<getLength();++i){
    printf("\n");
    tab();
    printf("id/off %d of %d: %p %d",
	   i,
	   getLength(),
	   getId(i),
	   getOffset(i));
  }
  unindent();
  printf("\n");
}

bool operator<(const SeqRet&a, const SeqRet&b){
  if (a.isFalse()&&b.isFalse())return false;
  if (a.isFalse()&&b.isTrue())return true;
  if (a.isTrue()&&b.isFalse())return false;
  uassert(a.isTrue()&&b.isTrue());
  return a.getLength()<b.getLength();
}

void SeqRet::addParent(Game*game, int offset){
  uassert(ids.size()==offsets.size());
  uassert(isTrue(),"SeqRet::addParent false");
  //  uassert(offsets.empty()||offset<0||offsets.back()>=offset,"SeqRet offset");
  ids.push_back(MarkBoard::identity(game));
  offsets.push_back(offset);
}

int SeqRet::getLength()const{
  int len=(int)(ids.size());
  uassert(len==(int)(offsets.size()));
  uassert(len<10000,"Too long seqret");
  return len;
}
