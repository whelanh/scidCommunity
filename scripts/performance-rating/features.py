#!/usr/bin/env python3
"""Per-player-game features from the engine pass.

    python3 tools/features.py --evals data/evals.jsonl --corpus data/corpus.json \
        --accuracy-tcl /home/david/work/scidcommunity/tcl/tools/accuracy.tcl \
        --out data/features.json

For each game and each side:

    esl             sum over that side's moves of max(0, E(best) - E(after))
                    with E = ::accuracy::winPercent/100 -- expected-score points
    eslPerMove      esl / that side's move count: the statistic the fit uses
    acpl            mean centipawn loss, capped at 300 as the report caps it
    accuracy        the application's own ::accuracy::calculateFrom, read from
                    tclsh -- Lichess accuracy, the figure the report prints
    decisive        moves with an expected-score loss of at least 0.20
    decisivePerMove decisive / moves -- the hybrid candidate's second term
    elo, oppElo, score, result, moves, event, date, eco, band

Ratings are the offline ground truth. Nothing here is read by the application.
"""
import argparse
import json
import math
import os
import statistics
import subprocess
import sys


def win_percent(cp):
    """Exactly ::accuracy::winPercent."""
    return 50.0 + 50.0 * (2.0 / (1.0 + math.exp(-0.00368208 * cp)) - 1.0)


DECISIVE = 0.20   # expected-score points; 20 win% of the game


def app_accuracies(series_by_game, accuracy_tcl, workdir):
    """Run the application's accuracy.tcl over every series in one tclsh."""
    lines = [f"{gid} {' '.join(str(c) for c in cps)}"
             for gid, cps in series_by_game.items()]
    points = os.path.join(workdir, "acc_points.txt")
    out_path = os.path.join(workdir, "acc.txt")
    with open(points, "w") as f:
        f.write("\n".join(lines) + "\n")
    subprocess.run(["tclsh", os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                         "app_accuracy.tcl"),
                    accuracy_tcl, points, out_path], check=True)
    acc = {}
    for line in open(out_path):
        gid, w, b = line.split()
        acc[int(gid)] = (float(w), float(b))
    return acc


def score_of(result, side):
    if result in ("1-0", "1-0 "):
        return 1.0 if side == "white" else 0.0
    if result == "0-1":
        return 1.0 if side == "black" else 0.0
    if result in ("=-=", "1/2-1/2"):
        return 0.5
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--evals", default="data/evals.jsonl")
    ap.add_argument("--corpus", default="data/corpus.json")
    ap.add_argument("--accuracy-tcl", required=True)
    ap.add_argument("--out", default="data/features.json")
    ap.add_argument("--workdir", default="data")
    ap.add_argument("--ids", default="",
                    help="file of game ids: restrict to an explicit subsample")
    args = ap.parse_args()

    corpus = {g["id"]: g for g in json.load(open(args.corpus))["games"]}
    wanted = None
    if args.ids:
        wanted = {int(x) for x in open(args.ids).read().split()}
    evals = []
    with open(args.evals) as f:
        for line in f:
            line = line.strip()
            if line:
                evals.append(json.loads(line))
    good = [e for e in evals if "cps" in e and e["id"] in corpus
            and (wanted is None or e["id"] in wanted)]
    print(f"evals: {len(evals)} records, {len(good)} usable", file=sys.stderr)

    series = {e["id"]: e["cps"] for e in good}
    acc = app_accuracies(series, args.accuracy_tcl, args.workdir)

    rows = []
    for e in good:
        cps = e["cps"]
        md = corpus[e["id"]]["metadata"]
        wacc, bacc = acc[e["id"]]
        per = {"white": {"esl": 0.0, "loss": [], "decisive": 0, "n": 0},
               "black": {"esl": 0.0, "loss": [], "decisive": 0, "n": 0}}
        for i in range(1, len(cps)):
            side = "white" if i % 2 == 1 else "black"
            eb, ea = win_percent(cps[i - 1]) / 100.0, win_percent(cps[i]) / 100.0
            if side == "white":
                gap = max(0.0, eb - ea)
                before, after = cps[i - 1], cps[i]
            else:
                gap = max(0.0, ea - eb)
                before, after = -cps[i - 1], -cps[i]
            p = per[side]
            p["esl"] += gap
            if gap >= DECISIVE:
                p["decisive"] += 1
            p["loss"].append(min(300, max(0, before - after)))
            p["n"] += 1

        for side, elo, opp, sacc in (("white", md["welo"], md["belo"], wacc),
                                     ("black", md["belo"], md["welo"], bacc)):
            p = per[side]
            if p["n"] == 0:
                continue
            rows.append({
                "game": e["id"], "side": side,
                "player": md["white"] if side == "white" else md["black"],
                "elo": elo, "oppElo": opp, "score": score_of(md["result"], side),
                "result": md["result"], "band": corpus[e["id"]].get("band"),
                "moves": p["n"], "plies": e["plies"],
                "esl": p["esl"], "eslPerMove": p["esl"] / p["n"],
                "acpl": statistics.mean(p["loss"]),
                "accuracy": sacc,
                "decisive": p["decisive"],
                "decisivePerMove": p["decisive"] / p["n"],
                "event": md.get("event", ""), "date": md.get("date", ""),
                "eco": md.get("eco", ""),
            })

    payload = {"engine": "Stockfish 19",
               "movetime_ms": None, "depth": None, "decisive": DECISIVE,
               "rows": rows}
    # The budget belongs with the features: the study's provenance is the
    # engine pass's own meta file, not a guess made here.
    meta_path = args.evals + ".meta.json"
    if os.path.exists(meta_path):
        meta = json.load(open(meta_path))
        payload["engine"] = meta.get("engine_version", ["Stockfish 19"])[0].split(" by ")[0]
        payload["movetime_ms"] = meta.get("movetime_ms")
        payload["depth"] = meta.get("depth")
        payload["evals"] = os.path.basename(args.evals)
        payload["subset"] = meta.get("subset")
    with open(args.out, "w") as f:
        json.dump(payload, f)
    print("rows", len(rows), "games", len(good))
    elos = [r["elo"] for r in rows]
    print("elo mean", round(statistics.mean(elos), 1),
          "sd", round(statistics.pstdev(elos), 1),
          "range", min(elos), max(elos))
    print("eslPerMove median", round(statistics.median(r["eslPerMove"] for r in rows), 5))
    print("accuracy median", round(statistics.median(r["accuracy"] for r in rows), 2))


if __name__ == "__main__":
    main()
