#include "parser.h"
#include "lexer.h"
#include "cql.h"
#include "tokenstream.h"

#ifdef STANDALONE
CqlNode* parseFile(const char* filename){
  if(CqlDebug)printf("Parser: lexing file: %s\n",filename);
  vector<Token*> tokens;
  bool ret=lexFile(filename,&tokens);
  if(CqlShowLex)
    printf("Got return of: %d and ntokens: %lu\n",ret,tokens.size());
  Tokens * ts=new Tokens(tokens);
  CqlGlobalTokens=ts;
  if(CqlShowLex){
    printf("Printing the token stream for file: %s:\n",filename);
    ts->print();
  }
  Variable::createNumericVariable("matchcount",true);
  uassert(!CqlParseRoot,"parser: expecting a null CqlParseRoot");
  CqlNode* n=ts->match_cqlnode();
  CqlParseRoot=n;
  uassert(n!=NULL,"CQL: Unable to parse file: %s",filename);
  n->setChildVariations();
  n->setUseMarks();
  if(n->isSilent()) n->makeSilentRecursively();
  n->makeNotNodeSilentRecursively(); // Not sure why this is here
  n->expand();
  n->addSortFields(n->sortfields);
  return n;
}
#endif

#ifdef INTEGRATED
CqlNode* parseBuffer(char* buffer){
  static bool pbDoOnce = true;
  if(CqlDebug)printf("Parser: lexing buffer:\n");
  vector<Token*> tokens;
  bool ret=lexStream(NULL,buffer,&tokens);
  if(CqlShowLex)
    printf("Got return of: %d and ntokens: %lu\n",ret,tokens.size());
  Tokens * ts=new Tokens(tokens);
  CqlGlobalTokens=ts;
  if(CqlShowLex){
    printf("Printing the token stream:\n");
    ts->print();
  }
  if (pbDoOnce) {
    Variable::createNumericVariable("matchcount",true);
    pbDoOnce = false;
  }
  uassert(!CqlParseRoot,"parser: expecting a null CqlParseRoot");
  CqlNode* n=ts->match_cqlnode();
  CqlParseRoot=n;
  uassert(n!=NULL,"CQL: Unable to parse buffer");
  n->setChildVariations();
  n->setUseMarks();
  if(n->isSilent()) n->makeSilentRecursively();
  n->makeNotNodeSilentRecursively();
  n->expand();
  n->addSortFields(n->sortfields);
  return n;
}
#endif

void showTokens(){
  if(!CqlGlobalTokens)
    printf("No global tokens\n");
  CqlGlobalTokens->print();
}


// Everything below this line is kludgeville... necessary because any inclusion
// of a header from this directory in tkscid.cpp descends into include-file-hell.

#ifdef INTEGRATED

bool CqlParseBuffer(char *buffer) {

  parseBuffer(buffer);

  // If there's a problem, we'll longjmp() our way out of it before we reach this point.
  return true;
}

// Reset initialised statics and free mem resources.
void CqlReset() {

  //if (MarkBoard::globalMarkBoard) {
    //delete MarkBoard::globalMarkBoard;
    //MarkBoard::globalMarkBoard=NULL;
  //}

  cql_initialize();

}
#endif
