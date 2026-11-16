/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"

void SeqConstituent::setOffset(int off){
  uassert(off>=0&&theOffset<0,"offset setoffset internal");
  theOffset=off;
}

