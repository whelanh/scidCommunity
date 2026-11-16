#include "node.h"
 
SeqRet FutureNode::computeLinearize(HolderConstituent* holder, SeqStack&stack){
  size_t stacklen=stack.size();
  uassert(holder,"computerLinearize internal");
  MFilter*filter=holder->filter;
  uassert (filter, "computeLinearize: bad filter");
  vector<simpleMoveT*>allmoves=MarkBoard::getMoves(game,getSearchVariations());
  auto me=MarkBoard::identity(game);
  int nchildren=MarkBoard::number_children(game,getSearchVariations());
  uassert(allmoves.size()==nchildren,"moves/nchildren mismatch: computeLinearize");
  vector<MoveFutureNode*>movefutures=linearize(filter);
  for(auto movefuture : movefutures){
    uassert(movefuture->requiredMove==NULL,"computeLinearize rM");
    uassert(movefuture->requiredIndex=-1,"computeLinearize rI");
  }
  uassert(!movefutures.empty(),"unexpected emptymovefutures");
  SeqRet best(false);
  for (int childindex=0;childindex<nchildren;++childindex){
    /* Set the moveIndex of all the MoveFutureNodes in the current filter*/
    simpleMoveT* currentmove=allmoves.at(childindex);
    for (auto movefuture: movefutures){
      uassert(movefuture->requiredMove==NULL,"cLmfrbmn");
      movefuture->requiredMove=currentmove;
      uassert(movefuture->requiredIndex== -1,"cLmfrI");
      movefuture->requiredIndex=childindex;
  }
    /* Now match the position and restore the old moveIndex values*/
    bool matchedcurrentfilter=filter->match_position(game);
    for (auto movefuture: movefutures){
      uassert(movefuture->requiredMove==currentmove,"cLmfrbmn2");
      movefuture->requiredMove=NULL;
      uassert(movefuture->requiredIndex== childindex,"cLmfrI2");
      movefuture->requiredIndex=-1;
  }
    /*now continue as usual for this childindex*/
    uassert(me==MarkBoard::identity(game),"identity mismatch computeLinear");
    if(matchedcurrentfilter){
    // Now the current filter is a match, but we just look the child'th child...
      MarkBoard::move_to_child(game,childindex);
      // should do error checking here to make sure this child was reached from the right move
      SeqRet sub=SequenceBase::compute(stack);
      best=std::max(best,sub);
      MarkBoard::gameBackup(game);
    } // if matchedcurrentfilter, inside the for(..child...)loop
  } // end the for(...child...) loop
  if(nchildren==0){
    uassert(best.isFalse(),"computeLinear internal best");
    bool defaultmatch=filter->match_position(game);
    if(defaultmatch)best=computeNull(stack);
  }
  uassert(me==MarkBoard::identity(game),"id fail check sequence");
  if(best.isFalse())return best;

  best.addParent(game,holder->getOffset());
  uassert(stack.size()==stacklen,"computeLinear stacksize");
  return best;
  
}

vector<MoveFutureNode*> FutureNode::linearize(Node* filter){
  uassert(filter!=NULL, "linearize null filter");
  vector<MoveFutureNode*> ret;
  MoveFutureNode* movefuturefilter=dynamic_cast<MoveFutureNode*>(filter);
  MovePastNode* movepastfilter=dynamic_cast<MovePastNode*>(filter);
  EchoNode* echofilter=dynamic_cast<EchoNode*>(filter);
  SequenceBase* seqfilter=dynamic_cast<SequenceBase*>(filter);
  FutureStarNode* futurestarfilter=dynamic_cast<FutureStarNode*>(filter);
  PastStarNode* paststarfilter=dynamic_cast<PastStarNode*>(filter);
  if (seqfilter ||
      futurestarfilter ||
      paststarfilter||
      echofilter ||
      movepastfilter) return ret;
  if (movefuturefilter)
    {ret.push_back(movefuturefilter);
      return ret;}
  vector<Node*> children=filter->children();
  for (auto child:children){
    vector<MoveFutureNode*> childlinear=linearize(child);
    for(auto childm : childlinear)
      myinsert(ret,childm);
  }
  return ret;
}
    
