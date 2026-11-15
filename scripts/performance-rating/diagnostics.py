#!/usr/bin/env python3
"""What the fit is worth beside the things it has to beat.

    python3 tools/diagnostics.py --features data/features.json

Computes, on the same player-disjoint folds the study uses:

  * the correlation of each feature with the player's rating
  * the constant predictor's held-out MAE (the corpus mean/median of the
    training fold) -- a statistic that cannot beat this is not measuring the
    player, it is measuring the population
  * each candidate's MAE after removing its mean signed error, which separates
    "the number is off by a constant" from "the number does not rank players"

The study's stop rule is against `estimateElo`; this is the other baseline, the
one that says whether the winner is worth displaying at all.
"""
import argparse
import json
import statistics
import sys

import numpy as np

sys.path.insert(0, __file__.rsplit("/", 1)[0])
import fit_calibration as fc  # noqa: E402


def ranks(xs):
    order = np.argsort(np.asarray(xs), kind="stable")
    r = np.empty(len(xs))
    r[order] = np.arange(len(xs))
    return r


def pearson(a, b):
    a, b = np.asarray(a, float), np.asarray(b, float)
    return float(np.corrcoef(a, b)[0, 1])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--features", default="data/features.json")
    ap.add_argument("--reps", type=int, default=10)
    ap.add_argument("--ids", default="",
                    help="file of game ids: restrict to an explicit subsample")
    ap.add_argument("--out", default="data/diagnostics.json")
    args = ap.parse_args()

    rows = [r for r in json.load(open(args.features))["rows"] if r["moves"] >= 20]
    if args.ids:
        wanted = {int(x) for x in open(args.ids).read().split()}
        rows = [r for r in rows if r["game"] in wanted]
    elo = [r["elo"] for r in rows]
    print(f"{len(rows)} player-games, {len({r['player'] for r in rows})} players")

    corr = {}
    for k in ("eslPerMove", "acpl", "accuracy", "decisivePerMove"):
        xs = [r[k] for r in rows]
        corr[k] = {"pearson": pearson(xs, elo),
                   "spearman": pearson(ranks(xs), ranks(elo))}
    print("\nfeature vs rating")
    for k, v in corr.items():
        print(f"  {k:16s} pearson {v['pearson']:+.3f}  spearman {v['spearman']:+.3f}")

    # Constant predictor, pooled per repeat exactly as the study pools its
    # candidates: one MAE per repeat, then the mean of those.
    const_mean, const_med, const_bias = [], [], []
    for i in range(args.reps):
        rng = np.random.default_rng(2000 + i)
        errs_mean, errs_med = [], []
        for fold in fc.grouped_folds(rows, rng):
            test_p = {r["player"] for r in fold}
            train = [r for r in rows if r["player"] not in test_p]
            if not train or not fold:
                continue
            cm = statistics.mean([r["elo"] for r in train])
            cd = statistics.median([r["elo"] for r in train])
            errs_mean.extend(cm - r["elo"] for r in fold)
            errs_med.extend(cd - r["elo"] for r in fold)
        const_mean.append(float(np.mean(np.abs(errs_mean))))
        const_med.append(float(np.mean(np.abs(errs_med))))
        const_bias.append(float(np.mean(errs_mean)))
    print(f"\nconstant predictor, same folds, pooled per repeat:")
    print(f"  training mean   MAE {np.mean(const_mean):.2f} (sd {np.std(const_mean):.2f})"
          f"  bias {np.mean(const_bias):+.2f}")
    print(f"  training median MAE {np.mean(const_med):.2f} (sd {np.std(const_med):.2f})")

    # Best possible constant, for reference (no fold discipline -- a ceiling).
    print(f"\nbest fixed constant on the whole corpus:")
    for c in range(2300, 2501, 25):
        print(f"  {c}: MAE {np.mean(np.abs(c - np.array(elo))):.2f}")

    payload = {"rows": len(rows), "corr": corr,
               "constant": {"meanMae": float(np.mean(const_mean)),
                            "meanSd": float(np.std(const_mean)),
                            "meanBias": float(np.mean(const_bias)),
                            "medianMae": float(np.mean(const_med)),
                            "values": {"mean": const_mean, "median": const_med}}}
    with open(args.out, "w") as f:
        json.dump(payload, f, indent=1)
    print(f"\nwrote {args.out}")


if __name__ == "__main__":
    main()
