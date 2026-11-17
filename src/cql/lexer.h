/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
#include "node.h"

bool lexFile(const char* filename, vector<Token*>* tokens);
bool lexStream(FILE* file, const char* buffer, vector<Token*>* tokens);
const char* readstring(FILE* file);
const char* readstring(const char* syntax);
Token* makeToken(const char* val);
PieceDesignatorToken* match_piecedesignator(const char* input);
bool match_piecespecifier(const char** inputp, vector<PieceToken*>* pieces);
PieceToken* match_singlepiecespecifier(const char** inputp);
bool match_singlepiecespecifierplus(const char** input,
                                    vector<PieceToken*>* piecesp);
PieceToken* match_simplepiecespecifier(const char** inputp);
bool match_compoundpiecespecifier(const char** inputp,
                                  vector<PieceToken*>* piecesp);
bool match_alphanums(const char** inputp, char* result, std::size_t maxlength);
Token* match_keyword(const char* input);
bool match_char(const char** input, char c);
VariableToken* match_variable(const char** input);
void match_variables(const char** input, vector<VariableToken*>* variablesp);
VariableToken* match_variable(const char* input);
bool match_letterdigit(const char** inputp, char* ch);
bool match_letterdigits(const char* input);
bool match_squarespecifier(const char** inputp,
                           vector<SquareToken*>* squaresp);
SquareToken* match_square(const char** inputp);
bool match_commasquares(const char** input, vector<SquareToken*>* squaresp);
bool match_file(const char** inputp, int* result);
bool match_rank(const char** inputp, int* result);
SquareToken* match_blocksquarespecifier(const char** inputp);
bool match_compoundsquarespecifier(const char** inputp,
                                   vector<SquareToken*>* squaresp);
bool match_files(const char** inputp, int* min, int* max);
bool match_filerange(const char** inputp, int* min, int* max);
bool match_ranks(const char** inputp, int* min, int* max);
bool match_rankrange(const char** inputp, int* min, int* max);
Token* match_int(const char* val);
Token* match_Bar(const char* v);
Token* match_Star(const char* v);
Token* match_QuestionMark(const char* v);
Token* match_Plus(const char* v);
Token* match_LParen(const char* v);
Token* match_RParen(const char* v);
Token* match_LBrace(const char* v);
Token* match_RBrace(const char* v);
Token* match_LessThan(const char* v);
Token* match_GreaterThan(const char* v);
Token* match_name(const char* input);
Token* match_quotedstring(const char* v);
