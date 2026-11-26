#!/usr/bin/env python3
"""End-to-end test for searching a database by position (FEN).

Creates a temporary Scid database, adds a few games and exercises every
db_search position option through the JSON-RPC headless interface.

Usage: scripts/test_headless_position.py [path-to-scidCommunity]
"""

import json
import os
import shutil
import subprocess
import sys
import tempfile

GAME_NAJDORF = """[Event "Najdorf"]
[White "Alice"]
[Black "Bob"]
[Result "1-0"]

1. e4 c5 2. Nf3 d6 3. d4 cxd4 4. Nxd4 Nf6 5. Nc3 a6 6. Be3 e5 1-0
"""

GAME_BERLIN = """[Event "Berlin"]
[White "Carol"]
[Black "Dave"]
[Result "1/2-1/2"]

1. e4 e5 2. Nf3 Nc6 3. Bb5 Nf6 4. O-O Nxe4 1/2-1/2
"""

GAME_VARIATION = """[Event "Variation"]
[White "Erin"]
[Black "Frank"]
[Result "1-0"]

1. e4 (1. d4 d5 2. c4 e6) 1... e5 2. Nf3 1-0
"""

FEN_NAJDORF = "rnbqkb1r/1p2pppp/p2p1n2/8/3NP3/2N5/PPP2PPP/R1BQKB1R w KQkq - 0 7"
FEN_NAJDORF_BLACK = "rnbqkb1r/1p2pppp/p2p1n2/8/3NP3/2N5/PPP2PPP/R1BQKB1R b KQkq - 0 7"
FEN_NAJDORF_NO_KNIGHT = "rnbqkb1r/1p2pppp/p2p1n2/8/3NP3/8/PPP2PPP/RNBQKB1R w KQkq - 0 7"
FEN_VARIATION_LAST = "rnbqkbnr/ppp2ppp/4p3/3p4/2PP4/8/PP2PPPP/RNBQKBNR w KQkq - 0 4"
# Mirror image (colors swapped) of the Berlin position after 3.Bb5.
FEN_BERLIN_MIRROR = "rnbqk2r/pppp1ppp/5n2/4p3/1b2P3/2N5/PPPP1PPP/R1BQKBNR w KQkq - 0 1"


def find_binary():
    if len(sys.argv) > 1:
        return sys.argv[1]
    for candidate in ("./build/scidCommunity", "./scidCommunity"):
        if os.path.exists(candidate):
            return candidate
    sys.exit("scidCommunity binary not found (pass its path as an argument)")


class Client:
    def __init__(self, binary):
        self.proc = subprocess.Popen(
            [binary, "--headless"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1,
        )
        self.next_id = 0

    def call(self, method, params=None):
        self.next_id += 1
        request = {"jsonrpc": "2.0", "method": method, "id": self.next_id}
        if params is not None:
            request["params"] = params
        self.proc.stdin.write(json.dumps(request) + "\n")
        self.proc.stdin.flush()
        line = self.proc.stdout.readline()
        if not line:
            stderr = self.proc.stderr.read()
            raise RuntimeError(f"no response to {method}; stderr:\n{stderr}")
        return json.loads(line)

    def result(self, method, params=None):
        response = self.call(method, params)
        if "error" in response:
            raise AssertionError(f"{method} failed: {response['error']}")
        return response["result"]

    def error(self, method, params=None):
        response = self.call(method, params)
        if "error" not in response:
            raise AssertionError(f"{method} should have failed: {response}")
        return response["error"]

    def close(self):
        self.proc.stdin.close()
        self.proc.wait(timeout=10)


failures = []


def check(name, actual, expected):
    if actual == expected:
        print(f"  ok   {name}")
    else:
        print(f"  FAIL {name}: got {actual!r}, expected {expected!r}")
        failures.append(name)


def search(client, handle, **params):
    params["handle"] = handle
    return client.result("db_search", params)["matches"]


def main():
    binary = find_binary()
    tmpdir = tempfile.mkdtemp(prefix="scid-position-")
    db_path = os.path.join(tmpdir, "positions")
    client = Client(binary)
    try:
        handle = client.result("db_create", {"path": db_path, "type": "SCID5"})["handle"]
        for pgn in (GAME_NAJDORF, GAME_BERLIN, GAME_VARIATION):
            client.result("game_add", {"handle": handle, "pgn": pgn})

        print("exact position")
        check("main line", search(client, handle, fen=FEN_NAJDORF), [1])
        check("wrong side to move", search(client, handle, fen=FEN_NAJDORF_BLACK), [])
        check("start position",
              search(client, handle,
                     fen="rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"),
              [1, 2, 3])

        print("combining with header criteria")
        check("AND (matching player)",
              search(client, handle, white="Alice", fen=FEN_NAJDORF), [1])
        check("AND (other player)",
              search(client, handle, white="Carol", fen=FEN_NAJDORF), [])
        check("header OR position",
              search(client, handle, white="Carol", fen=FEN_NAJDORF,
                     position_op="or"), [1, 2])

        print("match modes")
        check("exact rejects a moved knight",
              search(client, handle, fen=FEN_NAJDORF_NO_KNIGHT), [])
        check("pawns accepts a moved knight",
              search(client, handle, fen=FEN_NAJDORF_NO_KNIGHT,
                     position_match="pawns"), [1])
        check("material", search(client, handle, fen=FEN_NAJDORF,
                                 position_match="material"), [1])

        print("options")
        check("ignore colors",
              search(client, handle, fen=FEN_BERLIN_MIRROR,
                     position_ignore_colors=True), [2])
        check("ignore colors off",
              search(client, handle, fen=FEN_BERLIN_MIRROR), [])
        check("variations off",
              search(client, handle, fen=FEN_VARIATION_LAST), [])
        check("in variations",
              search(client, handle, fen=FEN_VARIATION_LAST,
                     position_in_variations=True), [3])

        print("errors")
        check("invalid FEN",
              client.error("db_search", {"handle": handle, "fen": "nonsense"})["code"],
              -32602)
        check("unknown parameter",
              client.error("db_search", {"handle": handle, "fenn": FEN_NAJDORF})["message"],
              "Unknown parameter: fenn")
        check("invalid position_match",
              client.error("db_search",
                           {"handle": handle, "fen": FEN_NAJDORF,
                            "position_match": "nope"})["code"],
              -32602)
    finally:
        client.close()
        shutil.rmtree(tmpdir, ignore_errors=True)

    if failures:
        print(f"\n{len(failures)} check(s) failed: {', '.join(failures)}")
        return 1
    print("\nAll position search checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
