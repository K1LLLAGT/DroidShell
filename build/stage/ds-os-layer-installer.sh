#!/data/data/com.termux/files/usr/bin/bash
# ds-os-layer-installer.sh — scaffold DroidShell OS layer (API spec + folders + Kotlin stubs)

set -e

echo "[+] Creating OS layer folders..."
mkdir -p docs
mkdir -p config
mkdir -p scripts
mkdir -p source/DroidShell/app/src/main/java/com/droidshell/os
mkdir -p source/DroidShell/app/src/main/res/xml
mkdir -p source/DroidShell/app/src/main/assets

echo "[+] Writing docs/droidshell-os-layer.md..."
cat << 'EOT' > docs/droidshell-os-layer.md
# DroidShell OS Layer

Your current repo already has source/DroidShell/app and a rich Gradle/CI setup, so we embed the OS layer into this app.

## 1. API Spec

### Transport
- JSON over stdin/stdout
- Optional HTTP

### Request
{
  "version": "1.0",
  "id": "string-or-number",
  "command": "env.info | backup.app | fs.list | apk.disassemble | apk.rebuild | sync.push | sync.pull",
  "args": {}
}

### Response
{
  "version": "1.0",
  "id": "same-as-request",
  "status": "ok | error",
  "data": {},
  "error": { "code": null, "message": null }
}

## 2. Folder Tree

Host:
scripts/
config/

Android:
source/DroidShell/app/src/main/java/com/droidshell/os
source/DroidShell/app/src/main/res/xml
source/DroidShell/app/src/main/assets

## 3. Manifest Snippet

<service
    android:name=".os.OsService"
    android:exported="true"
    android:foregroundServiceType="dataSync">
    <intent-filter>
        <action android:name="com.droidshell.OS_SERVICE" />
    </intent-filter>
</service>

## 4. Build

cd source/DroidShell
./gradlew :app:assembleDebug
EOT

echo "[+] Writing scripts/droidshell-os.sh..."
cat << 'EOT' > scripts/droidshell-os.sh
#!/data/data/com.termux/files/usr/bin/bash
# droidshell-os.sh — host entrypoint for DroidShell OS API (stub)

echo "droidshell-os: transport not wired yet. See docs/droidshell-os-layer.md"
EOT
chmod +x scripts/droidshell-os.sh

echo "[+] Writing Kotlin stubs..."

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

cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/OsCommandRouter.kt
package com.droidshell.os

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

cat << 'EOT' > source/DroidShell/app/src/main/java/com/droidshell/os/OsService.kt
package com.droidshell.os

import android.app.Service
import android.content.Intent
import android.os.IBinder
import kotlinx.coroutines.*

class OsService : Service() {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private lateinit var router: OsCommandRouter

    override fun onCreate() {
        super.onCreate()
        router = OsCommandRouter(
            OsEnvModule(this),
            OsFsModule(this),
            OsBackupModule(this),
            OsApkModule(this),
            OsSyncModule(this)
        )
        // TODO: start listening loop
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        scope.cancel()
        super.onDestroy()
    }
}
EOT

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

echo "[✓] DroidShell OS layer spec and stubs created."
