# The Analysis Engine retirement — a measured inventory

Issue whelanh/scidCommunity#437, phase 1 (*"Add a short deprecation note … make the inventory a checklist: every `::uci::` and `::analysis(` use gets a decision — port, retire, or dead"*).

Measured at **`97efd988`** (upstream `github`, 2026-11-11, after #436 closed). Counts include comments and quoted strings, so every row below was read rather than only counted. #437's own table was taken at `d3986fc1` and has drifted: four rows changed, one file it groups as "1–2 each" (`tcl/options.tcl`) actually carries 14, and two files are unlisted (`tcl/enginecomm.tcl`, and the new `tcl/tools/epd_analysis.tcl`).

The point of the document is the **decision** column, not the number. A number with no decision is what "a blind delete" looks like.

## What #436 already removed

- `tcl/main.tcl`, `tcl/file/epd.tcl`, `tcl/tools/enginelist.tcl`: no `::uci::`, `::analysis(` or `analysisWin` sites left. The doors are shut.
- EPD's "Analyse positions" moved to `tcl/tools/epd_analysis.tcl`: a private connection, no Tk, stub-testable. It is the newest client of `::uci::formatPv`.
- Review Settings carries `FindOpeningErrors` and `MarkTacticalExercises` (`tcl/tools/review_ui.tcl:129,131`), so the two features the legacy Annotate dialog kept are now the review writer's job.

## The count

| File | `::uci::` | `::analysis(` | `analysisWin` |
|---|---:|---:|---:|
| `tcl/tools/analysis.tcl` | 8 | 28 | 75 |
| `tcl/tools/sergame.tcl` | 80 | 6 | 0 |
| `tcl/tools/uci.tcl` | 56 | 26 | 0 |
| `tcl/tools/calvar.tcl` | 12 | 10 | 0 |
| `tcl/options.tcl` | 14 | 0 | 0 |
| `tcl/enginecomm.tcl` | 8 | 0 | 0 |
| `tcl/tools/reviewgame.tcl` | 4 | 4 | 0 |
| `tcl/tools/tactics.tcl` | 4 | 1 | 0 |
| `tcl/tools/finish_game.tcl` | 0 | 1 | 3 |
| `tcl/tools/epd_analysis.tcl` | 2 | 1 | 0 |
| `tcl/file/maint.tcl` | 0 | 0 | 2 |
| `tcl/tools/lichess_eval.tcl` | 2 | 0 | 0 |
| `tcl/tools/lichess_openex.tcl` | 2 | 0 | 0 |
| `tcl/tools/review_annotate.tcl` | 0 | 0 | 2 |
| `tcl/tools/game_review.tcl` | 1 | 0 | 0 |
| `tcl/tools/review_driver.tcl` | 1 | 0 | 0 |
| `tcl/tools/review_progress.tcl` | 1 | 0 | 0 |
| `tcl/tools/stored_eval.tcl` | 1 | 0 | 0 |
| `tcl/tools/tablebase.tcl` | 1 | 0 | 0 |
| `tcl/utils/win.tcl` | 0 | 0 | 1 |
| **total** | **197** | **77** | **83** |

Twenty files, 36 distinct `::uci::` symbols and 29 distinct `::analysis(...)` keys.

## `::uci::` — a decision per symbol

### Retire with the old pipe engine mode (20 procs, all of them defined in `tcl/tools/uci.tcl`)

`resetUciInfo` (2), `processAnalysisInput` (3), `processInput_` (2), `readUCI` (1), `checkEngineIsAlive` (2), `whenReady` (4), `onReady_` (6), `startEngine` (5), `sendToEngine` (13), `closeUCIengine` (7), `sendUCIoptions` (3), `sendStop` (3), `sendPositionGo` (1), `sendPositionGo_` (1), `sendIsReady` (1), `sendOptions_` (1), `uciConfig` (1), `uciConfigWin`, `tokeep`, `saveConfig` (1).

Callers today: `calvar` (12), `reviewgame` (4), `tactics` (4) — retired or ported by #437 §3 — and `sergame` (80), ported by #437 §4. Nothing else calls them, so the group dies in phase 6, after both ports.

### Retire with the engine-options config path (globals inside `uci.tcl`)

`uciOptions` (3), `optList` (2), `optionToken` (2), `oldOptions` (2), `newOptions` (4), `check` (3), `infoToken` (1), `optionToKeep` (1), `optionImportant` (1), `engineListIndex` (2).

They are written by `uciConfig`/`sendOptions_` and read by the same path. `engineListIndex` is also read by `sergame`, so it travels with that port. No file outside `uci.tcl` (and `sergame`, for that one) references them — `tcl/options.tcl` does not, which is the surprise: the Engines dialog does *not* use this machinery.

### Keep — this is the modern parser, not the old mode

`parseline` (3), `sendOptions` (2), `sendNewGame` (2), `sendGo` (2) — all defined in `tcl/enginecomm.tcl`, and `parseline` is already read by `tcl/tools/review_driver.tcl`. Deleting `uci.tcl` must not touch `enginecomm.tcl`.

### Relocate — formatting helpers with live, retained clients

| Symbol | Uses | Callers |
|---|---:|---|
| `formatPv` | 10 | `stored_eval`, `tablebase`, `lichess_eval`, `lichess_openex`, `calvar`, `epd_analysis` |
| `formatPvAfterMoves` | 1 | `calvar` |
| `sc_move_add` | 4 | `sergame`, `game_review`, `review_progress`, `analysis.tcl` |

Move to `tcl/tools/uci_format.tcl` (namespace choice is an open question below) **before** `uci.tcl` is deleted. `epd_analysis.tcl:30` — shipped by #436 — already depends on `::uci::formatPv` through an `info commands` guard, so the guard must keep resolving after the move.

### Port — the shared engine-slot state

`uciInfo` (95 uses): `sergame`, `calvar`, `options.tcl`, `uci.tcl`. This is **not** an Analysis-window structure. See finding 1.

## `::analysis(...)` — a decision per key

| Keys | Uses | Owner | Decision |
|---|---:|---|---|
| `waitForReadyOk`, `whenReady`, `waitForBestMove`, `thinking`, `pipe`, `score`, `uci`, `moves`, `movesDisplay`, `analyzeMode`, `lockEngine`, `multiPV`, `multiPV1`, `multiPVCount`, `multiPVraw`, `wants_usermove`, `log` | 76 | `uci.tcl` writes them; `analysis.tcl`, `sergame`, `calvar`, `reviewgame`, `tactics` read them | **Retire** with the window and the old mode; no key survives phase 6 |

`epd_analysis.tcl:7` mentions `::analysis(...)` in prose only (it explains what the module replaced) — a comment edit, not a dependency.

## Findings that change the plan

1. **`::uci::uciInfo` is Play-versus-Engine's state, not the Analysis window's.** `sergame` alone sets and reads clocks (`wtime`, `btime`, `winc`, `binc`), the limit triple (`fixeddepth`, `fixednodes`, `movetime`), `ponder`, `multipv`, `score`, `prevscore`, `pipe`, `bestmove` and `log_stdout`. `calvar.tcl` only sets one flag in it. `options.tcl` persists seven of its keys for the Analysis window (`:372–378`, saved `:738–739`) — those seven die with the window, the rest move with `sergame`. **Consequence:** #437 §6 ("delete the old `::uci` engine mode") cannot start before §4, and it is really "port the engine-slot state, then delete".
2. **`sergame` blocks the event loop on `bestmove`:** `vwait ::uci::uciInfo(bestmove$n)` (`sergame.tcl:878`). A port onto `::engine`/`enginecomm` must replace that wait with the reply contract #423 hardened; leaving a `vwait` behind would make the port a rename, not a port.
3. **`analysisWin` must be counted as an unescaped token.** `tcl/utils/win.tcl:865` matches it through the brace-quoted regexp `{\.(fdock)?analysisWin[0-9]+$}`, so a `\.analysisWin` search under-reports by exactly that site.
4. **`tcl/options.tcl` carries 14 references, not the "1–2" the issue's grouped row implies**, and seven of them persist the Analysis window's slot limits (`uciInfo(wtime1|winc1|btime1|binc1|fixeddepth1|fixednodes1|movetime1)`, set at `:372–378`, saved at `:738–739`). `tcl/enginecomm.tcl` (8) and the new `tcl/tools/epd_analysis.tcl` (2) are not in the table at all.
5. **The two helpers #436 kept already exist twice, and the review path uses the namespaced copy.** `tcl/tools/review_annotate.tcl` carries `::reviewannotate::markExercise` (`:235`, documented as *"Port of markExercise (analysis.tcl:536-608)"*), `::reviewannotate::openingTag` (`:394`) and `::reviewannotate::appendAnnotator` (`:445`), and calls them from the review path (`:218`, `:434`, `:1372`). The classics in `analysis.tcl` (`markExercise:649`, `appendAnnotator:1073`) are called only from the legacy annotator (`:947`, `:949`, `:736`, `:739`). So #437 §5's delete is safe **for these three**, and no new shared module is needed — but the two `analysisWin` lines left in `review_annotate.tcl` (`:1278–1279`, toggling `.analysisWin$n.b1.annotate`) are legacy-dialog UI state that must go with the window.
6. **`review_annotate.tcl` may not be dead at all.** It has **zero** `::analysis(` references now and only those two UI lines, but its writer helpers are live for the shipped Review Settings flags. #437 says "if nothing else calls the module, delete the rest and its `annotate_*` tests" — the caller audit, not the reference count, decides that, and the audit is part of phase 5.

## §3a — the trainers, measured on the way through

Review game (`reviewgame.tcl`, 552 lines, engine slot 6) and Calvar (`calvar.tcl`,
486 lines, engine slot 4) are retired: their menu entries, both modules, the
`CalVar` and `ReviewGame` help pages in all 28 help files (English and 27
translations), and 23 translation tags per catalogue (`serbian.tcl` is out of
sync on purpose and was pruned separately).

Tactics is §3b's, and its engine surface is far smaller than its line count
suggests — measured, not counted:

| Call site | What it is |
|---|---|
| `tactics.tcl:278` | `::uci::resetUciInfo 5` — slot 5 belongs to the trainer |
| `tactics.tcl:281` | `::uci::startEngine $engineIdx 5` |
| `tactics.tcl:347` | `::uci::closeUCIengine 5`, in `endTraining` |
| `tactics.tcl:686` | `::uci::sendToEngine 5 $text` — the only writer (`position fen`, `go infinite`, `stop`) |
| `tactics.tcl:717` | `::analysis(multiPV5)` — the only read |

Everything else in those 732 lines is Tk, `sc_*`, and two `after` timers. The
port is therefore four call sites and one `::analysis(...)` key.
`tests/tcl/tactics_trainer.tcl` drives the whole loop — start, one puzzle, a
right and a wrong answer, the timer expiring, stop — with the engine layer
stubbed, so §3b can change the engine layer under a harness that already covers
the behaviour.

## Phase mapping

| #437 phase | Files | Gate |
|---|---|---|
| 2 — EPD | none left: `epd.tcl` is clean and `epd_analysis.tcl` owns the pass | `epd_analysis` stub harness |
| 3 — trainers | `menus.tcl:235,236`, `reviewgame.tcl`, `calvar.tcl`, `tactics.tcl`, help + catalogs | gate + help_keys |
| 4 — `sergame` port | `sergame.tcl` | gate + manual play-test |
| 5 — dead annotate/analysis code | `analysis.tcl`, `review_annotate.tcl`, `finish_game.tcl`, `maint.tcl`, `win.tcl` | gate; `annotate_*` tests deleted with their subject |
| 6 — `::uci` mode | `uci.tcl`, `options.tcl`, new `uci_format.tcl` | gate + the acceptance greps in #437 |
| 7 — docs | `docs/engine-consolidation.md`, `docs/annotate-review-mode.md`, `docs/review-ui.md` | docs only |

## What this inventory does not decide

- Whether the relocated formatters keep the `::uci::` namespace (smallest diff, most confusing name) or move to `::ucifmt::`.
- Whether `uciInfo` survives as one renamed dict shared by the Engine Window and `sergame`, or is replaced by per-connection state owned by `enginecomm`.
- Whether `sergame`'s `vwait` becomes a reply callback or a continuation driven from the event loop.

Each of those is a decision for the phase that touches it, not for this document.

## Reproducing the numbers

```sh
git grep -c '::uci::'  <ref> -- tcl/
git grep -c '::analysis(' <ref> -- tcl/
git grep -c 'analysisWin'  <ref> -- tcl/     # unescaped: win.tcl matches via a pattern
git grep -o '::uci::[A-Za-z0-9_]*' <ref> -- tcl/ | sort | uniq -c | sort -rn
```
