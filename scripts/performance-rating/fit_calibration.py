#!/usr/bin/env python3
"""The calibration study: five candidates on identical player-disjoint folds.

    python3 tools/fit_calibration.py --features data/features.json \
        --out data/study.json [--label "150 ms"]

Candidates
-----------
  esl       ESL per move, isotonic (non-increasing in loss)
  acpl      mean centipawn loss, isotonic (non-increasing)
  lichess   the application's Lichess accuracy, isotonic (non-decreasing)
  current   ::reviewreport::estimateElo {accuracy acpl}, the shipped curve,
            ported line for line -- no fitting, evaluated on the test folds
  hybrid    ESL per move + lambda * decisive-error rate, isotonic; lambda by
            inner cross-validation on the training folds only

Folds
-----
Player-disjoint, k-fold, repeated: a player is in exactly one test fold, so a
player seen in training is never scored. Repeats re-draw the fold assignment;
every candidate sees the same folds inside a repeat.

Metrics are computed on out-of-fold predictions pooled within a repeat, then
averaged across repeats. They are also split by opponent-strength quartile --
the corpus's own oppElo quartiles -- which is how "biased when you play up or
down" is answered without opponent rating ever entering the model.
"""
import argparse
import json
import math
import statistics
import sys

import numpy as np

BIN = 25
K = 5
DECISIVE_GRID = [0.0, 0.02, 0.05, 0.1, 0.2, 0.35, 0.5]


# ── the shipped curve, ported from tcl/tools/review_report.tcl ──────────────
def tcl_round(x):
    """Tcl's round(): nearest integer, half away from zero.

    Python's round() is half-to-even, so 2524.5 -> 2524 where the shipped Tcl
    gives 2525. That is a one-point disagreement on the baseline candidate, and
    the baseline has to be the report's own number, not a nearby one.
    """
    return int(math.floor(x + 0.5)) if x >= 0 else -int(math.floor(-x + 0.5))


def elo_from_acpl(acpl):
    a = max(0.0, acpl)
    if a <= 8:
        elo = 2900 - (a / 8.0) * 200
    elif a <= 12:
        elo = 2700 - ((a - 8) / 4.0) * 200
    elif a <= 18:
        elo = 2500 - ((a - 12) / 6.0) * 300
    elif a <= 25:
        elo = 2200 - ((a - 18) / 7.0) * 300
    elif a <= 35:
        elo = 1900 - ((a - 25) / 10.0) * 300
    elif a <= 50:
        elo = 1600 - ((a - 35) / 15.0) * 200
    elif a <= 70:
        elo = 1400 - ((a - 50) / 20.0) * 200
    elif a <= 100:
        elo = 1200 - ((a - 70) / 30.0) * 300
    elif a <= 150:
        elo = 900 - ((a - 100) / 50.0) * 300
    elif a <= 250:
        elo = 600 - ((a - 150) / 100.0) * 200
    else:
        elo = max(300, 400 - (a - 250) * 0.4)
    return tcl_round(max(300, min(2900, elo)))


def estimate_elo(accuracy, acpl):
    from_acpl = elo_from_acpl(acpl)
    adjust = max(-100.0, min(100.0, (accuracy - 75) * 10))
    return tcl_round(max(300, min(2900, from_acpl + adjust * 0.2)))


# ── isotonic regression (PAVA), both directions ────────────────────────────
def pava(x, y, increasing=True, w=None):
    """Weighted isotonic fit; returns knots (block starts) and block values."""
    order = np.argsort(np.asarray(x, dtype=float), kind="stable")
    xs = np.asarray(x, dtype=float)[order]
    ys = np.asarray(y, dtype=float)[order]
    ws = np.ones_like(ys) if w is None else np.asarray(w, dtype=float)[order]
    val = ys if increasing else -ys
    blocks = [[val[i] * ws[i], ws[i], i, i] for i in range(len(ys))]
    i = 0
    while i < len(blocks) - 1:
        if blocks[i][0] / blocks[i][1] > blocks[i + 1][0] / blocks[i + 1][1]:
            a, b = blocks[i], blocks[i + 1]
            blocks[i] = [a[0] + b[0], a[1] + b[1], a[2], b[3]]
            del blocks[i + 1]
            if i > 0:
                i -= 1
        else:
            i += 1
    sign = 1.0 if increasing else -1.0
    kx = np.array([xs[b[2]] for b in blocks])
    ky = np.array([sign * (b[0] / b[1]) for b in blocks])
    return kx, ky


def predict(kx, ky, q):
    """Step function: a block's value holds from its first x to the next block."""
    q = np.atleast_1d(np.asarray(q, dtype=float))
    idx = np.clip(np.searchsorted(kx, q, side="right") - 1, 0, len(kx) - 1)
    return ky[idx]


class Fit:
    """A monotone fit on one feature; step-evaluated, clamped at the ends."""

    def __init__(self, increasing=True):
        self.increasing = increasing
        self.kx = self.ky = None

    def train(self, rows, key):
        self.kx, self.ky = pava([r[key] for r in rows], [r["elo"] for r in rows],
                                increasing=self.increasing)
        return self

    def __call__(self, rows, key):
        return predict(self.kx, self.ky, [r[key] for r in rows])


class Hybrid:
    """ESL per move plus lambda * decisive-error rate, fitted by isotonic.

    lambda is chosen on inner player-disjoint folds of the training data only;
    the held-out fold never sees it.
    """

    def __init__(self, reps=3):
        self.lam = 0.0
        self.reps = reps

    @staticmethod
    def z(rows, lam):
        return [r["eslPerMove"] + lam * r["decisivePerMove"] for r in rows]

    def train(self, rows, rng):
        best = (float("inf"), 0.0)
        players = sorted({r["player"] for r in rows})
        for lam in DECISIVE_GRID:
            errs = []
            for _ in range(self.reps):
                idx = list(range(len(players)))
                rng.shuffle(idx)
                for f in range(3):
                    test_p = {players[i] for i in idx[f::3]}
                    tr = [r for r in rows if r["player"] not in test_p]
                    te = [r for r in rows if r["player"] in test_p]
                    if not tr or not te:
                        continue
                    kx, ky = pava(self.z(tr, lam), [r["elo"] for r in tr],
                                  increasing=False)
                    est = predict(kx, ky, self.z(te, lam))
                    errs.extend(np.abs(est - np.array([r["elo"] for r in te])))
            if errs:
                mae = float(np.mean(errs))
                if mae < best[0]:
                    best = (mae, lam)
        self.lam = best[1]
        self.kx, self.ky = pava(self.z(rows, self.lam), [r["elo"] for r in rows],
                                increasing=False)
        return self

    def __call__(self, rows):
        return predict(self.kx, self.ky, self.z(rows, self.lam))


# ── folds and metrics ──────────────────────────────────────────────────────
def grouped_folds(rows, rng, k=K):
    players = sorted({r["player"] for r in rows})
    rng.shuffle(players)
    fold_of = {p: i % k for i, p in enumerate(players)}
    folds = [[] for _ in range(k)]
    for r in rows:
        folds[fold_of[r["player"]]].append(r)
    return folds


def metrics(est, act):
    est = np.asarray(est, dtype=float)
    act = np.asarray(act, dtype=float)
    if not len(est):
        return None
    err = est - act
    return {"mae": float(np.mean(np.abs(err))), "bias": float(np.mean(err)),
            "rmse": float(np.sqrt(np.mean(err ** 2))), "n": int(len(err))}


def run_repeat(rows, rng):
    folds = grouped_folds(rows, rng)
    out = {k: {"est": [], "act": [], "opp": []}
           for k in ("esl", "acpl", "lichess", "current", "hybrid")}
    lam_used = []
    for f in range(len(folds)):
        test = folds[f]
        train = [r for i, fold in enumerate(folds) if i != f for r in fold]
        if not test or not train:
            continue
        esl = Fit(increasing=False).train(train, "eslPerMove")
        acpl = Fit(increasing=False).train(train, "acpl")
        acc = Fit(increasing=True).train(train, "accuracy")
        hyb = Hybrid().train(train, rng)
        lam_used.append(hyb.lam)
        preds = {
            "esl": esl(test, "eslPerMove"),
            "acpl": acpl(test, "acpl"),
            "lichess": acc(test, "accuracy"),
            "current": [estimate_elo(r["accuracy"], r["acpl"]) for r in test],
            "hybrid": hyb(test),
        }
        for k, v in preds.items():
            out[k]["est"].extend(float(x) for x in v)
            out[k]["act"].extend(float(r["elo"]) for r in test)
            out[k]["opp"].extend(float(r["oppElo"]) for r in test)
    return out, lam_used


def summarise(per_repeat):
    keys = per_repeat[0].keys()
    res = {}
    for k in keys:
        res[k] = {
            "mae": statistics.mean(pr[k]["mae"] for pr in per_repeat),
            "maeSd": statistics.pstdev(pr[k]["mae"] for pr in per_repeat),
            "bias": statistics.mean(pr[k]["bias"] for pr in per_repeat),
            "rmse": statistics.mean(pr[k]["rmse"] for pr in per_repeat),
        }
    return res


def quartile_table(per_repeat, rows):
    """Metrics per candidate inside each opponent-strength quartile.

    Quartile edges come from the corpus's own oppElo distribution, so they are
    the same for both budgets and for every repeat.
    """
    opps = sorted(r["oppElo"] for r in rows)
    edges = [opps[int(q * len(opps))] for q in (0.25, 0.5, 0.75)]

    def q_of(x):
        for i, e in enumerate(edges):
            if x <= e:
                return i
        return len(edges)

    # Recompute per-repeat with quartile labels: the pooled per-repeat arrays
    # carry oppElo alongside est/act, so this is a partition of the same data.
    acc = {qi: {} for qi in range(len(edges) + 1)}
    for qi in range(len(edges) + 1):
        for pr in per_repeat:
            for k, d in pr.items():
                idx = [i for i, o in enumerate(d["opp"]) if q_of(o) == qi]
                if not idx:
                    continue
                m = metrics([d["est"][i] for i in idx], [d["act"][i] for i in idx])
                acc[qi].setdefault(k, []).append(m)
    table = []
    for qi in range(len(edges) + 1):
        row = {"quartile": qi + 1,
               "oppEloRange": [min(o for o in opps if q_of(o) == qi) if any(q_of(o) == qi for o in opps) else None,
                               max(o for o in opps if q_of(o) == qi) if any(q_of(o) == qi for o in opps) else None]}
        for k, ms in acc[qi].items():
            row[k] = {"mae": statistics.mean(m["mae"] for m in ms),
                      "bias": statistics.mean(m["bias"] for m in ms),
                      "rmse": statistics.mean(m["rmse"] for m in ms),
                      "n": ms[0]["n"]}
        table.append(row)
    return table


def shipped_table(rows):
    """The table the module holds: isotonic read on a grid, rounded to 25,
    re-monotonised, clamped at both ends."""
    kx, ky = pava([r["eslPerMove"] for r in rows], [r["elo"] for r in rows],
                  increasing=False)
    top = max(r["eslPerMove"] for r in rows)
    grid = [0.0, 0.0025, 0.005, 0.0075, 0.01, 0.0125, 0.015, 0.02, 0.025, 0.03,
            0.04, 0.05, 0.06, 0.08, 0.10, 0.15, 0.20, 0.30, 0.40, 0.60]
    grid = [x for x in grid if x <= max(0.40, top)] + [max(0.60, top * 1.2)]
    fit = predict(kx, ky, grid)
    rows_out, prev = [], None
    for x, v in zip(grid, fit):
        v = int(round(float(v) / BIN) * BIN)
        if prev is not None and v > prev:
            v = prev
        rows_out.append({"eslPerMove": float(x), "rating": v})
        prev = v
    while len(rows_out) > 2 and rows_out[-1]["rating"] == rows_out[-2]["rating"]:
        rows_out.pop()
    return rows_out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--features", default="data/features.json")
    ap.add_argument("--out", default="data/study.json")
    ap.add_argument("--reps", type=int, default=10)
    ap.add_argument("--label", default="150 ms")
    ap.add_argument("--ids", default="",
                    help="file of game ids: restrict to an explicit subsample")
    args = ap.parse_args()

    feats = json.load(open(args.features))
    rows = [r for r in feats["rows"] if r["moves"] >= 20]
    if args.ids:
        wanted = {int(x) for x in open(args.ids).read().split()}
        rows = [r for r in rows if r["game"] in wanted]
    print(f"{len(rows)} player-games, {len({r['player'] for r in rows})} players",
          file=sys.stderr)

    per_repeat, lams = [], []
    for i in range(args.reps):
        rng = np.random.default_rng(2000 + i)
        out, lam = run_repeat(rows, rng)
        per_repeat.append({k: {"mae": metrics(v["est"], v["act"])["mae"],
                               "bias": metrics(v["est"], v["act"])["bias"],
                               "rmse": metrics(v["est"], v["act"])["rmse"],
                               "est": v["est"], "act": v["act"], "opp": v["opp"]}
                           for k, v in out.items()})
        lams.extend(lam)

    agg = summarise(per_repeat)
    paired = {}
    for k in ("current", "acpl", "lichess", "hybrid"):
        d = [pr["esl"]["mae"] - pr[k]["mae"] for pr in per_repeat]
        paired[k] = {"mean": float(np.mean(d)), "sd": float(np.std(d)),
                     "wins": int(sum(1 for x in d if x < 0)), "of": len(d)}

    study = {
        "label": args.label, "engine": feats["engine"],
        "movetime_ms": feats.get("movetime_ms"), "depth": feats.get("depth"),
        "rows": len(rows), "games": len({r["game"] for r in rows}),
        "players": len({r["player"] for r in rows}),
        "meanElo": statistics.mean(r["elo"] for r in rows),
        "eloSd": statistics.pstdev(r["elo"] for r in rows),
        "eloRange": [min(r["elo"] for r in rows), max(r["elo"] for r in rows)],
        "folds": {"kind": "player-disjoint", "k": K, "repeats": args.reps},
        "hybridLambda": {"median": statistics.median(lams),
                         "values": sorted(set(lams))},
        "aggregate": agg,
        "eslMinus": paired,
        "quartiles": quartile_table(per_repeat, rows),
        "table": shipped_table(rows),
        "quantiles": {
            k: {"p10": float(np.percentile([r[k] for r in rows], 10)),
                "p50": float(np.percentile([r[k] for r in rows], 50)),
                "p90": float(np.percentile([r[k] for r in rows], 90))}
            for k in ("eslPerMove", "acpl", "accuracy", "decisivePerMove")},
    }
    study["tableRange"] = [study["table"][0]["rating"], study["table"][-1]["rating"]]

    with open(args.out, "w") as f:
        json.dump(study, f, indent=1)

    print(json.dumps({"label": study["label"], "rows": study["rows"],
                      "games": study["games"], "players": study["players"],
                      "meanElo": round(study["meanElo"], 1),
                      "eloSd": round(study["eloSd"], 1),
                      "aggregate": {k: {kk: round(vv, 2) for kk, vv in v.items()}
                                    for k, v in agg.items()},
                      "eslMinus": paired,
                      "hybridLambda": study["hybridLambda"],
                      "quantiles": study["quantiles"]}, indent=1))
    print("quartiles:")
    for q in study["quartiles"]:
        print(f"  Q{q['quartile']} oppElo {q['oppEloRange']}: " +
              " ".join(f"{k} mae={v['mae']:.1f} bias={v['bias']:+.1f}"
                       for k, v in q.items() if k not in ("quartile", "oppEloRange")))
    print("table:")
    for row in study["table"]:
        print(f"  {row['eslPerMove']:.4f} -> {row['rating']}")


if __name__ == "__main__":
    main()
