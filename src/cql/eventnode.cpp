#include "node.h"
EventNode::EventNode(const char* n):name{n}{
  uassert(n&&name,"eventnode internal");
}

bool EventNode::match_game(Game*game){
  const char* event=game->GetEventStr();
  if(event&&strstr(event,name))
    return true;
  return false;
}
  
void EventNode::print(){
  printf("<%s %s>",thisclass(),name);
}
  
