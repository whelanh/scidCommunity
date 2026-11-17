/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
bool RayNode::isSet(){
  return range==nullptr;
}

bool RayNode::isCountable(){
  return range!=nullptr;
}

void RayNode::print(){
  printf("\n");tab();
  printf("<%s ",thisclass());
  if(isAttack) printf(" isAttack ");
  if(range) {
    printf(" Range: ");
    range->print();
  }
  for(auto d:directions){
    printf(" ");
    d.print();
  }
  printf("\n");
  indent();
  int nds=(int)(designators.size());
  for(int i=0;i<nds;++i){
    tab();
    printf("Ray designator %d of %d: ",i,nds);
    designators[i]->print();
    printf("\n");
  }
  tab();
  printf(" %s>",thisclass());
  unindent();
}

RayNode::RayNode(vector<Direction>dirs,
		 vector<SetBase*> sets,
		 bool isattack,
		 Range*r){
  uassert(dirs.size()>0);
  uassert(sets.size()>=2);
  directions=dirs;
  for(auto s:sets) uassert(s);
  designators=sets;
  for (int i=0;i<designators.size();++i)
    designatorMasks.push_back(SquareMask());
  uassert(designatorMasks.size()==designators.size());
  isAttack=isattack;
  if(isAttack) uassert(dirs.size()==Direction::allDirections().size(),"raynode constructor internal");
  range=r;
}

bool RayNode::match_position(Game * game){
  //  printf("rn:mcp: called\n");
  Position * p=game->GetCurrentPos();
  const pieceT * board=p->GetBoard();
  int nmatches=0;
  matchedSoFar.clear();
  uassert(designators.size()>1);
  uassert(designatorMasks.size()==designators.size());
  for (int i=0;i<designators.size();++i){
    SetBase*designator=designators.at(i);
    uassert(designator);
    designatorMasks[i]=designator->getSquares(game);
  }
  SquareMask startmask=designatorMasks[0];
  for (squareT sq=0;sq<64;++sq)
    if(startmask.member(sq))
      for (Direction direction:directions){
	if (isAttack&&
	    !direction.isCompatible(board[sq]))
	  continue;
	if (match_starting(sq,direction,game))
	  { ++nmatches;
	    if (range&&nmatches>range->max) return false;
	  }
      } //for each direction
  if(range) {
      count=nmatches;
      return range->valid(nmatches);}
  return matchedSoFar.nonempty();
}

bool RayNode::match_count(Game*game, NumValue*value){
  uassert(range,"No range: must include a range when counting rays");
  if(match_position(game)){
    *value=(NumValue)(count);
    return true;
  }
  return false;
}

bool RayNode::match_starting(squareT square, Direction direction, Game*game){
  uassert(square_valid(square));
  int ndesignators=(int)(designators.size());
  uassert(ndesignators>1,"internal match_starting");
  int current=square;
  int nmatched=0;
  nmatched=1;
  while(true){
    uassert(nmatched<ndesignators,"RayNode::match_starting: internal error");
    current=direction.apply(current);
    if (!square_valid(current)) break;
    SquareMask nextmask=designatorMasks.at(nmatched);
    if (nextmask.member(current)){
      nmatched++;
      if(nmatched==ndesignators){
	matchedSoFar.insert(current);
	return true;
      }
    }
    else {
      pieceT piece=MarkBoard::piece_at_square((squareT)current,game);
      if(piece!=EMPTY)return false;
    }
  }
  uassert(nmatched<ndesignators,"match_starting, internal");
  return false;
}

SquareMask RayNode::getSquares(Game*game){
  uassert(!isSet(),
	  "A ray can only be used as a set filter when it does not have a range");
  match_position(game);
  return matchedSoFar;
}
  
