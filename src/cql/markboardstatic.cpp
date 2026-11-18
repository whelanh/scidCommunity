/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "util.h"
#include "cql.h"
#include "markboard.h"
#include "cqlglobals.h"
#include <cstring>
#include <map>
#include <string>

namespace {

// A PGN variation may hold no moves at all - "( {a note} )" - which scid keeps
// as an empty variation: entering it leaves the cursor on its end marker.
// There is no position in it to match, so the matcher must not walk in: it
// would call MoveForward() on that end marker and fail with "gameforward fail".
// The only way to tell is to enter the variation, which leaves the position
// exactly as it was.
bool variationIsEmpty(Game *game, uint varNumber) {
  if (game->MoveIntoVariation(varNumber) != OK)
    return true;
  const bool empty = game->AtVarEnd();
  game->MoveExitVariation();
  return empty;
}

// The variation number of the nth non-empty variation, counting from zero, or
// -1 when there are fewer. Empty variations are skipped so that the child
// indexes number_children() reports still line up.
int nthNonEmptyVariation(Game *game, int n) {
  const uint numvars = game->GetNumVariations();
  for (uint v = 0; v < numvars; ++v) {
    if (variationIsEmpty(game, v))
      continue;
    if (n-- == 0)
      return static_cast<int>(v);
  }
  return -1;
}

} // namespace

int  MarkBoard::number_children(Game*game, bool searchvariations){
  int nseen=0;
  bool currentatend=game->AtVarEnd();
  if (!currentatend)++nseen;
  if(searchvariations){
    const uint numvars=game->GetNumVariations();
    // An empty variation is not a child: it holds no position to match.
    for (uint v = 0; v < numvars; ++v)
      if (!variationIsEmpty(game, v))
        ++nseen;
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
  variationnumber=nthNonEmptyVariation(game,variationnumber);
  uassert(variationnumber>=0,"move_to_child: no such non-empty variation");
  MoveIntoVariation(game,static_cast<uint>(variationnumber));
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

void MarkBoard::MoveIntoVariation(Game*game, uint i){
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
  for(uint varnumber=0;varnumber<game->GetNumVariations();++varnumber){
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
  const std::size_t commentlen=std::strlen(comment);
  uassert(commentlen<2000);
  if(commentlen==0)return;
  std::string buffer;
  const char* oldcomment=game->GetMoveComment();
  if(oldcomment && *oldcomment){
    if (std::strstr(oldcomment,comment)) return;
    if(std::strlen(oldcomment)>500){
      printf("\nIgnoring too long comment in game: %u\n",CqlGameNumber());
      return;
    }
    buffer=oldcomment;
#ifdef STANDALONE
    buffer+="; ";
#endif
#ifdef INTEGRATED
    buffer+=" ";
#endif
  }
  buffer+=comment;
  if(buffer.size()>500){
    if(MarkBoard_gameAppendComment_lastignored!=CqlGameNumber()){
      MarkBoard_gameAppendComment_lastignored=CqlGameNumber();
      printf("\nNote: Truncating long comment in game: %u\n",MarkBoard_gameAppendComment_lastignored);
    }
    return;
  }
  game->SetMoveComment(buffer.c_str());
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
  for(uint varnum=0;varnum<game->GetNumVariations();++varnum){
    MoveIntoVariation(game,varnum);
    uassert(!atVarEnd(game),"get_moves end of var in var");
    moves.push_back(getCurrentMove(game));
    uassert(!game->MoveExitVariation());
  }
  int nm=static_cast<int>(moves.size());
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
  static thread_local unsigned gamenumber=0;
  static thread_local std::map<moveT*,vector<simpleMoveT*>> legalmap;
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
    globalMarkBoard=nullptr;
  }
}
