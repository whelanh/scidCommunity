// obrbook.cpp
// Reader for OpenBook Rich (.obr) opening books (format v1, little-endian).
//
// Layout: 64-byte header, positions (48 B, sorted by Polyglot key),
// moves (8 B), aliases (12 B, sorted by key), JSON metadata.
// An alias maps a key to a position record plus a transform:
//   bit0 = colours reversed (flip ranks, swap white/black stats)
//   bit1 = files mirrored   (flip files)

#include "obrbook.h"

#include <cstdio>
#include <cstring>
#include <filesystem>
#include <utility>

#include "book.h"

namespace {

constexpr uint32_t NO_CHILD = 0xFFFFFFFFu;
constexpr int POS_SIZE = 48;
constexpr int MOVE_SIZE = 8;
constexpr int ALIAS_SIZE = 12;
constexpr uint64_t HEADER_SIZE = 64;

struct obr_file_t {
	FILE* f = nullptr;
	uint32_t n_pos = 0, n_moves = 0, n_alias = 0;
	uint64_t pos_off = 0, move_off = 0, alias_off = 0;
};

obr_file_t Obr[MaxBook];

FILE* open_utf8(const char* filename) {
#ifdef _WIN32
	auto fname = reinterpret_cast<const char8_t*>(filename);
	std::filesystem::path path{fname, fname + strlen(filename)};
	return _wfopen(path.c_str(), L"rb");
#else
	return fopen(filename, "rb");
#endif
}

bool seek64(FILE* f, uint64_t off) {
#ifdef _WIN32
	return _fseeki64(f, static_cast<__int64>(off), SEEK_SET) == 0;
#else
	return fseeko(f, static_cast<off_t>(off), SEEK_SET) == 0;
#endif
}

uint64_t file_size(FILE* f) {
#ifdef _WIN32
	auto end = _fseeki64(f, 0, SEEK_END) == 0 ? _ftelli64(f) : -1;
#else
	auto end = fseeko(f, 0, SEEK_END) == 0 ? ftello(f) : -1;
#endif
	return end < 0 ? 0 : uint64_t(end); // 0 = unknown, makes obr_open fail
}

uint64_t le(const unsigned char* p, int n) {
	uint64_t v = 0;
	for (int i = n - 1; i >= 0; --i)
		v = (v << 8) | p[i];
	return v;
}

bool read_at(const obr_file_t& o, uint64_t off, unsigned char* buf, size_t n) {
	return seek64(o.f, off) && fread(buf, 1, n, o.f) == n;
}

bool read_pos(const obr_file_t& o, uint32_t i, uint64_t& key, obr_stats_t& s,
              uint32_t& first, uint16_t& count) {
	unsigned char b[POS_SIZE];
	if (!read_at(o, o.pos_off + uint64_t(i) * POS_SIZE, b, POS_SIZE))
		return false;
	key = le(b, 8);
	s.games = uint32_t(le(b + 8, 4));
	s.white_wins = uint32_t(le(b + 12, 4));
	s.draws = uint32_t(le(b + 16, 4));
	s.black_wins = uint32_t(le(b + 20, 4));
	s.rating_games = uint32_t(le(b + 24, 4));
	s.rating_sum = uint32_t(le(b + 28, 4));
	s.perf_games = uint32_t(le(b + 32, 4));
	s.perf_sum = uint32_t(le(b + 36, 4));
	first = uint32_t(le(b + 40, 4));
	count = uint16_t(le(b + 44, 2));
	s.recommendation = b[46];
	s.flags = b[47];
	return true;
}

// Binary search on a table of fixed-size records keyed by a leading
// little-endian u64 (keys are unique). Returns the index or -1.
int64_t bsearch_key(const obr_file_t& o, uint64_t base, int size, uint32_t n,
                    uint64_t key) {
	int64_t lo = 0, hi = int64_t(n) - 1;
	unsigned char b[8];
	while (lo <= hi) {
		int64_t mid = (lo + hi) / 2;
		if (!read_at(o, base + uint64_t(mid) * size, b, 8))
			return -1;
		uint64_t k = le(b, 8);
		if (k == key)
			return mid;
		if (k < key)
			lo = mid + 1;
		else
			hi = mid - 1;
	}
	return -1;
}

bool find(const obr_file_t& o, uint64_t key, uint32_t& index, int& transform) {
	int64_t i = bsearch_key(o, o.pos_off, POS_SIZE, o.n_pos, key);
	if (i >= 0) {
		index = uint32_t(i);
		transform = 0;
		return true;
	}
	if (o.n_alias == 0)
		return false;
	int64_t j = bsearch_key(o, o.alias_off, ALIAS_SIZE, o.n_alias, key);
	if (j < 0)
		return false;
	unsigned char b[ALIAS_SIZE];
	if (!read_at(o, o.alias_off + uint64_t(j) * ALIAS_SIZE, b, ALIAS_SIZE))
		return false;
	uint32_t v = uint32_t(le(b + 8, 4));
	index = v & 0x3FFFFFFFu;
	transform = int(v >> 30);
	return index < o.n_pos;
}

void apply_transform(obr_stats_t& s, int t) {
	if (t & 1) {
		std::swap(s.white_wins, s.black_wins);
		s.flags ^= 1;
	}
}

int transform_move(int mv, int t) {
	if (!t || !mv)
		return mv;
	int from = (mv >> 6) & 63, to = mv & 63;
	if (t & 1) {
		from ^= 56;
		to ^= 56;
	}
	if (t & 2) {
		from ^= 7;
		to ^= 7;
	}
	return (mv & 0x7000) | (from << 6) | to;
}

} // namespace

int obr_open(const char file_name[], const int BookNumber) {
	obr_close(BookNumber);
	FILE* f = open_utf8(file_name);
	if (!f)
		return OBR_NOT_OBR;
	unsigned char h[64];
	// Too short for a header, or not the OBR magic: not an OBR book, so the
	// caller may fall back to the Polyglot reader.
	if (fread(h, 1, 64, f) != 64 || memcmp(h, "OBR1", 4) != 0) {
		fclose(f);
		return OBR_NOT_OBR;
	}
	// It claims to be OBR, so any failure from here on is a rejected OBR file.
	if (le(h + 4, 2) != 1 || le(h + 20, 2) != POS_SIZE ||
	    le(h + 22, 2) != MOVE_SIZE) {
		fclose(f);
		return OBR_REJECTED;
	}
	obr_file_t o;
	o.f = f;
	o.n_pos = uint32_t(le(h + 8, 4));
	o.n_moves = uint32_t(le(h + 12, 4));
	o.n_alias = uint32_t(le(h + 16, 4));
	o.pos_off = le(h + 24, 8);
	o.move_off = le(h + 32, 8);
	o.alias_off = le(h + 40, 8);
	// Reject empty or truncated files: each table must start after the header,
	// lie inside the file, and be ordered and non-overlapping (positions, then
	// moves, then aliases).
	const uint64_t size = file_size(f);
	auto fits = [size](uint64_t off, uint64_t n, uint64_t rec) {
		return off >= HEADER_SIZE && off <= size && n * rec <= size - off;
	};
	const uint64_t pos_end = o.pos_off + uint64_t(o.n_pos) * POS_SIZE;
	const uint64_t move_end = o.move_off + uint64_t(o.n_moves) * MOVE_SIZE;
	if (o.n_pos == 0 || !fits(o.pos_off, o.n_pos, POS_SIZE) ||
	    !fits(o.move_off, o.n_moves, MOVE_SIZE) ||
	    !fits(o.alias_off, o.n_alias, ALIAS_SIZE) ||
	    o.move_off < pos_end || o.alias_off < move_end) {
		fclose(f);
		return OBR_REJECTED;
	}
	Obr[BookNumber] = o;
	return OBR_OPENED;
}

void obr_close(const int BookNumber) {
	obr_file_t& o = Obr[BookNumber];
	if (o.f)
		fclose(o.f);
	o = obr_file_t{};
}

bool obr_is_open(const int BookNumber) { return Obr[BookNumber].f != nullptr; }

bool obr_contains(const board_t* board, const int BookNumber) {
	const obr_file_t& o = Obr[BookNumber];
	uint32_t idx;
	int t;
	return o.f && find(o, board->key, idx, t);
}

bool obr_probe(const board_t* board, const int BookNumber, obr_stats_t& pos,
               std::vector<obr_move_t>& moves, int& transform) {
	moves.clear();
	const obr_file_t& o = Obr[BookNumber];
	if (!o.f)
		return false;
	uint32_t idx;
	if (!find(o, board->key, idx, transform))
		return false;
	uint64_t key;
	uint32_t first;
	uint16_t count;
	if (!read_pos(o, idx, key, pos, first, count))
		return false;
	apply_transform(pos, transform);
	// Reject a move range that runs past the move table; a corrupt position
	// could otherwise report success with no moves read. uint64_t avoids the
	// wrap at the uint32_t boundary.
	if (uint64_t(first) + count > o.n_moves)
		return false;
	for (uint32_t k = first; k < first + count; ++k) {
		unsigned char b[MOVE_SIZE];
		if (!read_at(o, o.move_off + uint64_t(k) * MOVE_SIZE, b, MOVE_SIZE))
			break;
		obr_move_t m;
		m.move = transform_move(int(le(b, 2)), transform);
		m.annotation = b[2];
		m.status = b[3];
		uint32_t child = uint32_t(le(b + 4, 4));
		if (child != NO_CHILD && child < o.n_pos) {
			uint64_t ck;
			uint32_t cf;
			uint16_t cc;
			if (read_pos(o, child, ck, m.child, cf, cc)) {
				apply_transform(m.child, transform);
				m.has_child = true;
			}
		}
		moves.push_back(m);
	}
	return true;
}

// end of obrbook.cpp
