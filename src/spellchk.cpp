/*
* Copyright (C) 2015 Fulvio Benini
* Copyright (c) 2001-2003  Shane Hudson (2nd part of the file)

* This file is part of Scid (Shane's Chess Information Database).
*
* Scid is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation.
*
* Scid is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Scid. If not, see <http://www.gnu.org/licenses/>.
*/

#include "spellchk.h"
#include "date.h"
#include "filebuf.h"
#include "misc.h"

#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <filesystem>
#include <memory>
#include <string>
#include <system_error>
#include <vector>

#ifdef _WIN32
#include <windows.h>
#else
#include <fcntl.h>
#include <unistd.h>
#endif


namespace {

/*
 * On-disk cache of a parsed spelling file.
 *
 * Parsing a large .ssp file (a FIDE rating list with tens of millions of
 * ratings takes about a second, and the in-memory result is several hundred
 * megabytes) is repeated at every start. The cache stores the parsed data in
 * a compact binary form that can be loaded with a few sequential reads.
 *
 * The cache is validated against the size and the last-write time of the
 * source file: if the .ssp file changes, the cache is stale and is rebuilt.
 * Every failure (missing file, read-only directory, truncated cache, older
 * version) silently falls back to parsing the source.
 */
constexpr uint32_t SPELL_CACHE_MAGIC = 0x43505353; // "SSPC"
constexpr uint32_t SPELL_CACHE_VERSION = 1;
constexpr uint32_t SPELL_CACHE_NULL_OFFSET = 0xFFFFFFFFu;
constexpr uint32_t SPELL_CACHE_MAX_ITEMS = 64u * 1024 * 1024;
constexpr uint32_t SPELL_CACHE_MAX_RULES = 0xFFFF;

/// Little-endian writer for the cache file.
class CacheWriter {
	FILE* f_;
	bool ok_;

public:
	explicit CacheWriter(FILE* f) : f_(f), ok_(true) {}
	bool ok() const { return ok_; }

	void bytes(const void* p, size_t n) {
		if (ok_ && n != 0 && std::fwrite(p, 1, n, f_) != n)
			ok_ = false;
	}
	void u16(uint32_t v) {
		unsigned char b[2] = {static_cast<unsigned char>(v),
		                      static_cast<unsigned char>(v >> 8)};
		bytes(b, sizeof b);
	}
	void u32(uint64_t v) {
		unsigned char b[4] = {static_cast<unsigned char>(v),
		                      static_cast<unsigned char>(v >> 8),
		                      static_cast<unsigned char>(v >> 16),
		                      static_cast<unsigned char>(v >> 24)};
		bytes(b, sizeof b);
	}
	void u64(uint64_t v) {
		unsigned char b[8];
		for (int i = 0; i < 8; ++i)
			b[i] = static_cast<unsigned char>(v >> (8 * i));
		bytes(b, sizeof b);
	}
	void str(const char* s) {
		const size_t n = s ? std::strlen(s) : 0;
		if (n > 0xFFFF) {
			ok_ = false;
			return;
		}
		u16(static_cast<uint32_t>(n));
		bytes(s, n);
	}
	void varint(uint64_t v) {
		unsigned char b[10];
		size_t n = 0;
		while (v >= 0x80) {
			b[n++] = static_cast<unsigned char>(v | 0x80);
			v >>= 7;
		}
		b[n++] = static_cast<unsigned char>(v);
		bytes(b, n);
	}
};

/// Little-endian reader for the cache file.
class CacheReader {
	FILE* f_;
	uint64_t remaining_;
	bool ok_;

public:
	explicit CacheReader(FILE* f, uint64_t size)
	    : f_(f), remaining_(size), ok_(true) {}
	bool ok() const { return ok_; }
	bool atEnd() const { return ok_ && remaining_ == 0; }
	uint64_t remaining() const { return remaining_; }

	void bytes(void* dst, size_t n) {
		if (!ok_)
			return;
		if (n > remaining_ || std::fread(dst, 1, n, f_) != n) {
			ok_ = false;
			return;
		}
		remaining_ -= n;
	}
	uint8_t u8() {
		unsigned char b = 0;
		bytes(&b, sizeof b);
		return b;
	}
	uint16_t u16() {
		unsigned char b[2] = {};
		bytes(b, sizeof b);
		return static_cast<uint16_t>(b[0] | (b[1] << 8));
	}
	uint32_t u32() {
		unsigned char b[4] = {};
		bytes(b, sizeof b);
		return static_cast<uint32_t>(b[0]) | (static_cast<uint32_t>(b[1]) << 8) |
		       (static_cast<uint32_t>(b[2]) << 16) |
		       (static_cast<uint32_t>(b[3]) << 24);
	}
	uint64_t u64() {
		unsigned char b[8] = {};
		bytes(b, sizeof b);
		uint64_t v = 0;
		for (int i = 7; i >= 0; --i)
			v = (v << 8) | b[i];
		return v;
	}
	bool str(std::string& out) {
		const uint16_t n = u16();
		if (!ok_ || n > remaining_) {
			ok_ = false;
			return false;
		}
		out.resize(n);
		if (n != 0)
			bytes(out.data(), n);
		return ok_;
	}
	uint64_t varint() {
		uint64_t v = 0;
		int shift = 0;
		while (ok_) {
			const uint8_t b = u8();
			if (!ok_)
				break;
			v |= static_cast<uint64_t>(b & 0x7F) << shift;
			if ((b & 0x80) == 0)
				return v;
			shift += 7;
			if (shift > 63) {
				ok_ = false;
				return 0;
			}
		}
		return 0;
	}
};

/// Inverse of the zigzag encoding used for the elo deltas.
inline int32_t unzigzag(uint64_t v) {
	return static_cast<int32_t>(v >> 1) ^ -static_cast<int32_t>(v & 1);
}

/// Absolute path of the cache file that belongs to @e filename.
[[maybe_unused]] std::string cachePathFor(const char* filename) {
	return std::string(filename) + ".sspc";
}


enum InfoType {
	SPELL_SECTIONSTART,
	SPELL_NEWNAME, SPELL_ALIAS, SPELL_PREFIX, SPELL_INFIX, SPELL_SUFFIX,
	SPELL_BIO, SPELL_ELO,
	SPELL_EMPTY, SPELL_OLDBIO, SPELL_UNKNOWN
};

struct Parser {
	char* name;
	char* extra;
	enum InfoType type;

	Parser(char* line);
};

/**
 * Parser::Parser() - Parse a "spelling" line.
 *
 * Fill data members doing the following tasks:
 * - separate the optional comment (a comment starts with '#' and
 *   extend to the end of the line) from the name data.
 * - remove leading and trailing white-spaces.
 * - identify the type of data
 */
Parser::Parser(char* line) {
	ASSERT(line != 0);

	extra = strchr(line, '#');
	if (extra != nullptr) {
		// Make [line, extra) a null terminated string
		*extra++ = 0;
	}
	name = (char*) strTrimLeft(line);
	strTrimRight(name);

	type = SPELL_UNKNOWN;
	switch (*name) {
		case 0:
			type = SPELL_EMPTY;
			break;
		case '>':
			type = SPELL_OLDBIO;
			break;
		case '=':
			type = SPELL_ALIAS;
			// Skip over "=" and spaces:
			name++;
			while (*name == ' ') { name++; }
			break;
		case '%':
			if (strIsPrefix("%Elo ", name)) {
				type = SPELL_ELO;
				name += 5; //Skip "%Elo "
			} else if (strIsPrefix("%Bio ", name)) {
				type = SPELL_BIO;
				name += 5; //Skip "%Bio "
			} else if (strIsPrefix("%Prefix ", name)) {
				type = SPELL_PREFIX;
			} else if (strIsPrefix("%Infix ", name)) {
				type = SPELL_INFIX;
			} else if (strIsPrefix("%Suffix ", name)) {
				type = SPELL_SUFFIX;
			}
			break;
		case '@':
			type = SPELL_SECTIONSTART;
			name++; //Skip '@'
			// Now check if there is a list of characters to exclude from
			// comparisons, e.g:   @PLAYER ", .-"
			// would indicate to exclude dots, commas, spaces and dashes.
			extra = strchr(name, '"');
			if (extra != nullptr) {
				char* end = strchr(++extra, '"');
				if (end != nullptr) {
					*end = 0;
				} else {
					extra = nullptr;
				}
			}
			break;
		default:
			type = SPELL_NEWNAME;
			if (extra != nullptr) {
				// Spelling files can provide player informations like titles/gender,
				// countries, highest elo, date of birth, date of death. For example:
				// Polgar, Judit           #gm+w HUN [2735] 1976
				strTrimRight(extra);
			}
	}
}

} // End of anonymous namespace


/**
 * class SpellChkLoader - load data into a SpellChecker object
 *
 * This class take parsed "spelling" data and store it into the right
 * data members of the associated SpellChecker object.
 * Reading from a "spelling" file is not stateless and the Parser object
 * cannot contain all the necessary data: a SpellChkLoader object keep track
 * of the current nameT section and the current correct name.
 * The SpellChkValidate object is used to log ignored data, usually
 * caused by typos like "@Eol" or "@Preffix".
 */
class SpellChkLoader {
	SpellChecker& sp_;
	SpellChecker::SpellChkValidate& validate_;
	nameT nt_;
	int32_t nameIdx_;

public:
	SpellChkLoader(SpellChecker& sp, SpellChecker::SpellChkValidate& v)
	: sp_(sp), validate_(v), nt_(NAME_INVALID), nameIdx_(-1) {
	}

	errorT load(const Parser& data, bool* keepBuffer) {
		ASSERT(keepBuffer != 0);
		*keepBuffer = false;

		switch (data.type) {
			case SPELL_SECTIONSTART:
				nt_ = NameBase::NameTypeFromString(data.name);
				if (!NameBase::IsValidNameType(nt_)) return ERROR_CorruptData;
				if (data.extra != nullptr) {
					sp_.excludeChars_[nt_] = data.extra;
				} else {
					sp_.excludeChars_[nt_].clear();
				}
				nameIdx_ = -1;
				return OK;
			case SPELL_NEWNAME:
			case SPELL_ALIAS:
			case SPELL_PREFIX:
			case SPELL_INFIX:
			case SPELL_SUFFIX:
				return nameSection(data, keepBuffer);
			case SPELL_BIO:
			case SPELL_ELO:
				return playerInfo(data, keepBuffer);
			case SPELL_EMPTY:
				return OK;
			case SPELL_OLDBIO:
			case SPELL_UNKNOWN:
				validate_.ignoredLine(data.name);
				return OK;
		}

		ASSERT(0);
		return ERROR_CorruptData;
	}

private:
	errorT nameSection(const Parser& data, bool* keepBuffer) {
		// Must be in a valid name section
		if (!NameBase::IsValidNameType(nt_)) return ERROR_CorruptData;

		switch (data.type) {
			case SPELL_NEWNAME:
				*keepBuffer = true;
				ASSERT(sp_.names_[nt_].size() < (1ULL << 31));
				nameIdx_ = static_cast<int32_t>(sp_.names_[nt_].size());
				sp_.names_[nt_].push_back(data.name);
				if (nt_ == NAME_PLAYER) {
					sp_.pInfo_.push_back(data.extra);
				}
				/* FALLTHRU */
			case SPELL_ALIAS:
				if (nameIdx_ == -1) {
					return ERROR_CorruptData;
				} else {
					sp_.idx_[nt_].push_back(SpellChecker::Idx(
						sp_.normalizeAndTransform(nt_, data.name),
						nameIdx_
						));
				}
				return OK;
			case SPELL_PREFIX:
				return sp_.general_[nt_].addPrefix(data.name);
			case SPELL_INFIX:
				return sp_.general_[nt_].addInfix(data.name);
			case SPELL_SUFFIX:
				return sp_.general_[nt_].addSuffix(data.name);
			default:
				ASSERT(0);
		}

		return ERROR_CorruptData;
	}

	errorT playerInfo(const Parser& data, bool* keepBuffer) {
		// SPELL_BIO and SPELL_ELO are valid only for a PLAYER name
		if (nt_ != NAME_PLAYER || nameIdx_ == -1) return ERROR_CorruptData;

		if (data.type == SPELL_BIO) {
			*keepBuffer = true;
			sp_.pInfo_[nameIdx_].bio_.push_back(data.name);
		} else {
			ASSERT(data.type == SPELL_ELO);
			// if necessary, add empty PlayerElo objects
			sp_.pElo_.resize(nameIdx_ + 1);
			sp_.pElo_[nameIdx_].AddEloData(data.name);
		}

		return OK;
	}
};


/**
 * SpellChecker::read() - Read a "spelling" file.
 *
 * This functions tries to open the @filename file and to load the data
 * into the SpellChecker object.
 * The object must be empty. In practice the requirement is to not call
 * this function twice, because this is the only non-const member function.
 * If the function fails (result != OK) the object state is undefined
 * and the only valid operation is to destroy the object.
 * If SPELLCHKVALIDATE is defined, it also creates a @filename.validate log.
 */
errorT SpellChecker::readSpellFile(const char* filename, const Progress& progress)
{
	ASSERT(filename != nullptr);
	ASSERT(staticStrings_ == nullptr);

	// Open the file and get the file size.
	Filebuf file;
	std::streamsize fileSize = -1;
	if (file.open(pathFromUtf8(filename),
	              std::ios::in | std::ios::binary | std::ios::ate) != 0) {
		fileSize = file.pubseekoff(0, std::ios::cur, std::ios::in);
		file.pubseekoff(0, std::ios::beg, std::ios::in);
	}
	if (fileSize == -1) return ERROR_FileOpen;

	SpellChkValidate validate(filename, *this);

	// Parse the file lines
	staticStrings_ = (char*) malloc(fileSize + 1);
	if (staticStrings_ == nullptr) return ERROR_FileOpen;
	char* bEnd = staticStrings_ + fileSize + 1;
	char* line = staticStrings_;
	size_t nRead;
	uint report_i = 0;
	std::streamsize report_done = 0;
	SpellChkLoader loader(*this, validate);
	while ((nRead = file.getline(line, std::distance(line, bEnd))) != 0) {
		report_done += nRead;
		if ((++report_i % 10000) == 0) {
			if (!progress.report(report_done, fileSize))
				return ERROR_UserCancel;
		}

		bool keepBuffer;
		errorT err = loader.load(Parser(line), &keepBuffer);
		if (err != OK) return err;

		if (keepBuffer) line += nRead;
	}
	if (report_done != fileSize || file.sgetc() != EOF) return ERROR_FileRead;

	// Success:
	if (pElo_.size() > 0) {
		// if necessary, add empty PlayerElo objects
		pElo_.resize(pInfo_.size());
		validate.checkEloData();
	}

	// Free unused memory
	const auto new_size = std::distance(staticStrings_, line);
	char* shrink = (char*)realloc(staticStrings_, new_size ? new_size : 1);
	if (shrink) {
		const auto offset = shrink - staticStrings_;
		staticStrings_ = shrink;
		if (offset) { // realloc() moved the memory: update the pointers.
			for (nameT i = 0; i < NUM_NAME_TYPES; i++) {
				for (auto& e : names_[i])
					e += offset;
			}
			for (auto& e : pInfo_) {
				e.comment_ += offset;
				for (auto& bio : e.bio_)
					bio += offset;
			}
		}
	}

	// Sort the index
	for (nameT i=0; i < NUM_NAME_TYPES; i++) {
		std::sort(idx_[i].begin(), idx_[i].end());
		validate.idxDuplicates(i);
	}
	return OK;
}

/**
 * SpellChecker::read() - Read a "spelling" file, using the cache if possible.
 *
 * The parsed data is cached in a file that sits next to the source (see
 * SpellChecker::writeCache()). The cache is used only when the source file
 * has not changed; otherwise the source is parsed and the cache is rebuilt.
 */
errorT SpellChecker::read(const char* filename, const Progress& progress)
{
	ASSERT(filename != nullptr);
	ASSERT(staticStrings_ == nullptr);

#ifndef SPELLCHKVALIDATE
	const auto srcPath = pathFromUtf8(filename);
	std::error_code ec;
	const uint64_t srcSize = std::filesystem::file_size(srcPath, ec);
	if (ec) return ERROR_FileOpen;
	const uint64_t srcTime = static_cast<uint64_t>(
	    std::filesystem::last_write_time(srcPath, ec).time_since_epoch().count());
	if (ec) return ERROR_FileOpen;

	// A validation build must look at the source every time: the cache skips
	// SpellChkValidate and its report.
	{
		const std::string cacheFile = cachePathFor(filename);
		if (readCache(cacheFile.c_str(), srcSize, srcTime))
			return OK;
	}
#endif

	errorT err = readSpellFile(filename, progress);
	if (err != OK)
		return err;

#ifndef SPELLCHKVALIDATE
	const std::string cacheFile = cachePathFor(filename);
	writeCache(cacheFile.c_str(), filename, srcSize, srcTime);
#endif
	return OK;
}

/**
 * SpellChecker::readCache() - Load the parsed data from a cache file.
 *
 * @returns true if the object has been filled from the cache; false if the
 * cache is missing, stale, corrupt or of an unknown version, in which case
 * the object is left untouched.
 */
bool SpellChecker::readCache(const char* cacheFile, uint64_t srcSize,
                             uint64_t srcTime)
{
	const auto cachePath = pathFromUtf8(cacheFile);
	std::error_code ec;
	const uint64_t cacheSize = std::filesystem::file_size(cachePath, ec);
	if (ec || cacheSize < 32)
		return false;

	FILE* f = fopenUtf8(cacheFile, "rb");
	if (f == nullptr)
		return false;
	struct Closer {
		FILE* f;
		~Closer() { std::fclose(f); }
	} closer{f};

	CacheReader r(f, cacheSize);
	if (r.u32() != SPELL_CACHE_MAGIC || r.u32() != SPELL_CACHE_VERSION)
		return false;
	if (r.u64() != srcSize || r.u64() != srcTime)
		return false;

	const uint64_t blobBytes = r.u64();
	if (!r.ok() || blobBytes == 0 || blobBytes > cacheSize)
		return false;
	if (r.u32() != NUM_NAME_TYPES)
		return false;
	const uint32_t nPlayers = r.u32();
	const uint32_t nElo = r.u32();
	if (!r.ok() || nPlayers > SPELL_CACHE_MAX_ITEMS || nElo > SPELL_CACHE_MAX_ITEMS)
		return false;
	// Every player and every elo entry occupies at least a few bytes: reject
	// counts that cannot possibly fit in the file before allocating for them.
	if (nPlayers > cacheSize / 8 || nElo > cacheSize / 8)
		return false;

	// Read the string blob directly into the buffer that will own it: it is
	// the largest allocation of the load and must not be duplicated.
	std::unique_ptr<char, decltype(&std::free)> strings(
	    static_cast<char*>(std::malloc(static_cast<size_t>(blobBytes))), &std::free);
	if (!strings)
		return false;
	r.bytes(strings.get(), static_cast<size_t>(blobBytes));
	if (!r.ok() || strings.get()[blobBytes - 1] != '\0')
		return false;

	const auto validOffset = [blobBytes](uint32_t off) {
		return off < blobBytes;
	};

	// Name tables: one offset into the string blob per name.
	std::vector<uint32_t> nameOff[NUM_NAME_TYPES];
	uint32_t nameCount[NUM_NAME_TYPES] = {};
	for (nameT t = 0; t < NUM_NAME_TYPES; ++t) {
		nameCount[t] = r.u32();
		if (!r.ok() || nameCount[t] > SPELL_CACHE_MAX_ITEMS ||
		    nameCount[t] > r.remaining() / 4)
			return false;
		nameOff[t].resize(nameCount[t]);
		for (auto& off : nameOff[t]) {
			off = r.u32();
			if (!r.ok() || !validOffset(off))
				return false;
		}
	}

	// Player data is indexed by player name id.
	if (nPlayers != nameCount[NAME_PLAYER] || (nElo != 0 && nElo != nPlayers))
		return false;

	// Lookup index: alias -> name id (sorted, as produced by readSpellFile()).
	std::vector<std::vector<SpellChecker::Idx>> idx(NUM_NAME_TYPES);
	for (nameT t = 0; t < NUM_NAME_TYPES; ++t) {
		const uint32_t n = r.u32();
		if (!r.ok() || n > SPELL_CACHE_MAX_ITEMS || n > r.remaining() / 6)
			return false;
		idx[t].reserve(n);
		for (uint32_t i = 0; i < n; ++i) {
			const uint32_t id = r.u32();
			std::string alias;
			if (!r.str(alias) || id >= nameCount[t])
				return false;
			idx[t].emplace_back(std::move(alias), static_cast<int32_t>(id));
		}
		// find() runs lower_bound() on this table.
		if (!std::is_sorted(idx[t].begin(), idx[t].end()))
			return false;
	}

	// Characters ignored when matching names, and the general corrections.
	std::string excludeChars[NUM_NAME_TYPES];
	NameNormalizer general[NUM_NAME_TYPES];
	for (nameT t = 0; t < NUM_NAME_TYPES; ++t) {
		if (!r.str(excludeChars[t]))
			return false;
		auto& rules = general[t];
		auto readRules = [&](std::vector<std::pair<std::string, std::string>>& dst) {
			const uint32_t n = r.u32();
			if (!r.ok() || n > SPELL_CACHE_MAX_RULES)
				return false;
			dst.reserve(n);
			for (uint32_t i = 0; i < n; ++i) {
				std::string from, to;
				// An empty match would make NameNormalizer::normalize() loop
				// forever; the text parser rejects it as well.
				if (!r.str(from) || !r.str(to) || from.empty())
					return false;
				dst.emplace_back(std::move(from), std::move(to));
			}
			return true;
		};
		if (!readRules(rules.prefix_) || !readRules(rules.infix_) ||
		    !readRules(rules.suffix_))
			return false;
	}

	// Player information: comment (or none) and biographies.
	std::vector<uint32_t> commentOff(nPlayers, SPELL_CACHE_NULL_OFFSET);
	std::vector<std::vector<uint32_t>> bioOff(nPlayers);
	for (uint32_t i = 0; i < nPlayers; ++i) {
		const uint32_t off = r.u32();
		const uint32_t nBio = r.u32();
		if (!r.ok() || nBio > SPELL_CACHE_MAX_ITEMS || nBio > r.remaining() / 4)
			return false;
		if (off != SPELL_CACHE_NULL_OFFSET) {
			if (!validOffset(off))
				return false;
			commentOff[i] = off;
		}
		bioOff[i].resize(nBio);
		for (auto& bo : bioOff[i]) {
			bo = r.u32();
			if (!r.ok() || !validOffset(bo))
				return false;
		}
	}

	// Elo ratings, delta encoded (see writeCache()).  The deltas are applied
	// in int64_t so that a corrupt cache cannot overflow, and the results are
	// range checked before they are narrowed to the stored types.
	std::vector<PlayerElo> eloVec(nElo);
	if (r.u32() != nElo)
		return false;
	for (uint32_t i = 0; i < nElo; ++i) {
		const uint32_t n = r.u32();
		if (!r.ok() || n > SPELL_CACHE_MAX_ITEMS || n > r.remaining() / 2)
			return false;
		eloVec[i].elo_.reserve(n);
		int64_t year = 0;
		int64_t elo = 0;
		for (uint32_t k = 0; k < n; ++k) {
			const uint64_t uYear = r.varint();
			const uint64_t uElo = r.varint();
			// unzigzag() maps a 32-bit value to int32_t.
			if (!r.ok() || uYear > 0xFFFFFFFFull || uElo > 0xFFFFFFFFull)
				return false;
			year += unzigzag(uYear);
			elo += unzigzag(uElo);
			if (year < 0 || year > 0xFFFF || elo < 0 || elo > 0xFFFF)
				return false;
			eloVec[i].elo_.emplace_back(static_cast<uint16_t>(year),
			                            static_cast<eloT>(elo));
		}
	}
	if (!r.atEnd())
		return false;

	// Everything has been read and validated.  Build everything that can fail
	// in local objects first and move it in at the end, so that a failed load
	// leaves the checker empty and the source file can be parsed.
	std::vector<const char*> names[NUM_NAME_TYPES];
	for (nameT t = 0; t < NUM_NAME_TYPES; ++t) {
		names[t].reserve(nameCount[t]);
		for (size_t i = 0; i < nameCount[t]; ++i)
			names[t].push_back(strings.get() + nameOff[t][i]);
	}

	std::vector<PlayerInfo> players;
	players.reserve(nPlayers);
	for (uint32_t i = 0; i < nPlayers; ++i) {
		const char* comment = (commentOff[i] == SPELL_CACHE_NULL_OFFSET)
		                          ? nullptr
		                          : strings.get() + commentOff[i];
		players.push_back(PlayerInfo(comment));
		players.back().bio_.reserve(bioOff[i].size());
		for (uint32_t off : bioOff[i])
			players.back().bio_.push_back(strings.get() + off);
	}

	// Commit.  These moves do not throw.
	pElo_ = std::move(eloVec);
	pInfo_ = std::move(players);
	for (nameT t = 0; t < NUM_NAME_TYPES; ++t) {
		names_[t] = std::move(names[t]);
		idx_[t] = std::move(idx[t]);
		excludeChars_[t] = std::move(excludeChars[t]);
		general_[t] = std::move(general[t]);
	}
	staticStrings_ = strings.release();

	return true;
}

/**
 * SpellChecker::writeCache() - Store the parsed data into a cache file.
 *
 * Best effort: every error is ignored, the cache can always be rebuilt by
 * parsing the source file. The file is written under a temporary name and
 * renamed into place, so a concurrent reader never sees a partial file.
 */
void SpellChecker::writeCache(const char* cacheFile, const char* sourceFile,
                              uint64_t srcSize, uint64_t srcTime) const
{
	// A file of names only is parsed in a fraction of a second and its cache
	// would be about as large as the source: not worth writing.
	uint64_t nEloEntries = 0;
	for (const auto& pe : pElo_)
		nEloEntries += pe.elo_.size();
	if (nEloEntries == 0 && srcSize < (64ull << 20))
		return;

	// Do not write a cache that readCache() would reject.
	for (const auto& norm : general_) {
		if (norm.prefix_.size() > SPELL_CACHE_MAX_RULES ||
		    norm.infix_.size() > SPELL_CACHE_MAX_RULES ||
		    norm.suffix_.size() > SPELL_CACHE_MAX_RULES)
			return;
	}

	// Build the string blob and remember where every string starts.
	std::vector<char> blob;
	std::vector<uint32_t> nameOff[NUM_NAME_TYPES];
	std::vector<uint32_t> commentOff(pInfo_.size(), SPELL_CACHE_NULL_OFFSET);
	std::vector<std::vector<uint32_t>> bioOff(pInfo_.size());
	const auto addString = [&blob](const char* s) {
		const uint32_t off = static_cast<uint32_t>(blob.size());
		const size_t n = std::strlen(s);
		blob.insert(blob.end(), s, s + n + 1);
		return off;
	};
	for (nameT t = 0; t < NUM_NAME_TYPES; ++t) {
		nameOff[t].reserve(names_[t].size());
		for (const char* s : names_[t])
			nameOff[t].push_back(addString(s));
	}
	for (size_t i = 0; i < pInfo_.size(); ++i) {
		if (pInfo_[i].comment_ != nullptr)
			commentOff[i] = addString(pInfo_[i].comment_);
		bioOff[i].reserve(pInfo_[i].bio_.size());
		for (const char* s : pInfo_[i].bio_)
			bioOff[i].push_back(addString(s));
	}
	if (blob.empty() || blob.size() > 0xFFFFFFFFull)
		return;

	const std::string tmp = std::string(cacheFile) + ".tmp" +
	                        std::to_string(std::chrono::steady_clock::now()
	                                           .time_since_epoch()
	                                           .count());
#ifdef _WIN32
	FILE* f = fopenUtf8(tmp.c_str(), "wb");
#else
	// Create the file private from the start: it holds the same personal
	// data as the source, and the source's own mode is only applied just
	// before it is published. O_EXCL also refuses a pre-existing file.
	const int fd = ::open(tmp.c_str(), O_WRONLY | O_CREAT | O_EXCL, 0600);
	FILE* f = (fd >= 0) ? ::fdopen(fd, "wb") : nullptr;
	if (fd >= 0 && f == nullptr)
		::close(fd);
#endif
	if (f == nullptr)
		return;

	{
		CacheWriter w(f);
		w.u32(SPELL_CACHE_MAGIC);
		w.u32(SPELL_CACHE_VERSION);
		w.u64(srcSize);
		w.u64(srcTime);
		w.u64(blob.size());
		w.u32(NUM_NAME_TYPES);
		w.u32(static_cast<uint32_t>(pInfo_.size()));
		w.u32(static_cast<uint32_t>(pElo_.size()));
		w.bytes(blob.data(), blob.size());

		for (nameT t = 0; t < NUM_NAME_TYPES; ++t) {
			w.u32(names_[t].size());
			for (uint32_t off : nameOff[t])
				w.u32(off);
		}
		for (nameT t = 0; t < NUM_NAME_TYPES; ++t) {
			w.u32(idx_[t].size());
			for (const auto& e : idx_[t]) {
				w.u32(static_cast<uint32_t>(e.idx));
				w.str(e.alias.c_str());
			}
		}
		for (nameT t = 0; t < NUM_NAME_TYPES; ++t) {
			w.str(excludeChars_[t].c_str());
			for (const auto* rules : {&general_[t].prefix_, &general_[t].infix_,
			                          &general_[t].suffix_}) {
				w.u32(rules->size());
				for (const auto& r : *rules) {
					w.str(r.first.c_str());
					w.str(r.second.c_str());
				}
			}
		}
		for (size_t i = 0; i < pInfo_.size(); ++i) {
			w.u32(commentOff[i]);
			w.u32(static_cast<uint32_t>(bioOff[i].size()));
			for (uint32_t off : bioOff[i])
				w.u32(off);
		}
		w.u32(static_cast<uint32_t>(pElo_.size()));
		for (const auto& pe : pElo_) {
			w.u32(static_cast<uint32_t>(pe.elo_.size()));
			int32_t prevYear = 0;
			int32_t prevElo = 0;
			const auto zigzag = [](int32_t v) {
				return (static_cast<uint32_t>(v) << 1) ^
				       static_cast<uint32_t>(v < 0 ? -1 : 0);
			};
			for (const auto& e : pe.elo_) {
				w.varint(zigzag(static_cast<int32_t>(e.first) - prevYear));
				w.varint(zigzag(static_cast<int32_t>(e.second) - prevElo));
				prevYear = e.first;
				prevElo = e.second;
			}
		}

		if (!w.ok()) {
			std::fclose(f);
			std::error_code ec;
			std::filesystem::remove(pathFromUtf8(tmp), ec);
			return;
		}
	}
	if (std::fclose(f) != 0) {
		std::error_code ec;
		std::filesystem::remove(pathFromUtf8(tmp), ec);
		return;
	}

#ifndef _WIN32
	// The cache holds the same personal data as the source file: it must not
	// be more readable than the file it was derived from.  If the mode cannot
	// be carried over, drop the cache instead of publishing it (see also
	// polyglot/book.cpp, which does the same for its derived file).
	{
		std::error_code ecMode;
		const auto srcPerms =
		    std::filesystem::status(pathFromUtf8(sourceFile), ecMode).permissions();
		if (!ecMode && srcPerms != std::filesystem::perms::unknown) {
			// Only the ordinary mode bits: the cache must not inherit
			// setuid, setgid or sticky bits from the source.
			std::filesystem::permissions(
			    pathFromUtf8(tmp), srcPerms & std::filesystem::perms::all,
			    std::filesystem::perm_options::replace, ecMode);
		}
		if (ecMode || srcPerms == std::filesystem::perms::unknown) {
			std::error_code ecRemove;
			std::filesystem::remove(pathFromUtf8(tmp), ecRemove);
			return;
		}
	}
#endif

	// Atomically replace any previous cache. POSIX rename() replaces an
	// existing destination, the Windows CRT rename() does not: use
	// MoveFileEx with MOVEFILE_REPLACE_EXISTING there (as EpdBook does).
#ifdef _WIN32
	if (!MoveFileExW(pathFromUtf8(tmp).c_str(),
	                 pathFromUtf8(cacheFile).c_str(),
	                 MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH)) {
		std::error_code ec;
		std::filesystem::remove(pathFromUtf8(tmp), ec);
	}
#else
	std::error_code ec;
	std::filesystem::rename(pathFromUtf8(tmp), pathFromUtf8(cacheFile), ec);
	if (ec)
		std::filesystem::remove(pathFromUtf8(tmp), ec);
#endif
}

//////////////////////////////////////////////////////////////////////
//
//  FILE:       spellchk.cpp
//
//              SpellChecker class methods
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.5
//
//  Notice:     Copyright (c) 2001-2003  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

// Retrieve the list of Rating figures for given player (aka node) from the given (ssp) string
// The string is formatted as:
// [%Elo ]<year>:<<rating>|?>,...,<<rating>|?> [<year>:<<rating>|?>,...,<<rating>|?>...]
//
// The ratings are stored in a rating array for this player, in the order of appearance
// and without any assumption on the period that the rating refers to.
// This is accomplished by assuming that for all years the same number of rating figures
// could be given (see ELO_RATINGS_PER_YEAR above).
//
// The (external) algorithm to map ratings to actual periods must be able to cope with
// the holes that - as a consequence - will appear in the rating graph constructed here!
//
void PlayerElo::AddEloData(const char * str)
{
    while (1) {
        // Get the year in which the rating figures to follow were published
        //
        str = strTrimLeft (str);
        if (! isdigit(static_cast<unsigned char>(*str))) { break; }
        uint16_t year = strGetUnsigned (str);
        str += 4;
        if (*str != ':') { break; }
        str++;

        // Now read all the ratings for this year:
        //
        eloT elo = 0;
        while (1) {
            if (isdigit(static_cast<unsigned char>(*str))) {
                elo = strGetUnsigned (str);
                str += 4;
            } else if (*str == '?') {
                elo = 0;
                str++;
            } else if (*str == ' ') {
                break;
            } else {
                // Invalid data seen:
                return;
            }

            elo_.push_back(std::make_pair(year, elo));

            if (*str == ',') { str++; }
        }
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PlayerInfo::GetTitle:
//    Extract the first title appearing in the player
//    comment, and return it.
const char *
PlayerInfo::getTitle() const
{
    static const char * titles[] = {
        "GM", "IM", "FM",
        "WGM", "WIM", "WFM", "W",
        "CGM", "CIM", "HGM",
        nullptr
    };
    const char ** titlePtr = titles;

    const char* comment = GetComment();
    if (*comment == 0) { return ""; }

    while (*titlePtr != nullptr) {
        if (strIsCasePrefix (*titlePtr, comment)) { return *titlePtr; }
        titlePtr++;
    }
    return "";
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PlayerInfo::GetLastCountry:
//    Scan the player comment string for the country field (which
//    is the second field, after the title), then return the
//    last three letters in the country field, or the empty string
//    if the country field is less than 3 characters long.
const char *
PlayerInfo::getLastCountry() const
{
    static char country[4];
    country[0] = 0;

    const char* start = GetComment();
    if (*start == 0) { return ""; }

    // Skip over the title field:
    while (*start != ' '  &&  *start != 0) { start++; }
    while (*start == ' ') { start++; }

    const char * end = start;
    int length = 0;
    while (*end != ' '  &&  *end != 0) { end++; length++; }
    // Return the final three characters of the country field:
    if (length >= 3) {
        for (int i=0; i < 3; i++) { country[i] = start[length-3 + i]; }
        country[3] = 0;
    }
    return country;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PlayerInfo::GetPeakRating:
//    Scan the player comment string for the peak rating
//    field (which is contained in brackets), convert it
//    to an unsigned integer, and return it.
eloT
PlayerInfo::getPeakRating() const
{
    const char* s = GetComment();
    if (*s == 0) { return 0; }

    while (*s != '['  &&  *s != 0) { s++; }
    if (*s != '[') { return 0; }
    s++;
    return strGetUnsigned (s);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PlayerInfo::GetBirthdate:
//    Scan the player comment string for the birthdate
//    field, convert it to a date, and return it.
dateT
PlayerInfo::getBirthdate() const
{
    const char* s = GetComment();
    if (*s == 0) { return ZERO_DATE; }

    // Find the end-bracket character after the rating:
    while (*s != ']'  &&  *s != 0) { s++; }
    if (*s != ']') { return ZERO_DATE; }
    s++;
    // Now skip over any spaces:
    while (*s == ' ') { s++; }
    if (*s == 0) { return ZERO_DATE; }
    return date_EncodeFromString (s);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PlayerInfo::GetDeathdate:
//    Scan the player comment string for the deathdate
//    field, convert it to a date, and return it.
dateT
PlayerInfo::getDeathdate() const
{
    const char* s = GetComment();
    if (*s == 0) { return ZERO_DATE; }

    // Find the end-bracket character after the rating:
    while (*s != ']'  &&  *s != 0) { s++; }
    if (*s != ']') { return ZERO_DATE; }
    s++;
    // Now skip over any spaces:
    while (*s == ' ') { s++; }
    // Now skip over the birthdate and dashes:
    while (*s != 0  &&  *s != '-') { s++; }
    while (*s == '-') { s++; }
    if (*s == 0) { return ZERO_DATE; }
    return date_EncodeFromString (s);
}

//////////////////////////////////////////////////////////////////////
//  EOF: spellchk.cpp
//////////////////////////////////////////////////////////////////////
