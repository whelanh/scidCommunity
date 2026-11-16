#include "node.h"
void PieceIdNode::print(){
  printf("<%s variable: ",thisclass());
  variable->print();
  printf(" %lu filters: ",filters.size());
  printf("\n");indent();tab();
  printf("PieceId Set: ");
  set->print();
  unindent();
  for(int i=0;i<filters.size();++i){
    printf("\n");
    indent();
    tab();
    printf("<%d of %lu: ",i,filters.size());
    filters[i]->print();
    unindent();
  }
  printf(" %s> ",thisclass());
}

PieceIdNode::PieceIdNode(TagVariable*v, SetBase*s,vector<Node*>nodes){
  uassert(v,"pieceidnode internal v");
  variable=v;
  uassert(s,"pieceidnode internal s");
  set=s;
  for(Node*np: nodes){
    uassert(np,"internal pieceidnode");
    MFilter * mf=dynamic_cast<MFilter*>(np);
    uassert(mf,"PieceIdNode: unexpected non-mfilter");
    filters.push_back(mf);
  }
  uassert(filters.size()==nodes.size());
}

SquareMask PieceIdNode::getSquares(Game*game){
  SquareMask ret;
  SquareMask setmask=set->getSquares(game);
  uassert(variable->isUnbound(),"PieceID expected unbound variable", variable->name);
  for(int square=0;square<64;++square)
    if(setmask.member(square)){
      int t=MarkBoard::getMark(square);
      if(!mark_valid(t))continue;
      uassert(MarkBoard::getSquare(t)==square);
      variable->bindTag(t);
      bool refuted=false;
      for (auto mfilter : filters)
	if (!mfilter->match_position(game)){
	  refuted=true;
	  break;
	}
      variable->unbind();
      if(!refuted) ret.insert(square);
    }
  return ret;
}
    
vnode PieceIdNode::children(){
  vnode ret{set};
  ret.insert(ret.end(),filters.begin(),filters.end());
  return ret;
}
