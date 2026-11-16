#pragma once
#include "deleteable.h"
class Transform {
 public:
  virtual squareT transform(squareT s)=0;
  static vector<Transform*>nonidentity(const vector<Transform*>&);
  virtual void print();
  virtual Direction transform(Direction)=0;
  virtual SquareMask transform(SquareMask)=0;
  virtual const char * thisclass()=0;
  virtual Node* transform(Node* n);
  virtual colorT transformColor(colorT color);
  virtual pieceT transformPiece(pieceT piece);
  DirectionParameter transform(DirectionParameter);
  virtual bool flipsColor(){return false;}
  Transform* transform(Transform*);
  Transform* compose(Transform*);
};

class PiOver4Transform:public Transform{
 public:
  const char* thisclass(){return "PiOver4Transform";}
  int times{-1};
  squareT transform(squareT);
  Direction transform(Direction);
  PiOver4Transform(int t);
  Direction rotate45(Direction);
  static vector<Transform*>rotations();
  SquareMask transform(SquareMask m);
  void print();
};

class DihedralTransform : public Transform{
 public:
  const char* thisclass(){return "DihedralTransform";}
  bool reflectx{false};
  bool reflecty{false};
  bool swap{false};
  squareT transform(squareT);
  Direction transform(Direction);
  DihedralTransform(bool rx, bool ry, bool swap);
  static DihedralTransform* flipVertical();
  static DihedralTransform* flipHorizontal();
  static vector<Transform*> rotations();
  SquareMask transform(SquareMask m);
  void print();
  static vector<Transform*> allDihedral();
  //  DihedralTransform* reflect(Direction);
};

class ShiftTransform : public Transform{
 public:
  const char* thisclass(){return "ShiftTransform";}
  int xoffset{0};
  int yoffset{0};
  squareT transform(squareT);
  Direction transform(Direction d){return d;}
  ShiftTransform(int xoff, int yoff);
  virtual void print();
  SquareMask transform(SquareMask);
  static vector<Transform*>allShift();
  static vector<Transform*>shiftHorizontal();
  static vector<Transform*>shiftVertical();
};

class ColorTransform : public Transform{
 public:
  squareT transform(squareT s){return s;}
  Direction transform(Direction d) {return d;}
  SquareMask transform(SquareMask m){return m;}
  const char* thisclass(){return "ColorTransform";}
  bool flipsColor(){return true;}
  static Transform* flipColorTransform();
};
  
class IdentityTransform : public Transform{
 public:
  squareT transform(squareT s){return s;}
  Direction transform(Direction d){return d;}
  SquareMask transform(SquareMask m){return m;}
  const char* thisclass(){return "IdentityTransform";}
};

class ComposeTransform: public Transform{
 public:
  vector<Transform*> transforms;
  squareT transform(squareT);
  Direction transform(Direction);
  void print();
  ComposeTransform(vector<Transform*>);
  ComposeTransform(Transform* t, Transform*s);
  static vector<Transform*> composeVectors(vector<Transform*>, vector<Transform*>);
  const char* thisclass(){return "ComposeTransform";}
  SquareMask transform(SquareMask);
  bool flipsColor();
};



  
