/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "util.h"
#include "cql.h"
#include "markboard.h"
#include "cqlglobals.h"
#include <map>

int  MarkBoard::number_children(Game*game, bool searchvariations){
  int nseen=0;
  bool currentatend=game->AtVarEnd();
  if (!currentatend)++nseen;
  if(searchvariations){
    int numvars=game->GetNumVariations();
    // This code assumes that a variation will never be at its own varend.
    nseen+=numvars;
  }
  return nseen;
}

pieceT MarkBoard::piece_at_square(squareT square, Game*game){
  uassert(square_valid(square), "internal piece_at_square");
  pieceT p= game->GetCurrentPos()->GetBoard()[square];
  uassert(piece_valid(p));
  return p;
}
    
moveT* MarkBoard::identity(Game*game){
  return CqlCurrentMove(game);
}

simpleMoveT* MarkBoard::getCurrentMove(Game*game){
  uassert(!atVarEnd(game),
	  "Attempt to get a move where there are none to be had"
	  );
  simpleMoveT* s=game->GetCurrentMove();
  uassert(s,"expecting non-null move");
  return s;
}



void MarkBoard::move_to_child(Game*game, int child){
  bool hasmainline= !atVarEnd(game);
  if(hasmainline&& child==0){
    gameForward(game);
    return;
  }
  int variationnumber=child;
  if(hasmainline) variationnumber--;
  uassert(variationnumber>=0 && variationnumber<game->GetNumVariations());
  MoveIntoVariation(game,variationnumber);
  gameForward(game);
}


bool MarkBoard::inMainline(Game*game){
  return game->GetVarLevel()==0;
}

bool MarkBoard::inVariation(Game*game){
  return game->GetVarLevel()>0;
}

bool MarkBoard::atVarEnd(Game*game){
  return game->AtVarEnd();
}

bool MarkBoard::atVarStart(Game*game){
  return game->AtVarStart();
}

void MarkBoard::MoveIntoVariation(Game*game, int i){
  if(game->MoveIntoVariation(i))
    uassert(false,"Move Into Variation error");
}

void MarkBoard::gameForward(Game*g){
  if (global())
    global()->MoveForward();
  else
    {bool r=g->MoveForward();
      uassert(!r,"gameforward fail");
    }
}

void MarkBoard::gameBackup(Game*g){
  if(global()){
    uassert(g==global()->game,"gameBackup");
    global()->MoveBackup();
  }
  else g->MoveBackup();
  if(atVarStart(g)&&inVariation(g))
    g->MoveExitVariation();
  uassert(inMainline(g) || !atVarStart(g));
}

void MarkBoard::gameMoveToPly(Game*g, int ply){ //ply must be 0
  uassert(ply==0);
  if(global()){
    uassert(global()->game==g);
    global()->MoveToPly(ply);
  }
  else
    g->MoveToPly(0);
}
    
  
void MarkBoard::make_move(simpleMoveT*move,Game*game){
  if(move==game->GetCurrentMove())
    {gameForward(game);return;}
  for(int varnumber=0;varnumber<game->GetNumVariations();++varnumber){
    MoveIntoVariation(game,varnumber);
    if(move==game->GetCurrentMove()){
      gameForward(game);
      return;
    }
    else
      game->MoveExitVariation();
  }
  uassert(false,"move not found in make_move");
}

int MarkBoard::getSquare(markT mark){
  MarkBoard*g=global();
  uassert(g,"internal no global found");
  uassert(mark_valid(mark),"internal bad mark gets");
  int square=g->map.marks_to_squares[mark];
  if(square_valid(square))
    uassert(g->map.squares_to_marks[square]==mark,"getsquare mismatch");
  return square;
}

markT MarkBoard::getMark(int square){
  uassert(square_valid(square));
  MarkBoard*g=global();
  uassert(g,"internal no global found2");
  int mark=g->map.squares_to_marks[square];
  if(mark_valid(mark))
    uassert(g->map.marks_to_squares[mark]==square);
  return mark;
}
    
    
  
void MarkBoard::gameToIdentity(moveT* myid, Game*game,bool variations){
  gameMoveToPly(game,0);
  if(gameSeekIdDescendants(myid,game,variations))
    return;
  else uassert(false,"id not found gametoid",myid->san);
}

void MarkBoard::gameToChild(moveT*childid,Game*game, bool variations){
  int nchildren=MarkBoard::number_children(game,variations);
  uassert(nchildren,"No children in gameToChild");
  for (int child=0;child<nchildren;++child){
    move_to_child(game,child);
    if (identity(game)==childid) return;
    else gameBackup(game);
  }
  uassert(false,"gametochild: id not found");
}

bool MarkBoard::gameSeekIdDescendants(moveT*myid, Game*game, bool vars){
  if(identity(game)==myid) return true;
  int nchildren=MarkBoard::number_children(game, vars);
  for(int child=0;child<nchildren;++child){
    move_to_child(game,child);
    if(gameSeekIdDescendants(myid,game,vars)) return true;
    else MarkBoard::gameBackup(game);
  }
  return false;
}

void MarkBoard::gameAppendComment(Game*game, const char* comment){
  uassert(comment);
  uassert(strlen(comment)<2000);
  if(strlen(comment)==0)return;
  char buffer[5000];
  char*current=buffer;
  current[0]=0;
  const char * oldcomment=game->GetMoveComment();
  if(oldcomment){
    if (strstr(oldcomment,comment)) return;
    if(strlen(oldcomment)>500){
      printf("\nIgnoring too long comment in game: %d\n",CqlGameNumber());
      return;
    }
    current+=sprintf(current,"%s",oldcomment);
  }
  if(current!=buffer){
    uassert(*current==0);
#ifdef STANDALONE
    current+=sprintf(current,"; ");
#endif
#ifdef INTEGRATED
    current+=sprintf(current," ");
 #endif
  }
  uassert(*current==0);
  sprintf(current,"%s",comment);
  if(strlen(buffer)>500){
    if(MarkBoard_gameAppendComment_lastignored!=CqlGameNumber()){
      MarkBoard_gameAppendComment_lastignored=CqlGameNumber();
      printf("\nNote: Truncating long comment in game: %d\n",MarkBoard_gameAppendComment_lastignored);
    }
    return;
  }
  game->SetMoveComment(buffer);
  // scidCommunity: scidvspc flagged the Game with SetAltered(true) so the
  // database driver would save it back. Our Game has no such flag; the
  // consumer of the match decides what to persist.
}

void MarkBoard::gameAppendComment(Game*game, moveT*loc, const char*comment){
  moveT* me=identity(game);
  gameToIdentity(loc,game,true);
  gameAppendComment(game,comment);
  gameToIdentity(me,game,true);
}
  
vector<simpleMoveT*> MarkBoard::getMoves(Game*game,bool searchvars){
  vector<simpleMoveT*> moves;
  if(!atVarEnd(game))
    moves.push_back(getCurrentMove(game));
  if(!searchvars) return moves;
  for(int varnum=0;varnum<game->GetNumVariations();++varnum){
    MoveIntoVariation(game,varnum);
    uassert(!atVarEnd(game),"get_moves end of var in var");
    moves.push_back(getCurrentMove(game));
    uassert(!game->MoveExitVariation());
  }
  int nm=(int)(moves.size());
  for(int i=0;i<nm;++i)
    for(int j=i+1;j<nm;++j)
      uassert(moves[i]!=moves[j],"get_moves internal");
  return moves;
}
  
vector<simpleMoveT*> MarkBoard::getLegalMoves(Game*game){
  // Not implemented in scidCommunity. Its only callers are ExtensionNode and
  // MoveLegalNode: Tokens::match_extensionnode() now refuses 'extension' at
  // parse time (nodematch.cpp), and MoveLegalNode is unreachable because
  // 'legal' is never set to true in match_movebase(). Either becoming reachable
  // again needs a real generator here; the body below is not one.
  uassert(false,"getLegalMoves is not implemented");
  static int gamenumber=0;
  static std::map<moveT*,vector<simpleMoveT*>> legalmap;
  if(CqlGameNumber()!=gamenumber){
    gamenumber=CqlGameNumber();
    legalmap.clear();
  }
  moveT* me=identity(game);
  if(legalmap.find(me)==legalmap.end()){
    Position*position=game->GetCurrentPos();
    // scidCommunity: our GenerateMoves() fills a caller owned MoveList
    // instead of returning one through GetLegalMoves().
    MoveList movelist;
    position->GenerateMoves(&movelist);
    vector<simpleMoveT*> movevec;
    for(unsigned int i=0;i<movelist.Size();++i)
      movevec.push_back(movelist.Get(i));
    legalmap[me]=movevec;
  }
  uassert(legalmap.find(me)!=legalmap.end());
  return legalmap[me];
}
  
void MarkBoard::restart(){
  if(globalMarkBoard){
    delete globalMarkBoard;
    globalMarkBoard=NULL;
  }
}
