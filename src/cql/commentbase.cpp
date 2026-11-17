/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
bool CommentBase::match_position(Game*game){
  const std::string comment=printBuffer(game);
  uassert(comment.size()<static_cast<std::size_t>(maxLen),"bad comment");
  MarkBoard::gameAppendComment(game,comment.c_str());
  return true;
}

CommentString::CommentString(std::string_view s):str(s){
  uassert(!s.empty()&&s.size()<static_cast<std::size_t>(maxLen),"bad commentstring arg");
}

std::string CommentString::printBuffer(Game* /*g*/){
  return str;
}

CommentSet::CommentSet(SetBase*v):set(v){
  uassert(v,"commentset arg");
}

std::string CommentSet::printBuffer(Game*g){
  const SquareMask mask=set->getSquares(g);
  std::string comment="[";
  bool seen=false;
  for(int sq=0;sq<64;++sq)
    if(mask.member(sq)){
      if(seen)comment+=',';
      comment+=file_to_char_cql(square_file(sq));
      comment+=rank_to_char_cql(square_rank(sq));
      seen=true;
    }
  comment+=']';
  return comment;
}
void CommentSet::print(){
  printf("<%s set: ",thisclass());
  set->print();
  printf(">");
}
void CommentString::print(){
  printf("<%s \"%s\">",thisclass(),str.c_str());
}
