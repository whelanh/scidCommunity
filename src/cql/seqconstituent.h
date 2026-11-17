/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
class SeqConstituent : public Node{
 public:
  void print() override=0;
  SeqConstituent* clone() override=0;
  virtual bool matchesNull()=0;
  int getOffset(){return theOffset;}
  void setOffset(int);
  virtual void setOffsets(int)=0;
 private:
  int theOffset{-1};
};

class RepeatConstituent : public SeqConstituent{
 public:
  SeqConstituent* constituent{nullptr};
  RepeatConstituent(SeqConstituent*,int, int);
  CVV(RepeatConstituent);
  int min= -1;
  int max= -1;
  bool matchesNull() override;
  void print() override;
  vnode children() override{return vnode{constituent};}
  void deepify() override{constituent=constituent->clone();}
  void setOffsets(int i) override;
};

class StarConstituent : public SeqConstituent{
 public:
  SeqConstituent*constituent{nullptr};
  //  StarConstituent(vector<SeqConstituent*>);
  StarConstituent(SeqConstituent*);
  CVV(StarConstituent);
  bool matchesNull() override{return true;}
  void print() override;
  vnode children() override{return vnode{constituent};}
  void deepify() override{constituent=constituent->clone();}
  void setOffsets(int i) override;
};

class HolderConstituent : public SeqConstituent{
 public:
  HolderConstituent(MFilter*);
  MFilter*filter{nullptr};
  CVV(HolderConstituent);
  void print() override;
  vnode children() override{return vnode{filter};}
  void deepify() override{filter=filter->clone();}
  bool matchesNull() override;
  void setOffsets(int i) override;
};

class VectorConstituent : public SeqConstituent{
 public:
  vector<SeqConstituent*>constituents;
  VectorConstituent(vector<SeqConstituent*>& cs);
  void print() override;
  CVV(VectorConstituent);
  vnode children() override;
  void deepify() override{clonevec(constituents);}
  bool matchesNull() override;
  void setOffsets(int) override;
};

class PlusConstituent : public SeqConstituent{
 public:
  StarConstituent* getStarConstituent(){return theStarConstituent;}
  SeqConstituent* getConstituent();
  PlusConstituent(SeqConstituent*c);
  CVV(PlusConstituent);
  vnode children() override{return vnode{theStarConstituent};}
  void deepify() override{theStarConstituent=theStarConstituent->clone();}
  bool matchesNull() override;
  void print() override;
  void setOffsets(int) override;
 private:
  StarConstituent* theStarConstituent{nullptr};
};

class OptionalConstituent : public SeqConstituent{
 public:
  OptionalConstituent(SeqConstituent*);
  SeqConstituent*constituent{nullptr};
  CVV(OptionalConstituent);
  void print() override;
  vnode children() override{return vnode{constituent};}
  void deepify() override{constituent=constituent->clone();}
  bool matchesNull() override;
  void setOffsets(int) override;
};

/* class SkipConstituent : public MFilter{ */
/*  public: */
/*   bool match_position(Game*game); */
/*   void setColor(color_t); */
/*   color_t getColor(color_t); */
/*   bool isValid(); */
/*   void clear(); */
/*   CVV(SkipConstituent); */
/*   SkipConstituent(); */
/*   vnode children(){return vnode{};} */
/*   bool matchesNull(); */
/*   void print(); */
/*  private: */
/*   color_t theColor{NOCOLOR}; */
/* }; */

