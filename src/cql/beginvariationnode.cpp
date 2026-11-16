#include "node.h"
bool BeginVariationNode::match_position(Game*game){
  int varlevel=game->GetVarLevel();
  if(varlevel==0)return false;
  int parentvarlevel=-1;
  auto me=MarkBoard::identity(game);
  uassert(game->GetCurrentPly()!=0,"PVN: internal getcurrentply");
  MarkBoard::gameBackup(game);
  parentvarlevel=game->GetVarLevel();
  MarkBoard::gameToChild(me,game,true);
  return varlevel>parentvarlevel;
}
