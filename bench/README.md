# Tree-window benchmark

`tree_bench` measures the two phases of a Tree-window refresh without Tcl/Tk:

1. **search** — build the per-position filter (`SearchPos::setFilter`), and
2. **stats** — count the moves played (`scidBaseT::getTreeStat`).

It exists to compare two revisions of the engine on the same base with the
same access pattern, including a *cold* page cache.

## Build

```sh
cmake -S . -B build-bench -DTREE_BENCH=ON -DCMAKE_BUILD_TYPE=Release
cmake --build build-bench --target tree_bench -j
```

## Create a synthetic base

```sh
build-bench/bench/tree_bench --create /path/to/base --games 2000000
```

`--unusual-fraction 0-100` controls how many games start with a move that is
not in the stored-line dictionary (default 5). With 100, every game has
stored-line code 0 and the statistics have to read every game body, which is
the worst case for cold I/O.

The generator is deterministic (fixed seed), so the same command produces the
same base on both revisions. Keep the base outside `/tmp` if `/tmp` is a
tmpfs: a cold measurement needs a real file cache.

## Measure

```sh
# cold: drop the page cache of the base files before every run
build-bench/bench/tree_bench --db /path/to/base --cold --repeat 3

# thread scaling
SCID_TREE_THREADS=1 build-bench/bench/tree_bench --db /path/to/base

# exact-result comparison between two builds (order-independent digest)
build-base/bench/tree_bench --db /path/to/base --depth 4 --digest
build-bench/bench/tree_bench --db /path/to/base --depth 4 --digest
```

Columns: wall time and process CPU time for each phase, minor/major page
faults, bytes actually read from the device, number of matching games and
number of statistics nodes.

`--cold` uses `posix_fadvise(POSIX_FADV_DONTNEED)` on the `.si5`/`.sg5`/`.sn5`
files. It needs no privileges and does not disturb other processes, unlike
`/proc/sys/vm/drop_caches`. The index is loaded into the heap when the base is
opened, so a cold run measures the same state the application has after
opening a database: index warm, game file cold.

The page-fault counters are the reliable signal on a large-RAM machine: a
cache that happens to hold the file can hide the wall-clock difference, but
the number of pages touched (and `read_bytes`) cannot be hidden.

## Reference numbers

Linux, 2,000,000 synthetic games (115 MB `.sg5`), depth 1, cold:

| scenario | revision | search ms | stats ms | major faults |
|---|---|---|---|---|
| start | before | 2.8 | 667.4 | 22,301 |
| start | after | 3.0 | 39.3 | 15 |
| 1.e4 | before | 21.0 | 28.4 | 0 |
| 1.e4 | after | 20.2 | 2.7 | 0 |
| 1.e4 c5 | before | 13.0 | 24.7 | 0 |
| 1.e4 c5 | after | 13.3 | 2.4 | 0 |

Depth 4, same base, cold:

| scenario | revision | stats ms | nodes |
|---|---|---|---|
| start | before | 1054.6 | 53,618 |
| start | after | 100.1 | 53,618 |
| 1.e4 | before | 586.0 | 19 |
| 1.e4 | after | 29.2 | 19 |

Worst case (all games have stored-line code 0, so the statistics must read
every game body), 2,000,000 games, depth 1, cold:

| scenario | revision | stats ms | major faults |
|---|---|---|---|
| start | before | 816.3 | 22,993 |
| start | after | 42.2 | 15 |

Statistics phase, start position, depth 1, by worker count:

| threads | cold ms | warm ms |
|---|---|---|
| 1 | 51.5 | 46.2 |
| 2 | 40.6 | 23.9 |
| 4 | 38.9 | 13.4 |
| 8 | 39.7 | 7.2 |
| 16 | 38.2 | 4.2 |

Once the page cache is warm the pass scales with the cores (11x at 16
threads); when it is cold the sequential readahead makes it disk-bound, so
extra threads buy little.

The digests of the statistics are identical to the previous revision at
depths 1-4 on every scenario.
