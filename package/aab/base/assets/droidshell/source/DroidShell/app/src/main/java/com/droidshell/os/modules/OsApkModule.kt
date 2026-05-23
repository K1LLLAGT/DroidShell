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
