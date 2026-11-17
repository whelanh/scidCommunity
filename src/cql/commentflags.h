/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
class CommentFlags{
 public:
  bool thesilent{false};
  bool isSilent() const{return thesilent;}
  void setSilent(bool b){thesilent=b;}
  void makeSilent(){setSilent(true);}
};
