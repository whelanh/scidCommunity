/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once

#include "cqlexit.h"

// The plain bool form is defined here so that a check costs a test and a
// not-taken branch at the call site: the matcher asserts several times per
// visited position, and an out-of-line call for each was a measurable part of
// a search. The string-argument forms stay out-of-line: they only run on the
// path that is about to longjmp().
inline void uassert(bool b) {
  if (!b)
    cql_exit("assertion failure");
}

void uassert(void*);
void uassert(void*,const char*s);
void uassert(void*,const char*s,const char*s1);
void uassert(bool b, const char*s, const char* s1);
void uassert(bool, const char*s);
