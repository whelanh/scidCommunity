/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
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
  const char* thisclass() override{return "PiOver4Transform";}
  int times{-1};
  squareT transform(squareT) override;
  Direction transform(Direction) override;
  PiOver4Transform(int t);
  Direction rotate45(Direction);
  static vector<Transform*>rotations();
  SquareMask transform(SquareMask m) override;
  void print() override;
};

class DihedralTransform : public Transform{
 public:
  const char* thisclass() override{return "DihedralTransform";}
  bool reflectx{false};
  bool reflecty{false};
  bool swap{false};
  squareT transform(squareT) override;
  Direction transform(Direction) override;
  DihedralTransform(bool rx, bool ry, bool swap);
  static DihedralTransform* flipVertical();
  static DihedralTransform* flipHorizontal();
  static vector<Transform*> rotations();
  SquareMask transform(SquareMask m) override;
  void print() override;
  static vector<Transform*> allDihedral();
  //  DihedralTransform* reflect(Direction);
};

class ShiftTransform : public Transform{
 public:
  const char* thisclass() override{return "ShiftTransform";}
  int xoffset{0};
  int yoffset{0};
  squareT transform(squareT) override;
  Direction transform(Direction d) override{return d;}
  ShiftTransform(int xoff, int yoff);
  void print() override;
  SquareMask transform(SquareMask) override;
  static vector<Transform*>allShift();
  static vector<Transform*>shiftHorizontal();
  static vector<Transform*>shiftVertical();
};

class ColorTransform : public Transform{
 public:
  squareT transform(squareT s) override{return s;}
  Direction transform(Direction d) override {return d;}
  SquareMask transform(SquareMask m) override{return m;}
  const char* thisclass() override{return "ColorTransform";}
  bool flipsColor() override{return true;}
  static Transform* flipColorTransform();
};
  
class IdentityTransform : public Transform{
 public:
  squareT transform(squareT s) override{return s;}
  Direction transform(Direction d) override{return d;}
  SquareMask transform(SquareMask m) override{return m;}
  const char* thisclass() override{return "IdentityTransform";}
};

class ComposeTransform: public Transform{
 public:
  vector<Transform*> transforms;
  squareT transform(squareT) override;
  Direction transform(Direction) override;
  void print() override;
  ComposeTransform(vector<Transform*>);
  ComposeTransform(Transform* t, Transform*s);
  static vector<Transform*> composeVectors(vector<Transform*>, vector<Transform*>);
  const char* thisclass() override{return "ComposeTransform";}
  SquareMask transform(SquareMask) override;
  bool flipsColor() override;
};



  
