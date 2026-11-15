#!/usr/bin/env python3
"""The engine pass: one evaluation per position, MultiPV 1, resumable.

    python3 tools/engine_pass.py --engine data/stockfish/stockfish-... \\
        --corpus data/corpus.json --movetime 0.15 --workers 10 \\
        --out data/evals.jsonl

Every position of every game is evaluated exactly once; both players' ESL is
then read off the same series, so the statistic costs one evaluation per
position rather than two.

The pass checkpoints **per game**: `--out` is JSONL appended as games finish,
and a re-run skips the ids already present. A crash therefore resumes where it
stopped instead of starting the hour again.

Threads per worker is pinned to 1 and Hash to `--hash` (16 MB), inside the
application's own MAX_PASS_THREADS (8) / MAX_PASS_HASH (512) caps: N workers use
N cores, and no single evaluation is allowed a bigger budget than the review
pass would give it.

The script never touches Tk; it is meant to run as a background job.
"""
import argparse
import io
import json
import multiprocessing as mp
import os
import subprocess
import sys
import time

import chess
import chess.engine
import chess.pgn

MATE_CP = 1000


def eval_game(task):
    gid, pgn_text, movetime, depth, hash_mb, engine_path = task
    game = chess.pgn.read_game(io.StringIO(pgn_text))
    if game is None or game.errors:
        return gid, {"id": gid, "error": "pgn parse"}
    board = game.board()
    positions, sans = [board.copy()], []
    for mv in game.mainline_moves():
        sans.append(board.san(mv))
        board.push(mv)
        positions.append(board.copy())

    try:
        eng = chess.engine.SimpleEngine.popen_uci(engine_path)
    except Exception as exc:  # pragma: no cover - environment failure
        return gid, {"id": gid, "error": f"engine: {exc}"}
    try:
        eng.configure({"Threads": 1, "Hash": hash_mb})
        limit = (chess.engine.Limit(depth=depth) if depth
                 else chess.engine.Limit(time=movetime))
        cps = []
        for pos in positions:
            info = eng.analyse(pos, limit, multipv=1)
            if isinstance(info, list):
                info = info[0]
            sc = info["score"].pov(chess.WHITE).score(mate_score=MATE_CP)
            cps.append(int(sc) if sc is not None else 0)
    finally:
        eng.quit()
    return gid, {"id": gid, "cps": cps, "sans": sans, "plies": len(positions) - 1}


def load_done(path):
    done = {}
    if not os.path.exists(path):
        return done
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue  # a torn final line from a killed run
            if "cps" in rec:
                done[rec["id"]] = rec
    return done


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--engine", required=True)
    ap.add_argument("--corpus", default="data/corpus.json")
    ap.add_argument("--out", default="data/evals.jsonl")
    ap.add_argument("--movetime", type=float, default=0.15)
    ap.add_argument("--depth", type=int, default=0)
    ap.add_argument("--workers", type=int, default=10)
    ap.add_argument("--hash", type=int, default=16)
    ap.add_argument("--limit", type=int, default=0,
                    help="first N games of the corpus (the depth-18 subsample)")
    ap.add_argument("--ids", default="",
                    help="file of game ids, one per line: an explicit subsample")
    args = ap.parse_args()

    corpus = json.load(open(args.corpus))
    games = corpus["games"]
    if args.ids:
        wanted = {int(x) for x in open(args.ids).read().split()}
        games = [g for g in games if g["id"] in wanted]
    if args.limit:
        games = games[: args.limit]
    done = load_done(args.out)
    todo = [g for g in games if g["id"] not in done]
    print(f"{len(games)} games, {len(done)} done, {len(todo)} to run",
          file=sys.stderr, flush=True)

    version = subprocess.run([args.engine], input="quit\n", text=True,
                             capture_output=True).stdout.splitlines()
    print("engine:", version[0] if version else "?", file=sys.stderr, flush=True)

    tasks = [(g["id"], g["pgn"], args.movetime, args.depth, args.hash, args.engine)
             for g in todo]
    t0 = time.time()
    n = 0
    with open(args.out, "a") as out, mp.Pool(args.workers) as pool:
        for gid, rec in pool.imap_unordered(eval_game, tasks):
            out.write(json.dumps(rec) + "\n")
            out.flush()
            n += 1
            if n % 25 == 0:
                el = time.time() - t0
                print(f"{n}/{len(tasks)} games, {el:.0f}s elapsed, "
                      f"{el / n:.1f}s/game", file=sys.stderr, flush=True)

    done = load_done(args.out)
    bad = [gid for gid in [g["id"] for g in games] if gid not in done]
    meta = {"engine_path": args.engine, "engine_version": version[:1],
            "movetime_ms": None if args.depth else int(args.movetime * 1000),
            "depth": args.depth or None, "threads_per_worker": 1,
            "hash_mb": args.hash, "multipv": 1, "games": len(games),
            "done": len(done), "failed": bad,
            "subset": os.path.basename(args.ids) if args.ids else None}
    with open(args.out + ".meta.json", "w") as f:
        json.dump(meta, f, indent=1)
    print(f"done {len(done)}/{len(games)}; missing {len(bad)}", file=sys.stderr)


if __name__ == "__main__":
    main()
