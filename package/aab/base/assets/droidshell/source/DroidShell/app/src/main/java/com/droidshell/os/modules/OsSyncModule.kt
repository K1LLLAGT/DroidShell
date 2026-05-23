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
