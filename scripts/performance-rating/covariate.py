#!/usr/bin/env python3
"""What opponent strength would buy, and why it is still not used.

    .venv/bin/python tools/covariate.py --features data/features.json

Ratings are not a runtime input, so the shipped table is moves-only. This
measures the price of that rule: the same player-disjoint folds, an ordinary
least-squares fit on ESL per move and opponent rating against one on ESL per
move alone, out-of-fold MAE for both.
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
    ap.add_argument("--reps", type=int, default=10)
    ap.add_argument("--out", default="data/covariate.json")
    args = ap.parse_args()

    rows = [r for r in json.load(open(args.features))["rows"] if r["moves"] >= 20]
    esl_maes, cov_maes, deltas, coefs, ts = [], [], [], [], []
    for i in range(args.reps):
        rng = np.random.default_rng(2000 + i)
        e_esl, e_cov, fold_coef = [], [], []
        for fold in fc.grouped_folds(rows, rng):
            test_p = {r["player"] for r in fold}
            train = [r for r in rows if r["player"] not in test_p]
            if not train or not fold:
                continue
            kx, ky = fc.pava([r["eslPerMove"] for r in train],
                             [r["elo"] for r in train], increasing=False)
            est = fc.predict(kx, ky, [r["eslPerMove"] for r in fold])
            y = np.array([r["elo"] for r in fold], float)
            e_esl.extend(np.abs(est - y))

            X = np.column_stack([[1.0] * len(train),
                                 [r["eslPerMove"] for r in train],
                                 [r["oppElo"] for r in train]]).astype(float)
            yt = np.array([r["elo"] for r in train], float)
            beta, *_ = np.linalg.lstsq(X, yt, rcond=None)
            Xt = np.column_stack([[1.0] * len(fold),
                                  [r["eslPerMove"] for r in fold],
                                  [r["oppElo"] for r in fold]]).astype(float)
            e_cov.extend(np.abs(Xt @ beta - y))
            fold_coef.append(float(beta[2]))
        esl_maes.append(float(np.mean(e_esl)))
        cov_maes.append(float(np.mean(e_cov)))
        deltas.append(esl_maes[-1] - cov_maes[-1])
        coefs.append(float(np.mean(fold_coef)))
        # crude t: mean coefficient over folds against its own spread
        se = np.std(fold_coef, ddof=1) / np.sqrt(len(fold_coef))
        ts.append(float(np.mean(fold_coef) / se))

    out = {"rows": len(rows), "reps": args.reps,
           "eslMae": float(np.mean(esl_maes)),
           "covariateMae": float(np.mean(cov_maes)),
           "deltaMae": float(np.mean(deltas)),
           "deltaSd": float(np.std(deltas)),
           "oppCoef": float(np.mean(coefs)),
           "t": float(np.mean(ts))}
    print(f"moves-only ESL    MAE {out['eslMae']:.2f}")
    print(f"ESL + opponent    MAE {out['covariateMae']:.2f}")
    print(f"improvement       {out['deltaMae']:+.2f} (sd {out['deltaSd']:.2f})")
    print(f"coefficient on oppElo {out['oppCoef']:.3f}, t {out['t']:.1f}")
    with open(args.out, "w") as f:
        json.dump(out, f, indent=1)
    print(f"wrote {args.out}")


if __name__ == "__main__":
    main()
