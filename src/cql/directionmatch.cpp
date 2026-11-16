#include "util.h"

vector<Direction> Direction::directionsFromString(const char*s){
  typedef Direction D;
  typedef vector<Direction>V;
  D up(0,1);
  D down(0,-1);
  D left(-1,0);
  D right(1,0);
  D northwest(-1,1);
  D northeast(1,1);
  D southwest(-1,-1);
  D southeast(1,-1);

  V diagonal{northwest,northeast,southwest,southeast};
  V orthogonal{up,down,left,right};
  V vertical{up,down};
  V maindiagonal{northeast,southwest};
  V horizontal{left,right};
  V offdiagonal{northwest,southeast};
  V anydirection{northwest,northeast,southwest,southeast,up,down,left,right};
  
 
#define X(q) if(strcmp(s,#q)==0) return vector<Direction>{q}

      X(up);
      X(down);
      X(left);
      X(right);
      X(northeast);
      X(northwest);
      X(southeast);
      X(southwest);

#define Y(q) if(strcmp(s,#q)==0) return vector<Direction>{q}
      Y(diagonal);
      Y(orthogonal);
      Y(vertical);
      Y(horizontal);
      Y(maindiagonal);
      Y(offdiagonal);
      Y(anydirection);
   
      return vector<Direction>{};
}
   
