#include "node.h"
AssignNode::AssignNode(NumericVariable * var, Node * filter){
  variable=var;
  uassert(var&&filter);
  node=dynamic_cast<Countable*>(filter);
  uassert(node,"unexpected non-countable argument to assignnode");
  uassert(node->isCountable(),"argument to assign node is not an actual countable node");
}

bool AssignNode::match_position(Game*game){
  NumValue value{-1000};
  if(node->match_count(game,&value)){
    variable->bindNumeric(value);
    return true;
  }
  return false;
}

void AssignNode::print(){
  printf("<%s variable: ",thisclass());
  variable->print();
  printf("\n");
  indent();tab();
  printf("Node: ");
  node->print();
  unindent();
  printf(" %s>",thisclass());
}

vnode AssignNode::children(){
  Node* n=dynamic_cast<Node*>(node);
  uassert(n);
  return vnode{n};
}
