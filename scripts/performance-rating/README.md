# Performance-rating calibration

The scripts that produced the calibration table in
[`docs/performance-rating.md`](../../docs/performance-rating.md). They are not
part of the application: the app ships the table, not the fit.

They need `python-chess` and `numpy`, a Stockfish binary, a built
`scidCommunity` (for its `--headless` JSON-RPC API, `src/api_headless.cpp`) and
a Scid database carrying both players' ratings. The run below is the one the
document's numbers came from: KingBase2018, 500 games with both ratings in
2001–2855 (the database has nothing both-rated below 2000 inside this
selection), at least 40 plies.

```sh
# 1. corpus: 500 games, both ratings 1200-2900, >= 40 plies, seeded, damped
#    proportional allocation over the 100-point rating bands
python3 extract_corpus.py --scid /path/to/scidCommunity --db /path/to/KingBase2018.si4 \
    --count 500 --seed 20261103 --lo 1200 --hi 2900 --min-plies 40 \
    --out data/corpus.json

# 2. the engine pass: one evaluation per position, movetime 150, MultiPV 1,
#    Threads 1 / Hash 16 MB per worker. Checkpoints per game, so a re-run resumes.
python3 engine_pass.py --engine /path/to/stockfish \
    --corpus data/corpus.json --movetime 0.15 --workers 10 --hash 16 \
    --out data/evals.jsonl

# 3. per player-game features. The accuracy figures come from the app's own
#    accuracy.tcl through tclsh (app_accuracy.tcl), not from a port of it.
python3 features.py --evals data/evals.jsonl --corpus data/corpus.json \
    --accuracy-tcl /path/to/scidCommunity/tcl/tools/accuracy.tcl \
    --out data/features.json

# 4. the fit, the player-disjoint folds and the five candidates
python3 fit_calibration.py --features data/features.json \
    --out data/study-150ms.json --label "150 ms"

# 5. the other baselines: the constant predictor, the opponent-quartile table
#    with that constant in it, and the opponent regression the design does not use
python3 diagnostics.py --features data/features.json --out data/diagnostics.json
python3 quartile_baseline.py --features data/features.json \
    --study data/study-150ms.json --out data/quartiles-constant.json
python3 covariate.py --features data/features.json --out data/covariate.json

# 6. the report: every number in it is read from the JSON files, none typed in
python3 report.py --out data/REPORT.md
```

The budget question — how much of the result is the 150 ms — is answered by
re-running the same 100 games at depth 18 and putting both budgets through the
identical folds:

```sh
python3 subsample.py --corpus data/corpus.json --n 100 --out data/subsample-100-ids.txt

python3 engine_pass.py --engine /path/to/stockfish --corpus data/corpus.json \
    --depth 18 --workers 10 --hash 16 --ids data/subsample-100-ids.txt \
    --out data/evals-depth18.jsonl

python3 features.py --evals data/evals-depth18.jsonl --corpus data/corpus.json \
    --accuracy-tcl /path/to/scidCommunity/tcl/tools/accuracy.tcl \
    --ids data/subsample-100-ids.txt --out data/features-depth18.json

python3 fit_calibration.py --features data/features-depth18.json \
    --out data/study-depth18.json --label "depth 18"

# the same 100 games at 150 ms, for the paired comparison
python3 fit_calibration.py --features data/features.json --ids data/subsample-100-ids.txt \
    --out data/study-150ms-100.json --label "150 ms, same 100 games"
```

`fit_calibration.py` prints the held-out MAE, bias and RMSE of ESL per move
against ACPL, Lichess accuracy, the report's accuracy+ACPL curve and the ESL +
decisive-error hybrid, plus the opponent-quartile table and the table it fits.
Its `table` output is what gets pasted into `tcl/tools/perf_rating.tcl` — the
module holds rows, never coefficients, so a re-fit replaces data and nothing
else.

The run's own artefacts (corpus, eval records, features, studies, `REPORT.md`)
belong in `data/` next to the scripts and are not committed: the corpus is a
database extract and the eval records run to hundreds of megabytes.
