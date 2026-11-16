#include "node.h"
bool CommentBase::match_position(Game*game){
  char buffer[maxLen+5];
  printBuffer(game,buffer);
  uassert(strlen(buffer)<maxLen,"bad comment");
  MarkBoard::gameAppendComment(game,buffer);
  return true;
}

CommentString::CommentString(const char*s):str(s){
  uassert(s&&strlen(s)<maxLen,"bad commentstring arg");
}

void CommentString::printBuffer(Game*g,char*buffer){
  sprintf(buffer,"%s",str);
}

CommentSet::CommentSet(SetBase*v):set(v){
  uassert(v,"commentset arg");
}

void CommentSet::printBuffer(Game*g,char*buffer){
  SquareMask mask=set->getSquares(g);
  char*current=buffer;
  current+=sprintf(buffer,"[");
  bool seen=false;
  for(int sq=0;sq<64;++sq)
    if(mask.member(sq)){
      if(seen)
	current+=sprintf(current,",");
      int file=square_file(sq);
      int rank=square_rank(sq);
      current+=sprintf(current,"%c%c",file_to_char_cql(file),rank_to_char_cql(rank));
      seen=true;
    }
  sprintf(current,"]");
  return;
}
void CommentSet::print(){
  printf("<%s set: ",thisclass());
  set->print();
  printf(">");
}
void CommentString::print(){
  printf("<%s \"%s\">",thisclass(),str);
}
