/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
#include "node.h"
class EchoMatchInfo{
 public:
  Game*game{nullptr};
  unsigned gamenumber{0};
  
  int targetnumber{0};
  moveT* source{nullptr};
  moveT* target{nullptr};
  moveT* lca{nullptr};
  bool uselca()const;
  vector<moveT*> substringsource;
  vector<moveT*> substringtarget;
  Transform*transform{nullptr};
  int substringlen()const;
  bool usesubstring()const;
  static void annotate (Game*game, const vector<EchoMatchInfo>& infos);
  EchoMatchInfo(EchoNode* node);
  void print();
  const char* thisclass(){return "EchoMatchInfo";}
  static void annotatePath(Game*game, const vector<moveT*>&path, const char* message, int start);

};
