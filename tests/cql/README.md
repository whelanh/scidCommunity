# CQL harnesses

Two headless scripts for working on `sc_search cql` and the CQL engine in
`src/cql/`. Both are run with the built binary and a script argument, which the
application executes on a bare interpreter: no Tk, no display, no X server.

```
./scidCommunity tests/cql/check.tcl      # correctness, well under a second
./scidCommunity tests/cql/bench.tcl      # timing on a synthetic base
```

`check.tcl` builds a MEMORY base from `tests/tcl/search_moves.pgn` (five games)
and checks the filter each query leaves behind. It covers the position filters,
`:gamenumber`, the index-backed tag pre-filter (player, result, event, site,
year, Elo, in both the `cql(:player ...)` and `cql() player ...` forms), the
"or" safety case, and the AND/OR/RESET filter operations. It prints
`deleteableCleanup` lines from the engine's own cleanup; those are expected.

`bench.tcl` repeats a PGN until it has at least the requested number of games,
imports it into a MEMORY base and times a few queries:

```
./scidCommunity tests/cql/bench.tcl tests/tcl/search_moves.pgn 100000 1000
```

The defaults are that PGN, 100000 games and a `:gamenumber` range ending at
1000. A synthetic base has short games, so it understates the cost of decoding
a real one; it is for comparing before/after on the same base, not for
predicting absolute times on a 4.5M game database.

The Tk harness `tests/tcl/search_cql.tcl` remains the end-to-end gate (window,
menu, progress bar, dialogs). It needs a working display — CI runs it under
Xvfb — and is much slower, so use these scripts in the edit/build loop and let
CI run the Tk one.
