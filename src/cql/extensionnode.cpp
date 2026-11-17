/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
void ExtensionNode::print(){
  printf("<%s>",thisclass());
}

bool ExtensionNode::match_position(Game* game){
  const vector<simpleMoveT*> moves=MarkBoard::getLegalMoves(game);
  std::string comment="Nlegal: "+std::to_string(moves.size())+" ";
  for (std::size_t i=0;i<moves.size();++i){
    const simpleMoveT* smt=moves[i];
    comment+=std::to_string(i)+": "+square_to_string(smt->from)+"-"+
             square_to_string(smt->to)+"; ";
  }
  MarkBoard::gameAppendComment(game,comment.c_str());
  return true;
}

  
