#!/data/data/com.termux/files/usr/bin/bash
# ds-os-next-suite-installer.sh
# - Upgrade OS modules to "real" implementations (fs, backup, apk, sync)
# - Add next OS subsystems (permissions, sandbox, scheduler, IPC, kernel, plugins, VFS, profiler, health)
# - Add simple web GUI + Python desktop client skeletons

set -e

echo "[+] Ensuring folders..."
mkdir -p docs
mkdir -p tools
mkdir -p web/gui
mkdir -p source/DroidShell/app/src/main/java/com/droidshell/os/modules
mkdir -p source/DroidShell/app/src/main/java/com/droidshell/os/subsystems

########################################
# DOCS
########################################
echo "[+] Writing docs/droidshell-os-next.md..."
cat << 'EOT' > docs/droidshell-os-next.md
# DroidShell OS Next Layer

This layer adds:

- Real-ish implementations for:
  - fs.list
  - backup.app
  - apk.disassemble
  - apk.rebuild
  - sync.push / sync.pull

- New subsystems:
  - permissions engine
  - sandbox
  - scheduler
  - IPC bus
  - kernel event dispatcher
  - plugin marketplace
  - virtual filesystem
  - profiler
  - health/metrics

- GUI / Desktop:
  - Minimal web GUI (HTML + JS)
  - Python desktop client skeleton
EOT

########################################
# REAL FS MODULE
########################################
echo "[+] Updating OsFsModule.kt (real scanning)..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/modules/OsFsModule.kt
package com.droidshell.os.modules

import android.content.Context
import org.json.JSONObject
import java.io.File

class OsFsModule(private val ctx: Context) {

    fun list(args: JSONObject): JSONObject {
        val path = args.optString("path", "/sdcard")
        val maxDepth = args.optInt("maxDepth", 1)
        val root = File(path)
        val arr = org.json.JSONArray()
        walk(root, 0, maxDepth, arr)
        return JSONObject().put("entries", arr)
    }

    private fun walk(f: File, depth: Int, maxDepth: Int, out: org.json.JSONArray) {
        if (!f.exists()) return
        out.put(
            JSONObject()
                .put("path", f.absolutePath)
                .put("name", f.name)
                .put("type", if (f.isDirectory) "dir" else "file")
                .put("size", f.length())
                .put("mtime", f.lastModified())
                .put("depth", depth)
        )
        if (f.isDirectory && depth < maxDepth) {
            f.listFiles()?.forEach { child ->
                walk(child, depth + 1, maxDepth, out)
            }
        }
    }
}
EOT

########################################
# REAL BACKUP MODULE
########################################
echo "[+] Updating OsBackupModule.kt (pm path + tar)..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/modules/OsBackupModule.kt
package com.droidshell.os.modules

import android.content.Context
import org.json.JSONObject
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader

class OsBackupModule(private val ctx: Context) {

    fun backupApp(args: JSONObject): JSONObject {
        val pkg = args.optString("package", "com.example.app")
        val mode = args.optString("mode", "both")
        val backupRoot = File("/sdcard/DroidShell/backups")
        backupRoot.mkdirs()
        val archivePath = File(backupRoot, "${pkg}-${mode}.tar").absolutePath

        val apkPath = pmPath(pkg)
        val dataDir = "/data/data/$pkg"

        val cmd = when (mode) {
            "apk"  -> "tar cf \"$archivePath\" \"$apkPath\""
            "data" -> "tar cf \"$archivePath\" \"$dataDir\""
            else   -> "tar cf \"$archivePath\" \"$apkPath\" \"$dataDir\""
        }

        runShell(cmd)

        return JSONObject()
            .put("package", pkg)
            .put("mode", mode)
            .put("archivePath", archivePath)
    }

    private fun pmPath(pkg: String): String {
        val out = runShell("pm path $pkg")
        // expected: package:/data/app/...
        val line = out.lines().firstOrNull { it.startsWith("package:") } ?: return ""
        return line.removePrefix("package:")
    }

    private fun runShell(cmd: String): String {
        val p = Runtime.getRuntime().exec(arrayOf("sh", "-c", cmd))
        val sb = StringBuilder()
        BufferedReader(InputStreamReader(p.inputStream)).use { r ->
            var line: String?
            while (true) {
                line = r.readLine() ?: break
                sb.append(line).append('\n')
            }
        }
        p.waitFor()
        return sb.toString()
    }
}
EOT

########################################
# REAL APK MODULE
########################################
echo "[+] Updating OsApkModule.kt (baksmali/smali hooks)..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/modules/OsApkModule.kt
package com.droidshell.os.modules

import android.content.Context
import org.json.JSONObject
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader

class OsApkModule(private val ctx: Context) {

    // Assumes apktool / baksmali / smali are available in PATH (Termux or embedded tools)
    private val apktool = "apktool"
    private val baksmali = "baksmali"
    private val smali = "smali"

    fun disassemble(args: JSONObject): JSONObject {
        val apkPath = args.optString("apkPath", "/sdcard/app.apk")
        val outDir = args.optString("outDir", "/sdcard/smali")
        File(outDir).mkdirs()

        // Prefer apktool if present, fallback to baksmali
        val cmd = if (hasCmd(apktool)) {
            "$apktool d -f -o \"$outDir\" \"$apkPath\""
        } else {
            "$baksmali disassemble \"$apkPath\" -o \"$outDir\""
        }

        runShell(cmd)

        return JSONObject()
            .put("apkPath", apkPath)
            .put("smaliDir", outDir)
    }

    fun rebuild(args: JSONObject): JSONObject {
        val smaliDir = args.optString("smaliDir", "/sdcard/smali")
        val outApk = args.optString("outApk", "/sdcard/app-rebuilt.apk")

        val cmd = if (hasCmd(apktool)) {
            "$apktool b \"$smaliDir\" -o \"$outApk\""
        } else {
            // Very rough: smali -> classes.dex, then zip with original resources
            val dexOut = "$smaliDir/classes.dex"
            val smaliCmd = "$smali assemble \"$smaliDir\" -o \"$dexOut\""
            runShell(smaliCmd)
            "cp \"$dexOut\" \"$outApk\""
        }

        runShell(cmd)

        return JSONObject()
            .put("smaliDir", smaliDir)
            .put("apkPath", outApk)
    }

    private fun hasCmd(name: String): Boolean {
        val out = runShell("command -v $name || which $name || echo ''")
        return out.trim().isNotEmpty()
    }

    private fun runShell(cmd: String): String {
        val p = Runtime.getRuntime().exec(arrayOf("sh", "-c", cmd))
        val sb = StringBuilder()
        BufferedReader(InputStreamReader(p.inputStream)).use { r ->
            var line: String?
            while (true) {
                line = r.readLine() ?: break
                sb.append(line).append('\n')
            }
        }
        p.waitFor()
        return sb.toString()
    }
}
EOT

########################################
# REAL SYNC MODULE
########################################
echo "[+] Updating OsSyncModule.kt (copy/rsync-like)..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/modules/OsSyncModule.kt
package com.droidshell.os.modules

import android.content.Context
import org.json.JSONObject
import java.io.File

class OsSyncModule(private val ctx: Context) {

    fun push(args: JSONObject): JSONObject {
        val local = args.optString("localPath", "/sdcard/local")
        val remote = args.optString("remotePath", "/sdcard/remote")
        val bytes = copyRecursive(File(local), File(remote))
        return JSONObject().put("bytes", bytes)
    }

    fun pull(args: JSONObject): JSONObject {
        val local = args.optString("localPath", "/sdcard/local")
        val remote = args.optString("remotePath", "/sdcard/remote")
        val bytes = copyRecursive(File(remote), File(local))
        return JSONObject().put("bytes", bytes)
    }

    private fun copyRecursive(src: File, dst: File): Long {
        if (!src.exists()) return 0L
        if (src.isDirectory) {
            if (!dst.exists()) dst.mkdirs()
            var total = 0L
            src.listFiles()?.forEach { child ->
                total += copyRecursive(child, File(dst, child.name))
            }
            return total
        } else {
            dst.parentFile?.mkdirs()
            src.copyTo(dst, overwrite = true)
            return dst.length()
        }
    }
}
EOT

########################################
# SUBSYSTEMS (NEXT 9)
########################################
echo "[+] Writing OS subsystems (permissions, sandbox, scheduler, IPC, kernel, plugins, VFS, profiler, health)..."

cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/subsystems/OsPermissions.kt
package com.droidshell.os.subsystems

import org.json.JSONObject

class OsPermissions {

    fun checkPermission(name: String): JSONObject {
        // Stub: integrate with Android permission APIs / policy engine
        return JSONObject()
            .put("permission", name)
            .put("granted", true)
    }
}
EOT

cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/subsystems/OsSandbox.kt
package com.droidshell.os.subsystems

import org.json.JSONObject

class OsSandbox {

    fun describe(): JSONObject {
        // Stub: describe sandbox constraints, namespaces, etc.
        return JSONObject()
            .put("sandbox", "default")
            .put("isolation", "process")
    }
}
EOT

cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/subsystems/OsScheduler.kt
package com.droidshell.os.subsystems

import org.json.JSONObject

class OsScheduler {

    fun schedule(task: String, whenMs: Long): JSONObject {
        // Stub: integrate with WorkManager / AlarmManager
        return JSONObject()
            .put("task", task)
            .put("scheduledAt", whenMs)
    }
}
EOT

cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/subsystems/OsIpcBus.kt
package com.droidshell.os.subsystems

import org.json.JSONObject

class OsIpcBus {

    fun publish(topic: String, payload: JSONObject): JSONObject {
        // Stub: in-memory bus / future Binder/HTTP bridge
        return JSONObject()
            .put("topic", topic)
            .put("status", "queued")
    }
}
EOT

cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/subsystems/OsKernelEvents.kt
package com.droidshell.os.subsystems

import org.json.JSONObject

class OsKernelEvents {

    fun emit(event: String, data: JSONObject): JSONObject {
        // Stub: event log / metrics
        return JSONObject()
            .put("event", event)
            .put("status", "emitted")
    }
}
EOT

cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/subsystems/OsPluginMarket.kt
package com.droidshell.os.subsystems

import org.json.JSONObject

class OsPluginMarket {

    fun listPlugins(): JSONObject {
        // Stub: later integrate with real plugin registry
        val arr = org.json.JSONArray()
        return JSONObject().put("plugins", arr)
    }
}
EOT

cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/subsystems/OsVfs.kt
package com.droidshell.os.subsystems

import org.json.JSONObject

class OsVfs {

    fun mount(name: String, path: String): JSONObject {
        // Stub: virtual filesystem mount table
        return JSONObject()
            .put("name", name)
            .put("path", path)
            .put("status", "mounted")
    }
}
EOT

cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/subsystems/OsProfiler.kt
package com.droidshell.os.subsystems

import org.json.JSONObject

class OsProfiler {

    fun snapshot(): JSONObject {
        // Stub: CPU/memory snapshot
        return JSONObject()
            .put("cpu", 0.1)
            .put("memMb", 64)
    }
}
EOT

cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/subsystems/OsHealth.kt
package com.droidshell.os.subsystems

import org.json.JSONObject

class OsHealth {

    fun status(): JSONObject {
        // Stub: health summary
        return JSONObject()
            .put("status", "ok")
            .put("uptimeSec", 0)
    }
}
EOT

########################################
# SIMPLE WEB GUI (STATIC)
########################################
echo "[+] Writing minimal web GUI (web/gui/index.html)..."
cat << 'EOT' > web/gui/index.html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>DroidShell OS GUI</title>
  <style>
    body { font-family: sans-serif; margin: 20px; }
    textarea { width: 100%; height: 120px; }
    pre { background: #111; color: #0f0; padding: 10px; overflow: auto; }
    button { padding: 6px 12px; margin-top: 8px; }
  </style>
</head>
<body>
  <h1>DroidShell OS GUI</h1>
  <p>Send JSON requests to the DroidShell OS layer and see responses.</p>

  <h3>Request</h3>
  <textarea id="req"></textarea>
  <br>
  <button onclick="send()">Send</button>

  <h3>Response</h3>
  <pre id="resp"></pre>

  <script>
    const defaultReq = {
      version: "1.0",
      id: "gui-1",
      command: "env.info",
      args: {}
    };
    document.getElementById('req').value = JSON.stringify(defaultReq, null, 2);

    async function send() {
      const txt = document.getElementById('req').value;
      try {
        const res = await fetch('/api/os', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: txt
        });
        const data = await res.json();
        document.getElementById('resp').textContent = JSON.stringify(data, null, 2);
      } catch (e) {
        document.getElementById('resp').textContent = 'Error: ' + e;
      }
    }
  </script>
</body>
</html>
EOT

########################################
# PYTHON WEB SERVER (GUI BACKEND)
########################################
echo "[+] Writing tools/droidshell_gui_server.py..."
cat << 'EOT' > tools/droidshell_gui_server.py
#!/usr/bin/env python3
import os
import json
from flask import Flask, request, send_from_directory, jsonify
import subprocess
import time

HOME = os.path.expanduser("~")
ROOT = os.path.join(HOME, "droidshell", "os")
INBOX = os.path.join(ROOT, "inbox")
OUTBOX = os.path.join(ROOT, "outbox")
REQ = os.path.join(INBOX, "request.json")
RESP = os.path.join(OUTBOX, "response.json")

app = Flask(__name__, static_folder="../web/gui", static_url_path="")

@app.route("/")
def index():
    return send_from_directory(app.static_folder, "index.html")

@app.route("/api/os", methods=["POST"])
def api_os():
    os.makedirs(INBOX, exist_ok=True)
    os.makedirs(OUTBOX, exist_ok=True)

    req_obj = request.get_json(force=True)
    with open(REQ, "w") as f:
        json.dump(req_obj, f)

    if os.path.exists(RESP):
        os.remove(RESP)

    # Optionally ensure service is running via adb/other means externally

    for _ in range(50):
        if os.path.exists(RESP):
            with open(RESP) as f:
                resp_obj = json.load(f)
            return jsonify(resp_obj)
        time.sleep(0.2)

    return jsonify({"status": "error", "error": {"message": "Timeout waiting for OS response"}}), 504

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8765, debug=True)
EOT
chmod +x tools/droidshell_gui_server.py

########################################
# PYTHON DESKTOP CLIENT SKELETON
########################################
echo "[+] Writing tools/droidshell_desktop_client.py..."
cat << 'EOT' > tools/droidshell_desktop_client.py
#!/usr/bin/env python3
import os
import json
import time

HOME = os.path.expanduser("~")
ROOT = os.path.join(HOME, "droidshell", "os")
INBOX = os.path.join(ROOT, "inbox")
OUTBOX = os.path.join(ROOT, "outbox")
REQ = os.path.join(INBOX, "request.json")
RESP = os.path.join(OUTBOX, "response.json")

def send_request(command, args=None, req_id=None):
    os.makedirs(INBOX, exist_ok=True)
    os.makedirs(OUTBOX, exist_ok=True)
    if req_id is None:
        req_id = str(int(time.time() * 1000))
    if args is None:
        args = {}
    req_obj = {
        "version": "1.0",
        "id": req_id,
        "command": command,
        "args": args,
    }
    with open(REQ, "w") as f:
        json.dump(req_obj, f)
    if os.path.exists(RESP):
        os.remove(RESP)
    for _ in range(50):
        if os.path.exists(RESP):
            with open(RESP) as f:
                resp_obj = json.load(f)
            return resp_obj
        time.sleep(0.2)
    raise TimeoutError("Timeout waiting for OS response")

if __name__ == "__main__":
    print("DroidShell Desktop Client")
    print("Requesting env.info...")
    resp = send_request("env.info")
    print(json.dumps(resp, indent=2))
EOT
chmod +x tools/droidshell_desktop_client.py

echo "[✓] ds-os-next-suite: real modules, subsystems, GUI, and desktop client skeleton created."
