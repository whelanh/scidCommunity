/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
bool KeywordToken::isReserved(std::string_view s){
  static constexpr std::string_view reserved[]{
    "all", "ancestor", "any", "attack", "attacks", "beginvariation",
    "between", "black", "btm", "check", "cql", "comment", "countsquares",
    "depth", "descendant", "dihedral", "echodihedral", "echoflip",
    "echoflipdihedral", "echoflipvertical", "echofliphorizontal",
    "echorotate45", "echorotate90", "echoshift", "echoshifthorizontal",
    "echoshiftvertical", "elo", "enpassant", "enpassantsquare", "event",
    "extension", "flip", "flipcolor", "flipdihedral", "fliphorizontal",
    "flipvertical", "from", "gamenumber", "hascomment", "in", "initial",
    "input", "lcamax", "lcasource", "lcasubstring", "lcasum", "lcatarget",
    "legal", "mainline", "match", "matchcount", "mate", "max", "min",
    "mismatch", "move", "movenumber", "nestban", "next", "next2", "next*",
    "not", "null", "number", "on", "or", "origin", "output", "pgn", "piece",
    "player", "power", "powerdifference", "previous", "previous2",
    "previous*", "primary", "promote", "ray", "relation", "result", "rotate45",
    "rotate90", "secondary", "shift", "shifthorizontal", "shiftvertical",
    "silent", "site", "sort", "sourcesquares", "square", "stalemate",
    "targetsquares", "terminal", "to", "tomove", "variation", "variations",
    "white", "wtm", "year", "."
  };

  uassert(!s.empty(),"reserved, internal");
  if(s.front()==':')s.remove_prefix(1);
  for(std::string_view k : reserved)
    if(k==s) return true;
  return false;
}

bool KeywordToken::eq(std::string_view s) const{
  uassert(!s.empty(),"eq: internal");
  if(s.front()==':')s.remove_prefix(1);
  return s==value;
}

KeywordToken::KeywordToken(std::string_view x){
  uassert(isReserved(x),"Cannot create keyword from unreserved name: ",std::string(x).c_str());
  if(x.front()==':')x.remove_prefix(1);
  value=x;
}

void KeywordToken::print(){
  printf("<%s: %s %s>",thisclass(),locationString().c_str(), value.c_str());
}
