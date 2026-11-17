/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
PlayerNode::PlayerNode(std::string_view n,colorT c):name{n},color{c}{
  uassert(!name.empty(),"playernode internal");
  uassert(color==WHITE||color==BLACK||color==NOCOLOR,"playernode color");
}

bool PlayerNode::match_game(Game*game){
  const char* whiteplayer=game->GetWhiteStr();
  const char* blackplayer=game->GetBlackStr();
  if( (whiteplayer&&strstr(whiteplayer,name.c_str())
       &&(color==WHITE||color==NOCOLOR))
      ||
      (blackplayer&&strstr(blackplayer,name.c_str())
       &&(color==BLACK||color==NOCOLOR)))
    return true;
  return false;
}
  
void PlayerNode::print(){
  printf("<%s %s %s>",thisclass(),color_string(color),name.c_str());
}
  
