#include "node.h"
#include "tokenstream.h"

Node* Tokens::match_basicnode(){
  Node * node=match_basicnode_no_suffix();
  if(!node) return NULL;
  OrNode*ornode=match_ornode(node);
  if(ornode) return ornode;

  OnNode*onnode=match_onnode(node);
  if(onnode) return onnode;

  return node;
}

OrNode* Tokens::match_ornode(Node*prefix){
  uassert(prefix,"match_ornode internal");
  if(!match_keyword("or"))return NULL;
  Node*suffix=match_basicnode();
  if(!suffix)
    show_error("expecting a filter following 'or'");
  MFilter*clause1=dynamic_cast<MFilter*>(prefix);
  MFilter*clause2=dynamic_cast<MFilter*>(suffix);
  if(!clause1||!clause2)
    show_error("invalid form of 'or' clause: illegal left or right clause");
  return new OrNode(clause1,clause2);
}

OnNode* Tokens::match_onnode(Node*prefix){
  if(!match_keyword("on"))return NULL;
  uassert(prefix,"unexpected OnNode arg");
  SetBase* s1=dynamic_cast<SetBase*>(prefix);
  if(!s1||!s1->isSet())
    show_error("left argument to 'on' is not a set filter");
  Node* suffix=match_set();
  if(!suffix)
    show_error("missing right argument to 'on'");
  SetBase* s2=dynamic_cast<SetBase*>(suffix);
  if(!s2||!s2->isSet())
    show_error("right argument to 'on' is not a set filter");
  return new OnNode(s1,s2);
}

Node* Tokens::match_basicnode_no_suffix(){
  Node*n=NULL;
  if(!n) n=match_simplenode();
  if(!n) n=match_compoundnode();
  return n;
}


Node* Tokens::match_compoundnode(){
  Node*n=NULL;
  if(!n) n=match_anynode();
  if(!n) n=match_attacknode();
  if(!n) n=match_betweennode();
  if(!n) n=match_commentbase();
  if(!n) n=match_countsquaresnode();
  if(!n) n=match_echonode();
  if(!n) n=match_elonode();
  if(!n) n=match_eventnode();
  if(!n) n=match_existsnode();
  if(!n) n=match_extensionnode();
  if(!n) n=match_forallnode();
  if(!n) n=match_futurestarnode();
  if(!n) n=match_matchcommentnode();
  if(!n) n=match_movebase();
  if(!n) n=match_movenumbernode();
  if(!n) n=match_notnode();
  if(!n) n=match_originnode();
  if(!n) n=match_paststarnode();
  if(!n) n=match_pieceidnode();
  if(!n) n=match_pieceloc();
  if(!n) n=match_playernode();
  if(!n) n=match_positionnode();
  if(!n) n=match_powerdifferencenode();
  if(!n) n=match_powernode();
  if(!n) n=match_raynode();
  if(!n) n=match_resultnode();
  if(!n) n=match_sequencenode();
  if(!n) n=match_silent();
  if(!n) n=match_sitenode();
  if(!n) n=match_sortbodynode();
  if(!n) n=match_transformnode();
  if(!n) n=match_yearnode();
  if(!n)n=match_vectornode();
  return n;
}
Node* Tokens::match_silent(){
  if(!match_keyword("silent")) return NULL;
  Node* n = match_basicnode();
  if(!n)
    show_error("silent keyword must be followed by a filter to make silent (relation, next, next*, previous, previous*");
  CommentFlags*cf=dynamic_cast<CommentFlags*>(n);
  if(!cf)
    show_error("silent keyword must be followed by one of: relation, next, next*, previous, previous*");
  cf->makeSilent();
  return n;
}

SilentFeatureNode* Tokens::match_silentfeature(){
  if (match_keyword("silent"))return new SilentFeatureNode();
  return NULL;
}

Node* Tokens::match_cqlfeature(){
  Node*n=NULL;
  if(!n)n=match_pgnnode();
  if(!n)n=match_resultnode();
  if(!n)n=match_gamenumbernode();
  if(!n) n=match_outputnode();
  if(!n) n=match_variationsnode();
  if(!n) n=match_matchcountnode();
  if(!n) n=match_silentfeature();
  if(!n)n=match_playernode();
  if(!n)n=match_elonode();
  if(!n)n=match_yearnode();
  if(!n)n=match_sitenode();
  if(!n)n=match_eventnode();
  return n;
}

MoveNumberNode* Tokens::match_movenumbernode(){
  KeywordToken* k=match_keyword(":movenumber");
  if(!k) return NULL;
  Range* r=match_range();
  if(!r) show_error(":movenumber expected range but got: ");
  return new MoveNumberNode(r);
}

GameNumberNode* Tokens::match_gamenumbernode(){
  int x=save();
  if(match_keyword(":gamenumber")){
    Range* r=match_range();
    if(r) return new GameNumberNode(r);
  }
  restore(x);
  return NULL;
}

CqlNode* Tokens::match_cqlnode(){
  if(!match_keyword("cql")) 
    show_error("Expected 'cql' word to start :cql specification but got: ");
  if(!match_lparen())
    show_error("Expected left paren following the 'cql' keyword");
  vector<Node*> features=match_some_cqlfeatures();
  //if(features.empty())
    //show_error("Empty CQL specification");
  
  if(!match_rparen())
    show_error("Syntax error while parsing the CQL specification. Expected right paren.");
  vector<Node*> nodes=match_some_basicnodes();
  if(nodes.empty())
    show_error("Expected one or more filters following CQL specification, got none");
  if(!eof())
    show_error("Extra text following the filters after the CQL specification, or unspecified syntax error");
  Node*node=NULL;
  if(nodes.size()>1)
    node=new PositionNode(nodes);
  else
    node=nodes.at(0);
  CqlNode*n=new CqlNode(features,node);
  return n;
}


//match_positionnode returns the contents of {x} if x is just one form
Node* Tokens::match_positionnode(){
  vector<Node*> nodes;
  int x=save();
  if (match_repeat_range()){
    restore(x);
    return NULL;
  }
  if(!match_lbrace()) return NULL;
  nodes=match_some_basicnodes();
  if(nodes.size()==0)
    show_error("syntax error following a '{' : expected a filter");
  bool rp=match_rbrace();
  if(!rp)
    show_error("Syntax error while trying to parse list of filters, expecting right brace");
  if(nodes.size()==1)
    return nodes.at(0);
  return new PositionNode(nodes);
}



NotNode* Tokens::match_notnode(){
  if(!match_keyword(":not")) return NULL;
  Node*node=match_basicnode();
  return new NotNode(node);
}

RayNode* Tokens::match_raynode(){
  if(!match_keyword("ray")) return NULL;
  bool isattack=false;
  Range* range=match_range();
  vector<Direction> directions=match_raydirections(&isattack);
  if (directions.empty())
    directions=Direction::allDirections();
  if(!match_lparen())
    show_error("Expecting '(' character after list of directions in the ray");
  vector<Node*>nodes=match_some_basicnodes();
  vector<SetBase*>constituents;
  for(auto node:nodes)
    constituents.push_back(dynamic_cast<SetBase*>(node));
  for(auto set:constituents)
    if(!set||!set->isSet())
      show_error("All parameters to ray must be sets");
  if(!match_rparen())
    show_error("Expected ')' character after arguments to ray");
  uassert(constituents.size()>1,"Must have at least two arguments to a ray");
  return new RayNode(directions,
		     constituents,
		     isattack,
		     range);
}

vector<Direction> Tokens::match_raydirections(bool*isattack){
  vector<Direction> directions;
  if (match_keyword("attack")||match_keyword("attacks")){
    directions=Direction::allDirections();
    *isattack=true;
    return directions;
  }
  *isattack=false;
  while(true){
    StringToken *token=dynamic_cast<StringToken*>(current());
    if(!token) break;
    vector<Direction> these=Direction::directionsFromString(token->value);
    if(these.empty()) break;
    forward();
    for(auto d:these){
      for(auto seen:directions)
	uassert(!d.eq(seen),"Duplicate directions in ray specification");
      directions.push_back(d);
    }
  }
  return directions;
}

      
vector<directionT>Tokens::directionsFromRayKeyword(KeywordToken *k){
  uassert(k);
  if(k->eq(":rayorthogonal"))
    return vector<directionT>{UP, DOWN, LEFT, RIGHT};
  else if (k->eq(":raydiagonal"))
    return vector<directionT>{UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT};
  else if (k->eq(":rayattack")||k->eq(":ray"))
    return vector<directionT>{
      UP, DOWN, LEFT, RIGHT,
	UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT};
  uassert(false, "Unknown ray keyword: ", k->value);
  return vector<directionT>{};
}
    
AttackNode* Tokens::match_attacknode(){
  bool keyword=(match_keyword(":attack")||match_keyword(":attacks"));
  if(!keyword) return NULL;
  Range *r=match_range();
  if(!match_lparen())
    show_error("'attack' expects left paren before the attacker and the attacked specifictions");
  SetBase *p1=match_set();
  if (!p1)
    show_error("missing set filter following 'attack' after the '('");
  SetBase*p2=match_set();
  uassert(p2&&p2->isSet(),"Two set specifiers must follow :attack but only one was found");
  if(!match_rparen())
    show_error("'attack' expects right paren following the attacker and attacked specifications");
  return new AttackNode(p1,p2,r);
}

Node* Tokens::match_simplenode(){
  if(match_keyword(":check"))
    return new CheckNode();
  if(match_keyword(":stalemate"))
    return new StalemateNode();
  if(match_keyword(":mate"))
    return new MateNode();
  if(match_keyword(":wtm"))
    return new ColorNode(WHITE);
  if(match_keyword(":btm"))
    return new ColorNode(BLACK);
  if(match_keyword(":initial"))
    return new InitialNode();
  if(match_keyword("variation"))
    return new InVariationNode();
  if(match_keyword("beginvariation"))
    return new BeginVariationNode();
  if(match_keyword("mainline"))
    return new InMainlineNode();
  if(match_keyword("terminal"))
    return new TerminalNode();
  return NULL;
}

VariationsNode* Tokens::match_variationsnode(){
  if(match_keyword(":variations"))
    return new VariationsNode();
  return NULL;
}

KeywordToken*Tokens::match_raykeyword(){
  int x=save();
  char*keys[]={":ray",":rayorthogonal",":raydiagonal",":rayattack"};
  size_t nkeys = sizeof(keys)/sizeof(char*);
  KeywordToken *t=match_keyword();
  if(!t)return NULL;
  for(int i=0;i<nkeys;++i)
    if(t->eq(keys[i]))return t;
  restore(x);
  return NULL;
}


TransformNode* Tokens::match_transformnode(){
  TransformNode*t=NULL;
  if(!t) t=match_fliptransform();
  if(!t) t=match_shifttransform();
  return t;
}

NumericVariable* Tokens::match_optionalnumericvariable(bool ismax){
  const char*name=match_quotedstring();
  if(!name){
  int nextid=Tokens_match_optional_numericvariable_nextid++; // this is a global variable
  char buffer[100];
  sprintf(buffer,"CQL ID-%d",nextid);
  name=util::copy(buffer);
  }
  uassert(name,"internal monv");
  return Variable::getNumericVariable(name,ismax);
}

NumericVariable* Tokens::match_sortheader(){
  if(!match_keyword("sort"))return NULL;
  bool ismax=true;
  if (match_keyword("max"))
    ismax=true;
  else if (match_keyword("min"))
    ismax=false;
  NumericVariable* var=match_optionalnumericvariable(ismax);
  uassert(var,"Unable to form numeric variable");
  return var;
}

Node* Tokens::match_sortbodynode(){
  NumericVariable* var=match_sortheader();
  if(!var)return NULL;
  Node*node=match_basicnode();
  if(!node)
    show_error("'sort' must be followed by optional 'max' or 'min'; then by an optional quoted string; and last by countable filter. The countable filter is missing");
  if(!node->isCountable())
    show_error("'sort' must be followed by optional 'max' or 'min'; then by an optional quoted string; and last by countable filter. The final filter is not a countable filter");
  return new AssignNode(var,node);
}

  
MatchCountNode* Tokens::match_matchcountnode(){
  bool sort=false;
  if (match_keywords("sort","matchcount"))
    sort=true;
  else if(!match_keyword("matchcount"))
    return NULL;
  Range * range= match_range();
  if(!range)
    show_error("missing range, eg. '1 20', following 'matchcount' keyword");
  return new MatchCountNode(range,sort);
}
  
PgnNode* Tokens::match_pgnnode(){
  if(match_keyword("pgn")||match_keyword("input")){
    StringToken*name=match_string();
    if(!name)show_error("Missing filename in :pgn specification");
    const char* filename= name->value;
    if(CqlPgnFilename){
#ifdef STANDALONE
      printf("Using command line argument pgn filename: %s\n",CqlPgnFilename);
#endif
      filename=CqlPgnFilename;
    }
    uassert(filename);
    if(!filename_is_pgn(filename)){
      fprintf(stderr,"Invalid pgn filename (must end in .pgn or .PGN): %s\n",filename);
      show_error("bad pgn filename");
    }
    return new PgnNode(filename);
  }
  return NULL;
}

OutputNode* Tokens::match_outputnode(){
  if(match_keyword(":output") || match_keyword(":out")){
    StringToken*name=match_string();
    if(!name)show_error("Missing filename in :output specification");
    const char* filename=name->value;
    uassert(filename);
    if(CqlOutputFilename){
      printf("Using command line argument for filename: %s\n",CqlOutputFilename);
      filename=CqlOutputFilename;
    }
    uassert(filename);
    if(!filename_is_pgn(filename)){
      fprintf(stderr,"Invalid pgn filename (must end in .pgn or .PGN): %s\n",filename);
      show_error("bad output filename");
    }
    return new OutputNode(filename);
  }
  return NULL;
}


PlayerNode* Tokens::match_playernode(){
  if(!match_keyword("player"))
    return NULL;
  colorT color=match_color();
  const char* name=match_quotedstring();
  if(!name)
    show_error("'player' must be followed by a quoted string");
  return new PlayerNode(name,color);
}

EventNode* Tokens::match_eventnode(){
  if(!match_keyword("event"))
    return NULL;
  const char* name=match_quotedstring();
  if(!name)
    show_error("'event' must be followed by a quoted string");
  return new EventNode(name);
}

SiteNode* Tokens::match_sitenode(){
  if(!match_keyword("site"))
    return NULL;
  const char* name=match_quotedstring();
  if(!name)
    show_error("'site' must be followed by a quoted string");
  return new SiteNode(name);
}

EloNode* Tokens::match_elonode(){
  if(!match_keyword("elo"))
    return NULL;
  colorT color=match_color();
  Range*range=match_range();
  if(!range)
    show_error("'elo' must be followed by an optional color and a range");
  return new EloNode(range,color);
}

YearNode* Tokens::match_yearnode(){
  if(!match_keyword("year"))
    return NULL;
  Range*range=match_range();
  if(!range)
    show_error("'year' must be followed by a range");
  return new YearNode(range);
}

ResultNode* Tokens::match_resultnode(){
  if(!match_keyword(":result"))
    return NULL;
  StringToken*name=NULL;
  if(!name ) name=match_string("1-0");
  if(!name) name=match_string("0-1");
  if(!name) name=match_string ("1/2-1/2");
  uassert(name,"expecting 1-0 or 0-1 or 1/2-1/2 following :result");
  return new ResultNode(name->value);
}


StringToken* Tokens::match_string(char* v){
  uassert(v!=NULL);
  int x=save();
  StringToken*n=match_string();
  if(n && n->eq(v))
    return n;
  restore(x);
  return NULL;
}
    
StringToken*Tokens::match_string(){
  StringToken*n=dynamic_cast<StringToken*>(current());
  if(n)forward();
  return n;
}

vector<Node*> Tokens::match_some_cqlfeatures(){
  vector<Node*>v;
  while(true){
    Node* n=match_cqlfeature();
    if(!n) break;
    v.push_back(n);
  }
  return v;
}

vector<Node*> Tokens::match_some_basicnodes(){
  vector<Node*>v;
  while(true){
    Node* n=match_basicnode();
    if(!n) break;
    v.push_back(n);
  }
  return v;
}

ForallNode*Tokens::match_forallnode(){
  if(!match_keywords("square", "all"))
    return NULL;
  SquareVariable*sv=match_squarevariable();
  uassert(sv,"Expecting a square variable in 'forall' keyword specification");
  SetBase* target=match_inexpr();
  vector<Node*>nodes=match_some_basicnodes();
  return new ForallNode(sv,target,nodes);
}


      

KeywordToken* Tokens::match_keyword(const char *v){
  KeywordToken* t=dynamic_cast<KeywordToken*>(current());
  if(!t)return NULL;
  if( !t->eq(v)) return NULL;
  forward();
  return t;
}

bool Tokens::match_keywordstar(const char *name){
  int x=save();
  if (match_keyword(name)&&match_star())
    return true;
  restore(x);
  return false;
}

bool Tokens::match_keywords(const char *v1, const char*v2){
  int x=save();
  if(match_keyword(v1)&&match_keyword(v2)) return true;
  restore(x);
  return false;
}


KeywordToken* Tokens::match_keyword(){
  KeywordToken* t=dynamic_cast<KeywordToken*>(current());
  if(t) forward();
  return t;
}

bool Tokens::match_bar(){
  BarToken* t=dynamic_cast<BarToken*>(current());
  if(!t)return false;
  forward();
  return true;
}

bool Tokens::match_lparen(){
  LParenToken* t=dynamic_cast<LParenToken*>(current());
  if(!t)return false;
  forward();
  return true;
}

bool Tokens::match_star(){
  StarToken* t=dynamic_cast<StarToken*>(current());
  if(!t)return false;
  forward();
  return true;
}
bool Tokens::match_questionmark(){
  QuestionMarkToken* t=dynamic_cast<QuestionMarkToken*>(current());
  if(!t)return false;
  forward();
  return true;
}

bool Tokens::match_plus(){
  PlusToken* t=dynamic_cast<PlusToken*>(current());
  if(!t)return false;
  forward();
  return true;
}

bool Tokens::match_lbrace(){
  LBraceToken* t=dynamic_cast<LBraceToken*>(current());
  if(!t)return false;
  forward();
  return true;
}

bool Tokens::match_rparen(){
  RParenToken* t=dynamic_cast<RParenToken*>(current());
  if(!t)return false;
  forward();
  return true;
}

bool Tokens::match_rbrace(){
  RBraceToken* t=dynamic_cast<RBraceToken*>(current());
  if(!t)return false;
  forward();
  return true;
}


PieceLoc* Tokens::match_pieceloc(){
  PieceDesignatorToken* t =
    dynamic_cast<PDT*>(current());
  if(!t) return NULL;
  else
    forward();
  if(t->pieceloc) return t->pieceloc;
  PieceLoc*p=new PieceLoc(t->pieces,
			  t->squares,
			  t->variables);
  t->pieceloc=p;
  return p;
}

Range* Tokens::match_range(){
  Range* r=match_compoundrange();
  if(r) return r;
  IntToken*ip=match_int();
  if(!ip) return NULL;
  return new Range(ip->value);
}

Range* Tokens::match_compoundrange(){
  int x=save();
  IntToken* minp=match_int();
  if(minp){
    IntToken* maxp=match_int();
    if(maxp)
      return new Range(minp->value,maxp->value);
  }
  restore(x);
  return NULL;
}

IntToken* Tokens::match_int(){
  IntToken *ip=dynamic_cast<IntToken*>(current());
  if(ip) forward();
  return ip;
}

MoveBase* Tokens::match_movebase(){
  bool past=false;
  bool future=false;
  past=match_keywords("move", "previous");
  if(!past)
    future=match_keyword("move");
  if (!past&&!future)return NULL;
  uassert (past||future,"match_movebase internal pf");

  bool legal=false;
  bool nullmove=false;
  bool primaryMove=false;
  bool secondaryMove=false;
  SetBase* from=NULL;
  SetBase* to=NULL;
  PieceLoc* promote=NULL;
  SetBase* epcapture=NULL;
  while(true)
    if (match_keyword("null"))
      nullmove=true;
    else if (match_keyword("primary"))
      primaryMove=true;
    else if (match_keyword("secondary"))
      secondaryMove=true;
    else if (from==NULL &&
	     ((from=match_fromexp())!=NULL));
    else if (to==NULL &&
	     ((to=match_toexp())!=NULL));
    else if (promote==NULL&&
	     ((promote=match_promoteexp())!=NULL));
    else if (epcapture==NULL&&
	     ((epcapture=match_enpassantexp())!=NULL));
    else break;
  if (nullmove&&(from||to||promote||epcapture))
      show_error("cannot use null with 'from', 'to', 'promote', or 'enpassant'");
  if(epcapture&&promote)
    show_error("cannot have a move that is both an en passant capture and a promotion");
  if (past)
    return new MovePastNode(from,to,promote,epcapture,nullmove,primaryMove,secondaryMove);
  else if(future)
    return new MoveFutureNode(from,to,promote,epcapture,nullmove,primaryMove,secondaryMove);
  else if (legal)
    return new MoveLegalNode(from,to,promote,epcapture,nullmove,primaryMove,secondaryMove);
  else uassert(false,"match_movebase");
  return NULL;
}
  
  
SetBase* Tokens::match_enpassantexp(){
  if (match_keyword("enpassant"))
    return new AnyNode();
  if (match_keyword("enpassantsquare")){
    SetBase*s=match_set();
    if(!s)
      show_error("expecting a set specifier following 'enpassantsquare' in 'move'");
    return s;
  }
  return NULL;
}

SetBase* Tokens::match_fromexp(){
  if(!match_keyword("from"))
    return NULL;
  SetBase* s=match_set();
  if(!s)
    show_error("missing set specifier in move from");
  return s;
}

SetBase* Tokens::match_toexp(){
  if(!match_keyword("to"))
    return NULL;
  SetBase* s=match_set();
  if(!s)
    show_error("missing set specifier in move to");
  return s;
}

PieceLoc* Tokens::match_promoteexp(){
  if(!match_keyword(":promote"))
    return NULL;
  PieceLoc* p=match_pieceloc();
  if(!p) show_error("missing set specifier in :move :promote");
  if(!p->isPurePiece())
    show_error("The promoted piece must be just a piece or set of pieces without square designators, e.g. 'promote R' or 'promote [RN]' ");
  return p;
}


    
SquareVariable*Tokens::match_squarevariable(){
  PDT* t=
    dynamic_cast<PDT*>(current());
  if(!t)return NULL;
  VariableToken*vt=t->getAsVariableToken();
  if(!vt)return NULL;
  const char *name=vt->value;
  uassert(vt);
  SquareVariable*sv=Variable::getSquareVariable(name);
  uassert(sv,"match_squarevariable, internal",name);
  forward();
  return sv;
}

TagVariable*Tokens::match_tagvariable(){
  PDT* t=
    dynamic_cast<PDT*>(current());
  if(!t)return NULL;
  VariableToken*vt=t->getAsVariableToken();
  if(!vt)return NULL;
  const char *name=vt->value;
  uassert(vt);
  TagVariable*tv=Variable::getTagVariable(name);
  uassert(tv,"match_tagvariable, internal",name);
  forward();
  return tv;
}


void Tokens::show_error(const char* message){
  printf("\n**SYNTAX ERROR** %s\n",message);
  if(eof())printf("unexpected end of file\n");
  else {
    printf ("Unable to parse the following token: ");
    current()->print();
    printf("\n");
  }
  uassert(false, message);
}

VectorNode* Tokens::match_vectornode(){
  DirectionParameter*p=match_directionparameter();
  if(!p)return NULL;
  SetBase*source=match_set();
  if(!source)
    show_error("expecting a set specifier following the direction parameter");
  return new VectorNode(*p,source);
}

vector<Direction>Tokens::match_direction(){
  StringToken*token=dynamic_cast<StringToken*>(current());
  if(!token)return vector<Direction>{};
  const char* v=token->value;
  uassert(v,"internal match_directionparameter");
  vector<Direction> directions=Direction::directionsFromString(v);
  if(directions.empty()){
    return directions;
  }
  forward();
  return directions;
}
  
DirectionParameter* Tokens::match_directionparameter(){
  vector<Direction> directions=match_direction();
  if(directions.empty())return NULL;
  Range *range=match_range();
  if (!range) range= new Range(1,7);
  DirectionParameter*p=new DirectionParameter(directions,range);
  return p;
}

FutureStarNode* Tokens::match_futurestarnode(){
  int depth=-1;
  if(!match_keywordstar("next")) return NULL;
  Range*range=match_range();
  if(match_keyword("depth")){
    Range*depthrange=match_range();
    if(!depthrange)
      show_error("the 'depth' keyword must be followed by a single nonnegative integer");
    depth=depthrange->min;
    if (depth<0||depth!=depthrange->max)
      show_error("the 'depth' keyword must be followed by a single nonnegative integer");
  }
  Node*node=match_basicnode();
  if(!node)
    show_error("expecting a valid filter following 'next*'");
  return new FutureStarNode(node,range,depth);
}

PastStarNode* Tokens::match_paststarnode(){
  int depth=-1;
  if(!match_keywordstar("previous")) return NULL;
  Range*range=match_range();
  if(match_keyword("depth")){
    Range*depthrange=match_range();
    if(!depthrange)
      show_error("the 'depth' keyword must be followed by a single nonnegative integer");
    depth=depthrange->min;
    if (depth<0||depth!=depthrange->max)
      show_error("the 'depth' keyword must be followed by a single nonnegative integer");
  }
  Node*node=match_basicnode();
  if(!node)
    show_error("expecting a valid filter following 'previous*' ");
  return new PastStarNode(node,range,depth);
}


CountSquaresNode* Tokens::match_countsquaresnode(){
  if(!match_keyword("countsquares")) return NULL;
  Range*r=match_range();
  if(!r)
    show_error("The 'countsquares' keyword must be followed by a range");
  SetBase*s=match_set();
  if(!s)
    show_error("Expected a set filter following 'countsquares range'");
  return new CountSquaresNode(s,r);
}
  
SetBase* Tokens::match_set(){
  int x=save();
  Node*n=match_basicnode();
  if(!n)return NULL;
  SetBase*set=dynamic_cast<SetBase*>(n);
  if(!set||!set->isSet()){
    restore(x);
    return NULL;}
  return set;
}

SetBase* Tokens::match_inexpr(){
  if(!match_keyword("in"))
    return NULL;
  SetBase*ret=match_set();
  if(!ret)
    show_error("Expecting a set expression following the 'in' keyword in 'square' expression");
  return ret;
}

BetweenNode* Tokens::match_betweennode(){
  if(!match_keyword("between"))
    return NULL;
  if(!match_lparen())
    show_error("arguments to 'between' should be enclosed in parens: missing '('");
  SetBase* source=match_set();
  if(!source)
    show_error("Expected a source set following 'between'");
  SetBase* target=match_set();
  if(!target)
    show_error("Expected a target set following 'between' and the source");
  if(!match_rparen())
    show_error("arguments to 'between' should be enclosed in parens: missing ')'");

  return new BetweenNode(source,target);
}

ExtensionNode* Tokens::match_extensionnode(){
  if(!match_keyword("extension"))
    return NULL;
  return new ExtensionNode();
}

AnyNode* Tokens::match_anynode(){
  if(match_keyword("any"))
    show_error("The 'any' keyword has been replaced by the '.' character since version 5.2. Use '_' instead of '.' to denote an empty square");
  if(match_keyword("."))
    return new AnyNode();
  return NULL;
}

PowerNode* Tokens::match_powernode(){
  if(!match_keyword("power"))
    return NULL;
  Range*range=match_range();
  if(!range)
    show_error("Expected a range following 'power' ");
  SetBase*set=match_set();
  if(!set)
    show_error("Expected a set following 'power' and the range");
  return new PowerNode(set,range);
}

PowerDifferenceNode* Tokens::match_powerdifferencenode(){
  if(!match_keyword("powerdifference"))
    return NULL;
  Range*range=match_range();
  if(!range)
    show_error("Expected a range following 'powerdifference' ");
  if(!match_lparen())
    show_error("Expected '(' following 'powerdifference' and range");
  SetBase*set1=match_set();
  if(!set1)
    show_error("Expected a set following 'powerdifference range <'");
  SetBase*set2=match_set();
  if(!set2)
    show_error("Expected another set following 'powerdifference range < set1 '");
  if(!match_rparen())
    show_error("Expected ')' following 'powerdifference range < set1 set2'");
  return new PowerDifferenceNode(set1,set2,range);
}

Node* Tokens::match_existsnode(){
  int x=save();
  if(match_keywords("square","all")){
    restore(x);
    return NULL;}
  
  if(!match_keyword("square")) return NULL;
  Range*range=match_range();
  SquareVariable*sv=match_squarevariable();
  if(!sv) show_error("Expecting a square variable in 'square' keyword specification");
  SetBase*target=match_inexpr();
  if(!target)
    show_error ("Missing 'in' following the variable name in 'square' expression");
  vector<Node*>nodes=match_some_basicnodes();
  if(!nodes.size())
    show_error("expected a nonzero number of nodes to test in square filter");
  ExistsNode* existsnode=new ExistsNode(sv,target,nodes);
  if (!range) return existsnode;
  return new CountSquaresNode(existsnode,range);
}

Node* Tokens::match_pieceidnode(){
  if(!match_keyword("piece"))
    return NULL;
  Range*range=match_range();
  TagVariable*tv=match_tagvariable();
  if(!tv) show_error("Expecting an id variable in 'piece' keyword specification");
  SetBase*target=match_inexpr();
  if(!target)
    show_error("Expecting 'in', followed by a set, after  'piece' or 'piece' range");
  vector<Node*>nodes=match_some_basicnodes();
  if(!nodes.size())
    show_error("expected a nonzero number of filters following 'in set'  in piece filter");
  PieceIdNode* pieceidnode=new PieceIdNode(tv,target,nodes);
  if (!range) return pieceidnode;
  return new CountSquaresNode(pieceidnode,range);
}

OriginNode* Tokens::match_originnode(){
  if(!match_keyword("origin"))
    return NULL;
  TagVariable*tag=match_tagvariable();
  if(!tag)
    show_error("expected a piece id following 'origin'");
  return new OriginNode(tag);
}

MatchCommentNode* Tokens::match_matchcommentnode(){
  if(!match_keyword("hascomment"))
    return NULL;
  const char * name=match_quotedstring();
  if(!name)
    show_error("Expected a quoted string folllowing 'hascomment'");
  return new MatchCommentNode(name);
}

const char* Tokens::match_quotedstring(){
  QuotedStringToken*q=dynamic_cast<QuotedStringToken*>(current());
  if(!q) return NULL;
  forward();
  return q->value;
}

CommentBase* Tokens::match_commentbase(){
  if(!match_keyword("comment"))return NULL;
  const char* s=match_quotedstring();
  if(s){
    if(strlen(s)>=CommentBase::maxLen)
      show_error("comment too long");
    return new CommentString(s);
  }
  SetBase*set=match_set();
  if(set)
    return new CommentSet(set);
  show_error("'comment' must be followed by either a quoted string or a set filter");
  return NULL;
}

colorT Tokens::match_color(){
  if (match_keyword("white"))return WHITE;
  if (match_keyword("black"))return BLACK;
  return NOCOLOR;
}
