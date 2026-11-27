---
name: xerj
description: Definition-first code search over locally indexed repos (xerj search / xerj def)
---

Use XERJ instead of grep when you need code you cannot see in the open files.

**Always pass a prefix.** The default prefix (`ax-*`) does not exist here, so a
query without one returns zero hits silently. Corpora:

- `scid` - this repository
- `ref-scid-codeberg` - the Codeberg `scid` fork
- `ref-scidvspc` - Scid vs. PC

Commands:

- `xerj def --prefix scid "<symbol>"` - where is this defined? Returns file:line + signature.
  Only C/C++ has symbol tables: `def` cannot resolve a Tcl proc; use `search` for Tcl.
- `xerj search --prefix ref-scidvspc "<plain words>"` - ranked passages; cite the printed file:line.
- MCP: the `xerj_search` tool takes the same `prefix` argument.

The node runs as the user service `xerj.service` on `http://localhost:9200`.
Setup, recipes and limits: `docs/REFERENCE_CODING.md`.

Trust the passage over memory: it is the actual code at that path.
