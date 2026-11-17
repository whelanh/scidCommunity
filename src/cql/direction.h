/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
class Range;
class Direction{
 public:
   int xoffset;
   int yoffset;
  Direction(int xoff,int yoff);
  static vector<Direction> directionsFromString(const char*s);
  void print() const;
  squareT apply(squareT square) const;
  squareT apply(squareT square, int ntimes) const;
  bool reachable(squareT source, squareT target) const;
  static SquareMask between(squareT source, squareT target);
  bool eq(const Direction& other) const;
  Direction reverse();
  static vector<Direction> allDirections();
  bool isDiagonal() const;
  bool isOrthogonal() const;
  static bool validOffset(int xoffset, int yoffset);
  static bool validOffset(int offset);
  bool isCompatible(pieceT piece) const;
};
  
class DirectionParameter {
 public: vector<Direction> directions;
  Range*range {nullptr};
  const char* thisclass(){return "DirectionParameter";}
  void print();
  SquareMask neighborhood(squareT square);
  SquareMask neighborhood(SquareMask mask);
  DirectionParameter(vector<Direction> v, Range*r);
};
  
