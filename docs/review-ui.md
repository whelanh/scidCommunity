# The engine window's review buttons

The engine window used to carry one **Game Comment** button that opened the
batch annotator. It now carries two buttons over one engine pass, plus a small
settings dialog. The pass itself is `::reviewdriver` (`tcl/tools/review_driver.tcl`),
the decisions behind the buttons are `::reviewui` (`tcl/tools/review_ui.tcl`),
and a review writes into the open game: `::reviewdriver::run` searches the
positions, turns the replies into verdicts and calls `::review::writeMove`, so the
moves come back labelled with `[%eval]` and variations.

```
[Game Review]  [Move Comment]  [Review Settings]  [Cancel]   Reviewing position 3 of 42
```

Both buttons are disabled unless there is a game with moves and an engine; Move
Comment additionally needs a move after the current position, and both are
disabled while a pass runs, which is what Cancel is for.

## Game Review — the whole main line

The Game List's **Batch annotate** uses this same writer over its parallel
engine pool, with these settings, so a batch of games gets what pressing Game
Review on each would have written. Its dialog only chooses the engine and the
number of instances. **Rapid annotate** (Ctrl+Shift+A) uses the writer too, from
the best line the score graph has already collected.

Press **Game Review** and the pass searches every position of the main line at
the review's depth, showing `Reviewing position n of m` in the button bar, and
then writes the verdicts into the game: a label and a `[%eval]` on each move's
comment, the NAG the label implies (`??`, `?`, `?!`, `!`, `!!`, or none for
best/excellent/good/book), a position assessment from the same score on the
moves the review marks (`=`, `+=`, `+/-`, `+-`, `+--` and the Black half `=+`,
`-/+`, `-+`, `--+`), a `D` diagram marker on the move before each mistake and
blunder when the Diagram setting is on (a verdict on the first move has no move
before it, so no diagram), and at each mistake, blunder and missed win the
engine's preferred move as a variation, up to `var_lines` of them. A best,
excellent or good move gets no variation: the only line left to show would be
the second-best move, which is not an improvement. Running it again replaces the
review's own marks — `writeMove` strips its comment tokens, and the NAG matching
the previous label and its diagram are replaced — while the user's prose and any
mark the user put there are left alone (Scid keeps one move mark per move, so a
move that already carries one keeps it and the review's label goes without). The
one case that cannot be told apart is a user mark that is the *same symbol* the
label implies - `??` on a move the review also calls a blunder. It is then
treated as the review's mark and replaced on a later run. The position
assessment is the review's own slot and comes only with a mark: on a move the
review marks, its assessment is replaced by the one the current score implies,
including one the classic annotator or the user put there, because it has to
agree with the `[%eval]` beside it. A quiet move gets no assessment, and any
assessment already on it is taken off, so a first and a second pass agree and the
symbols point at the moves worth looking at. The same holds for a
`D` on the move before a mistake or blunder: it is treated as the review's
whether or not the review wrote it, because a NAG carries no owner.
The board is back where the user left it when the pass ends.

The positions come from `::reviewdriver::planPositions` over the snapshot
`::review::mainLineMap` takes of the line, so:

- the board is never moved to build a position, and the pass is unaffected by
  where the user has scrolled to;
- the reference position for each judged move is searched, plus the position
  after it, so a move can still be judged when it is not one of the engine's
  lines;
- a null move appears as a fresh `position … moves` header in that snapshot and
  does not shift the plies after it;
- a position the snapshot cannot name is dropped rather than sent as an empty
  `position`.

**The opening book.** Game Review reads book #1 — the book loaded in the Book
window's first slot, or the book configured as #1 when none is open — and asks
`::review::bookEnd` how many moves of the game followed it. Those moves are
written `[Book]`, with no `[%eval]` and no variation, because there was no search
behind either; the early book positions are not searched either. The move that
leaves the book and everything after it is judged normally.
`::review::skip_book` (default on) turns this off; it has no row in Review
Settings yet. Move Comment ignores the book: it judges the move it was asked
about, whichever opening it belongs to.

Depth and MultiPV are **not** settings of the review dialog: they come from
`::review::effective`, where the engine preset wins `Threads`, `Hash` and a
higher `MultiPV`, and the review's own depth is a floor a shallower preset cannot
lower.

**The time cap** is the other way round. `::review::movetime` (milliseconds, 0 =
none) is a ceiling on one position's search, and `::review::passLimits` decides
which cap a pass runs under: the review's own value when it has one, otherwise
the preset's `Limits.movetime`, otherwise none — never the smaller of the two.
So a preset's cap reaches every pass, and setting one in Review Settings replaces
it rather than tightening or loosening it by arithmetic nobody can predict. Both
numbers go to the engine in one `go depth N movetime M` built by
`::enginelimits::goLimits`, the same helper the engine window's own search uses.

**Under a time cap the depth is not a floor.** The engine stops at whichever
comes first, so a capped pass can finish shallower than `::review::depth`, and a
verdict then rests on a shallower search than the setting promised. That is the
trade the cap asks for, and it is why the cap is off by default.

**One setting, two surfaces.** The Analysis window's annotate dialog shows the
same `::review::movetime` as a time-per-move spinner, in seconds, labelled with
the Review Settings row it writes. Editing either surface changes the other, and
a cap typed there reaches every pass this session runs — the annotate pass, Game
Review and Move Comment — because `::review::passLimits` is the only place the
number is read.

**A bound never displaces a verdict.** A capped search can report a MultiPV slot
as `lowerbound`/`upperbound` at the depth it had reached and only then finish the
line. `::reviewdriver::collect` keeps one line per slot by ranking a `cp`/`mate`
score above a bound before depth, because `::reviewdriver::lineScore` refuses a
bound: the deepest-line rule would have let the bound hold the slot (the exact line
at the same depth is "not deeper") or overwrite an exact line already in hand, and
the ply would have been written with no verdict at all.

The pass runs on its own engine connection (id 20), so it never restarts the
search the user is watching in the analysis pane.

**Cancel** stops the pass: no further position is started, the engine is closed
and nothing is written.

## Move Comment — the current move only

Press **Move Comment** to judge the move played from the current position. It
searches two positions, the one before the move and the one after it, because a
verdict needs both scores: what the move was worth, and what it brought.

When it may start is `::review::moveCommentPlan`:

- with `move_comment_wait` on (the default) the comment has to be the one a
  review would have written, so a shallower analysis is not good enough: the pass
  searches at the review's depth instead. That depth is the *effective* one
  (`::review::effective`): an engine preset with its own deeper limit raises it, so
  a review and a one-move comment of the same position cannot disagree at two
  depths;
- with `move_comment_wait` off, whatever the window's own analysis has already
  reached is good enough and is the depth searched — the depth shown in the bar's
  depth box is the depth used.

The current analysis depth is read from the window's depth map, the one the
Autorun pass fills in. A position that has not been analysed yet has no entry,
and that is "nothing yet", not "depth 0".

The wait is **depth-based even when the pass is capped**: `movetime` bounds the
pass, not what a comment has to reach. A capped comment therefore writes the
verdict the capped search actually produced — shallower than `::review::depth` if
the cap bit — instead of waiting for a depth the cap will never allow.

## Review Settings

**Review Settings** opens nine rows:

| Row | Setting | Range |
| --- | --- | --- |
| Lines | `mpv` | 1–5 |
| Depth | `depth` | 6–60 |
| Time cap (ms) | `movetime` | 0–3600000 (0 = no cap of the review's own) |
| Variations to write | `var_lines` | 0–`mpv` (default 1) |
| Variation margin (cp) | `var_cp` | 0–500 |
| Wait for the review depth | `move_comment_wait` | checkbox |
| Diagram | `diagram` | checkbox |
| Verifier engine | `verifier` | Off or an engine preset |
| Coach prose | `coach` | checkbox |

The time cap sits beside Depth because it bounds the same thing. A value of 0
means the review sets no cap of its own, and the row then shows the preset's, as
`1500 ms (from engine preset)`. The note reads the preset's own
`Limits.movetime` — never `::review::effective`, which keeps a review cap that is
still saved: with 200 ms saved beside a preset's 900, a box at 0 is the edit that
clears the saved cap, so the note says 900. The note disappears the moment a value
of its own is typed.

A variation is written only where the verdict says a better move existed —
`mistake`, `blunder` and `miss` — so the default of 1 gives a game a handful of
lines at exactly the moves the review complains about, not one after every move.
An inaccuracy is deliberately excluded: the gain is small and the lines would
outnumber the interesting ones. The variation is the engine's best line, so it
is the move that should have been played.

A variation already in the game is never removed by a later pass: it cannot be
told from one the user inserted, so the write phase dedupes by first move and
adds what its current verdict wants. A move that was a mistake last run and is
best now therefore keeps the line it had.

`var_cp` is a noise filter, not a quality floor: a line is written when it is
strictly less than `var_cp` centipawns behind the best line, and **0 means no
filter at all**. A margin of 2 therefore keeps only lines less than 2 cp behind
the best — usually none, because MultiPV's alternatives are further behind than
that. To see variations, leave the margin at 0 or set it well above the gap the
engine reports between its lines.

Every row is stored through `::review::setValue`, which owns the rules. A value
it refuses is reported in the dialog and the dialog stays open, so the rest of
the edit is not lost; nothing is clamped behind the user's back. `var_lines` is
capped by `mpv`, so its box follows `mpv` rather than offering a number the
setter would reject. The verifier row is a preset chooser: `Off` is the empty
value, and a named preset must be a different engine from the review's own.

The nine settings are ordinary options (`::reviewopt(mpv)` and so on, registered
with `options.store`), so they are written to the options file with the rest of
the user's preferences and read back at the next start. A value in a hand-edited
options file is clamped to the same range before it is used: the file must not be
able to decide that a pass searches at depth 0, or never gets a search at all.

**The verifier** re-searches only the positions whose move was labelled
Brilliant or Great, with the chosen preset and under the pass's own limits: the
same depth floor and time cap, so a capped review stays capped in its second
opinion. If it disagrees
about the best move, or a Great move does not have a 200 cp gap to the second
line, the move is written as Best. It is off by default and never uses the
review's own engine; a missing or broken verifier leaves the labels as the
review found them.

**Coach prose** runs the configured model (the **Coach settings...** button
beside the switch opens the provider, key and model dialog) over the review’s own
facts: a closing note in the header (`Summary`, `Level`, `Opening`), one
paragraph per phase at the end of that phase, carrying its own move range, accuracy
and ACPL, and a note on the key moments and mistakes. The model is a narrator:
it may name only what the facts list, never a label, a score or a number. It
never changes a label or a score; a failed request is dropped, and a phase whose
prose fails keeps its figures. It is off by default, no request is made when no
provider is configured, and turning it off removes the prose a previous run
wrote.

The labels, the header and the variations are written and redrawn as soon as the
search ends, whether or not the coach is on. Prose is the only part that arrives
later, and the status line counts it (`Coach prose: 3 of 9`) while the pass holds
the window: a review waiting on a model must not look like a review that did
nothing.

The pass also shows a small progress window over the engine window: the same
count with a bar (`Reviewing position 12 of 38`, then `Coach prose: 3 of 9`),
and a Cancel button. It is not modal, it stays up until the whole pass is
finished - including the coach - and closing it only hides it; the pass carries
on and the bar in the engine window still reports.

## What's the threat?

**What's the threat?** is a button in the engine window beside
<a ReviewMoveButton>Move Comment</a>, and the same command is in
<menu>Tools</menu>. The button uses that window's engine preset; the menu entry
uses the first open engine window's preset, or the first configured preset when
no window is open - so the probe works without an engine window as long as an
engine is configured. It asks for the strongest move in the position on the
board and describes it in words. The side to move is the side whose threat it
is: ask after your own move and the answer is the opponent's threat. The probe
is a short search at depth 14 under the review's effective time cap
(`::review::effective`), on a connection of its own - never the review pass and
never the window's analysis - so it does not disturb either.

It reads the same deterministic facts as a move comment: the move in words, the
rule state, what the move wins or threatens, and what it achieves. With a coach
model configured it shows one sentence of prose over those facts; without one,
the deterministic sentence is the answer. **Nothing is written into the game**;
it is a question, not an annotation. The menu item uses the preset of the first
open engine window, or the first configured preset when no window is open.

**Threads and Hash are not in this dialog.** They are properties of the engine
preset — the whole point of the preset work in #382 — and are set from the
window's own controls. The dialog shows what the pass will take from them,
read-only, under the nine rows, as `Threads 8, Hash 256 MB (from engine preset)`.
A second place to set them is a second place to get them wrong, and the window's
own controls already write the preset.

The pass is bounded to at most 8 threads and 512 MB of hash
(`::review::MAX_PASS_THREADS`, `MAX_PASS_HASH`), and a preset asking for less
keeps what it asks for. The reason is that the pass is a *second* engine process:
the preset's reservation is allocated a second time beside the window's own
engine. A preset of Threads 64 / Hash 110000 MB on a 128 GB machine therefore
means two ~107 GB searches, the kernel swaps for its life, and systemd-oomd kills
the whole application when the second engine's table fills in. A batch of
short, fixed-depth searches cannot use a table that size anyway.

## How a review is written, and what Cancel does

`::reviewdriver::run` is plan → search → verdicts → write, and the write phase
runs only after the whole search has finished: `::review::writeMove` is called per
move with the label, the `[%eval]` and the engine's lines, and the game's own move
is never inserted as a variation of itself. The status line is `::reviewdriver`'s
own state read through `::reviewui::statusText` — the window keeps no token of its
own.

**Cancel** stops the pass before the write phase, so nothing is written at all.
That keeps the search and the write apart for the reason they always were:
writing mid-pass re-enters the engine window from an open engine, which makes the
main-line snapshot non-authoritative.

## The review report

`tcl/tools/review_report.tcl` turns a finished pass into the figures a reader
wants first: accuracy per side, ACPL, an estimated Elo, the label tally, the
key moments, and the opening / middlegame / endgame split. The accuracy is the
app's own figure — `::accuracy::calculate`, the same call the engine window's
chart and the PGN viewer's chart make — so one game has one accuracy in this
application instead of two. It is arithmetic over
the pass's own results — no second search and no model — and it writes one block
into the game's header comment, marked `[Game review]` so a second run replaces
the block instead of stacking another under it. It removes only its own lines —
the marker and the indented lines under it — so a note typed below the block
survives the next review. In this slice the module is not
wired to the pass yet: its figures and its boundary rule are tested without a
board or an engine.

**Where the opening ends.** Three signals, and the opening ends at the first one
to fire:

- **Smyrnov's test** — both sides have developed every minor piece (no bishop or
  knight left on c1/f1/b1/g1 or c8/f8/b8/g8; a captured one is not on its square,
  so it counts as developed) *and* both sides' rooks are connected. Connected
  means two rooks sharing a rank or a file with every square strictly between
  them empty, wherever they stand: the back rank is the usual case, not the
  definition. A side with fewer than two rooks has no pair to connect and passes
  that half — otherwise a rook-less game would sit in the opening for ever.
- **mixedness above 150** — how far the two armies have grown into each other
  (ported verbatim from David Crandall's game-review plugin, see
  [`third-party-notices.md`](third-party-notices.md)). It closes a sharp, tangled
  opening early, so a hypermodern line is not held to Smyrnov's strictness.
- **ten or fewer majors-and-minors** — four of the initial fourteen (`n b r q`
  across *both* sides, never per side) have left the board. This is the safety
  net for a game that trades material fast; it fires early, which is why it is
  not the primary signal.

The consequences are deliberate:

- openings now end **later** — typically around moves 12–20, when the back rank
  is resolved — instead of at a fixed ply;
- there is **no ply floor**: a line that is out of the opening on move 5 is out
  on move 4;
- a game that ends before any of the three fires has **no middlegame bucket** and
  gets no middlegame prose. The report does not invent a phase, and it does not
  lend the opening's figures to one that never happened.

The endgame is unchanged: non-pawn material 26 or fewer with the queens off, or
six majors-and-minors in total. A bucket of fewer than four plies is still
suppressed — three plies of "phase" is a rounding artefact, not a phase.

## Files

| File | What is there |
| --- | --- |
| `tcl/tools/game_review.tcl` | `::review` settings, `passLimits`, `plan`, `searchPlies`, `mainLineMap`, `playedMove`, `moveCommentPlan`, `writeMove`, `selectLines`, `scoreToNag`, `variationWanted` |
| `tcl/tools/review_driver.tcl` | `::reviewdriver` — the engine pass on connection 20, `run` (plan → verdicts → write), the `-done` completion hook, `status`, `cancel` |
| `tcl/tools/review_annotate.tcl` | `::reviewannotate` — the annotate dialog's decision, the run (single game and batch chain), Cancel, the progress line, the classic marks |
| `tcl/tools/review_ui.tcl` | `::reviewui` — button state, the call a press makes, dialog values, the time cap's note, the status line |
| `tcl/tools/review_report.tcl` | the deterministic report: CAPS accuracy, ACPL, estimated Elo, key moments, and the phase split with the three-signal opening boundary, plus the `[Game review]` header |
| `tcl/tools/review_coach.tcl` | `::reviewcoach` — the facts a coach may use, the summary/phase/move prompts, and where the prose lands. No model, no network |
| `tcl/tools/review_prose.tcl` | the one-request-at-a-time prose queue: progress, cancel, cache, failed-request dropping |
| `tcl/tools/review_verify.tcl` | the second engine for Brilliant and Great, under the pass's own depth and time cap |
| `tcl/tools/review_threat.tcl` | the "What's the threat?" probe: one short search, facts in words and an optional coach sentence |
| `tcl/windows/engine.tcl` | the two buttons, the status line, the settings dialog (guarded glue) |
| `tcl/tools/analysis.tcl` | the Analysis window's annotate dialog, its OK (`configAnnotateOK`) and the button on every pane |
| `tests/tcl/review_settings_dialog.tcl` | under Tk: the dialog builds, has OK/Cancel, stores what is typed, refuses a bad value, the variation box follows `mpv`, the time cap's row shows the preset's cap and drops the note, and both traces are removed when the dialog closes |
| `tests/tcl/review_ui.tcl` | 213 checks: the call a press makes, the status line, the button states, the dialog round trip, the precedence table through the dialog, the time cap's note, the move-comment depth, the key set |
| `tests/tcl/review_driver.tcl` | 254 checks: the pass against a stub engine, the four Go shapes the precedence table produces, a capped run, two reviews of the same game in a row, the engine window's hand-off to it, and the completion hook |
| `tests/tcl/review_coach.tcl` | 44 checks: the move facts, the game-level facts, the turning move, the phase facts, the prompts and their hard rules, where the prose lands, and that the header block comes off without taking the report's header with it |
| `tests/tcl/review_prose.tcl` | 17 checks: the one-request-at-a-time queue, its progress, cancel, cache and a failed request being dropped |
| `tests/tcl/review_verify.tcl` | 9 checks: the second engine's verdicts and corrections |
| `tests/tcl/review_verify_engine.tcl` | 5 checks: the verifier's Go limits, under the pass's own depth and time cap |
| `tests/tcl/review_threat.tcl` | 34 checks: the facts in words, the engine Go limits, the quiet-move fallback and the model path |
| `tests/tcl/annotate_dialog.tcl` | 80 checks: the dialog's decision (pane preset, book end, tier, the non-UCI refusal), the blunders-only filter, and the Cancel label rule |
| `tests/tcl/annotate_run.tcl` | 77 checks: the plan run against a stub engine, the write, the batch chain, the Cancel escalation and a cancelled run writing nothing |
| `tests/tcl/review_report.tcl` | 79 checks: accuracy as the app's own figure and the parity a phase starting on Black's move needs, Elo, key moments, the endgame rule, the opening boundary — Smyrnov met and half met, rook-less and file/rank connectivity, mixedness at 150 and 161, the material net at ten and eleven, the first-firing signal at 17/21/25, no ply floor — and the block removal, two writes deep |

The coach layer adapts Patzer (MIT) and David Crandall's game-review plugin
(GPL-2.0-or-later); the file-by-file record is in
[`docs/third-party-notices.md`](third-party-notices.md).

## Tests

`tclsh tests/tcl/review_ui.tcl` (also run by the Tcl Tests workflow) pins what a
widget would otherwise have to decide:

- **the call a press makes** — `::reviewdriver::run`, with `-bookEnd`, the one move
  and depth for Move Comment, and a refusal (not an engine opening) when there is
  no game, no engine or no driver;
- **the status line** the driver's own state maps to: a search's count, the
  write phase, the coach's answer count, a finished run and a cancelled one, and
  the reason a run that failed or was partly refused gives;
- **button state** for every combination the window can be in — no game, no
  engine, last position, a pass running, and a state dict with a key missing;
- **the dialog round trip**: read, change, refuse one field, and check the four
  good fields still landed and the refused one kept its old value, with the
  spin-box ranges checked against what `::review::setValue` accepts;
- **the one-move depth**, from `moveCommentPlan`, for a deep analysis, a shallow
  one, nothing analysed, the wait turned off, and a preset that raises the depth
  the review would use;
- **the key set**: the thirteen new strings are present in all 29
  `tcl/lang/*.tcl` files, the file list is read from the tree so a new language
  file fails loudly, and the English text is the text the labels are asserted
  against.

The Tk glue in `tcl/windows/engine.tcl` is guarded rather than tested for its
widgets: a missing widget, a missing engine or a driver that refuses to start is a
no-op with a message, never an exception in the middle of a game.

One part of it is not a widget and is tested: **who owns a run**. One pass exists
at a time, so a second engine window pressing Game Review while a review is
searching is refused by the driver, and that refusal must not disturb the window
that started the pass. `tests/tcl/review_driver.tcl` loads `engine.tcl` over its
fake board with the widget commands stubbed, presses from two windows, and checks
that the refused press leaves the first window's Cancel live and its status line
following the pass. A window claims a run only once `::reviewdriver::run` has
actually started it.

## Related

- `docs/move-labels.md` — the label ladder the comments are built on.
- `docs/engine-presets.md` — the presets that own Threads, Hash and the search
  limits.
- `docs/comment-facts.md` — the deterministic facts a comment may state.
