/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"

#include <atomic>

void cql_initialize(){
  // Process-wide setup, done exactly once. The exchange keeps the check
  // race-free for the parallel search: a worker calling CqlReset() must not
  // read or write this while another one does. The first call is the main
  // thread's parse, before any worker exists, so stdout is set up there.
  static std::atomic<bool> first_call{true};
  if(first_call.exchange(false, std::memory_order_relaxed)){
    uassert(sizeof(Mask)==8,"Expecting sizeof of datatype 'Mask' to be 8");
    setbuf(stdout,nullptr);
    //scid_Init(); // remove this at some future point. 
  }
  cqlglobals_initialize();
  MarkBoard::restart();
  Deleteable::deleteableCleanup(); //Not deleteableInitalize!
}
