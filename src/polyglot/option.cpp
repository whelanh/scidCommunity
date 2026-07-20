
// option.cpp

// includes

#include <cstdlib>
#include <cstring>

#include "option.h"
#include "util.h"

// constants

static const bool UseDebug = false;

// types

struct option_t {
   const char * var;
   const char * val;
};

// variables

static option_t Option[] = {

   { "OptionFile",    nullptr, }, // string

   // options

   { "EngineName",    nullptr, }, // string
   { "EngineDir",     nullptr, }, // string
   { "EngineCommand", nullptr, }, // string

   { "Log",           nullptr, }, // true/false
   { "LogFile",       nullptr, }, // string

   { "Chess960",      nullptr, }, // true/false

   { "Resign",        nullptr, }, // true/false
   { "ResignMoves",   nullptr, }, // move number
   { "ResignScore",   nullptr, }, // centipawns

   { "MateScore",     nullptr, }, // centipawns

   { "Book",          nullptr, }, // true/false
   { "BookFile",      nullptr, }, // string

   { "BookRandom",    nullptr, }, // true/false
   { "BookLearn",     nullptr, }, // true/false

   { "KibitzMove",    nullptr, }, // true/false
   { "KibitzPV",      nullptr, }, // true/false

   { "KibitzCommand", nullptr, }, // string
   { "KibitzDelay",   nullptr, }, // seconds

   { "ShowPonder",    nullptr, }, // true/false

   // work-arounds

   { "UCIVersion",    nullptr, }, // 1-
   { "CanPonder",     nullptr, }, // true/false
   { "SyncStop",      nullptr, }, // true/false
   { "PromoteWorkAround", nullptr, }, // true/false

   // { "",              nullptr, },

   { nullptr,            nullptr, },
};

// prototypes

static option_t * option_find (const char var[]);

// functions

// option_init()

void option_init() {

   option_set("OptionFile","polyglot.ini");

   // options

   option_set("EngineName","<empty>");
   option_set("EngineDir",".");
   option_set("EngineCommand","<empty>");

   option_set("Log","false");
   option_set("LogFile","polyglot.log");

   option_set("Chess960","false");

   option_set("Resign","false");
   option_set("ResignMoves","3");
   option_set("ResignScore","600");

   option_set("MateScore","10000");

   option_set("Book","false");
   option_set("BookFile","book.bin");

   option_set("BookRandom","true");
   option_set("BookLearn","false");

   option_set("KibitzMove","false");
   option_set("KibitzPV","false");

   option_set("KibitzCommand","tellall");
   option_set("KibitzDelay","5");

   option_set("ShowPonder","true");

   // work-arounds

   option_set("UCIVersion","2");
   option_set("CanPonder","false");
   option_set("SyncStop","false");
   option_set("PromoteWorkAround","false");

   // option_set("","");
}

// option_set()

bool option_set(const char var[], const char val[]) {

   option_t * opt;

   ASSERT(var!=nullptr);
   ASSERT(val!=nullptr);

   opt = option_find(var);
   if (opt == nullptr) return false;

   my_string_set(&opt->val,val);

   if (UseDebug) my_log("POLYGLOT OPTION SET \"%s\" -> \"%s\"\n",opt->var,opt->val);

   return true;
}

// option_find()

static option_t * option_find(const char var[]) {

   option_t * opt;

   ASSERT(var!=nullptr);

   for (opt = &Option[0]; opt->var != nullptr; opt++) {
      if (my_string_case_equal(opt->var,var)) return opt;
   }

   return nullptr;
}

// end of option.cpp

