/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
std::set<Deleteable*>*Deleteable::deleteableConstructed;
bool Deleteable::deleteableCleaningUp=false;
std::size_t Deleteable::deleteableNDeleted=0;

Deleteable::Deleteable(){
  deleteableInitialize();
  uassert(!deleteableCleaningUp,"Deletable: constructing an object during the cleanup phase");
  uassert(deleteableConstructed,"deleteable: internal: construct");
  uassert(deleteableConstructed->count(this)==0,"Deleteable: attempted construction of already constructed object");
  deleteableConstructed->insert(this);
}

// A clone (clone.cpp's `new X(*this)`) copy-constructs the node, so it never
// runs the default constructor above and would otherwise never be registered
// for cleanup. Register the copy too, so CqlReset() frees the clones.
Deleteable::Deleteable(const Deleteable&){
  deleteableInitialize();
  uassert(!deleteableCleaningUp,"Deletable: copy-constructing during the cleanup phase");
  uassert(deleteableConstructed,"deleteable: internal: copy construct");
  uassert(deleteableConstructed->count(this)==0,"Deleteable: attempted copy construction of already constructed object");
  deleteableConstructed->insert(this);
}

Deleteable::~Deleteable(){
  uassert(deleteableCleaningUp,"Deleteable: a deletion occurred outside of the allowed cleanup time");
  uassert(deleteableConstructed,"deleteable: internal: delete");
  uassert(deleteableConstructed->count(this)==1,"deleteable: deleting a non-constructed instance");
  ++deleteableNDeleted;
}

void Deleteable::deleteableCleanup(){
  uassert(!deleteableCleaningUp,"deleteableCleanup internal");
  uassert(deleteableNDeleted==0,"deleteableCleanup: unexpectedly seen deletion");
  deleteableCleaningUp=true;
  deleteableInitialize();
  const std::size_t ninstances=deleteableConstructed->size();
  for (auto d : *deleteableConstructed){
    uassert(d!=nullptr,"deleteableCleanup: unexpected null instance");
    delete d;
  }
  uassert(deleteableNDeleted==ninstances,"deleteableCleanup: ninstances mismatch");
  if(1)printf("deleteableCleanup: deleted %d instances\n",static_cast<int>(ninstances));
  delete deleteableConstructed;
  deleteableConstructed=nullptr;
  deleteableCleaningUp=false;
  deleteableNDeleted=0;
}

void Deleteable::deleteableInitialize(){
  if (!deleteableConstructed)
    deleteableConstructed=new std::set<Deleteable*>;
}
