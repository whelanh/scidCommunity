#pragma once
#include "node.h"
class EchoMatchInfo{
 public:
  Game*game{NULL};
  int gamenumber{-1};
  
  int targetnumber{0};
  moveT* source{NULL};
  moveT* target{NULL};
  moveT* lca{NULL};
  bool uselca()const;
  vector<moveT*> substringsource;
  vector<moveT*> substringtarget;
  Transform*transform{NULL};
  int substringlen()const;
  bool usesubstring()const;
  static void annotate (Game*game, const vector<EchoMatchInfo>& infos);
  EchoMatchInfo(EchoNode* node);
  void print();
  const char* thisclass(){return "EchoMatchInfo";}
  static void annotatePath(Game*game, const vector<moveT*>&path, const char* message, int start);

};
