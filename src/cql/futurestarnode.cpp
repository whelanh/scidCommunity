#include "node.h"
FutureStarNode::FutureStarNode(Node*node,Range*r, int depth){
  uassert(node);
  filter=dynamic_cast<MFilter*>(node);
  uassert(filter,"unexpected nonmfilter to futurestartnode");
  range=r;
  depthMax=depth;
}

void FutureStarNode::print(){
  printf("<%s ",thisclass());
  if(isSilent())printf("silent ");
  if(range)range->print();
  if(depthMax>=0) printf("depthMax: %d",depthMax);
  printf("\n");indent();tab();
  filter->print();
  unindent();
  printf(">");
}

bool FutureStarNode::match_count(Game*game,NumValue*value){
  uassert(range,"If next* is sorted, it requires an explicit range: missing range");
  if(match_position(game)){
    *value=(NumValue)(getCount());
    return true;
  }
  return false;
}


bool FutureStarNode::match_position(Game*game){
  count=0;
  auto pid=MarkBoard::identity(game);
  vector<moveT*> ids;
  compute_counts(game,ids,0);
  uassert(count==(int)(ids.size()));
  uassert(pid==MarkBoard::identity(game));
  if(!range&&!count) return false;
  if(range&& !range->valid(count)) return false;
  for(int idindex=0;idindex<count;++idindex){
    MarkBoard::gameToIdentity(ids[idindex],
			      game,
			      getSearchVariations());
    char buffer[100];
    sprintf(buffer,"next* %d of %d",idindex+1,count);
    if(!isSilent())MarkBoard::gameAppendComment(game,buffer);
  }
  MarkBoard::gameToIdentity(pid,game,getSearchVariations());
  return true;
}

void FutureStarNode::compute_counts(Game*game,vector<moveT*>&ids, int depth){
  if (depthMax>=0 && depth>depthMax) return;
  if(!range&&count)return;
  if(filter->match_position(game)){
    ++count;
    ids.push_back(MarkBoard::identity(game));
    if(!range)return;
  }
  int nchildren=MarkBoard::number_children(game,getSearchVariations());
  for(int child=0;child<nchildren;++child){
    MarkBoard::move_to_child(game,child);
    compute_counts(game,ids,depth+1);
    MarkBoard::gameBackup(game);
  }
}





  

					  
  
