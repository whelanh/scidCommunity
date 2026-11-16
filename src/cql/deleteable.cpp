#include "node.h"
set<Deleteable*>*Deleteable::deleteableConstructed;
bool Deleteable::deleteableCleaningUp=false;
size_t Deleteable::deleteableNDeleted=0;

Deleteable::Deleteable(){
  deleteableInitialize();
  uassert(!deleteableCleaningUp,"Deletable: constructing an object during the cleanup phase");
  uassert(deleteableConstructed,"deleteable: internal: construct");
  uassert(deleteableConstructed->count(this)==0,"Deleteable: attempted construction of already constructed object");
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
  size_t ninstances=deleteableConstructed->size();
  for (auto d : *deleteableConstructed){
    uassert(d!=NULL,"deleteableCleanup: unexpected null instance");
    delete d;
  }
  uassert(deleteableNDeleted==ninstances,"deleteableCleanup: ninstances mismatch");
  if(1)printf("deleteableCleanup: deleted %d instances\n",(int)ninstances);
  delete deleteableConstructed;
  deleteableConstructed=NULL;
  deleteableCleaningUp=false;
  deleteableNDeleted=0;
}

void Deleteable::deleteableInitialize(){
  if (!deleteableConstructed)
    deleteableConstructed=new set<Deleteable*>;
}
