/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include <stdio.h>
#include <stdlib.h>
#include "cqlexit.h"

#ifndef INTEGRATED  
void cql_exit(const char* message){
  if(!message)message="BAD CQL_EXIT ARGUMENT";
  printf("\n%s\n",message);
  exit(1);
}
#endif

#ifdef INTEGRATED
#include <iostream>
#include <csetjmp>
// Per thread, like everything else the engine keeps per query: cql_exit()
// longjmp()s to the buffer the *calling* thread set, so a worker's error must
// not jump into (or be reported through) another thread's frame.
thread_local const char* cqlErrMsg;
thread_local std::jmp_buf jump_buffer;
void cql_exit(const char* message){
  cqlErrMsg = message;
  std::longjmp(jump_buffer, 1);
}
#endif

