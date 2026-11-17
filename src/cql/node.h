/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
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

using vnode = vector<Node*>;
// Every node reports its class name for debug output and clones itself; the
// two functions come as a pair in nearly every subclass.
#define CVV(name) \
  const char* thisclass() override { return #name; } \
  name* clone() override

class Node : public Deleteable { //abstract
 public:
  static thread_local int ndisabled;
  bool disabled{false};
  void disable();
  bool annotateFlag{false};
  virtual void print(){printf("<%s>",thisclass());}
  virtual const char* thisclass()=0;
  virtual vnode children()=0;
  vnode descendants();
  void alldescendants(vnode*);
  static thread_local int counter;
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
  MFilter* clone() override=0;
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
  bool match_position(Game*game) override;
  virtual SquareMask getSquares(Game*game)=0;
  bool isSet() override{return true;}
  SetBase* clone() override=0;

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
  PieceLoc(const vector<PieceToken*>& piecetokens,
	   const vector<SquareToken*>& squaretokens,
	   const vector<VariableToken*>& variabletokens);
  static vector<pieceT>piecesFromChar(char c);
  void print() override;
  CVV(PieceLoc);
  vnode children() override{return vnode{};}
  bool match_piece(pieceT piece) const;
  bool isPurePiece() const;
  Variable* getAsVariable();
  void transform_members(Transform *) override;
  bool hasEmptySquareMask() override;
  SquareMask getSquares(Game*game) override;
  SquareMask getPieceMask(Game*game);
};

class GameFilter:public MFilter{ //abstract
 public:
  virtual bool match_game(Game*game)=0;
  bool match_position(Game*game) override{return match_game(game);}
  GameFilter*clone() override=0;
};



////////Simple keyword specs with no arguments, base class is KeywordNode, subclasses
///////are TransformNode, VariationsNode
class Childless : public Node{ //abstract
 public:
  vnode children() override{return vnode{};}
  Childless* clone() override=0;
};
  
class KeywordNode: public Childless{
 public:
  std::string value;
  explicit KeywordNode(std::string_view v);
  CVV(KeywordNode);
  void print() override;
  bool eq(const char*) const;
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
  SquareMask getSquares(Game* /*game*/) override{return SquareMask::all();}
  bool match_position(Game* /*game*/) override{return true;}
  vnode children() override{return vnode{};}
  CVV(AnyNode);
};


class SimpleNode:public MFilter { //no arg keywords corresponding to a filter, abstract
 public:
  SimpleNode*clone() override=0;
  vnode children() override{return vnode{};}
};

class CheckNode:public SimpleNode{
  CVV(CheckNode);
  bool match_position(Game*game) override;
};

class StalemateNode:public SimpleNode{
  CVV(StalemateNode);
  bool match_position(Game*) override;
};

class MateNode:public SimpleNode{
  CVV(MateNode);
  bool match_position(Game*) override;
};

class ColorNode:public MFilter{
 public:
  CVV(ColorNode);
  void print() override;
  bool match_position(Game*) override;
  colorT color;
  ColorNode(colorT c);
  vnode children() override{return vnode{};}
  void transform_members(Transform*) override;
};


class InitialNode:public SimpleNode{
  CVV(InitialNode);
  bool match_position(Game*) override;
};

class InVariationNode:public SimpleNode{
 public:
  CVV(InVariationNode);
  bool match_position(Game*game) override;
};

class BeginVariationNode:public SimpleNode{
 public:
  CVV(BeginVariationNode);
  bool match_position(Game*game) override;
};


class InMainlineNode:public SimpleNode{
 public:
  CVV(InMainlineNode);
  bool match_position(Game*game) override;
};



class TerminalNode:public SimpleNode{
  CVV(TerminalNode);
  bool match_position(Game*) override;
};

class NotNode:public SetBase{
 public:
  MFilter* filter{nullptr};
  CVV(NotNode);
  vnode children() override{return vnode{filter};}
  void print() override;
  NotNode(Node*np);
  bool match_position(Game*) override;
  void deepify() override{filter=filter->clone();}
  bool isSet() override;
  SquareMask getSquares(Game*) override;
};

class PositionNode: public MFilter{
 public:
  vector<MFilter*> specs;
  PositionNode(const vector<Node*>&);
  void print() override;
  bool variations{false};
  CVV(PositionNode);
  vnode children() override;
  bool match_position(Game*game) override;
  void deepify() override{clonevec(specs);}
};

class MatchCountNode: public Node{
 public:
  Range*range{nullptr};
  MatchCountNode(Range*,bool);
  bool sort{false};
  void print() override;
  vnode children() override{return vnode{};}
  CVV(MatchCountNode);
};

class PgnNode: public Node{
 public:
  explicit PgnNode(std::string_view v){value=v;}
  std::string value;
  CVV(PgnNode);
  void print() override;
  vnode children() override{return vnode{};}
};

class OutputNode: public Node{
 public:
  explicit OutputNode(std::string_view v){value=v;}
  std::string value;
  CVV(OutputNode);
  void print() override;
  vnode children() override{return vnode{};}
};

class ResultNode: public GameFilter{
 public:
  ResultNode(const char*v);
  resultT result{RESULT_None};
  void transform_members(Transform*t) override;
  CVV(ResultNode);
  void print() override;
  bool match_game(Game*game) override;
  vnode children() override{return vnode{};}
};

class PlayerNode: public GameFilter{
 public:
  std::string name;
  colorT color {NOCOLOR};
  vnode children() override{return vnode{};}
  bool match_game(Game*game) override;
  void print() override;
  CVV(PlayerNode);
  PlayerNode(std::string_view,colorT);
  void transform_members(Transform*) override;
};

class EventNode: public GameFilter{
 public:
  std::string name;
  vnode children() override{return vnode{};}
  bool match_game(Game*game) override;
  void print() override;
  CVV(EventNode);
  explicit EventNode(std::string_view);
};

class SiteNode: public GameFilter{
 public:
  std::string name;
  vnode children() override{return vnode{};}
  bool match_game(Game*game) override;
  void print() override;
  CVV(SiteNode);
  explicit SiteNode(std::string_view);
};


class EloNode: public GameFilter,public Countable{
 public:
  Range*range{nullptr};
  colorT color {NOCOLOR};
  vnode children() override{return vnode{};}
  bool match_game(Game*game) override;
  bool match_count(Game*game, NumValue*value) override;
  void print() override;
  CVV(EloNode);
  EloNode(Range*range,colorT);
  void transform_members(Transform*) override;
};

  
class YearNode: public GameFilter, public Countable{
 public:
  Range*range{nullptr};
  vnode children() override{return vnode{};}
  bool match_game(Game*game) override;
  bool match_count(Game*game, NumValue*value) override;
  void print() override;
  CVV(YearNode);
  YearNode(Range*range);
};

class GameNumberNode: public GameFilter{
 public:
  Range * range{nullptr};
  CVV(GameNumberNode);
  GameNumberNode(Range* r);
  vnode children() override{return vnode{};};
  bool match_game(Game*game) override;
  void print() override;
};

class OriginNode:public SetBase{
 public:
  OriginNode(TagVariable*);
  TagVariable*variable{nullptr};
  SquareMask getSquares(Game*game) override;
  CVV(OriginNode);
  vnode children() override{return vnode{};}
  void print() override;
};

class CountSquaresNode:public MFilter, public Countable{
 private:
  int count{0};
 public:
  int getCount() const{return count;}
  Range* range{nullptr};
  SetBase* set{nullptr};
  CVV(CountSquaresNode);
  bool match_count(Game*game, NumValue* value) override;
  void print() override;
  CountSquaresNode(SetBase* s,Range*r);
  vnode children() override {return vnode{set};}
  bool match_position(Game*game) override;
  void deepify() override{set=set->clone();}
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
  SetBase* attacking{nullptr};
  SetBase* attacked{nullptr};
  Range* range{nullptr};
  void print() override;
  int getCount() const{return count;}
  bool match_position(Game*game) override;
  SquareMask getSquares(Game*game) override;
  vnode children() override;
  CVV(AttackNode);
  AttackNode(SetBase*s, SetBase*t, Range*r);
  void deepify() override{attacking=attacking->clone();attacked=attacked->clone();}
  bool match_count(Game*game, NumValue* value) override;
  bool isSet() override;
  bool isCountable() override;
};

class OrNode: public SetBase{
 public:
  MFilter* clause1{nullptr};
  MFilter* clause2{nullptr};
  bool match_position(Game*g) override;
  OrNode(MFilter*c1, MFilter*c2);
  vnode children() override{return vnode{clause1,clause2};}
  void print() override;
  CVV(OrNode);
  void deepify() override{clause1=clause1->clone();clause2=clause2->clone();}
  SquareMask getSquares(Game*g) override;
  bool isSet() override;
};

class OnNode: public SetBase{
 public:
  SetBase* clause1{nullptr};
  SetBase* clause2{nullptr};
  SquareMask getSquares(Game*g) override;
  OnNode(SetBase* s1, SetBase* s2);
  vnode children() override{return vnode{clause1,clause2};}
  void print() override;
  CVV(OnNode);
  void deepify() override{clause1=clause1->clone();clause2=clause2->clone();}
};


class ExistsNode: public SetBase{
 private:
  bool match_filters(squareT,Game*);
 public:
  SquareVariable*variable{nullptr};
  vector<MFilter*> filters;
  SetBase*target{nullptr};
  CVV(ExistsNode);
  vnode children() override;
  SquareMask getSquares(Game*game) override;
  void print() override;
  ExistsNode(SquareVariable*v, SetBase*target, const vector<Node*>& nodes);
  void deepify() override{clonevec(filters);if(target)target=target->clone();}
};


class ForallNode: public MFilter{
 public:
  SquareVariable*variable{nullptr};
  SetBase*target{nullptr};
  vector<MFilter*>filters;
  CVV(ForallNode);
  vnode children() override;
  bool match_position(Game*game) override;
  ForallNode(SquareVariable*v,SetBase*target,const vector<Node*>& nodes);
  void print() override;
  void deepify() override{if(target)target=target->clone();clonevec(filters);}
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
  bool match_position(Game*game) override;
  RayNode(vector<Direction>directions,
	  vector<SetBase*> ds,
	  bool isattack,
	  Range*r);
  CVV(RayNode);
  void print() override;
  vnode children() override;
  Range*range{nullptr};
  void deepify() override{clonevec(designators);}
  void transform_members(Transform*t) override;
 bool match_count(Game*game, NumValue* value) override;
 SquareMask getSquares(Game*game) override;
 bool isSet() override;
 bool isCountable() override;
};


class AssignNode: public MFilter{
 public:
  NumericVariable* variable{nullptr};
  Countable* node{nullptr};
  bool match_position(Game*game) override;
  CVV(AssignNode);
  vnode children() override;
  void print() override;
  AssignNode(NumericVariable*, Node*);
  void deepify() override{node=node->clone();}
};
  
  
class MoveBase:public SetBase, public VariationFlags{
 public:
  virtual vector<simpleMoveT*> getMoves(Game*game)=0;
  SetBase* from{nullptr};
  SetBase* to{nullptr};
  PieceLoc* promote{nullptr};
  SetBase* enpassantsquare{nullptr};
  bool primaryMove{false};
  bool secondaryMove{false};
  MoveBase(SetBase*from, SetBase* to, PieceLoc* promote,SetBase* enpassant,bool nullmove,bool mainline, bool variation);
  bool nullMove{false};
  void print() override;
  vnode children() override;
  bool match_position(Game*game) override;
  SquareMask getSquares(Game*game) override;
  bool match_move(simpleMoveT*move, Game* game);
  void deepify() override{if(from) from=from->clone();if(to)to=to->clone();if(promote)promote=promote->clone();if(enpassantsquare)enpassantsquare=enpassantsquare->clone();}
};
  
class MovePastNode:public MoveBase{
 public:
  CVV(MovePastNode);
  vector<simpleMoveT*>getMoves(Game*game) override;
  MovePastNode(SetBase*from, SetBase*to, PieceLoc* promote, SetBase* enpassant,bool nullmove,bool mainline, bool variation);
};

class MoveFutureNode:public MoveBase{
 public:
  CVV(MoveFutureNode);
  MoveFutureNode(SetBase*from, SetBase*to, PieceLoc* promote, SetBase* enpassant,bool nullmove, bool mainline, bool variation);
  vector<simpleMoveT*>getMoves(Game*game) override;
  int requiredIndex=-1 ; // used by FutureNode: only examine this child
  simpleMoveT* requiredMove=nullptr; // used by Future Node
};

class MoveLegalNode:public MoveBase{
 public:
  CVV(MoveLegalNode);
  MoveLegalNode(SetBase*from, SetBase*to, PieceLoc* promote, SetBase* enpassant,bool nullmove, bool mainline, bool variation);
  vector<simpleMoveT*>getMoves(Game*game) override;
};

class MoveNumberNode: public MFilter, public Countable {
 public:
  Range*range{nullptr};
  CVV(MoveNumberNode);
  MoveNumberNode(Range*r);
  vnode children() override{return vnode{};}
  bool match_position(Game*game) override;
  bool match_count(Game*game, NumValue*n) override;
  void print() override;
};

    

class CqlNode : public Node,public VariationFlags, public CommentFlags{
 public:
  MFilter* filter{nullptr};
  vector<GameFilter*> gamefilters;
  vector<NumericVariable*> sortfields;
  int currentGameNumber{0};
  bool usemarks{false};
  std::string inputfile;
  std::string outputfile;
  FILE*outputstream{nullptr};
  Range* nmatchesrange{nullptr};
  Range* gamenumberrange{nullptr};
  Range* matchCountRange{nullptr};
  void setChildVariations(); //must be called after variationflags is set
  void match();
  bool match_game(Game*game);
  void do_match(MFilter*p, Game*game);
  void print() override;
  CVV(CqlNode);
  vnode children() override;
  CqlNode(const vector<Node*>& features,Node* node);
  ~CqlNode() override = default;
  void run();
  void setUseMarks();
  void deepify() override{filter=filter->clone();clonevec(gamefilters);}
  void setFirstComment(Game*game);
  void annotateEchoes(Game*game);
  GameSortInfo makeInfo(Game*game);
  static std::string outputFileFromCqlFile(const char* cqlfile);
};

class FutureStarNode : public MFilter, public Countable, public VariationFlags, public CommentFlags{
 private:
  int count{0};
  int depthMax{-1};
  void compute_counts(Game*game,vector<moveT*>&, int depth);
 public:
  MFilter* filter{nullptr};
  Range* range{nullptr};
  CVV(FutureStarNode);
  void print() override;
  int getCount() const{return count;}
  bool match_count(Game*game, NumValue* value) override;
  vnode children() override{return vnode{filter};}
  void deepify() override{filter=filter->clone();}
  bool match_position(Game*game) override;
  FutureStarNode(Node*,Range*, int maxdepth);
};

class PastStarNode : public MFilter, public Countable, public CommentFlags{
 private:
  int count{0};
  void compute_counts(Game*game,vector<moveT*>&,int depth);
  int depthMax{-1};
 public:
  MFilter* filter{nullptr};
  Range* range{nullptr};
  CVV(PastStarNode);
  void print() override;
  int getCount() const{return count;}
  bool match_count(Game*game, NumValue* value) override;
  vnode children() override{return vnode{filter};}
  void deepify() override{filter=filter->clone();}
  bool match_position(Game*game) override;
  PastStarNode(Node*,Range*,int depth);
};


class PieceIdNode : public SetBase{
 public:
  TagVariable*variable{nullptr};
  SetBase* set{nullptr};
  vector<MFilter*>filters;
  SquareMask getSquares(Game*game) override;
  CVV(PieceIdNode);
  void print() override;
  PieceIdNode(TagVariable *v, SetBase* set,const vector<Node*>& fs);
  vnode children() override;
  void deepify() override{if(set)set=set->clone();clonevec(filters);}
};


class VectorNode : public SetBase{
 public:
  DirectionParameter parameter;
  SetBase* source{nullptr};
  CVV(VectorNode);
  void print() override;
  vnode children() override;
  bool match_position(Game*game) override;
  SquareMask getSquares(Game*game) override;
  VectorNode(DirectionParameter dp,SetBase* source);
  void deepify() override{source=source->clone();}
  void transform_members(Transform*) override;
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
  MFilter* filter{nullptr};
  int count{0};
  Range*range{nullptr};
  vector<MFilter*> transformedFilters;
  void print() override;
  vnode children() override;
  void expand() override;
  void deepify() override;
  void transform_in_place(Transform*t) override;
  bool expanded() const;
  SquareMask getSquares(Game*game) override;
  bool isSet() override;
  bool isCountable() override;
  CVV(TransformNode);
  vector<Transform*> getTransforms() const{return transforms;}
  MFilter* getSource() const{return filter;}
  bool match_position(Game*game) override;
  bool match_count(Game*game, NumValue*value) override;
};


class BetweenNode: public SetBase {
 public:
  SetBase* source{nullptr};
  SetBase* target{nullptr};
  void print() override;
  //  bool match_square(squareT square, Game*game);
  SquareMask getSquares(Game*game) override;
  CVV(BetweenNode);
  void deepify() override{source=source->clone();target=target->clone();}
  vnode children() override{return vnode{source,target};}
  BetweenNode(SetBase*s,SetBase*t);
};

class ExtensionNode:public MFilter{
 public:
  CVV(ExtensionNode);
  bool match_position(Game*game) override;
  vnode children() override{return vnode{};}
  void print() override;
  ExtensionNode() = default;
};

class PowerNode: public MFilter, public Countable {
 public:
  SetBase* set{nullptr};
  Range*range{nullptr};
  int power{-1000};
  void print() override;
  bool match_count(Game*game, NumValue*value) override;
  CVV(PowerNode);
  void deepify() override{set=set->clone();}
  vnode children() override{return vnode{set};}
  PowerNode(SetBase*s,Range*r);
  bool match_position(Game*game) override;
  static int pieceValue(pieceT p);
};

class PowerDifferenceNode: public MFilter, public Countable {
 public:
  PowerNode* power1{nullptr};
  PowerNode* power2{nullptr};
  Range*range{nullptr};
  int powerdifference{-1000};
  void print() override;
  bool match_count(Game*game, NumValue*value) override;
  CVV(PowerDifferenceNode);
  void deepify() override{power1=power1->clone();power2=power2->clone();}
  vnode children() override{return vnode{power1,power2};}
  PowerDifferenceNode(SetBase*,SetBase*,Range*);
  bool match_position(Game*game) override;
  static int pieceValue(pieceT p);
};

class MatchCommentNode: public MFilter{
 public:
  std::string value;
  explicit MatchCommentNode(std::string_view v);
  CVV(MatchCommentNode);
  void print() override;
  vnode children() override{return vnode{};}
  bool match_position(Game*game) override;
};

class CommentBase: public MFilter{
 public:
  bool match_position(Game*game) override;
  virtual std::string printBuffer(Game*g)=0;
  static const int maxLen=200;
};

class CommentString:public CommentBase{
 public:
  std::string printBuffer(Game*g) override;
  std::string str;
  explicit CommentString(std::string_view s);
  CVV(CommentString);
  vnode children() override{return vnode{};}
  void print() override;
};

class CommentSet:public CommentBase{
 public:
  CommentSet(SetBase*);
  std::string printBuffer(Game*g) override;
  SetBase*set{nullptr};
  CVV(CommentSet);
  void deepify() override{set=set->clone();}
  vnode children() override{return vnode{set};}
  void print() override;
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
