#include "node.h"
void SequenceBase::nestsClear(){
  for (SequenceBase* filterp: *nestGetSequenceFilters()){
    uassert(filterp,"nestsClear:internal");
    filterp->nestClearPositions();
  }
}

void SequenceBase::nestRegisterPosition(Game*game){
  moveT*me=MarkBoard::identity(game);
  nestIds.insert(me);
}

bool SequenceBase::nestSeenPosition(Game*game){
  uassert(nestBan,"nestSeenPosition: internal");
  moveT*me=MarkBoard::identity(game);
  if(nestIds.count(me)>0)return true;
  return false;
}

void SequenceBase::nestClearPositions(){
  nestIds.clear();
}

set<SequenceBase*>* SequenceBase::nestGetSequenceFilters(){
  if (CqlAllSequences) return CqlAllSequences;
  CqlAllSequences=new set<SequenceBase*>;
  CqlNode*root=CqlParseRoot;
  uassert(root,"nestGetSequenceFilters: internal");
  auto descendants=root->descendants();
  for(auto d : descendants){
    uassert(d,"nestGetSequenceFilters: null descendant");
    SequenceBase* s= dynamic_cast<SequenceBase*>(d);
    if(s) CqlAllSequences->insert(s);
  }
  return CqlAllSequences;
}

