# Consolidating the engine UI

The plan agreed in [whelanh/scidCommunity#380](https://github.com/whelanh/scidCommunity/issues/380):
one engine-window widget, one review driver, and one engine preset that carries everything an
engine needs.

This document is the artifact B1 and B2 are reviewed against. It lives in the tree so a row can be
diffed when it changes, rather than edited in a comment fifteen screens down.

## Phases

| Phase | Scope | State |
|---|---|---|
| **A0** | A complete engine preset: binary, args, working directory, the full UCI option set and a `Limits` dict in `engines.dat`; the engine window reads and writes them; Duplicate copies a whole spec, and a rename cannot take another preset's name | merged — `#382`, `#387`, `#390` |
| **A** | `::reviewdriver`: a MultiPV pass on its own engine connection; `Game Review` and `Move Comment` in the engine window; the review settings dialog; `::review::writeMove`; the chart's stored-`[%eval]` seeding | merged — `#385`, `#386`, `#389` |
| **A2** | The pass a caller owns: plan → verdicts → write, so `writeMove` has a caller | merged — `#388` |
| **A3** | The engine window calls `::reviewdriver::run` instead of `start`, so a review's verdicts reach the game | merged — `#393` |
| **B0** | The three trainers (`reviewgame`, `tactics`, `calvar`) leave `::uci`/`::analysis(...)` for `::engine` | after A3 |
| **B1** | `::enginewin::widget {parent id}`; the analysis group becomes a container of 1–4 panes, each detachable | after B0 |
| **B2** | Per-pane mode (Analyze / Train / Review) and a single driving owner | after B1 |
| **C** | Annotate becomes a review mode: NAG, `T`-flag and `.bin`-book writers | after A3, and after the parity fixture |
| **C2** | Retire the classic annotator — its own change, after the parity fixture passes | last |

## Capability matrix

Today's owner and the check counts are read from `github` after `#390` (`960e0cbf`). "Test" is
what runs today; `—` means nothing does, which is the argument for the manual matrix further down.

| Feature | Today's owner | After B1/B2 | Test today |
|---|---|---|---|
| Follow the board / lock a position | `windows/engine.tcl` `::enginewin::changeState`, `stateFollow`/`stateLocked` | the widget, per instance | `—` |
| Start / stop / pause | `::enginewin::start`, `stop`, `toggleStartStop` (the `$btn.startStop` button) | the widget | `—` |
| Add best move | `::enginewin::playBestMove` | the widget | `—` |
| Add all lines | `::enginewin::exportLines` | the widget | `—` |
| MultiPV / Threads / Hash | `::enginewin::changeOption` → `::enginecfg::setOption`, stored in the preset | unchanged (preset-owned) | `engine_limits.tcl` 43, `engine_duplicate.tcl` 63 — the file and list layer, not the buttons |
| Depth / movetime | `::enginewin::applyLimits` → the preset's `Limits` | unchanged (preset-owned) | `engine_limits.tcl` |
| Autorun cadence | `::enginewin_autorun($id)` + `::enginewin::analyzeMainLine` | the widget | `—` |
| Score chart and stored-`[%eval]` seeding | `::enginewin::updateChart`, `seedChart`, `seedLabel` | the widget | `engine_seed.tcl` 55 — seeded markers, the Autorun skip, a manual search at a seeded ply, the nested-variation restore; the `connectEngine`/`sendPosition` resets are structural. `score_seed.tcl` 35 |
| Game Review / Move Comment | `tools/review_ui.tcl` + `tools/review_driver.tcl` | the widget, mode Review | `review_ui.tcl` 188, `review_driver.tcl` 210 — the logic; Tk glue structural except the run's ownership, driven over a stub window |
| **Review verdicts → the game** | `::reviewdriver::run` (merged in #388) calls `::review::writeMove`, and the engine window calls `run` (A3); the label's NAG and the diagram at mistakes/blunders are written beside it (`diagram` setting) | mode Review | `game_review.tcl` 160 covers `writeMove`, `review_driver.tcl` 210 covers `run` end to end — two reviews in a row, the marks replaced rather than stacked, the variations not duplicated, a NAG and a user comment kept, and the window's hand-off to `run` from two engine windows; `review_ui.tcl` 188 covers the window's decision |
| Embedded PGN viewer instance | `::enginewin` `pgnviewer($id)` branch; seeding skips it | the widget keeps the flag | `—` |
| 1–4 panes, one engine each | `tools/analysis.tcl` `.analysisWin1..4`, `analysis(uci$n)` | the analysis group; panes detachable | `—` |
| Per-pane lock | `toggleLockEngine` | the pane | `—` |
| Add move / add variation / add all variations | `makeAnalysisMove`, `addAnalysisVariation`, `addAllVariations` | the pane | `—` |
| Analysis board | `toggleAnalysisBoard` | the pane | `—` |
| Engine info | `toggleEngineInfo` | the pane | `—` |
| Per-pane priority | `setAnalysisPriority` | the pane | `—` |
| Finish Game | `toggleFinishGame`, `autoplayFinishGame` | the pane, mode Train | `—` |
| Training / autoplay, move time | `toggleAutomove`, `automove`, `setAutomoveTime` | the pane, mode Train, one owner | `—`; `toggleAutomove` writes `.analysisWin1`'s button for every pane |
| The opening trainer's engine reply | `windows/tree.tcl` `::tree::doTraining` tests `.analysisWin1`/`.analysisWin2` and `analysis(automove1`/`automove2)`; panes 3 and 4 are never consulted | the owner registry | `—` |
| Classic annotator: all moves / blunders only, White/Black, variations, short annotations, add score, annotator tag, score all moves, mark tactical exercises (writes `??`/`?`, sets the `T` flag, `****D<difficulty>`), batch games, find opening errors | `tools/analysis.tcl` `configAnnotation` + `annotateMode`; `tools/batch_annotate.tcl` | stays until C's parity gate | `—` |
| Book annotation: last book move / out of book | `bookAnnotation` + a `.bin` book | stays until C | `—` |
| `D` diagram NAG on blunders | `analysis.tcl:864`, `batch_annotate.tcl:740`; read by `src/game.cpp` (`NAG_Diagram`, `PGN_STYLE_DIAGRAM`) and `tcl/file/rtf.tcl` (`hasDiagramNag_`) | unchanged through B0–B2; C reproduces it | `—` |
| Review Game / Tactics / Calvar trainers | `reviewgame.tcl`, `tactics.tcl`, `calvar.tcl` on `::uci` | **B0** | `—` |

## B0 — the trainers leave `::uci`

`::uci`/`::analysis(...)` serves the Analysis window and three trainers that have no window.
`::engine`/`enginecomm.tcl` serves the engine windows and the review pass.

If B1 drops `::analysis(...)` while the trainers still read it, the widget either keeps the old
layer alive or the trainers break. So they move first, and B1 can delete `::uci` outright.

**Reuse `::engineNoWin`, do not hand-roll `::engine::connect`.** `tools/enginenowin.tcl` is sourced
at `start.tcl:1123` and gives a trainer the two things a raw connect does not: it runs the launch
with the preset's `Dir` as the working directory, and it sends the preset's `UCIoptions` once
connected. It also keeps `::enginecfg::engConfig_$id` and refuses a second init on the same id.
The review pass did not use it because the pass pins the protocol (`uci` last), which
`initEngine` does not pass; a trainer has no such requirement.

**Engine ids.** Windows and the pass draw from one pool, and `::engine::connect` closes whatever
already holds the id it is given — which is why the pass has `::reviewdriver::reservedId`
(`review_driver.tcl:39`). B0 replaces that reservation with one allocator
(`::engine::nextFreeId` or equivalent) used by the pass, the trainers and the panes, and deletes
`reservedId` when it lands. Trainers take whatever the allocator returns, not three constants.

**MultiPV.** A preset stores only the options that differ from the engine's default, so `MultiPV`
may be absent from a preset that never set it. A trainer that needs more than one line sets it on
its own connection after init, exactly as the pass does — never through
`::enginecfg::setOption`, which persists and restarts the user's search.

**Acceptance**
1. TDD, red first: which id a trainer may take, and the preset → `Go` limits mapping.
2. Manual: the tree-training row, plus a Review Game, a Tactics and a Calvar session that still
   finish and still store their result the same way.
3. The PR says, in as many words, that a user who had tuned `analysis(multiPV…)` now gets the
   preset's value. It is the one behaviour change a user can notice.
4. `grep` shows no `::analysis(...)` and no `sendToEngine` left in the three trainer files; the
   output goes in the PR body.

**Risk.** These are three shipped, user-facing trainers with no harness. B0 is where a regression
would hide, which is why it is its own change with its own manual matrix.

## B2 — the state machine, written before it is written

**Modes, per pane:** `analyze`, `train`, `review`. A pane's mode decides which controls it shows
and which of its buttons may write into the game.

**One driving owner.** At most one pane may write moves into the game:

```
::train::attach {paneId} {mode}   ;# -> true, or false if another pane already owns it
::train::detach {paneId}          ;# -> true if it was the owner
::train::owner {}                 ;# -> paneId, or "" 
::train::ownerMode {}             ;# -> analyze|train|review, or ""
```

Invariants:

1. `owner` is `""` or the id of an open pane; closing that pane detaches it.
2. `attach` on an owned pane returns false and changes nothing — it never steals.
3. A pane whose id is not the owner greys its move-making controls (add move, add variation, add
   all, automove, finish game) and keeps the read-only ones.
4. `::tree::doTraining` asks `::train::owner`/`ownerMode` instead of testing `.analysisWin1` and
   `.analysisWin2` by name, and plays through the owner. The two panes it does test today are
   also the whole of the current gap: panes 3 and 4 never answer the trainer.
5. `toggleAutomove` toggles the button of the pane it was given, not `.analysisWin1`'s.

`attach`/`detach`/`owner` are pure Tcl and must be pinned by tests before any window code uses
them.

## Manual test matrix

Neither window's state machine has a harness, so this runs by hand before B1, and again before
B2. The result of each run goes in that PR's body. "Pass" means identical observable behaviour to
the build before the change.

Rows 9–12 exercise the classic annotator, which B0–B2 do not touch: they are here to prove that,
not to prove the merge. Row 15 is a different path — the AI commentary batch
(`tools/analysis_auto_comment.tcl`) reads its scores from `.engineWin$id.chart.canvas`, so it is a
consumer of the window B1 changes, not a control for the classic pipeline.

| # | Scenario | Pass |
|---|---|---|
| 1 | Four panes, four engines, all analysing | all four update; each stops and locks independently |
| 2 | Lock pane 2, navigate the board | pane 2 holds its position, the others follow |
| 3 | Add move / add variation / add all variations from a pane | main line and variation tree unchanged |
| 4 | Panes 1's board and engine-info toggles | both show and hide without disturbing the search |
| 5 | Raise pane 3's priority | pane 3 takes the CPU share, the others still update |
| 6 | Finish Game from a pane | both sides played to the end, result set on repetition |
| 7 | Automove on pane 2, then on pane 4 | exactly one pane plays; the other greys its move buttons |
| 8 | Tree training asks for an engine move, with automove on pane 3 or 4 as well | the owner answers; no second move. Only panes 1 and 2 are consulted today, so this row is what proves B2's registry |
| 9 | Annotate: all moves, variations, short annotations, add score | NAGs and comments unchanged |
| 10 | Annotate: blunders only | a `D` NAG at each blunder, `T` flag and `****D<n>` for tactical marking |
| 11 | Annotate with `UseBook` and a `.bin` book | last-book-move / out-of-book comments written |
| 12 | Batch annotate and find opening errors | same games selected, same annotations |
| 13 | Autorun the main line, reload the game | chart fills; stored `[%eval]`s seed; seeded plies are skipped |
| 14 | Embedded PGN viewer engine window | its own game and chart; seeding stays off |
| 15 | AI commentary: batch + summary | prose written as before |
| 16 | Game Review on a normal game | labels, `[%eval]` and variations written into the game; the board ends where the user left it |
| 17 | Game Review a second time on the same game | the labels and `[%eval]`s are replaced, not stacked; no variation is duplicated |
| 18 | A move that already carries a NAG and a user comment, then Game Review | the NAG and the user's text survive; the verdict is added |
| 19 | Cancel a review mid-search | nothing is written; the board is where the user left it |

Rows 16–18 are no longer only manual: `tests/tcl/review_driver.tcl` drives
`::reviewdriver::run` to completion against a stub engine and a board that
remembers what was written, and asserts the comment, the `[%eval]`, the
variation set and the cursor after a second run. What remains manual is the
window itself — the button, the status line and the board repaint — which has
no Tk harness. Row 19 is the driver's own guarantee (`::reviewdriver::cancel`
before the write phase) rather than a window behaviour.

**Where a row can stop being manual, it should.** `tests/tcl/auto_comment_dialogs.tcl` runs a real
`wish` under `xvfb-run` in CI; the same pattern reaches the pgnviewer/seeding branch, autorun and
the annotator's NAG writers. A row that moves from manual to harness cannot rot silently. This is
a direction, not a gate.

## What must not be lost

**NAGs, and `D` in particular, are the diagram marker.** HTML and print/colour PGN export emit a
board where a `NAG_Diagram` appears (`src/game.cpp`, `PGN_STYLE_DIAGRAM`); RTF renders one for `D`
and `#` through `hasDiagramNag_` (`tcl/file/rtf.tcl`); blunders-only annotation writes `D` on
purpose (`analysis.tcl:864`, `batch_annotate.tcl:740`); the opening trainer reads NAGs
(`opening.tcl`).

**Tactical exercises are NAG- and flag-based.** `markExercise` writes `??`/`?` and the
`****D<difficulty>` comment, and the batch sets the game's `T` flag (`analysis.tcl:603`) so those
games can be filtered and trained on.

**Book annotation** writes the last-book-move / out-of-book comments from a Scid `.bin` book
(`bookAnnotation`).

B0, B1 and B2 leave all of this where it is. C moves it, and is gated on a fixture: the same game
annotated by the classic pipeline and by the new path must produce the same export artefacts —
RTF with the diagram, PGN NAGs, and a `T`-flag filter that selects the exercise. The fixture also
covers:

- a game **reviewed twice** — the second run replaces labels and `[%eval]`, it does not stack them;
- a move that already carries a NAG or a user's comment — "label + NAG + eval coexisting" is where
  `mergeComment`/`stripReviewTokens` can eat an annotation.

Nothing in the classic pipeline is retired before that fixture passes.

## A second engine process costs twice

Every resource a pass or a trainer hands to its engine is allocated again beside the window's own
engine. A preset set up for a long interactive search (`Threads 64`, `Hash 110000`) put two 107 GB
transposition tables in memory and `systemd-oomd` killed the application at 28 of 90 positions.
`::review::effective` now caps the pass at `MAX_PASS_THREADS` 8 and `MAX_PASS_HASH` 512 MB; a preset
asking for less keeps what it asks for. Anything in B0, B1 or C that starts its own engine follows
the same rule: budget the second process, not the preset, and show the capped values in the UI
rather than clamping silently.
