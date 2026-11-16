#pragma once
class VariationFlags{
 public:
  bool theisset{false};
  bool thesearchvariations{false};
  bool getSearchVariations();
  bool isVariationsSet(){return theisset;}
  void setSearchVariations(bool arg);
  void printVariationFlags();
  virtual void setVariations(bool arg);
};

