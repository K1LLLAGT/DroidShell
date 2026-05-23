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
