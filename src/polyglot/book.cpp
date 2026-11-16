
// book.cpp

// includes

#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <string>

#ifdef _WIN32
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <fcntl.h>
#include <io.h>
#include <sys/stat.h>
#include <windows.h>
#else
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

#include "board.h"
#include "book.h"
#include "list.h"
#include "move.h"
#include "move_do.h"
#include "move_gen.h"
#include "move_legal.h"
#include "san.h"
#include "util.h"

// The filenames received from Tcl are UTF-8 encoded, but on Windows fopen() and
// std::filesystem interpret narrow strings using the ANSI code page: convert
// explicitly.
// Note: cannot use misc.h/fopenUtf8 here because the polyglot headers clash
// with the scid ones (e.g. the global A1..H8 constants).
static std::filesystem::path path_utf8(const char* filename) {
#ifdef _WIN32
	auto fname = reinterpret_cast<const char8_t*>(filename);
	return std::filesystem::path{fname, fname + strlen(filename)};
#else
	return std::filesystem::path{filename};
#endif
}

static FILE* fopen_utf8(const char* filename, const char* mode) {
#ifdef _WIN32
	wchar_t wmode[8] = {};
	for (size_t i = 0; i < 7 && mode[i]; ++i)
		wmode[i] = static_cast<wchar_t>(mode[i]);
	return _wfopen(path_utf8(filename).c_str(), wmode);
#else
	return fopen(filename, mode);
#endif
}

// Do two slots name the same book? The Book window and the Book tuning window
// are handed the same path by the file dialog, but a differently spelled path
// (relative, other separator) must not hide the second slot from a rewrite: a
// slot left open keeps the BookSize it read and reads past EOF after a shrink.
static bool same_book(const std::string& a, const std::string& b) {
	if (a.empty() || b.empty()) return false;
	if (a == b) return true;
	std::error_code ec;
	const auto ca = std::filesystem::weakly_canonical(path_utf8(a.c_str()), ec);
	if (ec) return false;
	const auto cb = std::filesystem::weakly_canonical(path_utf8(b.c_str()), ec);
	if (ec) return false;
	return ca == cb;
}

// Carry the book's permission bits onto the file that is about to replace it.
// The rename replaces the inode, so the mode of the staged file -- 0644 under
// the usual umask -- would otherwise become the book's, and a 0600 book would
// come back readable by every user. A book that does not exist yet keeps the
// mode its staging file was created with: there is nothing to carry over.
static bool carry_book_mode(const std::filesystem::path& staged,
                            const std::filesystem::path& book) {
#ifdef _WIN32
	// MoveFileExW promotes the *staged* file's security descriptor, and that is
	// the descriptor the staged file inherited from the directory it was
	// created in. An inherited ACE therefore keeps the book as private as the
	// staging directory is; a per-file ACL set by hand on the book is not
	// carried over, and Windows has no mode bits that could stand in for it.
	// scidCommunity does not edit per-book ACLs, so this is the whole story --
	// do not read it as full ACL retention.
	(void)staged;
	(void)book;
	return true;
#else
	std::error_code ec;
	// status() follows a symlink, which is what the rename lands on.
	const auto status = std::filesystem::status(book, ec);
	if (ec) return true; // no book to copy from: the created mode stands
	const auto perms = status.permissions();
	if (perms == std::filesystem::perms::unknown) return true;
	std::filesystem::permissions(staged, perms,
	                             std::filesystem::perm_options::replace, ec);
	// A book whose mode could not be carried would land with the staging file's
	// mode instead, which is what the finding is about: refuse the promotion
	// rather than hand over a file less protected than the one it replaces.
	return !ec;
#endif
}

// The name a replacement sibling gets: a suffix after the book's own name, so
// it lands on the book's filesystem and no other save can pick it by accident.
static std::filesystem::path staging_name(const std::filesystem::path& book,
                                          int attempt) {
	char suffix[32];
	std::snprintf(suffix, sizeof suffix, ".tmp-%ld-%d",
#ifdef _WIN32
	              static_cast<long>(_getpid()),
#else
	              static_cast<long>(getpid()),
#endif
	              attempt);
#ifdef _WIN32
	std::wstring name = book.native();
	name.append(suffix, suffix + std::strlen(suffix));
	return std::filesystem::path{name};
#else
	return std::filesystem::path{book.native() + suffix};
#endif
}

// Stage a copy of `source` beside `book` under a name claimed exclusively before
// a byte is written. The old fallback copied onto a fixed `book + ".tmp"` with
// overwrite_existing: a stranded staging file from an interrupted save, or any
// file the user happened to put there, lost its contents, and copy_file follows
// a symlink placed at the destination. O_EXCL means the name is ours before it
// can be anything else, a taken name is retried under another suffix and never
// overwritten, and only the file this call created is removed on failure.
static bool stage_beside(const char* source, const std::filesystem::path& book,
                         std::filesystem::path& staged) {
	FILE* in = fopen_utf8(source, "rb");
	if (in == nullptr) return false;
	bool staged_ok = false;
	for (int attempt = 0; attempt < 32 && !staged_ok; ++attempt) {
		const std::filesystem::path candidate = staging_name(book, attempt);
#ifdef _WIN32
		const int fd = _wopen(candidate.c_str(),
		                      _O_WRONLY | _O_CREAT | _O_EXCL | _O_BINARY,
		                      _S_IREAD | _S_IWRITE);
		FILE* out = (fd < 0) ? nullptr : _fdopen(fd, "wb");
#else
		const int fd = open(candidate.c_str(), O_WRONLY | O_CREAT | O_EXCL, 0600);
		FILE* out = (fd < 0) ? nullptr : fdopen(fd, "wb");
#endif
		if (out == nullptr) {
			// Someone else's file is at that name: leave it alone and try
			// another, never truncate it.
			if (fd >= 0) {
#ifdef _WIN32
				_close(fd);
#else
				close(fd);
#endif
			}
			continue;
		}
		char buf[65536];
		size_t n;
		int failed = 0;
		while ((n = fread(buf, 1, sizeof buf, in)) > 0) {
			if (fwrite(buf, 1, n, out) != n) {
				failed = 1;
				break;
			}
		}
		if (ferror(in)) failed = 1;
		if (fflush(out) != 0) failed = 1;
		if (fclose(out) != 0) failed = 1;
		if (failed) {
			std::error_code ignored;
			std::filesystem::remove(candidate, ignored);
			break; // a write error does not clear up under another name
		}
		staged = candidate;
		staged_ok = true;
	}
	fclose(in);
	return staged_ok;
}

// Put the staged replacement in place with one rename: the operation is then
// all-or-nothing. Copying the surviving entries back into the live file is not
// -- a failure after the copy leaves the new entries followed by the old tail,
// while the caller still holds the old entry count, and a reopen reads the
// removed entry again. The caller closes the slots first: Windows cannot
// replace an open file.
//
// The rename lands on the file the book name *resolves* to. A book opened
// through a symlink must be rewritten at the link's target: renaming onto the
// name itself replaces the link with a regular file and leaves the book the
// user picked holding the old contents.
static bool replace_book_file(const char* tempfile, const std::string& target) {
	std::filesystem::path book = path_utf8(target.c_str());
	std::error_code ec;
	if (std::filesystem::exists(book, ec) && !ec) {
		const auto real = std::filesystem::canonical(book, ec);
		if (!ec) book = real;
	}
	if (!carry_book_mode(path_utf8(tempfile), book)) return false;
#ifdef _WIN32
	// std::filesystem::rename fails on Windows if the destination exists;
	// MoveFileExW with MOVEFILE_REPLACE_EXISTING replaces it and keeps the
	// original intact until the temporary file is promoted.
	if (MoveFileExW(path_utf8(tempfile).c_str(), book.c_str(),
	                MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH)) {
		return true;
	}
#else
	std::filesystem::rename(path_utf8(tempfile), book, ec);
	if (!ec) return true;
#endif
	// The staging file need not be on the book's filesystem -- the window puts
	// it under the user directory, the book lives under the books directory, and
	// on Windows those are often different drives. A rename cannot cross
	// devices, so stage a copy beside the book and rename that instead: the step
	// that changes the book is still a single rename, on its own filesystem.
	std::filesystem::path sibling;
	if (!stage_beside(tempfile, book, sibling)) return false;
	if (!carry_book_mode(sibling, book)) {
		std::error_code ignored;
		std::filesystem::remove(sibling, ignored); // ours, and only ours
		return false;
	}
#ifdef _WIN32
	if (!MoveFileExW(sibling.c_str(), book.c_str(),
	                 MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH)) {
		std::error_code ignored;
		std::filesystem::remove(sibling, ignored);
		return false;
	}
#else
	std::filesystem::rename(sibling, book, ec);
	if (ec) {
		std::error_code ignored;
		std::filesystem::remove(sibling, ignored);
		return false;
	}
#endif
	return true;
}

// types

struct entry_t {
	uint64_t key;
	uint16_t move;
	uint16_t count;
	int16_t engine_score;
	uint8_t engine_depth;
	uint8_t engine_name_idx;
};

// variables
static FILE* BookFile[MaxBook];

static int BookSize[MaxBook];

// The path a slot was opened from, and whether it could only be opened
// read-only. A rewrite replaces the file under every slot that reads it, so it
// has to know which slots those are -- and reopen them with the access they had
// rather than handing a read-only book write access.
static std::string BookName[MaxBook];

static bool BookReadOnly[MaxBook];

// prototypes

static int find_pos(uint64 key, const int BookNumber);

static int open_book_slot(const char file_name[], const int BookNumber,
                          const bool read_only);
static void close_slot(const int BookNumber);

static void read_entry(entry_t* entry, int n, const int BookNumber);
static void write_entry(const entry_t* entry, int n, const int BookNumber);

static void read_entry_file(FILE* f, entry_t* entry);
static void write_entry_file(FILE* f, const entry_t* entry);

static uint64 read_integer(FILE* file, int size);
static void write_integer(FILE* file, int size, uint64 n);

// functions

// =================================================================
// Pascal Georges : functions added to interface with Scid
// =================================================================
board_t scid_board[MaxBook][1];
void scid_book_update(char* probs, const int BookNumber) {

	int first_pos;
	int sum;
	int pos;
	entry_t entry[1];
	int prob[100];
	int prob_count = 0;
	int prob_sum = 0;
	int i;

	/* parse probs and fill prob array */
	char* s;

	s = strtok(probs, " ");
	if (s != nullptr) {
		sscanf(s, "%d", &(prob[prob_count]));
		prob_count++;
		while ((s = strtok(nullptr, " ")) != nullptr) {
			if (prob_count >= 100) return;
			sscanf(s, "%d", &(prob[prob_count]));
			prob_count++;
		}
	}

	first_pos = find_pos(scid_board[BookNumber]->key, BookNumber);

	// sum

	sum = 10000;

	for (i = 0; i < prob_count; i++)
		prob_sum += prob[i];

	double coef = (prob_sum) ? double(sum) / double(prob_sum) : 0;

	i = 0;
	for (pos = first_pos; pos < BookSize[BookNumber] && i < prob_count; pos++) {
		read_entry(entry, pos, BookNumber);
		if (entry->key != scid_board[BookNumber]->key)
			break;
		// change entry weight : no entry count == 0
		if (prob[i] != 0) {
			entry->count = int(double(prob[i]) * coef);
		} else {
			entry->count = 1;
		}
		i++;
		write_entry(entry, pos, BookNumber);
	}
}

#define MAX_MOVES 100

int scid_book_movesupdate(char* moves, char* probs, const int BookNumber,
                          char* tempfile) {

	int maximum;
	int pos;
	entry_t entry[1], entry1[1];
	uint16 move[MAX_MOVES];
	int prob[MAX_MOVES];
	int move_count = 0;
	int prob_count = 0;
	int prob_max = 0;
	double coef = 1.0;
	int probs_written;
	int write_count;
	int surviving;
	int i;
	FILE* f;
	char *probs_copy, *moves_copy;
	//	printf("Updating book: moves=%s; probs=%s; tempfile=%s;
	// key=%016llx.\n",moves,probs,tempfile,scid_board[BookNumber]->key);
	/* parse probs and fill prob array */
	char* s;
	probs_copy = strdup(probs); // strtok modifies its first argument
	s = strtok(probs_copy, " ");
	if (s != nullptr) {
		sscanf(s, "%d", &(prob[prob_count]));
		prob_count++;
		while ((s = strtok(nullptr, " ")) != nullptr) {
			if (prob_count >= MAX_MOVES) {
				free(probs_copy);
				return -1; // fail
			}
			sscanf(s, "%d", &(prob[prob_count]));
			prob_count++;
		}
	}
	free(probs_copy);
	// max
	maximum = 0xfff0;

	for (i = 0; i < prob_count; i++)
		if (prob[i] > prob_max)
			prob_max = prob[i];
	if (prob_max != 0) { // avoid division by zero
		coef = double(maximum) / double(prob_max);
	}

	/* parse moves and fill move array */
	moves_copy = strdup(moves); // strtok modifies its first argument
	move_count = 0;
	s = strtok(moves_copy, " ");
	if (s != nullptr) {
		move[move_count] = move_from_san(s, scid_board[BookNumber]);
		move_count++;
		while ((s = strtok(nullptr, " ")) != nullptr) {
			if (move_count >= MAX_MOVES) {
				free(moves_copy);
				return -1; // fail
			}
			move[move_count] = move_from_san(s, scid_board[BookNumber]);
			move_count++;
		}
	}
	free(moves_copy);
	if (prob_count != move_count) {
		return -1; // fail
	}
	if (prob_count == 0) {
		// Don't return. If we're deleting the last move, we have to write the
		// file return 0; // nothing to do
	}

	// The update must not empty the book. scid_book_open treats a zero-length
	// file as "not a book" (BookSize = ftell / 16 == 0 -> -1), so cutting the
	// last entry away would leave a file the app can never open again, and
	// nothing else in the tree expects a book with no entries. Decide it here,
	// before a replacement is staged or anything is renamed: a refusal must
	// leave the book exactly as it was.
	if (BookFile[BookNumber] == nullptr || BookName[BookNumber].empty()) {
		return -1; // fail: the slot has no open stream on a file
	}
	surviving = BookSize[BookNumber];
	if (fseek(BookFile[BookNumber], 0, SEEK_SET) != 0) {
		return -1; // fail
	}
	for (pos = 0; pos < BookSize[BookNumber]; pos++) {
		read_entry_file(BookFile[BookNumber], entry);
		if (entry->key == scid_board[BookNumber]->key)
			surviving--;
	}
	if (surviving + move_count <= 0) {
		return -1; // fail
	}

	if (!(f = fopen_utf8(tempfile, "wb+"))) {
		return -1; // fail
	}
	probs_written = 0;
	write_count = 0;

	fseek(BookFile[BookNumber], 0, SEEK_SET);

	for (pos = 0; pos < BookSize[BookNumber]; pos++) {
		read_entry_file(BookFile[BookNumber], entry);
		if ((entry->key < scid_board[BookNumber]->key) ||
		    ((entry->key > scid_board[BookNumber]->key) && probs_written)) {
			write_count++;
			write_entry_file(f, entry);
		} else if (!probs_written) {
			for (i = 0; i < move_count; i++) {
				entry1->key = scid_board[BookNumber]->key;
				entry1->move = move[i];
				if (prob[i] != 0) {
					entry1->count = int(double(prob[i]) * coef);
				} else {
					entry1->count = 1;
				}
				entry1->engine_score = 0;
				entry1->engine_depth = 0;
				entry1->engine_name_idx = 0;
				write_count++;
				write_entry_file(f, entry1);
			}
			if (entry->key > scid_board[BookNumber]->key) {
				write_count++;
				write_entry_file(f, entry);
			}
			probs_written = 1;
		}
	}
	if (!probs_written) { // not nice...
		for (i = 0; i < move_count; i++) {
			entry1->key = scid_board[BookNumber]->key;
			entry1->move = move[i];
			if (prob[i] != 0) {
				entry1->count = int(double(prob[i]) * coef);
			} else {
				entry1->count = 1;
			}
			entry1->engine_score = 0;
			entry1->engine_depth = 0;
			entry1->engine_name_idx = 0;
			write_count++;
			write_entry_file(f, entry1);
		}
		probs_written = 1;
	}
	ASSERT(probs_written);
	if (write_count == 0) {
		fclose(f);
		return -1; // fail
	}
	// The replacement is complete in the tempfile. Close it, and only then touch
	// the book: the surviving entries are already in place, so the rename below
	// is the whole write. fclose must run even when fflush has already failed,
	// so a failed flush cannot leak the staging file.
	int flush_err = fflush(f);
	int close_err = fclose(f);
	if (flush_err != 0 || close_err != 0) {
		return -1; // fail: the original is untouched
	}

	// Every slot reading this file has to let go of it before the rename: on
	// Windows an open file cannot be replaced, and on any platform a slot left
	// open keeps the BookSize it read before the rewrite -- after a shrink its
	// bounded loops then read past EOF and hand back garbage moves. Remember
	// which slots were open, and the access they had, to reopen them onto the
	// new file.
	const std::string target = BookName[BookNumber];
	bool wasOpen[MaxBook] = {};
	bool wasReadOnly[MaxBook] = {};
	std::string wasName[MaxBook];
	for (i = 0; i < MaxBook; i++) {
		wasOpen[i] = BookFile[i] != nullptr && same_book(BookName[i], target);
		wasReadOnly[i] = BookReadOnly[i];
		wasName[i] = BookName[i];
		if (wasOpen[i]) close_slot(i);
	}
	// Reopen each slot on the path it was opened with, not on the edited slot's
	// name: two slots can read one book through different names (a symlink, or
	// the path the file dialog happened to hand out), and reopening them all on
	// the edited name moves a slot onto a file it never read.
	if (!replace_book_file(tempfile, target)) {
		// Nothing of the book was touched: put the slots back on the original.
		for (i = 0; i < MaxBook; i++) {
			if (wasOpen[i]) open_book_slot(wasName[i].c_str(), i, wasReadOnly[i]);
		}
		return -1; // fail
	}
	int failed = 0;
	for (i = 0; i < MaxBook; i++) {
		if (!wasOpen[i]) continue;
		if (open_book_slot(wasName[i].c_str(), i, wasReadOnly[i]) < 0) {
			failed = 1; // the slot stays closed rather than holding a stale count
		}
	}
	return failed ? -1 : 0;
}

// =================================================================
// Drop a slot's stream and the count it was holding: after a rewrite the count
// belongs to a file that no longer exists.
static void close_slot(const int BookNumber) {
	if (BookFile[BookNumber] != nullptr) {
		fclose(BookFile[BookNumber]);
		BookFile[BookNumber] = nullptr;
	}
	BookSize[BookNumber] = 0;
}
// =================================================================
int scid_book_close(const int BookNumber) {
	if (BookFile[BookNumber] == nullptr) {
		return 0;
	}
	const int res = (fclose(BookFile[BookNumber]) == EOF) ? -1 : 0;
	BookFile[BookNumber] = nullptr;
	BookSize[BookNumber] = 0;
	BookName[BookNumber].clear();
	BookReadOnly[BookNumber] = false;
	return res;
}
// =================================================================
// Open one slot onto a book file with the access the caller asks for, so a slot
// reopened after a rewrite keeps the access it was opened with. Returns 0 for a
// read-write slot, 1 for a read-only one, -1 on failure.
static int open_book_slot(const char file_name[], const int BookNumber,
                          const bool read_only) {

	BookFile[BookNumber] = fopen_utf8(file_name, read_only ? "rb" : "rb+");
	if (BookFile[BookNumber] == nullptr)
		return -1;

	if (fseek(BookFile[BookNumber], 0, SEEK_END) == -1) {
		close_slot(BookNumber);
		return -1;
	}

	BookSize[BookNumber] = ftell(BookFile[BookNumber]) / 16;
	if (BookSize[BookNumber] == 0) {
		close_slot(BookNumber);
		return -1;
	}
	BookName[BookNumber] = file_name;
	BookReadOnly[BookNumber] = read_only;
	return read_only ? 1 : 0; // success
}
// =================================================================
int scid_book_open(const char file_name[], const int BookNumber) {

	int ReadOnlyFile = 0;

	// the book can not be opened in read/write mode, try read only
	if (open_book_slot(file_name, BookNumber, false) < 0) {
		ReadOnlyFile = 1;
		if (open_book_slot(file_name, BookNumber, true) < 0)
			return -1;
	}
	return (0 + ReadOnlyFile); // success
}

// =========================================================
// similar signature as gen_legal_moves
int gen_book_moves(list_t* list, const board_t* board, const int BookNumber) {
	int first_pos, pos;
	entry_t entry[1];
	list_clear(list);
	first_pos = find_pos(board->key, BookNumber);
	for (pos = first_pos; pos < BookSize[BookNumber]; pos++) {
		read_entry(entry, pos, BookNumber);
		if (entry->key != board->key)
			break;
		if (entry->count > 0 && entry->move != MoveNone &&
		    move_is_legal(entry->move, board)) {
			list_add(list, entry->move);
		}
	}
	return 0;
}

// =================================================================
std::vector<std::tuple<int16_t, uint8_t, uint8_t>>
scid_book_disp(const board_t* board, char* s, const int BookNumber) {

	int first_pos;
	int sum;
	int pos;
	entry_t entry[1];
	int move;
	int score;

	// keep board in memory to ease book update
	memcpy(scid_board[BookNumber], board, sizeof(board_t));

	first_pos = find_pos(board->key, BookNumber);

	// sum

	sum = 0;

	for (pos = first_pos; pos < BookSize[BookNumber]; pos++) {

		read_entry(entry, pos, BookNumber);
		if (entry->key != board->key)
			break;
		sum += entry->count;
	}

	// disp
	std::vector<std::tuple<int16_t, uint8_t, uint8_t>> extra_info;
	s[0] = '\0';
	for (pos = first_pos; pos < BookSize[BookNumber]; pos++) {
		read_entry(entry, pos, BookNumber);
		if (entry->key != board->key)
			break;

		move = entry->move;
		score = entry->count;
		if (score > 0 && move != MoveNone && move_is_legal(move, board)) {
			char tmp[256] = {' '};
			move_to_san(move, board, tmp + 1, 255);
			std::snprintf(tmp + std::strlen(tmp), sizeof(tmp) - std::strlen(tmp),
			              " %.0f%%", (double(score) / double(sum)) * 100.0);
			strcat(s, tmp);

			extra_info.emplace_back(entry->engine_score, entry->engine_depth,
			                        entry->engine_name_idx);
		}
	}

	return extra_info;
}

// =================================================================
int scid_position_book_disp(const board_t* board, char* s,
                            const int BookNumber) {

	int move;
	list_t /*book_moves[1],*/ legal_moves[1];
	int i;
	s[0] = '\0';
	gen_legal_moves(legal_moves, board);
	//   gen_book_moves(book_moves,board,BookNumber);
	for (i = 0; i < list_size(legal_moves); i++) {
		move = list_move(legal_moves, i);
		//       if(list_contain(book_moves,move)) continue;
		// scratch_board
		board_t new_board = *board;
		move_do(&new_board, move);
		if (is_in_book(&new_board, BookNumber)) {
			char tmp[256] = {' '};
			move_to_san(move, board, tmp + 1, 255);
			strcat(s, tmp);
		}
	}
	return 0;
}

// =================================================================

// book_clear()

void book_clear(const int BookNumber) {

	BookFile[BookNumber] = nullptr;
	BookSize[BookNumber] = 0;
	BookName[BookNumber].clear();
	BookReadOnly[BookNumber] = false;
}

// book_open()

void book_open(const char file_name[], const int BookNumber) {

	ASSERT(file_name != nullptr);

	BookFile[BookNumber] = fopen_utf8(file_name, "rb+");

	if (BookFile[BookNumber] == nullptr)
		my_fatal("book_open(): can't open file \"%s\": %s\n", file_name,
		         strerror(errno));

	if (fseek(BookFile[BookNumber], 0, SEEK_END) == -1) {
		my_fatal("book_open(): fseek(): %s\n", strerror(errno));
	}

	BookSize[BookNumber] = ftell(BookFile[BookNumber]) / 16;

	if (BookSize[BookNumber] == 0)
		my_fatal("book_open(): empty file\n");

	BookName[BookNumber] = file_name;
	BookReadOnly[BookNumber] = false;
}

// book_close()

void book_close(const int BookNumber) {
	if (fclose(BookFile[BookNumber]) == EOF) {
		my_fatal("book_close(): fclose(): %s\n", strerror(errno));
	}
}

// is_in_book()

bool is_in_book(const board_t* board, const int BookNumber) {

	int pos;
	entry_t entry[1];

	ASSERT(board != nullptr);
	for (pos = find_pos(board->key, BookNumber); pos < BookSize[BookNumber];
	     pos++) {
		read_entry(entry, pos, BookNumber);
		if (entry->key == board->key)
			return true;
	}

	return false;
}

// book_flush()

void book_flush(const int BookNumber) {
	if (fflush(BookFile[BookNumber]) == EOF) {
		my_fatal("book_flush(): fflush(): %s\n", strerror(errno));
	}
}

// find_pos()

static int find_pos(uint64 key, const int BookNumber) {

	int left, right, mid;
	entry_t entry[1];

	// binary search (finds the leftmost entry)
	left = 0;
	right = BookSize[BookNumber] - 1;

	ASSERT(left <= right);

	while (left < right) {

		mid = (left + right) / 2;
		ASSERT(mid >= left && mid < right);

		read_entry(entry, mid, BookNumber);

		if (key <= entry->key) {
			right = mid;
		} else {
			left = mid + 1;
		}
	}

	ASSERT(left == right);

	read_entry(entry, left, BookNumber);

	return (entry->key == key) ? left : BookSize[BookNumber];
}

// read_entry()
static void read_entry_file(FILE* f, entry_t* entry) {
	ASSERT(entry != nullptr);

	entry->key = read_integer(f, 8);
	entry->move = static_cast<uint16_t>(read_integer(f, 2));
	entry->count = static_cast<uint16_t>(read_integer(f, 2));
	entry->engine_score = static_cast<uint8_t>(read_integer(f, 1));
	int score_hi = static_cast<int8_t>(read_integer(f, 1)) * 256;
	entry->engine_score += static_cast<int16_t>(score_hi);
	entry->engine_depth = static_cast<uint8_t>(read_integer(f, 1));
	entry->engine_name_idx = static_cast<uint8_t>(read_integer(f, 1));
}

// read_entry()
static void read_entry(entry_t* entry, int n, const int BookNumber) {
	ASSERT(entry != nullptr);
	ASSERT(n >= 0 && n < BookSize[BookNumber]);
	if (fseek(BookFile[BookNumber], n * 16, SEEK_SET) == -1) {
		my_fatal("read_entry(): fseek(): %s\n", strerror(errno));
	}

	read_entry_file(BookFile[BookNumber], entry);
}

// write_entry_file
static void write_entry_file(FILE* f, const entry_t* entry) {
	ASSERT(entry != nullptr);
	write_integer(f, 8, entry->key);
	write_integer(f, 2, entry->move);
	write_integer(f, 2, entry->count);
	const auto score = static_cast<uint16_t>(entry->engine_score);
	write_integer(f, 1, score & 0xFF);
	write_integer(f, 1, score >> 8);
	write_integer(f, 1, entry->engine_depth);
	write_integer(f, 1, entry->engine_name_idx);
}

// write_entry()
static void write_entry(const entry_t* entry, int n, const int BookNumber) {

	ASSERT(entry != nullptr);
	ASSERT(n >= 0 && n < BookSize[BookNumber]);
	if (fseek(BookFile[BookNumber], n * 16, SEEK_SET) == -1) {
		my_fatal("write_entry(): fseek(): %s\n", strerror(errno));
	}

	write_entry_file(BookFile[BookNumber], entry);
}

// read_integer()
static uint64 read_integer(FILE* file, int size) {
	uint64 n;
	int i;
	int b;
	ASSERT(file != nullptr);
	ASSERT(size > 0 && size <= 8);

	n = 0;

	for (i = 0; i < size; i++) {

		b = fgetc(file);
		if (b == EOF) {
			if (feof(file)) {
				my_fatal("read_integer(): fgetc(): EOF reached\n");
			} else { // error
				my_fatal("read_integer(): fgetc(): %s\n", strerror(errno));
			}
		}

		ASSERT(b >= 0 && b < 256);
		n = (n << 8) | b;
	}

	return n;
}

// write_integer()
static void write_integer(FILE* file, int size, uint64 n) {
	int i;
	int b;
	ASSERT(file != nullptr);
	ASSERT(size > 0 && size <= 8);
	ASSERT(size == 8 || n >> (size * 8) == 0);

	for (i = size - 1; i >= 0; i--) {

		b = (n >> (i * 8)) & 0xFF;
		ASSERT(b >= 0 && b < 256);
		if (fputc(b, file) == EOF) {
			my_fatal("write_integer(): fputc(): %s\n", strerror(errno));
		}
	}
}

// end of book.cpp
