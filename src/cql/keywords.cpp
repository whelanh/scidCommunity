#include "node.h"
bool KeywordToken::isReserved(const char* s){
  static const vector<const char*> reserved{
    "all",
    "ancestor",
      "any",
      "attack",
      "attacks",
      "beginvariation",
      "between",
      "black",
      "btm",
      "check",
      "cql",
      "comment",
      "countsquares",
      "depth",
      "descendant",
      "dihedral",
      "echodihedral",
      "echoflip",
      "echoflipdihedral",
      "echoflipvertical",
      "echofliphorizontal",
      "echorotate45",
      "echorotate90",
      "echoshift",
      "echoshifthorizontal",
      "echoshiftvertical",
      "elo",
      "enpassant",
      "enpassantsquare",
      "event",
      "extension",
      "flip",
      "flipcolor",
      "flipdihedral",
      "fliphorizontal",
      "flipvertical",
      "from",
      "gamenumber",
      "hascomment",
      "in",
      "initial",
      "input",
      "lcamax",
      "lcasource",
      "lcasubstring",
      "lcasum",
      "lcatarget",
      "legal",
      "mainline",
      "match",
      "matchcount",
      "mate",
      "max",
      "min",
      "mismatch",
      "move",
      "movenumber",
      "nestban",
      "next",
      "next2",
      "next*",
      "not",
      "null",
      "number",
      "on",
      "or",
      "origin",
      "output",
      "pgn",
      "piece",
      "player",
      "power",
      "powerdifference",
      "previous",
      "previous2",
      "previous*",
      "primary",
      "promote",
      "ray",
      "relation",
      "result",
      "rotate45",
      "rotate90",
      "secondary",
      "shift",
      "shifthorizontal",
      "shiftvertical",
      "silent",
      "site",
      "sort",
      "sourcesquares",
      "square",
      "stalemate",
      "targetsquares",
      "terminal",
      "to",
      "tomove",
      "variation",
      "variations",
      "white",
      "wtm",
      "year",
      "."
	};
  
  uassert(s,"reserved, internal");
  if(*s==':')++s;
  for(const char* k : reserved)
    if(strcmp(k,s)==0) return true;
  return false;
}

bool KeywordToken::eq(const char*s){
  uassert(*s,"eq: internal");
  if(*s==':') s++;
  return strcmp(s,value)==0;
}

KeywordToken::KeywordToken(const char*x){
  uassert(isReserved(x),"Cannot create keyword from unreserved name: ",x);
  if(*x==':')++x;
  value=x;
}

void KeywordToken::print(){
  printf("<%s: %s %s>",thisclass(),locationString(), value);
}
