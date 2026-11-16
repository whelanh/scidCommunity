/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
StarConstituent::StarConstituent(SeqConstituent*c){
  uassert(c,"nullscsc");
  constituent=c;
}

void StarConstituent::print(){
  printf("<%s ",thisclass());
  constituent->print();
  printf(">");
}

void StarConstituent::setOffsets(int i){
  setOffset(i);
  constituent->setOffsets(i);
}


