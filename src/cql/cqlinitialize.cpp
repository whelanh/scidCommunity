/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
void cql_initialize(){
  static bool first_call=true; //first time called
  if(first_call){
    uassert(sizeof(Mask)==8,"Expecting sizeof of datatype 'Mask' to be 8");
    setbuf(stdout,NULL);
    //scid_Init(); // remove this at some future point. 
  }
  cqlglobals_initialize();
  MarkBoard::restart();
  Deleteable::deleteableCleanup(); //Not deleteableInitalize!
  first_call=false;
}
