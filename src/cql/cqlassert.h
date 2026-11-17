/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once

void uassert(void*);
void uassert(void*,const char*s);
void uassert(void*,const char*s,const char*s1);
void uassert(bool b);
void uassert(bool b, const char*s, const char* s1);
void uassert(bool, const char*s);
