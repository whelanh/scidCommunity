#include "node.h"
PowerDifferenceNode::PowerDifferenceNode(SetBase*s1,SetBase*s2,Range*r){
  uassert(s1&&s2&&r);
  power1=new PowerNode(s1,new Range(0,1000));
  power2=new PowerNode(s2,new Range(0,1000));
  range=r;
}

void PowerDifferenceNode::print(){
  printf("\n");tab();
  printf("<%s Range: ",thisclass());
  range->print();
  indent();
  printf("\n");tab();
  printf("Power: ");
  power1->print();
  printf("\n");tab();
  printf("Power: ");
  power2->print();
  printf(" >");
}

bool PowerDifferenceNode::match_count(Game*game,NumValue*value){
  if (match_position(game)){
    *value=(NumValue)powerdifference;
    return true;
  }
  return false;
}
    
  
bool PowerDifferenceNode::match_position(Game*game){
  power1->match_position(game);
  power2->match_position(game);
  powerdifference=power1->power-power2->power;
  return range->valid(powerdifference);
}

