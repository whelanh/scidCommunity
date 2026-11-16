#pragma once
extern const char * CqlVersion;
extern const char * CqlBuild;

void parseargs(int argc, char*argv[]);
void cql_initialize();
void versionInitialize();
void cqlglobals_initialize();

