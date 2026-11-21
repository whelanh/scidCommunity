# Woodpecker feasibility probe

Measures what the review's verdict code writes on Lichess puzzle solutions.
It runs the repository's own `::review::mainLineMap`, `::reviewdriver::sides`,
`::reviewdriver::judge`, `::movelabels::label` and `::movelabels::refine` on
each solver move, with Stockfish doing the search the review pass would do
(MultiPV 3, depth 18 by default). Results are in `docs/woodpecker-adr.md`, Decision 3.

Requirements: `tclsh` 8.6, `python3` (stdlib only), Stockfish
(`/usr/games/stockfish` or `$STOCKFISH`), network access to `lichess.org`.

```bash
mkdir -p out
for d in easier normal harder hardest; do curl -sS "https://lichess.org/api/puzzle/batch/mix?nb=40&difficulty=$d" -o out/batch_$d.json; sleep 2; done
```

```bash
python3 -I extract.py out/puzzles.tsv out/batch_*.json
```

```bash
tclsh puzzle_review_probe.tcl ../.. out/puzzles.tsv out/probe.tsv 18 3
```

```bash
tclsh features.tcl ../.. out/puzzles.tsv out/probe.tsv out/probe_f.tsv
```

```bash
python3 -I analyze.py out/probe_f.tsv
```

| File | Role |
|---|---|
| `extract.py` | Lichess batch JSON → one TSV row per puzzle |
| `sanlib.tcl` | SAN → UCI on `::chessboard`, and the puzzle's start FEN from the game PGN (the batch endpoint has no FEN) |
| `puzzle_review_probe.tcl` | Engine search + the review's verdict code, one row per solver move |
| `features.tcl` | Adds capture / check / quiet flags to each row |
| `analyze.py` | Label distribution, why brilliant is rare, candidate `!`/`!!` definitions checked against the Lichess rating |

The batch endpoint is for training, not bulk download (Lichess API spec): keep
samples small, one request at a time.

## Marks of the bundled puzzles

`bundled_marks.tcl` regenerates `puzzles/marks.tsv`, the `!` and `!!` of the nine
bundled puzzle sets, with the trainer's own evaluation. It needs the built
application (for the `sc_*` commands) and a UCI engine, not network access:

```bash
WP_ENGINE=/path/to/stockfish scidCommunity scripts/woodpecker/bundled_marks.tcl
```

All 9,000 puzzles take roughly two hours on one core (the high sets are the
slow ones). `WP_SETS` and `WP_OUT` grade some sets into a part file, which lets
you run one process per set; the header of the script shows how to join the
parts. Rerun it whenever `::woodpecker::markFor` or the evaluation changes.
