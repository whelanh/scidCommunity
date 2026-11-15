#!/usr/bin/env python3
"""Draw the ESL calibration corpus out of KingBase2018 through the app's own
headless JSON-RPC API.

    python3 tools/extract_corpus.py --scid build/scidCommunity \
        --db data/KingBase2018.si4 --count 500 --seed 20261103 \
        --out data/corpus.json

Selection, fixed before the run (card t_6bb4de78):

  * both players carry a rating, inside [--lo, --hi];
  * at least --min-plies plies (the length filter is in plies);
  * the game is decided or drawn: result is 1-0, 0-1 or 1/2-1/2, never "*";
  * spread across rating bands: the range is cut into 100-point bands and the
    500 games are allocated across them, so the sample is not the middle of the
    database. Games are drawn at random inside each band with a fixed seed.

Ratings are read here, offline, as the ground truth of the fit. Nothing in the
application reads them at runtime.
"""
import argparse
import json
import random
import subprocess
import sys
from collections import OrderedDict


class Headless:
    def __init__(self, scid):
        self.p = subprocess.Popen([scid, "--headless"], stdin=subprocess.PIPE,
                                  stdout=subprocess.PIPE, text=True, bufsize=1)
        self.id = 0
        self.call("get_version")

    def call(self, method, **params):
        self.id += 1
        req = {"jsonrpc": "2.0", "id": self.id, "method": method, "params": params}
        self.p.stdin.write(json.dumps(req) + "\n")
        self.p.stdin.flush()
        line = self.p.stdout.readline()
        if not line:
            raise RuntimeError("headless API died")
        resp = json.loads(line)
        if "error" in resp:
            raise RuntimeError(f"{method}: {resp['error']}")
        return resp["result"]

    def close(self):
        try:
            self.p.stdin.close()
        except Exception:
            pass
        self.p.wait(timeout=60)


# Scid's result codes: 1-0, 0-1, "=-=" (draw), "*" (unknown/unfinished). The
# search API cannot filter on result, so the sample drops "*" here.
GOOD_RESULTS = {"1-0", "0-1", "=-="}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--scid", required=True)
    ap.add_argument("--db", required=True)
    ap.add_argument("--count", type=int, default=500)
    ap.add_argument("--seed", type=int, default=20261103)
    ap.add_argument("--lo", type=int, default=1200)
    ap.add_argument("--hi", type=int, default=2900)
    ap.add_argument("--min-plies", type=int, default=40)
    ap.add_argument("--out", default="data/corpus.json")
    ap.add_argument("--probe", action="store_true",
                    help="print per-band counts and exit without sampling")
    args = ap.parse_args()

    length = f"{args.min_plies} 400"
    bands = [(lo, lo + 99) for lo in range(args.lo, args.hi + 1, 100)]

    h = Headless(args.scid)
    handle = h.call("db_open", path=args.db, type="SCID4", readonly=True)["handle"]
    print(h.call("db_info", handle=handle), file=sys.stderr)

    counts, ids_by_band = OrderedDict(), {}
    for lo, hi in bands:
        res = h.call("db_search", handle=handle,
                     welo=f"{lo} {hi}", belo=f"{lo} {hi}", length=length)
        ids = res.get("matches") or []
        counts[(lo, hi)] = res["count"]
        ids_by_band[(lo, hi)] = ids
        print(f"band {lo}-{hi}: {res['count']} games, {len(ids)} ids listed",
              file=sys.stderr)

    if args.probe:
        total = sum(counts.values())
        print(json.dumps({"bands": {f"{lo}-{hi}": c for (lo, hi), c in counts.items()},
                          "total": total}, indent=1))
        h.close()
        return

    live = [(b, c) for b, c in counts.items() if c > 0]
    if not live:
        raise SystemExit("no band matched")

    # Damped proportional allocation: full proportionality would put almost the
    # whole sample on the 2200-2500 bands and leave the tails as anecdotes; a
    # floor of 10 games per band keeps every band with data in the study.
    weights = [c ** 0.5 for _, c in live]
    wsum = sum(weights)
    alloc, spare = {}, args.count
    for (band, _), w in zip(live, weights):
        n = max(10, int(round(args.count * w / wsum)))
        alloc[band] = n
        spare -= n
    # hand out (or take back) the rounding remainder, largest bands first
    order = [b for b, _ in sorted(live, key=lambda x: -x[1])]
    i = 0
    while spare != 0:
        band = order[i % len(order)]
        if spare > 0:
            alloc[band] += 1
            spare -= 1
        elif alloc[band] > 10:
            alloc[band] -= 1
            spare += 1
        i += 1

    rng = random.Random(args.seed)
    games, picked = [], set()
    shortfall = 0
    for (lo, hi), n in alloc.items():
        ids = list(ids_by_band[(lo, hi)])
        rng.shuffle(ids)
        got = 0
        for gid in ids:
            if got >= n:
                break
            if gid in picked:
                continue
            g = h.call("game_get", handle=handle, id=gid)
            md = g["metadata"]
            if md["result"] not in GOOD_RESULTS:
                continue  # the search cannot filter on result; drop and refill
            picked.add(gid)
            games.append({"id": gid, "band": f"{lo}-{hi}", "metadata": md,
                          "pgn": g["pgn"]})
            got += 1
            if len(games) % 100 == 0:
                print("fetched", len(games), file=sys.stderr, flush=True)
        shortfall += n - got
        print(f"band {lo}-{hi}: {got}/{n}", file=sys.stderr, flush=True)

    # Refill any shortfall from bands that still have unseen ids, largest first.
    if shortfall > 0:
        order = [b for b, _ in sorted(live, key=lambda x: -x[1])]
        for band in order:
            if shortfall <= 0:
                break
            ids = list(ids_by_band[band])
            rng.shuffle(ids)
            for gid in ids:
                if shortfall <= 0:
                    break
                if gid in picked:
                    continue
                g = h.call("game_get", handle=handle, id=gid)
                md = g["metadata"]
                if md["result"] not in GOOD_RESULTS:
                    continue
                picked.add(gid)
                games.append({"id": gid, "band": f"{band[0]}-{band[1]}",
                              "metadata": md, "pgn": g["pgn"]})
                shortfall -= 1
    h.close()
    games.sort(key=lambda g: g["id"])

    payload = {
        "source": args.db,
        "selection": {"welo": f"{args.lo} {args.hi}", "belo": f"{args.lo} {args.hi}",
                      "length": length, "results": sorted(GOOD_RESULTS)},
        "bands": {f"{lo}-{hi}": c for (lo, hi), c in counts.items()},
        "allocation": {f"{lo}-{hi}": n for (lo, hi), n in alloc.items()},
        "seed": args.seed,
        "games": games,
    }
    with open(args.out, "w") as f:
        json.dump(payload, f)
    print(f"wrote {args.out}: {len(games)} games", file=sys.stderr)


if __name__ == "__main__":
    main()
