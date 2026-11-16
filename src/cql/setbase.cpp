#include "node.h"
bool SetBase::match_position(Game*game){
  return getSquares(game).nonempty();
}

// SquareMask SetBase::getSquares(Game*game){
//   SquareMask mask;
//   for(squareT square=0;square<64;++square)
//     if (match_square(square,game))
//       mask.insert(square);
//   return mask;
// }
