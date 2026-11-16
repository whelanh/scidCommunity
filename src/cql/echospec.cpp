#include "node.h"
void EchoSpec::start_new_search(Game*game){
  uassert(!insearch&&!sourceIdentity);
  sourceIdentity=MarkBoard::identity(game);
  theGame=game;
  insearch=true;
}

void EchoSpec::end_search(){
  uassert(insearch&&sourceIdentity);
  insearch=false;
  sourceIdentity=NULL;
}

bool EchoSpec::match_target(Transform*t){
  uassert(false,
	  "\nAn echo transform can only operator on echo square specifiers, not on specifiers of type: ",
	  thisclass());
  return false;
}
