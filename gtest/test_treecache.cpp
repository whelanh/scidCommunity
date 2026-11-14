/*
 * Copyright (C) 2026 Hugh Whelan
 *
 * This file is part of Scid (Shane's Chess Information Database).
 *
 * Scid is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Scid is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Scid.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "hfilter.h"
#include "tree.h"

#include <gtest/gtest.h>

namespace {

Position fen(const char* f) {
	Position pos;
	EXPECT_EQ(OK, pos.ReadFromFEN(f));
	return pos;
}

} // namespace

TEST(TreeCache, stores_and_restores) {
	Position start;
	start.StdStart();

	Filter filter(1000);
	filter.Fill(1);
	filter.Set(7, 3);

	TreeCache cache;
	cache.CacheResize(10);
	cache.cacheAdd(start, filter);

	EXPECT_EQ(1u, cache.Count());
	EXPECT_GT(cache.UsedBytes(), 0u);
	EXPECT_LE(cache.UsedBytes(), cache.MaxBytes());

	Filter out(1000);
	out.Fill(0);
	EXPECT_TRUE(cache.cacheRestore(start, out));
	EXPECT_EQ(1, out.Get(0));
	EXPECT_EQ(3, out.Get(7));
}

TEST(TreeCache, evicts_to_respect_the_byte_budget) {
	Position a = fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
	Position b = fen("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1");

	Filter filter(1000);
	filter.Fill(1);

	TreeCache cache;
	// Room for the entry headers and the tiny compressed filters, but not
	// for many entries.
	const size_t twoEntries = 2 * (512 + 64);
	cache.CacheResize(10, twoEntries);

	cache.cacheAdd(a, filter);
	cache.cacheAdd(b, filter);
	EXPECT_EQ(2u, cache.Count());
	EXPECT_LE(cache.UsedBytes(), cache.MaxBytes());

	// A budget that only fits one entry must evict the least recently used.
	cache.CacheResize(10, 512 + 64);
	cache.cacheAdd(a, filter);
	cache.cacheAdd(b, filter);
	EXPECT_EQ(1u, cache.Count());
	EXPECT_LE(cache.UsedBytes(), cache.MaxBytes());

	Filter out(1000);
	out.Fill(0);
	EXPECT_FALSE(cache.cacheRestore(a, out)); // a was evicted
	EXPECT_TRUE(cache.cacheRestore(b, out));
}

TEST(TreeCache, refuses_an_entry_larger_than_the_budget) {
	Position start;
	start.StdStart();
	Filter filter(1000);
	filter.Fill(1);

	TreeCache cache;
	cache.CacheResize(10, 100); // smaller than the per-entry overhead
	cache.cacheAdd(start, filter);
	EXPECT_EQ(0u, cache.Count());
	EXPECT_EQ(0u, cache.UsedBytes());
}

TEST(TreeCache, honours_the_entry_limit) {
	Position a = fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
	Position b = fen("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1");
	Filter filter(1000);
	filter.Fill(1);

	TreeCache cache;
	cache.CacheResize(1, TreeCache::DefaultMaxBytes);
	cache.cacheAdd(a, filter);
	cache.cacheAdd(b, filter);
	EXPECT_EQ(1u, cache.Count());
}
