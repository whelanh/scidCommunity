/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
#include "cql_pgnparse_adapter.h"
#include "tokenstream.h"
CqlNode::CqlNode(vector<Node*> features,Node*node){
#ifdef STANDALONE
  uassert(features.size(),"null feature");
#endif
  uassert(node);
  filter=dynamic_cast<MFilter*>(node);
  uassert(filter,"CqlNode: bad node argument: expected an mfilter");
  filter->annotateFlag=true;

  for(auto feature : features){
    VariationsNode*variationsnode=dynamic_cast<VariationsNode*>(feature);
    if(variationsnode){
      uassert(!isVariationsSet(),"Only one :variations keyword allowed in a CQL node");
      setSearchVariations(true);
      continue;
    }
  
    SilentFeatureNode*silent=dynamic_cast<SilentFeatureNode*>(feature);
    if(silent){
      makeSilent();
      continue;
    }
    PgnNode *pgnnode=dynamic_cast<PgnNode*>(feature);
    if(pgnnode){
      uassert(!inputfile,"multiple pgn designators");
      inputfile=pgnnode->value;
      uassert(inputfile);
      pgnnode->disable();
      continue;
    }

    OutputNode* outputnode=dynamic_cast<OutputNode*>(feature);
    if(outputnode){
      uassert(!outputfile,"Multiple outputfiles");
      outputfile=outputnode->value;
      uassert(outputfile);
      if(0)printf("cqlnode: got output file of: %s\n",outputfile);
      outputnode->disable();
      continue;
    }

    MatchCountNode* matchcountnode=dynamic_cast<MatchCountNode*>(feature);
    if(matchcountnode){
      uassert(!matchCountRange,"unexpected two matchcount ranges");
      matchCountRange=matchcountnode->range;
      if(matchcountnode->sort){
	NumericVariable*mc=Variable::getNumericVariable("matchcount",true);
	sortfields.push_back(mc);
      }
      continue;
    }
    
    GameNumberNode* gamenumbernode=dynamic_cast<GameNumberNode*>(feature);
    if(gamenumbernode){
      uassert(!gamenumberrange,"unexpected two gamenumberranges");
      gamenumberrange=gamenumbernode->range;
      uassert(gamenumberrange,"expected non-null game number range");
      continue;
    }
    
    GameFilter* gamefilter=dynamic_cast<GameFilter*>(feature);
    if(gamefilter){
      gamefilters.push_back(gamefilter);
      continue;
    }
    uassert(false,"cql unknown feature: ",feature->thisclass());
  }
  if(!isVariationsSet())
    setSearchVariations(false);
  if(!inputfile)
    inputfile=CqlPgnFilename;
  uassert(inputfile,"Missing pgn file: no pgn file was specified either (a) via 'pgn filname.pgn' in cql form, or (b) via '--pgn filename.pgn' or '--input filename.pgn' as a command line argument to 'cql'");
  if(!outputfile)
    outputfile=CqlOutputFilename;
  if(outputfile)
    uassert(filename_is_pgn(outputfile),"Expected pgn extension in output file: ",outputfile);
  if(!outputfile)
    outputfile=outputFileFromCqlFile(CqlFilename);
  if(outputfile)
    uassert(filename_is_pgn(outputfile),"Expected pgn extension in output file: ",outputfile);
  uassert(outputfile,"internal: expected output file in cql creation");
  if(CqlGameNumberRange)
    gamenumberrange=CqlGameNumberRange;
  if(CqlSilent)makeSilent();
  if(CqlPlayer){
    PlayerNode*p=new PlayerNode(CqlPlayer,NOCOLOR);
    gamefilters.push_back(p);
  }
  if(CqlYearRange){
    YearNode*y=new YearNode(CqlYearRange);
    gamefilters.push_back(y);
  }
}

const char* CqlNode::outputFileFromCqlFile(const char* cqlname){
  uassert(filename_is_cql(cqlname));
  const char*stem=filename_stem(cqlname);
  uassert(stem&&strlen(stem),"bad stem from: ",cqlname);
  return util::string_append(stem,"-out.pgn");
}
  
void CqlNode::print(){
  printf("<%s  inputfile: %s outputfile: %s",thisclass(),inputfile,outputfile);
  printVariationFlags();
  if(usemarks) printf(" usemarks ");
  if(gamenumberrange){
    printf(" gamenumberrange: ");
    gamenumberrange->print();
  }
  if(!sortfields.empty()){
    printf(" sortfields:");
    for(NumericVariable* field:sortfields)
      field->print();
  }
  if(matchCountRange){
    printf("matchCountRange: ");
    matchCountRange->print();
  }
  indent();
  std::size_t i=0;
  for(GameFilter* gamefilter:gamefilters){
    printf("\n");
    tab();
    printf("GameFilter %zu of %zu: ",i++,gamefilters.size());
    gamefilter->print();
  }
    
  printf("\n");tab();
  printf("filter: ");
  filter->print();
  printf(" %s>",thisclass());
}


vnode CqlNode::children()
{ vnode ret;
  ret.push_back(filter);
  ret.insert(ret.end(),gamefilters.begin(),gamefilters.end());
  return ret;
};

void CqlNode::setUseMarks(){
  vnode v=descendants();
  for(auto w:v)
    if(dynamic_cast<PieceIdNode*>(w))
      usemarks=true;
}

void CqlNode::setFirstComment(Game*game){
  if (isSilent())return;
  MarkBoard::gameMoveToPly(game,0);
  char buffer[10000];
  char*current=buffer;
  *current=0;
  for(NumericVariable* var:sortfields)
    current+=sprintf(current," %s: %d",var->name,(int)(var->getExtremalValue()));
  MarkBoard::gameAppendComment(game,buffer);
}

     
  
GameSortInfo CqlNode::makeInfo(Game*game){
  vector<SortValue> values;
  for(NumericVariable* var : sortfields)
    values.push_back(SortValue(var->getExtremalValue(),var->isMax()));
  string out=util::game_to_string(game);
  return GameSortInfo(out,values);
}
  
void CqlNode::annotateEchoes(Game*game){
  vnode ds=descendants();
  for(auto n:ds){
    EchoNode*e=dynamic_cast<EchoNode*>(n);
    if(e)e->annotate(game);
  }
}
	   
