/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include <limits>

#include "cqlglobals.h"

bool CqlDebug=false;
bool CqlParseOnly=false;
bool CqlShowParse=false;
bool CqlShowLex=false;

const char* CqlFilename=nullptr;
#ifdef STANDALONE
const char* CqlPgnFilename=nullptr;
const char* CqlOutputFilename=nullptr;
#endif
#ifdef INTEGRATED
const char* CqlPgnFilename="fileInNull.pgn";
const char* CqlOutputFilename="fileOutNull.pgn";
#endif
bool CqlSilent=false;
Range* CqlGameNumberRange=nullptr;
Range* CqlYearRange=nullptr;
const char* CqlPlayer=nullptr;
unsigned MarkBoard_gameAppendComment_lastignored=std::numeric_limits<unsigned>::max();
int Tokens_match_optional_numericvariable_nextid=0; // the next valid id to use if no name specified by numeric
Tokens* CqlGlobalTokens=nullptr; //the list of tokens that have been read
CqlNode* CqlParseRoot=nullptr; //The most recently read CQL parse tree;
std::set<SequenceBase*>* CqlAllSequences=nullptr; //All of the sequences, used by Nest::getSequenceDescendants
bool CqlDoNotLinearize=false;

void cqlglobals_initialize(){
 CqlDebug=false;
 CqlParseOnly=false;
 CqlShowParse=false;
 CqlShowLex=false;
 CqlFilename=nullptr;
 #ifdef STANDALONE
 CqlPgnFilename=nullptr;
 CqlOutputFilename=nullptr;
 #endif
 #ifdef INTEGRATED
 CqlPgnFilename="fileInNull.pgn";
 CqlOutputFilename="fileOutNull.pgn";
 #endif
 CqlSilent=false;
 CqlGameNumberRange=nullptr;
 CqlYearRange=nullptr;
 CqlPlayer=nullptr;
 MarkBoard_gameAppendComment_lastignored=std::numeric_limits<unsigned>::max();
 Tokens_match_optional_numericvariable_nextid=0; // the next valid id to use if no name specified by numeric
 CqlGlobalTokens=nullptr; //the list of tokens that have been read
 CqlParseRoot=nullptr; //The most recently read CQL parse tree;
 CqlAllSequences=nullptr; //All of the sequences, used by SequenceBase::getSequenceDescendants()
 CqlDoNotLinearize=false;
}
