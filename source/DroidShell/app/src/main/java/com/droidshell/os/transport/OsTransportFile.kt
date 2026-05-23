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
