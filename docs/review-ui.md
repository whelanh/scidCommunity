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

## Review Settings

**Review Settings** opens six rows:

| Row | Setting | Range |
| --- | --- | --- |
| Lines | `mpv` | 1–5 |
| Depth | `depth` | 6–60 |
| Variations to write | `var_lines` | 0–`mpv` (default 1) |
| Variation margin (cp) | `var_cp` | 0–500 |
| Wait for the review depth | `move_comment_wait` | 0–1 |
| Diagram | `diagram` | 0–1 |

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
setter would reject.

The six rows are ordinary options (`::reviewopt(mpv)` and so on, registered
with `options.store`), so they are written to the options file with the rest of
the user's preferences and read back at the next start. A value in a hand-edited
options file is clamped to the same range before it is used: the file must not be
able to decide that a pass searches at depth 0.

**Threads and Hash are not in this dialog.** They are properties of the engine
preset — the whole point of the preset work in #382 — and are set from the
window's own controls. The dialog shows what the pass will take from them,
read-only, under the six rows, as `Threads 8, Hash 256 MB (from engine preset)`.
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

## Files

| File | What is there |
| --- | --- |
| `tcl/tools/game_review.tcl` | `::review` settings, `plan`, `searchPlies`, `mainLineMap`, `playedMove`, `moveCommentPlan`, `writeMove`, `selectLines`, `scoreToNag`, `variationWanted` |
| `tcl/tools/review_driver.tcl` | `::reviewdriver` — the engine pass on connection 20, `run` (plan → verdicts → write), `status`, `cancel` |
| `tcl/tools/review_ui.tcl` | `::reviewui` — button state, the call a press makes, dialog values, the status line |
| `tcl/windows/engine.tcl` | the two buttons, the status line, the settings dialog (guarded glue) |
| `tests/tcl/review_settings_dialog.tcl` | 22 checks under Tk: the dialog builds, has OK/Cancel, stores what is typed, refuses a bad value, the variation box follows `mpv`, and the trace that does it is removed when the dialog closes |
| `tests/tcl/review_ui.tcl` | 188 checks: the call a press makes, the status line, the button states, the dialog round trip, the move-comment depth, the key set |
| `tests/tcl/review_driver.tcl` | 222 checks: the pass against a stub engine, including two reviews of the same game in a row and the engine window's hand-off to it |

## Tests

`tclsh tests/tcl/review_ui.tcl` (also run by the Tcl Tests workflow) pins what a
widget would otherwise have to decide:

- **the call a press makes** — `::reviewdriver::run`, with `-bookEnd`, the one move
  and depth for Move Comment, and a refusal (not an engine opening) when there is
  no game, no engine or no driver;
- **the status line** the driver's own state maps to: a search's count, silence
  for the write phase, a finished run and a cancelled one, and the reason a run
  that failed or was partly refused gives;
- **button state** for every combination the window can be in — no game, no
  engine, last position, a pass running, and a state dict with a key missing;
- **the dialog round trip**: read, change, refuse one field, and check the four
  good fields still landed and the refused one kept its old value, with the
  spin-box ranges checked against what `::review::setValue` accepts;
- **the one-move depth**, from `moveCommentPlan`, for a deep analysis, a shallow
  one, nothing analysed, the wait turned off, and a preset that raises the depth
  the review would use;
- **the key set**: the twelve new strings are present in all 29
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
