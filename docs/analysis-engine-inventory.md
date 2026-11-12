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
translations), and 24 translation tags per catalogue (`serbian.tcl` is out of
sync on purpose and was pruned separately). The 24th is `BatchGameReview`, which
had no reader anywhere in the tree — in Tcl or C++ — and none at the base
revision either, so it was orphan debt the `GameReview*` family carried; it goes
with the family rather than staying as the one dead key nothing names.

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

## §4a — Play versus Engine, measured on the way through

`sergame.tcl` was 1,243 lines with 80 `::uci::` uses, and every one of them was
one of three things: the engine-slot state (`uciInfo`, 68 uses), the old mode's
process control (`startEngine`, `sendToEngine`, `closeUCIengine`,
`sendUCIoptions`, `uciConfig`), or the formatter (`sc_move_add`). What the port
found, in the order it mattered:

| Finding | What it changed |
|---|---|
| `uciInfo(wtime1/winc1/btime1/binc1/fixeddepth1/fixednodes1/movetime1)` are written by Play-vs-Engine's *config dialog* (`:368-374`), not only by the Analysis window | They are the game's clock and limits. The four clock values became `::sergame::wtime/winc/btime/binc` (saved by `options.tcl` like the rest of the game's settings); `depth/nodes/movetime` already had module variables of their own. The Analysis window's seven keys are untouched and still saved, and still die with §5/§6 |
| `::uci::uciInfo` held **both** engines: `score1/pv1/ponder1/pipe1` and `score2/pv2/pipe2`, keyed by slot | Each engine now has a `::engineNoWin` connection (`sergamePlayer`, `sergameCoach`) and its state lives in `::engine::state <id>` (`tcl/enginecomm.tcl`). Two engines thinking at once cannot write each other's score, move, ponder flag or clock, and a connection that dies takes its state with it |
| `::uci::parseline` **discarded** the ponder move (`lassign [split $line] -> InfoBestMove ponder ponder_move`, then dropped both) | `InfoBestMove` now carries `{best_move ponder_move}` (documented in `tcl/enginecomm.tcl`'s protocol block). Every existing client reads `lindex $data 0`, so none of them changed; Play-vs-Engine's ponder mode is the one that needs the second element, and without it that shipped feature would have been silently lost |
| The old mode's `isready` + 5 s `vwaitTimed` per move was really "wait until the engine is free" | `::enginecomm` already serialises messages behind the reply in flight, and a second `Go` stops the first search before it is sent. Both waits are gone: the answer is the connection's reply, and `::sergame::answer` continues the game from it |
| `ponderhit` has no message in the `::enginecomm` protocol (UCI defines no reply to it either) | It goes onto the connection with `::engine::rawsend`, deliberately outside the reply queue: the pending `Go`'s `bestmove` is what it must not disturb |
| A ponder search that finishes before the player moves would deliver its answer during the player's turn | The old code would have blocked on `ponderhit` for an answer nobody would send. `answer` now plays a move only while it is the engine's turn, and `ponderhit` is only sent while a search is actually in flight |
| `score$n` was turned for White by the board's side at *parse* time | It is turned by the position the search was asked about (`st $n fen`), which is the same value in the normal flow and the right one when a line arrives late |
| The config dialog's "..." button opened the legacy UCI options window (`::uci::uciConfig`) | It opens Configure Engines (`::enginelist::choose`) — the dialog every other preset is edited in, and the one that survives §6. Named in the PR body as a change the user can see |
| `formatPv`, `formatPvAfterMoves`, `sc_move_add` are the "relocate" row of the table above, and Play-vs-Engine needs two of them | They now live in `tcl/tools/uci_format.tcl` (`::ucifmt::`), with one-line wrappers left in `uci.tcl` so every old caller keeps working. §6 repoints those callers and deletes the wrappers instead of moving the code |

`tests/tcl/sergame_engine.tcl` drives the port with `::enginecomm` running for
real over a socket pair and a fake engine on the far end: a `go` answered by a
reply, a search replaced by a second `go`, a cancel before the reply, an engine
that dies mid-search, the coach on its own connection, and the exact `go` line
the game's clock produces.

## Phase mapping

| #437 phase | Files | Gate |
|---|---|---|
| 2 — EPD | none left: `epd.tcl` is clean and `epd_analysis.tcl` owns the pass | `epd_analysis` stub harness |
| 3 — trainers | `menus.tcl:235,236`, `reviewgame.tcl`, `calvar.tcl`, `tactics.tcl`, help + catalogs | gate + help_keys |
| 4 — `sergame` port | `sergame.tcl`, new `uci_format.tcl`, `enginecomm.tcl` (per-connection state) | gate + manual play-test |
| 5 — dead annotate/analysis code | `analysis.tcl`, `review_annotate.tcl`, `finish_game.tcl`, `maint.tcl`, `win.tcl` | gate; `annotate_*` tests deleted with their subject |
| 6 — `::uci` mode | `uci.tcl`, `options.tcl`, new `uci_format.tcl` | gate + the acceptance greps in #437 |
| 7 — docs | `docs/engine-consolidation.md`, `docs/annotate-review-mode.md`, `docs/review-ui.md` | docs only |

## What this inventory does not decide

- ~~Whether the relocated formatters keep the `::uci::` namespace (smallest diff, most confusing name) or move to `::ucifmt::`.~~ **Decided (Hugh, 2026-11-11):** `::ucifmt::`, in a new `tcl/tools/uci_format.tcl`. §4a created it with `sc_move_add`, `formatPv` and `formatPvAfterMoves`, and left one-line wrappers in `uci.tcl`; §6 repoints the remaining callers and deletes the wrappers.
- ~~Whether `uciInfo` survives as one renamed dict shared by the Engine Window and `sergame`, or is replaced by per-connection state owned by `enginecomm`.~~ **Decided (Hugh, 2026-11-11):** per-connection state owned by `enginecomm` (`::engine::state` / `::engine::setState`), keyed by the connection's id. `::uci::uciInfo` does not survive as a renamed dict.
- ~~Whether `sergame`'s `vwait` becomes a reply callback or a continuation driven from the event loop.~~ **Decided in the port (§4a):** the reply callback continues the game (`::sergame::answer`), and the module has no wait of any kind.

## Deltas measured while landing the phases

The table above is the measurement at `97efd988`. Where a phase moved a file, the row is stale; these are the measured replacements, so §6 does not have to re-derive them.

- **§3b — the tactics trainer, ported onto `::engineNoWin`.** `tcl/tools/tactics.tcl` (961 lines) now has **1** `::uci::` reference — `::uci::formatPv` at `tactics.tcl:510`, the relocated formatter §6 renames — and **0** `::analysis(`. The four `startEngine`/`sendToEngine`/`resetUciInfo`/`closeUCIengine` sites are gone: the trainer opens one connection under the literal id `tacticsTrainer`, sends the preset's options through `::engineNoWin::initEngine`, then asks for `MultiPV 1` on that connection, and reads the line out of `::enginecomm`'s `InfoPV` replies instead of the shared array. Two consequences for the later phases: `epdAnalysis` and `tacticsTrainer` are ids in the same flat `::engconn(...)` namespace (§4's per-connection state must not collide with them), and the trainer's `vwait` is on its own timer flag, not on an engine reply, so §6 can delete the reply machinery without touching it.

## Reproducing the numbers

```sh
git grep -c '::uci::'  <ref> -- tcl/
git grep -c '::analysis(' <ref> -- tcl/
git grep -c 'analysisWin'  <ref> -- tcl/     # unescaped: win.tcl matches via a pattern
git grep -o '::uci::[A-Za-z0-9_]*' <ref> -- tcl/ | sort | uniq -c | sort -rn
```
