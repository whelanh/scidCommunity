/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"

EchoNode::EchoNode(vector<Node*>fs, vector<EchoSpec*>ss){
  uassert(filters.empty());
  for(Node*n:fs){
    MFilter*m=dynamic_cast<MFilter*>(n);
    uassert(m,"Bad argument to echonode, expected MFilter");
    filters.push_back(m);
  }
  specs=ss;
  for(auto s:specs) uassert(s,"invalid null spec to echoNode");
  uassert(filters.size()==fs.size());
  uassert(specs.size()==ss.size());
}

void EchoNode::print(){
  printf("<%s NFilters: %zu NSpecs: %zu ",thisclass(),filters.size(),specs.size());
  if(isSilent())printf("silent ");
  std::size_t i=0;
  for(MFilter* filter:filters){
    printf("\n");
    indent();
    tab();
    printf("Filter <%zu of %zu: ",i++,filters.size());
    filter->print();
    unindent();
  }
  i=0;
  for(EchoSpec* spec:specs){
    printf("\n");
    indent();
    tab();
    printf("Spec <%zu of %zu: ",i++,specs.size());
    spec->print();
    unindent();
  }
};
vnode EchoNode::children(){
  vnode v;
  v.insert(v.end(),filters.begin(),filters.end());
  v.insert(v.end(),specs.begin(),specs.end());
  return v;
}


bool EchoNode::match_position(Game*g){
  nfound=0;
  start_new_search(g); //resets game to ply 0
  match_target_children();
  end_search();
  return nfound>0;
}

//begin new search and set game to start
void EchoNode::start_new_search(Game*g){
  uassert(!insearch);
  insearch=true;
  theGame=g;
  if(!matchinfos.empty()&&matchinfos[0].gamenumber!=CqlGameNumber())
    matchinfos.clear();
  sourceIdentity=MarkBoard::identity(g);
  for(auto spec:specs)
    spec->start_new_search(g);
  MarkBoard::gameMoveToPly(theGame,0);
  return;
}

// match the target and, if not found, match the children of the target
void EchoNode::match_target_children(){
  bool searchvariations=getSearchVariations();
  if(match_target()){++nfound;}
  int nchildren=MarkBoard::number_children(theGame,searchvariations);
  for(int child=0;child<nchildren;++child){
      MarkBoard::move_to_child(theGame,child);
      match_target_children();
      MarkBoard::gameBackup(theGame);
    }
}

bool EchoNode::match_target(){
  if(MarkBoard::identity(theGame)==sourceIdentity) return false; //change later if allowed
  for(MFilter*filter : filters)
    if(!filter->match_position(theGame))
      return false;
  for(EchoSpec*spec:specs)
    if(!spec->match_target()) return false;
  assignVariables();
  registerMatch();
  return true;
};

void EchoNode::assignVariables(){
  for(EchoSpec*spec:specs){
    EchoLcaSpec* lcaspec=dynamic_cast<EchoLcaSpec*>(spec);
    if(!lcaspec)continue;
    NumericVariable*var=lcaspec->assignee;
    if(!var) continue;
    int len=lcaspec->getCount();
    var->bindNumeric((NumValue)len);
  }
}

void EchoNode::end_search(){
  uassert(insearch);
  for(auto spec:specs)
    spec->end_search();
  uassert(sourceIdentity);
  MarkBoard::gameToIdentity(sourceIdentity,theGame,true);
  sourceIdentity=nullptr;
  insearch=false;
}

void EchoNode::registerMatch(){
  EchoMatchInfo info(this);
  if(!matchinfos.empty())
    uassert(matchinfos.back().gamenumber==CqlGameNumber());
  matchinfos.push_back(info);
}

void EchoNode::annotate(Game*game){
  if(isSilent())return;
  if(matchinfos.empty() || matchinfos.front().gamenumber!=CqlGameNumber())
    return;
  EchoMatchInfo::annotate(game, matchinfos);
}
  
