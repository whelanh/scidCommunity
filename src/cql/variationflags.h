/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
class VariationFlags{
 public:
  bool theisset{false};
  bool thesearchvariations{false};
  bool getSearchVariations() const;
  bool isVariationsSet() const{return theisset;}
  void setSearchVariations(bool arg);
  void printVariationFlags() const;
  virtual void setVariations(bool arg);
};

