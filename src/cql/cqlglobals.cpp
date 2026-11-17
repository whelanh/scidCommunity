/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include <limits>

#include "cqlglobals.h"

// One copy per thread: each thread parses the query and matches its own games.
thread_local bool CqlDebug=false;
thread_local bool CqlParseOnly=false;
thread_local bool CqlShowParse=false;
thread_local bool CqlShowLex=false;

thread_local const char* CqlFilename=nullptr;
#ifdef STANDALONE
thread_local const char* CqlPgnFilename=nullptr;
thread_local const char* CqlOutputFilename=nullptr;
#endif
#ifdef INTEGRATED
thread_local const char* CqlPgnFilename="fileInNull.pgn";
thread_local const char* CqlOutputFilename="fileOutNull.pgn";
#endif
thread_local bool CqlSilent=false;
thread_local Range* CqlGameNumberRange=nullptr;
thread_local Range* CqlYearRange=nullptr;
thread_local const char* CqlPlayer=nullptr;
thread_local unsigned MarkBoard_gameAppendComment_lastignored=std::numeric_limits<unsigned>::max();
thread_local int Tokens_match_optional_numericvariable_nextid=0; // the next valid id to use if no name specified by numeric
thread_local Tokens* CqlGlobalTokens=nullptr; //the list of tokens that have been read
thread_local CqlNode* CqlParseRoot=nullptr; //The most recently read CQL parse tree;
thread_local std::set<SequenceBase*>* CqlAllSequences=nullptr; //All of the sequences, used by Nest::getSequenceDescendants
thread_local bool CqlDoNotLinearize=false;

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
