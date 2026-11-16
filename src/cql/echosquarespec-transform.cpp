#include "node.h"
//This should be kept in sync with match_target()
bool EchoSquareSpec::match_target(Transform*transform){
  uassert(insearch);
  int nmatches=0;
  int nmismatches=0;
  const pieceT*targetboard=theGame->GetCurrentPos()->GetBoard();
  SquareMask targetmask=targetset->getSquares(theGame);
  SquareMask mask=sourcemask&targetmask;
  SquareMask targettested;
  pieceT targetpiece=EMPTY;
  for(squareT square=0;square<64;++square)
    if(mask.member(square)){
      squareT transformedsquare=transform->transform(square);
      if(square_valid(transformedsquare)){
	targettested.insert(transformedsquare);
	targetpiece=targetboard[transformedsquare];
      }
      else
	targetpiece=EMPTY;
      if(sourceboard[square]==targetpiece)
	++nmatches;
      else
	++nmismatches;
      if(nmatches>matchrange->max) return false;
      if(nmismatches>mismatchrange->max) return false;
    }
  SquareMask remainder= mask & ~targettested;
  for(squareT targetsquare=0;targetsquare<64;++targetsquare)
    if(remainder.member(targetsquare)){
      if(targetboard[targetsquare]!=EMPTY)
	nmismatches=std::min(nmismatches+1,64);
      else
	nmatches=std::min(nmatches+1,64);
      if (nmatches>matchrange->max||nmismatches>mismatchrange->max) return false;
    }
  if (!matchrange->valid(nmatches))return false;
  if(!mismatchrange->valid(nmismatches))return false;
  return true;
};

// bool EchoSquareSpec::compareSourceTargetTransformed(squareT square,squareT transformedsquare){
//   uassert(square_valid(square));
//   pieceT sourcepiece=sourceboard[square];
//   pieceT targetpiece;
  
// =
//     square_valid(transformedsquare) ? 
//      MarkBoard::piece_at_square(transformedsquare,theGame)
//     : EMPTY;
  
//   //  uassert(piece_valid(sourcepiece)&&piece_valid(targetpiece));
//   return sourcepiece==targetpiece;
// }
