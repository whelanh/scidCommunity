/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
#include "node.h"

class EchoNode : public MFilter,public VariationFlags,public CommentFlags{
 public:
  vector<MFilter*>filters;
  vector<EchoSpec*> specs;
  EchoNode(vector<Node*> filters, vector<EchoSpec*> specs);
  bool match_position(Game*game);
  void print();
  CVV(EchoNode);
  vnode children();
  moveT* sourceIdentity{nullptr};
  void deepify(){clonevec(filters);clonevec(specs);}
  vector<EchoMatchInfo> matchinfos;
  void registerMatch();
  bool matched{false};
  int nfound{0};
  Game*theGame{nullptr};
  void annotate(Game*game);
 private:
  bool insearch{false};
  void initialize();
  bool match_target();
  void start_new_search(Game*g);
  void match_target_children();
  void end_search();
  void assignVariables();
};

