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

## One deliberate deviation from r3777

`src/cql/lexer.cpp` is **not** byte-identical to r3777. `bgetc()` no longer
advances `rsIndex` past the terminating NUL:

```cpp
int bgetc(char *buffer) {
  int c = buffer[rsIndex];
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
on a standalone harness over the real lexer. **Do not revert this line when
re-syncing.**

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

## Re-syncing upstream

1. `svn export` the desired revision's `src/cql/` from
   `svn://svn.code.sf.net/p/scidvspc/code`.
2. Keep `cql_pgnparse_adapter.*` and this file.
3. Re-apply the `lexer.cpp` fix above and the 23 adaptations, or diff against
   r3777 and carry the changes forward.
4. Re-add the SPDX headers.
5. `cmake --build build` and run `tests/tcl/search_cql.tcl` and
   `tests/tcl/search_cql_tk.tcl`.
