/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
#include <cstdint>

using Mask = std::uint64_t;

class SquareMask{
 public:
  Mask mask{0};
  SquareMask(Mask m) : mask(m) {}
  SquareMask(int) = delete; // must not be linked to
  SquareMask(unsigned int) = delete; // must not be linked to
  static SquareMask fromSquare(squareT square){
    return {static_cast<Mask>(1) << square};
  }
  SquareMask(const vector<squareT>&);
  SquareMask() = default;
  void print() const;
  void boardprint() const;
  static void boardprint(Mask m);
  const char* thisclass(){return "SquareMask";}
  void printnl() const;
  int size() const;
  void clear(){mask=0;}
  bool empty() const{return mask==0;}
  static SquareMask all();
  bool nonempty() const{return !empty();}
  bool full() const{return (~mask)==0;}
  bool member(int s) const{return ((mask>>s)&1)!=0;}
  void insert(int s){mask|=(static_cast<Mask>(1)<<s);}
  int rankCount(int rank) const;
  vector<squareT> getSquares() const;
  void operator|=(const SquareMask& o){mask|=o.mask;}
  SquareMask operator|(const SquareMask& o) const{return {mask|o.mask};}
  void operator&=(const SquareMask& o){mask&=o.mask;}
  SquareMask operator&(const SquareMask& o) const{return {mask&o.mask};}
  SquareMask operator~() const{return {~mask};}
};
