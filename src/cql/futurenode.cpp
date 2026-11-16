#include "node.h"

FutureNode::FutureNode(vector<SeqConstituent*>cs,Range*r,bool isskip,bool allownest):SequenceBase(cs,r,isskip,allownest){
}

SeqRet FutureNode::compute(HolderConstituent*holder,SeqStack&stack){
  size_t stacklen=stack.size();
  uassert(holder,"fncholdererr");
  MFilter*filter=holder->filter;
  uassert(filter,"fncfilter");
  if (!CqlDoNotLinearize && !linearize(filter).empty())
    return computeLinearize(holder,stack);
  if(!filter->match_position(game))
    return SeqRet(false);
  if(stack.empty())return SeqRet(game,holder->getOffset());
  auto me=MarkBoard::identity(game);
  int nchildren=MarkBoard::number_children(game,getSearchVariations());
  SeqRet best(false);
  for(int childindex=0;childindex<nchildren;++childindex){
    MarkBoard::move_to_child(game,childindex);
    SeqRet sub=SequenceBase::compute(stack); //Why do I need the class qualifier?
    best=std::max(best,sub);
    MarkBoard::gameBackup(game);
  }
  if(nchildren==0)
    best=computeNull(stack);
  uassert(me==MarkBoard::identity(game),"id fail check sequence");
  if(best.isFalse())return best;
  best.addParent(game,holder->getOffset());
  uassert(stack.size()==stacklen,"fnch size");
  return best;
}

void FutureNode::notate(SeqRet& ret){
  if(isSilent())return;
  uassert(ret.isTrue(),"notate rist");
  int len=ret.getLength();
  if(!len)return;
  moveT*me=MarkBoard::identity(game);
  moveT*previousid=NULL;
  uassert(me==ret.getId(0),"notate bad back");
  char buffer[1000];
  int positionsseen=0;
  int positionsexpected=len;
  if(isSkip()) positionsexpected=(len+1)/2;
  for(int index=0;index<len;++index){
    if(previousid){
      uassert(previousid==MarkBoard::identity(game),"idcheck fail notateoop");
      moveT*nextid=ret.getId(index);
      MarkBoard::gameToChild(nextid,game,getSearchVariations());
    }
    moveT*thisid=MarkBoard::identity(game);
    uassert(thisid==ret.getId(index),"idcheck fail notate");
    int offset=ret.getOffset(index);
    if(offset>=0){
      nestRegisterPosition(game);
      ++positionsseen;
      sprintf(buffer,"NEXT %d (position %d of %d)",offset+1,positionsseen,positionsexpected);
      MarkBoard::gameAppendComment(game,buffer);
    }
    previousid=thisid;
  }
  uassert(MarkBoard::identity(game)==ret.getId(len-1),"bad id check notate");
  MarkBoard::gameToIdentity(me,game,getSearchVariations());
}
