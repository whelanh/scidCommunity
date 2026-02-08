import subprocess
import json
import time
import os

def test_headless_api():
    print("Testing scidCommunity Headless API...")
    
    # Path to the compiled binary
    cmd = ["./build/scidCommunity", "--headless"]
    
    if not os.path.exists("./build/scidCommunity"):
        print("Error: scidCommunity binary not found in ./build/")
        return

    try:
        # Spawn the process
        proc = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1
        )
        
        def send_request(req):
            print(f"\nSending: {json.dumps(req)}")
            proc.stdin.write(json.dumps(req) + "\n")
            proc.stdin.flush()
            line = proc.stdout.readline()
            if line:
                resp = json.loads(line)
                print(f"Received: {json.dumps(resp, indent=2)}")
                return resp
            return None

        # 1. Test get_version
        resp = send_request({"jsonrpc": "2.0", "method": "get_version", "id": 1})
        if resp and "result" in resp:
            print("✓ get_version test PASSED")

        # 2. Test db_open
        resp = send_request({
            "jsonrpc": "2.0", 
            "method": "db_open", 
            "params": {"path": "test.pgn", "type": "PGN"}, 
            "id": 2
        })
        handle = None
        if resp and "result" in resp:
            handle = resp["result"]["handle"]
            print(f"✓ db_open test PASSED (Handle: {handle})")

        if handle is not None:
            # 3. Test db_info
            resp = send_request({"jsonrpc": "2.0", "method": "db_info", "params": {"handle": handle}, "id": 3})
            if resp and "result" in resp:
                print("✓ db_info test PASSED")

            # 4. Test db_search (e.g. White matches "Player White")
            resp = send_request({
                "jsonrpc": "2.0", 
                "method": "db_search", 
                "params": {"handle": handle, "white": "Player White"}, 
                "id": 4
            })
            if resp and "result" in resp:
                print("✓ db_search test PASSED")
                if resp["result"]["count"] > 0:
                    print(f"  Matches found: {resp['result']['count']}")
                else:
                    print("  ! No matches found (expected at least 1)")

            # 5. Test game_get
            resp = send_request({
                "jsonrpc": "2.0", 
                "method": "game_get", 
                "params": {"handle": handle, "id": 1}, 
                "id": 5
            })
            if resp and "result" in resp:
                print("✓ game_get test PASSED")
                pgn = resp["result"].get("pgn", "")
                if pgn:
                    print("  PGN data received successfully")
                else:
                    print("  ! PGN data missing")

        # Cleanup
        proc.terminate()
        proc.wait(timeout=5)
        print("\nTests completed.")
        
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    test_headless_api()
