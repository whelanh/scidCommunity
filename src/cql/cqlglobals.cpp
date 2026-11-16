#include "cqlglobals.h"
using std::set;

bool CqlDebug=false;
bool CqlParseOnly=false;
bool CqlShowParse=false;
bool CqlShowLex=false;

const char* CqlFilename=0;
#ifdef STANDALONE
const char* CqlPgnFilename=0;
const char* CqlOutputFilename=0;
#endif
#ifdef INTEGRATED
const char* CqlPgnFilename="fileInNull.pgn";
const char* CqlOutputFilename="fileOutNull.pgn";
#endif
bool CqlSilent=false;
Range* CqlGameNumberRange=0;
Range* CqlYearRange=0;
const char* CqlPlayer=0;
int MarkBoard_gameAppendComment_lastignored=-1; //must be initialized to -1
int Tokens_match_optional_numericvariable_nextid=0; // the next valid id to use if no name specified by numeric
Tokens* CqlGlobalTokens=0; //the list of tokens that have been read
CqlNode* CqlParseRoot=0; //The most recently read CQL parse tree;
set<SequenceBase*>* CqlAllSequences=0; //All of the sequences, used by Nest::getSequenceDescendants
bool CqlDoNotLinearize=false;

void cqlglobals_initialize(){
 CqlDebug=false;
 CqlParseOnly=false;
 CqlShowParse=false;
 CqlShowLex=false;
 CqlFilename=0;
 #ifdef STANDALONE
 CqlPgnFilename=0;
 CqlOutputFilename=0;
 #endif
 #ifdef INTEGRATED
 CqlPgnFilename="fileInNull.pgn";
 CqlOutputFilename="fileOutNull.pgn";
 #endif
 CqlSilent=false;
 CqlGameNumberRange=0;
 CqlYearRange=0;
 CqlPlayer=0;
 MarkBoard_gameAppendComment_lastignored=-1; //must be initialized to -1
 Tokens_match_optional_numericvariable_nextid=0; // the next valid id to use if no name specified by numeric
 CqlGlobalTokens=0; //the list of tokens that have been read
 CqlParseRoot=0; //The most recently read CQL parse tree;
 CqlAllSequences=0; //All of the sequences, used by SequenceBase::getSequenceDescendants()
 CqlDoNotLinearize=false;
}
