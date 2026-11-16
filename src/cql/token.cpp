#include <stdio.h>
#include "node.h"
int Token::CurrentLine{0};
int Token::CurrentChar{0};


      
char* Token::locationString(){
  char buffer[100];
  sprintf(buffer,"{Line %d, Character %d}",line,character);
  return util::copy(buffer);
}

void Token::printLocation(){
  printf("%s",locationString());
}

StringToken::StringToken(const char *c){
  uassert(c);
  value=c;
}

bool PieceToken::isAllowed(char c){
  static char* allowed="RNBQKPrnbqkpAaU?_";
  for (int i=0;i<strlen(allowed);++i)
    if (c==allowed[i])return true;
  return false;
}

PieceToken::PieceToken(char c){
  uassert(isAllowed(c));
  value=c;
}

PieceToken* PieceToken::create(char c){
  if(isAllowed(c)) return new PieceToken(c);
  return NULL;
}

SquareToken::SquareToken(int mif, int maf, int mir, int mar){
  uassert(isAllowed(mif,maf,mir,mar),"Internal error: bad square arguments");
  minfile=mif;
  maxfile=maf;
  minrank=mir;
  maxrank=mar;
}

bool SquareToken::isAllowed(int mif, int maf, int mir, int mar){
  return file_valid(mif)&&
    file_valid(maf)&&
    rank_valid(mir)&&
    rank_valid(mar)&&
    mif<=maf&&
    mir<=mar;
}

bool StringToken::eq(const char*v){
  uassert(v!=NULL);
  return strcmp(v,value)==0;
}

void OneToken::print(){
  printf("'%c' at %s\n",getChar(),locationString());
}

void SquareToken::print(){
  //  printf("<%s %s ",thisclass(),locationString());
  char mif=file_to_char_cql(minfile);
  char maf=file_to_char_cql(maxfile);
  char mir=rank_to_char_cql(minrank);
  char mar=rank_to_char_cql(maxrank);
  if(minfile==maxfile) printf("%c",mif);
  else printf("%c-%c",mif,maf);
  if(minrank==maxrank) printf("%c",mir);
  else printf("%c-%c",mir,mar);
  //  printf(">");
}

void StringToken::print(){
  printf("<%s %s %s>",thisclass(),locationString(),value);
}

void IntToken::print(){
  printf("<%s: %s %d>",thisclass(),locationString(),value);
}
  
void PieceToken::print(){
  //  printf("<%s: %s %c>",thisclass(),locationString(), value);
  printf("%c",value);
}


PieceDesignatorToken::PieceDesignatorToken(vector<PieceToken*>ps,
					   vector<SquareToken*>ss,
					   vector<VariableToken*>vs){
  pieces=ps;
  squares=ss;
  variables=vs;
}

void PieceDesignatorToken::print(){
  printf("<%s %s",thisclass(),locationString());
  printf(" pieces: ");
  for(auto p : pieces) p->print();
  printf(" squares: ");
  for(auto s : squares) s->print();
  if(variables.size()){
    printf(" Vars: ");
    for (auto v:variables) v->print();
  }
  printf(">");
}

VariableToken* PieceDesignatorToken::getAsVariableToken(){
  if(pieces.size()!=1 || squares.size()!=1 || variables.size()!=1)
    return NULL;
  if(pieces[0]->value!='?')return NULL;
  SquareToken*s=squares[0];
  if(s->minfile!=0||
     s->maxfile!=7||
     s->minrank!=0||
     s->maxrank!=7)return NULL;
  return variables[0];
}
  
  
  // printf("<%s pieces: ",thisclass());
  // for(int i=0;i<pieces.size();++i)
  //   pieces[i]->print();
  // printf(" squares: ");
  // for(int i=0;i<squares.size();++i)
  //   squares[i]->print();
  // printf("> ");


  void Token::print(){
    printf("<%s %s>",thisclass(),locationString());
}
  
