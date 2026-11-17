/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"

PastNode::PastNode(vector<SeqConstituent*>cs,Range*r,bool isskip, bool allownest):SequenceBase(std::move(cs),r,isskip,allownest){
}

SeqRet PastNode::compute(HolderConstituent*holder,SeqStack&stack){
  size_t stacklen=stack.size();
  uassert(holder,"fncholdererr");
  MFilter*filter=holder->filter;
  uassert(filter,"fncfilter");
  if(!filter->match_position(game))
    return {false};
  if(stack.empty())return {game,holder->getOffset()};
  auto me=MarkBoard::identity(game);
  SeqRet best(false);
  if(game->GetCurrentPly()!=0){
    MarkBoard::gameBackup(game);
    best=SequenceBase::compute(stack);
    MarkBoard::gameToChild(me,game,getSearchVariations());
  }
  else
    best=computeNull(stack);
  uassert(me==MarkBoard::identity(game),"id fail check sequence");
  if(best.isFalse())return best;
  best.addParent(game,holder->getOffset());
  uassert(stack.size()==stacklen,"fnch size");
  return best;
}

void PastNode::notate(SeqRet& ret){
  if(isSilent())return;
  uassert(ret.isTrue(),"notate rist");
  int len=ret.getLength();
  if(!len)return;
  moveT*me=MarkBoard::identity(game);
  moveT*previousid=nullptr;
  uassert(me==ret.getId(0),"notate bad back");
  int positionsseen=0;
  int positionsexpected=len;
  if(isSkip()) positionsexpected=(len+1)/2;
  for(int index=0;index<len;++index){
    if(previousid){
      uassert(previousid==MarkBoard::identity(game),"idcheck fail notateoop");
      moveT*nextid=ret.getId(index);
      uassert(nextid&&nextid!=previousid,"pastnode notate next next");
      MarkBoard::gameBackup(game);
      uassert(nextid==MarkBoard::identity(game),"pastnode notate id check fail");
    }
    moveT*thisid=MarkBoard::identity(game);
    uassert(thisid==ret.getId(index),"idcheck fail notate");
    int offset=ret.getOffset(index);
    if (offset>=0){
      ++positionsseen;
      const std::string comment="PREVIOUS "+std::to_string(offset+1)+" (position "+
        std::to_string(positionsseen)+" of "+std::to_string(positionsexpected)+")";
      MarkBoard::gameAppendComment(game,comment.c_str());
    }
    previousid=thisid;
  }
  uassert(MarkBoard::identity(game)==ret.getId(len-1),"bad id check notate");
  MarkBoard::gameToIdentity(me,game,getSearchVariations());
}

