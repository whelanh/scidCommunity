#include "node.h"
void ExtensionNode::print(){
  printf("<%s>",thisclass());
}

bool ExtensionNode::match_position(Game*game){
  char buffer[5000];
  char*current=buffer;
  vector<simpleMoveT*>moves=MarkBoard::getLegalMoves(game);
  current+=sprintf(current,"Nlegal: %d ",(int)(moves.size()));
  for (int i=0;i<moves.size();++i){
    auto smt=moves[i];
    squareT fromsq=smt->from;
    squareT tosq=smt->to;
    char*fromname=square_to_string(fromsq);
    char*toname=square_to_string(tosq);
    current+=sprintf(current,"%d: %s-%s; ",i,fromname,toname);
  }
   MarkBoard::gameAppendComment(game,buffer);
   return true;
}  
    
		   

// bool ExtensionNode::match_position(Game*game){
//   char buffer[1000];
//   buffer[0]=0;
//   if(game->GetCurrentPly()==0)
//     sprintf(buffer,"STARTGAME");
//   else{
//     moveT* prev=game->CurrentMove->prev;
//     if(!prev)
//       sprintf(buffer,"NULL");
//     else if (prev->marker==START_MARKER)
// 	sprintf(buffer,"STARTMARKER");
//     else {
//       simpleMoveT* smt= &(prev->moveData);
//       squareT fromsq=smt->from;
//       squareT tosq=smt->to;
//       char*fromname=square_to_string(fromsq);
//       char*toname=square_to_string(tosq);
//       sprintf(buffer,"Prev: %s-%s",fromname,toname);
//     }
//   }
//   MarkBoard::gameAppendComment(game,buffer);
//   return true;
// }
      
  
