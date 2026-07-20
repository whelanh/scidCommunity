
// util.h

#ifndef UTIL_H
#define UTIL_H

// includes

#include <cstdio>
// constants

#undef FALSE
#define FALSE 0

#undef TRUE
#define TRUE 1

#ifdef DEBUG
#  undef DEBUG
#  define DEBUG TRUE
#else
#  define DEBUG FALSE
#endif

#ifdef _MSC_VER
#  define S64_FORMAT "%I64d"
#  define U64_FORMAT "%016I64X"
#else
#  define S64_FORMAT "%lld"
#  define U64_FORMAT "%016llX"
#endif

// macros

#ifdef _MSC_VER
#  define S64(u) (u##i64)
#  define U64(u) (u##ui64)
#else
#  define S64(u) (u##LL)
#  define U64(u) (u##ULL)
#endif

#undef ASSERT
#if DEBUG
#  define ASSERT(a) { if (!(a)) my_fatal("file \"%s\", line %d, assertion \"" #a "\" failed\n",__FILE__,__LINE__); }
#else
#  define ASSERT(a)
#endif

// types

using sint8 = signed char;
using uint8 = unsigned char;

using sint16 = signed short;
using uint16 = unsigned short;

using sint32 = signed int;
using uint32 = unsigned int;

#ifdef _MSC_VER
  using sint64 = signed __int64;
  using uint64 = unsigned __int64;
#else
  using sint64 = signed long long int;
  using uint64 = unsigned long long int;
#endif

struct my_timer_t {
   double start_real;
   double start_cpu;
   double elapsed_real;
   double elapsed_cpu;
   bool running;
};

// functions

extern void   util_init             ();

extern sint64 my_atoll              (const char string[]);

extern void * my_malloc             (size_t size);
extern void * my_realloc            (void * address, size_t size);
extern void   my_free               (void * address);

extern void   my_log                (const char format[], ...);
extern void   my_fatal              (const char format[], ...);

extern bool   my_string_empty       (const char string[]);
extern bool   my_string_equal       (const char string_1[], const char string_2[]);
extern bool   my_string_case_equal  (const char string_1[], const char string_2[]);
extern char * my_strdup             (const char string[]);

extern void   my_string_clear       (const char * * variable);
extern void   my_string_set         (const char * * variable, const char string[]);

extern void   my_timer_reset        (my_timer_t * timer);
extern void   my_timer_start        (my_timer_t * timer);
extern void   my_timer_stop         (my_timer_t * timer);

extern double my_timer_elapsed_real (const my_timer_t * timer);
extern double my_timer_elapsed_cpu  (const my_timer_t * timer);
extern double my_timer_cpu_usage    (const my_timer_t * timer);

#endif // !defined UTIL_H

// end of util.h

