#!/data/data/com.termux/files/usr/bin/bash
# ds-os-full-installer.sh — full DroidShell OS layer (transports + modules + CLI)

set -e

ROOT="$HOME/droidshell/os"
INBOX="$ROOT/inbox"
OUTBOX="$ROOT/outbox"

echo "[+] Creating OS queue folders at $ROOT..."
mkdir -p "$INBOX" "$OUTBOX"

echo "[+] Creating source and script folders..."
mkdir -p docs
mkdir -p scripts
mkdir -p config
mkdir -p source/DroidShell/app/src/main/java/com/droidshell/os
mkdir -p source/DroidShell/app/src/main/java/com/droidshell/os/modules
mkdir -p source/DroidShell/app/src/main/java/com/droidshell/os/transport
mkdir -p source/DroidShell/app/src/main/res/xml
mkdir -p source/DroidShell/app/src/main/assets

########################################
# DOCS
########################################
echo "[+] Writing docs/droidshell-os-layer.md..."
cat << 'EOT' > docs/droidshell-os-layer.md
# DroidShell OS Layer

## API

- Transport: JSON over file queue (default), Binder (stub), HTTP (stub)
- Request:
  - version, id, command, args
- Response:
  - version, id, status, data, error

Core commands (v1):

- env.info
- fs.list
- backup.app
- apk.disassemble
- apk.rebuild
- sync.push
- sync.pull
EOT

echo "[+] Writing docs/droidshell-os-transports.md..."
cat << 'EOT' > docs/droidshell-os-transports.md
# DroidShell OS Transports

## Default: File Queue

Root:
  ~/droidshell/os/
    inbox/request.json
    outbox/response.json

CLI:
  - writes JSON request to inbox/request.json
  - waits for outbox/response.json
  - prints response

Service:
  - polls inbox/request.json
  - processes request
  - writes outbox/response.json

## Binder / HTTP

Binder and HTTP transports are stubbed for future expansion.
EOT

echo "[+] Writing docs/droidshell-os-cli.md..."
cat << 'EOT' > docs/droidshell-os-cli.md
# DroidShell OS CLI

Usage examples:

  droidshell-os env.info
  droidshell-os fs.list --path /sdcard
  droidshell-os backup.app --package com.example.app --mode both

The CLI:
- builds a JSON request
- writes it to ~/droidshell/os/inbox/request.json
- waits for ~/droidshell/os/outbox/response.json
- prints the JSON response
EOT

########################################
# HOST-SIDE CLI
########################################
echo "[+] Writing scripts/droidshell-os..."
cat << 'EOT' > scripts/droidshell-os
#!/data/data/com.termux/files/usr/bin/bash
# droidshell-os — host CLI for DroidShell OS layer (file-queue transport)

ROOT="$HOME/droidshell/os"
INBOX="$ROOT/inbox"
OUTBOX="$ROOT/outbox"
REQ="$INBOX/request.json"
RESP="$OUTBOX/response.json"

mkdir -p "$INBOX" "$OUTBOX"

usage() {
  echo "Usage:"
  echo "  droidshell-os env.info"
  echo "  droidshell-os fs.list --path <path>"
  echo "  droidshell-os backup.app --package <id> --mode <apk|data|both>"
  echo "  droidshell-os apk.disassemble --apk <path> --out <dir>"
  echo "  droidshell-os apk.rebuild --smali <dir> --out <apk>"
  echo "  droidshell-os sync.push --local <path> --remote <path>"
  echo "  droidshell-os sync.pull --local <path> --remote <path>"
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

COMMAND="$1"
shift

ID="$(date +%s%N)"

build_args() {
  cmd="$1"; shift
  case "$cmd" in
    env.info)
      echo '{}'
      ;;
    fs.list)
      while [ $# -gt 0 ]; do
        case "$1" in
          --path) PATH_VAL="$2"; shift 2 ;;
          *) shift ;;
        esac
      done
      echo "{ \"path\": \"${PATH_VAL:-/sdcard}\" }"
      ;;
    backup.app)
      while [ $# -gt 0 ]; do
        case "$1" in
          --package) PKG="$2"; shift 2 ;;
          --mode) MODE="$2"; shift 2 ;;
          *) shift ;;
        esac
      done
      echo "{ \"package\": \"${PKG:-com.example.app}\", \"mode\": \"${MODE:-both}\" }"
      ;;
    apk.disassemble)
      while [ $# -gt 0 ]; do
        case "$1" in
          --apk) APK="$2"; shift 2 ;;
          --out) OUT="$2"; shift 2 ;;
          *) shift ;;
        esac
      done
      echo "{ \"apkPath\": \"${APK:-/sdcard/app.apk}\", \"outDir\": \"${OUT:-/sdcard/smali}\" }"
      ;;
    apk.rebuild)
      while [ $# -gt 0 ]; do
        case "$1" in
          --smali) SMALI="$2"; shift 2 ;;
          --out) OUT="$2"; shift 2 ;;
          *) shift ;;
        esac
      done
      echo "{ \"smaliDir\": \"${SMALI:-/sdcard/smali}\", \"outApk\": \"${OUT:-/sdcard/app-rebuilt.apk}\" }"
      ;;
    sync.push|sync.pull)
      while [ $# -gt 0 ]; do
        case "$1" in
          --local) LOCAL="$2"; shift 2 ;;
          --remote) REMOTE="$2"; shift 2 ;;
          *) shift ;;
        esac
      done
      echo "{ \"localPath\": \"${LOCAL:-/sdcard/local}\", \"remotePath\": \"${REMOTE:-/sdcard/remote}\" }"
      ;;
    *)
      echo '{}'
      ;;
  esac
}

ARGS_JSON="$(build_args "$COMMAND" "$@")"

cat > "$REQ" <<JSON
{
  "version": "1.0",
  "id": "$ID",
  "command": "$COMMAND",
  "args": $ARGS_JSON
}
JSON

rm -f "$RESP"

echo "[CLI] Wrote request to $REQ"
echo "[CLI] Waiting for response..."

for i in $(seq 1 50); do
  if [ -f "$RESP" ]; then
    cat "$RESP"
    exit 0
  fi
  sleep 0.2
done

echo "[CLI] Timeout waiting for response at $RESP" >&2
exit 1
EOT
chmod +x scripts/droidshell-os

########################################
# KOTLIN CORE: JSON MODELS
########################################
echo "[+] Writing OsJson.kt..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/OsJson.kt
package com.droidshell.os

import org.json.JSONObject

data class OsRequest(
    val version: String,
    val id: String?,
    val command: String,
    val args: JSONObject
)

data class OsResponse(
    val version: String = "1.0",
    val id: String?,
    val status: String,
    val data: JSONObject = JSONObject(),
    val error: JSONObject? = null
)
EOT

########################################
# KOTLIN CORE: ENV MODULE
########################################
echo "[+] Writing OsEnvModule.kt..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/OsEnvModule.kt
package com.droidshell.os

import android.content.Context
import android.os.Build
import org.json.JSONObject

class OsEnvModule(private val ctx: Context) {

    fun info(): JSONObject {
        return JSONObject()
            .put("device", Build.MODEL)
            .put("manufacturer", Build.MANUFACTURER)
            .put("apiLevel", Build.VERSION.SDK_INT)
            .put("sdkInt", Build.VERSION.SDK_INT)
            .put("os", "Android")
    }
}
EOT

########################################
# KOTLIN MODULES
########################################
echo "[+] Writing OsFsModule.kt..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/modules/OsFsModule.kt
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
                        .put("type", if (f.isDirectory) "dir" else "file")
                        .put("size", f.length())
                        .put("mtime", f.lastModified())
                )
            }
        }
        return JSONObject().put("entries", arr)
    }
}
EOT

echo "[+] Writing OsBackupModule.kt..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/modules/OsBackupModule.kt
package com.droidshell.os.modules

import android.content.Context
import org.json.JSONObject

class OsBackupModule(private val ctx: Context) {

    fun backupApp(args: JSONObject): JSONObject {
        val pkg = args.optString("package", "com.example.app")
        val mode = args.optString("mode", "both")
        // Stub: real implementation would use pm / backup APIs
        val archivePath = "/sdcard/DroidShell/backups/${pkg}-${mode}.tar"
        return JSONObject()
            .put("package", pkg)
            .put("mode", mode)
            .put("archivePath", archivePath)
    }
}
EOT

echo "[+] Writing OsApkModule.kt..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/modules/OsApkModule.kt
package com.droidshell.os.modules

import android.content.Context
import org.json.JSONObject

class OsApkModule(private val ctx: Context) {

    fun disassemble(args: JSONObject): JSONObject {
        val apkPath = args.optString("apkPath", "/sdcard/app.apk")
        val outDir = args.optString("outDir", "/sdcard/smali")
        // Stub: real implementation would call smali/baksmali
        return JSONObject()
            .put("apkPath", apkPath)
            .put("smaliDir", outDir)
    }

    fun rebuild(args: JSONObject): JSONObject {
        val smaliDir = args.optString("smaliDir", "/sdcard/smali")
        val outApk = args.optString("outApk", "/sdcard/app-rebuilt.apk")
        // Stub: real implementation would call build tools
        return JSONObject()
            .put("smaliDir", smaliDir)
            .put("apkPath", outApk)
    }
}
EOT

echo "[+] Writing OsSyncModule.kt..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/modules/OsSyncModule.kt
package com.droidshell.os.modules

import android.content.Context
import org.json.JSONObject
import java.io.File

class OsSyncModule(private val ctx: Context) {

    fun push(args: JSONObject): JSONObject {
        val local = args.optString("localPath", "/sdcard/local")
        val remote = args.optString("remotePath", "/sdcard/remote")
        // Stub: simple copy
        val src = File(local)
        val dst = File(remote)
        src.copyTo(dst, overwrite = true)
        return JSONObject().put("bytes", dst.length())
    }

    fun pull(args: JSONObject): JSONObject {
        val local = args.optString("localPath", "/sdcard/local")
        val remote = args.optString("remotePath", "/sdcard/remote")
        // Stub: simple copy reverse
        val src = File(remote)
        val dst = File(local)
        src.copyTo(dst, overwrite = true)
        return JSONObject().put("bytes", dst.length())
    }
}
EOT

########################################
# TRANSPORTS
########################################
echo "[+] Writing OsTransportFile.kt..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/transport/OsTransportFile.kt
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

    private val root = File(ctx.getExternalFilesDir(null), "os")
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
EOT

echo "[+] Writing OsTransportBinder.kt (stub)..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/transport/OsTransportBinder.kt
package com.droidshell.os.transport

// Stub for future Binder-based transport
class OsTransportBinder
EOT

echo "[+] Writing OsTransportHttp.kt (stub)..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/transport/OsTransportHttp.kt
package com.droidshell.os.transport

// Stub for future HTTP-based transport
class OsTransportHttp
EOT

########################################
# COMMAND ROUTER
########################################
echo "[+] Writing OsCommandRouter.kt..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/OsCommandRouter.kt
package com.droidshell.os

import com.droidshell.os.modules.OsFsModule
import com.droidshell.os.modules.OsBackupModule
import com.droidshell.os.modules.OsApkModule
import com.droidshell.os.modules.OsSyncModule
import org.json.JSONObject

class OsCommandRouter(
    private val env: OsEnvModule,
    private val fs: OsFsModule,
    private val backup: OsBackupModule,
    private val apk: OsApkModule,
    private val sync: OsSyncModule
) {
    fun handle(req: OsRequest): OsResponse {
        return try {
            val data = when (req.command) {
                "env.info"        -> env.info()
                "fs.list"         -> fs.list(req.args)
                "backup.app"      -> backup.backupApp(req.args)
                "apk.disassemble" -> apk.disassemble(req.args)
                "apk.rebuild"     -> apk.rebuild(req.args)
                "sync.push"       -> sync.push(req.args)
                "sync.pull"       -> sync.pull(req.args)
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
EOT

########################################
# SERVICE
########################################
echo "[+] Writing OsService.kt..."
cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/OsService.kt
package com.droidshell.os

import android.app.Service
import android.content.Intent
import android.os.IBinder
import com.droidshell.os.modules.OsApkModule
import com.droidshell.os.modules.OsBackupModule
import com.droidshell.os.modules.OsFsModule
import com.droidshell.os.modules.OsSyncModule
import com.droidshell.os.transport.OsTransportFile
import kotlinx.coroutines.*

class OsService : Service() {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private lateinit var router: OsCommandRouter
    private var fileTransport: OsTransportFile? = null

    override fun onCreate() {
        super.onCreate()
        router = OsCommandRouter(
            OsEnvModule(this),
            OsFsModule(this),
            OsBackupModule(this),
            OsApkModule(this),
            OsSyncModule(this)
        )
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
EOT

echo "[✓] DroidShell OS full layer (transports + modules + CLI) created."
