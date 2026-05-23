#!/data/data/com.termux/files/usr/bin/bash
# ds-os-advanced-installer.sh
# Single installer (CAT) that:
#  - Replaces module stubs with real implementations (apk, backup, fs, sync)
#  - Adds a simple Electron desktop skeleton + Python client + web dashboard skeleton
#  - Adds next-9 OS subsystems installer (security, sandbox, scheduler, IPC, kernel events, plugin marketplace, vfs, profiler, metrics, health, remote)
#  - All files created as separate CAT blocks (multi-file bundle)
#
# NOTE: This installer writes code and scaffolding only. It does not install native tools (smali/baksmali, tar, adb).
# You must install required host/device tools separately.

set -euo pipefail

ROOT="$PWD"
TERMUX_OS_ROOT="$HOME/droidshell/os"
INBOX="$TERMUX_OS_ROOT/inbox"
OUTBOX="$TERMUX_OS_ROOT/outbox"

echo "[+] Creating queue folders..."
mkdir -p "$INBOX" "$OUTBOX"

echo "[+] Creating repo scaffolding..."
mkdir -p docs
mkdir -p scripts
mkdir -p config
mkdir -p source/DroidShell/app/src/main/java/com/droidshell/os
mkdir -p source/DroidShell/app/src/main/java/com/droidshell/os/modules
mkdir -p source/DroidShell/app/src/main/java/com/droidshell/os/transport
mkdir -p source/DroidShell/app/src/main/res/xml
mkdir -p source/DroidShell/app/src/main/assets
mkdir -p tools/electron
mkdir -p tools/python-client
mkdir -p tools/web-dashboard
mkdir -p installers

########################################
# 1) Replace modules with "real" implementations (Kotlin)
########################################

echo "[+] Writing modules: real implementations (OsApkModule, OsBackupModule, OsFsModule, OsSyncModule)..."

cat << 'KOT' > source/DroidShell/app/src/main/java/com/droidshell/os/modules/OsApkModule.kt
package com.droidshell.os.modules

import android.content.Context
import org.json.JSONObject
import java.io.File
import java.lang.ProcessBuilder

class OsApkModule(private val ctx: Context) {

    // Disassemble APK using baksmali (if available on device)
    fun disassemble(args: JSONObject): JSONObject {
        val apkPath = args.optString("apkPath", "/sdcard/app.apk")
        val outDir = args.optString("outDir", "/sdcard/smali")
        val out = JSONObject()
        try {
            val outDirFile = File(outDir)
            if (!outDirFile.exists()) outDirFile.mkdirs()
            // Try to run baksmali if present
            val pb = ProcessBuilder("sh", "-c", "which baksmali || true")
            val which = pb.start().inputStream.bufferedReader().readText().trim()
            if (which.isNotEmpty()) {
                val cmd = "baksmali disassemble -o '${outDir}' '${apkPath}'"
                val p = ProcessBuilder("sh", "-c", cmd).redirectErrorStream(true).start()
                val log = p.inputStream.bufferedReader().readText()
                p.waitFor()
                out.put("tool", "baksmali")
                out.put("log", log)
            } else {
                out.put("tool", "none")
                out.put("note", "baksmali not found on PATH; created outDir only")
            }
            out.put("apkPath", apkPath)
            out.put("smaliDir", outDir)
            out.put("status", "ok")
        } catch (t: Throwable) {
            out.put("status", "error")
            out.put("message", t.message)
        }
        return out
    }

    // Rebuild APK using smali (if available) and zipalign/apksigner if present (stubbed)
    fun rebuild(args: JSONObject): JSONObject {
        val smaliDir = args.optString("smaliDir", "/sdcard/smali")
        val outApk = args.optString("outApk", "/sdcard/app-rebuilt.apk")
        val out = JSONObject()
        try {
            // Attempt to run smali assemble if available
            val pb = ProcessBuilder("sh", "-c", "which smali || true")
            val which = pb.start().inputStream.bufferedReader().readText().trim()
            if (which.isNotEmpty()) {
                val cmd = "smali assemble '${smaliDir}' -o '${outApk}'"
                val p = ProcessBuilder("sh", "-c", cmd).redirectErrorStream(true).start()
                val log = p.inputStream.bufferedReader().readText()
                p.waitFor()
                out.put("tool", "smali")
                out.put("log", log)
            } else {
                out.put("tool", "none")
                out.put("note", "smali not found; no binary produced")
            }
            out.put("smaliDir", smaliDir)
            out.put("apkPath", outApk)
            out.put("status", "ok")
        } catch (t: Throwable) {
            out.put("status", "error")
            out.put("message", t.message)
        }
        return out
    }
}
KOT

cat << 'KOT' > source/DroidShell/app/src/main/java/com/droidshell/os/modules/OsBackupModule.kt
package com.droidshell.os.modules

import android.content.Context
import org.json.JSONObject
import java.io.File
import java.lang.ProcessBuilder

class OsBackupModule(private val ctx: Context) {

    // Backup APK and optionally app data using pm and tar
    fun backupApp(args: JSONObject): JSONObject {
        val pkg = args.optString("package", "")
        val mode = args.optString("mode", "both") // apk | data | both
        val out = JSONObject()
        try {
            if (pkg.isEmpty()) {
                out.put("status", "error")
                out.put("message", "package argument required")
                return out
            }
            val backupDir = File(ctx.getExternalFilesDir(null), "backups")
            if (!backupDir.exists()) backupDir.mkdirs()
            val timestamp = System.currentTimeMillis()
            val apkArchive = File(backupDir, "${pkg}-${timestamp}.apk")
            val dataArchive = File(backupDir, "${pkg}-${timestamp}-data.tar")
            // Get APK path via pm path
            val pb = ProcessBuilder("sh", "-c", "pm path ${pkg} || true")
            val proc = pb.start()
            val outText = proc.inputStream.bufferedReader().readText().trim()
            proc.waitFor()
            val apkPath = if (outText.startsWith("package:")) outText.removePrefix("package:").trim() else ""
            if ((mode == "apk" || mode == "both") && apkPath.isNotEmpty()) {
                // Copy APK to backup location
                val copyCmd = "cp '${apkPath}' '${apkArchive.absolutePath}'"
                ProcessBuilder("sh", "-c", copyCmd).start().waitFor()
                out.put("apkArchive", apkArchive.absolutePath)
            } else if (mode == "apk") {
                out.put("apkArchive", "apk not found")
            }
            if (mode == "data" || mode == "both") {
                // Use run-as if available (non-root) to tar app data; fallback to tar of /data/data (requires root)
                val tarCmd = "sh -c 'if command -v run-as >/dev/null 2>&1; then run-as ${pkg} tar -cf \"${dataArchive.absolutePath}\" .; else tar -cf \"${dataArchive.absolutePath}\" /data/data/${pkg} 2>/dev/null || echo \"tar-failed\"; fi'"
                val p = ProcessBuilder("sh", "-c", tarCmd).redirectErrorStream(true).start()
                val log = p.inputStream.bufferedReader().readText()
                p.waitFor()
                out.put("dataArchive", dataArchive.absolutePath)
                out.put("dataLog", log)
            }
            out.put("package", pkg)
            out.put("mode", mode)
            out.put("status", "ok")
        } catch (t: Throwable) {
            out.put("status", "error")
            out.put("message", t.message)
        }
        return out
    }
}
KOT

cat << 'KOT' > source/DroidShell/app/src/main/java/com/droidshell/os/modules/OsFsModule.kt
package com.droidshell.os.modules

import android.content.Context
import org.json.JSONObject
import java.io.File

class OsFsModule(private val ctx: Context) {

    fun list(args: JSONObject): JSONObject {
        val path = args.optString("path", "/sdcard")
        val dir = File(path)
        val arr = org.json.JSONArray()
        if (dir.exists() && dir.isDirectory) {
            dir.listFiles()?.forEach { f ->
                arr.put(
                    JSONObject()
                        .put("name", f.name)
                        .put("path", f.absolutePath)
                        .put("type", if (f.isDirectory) "dir" else "file")
                        .put("size", f.length())
                        .put("mtime", f.lastModified())
                )
            }
        } else {
            // Try to resolve logical paths
            if (path.startsWith("app://")) {
                val pkg = path.removePrefix("app://").trimEnd('/')
                val appDir = File("/data/data/${pkg}")
                appDir.listFiles()?.forEach { f ->
                    arr.put(
                        JSONObject()
                            .put("name", f.name)
                            .put("path", f.absolutePath)
                            .put("type", if (f.isDirectory) "dir" else "file")
                            .put("size", f.length())
                            .put("mtime", f.lastModified())
                    )
                }
            }
        }
        return JSONObject().put("entries", arr)
    }

    fun stat(args: JSONObject): JSONObject {
        val path = args.optString("path", "/sdcard")
        val f = File(path)
        val o = JSONObject()
        if (f.exists()) {
            o.put("path", f.absolutePath)
            o.put("type", if (f.isDirectory) "dir" else "file")
            o.put("size", f.length())
            o.put("mtime", f.lastModified())
            o.put("exists", true)
        } else {
            o.put("exists", false)
        }
        return o
    }
}
KOT

cat << 'KOT' > source/DroidShell/app/src/main/java/com/droidshell/os/modules/OsSyncModule.kt
package com.droidshell.os.modules

import android.content.Context
import org.json.JSONObject
import java.io.File
import java.lang.Exception

class OsSyncModule(private val ctx: Context) {

    // Simple copy-based push
    fun push(args: JSONObject): JSONObject {
        val local = args.optString("localPath", "/sdcard/local")
        val remote = args.optString("remotePath", "/sdcard/remote")
        val out = JSONObject()
        try {
            val src = File(local)
            val dst = File(remote)
            if (!src.exists()) {
                out.put("status", "error")
                out.put("message", "local path does not exist")
                return out
            }
            if (src.isDirectory) {
                copyDir(src, dst)
            } else {
                src.copyTo(dst, overwrite = true)
            }
            out.put("bytes", dst.length())
            out.put("status", "ok")
        } catch (e: Exception) {
            out.put("status", "error")
            out.put("message", e.message)
        }
        return out
    }

    // Simple copy-based pull
    fun pull(args: JSONObject): JSONObject {
        val local = args.optString("localPath", "/sdcard/local")
        val remote = args.optString("remotePath", "/sdcard/remote")
        val out = JSONObject()
        try {
            val src = File(remote)
            val dst = File(local)
            if (!src.exists()) {
                out.put("status", "error")
                out.put("message", "remote path does not exist")
                return out
            }
            if (src.isDirectory) {
                copyDir(src, dst)
            } else {
                src.copyTo(dst, overwrite = true)
            }
            out.put("bytes", dst.length())
            out.put("status", "ok")
        } catch (e: Exception) {
            out.put("status", "error")
            out.put("message", e.message)
        }
        return out
    }

    private fun copyDir(src: File, dst: File) {
        if (!dst.exists()) dst.mkdirs()
        src.listFiles()?.forEach { f ->
            val target = File(dst, f.name)
            if (f.isDirectory) copyDir(f, target) else f.copyTo(target, overwrite = true)
        }
    }
}
KOT

########################################
# 2) Update transport file to use Termux home queue (file-based)
########################################

echo "[+] Updating OsTransportFile.kt to use external files dir fallback to Termux home..."

cat << 'KOT' > source/DroidShell/app/src/main/java/com/droidshell/os/transport/OsTransportFile.kt
package com.droidshell.os.transport

import android.content.Context
import com.droidshell.os.OsCommandRouter
import com.droidshell.os.OsRequest
import com.droidshell.os.OsResponse
import org.json.JSONObject
import java.io.File

class OsTransportFile(
    private val ctx: Context,
    private val router: OsCommandRouter
) : Runnable {

    // Prefer external files dir; fallback to Termux home path if available
    private val root: File by lazy {
        val ext = ctx.getExternalFilesDir(null)
        if (ext != null) {
            File(ext, "os")
        } else {
            // Fallback to /data/data/<package>/files/os
            File(ctx.filesDir, "os")
        }
    }
    private val inbox = File(root, "inbox")
    private val outbox = File(root, "outbox")
    private val reqFile = File(inbox, "request.json")
    private val respFile = File(outbox, "response.json")

    @Volatile
    private var running = true

    init {
        inbox.mkdirs()
        outbox.mkdirs()
    }

    fun stop() {
        running = false
    }

    override fun run() {
        while (running) {
            if (reqFile.exists()) {
                try {
                    val text = reqFile.readText()
                    val obj = JSONObject(text)
                    val req = OsRequest(
                        version = obj.optString("version", "1.0"),
                        id = obj.optString("id", null),
                        command = obj.optString("command", ""),
                        args = obj.optJSONObject("args") ?: JSONObject()
                    )
                    val resp = router.handle(req)
                    val out = JSONObject()
                        .put("version", resp.version)
                        .put("id", resp.id)
                        .put("status", resp.status)
                        .put("data", resp.data)
                        .put("error", resp.error)
                    respFile.writeText(out.toString())
                } catch (t: Throwable) {
                    val err = OsResponse(
                        id = null,
                        status = "error",
                        error = JSONObject().put("message", t.message ?: "Unknown error")
                    )
                    val out = JSONObject()
                        .put("version", err.version)
                        .put("id", err.id)
                        .put("status", err.status)
                        .put("data", err.data)
                        .put("error", err.error)
                    respFile.writeText(out.toString())
                } finally {
                    reqFile.delete()
                }
            }
            Thread.sleep(200)
        }
    }
}
KOT

########################################
# 3) GUI layer skeletons
########################################

echo "[+] Writing Electron desktop skeleton (tools/electron)..."

cat << 'EOT' > tools/electron/package.json
{
  "name": "droidshell-desktop",
  "version": "0.1.0",
  "main": "main.js",
  "scripts": {
    "start": "electron ."
  },
  "devDependencies": {
    "electron": "^25.0.0"
  }
}
EOT

cat << 'EOT' > tools/electron/main.js
const { app, BrowserWindow, ipcMain } = require('electron')
const path = require('path')
function createWindow () {
  const win = new BrowserWindow({
    width: 1000,
    height: 700,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: true,
      contextIsolation: false
    }
  })
  win.loadFile('index.html')
}
app.whenReady().then(createWindow)
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit()
})
EOT

cat << 'EOT' > tools/electron/index.html
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>DroidShell Desktop</title></head>
  <body>
    <h1>DroidShell Desktop (Skeleton)</h1>
    <p>Use the CLI or the web dashboard to send commands. This is a minimal Electron shell.</p>
    <div id="log"></div>
  </body>
</html>
EOT

cat << 'EOT' > tools/electron/preload.js
// Preload stub
window.addEventListener('DOMContentLoaded', () => {
  // UI wiring can be added here
})
EOT

echo "[+] Writing Python client (tools/python-client)..."

cat << 'EOT' > tools/python-client/client.py
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
EOT
chmod +x tools/python-client/client.py

echo "[+] Writing Web dashboard skeleton (tools/web-dashboard)..."

cat << 'EOT' > tools/web-dashboard/index.html
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>DroidShell Web Dashboard</title></head>
  <body>
    <h1>DroidShell Web Dashboard (Skeleton)</h1>
    <p>This is a static skeleton. Implement a small server to POST JSON to the Termux queue.</p>
  </body>
</html>
EOT

########################################
# 4) Next 9 OS subsystems installer (ds-os-next9-installer.sh)
########################################

echo "[+] Writing installers/ds-os-next9-installer.sh..."
cat << 'SH' > installers/ds-os-next9-installer.sh
#!/data/data/com.termux/files/usr/bin/bash
# ds-os-next9-installer.sh — adds next 9 subsystems:
# security (permissions), sandbox, scheduler, ipc, kernel events, plugin marketplace, vfs, profiler, metrics, health, remote-monitor
set -e
BASE="source/DroidShell/app/src/main/java/com/droidshell/os/subsystems"
mkdir -p "$BASE"

echo "[+] Writing PermissionsEngine.kt..."
cat << 'KOT' > "$BASE/PermissionsEngine.kt"
package com.droidshell.os.subsystems

import org.json.JSONObject
import java.io.File

class PermissionsEngine(private val storageDir: File) {
    private val permFile = File(storageDir, "permissions.map")
    init { storageDir.mkdirs(); if (!permFile.exists()) permFile.createNewFile() }
    fun grant(subject: String, action: String) {
        permFile.appendText("${subject}:${action}\n")
    }
    fun check(subject: String, action: String): Boolean {
        return permFile.readLines().any { it.trim() == "${subject}:${action}" }
    }
    fun list(): JSONObject {
        val arr = org.json.JSONArray()
        permFile.readLines().forEach { if (it.isNotBlank()) arr.put(it.trim()) }
        return JSONObject().put("permissions", arr)
    }
}
KOT

echo "[+] Writing Sandbox.kt..."
cat << 'KOT' > "$BASE/Sandbox.kt"
package com.droidshell.os.subsystems

import java.io.File

class Sandbox(private val root: File) {
    init { if (!root.exists()) root.mkdirs() }
    fun runCommand(cmd: String): String {
        // Very small sandbox: run command in a chroot-like directory (not real chroot)
        val p = ProcessBuilder("sh", "-c", cmd).directory(root).redirectErrorStream(true).start()
        val out = p.inputStream.bufferedReader().readText()
        p.waitFor()
        return out
    }
}
KOT

echo "[+] Writing Scheduler.kt..."
cat << 'KOT' > "$BASE/Scheduler.kt"
package com.droidshell.os.subsystems

import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

class Scheduler {
    private val ex = Executors.newScheduledThreadPool(1)
    fun schedule(delaySec: Long, runnable: Runnable) {
        ex.schedule(runnable, delaySec, TimeUnit.SECONDS)
    }
    fun shutdown() { ex.shutdown() }
}
KOT

echo "[+] Writing IPCBus.kt..."
cat << 'KOT' > "$BASE/IPCBus.kt"
package com.droidshell.os.subsystems

import org.json.JSONObject
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.LinkedBlockingQueue

class IPCBus {
    private val queues = ConcurrentHashMap<String, LinkedBlockingQueue<JSONObject>>()
    fun publish(topic: String, msg: JSONObject) {
        queues.computeIfAbsent(topic) { LinkedBlockingQueue() }.put(msg)
    }
    fun subscribe(topic: String) = queues.computeIfAbsent(topic) { LinkedBlockingQueue() }
}
KOT

echo "[+] Writing KernelEvents.kt..."
cat << 'KOT' > "$BASE/KernelEvents.kt"
package com.droidshell.os.subsystems

import org.json.JSONObject

class KernelEvents {
    fun emit(event: String, payload: JSONObject) {
        // Stub: persist or broadcast
    }
}
KOT

echo "[+] Writing PluginMarketplace.kt..."
cat << 'KOT' > "$BASE/PluginMarketplace.kt"
package com.droidshell.os.subsystems

import org.json.JSONObject
import java.io.File

class PluginMarketplace(private val dir: File) {
    init { if (!dir.exists()) dir.mkdirs() }
    fun list(): JSONObject {
        val arr = org.json.JSONArray()
        dir.listFiles()?.forEach { arr.put(it.name) }
        return JSONObject().put("plugins", arr)
    }
}
KOT

echo "[+] Writing VirtualFS.kt..."
cat << 'KOT' > "$BASE/VirtualFS.kt"
package com.droidshell.os.subsystems

import org.json.JSONObject
import java.io.File

class VirtualFS(private val root: File) {
    init { if (!root.exists()) root.mkdirs() }
    fun resolve(logical: String): File {
        // simple mapping: app://pkg -> /data/data/pkg
        return if (logical.startsWith("app://")) {
            File("/data/data/" + logical.removePrefix("app://").trimEnd('/'))
        } else {
            File(logical)
        }
    }
}
KOT

echo "[+] Writing Profiler.kt..."
cat << 'KOT' > "$BASE/Profiler.kt"
package com.droidshell.os.subsystems

import java.io.File

class Profiler(private val log: File) {
    init { if (!log.exists()) log.parentFile.mkdirs() }
    fun start() { log.appendText("START ${System.currentTimeMillis()}\n") }
    fun stop() { log.appendText("STOP ${System.currentTimeMillis()}\n") }
}
KOT

echo "[+] Writing Metrics.kt..."
cat << 'KOT' > "$BASE/Metrics.kt"
package com.droidshell.os.subsystems

import org.json.JSONObject
import java.io.File

class Metrics(private val file: File) {
    init { if (!file.exists()) file.parentFile.mkdirs() }
    fun collect(): JSONObject {
        val o = JSONObject()
        o.put("timestamp", System.currentTimeMillis())
        // stub metrics
        o.put("freeSpace", file.freeSpace)
        return o
    }
}
KOT

echo "[+] Writing Health.kt..."
cat << 'KOT' > "$BASE/Health.kt"
package com.droidshell.os.subsystems

import org.json.JSONObject

class Health {
    fun check(): JSONObject {
        val o = org.json.JSONObject()
        o.put("status", "ok")
        o.put("timestamp", System.currentTimeMillis())
        return o
    }
}
KOT

echo "[+] Writing RemoteMonitor.kt..."
cat << 'KOT' > "$BASE/RemoteMonitor.kt"
package com.droidshell.os.subsystems

import org.json.JSONObject

class RemoteMonitor {
    fun ping(): JSONObject {
        return JSONObject().put("alive", true).put("ts", System.currentTimeMillis())
    }
}
KOT

echo "[✓] Next-9 subsystems written to $BASE"
SH
chmod +x installers/ds-os-next9-installer.sh

########################################
# 5) Update Router and Service to expose new subsystems (light touch)
########################################

echo "[+] Updating OsCommandRouter to include subsystem endpoints..."

cat << 'KOT' > source/DroidShell/app/src/main/java/com/droidshell/os/OsCommandRouter.kt
package com.droidshell.os

import com.droidshell.os.modules.OsFsModule
import com.droidshell.os.modules.OsBackupModule
import com.droidshell.os.modules.OsApkModule
import com.droidshell.os.modules.OsSyncModule
import com.droidshell.os.subsystems.*
import org.json.JSONObject

class OsCommandRouter(
    private val env: OsEnvModule,
    private val fs: OsFsModule,
    private val backup: OsBackupModule,
    private val apk: OsApkModule,
    private val sync: OsSyncModule,
    private val perms: PermissionsEngine? = null,
    private val sandbox: Sandbox? = null,
    private val scheduler: Scheduler? = null,
    private val ipc: IPCBus? = null,
    private val kernel: KernelEvents? = null,
    private val plugins: PluginMarketplace? = null,
    private val vfs: VirtualFS? = null,
    private val profiler: Profiler? = null,
    private val metrics: Metrics? = null,
    private val health: Health? = null,
    private val remote: RemoteMonitor? = null
) {
    fun handle(req: OsRequest): OsResponse {
        return try {
            val data = when (req.command) {
                "env.info"        -> env.info()
                "fs.list"         -> fs.list(req.args)
                "fs.stat"         -> fs.stat(req.args)
                "backup.app"      -> backup.backupApp(req.args)
                "apk.disassemble" -> apk.disassemble(req.args)
                "apk.rebuild"     -> apk.rebuild(req.args)
                "sync.push"       -> sync.push(req.args)
                "sync.pull"       -> sync.pull(req.args)
                "perms.grant"     -> { perms?.grant(req.args.optString("subject",""), req.args.optString("action","")); JSONObject().put("status","ok") }
                "perms.check"     -> JSONObject().put("allowed", perms?.check(req.args.optString("subject",""), req.args.optString("action","")) ?: false)
                "sandbox.run"     -> JSONObject().put("output", sandbox?.runCommand(req.args.optString("cmd","")) ?: "no-sandbox")
                "scheduler.schedule" -> { scheduler?.schedule(req.args.optLong("delay",0), Runnable { /* no-op */ }); JSONObject().put("status","scheduled") }
                "ipc.publish"     -> { ipc?.publish(req.args.optString("topic",""), req.args.optJSONObject("msg") ?: JSONObject()); JSONObject().put("status","ok") }
                "kernel.emit"     -> { kernel?.emit(req.args.optString("event",""), req.args.optJSONObject("payload") ?: JSONObject()); JSONObject().put("status","ok") }
                "plugins.list"    -> plugins?.list() ?: JSONObject().put("plugins", org.json.JSONArray())
                "vfs.resolve"     -> JSONObject().put("path", vfs?.resolve(req.args.optString("logical","")).absolutePath ?: "")
                "profiler.start"  -> { profiler?.start(); JSONObject().put("status","ok") }
                "profiler.stop"   -> { profiler?.stop(); JSONObject().put("status","ok") }
                "metrics.collect" -> metrics?.collect() ?: JSONObject()
                "health.check"    -> health?.check() ?: JSONObject().put("status","unknown")
                "remote.ping"     -> remote?.ping() ?: JSONObject().put("alive", false)
                else -> return OsResponse(
                    id = req.id,
                    status = "error",
                    error = JSONObject().put("message", "Unknown command: ${req.command}")
                )
            }
            OsResponse(id = req.id, status = "ok", data = data)
        } catch (t: Throwable) {
            OsResponse(
                id = req.id,
                status = "error",
                error = JSONObject().put("message", t.message ?: "Unknown error")
            )
        }
    }
}
KOT

########################################
# 6) Update OsService to instantiate subsystems
########################################

echo "[+] Updating OsService to instantiate subsystems..."

cat << 'KOT' > source/DroidShell/app/src/main/java/com/droidshell/os/OsService.kt
package com.droidshell.os

import android.app.Service
import android.content.Intent
import android.os.IBinder
import com.droidshell.os.modules.OsApkModule
import com.droidshell.os.modules.OsBackupModule
import com.droidshell.os.modules.OsFsModule
import com.droidshell.os.modules.OsSyncModule
import com.droidshell.os.subsystems.*
import com.droidshell.os.transport.OsTransportFile
import kotlinx.coroutines.*
import java.io.File

class OsService : Service() {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private lateinit var router: OsCommandRouter
    private var fileTransport: OsTransportFile? = null

    override fun onCreate() {
        super.onCreate()
        // instantiate modules
        val env = OsEnvModule(this)
        val fs = OsFsModule(this)
        val backup = OsBackupModule(this)
        val apk = OsApkModule(this)
        val sync = OsSyncModule(this)

        // instantiate subsystems
        val storage = File(this.filesDir, "subsystems")
        val perms = PermissionsEngine(storage)
        val sandbox = Sandbox(File(this.filesDir, "sandbox"))
        val scheduler = Scheduler()
        val ipc = IPCBus()
        val kernel = KernelEvents()
        val plugins = PluginMarketplace(File(this.filesDir, "plugins"))
        val vfs = VirtualFS(File(this.filesDir, "vfs"))
        val profiler = Profiler(File(this.filesDir, "profiler.log"))
        val metrics = Metrics(File(this.filesDir, "metrics.data"))
        val health = Health()
        val remote = RemoteMonitor()

        router = OsCommandRouter(env, fs, backup, apk, sync, perms, sandbox, scheduler, ipc, kernel, plugins, vfs, profiler, metrics, health, remote)
        fileTransport = OsTransportFile(this, router)
        scope.launch {
            fileTransport?.run()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        fileTransport?.stop()
        scope.cancel()
        super.onDestroy()
    }
}
KOT

########################################
# 7) Manifest snippet (write to docs for manual merge)
########################################

echo "[+] Writing docs/manifest-updates.txt..."
cat << 'TXT' > docs/manifest-updates.txt
Add the following to AndroidManifest.xml inside <application>:

<!-- OS Service -->
<service
    android:name=".os.OsService"
    android:exported="true"
    android:foregroundServiceType="dataSync" />

<!-- If you plan to expose HTTP, add INTERNET permission -->
<!-- <uses-permission android:name="android.permission.INTERNET" /> -->

Note: File-based transport uses app external files dir; ensure storage access if needed.
TXT

########################################
# 8) Final notes and make scripts executable
########################################

echo "[+] Making CLI executable..."
chmod +x scripts/droidshell-os
chmod +x installers/ds-os-next9-installer.sh

echo "[✓] ds-os-advanced-installer created and all files written."
echo "Run the next-9 installer if you want to re-generate subsystems in app:"
echo "  bash installers/ds-os-next9-installer.sh"
echo ""
echo "To build APK (after merging manifest changes):"
echo "  cd source/DroidShell && ./gradlew :app:assembleDebug"
