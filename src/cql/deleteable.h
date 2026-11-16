#pragma once
#include <stdlib.h>
#include<set>
using std::set;

/*
Abstract base class Deleteable. Keeps a list of all its instances and deletes them
when deleteableCleanup() is called. To use, make a class you want to make Deleteable inherit (directly or indirectly) from
Deleteable, e.g.
class A : public Deleteable...{...}
class B: public A{...}
class C: public B{...}

No instance of class A or a subclass of A can be deleted by the user or on the stack. Thus no such object can be allocated on the stack. All references to such objects are stale after deleteableCleanup() is called. Here, A, B and C are all Deleteable.

For safety there should be no class E with parents F and G both of which are Deleteable.
*/



class Deleteable{
 public:
  Deleteable();
  virtual ~Deleteable();
  static void deleteableCleanup();

 private:
  static void deleteableInitialize();
  static set<Deleteable*>*deleteableConstructed;
  static bool deleteableCleaningUp;
  static size_t deleteableNDeleted;
};
