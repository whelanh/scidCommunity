#pragma once
class SortValue{
 public:
  bool isMax()const{return theIsMax;}
  bool isMin()const{return !theIsMax;}
  NumValue getValue()const{return theValue;}
  void print();
  SortValue(NumValue v,bool ismax);
 private:
  bool theIsMax{false};
  NumValue theValue{0};
  char*thisclass(){return "SortValue";}
};

bool operator< (const SortValue& a, const SortValue& b);

  
  
