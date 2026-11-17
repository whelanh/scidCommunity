/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
#include <vector>

#include "cqlassert.h"

template <class T> void clonevec(std::vector<T*>& v) {
  for (T*& element : v) {
    uassert(element, "Clonevec: unexpected null argument");
    element = element->clone();
  }
}
