/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
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
