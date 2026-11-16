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
char *cqlErrMsg;
std::jmp_buf jump_buffer;
void cql_exit(const char* message){
  cqlErrMsg = (char *)message;
  std::longjmp(jump_buffer, 1);
}
#endif

