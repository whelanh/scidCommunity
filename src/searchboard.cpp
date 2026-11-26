/*
 * Copyright (C) 2026  Fulvio Benini
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

#include "searchboard.h"
#include "hfilter.h"
#include "matsig.h"
#include "misc.h"
#include "scidbase.h"
#include <algorithm>
#include <atomic>
#include <future>
#include <thread>

namespace {

/// A position ready to be compared with the games' positions.
struct SearchForm {
	Position pos;
	matSigT matSig;
	uint hpSig;
};

Position flipColors(const Position& src) {
	Position dst;
	dst.Clear();
	for (squareT sq = A1; sq <= H8; ++sq) {
		const pieceT piece = src.GetPiece(sq);
		if (piece != EMPTY)
			dst.AddPiece(PIECE_FLIP[piece], square_Relative(BLACK, sq));
	}
	dst.SetToMove(color_Flip(src.GetToMove()));
	dst.SetEPTarget(src.GetEPTarget());
	return dst;
}

std::vector<SearchForm> makeForms(const std::vector<Position>& positions,
                                  bool ignoreColors) {
	std::vector<SearchForm> forms;
	forms.reserve(positions.size() * (ignoreColors ? 2 : 1));
	for (const auto& pos : positions) {
		SearchForm form{pos, matsig_Make(pos.GetMaterial()), 0};
		forms.push_back(form);
		if (ignoreColors) {
			auto flipped = flipColors(pos);
			SearchForm formFlipped{flipped, matsig_Make(flipped.GetMaterial()), 0};
			forms.push_back(formFlipped);
		}
	}
	return forms;
}

/// The ply stored in a filter is a byte, so longer matches are capped.
constexpr uint8_t MAX_PLY = 255;

} // namespace

BoardSearchResult boardSearch(const scidBaseT& base,
                              const std::vector<gamenumT>& candidates,
                              const std::vector<Position>& positions,
                              const BoardSearchOptions& options,
                              const Progress& progress) {
	BoardSearchResult res;
	res.ply.assign(candidates.size(), 0);
	if (candidates.empty() || positions.empty()) {
		progress.report(1, 1);
		return res;
	}

	// progress.report pumps UI events; keep the base from being closed
	// while the workers use it.
	BusyGuard busy(base);

	if (!progress.report(0, candidates.size())) {
		res.status = BoardSearchStatus::Cancelled;
		return res;
	}

	std::vector<SearchForm> forms = makeForms(positions, options.ignoreColors);
	if (options.useIndexOptimizations) {
		for (auto& form : forms)
			form.hpSig = form.pos.GetHPSig();
	}

	// Sentinel used inside the workers to flag a game that could not be read.
	constexpr uint8_t READ_ERROR = 0xFF;
	std::vector<uint8_t> ply(candidates.size(), 0);

	struct Sync {
		alignas(64) std::atomic<size_t> n_done{0};
		alignas(64) std::atomic<bool> interrupted{false};
	} sync;

	auto worker = [&](size_t begin, size_t end) {
		constexpr size_t rep_freq = 8 * 1024;
		size_t rep_i = 0;
		// Private copies: ExactMatch() updates the COLOR_SQUARE byte of the
		// searched position via GetBoard().
		auto localForms = forms;
		Game game;
		for (size_t ci = begin; ci < end; ++ci) {
			// Count every examined game, even the ones skipped below,
			// otherwise the main thread would wait forever.
			if (++rep_i % rep_freq == 0) {
				sync.n_done.fetch_add(rep_freq, std::memory_order_relaxed);
				sync.n_done.notify_one();
			}

			if (sync.interrupted.load(std::memory_order_acquire))
				break;

			const gamenumT gnum = candidates[ci];
			const IndexEntry* ie = base.getIndexEntry(gnum);
			if (ie->GetLength() == 0)
				continue; // no moves, cannot match

			const bool useVars =
			    options.searchInVariations && ie->GetVariationsFlag();

			// Cheap tests on the index: drop the forms that this game cannot
			// possibly reach, and skip the game if no form is left.
			std::vector<SearchForm*> possible;
			possible.reserve(localForms.size());
			for (auto& form : localForms) {
				bool ok = true;
				if (!useVars) {
					if (options.useIndexOptimizations &&
					    !ie->GetStartFlag() &&
					    form.hpSig != HPSIG_StdStart)
						ok = hpSig_PossibleMatch(form.hpSig,
						                         ie->GetHomePawnData());
					if (ok)
						ok = matsig_isReachable(form.matSig,
						                        ie->GetFinalMatSig(),
						                        ie->GetPromotionsFlag(),
						                        ie->GetUnderPromoFlag());
				}
				if (ok)
					possible.push_back(&form);
			}
			if (possible.empty())
				continue;

			auto bbuf = base.getGame(*ie);
			if (!bbuf) {
				ply[ci] = READ_ERROR;
			} else {
				uint matchPly = 0;
				if (useVars) {
					game.DecodeMovesOnly(bbuf);
					for (auto* form : possible) {
						if (game.ExactMatch(&form->pos, nullptr,
						                    options.matchType)) {
							matchPly = game.GetCurrentPly() + 1u;
							break;
						}
					}
					if (matchPly == 0) {
						for (auto* form : possible) {
							game.MoveToStart();
							if (game.VarExactMatch(&form->pos,
							                       options.matchType)) {
								matchPly = game.GetCurrentPly() + 1u;
								break;
							}
						}
					}
				} else {
					for (auto* form : possible) {
						// ExactMatch() advances the buffer; use a fresh copy.
						auto buf = bbuf;
						if (game.ExactMatch(&form->pos, &buf,
						                    options.matchType)) {
							matchPly = game.GetCurrentPly() + 1u;
							break;
						}
					}
				}
				if (matchPly != 0)
					ply[ci] = static_cast<uint8_t>(
					    std::min<uint>(matchPly, MAX_PLY));
			}
		}
		sync.n_done.fetch_add(rep_i % rep_freq, std::memory_order_relaxed);
		sync.n_done.notify_one();
	};

	const size_t n_games = candidates.size();
	const unsigned n_cores =
	    std::max(1u, std::thread::hardware_concurrency());
	const size_t n_threads = std::min<size_t>({n_cores, 8, n_games});
	const size_t chunk = (n_games + n_threads - 1) / n_threads;

	std::vector<std::future<void>> futures;
	futures.reserve(n_threads > 0 ? n_threads - 1 : 0);
	for (size_t t = 0; t + 1 < n_threads; ++t) {
		const size_t begin = t * chunk;
		const size_t end = std::min(begin + chunk, n_games);
		if (begin >= end)
			break;
		futures.push_back(std::async(std::launch::async, worker, begin, end));
	}
	{
		const size_t begin = (n_threads - 1) * chunk;
		if (begin < n_games)
			worker(begin, n_games);
	}

	size_t n_reported = 0;
	while (n_reported != n_games) {
		sync.n_done.wait(n_reported, std::memory_order_relaxed);
		n_reported = sync.n_done.load(std::memory_order_relaxed);
		n_reported = std::min(n_reported, n_games);
		if (!progress.report(n_reported, n_games)) {
			sync.interrupted = true;
			break;
		}
	}
	for (auto& f : futures)
		f.get();

	if (sync.interrupted.load(std::memory_order_relaxed))
		res.status = BoardSearchStatus::Cancelled;

	for (size_t i = 0; i < ply.size(); ++i) {
		if (ply[i] == READ_ERROR) {
			res.readError = true;
			res.ply[i] = 0;
		} else {
			res.ply[i] = ply[i];
		}
	}

	progress.report(1, 1);
	return res;
}
