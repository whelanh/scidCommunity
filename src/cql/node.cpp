/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
int Node::counter=0;     
int Node::ndisabled=0;

bool Node::isSet(){
  SetBase* set=dynamic_cast<SetBase*>(this);
  return set && set->isSet();
}

bool Node::isCountable(){
  Countable* countable=dynamic_cast<Countable*>(this);
  return countable&&countable->isCountable();
}

void Node::cloneverify(Node*s,Node*t){
  uassert(s,"cloneverify s");
  uassert(t,"cloneverify t");
  vnode schildren=s->children();
  vnode tchildren=t->children();
  uassert(schildren.size()==tchildren.size(),"bad child count");
  for(std::size_t i=0;i<schildren.size();++i){
    Node*schild=schildren[i];
    Node*tchild=tchildren[i];
    uassert(schild&&tchild,"internal cloneverify");
    uassert(strcmp(schild->thisclass(),tchild->thisclass())==0,"bad classes");
    if(schild==tchild){
      printf("Unexpected identical children after cloning. \n");
      printf("Source child: \n");
      schild->print();
      printf("\nTarget child: \n");
      tchild->print();
      printf("\n");
      uassert(false,"cloneverify child identical");
    }
    cloneverify(schild,tchild);
  }
}

	     
  
  
void KeywordNode::print(){
  printf("%s: %s>",thisclass(),value);
}

void PgnNode::print(){
  printf("<%s: %s>",thisclass(),value);
}

void OutputNode::print(){
  printf("<%s: %s>",thisclass(),value);
}

KeywordNode::KeywordNode(const char* v){
  uassert(v&&strlen(v)>=1);
  uassert(KeywordToken::isReserved(v),"KeywordNode: internal");
  value=v;
}

bool KeywordNode::eq(const char*v){
  if(!v) return false;
  return strcmp(value,v)==0;
}

Range::Range(int mi){
  min=mi;
  max=mi;
}

Range::Range(int mi,int ma){
  uassert(mi<=ma,"Invalid range: max smaller than min");
  min=mi;
  max=ma;
}

void Range::print(){
  printf("<%s %d %d>",thisclass(),min,max);
}

void ResultNode::print(){
  printf("<%s %s>",thisclass(),result_to_string(result));
}


vnode Node::descendants(){
  vnode start{this};
  alldescendants(&start);
  return start;
}

void Node::alldescendants(vnode*v){
  vnode c=children();
  for(auto np : c)
    if(np){
      v->push_back(np);
      np->alldescendants(v);
    }
}
	
GameNumberNode::GameNumberNode(Range*r){
  if(!r) 
    r=new Range(1,100000000);
  range=r;
}

void GameNumberNode::print(){
  uassert(range);
  printf("<%s: ",thisclass());
  range->print();
  printf(">");
}

ResultNode::ResultNode(const char*v){
  uassert(v,"bad result node");
  if(!strcmp(v,"1-0"))
    result=RESULT_White;
  else if(!strcmp(v,"0-1"))
    result=RESULT_Black;
  else if(!strcmp(v,"1/2-1/2"))
    result=RESULT_Draw;
  else
    uassert(false,"Invalid result string",v);
}

bool GameNumberNode::match_game(Game* /*game*/){
  return range->valid(CqlGameNumber());
}

bool ResultNode::match_game(Game*game){
  uassert(game);
  if(result!=RESULT_None&&
     result!=game->GetResult())
    return false;
  return true;
}

vnode RayNode::children(){
  return vnode {designators.begin(),designators.end()};
}

void Node::disable(){
  uassert(!disabled,"internal delete");
  disabled=true;
  ++ndisabled;
}

ColorNode::ColorNode(colorT c){
  uassert(c==BLACK||c==WHITE);
  color=c;
}

void ColorNode::print(){
  if(color==WHITE)
    printf(" :wtm");
  else if (color==BLACK)
    printf(" :btm");
  else
    uassert(false,"internal color");
}

void Node::makeSilentRecursively(){
  CommentFlags* cf=dynamic_cast<CommentFlags*>(this);
  if(cf)cf->makeSilent();
  for (Node*child:children()){
    uassert(child,"null child expand silent");
    child->makeSilentRecursively();
  }
}

//I have no idea why this is here or what this does
void Node::makeNotNodeSilentRecursively(){
  if(dynamic_cast<NotNode*>(this))
    makeSilentRecursively();
  for(Node*child:children()){
        uassert(child,"null child notsilentrecursive");
	child->makeNotNodeSilentRecursively();
  }
}

void Node::addSortFields(vector<NumericVariable*>&fields){
  AssignNode*a=dynamic_cast<AssignNode*>(this);
  if(a){
    NumericVariable* v=a->variable;
    uassert(v,"unexpected null variable in an assignnode");
    myinsert(fields,v);
  }
  EchoLcaSpec*spec=dynamic_cast<EchoLcaSpec*>(this);
  if(spec){
    NumericVariable*v=spec->assignee;
    if(v) myinsert(fields,v);
  }
  for(Node* child:children())
    child->addSortFields(fields);
}
