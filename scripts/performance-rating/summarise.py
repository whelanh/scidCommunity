#!/usr/bin/env python3
"""Summarise a corpus.json (or features.json / study.json) for the log."""
import json
import statistics
import sys
from collections import Counter

path = sys.argv[1]
d = json.load(open(path))
if "games" in d:
    games = d["games"]
    plies = []
    players = set()
    elos = []
    results = Counter()
    bands = Counter()
    for g in games:
        md = g["metadata"]
        n = g["pgn"].count(".")  # rough; real plies come from the engine pass
        results[md["result"]] += 1
        bands[g.get("band")] += 1
        elos += [md["welo"], md["belo"]]
        players.add(md["white"])
        players.add(md["black"])
    print("games:", len(games))
    print("results:", dict(results))
    print("bands:", dict(sorted(bands.items())))
    print("players:", len(players))
    print("elo min/median/max:", min(elos), statistics.median(elos), max(elos),
          "mean", round(statistics.mean(elos), 1),
          "sd", round(statistics.pstdev(elos), 1))
    print("both-rated:", sum(1 for g in games
                             if g["metadata"].get("welo") and g["metadata"].get("belo")))
elif "rows" in d:
    rows = d["rows"]
    print("rows:", len(rows), "games:", len({r["game"] for r in rows}),
          "players:", len({r["player"] for r in rows}))
    for k in ("eslPerMove", "acpl", "accuracy", "decisivePerMove", "moves"):
        xs = sorted(r[k] for r in rows)
        q = lambda p: xs[min(len(xs) - 1, int(p * len(xs)))]
        print(f"{k}: min {xs[0]:.4f} p10 {q(.1):.4f} p50 {q(.5):.4f} "
              f"p90 {q(.9):.4f} max {xs[-1]:.4f}")
