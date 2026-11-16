#include "node.h"
EchoSquareSpec::EchoSquareSpec(SetBase*source,
			       SetBase*target,
			       Range*match,
			       Range*mismatch){
  sourceset=source;
  targetset=target;
  matchrange=match;
  mismatchrange=mismatch;
  if(!sourceset)sourceset=new AnyNode();
  if(!targetset)targetset=new AnyNode();
  if (!matchrange)matchrange=new Range(0,64);
  if(!mismatchrange)mismatchrange=new Range(0,64);
}

void EchoSquareSpec::start_new_search(Game*game){
  EchoSpec::start_new_search(game);
  uassert(insearch&&game==theGame);
  sourcemask=sourceset->getSquares(game);
  for(int sq=0;sq<64;++sq)
    sourceboard[sq]=MarkBoard::piece_at_square(sq,game);
}

//keep in sync with match_target(Transform*)
bool EchoSquareSpec::match_target(){
  uassert(insearch);
  int nmatches=0;
  int nmismatches=0;
  SquareMask targetmask=targetset->getSquares(theGame);
  SquareMask mask=sourcemask&targetmask;
  for(squareT square=0;square<64;++square)
    if(mask.member(square)){
      if(compareSourceTarget(square))
	++nmatches;
      else
	++nmismatches;
      if(nmatches>matchrange->max) return false;
      if(nmismatches>mismatchrange->max) return false;
    }
  if (!matchrange->valid(nmatches))return false;
  if(!mismatchrange->valid(nmismatches))return false;
  return true;
};

bool EchoSquareSpec::compareSourceTarget(squareT square){
  uassert(square_valid(square));
  pieceT sourcepiece=sourceboard[square];
  pieceT targetpiece=MarkBoard::piece_at_square(square,theGame);
  uassert(piece_valid(sourcepiece)&&piece_valid(targetpiece));
  return sourcepiece==targetpiece;
}

void EchoSquareSpec::print(){
  printf("<%s",thisclass());
    printf(" Match: ");
  matchrange->print();
  printf(" Mismatch: ");
  mismatchrange->print();
  if(sourceset){
    printf("\n");
    indent();
    tab();
    printf("sourceset: ");
    sourceset->print();
    unindent();
  }
  if(targetset){
    printf("\n");
    indent();
    tab();
    printf("targetset: ");
    targetset->print();
    unindent();
  }
}



