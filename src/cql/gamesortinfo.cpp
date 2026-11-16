#include "node.h"
#include "gamesortinfo.h"

GameSortInfo::GameSortInfo(string d, vector<SortValue> v){
  values=v;
  uassert(!d.empty(),"bad gamesortinfo constructor arg");
  data=d;
}

void GameSortInfo::print(){
  output(stdout);
}

void GameSortInfo::output(FILE* os)const{
  fprintf(os,"%s\n\n",data.data());
}

void GameSortInfo::output(FILE* os, const vector<GameSortInfo>& v){
  for (const auto gs : v)
    gs.output(os);
}

void GameSortInfo::sort(vector<GameSortInfo>& v){
  if(0){
    printf("\n\nGSI: got v presort of:\n");
    for(int i=0;i<v.size();++i){
      printf("sortinfo value %d is: \n",i);
      for(auto &w : v[i].values){
	printf("     ");
	w.print();
      }
      printf("\n");
    }
  }
  std::stable_sort(v.begin(), v.end());
  if(0){
    printf("\n\nGSI: got v postsort of:\n");
    output(stdout,v);
  }

}


bool operator<(const GameSortInfo& a, const GameSortInfo& b){
  uassert(!a.data.empty()&&!b.data.empty()&&a.values.size()==b.values.size(),"gamesortinfo < internal");
  int len=(int)(a.values.size());
  for (int i=0;i<len;i++)
    if(b.values[i]<a.values[i]) return true;
    else if (a.values[i]<b.values[i]) return false;
  return false;
}

       
