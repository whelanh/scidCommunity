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

// The spelling file cache: a second load must produce the object the first
// one parsed, a stale or damaged cache must fall back to parsing the source,
// and the cache must never be more readable than the file it came from.

#include "spellchk.h"
#include <atomic>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <gtest/gtest.h>
#include <string>

namespace {

const char* kSpellFile =
    "# a spelling file that uses every kind of record\n"
    "@PLAYER \", .-\"\n"
    "Carlsen, Magnus   #gm NOR [2830] 1990\n"
    "=Karlsen, Magnus\n"
    "%Bio born in Tonsberg\n"
    "%Bio second line\n"
    "%Prefix \"II \" \"2. \"\n"
    "%Infix \"3rd \" \"3. \"\n"
    "%Suffix \"(Italy)\" \"ITA\"\n"
    "%Elo 2020:2860,?,2855\n"
    "%Elo 2021:2850\n"
    "Polgar, Judit #gm+w HUN [2735] 1976\n"
    "@EVENT\n"
    "Wijk aan Zee\n"
    "=Tata Steel\n"
    "@SITE \", \"\n"
    "Wijk aan Zee NED\n"
    "@ROUND\n"
    "1\n"
    "2.1\n";

/// Everything a caller can observe, as one string, so that a cache load can
/// be compared with the parse it replaces.
std::string describe(SpellChecker& sp) {
	std::string res;
	for (nameT nt = 0; nt < NUM_NAME_TYPES; ++nt) {
		res += std::to_string(sp.numCorrectNames(nt)) + "|";
		// The general corrections are applied by the spelling dialog; check
		// that they survived by normalizing a string they must change.
		std::string sample = "II champ 3rd (Italy)";
		sp.getGeneralCorrections(nt).normalize(&sample);
		res += sample + "|";
	}
	for (const char* name : {"Carlsen, Magnus", "Karlsen, Magnus", "Short, Nigel",
	                         "Wijk aan Zee", "Tata Steel", "zzz"}) {
		for (nameT nt = 0; nt < NUM_NAME_TYPES; ++nt) {
			for (const char* found : sp.find(nt, name)) {
				res += found;
				res += ";";
			}
			res += "|";
		}
	}
	const PlayerInfo* info = sp.getPlayerInfo("Carlsen, Magnus");
	if (info != nullptr) {
		res += info->GetComment();
		res += "|";
		res += info->getTitle();
		res += "|";
		res += std::to_string(info->getPeakRating());
		res += "|";
		res += info->getLastCountry();
	}
	const PlayerElo* elo = sp.getPlayerElo("Carlsen, Magnus");
	if (elo != nullptr) {
		res += "|";
		res += std::to_string(elo->getElo(date_parsePGNTag("2020.03.01", 10)));
		res += ",";
		res += std::to_string(elo->getElo(date_parsePGNTag("2021.07.01", 10)));
	}
	return res;
}

/// Load @e file, returning what the object looks like.
std::string load(const std::filesystem::path& file) {
	const std::string name = file.string();
	auto [err, sp] = SpellChecker::Create(name.c_str(), Progress());
	EXPECT_EQ(OK, err);
	if (!sp)
		return "<failed>";
	std::string res = describe(*sp);
	delete sp;
	return res;
}

class Test_SpellChkCache : public ::testing::Test {
protected:
	std::filesystem::path dir_;

	void SetUp() override {
		static std::atomic<unsigned> counter{0};
		dir_ = std::filesystem::temp_directory_path() /
		       ("scid_spellchk_" + std::to_string(++counter) + "_" +
		        std::to_string(reinterpret_cast<uintptr_t>(this)));
		std::filesystem::remove_all(dir_);
		std::filesystem::create_directories(dir_);
	}
	void TearDown() override { std::filesystem::remove_all(dir_); }

	std::filesystem::path write(const char* contents,
	                            const char* name = "test.ssp") {
		const auto file = dir_ / name;
		std::ofstream out(file, std::ios::binary);
		out << contents;
		out.close();
		return file;
	}
	static std::filesystem::path cacheFor(const std::filesystem::path& file) {
		auto cache = file;
		cache += ".sspc";
		return cache;
	}
};

TEST_F(Test_SpellChkCache, second_load_uses_the_cache) {
	const auto file = write(kSpellFile);
	const std::string parsed = load(file);
	ASSERT_TRUE(std::filesystem::exists(cacheFor(file)));
	const std::string cached = load(file);
	EXPECT_EQ(parsed, cached);
	EXPECT_NE(std::string::npos, cached.find("Carlsen, Magnus"));
}

TEST_F(Test_SpellChkCache, truncated_cache_falls_back_to_the_source) {
	const auto file = write(kSpellFile);
	const std::string parsed = load(file);
	const auto cache = cacheFor(file);
	ASSERT_TRUE(std::filesystem::exists(cache));
	const auto goodSize = std::filesystem::file_size(cache);
	std::filesystem::resize_file(cache, 40);
	EXPECT_EQ(parsed, load(file));
	// The damaged file has been replaced by a usable one.
	EXPECT_EQ(goodSize, std::filesystem::file_size(cache));
	EXPECT_EQ(parsed, load(file));
}

TEST_F(Test_SpellChkCache, corrupted_payload_is_rejected) {
	const auto file = write(kSpellFile);
	const std::string parsed = load(file);
	const auto cache = cacheFor(file);
	std::string data;
	{
		std::ifstream in(cache, std::ios::binary);
		data.assign(std::istreambuf_iterator<char>(in), {});
	}
	ASSERT_GT(data.size(), 64u);
	// Keep a valid header (44 bytes) but corrupt every payload byte after it.
	for (size_t i = 44; i < data.size(); ++i)
		data[i] = static_cast<char>(0xA5);
	{
		std::ofstream out(cache, std::ios::binary | std::ios::trunc);
		out.write(data.data(), static_cast<std::streamsize>(data.size()));
	}
	EXPECT_EQ(parsed, load(file));
}

TEST_F(Test_SpellChkCache, changed_source_invalidates_the_cache) {
	const auto file = write(kSpellFile);
	const std::string before = load(file);
	// A different file with the same name must not be answered from the cache.
	const char* replacement = "@PLAYER\nSomeone, Else\n";
	write(replacement, "test.ssp");
	// The same replacement at a path without a cache is the reference.
	const std::string expected = load(write(replacement, "reference.ssp"));
	const std::string reloaded = load(file);
	EXPECT_EQ(expected, reloaded);
	EXPECT_NE(before, reloaded);
}

#ifndef _WIN32
TEST_F(Test_SpellChkCache, cache_is_not_more_readable_than_the_source) {
	const auto file = write(kSpellFile);
	const auto cache = cacheFor(file);
	std::filesystem::permissions(file,
	                             std::filesystem::perms::owner_read |
	                                 std::filesystem::perms::owner_write,
	                             std::filesystem::perm_options::replace);
	load(file);
	ASSERT_TRUE(std::filesystem::exists(cache));
	const auto src = std::filesystem::status(file).permissions();
	const auto cas = std::filesystem::status(cache).permissions();
	EXPECT_EQ(src & std::filesystem::perms::all, cas & std::filesystem::perms::all);
}
#endif

TEST_F(Test_SpellChkCache, names_only_file_gets_no_cache) {
	const auto file = write("@PLAYER\nAlpha, Ann\n@EVENT\nSome Event\n");
	load(file);
	EXPECT_FALSE(std::filesystem::exists(cacheFor(file)));
}

} // namespace
