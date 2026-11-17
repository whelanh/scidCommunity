/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
class EchoSpec:public Node{ //abstract
 public:
  bool insearch{false};
  moveT* sourceIdentity{nullptr};
  Game*theGame{nullptr};
  virtual bool match_target()=0;
  virtual void start_new_search(Game*game);
  virtual void end_search();
  EchoSpec* clone() override=0;
  virtual bool match_target(Transform*); //returns error by default
};
class EchoSquareSpec:public EchoSpec{
 public:
  EchoSquareSpec(SetBase*source,SetBase*target,Range*match,Range*mismatch);
  void start_new_search(Game*game) override;
  bool compareSourceTarget(squareT square);
  bool compareSourceTargetTransformed(squareT square, squareT transformedsquare);
  SquareMask sourcemask;
  pieceT sourceboard[64];
  SetBase*sourceset{nullptr};
  SetBase*targetset{nullptr};
  Range*mismatchrange{nullptr};
  Range*matchrange{nullptr};
  CVV(EchoSquareSpec);
  vnode children() override{return vnode{sourceset,targetset};}
  void deepify() override{sourceset=sourceset->clone();targetset=targetset->clone();}
  void print() override;
  bool match_target() override;
  bool match_target(Transform*) override;
};
class EchoLcaSpec:public EchoSpec{//abstract
 public:
  void computeLca(moveT*sourceid,
		  moveT*targetid,
		  vector<moveT*>&sourcemoves,
		  vector<moveT*>&targetmoves);
  vector<moveT*> backsequence(moveT*id);
  void start_new_search(Game*g) override;
  vnode children() override{return vnode{};}
  bool match_target() override;
  moveT* theLca{nullptr};
  NumericVariable*assignee{nullptr};
  virtual bool match_lca(const vector<moveT*>&sourcepath, const vector<moveT*>&targetpath)=0;
  virtual int getCount();
  virtual void clearCount();
  virtual void setCount(int j);
 private:
  int theCount=-1;
};

class EchoDistanceSpec:public EchoLcaSpec{//abstract
 public:
  EchoDistanceSpec(Range*r,NumericVariable*v);
  bool match_distance(int sourcedistance, int targetdistance);
  virtual void computeCount(int sourcedistance, int targetdistance)=0;
  bool match_lca(const vector<moveT*>&sourcepath, const vector<moveT*>&targetpath) override;
  Range* range{nullptr};
  void print() override;
  vnode children() override{return vnode{};}
};

class EchoMaxDistanceSpec:public EchoDistanceSpec{
 public:
 EchoMaxDistanceSpec(Range*r,NumericVariable*v) : EchoDistanceSpec(r,v){}
  CVV(EchoMaxDistanceSpec);
  void computeCount(int sd, int td) override;
};
class EchoSumDistanceSpec:public EchoDistanceSpec{
 public:
 EchoSumDistanceSpec(Range*r,NumericVariable*v) : EchoDistanceSpec(r,v){}
  CVV(EchoSumDistanceSpec);
  void computeCount(int sd, int td) override;
};
class EchoSourceDistanceSpec:public EchoDistanceSpec{
 public:
 EchoSourceDistanceSpec(Range*r,NumericVariable*v) : EchoDistanceSpec(r,v){}
  CVV(EchoSourceDistanceSpec);
  void computeCount(int sd, int td) override;
};
class EchoTargetDistanceSpec:public EchoDistanceSpec{
 public:
 EchoTargetDistanceSpec(Range*r,NumericVariable*v) : EchoDistanceSpec(r,v){}
  CVV(EchoTargetDistanceSpec);
  void computeCount(int sd, int td) override;
};
  
class EchoLongestSubstringSpec:public EchoLcaSpec{
 public:
  Range*range{nullptr};
  bool seenmatch{false};
  vector<moveT*>matchedSourcePath;
  vector<moveT*>matchedTargetPath;
  int matchedSourceStart{-1};
  int matchedTargetStart{-1};
  EchoLongestSubstringSpec(Range*r,NumericVariable*v);
  bool match_lca(const vector<moveT*>&sourcepath,const vector<moveT*>&targetpath) override;
  void print() override;
  vnode children() override{return vnode{};}
  CVV(EchoLongestSubstringSpec);

 private:
  static void getprev(moveT*posid,pieceT*piece,squareT*from,squareT*to,
                      pieceT*promote);
  static int id_to_int(moveT*posid);
  static vector<int>path_to_ints(const vector<moveT*>&path);
};

class EchoTransformSpec:public EchoSpec{
 public:
  EchoTransformSpec(vector<Transform*>,EchoSpec*);
  vector<Transform*> transforms;
  EchoSpec* spec{nullptr};
  Transform* matchedTransform{nullptr};
  vnode children() override{return vnode{spec};}
  void print() override;
  bool match_target() override;
  CVV(EchoTransformSpec);
  void deepify() override{spec=spec->clone();}
  void start_new_search(Game*) override;
  void end_search() override;
};

class EchoSideToMoveSpec:public EchoSpec{
 public: EchoSideToMoveSpec(bool sameside);
  bool same{false};
  colorT sourceToMove{NOCOLOR};
  vnode children() override{return vnode{};}
  void print() override;
  bool match_target() override;
  void start_new_search(Game*game) override;
  void end_search() override;
  CVV(EchoSideToMoveSpec);
};
