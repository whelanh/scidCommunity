#pragma once
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
  char* locationString();
  virtual void print();
  virtual const char* thisclass(){return "UnknownToken";}
};

class OneToken:public Token{
 public:
  virtual char getChar()=0;
  int len(){return 1;}
  void print();
};

class BarToken:public OneToken{
 public:
  virtual const char* thisclass(){return "BarToken";}
  char getChar(){return '|';}
};

class StarToken:public OneToken{
 public:
  virtual const char* thisclass(){return "StarToken";}
  char getChar(){return '*';}
};
class PlusToken:public OneToken{
 public:
  virtual const char* thisclass(){return "PlusToken";}
  char getChar(){return '+';}
};
class QuestionMarkToken:public OneToken{
 public:
  virtual const char* thisclass(){return "QuestionMarkToken";}
  char getChar(){return '?';}
};

class LessThanToken:public OneToken{
 public:
  const char* thisclass(){return "LessThanToken";}
  char getChar(){return '<';}
};

class GreaterThanToken:public OneToken{
 public:
  const char* thisclass(){return "GreaterThanToken";}
  char getChar(){return '>';}
};
    
class LParenToken:public OneToken{
 public:
  virtual const char* thisclass(){return "LParenToken";}
  char getChar(){return '(';}
};

class RParenToken: public OneToken{
 public:
  virtual const char* thisclass(){return "RParenToken";}
  char getChar(){return ')';}
};

class LBraceToken:public OneToken{
 public:
  virtual const char* thisclass(){return "LBraceToken";}
  char getChar(){return '{';}
};

class RBraceToken: public OneToken{
 public:
  virtual const char* thisclass(){return "RBraceToken";}
  char getChar(){return '}';}
};

class StringToken: public Token{
 public:
  const char*value;
  StringToken(const char*x);
  void print();
  virtual bool eq(const char*v);
  virtual const char* thisclass(){return "StringToken";}
  int len(){return strlen(value);}
};

class NameToken: public StringToken{
 public:
 NameToken(const char*x): StringToken(x){}
  virtual const char* thisclass(){return "NameToken";}
};

class QuotedStringToken: public StringToken{
 public:
 QuotedStringToken(const char* x):StringToken(x){}
  virtual const char* thisclass(){return "QuotedStringToken";}
};

class IntToken: public Token{
 public:
  int value;
  IntToken(int i){value=i;}
  void print();
  virtual const char* thisclass(){return "IntToken";}
  int len(){return 1;}//not actually accurate
};

class KeywordToken:public Token{
 public:
  const char*value;
 virtual const char* thisclass(){return "KeywordToken";}
 static bool isReserved(const char* s);
 bool eq(const char *v);
 KeywordToken(const char*v);
 void print();
 int len(){return strlen(value);}
};

class VariableToken: public StringToken{
 public:
 VariableToken(const char*x): StringToken(x){}
  virtual const char* thisclass(){return "VariableToken";}
};

class PieceToken: public Token{
 public:
  char value;
  PieceToken(char v);
  void print();
  static PieceToken *create(char c);
  static bool isAllowed(char c);
  virtual const char* thisclass(){return "PieceToken";}
  int len(){return 1;}
};

class PieceDesignatorToken:public Token{
 public:
  PieceLoc* pieceloc{NULL};
  vector<PieceToken*>pieces;
  vector<SquareToken*> squares;
  vector<VariableToken*> variables;
  PieceDesignatorToken(vector<PieceToken*>,vector<SquareToken*>,vector<VariableToken*>);
  VariableToken* getAsVariableToken();
  void print();
  virtual const char* thisclass(){return "PieceDesignatorToken";}
  int len(){return 1;}//inaccurate
  };
typedef PieceDesignatorToken PDT;

class SquareToken: public Token{
 public:
  int minfile;
  int maxfile;
  int minrank;
  int maxrank;
  bool isAllowed(int mif, int maf, int mir, int mar);
  SquareToken(int mif, int maf, int mir, int mar);
  void print();
  virtual const char* thisclass(){return "SquareToken";}
  int len(){return 1;}
};


