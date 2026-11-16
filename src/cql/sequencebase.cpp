#include "node.h"
void SequenceBase::print(){
  printf("<%s at %p: %d constituents: ",thisclass(),this,nconstituents());
  printVariationFlags();
  if(isSilent())printf("silent ");
  if (isSkip()) getSkipConstituent()->print();
  printf("nestBan: %d",nestBan);
  for(int i=0;i<nconstituents();++i){
    printf("\n");
    indent();
    tab();
    printf("<%d of %d: ",i,nconstituents());
    getConstituent(i)->print();
    unindent();
  }
  printf(" %s> ",thisclass());
}

vnode SequenceBase::children(){
  vnode v;
  for (SeqConstituent* c:constituents)
    for (Node* child:c->children()){
      uassert(c);
      uassert(myindex(v,child)<0,"unexpected duplicate child");
      v.push_back(child);
    }
  // Do NOT include the skipholders here because they will transform under flipcolor, which we do NOT want
  return v;
}
  
SequenceBase::SequenceBase(vector<SeqConstituent*>cs,Range*r,bool isskip,bool nestbanparam){
  range=r;
  constituents=cs;
  nestBan=nestbanparam;
  for(auto c:constituents)uassert(c,"sbsb");
  if (isskip) {
    theWhiteHolder=new HolderConstituent(new ColorNode(WHITE));
    theBlackHolder=new HolderConstituent(new ColorNode(BLACK));
  }
}

bool SequenceBase::valid_constituent (int offset)const{
  uassert(offset>=0,"vcsb");
  return offset<nconstituents();
}

SeqConstituent* SequenceBase::getConstituent (int offset)const{
  uassert(valid_constituent(offset),"internal in getConstituent");
  return constituents.at(offset);
};

int SequenceBase::nconstituents()const{
  return (int)(constituents.size());
}

void SequenceBase::setOffsets(){
  for (int i=0;i<constituents.size();++i)
    constituents[i]->setOffsets(i);
}


bool SequenceBase::match_position(Game*g){
  uassert(game==NULL&&g,"fnmpg");
  if (nestBan&&nestSeenPosition(g))
    return false;
  game=g;
  if(isSkip()) initializeSkip();
  auto me=MarkBoard::identity(game);
  count=-1;
  uassert(isVariationsSet(),"variations not yet set");
  SeqStack stack=constituents;
  std::reverse(stack.begin(),stack.end());
  size_t len=stack.size();
  SeqRet ret= compute(stack);
  uassert(len=stack.size(),"fnmp mismatch");
  uassert(MarkBoard::identity(game)==me,"fnmp me");
  if(ret.isFalse()){exitMatch();return false;}
  count=ret.getLength();
  if (isSkip()) count=(count+1)/2;
  if(range&&!range->valid(count)) {exitMatch();return false;}
  notate(ret);
  exitMatch();
  return true;
}

void SequenceBase::exitMatch(){
  uassert(game,"sbem g");
  game=NULL;
  if(isSkip()){
    uassert(theSkipColor!=NOCOLOR,"sbem s");
    theSkipColor=NOCOLOR;
  }
}

SeqRet SequenceBase::compute(SeqStack &stack){
  if(stack.empty())return SeqRet(true);
  if(isSkip()&&skipCurrentPosition())
    return computeSkip(stack);
  size_t startlen=stack.size();
  SeqConstituent*top=stack.back();
  stack.pop_back();
  StarConstituent*star=dynamic_cast<StarConstituent*>(top);
  RepeatConstituent*repeat=dynamic_cast<RepeatConstituent*>(top);
  HolderConstituent*holder=dynamic_cast<HolderConstituent*>(top);
  VectorConstituent*vc=dynamic_cast<VectorConstituent*>(top);
  PlusConstituent*plus=dynamic_cast<PlusConstituent*>(top);
  OptionalConstituent*optional=dynamic_cast<OptionalConstituent*>(top);
  SeqRet ret(false);
  if(star)
    ret=compute(star,stack);
  else if (repeat)
    ret=compute(repeat,stack);
  else if(holder)
    ret=compute(holder,stack);
  else if (vc)
    ret=compute(vc,stack);
  else if (plus)
    ret=compute(plus,stack);
  else if (optional)
    ret=compute(optional,stack);
  else
    uassert(false,"bad top fnc");
  stack.push_back(top);
  uassert(stack.size()==startlen,"bad stacksize fncmain");
  return ret;
}

SeqRet SequenceBase::compute(RepeatConstituent*repeat,SeqStack&stack){
  int nrepetitions=0;
  SeqConstituent*c = repeat->constituent;
  size_t stacklen=stack.size();
  SeqRet best=SeqRet(false);
  for (nrepetitions=repeat->min;
       nrepetitions<=repeat->max;
       ++nrepetitions){
    uassert(stack.size()==stacklen);
    for (int i=0;i<nrepetitions;++i)
      stack.push_back(c);
    uassert(stack.size()==stacklen+nrepetitions);
    SeqRet ret=compute(stack);
    uassert(stack.size()==stacklen+nrepetitions);
    best=std::max(ret,best);
    for (int i=0;i<nrepetitions;++i)
      stack.pop_back();
    uassert(stack.size()==stacklen);
  }
  uassert(stack.size()==stacklen);
  return best;
}

    
SeqRet SequenceBase::compute(StarConstituent*star,SeqStack&stack){
  SeqRet unused=compute(stack);
  SeqConstituent*c=star->constituent;
  size_t stacklen=stack.size();
  stack.push_back(star);
  stack.push_back(c);
  SeqRet used=compute(stack);
  uassert(stack.size()==stacklen+2);
  stack.pop_back();
  stack.pop_back();
  uassert(stack.size()==stacklen);
  return std::max(used,unused);
}

SeqRet SequenceBase::compute(PlusConstituent*plus,SeqStack&stack){
  StarConstituent*star=plus->getStarConstituent();
  SeqConstituent*c=star->constituent;
  size_t stacklen=stack.size();
  stack.push_back(star);
  stack.push_back(c);
  SeqRet ret=compute(stack);
  uassert(stack.size()==stacklen+2);
  stack.pop_back();
  stack.pop_back();
  uassert(stack.size()==stacklen);
  return ret;
}

SeqRet SequenceBase::compute(OptionalConstituent*optional,SeqStack&stack){
  SeqConstituent*c=optional->constituent;
  size_t stacklen=stack.size();
  SeqRet unused=compute(stack);
  uassert(stacklen==stack.size(),"fncoclen");
  stack.push_back(c);
  SeqRet used=compute(stack);
  uassert(stack.size()==stacklen+1);
  stack.pop_back();
  uassert(stack.size()==stacklen);
  return std::max(used,unused);
}

SeqRet SequenceBase::compute(VectorConstituent*vc,SeqStack&stack){
  size_t stacklen=stack.size();
  uassert(vc,"fncvc");
  vector<SeqConstituent*>v=vc->constituents;
  int nconstituents=(int)(v.size());
  uassert(nconstituents,"fncvc");
  for(int i=nconstituents-1;i>=0;--i)
    stack.push_back(v.at(i));
  uassert(stack.size()==stacklen+nconstituents,"fnclen");
  SeqRet ret=compute(stack);
  uassert(stack.size()==stacklen+nconstituents,"fnclen");
  for(int i=0;i<nconstituents;++i)
    stack.pop_back();
  uassert(stack.size()==stacklen,"fnclen3");
  return ret;
}

SeqRet SequenceBase::computeNull(SeqStack& stack){
  size_t startsize=stack.size();
  if(stack.empty()) return SeqRet(true);
  SeqConstituent* top=stack.back();
  if (!top->matchesNull())
    return SeqRet(false);
  stack.pop_back();
  SeqRet ret=computeNull(stack);
  stack.push_back(top);
  uassert(stack.size()==startsize,"fncn size");
  return ret;
}

void SequenceBase::deepify(){
  clonevec(constituents); // VERY IMPORTANT!!!
  // The next two lines are essentially optional but included for consistency
  if(theWhiteHolder)theWhiteHolder=theWhiteHolder->clone();
  if(theBlackHolder)theBlackHolder=theBlackHolder->clone();
}
/********SKIP METHODS**************/

void SequenceBase::initializeSkip(){
  uassert(game,"sbis");
  colorT tomove=game->GetCurrentPos()->GetToMove();
  uassert(tomove==WHITE||tomove==BLACK,"sbist");
  if (tomove==WHITE)
    setSkipColor(BLACK);
  else if (tomove==BLACK)
    setSkipColor(WHITE);
}

SeqRet SequenceBase::computeSkip(SeqStack &stack){
  uassert(isSkip()&&skipCurrentPosition(),"computeSkip internal");
  HolderConstituent*skipconstituent=getSkipConstituent();
  return compute(skipconstituent,stack);
}


HolderConstituent*SequenceBase::getSkipConstituent()const{
  colorT c=getSkipColor();
  HolderConstituent* ret=NULL;
  switch(c){
  case WHITE:ret=theWhiteHolder;break;
  case BLACK:ret=theBlackHolder;break;
  default: uassert(false,"hcgsh: internal");
  }
  uassert(ret,"getskipholder: internal");
  return ret;
}

bool SequenceBase::isSkip()const{
  return theWhiteHolder!=NULL;
}

colorT SequenceBase::getSkipColor()const{
  uassert(isSkip(),"sbgsc");
  colorT ret=theSkipColor;
  uassert(ret==WHITE||ret==BLACK);
  return ret;
}

bool SequenceBase::skipColor(colorT c)const{
  uassert(isSkip()&&c==WHITE||c==BLACK,"sbsc");
  return getSkipColor()==c;
}

void SequenceBase::clearSkipColor(){
  uassert(isSkip(),"sbcsc");
  uassert(theSkipColor==WHITE||theSkipColor==BLACK,"sbcsc col");
  theSkipColor=NOCOLOR;
}

void SequenceBase::setSkipColor(colorT c){
  uassert(isSkip()&&(c==WHITE||c==BLACK),"sbssc");
  uassert(theSkipColor==NOCOLOR,"sbssc nc");
  theSkipColor=c;
}

bool SequenceBase::skipCurrentPosition()const{
  uassert(isSkip()&&game!=NULL);
  colorT tomove=game->GetCurrentPos()->GetToMove();
  uassert(tomove==WHITE||tomove==BLACK,"sbscp");
  return skipColor(tomove);
}


bool SequenceBase::match_count(Game*game, NumValue*value){
  if (match_position(game)){
    uassert (count>=0,"match_count");
    *value=(NumValue)(count);
    return true;
  }
  return false;
}
    
