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
