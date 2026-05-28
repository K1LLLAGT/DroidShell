#!/usr/bin/env bash
set -euo pipefail

# create_droidshell_next_layer.sh
# Adds:
# - Folder Detail Explorer
# - Plugin System (manifest.json reader)
# - Script Execution Engine
# - IPC Bridge
# - Workspace Resolver
#
# Package: com.k1lllagt.droidshell

ROOT="$(pwd)"
APP_DIR="$ROOT/app"
SRC_DIR="$APP_DIR/src/main"
JAVA_DIR="$SRC_DIR/java/com/k1lllagt/droidshell"
RES_DIR="$SRC_DIR/res"
LAYOUT_DIR="$RES_DIR/layout"

mkdir -p "$JAVA_DIR" "$LAYOUT_DIR"

echo "=== Writing WorkspaceResolver.kt ==="
cat > "$JAVA_DIR/WorkspaceResolver.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.content.Context
import java.io.File

object WorkspaceResolver {

    data class Roots(
        val internalRoot: File,
        val publicRoot: File
    )

    fun resolveRoots(context: Context): Roots {
        val internalRoot = File(context.getExternalFilesDir(null), "DroidShell")
        val publicRoot = File("/sdcard/DroidShell")
        return Roots(internalRoot, publicRoot)
    }

    fun resolveFolder(context: Context, folderName: String): File {
        val roots = resolveRoots(context)
        val internal = File(roots.internalRoot, folderName)
        val public = File(roots.publicRoot, folderName)
        return when {
            internal.exists() -> internal
            public.exists() -> public
            else -> internal
        }
    }
}
KOTLIN

echo "=== Writing DroidShellBridge.kt (IPC / shell exec) ==="
cat > "$JAVA_DIR/DroidShellBridge.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.util.Log
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader

object DroidShellBridge {

    data class ExecResult(
        val exitCode: Int,
        val stdout: String,
        val stderr: String
    )

    private const val TAG = "DroidShellBridge"

    fun exec(command: List<String>, workingDir: File? = null): ExecResult {
        return try {
            val pb = ProcessBuilder(command)
            if (workingDir != null) pb.directory(workingDir)
            pb.redirectErrorStream(false)
            val proc = pb.start()

            val stdout = StringBuilder()
            val stderr = StringBuilder()

            BufferedReader(InputStreamReader(proc.inputStream)).use { r ->
                var line: String?
                while (r.readLine().also { line = it } != null) {
                    stdout.appendLine(line)
                }
            }
            BufferedReader(InputStreamReader(proc.errorStream)).use { r ->
                var line: String?
                while (r.readLine().also { line = it } != null) {
                    stderr.appendLine(line)
                }
            }

            val code = proc.waitFor()
            ExecResult(code, stdout.toString(), stderr.toString())
        } catch (e: Exception) {
            Log.e(TAG, "exec failed", e)
            ExecResult(-1, "", e.message ?: "error")
        }
    }

    fun execScript(script: File, args: List<String> = emptyList()): ExecResult {
        val cmd = mutableListOf(script.absolutePath)
        cmd.addAll(args)
        return exec(cmd, script.parentFile)
    }
}
KOTLIN

echo "=== Writing ScriptRunner.kt ==="
cat > "$JAVA_DIR/ScriptRunner.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.content.Context
import java.io.File

object ScriptRunner {

    data class ScriptRunResult(
        val script: File,
        val exitCode: Int,
        val stdout: String,
        val stderr: String
    )

    fun runScript(context: Context, relativePath: String, args: List<String> = emptyList()): ScriptRunResult {
        val roots = WorkspaceResolver.resolveRoots(context)
        val script = listOf(
            File(roots.internalRoot, "scripts/$relativePath"),
            File(roots.publicRoot, "scripts/$relativePath")
        ).firstOrNull { it.exists() } ?: File(roots.internalRoot, "scripts/$relativePath")

        val result = DroidShellBridge.execScript(script, args)
        return ScriptRunResult(script, result.exitCode, result.stdout, result.stderr)
    }
}
KOTLIN

echo "=== Writing ScriptOutputFragment.kt ==="
cat > "$JAVA_DIR/ScriptOutputFragment.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.fragment.app.Fragment

class ScriptOutputFragment : Fragment() {

    companion object {
        private const val ARG_TITLE = "title"
        private const val ARG_STDOUT = "stdout"
        private const val ARG_STDERR = "stderr"
        private const val ARG_EXIT = "exit"

        fun newInstance(title: String, stdout: String, stderr: String, exitCode: Int): ScriptOutputFragment {
            val f = ScriptOutputFragment()
            f.arguments = Bundle().apply {
                putString(ARG_TITLE, title)
                putString(ARG_STDOUT, stdout)
                putString(ARG_STDERR, stderr)
                putInt(ARG_EXIT, exitCode)
            }
            return f
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val v = inflater.inflate(R.layout.fragment_script_output, container, false)
        val titleView = v.findViewById<TextView>(R.id.scriptTitle)
        val stdoutView = v.findViewById<TextView>(R.id.scriptStdout)
        val stderrView = v.findViewById<TextView>(R.id.scriptStderr)
        val exitView = v.findViewById<TextView>(R.id.scriptExitCode)

        val args = requireArguments()
        titleView.text = args.getString(ARG_TITLE, "Script Output")
        stdoutView.text = args.getString(ARG_STDOUT, "")
        stderrView.text = args.getString(ARG_STDERR, "")
        exitView.text = "Exit code: ${args.getInt(ARG_EXIT, -1)}"

        return v
    }
}
KOTLIN

echo "=== Writing fragment_script_output.xml ==="
cat > "$LAYOUT_DIR/fragment_script_output.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="12dp">

    <LinearLayout
        android:orientation="vertical"
        android:layout_width="match_parent"
        android:layout_height="wrap_content">

        <TextView
            android:id="@+id/scriptTitle"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textStyle="bold"
            android:textSize="18sp"
            android:paddingBottom="8dp"/>

        <TextView
            android:id="@+id/scriptExitCode"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="14sp"
            android:paddingBottom="8dp"/>

        <TextView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="STDOUT:"
            android:textStyle="bold"/>

        <TextView
            android:id="@+id/scriptStdout"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:paddingBottom="12dp"
            android:textIsSelectable="true"/>

        <TextView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="STDERR:"
            android:textStyle="bold"/>

        <TextView
            android:id="@+id/scriptStderr"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textIsSelectable="true"/>

    </LinearLayout>
</ScrollView>
XML

echo "=== Writing PluginDescriptor.kt ==="
cat > "$JAVA_DIR/PluginDescriptor.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import org.json.JSONObject
import java.io.File

data class PluginDescriptor(
    val id: String,
    val name: String,
    val version: String,
    val description: String?,
    val entryScript: File
) {
    companion object {
        fun fromManifest(dir: File): PluginDescriptor? {
            val manifest = File(dir, "manifest.json")
            if (!manifest.exists()) return null
            val json = manifest.readText()
            val obj = JSONObject(json)

            val id = obj.optString("id", dir.name)
            val name = obj.optString("name", dir.name)
            val version = obj.optString("version", "0.0.0")
            val desc = obj.optString("description", null)
            val entryName = obj.optString("entry", "plugin.sh")
            val entryFile = File(dir, entryName)

            if (!entryFile.exists()) return null

            return PluginDescriptor(
                id = id,
                name = name,
                version = version,
                description = desc,
                entryScript = entryFile
            )
        }
    }
}
KOTLIN

echo "=== Writing PluginLoader.kt ==="
cat > "$JAVA_DIR/PluginLoader.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.content.Context
import java.io.File

object PluginLoader {

    fun listPlugins(context: Context): List<PluginDescriptor> {
        val roots = WorkspaceResolver.resolveRoots(context)
        val pluginDirs = listOf(
            File(roots.internalRoot, "plugins"),
            File(roots.publicRoot, "plugins")
        )

        val result = mutableListOf<PluginDescriptor>()
        pluginDirs.forEach { root ->
            if (!root.exists()) return@forEach
            root.listFiles { f -> f.isDirectory }?.forEach { dir ->
                PluginDescriptor.fromManifest(dir)?.let { result.add(it) }
            }
        }
        return result.sortedBy { it.name.lowercase() }
    }

    fun runPlugin(context: Context, plugin: PluginDescriptor): ScriptRunner.ScriptRunResult {
        val script = plugin.entryScript
        val result = DroidShellBridge.execScript(script)
        return ScriptRunner.ScriptRunResult(script, result.exitCode, result.stdout, result.stderr)
    }
}
KOTLIN

echo "=== Writing PluginListAdapter.kt ==="
cat > "$JAVA_DIR/PluginListAdapter.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class PluginListAdapter(
    private val plugins: List<PluginDescriptor>,
    private val onClick: (PluginDescriptor) -> Unit
) : RecyclerView.Adapter<PluginListAdapter.ViewHolder>() {

    inner class ViewHolder(v: View) : RecyclerView.ViewHolder(v) {
        val name: TextView = v.findViewById(R.id.pluginName)
        val version: TextView = v.findViewById(R.id.pluginVersion)
        val desc: TextView = v.findViewById(R.id.pluginDescription)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val v = LayoutInflater.from(parent.context).inflate(R.layout.item_plugin, parent, false)
        return ViewHolder(v)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val p = plugins[position]
        holder.name.text = p.name
        holder.version.text = p.version
        holder.desc.text = p.description ?: p.id
        holder.itemView.setOnClickListener { onClick(p) }
    }

    override fun getItemCount(): Int = plugins.size
}
KOTLIN

echo "=== Writing PluginListFragment.kt ==="
cat > "$JAVA_DIR/PluginListFragment.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView

class PluginListFragment : Fragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val v = inflater.inflate(R.layout.fragment_plugin_list, container, false)
        val rv = v.findViewById<RecyclerView>(R.id.pluginRecyclerView)
        rv.layoutManager = LinearLayoutManager(requireContext())

        val plugins = PluginLoader.listPlugins(requireContext())
        rv.adapter = PluginListAdapter(plugins) { plugin ->
            val result = PluginLoader.runPlugin(requireContext(), plugin)
            parentFragmentManager.beginTransaction()
                .replace(
                    R.id.mainContainer,
                    ScriptOutputFragment.newInstance(
                        title = "Plugin: ${plugin.name}",
                        stdout = result.stdout,
                        stderr = result.stderr,
                        exitCode = result.exitCode
                    )
                )
                .addToBackStack(null)
                .commit()
        }

        return v
    }
}
KOTLIN

echo "=== Writing item_plugin.xml ==="
cat > "$LAYOUT_DIR/item_plugin.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<androidx.cardview.widget.CardView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_margin="8dp"
    android:foreground="?attr/selectableItemBackground">

    <LinearLayout
        android:orientation="vertical"
        android:padding="12dp"
        android:layout_width="match_parent"
        android:layout_height="wrap_content">

        <TextView
            android:id="@+id/pluginName"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textStyle="bold"
            android:textSize="16sp"/>

        <TextView
            android:id="@+id/pluginVersion"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="12sp"
            android:paddingTop="2dp"/>

        <TextView
            android:id="@+id/pluginDescription"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:paddingTop="4dp"
            android:textSize="14sp"/>

    </LinearLayout>
</androidx.cardview.widget.CardView>
XML

echo "=== Writing fragment_plugin_list.xml ==="
cat > "$LAYOUT_DIR/fragment_plugin_list.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/pluginRecyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="4dp"/>
</androidx.coordinatorlayout.widget.CoordinatorLayout>
XML

echo "=== Writing FolderDetailAdapter.kt ==="
cat > "$JAVA_DIR/FolderDetailAdapter.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import java.io.File

class FolderDetailAdapter(
    private val items: List<File>,
    private val onClick: (File) -> Unit
) : RecyclerView.Adapter<FolderDetailAdapter.ViewHolder>() {

    inner class ViewHolder(v: View) : RecyclerView.ViewHolder(v) {
        val icon: ImageView = v.findViewById(R.id.fileIcon)
        val name: TextView = v.findViewById(R.id.fileName)
        val meta: TextView = v.findViewById(R.id.fileMeta)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val v = LayoutInflater.from(parent.context).inflate(R.layout.item_file, parent, false)
        return ViewHolder(v)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val f = items[position]
        holder.name.text = f.name
        holder.meta.text = if (f.isDirectory) "Directory" else "${f.length()} bytes"
        holder.icon.setImageResource(
            if (f.isDirectory) R.drawable.ic_folder_default else R.drawable.ic_droidshell_scripts
        )
        holder.itemView.setOnClickListener { onClick(f) }
    }

    override fun getItemCount(): Int = items.size
}
KOTLIN

echo "=== Writing FolderDetailFragment.kt ==="
cat > "$JAVA_DIR/FolderDetailFragment.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import java.io.File

class FolderDetailFragment : Fragment() {

    companion object {
        private const val ARG_FOLDER_NAME = "folder_name"

        fun newInstance(folderName: String): FolderDetailFragment {
            val f = FolderDetailFragment()
            f.arguments = Bundle().apply { putString(ARG_FOLDER_NAME, folderName) }
            return f
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val v = inflater.inflate(R.layout.fragment_folder_detail, container, false)
        val rv = v.findViewById<RecyclerView>(R.id.fileRecyclerView)
        rv.layoutManager = LinearLayoutManager(requireContext())

        val folderName = requireArguments().getString(ARG_FOLDER_NAME) ?: ""
        val root = WorkspaceResolver.resolveFolder(requireContext(), folderName)
        val items = root.listFiles()?.sortedWith(
            compareBy<File> { !it.isDirectory }.thenBy { it.name.lowercase() }
        ) ?: emptyList()

        rv.adapter = FolderDetailAdapter(items) { file ->
            if (file.isDirectory) {
                parentFragmentManager.beginTransaction()
                    .replace(R.id.mainContainer, newInstance(file.name))
                    .addToBackStack(null)
                    .commit()
            } else if (file.name.endsWith(".sh")) {
                val result = DroidShellBridge.execScript(file)
                parentFragmentManager.beginTransaction()
                    .replace(
                        R.id.mainContainer,
                        ScriptOutputFragment.newInstance(
                            title = "Script: ${file.name}",
                            stdout = result.stdout,
                            stderr = result.stderr,
                            exitCode = result.exitCode
                        )
                    )
                    .addToBackStack(null)
                    .commit()
            }
        }

        return v
    }
}
KOTLIN

echo "=== Writing fragment_folder_detail.xml ==="
cat > "$LAYOUT_DIR/fragment_folder_detail.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/fileRecyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="4dp"/>
</androidx.coordinatorlayout.widget.CoordinatorLayout>
XML

echo "=== Writing item_file.xml ==="
cat > "$LAYOUT_DIR/item_file.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="horizontal"
    android:padding="8dp"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:foreground="?attr/selectableItemBackground">

    <ImageView
        android:id="@+id/fileIcon"
        android:layout_width="32dp"
        android:layout_height="32dp"
        android:layout_marginEnd="8dp"/>

    <LinearLayout
        android:orientation="vertical"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_weight="1">

        <TextView
            android:id="@+id/fileName"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textStyle="bold"/>

        <TextView
            android:id="@+id/fileMeta"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="12sp"/>
    </LinearLayout>
</LinearLayout>
XML

echo
echo "=== Next steps ==="
echo "1) Rebuild project so new classes/layouts are recognized."
echo "2) From SampleFolderFragment, replace the TODO click handler with:"
echo "   parentFragmentManager.beginTransaction()"
echo "       .replace(R.id.mainContainer, FolderDetailFragment.newInstance(folderName))"
echo "       .addToBackStack(null)"
echo "       .commit()"
echo "3) Use PluginListFragment to browse and run plugins."
echo "4) ScriptRunner + ScriptOutputFragment now give you a full script execution UI."
echo
echo "DroidShell next layer (folder detail + plugins + scripts + IPC + workspace) created."
