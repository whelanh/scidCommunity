#pragma once
class SquareVariable;
class TagVariable;
class NumericVariable;
typedef int NumValue;

class Variable{
 public:
  const char*name{NULL};
  bool eq(const char*name);
  bool bound{false};
  virtual bool isSquare()const {return false;}
  virtual bool isTag()const {return false;}
  virtual bool isNumeric() const{return false;}
  bool isBound() const{return bound;}
  bool isUnbound()const {return !isBound();}
  virtual void print()=0;
  virtual const char* thisclass()=0;;
  static Variable* find(const char*name);
  virtual bool getSquare(squareT*s)=0; // now that we have numerics this should be taken out
  static vector<Variable*>* theVariables;
  static vector<Variable*>*getVariables();
  static SquareVariable* createSquareVariable(const char*n);
  static TagVariable* createTagVariable(const char*n);
  static NumericVariable* createNumericVariable(const char*n,bool ismax);
  static SquareVariable* getSquareVariable(const char*n);
  static TagVariable* getTagVariable(const char*n);
  static NumericVariable* getNumericVariable(const char*n,bool ismax);
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
  bool isSquare() const {return true;}
  void print();
  const char*thisclass() {return "SquareVariable";}
  SquareVariable(const char*nm);
  bool getSquare(squareT*s);
  void bindSquare(squareT s);
};

class TagVariable:public Variable{
 private: markT tag{-1};
 private: squareT origin{65};
 public:
  bool isTag() const {return true;}
  void print();
  const char*thisclass(){return "TagVariable";}
  TagVariable(const char* name);
  bool getSquare(squareT*s);
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
  bool getSquare(squareT*s); //for compilation, calls a stub
  NumericVariable(const char* nm, bool ismax);
  bool isNumeric()const {return true;}
  bool isMax()const {return theIsMax;}
  bool isMin()const {return !isMax();}
  void print();
  const char* thisclass(){return "NumericVariable";}
  NumValue getValue()const;
  virtual NumValue getExtremalValue();
  void clear();
  void bindNumeric(NumValue v);
  static void resetAll();
  void reset();
};

bool operator< (const NumericVariable& lhs, const NumericVariable& rhs);
