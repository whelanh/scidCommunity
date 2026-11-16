/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#include "node.h"
SiteNode::SiteNode(const char* n):name{n}{
  uassert(n&&name,"sitenode internal");
}

bool SiteNode::match_game(Game*game){
  const char* site=game->GetSiteStr();
  if(site&&strstr(site,name))
    return true;
  return false;
}
  
void SiteNode::print(){
  printf("<%s %s>",thisclass(),name);
}
  
