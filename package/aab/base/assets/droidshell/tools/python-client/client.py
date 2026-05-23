#!/usr/bin/env python3
"""
Simple Python client to send JSON requests to the Termux file-queue.
Writes request to ~/droidshell/os/inbox/request.json and waits for outbox/response.json
"""
import json, os, time, sys
HOME = os.path.expanduser("~")
INBOX = os.path.join(HOME, "droidshell", "os", "inbox")
OUTBOX = os.path.join(HOME, "droidshell", "os", "outbox")
REQ = os.path.join(INBOX, "request.json")
RESP = os.path.join(OUTBOX, "response.json")

def send(command, args):
    os.makedirs(INBOX, exist_ok=True)
    os.makedirs(OUTBOX, exist_ok=True)
    req = {
        "version": "1.0",
        "id": str(int(time.time()*1000)),
        "command": command,
        "args": args
    }
    with open(REQ, "w") as f:
        json.dump(req, f)
    # wait for response
    for _ in range(50):
        if os.path.exists(RESP):
            with open(RESP) as r:
                print(r.read())
            return
        time.sleep(0.2)
    print("Timeout waiting for response", file=sys.stderr)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: client.py <command> [json-args]")
        sys.exit(1)
    cmd = sys.argv[1]
    args = {}
    if len(sys.argv) > 2:
        try:
            args = json.loads(sys.argv[2])
        except:
            pass
    send(cmd, args)
