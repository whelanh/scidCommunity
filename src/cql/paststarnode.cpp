#include "node.h"
PastStarNode::PastStarNode(Node*node,Range*r,int depth){
  uassert(node);
  filter=dynamic_cast<MFilter*>(node);
  uassert(filter,"unexpected nonmfilter to paststarnode");
  range=r;
  depthMax=depth;
}

void PastStarNode::print(){
  printf("<%s ",thisclass());
  if(isSilent())printf("silent ");
  if(range)range->print();
  if(depthMax>=0) printf("depthMax: %d",depthMax);
  printf("\n");indent();tab();
  filter->print();
  unindent();
  printf(">");
}

bool PastStarNode::match_count(Game*game,NumValue*value){
  uassert(range,"If previous* is sorted, it requires an explicit range: missing range");
  if(match_position(game)){
    *value=(NumValue)(getCount());
    return true;
  }
  return false;
}



bool PastStarNode::match_position(Game*game){
  count=0;
  bool variation=MarkBoard::inVariation(game);
  auto pid=MarkBoard::identity(game);
  vector<moveT*> ids;
  compute_counts(game,ids,0);
  uassert(count==(int)(ids.size()));
  uassert(pid==MarkBoard::identity(game));
  if(!range&&!count)return false;
  if(range&&!range->valid(count)) return false;
  if(isSilent())return true;
  for(int idindex=0;idindex<count;++idindex){
    MarkBoard::gameToIdentity(ids[idindex],
			      game,
			      variation);
    char buffer[100];
    sprintf(buffer,"previous* %d of %d",idindex+1,count);
    if(!isSilent())MarkBoard::gameAppendComment(game,buffer);
  }
  MarkBoard::gameToIdentity(pid,game,variation);
  return true;
}

void PastStarNode::compute_counts(Game*game,vector<moveT*>&ids,int depth){
  if (depthMax>=0 && depth>depthMax) return;
  if(!range&&count)return;
  moveT* me=MarkBoard::identity(game);
  bool variation=MarkBoard::inVariation(game);
  if(filter->match_position(game)){
    ++count;
    ids.push_back(me);
    if(!range)return;
  }
  if(game->GetCurrentPly()==0) return;
  MarkBoard::gameBackup(game);
  compute_counts(game,ids,depth+1);
  MarkBoard::gameToChild(me,game,variation);
}





  

					  
  
