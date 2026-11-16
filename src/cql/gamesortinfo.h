#pragma once
#include<string>
using std::string;
class GameSortInfo{
 public:
  string data;
  int gamenumber{0};
  vector<SortValue> values;
  const char* thisclass(){return "GameSortInfo";}
  GameSortInfo(string d, vector<SortValue> values);
  void print();
  static void sort(vector<GameSortInfo>&);
  void output(FILE* ostream) const;
  static void output(FILE* ostream,const vector<GameSortInfo>&);
};

bool operator< (const GameSortInfo& a, const GameSortInfo& b);

