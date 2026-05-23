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
