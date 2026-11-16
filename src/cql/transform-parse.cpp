#include "node.h"
#include "tokenstream.h"
TransformNode* Tokens::match_shifttransform(){
  KeywordToken *k=match_keyword("shift");
  if(!k)k=match_keyword("shiftvertical");
  if(!k)k=match_keyword("shifthorizontal");
  if(!k) return NULL;
  Range*range=match_range();
  Node*node=match_basicnode();
  if(!node)
    show_error("After a shift keyword expecting a filter specification");
  vector<Transform*>transforms;
  transforms.push_back(new IdentityTransform());
  if(k->eq("shift"))
    for(auto t:ShiftTransform::allShift())
      transforms.push_back(t);
  else if (k->eq("shifthorizontal"))
    for(auto t:ShiftTransform::shiftHorizontal())
      transforms.push_back(t);
  else if (k->eq("shiftvertical"))
    for(auto t:ShiftTransform::shiftVertical())
      transforms.push_back(t);
  else uassert(false, "internal shift");
  return TransformNode::create(transforms,node,range);
}
  
    
TransformNode* Tokens::match_fliptransform(){
  KeywordToken *k=NULL;
  if(!k) k=match_keyword("flip");
  if(!k) k=match_keyword("flipvertical");
  if(!k) k=match_keyword("fliphorizontal");
  if(!k) k=match_keyword("flipcolor");
  if(!k) k=match_keyword("rotate90");
  if(!k) k=match_keyword("rotate45");
  if(!k) k= match_keyword("flipdihedral");
  if(!k) k=match_keyword("dihedral");
  if(!k) return NULL;
  Range*range=match_range();
  Node*node=match_basicnode();
  if(!node)
    show_error("After a flip keyword, expecting a filter specification");
  vector<Transform*> transforms;
  transforms.push_back(new IdentityTransform());
  if(k->eq("flip")||k->eq("flipdihedral")||k->eq("dihedral"))
    for(auto t: DihedralTransform::allDihedral())
      transforms.push_back(t);
  else if (k->eq("rotate90"))
    for(auto t:DihedralTransform::rotations())
      transforms.push_back(t);
  else if (k->eq("rotate45"))
    for(auto t:PiOver4Transform::rotations())
      transforms.push_back(t);
  else if(k->eq("flipvertical"))
    transforms.push_back(DihedralTransform::flipVertical());
  else if(k->eq("fliphorizontal"))
    transforms.push_back(DihedralTransform::flipHorizontal());
  else if(k->eq("flipcolor"))
    transforms.push_back(ColorTransform::flipColorTransform());
  else
    uassert(false,"internal fliptransform");
  return TransformNode::create(transforms,node,range);
}
