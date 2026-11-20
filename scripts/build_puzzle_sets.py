#!/usr/bin/env python3
"""Build graded Lichess puzzle sets for scidCommunity.

Streams the Lichess puzzle CSV (https://database.lichess.org/#puzzles),
applies quality filters, and samples one rating-banded set per skill level.
Within each set it balances phase, outcome, side to move and tactical
theme, and it writes one PGN per set (FEN = the position the solver sees,
main line = the solution), a manifest and a verification report.

The sampling is seeded, so a run is reproducible.  Change --seed (or
--count) to produce a different collection from the same snapshot.

Usage:
    python3 scripts/build_puzzle_sets.py \
        --csv ~/Downloads/lichess_db_puzzle.csv --out puzzles
"""

from __future__ import annotations

import argparse
import csv
import datetime
import hashlib
import heapq
import math
import os
import random
import re
import statistics
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass

try:
    import chess
    import chess.pgn
except ImportError:  # pragma: no cover
    sys.exit("python-chess is required: pip install chess")


# --------------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class SetSpec:
    number: int
    name: str
    lo: int          # inclusive Lichess puzzle rating
    hi: int          # inclusive
    max_solver_moves: int | None


# Contiguous, non-overlapping bands: a puzzle can only belong to one set.
SETS = [
    SetSpec(1, "Beginner",     600,  899, 3),
    SetSpec(2, "Novice",       900, 1199, 5),
    SetSpec(3, "Intermediate", 1200, 1499, None),
    SetSpec(4, "Club",         1500, 1799, None),
    SetSpec(5, "Advanced",     1800, 2099, None),
    SetSpec(6, "Expert",       2100, 2450, None),
    SetSpec(7, "Master",       2451, 2599, None),
    SetSpec(8, "Grandmaster",  2600, 2749, None),
    SetSpec(9, "Elite",        2750, 2899, None),
]

# Sets 1-6 were published first and draw their sampling keys from the one
# seeded generator; every later set draws from its own, so adding a band
# leaves the published sets byte-identical.  Above 2899 too few puzzles pass
# the quality gates (88 in the 2026-11 snapshot) for a set.
FIRST_RELEASE = 6

# Phase and outcome mixes, by set.  Availability clipping in allocate_cells()
# redistributes anything a band cannot supply.
PHASE_TARGETS = {"opening": 0.10, "middlegame": 0.55, "endgame": 0.35, "other": 0.0}

OUTCOME_TARGETS = {
    1: {"mate": 0.30, "crushing": 0.50, "advantage": 0.20, "other": 0.00},
    2: {"mate": 0.25, "crushing": 0.45, "advantage": 0.27, "other": 0.03},
    3: {"mate": 0.20, "crushing": 0.40, "advantage": 0.35, "other": 0.05},
    4: {"mate": 0.15, "crushing": 0.35, "advantage": 0.44, "other": 0.06},
    5: {"mate": 0.10, "crushing": 0.32, "advantage": 0.50, "other": 0.08},
    6: {"mate": 0.05, "crushing": 0.30, "advantage": 0.57, "other": 0.08},
    7: {"mate": 0.05, "crushing": 0.30, "advantage": 0.57, "other": 0.08},
    8: {"mate": 0.05, "crushing": 0.30, "advantage": 0.57, "other": 0.08},
    9: {"mate": 0.05, "crushing": 0.30, "advantage": 0.57, "other": 0.08},
}

# Theme families.  Specific mate patterns are grouped: the exotic names are
# kept as tags in the PGN, but they share the "mate" budget instead of
# fragmenting it into twenty families of one or two puzzles.
EXOTIC_MATES = {
    "arabianMate", "bodenMate", "dovetailMate", "hookMate", "killBoxMate",
    "anastasiaMate", "doubleBishopMate", "vukovicMate", "pillsburysMate",
    "damianoMate", "grecoMate", "morphysMate", "operaMate", "epauletteMate",
    "cornerMate", "swallowstailMate", "triangleMate", "blindSwineMate",
    "balestraMate",
}

TACTIC_ORDER = [
    "fork", "pin", "skewer", "discoveredAttack", "doubleCheck", "discoveredCheck",
    "deflection", "attraction", "clearance", "intermezzo", "interference",
    "sacrifice", "hangingPiece", "trappedPiece", "advancedPawn", "promotion",
    "underPromotion", "enPassant", "castling", "capturingDefender",
    "defensiveMove", "quietMove", "xRayAttack", "zugzwang", "exposedKing",
    "collinearMove", "attackingF2F7",
]

ENDGAME_ORDER = [
    "rookEndgame", "pawnEndgame", "queenEndgame", "bishopEndgame",
    "knightEndgame", "queenRookEndgame",
]

FAMILY_ORDER = (
    ["backRankMate", "smotheredMate"]
    + TACTIC_ORDER
    + ["mate"]
    + ENDGAME_ORDER
    + ["kingsideAttack", "queensideAttack"]
)

# Used only by the report, to show that the classic motifs are well covered.
MAJOR_MOTIFS = [
    "fork", "pin", "skewer", "discoveredAttack", "doubleCheck", "deflection",
    "attraction", "clearance", "intermezzo", "sacrifice", "hangingPiece",
    "trappedPiece", "advancedPawn", "promotion", "backRankMate", "quietMove",
    "defensiveMove", "exposedKing", "zugzwang",
]

MIN_POPULARITY = 90
MIN_PLAYS = 100
MAX_RD = 90
POOL_CAP = 50_000          # reservoir size per set
FAMILY_FLOOR_PER_100 = 1   # at least 1 per family per 100 puzzles


# --------------------------------------------------------------------------
# Records and parsing
# --------------------------------------------------------------------------

class Puzzle:
    __slots__ = (
        "pid", "fen", "moves", "rating", "rd", "pop", "nb", "themes",
        "url", "daily", "key", "solver_fen", "solution", "solver_moves",
        "side", "phase", "outcome", "family",
    )

    def __init__(self, pid, fen, moves, rating, rd, pop, nb, themes, url, daily):
        self.pid = pid
        self.fen = fen
        self.moves = moves
        self.rating = rating
        self.rd = rd
        self.pop = pop
        self.nb = nb
        self.themes = themes
        self.url = url
        self.daily = daily
        self.key = 0.0
        self.solver_fen = ""
        self.solution = ()
        self.solver_moves = 0
        self.side = ""
        self.phase = "other"
        self.outcome = "other"
        self.family = "other"

    @property
    def cell(self):
        return (self.phase, self.outcome)


def quality_weight(pop, nb, daily):
    """Modest weight: popularity is already gated, daily puzzles are a bonus."""
    w = 1.0
    w += 0.5 * min(max(pop - MIN_POPULARITY, 0) / 10.0, 1.0)
    w += 0.5 if nb >= 1000 else 0.0
    w += 3.0 if daily else 0.0
    return w


def game_id(url):
    """Extract the Lichess game id from a GameUrl such as
    https://lichess.org/game/787zsVup/black#48 or .../yyznGmXs#34."""
    m = re.search(r"lichess\.org/(?:game/)?([A-Za-z0-9]+)", url)
    return m.group(1) if m else url


def family_of(themes):
    if "backRankMate" in themes:
        return "backRankMate"
    if "smotheredMate" in themes:
        return "smotheredMate"
    for t in TACTIC_ORDER:
        if t in themes:
            return t
    if "mate" in themes or not themes.isdisjoint(EXOTIC_MATES):
        return "mate"
    for t in ENDGAME_ORDER:
        if t in themes:
            return t
    if "kingsideAttack" in themes:
        return "kingsideAttack"
    if "queensideAttack" in themes:
        return "queensideAttack"
    return "other"


def analyse(p):
    """Replay the puzzle, compute the solver's start position and attributes.

    Lichess convention: the FEN is the position *before* the opponent's move;
    Moves[0] is that opponent move, and the solution starts at Moves[1].
    """
    board = chess.Board(p.fen)
    if not p.moves:
        raise ValueError("empty Moves")
    setup = chess.Move.from_uci(p.moves[0])
    if setup not in board.legal_moves:
        raise ValueError("illegal setup move %s" % p.moves[0])
    board.push(setup)
    p.solver_fen = board.fen()
    p.side = "white" if board.turn else "black"

    solution = p.moves[1:]
    if not solution:
        raise ValueError("no solution move")
    for uci in solution:
        move = chess.Move.from_uci(uci)
        if move not in board.legal_moves:
            raise ValueError("illegal solution move %s" % uci)
        board.push(move)
    p.solution = tuple(solution)
    p.solver_moves = len(solution)

    th = set(p.themes)
    if "endgame" in th:
        p.phase = "endgame"
    elif "opening" in th:
        p.phase = "opening"
    elif "middlegame" in th:
        p.phase = "middlegame"

    if "mate" in th:
        p.outcome = "mate"
    elif "crushing" in th:
        p.outcome = "crushing"
    elif "advantage" in th:
        p.outcome = "advantage"

    p.family = family_of(th)
    return p


# --------------------------------------------------------------------------
# Streaming and reservoir sampling
# --------------------------------------------------------------------------

def stream_pools(csv_path, sets, cap, rng, row_limit=None, seed=""):
    heaps = {s.number: [] for s in sets}
    rngs = {s.number: rng if s.number <= FIRST_RELEASE else random.Random("%s/%d" % (seed, s.number))
            for s in sets}
    seq = 0
    seen = 0
    skipped = Counter()

    with open(csv_path, newline="", encoding="utf-8") as fh:
        reader = csv.reader(fh)
        header = next(reader)
        if header[:3] != ["PuzzleId", "FEN", "Moves"]:
            raise SystemExit("unexpected CSV header: %r" % (header,))

        for row in reader:
            seen += 1
            if row_limit and seen > row_limit:
                break
            if len(row) < 11:
                skipped["short row"] += 1
                continue
            pid, fen, moves, rating, rd, pop, nb, themes, url, _opening, daily = row[:11]
            try:
                rating_i = int(rating)
                rd_i = int(rd)
                pop_i = int(pop)
                nb_i = int(nb)
            except ValueError:
                skipped["bad number"] += 1
                continue

            if rd_i > MAX_RD or pop_i < MIN_POPULARITY or nb_i < MIN_PLAYS:
                skipped["quality"] += 1
                continue
            if not moves:
                skipped["no moves"] += 1
                continue

            spec = next((s for s in sets if s.lo <= rating_i <= s.hi), None)
            if spec is None:
                skipped["out of band"] += 1
                continue

            w = quality_weight(pop_i, nb_i, daily)
            key = rngs[spec.number].random() ** (1.0 / w)
            rec = (pid, fen, tuple(moves.split()), rating_i, rd_i, pop_i, nb_i,
                   tuple(themes.split()), url, daily)
            heap = heaps[spec.number]
            if len(heap) < cap:
                heapq.heappush(heap, (key, seq, rec))
            elif key > heap[0][0]:
                heapq.heapreplace(heap, (key, seq, rec))
            seq += 1

    return heaps, seen, skipped


# --------------------------------------------------------------------------
# Selection helpers
# --------------------------------------------------------------------------

def largest_remainder(desired, total, caps):
    """Round a dict of fractional targets to integers summing to total,
    never exceeding caps, using the largest-remainder method."""
    out = {k: min(int(math.floor(v)), caps.get(k, 0)) for k, v in desired.items()}
    rem = total - sum(out.values())
    if rem <= 0:
        return out
    order = sorted(desired, key=lambda k: desired[k] - math.floor(desired[k]), reverse=True)
    progress = True
    while rem > 0 and progress:
        progress = False
        for k in order:
            if rem == 0:
                break
            if out[k] < caps.get(k, 0):
                out[k] += 1
                rem -= 1
                progress = True
    return out


def allocate_cells(n, phase_w, outcome_w, avail):
    """Split n across (phase, outcome) cells, clipping at availability and
    redistributing the shortfall to cells that still have candidates."""
    cells = [(ph, ou) for ph in phase_w for ou in outcome_w]
    desired = {c: n * phase_w[c[0]] * outcome_w[c[1]] for c in cells}
    for _ in range(100):
        over = [c for c in cells if desired[c] > avail.get(c, 0) + 1e-9]
        if not over:
            break
        deficit = sum(desired[c] - avail.get(c, 0) for c in over)
        for c in over:
            desired[c] = avail.get(c, 0)
        spare = [c for c in cells if desired[c] < avail.get(c, 0) - 1e-9]
        if not spare:
            break
        total_spare = sum(avail[c] - desired[c] for c in spare)
        for c in spare:
            desired[c] += deficit * (avail[c] - desired[c]) / total_spare
    return largest_remainder(desired, n, {c: avail.get(c, 0) for c in cells})


def allocate_families(k, avail, other_cap=0.10):
    """Give k slots to families, weighted by sqrt(availability) so that rare
    motifs get a fair share without displacing the common ones.  The untagged
    "other" family is capped so the set stays thematic."""
    fams = list(avail)
    if not fams or k <= 0:
        return {}
    w = {f: math.sqrt(max(avail[f], 1)) for f in fams}
    total = sum(w.values())
    if other_cap is not None and "other" in w and len(fams) > 1 and total:
        if w["other"] / total > other_cap:
            rest = total - w["other"]
            w["other"] = other_cap * rest / (1.0 - other_cap)
    total = sum(w.values())
    if total <= 0:
        w = {f: 1.0 for f in fams}
        total = float(len(fams))
    desired = {f: k * w[f] / total for f in fams}
    return largest_remainder(desired, k, avail)


def pick_from_cell(cands, k, rng):
    fams = defaultdict(list)
    for p in cands:
        fams[p.family].append(p)
    alloc = allocate_families(k, {f: len(v) for f, v in fams.items()})
    out = []
    for fam, count in alloc.items():
        lst = fams[fam][:]
        rng.shuffle(lst)
        out.extend(lst[:count])
    return out


def repair_family_floor(chosen, cells, all_families, floor, rng):
    """Swap within a (phase, outcome) cell so that every family present in
    the pool reaches the floor, without disturbing the cell quotas or the
    side balance."""
    counts = Counter(p.family for p in chosen)
    have = {p.pid for p in chosen}
    for fam in sorted(all_families, key=lambda f: counts[f]):
        if all_families[fam] < floor:
            continue
        guard = 0
        while counts[fam] < floor and guard < 200:
            guard += 1
            moved = False
            for cell, cands in cells.items():
                repls = [p for p in cands if p.family == fam and p.pid not in have]
                if not repls:
                    continue
                victims = [p for p in chosen if p.cell == cell and counts[p.family] > floor]
                if not victims:
                    continue
                victim = rng.choice(victims)
                same_side = [p for p in repls if p.side == victim.side]
                repl = rng.choice(same_side or repls)
                chosen.remove(victim)
                chosen.append(repl)
                have.discard(victim.pid)
                have.add(repl.pid)
                counts[victim.family] -= 1
                counts[fam] += 1
                moved = True
                break
            if not moved:
                break
    return chosen


def balance_sides(chosen, cells, rng, floor):
    """Swap within a cell until the set is 50/50 (or as close as the band
    allows) in side to move, taking victims only from families that are
    above the theme floor."""
    have = {p.pid for p in chosen}
    counts = Counter(p.family for p in chosen)
    for _ in range(5000):
        white = sum(1 for p in chosen if p.side == "white")
        black = len(chosen) - white
        if abs(white - black) <= 1:
            break
        major = "white" if white > black else "black"
        minor = "black" if major == "white" else "white"
        swapped = False
        cell_keys = list(cells)
        rng.shuffle(cell_keys)
        for cell in cell_keys:
            victims = [p for p in chosen if p.cell == cell and p.side == major]
            # Prefer a victim from a well-represented family, but do not let
            # the side balance stay broken if that is impossible.
            safe = [p for p in victims if counts[p.family] > floor]
            victims = safe or victims
            repls = [p for p in cells[cell] if p.side == minor and p.pid not in have]
            if not victims or not repls:
                continue
            victim = rng.choice(victims)
            repl = rng.choice(repls)
            chosen.remove(victim)
            chosen.append(repl)
            have.discard(victim.pid)
            have.add(repl.pid)
            counts[victim.family] -= 1
            counts[repl.family] += 1
            swapped = True
            break
        if not swapped:
            break
    return chosen


def select_set(pool, n, spec, rng):
    cells = defaultdict(list)
    for p in pool:
        cells[p.cell].append(p)
    avail = {c: len(v) for c, v in cells.items()}

    cell_targets = allocate_cells(n, PHASE_TARGETS, OUTCOME_TARGETS[spec.number], avail)
    chosen = []
    for cell, k in cell_targets.items():
        if k <= 0:
            continue
        cands = cells[cell]
        whites = [p for p in cands if p.side == "white"]
        blacks = [p for p in cands if p.side == "black"]
        kw = min(len(whites), k // 2)
        kb = min(len(blacks), k - kw)
        if kw + kb < k:  # one side is short in this cell; take the rest from the other
            if len(blacks) > kb:
                kb = min(len(blacks), k - kw)
            elif len(whites) > kw:
                kw = min(len(whites), k - kb)
        chosen.extend(pick_from_cell(whites, kw, rng))
        chosen.extend(pick_from_cell(blacks, kb, rng))

    # Top up if a cell could not supply its target.
    if len(chosen) < n:
        have = {p.pid for p in chosen}
        rest = [p for p in pool if p.pid not in have]
        rng.shuffle(rest)
        chosen.extend(rest[: n - len(chosen)])
    chosen = chosen[:n]

    family_avail = Counter(p.family for p in pool)
    floor = max(2, n // 100)
    chosen = repair_family_floor(chosen, cells, family_avail, floor, rng)
    chosen = balance_sides(chosen, cells, rng, floor)
    return chosen


# --------------------------------------------------------------------------
# Output
# --------------------------------------------------------------------------

def san_line(p):
    board = chess.Board(p.solver_fen)
    out = []
    for uci in p.solution:
        move = chess.Move.from_uci(uci)
        out.append(board.san(move))
        board.push(move)
    return " ".join(out)


def pgn_game(p, spec):
    game = chess.pgn.Game()
    game.headers["Event"] = "scidCommunity Puzzles: %s" % spec.name
    game.headers["Site"] = p.url
    game.headers["Date"] = "????.??.??"
    game.headers["Round"] = "-"
    game.headers["White"] = "?"
    game.headers["Black"] = "?"
    game.headers["Result"] = "*"
    game.headers["PuzzleId"] = p.pid
    game.headers["LichessRating"] = str(p.rating)
    game.headers["RatingDeviation"] = str(p.rd)
    game.headers["Popularity"] = str(p.pop)
    game.headers["NbPlays"] = str(p.nb)
    game.headers["Themes"] = " ".join(p.themes)
    game.headers["GameUrl"] = p.url
    game.headers["Set"] = str(spec.number)
    game.headers["SetName"] = spec.name
    # Scid orients the board from the "FlipB" extra tag when it loads a game
    # (tcl/game.tcl, ::game::Load) and otherwise keeps whatever orientation
    # the board already had. Puzzles must be solved from the solver's side,
    # so pin the orientation to the side to move; without an explicit "0"
    # a white-to-move puzzle would inherit a board the user had flipped.
    game.headers["FlipB"] = "1" if p.side == "black" else "0"
    game.headers["SourceFEN"] = p.fen
    if p.daily:
        try:
            stamp = datetime.datetime.fromtimestamp(
                int(p.daily) / 1000, tz=datetime.timezone.utc)
            game.headers["DailyDate"] = stamp.strftime("%Y.%m.%d")
        except (ValueError, OverflowError, OSError):
            game.headers["DailyDate"] = p.daily
    game.setup(p.solver_fen)
    node = game
    for uci in p.solution:
        node = node.add_main_variation(chess.Move.from_uci(uci))
    return game


def write_pgn(path, puzzles, spec):
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        for p in puzzles:
            fh.write(str(pgn_game(p, spec)))
            fh.write("\n\n")


MANIFEST_COLUMNS = [
    "Set", "SetName", "PuzzleId", "Rating", "RatingDeviation", "Popularity",
    "NbPlays", "SideToMove", "SolverMoves", "Phase", "Outcome", "Family",
    "Themes", "GameUrl", "DailyDate", "SolverFEN", "SourceFEN", "SolutionUCI",
]


def write_manifest(path, by_set):
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        w = csv.writer(fh)
        w.writerow(MANIFEST_COLUMNS)
        for spec, puzzles in by_set:
            for p in puzzles:
                w.writerow([
                    spec.number, spec.name, p.pid, p.rating, p.rd, p.pop,
                    p.nb, p.side, p.solver_moves, p.phase, p.outcome, p.family,
                    " ".join(p.themes), p.url, p.daily, p.solver_fen, p.fen,
                    " ".join(p.solution),
                ])


def fmt_pct(count, total):
    return "%.1f%%" % (100.0 * count / total) if total else "-"


def write_report(path, by_set, csv_path, csv_sha, args):
    lines = []
    lines.append("# Puzzle set generation report\n")
    lines.append("Generated by `scripts/build_puzzle_sets.py`.\n")
    lines.append("- Source: `%s`" % os.path.basename(csv_path))
    lines.append("- SHA-256: `%s`" % csv_sha)
    lines.append("- Seed: `%s`" % args.seed)
    lines.append("- Requested size per set: %d" % args.count)
    lines.append("")

    lines.append("## Summary\n")
    lines.append("| Set | Name | Puzzles | Rating min | Median | Max | White to move | "
                 "Avg solver moves |")
    lines.append("|---:|---|---:|---:|---:|---:|---:|---:|")
    for spec, puzzles in by_set:
        ratings = [p.rating for p in puzzles]
        whites = sum(1 for p in puzzles if p.side == "white")
        avg_moves = sum(p.solver_moves for p in puzzles) / len(puzzles)
        lines.append("| %d | %s | %d | %d | %.0f | %d | %s | %.1f |" % (
            spec.number, spec.name, len(puzzles), min(ratings),
            statistics.median(ratings), max(ratings),
            fmt_pct(whites, len(puzzles)), avg_moves))
    lines.append("")

    lines.append("## Phase, outcome and length\n")
    lines.append("| Set | opening | middlegame | endgame | mate | crushing | "
                 "advantage | other | 1 move | 3 moves | 5+ moves |")
    lines.append("|---:|---|---|---|---|---|---|---|---|---|---|")
    for spec, puzzles in by_set:
        total = len(puzzles)
        ph = Counter(p.phase for p in puzzles)
        ou = Counter(p.outcome for p in puzzles)
        mv = Counter(p.solver_moves for p in puzzles)
        long_moves = sum(c for m, c in mv.items() if m >= 5)
        lines.append("| %d | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (
            spec.number,
            fmt_pct(ph["opening"], total), fmt_pct(ph["middlegame"], total),
            fmt_pct(ph["endgame"], total), fmt_pct(ou["mate"], total),
            fmt_pct(ou["crushing"], total), fmt_pct(ou["advantage"], total),
            fmt_pct(ou["other"], total), fmt_pct(mv[1], total),
            fmt_pct(mv[3], total), fmt_pct(long_moves, total)))
    lines.append("")

    lines.append("## Theme coverage\n")
    lines.append("Families present per set, and the minimum count for a family "
                 "that is available in that band:\n")
    lines.append("| Set | Families | Smallest family count | Families below 5 |")
    lines.append("|---:|---:|---:|---:|")
    for spec, puzzles in by_set:
        fam = Counter(p.family for p in puzzles)
        lines.append("| %d | %d | %d | %d |" % (
            spec.number, len(fam), min(fam.values()),
            sum(1 for c in fam.values() if c < 5)))
    lines.append("")

    lines.append("### Major motifs\n")
    lines.append("| Motif | " + " | ".join(str(s.number) for s, _ in by_set) + " |")
    lines.append("|---|" + "---:|" * len(by_set))
    for motif in MAJOR_MOTIFS:
        row = []
        for _, puzzles in by_set:
            row.append(str(sum(1 for p in puzzles if motif in p.themes)))
        lines.append("| %s | %s |" % (motif, " | ".join(row)))
    lines.append("")

    lines.append("### Family counts\n")
    lines.append("Each puzzle is counted under the first theme family it matches, "
                 "so a puzzle tagged both `discoveredAttack` and `discoveredCheck` "
                 "is counted once, under `discoveredAttack`. The tag-level coverage "
                 "is in the two tables that follow.\n")
    lines.append("| Family | " + " | ".join(str(s.number) for s, _ in by_set) + " |")
    lines.append("|---|" + "---:|" * len(by_set))
    for fam in FAMILY_ORDER + ["other"]:
        row = [str(sum(1 for p in puzzles if p.family == fam)) for _, puzzles in by_set]
        lines.append("| %s | %s |" % (fam, " | ".join(row)))
    lines.append("")

    lines.append("### All theme tags\n")
    for spec, puzzles in by_set:
        counts = Counter(t for p in puzzles for t in p.themes)
        lines.append("**Set %d (%s):** " % (spec.number, spec.name) +
                     ", ".join("%s %d" % (t, c) for t, c in counts.most_common()))
        lines.append("")

    lines.append("## Verification\n")
    all_ids = [p.pid for _, ps in by_set for p in ps]
    lines.append("- Puzzles written: %d" % len(all_ids))
    lines.append("- Duplicate PuzzleIds: %d" % (len(all_ids) - len(set(all_ids))))
    lines.append("- Duplicate solver positions: %d" % (
        len(all_ids) - len({" ".join(p.solver_fen.split(" ")[:4])
                            for _, ps in by_set for p in ps})))
    lines.append("- Every solution was replayed with python-chess before writing.")
    white = sum(1 for _, ps in by_set for p in ps if p.side == "white")
    lines.append("- Orientation: `FlipB` is written to match the side to move in "
                 "every game (%d white, %d black), so Scid opens each puzzle "
                 "from the solver's side." % (white, len(all_ids) - white))
    lines.append("")

    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(lines))


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--csv", required=True, help="Lichess puzzle CSV")
    ap.add_argument("--out", required=True, help="output directory")
    ap.add_argument("--count", type=int, default=1000, help="puzzles per set")
    ap.add_argument("--seed", default="20261120", help="sampling seed")
    ap.add_argument("--rows", type=int, default=None, help="only read N data rows (testing)")
    args = ap.parse_args(argv)

    rng = random.Random(args.seed)
    os.makedirs(args.out, exist_ok=True)

    print("Streaming %s ..." % args.csv, flush=True)
    heaps, seen, skipped = stream_pools(args.csv, SETS, POOL_CAP, rng, args.rows, args.seed)
    print("Read %d rows (%s)." % (seen, ", ".join("%s: %d" % kv for kv in skipped.items())),
          flush=True)

    by_set = []
    for spec in SETS:
        raw = [rec for _, _, rec in heaps[spec.number]]
        # Highest-weight first, then drop duplicate games and positions.
        raw.sort(key=lambda r: r[0])
        pool = []
        games = set()
        positions = set()
        bad = 0
        for rec in raw:
            p = Puzzle(*rec)
            try:
                analyse(p)
            except (ValueError, KeyError) as exc:
                bad += 1
                if bad <= 3:
                    print("  skipping %s: %s" % (p.pid, exc), file=sys.stderr)
                continue
            if spec.max_solver_moves and p.solver_moves > spec.max_solver_moves:
                continue
            gid = game_id(p.url)
            pos = " ".join(p.solver_fen.split(" ")[:4])
            if gid in games or pos in positions:
                continue
            games.add(gid)
            positions.add(pos)
            pool.append(p)
        if len(pool) < args.count:
            raise SystemExit("set %d: only %d candidates, need %d" %
                             (spec.number, len(pool), args.count))
        puzzles = select_set(pool, args.count, spec, rng)
        puzzles.sort(key=lambda p: (p.rating, p.pid))
        by_set.append((spec, puzzles))
        print("Set %d (%s): %d puzzles from %d candidates." %
              (spec.number, spec.name, len(puzzles), len(pool)), flush=True)

    for spec, puzzles in by_set:
        name = "set-%d-%s.pgn" % (spec.number, spec.name.lower())
        write_pgn(os.path.join(args.out, name), puzzles, spec)

    write_manifest(os.path.join(args.out, "manifest.csv"), by_set)
    csv_sha = sha256_file(args.csv) if not args.rows else "not computed (--rows)"
    write_report(os.path.join(args.out, "REPORT.md"), by_set, args.csv, csv_sha, args)
    print("Wrote %d PGN files, manifest.csv and REPORT.md to %s." %
          (len(by_set), args.out))


if __name__ == "__main__":
    main()
