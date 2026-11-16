#include "node.h"
void EchoLcaSpec::setCount(int j){
  uassert(j>=0,"setcount");
  theCount=j;
}

int EchoLcaSpec::getCount(){
  uassert(theCount>=0,"getCount eds");
  return theCount;
}

void EchoLcaSpec::clearCount(){
  theCount=-1;
}

void EchoLcaSpec::computeLca(moveT*sourceid,
			     moveT*targetid,
			     vector<moveT*>&sourcemoves,
			     vector<moveT*>&targetmoves){
  uassert (sourcemoves.empty()&&targetmoves.empty());
  uassert(sourceid&&targetid&&sourceid!=targetid);
  vector<moveT*>sourceback=backsequence(sourceid);
  vector<moveT*>targetback=backsequence(targetid);
  int sourcebacklen=(int)(sourceback.size());
  int targetbacklen=(int)(targetback.size());
  uassert(sourcebacklen&&targetbacklen);
  uassert(sourceback[0]==targetback[0]);
  uassert(sourceback.back()==sourceid);
  uassert(targetback.back()==targetid);
  int lcai=-1;
  for(lcai=0;;lcai++)
    if(lcai>=sourcebacklen||
       lcai>=targetbacklen||
       sourceback[lcai]!=targetback[lcai]
       ) {lcai--;break;}
  uassert(lcai>=0
	  &&lcai<sourcebacklen
	  &&lcai<targetbacklen
	  &&sourceback[lcai]==targetback[lcai]);
  for(int i=lcai;i<sourcebacklen;++i)
    sourcemoves.push_back(sourceback.at(i));
  for(int i=lcai;i<targetbacklen;++i)
    targetmoves.push_back(targetback.at(i));
  theLca=sourcemoves[0];
  uassert(theLca==targetmoves[0]);
}

vector<moveT*>EchoLcaSpec::backsequence(moveT*theid){
  vector<moveT*>ids;
  moveT *oldid=MarkBoard::identity(theGame);
  MarkBoard::gameToIdentity(theid,theGame,true);
  while(true){
    ids.push_back(MarkBoard::identity(theGame));
    if(theGame->AtStart()) break;
    else MarkBoard::gameBackup(theGame);
  }
  uassert(theGame->AtStart());
  std::reverse(ids.begin(),ids.end());
  MarkBoard::gameToIdentity(oldid,theGame,true);
  return ids;
}


bool EchoLcaSpec::match_target(){
  vector<moveT*>sourcepath,targetpath,lcapath;
  moveT* targetid=MarkBoard::identity(theGame);
  uassert(targetid&&sourceIdentity&&targetid!=sourceIdentity);
  computeLca(sourceIdentity,targetid,sourcepath,targetpath);
  uassert(sourcepath.size()&&targetpath.size()&&sourcepath[0]==targetpath[0]&&
	  sourcepath.back()==sourceIdentity&&
	  targetpath.back()==targetid);
  return match_lca(sourcepath,targetpath);
}

void EchoLcaSpec::start_new_search(Game*g){
  EchoSpec::start_new_search(g);
  theLca=NULL;
}

