#pragma once
template <class T> void myinsert(vector<T>&v, const T& t){
  for(auto e: v)
    if (e==t) return;
  v.push_back(t);
}

template <class T> int myindex(const vector<T>&v, const T& t){
  for(int i=0;i<v.size();++i)
    if(v[i]==t)return i;
  return -1;
}
