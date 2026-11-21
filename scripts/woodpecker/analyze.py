# Summarise puzzle_review_probe.tcl output (stdlib only).
# Usage: python3 -I analyze.py probe_out.tsv
import csv, sys
from collections import Counter, defaultdict

rows = list(csv.DictReader(open(sys.argv[1]), delimiter="\t"))
puzzles = defaultdict(list)
for r in rows:
    puzzles[r["id"]].append(r)
n_p, n_m = len(puzzles), len(rows)
print(f"puzzles {n_p}, solver moves {n_m}")

def pct(a, b):
    return f"{100.0 * a / b:5.1f}%" if b else "  n/a"

print("\n== what Game Review writes today (base ladder) ==")
c = Counter(r["base_label"] for r in rows)
for k, v in c.most_common():
    print(f"  {k:12s} {v:4d} {pct(v, n_m)}")
print("  moves with ! or !! today:", sum(1 for r in rows if r["nag"] in ("!", "!!")))

print("\n== with ::movelabels::refine (in_book 0) ==")
c = Counter(r["refined"] for r in rows)
for k, v in c.most_common():
    print(f"  {k:12s} {v:4d} {pct(v, n_m)}")

print("\n  by solver move index (1 = key move):")
by = defaultdict(Counter)
for r in rows:
    by[min(int(r["mover_index"]), 3)][r["refined"]] += 1
for i in sorted(by):
    tot = sum(by[i].values())
    lab = "3+" if i == 3 else str(i)
    print(f"   move {lab}: n={tot:3d} great {pct(by[i]['great'], tot)} brilliant {pct(by[i]['brilliant'], tot)}")

print("\n  by tier (share of solver moves marked ! / !!):")
bt = defaultdict(list)
for r in rows:
    bt[r["tier"]].append(r)
for t in ("easier", "normal", "harder", "hardest"):
    rs = bt.get(t, [])
    if not rs:
        continue
    g = sum(r["refined"] == "great" for r in rs)
    b = sum(r["refined"] == "brilliant" for r in rs)
    print(f"   {t:8s} n={len(rs):3d}  ! {pct(g, len(rs))}  !! {pct(b, len(rs))}")

per = Counter()
for pid, rs in puzzles.items():
    per[(sum(r["refined"] == "great" for r in rs), sum(r["refined"] == "brilliant" for r in rs))] += 1
print("\n  puzzles by (#!, #!!):", dict(sorted(per.items())))
none = sum(v for (g, b), v in per.items() if g == 0 and b == 0)
print("  puzzles with no mark at all:", none, pct(none, n_p))

print("\n== why brilliant is rare ==")
sac = [r for r in rows if r["hanging"] not in ("",) and r["is_best"] == "1" and int(r["hanging"]) >= 2]
capped = [r for r in sac if r["cp_before"] and int(r["cp_before"]) > 500]
print(f"  engine-best moves that leave >=2 points en prise: {len(sac)}")
print(f"  ... of which cp_before > 500 (refine refuses brilliant): {len(capped)} {pct(len(capped), len(sac))}")
print(f"  ... brilliant actually given: {sum(r['refined']=='brilliant' for r in sac)}")

print("\n== only-move gap (best - 2nd best, mover POV) ==")
gaps = [int(r["gap12"]) for r in rows if r["gap12"] not in ("",)]
print(f"  moves with a 2nd line: {len(gaps)}, gap>=200: {sum(g >= 200 for g in gaps)} {pct(sum(g >= 200 for g in gaps), len(gaps))}")

print("\n== Lichess solution vs engine first choice ==")
dis = [r for r in rows if r["is_best"] == "0"]
print(f"  solver moves where the engine prefers another move: {len(dis)} {pct(len(dis), n_m)}")
for r in dis[:12]:
    print(f"    {r['id']} ply {r['ply']} played {r['played']} engine {r['engine_best']} label {r['base_label']} cp {r['cp_before']}->{r['cp_after']}")

print("\n== stable depth (first depth from which the engine keeps the move) ==")
def rank(xs):
    o = sorted(range(len(xs)), key=lambda i: xs[i])
    rk = [0] * len(xs)
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
    return cov / (va * vb) if va and vb else float("nan")
sd = [r for r in rows if r["stable_depth"] not in ("",)]
c = Counter(min(int(r["stable_depth"]), 10) for r in sd)
print("  distribution (10 = 10+):", dict(sorted(c.items())))
key = [r for r in sd if r["mover_index"] == "1"]
if len(key) > 5:
    print("  Spearman(rating, stable depth of key move): %.2f (n=%d)" % (
        spearman([int(r["rating"]) for r in key], [int(r["stable_depth"]) for r in key]), len(key)))
    mx = []
    for pid, rs in puzzles.items():
        ds = [int(r["stable_depth"]) for r in rs if r["stable_depth"] not in ("",)]
        if ds:
            mx.append((int(rs[0]["rating"]), max(ds)))
    print("  Spearman(rating, max stable depth over the line): %.2f (n=%d)" % (
        spearman([a for a, _ in mx], [b for _, b in mx]), len(mx)))

# ---- candidate puzzle definitions of ! and !! (needs features.tcl columns) ----
if rows and "quiet" in rows[0]:
    def sac(r):
        return r["is_best"] == "1" and r["hanging"] not in ("",) and int(r["hanging"]) >= 2
    def sd(r):
        return int(r["stable_depth"]) if r["stable_depth"] not in ("",) else 99
    defs = {
        "A refine as is (!=great, !!=brilliant)":
            (lambda r: r["refined"] == "great", lambda r: r["refined"] == "brilliant"),
        "A' refine, !! without the +5 cap (approx.)":
            (lambda r: r["refined"] == "great" and not sac(r), lambda r: r["refined"] == "brilliant" or sac(r)),
        "B !=quiet only-move, !!=sacrifice":
            (lambda r: r["quiet"] == "1" and not sac(r), sac),
        "C !=engine needs depth>=4, !!=sacrifice":
            (lambda r: sd(r) >= 4 and not sac(r), sac),
        "D !=quiet or depth>=4, !!=sacrifice":
            (lambda r: (r["quiet"] == "1" or sd(r) >= 4) and not sac(r), sac),
        "E !=key move, !!=sacrifice":
            (lambda r: r["mover_index"] == "1" and not sac(r), sac),
    }
    print("\n== candidate definitions: share of solver moves, and validity vs Lichess rating ==")
    print("   (validity = Spearman between puzzle rating and the puzzle's max score M = V + sum b + C)")
    for name, (one, two) in defs.items():
        n1 = sum(1 for r in rows if one(r))
        n2 = sum(1 for r in rows if two(r))
        rat, mx, cnt0 = [], [], 0
        for pid, rs in puzzles.items():
            b = sum(2 if two(r) else (1 if one(r) else 0) for r in rs)
            if b == 0:
                cnt0 += 1
            rat.append(int(rs[0]["rating"]))
            mx.append(2 + b)
        print(f"  {name:42s} ! {pct(n1, n_m)}  !! {pct(n2, n_m)}  no-mark puzzles {pct(cnt0, n_p)}  rho={spearman(rat, mx):.2f}")
    rat = [int(rs[0]["rating"]) for rs in puzzles.values()]
    ln = [len(rs) for rs in puzzles.values()]
    print(f"  {'(reference) number of solver moves':42s} rho={spearman(rat, ln):.2f}")
