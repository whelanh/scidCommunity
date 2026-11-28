/*
 * Copyright (C) 2026 Tommaso Bergamasco
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * This file is part of scidCommunity.
 */

/** @file
 * Builds small 2CBH databases byte by byte for the tests: no real database,
 * and nothing derived from one, is ever needed.
 */

#pragma once

#include <array>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <random>
#include <string>
#include <vector>

namespace cb2test {

using Buf = std::vector<uint8_t>;

/// A directory removed with everything in it when the object goes.
struct TempDir {
	std::filesystem::path path;
	TempDir() {
		std::random_device rd;
		path = std::filesystem::temp_directory_path() /
		       ("scid_cb2_" + std::to_string(rd()) + std::to_string(rd()));
		std::filesystem::create_directories(path);
	}
	~TempDir() {
		std::error_code ec;
		std::filesystem::remove_all(path, ec);
	}
	std::string file(const std::string& name) const {
		return (path / name).string();
	}
};

inline void writeFile(const std::string& name, const Buf& data) {
	std::ofstream f(name, std::ios::binary | std::ios::trunc);
	f.write(reinterpret_cast<const char*>(data.data()), data.size());
}

inline void putLE(Buf& b, size_t at, uint64_t v, int n) {
	if (b.size() < at + n)
		b.resize(at + n);
	for (int i = 0; i < n; ++i)
		b[at + i] = static_cast<uint8_t>(v >> (8 * i));
}
inline void putBE(Buf& b, size_t at, uint64_t v, int n) {
	if (b.size() < at + n)
		b.resize(at + n);
	for (int i = 0; i < n; ++i)
		b[at + i] = static_cast<uint8_t>(v >> (8 * (n - 1 - i)));
}
inline void addLE(Buf& b, uint64_t v, int n) { putLE(b, b.size(), v, n); }
inline void addBE(Buf& b, uint64_t v, int n) { putBE(b, b.size(), v, n); }
inline void addBytes(Buf& b, const Buf& v) {
	b.insert(b.end(), v.begin(), v.end());
}

/// The 192 bytes of a header record that the reader uses.
using RecordBytes = std::array<uint8_t, 192>;

/// A `.2cbh` file: a header record, then @p records, each padded to
/// @p recordSize. A 208-byte record carries 16 trailing bytes as ChessBase
/// 2027 writes them: an i64 -1, then a small i64.
inline Buf headerFile(int recordSize, unsigned version,
                      const std::vector<RecordBytes>& records) {
	const size_t rs = recordSize > 0 ? size_t(recordSize) : 192;
	Buf out(rs, 0);
	putLE(out, 0x0a, static_cast<uint16_t>(recordSize), 2);
	out[0x0d] = static_cast<uint8_t>(version);
	for (auto& r : records) {
		auto at = out.size();
		out.insert(out.end(), r.begin(), r.end());
		out.resize(at + rs, 0);
		if (rs >= 208) {
			putLE(out, at + 192, uint64_t(-1), 8);
			putLE(out, at + 200, 3, 8);
		}
	}
	return out;
}

} // namespace cb2test
