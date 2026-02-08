import subprocess
import json
import time
import os

def test_phase3():
    binary_path = "./build/scidCommunity"
    test_db_path = "/tmp/test_create"
    
    # Cleanup old test files if they exist
    for ext in [".si5", ".sn5", ".sg5"]:
        f = test_db_path + ext
        if os.path.exists(f):
            os.remove(f)

    print("Testing Phase 3 Write Operations...")
    
    cmd = ["stdbuf", "-oL", binary_path, "--headless"]
    proc = subprocess.Popen(
        cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1
    )

    def send(method, params=None):
        req = {"jsonrpc": "2.0", "method": method, "id": int(time.time() * 1000)}
        if params:
            req["params"] = params
        print(f"Sending: {json.dumps(req)}")
        proc.stdin.write(json.dumps(req) + "\n")
        line = proc.stdout.readline()
        if not line:
            return None
        return json.loads(line)

    try:
        # 1. db_create
        res = send("db_create", {"path": test_db_path, "type": "SCID5"})
        if not res or "result" not in res:
            print(f"FAILED db_create: {res}")
            return
        handle = res["result"]["handle"]
        print(f"✓ Created database, handle: {handle}")

        # 2. game_add (PGN)
        pgn_text = '[Event "Test Event"]\n[White "Player 1"]\n[Black "Player 2"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 *'
        res = send("game_add", {"handle": handle, "pgn": pgn_text})
        if not res or "result" not in res or not res["result"].get("success"):
            print(f"FAILED game_add (PGN): {res}")
            return
        print(f"✓ Added game 1 (PGN), ID: {res['result']['id']}")

        # 3. game_add (Tags + Moves in PGN)
        res = send("game_add", {
            "handle": handle, 
            "pgn": "1. d4 d5 2. c4 c6 *",
            "tags": {"White": "Nakamura,Hi", "Black": "Carlsen,M", "Event": "Speed Chess"}
        })
        print(f"✓ Added game 2 (Tags + Moves), ID: {res['result']['id']}")

        # 4. db_info
        res = send("db_info", {"handle": handle})
        count = res["result"]["num_games"]
        print(f"✓ Database info: {count} games total")
        if count != 2:
            print("FAILED: Expected 2 games")
            return

        # 5. game_delete
        res = send("game_delete", {"handle": handle, "id": 1})
        if not res or "result" not in res or not res["result"].get("success"):
            print(f"FAILED game_delete: {res}")
            return
        print("✓ Marked game 1 for deletion")

        # 6. db_compact
        res = send("db_compact", {"handle": handle})
        if not res or "result" not in res or not res["result"].get("success"):
            print(f"FAILED db_compact: {res}")
            return
        print("✓ Compacted database")

        # 7. Final count
        res = send("db_info", {"handle": handle})
        count = res["result"]["num_games"]
        print(f"✓ Final game count after compact: {count}")
        if count != 1:
            print("FAILED: Expected 1 game after compact")
            return

        # 8. db_close
        res = send("db_close", {"handle": handle})
        print("✓ Closed database")

        print("\nALL PHASE 3 TESTS PASSED! 🎉")

    finally:
        proc.terminate()

if __name__ == "__main__":
    test_phase3()
