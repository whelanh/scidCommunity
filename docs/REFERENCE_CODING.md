# Reference coding with XERJ

This project has a local [XERJ](https://xerj.org) node with four searchable
corpora: **this repository** and three **peer `scid` trees**, indexed so an
agent can retrieve how a neighbouring project already solved a problem *before*
writing code.

The workflow (the measured "reference coding" loop):

1. **Retrieve** the mechanism from an indexed peer (`xerj search` / the
   `xerj_search` MCP tool) and read the returned passage with its `file:line`.
2. **Adapt** it to this codebase and **cite** the source you relied on.
3. If nothing relevant comes back, say so and work normally — a forced match is
   worse than no retrieval.

## The node

| | |
| --- | --- |
| Endpoint | `http://localhost:9200` (Elasticsearch 8.x-compatible) |
| Data dir | `~/xerj-data` (kept **outside** every indexed tree) |
| Service | `xerj.service`, a systemd **user** unit at `~/.config/systemd/user/xerj.service` |
| Start / stop | `systemctl --user start xerj` / `systemctl --user stop xerj` |
| Health | `curl -s localhost:9200/_cluster/health` or `systemctl --user status xerj` |
| Logs | `journalctl --user -u xerj -f` |

The unit is `enabled` with lingering on (`loginctl enable-linger`), so it
starts at boot whether or not you log in, and `Restart=on-failure` brings it
back if it dies. There is no pid file to manage. Restart with
`systemctl --user restart xerj`; the same `--data-dir` keeps every index.

> **Embedding mode is fixed at ingest.** The node runs in the **default lexical
> mode** (deterministic feature-hashing, BM25-style). This is the configuration
> the reference-coding study measured. Neural mode (`--embed-mode neural`) would
> require re-indexing every corpus, so decide before re-indexing if you want it.

## The corpora

**This project** — prefix `scid`, query `scid-*` (6 datasets, 47,855 records;
352 code files, 246 of them with symbol tables). Code and prose share
`scid-docs`; `scid-scripts-cb-mega`, `scid-puzzles`, `scid-data`,
`scid-data-io-github-whelanh-scidco` and `scid-resources-svg` hold bulk
data/XML. The dataset split is chosen by `autoindex` from content and can
change between versions, so scope with prefix or `ax_format`, not with an
index-name list.

**References** — prefix `ref-<repo>`, query all with `ref-*` or one repo with
`ref-<repo>-*`. The two Scid vs. PC trees are indexed **in place**; the Codeberg
fork is a dedicated clone at `~/Downloads/scid-codeberg-myscid` (there is no
`~/xerj-refs/` directory). Resume journals live in `~/xerj-state/<prefix>`.

> **Index-name patterns take a trailing `*` only.** `ref-*` and
> `ref-scidvspc-*` work; `ref-*-docs` matches nothing. A pattern also matches
> longer prefixes — `ref-scid-codeberg-*` covers both corpora under that
> prefix, which is deliberate; otherwise keep peer prefixes that do not start
> one another so a query cannot silently widen.

| Prefix | Upstream | Version | Licence | Records | Why it is here |
| --- | --- | --- | --- | --- | --- |
| `ref-scid-codeberg-myscid` | codeberg.org/scid/scid, `myscid` branch | `be2908ea` (2026-08-15) | GPL-2.0 | 10,133 | The fork this project credits for the engine-vs-engine tournament feature and PGN viewer; same `scid` core, cloned to `~/Downloads/scid-codeberg-myscid` |
| `ref-scid-codeberg` | benini/scid (Scid vs. PC), `github` branch | `fc263371` (2026-06-03) | GPL-2.0 | 9,626 | Older Scid vs. PC tree, indexed in place from `~/Downloads/scid`; overlaps `ref-scidvspc` |
| `ref-scidvspc` | benini/scid (Scid vs. PC) | plain source tree, no git metadata | GPL-2.0 | 70,665 | Closest sibling — a Tcl/Tk `scid` fork with the same `dbase`/`codec`/`movetree`/`polyglot` lineage, indexed in place from `~/Downloads/scidvspc-code` |

Only these three peers are part of the dataset. The four other references this
doc used to list are **not indexed**: Stockfish's source is on disk at
`~/Downloads/Stockfish` but was deliberately left out; chessx and python-chess
have no checkout; `~/GoogleDrive/cutechess-linux` is a compiled release, not
source. A `ref-stockfish-*`, `ref-chessx-*`, `ref-pychess-*` or
`ref-cutechess-*` query therefore returns no hits rather than an error.

All indexed peers are GNU GPL-2.0; this project is GPL too, so the licences
are compatible. Still follow the reference-coding rule for GPL peers: **read
the design and adapt it — do not paste code**, and record which file:line you
used.

## Retrieving

Definition-first query (ranks the file that *defines* a symbol above files that
merely mention it; `_passage` returns the enclosing function/block, not the whole
file):

```sh
curl -s 'http://localhost:9200/ref-*/_search' -H 'Content-Type: application/json' -d '{
  "query":{"bool":{"should":[
    {"multi_match":{"query":"<symbol or plain words>","fields":["body","defs"],"type":"most_fields"}},
    {"match_phrase":{"defs":{"query":"<symbol or plain words>","boost":4}}}]}},
  "_source":["ax_path","title"],"fields":["_passage"],"size":5}'
```

Scope it: replace `ref-*` with `ref-scidvspc-*` (the Scid vs. PC tree) or
`ref-scid-codeberg-*` (both corpora under that prefix, or
`ref-scid-codeberg-myscid-*` for the newer fork alone), or use `scid-*` for this
project's own code. To
restrict a hit set to source files add a `{"term":{"ax_format":"code"}}` filter
(`ax_format` values here include `code`, `html`, `txt-lines`, `txt-prose`,
`xml`, `yaml`).

CLI and MCP shortcuts:

```sh
xerj search --prefix scid "how the movetree encodes variations"  # ranked passages, definitions first
xerj def --prefix scid AddMove                                  # go-to-definition: file:line + signature
xerj search --prefix ref-scidvspc "polyglot book probe"
```

> **The default prefix is `ax`, and this node has no `ax-*` indices.** Omit
> `--prefix` (or `index`) and the CLI errors with *no indices named ax-\** while
> the MCP tools return **zero hits silently**. Always name the corpus.

MCP tool `xerj_search` takes the same plain-string query plus `prefix`. `xerj_map`
returns each index's real field names/types — call it before writing query DSL.

## Honest limits

- **Lexical, not neural.** Query in the words the source would use; a paraphrase
  that shares no words will miss. (Neural is opt-in via `--embed-mode neural`,
  at the cost of re-indexing.)
- **Definitions only, and C/C++ only.** Hits name the declaration site; there is
  no call graph, no import graph, no cross-file reference resolution. Symbol
  extraction covers `.c`, `.h` and `.cpp` — **Tcl is not AST-indexed**: the 315
  `.tcl` files here (and most of Scid vs. PC's UI) land as `txt-lines`/`txt-prose`,
  so lexical search finds them but `xerj def` cannot resolve a Tcl proc and may
  return a same-named C++ symbol instead.
- **Retrieval pays on unfamiliar code, not memorised libraries.** Widely known
  engine internals (`attacks`, `movegen`) are often faster to recall than to
  retrieve, and Stockfish is not indexed here anyway. Retrieval pays most on this
  project's own internals and on the sibling forks.
- **Server memory grows with documents indexed.** The current corpora (~138k
  documents, 701 MB on disk) hold about 2.4 GB resident after the index runs.
  Watch it with
  `systemctl --user show xerj -p MemoryCurrent`; `systemctl --user restart xerj`
  keeps every index and releases heap. Index one corpus at a time.

## Re-indexing / adding a peer

```sh
# this repository (run from the repo root)
xerj autoindex . --prefix scid --state-dir ~/xerj-state/scid --progress plain

# a peer indexed in place (here the older benini/scid tree)
xerj autoindex ~/Downloads/scid --prefix ref-scid-codeberg \
  --state-dir ~/xerj-state/ref-scid-codeberg --progress plain

# the Codeberg fork on its myscid branch (dedicated clone)
xerj autoindex ~/Downloads/scid-codeberg-myscid --prefix ref-scid-codeberg-myscid \
  --state-dir ~/xerj-state/ref-scid-codeberg-myscid --progress plain
```

One prefix per folder. A re-run resumes and never duplicates; unchanged bytes
are not rewritten, so re-index after a pull or branch switch. To add a new peer,
clone it (anywhere with room), index it under `ref-<name>`, and add a row to the
table above. To drop a corpus:

```sh
xerj autoindex remove --prefix <name> --root <folder> --yes
```

Exit code `3` means *completed with junk* and is a **success** (binary assets
skipped, recorded as junk rather than fatal).
