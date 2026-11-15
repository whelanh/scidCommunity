#!/usr/bin/env python3
"""Is the estimate biased when the player plays up or down?

    .venv/bin/python tools/quartile_baseline.py --features data/features.json \
        --study data/study-150ms.json --out data/quartiles-constant.json

The study's quartet table shows a large signed bias in the outer opponent-strength
quartiles for *every* candidate. That looks like "the model is biased when you
play up or down", but a constant predictor would show the same thing, because
the player's own rating is not fixed inside an opponent quartile: the field
facing 2000-2235 opposition contains both 2000-rated players and 2800-rated
players playing down.

So this script puts the constant (the training fold's mean rating) in the same
quartiles on the same folds. If a candidate's quartile MAE is no better than
the constant's, the stratum is hard because of the sample, not because the
statistic mis-ranks it. The column that answers the question is the difference.
"""
import argparse
import json
import statistics
import sys

import numpy as np

sys.path.insert(0, __file__.rsplit("/", 1)[0])
import fit_calibration as fc  # noqa: E402


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--features", default="data/features.json")
    ap.add_argument("--study", default="data/study-150ms.json")
    ap.add_argument("--reps", type=int, default=10)
    ap.add_argument("--out", default="data/quartiles-constant.json")
    args = ap.parse_args()

    rows = [r for r in json.load(open(args.features))["rows"] if r["moves"] >= 20]
    study = json.load(open(args.study))

    opps = sorted(r["oppElo"] for r in rows)
    edges = [opps[int(q * len(opps))] for q in (0.25, 0.5, 0.75)]

    def q_of(x):
        for i, e in enumerate(edges):
            if x <= e:
                return i
        return len(edges)

    nq = len(edges) + 1
    const = {qi: [] for qi in range(nq)}
    sign = {qi: [] for qi in range(nq)}
    gap = {qi: [] for qi in range(nq)}
    for i in range(args.reps):
        rng = np.random.default_rng(2000 + i)
        for fold in fc.grouped_folds(rows, rng):
            test_p = {r["player"] for r in fold}
            train = [r for r in rows if r["player"] not in test_p]
            if not train or not fold:
                continue
            cm = statistics.mean(r["elo"] for r in train)
            per = {qi: [] for qi in range(nq)}
            for r in fold:
                per[q_of(r["oppElo"])].append(cm - r["elo"])
            for qi, errs in per.items():
                if errs:
                    const[qi].append(float(np.mean(np.abs(errs))))
                    sign[qi].append(float(np.mean(errs)))

    out = []
    for qi in range(nq):
        q = study["quartiles"][qi]
        cand = {k: v["mae"] for k, v in q.items()
                if k not in ("quartile", "oppEloRange")}
        row = {"quartile": qi + 1, "oppEloRange": q["oppEloRange"],
               "constantMae": float(np.mean(const[qi])),
               "constantSd": float(np.std(const[qi])),
               "constantBias": float(np.mean(sign[qi]))}
        for k, m in cand.items():
            row[k] = {"mae": m, "gain": row["constantMae"] - m}
        out.append(row)

    print(f"{len(rows)} player-games; constant = training-fold mean; "
          f"{args.reps} repeats")
    print(f"{'Q':<3}{'oppElo':<18}{'const MAE':>10}   "
          + "  ".join(f"{k:>18}" for k in ("esl", "acpl", "lichess", "current", "hybrid")))
    for row in out:
        cells = []
        for k in ("esl", "acpl", "lichess", "current", "hybrid"):
            c = row[k]
            cells.append(f"{c['mae']:7.1f} ({c['gain']:+6.1f})")
        print(f"{row['quartile']:<3}{str(row['oppEloRange']):<18}"
              f"{row['constantMae']:10.1f}   " + "  ".join(cells))

    with open(args.out, "w") as f:
        json.dump({"edges": edges, "rows": out}, f, indent=1)
    print(f"wrote {args.out}")


if __name__ == "__main__":
    main()
