#include "node.h"
Node* Node::transform(Transform* t){
  uassert(t);
  Node* newfilter=clone();
  newfilter->transform_in_place(t);
  return newfilter;
}

void Node::transform_in_place(Transform* t){
  for (Node* child : children())
    child->transform_in_place(t);
  transform_members(t);
}
  
void Node::expand(){
  for(Node* child:children()){
    uassert(child,"null child expand");
    child->expand();
  }
}

