# Flatten Lichess batch JSON files into one TSV row per puzzle (stdlib only).
# Usage: python3 -I extract.py out.tsv batch1.json [batch2.json ...]
import json, sys

out = open(sys.argv[1], "w")
seen = set()
for path in sys.argv[2:]:
    tier = path.rsplit("_", 1)[-1].split(".")[0]
    data = json.load(open(path))
    for e in data.get("puzzles", []):
        p, g = e["puzzle"], e["game"]
        if p["id"] in seen:
            continue
        seen.add(p["id"])
        out.write("\t".join([
            p["id"], tier, str(p["rating"]), str(p["initialPly"]),
            " ".join(p["solution"]), ",".join(p["themes"]), g["pgn"],
        ]) + "\n")
out.close()
print(len(seen), "puzzles")
