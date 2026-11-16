#include "node.h"
bool filename_is_pgn(const char*filename){
  const char*ext=filename_extension(filename);
  if(!ext)return false;
  return !strcmp(ext,".pgn")||!strcmp(ext,".PGN");
}

bool filename_is_cql(const char* filename){
  const char*ext=filename_extension(filename);
  if(!ext)return false;
  return !strcmp(ext,".cql")||!strcmp(ext,".CQL");
}
  
const char* filename_extension(const char* filename){
  uassert(filename,"bad filename to filename_extension");
  const char* last=strrchr(filename,'.');
  return last;
}

const char* filename_stem(const char*name){
  const char* noprefix=filename_trim_path_prefix(name);
  const char* noext=filename_trim_extension(noprefix);
  return noext;
}

const char* filename_trim_path_prefix(const char*name){
  uassert(name);
  const char* ret=name;
  ret=filename_trim_last(ret,'\\');
  ret=filename_trim_last(ret,':');
  ret=filename_trim_last(ret,'/');
  uassert(ret&&strlen(ret)>0,"unable to obtain filename from string",name);
  return ret;
}

const char* filename_trim_last(const char* name, char c){
  uassert(name,"null trim last arg");
  const char * ret=strrchr(name,c);
  if(ret) return ret+1;
  return name;
}

const char* filename_trim_extension(const char* name){
  uassert(name,"bad arg to trim_ext");
  const char* ext=filename_extension(name);
  if(!ext)return name;
  char buffer[200];
  uassert(strlen(name)<sizeof(buffer)-5,"too long name trim");
  sprintf(buffer,"%s",name);
  char* last=strrchr(buffer,'.');
  uassert(last,"internal trimext");
  *last=0;
  uassert(!filename_extension(buffer),"multiple . in filename not supported for name: ",name);
  return util::copy(buffer);
}

  
