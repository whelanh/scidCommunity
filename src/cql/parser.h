#pragma once
#include "util.h"
#include "node.h"
#include "token.h"
#include "tokenstream.h"

CqlNode* parseFile(const char* filename);
CqlNode* parseBuffer(char* buffer);
void showTokens();

