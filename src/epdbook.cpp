/*
 * EpdBook: a read/write collection of chess positions, each with an
 * associated set of EPD opcodes stored as newline-separated text.
 *
 * This is a modern reimplementation of the position-book used by the
 * EPD editor window. Positions are keyed by their canonical 4-field FEN
 * (board, side-to-move, castling, en-passant) which is unambiguous and
 * independent of the internal piece-list ordering.
 *
 * This file is part of Scid (Shane's Chess Information Database).
 *
 * Scid is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation.
 */

#include "epdbook.h"
#include "misc.h"
#include <cstdio>
#include <fstream>

EpdBook::~EpdBook() { delete[] fileName_; }

void EpdBook::setFileName(const char* fname) {
	delete[] fileName_;
	fileName_ = fname ? strDuplicate(fname) : nullptr;
}

// Produce the canonical 4-field FEN (board, side, castling, ep) used as a
// position key. Position::PrintFEN() emits the full 6-field FEN, so we
// truncate at the 4th space to drop the halfmove/fullmove counters.
std::string EpdBook::canonicalFen(Position* pos) {
	char buf[256];
	pos->PrintFEN(buf);
	int spaces = 0;
	for (char* s = buf; *s != 0; ++s) {
		if (*s == ' ' && ++spaces == 4) {
			*s = 0;
			break;
		}
	}
	return std::string(buf);
}

bool EpdBook::find(Position* pos, const char** ptrComment) const {
	std::string fen = canonicalFen(pos);
	auto it = fenIndex_.find(fen);
	if (it != fenIndex_.end()) {
		if (ptrComment) {
			*ptrComment = entries_[it->second].comment.c_str();
		}
		return true;
	}
	return false;
}

int EpdBook::getIndex(Position* pos) const {
	std::string fen = canonicalFen(pos);
	auto it = fenIndex_.find(fen);
	if (it != fenIndex_.end()) {
		return static_cast<int>(it->second);
	}
	return -1;
}

int EpdBook::setIndex(uint idx) {
	if (idx >= entries_.size()) {
		return -1;
	}
	nextIndex_ = idx;
	return static_cast<int>(nextIndex_);
}

void EpdBook::insert(Position* pos, const char* comment) {
	std::string fen = canonicalFen(pos);
	auto it = fenIndex_.find(fen);
	if (it != fenIndex_.end()) {
		// Already exists: overwrite the comment.
		entries_[it->second].comment = comment;
		altered_ = true;
		return;
	}
	size_t newIndex = entries_.size();
	entries_.push_back({fen, std::string(comment)});
	fenIndex_[fen] = newIndex;
	altered_ = true;
}

bool EpdBook::loadByIndex(Position* pos, uint idx) const {
	if (idx >= entries_.size()) {
		return false;
	}
	return pos->ReadFromFEN(entries_[idx].fen.c_str()) == OK;
}

// Move to the next (or previous) position in file order and read it into pos.
bool EpdBook::findNext(Position* pos, bool forwards) {
	uint total = entries_.size();
	if (total == 0) {
		return false;
	}
	if (forwards) {
		nextIndex_++;
		if (nextIndex_ >= total) {
			nextIndex_ = 0;
		}
	} else {
		nextIndex_ = (nextIndex_ == 0) ? total - 1 : nextIndex_ - 1;
	}
	return loadByIndex(pos, nextIndex_);
}

// Removes the first line matching "<opcode> " from every position.
// Returns the number of positions that were modified.
uint EpdBook::stripOpcode(const char* opcode) {
	std::string prefix = std::string(opcode) + " ";
	uint countFound = 0;
	for (auto& e : entries_) {
		std::string& c = e.comment;
		size_t start = 0;
		while (start <= c.size()) {
			size_t nl = c.find('\n', start);
			if (c.compare(start, prefix.size(), prefix) == 0) {
				size_t removeEnd =
				    (nl == std::string::npos) ? c.size() : nl + 1;
				c.erase(start, removeEnd - start);
				countFound++;
				break;
			}
			if (nl == std::string::npos) {
				break;
			}
			start = nl + 1;
		}
	}
	if (countFound > 0) {
		altered_ = true;
	}
	return countFound;
}

errorT EpdBook::readFile() {
	if (fileName_ == nullptr) {
		return ERROR_FileOpen;
	}
	std::ifstream in(fileName_, std::ios::binary);
	if (!in) {
		return ERROR_FileOpen;
	}

	// Determine whether the file is writable. Opening in append mode does
	// not truncate or modify the file if nothing is written.
	{
		std::ofstream test(fileName_, std::ios::app);
		readOnly_ = !test.is_open();
	}

	entries_.clear();
	fenIndex_.clear();
	Position pos;
	std::string line;
	uint lineNumber = 0;
	while (std::getline(in, line)) {
		lineNumber++;
		if (!line.empty() && line.back() == '\r') {
			line.pop_back();
		}
		if (line.empty()) {
			continue;
		}
		std::string originalLine = line;
		if (pos.ReadFromFEN(line.c_str()) != OK) {
			// Preserve malformed line as raw text to prevent data loss.
			// Use a synthetic FEN key that won't match any valid position.
			std::string malformedKey = "MALFORMED:" + std::to_string(lineNumber);
			size_t idx = entries_.size();
			entries_.push_back({malformedKey, originalLine});
			fenIndex_[malformedKey] = idx;
			continue;
		}

		// Skip over the first four (FEN) fields to reach the opcodes.
		const char* s = line.c_str();
		while (*s == ' ') {
			s++;
		}
		for (int i = 0; i < 4; i++) {
			while (*s != ' ' && *s != 0) {
				s++;
			}
			while (*s == ' ') {
				s++;
			}
		}

		// Parse each opcode field, converting "\s" -> ';' and "\\" -> '\'.
		std::string comment;
		while (*s == ';' || *s == ' ') {
			s++;
		}
		while (*s != 0) {
			while (*s == ';' || *s == ' ') {
				s++;
			}
			bool seenCode = false;
			while (*s != ';' && *s != 0) {
				seenCode = true;
				char ch = *s;
				if (ch == '\\') {
					s++;
					ch = *s;
					if (ch == 's') {
						ch = ';';
					}
					if (ch == 0) {
						break;
					}
				}
				comment.push_back(ch);
				s++;
			}
			if (seenCode) {
				comment.push_back('\n');
			}
		}

		insert(&pos, comment.c_str());
	}

	altered_ = false;
	nextIndex_ = entries_.empty() ? 0 : entries_.size() - 1;
	return OK;
}

errorT EpdBook::writeFile() {
	if (fileName_ == nullptr) {
		return ERROR_FileOpen;
	}

	// Create a temporary file in the same directory as the target file
	std::string tempFileName = std::string(fileName_) + ".tmp";
	std::ofstream out(tempFileName, std::ios::binary | std::ios::trunc);
	if (!out) {
		return ERROR_FileOpen;
	}

	for (const auto& e : entries_) {
		// Check if this is a malformed line preserved during read
		if (e.fen.rfind("MALFORMED:", 0) == 0) {
			// Write the original line as-is
			out << e.comment << '\n';
		} else {
			out << e.fen;
			bool atCodeStart = true;
			const char* s = e.comment.c_str();
			while (*s != 0) {
				if (*s == '\n') {
					if (!atCodeStart) {
						out << ';';
					}
					atCodeStart = true;
					s++;
					while (*s == ' ') {
						s++;
					}
				} else {
					if (atCodeStart) {
						out << ' ';
					}
					atCodeStart = false;
					switch (*s) {
					case '\\':
						out << "\\\\";
						break;
					case ';':
						out << "\\s";
						break;
					default:
						out << *s;
					}
					s++;
				}
			}
			out << '\n';
		}
	}

	// Flush and close, checking for errors
	out.flush();
	if (!out) {
		out.close();
		std::remove(tempFileName.c_str());
		return ERROR_FileWrite;
	}
	out.close();
	if (!out.good() && out.eof()) {
		// EOF is expected; only fail if badbit is set
		if (out.bad()) {
			std::remove(tempFileName.c_str());
			return ERROR_FileWrite;
		}
	}

	// Atomically replace the original file
#ifdef _WIN32
	// Windows std::rename() fails if the destination exists.
	std::remove(fileName_);
#endif
	if (std::rename(tempFileName.c_str(), fileName_) != 0) {
		std::remove(tempFileName.c_str());
		return ERROR_FileWrite;
	}

	altered_ = false;
	return OK;
}
