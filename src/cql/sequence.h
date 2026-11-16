#pragma once

typedef vector<SeqConstituent*>SeqStack;
class SequenceBase : public MFilter, public Countable, public VariationFlags, public CommentFlags{ //abstract
 public:
  bool match_position(Game*game);
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
  bool match_count(Game*game,NumValue*value);
  vector<SeqConstituent*> constituents;
  void print();
  Range*range{NULL};
  int count{-1};
  void deepify();
  SequenceBase(vector<SeqConstituent*> scs,Range*r, bool isskip,bool allownests);
  vnode children();
  int nconstituents()const;
  bool valid_constituent (int offset)const;
  Game*game{NULL};
  SeqConstituent* getConstituent (int offset)const;
  void setOffsets();
 private:
  HolderConstituent* theWhiteHolder{NULL};
  HolderConstituent* theBlackHolder{NULL};
  colorT theSkipColor{NOCOLOR};

  //nest members
 public:
  static set<SequenceBase*>*nestGetSequenceFilters();
  static void nestsClear(); // clear all positions that have been seen by all filters, called to start a game
  bool nestBan{false}; //whether this bans nesting
  void nestRegisterPosition(Game*game); //register current position as having matched
  bool nestSeenPosition(Game*game); // query if this filter has seen current position
  void nestClearPositions(); //clear all positions that have been seen by this
  set<moveT*> nestIds; // the positions that have been matched by part of the current filter
};

class PastNode : public SequenceBase{
 public:
  SeqRet compute(HolderConstituent*,SeqStack&);
  CVV(PastNode);
  void notate(SeqRet& ret);
  PastNode(vector<SeqConstituent*>,Range*,bool isskip, bool nestban);
};

class FutureNode : public SequenceBase{
 public:
  SeqRet computeLinearize(HolderConstituent*,SeqStack&);
  SeqRet compute(HolderConstituent*,SeqStack&);
  CVV(FutureNode);
  void notate(SeqRet& ret);
  FutureNode(vector<SeqConstituent*>,Range*,bool isskip, bool nestban);
  vector<MoveFutureNode*>linearize(Node* node);
};

