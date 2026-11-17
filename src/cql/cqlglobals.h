/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
/***** certain global variables to be reset.*////
/**the following are used to hold command line parameters. 
   These parameters override values specified in the cql file itself
   Most of these don't need to be global at all actually
*/
#include <set>
class Range;
class Tokens;
class SequenceBase;
class CqlNode;

// All of the engine's state below is per query, not per process: each thread
// parses its own copy of the query and matches its own games (see the
// parallel search in sc_search_cql()), so a shared variable here would be a
// data race and would let one game's bindings leak into another thread's.
extern thread_local bool CqlDebug; // debugging, not used
extern thread_local bool CqlParseOnly; //show only the parse
extern thread_local bool CqlShowLex; // show only the lex, may not be used
extern thread_local bool CqlShowParse; // show the parse
extern thread_local const char* CqlFilename; // read from this CqlFilename
extern thread_local const char* CqlPgnFilename; //read from this PgnFilename
extern thread_local const char* CqlOutputFilename; // read from this CqlOutputFilename
extern thread_local Range* CqlGameNumberRange; //Use this gamenumberrange
extern thread_local bool CqlSilent; // don't comment
extern thread_local Range* CqlYearRange; // only search in these years
extern thread_local const char* CqlPlayer; //only look for this player
extern thread_local bool CqlDoNotLinearize; // whether to linearize move filters inside next filter

/* Caches: static variables in methods*/
extern thread_local unsigned MarkBoard_gameAppendComment_lastignored; //sentinel: max unsigned
extern thread_local int Tokens_match_optional_numericvariable_nextid; // the next valid id to use if no name specified by numeric
extern thread_local Tokens* CqlGlobalTokens; //the list of tokens that have been read

/* Other global variables*/
extern thread_local CqlNode* CqlParseRoot; //The most recently read CQL parse tree;
extern thread_local std::set<SequenceBase*>* CqlAllSequences; //All of the sequences, used by SequenceBase::nestsClearAll
