/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"

#include <cstring>

int CqlMatchCount = 0;
uint CqlMatchPlyFirst;

void CqlNode::do_match(MFilter*p,Game*game){
  NumericVariable*mc=Variable::matchCountVariable();
  bool searchvariations=getSearchVariations();
  if(!searchvariations)
    uassert(MarkBoard::inMainline(game));
  auto id=MarkBoard::identity(game);
  if(p->match_position(game)){
    mc->increment();
    // If our first match is in a variation, set the ply to 1.
    if (!CqlMatchCount++) {
      if (game->GetVarLevel()) CqlMatchPlyFirst = 1;
      else CqlMatchPlyFirst = game->GetCurrentPly();
    }
    if(p->annotateFlag&&!isSilent())
      MarkBoard::gameAppendComment(game,"MATCH");
  }
  //  printf("cqlnode: unbinding tags at ply: %d\n",game->GetCurrentPly());
  Variable::unbindTags();
  int nchildren=MarkBoard::number_children(game,searchvariations);
  vector<moveT*>ids;
  ids.push_back(id);
  for(int i=0;i<nchildren;++i){
    MarkBoard::move_to_child(game,i);
    auto childid=MarkBoard::identity(game);
    for(auto oid:ids)
      uassert(oid!=childid,"idcheck fail");
    ids.push_back(childid);
    do_match(p,game);
    MarkBoard::gameBackup(game);
    uassert(id==MarkBoard::identity(game),"movecheckfail");
  }
  uassert(id==MarkBoard::identity(game),"movecheckfail2");
  uassert(mc->getValue()==mc->getExtremalValue());
}

bool CqlNode::match_game(Game*game){
  game->MoveToPly(0);
  if(CqlDebug) {
    printf("\n\ncqlnode:match_game entered: %d\n", CqlGameNumber());
    util::printgame(stdout,game);
  }
#ifdef STANDALONE
  //MarkBoard::cleanFirstComment(game);
  const std::string comment="Game number "+std::to_string(CqlGameNumber());
  if(!isSilent())MarkBoard::gameAppendComment(game,comment.c_str());
#endif
  if(usemarks) MarkBoard::mark(game);
  SequenceBase::nestsClear();
  NumericVariable::resetAll();
  NumericVariable*mc=Variable::matchCountVariable();
  mc->bindNumeric(0);
  // first check the standard tags
  for(GameFilter* gf : gamefilters)
    if(!gf->match_game(game))
      return false;
  CqlMatchCount = 0;
  do_match(filter,game);
  int nmatches=static_cast<int>(mc->getValue());
  uassert(nmatches==static_cast<int>(mc->getExtremalValue()));
  bool matched=false;
  if(matchCountRange)
    matched=matchCountRange->valid(nmatches);
  else matched=(nmatches>0);
  if(matched)
    annotateEchoes(game);
  if(matched && CqlDebug) {
    printf("\n\ncqlnode:match_game matched on game: %d\n", CqlGameNumber());
    util::printgame(stdout,game);
  }
  return matched;
}

void CqlNode::match(){
  Game * game=new Game;
  MFile*inputMFile=new MFile;
  printf("CQL: reading PGN file: %s: \n",inputfile.c_str());
  if(inputMFile->Open(inputfile.c_str(),FMODE_ReadOnly)!=OK)
    uassert(false,"Unable to open file: ",inputfile.c_str());
  inputMFile->skipNonAscii();
  PgnParser pgnparser(inputMFile);
  currentGameNumber=0;
  uassert(!outputfile.empty(),"missing output file");
  uassert(!outputstream,"unexpected outputstream");
  outputstream=fopen(outputfile.c_str(),"w");
  uassert(outputstream,"CQL: could not open file for writing: ",outputfile.c_str());
  int nmatches=0;
  vector<GameSortInfo>infos;
  while(pgnparser.ParseGame(game)!=ERROR_NotFound){
    if(0){
      printf("cqlnode:match printing just after parse: \n");
      util::printgame(stdout,game);
      printf("clqnode:match: done print just after parse\n");
    }
    CqlSetGameNumber(++currentGameNumber);
    if(gamenumberrange){
      if(currentGameNumber>gamenumberrange->max)
	break;
      else if(currentGameNumber<gamenumberrange->min)
	continue;
    }
    if ((currentGameNumber-1)%1000==0&&currentGameNumber>1000)
      printf("%d\n",currentGameNumber);
    else if ((currentGameNumber-1)%100==0)printf(".");
    bool matched=match_game(game);
    if(matched) {
      ++nmatches;
      printf("+<%d>",CqlGameNumber());
      setFirstComment(game);
      infos.push_back(makeInfo(game));
    } // if (matched)
  } // while next game
  GameSortInfo::sort(infos);
  GameSortInfo::output(outputstream,infos);
  printf("\nCQL: wrote %d matching game%s to file: %s\n",
	 nmatches,
	 nmatches==1 ? "" : "s",
	 outputfile.c_str());
}


// Everything below this line is kludgeville... necessary because any inclusion
// of a header from this directory in tkscid.cpp descends into include-file-hell.

#ifdef INTEGRATED

bool CqlQueryGameNumberRange(int *first, int *last) {
  if (!CqlParseRoot || !CqlParseRoot->gamenumberrange)
    return false;
  if (first)
    *first = CqlParseRoot->gamenumberrange->min;
  if (last)
    *last = CqlParseRoot->gamenumberrange->max;
  return true;
}

namespace {

// The same test the nodes use: a null tag matches nothing.
bool tagContains(const char *tag, const std::string &value) {
  return tag && std::strstr(tag, value.c_str()) != nullptr;
}

// One game-level filter, answered from the index entry. This mirrors what the
// node's match_game()/match_position() does with the decoded Game, whose tags
// Game::LoadStandardTags() fills from the index entry and the name base.
bool indexRejectsFilter(const GameFilter &gf, const IndexEntry &ie,
                        const NameBase &names) {
  if (auto *result = dynamic_cast<const ResultNode *>(&gf)) {
    return result->result != RESULT_None && result->result != ie.GetResult();

  } else if (auto *player = dynamic_cast<const PlayerNode *>(&gf)) {
    const bool checkWhite = player->color == WHITE || player->color == NOCOLOR;
    const bool checkBlack = player->color == BLACK || player->color == NOCOLOR;
    const bool whiteMatches =
        checkWhite &&
        tagContains(names.GetName(NAME_PLAYER, ie.GetWhite()), player->name);
    const bool blackMatches =
        checkBlack &&
        tagContains(names.GetName(NAME_PLAYER, ie.GetBlack()), player->name);
    return !whiteMatches && !blackMatches;

  } else if (auto *event = dynamic_cast<const EventNode *>(&gf)) {
    return !tagContains(names.GetName(NAME_EVENT, ie.GetEvent()), event->name);

  } else if (auto *site = dynamic_cast<const SiteNode *>(&gf)) {
    return !tagContains(names.GetName(NAME_SITE, ie.GetSite()), site->name);

  } else if (auto *year = dynamic_cast<const YearNode *>(&gf)) {
    return !year->range->valid(static_cast<int>(date_GetYear(ie.GetDate())));

  } else if (auto *elo = dynamic_cast<const EloNode *>(&gf)) {
    const bool checkWhite = elo->color == WHITE || elo->color == NOCOLOR;
    const bool checkBlack = elo->color == BLACK || elo->color == NOCOLOR;
    return !((checkWhite && elo->range->valid(ie.GetWhiteElo())) ||
             (checkBlack && elo->range->valid(ie.GetBlackElo())));
  }

  // GameNumberNode is answered by CqlQueryGameNumberRange() before this; any
  // other filter is left for the decoded game.
  return false;
}

// Collect game-level filters, but only where they are a conjunct the position
// must satisfy. PositionNode is the engine's "all of these at once", so a
// rejecting spec rejects the position; every other node (or, not, relation,
// past, ...) can still match without it, so it is not descended into. The same
// filters can appear in the cql() specification, which CqlNode keeps in
// gamefilters instead.
void collectIndexFilters(const Node *node,
                         std::vector<const GameFilter *> &filters) {
  if (!node)
    return;
  if (auto *position = dynamic_cast<const PositionNode *>(node)) {
    for (const MFilter *spec : position->specs)
      collectIndexFilters(spec, filters);
    return;
  }
  if (auto *gf = dynamic_cast<const GameFilter *>(node))
    filters.push_back(gf);
}

// The filters that can be answered from the index entry, flattened once per
// parse: walking the tree and dynamic_casting for every game would put back a
// cost on queries that do not even use a tag filter.
std::vector<const GameFilter *> indexFilters;

} // namespace

void CqlQueryPrepareIndexFilters() {
  indexFilters.clear();
  if (!CqlParseRoot)
    return;
  indexFilters.insert(indexFilters.end(),
                      CqlParseRoot->gamefilters.begin(),
                      CqlParseRoot->gamefilters.end());
  collectIndexFilters(CqlParseRoot->filter, indexFilters);
}

bool CqlQueryIndexRejectsGame(const IndexEntry &ie, const NameBase &names) {
  for (const GameFilter *gf : indexFilters)
    if (indexRejectsFilter(*gf, ie, names))
      return true;
  return false;
}

bool CqlMatchGame(Game *game) {
  Range* gamenumberrange = CqlParseRoot->gamenumberrange;
  int currentGameNumber = CqlGameNumber();
  if(gamenumberrange) {
    if(currentGameNumber > gamenumberrange->max || currentGameNumber < gamenumberrange->min)
      return false;
  }

  return CqlParseRoot->match_game(game);
}
#endif
