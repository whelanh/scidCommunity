# CQL Engine Import

This directory contains the CQL (Chess Query Language) engine, imported from
Scid vs. PC so that scidCommunity can offer a `cql` search alongside the
existing moves, board, header, comments and material searches.

## Provenance

- **Source:** Scid vs. PC, `svn://svn.code.sf.net/p/scidvspc/code` at
  **r3777** (`src/cql/`).
- **Mirror reference:** [github.com/tagatac/scidvspc](https://github.com/tagatac/scidvspc)
  at `cb5309c2`. The mirror lags r3777 in two files only
  (`gamesortinfo.cpp`, `origChanges.cpp`); both were refreshed from r3777, so
  the imported tree matches r3777 rather than the mirror.
- **Imported:** 2026-11-16.
- **Licence:** see `COPYING` in this directory. Every imported source carries
  an `SPDX-License-Identifier` header.

## What is not upstream

| Path | What it is |
|---|---|
| `cql_pgnparse_adapter.h`, `cql_pgnparse_adapter.cpp` | **scidCommunity's own code.** Re-creates the members the engine uses from Scid vs. PC's file-oriented PGN reader (`MFile`, `PgnParser`) on top of scidCommunity's buffer-oriented `pgn::parse_game()`, and exposes the four calls the search driver needs. Not imported, not covered by an upstream resync. |
| `src/tkscid.cpp` (`scid_search` / `cql` branch) | **scidCommunity's own code.** Scid vs. PC drives the engine from its own search code; this tree has no equivalent, so the query loop lives here instead. |

`CqlQueryParse()`'s second parameter is Scid vs. PC's `silentSwitch` polarity
(1 = annotations/comments allowed), not an `allowComments` flag.

## Deliberate deviations

Five files differ from r3777 on purpose. **Do not revert any of these when
re-syncing**; each one fixes a bug that only shows against scidCommunity's own
callers.

| # | Where | Why |
|---|---|---|
| 1 | `lexer.cpp` — `bgetc()` leaves the cursor **on** the terminating NUL | Upstream advances first, so it consumes the terminator and the next `readstring()` lexes whatever bytes follow the query in memory. |
| 2 | `lexer.cpp` — `bgetc()` returns the byte **unsigned** | `char` is signed on x86-64, so a UTF-8 byte ≥ 0x80 came back negative and ended the token at the first accented character (a non-ASCII comment or player name truncated the query). |
| 3 | `echomatchinfo.cpp` — relation id lists are built in a `std::string`, not a `char buffer[2000]` | An unchecked `sprintf()` per target overflowed the stack buffer for a source with a few hundred targets; a list too long for the engine's comment limit now ends with `...]` instead of overflowing. |
| 4 | `nodematch.cpp` — `extension` is refused at parse time | The generator needs `MarkBoard::getLegalMoves()`, which this tree does not implement: it asserted, and the adapter turned that into a per-game runtime error, so the keyword could never match. |
| 5 | `chesstypes.h` — `square_rank()`/`square_file()` are `static inline` | Upstream declares them `inline` with no internal linkage. GCC folds the inline copies and lets `src/polyglot/square.cpp`'s definitions win, but MSVC emits them from `chesstypes.obj` and fails the link with `LNK2005` against `polyglot.lib`. `static` keeps each translation unit self-contained. |

Details on the two lexer deviations, both in `bgetc()`:

```cpp
int bgetc(char *buffer) {
  const unsigned char c = static_cast<unsigned char>(buffer[rsIndex]);
  if (!c) return EOF;
  rsIndex++;
  return c;
}
```

Upstream advances first (`int c = buffer[rsIndex++];`), so it consumes the
terminator and the next `readstring()` lexes whatever bytes follow the query in
memory. scidCommunity is the first caller to hand the lexer an in-memory
`std::string`, which makes the bug a live one: any query whose last token is
not a delimiter (`cql() qh4`) reads one phantom `NameToken` and fails with
`Lexer: Unknown or not understood sequence of characters` — measured as 4-7
failures in 8 runs before the fix, 0 afterwards, and 5 tokens before vs 4 after
on a standalone harness over the real lexer.

The `static_cast<unsigned char>` is the second half: without it a query such as
`cql() ; Zürich` followed by `qh4` on the next line lexed only up to the `ü`
and the rest of the query was silently dropped. `bungetc()` now rewinds only a
byte `bgetc()` actually consumed, for the same reason (`EOF` is reported for the
NUL without advancing).

## Files adapted to scidCommunity's API (23)

The rest of the engine is upstream's, unchanged apart from the SPDX headers.
These 23 files were adapted because scidCommunity's `Game`/`Position`/`MoveList`
API differs from Scid vs. PC's: `isNullMove(sm)` becomes `sm->isNullMove()`,
`pieceT*` board parameters become `const pieceT*`, `pos->IsStaleMate()` goes
through `CqlIsStaleMate(pos)`, `game->GetNumber()` through `CqlGameNumber()`,
`game->GetCurrentMoveCQL()` through `CqlCurrentMove(game)`, and
`Game::WriteToPGN_CQL()` (which lives in Scid vs. PC's `origChanges.cpp`) is
replaced by scidCommunity's `Game::WriteToPGN()`:

```
attacknode.cpp            echomatchinfo.cpp         node.h
cqlnode.cpp               echonode.cpp              piecelocmatch.cpp
cqlnodematch.cpp          echosquarespec-transform.cpp  playernode.cpp
eventnode.cpp             markboard.cpp             powernode.cpp
markboard.h               markboardmap.cpp          raynode.cpp
markboardstatic.cpp       match.cpp                 sitenode.cpp
matchcommentnode.cpp      movebase.cpp              util.cpp
node.cpp                  util.h
```

## Known limitations carried from r3777

### A mixed `move` / `next ... nestban` filter (report not reproduced)

Reported: a filter with a `move` in one branch of an `or` and a `next ... nestban`
in a sibling is linearised per child, which re-evaluates the whole filter at
every outgoing move; `notate()` registers the positions a `nestban` sequence
matched, so the second evaluation at the same position is refused by
`SequenceBase::match_position()` and a valid filter misses the game.

Measured on this tree with a debug build that printed every
`FutureNode::computeLinearize()` child evaluation and every
`SequenceBase::nestSeenPosition()` decision:

- Without search variations the lineariser is called with **one** child per
  position, so nothing is evaluated twice.
- With `:variations` and a game holding a second first move, the filter is
  evaluated once per child (`nchildren=2`), and on an annotating search
  (`sc_search cql ... 0 1`) the second evaluation *is* refused ("nestban
  refuse") - the mechanism the report describes is real.
- No query of that shape produced the claimed false negative. Every one still
  matched the fixture game, silent and annotating, e.g. on
  `1. d4 (1. Nf3 Nf6) 1... d5 2. c4`:
  `cql(:variations) next (next nestban ((K) (K)) or move h2 h3 (K))`,
  `... or move h2 h3 c4`, `... or move h2 h3`, and the same three with
  `next nestban ((move g1 f3) (K))` - each against the identical query without
  `nestban`, and every pair agreed on the count.

A refused branch only suppresses that branch at one position: `do_match()`
evaluates the filter at every position of the game, and registration only
covers positions already on a matched path, so the match is still found. Since
the consequence does not reproduce, `linearize.cpp` is unchanged - re-test
before rewriting the lineariser.

## Re-syncing upstream

1. `svn export` the desired revision's `src/cql/` from
   `svn://svn.code.sf.net/p/scidvspc/code`.
2. Keep `cql_pgnparse_adapter.*` and this file.
3. Carry the whole diff against r3777 forward rather than re-applying pieces of
   it. That diff is all four deliberate deviations listed above - both
   `lexer.cpp` changes, the `echomatchinfo.cpp` buffer fix and the
   `nodematch.cpp` parse-time rejection of `extension` - plus the 23 API
   adaptations in the next section. Re-applying only the `lexer.cpp` part
   restores the stack-buffer overflow and lets `extension` reach the runtime
   stub again, and both regressions look like engine behaviour rather than a
   missing change.
4. Re-add the SPDX headers.
5. `cmake --build build` and run `tests/tcl/search_cql.tcl` and
   `tests/tcl/search_cql_tk.tcl`.
