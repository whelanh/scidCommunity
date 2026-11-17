/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "tokenstream.h"
#include "util.h"

void Tokens::print(){
  printf("Tokens: Bottom: %d size: %lu Tokens:\n",bottom, tokens.size());
  for(int i=0;i<tokens.size();++i){
    printf("Token %d of %lu: ",i,tokens.size());
    tokens[i]->print();
    printf("\n");
  }
  printf("\n");
}

bool Tokens::eof(){
  return bottom==(int)tokens.size();
}

Token* Tokens::current(){
  if(eof())return nullptr;
  return tokens[bottom];
}

void Tokens::forward(){
  uassert(!eof());
  ++bottom;
}

Tokens::Tokens(vector<Token*>ts){
  for(auto s:ts)
    {uassert (s!=nullptr);}
  tokens=ts;
  bottom=0;
}

int Tokens::save(){
  return bottom;
}

void Tokens::restore(int x){
  uassert(x<=bottom&&x>=0,"internal stack error");
  bottom=x;
}


  
  
