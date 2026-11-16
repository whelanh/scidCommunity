/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Original authors: scidvspc (https://sourceforge.net/projects/scidvspc/)
 */
#pragma once
#include "util.h"
#include "node.h"
#include "token.h"
#include "tokenstream.h"

CqlNode* parseFile(const char* filename);
CqlNode* parseBuffer(char* buffer);
void showTokens();

