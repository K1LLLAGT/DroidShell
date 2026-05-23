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
