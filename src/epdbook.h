#ifndef SCID_EPDBOOK_H
#define SCID_EPDBOOK_H

#include "common.h"
#include "position.h"
#include <string>
#include <string_view>
#include <string.h>
#include <unordered_map>
#include <vector>

struct EpdEntry {
	std::string fen;     // 4-field FEN (board+stm+castling+ep)
	std::string comment; // newline-separated opcodes
};

class EpdBook {
	char* fileName_ = nullptr;
	bool altered_ = false;
	bool readOnly_ = false;
	std::vector<EpdEntry> entries_;
	std::unordered_map<std::string, size_t> fenIndex_;
	uint nextIndex_ = 0;

	static std::string canonicalFen(Position* pos);

public:
	~EpdBook();
	EpdBook() = default;

	const char* getFileName() const {
		return fileName_ ? fileName_ : "";
	}
	void setFileName(const char* fname);

	bool isAltered() const { return altered_; }
	bool isReadOnly() const { return readOnly_; }

	errorT readFile();
	errorT writeFile();

	uint size() const { return entries_.size(); }

	bool find(Position* pos, const char** ptrComment) const;
	int getIndex(Position* pos) const;
	int setIndex(uint idx);
	void insert(Position* pos, const char* comment);
	bool findNext(Position* pos, bool forwards);
	bool loadByIndex(Position* pos, uint idx) const;

	uint stripOpcode(const char* opcode);
	void removeByIndex(uint idx);
};

#endif // SCID_EPDBOOK_H
