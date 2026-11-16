#pragma once
class EchoSpec:public Node{ //abstract
 public:
  bool insearch{false};
  moveT* sourceIdentity{NULL};
  Game*theGame{NULL};
  virtual bool match_target()=0;
  virtual void start_new_search(Game*game);
  virtual void end_search();
  virtual EchoSpec* clone()=0;
  virtual bool match_target(Transform*); //returns error by default
};
class EchoSquareSpec:public EchoSpec{
 public:
  EchoSquareSpec(SetBase*source,SetBase*target,Range*match,Range*mismatch);
  void start_new_search(Game*game);
  bool compareSourceTarget(squareT square);
  bool compareSourceTargetTransformed(squareT square, squareT transformedsquare);
  SquareMask sourcemask;
  pieceT sourceboard[64];
  SetBase*sourceset{NULL};
  SetBase*targetset{NULL};
  Range*mismatchrange{NULL};
  Range*matchrange{NULL};
  CVV(EchoSquareSpec);
  vnode children(){return vnode{sourceset,targetset};}
  void deepify(){sourceset=sourceset->clone();targetset=targetset->clone();}
  void print();
  bool match_target();
  bool match_target(Transform*);
};
class EchoLcaSpec:public EchoSpec{//abstract
 public:
  void computeLca(moveT*sourceid,
		  moveT*targetid,
		  vector<moveT*>&sourcemoves,
		  vector<moveT*>&targetmoves);
  vector<moveT*> backsequence(moveT*id);
  void start_new_search(Game*g);
  static void print(moveT*);
  vnode children(){return vnode{};}
  virtual bool match_target();
  moveT* theLca{NULL};
  NumericVariable*assignee{NULL};
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
  bool match_lca(const vector<moveT*>&sourcepath, const vector<moveT*>&targetpath);
  Range* range{NULL};
  void print();
  vnode children(){return vnode{};}
};

class EchoMaxDistanceSpec:public EchoDistanceSpec{
 public:
 EchoMaxDistanceSpec(Range*r,NumericVariable*v) : EchoDistanceSpec(r,v){}
  CVV(EchoMaxDistanceSpec);
  void computeCount(int sd, int td);
};
class EchoSumDistanceSpec:public EchoDistanceSpec{
 public:
 EchoSumDistanceSpec(Range*r,NumericVariable*v) : EchoDistanceSpec(r,v){}
  CVV(EchoSumDistanceSpec);
  void computeCount(int sd, int td);
};
class EchoSourceDistanceSpec:public EchoDistanceSpec{
 public:
 EchoSourceDistanceSpec(Range*r,NumericVariable*v) : EchoDistanceSpec(r,v){}
  CVV(EchoSourceDistanceSpec);
  void computeCount(int sd, int td);
};
class EchoTargetDistanceSpec:public EchoDistanceSpec{
 public:
 EchoTargetDistanceSpec(Range*r,NumericVariable*v) : EchoDistanceSpec(r,v){}
  CVV(EchoTargetDistanceSpec);
  void computeCount(int sd, int td);
};
  
class EchoLongestSubstringSpec:public EchoLcaSpec{
 public:
  Range*range{NULL};
  bool seenmatch{false};
  vector<moveT*>matchedSourcePath;
  vector<moveT*>matchedTargetPath;
  int matchedSourceStart{-1};
  int matchedTargetStart{-1};
  EchoLongestSubstringSpec(Range*r,NumericVariable*v);
  bool match_lca(const vector<moveT*>&sourcepath,const vector<moveT*>&targetpath);
  void print();
  vnode children(){return vnode{};}
  CVV(EchoLongestSubstringSpec);

 private:
  static void getprev(moveT*posid,pieceT*piece,squareT*from,squareT*to);
  static int id_to_int(moveT*posid);
  static vector<int>path_to_ints(const vector<moveT*>&path);
};

class EchoTransformSpec:public EchoSpec{
 public:
  EchoTransformSpec(vector<Transform*>,EchoSpec*);
  vector<Transform*> transforms;
  EchoSpec* spec{NULL};
  Transform* matchedTransform{NULL};
  vnode children(){return vnode{spec};}
  void print();
  bool match_target();
  CVV(EchoTransformSpec);
  void deepify(){spec=spec->clone();}
  void start_new_search(Game*);
  void end_search();
};

class EchoSideToMoveSpec:public EchoSpec{
 public: EchoSideToMoveSpec(bool sameside);
  bool same{false};
  colorT sourceToMove{NOCOLOR};
  vnode children(){return vnode{};}
  void print();
  bool match_target();
  void start_new_search(Game*game);
  void end_search();
  CVV(EchoSideToMoveSpec);
};
