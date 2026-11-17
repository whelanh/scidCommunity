/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
#include <string>
#include <string_view>
class SquareVariable;
class TagVariable;
class NumericVariable;
using NumValue = int;

class Variable{
 public:
  virtual ~Variable() = default;
  std::string name;
  bool eq(std::string_view name) const;
  bool bound{false};
  virtual bool isSquare()const {return false;}
  virtual bool isTag()const {return false;}
  virtual bool isNumeric() const{return false;}
  bool isBound() const{return bound;}
  bool isUnbound()const {return !isBound();}
  virtual void print()=0;
  virtual const char* thisclass()=0;
  static Variable* find(std::string_view name);
  virtual bool getSquare(squareT*s)=0; // now that we have numerics this should be taken out
  static thread_local vector<Variable*>* theVariables;
  static vector<Variable*>*getVariables();
  static void clearAll();
  static SquareVariable* createSquareVariable(std::string_view n);
  static TagVariable* createTagVariable(std::string_view n);
  static NumericVariable* createNumericVariable(std::string_view n,bool ismax);
  static SquareVariable* getSquareVariable(std::string_view n);
  static TagVariable* getTagVariable(std::string_view n);
  static NumericVariable* getNumericVariable(std::string_view n,bool ismax);
  void unbind();
  static void unbindTags();
  static NumericVariable* matchCountVariable();
  
};

class SquareVariable:public Variable{
 private:
  squareT square{65};
  bool used{false};
 
 public:
  bool isUsed()const {return used;}
  bool isSquare() const override {return true;}
  void print() override;
  const char*thisclass() override {return "SquareVariable";}
  explicit SquareVariable(std::string_view nm);
  bool getSquare(squareT*s) override;
  void bindSquare(squareT s);
};

class TagVariable:public Variable{
 private: markT tag{-1};
 private: squareT origin{65};
 public:
  bool isTag() const override {return true;}
  void print() override;
  const char*thisclass() override{return "TagVariable";}
  explicit TagVariable(std::string_view name);
  bool getSquare(squareT*s) override;
  squareT getOrigin();
  void bindTag(int t);
};
  

class NumericVariable:public Variable{
 private:
  NumValue value{0};
  NumValue extremalValue{0};
  bool theIsMax{false};
 public:
  void increment();
  NumValue extremeValue()const;
  bool getSquare(squareT*s) override; //for compilation, calls a stub
  explicit NumericVariable(std::string_view nm, bool ismax);
  bool isNumeric()const override {return true;}
  bool isMax()const {return theIsMax;}
  bool isMin()const {return !isMax();}
  void print() override;
  const char* thisclass() override{return "NumericVariable";}
  NumValue getValue()const;
  virtual NumValue getExtremalValue();
  void clear();
  void bindNumeric(NumValue v);
  static void resetAll();
  void reset();
};

bool operator< (const NumericVariable& lhs, const NumericVariable& rhs);
