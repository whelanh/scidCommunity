/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include <bit>

#include "util.h"

void SquareMask::print() const{
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

void SquareMask::boardprint() const{
  for (int rank=7; rank>=0; rank--) {
    printf("%c: ",rank_to_char_cql(rank));
    for (int file=0; file<=7; file++) {
      const squareT s = square_make(file,rank);
      const char c=member(s)?'1': rank%2==file%2 ? '+' : '-';
      printf("%c",c);
    }
    printf ("\n");
  }
  printf("   abcdefgh\n");
}

void SquareMask::boardprint(Mask m){
  SquareMask(m).boardprint();
}

void SquareMask::printnl() const{
  print();
  printf("\n");
}

int SquareMask::size() const{
  return std::popcount(mask);
}

vector<squareT> SquareMask::getSquares() const{
  vector<squareT> v;
  for(int i=0;i<64;++i)
    if(member(i)) v.push_back(static_cast<squareT>(i));
  return v;
}

SquareMask::SquareMask(const vector<squareT>&squares){
  for(auto sq:squares)
    mask |= (static_cast<Mask>(1)<<sq);
}

int SquareMask::rankCount(int rank) const{
  uassert(rank_valid(rank));
  int count=0;
  for(int file=0;file<8;++file){
    const squareT square=square_make(file,rank);
    if (member(square))++count;
  }
  return count;
}

SquareMask SquareMask::all(){
  return {~static_cast<Mask>(0)};
}
