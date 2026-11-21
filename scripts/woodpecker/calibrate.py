# Candidate Woodpecker mark rules on a probe run that has the d3best and
# sound_sac columns (puzzle_review_probe.tcl). Target from the plan: the moves
# that earn a bonus (! or !!) are about 25-30% of the solver's moves.
# Usage: python3 -I calibrate.py probe.tsv
import csv, sys
from collections import defaultdict

rows = list(csv.DictReader(open(sys.argv[1]), delimiter="\t"))
puzzles = defaultdict(list)
for r in rows:
    puzzles[r["id"]].append(r)

def rank(xs):
    o = sorted(range(len(xs)), key=lambda i: xs[i])
    rk = [0.0] * len(xs)
    i = 0
    while i < len(o):
        j = i
        while j + 1 < len(o) and xs[o[j + 1]] == xs[o[i]]:
            j += 1
        for k in range(i, j + 1):
            rk[o[k]] = (i + j) / 2.0
        i = j + 1
    return rk

def spearman(a, b):
    ra, rb = rank(a), rank(b)
    n = len(a)
    ma, mb = sum(ra) / n, sum(rb) / n
    cov = sum((x - ma) * (y - mb) for x, y in zip(ra, rb))
    va = sum((x - ma) ** 2 for x in ra) ** 0.5
    vb = sum((y - mb) ** 2 for y in rb) ** 0.5
    return cov / (va * vb)

ok = lambda r: r["base_label"] in ("best", "excellent")
sac = lambda r: ok(r) and r["sound_sac"] == "1"
miss = lambda r: r["d3best"] not in ("", r["played"])
quiet = lambda r: r["capture"] == "0" and r["check"] == "0"

rules = {
    "S1 ! = a depth-3 search plays something else": lambda r: ok(r) and miss(r),
    "S2 ! = quiet (no capture, no check)": lambda r: ok(r) and quiet(r),
    "S3 ! = S1 or S2": lambda r: ok(r) and (miss(r) or quiet(r)),
    "S4 ! = S1 and not a check": lambda r: ok(r) and miss(r) and r["check"] == "0",
}
n = len(rows)
print(f"{len(puzzles)} puzzles, {n} solver moves; !! = sound sacrifice: {sum(map(sac, rows))} ({100*sum(map(sac, rows))/n:.1f}%)")
for name, one in rules.items():
    m1 = sum(1 for r in rows if one(r) and not sac(r))
    m2 = sum(1 for r in rows if sac(r))
    rat, mx, none = [], [], 0
    for rs in puzzles.values():
        b = sum(2 if sac(r) else (1 if one(r) else 0) for r in rs)
        none += b == 0
        rat.append(int(rs[0]["rating"]))
        mx.append(2 + b)
    print(f"  {name:46s} ! {100*m1/n:4.1f}%  total {100*(m1+m2)/n:4.1f}%  unmarked puzzles {100*none/len(puzzles):4.1f}%  rho {spearman(rat, mx):.2f}")
print(f"  {'(reference) solution length':46s} rho {spearman([int(rs[0]['rating']) for rs in puzzles.values()], [len(rs) for rs in puzzles.values()]):.2f}")
