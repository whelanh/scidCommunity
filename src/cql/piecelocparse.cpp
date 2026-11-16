#include "util.h"
#include <ctype.h>
#include "lexer.h"

//piecedesignator= squarespecifier | piecespecifier squarespecifier?
PieceDesignatorToken* match_piecedesignator(char* input){
  if(!strcmp(input,"darksquares"))
    return match_piecedesignator("[a1,a3,a5,a7,b2,b4,b6,b8,c1,c3,c5,c7,d2,d4,d6,d8,e1,e3,e5,e7,f2,f4,f6,f8,g1,g3,g5,g7,h2,h4,h6,h8]");
  else if(!strcmp(input,"lightsquares"))
    return match_piecedesignator("[a2,a4,a6,a8,b1,b3,b5,b7,c2,c4,c6,c8,d1,d3,d5,d7,e2,e4,e6,e8,f1,f3,f5,f7,g2,g4,g6,g8,h1,h3,h5,h7]");
  vector<PieceToken*>pieces; //disjunctive
  vector<SquareToken*>squares; //disjunctive
  vector<VariableToken*>variables; //conjunctive
  char* current=input;
  bool seeninitialsquare=match_squarespecifier(&current,&squares);
  // printf("mpd: input: %s\n",input);
  // printf("mpd: seeninitialsquare: %d\n",seeninitialsquare);
  if(!seeninitialsquare){
    match_piecespecifier(&current,&pieces);
    // printf("mpd: current after match_ps: %s and npieces: %lu\n",current,pieces.size());
    match_squarespecifier(&current,&squares); //a failed match is taken as an empty string
    // printf("mpd: current after match_ss: %s and nsquares: %lu\n",current,squares.size());
  }
  match_variables(&current,&variables);
  // printf("mpd: current after match_vs: %s and nvars: %lu\n",current,variables.size());
  if(*current) return NULL; // expect end of string in a piece designator here
  if(pieces.empty()&&squares.empty()&&variables.empty()) return NULL;
  if(pieces.empty()) pieces.push_back(new PieceToken('?'));
  if(squares.empty())squares.push_back(new SquareToken(0,7,0,7));
  // printf("mpd: calling pdt with sizes: pieces: %lu, squares: %lu, vars: %lu\n",
  // 	 pieces.size(),
  // 	 squares.size(),
  // 	 variables.size());
  return new PieceDesignatorToken(pieces,squares,variables);
}

void match_variables(char**inputp,vector<VariableToken*>*varsp){
  char* current=*inputp;
  while(true){
    VariableToken* t=match_variable(&current);
    if(!t) return;
    varsp->push_back(t);
    *inputp=current;
  }
}
//piecespecifer= singlepiecespecifier |  compoundpiecespecifier 
bool match_piecespecifier(char**inputp,vector<PieceToken*>*pieces){
  PieceToken*t=match_singlepiecespecifier(inputp);
  if(t) {
    pieces->push_back(t);
    return true;
  }
  if(match_compoundpiecespecifier(inputp,pieces))
    return true;
  return false;
}

//singlepiecespecifier= simplepiecespecifier | tagname
PieceToken* match_singlepiecespecifier(char**inputp){
  return match_simplepiecespecifier(inputp);
}

//simplepiecespecifier= R | N | ... | '?' | '_'
PieceToken* match_simplepiecespecifier(char**inputp){
  char*input= *inputp;
  uassert(input);
  char c=input[0];
  PieceToken* st=PieceToken::create(c);
  if(!st)return NULL;
  *inputp=*inputp + 1;
  return st;
}

bool match_singlepiecespecifierplus(char**inputp,vector<PieceToken*>*piecesp){
  char*current=*inputp;
  vector<PieceToken*>pieces;
  PieceToken*t=match_singlepiecespecifier(&current);
  if(!t)return false;
  pieces.push_back(t);
  match_singlepiecespecifierplus(&current,&pieces);
  *inputp=current;
  for(auto p: pieces) piecesp->push_back(p);
  return true;
}
  
//compoundpiecespecifier = '[' singlepiecespecifier+ ']'
bool match_compoundpiecespecifier(char**inputp,vector<PieceToken*>*piecesp){
  vector<PieceToken*>pieces;
  char*current=*inputp;
  if(!(match_char(&current,'['))) return false;
  if(!match_singlepiecespecifierplus(&current,&pieces))
    return false;
  if(!match_char(&current,']')) return false;
  *inputp=current;
  for(auto p:pieces) piecesp->push_back(p);
  return true;
}


bool match_alphanums(char**inputp, char* result, int maxlength){
  char*current=*inputp;
  int len=0;
  while(isalnum(current[len])){
    if(len>=maxlength){
      printf("error\n");
      uassert(false,"matchalphanums");
    }
    ++len;
  }
  if(len==0) return false;
  uassert(len<maxlength);
  for(int i=0;i<len;++i)
    result[i]=current[i];
  result[len]=0;
  *inputp=current+len;
  return true;
}

bool match_char(char**inputp,char c){
  char*current=*inputp;
  uassert(current);
  if(current[0]==c){
    *inputp= *inputp+1;
    return true;}
  return false;
}

//squarespecifier= blocksquarespecifier | compoundsquarespecifier
bool match_squarespecifier(char**inputp, vector<SquareToken*>*squaresp){
  SquareToken* t=match_blocksquarespecifier(inputp);
  if(t){
    squaresp->push_back(t);
    return true;}

  if(match_compoundsquarespecifier(inputp,squaresp))
    return true;

  return false;
}

//file = [a-h]
bool match_file(char**inputp,int * result){
  char*current=*inputp;
  uassert(current);
  char f=current[0];
  if(f>='a'&&f<='h'){
    *result=f-'a';
    *inputp=current+1;
    return true;
  }
  return false;
}

//rank= [1-8]
bool match_rank(char**inputp,int * result){
  char*current=*inputp;
  uassert(current);
  char r=current[0];
  if(r>='1'&&r<='8'){
    *result=r-'1';
    *inputp=current+1;
    return true;
  }
  return false;
}
  
//simplesquarespecifer=files ranks
SquareToken* match_simplesquarespecifier(char**inputp){
  int minf=-1,maxf=-1,minr=-1,maxr=-1;
  char*current=*inputp;
  if(match_files(&current,&minf,&maxf))
    if(match_ranks(&current,&minr,&maxr)){
      *inputp=current;
      return new SquareToken(minf,maxf,minr,maxr);
    }
  return NULL;
}
	
// blocksquarespecifier= bindingsquarespecifier  | simplesquarespecifier
SquareToken* match_blocksquarespecifier(char**inputp){
  return match_simplesquarespecifier(inputp);
 }

//compoundsquarespecifier= '[' blocksquarespecifier commasquares ']'
bool match_compoundsquarespecifier(char**inputp,vector<SquareToken*>*squaresp){
  char*current=*inputp;
  if(!match_char(&current,'[')) return false;
  vector<SquareToken*>squares;
  SquareToken* t=match_blocksquarespecifier(&current);
  if(!t)return false;
  squares.push_back(t);
  if(!match_commasquares(&current,&squares)) return false;
  if(!match_char(&current,']')) return false;
  for(auto s:squares) squaresp->push_back(s);
  *inputp=current;
  return true;
}

//commasquares= ',' blocksquarespecifier commasquares
bool match_commasquares(char**input,vector<SquareToken*>*squaresp){
  char*current=*input;
  vector<SquareToken*> squares;
  if(!match_char(&current,',')) return true;
  SquareToken *t=match_blocksquarespecifier(&current);
  if(!t) return true;
  squares.push_back(t);
  match_commasquares(&current,&squares);
  for(auto s:squares)squaresp->push_back(s);
  *input=current;
  return true;
}
  

//files=	filerange | file
bool match_files(char**inputp,int*min,int *max){
  if(match_filerange(inputp,min,max))
    return true;
  if(match_file(inputp,min)){
    *max=*min;
    return true;
  }
  return false;
}

//filerange= file '-' file
bool match_filerange(char**inputp,int*min,int*max){
  char*current=*inputp;
  int lmin=-1,lmax=-1;
  if(!match_file(&current,&lmin))return false;
  if(!match_char(&current,'-')) return false;
  if(!match_file(&current,&lmax))return false;
  *min=lmin;
  *max=lmax;
  *inputp=current;
  uassert(lmin<=lmax,"Unexpected filerange",*inputp);
  return true;
}

bool match_ranks(char**inputp,int*min,int *max){
  if(match_rankrange(inputp,min,max))
    return true;
  if(match_rank(inputp,min)){
    *max=*min;
    return true;
  }
  return false;
}

//rankrange= rank '-' rank
bool match_rankrange(char**inputp,int*min,int*max){
  char*current=*inputp;
  int lmin=-1,lmax=-1;
  if(!match_rank(&current,&lmin))return false;
  if(!match_char(&current,'-')) return false;
  if(!match_rank(&current,&lmax))return false;
  *min=lmin;
  *max=lmax;
  *inputp=current;
  uassert(lmin<=lmax,"Unexpected rankrange",*inputp);
  return true;
}

		 
VariableToken* match_variable(char**inputp){
  char*current=*inputp;
  char*name=new char[42];
  uassert(current);
  if(!match_char(&current,'$')) return NULL;
  name[0]='$';
  if(!match_alphanums(&current,name+1,40))
    return NULL;
  *inputp=current;
  return new VariableToken(name);
}
  
VariableToken* match_variable(char*input){
  char*current=input;
  VariableToken *t=match_variable(&current);
  if(t==NULL||*current) return NULL;
  return t;
}



