/*
 * Copyright (C) 2011  Gerd Lorscheid
 * Copyright (C) 2011-2017  Fulvio Benini
 *
 * This file is part of Scid (Shane's Chess Information Database).
 *
 * Scid is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation.
 *
 * Scid is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Scid.  If not, see <http://www.gnu.org/licenses/>.
 */

/** @file
 * Implements the SortCache class, which sorts the games of an @e Index.
 */

#include "sortcache.h"
#include "hfilter.h"
#include "index.h"
#include "misc.h"
#include "namebase.h"
#include <algorithm>
#include <climits>
#include <cstring>
#include <numeric>
#include <thread>
#include <cmath>

/**
 * Blocks the current thread until the thread @e th_ finishes its execution.
 */
void SortCache::th_join() {
	if (th_ != nullptr) {
		static_cast<std::thread*>(th_)->join();
		delete static_cast<std::thread*>(th_);
		th_ = nullptr;
	}
}

/**
 * Populate @e fullMap_ with the sorted ids of all the games contained into @e
 * index_. This function can run in a worker thread and can be interrupted.
 * It is necessary to invoke th_interrupt() or th_join() before modifying the
 * SortCache object, or the associated Index and NameBase objects.
 */
void SortCache::th_sort() {
	gamenumT* begin = fullMap_;
	const size_t n = nGames_;
	std::iota(begin, begin + n, 0);

	// The comparator is constant for the whole run: std::sort, std::partition
	// and friends require a strict weak ordering for the duration of the
	// call, so the sort is cancelled between two steps instead (see
	// th_sort_range()).
	int depth = 2 * static_cast<int>(std::log2(std::max<size_t>(n, 2)));
	th_sort_range(begin, begin + n, depth);

	if (th_interrupt_)
		return;

	ASSERT(std::is_sorted(begin, begin + n, CmpLess(this)));
	this->valid_fullMap_ = true;
}

/**
 * Heap sort [first, last) with the key cache comparator.
 *
 * Used as introsort's fallback when the pivot choices degenerate; it checks
 * th_interrupt_ between the steps, so a cancelled sort still stops quickly.
 */
void SortCache::th_heap_sort_range(gamenumT* first, gamenumT* last) {
	const ptrdiff_t n = last - first;
	if (n < 2)
		return;
	CmpLess comp(this);
	const ptrdiff_t lastNode = n - 1;
	for (ptrdiff_t node = (lastNode - 1) / 2; node >= 0; --node) {
		if (th_interrupt_)
			return;
		for (ptrdiff_t toSift = node;;) {
			const ptrdiff_t leftChild = 2 * toSift + 1;
			const ptrdiff_t rightChild = 2 * toSift + 2;
			if (leftChild > lastNode)
				break;
			const ptrdiff_t maxChild = (rightChild <= lastNode &&
			                            comp(first[leftChild], first[rightChild]))
			                               ? rightChild
			                               : leftChild;
			if (!comp(first[toSift], first[maxChild]))
				break;
			std::swap(first[toSift], first[maxChild]);
			toSift = maxChild;
		}
	}
	for (ptrdiff_t i = n; i > 0; --i) {
		if (th_interrupt_)
			return;
		std::pop_heap(first, first + i, comp);
	}
}

/**
 * Sort [first, last) with quicksort over the key cache.
 *
 * The recursion checks th_interrupt_ before every partition, so a cancelled
 * sort stops within one partition without ever changing the comparator's
 * answers. A depth limit falls back to std::sort on the remaining range,
 * which bounds the worst case.
 */
void SortCache::th_sort_range(gamenumT* first, gamenumT* last, int depth) {
	CmpLess comp(this);
	while (last - first > 24) {
		if (th_interrupt_)
			return;
		if (depth <= 0) {
			// Introsort's safety net for a pathological pivot sequence: a
			// heap sort, which can be abandoned between two steps.
			th_heap_sort_range(first, last);
			return;
		}
		// Median of three at the front, then three-way-less partition.
		gamenumT* mid = first + (last - first) / 2;
		if (comp(*mid, *first))
			std::iter_swap(mid, first);
		if (comp(*(last - 1), *first))
			std::iter_swap(last - 1, first);
		if (comp(*(last - 1), *mid))
			std::iter_swap(last - 1, mid);
		std::iter_swap(first, mid);

		gamenumT* cut = std::partition(first + 1, last, [&](gamenumT g) {
			return comp(g, *first);
		});
		std::iter_swap(first, cut - 1);
		--depth;
		// Sort the smaller part recursively, keep looping on the larger one.
		if (cut - 1 - first < last - cut) {
			th_sort_range(first, cut - 1, depth);
			first = cut;
		} else {
			th_sort_range(cut, last, depth);
			last = cut - 1;
		}
	}
	std::sort(first, last, comp);
}

SortCache::SortCache(const Index* idx, const NameBase* nbase)
    : nGames_(0), valid_fullMap_(false), th_interrupt_(false),
      partialKey_(false), fullMap_(nullptr), th_(nullptr), key_(nullptr), index_(idx),
      nbase_(nbase), refCount_(0) {}

SortCache::~SortCache() {
	th_interrupt();
	delete_huge(key_, nGames_);
	delete_huge(fullMap_, nGames_);
}

SortCache* SortCache::create(const Index* idx, const NameBase* nb,
                             const char* criteria) {
	ASSERT(idx != nullptr && nb != nullptr && criteria != nullptr);

	static const char fields[] = {
	    SORTING_date,       SORTING_year,         SORTING_event,
	    SORTING_site,       SORTING_round,        SORTING_white,
	    SORTING_black,      SORTING_eco,          SORTING_result,
	    SORTING_moveCount,  SORTING_avgElo,       SORTING_country,
	    SORTING_deleted,    SORTING_eventdate,    SORTING_whiteelo,
	    SORTING_blackelo,   SORTING_commentcount, SORTING_varcount,
	    SORTING_nagcount,   SORTING_resultwin,    SORTING_resultdraw,
	    SORTING_resultloss, SORTING_rating,       SORTING_number,
	    SORTING_sentinel};
	static const char* fields_end = fields + sizeof(fields);

	if (*criteria == '\0') // Invalid empty criteria.
		return nullptr;

	SortCache* sc = new SortCache(idx, nb);

	// Parse the sorting criteria.
	size_t i = 0;
	for (const char *it = criteria; *it != 0; ++it) {
		bool valid = std::find(fields, fields_end, *it) != fields_end;
		sc->criteria_[i++] = *it++;
		bool reverse = (*it != '+');
		sc->criteria_[i++] = reverse ? 1 : 0;
		if (!valid                         // Unknown field
		    || (reverse && *it != '-')     // Invalid asc/desc param
		    || i >= sizeof(sc->criteria_)) // No space left for SORTING_sentinel
		{
			delete sc;
			return nullptr;
		}
	}
	sc->criteria_[i] = SORTING_sentinel;

	if (!sc->computeKeyLayout(sc->criteria_)) {
		delete sc;
		return nullptr;
	}
	sc->generateKeyCache();
	sc->sortAsynchronously();

	return sc;
}

size_t SortCache::select(size_t row_offset, size_t row_count,
                         const HFilter& filter, gamenumT* result) const {
	ASSERT(filter != nullptr && filter->size() <= nGames_);
	ASSERT(result != nullptr);

	const size_t maxResults = filter->size();
	if (row_count == 0 || row_offset >= maxResults)
		return 0;

	size_t row_end = std::min(row_offset + row_count, maxResults);

	if (!valid_fullMap_) {
		gamenumT* v = new_huge<gamenumT>(maxResults);
		gamenumT* v_end = v + maxResults;
		if (maxResults == nGames_) {
			// std::iota(v, v_end, 0);
			for (gamenumT i = 0; i < maxResults; ++i) {
				v[i] = i;
			}
		} else {
			std::copy(filter->begin(), filter->end(), v);
		}

		size_t skip = 0;
		if (row_offset > 1000) {
			skip = row_offset;
			std::nth_element(v, v + row_offset, v_end, CmpLess(this));
		}
		std::partial_sort(v + skip, v + row_end, v_end, CmpLess(this));
		std::copy(v + row_offset, v + row_end, result);
		delete_huge(v, maxResults);
	} else {
		if (maxResults == nGames_) {
			std::copy(fullMap_ + row_offset, fullMap_ + row_end, result);
		} else {
			size_t filterCount = 0;
			size_t i = 0;
			for (; filterCount < row_offset; i++) {
				if (filter->get(fullMap_[i]) != 0)
					filterCount++;
			}
			for (; filterCount != row_end; i++) {
				if (filter->get(fullMap_[i]) != 0) {
					*result++ = fullMap_[i];
					filterCount++;
				}
			}
		}
	}

	return row_end - row_offset;
}

size_t SortCache::sortedPosition(gamenumT gameId, const HFilter& filter) const {
	ASSERT(filter != 0 && filter->size() <= nGames_);
	ASSERT(gameId < nGames_ && filter->get(gameId) != 0);

	size_t res = 0;
	if (valid_fullMap_) {
		for (gamenumT i = 0; i < nGames_; i++) {
			if (filter->get(fullMap_[i]) == 0)
				continue;
			if (fullMap_[i] == gameId)
				break;
			res++;
		}
	} else {
		CmpLess comp(this);
		for (gamenumT i = 0; i < nGames_; i++) {
			if (filter->get(i) == 0)
				continue;
			if (comp(i, gameId))
				++res;
		}
	}
	return res;
}

void SortCache::checkForChanges(gamenumT id) {
	th_interrupt();
	if (id >= nGames_) {
		generateKeyCache();
		sortAsynchronously();
	} else {
		key_[id] = calcKey(id);
		if (valid_fullMap_) {
			gamenumT* begin = fullMap_;
			gamenumT* end = fullMap_ + nGames_;
			gamenumT* it = std::find(begin, end, id);
			ASSERT(it != end);
			// Reposition the game if necessary:
			// - to the left if it compares less than the previous element;
			// - to the right if the next element is lower.
			CmpLess comp(this);
			if (it != begin && comp(*it, *(it - 1))) {
				std::rotate(
					std::upper_bound(begin, it, *it, comp),
					it, it + 1);
			} else if (it + 1 != end && comp(*(it + 1), *it)) {
				std::rotate(
					it, it + 1,
					std::lower_bound(it + 1, end, *it, comp));
			}
			ASSERT(std::is_sorted(begin, end, comp));
		} else {
			sortAsynchronously();
		}
	}
}

/*
 * Calculate the keys of all games and store them into @e key_.
 */
void SortCache::generateKeyCache() {
	ASSERT(th_ == nullptr);

	valid_fullMap_ = false;
	delete_huge(key_, nGames_);
	nGames_ = index_->GetNumGames();
	key_ = new_huge<uint64_t>(nGames_);
	for (gamenumT i = 0; i < nGames_; i++) {
		key_[i] = calcKey(i);
	}
}

/*
 * Start a background thread that will sort the gameIds and will populate @e
 * fullMap_.
 */
void SortCache::sortAsynchronously() {
	ASSERT(th_ == nullptr);

	delete_huge(fullMap_, nGames_);
	fullMap_ = new_huge<gamenumT>(nGames_);
	th_ = new std::thread(&SortCache::th_sort, this);
}

/*
 * Compare two games according to @e criteria_.
 * The @e index_ is accessed only if the games' hashes are equal.
 * @param g1: the id of the first game.
 * @param g2: the id of the second game.
 * @returns true if @e g1 is ordered before @e g2.
 */
bool SortCache::CmpLess::operator()(gamenumT g1, gamenumT g2) const {
	ASSERT(g1 < sc_->nGames_ && g2 < sc_->nGames_);

	if (sc_->key_[g1] != sc_->key_[g2])
		return sc_->key_[g1] < sc_->key_[g2];
	if (!sc_->partialKey_)
		return g1 < g2;

	int cmp = sc_->fullCompare(g1, g2);
	if (cmp != 0)
		return cmp < 0;

	return g1 < g2;
}

static const int RESULT_SORT[] = { 0, 3, 1, 2 };
static int nameComp(const NameBase* nbase, nameT nt, idNumberT id1,
                    idNumberT id2) {
	ASSERT(nbase != nullptr);
	return (id1 == id2) ? 0
	                    : strCaseCompare(nbase->GetName(nt, id1),
	                                     nbase->GetName(nt, id2));
}

/*
 * Compare two games according to @e criteria_.
 * @param left: the id of the first game.
 * @param right: the id of the second game.
 * @returns
 * - <0 if @e left is ordered before @e right.
 * - >0 if @e right is ordered before @e left.
 * - 0 otherwise.
 */
int SortCache::fullCompare(gamenumT left, gamenumT right) const {
	const IndexEntry *ie1 = index_->GetEntry(left);
	const IndexEntry *ie2 = index_->GetEntry(right);

	for (const char* field = criteria_; *field != SORTING_sentinel; field += 2) {
		int res;
		switch (*field) {
		case SORTING_date:
			res = (int)ie1->GetDate() - (int)ie2->GetDate();
			break;

		case SORTING_year:
			res = (int)ie1->GetYear() - (int)ie2->GetYear();
			break;

		case SORTING_eco:
			res = (int)ie1->GetEcoCode() - (int)ie2->GetEcoCode();
			break;

		case SORTING_moveCount:
			res = (int)ie1->GetNumHalfMoves() - (int)ie2->GetNumHalfMoves();
			break;

		case SORTING_white:
			res = nameComp(nbase_, NAME_PLAYER, ie1->GetWhite(), ie2->GetWhite());
			break;

		case SORTING_black:
			res = nameComp(nbase_, NAME_PLAYER, ie1->GetBlack(), ie2->GetBlack());
			break;

		case SORTING_event:
			res = nameComp(nbase_, NAME_EVENT, ie1->GetEvent(), ie2->GetEvent());
			break;

		case SORTING_site:
			res = nameComp(nbase_, NAME_SITE, ie1->GetSite(), ie2->GetSite());
			break;

		case SORTING_round: {
			idNumberT id1 = ie1->GetRound();
			idNumberT id2 = ie2->GetRound();
			res = (id1 == id2)
			          ? 0
			          : strCompareRound(nbase_->GetName(NAME_ROUND, id1),
			                            nbase_->GetName(NAME_ROUND, id2));
			break;
		}

		case SORTING_resultwin:
			res = (ie1->GetResult() == RESULT_White ? 1 : 0) - (ie2->GetResult() == RESULT_White ? 1 : 0);
			break;

		case SORTING_resultdraw:
			res = (ie1->GetResult() == RESULT_Draw ? 1 : 0) - (ie2->GetResult() == RESULT_Draw ? 1 : 0);
			break;

		case SORTING_resultloss:
			res = (ie1->GetResult() == RESULT_Black ? 1 : 0) - (ie2->GetResult() == RESULT_Black ? 1 : 0);
			break;

		case SORTING_result:
			res = RESULT_SORT[ie1->GetResult()] - RESULT_SORT[ie2->GetResult()];
			break;

		case SORTING_avgElo:  // Average Elo rating:
			{
				int r1 = ie1->GetWhiteElo() + ie1->GetBlackElo();
				int r2 = ie2->GetWhiteElo() + ie2->GetBlackElo();
				res = r1 - r2;
			}
			break;

		case SORTING_country:  // Last 3 characters of site field:
			{
				const char* sOne = nbase_->GetName(NAME_SITE, ie1->GetSite());
				const char* sTwo = nbase_->GetName(NAME_SITE, ie2->GetSite());
				size_t slenOne = std::strlen(sOne);
				size_t slenTwo = std::strlen(sTwo);
				if (slenOne > 3) { sOne += slenOne - 3; }
				if (slenTwo > 3) { sTwo += slenTwo - 3; }
				res = strCaseCompare (sOne, sTwo);
			}
			break;

		case SORTING_deleted:
			res = (int)ie1->GetDeleteFlag() - (int)ie2->GetDeleteFlag();
			break;

		case SORTING_eventdate:
			res = (int)ie1->GetEventDate() - (int)ie2->GetEventDate();
			break;

		case SORTING_whiteelo:
			res = (int)ie1->GetWhiteElo() - (int)ie2->GetWhiteElo();
			break;

		case SORTING_blackelo:
			res = (int)ie1->GetBlackElo() - (int)ie2->GetBlackElo();
			break;

		case SORTING_commentcount:
			res = (int) ie1->GetCommentCount() - (int) ie2->GetCommentCount();
			break;

		case SORTING_varcount:
			res = (int) ie1->GetVariationCount() - (int) ie2->GetVariationCount();
			break;

		case SORTING_nagcount:
			res = (int) ie1->GetNagCount() - (int) ie2->GetNagCount();
			break;

		case SORTING_rating:
			res = (int)ie1->GetRating() - (int)ie2->GetRating();
			break;

		case SORTING_number:
			res = (int) left - (int) right;
			break;

		default:    // Should never happen:
			ASSERT(0);
			return 0;
		}

		if (res != 0)
			return *(field + 1) ? -res : res;
	}

    return 0;
}

/**
 * True if the key cache stores the whole value of a sorting field.
 *
 * The name-based fields are packed as their first 32 bits (see calcKey()):
 * two different names often share a prefix, so their key is only a
 * coarsening of the real order.  A field that is not exact must be the last
 * one contributing to the key, because a tie in a prefix says nothing about
 * the fields that follow it: the comparison of the following fields would
 * then decide an order that the truncated field should have decided first.
 */
static bool keyFieldIsExact(char field) {
	switch (field) {
	case 'w': // white
	case 'b': // black
	case 's': // site
	case 'e': // event
	case 'n': // round
	case 'c': // country
		return false;
	default:
		return true;
	}
}

/*
 * Compute the bit layout of the key cache from the sorting criteria.
 *
 * The key is a uint64_t built by concatenating the sorting fields, most
 * significant field first (see calcKey()). When the fields do not fit into
 * 64 bits, or when a field is a string (of which only a 32 bits prefix is
 * used), the key is not enough to decide the order: @e partialKey_ is set
 * and CmpLess() resolves the remaining ties with fullCompare().
 *
 * @param criteria: the sorting criteria.
 * @returns false if the criteria contain an unknown field.
 */
bool SortCache::computeKeyLayout(const char* criteria) {
	size_t totalBits = 0;
	partialKey_ = false;

	for (const char* field = criteria; *field != SORTING_sentinel; field += 2) {
		size_t bits;
		switch (*field) {
		case SORTING_white:
		case SORTING_black:
		case SORTING_site:
		case SORTING_event:
		case SORTING_round:
		case SORTING_country:
			// Only the first 32 bits of the name are compared: a string
			// prefix can never decide the order on its own.  It must also
			// be the last field packed into the key (see keyFieldIsExact()).
			bits = 32;
			break;
		case SORTING_date:         bits = 24; break;
		case SORTING_eventdate:    bits = 32; break;
		case SORTING_year:         bits = 16; break;
		case SORTING_whiteelo:     bits = 16; break;
		case SORTING_blackelo:     bits = 16; break;
		case SORTING_avgElo:       bits = 16; break;
		case SORTING_result:       bits = 8;  break;
		case SORTING_resultwin:    bits = 8;  break;
		case SORTING_resultdraw:   bits = 8;  break;
		case SORTING_resultloss:   bits = 8;  break;
		case SORTING_moveCount:    bits = 16; break;
		case SORTING_eco:          bits = 16; break;
		case SORTING_commentcount: bits = 16; break;
		case SORTING_varcount:     bits = 16; break;
		case SORTING_nagcount:     bits = 16; break;
		case SORTING_deleted:      bits = 8;  break;
		case SORTING_rating:       bits = 8;  break;
		case SORTING_number:       bits = 32; break;
		default:                   return false;
		}

		totalBits += bits;
		if (totalBits > 64 || !keyFieldIsExact(*field)) {
			// The key keeps the leading criteria only.
			partialKey_ = true;
			break;
		}
		if (totalBits == 64) {
			if (*(field + 2) != SORTING_sentinel)
				partialKey_ = true;
			break;
		}
	}
	return true;
}

/*
 * Calculate an order-preserving key corresponding to the current criteria.
 * @param gameId: the id of the game whose key should be calculated.
 * @returns the key value.
 */
uint64_t SortCache::calcKey(gamenumT gameId) const {
	uint64_t retValue = 0;
	size_t totalBitsUsed = 0;
	const IndexEntry* ie = index_->GetEntry(gameId);

	for (const char* field = criteria_; *field != SORTING_sentinel; field += 2) {
		uint32_t value;
		size_t bitsUsed;
		switch (*field) {
			case SORTING_white:
				value = strStartHash(nbase_->GetName(NAME_PLAYER, ie->GetWhite()));
				bitsUsed = 32;
				break;
			case SORTING_black:
				value = strStartHash(nbase_->GetName(NAME_PLAYER, ie->GetBlack()));
				bitsUsed = 32;
				break;
			case SORTING_site:
				value = strStartHash(nbase_->GetName(NAME_SITE, ie->GetSite()));
				bitsUsed = 32;
				break;
			case SORTING_event:
				value = strStartHash(nbase_->GetName(NAME_EVENT, ie->GetEvent()));
				bitsUsed = 32;
				break;
			case SORTING_round:
				value = strGetUnsigned(nbase_->GetName(NAME_ROUND, ie->GetRound()));
				bitsUsed = 32;
				break;
			case SORTING_country:
			{
				const char *scountry = nbase_->GetName(NAME_SITE, ie->GetSite());
				size_t slen = std::strlen(scountry);
				if (slen > 3) 
					scountry += slen - 3;
				value = strStartHash(scountry);
				bitsUsed = 32;
				break;
			}
			case SORTING_date:
				value = ie->GetDate();
				bitsUsed = 24;
				break;
			case SORTING_eventdate:
				value = ie->GetEventDate();
				bitsUsed = 32;
				break;
			case SORTING_year:
				value = ie->GetYear();
				bitsUsed = 16;
				break;
			case SORTING_whiteelo:
				value = ie->GetWhiteElo();
				bitsUsed = 16;
				break;
			case SORTING_blackelo:
				value = ie->GetBlackElo();
				bitsUsed = 16;
				break;
			case SORTING_avgElo:
				value = ie->GetWhiteElo() + ie->GetBlackElo();
				bitsUsed = 16;
				break;
			case SORTING_result:
				value = RESULT_SORT[ie->GetResult()];
				bitsUsed = 8;
				break;
			case SORTING_resultwin:
				value = ie->GetResult() == RESULT_White ? 1 : 0;
				bitsUsed = 8;
				break;
			case SORTING_resultdraw:
				value = ie->GetResult() == RESULT_Draw ? 1 : 0;
				bitsUsed = 8;
				break;
			case SORTING_resultloss:
				value = ie->GetResult() == RESULT_Black ? 1 : 0;
				bitsUsed = 8;
				break;
			case SORTING_moveCount:
				value = ie->GetNumHalfMoves();
				bitsUsed = 16;
				break;
			case SORTING_eco:
				value = ie->GetEcoCode();
				bitsUsed = 16;
				break;
			case SORTING_commentcount:
				value = ie->GetCommentCount();
				bitsUsed = 16;
				break;
			case SORTING_varcount:
				value = ie->GetVariationCount();
				bitsUsed = 16;
				break;
			case SORTING_nagcount:
				value = ie->GetNagCount();
				bitsUsed = 16;
				break;
			case SORTING_deleted:
				value = (ie->GetDeleteFlag() ? 1 : 0);
				bitsUsed = 8;
				break;
			case SORTING_rating:
				value = ie->GetRating();
				bitsUsed = 8;
				break;
			case SORTING_number:
				value = gameId;
				bitsUsed = 32;
				break;
			default:    // Should never happen:
				ASSERT(0);
				return 0;
		}

		// If reverse order, just negate the cache value
		if (*(field + 1)) {
			value = ~value;
			if (bitsUsed < 32) {
				// Clear the unused top bits
				value &= (1u << bitsUsed) - 1;
			}
		}
		// Combine with the previous key value. If not all the sorting fields
		// fit, the key keeps the leading bits only: the remaining
		// differences are resolved by fullCompare().
		if (totalBitsUsed + bitsUsed > 64) {
			const size_t keep = 64 - totalBitsUsed;
			retValue <<= keep;
			if (keep != 0)
				retValue |= value >> (bitsUsed - keep);
			break;
		}
		retValue <<= bitsUsed;
		retValue |= value;
		totalBitsUsed += bitsUsed;
		if (totalBitsUsed == 64 || !keyFieldIsExact(*field))
			break;
	}

	return retValue;
}
