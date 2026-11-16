#include "util.h"
void SquareMask::print(){
  if(full())
    printf("<all>");
  else if(empty())
      printf("<none>");
  else{
      printf("[");
      for(squareT s : getSquares())
	square_print(s);
      printf("]");
  }
}

void SquareMask::boardprint(){
  squareT s;
  for (int rank=7; rank>=0; rank--) {
    printf("%c: ",rank_to_char_cql(rank));
    for (int file=0; file<=7; file++) {
      s = square_make(file,rank);
      char c=member(s)?'1': rank%2==file%2 ? '+' : '-';
      printf("%c",c);
    }
    printf ("\n");
  }
  printf("   abcdefgh\n");
}

void SquareMask::boardprint(Mask m){
  SquareMask(m).boardprint();
}

void SquareMask::printnl(){
  print();
  printf("\n");
}

void mask_print(Mask m){
  SquareMask(m).printnl();
}

int SquareMask::size(){
  int s=0;
  Mask tmp=mask;
  while(tmp){
    s+=tmp%2;
    tmp=tmp>>1;
  }
  return s;
}


vector<squareT> SquareMask::getSquares(){
  vector<squareT> v;
  for(int i=0;i<64;++i)
    if(member(i)) v.push_back(i);
  return v;
}

SquareMask::SquareMask(const vector<squareT>&squares){
  mask=0;
  for(auto sq:squares)
    mask |= ((Mask)1<<sq);
}

int SquareMask::rankCount(int rank){
  uassert(rank_valid(rank));
  int count=0;
  for(int file=0;file<8;++file){
    squareT square=square_make(file,rank);
    if (member(square))++count;
  }
  return count;
}

SquareMask SquareMask::all(){
  Mask tmp=0;
  tmp= ~tmp;
  return SquareMask(tmp);
}
  
    
