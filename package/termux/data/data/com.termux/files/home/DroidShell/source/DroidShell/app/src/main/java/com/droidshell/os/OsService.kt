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
