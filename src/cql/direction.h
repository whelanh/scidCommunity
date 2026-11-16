#pragma once
class Range;
class Direction{
 public:
   int xoffset;
   int yoffset;
  Direction(int xoff,int yoff);
  char* toString();
  static vector<Direction> directionsFromString(const char*s);
  void print();
  squareT apply(squareT square);
  squareT apply(squareT square, int ntimes);
  bool reachable(squareT source, squareT target);
  static SquareMask between(squareT source, squareT target);
  static Direction fromString(const char* name);
  bool eq(const Direction& other);
  Direction reverse();
  static vector<Direction> allDirections();
  bool isDiagonal();
  bool isOffdiagonal();
  bool isOrthogonal();
  static bool validOffset(int xoffset, int yoffset);
  static bool validOffset(int offset);
  bool isCompatible(pieceT piece);
};
  
class DirectionParameter {
 public: vector<Direction> directions;
  Range*range {NULL};
  const char* thisclass(){return "DirectionParameter";}
  void print();
  SquareMask neighborhood(squareT square);
  SquareMask neighborhood(SquareMask mask);
  DirectionParameter(vector<Direction> v, Range*r);
};
  
