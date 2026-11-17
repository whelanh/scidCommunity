/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include <string>
using std::string;
#include "cqlassert.h"
#include "cqlexit.h"

void uassert(void* v){
  uassert(v!=nullptr);
}

void uassert(void* v,const char*s){
  uassert(v!=nullptr,s);
}

void uassert(void *v,const char*s, const char*s2){
  uassert(v!=nullptr,s,s2);
}


void uassert(bool b){
  if(!b)
    cql_exit("assertion failure");
}

void uassert(bool b,const char*s){
  if (!b)
    uassert(b,s,"");
}

void uassert(bool b,const char*s1, const char*s2){
  if (!b){
    if(!s1)s1="missing uassert argument1";
    if(!s2)s2="missing uassert argument2";
    // One buffer for the process, refilled per assertion. The adapter copies
    // the message where the longjmp() lands (cql_pgnparse_adapter.cpp's
    // engineError(), inside its setjmp() handler) and nothing reads cqlErrMsg
    // after that copy, so the text only has to outlive the jump itself. It used
    // to be a new string per call, which leaked one message per rejected query.
    static thread_local string ret;
    ret.assign("CQL error: ");
    ret += s1;
    ret += s2;
    cql_exit(ret.c_str());
  }
}

