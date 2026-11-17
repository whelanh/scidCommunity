/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
#include <string>

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
  const char*value;
  StringToken(const char*x);
  void print() override;
  virtual bool eq(const char*v);
  const char* thisclass() override{return "StringToken";}
  int len() override{return strlen(value);}
};

class NameToken: public StringToken{
 public:
 NameToken(const char*x): StringToken(x){}
  const char* thisclass() override{return "NameToken";}
};

class QuotedStringToken: public StringToken{
 public:
 QuotedStringToken(const char* x):StringToken(x){}
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
  const char*value;
 const char* thisclass() override{return "KeywordToken";}
 static bool isReserved(const char* s);
 bool eq(const char *v);
 KeywordToken(const char*v);
 void print() override;
 int len() override{return strlen(value);}
};

class VariableToken: public StringToken{
 public:
 VariableToken(const char*x): StringToken(x){}
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


