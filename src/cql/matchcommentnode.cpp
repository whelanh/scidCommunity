/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
MatchCommentNode::MatchCommentNode(std::string_view v){
  uassert(!v.empty(),"cannot match empty string");
  value=v;
}

void MatchCommentNode::print(){
  printf("<%s %s>",thisclass(),value.c_str());
}

bool MatchCommentNode::match_position(Game*game){
  const char * comment=game->GetMoveComment();
  if(!comment) return false;
  return strstr(comment,value.c_str())!=nullptr;
}

