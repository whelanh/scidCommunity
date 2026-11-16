#pragma once
class SeqRet{
 public:
  bool success{false};
  vector<moveT*>ids;
  vector<int>offsets;
  bool isTrue()const{return success;}
  bool isFalse() const{return !success;}
  void addParent(Game*game,int offset);
  SeqRet(bool);
  SeqRet(Game*game, int offset);
  void print();
  const char* thisclass(){return "SeqRet";}
  moveT* getId(int index)const;
  int getOffset(int index)const;
  int getLength()const;
 private:
  int getTrueIndex(int i)const;
};
bool operator<(const SeqRet&,const SeqRet&);
