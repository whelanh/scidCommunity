# Graded puzzle sets

Six sets of 1,000 Lichess puzzles, from beginner to expert. They are plain
PGN, so the Woodpecker trainer, Scid's PGN import and any other chess
program can read them.

| Set | File | Lichess rating | Median | Label |
|---:|---|---:|---:|---|
| 1 | `set-1-beginner.pgn` | 600–899 | 821 | Beginner |
| 2 | `set-2-novice.pgn` | 900–1199 | 1092 | Novice |
| 3 | `set-3-intermediate.pgn` | 1200–1499 | 1367 | Intermediate |
| 4 | `set-4-club.pgn` | 1500–1799 | 1636 | Club |
| 5 | `set-5-advanced.pgn` | 1800–2099 | 1944 | Advanced |
| 6 | `set-6-expert.pgn` | 2100–2450 | 2209 | Expert |

The bands are contiguous and do not overlap, so no puzzle appears in two
sets. Within a set the puzzles are sorted from easiest to hardest.

## Format

One game per puzzle:

- `FEN` is the position the solver is shown. Lichess publishes the position
  *before* the opponent's move; the first move of the CSV is that opponent
  move, so it has already been played here. The main line is the solution,
  starting with the solver's first move, in SAN.
- `PuzzleId`, `LichessRating`, `RatingDeviation`, `Popularity`, `NbPlays`,
  `Themes`, `GameUrl` and `SourceFEN` record where the puzzle came from.
  `SourceFEN` is the position before the opponent's move, for reference.

`manifest.csv` has the same information in tabular form, including the
solution in UCI, and is meant for review rather than for training.

## How the sets were chosen

Every puzzle passed these gates:

- Lichess `Popularity` ≥ 90, `NbPlays` ≥ 100 and `RatingDeviation` ≤ 90;
- the whole solution replays legally (checked with python-chess);
- one puzzle per source game, and no repeated solver position.

Within each set the selection balances:

- **phase** — 10% opening, 55% middlegame, 35% endgame;
- **outcome** — mates, crushing wins and smaller advantages, with the mate
  share falling from 30% in set 1 to 5% in set 6;
- **side to move** — 50% white, 50% black;
- **theme** — families are weighted by the square root of their availability,
  so rare motifs appear without displacing forks and pins, and the untagged
  "other" group is held to roughly 10% (a little more in the top sets, where
  fewer puzzles carry a specific motif);
- **length** — set 1 allows at most three solver moves, and longer solutions
  become more common as the rating rises.

The exact coverage of this build is in `REPORT.md`.

## Regenerating

The generator is seeded, so the same command reproduces this build exactly:

```sh
python3 scripts/build_puzzle_sets.py \
    --csv ~/Downloads/lichess_db_puzzle.csv --out puzzles --count 1000
```

It needs [python-chess](https://python-chess.readthedocs.io/) (`pip install chess`).
Use a different `--seed` to draw a different collection from the same
snapshot, or `--count` to change the size. The rating bands and the phase and
outcome targets are constants near the top of the script.

## Licence

The puzzles come from the Lichess puzzle database, which Lichess publishes
under CC0. See `Copyright.txt`.
