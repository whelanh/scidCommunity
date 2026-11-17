/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"

SortValue::SortValue(NumValue v, bool ismax) : theIsMax(ismax), theValue(v) {}

void SortValue::print() const {
  printf("<%s value: %d ismax: %d>", thisclass(), getValue(), isMax());
}

bool operator<(const SortValue& a, const SortValue& b) {
  uassert((a.isMax() && b.isMax()) || (a.isMin() && b.isMin()),
          "< sortvalue internal");
  if (a.isMax())
    return a.getValue() < b.getValue();
  return a.getValue() > b.getValue();
}
