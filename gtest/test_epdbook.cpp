/*
 * Copyright (C) 2026 scidCommunity contributors
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

#include "epdbook.h"
#include <gtest/gtest.h>
#include <chrono>
#include <filesystem>
#include <fstream>

TEST(Test_EpdBook, ReadFileSkipsMalformedLines) {
	const auto stamp = std::chrono::steady_clock::now().time_since_epoch().count();
	const auto path = std::filesystem::temp_directory_path() /
	                  ("scid-epdbook-" + std::to_string(stamp) + ".epd");

	{
		std::ofstream out(path);
		ASSERT_TRUE(out.is_open());
		out << "8/8/8/8/8/8/8/K6k w - -\n";
		out << "not a valid epd line\n";
		out << "8/8/8/8/8/8/8/1K5k w - -\n";
	}

	EpdBook book;
	book.setFileName(path.string().c_str());
	ASSERT_EQ(OK, book.readFile());
	EXPECT_EQ(2u, book.size());

	Position pos;
	ASSERT_TRUE(book.findNext(&pos, true));
	EXPECT_EQ(0, book.getIndex(&pos));
	ASSERT_TRUE(book.findNext(&pos, true));
	EXPECT_EQ(1, book.getIndex(&pos));
	ASSERT_TRUE(book.loadByIndex(&pos, 1));
	EXPECT_EQ(1, book.getIndex(&pos));

	std::filesystem::remove(path);
}
