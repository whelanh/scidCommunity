/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
void MatchCountNode::print(){
  printf("<%s ",thisclass());
  if(sort) printf("sort ");
  range->print();
  printf(">");
}

MatchCountNode::MatchCountNode(Range*r,bool s) : range{r},sort{s} {
  uassert(range);
  uassert(range->min>=0);
}

