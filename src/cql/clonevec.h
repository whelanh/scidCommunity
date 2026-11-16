#pragma once
template <class T> void clonevec(vector<T*> &v){
  for(int i=0;i<v.size();++i){
    uassert(v[i],"Clonevec: unexpected null argument");
    v[i]=v[i]->clone();
  }
};
    
