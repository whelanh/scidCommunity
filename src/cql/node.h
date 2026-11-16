#pragma once
#include "deleteable.h"
#include "util.h"
#include "cqlglobals.h"
#include "token.h"
#include "game.h"
#include "variable.h"
#include "markboard.h"
#include "squaremask.h"
#include "variationflags.h"
#include "commentflags.h"
#include "clonevec.h"
#include "sortvalue.h"
#include "gamesortinfo.h"
#include "cql.h"
#include "seqret.h"

class PieceLoc;
class Node;
class CqlNode;
class Range;
class MFilter;
class Transform;
class TransformNode;
class SeqConstituent;
class StarConstituent;
class RepeatConstituent;
class HolderConstituent;

typedef vector<Node*> vnode;
#define CVV(name) const char * thisclass() {return #name;} name* clone() 

class Node : public Deleteable { //abstract
 public:
  static int ndisabled;
  bool disabled{false};
  void disable();
  bool annotateFlag{false};
  virtual void print(){printf("<%s>",thisclass());}
  virtual const char* thisclass()=0;
  virtual vnode children()=0;
  vnode descendants();
  void alldescendants(vnode*);
  static int counter;
  Node(){++counter;}
  virtual void setVariations(bool arg);
  virtual void deepify(){};
  void cloneverify(Node*source,Node*target);
  virtual Node* clone()=0;
  virtual void transform_members(Transform*){}
  virtual void transform_in_place(Transform*);
  virtual void expand();
  void makeSilentRecursively();
  void makeNotNodeSilentRecursively();
  virtual Node* transform(Transform*t);
  virtual bool hasEmptySquareMaskDescendant();
  virtual bool hasEmptySquareMask(){return false;}
  virtual void addSortFields(vector<NumericVariable*>& fields);
  virtual bool isSet();
  virtual bool isCountable();
};



  
class MFilter : public Node { //abstract
 public:
  virtual bool match_position(Game*game)=0;
  virtual bool isGap(){return false;}
  virtual MFilter* clone()=0;
};

class Countable{
 public:
  virtual bool match_count(Game*game, NumValue*value)=0;
  virtual Countable* clone()=0;
  virtual void print()=0;
  virtual bool isCountable(){return true;}
};

class SetBase: public MFilter{ //abstract
 public:
  //  virtual bool match_square(squareT square, Game*game)=0;
  virtual bool match_position(Game*game);
  virtual SquareMask getSquares(Game*game)=0;
  virtual bool isSet(){return true;}
  virtual SetBase* clone()=0;

};

class PieceLoc:public SetBase{
 public:
  SquareMask pieces;
  SquareMask squaremask;
  /*caching related members*/
  moveT* lastid;
  int lastgamenumber=-1;
  SquareMask lastmask;
  /*end of caching related members*/
  vector<Variable*> variables;
  //  bool piecemask[18];
  //  bool matchPieceSquare(pieceT piece,squareT square);
  PieceLoc(vector<PieceToken*>piecetokens,
	   vector<SquareToken*> squaretokens,
	   vector<VariableToken*> variabletokens);
  static vector<pieceT>piecesFromChar(char c);
  void print();
  CVV(PieceLoc);
  vnode children(){return vnode{};}
  bool match_piece(pieceT piece);
  bool isPurePiece();
  Variable* getAsVariable();
  void transform_members(Transform *);
  bool hasEmptySquareMask();
  SquareMask getSquares(Game*game);
  SquareMask getPieceMask(Game*game);
};

class GameFilter:public MFilter{ //abstract
 public:
  virtual bool match_game(Game*game)=0;
  bool match_position(Game*game){return match_game(game);}
  virtual GameFilter*clone()=0;
};



////////Simple keyword specs with no arguments, base class is KeywordNode, subclasses
///////are TransformNode, VariationsNode
class Childless : public Node{ //abstract
 public:
  vnode children(){return vnode{};}
  virtual Childless* clone()=0;
};
  
class KeywordNode: public Childless{
 public:
  const char*value;
  KeywordNode(const char*v);
  CVV(KeywordNode);
  void print();
  bool eq(const char*);
};

class SilentFeatureNode: public KeywordNode{
 public:
  CVV(SilentFeatureNode);
 SilentFeatureNode(): KeywordNode("silent"){};
};

class VariationsNode: public KeywordNode{
 public:
  CVV(VariationsNode);
 VariationsNode(): KeywordNode(":variations"){}
};


class AnyNode:public SetBase{
 public:
  SquareMask getSquares(Game*game){return SquareMask::all();}
  bool match_position(Game*game){return true;}
  vnode children(){return vnode{};}
  CVV(AnyNode);
};


class SimpleNode:public MFilter { //no arg keywords corresponding to a filter, abstract
 public:
  virtual SimpleNode*clone()=0;
  vnode children(){return vnode{};}
};

class CheckNode:public SimpleNode{
  CVV(CheckNode);
  bool match_position(Game*game);
};

class StalemateNode:public SimpleNode{
  CVV(StalemateNode);
  bool match_position(Game*);
};

class MateNode:public SimpleNode{
  CVV(MateNode);
  bool match_position(Game*);
};

class ColorNode:public MFilter{
 public:
  CVV(ColorNode);
  void print();
  bool match_position(Game*);
  colorT color;
  ColorNode(colorT c);
  vnode children(){return vnode{};}
  void transform_members(Transform*);
};


class InitialNode:public SimpleNode{
  CVV(InitialNode);
  bool match_position(Game*);
};

class InVariationNode:public SimpleNode{
 public:
  CVV(InVariationNode);
  bool match_position(Game*game);
};

class BeginVariationNode:public SimpleNode{
 public:
  CVV(BeginVariationNode);
  bool match_position(Game*game);
};


class InMainlineNode:public SimpleNode{
 public:
  CVV(InMainlineNode);
  bool match_position(Game*game);
};



class TerminalNode:public SimpleNode{
  CVV(TerminalNode);
  bool match_position(Game*);
};

class NotNode:public SetBase{
 public:
  MFilter* filter{NULL};
  CVV(NotNode);
  vnode children(){return vnode{filter};}
  void print();
  NotNode(Node*np);
  bool match_position(Game*);
  void deepify(){filter=filter->clone();}
  virtual bool isSet();
  SquareMask getSquares(Game*);
};

class PositionNode: public MFilter{
 public:
  vector<MFilter*> specs;
  PositionNode(vector<Node*>);
  void print();
  bool variations{false};
  CVV(PositionNode);
  vnode children();
  bool match_position(Game*game);
  void deepify(){clonevec(specs);}
};

class MatchCountNode: public Node{
 public:
  Range*range{NULL};
  MatchCountNode(Range*,bool);
  bool sort{false};
  void print();
  vnode children(){return vnode{};}
  CVV(MatchCountNode);
};

class PgnNode: public Node{
 public:
  PgnNode(const char*v){value=v;}
  const char* value;
  CVV(PgnNode);
  void print();
  vnode children(){return vnode{};}
};

class OutputNode: public Node{
 public:
  OutputNode(const char*v){value=v;}
  const char* value;
  CVV(OutputNode);
  void print();
  vnode children(){return vnode{};}
};

class ResultNode: public GameFilter{
 public:
  ResultNode(const char*v);
  resultT result{RESULT_None};
  void transform_members(Transform*t);
  CVV(ResultNode);
  void print();
  bool match_game(Game*game);
  vnode children(){return vnode{};}
};

class PlayerNode: public GameFilter{
 public:
  const char* name{NULL};
  colorT color {NOCOLOR};
  vnode children(){return vnode{};}
  bool match_game(Game*game);
  void print();
  CVV(PlayerNode);
  PlayerNode(const char*,colorT);
  void transform_members(Transform*);
};

class EventNode: public GameFilter{
 public:
  const char* name{NULL};
  vnode children(){return vnode{};}
  bool match_game(Game*game);
  void print();
  CVV(EventNode);
  EventNode(const char*);
};

class SiteNode: public GameFilter{
 public:
  const char* name{NULL};
  vnode children(){return vnode{};}
  bool match_game(Game*game);
  void print();
  CVV(SiteNode);
  SiteNode(const char*);
};


class EloNode: public GameFilter,public Countable{
 public:
  Range*range{NULL};
  colorT color {NOCOLOR};
  vnode children(){return vnode{};}
  bool match_game(Game*game);
  bool match_count(Game*game, NumValue*value);
  void print();
  CVV(EloNode);
  EloNode(Range*range,colorT);
  void transform_members(Transform*);
};

  
class YearNode: public GameFilter, public Countable{
 public:
  Range*range{NULL};
  vnode children(){return vnode{};}
  bool match_game(Game*game);
  bool match_count(Game*game, NumValue*value);
  void print();
  CVV(YearNode);
  YearNode(Range*range);
};

class GameNumberNode: public GameFilter{
 public:
  Range * range{NULL};
  CVV(GameNumberNode);
  GameNumberNode(Range* r);
  vnode children(){return vnode{};};
  bool match_game(Game*game);
  void print();
};

class OriginNode:public SetBase{
 public:
  OriginNode(TagVariable*);
  TagVariable*variable{NULL};
  SquareMask getSquares(Game*game);
  CVV(OriginNode);
  vnode children(){return vnode{};}
  void print();
};

class CountSquaresNode:public MFilter, public Countable{
 private:
  int count{0};
 public:
  int getCount(){return count;}
  Range* range{NULL};
  SetBase* set{NULL};
  CVV(CountSquaresNode);
  bool match_count(Game*game, NumValue* value);
  void print();
  CountSquaresNode(SetBase* s,Range*r);
  vnode children() {return vnode{set};}
  virtual bool match_position(Game*game);
  void deepify(){set=set->clone();}
};


class AttackNode : public SetBase, public Countable{
 private:
  int count{0};
  void addcounts(pieceT piece, const pieceT*board, squareT square);
  void addslidingcounts(directionT direction, const pieceT*board, squareT square);
  void addknightcounts(const pieceT*board,squareT square);
  void addkingcounts(const pieceT*board,squareT square);
  void addpawncounts(pieceT pawn,const pieceT*board,squareT square);
  void addnonsliding(int fileoff,int rankoff,const pieceT*board,squareT square);
  int squarecounts[64]; //tmp

 public:
  SetBase* attacking{NULL};
  SetBase* attacked{NULL};
  Range* range{NULL};
  void print();
  int getCount(){return count;}
  bool match_position(Game*game);
  SquareMask getSquares(Game*game);
  vnode children();
  CVV(AttackNode);
  AttackNode(SetBase*s, SetBase*t, Range*r);
  void deepify(){attacking=attacking->clone();attacked=attacked->clone();}
  bool match_count(Game*game, NumValue* value);
  virtual bool isSet();
  virtual bool isCountable();
};

class OrNode: public SetBase{
 public:
  MFilter* clause1{NULL};
  MFilter* clause2{NULL};
  bool match_position(Game*g);
  OrNode(MFilter*c1, MFilter*c2);
  vnode children(){return vnode{clause1,clause2};}
  void print();
  CVV(OrNode);
  void deepify(){clause1=clause1->clone();clause2=clause2->clone();}
  SquareMask getSquares(Game*g);
  bool isSet();
};

class OnNode: public SetBase{
 public:
  SetBase* clause1{NULL};
  SetBase* clause2{NULL};
  SquareMask getSquares(Game*g);
  OnNode(SetBase* s1, SetBase* s2);
  vnode children(){return vnode{clause1,clause2};}
  void print();
  CVV(OnNode);
  void deepify(){clause1=clause1->clone();clause2=clause2->clone();}
};


class ExistsNode: public SetBase{
 private:
  bool match_filters(squareT,Game*);
 public:
  SquareVariable*variable{NULL};
  vector<MFilter*> filters;
  SetBase*target{NULL};
  CVV(ExistsNode);
  vnode children();
  SquareMask getSquares(Game*game);
  void print();
  ExistsNode(SquareVariable*v, SetBase*target, vector<Node*> nodes);
  void deepify(){clonevec(filters);if(target)target=target->clone();}
};


class ForallNode: public MFilter{
 public:
  SquareVariable*variable{NULL};
  SetBase*target{NULL};
  vector<MFilter*>filters;
  CVV(ForallNode);
  vnode children();
  bool match_position(Game*game);
  ForallNode(SquareVariable*v,SetBase*target,vector<Node*>nodes);
  void print();
  void deepify(){if(target)target=target->clone();clonevec(filters);}
};

class RayNode: public SetBase, public Countable{
 private:
  bool match_starting(squareT square, Direction direction, Game*game);
  int count{0};
  SquareMask matchedSoFar;
  vector<SquareMask> designatorMasks;
 public:
  vector<SetBase*> designators;
  vector<Direction>directions;
  bool isAttack{false};
  bool match_position(Game*game);
  RayNode(vector<Direction>directions,
	  vector<SetBase*> ds,
	  bool isattack,
	  Range*r);
  CVV(RayNode);
  void print();
  vnode children();
  Range*range{NULL};
  void deepify(){clonevec(designators);}
  void transform_members(Transform*t);
 bool match_count(Game*game, NumValue* value);
 SquareMask getSquares(Game*game);
 bool isSet();
 bool isCountable();
};


class AssignNode: public MFilter{
 public:
  NumericVariable* variable{NULL};
  Countable* node{NULL};
  bool match_position(Game*game);
  CVV(AssignNode);
  vnode children();
  void print();
  AssignNode(NumericVariable*, Node*);
  void deepify(){node=node->clone();}
};
  
  
class MoveBase:public SetBase, public VariationFlags{
 public:
  virtual vector<simpleMoveT*> getMoves(Game*game)=0;
  SetBase* from{NULL};
  SetBase* to{NULL};
  PieceLoc* promote{NULL};
  SetBase* enpassantsquare{NULL};
  bool primaryMove{false};
  bool secondaryMove{false};
  MoveBase(SetBase*from, SetBase* to, PieceLoc* promote,SetBase* enpassant,bool nullmove,bool mainline, bool variation);
  bool nullMove{false};
  void print();
  vnode children();
  bool match_position(Game*game);
  SquareMask getSquares(Game*game);
  bool match_move(simpleMoveT*move, Game* game);
  void deepify(){if(from) from=from->clone();if(to)to=to->clone();if(promote)promote=promote->clone();if(enpassantsquare)enpassantsquare=enpassantsquare->clone();}
};
  
class MovePastNode:public MoveBase{
 public:
  CVV(MovePastNode);
  vector<simpleMoveT*>getMoves(Game*game);
  MovePastNode(SetBase*from, SetBase*to, PieceLoc* promote, SetBase* enpassant,bool nullmove,bool mainline, bool variation);
};

class MoveFutureNode:public MoveBase{
 public:
  CVV(MoveFutureNode);
  MoveFutureNode(SetBase*from, SetBase*to, PieceLoc* promote, SetBase* enpassant,bool nullmove, bool mainline, bool variation);
  vector<simpleMoveT*>getMoves(Game*game);
  int requiredIndex=-1 ; // used by FutureNode: only examine this child
  simpleMoveT* requiredMove=NULL; // used by Future Node
};

class MoveLegalNode:public MoveBase{
 public:
  CVV(MoveLegalNode);
  MoveLegalNode(SetBase*from, SetBase*to, PieceLoc* promote, SetBase* enpassant,bool nullmove, bool mainline, bool variation);
  vector<simpleMoveT*>getMoves(Game*game);
};

class MoveNumberNode: public MFilter, public Countable {
 public:
  Range*range{NULL};
  CVV(MoveNumberNode);
  MoveNumberNode(Range*r);
  vnode children(){return vnode{};}
  bool match_position(Game*game);
  bool match_count(Game*game, NumValue*n);
  void print();
};

    

class CqlNode : public Node,public VariationFlags, public CommentFlags{
 public:
  MFilter* filter{NULL};
  vector<GameFilter*> gamefilters;
  vector<NumericVariable*> sortfields;
  int currentGameNumber{0};
  bool usemarks{false};
  const char* inputfile{NULL};
  const char* outputfile{NULL};
  FILE*outputstream{NULL};
  Range* nmatchesrange{NULL};
  Range* gamenumberrange{NULL};
  Range* matchCountRange{NULL};
  void setChildVariations(); //must be called after variationflags is set
  void match();
  bool match_game(Game*game);
  void do_match(MFilter*p, Game*game);
  void print();
  CVV(CqlNode);
  vnode children();
  CqlNode(vector<Node*> features,Node* node);
  virtual ~CqlNode() {}
  void run();
  void setUseMarks();
  void deepify(){filter=filter->clone();clonevec(gamefilters);}
  void setFirstComment(Game*game);
  void annotateEchoes(Game*game);
  GameSortInfo makeInfo(Game*game);
  static const char * outputFileFromCqlFile(const char* cqlfile);
};

class FutureStarNode : public MFilter, public Countable, public VariationFlags, public CommentFlags{
 private:
  int count{0};
  int depthMax{-1};
  void compute_counts(Game*game,vector<moveT*>&, int depth);
 public:
  MFilter* filter{NULL};
  Range* range{NULL};
  CVV(FutureStarNode);
  void print();
  int getCount(){return count;}
  bool match_count(Game*game, NumValue* value);
  vnode children(){return vnode{filter};}
  void deepify(){filter=filter->clone();}
  bool match_position(Game*game);
  FutureStarNode(Node*,Range*, int maxdepth);
};

class PastStarNode : public MFilter, public Countable, public CommentFlags{
 private:
  int count{0};
  void compute_counts(Game*game,vector<moveT*>&,int depth);
  int depthMax{-1};
 public:
  MFilter* filter{NULL};
  Range* range{NULL};
  CVV(PastStarNode);
  void print();
  int getCount(){return count;}
  bool match_count(Game*game, NumValue* value);
  vnode children(){return vnode{filter};}
  void deepify(){filter=filter->clone();}
  bool match_position(Game*game);
  PastStarNode(Node*,Range*,int depth);
};


class PieceIdNode : public SetBase{
 public:
  TagVariable*variable{NULL};
  SetBase* set{NULL};
  vector<MFilter*>filters;
  SquareMask getSquares(Game*game);
  CVV(PieceIdNode);
  void print();
  PieceIdNode(TagVariable *v, SetBase* set,vector<Node*>fs);
  vnode children();
  void deepify(){if(set)set=set->clone();clonevec(filters);}
};


class VectorNode : public SetBase{
 public:
  DirectionParameter parameter;
  SetBase* source{NULL};
  CVV(VectorNode);
  void print();
  vnode children();
  bool match_position(Game*game);
  SquareMask getSquares(Game*game);
  VectorNode(DirectionParameter dp,SetBase* source);
  void deepify(){source=source->clone();}
  void transform_members(Transform*);
 private:
  SquareMask neighborhoods[64];
  bool neighborhoodsvalid{false};
  void makeNeighborhoods();
  
};

class TransformNode: public SetBase, public Countable{
 private:
  TransformNode(vector<Transform*> ts,MFilter*f,Range*range);
 public:
  vector<Transform*> transforms;
  static TransformNode* create(vector<Transform*>, Node*, Range*);
  MFilter* filter{NULL};
  int count{0};
  Range*range{NULL};
  vector<MFilter*> transformedFilters;
  void print();
  vnode children();
  void expand();
  void deepify();
  void transform_in_place(Transform*t);
  bool expanded();
  SquareMask getSquares(Game*game);
  virtual bool isSet();
  virtual bool isCountable();
  CVV(TransformNode);
  vector<Transform*> getTransforms(){return transforms;}
  MFilter* getSource(){return filter;}
  bool match_position(Game*game);
  bool match_count(Game*game, NumValue*value);
};


class BetweenNode: public SetBase {
 public:
  SetBase* source{NULL};
  SetBase* target{NULL};
  void print();
  //  bool match_square(squareT square, Game*game);
  SquareMask getSquares(Game*game);
  CVV(BetweenNode);
  void deepify(){source=source->clone();target=target->clone();}
  vnode children(){return vnode{source,target};}
  BetweenNode(SetBase*s,SetBase*t);
};

class ExtensionNode:public MFilter{
 public:
  CVV(ExtensionNode);
  bool match_position(Game*game);
  vnode children(){return vnode{};}
  void print();
  ExtensionNode(){};
};

class PowerNode: public MFilter, public Countable {
 public:
  SetBase* set{NULL};
  Range*range{NULL};
  int power{-1000};
  void print();
  bool match_count(Game*game, NumValue*value);
  CVV(PowerNode);
  void deepify(){set=set->clone();}
  vnode children(){return vnode{set};}
  PowerNode(SetBase*s,Range*r);
  bool match_position(Game*game);
  static int pieceValue(pieceT p);
};

class PowerDifferenceNode: public MFilter, public Countable {
 public:
  PowerNode* power1{NULL};
  PowerNode* power2{NULL};
  Range*range{NULL};
  int powerdifference{-1000};
  void print();
  bool match_count(Game*game, NumValue*value);
  CVV(PowerDifferenceNode);
  void deepify(){power1=power1->clone();power2=power2->clone();}
  vnode children(){return vnode{power1,power2};}
  PowerDifferenceNode(SetBase*,SetBase*,Range*);
  bool match_position(Game*game);
  static int pieceValue(pieceT p);
};

class MatchCommentNode: public MFilter{
 public:
  const char* value{NULL};
  MatchCommentNode(const char* v);
  CVV(MatchCommentNode);
  void print();
  vnode children(){return vnode{};}
  bool match_position(Game*game);
};

class CommentBase: public MFilter{
 public:
  bool match_position(Game*game);
  virtual void printBuffer(Game*g,char*buffer)=0;
  static const int maxLen=200;
};

class CommentString:public CommentBase{
 public:
  void printBuffer(Game*g, char*buffer);
  const char*str;
  CommentString(const char*s);
  CVV(CommentString);
  vnode children(){return vnode{};}
  void print();
};

class CommentSet:public CommentBase{
 public:
  CommentSet(SetBase*);
  void printBuffer(Game*g,char*buffer);
  SetBase*set{NULL};
  CVV(CommentSet);
  void deepify(){set=set->clone();}
  vnode children(){return vnode{set};}
  void print();
};


#include "transform.h"
#include "seqconstituent.h"
#include "sequence.h"
class EchoNode;
class EchoSpec;
class EchoLcaSpec;
class EchoDistanceSpec;
class EchoSquareSpec;
class EchoMaxDistanceSpec;
class EchoSumDistanceSpec;
class EchoSourceDistanceSpec;
class EchoTargetDistanceSpec;
class EchoLongestSubstringSpec;
#include "echomatchinfo.h"
#include "echonode.h"
#include "echospec.h"
#undef CVV
