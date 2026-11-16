#include "node.h"
int longestCommonSubstring(std::vector<int>a, std::vector<int>b, int* astart, int*bstart);

EchoLongestSubstringSpec::EchoLongestSubstringSpec(Range*r,NumericVariable*v):range{r}{
  uassert(range);
  uassert(range->min>0,"LongestSubstring requires a positive minimum length");
  assignee=v;
}

bool EchoLongestSubstringSpec::match_lca(const vector<moveT*>&sourcepath,
				    const vector<moveT*>&targetpath){
  clearCount();
  int splen=(int)(sourcepath.size());
  int tplen=(int)(targetpath.size());
  if(splen<2||tplen<2)return false; 
  uassert(sourcepath[1]!=targetpath[1]);
  uassert(splen&&tplen&&sourcepath[0]==targetpath[0]);
  vector<int>spints=path_to_ints(sourcepath);
  vector<int>tpints=path_to_ints(targetpath);
  uassert(spints.size()==splen-1);
  uassert(tpints.size()==tplen-1);
  uassert(spints.size()&&tpints.size());
  int sstarti=-1,tstarti=-2;
  int mylen=longestCommonSubstring(spints,tpints,&sstarti,&tstarti);
  if(!mylen)return false;
  uassert(mylen<=spints.size()&&mylen<=tpints.size()&&sstarti>=0&&tstarti>=0&&sstarti<spints.size()&&tstarti<tpints.size());
  uassert(mylen+sstarti<=spints.size());
  uassert(mylen+tstarti<=tpints.size());
  for(int i=0;i<mylen;++i)
    uassert(spints.at(i+sstarti)==tpints.at(i+tstarti));
  if(!range->valid(mylen))return false;
  
  setCount(mylen);
  matchedSourceStart=sstarti;
  matchedTargetStart=tstarti;
  matchedSourcePath.clear();
  matchedTargetPath.clear();
  for(int i=0;i<mylen;++i){
    matchedSourcePath.push_back(sourcepath.at(sstarti+i));
    matchedTargetPath.push_back(targetpath.at(tstarti+i));
  }
  seenmatch=true;
  return true;
}

vector<int> EchoLongestSubstringSpec::path_to_ints(const vector<moveT*>&path){
  int len=(int)(path.size());
  uassert(len>=2);
  vector<int>ret;
  for(int i=len-1;i>0;--i)
    ret.push_back(id_to_int(path.at(i)));
  std::reverse(ret.begin(),ret.end());
  uassert(ret.size()==len-1);
  return ret;
}

int EchoLongestSubstringSpec::id_to_int(moveT*posid){
  uassert(posid);
  pieceT piece=50;
  squareT from=65, to=65;
  //  colorT color=65; Not certain how to handle color, whether encoded in piecetype or not
  getprev(posid,&piece, &from, &to);
  uassert(piece_valid(piece)&&square_valid(from)&&square_valid(to)&&to!=from);
  int tmp= to*100+from;
  tmp=tmp*100+(int)piece;
  uassert(tmp>0&&tmp<5000000);
  return tmp;
}

/* see Game::MoveBackup in game.cpp. 
   The previous position or move which should exist is pointed to in moveT* prev field of arg.
   That field has a moveData field of type simpleMoveT (in orig/movelist.h).
   See game.h for the moveT definition
*/
void EchoLongestSubstringSpec::getprev(moveT* posid,pieceT* piece, squareT*from,squareT*to){
  uassert(posid);
  moveT*prev=posid->prev;
  uassert(prev&&prev->marker!=START_MARKER);
  *from=prev->moveData.from;
  *to=prev->moveData.to;
  *piece=prev->moveData.movingPiece;
  return;
}

void EchoLongestSubstringSpec::print(){
  printf("<%s ",thisclass());
  range->print();
  if(assignee)assignee->print();
  if(seenmatch)
    printf(" matchedLen: %d matchedSourceStart: %d matchedTargetStart: %d",
	   getCount(),matchedSourceStart,matchedTargetStart);
  printf(">");
}
