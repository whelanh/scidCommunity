/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include <string>
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
  return lca!=nullptr;
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

namespace {

// The engine's comment limit: MarkBoard::gameAppendComment() drops a comment
// longer than 500 characters (and asserts on one of 2000 or more), so an id
// list is cut here, with an explicit marker, instead of being handed over and
// thrown away. The list used to be built with sprintf() into a fixed 2000-byte
// stack buffer with no bound at all, which overflows for a relation whose
// source has a few hundred targets.
const size_t kIdListLimit = 480;

// "SOURCE 1 [3 4 7]" - the ids are 1-based target/source numbers, in the order
// they were first seen. A list too long for one comment ends with "...]" so
// the reader can tell a cut list from a complete one.
std::string idList(const char*label,int number,const vector<int>&ids){
  std::string text(label);
  text+=' ';
  text+=std::to_string(number);
  text+=" [";
  for(int id:ids){
    const std::string next=std::to_string(id+1)+' ';
    if(text.size()+next.size()+1>kIdListLimit)
      return text+"...]";
    text+=next;
  }
  text[text.size()-1]=']'; // the space after the last id becomes the bracket
  return text;
}

} // namespace

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
    MarkBoard::gameAppendComment(game,thissource,
				 idList("SOURCE",i+1,targetids).c_str());
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
    MarkBoard::gameAppendComment(game,thistarget,
				 idList("TARGET",i+1,sourceids).c_str());
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

