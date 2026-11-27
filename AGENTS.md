# Agent notes

## XERJ (code search)

This project uses XERJ for reference coding. Before writing code that touches
unfamiliar territory, retrieve how a peer already solved it, adapt it here, and
cite the `file:line` you relied on.

The node runs as the systemd **user** service `xerj.service` at
`http://localhost:9200` (`systemctl --user status xerj`, logs with
`journalctl --user -u xerj`). Four corpora are indexed:

- `scid` — **this repository** (6 datasets, 47,855 records, 352 code files).
- `ref-scid-codeberg-myscid` — the Codeberg `scid` fork, `myscid` branch
  (10,133 records), cloned to `~/Downloads/scid-codeberg-myscid`.
- `ref-scid-codeberg` — an older `benini/scid` (Scid vs. PC) tree (9,626
  records), indexed in place from `~/Downloads/scid`.
- `ref-scidvspc` — Scid vs. PC (70,665 records), indexed in place from
  `~/Downloads/scidvspc-code`.

No other peers are indexed: Stockfish, chessx, python-chess and cutechess are
**not** in the dataset, so `ref-stockfish-*`, `ref-chessx-*`, `ref-pychess-*`
and `ref-cutechess-*` match nothing.

**Always pass a prefix**, because the CLI and MCP defaults are `ax-*`, which
does not exist here:

```sh
xerj def --prefix scid "AddMove"
xerj search --prefix scid "how the movetree encodes variations"
xerj search --prefix ref-scidvspc "polyglot book probe"
```

The `xerj_*` MCP tools behave the same way: pass `prefix` (`xerj_search`
without one returns zero hits silently, not an error). Only C/C++ gets symbol
tables — `.tcl` is indexed as searchable text, so `xerj def` cannot resolve a
Tcl proc.

Full setup, query recipes and limits: **`docs/REFERENCE_CODING.md`**.
