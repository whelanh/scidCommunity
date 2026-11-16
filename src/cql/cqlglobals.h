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

extern bool CqlDebug; // debugging, not used
extern bool CqlParseOnly; //show only the parse
extern bool CqlShowLex; // show only the lex, may not be used
extern bool CqlShowParse; // show the parse
extern const char* CqlFilename; // read from this CqlFilename
extern const char* CqlPgnFilename; //read from this PgnFilename
extern const char* CqlOutputFilename; // read from this CqlOutputFilename
extern Range* CqlGameNumberRange; //Use this gamenumberrange
extern bool CqlSilent; // don't comment
extern Range* CqlYearRange; // only search in these years
extern const char* CqlPlayer; //only look for this player
extern bool CqlDoNotLinearize; // whether to linearize move filters inside next filter

/* Caches: static variables in methods*/
extern  int MarkBoard_gameAppendComment_lastignored; //must be initialized to -1
extern int Tokens_match_optional_numericvariable_nextid; // the next valid id to use if no name specified by numeric
extern Tokens* CqlGlobalTokens; //the list of tokens that have been read

/* Other global variables*/
extern CqlNode* CqlParseRoot; //The most recently read CQL parse tree;
extern std::set<SequenceBase*>* CqlAllSequences; //All of the sequences, used by SequenceBase::nestsClearAll
