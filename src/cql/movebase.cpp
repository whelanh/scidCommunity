/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
MoveBase::MoveBase(SetBase*f, SetBase*t, PieceLoc*p,SetBase* e,bool nullmove, bool mainline, bool variation){
  uassert(!(mainline&&variation),"Movebase args");
  from =f;
  to=t;
  promote=p;
  enpassantsquare=e;
  nullMove=nullmove;
  primaryMove=mainline;
  secondaryMove=variation;
}

MoveFutureNode::MoveFutureNode(SetBase*from,
			       SetBase*to,
			       PieceLoc* promote,
			       SetBase* enpassant,
			       bool nullmove,
			       bool mainline,
			       bool variation) :
  MoveBase(from, to, promote, enpassant,nullmove,mainline,variation){}

MoveLegalNode::MoveLegalNode(SetBase*from,
			       SetBase*to,
			       PieceLoc* promote,
			       SetBase* enpassant,
			       bool nullmove,
			       bool mainline,
			       bool variation) :
  MoveBase(from, to, promote, enpassant,nullmove,mainline,variation){}

MovePastNode::MovePastNode(SetBase*from,
			       SetBase*to,
			       PieceLoc* promote,
			       SetBase* enpassant,
			       bool nullmove,
			       bool mainline,
			       bool variation) :
  MoveBase(from, to, promote, enpassant,nullmove,mainline,variation){}


vector<simpleMoveT*> MovePastNode::getMoves(Game*game){
  vector<simpleMoveT*>moves;
  if(game->GetCurrentPly()==0) return moves;
  if(primaryMove||secondaryMove){
    int varlevel=game->GetVarLevel(); // should put this in MarkBoard of course, copied from beginvariationnode
    int parentlevel=-1;
    auto me=MarkBoard::identity(game);
    uassert(game->GetCurrentPly()!=0,"MovePastNode: internal getcurrentply");
    MarkBoard::gameBackup(game);
    parentlevel=game->GetVarLevel();
    uassert (varlevel==parentlevel||varlevel==parentlevel+1,"MovePastNode: internal level");
    MarkBoard::gameToChild(me,game,true);
    if (primaryMove && varlevel>parentlevel) return moves;
    if (secondaryMove && varlevel==parentlevel)return moves;
  }
  
  moveT*prev=CqlCurrentMove(game)->prev;
  uassert(prev&&prev->marker!=START_MARKER);
  simpleMoveT* smt= &(prev->moveData);
  moves.push_back(smt);
  return moves;
}

vector<simpleMoveT*>MoveLegalNode::getMoves(Game*game){
  return MarkBoard::getLegalMoves(game);
}

vector<simpleMoveT*>MoveFutureNode::getMoves(Game*game){
  uassert (!(primaryMove&&secondaryMove),"getMoves mv");
  vector<simpleMoveT*>allmoves=MarkBoard::getMoves(game,getSearchVariations());
  vector<simpleMoveT*>ret;
  if (requiredMove){
    uassert(requiredIndex>=0 && requiredIndex<allmoves.size(),"getMoves: required size");
    uassert(requiredMove==allmoves.at(requiredIndex),"getMove, rm ==, possible issue");
    vector<simpleMoveT*>requiredret(1, allmoves.at(requiredIndex));
    if(primaryMove && requiredIndex>0) return ret;
    else if (primaryMove && requiredIndex==0) return requiredret;
    else if (secondaryMove&&requiredIndex==0) return ret;
    else if (secondaryMove&&requiredIndex>0) return requiredret;
    else return requiredret;
  }      
  uassert(requiredIndex== -1,"getMoves: rimo");
  
  if (allmoves.empty())return allmoves;
  if (primaryMove){
    ret.push_back(allmoves.at(0));
    return ret;
  }
  else if (secondaryMove){
    for (int i=1;i<allmoves.size();++i)
      ret.push_back(allmoves.at(i));
    return ret;
  }
  return allmoves;
}  
  
    
SquareMask MoveBase::getSquares(Game*game){
  bool searchvariations=getSearchVariations();
  SquareMask ret;
  if(!searchvariations)
    uassert(MarkBoard::inMainline(game),
	    "unexpectedly in a variation in move");
  vector<simpleMoveT*>moves=getMoves(game);
  for(auto move:moves)
    if(match_move(move,game)){
      squareT tosquare=move->to;
      uassert(square_valid(tosquare));
      ret.insert(tosquare);
    }
  return ret;
}
  
bool MoveBase::match_position(Game*game){
  return getSquares(game).nonempty();
}

bool MoveBase::match_move(simpleMoveT* move, Game*game){
  bool ispast=(dynamic_cast<MovePastNode*>(this)!=nullptr);
  bool ret=true;
  auto me=MarkBoard::identity(game);
  bool movenull=MarkBoard::myIsNullMove(move);
  if(nullMove && !movenull)
    return false;

  //if this is a past move, we backup for all the filters
  if(ispast){
    if(game->GetCurrentPly()==0)
      return false;
    MarkBoard::gameBackup(game);
  }
  if(from){
    squareT fromsquare=move->from;
    uassert(square_valid(fromsquare),"match_move, bad from square");
    bool checkfrom=from->getSquares(game).member(fromsquare);
    if(!checkfrom)ret=false;
  }
  if(to){
    squareT tosquare=move->to;
    uassert(square_valid(tosquare),"match_move, bad to square");
    bool checkto=to->getSquares(game).member(tosquare);
    if(!checkto)ret=false;
  }
  if(promote){
    pieceT promoted=move->promote;
    if(promoted==EMPTY) ret=false;
    else{
      colorT color=game->GetCurrentPos()->GetToMove();
      pieceT promotedpiece=piece_Make(color,promoted);
      if(color==WHITE)
	uassert(promotedpiece==WQ||
		promotedpiece==WR||
		promotedpiece==WN||
		promotedpiece==WB);
      else if(color==BLACK)
	uassert(promotedpiece==BQ||
		promotedpiece==BR||
		promotedpiece==BN||
		promotedpiece==BB);
      else
	uassert(false, "promotion internal");
      bool checkpromoted=promote->match_piece(promotedpiece);
      if(!checkpromoted)ret=false;
    }
  }
  if(enpassantsquare){
    squareT capturedsquare=move->capturedSquare;
    squareT tosquare=move->to;
    if(tosquare==capturedsquare)ret= false;
    else{
      bool epto=enpassantsquare->getSquares(game).member(capturedsquare);
      if(!epto)ret=false;
    }
  }//enpassantsquare
  if(ispast)
    MarkBoard::gameToChild(me,game,getSearchVariations());
  uassert(me==MarkBoard::identity(game),"id fail check movebase");
  return ret;
}

vnode MoveBase::children(){
  vnode v;
  if(from)v.push_back(from);
  if(to)v.push_back(to);
  if(promote)v.push_back(promote);
  if(enpassantsquare)v.push_back(enpassantsquare);
  return v;
}
  
void MoveBase::print(){
  printf("<%s",thisclass());
  printVariationFlags();
  if(from) {
    printf(" from ");
    from->print();}
  if (to){
    printf(" to ");
    to->print();
  }
  if (promote){
    printf(" promote ");
    promote->print();
  }
  if(enpassantsquare){
    printf(" enpassant ");
    enpassantsquare->print();
  }
  if(nullMove){
    printf(" nullMove ");
  }
  if (primaryMove)
    printf(" primaryMove ");
  if (secondaryMove)
    printf(" secondaryMove ");
  printf("%s>",thisclass());
}

