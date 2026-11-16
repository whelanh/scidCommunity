#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "token.h"
#include "node.h"
#include "lexer.h"

bool lexFile(const char*filename, vector<Token*>*tokens){
  FILE * file=fopen(filename,"r");
  if (file==NULL){
    fprintf(stderr,"Could not open file: %s\n",filename);
    exit(1);
  }
  return lexStream(file,NULL,tokens);
  fclose(file);
  return true;
}

int rsIndex;
bool lexStream(FILE*file, char*buffer, vector<Token*>*tokens){
  char* current = NULL;
  rsIndex = 0;
  Token::incrementLine();
  while(true){
    // kludge alert
    if (file) current=readstring(file);
    else if (buffer) current=readstring(buffer);
    else uassert(false,"Could not find syntax");

    if(current==NULL) return true;
    Token* token=makeToken(current);
    if(!token){
      fprintf(stderr,"Unable to process string: %s\n",current);
      uassert(false,"Syntax error");
    }
    tokens->push_back(token);
  }
  return true;
}

char * readstring(FILE * file){
  char buffer[1000];
  int c;
  int nextchar=0;
  while ((c=fgetc(file))>=0){
    Token::incrementChar();
    if(c=='\n')Token::incrementLine();
    if (isspace(c)) continue;
    else if (c==';'){
      while((c=fgetc(file))>=0){
	Token::incrementChar();
	if (c=='\n') {Token::incrementLine();break;}
      }
      if (c<0) break;
      else continue;
    }
    else if (c=='"'){
      Token::incrementChar();
      buffer[nextchar++]=c;
      uassert(nextchar<sizeof(buffer)-2,"Token too long");
      while ((c=fgetc(file))>=0){
	uassert(c>0,"Unexpected EOF in quoted string");
	uassert(c!='\n',"Unexpected newline inside quoted string");
	uassert(nextchar<sizeof(buffer)-2,"Token too long here");
	buffer[nextchar++]=c;
	Token::incrementChar();
	if (c=='"'){
	  buffer[nextchar++]=0;
	  return util::copy(buffer);
	} // if c is the trailing quote
      } // end read the quote
    }// end beging the quote
    else if (c=='(') return "(";
    else if (c==')') return ")";
    else if (c=='{') return "{";
    else if (c=='}') return "}";
    else if (c=='*') return "*";
    else if (c=='+') return "+";
    else if (c=='?') return "?";
    else {
      ungetc(c,file);
      if(c=='\n')
	Token::decrementLine();
      else
	Token::decrementChar();
      break;
    }
  }
  if (c<0) return NULL;
  while((c=fgetc(file))>=0){
    if(c=='\n')Token::incrementLine();
    else
      Token::incrementChar();
    if (isspace(c)||c=='('||c==')'||c=='{'||c=='}'||c=='*'||c=='+'||c=='?'){
      ungetc(c,file);
      if(c=='\n') Token::decrementLine();
      else
	Token::decrementChar();
      buffer[nextchar++]=0;
      return util::copy(buffer);
    }
    else if (nextchar>500){
      fprintf(stderr,"token too long: readstring");
      exit(1);
    }
    else buffer[nextchar++]=c;
  }
  if (nextchar==0)
    return NULL;
  buffer[nextchar++]=0;
  return util::copy(buffer);
}


int bgetc(char *buffer) {
  int c = buffer[rsIndex++];
  if (c) return c;
  else return EOF;
}

int bungetc(int c, char *buffer) {
  rsIndex--;
  return c;
}

char * readstring(char * syntax){
  char buffer[1000];
  int c;
  int nextchar=0;
  while ((c=bgetc(syntax))>=0){
    Token::incrementChar();
    if(c=='\n')Token::incrementLine();
    if (isspace(c)) continue;
    else if (c==';'){
      while((c=bgetc(syntax))>=0){
	Token::incrementChar();
	if (c=='\n') {Token::incrementLine();break;}
      }
      if (c<0) break;
      else continue;
    }
    else if (c=='"'){
      Token::incrementChar();
      buffer[nextchar++]=c;
      uassert(nextchar<sizeof(buffer)-2,"Token too long");
      while ((c=bgetc(syntax))>=0){
	uassert(c>0,"Unexpected EOF in quoted string");
	uassert(c!='\n',"Unexpected newline inside quoted string");
	uassert(nextchar<sizeof(buffer)-2,"Token too long here");
	buffer[nextchar++]=c;
	Token::incrementChar();
	if (c=='"'){
	  buffer[nextchar++]=0;
	  return util::copy(buffer);
	} // if c is the trailing quote
      } // end read the quote
    }// end beging the quote
    else if (c=='(') return "(";
    else if (c==')') return ")";
    else if (c=='{') return "{";
    else if (c=='}') return "}";
    else if (c=='*') return "*";
    else if (c=='+') return "+";
    else if (c=='?') return "?";
    else {
      bungetc(c,syntax);
      if(c=='\n')
	Token::decrementLine();
      else
	Token::decrementChar();
      break;
    }
  }
  if (c<0) return NULL;
  while((c=bgetc(syntax))>=0){
    if(c=='\n')Token::incrementLine();
    else
      Token::incrementChar();
    if (isspace(c)||c=='('||c==')'||c=='{'||c=='}'||c=='*'||c=='+'||c=='?'){
      bungetc(c,syntax);
      if(c=='\n') Token::decrementLine();
      else
	Token::decrementChar();
      buffer[nextchar++]=0;
      return util::copy(buffer);
    }
    else if (nextchar>500){
      uassert(false,"token too long: readstring");
    }
    else buffer[nextchar++]=c;
  }
  if (nextchar==0)
    return NULL;
  buffer[nextchar++]=0;
  return util::copy(buffer);
}

Token* makeToken(char* val){
  char*current=val;
  uassert(current&&strlen(current),"makeToken bad arg");
  uassert(strlen(val)<100,"Max token size too large");
  Token* t=NULL;
  if(!t) t=match_LParen(current);
  if(!t) t=match_RParen(current);
  if(!t) t=match_LBrace(current);
  if(!t) t=match_RBrace(current);
  if(!t) t=match_Star(current);
  if(!t) t=match_Plus(current);
  if(!t) t=match_QuestionMark(current);
  if(!t) t=match_keyword(current);
  if(!t) t=match_int(current);
  if(!t) t=match_piecedesignator(current);
  if(!t) t=match_quotedstring(current);
  if(!t) t=match_name(current);
  if (t==NULL){
    //If val has a '.' in it, then it is likely due to a wrong CQL version:
    uassert(current==val,"makeToken: logic");
    for(current=val;*current;++current)
	uassert(*current!='.',
		"A lexer error involving a token with a '.' in it was observed. The '.' means 'any' since version 5.2. Use '_' to denote an empty square: ",
		val);
    uassert(false,"Lexer: Unknown or not understood sequence of characters: ",val);
  } // if (t==NULL)
  uassert(t,"make_token: internal");
  return t;
}

Token* match_Star(char*v){
  uassert(v,"match_Star internal");
  if (*v=='*') return new StarToken;
  return NULL;
}
Token* match_Plus(char*v){
  uassert(v);
  if (*v=='+') return new PlusToken;
  return NULL;
}
Token* match_QuestionMark(char*v){
  uassert(v);
  if (*v=='?') return new QuestionMarkToken;
  return NULL;
}

Token* match_Bar(char*v){
  uassert(v);
  if (*v=='|') return new BarToken;
  return NULL;
}

Token* match_LParen(char*v){
  uassert(v);
  if(*v=='(') return new LParenToken;
  return NULL;
}

Token* match_RParen(char*v){
  uassert(v);
  if(*v==')') return new RParenToken;
  return NULL;
}

Token* match_LBrace(char*v){
  uassert(v);
  if(*v=='{') return new LBraceToken;
  return NULL;
}

Token* match_RBrace(char*v){
  uassert(v);
  if(*v=='}') return new RBraceToken;
  return NULL;
}

Token* match_LessThan(char*v){
  uassert(v);
  if(*v=='<') return new LessThanToken;
  return NULL;
}

Token* match_GreaterThan(char*v){
  uassert(v);
  if(*v=='>') return new GreaterThanToken;
  return NULL;
}


Token* match_int(char*val){
  int tokval=0;
  if(util::signedIntValue(val,&tokval))
    return new IntToken(tokval);
  return NULL;
}
  
  
Token* match_keyword(char*input){
  if(!KeywordToken::isReserved(input))return NULL;
  return new KeywordToken(input);
}

bool match_letterdigits(char*input){
  uassert(input);
  char*current=input;
  while(char c=*current++)
    if(!isalnum(c))return false;
  return true;
}

Token* match_name(char*input){
  uassert(input);
  char*current=input;
  while(char c=*current++)
    if(!isalnum(c)&&
       c!='.'&&
       c!='/'&&
       c!='-'&&
       c!='_')return NULL;
  return new NameToken(input);
}

bool match_letterdigit(char**inputp,char * ch){
  char*current=*inputp;
  uassert(current);
  if(isalnum(current[0])){
    *inputp= *inputp+1;
    return true;
  }
  return false;
}
  
Token* match_quotedstring(char* v){
  if (!v) return NULL;
  //  if(1)printf("match_quotedstring called on v: %s\n",v);
  int vlen=(int)(strlen(v));
  if (vlen<=2)return NULL;
  if(v[0]!='"'||v[vlen-1]!='"')return NULL;
  uassert(vlen<500,"string token too long: 500 character limit");
  char buffer[502];
  sprintf(buffer,"%s",v);
  uassert(buffer[vlen-1]=='"',"internal");
  buffer[vlen-1]=0;
  char*result=buffer+1;
  uassert(strlen(result)==vlen-2);
  return new QuotedStringToken(util::copy(result));
}
