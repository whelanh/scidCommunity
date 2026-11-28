/*
 * Copyright (C) 2026 Tommaso Bergamasco
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * 2CBH layout derived from oschess-cb-bridge v1.0.3 (MIT), commit bffebfc4.
 * See docs/third-party-notices.md.
 *
 * This file is part of scidCommunity.
 *
 * scidCommunity is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 2 of the License, or (at your option)
 * any later version.
 */

#include "cb2_format.h"
#include <limits>

namespace cb2 {

errorT HeaderTable::open(std::string_view path, std::string& why) {
	close();
	count_ = 0;
	recordSize_ = 0;
	version_ = 0;
	if (auto err = file_.open(path)) {
		why = "cannot open the .2cbh file";
		return err;
	}
	const auto size = file_.size();
	const auto head = file_.view(0, 0x0e);
	if (head.empty()) {
		why = ".2cbh file too short";
		return ERROR_BadMagic;
	}
	// The record size is at 0x0a: 192 up to the 2026 databases, 208 in the
	// 2027 ones, whose version byte at 0x0d went from 5 to 6.
	const auto rs = le_i16(head, 0x0a);
	if (rs < int(kMinRecordSize) || rs > int(kMaxRecordSize)) {
		why = ".2cbh record size " + std::to_string(rs) + " not supported";
		return ERROR_FileVersion;
	}
	if (size < uint64_t(rs) || size % uint64_t(rs) != 0) {
		why = ".2cbh size " + std::to_string(size) +
		      " is not a multiple of its record size " + std::to_string(rs);
		return ERROR_Corrupt;
	}
	const auto n = size / uint64_t(rs) - 1;
	if (n > std::numeric_limits<uint32_t>::max()) {
		why = ".2cbh holds too many records";
		return ERROR_Corrupt;
	}
	count_ = static_cast<uint32_t>(n);
	recordSize_ = static_cast<size_t>(rs);
	version_ = head[0x0d];
	return OK;
}

} // namespace cb2
