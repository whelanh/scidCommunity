/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
#include <string>
#include <string_view>

#include "util.h"
#include "deleteable.h"
class PieceLoc;
class SquareToken;
class PieceToken;

class Token:public Deleteable {
 public:
  static int CurrentLine;
  static int CurrentChar;
  int line{CurrentLine};
  int character{CurrentChar};
  virtual int len()=0;

  static void incrementLine(){++CurrentLine;CurrentChar=0;};
  static void decrementLine(){--CurrentLine;uassert(CurrentLine>=1);}
  static void incrementChar(){++CurrentChar;}
  static void decrementChar(){--CurrentChar;uassert(CurrentChar>=0);}
  void printLocation();
  std::string locationString() const;
  virtual void print();
  virtual const char* thisclass(){return "UnknownToken";}
};

class OneToken:public Token{
 public:
  virtual char getChar()=0;
  int len() override{return 1;}
  void print() override;
};

class BarToken:public OneToken{
 public:
  const char* thisclass() override{return "BarToken";}
  char getChar() override{return '|';}
};

class StarToken:public OneToken{
 public:
  const char* thisclass() override{return "StarToken";}
  char getChar() override{return '*';}
};
class PlusToken:public OneToken{
 public:
  const char* thisclass() override{return "PlusToken";}
  char getChar() override{return '+';}
};
class QuestionMarkToken:public OneToken{
 public:
  const char* thisclass() override{return "QuestionMarkToken";}
  char getChar() override{return '?';}
};

class LessThanToken:public OneToken{
 public:
  const char* thisclass() override{return "LessThanToken";}
  char getChar() override{return '<';}
};

class GreaterThanToken:public OneToken{
 public:
  const char* thisclass() override{return "GreaterThanToken";}
  char getChar() override{return '>';}
};
    
class LParenToken:public OneToken{
 public:
  const char* thisclass() override{return "LParenToken";}
  char getChar() override{return '(';}
};

class RParenToken: public OneToken{
 public:
  const char* thisclass() override{return "RParenToken";}
  char getChar() override{return ')';}
};

class LBraceToken:public OneToken{
 public:
  const char* thisclass() override{return "LBraceToken";}
  char getChar() override{return '{';}
};

class RBraceToken: public OneToken{
 public:
  const char* thisclass() override{return "RBraceToken";}
  char getChar() override{return '}';}
};

class StringToken: public Token{
 public:
  std::string value;
  explicit StringToken(std::string_view x);
  void print() override;
  bool eq(std::string_view v) const;
  const char* thisclass() override{return "StringToken";}
  int len() override{return static_cast<int>(value.size());}
};

class NameToken: public StringToken{
 public:
  explicit NameToken(std::string_view x): StringToken(x){}
  const char* thisclass() override{return "NameToken";}
};

class QuotedStringToken: public StringToken{
 public:
  explicit QuotedStringToken(std::string_view x):StringToken(x){}
  const char* thisclass() override{return "QuotedStringToken";}
};

class IntToken: public Token{
 public:
  int value;
  IntToken(int i){value=i;}
  void print() override;
  const char* thisclass() override{return "IntToken";}
  int len() override{return 1;}//not actually accurate
};

class KeywordToken:public Token{
 public:
  std::string value;
  const char* thisclass() override{return "KeywordToken";}
  static bool isReserved(std::string_view s);
  bool eq(std::string_view v) const;
  explicit KeywordToken(std::string_view v);
  void print() override;
  int len() override{return static_cast<int>(value.size());}
};

class VariableToken: public StringToken{
 public:
  explicit VariableToken(std::string_view x): StringToken(x){}
  const char* thisclass() override{return "VariableToken";}
};

class PieceToken: public Token{
 public:
  char value;
  PieceToken(char v);
  void print() override;
  static PieceToken *create(char c);
  static bool isAllowed(char c);
  const char* thisclass() override{return "PieceToken";}
  int len() override{return 1;}
};

class PieceDesignatorToken:public Token{
 public:
  PieceLoc* pieceloc{nullptr};
  vector<PieceToken*>pieces;
  vector<SquareToken*> squares;
  vector<VariableToken*> variables;
  PieceDesignatorToken(vector<PieceToken*>,vector<SquareToken*>,vector<VariableToken*>);
  VariableToken* getAsVariableToken();
  void print() override;
  const char* thisclass() override{return "PieceDesignatorToken";}
  int len() override{return 1;}//inaccurate
  };
using PDT = PieceDesignatorToken;

class SquareToken: public Token{
 public:
  int minfile;
  int maxfile;
  int minrank;
  int maxrank;
  bool isAllowed(int mif, int maf, int mir, int mar);
  SquareToken(int mif, int maf, int mir, int mar);
  void print() override;
  const char* thisclass() override{return "SquareToken";}
  int len() override{return 1;}
};


