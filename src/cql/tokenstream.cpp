/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "tokenstream.h"
#include "util.h"

void Tokens::print(){
  printf("Tokens: Bottom: %d size: %zu Tokens:\n",bottom, tokens.size());
  std::size_t i=0;
  for(auto* token:tokens){
    printf("Token %zu of %zu: ",i,tokens.size());
    token->print();
    printf("\n");
    ++i;
  }
  printf("\n");
}

bool Tokens::eof() const{
  return static_cast<std::size_t>(bottom)==tokens.size();
}

Token* Tokens::current(){
  if(eof())return nullptr;
  return tokens[bottom];
}

void Tokens::forward(){
  uassert(!eof());
  ++bottom;
}

Tokens::Tokens(vector<Token*>ts) : tokens(std::move(ts)){
  for(auto* token:tokens)
    uassert(token!=nullptr);
  bottom=0;
}

int Tokens::save() const{
  return bottom;
}

void Tokens::restore(int x){
  uassert(x<=bottom&&x>=0,"internal stack error");
  bottom=x;
}


  
  
