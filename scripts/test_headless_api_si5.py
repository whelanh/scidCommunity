import subprocess
import json
import os
import sys

def test_real_database():
    print("Testing scidCommunity Headless API with real database...")
    
    # Path to the compiled binary
    binary_path = "./build/scidCommunity"
    db_path = "/home/hugh/Downloads/testTWIC"
    db_type = "SCID5" 
    
    if not os.path.exists(binary_path):
        print(f"Error: binary {binary_path} not found.")
        return

    # Using stdbuf to avoid buffering issues
    cmd = ["stdbuf", "-oL", binary_path, "--headless"]
    
    try:
        print(f"Starting process: {' '.join(cmd)}")
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

        # 1. Open Database
        resp = send_request({
            "jsonrpc": "2.0",
            "method": "db_open",
            "params": {
                "path": db_path,
                "type": db_type
            },
            "id": 1
        })
        
        if not resp or "result" not in resp:
            print("Failed to open database.")
            proc.terminate()
            return

        handle = resp["result"]["handle"]
        
        # 2. Search for Nakamura as White
        resp = send_request({
            "jsonrpc": "2.0",
            "method": "db_search",
            "params": {
                "handle": handle,
                "white": "Nakamura,Hi"
            },
            "id": 2
        })
        
        if resp and "result" in resp:
            count = resp["result"]["count"]
            matches = resp["result"]["matches"]
            print(f"✓ Found {count} games for Nakamura as White.")
            
            if count > 0:
                # 3. Get first game data
                first_game_id = matches[0]
                resp = send_request({
                    "jsonrpc": "2.0",
                    "method": "game_get",
                    "params": {
                        "handle": handle,
                        "id": first_game_id
                    },
                    "id": 3
                })
                if resp and "result" in resp:
                    meta = resp["result"]["metadata"]
                    print(f"✓ Retrieved game: {meta['white']} vs {meta['black']} ({meta['date']})")

        proc.terminate()
        proc.wait(timeout=5)
        print("\nTest completed.")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    test_real_database()
