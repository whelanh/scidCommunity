#!/usr/bin/env python3
"""A 100-game subsample of the corpus, stratified by rating band.

    python3 tools/subsample.py --corpus data/corpus.json --n 100 \
        --out data/subsample-100-ids.txt

Band counts are allocated proportionally to the corpus by largest remainder,
then games are drawn inside each band by a seeded shuffle, so the list is
reproducible and the depth-18 ablation runs on the same shape of population as
the 150 ms headline rather than on the low half of the range.
"""
import argparse
import json
import random
from collections import defaultdict


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--corpus", default="data/corpus.json")
    ap.add_argument("--n", type=int, default=100)
    ap.add_argument("--seed", type=int, default=20180)
    ap.add_argument("--out", default="data/subsample-100-ids.txt")
    args = ap.parse_args()

    games = json.load(open(args.corpus))["games"]
    by_band = defaultdict(list)
    for g in games:
        by_band[g["band"]].append(g["id"])
    total = len(games)

    exact = {b: len(ids) * args.n / total for b, ids in by_band.items()}
    alloc = {b: int(v) for b, v in exact.items()}
    short = args.n - sum(alloc.values())
    for b in sorted(exact, key=lambda b: exact[b] - alloc[b], reverse=True)[:short]:
        alloc[b] += 1

    rng = random.Random(args.seed)
    picked = []
    for b in sorted(by_band):
        ids = sorted(by_band[b])
        rng.shuffle(ids)
        take = ids[: alloc[b]]
        picked.extend(take)
        print(f"{b}: {len(by_band[b])} games, take {len(take)}")
    picked.sort()

    with open(args.out, "w") as f:
        f.write("\n".join(str(i) for i in picked) + "\n")
    print(f"wrote {args.out}: {len(picked)} games")


if __name__ == "__main__":
    main()
