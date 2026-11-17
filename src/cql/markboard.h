/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once

class MarkBoardMap{
 public:
  markT squares_to_marks[64];
  int marks_to_squares[32];
  void initialize(Game*game);
  void print();
  void verify(Game*game);
  const char*thisclass(){return "MarkBoardMap";}
  void make_move(squareT from, squareT to, const pieceT*board, colorT color);
  void make_null_move(squareT from, squareT to, const pieceT*board, colorT color);
};


  
class MarkBoard{
 private:
  MarkBoard(Game*game);
 public:
  //fields
  vector<MarkBoardMap>stack;
  MarkBoardMap map;
  Game * game;
  //member methods
  const char* thisclass(){return "MarkBoard";}
  void print();
  void MoveForward();
  void MoveToPly(int n);
  void MoveBackup();
  void initialize(Game *game);
  void verify();
  void popstate();
  void pushstate();
    //class variables
  static MarkBoard * globalMarkBoard;


  //static methods
  static void restart(); //delete current globalMarkBoard if any
  static int getSquare(markT mark);
  static markT getMark(int square);
  static simpleMoveT* getCurrentMove(Game*game);
  static moveT* identity(Game*game);
  static bool myIsNullMove(simpleMoveT*);
  static pieceT piece_at_square(squareT square, Game*game);
  static int number_children(Game*game, bool searchvariations);
  static void move_to_child(Game*game, int child);
  static void make_move(simpleMoveT*move,Game*game); 
  static vector<simpleMoveT*> getMoves(Game*g,bool searchvariations);
  static vector<simpleMoveT*> getLegalMoves(Game*g);
  static bool inMainline(Game*game);
  static bool inVariation(Game*game);
  static bool atVarEnd(Game*game);
  static bool atVarStart(Game*game);
  static MarkBoard * global();
  static void mark(Game*game);
  static void gameForward(Game*game);
  static void gameBackup(Game*game);
  static void gameSaveState(Game*game);
  static void gameRestoreState(Game*game);
  static void gameMoveToPly(Game*game, int ply); //ply must be 0
  static void MoveIntoVariation(Game*game, int i);
  static void gameToIdentity(moveT*id, Game*game, bool variations);
  static bool gameSeekIdDescendants(moveT*id, Game*game, bool variations);
  static void gameAppendComment(Game*game, const char* comment);
  static void gameAppendComment(Game*game, moveT* loc, const char* comment);
  static void gameToChild(moveT*id, Game*game, bool vars);
  };



