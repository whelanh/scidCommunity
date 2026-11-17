/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include <cstring>
#include <string>
#include <string_view>

#include "node.h"

int Token::CurrentLine{0};
int Token::CurrentChar{0};

std::string Token::locationString() const {
  return "{Line " + std::to_string(line) + ", Character " +
         std::to_string(character) + "}";
}

void Token::printLocation() {
  printf("%s", locationString().c_str());
}

StringToken::StringToken(std::string_view c) {
  uassert(!c.empty());
  value = c;
}

bool PieceToken::isAllowed(char c) {
  constexpr std::string_view allowed = "RNBQKPrnbqkpAaU?_";
  return allowed.find(c) != std::string_view::npos;
}

PieceToken::PieceToken(char c) {
  uassert(isAllowed(c));
  value = c;
}

PieceToken* PieceToken::create(char c) {
  if (isAllowed(c)) return new PieceToken(c);
  return nullptr;
}

SquareToken::SquareToken(int mif, int maf, int mir, int mar) {
  uassert(isAllowed(mif, maf, mir, mar), "Internal error: bad square arguments");
  minfile = mif;
  maxfile = maf;
  minrank = mir;
  maxrank = mar;
}

bool SquareToken::isAllowed(int mif, int maf, int mir, int mar) {
  return file_valid(mif) && file_valid(maf) && rank_valid(mir) &&
         rank_valid(mar) && mif <= maf && mir <= mar;
}

bool StringToken::eq(std::string_view v) const {
  return v == value;
}

void OneToken::print() {
  printf("'%c' at %s\n", getChar(), locationString().c_str());
}

void SquareToken::print() {
  const char mif = file_to_char_cql(minfile);
  const char maf = file_to_char_cql(maxfile);
  const char mir = rank_to_char_cql(minrank);
  const char mar = rank_to_char_cql(maxrank);
  if (minfile == maxfile) printf("%c", mif);
  else printf("%c-%c", mif, maf);
  if (minrank == maxrank) printf("%c", mir);
  else printf("%c-%c", mir, mar);
}

void StringToken::print() {
  printf("<%s %s %s>", thisclass(), locationString().c_str(), value.c_str());
}

void IntToken::print() {
  printf("<%s: %s %d>", thisclass(), locationString().c_str(), value);
}

void PieceToken::print() {
  printf("%c", value);
}

PieceDesignatorToken::PieceDesignatorToken(vector<PieceToken*> ps,
                                           vector<SquareToken*> ss,
                                           vector<VariableToken*> vs)
    : pieces(std::move(ps)), squares(std::move(ss)), variables(std::move(vs)) {
}

void PieceDesignatorToken::print() {
  printf("<%s %s", thisclass(), locationString().c_str());
  printf(" pieces: ");
  for (auto p : pieces) p->print();
  printf(" squares: ");
  for (auto s : squares) s->print();
  if (!variables.empty()) {
    printf(" Vars: ");
    for (auto v : variables) v->print();
  }
  printf(">");
}

VariableToken* PieceDesignatorToken::getAsVariableToken() {
  if (pieces.size() != 1 || squares.size() != 1 || variables.size() != 1)
    return nullptr;
  if (pieces[0]->value != '?') return nullptr;
  SquareToken* s = squares[0];
  if (s->minfile != 0 || s->maxfile != 7 || s->minrank != 0 || s->maxrank != 7)
    return nullptr;
  return variables[0];
}

void Token::print() {
  printf("<%s %s>", thisclass(), locationString().c_str());
}
