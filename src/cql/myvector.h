/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
#include <algorithm>
#include <cstddef>
#include <vector>

template <class T> void myinsert(std::vector<T>& v, const T& t) {
  if (std::find(v.begin(), v.end(), t) != v.end()) return;
  v.push_back(t);
}

template <class T> int myindex(const std::vector<T>& v, const T& t) {
  for (std::size_t i = 0; i < v.size(); ++i)
    if (v[i] == t) return static_cast<int>(i);
  return -1;
}
