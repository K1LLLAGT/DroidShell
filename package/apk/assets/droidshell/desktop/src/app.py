#!/usr/bin/env python3
"""
DroidShell Desktop Companion — Flask prototype
"""
from flask import Flask, jsonify
from flask_cors import CORS
import subprocess, json, os

app = Flask(__name__)
CORS(app)

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))

def run_ds(script, *args):
    path = os.path.join(BASE_DIR, "scripts", script)
    result = subprocess.run(["bash", path, *args],
                            capture_output=True, text=True, timeout=30)
    return {"stdout": result.stdout, "stderr": result.stderr,
            "returncode": result.returncode}

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

@app.route("/version")
def version():
    vfile = os.path.join(BASE_DIR, "VERSION")
    ver = open(vfile).read().strip() if os.path.exists(vfile) else "unknown"
    return jsonify({"version": ver})

@app.route("/ota/metadata")
def ota_metadata():
    mfile = os.path.join(BASE_DIR, "ota", "metadata.json")
    if os.path.exists(mfile):
        return jsonify(json.load(open(mfile)))
    return jsonify({"error": "metadata not found"}), 404

@app.route("/plugins")
def plugins():
    pdir = os.path.join(BASE_DIR, "plugins")
    names = [d for d in os.listdir(pdir)
             if os.path.isdir(os.path.join(pdir, d))] if os.path.isdir(pdir) else []
    return jsonify({"plugins": names})

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=True)
