// SPDX-FileCopyrightText: 2026 TBergh98
// SPDX-License-Identifier: GPL-3.0-or-later
//
// ctg2obr.h: convert a ChessBase CTG book to OpenBook Rich (.obr).

#ifndef CTG2OBR_H
#define CTG2OBR_H

#include <cstddef>
#include <functional>
#include <string>

// Progress callback: return false to cancel the conversion.
using Ctg2ObrProgress = std::function<bool(size_t done, size_t total)>;

// Converts ctg_path (with its .cto and .ctb next to it; .ini optional) to
// out_path. Paths are UTF-8. The output is written to out_path + ".part" and
// renamed at the end, so on failure out_path is untouched.
// Returns true on success, with a summary of the conversion in result.
// Returns false on error, with the error in result, or when cancelled, with
// result empty.
bool ctg2obr(const std::string& ctg_path, const std::string& out_path,
             const Ctg2ObrProgress& progress, std::string& result);

#endif
