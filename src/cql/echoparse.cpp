#include "node.h"
#include "tokenstream.h"
EchoNode* Tokens::match_echonode(){
  if(!match_keyword("relation")&&!match_keyword("echo")) return NULL;
  vector<Node*>filters=match_some_basicnodes();
  vector<EchoSpec*>specs=match_echospecs();
  if(specs.empty())
    show_error(
	       "Syntax error parsing 'relation'. Expected a relation parameter enclosed in parens, or an echotransform spec, following the specifications after the relation keyword\n");
  EchoNode*e=new EchoNode(filters,specs);
  if(0)
    {
      printf("\nmatch_echonode: filters:\n");
      for(auto f:filters){
	printf("filter: %p: \n",f);
	f->print();
      }
      printf("\nmatch_echonode: specs:\n");
      for(auto s:specs){
	printf("spec: %p: \n",s);
	s->print();
      }
      printf("\nmatch_echonode: got echonode of: \n");
      e->print();
    }
  return new EchoNode(filters,specs);
  
}

vector<EchoSpec*> Tokens::match_echospecs(){
  vector<EchoSpec*>specs;
  EchoSpec*spec=NULL;
  while(spec=match_echospec())
    specs.push_back(spec);
  return specs;
}


EchoSpec* Tokens::match_echospec(){
  if(match_echoemptyspec())
    show_error("Invalid empty 'relation' specification");
  EchoSpec*e=NULL;
  if(!e) e=match_echodescendant();
  if(!e) e=match_echosquarespec();
  if(!e) e=match_echolongestsubstringspec();
  if(!e) e=match_echomaxdistancespec();
  if(!e) e=match_echosumdistancespec();
  if(!e) e=match_echosourcedistancespec();
  if(!e) e=match_echotargetdistancespec();
  if(!e) e=match_echoancestor();
  if(!e) e=match_echotransformspec();
  if(!e) e=match_echosidetomovespec();
  return e;
}

bool Tokens::match_echoemptyspec(){
  int x=save();
  if(!match_lparen())return false;
  if(!match_rparen()){
    restore(x);
    return false;
  }
  return true;
}

EchoSquareSpec* Tokens::match_echosquarespec(){
  int x=save();
  if(!match_lparen())return NULL;
  SetBase*source=NULL;
  SetBase*target=NULL;
  Range*match=NULL;
  Range*mismatch=NULL;
  while(true)
    if(match_keyword("sourcesquares")){
      source=match_set();
      if(!source) show_error("missing set specifier after 'sourcesquares'");
      continue;
    }
    else if(match_keyword("targetsquares")){
      target=match_set();
      if(!target) show_error("missing set specifier after 'targetsquares'");
      continue;
    }
    else if(match_keyword("match")){
      match=match_range();
      if(!match) show_error("missing range following 'match' in relation");
      continue;
    }
    else if(match_keyword("mismatch")){
      mismatch=match_range();
      if(!mismatch) show_error("missing range following 'mismatch' in relation");
      continue;
    }
    else break;
  if(source||target||match||mismatch){
    if(!match_rparen())
      show_error("Expected ')' or relation specifier consituent: illegal relation specifier");
    return new EchoSquareSpec(source,target,match,mismatch);
  }
  restore(x);
  return NULL;
}

EchoDistanceSpec* Tokens::match_echoancestor(){
  int x=save();
  if(!match_lparen()) return NULL;
  if (!match_keyword("ancestor")) {
    restore(x);
    return NULL;
  }
  if (!match_rparen())
    show_error("expecting ')' following 'ancestor' keyword in relation specification");
  return new EchoTargetDistanceSpec(new Range(0,0),NULL);
}

EchoDistanceSpec* Tokens::match_echodescendant(){
  int x=save();
  if(!match_lparen()) return NULL;
  if (!match_keyword("descendant")) {
    restore(x);
    return NULL;
  }
  if (!match_rparen())
    show_error("expecting ')' following 'descendant' keyword in relation specification");
  return new EchoSourceDistanceSpec(new Range(0,0),NULL);
}

EchoMaxDistanceSpec* Tokens::match_echomaxdistancespec(){
  int x=save();
  if(!match_lparen()) return NULL;
  NumericVariable*var=match_sortheader();
  if(!match_keyword("lcamax")){
    restore(x);
    return NULL;
  }
  Range*range=match_range();
  if(!range)
    show_error("missing range in range specifier following 'lcamax'");
  if(!match_rparen())
    show_error("illegal specifier constituent, expecting ')'");
  return new EchoMaxDistanceSpec(range,var);
}

EchoSumDistanceSpec* Tokens::match_echosumdistancespec(){
  int x=save();
  if(!match_lparen()) return NULL;
  NumericVariable*var=match_sortheader();
  if(!match_keyword("lcasum")){
    restore(x);
    return NULL;
  }
  Range*range=match_range();
  if(!range)
    show_error("missing range in range specifier following 'lcasum'");
  if(!match_rparen())
    show_error("illegal specifier constituent, expecting ')'");
  return new EchoSumDistanceSpec(range,var);
}

EchoSourceDistanceSpec* Tokens::match_echosourcedistancespec(){
  int x=save();
  if(!match_lparen()) return NULL;
  NumericVariable*var=match_sortheader();
  if(!match_keyword("lcasource")){
    restore(x);
    return NULL;
  }
  Range*range=match_range();
  if(!range)
    show_error("missing range in range specifier following 'lcasource'");
  if(!match_rparen())
    show_error("illegal specifier constituent, expecting ')'");
  return new EchoSourceDistanceSpec(range,var);
}

EchoTargetDistanceSpec* Tokens::match_echotargetdistancespec(){
  int x=save();
  if(!match_lparen()) return NULL;
  NumericVariable*var=match_sortheader();
  if(!match_keyword("lcatarget")){
    restore(x);
    return NULL;
  }
  Range*range=match_range();
  if(!range)
    show_error("missing range in range specifier following 'lcatarget'");
  if(!match_rparen())
    show_error("illegal specifier constituent, expecting ')'");
  return new EchoTargetDistanceSpec(range,var);
}

EchoLongestSubstringSpec* Tokens::match_echolongestsubstringspec(){
  int x=save();
  if(!match_lparen())return NULL;
  NumericVariable*var=match_sortheader();
  if(!match_keyword("lcasubstring")){
    restore(x);
    return NULL;
  }
  Range*range=match_range();
  if(!range)
    show_error("Expected range following 'lcasubstring'");
  if(!match_rparen())
    show_error("expected ')' following range after 'lcasubstring'");
  return new EchoLongestSubstringSpec(range,var);
}

EchoSpec* Tokens::match_echotransformspec(){
  vector<Transform*> transforms=match_echotransforms();
  if(transforms.empty())return NULL;
  EchoSpec*spec=match_echospec();
  if(!spec)
    show_error("echo transforms  must be followed by a specification: expecting '(' for an echo spec");
  return new EchoTransformSpec(transforms,spec);
}

vector<Transform*>Tokens::match_echotransforms(){
  if (match_keyword("echoshiftvertical"))
    return ShiftTransform::shiftVertical();
  else if (match_keyword("echoshifthorizontal"))
    return ShiftTransform::shiftHorizontal();
  else if (match_keyword("echoshift"))
    return ShiftTransform::allShift();
  else if (match_keyword("echoflipvertical"))
    return vector<Transform*>{DihedralTransform::flipVertical()};
  else if (match_keyword("echofliphorizontal"))
    return vector<Transform*>{DihedralTransform::flipHorizontal()};
  else if (match_keyword("echorotate90"))
    return DihedralTransform::rotations();
  else if (match_keyword("echorotate45"))
    return PiOver4Transform::rotations();
  else if (match_keyword("echoflip") || match_keyword("echoflipdihedral")||match_keyword("echodihedral"))
    return DihedralTransform::allDihedral();
  else return vector<Transform*>{};
}  

EchoSideToMoveSpec* Tokens::match_echosidetomovespec(){
  int x=save();
  if(!match_lparen())return NULL;
  if(!match_keyword("tomove")) {restore(x);return NULL;}
  bool same=false;
  if(match_keyword("match")) same=true;
  else if (match_keyword("mismatch")) same=false;
  else show_error("'tomove' in relation must be followed by either 'match' or 'mismatch'");
  if(!match_rparen())
    show_error ("missing ')' after '(tomove match' or '(tomove mismatch'");
  return new EchoSideToMoveSpec(same);
}
