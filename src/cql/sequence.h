/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
#include <set>

using SeqStack = vector<SeqConstituent*>;
class SequenceBase : public MFilter, public Countable, public VariationFlags, public CommentFlags{ //abstract
 public:
  bool match_position(Game*game) override;
  bool isSkip()const;
  colorT getSkipColor()const;
  bool skipColor(colorT)const;
  bool skipCurrentPosition()const;
  void clearSkipColor();
  void setSkipColor(colorT);
  void initializeSkip();
  void exitMatch();
  
  
  SeqRet computeSkip(SeqStack&stack);
  HolderConstituent* getSkipConstituent()const;
  virtual SeqRet compute (SeqStack&);
  virtual SeqRet compute(VectorConstituent*,SeqStack&);
  virtual SeqRet compute(StarConstituent*,SeqStack&);
  virtual SeqRet compute(RepeatConstituent*,SeqStack&);
  virtual SeqRet compute(HolderConstituent*,SeqStack&)=0;
  virtual SeqRet compute(PlusConstituent*,SeqStack&);
  virtual SeqRet compute(OptionalConstituent*,SeqStack&);
  virtual SeqRet computeNull(SeqStack&);
  virtual void notate(SeqRet& ret)=0;
  bool match_count(Game*game,NumValue*value) override;
  vector<SeqConstituent*> constituents;
  void print() override;
  Range*range{nullptr};
  int count{-1};
  void deepify() override;
  SequenceBase(vector<SeqConstituent*> scs,Range*r, bool isskip,bool allownests);
  vnode children() override;
  int nconstituents()const;
  bool valid_constituent (int offset)const;
  Game*game{nullptr};
  SeqConstituent* getConstituent (int offset)const;
  void setOffsets();
 private:
  HolderConstituent* theWhiteHolder{nullptr};
  HolderConstituent* theBlackHolder{nullptr};
  colorT theSkipColor{NOCOLOR};

  //nest members
 public:
  static std::set<SequenceBase*>* nestGetSequenceFilters();
  static void nestsClear(); // clear all positions that have been seen by all filters, called to start a game
  bool nestBan{false}; //whether this bans nesting
  void nestRegisterPosition(Game*game); //register current position as having matched
  bool nestSeenPosition(Game*game) const; // query if this filter has seen current position
  void nestClearPositions(); //clear all positions that have been seen by this
  std::set<moveT*> nestIds; // the positions that have been matched by part of the current filter
};

class PastNode : public SequenceBase{
 public:
  SeqRet compute(HolderConstituent*,SeqStack&) override;
  CVV(PastNode);
  void notate(SeqRet& ret) override;
  PastNode(vector<SeqConstituent*>,Range*,bool isskip, bool nestban);
};

class FutureNode : public SequenceBase{
 public:
  SeqRet computeLinearize(HolderConstituent*,SeqStack&);
  SeqRet compute(HolderConstituent*,SeqStack&) override;
  CVV(FutureNode);
  void notate(SeqRet& ret) override;
  FutureNode(vector<SeqConstituent*>,Range*,bool isskip, bool nestban);
  vector<MoveFutureNode*>linearize(Node* node);
};

