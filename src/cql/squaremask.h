#pragma once
typedef unsigned long long Mask;
class SquareMask{
 public:
  Mask mask{0};
  SquareMask(Mask m){mask=m;}
  SquareMask(int i); // must not be linked to
  SquareMask(unsigned int i); // must not be linked to
  static SquareMask fromSquare(squareT square){return SquareMask((Mask)1<<square);}
  SquareMask(const vector<squareT>&);
  SquareMask(){}
  void print();
  void boardprint();
  static void boardprint(Mask m);
  const char* thisclass(){return "SquareMask";}
  void printnl();
  int size();
  void clear(){mask=0;}
  bool empty(){return mask==0;}
  static SquareMask all();
  bool nonempty(){return !empty();}
  bool full() {return (~mask)==0;}
  bool member(int s){return (mask>>s)%2;}
  void insert(int s){mask|=((Mask)1<<s);}
  int rankCount(int rank);
  vector<squareT> getSquares();
  void operator|= (SquareMask o){mask|=o.mask;}
  SquareMask operator|(SquareMask o){return SquareMask(mask|o.mask);}
  void operator&= (SquareMask o){mask&=o.mask;}
  SquareMask operator&(SquareMask o){return SquareMask(mask&o.mask);}
  SquareMask operator~(){return SquareMask(~mask);}
};
  
