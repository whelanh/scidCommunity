#pragma once
class SeqConstituent : public Node{
 public:
  virtual void print()=0;
  virtual SeqConstituent* clone()=0;
  virtual bool matchesNull()=0;
  int getOffset(){return theOffset;}
  void setOffset(int);
  virtual void setOffsets(int)=0;
 private:
  int theOffset{-1};
};

class RepeatConstituent : public SeqConstituent{
 public:
  SeqConstituent* constituent{NULL};
  RepeatConstituent(SeqConstituent*,int, int);
  CVV(RepeatConstituent);
  int min= -1;
  int max= -1;
  bool matchesNull();
  void print();
  vnode children(){return vnode{constituent};}
  void deepify(){constituent=constituent->clone();}
  void setOffsets(int i);
};

class StarConstituent : public SeqConstituent{
 public:
  SeqConstituent*constituent{NULL};
  //  StarConstituent(vector<SeqConstituent*>);
  StarConstituent(SeqConstituent*);
  CVV(StarConstituent);
  bool matchesNull(){return true;}
  void print();
  vnode children(){return vnode{constituent};}
  void deepify(){constituent=constituent->clone();}
  void setOffsets(int i);
};

class HolderConstituent : public SeqConstituent{
 public:
  HolderConstituent(MFilter*);
  MFilter*filter{NULL};
  CVV(HolderConstituent);
  void print();
  vnode children(){return vnode{filter};}
  void deepify(){filter=filter->clone();}
  bool matchesNull();
  void setOffsets(int i);
};

class VectorConstituent : public SeqConstituent{
 public:
  vector<SeqConstituent*>constituents;
  VectorConstituent(vector<SeqConstituent*>& cs);
  void print();
  CVV(VectorConstituent);
  vnode children();
  void deepify(){clonevec(constituents);}
  bool matchesNull();
  void setOffsets(int);
};

class PlusConstituent : public SeqConstituent{
 public:
  StarConstituent* getStarConstituent(){return theStarConstituent;}
  SeqConstituent* getConstituent();
  PlusConstituent(SeqConstituent*c);
  CVV(PlusConstituent);
  vnode children(){return vnode{theStarConstituent};}
  void deepify(){theStarConstituent=theStarConstituent->clone();}
  bool matchesNull();
  void print();
  void setOffsets(int);
 private:
  StarConstituent* theStarConstituent{NULL};
};

class OptionalConstituent : public SeqConstituent{
 public:
  OptionalConstituent(SeqConstituent*);
  SeqConstituent*constituent{NULL};
  CVV(OptionalConstituent);
  void print();
  vnode children(){return vnode{constituent};}
  void deepify(){constituent=constituent->clone();}
  bool matchesNull();
  void setOffsets(int);
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

