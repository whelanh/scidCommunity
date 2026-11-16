#pragma once
class CommentFlags{
 public:
  bool thesilent{false};
  bool isSilent(){return thesilent;}
  void setSilent(bool b){thesilent=b;}
  void makeSilent(){setSilent(true);}
};
