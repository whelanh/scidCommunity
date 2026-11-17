/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
#include <string>
class GameSortInfo{
 public:
  std::string data;
  int gamenumber{0};
  vector<SortValue> values;
  const char* thisclass(){return "GameSortInfo";}
  GameSortInfo(std::string d, vector<SortValue> values);
  void print() const;
  static void sort(vector<GameSortInfo>&);
  void output(FILE* ostream) const;
  static void output(FILE* ostream,const vector<GameSortInfo>&);
};

bool operator< (const GameSortInfo& a, const GameSortInfo& b);

