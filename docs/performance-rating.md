# The performance rating

`tcl/tools/perf_rating.tcl` turns one game's moves into one number:

```
White performance rating (from this game): ≈2375
Black performance rating (from this game): ≈2275
```

It answers exactly that question — *based on the moves of this game, what rating
does this play suggest?* — and nothing else. It is not a FIDE tournament
performance (`R_opp + dp(score)`), which measures a result against a field; the
two must never be blended, and the outcome-only figure appears in this document
only as a row of scale (below).

**Ratings are not a runtime input.** The estimate is a function of the moves
alone. The report block is byte-identical whether the PGN carries no ratings,
one, or both; `tests/tcl/review_report.tcl` asserts it. Ratings enter in two
places and neither is the running application: this offline calibration, which
needed them as ground truth, and the reader's own arithmetic outside the app.

## The statistic

`E(p)` is `::accuracy::winPercent` on the side to move, divided by 100.

```
d_i  = max(0, E(best at p_i) - E(position after the move played))
ESL  = sum of d_i over the player's own moves      (expected-score points)
```

The fit is on `ESL` per move. It is additive on purpose, and the two alternatives
it rejects are rejected by arithmetic, not taste:

* **Lichess accuracy** pushes the same win%-point gap through
  `103.1668·e^(−0.04354·gap) − 3.1669` and averages the moves with volatility
  weights and a harmonic mean. Forty one-point losses score **95.60** for an
  expected-score cost of **0.40**; thirty-nine one-point losses plus one
  fifty-point loss score **80.39** for a cost of **0.89**. The cost more than
  doubles and the accuracy does not follow it. (Measured with the app's own
  `::accuracy::calculatePairs`; `tests/tcl/perf_rating.tcl` asserts both.)
  Note for the record: the card that specified this feature quoted 93.4 for the
  second game. That is the *unweighted mean of the per-move accuracies* (93.43),
  which `accuracy.tcl` does not compute — its weighted, harmonic figure is 80.39.
  The argument for the statistic is stronger than the card claimed, not weaker.
* **The per-move ratio** `E_after / E_best`. In a decided position `E_best → 0`,
  so `0.05 → 0.03` scores as a 60% collapse when 0.02 of expected score was at
  stake. The test file pins that case: 0.02 given away, not a ratio.

`::perfrating::keptPercent` — `100·ΣE_after / ΣE_best`, a ratio of sums — is the
statistic's own quality check and exists for the calibration. The report does
not print it, and neither does anything else: the block carries the rating and
the accuracy figure under its own name, and no third number derived from the
expected-score statistic. (ACPL is printed too, but it is a pre-existing figure
with its own meaning and is not computed from ESL.)

## Display

The rating is read off the calibration table, clamped at the table's ends and
rounded to the table's own bin width (25). It is never a raw fit output, never
carries a band, and never appears beside a second rating: it replaces the
`estimated Elo` the report printed from accuracy and ACPL, which remains only as
a baseline in this study and as the level the coach's facts name.

## The calibration

Everything below was measured in one run on 2026-11-03. The corpus, the eval
records, the features and the study were each written to disk; the features were
then rebuilt from the eval records and compared field by field (bit-identical)
and the study was re-run from the same features (identical to the last digit).
The study report is `data/REPORT.md` in the run's own workspace; this document
is its summary.

### Corpus

| | |
|---|---|
| Source | `KingBase2018` (Scid database), read through `scidCommunity --headless` |
| Selection | both players rated 1200–2900, at least 40 plies, result 1-0 / 0-1 / draw |
| Games | 500 (1000 player-games; 860 distinct players) |
| Mean rating | 2396, sd 206.7 |
| Range | 2001–2855. The selection holds **no both-rated game under 2000** (every 100-point band from 1200 to 1999 returns zero matches), so the table cannot be fitted below the corpus |
| Results | 169 White wins, 116 Black wins, 215 draws |
| Bands (games taken) | 2000–2099: 45, 2100–2199: 55, 2200–2299: 70, 2300–2399: 82, 2400–2499: 86, 2500–2599: 71, 2600–2699: 48, 2700–2799: 33, 2800–2899: 10 |

Allocation across the bands is damped-proportional (weight `√count`, floor 10),
so the sample is not just the middle of the database. The draw is random inside
each band with a fixed seed (20261103), so the corpus is reproducible.

### Engine pass

| | |
|---|---|
| Engine | Stockfish 19 (`stockfish-linux-x86-64-universal`) |
| Limit | `movetime 150`, no depth cap, MultiPV 1 |
| Threads / Hash | 1 per worker, 16 MB; 10 workers |
| Positions | one evaluation per position, shared by both players (median 84 plies a game) |
| Cost | 500 games in 909 s wall; the depth-18 subsample, 100 games, in 3988 s |

MultiPV 1 is the correct setting for this statistic and not a shortcut: the
statistic needs the primary evaluation at `p_i` and at the child position, which
is exactly what the pass measures. Candidates belong to the verdict layer.

The pass checkpoints per game: `data/evals.jsonl` is appended as games finish
and a re-run skips the ids already present, so a crash resumes instead of
restarting the hour.

This is a **pilot budget**, deliberately cheap. ESL from 150 ms evaluations is
noisier than from depth 18. The depth-18 subsample below is the check on that,
and it comes back negative: the budget is not what limits the estimate.

### Folds and baselines

Player-disjoint: the 860 players are dealt into 5 folds, a player appears in
exactly one test fold, and the whole procedure is repeated 10 times with a
different deal. Every candidate is fitted on the same folds and evaluated on the
same held-out player-games. Out-of-fold predictions are pooled inside a repeat,
then averaged over the 10 repeats.

| Model | MAE | sd | bias | RMSE |
|---|---|---|---|---|
| **ESL per move, isotonic** | **164.3** | 0.49 | −0.0 | 199.5 |
| ACPL, isotonic | 163.0 | 0.46 | +0.0 | 198.0 |
| Lichess accuracy, isotonic | 165.1 | 0.56 | −0.6 | 201.2 |
| `::reviewreport::estimateElo {accuracy acpl}` | 378.2 | 0.00 | −226.8 | 465.3 |
| hybrid: ESL + decisive-error count, isotonic | 164.4 | 0.44 | +0.2 | 199.6 |
| *constant: the training fold's mean rating* | *172.3* | *0.36* | *−0.2* | |

Paired per-repeat differences, ESL minus the other candidate:

| | mean ΔMAE | sd | repeats won |
|---|---|---|---|
| ESL − `estimateElo` | −213.9 | 0.49 | 10/10 |
| ESL − Lichess accuracy | −0.8 | 0.38 | 10/10 |
| ESL − hybrid | −0.1 | 0.28 | 6/10 |
| ESL − ACPL | +1.3 | 0.39 | 0/10 |

**The gate is passed**: the statistic beats the report's own `estimateElo` curve
by 214 Elo of held-out MAE, on identical folds, in every repeat. Three things
have to be said in the same breath:

* Nearly all of that win is the *refit*, not the statistic: the shipped curve is
  a hand-drawn ACPL ladder whose bias is −227 points against this corpus,
  because it is calibrated for a different population. Replacing it was worth
  doing on its own account.
* Against an ACPL-only isotonic fit — the same statistical treatment applied to
  a number the report already computes — ESL is **level and fractionally
  behind** (164.3 against 163.0; ESL wins none of 10 repeats, by about a point).
  At 150 ms, expected-score loss does not separate from plain centipawn loss.
* Against a constant predictor (the training fold's mean rating) the whole gain
  is **7.9 Elo of MAE, 4.6%**. The Pearson correlation of ESL per move with
  rating is −0.287, `r² = 0.082`.

### Stratified by opponent strength

The quartiles are the corpus's own `oppElo` quartiles, identical for every
candidate. The constant column is the reason the table is readable: inside an
opponent band the player's own rating is not fixed, so the constant is just as
"biased when you play up or down". The gain in brackets is the candidate's MAE
advantage over the constant in that stratum.

| Q | oppElo | constant MAE | ESL | ACPL | Lichess acc | `estimateElo` |
|---|---|---|---|---|---|---|
| 1 | 2001–2236 | 260.8 | 235.0 (+25.8) | 231.6 (+29.1) | 237.8 (+23.0) | 369.2 (−108.4) |
| 2 | 2237–2397 | 81.5 | 89.4 (−7.9) | 90.2 (−8.7) | 87.3 (−5.8) | 379.4 (−297.9) |
| 3 | 2398–2551 | 82.8 | 91.3 (−8.5) | 91.3 (−8.5) | 87.1 (−4.3) | 375.5 (−292.7) |
| 4 | 2553–2855 | 261.5 | 241.5 (+20.0) | 238.8 (+22.7) | 248.2 (+13.3) | 388.7 (−127.2) |

The signed bias of ±230 in Q1/Q4 is sample composition — the constant carries
the same or a larger bias there — not a defect of the statistic. What the
statistic cannot do is buy back the player's own rating from a single game, and
it is worse than a constant in the two middle quartiles, where most players are
near the mean.

### What opponent strength would buy, and why it is still not used

One more regression, same folds: ESL per move *plus the opponent's rating* takes
held-out MAE from 164.3 to **34.5** (coefficient on opponent rating 0.976).
KingBase pairs players by rating, so the opponent's number is almost the
player's number, and a moves-only estimate carries all of the error by itself.
That is the design's rule — no opponent rating at runtime — and this is its
measured price. It is also the honest limit of the feature: no per-game move
statistic in this study comes close to the information the design withholds.

### The table

`::perfrating::TABLE`, in the module, is the isotonic fit on all 1000
player-games read at a grid, rounded to 25 and re-monotonised:

| ESL per move | rating |
|---|---|
| 0.0000 | 2725 |
| 0.0025 | 2625 |
| 0.0050 | 2475 |
| 0.0075 | 2475 |
| 0.0100 | 2450 |
| 0.0125 | 2400 |
| 0.0150 | 2375 |
| 0.0200 | 2375 |
| 0.0250 | 2350 |
| 0.0300 | 2275 |
| 0.0400 | 2275 |
| 0.0500 | 2250 |
| 0.0600 | 2100 |

Between rows the lookup interpolates; outside them it clamps, so a game worse
than 0.06 expected-score points a move reads 2100 and a flawless one reads 2725.
The corpus's own interquartile range is 0.0085–0.0225 and its 90th percentile is
0.0277, so most games land between 2350 and 2450 — a handful of the display's
bins, which is the honest width of a single game's evidence.

### What this number is worth

* **MAE 164 Elo for a single game** in an 860-player pool of sd 207 — the
  statistic explains about 8% of the variance in rating. It is a description of
  the play, not a measurement of the player. The report prints it because it is
  a better estimate than the curve it replaces; it prints no confidence figure,
  and the number must not be read as one.
* **The fitted range is 2001–2855.** KingBase2018 has nothing both-rated below
  2000, so the ends are clamped rather than extrapolated.
* **The study and the report count the same moves.** The pass evaluates every
  position; `::perfrating::measuredMoves` counts every ply it judged (a ply with
  no evaluation is not a move for anyone). The fit's ESL is summed over exactly
  those plies, so the module is not reading the table at a shifted x.
* **The scale is tied to the budget.** Deeper evaluations raise both ACPL and
  ESL on the same game (median ACPL 18.9 at 150 ms against 21.9 at depth 18), so
  a table fitted at one budget is not exactly right at another. The table
  carries the budget it was fitted at; a review pass run at another movetime
  moves the estimate by roughly a bin over the central range.
* Book plies, unjudged plies and a side with no measured move are all handled
  and tested; a side with no measured move gets no line at all.

### The depth-18 subsample

The 150 ms budget is the study's main soft spot: cheap evaluations inflate both
centipawn loss and expected-score loss. The same 100 games (drawn in the same
band proportions, `data/subsample-100-ids.txt`) were re-evaluated at `depth 18`
and put through the identical fold procedure, so the two budgets are compared on
the same games, the same players and the same folds:

| Model | 150 ms | depth 18 |
|---|---|---|
| ESL per move, isotonic | 174.9 | 176.7 |
| ACPL, isotonic | 175.9 | 176.4 |
| Lichess accuracy, isotonic | 175.7 | 176.5 |
| `estimateElo` | 387.9 | 462.5 |
| constant (training-fold mean) | 174.8 | 174.8 |

Feature/rating correlation on that subsample: ESL −0.187 at 150 ms and −0.103 at
depth 18; ACPL −0.204 and −0.130.

**Deeper search does not buy accuracy on this task.** Five times the budget
moves the statistic's held-out error by about two points in the wrong direction
and leaves the ranking of the candidates unchanged; on 100 games the candidates
are indistinguishable from a constant at either budget. The weak 150 ms result is
therefore not an artifact of a cheap search: what limits the estimate is the
information in one game. One visible side effect is that the *scale* shifts with
the budget (see above), which is why the table records the budget it came from.

## Reproducing it

`scripts/performance-rating/README.md` has the commands: corpus, engine pass,
features, fit, the depth-18 subsample, the diagnostics and the report.
`fit_calibration.py` prints the table that goes into `tcl/tools/perf_rating.tcl`;
the module holds rows, never coefficients, so a re-fit replaces data and nothing
else. The scripts in that directory are the ones that produced the numbers in
this document.

## Tests

`tests/tcl/perf_rating.tcl` (23 checks) covers the table's shape and monotonicity,
the lookup's interpolation, clamping and bin rounding, the two games' ESL and
accuracy arithmetic, the `0.05 → 0.03` case, the ratio of sums against the mean
of ratios on a set containing a zero-`E_best` move, and the side attribution
across holes and book plies. `tests/tcl/review_report.tcl` covers the block: one
rating line per side, no `estimated Elo` beside it, no band, no expected-score
figure, no kept percentage, and a byte-identical block when the moves carry
ratings.
