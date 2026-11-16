#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <tcl.h>
#include "node.h"
#include "parser.h"

void printhelp();
int Cql_InitTcl(Tcl_Interp * interp);
CqlNode* pNode;

int main(int argc, char*argv[]){
  cql_initialize();
  printf("CQL version %s (build %s) (c) Gady Costeff and Lewis Stiller\n",
	 CqlVersion,
	 CqlBuild);
  parseargs(argc,argv);
  printf("CQL: reading CQL file: %s\n",CqlFilename);
  pNode=parseFile(CqlFilename);
  if(!pNode){
    fprintf(stderr,"CQL: unable to parse file: %s\n",CqlFilename);
    exit(1);
  }
  if(CqlShowParse){
    pNode->print();
    printf("\n");
  }
  if(!CqlParseOnly) {
    Tcl_Main(argc, argv, Cql_InitTcl);  // never returns
    //exit(0);
  }
}

	      
int Cql_InitTcl(Tcl_Interp * ti) {

  if (Tcl_Init(ti) == TCL_ERROR) { return TCL_ERROR; }

  pNode->match();  // off to match games against the CQL script
  exit (0);  // no need to return to an interactive interpreter

  // return TCL_OK;
}

	
void parseargs(int argc, char*argv[]){
  int nextarg=0;
  if(argc==1){
    printhelp();
    exit(0);
  }
  while (++nextarg<argc){
    char*current=argv[nextarg];
    if(current==NULL || strlen(current)==0) break;
    else if (!strcmp(current,"-d") || !strcmp(current,"--debug"))
      CqlDebug=1;
    else if (!strcmp(current,"--parse")) {
	CqlParseOnly=true;
	CqlShowParse=true;
	CqlShowLex=true;
	CqlDebug=true;
      }
    else if (!strcmp(current,"--pgn")
	     ||!strcmp(current,"-i")
	     ||!strcmp(current,"--input")){
	++nextarg;
	uassert(nextarg<argc,"CQL command line: missing input file argument");
	CqlPgnFilename=argv[nextarg];
      uassert(filename_is_pgn(CqlPgnFilename),"invalid pgn input filename from command line", CqlPgnFilename);
    }
    else if (!strcmp(current,"--nolinearize"))
      CqlDoNotLinearize=true;
    else if (!strcmp(current,"--output")||!strcmp(current,"-o")){
      ++nextarg;
      uassert(nextarg<argc,"CQL command line: missing output file argument");
      CqlOutputFilename=argv[nextarg];
      uassert(CqlOutputFilename,"missing output file");
      uassert(filename_is_pgn(CqlOutputFilename),"bad output filenemame from command line", CqlOutputFilename);
    }
    else if (!strcmp(current,"--player")){
      ++nextarg;
      uassert(nextarg<argc,"CQL command line: missing player argument");
      CqlPlayer=argv[nextarg];
      uassert(CqlPlayer,"missing player");
    }
    else if (!strcmp(current,"-g")||!strcmp(current,"--gamenumber")||!strcmp(current,"--game")){
      ++nextarg;
      uassert(nextarg<argc,"CQL command line: missing gamenumber");
      int gamestart=0;
      int gamestop=0;
      if (!util::positiveIntValue(argv[nextarg],&gamestart))
	uassert(false,"expected positive integer following -g or --game");
      uassert(gamestart>0,"internal");
      if(nextarg+1<argc&& util::positiveIntValue(argv[nextarg+1],&gamestop))
	nextarg++;
      if (gamestop==0) gamestop=gamestart;
      CqlGameNumberRange=new Range(gamestart,gamestop);
    }
    else if (!strcmp(current,"--year")){
      ++nextarg;
      uassert(nextarg<argc,"CQL command line: missing year");
      int yearstart=0;
      int yearstop=0;
      if (!util::positiveIntValue(argv[nextarg],&yearstart))
	uassert(false,"expected positive integer following --year");
      uassert(yearstart>0,"internal");
      if(nextarg+1<argc&& util::positiveIntValue(argv[nextarg+1],&yearstop))
	nextarg++;
      if (yearstop==0) yearstop=yearstart;
      CqlYearRange=new Range(yearstart,yearstop);
    }
    else if (!strcmp(current,"--silent")){
      CqlSilent=true;
    }
    else if (!strcmp(current,"-h")|| !strcmp (current,"--help")){
      printhelp();
      exit(0);
    }
    else if (current[0]=='-'){
      fprintf(stderr, "CQL: invalid option: %s. Printing help: \n",current);
      printhelp();
      exit(1);
    }
    else{
    uassert(!CqlFilename,"cql command line: got two CQL filenames, last one is ", current);
    CqlFilename=current;
    if(!filename_extension(CqlFilename))
      CqlFilename=util::string_append(CqlFilename,".cql");
    uassert(filename_is_cql(CqlFilename),
	    "CQL command line: CQL file must have extension .cql or .CQL, if it has an extension. Invalid CQL filename: ",CqlFilename);
    uassert(nextarg==argc-1,"The CQL filename must be the last argument on the command line", current);
    break;
    }
  }//while(++nextarg<argc)
  uassert(CqlFilename,"No CQL file specified to command line");
}

void printhelp(){
  printf("CQL usage: cql options filename\n");
  printf(" the 'filename' above should a be a file with extension .cql. The allowed options are:\n");
  printf("--help or -h: print this message\n");
  printf("--parse: parse only, do not run [not supported]\n");
  printf("--player playername to restrict output to given playername\n");
  printf("--silent: do not add any annotations to matched games\n");
  printf("--year number or --year number number to restrict output to year in the given range\n");
  printf("-g number, or -g number number, or --game number, or --game number number to specify the range of games to search\n");
  printf("-i inputfile.pgn (or --pgn inputfile.pgn, or --input inputfile.pgn): read games from inputfile.pgn\n");
  printf("-o outputfile.pgn (or --output outputfile.pgn): write output to outputfile.pgn\n");
}

