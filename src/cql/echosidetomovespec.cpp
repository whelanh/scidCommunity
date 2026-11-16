#include "node.h"
EchoSideToMoveSpec::EchoSideToMoveSpec(bool sameside){
  same=sameside;
}

void EchoSideToMoveSpec::print(){
  printf("<%s %s>",thisclass(),
	 same?"same":"different");
}

bool EchoSideToMoveSpec::match_target(){
  uassert(insearch,"sidetomove");
  colorT tomove=theGame->GetCurrentPos()->GetToMove();
  uassert (color_valid(tomove)&&color_valid(sourceToMove));
  if (same) return tomove==sourceToMove;
  else return tomove!=sourceToMove;
}

void EchoSideToMoveSpec::start_new_search(Game*game){
  uassert(!insearch&&!color_valid(sourceToMove));
  EchoSpec::start_new_search(game);
  uassert(insearch&&game==theGame);
  sourceToMove=game->GetCurrentPos()->GetToMove();
  uassert(color_valid(sourceToMove));
}

void EchoSideToMoveSpec::end_search(){
  uassert(insearch&&color_valid(sourceToMove));
  sourceToMove=NOCOLOR;
  EchoSpec::end_search();
}

