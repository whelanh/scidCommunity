/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
EchoMatchInfo::EchoMatchInfo(EchoNode* node){
  Game*g=node->theGame;
  uassert(g);
  gamenumber=CqlGameNumber();
  targetnumber=node->nfound;
  source=node->sourceIdentity;
  uassert(source,"bad source emi");
  target=MarkBoard::identity(g);
  for (EchoSpec* spec:node->specs){
    EchoTransformSpec* et=dynamic_cast<EchoTransformSpec*>(spec);
    if(et){
      transform=et->matchedTransform;
      uassert(transform,"expecting nonnull matchedTransform");
      continue;
    }
    EchoLcaSpec* e=dynamic_cast<EchoLcaSpec*>(spec);
    if(!e) continue;
    if(lca) uassert(lca==e->theLca);
    lca=e->theLca;
    uassert(lca);
    EchoLongestSubstringSpec* esubstring=dynamic_cast<EchoLongestSubstringSpec*>(spec);
    if(!esubstring)continue;
    if(esubstring->matchedSourcePath.size()>substringsource.size()){
      substringsource=esubstring->matchedSourcePath;
      substringtarget=esubstring->matchedTargetPath;
    }
    uassert(substringsource.size()&&substringtarget.size()&&
	    substringsource.size()==substringtarget.size());
  }
}
bool EchoMatchInfo::uselca()const{
  return lca!=NULL;
}

int EchoMatchInfo::substringlen()const{
  return (int)(substringsource.size());
}

bool EchoMatchInfo::usesubstring()const{
  return substringlen()>0;
}

void EchoMatchInfo::print(){
  printf("<%s source: %p target: %p lca: %p gamenumber: %d targetnumber: %d substringlen: %d\n",
	 thisclass(),
	 source,
	 target,
	 lca,
	 gamenumber,
	 targetnumber,
	 substringlen());
}

void EchoMatchInfo::annotate(Game* game, const vector<EchoMatchInfo>& infos){
  //Stage 1: Compute the list of sources and targets used
  vector<moveT*>sources;
  vector<moveT*>targets;
  for(auto &emi : infos){
    myinsert(sources,emi.source);
    myinsert(targets,emi.target);
  }
  uassert(sources.size()&&targets.size());

  //Stage 2: Annotate the sources
  for(int i=0;i<sources.size();++i){
    moveT* thissource=sources[i];
    vector<int>targetids;
    for(auto &emi:infos)
      if(emi.source==thissource){
	int targetid=myindex(targets,emi.target);
	uassert(targetid>=0);
	myinsert(targetids,targetid);
      }
    uassert(targetids.size());
    char buffer[2000];
    char*current=buffer;
    current+=sprintf(current,"SOURCE %d [",i+1);
    for(auto targetid: targetids)
      current+=sprintf(current,"%d ",targetid+1);
    --current;
    current+=sprintf(current,"]");
    MarkBoard::gameAppendComment(game,thissource,buffer);
  }

  //Stage 3: Annotate the targets
  for(int i=0;i<targets.size();++i){
    moveT* thistarget=targets[i];
    vector<int>sourceids;
    for(auto &emi:infos)
      if(emi.target==thistarget){
	int sourceid=myindex(sources,emi.source);
	uassert(sourceid>=0);
	myinsert(sourceids,sourceid);
      }
    uassert(sourceids.size());
    char buffer[2000];
    char*current=buffer;
    
    current+=sprintf(current,"TARGET %d [",i+1);
    for(auto sourceid: sourceids)
      current+=sprintf(current,"%d ",sourceid+1);
    --current;
    current+=sprintf(current,"]");
    MarkBoard::gameAppendComment(game,thistarget,buffer);
  }

  //Stage 4: Annotate the LCAs
  vector<moveT*>lcas;
  for(auto& emi:infos){
    if(emi.lca)
      myinsert(lcas,emi.lca);
  }
  for(auto& lca:lcas)
    MarkBoard::gameAppendComment(game,lca,"LCA");
  for(auto& emi:infos)
    if(emi.lca){
      int sourceid=myindex(sources,emi.source);
      int targetid=myindex(targets,emi.target);
      uassert(sourceid>=0&&targetid>=0);
      char buffer[100];
      sprintf(buffer,"[%d,%d]",sourceid+1,targetid+1);
      MarkBoard::gameAppendComment(game,emi.lca,buffer);
    }
      
  //Stage 5: Annotate the longest substring
  vector<moveT*>sourcesubstring;
  vector<moveT*>targetsubstring;
  int maxsubstring=0;
  for(auto&emi:infos)
    if(emi.usesubstring()&&emi.substringlen()>maxsubstring){
      sourcesubstring=emi.substringsource;
      targetsubstring=emi.substringtarget;
      maxsubstring=emi.substringlen();
      uassert(maxsubstring==(int)(sourcesubstring.size())&&
	      sourcesubstring.size()==targetsubstring.size());
    }
  if(maxsubstring>0){
    annotatePath(game, sourcesubstring,"SOURCEPATH",1);
    annotatePath(game, targetsubstring,"TARGETPATH",1);
  }
}
  
void EchoMatchInfo::annotatePath(Game*game, const vector<moveT*>&path,const char * message,int start){
  moveT*oldid=MarkBoard::identity(game);
  MarkBoard::gameToIdentity(path.at(0),game,true);
  char buffer[1000];
  for(int pathi=start;pathi<path.size();++pathi){
    MarkBoard::gameToIdentity(path.at(pathi),game,true);
    sprintf(buffer,"%s: %d",message,pathi);
    MarkBoard::gameAppendComment(game,buffer);
  }
  MarkBoard::gameToIdentity(oldid,game,true);
}

