/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
HolderConstituent::HolderConstituent(MFilter*f){
  uassert(f,"hc");
  filter=f;
}

void HolderConstituent::print(){
  printf("<%s ",thisclass());
  filter->print();
  printf(">");
}


void HolderConstituent::setOffsets(int i){
  setOffset(i);
}

bool HolderConstituent::matchesNull(){
  return false;
}
