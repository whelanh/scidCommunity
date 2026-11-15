# Consolidating the engine UI — a historical note

> **Status: historical (2026-11-14).** This document was the artifact the
> engine-consolidation plan was reviewed against —
> [whelanh/scidCommunity#380](https://github.com/whelanh/scidCommunity/issues/380),
> one engine-window widget, one review driver, one engine preset. It is kept as
> the record of a plan that was **partly built and then overtaken**, not as a
> description of the tree. Nothing in it is a plan of work: the phases below are
> closed, and the windows it wanted are not in the build.
>
> Two issues decided the end state. [#436](https://github.com/whelanh/scidCommunity/issues/436)
> retired the Analysis window instead of building the B1/B2 analysis-group
> widget. [#437](https://github.com/whelanh/scidCommunity/issues/437) then deleted
> the substrate that window stood on: `tcl/tools/analysis.tcl`, the `::uci` pipe
> engine mode in `tcl/tools/uci.tcl`, `tcl/tools/wbdetect.tcl`, and the
> `::analysis(...)` array. A0–A4 shipped and are in the build. B0, B1, B2 and C2
> were superseded; C shipped as Review Settings.
>
> Where this note cites a test count it is the count **at the time**, not
> today's; `docs/review-ui.md` carries the current table.

## The shape it had

At `97efd988` — after #436 closed the Analysis window's doors — the tree ran
**two engine substrates side by side**, inherited from Scid and joined by this
project:

- `tcl/enginecomm.tcl` + `tcl/windows/engine.tcl`: the modern one. A connection
  is a command (socket or pipe) that `::engine::connect` owns, messages go
  through `::engine::send` (`tcl/enginecomm.tcl:231`), a protocol handler per
  engine family is installed by `::engine::handshake_`
  (`tcl/enginecomm.tcl:371`), and `::engine::reply` (`:548`) is where the engine's
  answer arrives. This is what the Engine Window, the review pass and Play
  versus Engine use.
- the 2007 UCI pipe mode in `tcl/tools/uci.tcl`: `startEngine` opened
  `| command` as a read/write channel, `sendToEngine` wrote a line to it, a
  `fileevent` reader parsed `info`/`bestmove` into a **shared array**
  `::uci::uciInfo(slot,key)`, and callers waited on that array with `vwait`.
  The Analysis window and three trainers (Review game, Tactics, Calvar) and
  Play versus Engine all rode it. `wbdetect.tcl` existed only to guess which
  WinBoard engines had an `analyze` mode worth using as analysis engines.

The B0/B1/B2 plan wanted to finish that: move the trainers off `::uci`, then
replace the 1–4 panes of the Analysis Engine with instances of the Engine Window
widget whose mode (Analyze / Train / Review) decides what a pane may write.

## What A0–A4 shipped

| Phase | Scope | Landed as |
|---|---|---|
| **A0** | A complete engine preset: binary, args, working directory, the full UCI option set and a `Limits` dict in `engines.dat`; the engine window reads and writes them; Duplicate copies a whole spec, and a rename cannot take another preset's name | #382, #387, #390 |
| **A** | `::reviewdriver`: a MultiPV pass on its own engine connection; `Game Review` and `Move Comment` in the engine window; the review settings dialog; `::review::writeMove`; the chart's stored-`[%eval]` seeding | #385, #386, #389 |
| **A2** | The pass a caller owns: plan → verdicts → write, so `writeMove` has a caller | #388 |
| **A3** | The engine window calls `::reviewdriver::run` instead of `start`, so a review's verdicts reach the game | #393 |
| **A4** | The review progress pane: a docked pane of the app (not a window) fed a FEN and nothing else, a header composed once per run, a determinate bar from `::reviewui::passFraction`, and Finish Game collecting on a pure board then committing once. Runs that publish into it: Game Review, Move Comment, annotate (single and batch), rapid annotate, Finish Game | #422 item 3 |
| **C** | Annotate becomes a review mode: NAG, `T`-flag and `.bin`-book writers, with its options in Review Settings | #436 item 2 |

## Why the consolidation became a retirement

The plan assumed the Analysis window would be rebuilt on the new substrate. It
was retired instead, for reasons that were already visible in A0–A4:

1. **The window was a second copy of the Engine Window.** Four panes, four
   engines, per-pane lock, add-a-variation, a board, engine info, priority — the
   Engine Window had grown the same features one at a time, and A0–A4 gave it the
   review pass as well. B1 would have been a rewrite of a feature that already
   worked somewhere else.
2. **Its user-facing value did not justify a second substrate.** The features
   people actually used from it — analysis of a position, a coach line, Finish
   Game, annotation — were reachable from the Engine Window, Game Review and
   Batch annotate.
3. **Its substrate was the expensive part.** The shared `::uci::uciInfo` array
   meant two engines could write each other's score, a window's state outlived
   its window, and every caller had to know which slot it owned. The port
   (#437 §4) measured this: `sergame.tcl` had 80 `::uci::` references and every
   one of them was either the shared array or the pipe. Per-connection state
   (`::engine::state`, `tcl/enginecomm.tcl:273`) replaced it, and two engines
   thinking at once can no longer touch each other.
4. **Polling and blocking had to go anyway.** Play versus Engine blocked the
   event loop on `vwait ::uci::uciInfo(bestmove…)`. The reply contract means the
   answer is a callback, not a wait (`::sergame::answer`), and each caller reads
   its own connection. Keeping the window would have meant keeping a second,
   blocking way to talk to an engine alive.
5. **Headless engines are now a requirement.** The EPD pass
   (`tcl/tools/epd_analysis.tcl:1`) and the Tactics trainer own a private
   `::engineNoWin` connection and no Tk at all, which is what makes them
   stub-testable in `tclsh`. The pipe mode had no such shape: its state was a
   global array that only a window could own.

So #437's §5 deleted the Analysis window's module and the legacy annotator, and
its §6 deleted the pipe mode, the engine-options dialog, the `wbdetect` guesser
and the `::analysis(...)` array. **The `::uci` namespace itself was not deleted:**
`sendOptions`, `sendNewGame`, `sendGo` and `parseline` (`tcl/enginecomm.tcl:595`,
`:630`, `:669`, `:820`) are the UCI protocol handler the app still speaks, and they
stay. What died is the pipe *mode* and its formatting wrappers, whose only
implementation is now `tcl/tools/uci_format.tcl` (`::ucifmt::`).

## The scid lineage

This tree's engine layer is Scid's, and the parts that were deleted here are
still in the sibling that shares that lineage. That departure is recorded here
rather than only in the diff. The references below are to
**benini/scid (Scid vs. PC) at `fc26337`**, the pinned commit of the reference
corpus in `docs/REFERENCE_CODING.md`; paths are that repository's.

**What `analysis.tcl` was.** `tcl/tools/analysis.tcl` in Scid vs. PC carries
`Copyright (C) 1999-2003 Shane Hudson` and `Copyright (C) 2007 Pascal Georges`
(`tcl/tools/analysis.tcl:3-5`) and is the Analysis window itself: the window
builder is `makeAnalysisWin` (`:1700`), the pane's controls are built there, and
the passes drive engines in a **loop that waits on the shared array** —
`vwait analysis(waitForReadyOk$current_engine)` (`:2418`) and
`vwait analysis(waitForBestMove$current_engine)` (`:2425`), with the `analysis`
array declared at the top of the file (`:12`, `set analysis(logMax) 5000`). Our
`analysis.tcl` was that file, ported forward; #436 removed its doors, #437 §5
deleted the module.

**What the `uci.tcl` pipe mode was.** `tcl/tools/uci.tcl:1-6` — *"Copyright (C)
2007 Pascal Georges … add UCI engine support"* — is the pipe mode entire:
`namespace eval uci` holding `uciOptions`/`optList`/`check`/`infoToken`/
`optionToken`/`optionImportant`/`optionToKeep` and `array set uciInfo {}`
(`:8-24`), `startEngine` (`:716`) which spawns
`open "| [list $analysisCommand] $analysisArgs" "r+"` (`:737`),
`resetUciInfo` / `sendToEngine` (`:28`, `:765`), and `closeUCIengine` (`:802`).
§5 deleted everything in it that the Analysis window was the only caller of, and
§6 deleted the file, which by then held nothing but three one-line wrappers
around `::ucifmt::`.

**What `wbdetect.tcl` was.** `tcl/tools/wbdetect.tcl:1-4` — Shane Hudson
1999-2002, Pascal Georges 2006-2007 — with one proc, `detectWBEngine` (`:21`),
whose job was to recognise, by a line of an engine's output, WinBoard engines
that have an `analyze` mode but do not say so in their `feature` line. It wrote
into the same `analysis` array (`global analysis`, `:23`). Our copy survived
until #437 §5, by then with no caller: its 22 `logEngineNote` calls died with the
Analysis window.

**How Scid vs. PC kept the design.** It still runs both substrates side by side.
`tcl/windows/engine.tcl` is on the modern layer (`::engine::connect`), and
`tcl/enginecomm.tcl` is present and sourced (`tcl/start.tcl:747`) — but the
Analysis window and Play versus Engine are still on the 2007 pipe:
`tcl/tools/analysis.tcl` has 54 `startEngine`/`sendToEngine`/`uciInfo`
references and **zero** `::engine::` ones, and the same is true of its
`tcl/tools/sergame.tcl` (52 legacy references). Both modules are sourced
directly as legacy files (`tcl/start.tcl:720-721`, and `tools/wbdetect.tcl` at
`:782`). That is the design this tree left: one substrate, and every engine
caller on it.

**Why this tree left it.** Not because the pipe is wrong — it is what Scid has
always done — but because the requirements diverged. Play versus Engine had to
stop blocking the event loop (§4: `vwait` → reply callback); EPD and the trainers
had to run without Tk (§3b, `tcl/tools/epd_analysis.tcl:1-12`); the review pass
had to own its own connection and its own per-slot state so it could not disturb
what the user was watching (§4a: per-connection `::engine::state`,
`tcl/enginecomm.tcl:273`). A shared array with a slot per window cannot give any
of those three. The alternative to deleting the pipe would have been porting the
Analysis window onto the Engine Window's substrate and keeping a second way to
talk to an engine — the cost B1 was going to pay, and the reason it was not paid.

## Phases

| Phase | Scope | State |
|---|---|---|
| **A0** | A complete engine preset in `engines.dat`; the engine window reads and writes it; Duplicate copies a whole spec | merged — #382, #387, #390 |
| **A** | `::reviewdriver`, Game Review / Move Comment in the engine window, Review Settings, `::review::writeMove`, stored-`[%eval]` seeding | merged — #385, #386, #389 |
| **A2** | plan → verdicts → write, so `writeMove` has a caller | merged — #388 |
| **A3** | the engine window calls `::reviewdriver::run` | merged — #393 |
| **A4** | the review progress pane, fed a FEN and nothing else | merged — #422 item 3 |
| **B0** | the three trainers (`reviewgame`, `tactics`, `calvar`) leave `::uci`/`::analysis(...)` for `::engine` | superseded — Review game and Calvar retired (#437 §3a); Tactics ported to `::engineNoWin` (#437 §3b) |
| **B1** | `::enginewin::widget {parent id}`; the analysis group becomes a container of 1–4 panes, each detachable | never built — #436 retired the Analysis window |
| **B2** | per-pane mode (Analyze / Train / Review) and a single driving owner | never built — #436/#437 |
| **C** | Annotate becomes a review mode: NAG, `T`-flag and `.bin`-book writers | merged; its options live in Review Settings — #436 item 2 |
| **C2** | Retire the classic annotator | superseded — #437 §5 deleted the legacy annotator with the window |

B0's *design* died with the trainers it was written for, but its rule survived
into the ports and is worth keeping: **reuse `::engineNoWin`, do not hand-roll
`::engine::connect`.** `tcl/tools/enginenowin.tcl:12` gives a trainer what a raw
connect does not — it runs the launch with the preset's `Dir` as the working
directory, sends the preset's `UCIoptions` once connected
(`::engineNoWin::initEngineOptions`, `:120`), and refuses a second init on a live
id. The review pass still pins the protocol itself (`uci` last) and so connects
directly; a trainer has no such requirement. Equally, a trainer that needs more
than one line sets `MultiPV` on **its own** connection after init, never through
`::enginecfg::setOption`, which persists and restarts the user's search.

B2's state machine was designed and never written. Its invariants are kept here
as history, because "at most one pane may write into the game" is the question
the Engine Window's own lock/pause/review state answers today:

```
::train::attach {paneId} {mode}   ;# -> true, or false if another pane already owns it
::train::detach {paneId}          ;# -> true if it was the owner
::train::owner {}                 ;# -> paneId, or ""
::train::ownerMode {}             ;# -> analyze|train|review, or ""
```

1. `owner` is `""` or the id of an open pane; closing that pane detaches it.
2. `attach` on an owned pane returns false and changes nothing — it never steals.
3. A pane whose id is not the owner greys its move-making controls and keeps the
   read-only ones.
4. `::tree::doTraining` never consults an analysis window: training is the tree's
   statistical reply, and Play from here lives in the engine window that owns its
   engine.
5. `toggleAutomove` toggles the button of the pane it was given, not `.analysisWin1`'s.

## Capability matrix — the pre-retirement snapshot

Measured at `97efd988`. Every row naming `.analysisWin`, per-pane analysis, the
classic Annotate dialog or a `::uci` slot describes a state that no longer
exists; the rows are kept so the retirement can be diffed. "Test" is what ran
then; `—` means nothing did. The counts are the ones quoted when the plan was
written, not today's, and three of the harnesses named below (`annotate_dialog`,
`annotate_run`, `annotate_parity`) were deleted in #437 §5 with their subject.
Today's table is in `docs/review-ui.md`.

| Feature | Owner then | Test then |
|---|---|---|
| Follow the board / lock a position | `windows/engine.tcl` `::enginewin::changeState` | `—` |
| Start / stop / pause | `::enginewin::start`, `stop`, `toggleStartStop` | `—` |
| Add best move / all lines | `::enginewin::playBestMove`, `exportLines` | `—` |
| MultiPV / Threads / Hash | `::enginewin::changeOption` → `::enginecfg::setOption` | `engine_limits.tcl 43` — the file and list layer, not the buttons |
| Depth / movetime | `::enginewin::applyLimits` → the preset's `Limits` | `engine_limits.tcl` |
| Autorun cadence | `::enginewin_autorun($id)`, `::enginewin::analyzeMainLine` | `—` |
| Score chart and stored-`[%eval]` seeding | `::enginewin::updateChart`, `seedChart` | `engine_seed.tcl 55`, `score_seed.tcl 35` |
| Game Review / Move Comment | `tools/review_ui.tcl` + `tools/review_driver.tcl` | `review_ui.tcl 188`, `review_driver.tcl 222` |
| Review verdicts → the game | `::reviewdriver::run` → `::review::writeMove` | `game_review.tcl 183`, `review_driver.tcl 222`, `review_ui.tcl 188` |
| Brilliant/Great second opinion | `::reviewverify` behind `::reviewdriver::verified` | `review_verify.tcl 66`, `review_verify_engine.tcl 56` |
| Embedded PGN viewer instance | `::enginewin`'s `pgnviewer($id)` branch | `—` |
| 1–4 panes, one engine each | `makeAnalysisWin`, `::analysis(name$n)` | `—` — retired with the window (#436) |
| Per-pane lock | `toggleLockEngine` | `—` |
| Add move / variation / all variations | `makeAnalysisMove`, `addAnalysisVariation`, `addAllVariations` | `—` |
| Analysis board / engine info | `toggleAnalysisBoard`, `toggleEngineInfo` | `—` |
| Per-pane priority | `setAnalysisPriority` | `—` |
| Finish Game | `::finishgame::start` in the engine window (the pane's `startPane` path came off) | `finish_game.tcl 39`, `finish_game_dialog.tcl 18` |
| Training / autoplay, move time | the classic autoplay button and `toggleAutomove`/`automove`/`setAutomoveTime` | `—` — the button and its menu entry were retired in #437 §5 |
| The opening trainer's reply | `windows/tree.tcl` `::tree::doTraining` uses `sc_filter treestats` only | `—` |
| Play from here | `::enginewin::playToggle`, `playPosition`, `playInfo`, `playCheck` | `review_driver.tcl` — the successor, limit and state-machine checks |
| Classic annotator (all moves / blunders only, sides, variations, short annotations, add score, annotator tag, mark tactical exercises, find opening errors) | retired (#436 removed its door, #437 §5 its code) | `—`; its two surviving marks are Review Settings', and `review_marks.tcl 54` pins them |
| Annotate as a review pass (one game, a range, opening errors) | retired with the Analysis window (#436 item 3); Game Review and Batch annotate are the live paths | `annotate_dialog.tcl 56`, `annotate_run.tcl 80`, `annotate_parity.tcl 45` — all deleted in #437 §5 |
| Batch annotate (Game List) | `tools/batch_annotate.tcl`; each finished game is written by `::reviewdriver::writeResults` with Review Settings | `batch_annotate.tcl 24` — the MultiPV parser and the shared-writer call; the loop is manual |
| Book annotation: last book move / out of book | retired — the classic writer went with the legacy annotator in #437 §5 and nothing writes those comments now | `—` |
| `D` diagram NAG on blunders | the review writer (`::reviewdriver` / `::review::writeMove`); read by `src/game.cpp` (`NAG_Diagram`, `PGN_STYLE_DIAGRAM`) and `tcl/file/rtf.tcl` (`hasDiagramNag_`) | `—` — the exporter side is structural |
| Review Game / Tactics / Calvar trainers | `reviewgame.tcl`, `tactics.tcl`, `calvar.tcl`, all on `::uci` | Review game and Calvar retired (§3a); Tactics ported (§3b) — `tactics_trainer.tcl` |

## Manual test matrix — never run as written

This was the hand-test plan for B1/B2, and it is here only so that a future
reader can see what was going to be verified. Rows 1–8 and 9–12b describe the
four-pane analysis group and the classic annotator, neither of which exists.

| # | Scenario | What it was for |
|---|---|---|
| 1 | Four panes, four engines, all analysing | per-pane independence |
| 2 | Lock pane 2, navigate the board | per-pane lock |
| 3 | Add move / variation / all variations from a pane | the single-owner rule |
| 4 | Pane 1's board and engine-info toggles | pane-local state |
| 5 | Raise pane 3's priority | per-pane priority |
| 6 | Finish Game from a pane | the pane's own pass |
| 7 | Automove on pane 2, then pane 4 | exactly one pane plays |
| 8 | Tree training with Play from here on | the tree does not ask an engine |
| 9–11 | Annotate: all moves, variations; blunders only; with a `.bin` book | classic writer parity |
| 12 | Batch annotate | the share-writer path |
| 12b | Find opening errors | the classic behaviour |
| 13 | Autorun the main line, reload the game | chart seeding |
| 14 | Embedded PGN viewer engine window | its own game and chart |
| 15 | AI commentary: batch + summary | prose from the chart |
| 16–19 | Game Review, twice; a move with a NAG and a comment; Cancel mid-search | the review writer (now `review_driver.tcl`, harnessed) |
| 20–21 | Verifier engine on/off, and a deleted verifier preset | `::reviewverify` |

Rows 16–18 stopped being manual in A: `tests/tcl/review_driver.tcl` drives
`::reviewdriver::run` to completion against a stub engine and a board that
remembers what was written. Row 19 is the driver's own guarantee
(`::reviewdriver::cancel` before the write phase). The rows that remain manual
are the ones a Tk harness or a stub cannot see: a real preset handshake, a real
ponder hit, the config dialog's widgets, and the text on screen — which is why
every phase that touched them carried a hand-run play-test in its PR body.

**Where a row can stop being manual, it should.** `tests/tcl/review_settings_dialog.tcl`
and `tests/tcl/auto_comment_dialogs.tcl` run a real `wish` under `xvfb-run` in
CI. The Review Settings one exists because its proc stopped compiling part-way:
the rows appeared, the OK and Cancel buttons never did, and nothing could be
applied. A tclsh harness cannot see that; building the window can.

## What must not be lost

**NAGs, and `D` in particular, are the diagram marker.** HTML and print/colour
PGN export emit a board where a `NAG_Diagram` appears (`src/game.cpp`,
`PGN_STYLE_DIAGRAM`); RTF renders one for `D` and `#` through `hasDiagramNag_`
(`tcl/file/rtf.tcl`); the review writer puts `D` on a blunder; the opening
trainer reads NAGs (`opening.tcl`).

**Tactical exercises are NAG- and flag-based.** `::reviewannotate::writeTactical`
(`tcl/tools/review_annotate.tcl:139`) sets the game's `T` flag and writes the
`****D<difficulty>` comment, and
`::reviewannotate::openingMark` (`:236`) writes the `opBlunder` entry of the
Annotator tag. Both are reached only from `::reviewdriver::writeResults`, behind
`info commands` guards (`tcl/tools/review_driver.tcl:1425`, `:1469`), which is
what Review Settings' **Mark tactical exercises** and **Find opening errors**
switch on. Neither Batch annotate nor Rapid annotate has a switch of its own:
they are consumers of the review writer, so their games carry labels,
`[%eval]`, the label's NAG, the assessment, `D`, and (when the settings ask)
those two marks.

**Book annotation is retired.** The classic writer's "Out of book …" / "Last book
move" comments are written by nothing now: the keys are gone from the catalogues
and the writer went with the legacy annotator in #437 §5.

The classic annotator that once wrote all of this is deleted; the `T` flag and the
`****D` exercise comment and the opening tag above are its surviving behaviour, and
`tests/tcl/review_marks.tcl` pins them.

## A second engine process costs twice

Every resource a pass or a trainer hands to its engine is allocated again beside
the window's own engine. A preset set up for a long interactive search
(`Threads 64`, `Hash 110000`) put two 107 GB transposition tables in memory and
`systemd-oomd` killed the application at 28 of 90 positions. `::review::effective`
now caps the pass at `MAX_PASS_THREADS` 8 and `MAX_PASS_HASH` 512 MB; a preset
asking for less keeps what it asks for. Anything that starts its own engine
follows the same rule: budget the second process, not the preset, and show the
capped values in the UI rather than clamping silently.
