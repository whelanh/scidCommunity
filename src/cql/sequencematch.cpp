#include "node.h"
#include "tokenstream.h"
SequenceBase*Tokens::match_sequencenode(){
  bool isfuture{false};
  bool is2{false};
  bool nestban{false};
  if (match_keyword("next")){
    isfuture=true;
    is2=false;
  }
  else if (match_keyword("previous")){
    isfuture=false;
    is2=false;
  }
  else if (match_keyword("next2")){
    isfuture=true;
    is2=true;
  }
  else if (match_keyword("previous2")){
    isfuture=false;
    is2=true;
  }
  else return NULL;
  Range*range=match_range();
  if (match_keyword("nestban"))
    nestban=true;
  if (nestban&&!isfuture)
    show_error("the 'nestban' keyword can only be used with 'next'");
  VectorConstituent*argsv=match_vectorconstituent();
  if(!argsv)
    show_error("invalid or missing argument list in next/previous");
  vector<SeqConstituent*>ps=argsv->constituents;
  SequenceBase*ret=NULL;
  if(isfuture) ret = new FutureNode(ps,range,is2,nestban);
  else ret = new PastNode(ps,range,is2,nestban);
  ret->setOffsets();
  return ret;
}

vector<SeqConstituent*> Tokens::match_some_seqconstituents(){
  vector<SeqConstituent*>v;
  while(true){
    SeqConstituent*c=match_seqconstituent();
    if(!c)break;
    v.push_back(c);
  }
  return v;
}

SeqConstituent* Tokens::match_seqconstituent(){
  SeqConstituent*current=NULL;
  if(!current)current=match_vectorconstituent();
  if(!current)current=match_holderconstituent();
  if(!current) return NULL;
  return match_seqsuffix(current);
}

SeqConstituent* Tokens::match_seqsuffix(SeqConstituent*c){
  uassert(c,"stms");
  SeqConstituent*current=c;
  while(true){
    if(match_star())
      current=new StarConstituent(current);
    else if(match_plus())
      current=new PlusConstituent(current);
    else if (match_questionmark())
      current=new OptionalConstituent(current);
    else {
      Range*range=match_repeat_range();
      if(!range) break;
      current=new RepeatConstituent(current,range->min,range->max);
    }
  }
  return current;
}
  
//This expects either a non-lparen start OR a valid paren contained nonempty list of seqconstituent
VectorConstituent* Tokens::match_vectorconstituent(){
  vector<SeqConstituent*>args;
  if(!match_lparen())return NULL;
  args=match_some_seqconstituents();
  if(!match_rparen())
    show_error("malformed expression inside next/previous: expected ')'");
  if(args.empty())
    show_error("unexpected null length sequence in next/previous");
  return new VectorConstituent(args);
}

HolderConstituent* Tokens::match_holderconstituent(){
  Node*n=match_basicnode();
  if(!n)return NULL;
  MFilter*filter=dynamic_cast<MFilter*>(n);
  if(!filter)
    show_error("Invalid and unexpected entry in next/previous");
  return new HolderConstituent(filter);
}

Range* Tokens::match_repeat_range(){
  int x=save();
  if (!match_lbrace()){
    restore(x);
    return NULL;}
  Range*range=match_range();
  if(!range){
    restore(x);
    return NULL;}
  if(!match_rbrace()){
    restore(x);
    return NULL;
  }
  if(range->min<0||range->max<range->min)
    show_error("Invalid range to repeat expression: min must be nonnegative and smaller than max");
  return range;
}
  
