#include <string>
using std::string;
#include "cqlassert.h"
#include "cqlexit.h"

void uassert(void* v){
  uassert(v!=NULL);
}

void uassert(void* v,const char*s){
  uassert(v!=NULL,s);
}

void uassert(void *v,const char*s, const char*s2){
  uassert(v!=NULL,s,s2);
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
    string *ret=new string("CQL error: ");
    if(!ret) cql_exit("Fatal memory");
    *ret+=s1;
    *ret+=s2;
    cql_exit(ret->data());
  }
}

