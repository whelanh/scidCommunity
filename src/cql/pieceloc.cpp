#include "node.h"
 
PieceLoc::PieceLoc(vector<PieceToken*>pts,
		   vector<SquareToken*>sts,
		   vector<VariableToken*>vartokens){
  vector<squareT> squares;
  uassert(pts.size()&&sts.size());
  for (PieceToken* pt : pts){
    uassert(pt);
    vector<pieceT> v=piecesFromChar(pt->value);
    for (pieceT p : v){
      uassert(piece_valid(p));
      pieces.insert((squareT)p);
    }
  }

  for(SquareToken* st : sts){
    uassert(st);
    for (int file=st->minfile; file<=st->maxfile;++file)
      for(int rank=st->minrank;rank<=st->maxrank;++rank){
	uassert(file_valid(file)&&rank_valid(rank));
	squareT square=square_make(file,rank);
	uassert(square_file(square)==file&&square_rank(square)==rank);
	uassert(square_valid(square));
	squares.push_back(square); 
      }// for file..//for rank
  }//for each squaretoken
  squaremask=SquareMask(squares);
  for(VariableToken*vt: vartokens){
    uassert(vt,"internal pieceloc");
    const char*name=vt->value;
    uassert(name,"internal name pieceloc");
    Variable* v=Variable::find(name);
    if(!v) v=Variable::getSquareVariable(name);
    uassert(v,"internal pieceloc var");
    variables.push_back(v);
  }
}
    
void PieceLoc::print(){
  // if(1){
  //   printf("print called on pieceloc %p with variables size: %lu\n",this,variables.size());
  // }
  uassert(pieces.nonempty());
  if(pieces.size()>1)
    printf("[");
  for(int p =0;p<64;++p) if(pieces.member(p)){
      uassert(piece_valid((pieceT)p));
      printf("%c", piece_to_char((pieceT)p));
    }
  if(pieces.size()>1)
    printf("]");
  squaremask.print();
  for(Variable* v:variables){
    //    printf("pl::print has got a variable at: %p\n",v);
    //    printf("its class is: %s\n",v->thisclass());
    v->print();
  }
}

vector<pieceT> PieceLoc::piecesFromChar(char c){
  vector<pieceT> r{BR};
  vector<pieceT> n{BN};
  vector<pieceT> b{BB};
  vector<pieceT> q{BQ};
  vector<pieceT> k{BK};
  vector<pieceT> p{BP};
  vector<pieceT> R{WR};
  vector<pieceT> N{WN};
  vector<pieceT> B{WB};
  vector<pieceT> Q{WQ};
  vector<pieceT> K{WK};
  vector<pieceT> P{WP};
  vector<pieceT> A{WR,WN,WB,WQ,WK,WP};
  vector<pieceT> a{BR,BN,BB,BQ,BK,BP};
  vector<pieceT> dot{EMPTY};
  vector<pieceT> U;
  U.insert(U.end(),A.begin(),A.end());
  U.insert(U.end(),a.begin(),a.end());
  vector<pieceT> questionmark{U};
  questionmark.push_back(EMPTY);

  switch(c){
  case 'r': return r;
  case 'R': return R;
  case 'n': return n;
  case 'N': return N;
  case 'b': return b;
  case 'B': return B;
  case 'q': return q;
  case 'Q': return Q;
  case 'k': return k;
  case 'K': return K;
  case 'p': return p;
  case 'P': return P;
  case 'A': return A;
  case 'a': return a;
  case 'U': return U;
  case '_': return dot;
  case '?': return questionmark;
  };
  uassert(false,"invalid piece character");
  return U;
};

bool PieceLoc::isPurePiece(){
  if (pieces.size()==0 ||
      variables.size()>0||
      squaremask.size()<64)
    return false;
  return true;
}

bool PieceLoc::hasEmptySquareMask(){
  return squaremask.empty();
}
