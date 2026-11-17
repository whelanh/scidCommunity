/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
#include "deleteable.h"
class Range: public Deleteable{
 public:
  int min;
  int max;
  const char* thisclass(){return "Range";}
  void print();
  Range(int m);
  Range(int mi,int ma);
  bool valid(int i){return min<=i&&i<=max;}

};

