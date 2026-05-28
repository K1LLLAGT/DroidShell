#!/usr/bin/env bash
set -euo pipefail

# create_full_droidshell_stack.sh
# Wires the entire DroidShell stack into an Android project.
# Package: com.k1lllagt.droidshell

ROOT="$(pwd)"
APP_DIR="$ROOT/app"
SRC_DIR="$APP_DIR/src/main"
JAVA_DIR="$SRC_DIR/java/com/k1lllagt/droidshell"
RES_DIR="$SRC_DIR/res"
LAYOUT_DIR="$RES_DIR/layout"
DRAWABLE_DIR="$RES_DIR/drawable"
RAW_DIR="$RES_DIR/raw"

mkdir -p "$JAVA_DIR" "$LAYOUT_DIR" "$DRAWABLE_DIR" "$RAW_DIR"

echo "=== AndroidManifest snippet (manual merge) ==="
cat <<'MANIFEST_SNIPPET'

<!-- app/src/main/AndroidManifest.xml -->

<!-- Add (or merge) inside <manifest> -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<!-- Optional / advanced: MANAGE_EXTERNAL_STORAGE or SAF if you go beyond your own folder -->

<!-- Add (or merge) inside <application> -->
<application
    android:name=".DroidShellApp"
    android:allowBackup="true"
    android:theme="@style/Theme.Material3.DayNight.NoActionBar"
    ... >

    <activity
        android:name=".MainActivity"
        android:exported="true">
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>
    </activity>

    <!-- Optional: separate DroidShell host activity -->
    <activity
        android:name=".DroidShellActivity"
        android:exported="false" />
</application>

MANIFEST_SNIPPET

echo "=== build.gradle(.kts) dependency snippet (manual merge) ==="
cat <<'GRADLE_SNIPPET'

/* app/build.gradle(.kts) – inside dependencies { } */

implementation("androidx.core:core-ktx:1.13.1")
implementation("androidx.appcompat:appcompat:1.7.0")
implementation("com.google.android.material:material:1.12.0")
implementation("androidx.recyclerview:recyclerview:1.3.2")
implementation("androidx.constraintlayout:constraintlayout:2.2.0")
implementation("androidx.fragment:fragment-ktx:1.8.2")

GRADLE_SNIPPET

echo "=== Writing DroidShellApp.kt ==="
cat > "$JAVA_DIR/DroidShellApp.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.app.Application
import java.io.File

class DroidShellApp : Application() {

    override fun onCreate() {
        super.onCreate()
        provisionDroidShellTree()
    }

    private fun provisionDroidShellTree() {
        val prefs = getSharedPreferences("droidshell_prefs", MODE_PRIVATE)
        if (prefs.getBoolean("tree_provisioned", false)) return

        val internalRoot = File(getExternalFilesDir(null), "DroidShell")
        val publicRoot = File("/sdcard/DroidShell")

        val dirs = listOf("bin", "plugins", "themes", "scripts", "workspace", "packages", "config", "logs")

        fun createTree(root: File) {
            root.mkdirs()
            dirs.forEach { name ->
                val d = File(root, name)
                d.mkdirs()
                val readme = File(d, "README.txt")
                if (!readme.exists()) {
                    readme.writeText(
                        "DroidShell canonical folder: $name\n" +
                        "Location: ${root.absolutePath}\n"
                    )
                }
            }
        }

        createTree(internalRoot)
        createTree(publicRoot)

        prefs.edit().putBoolean("tree_provisioned", true).apply()
    }
}
KOTLIN

echo "=== Writing MainActivity.kt (DroidShell as home) ==="
cat > "$JAVA_DIR/MainActivity.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        if (savedInstanceState == null) {
            supportFragmentManager.beginTransaction()
                .replace(R.id.mainContainer, SampleFolderFragment())
                .commit()
        }
    }
}
KOTLIN

echo "=== Writing DroidShellActivity.kt (DroidShell as sub-screen host) ==="
cat > "$JAVA_DIR/DroidShellActivity.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class DroidShellActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main) // reuse same container layout

        if (savedInstanceState == null) {
            supportFragmentManager.beginTransaction()
                .replace(R.id.mainContainer, SampleFolderFragment())
                .commit()
        }
    }
}
KOTLIN

echo "=== Writing DroidShellLauncher.kt (global entry helper) ==="
cat > "$JAVA_DIR/DroidShellLauncher.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.content.Context
import android.content.Intent

object DroidShellLauncher {
    fun open(context: Context) {
        context.startActivity(Intent(context, DroidShellActivity::class.java))
    }
}
KOTLIN

echo "=== Writing ThemeManager.kt ==="
cat > "$JAVA_DIR/ThemeManager.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.content.Context
import android.graphics.Color
import androidx.annotation.ColorInt
import org.json.JSONObject

data class DroidShellTheme(
    @ColorInt val accentColor: Int,
    @ColorInt val backgroundColor: Int,
    @ColorInt val folderTitleColor: Int,
    @ColorInt val iconTint: Int
)

object ThemeManager {
    private var cachedTheme: DroidShellTheme? = null

    fun getTheme(context: Context): DroidShellTheme {
        cachedTheme?.let { return it }
        val res = context.resources
        val rawId = res.getIdentifier("droidshell_theme", "raw", context.packageName)
        val theme = if (rawId != 0) {
            val json = res.openRawResource(rawId).bufferedReader().use { it.readText() }
            val obj = JSONObject(json)
            DroidShellTheme(
                accentColor = Color.parseColor(obj.optString("accentColor", "#00FF7F")),
                backgroundColor = Color.parseColor(obj.optString("backgroundColor", "#101010")),
                folderTitleColor = Color.parseColor(obj.optString("folderTitleColor", "#FFFFFF")),
                iconTint = Color.parseColor(obj.optString("iconTint", "#00FF7F"))
            )
        } else {
            DroidShellTheme(
                accentColor = Color.parseColor("#00FF7F"),
                backgroundColor = Color.parseColor("#101010"),
                folderTitleColor = Color.WHITE,
                iconTint = Color.parseColor("#00FF7F")
            )
        }
        cachedTheme = theme
        return theme
    }
}
KOTLIN

echo "=== Writing IconResolver.kt ==="
cat > "$JAVA_DIR/IconResolver.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.content.Context
import androidx.annotation.DrawableRes
import org.json.JSONObject

object IconResolver {

    private var nameToRes: Map<String, Int>? = null

    private fun ensureLoaded(context: Context) {
        if (nameToRes != null) return

        val res = context.resources
        val pkg = context.packageName
        val map = mutableMapOf<String, Int>()

        val rawId = res.getIdentifier("droidshell_icon_map", "raw", pkg)
        if (rawId != 0) {
            val json = res.openRawResource(rawId).bufferedReader().use { it.readText() }
            val obj = JSONObject(json)
            obj.keys().forEach { key ->
                val drawableName = obj.getString(key)
                val drawableId = res.getIdentifier(drawableName, "drawable", pkg)
                if (drawableId != 0) map[key.lowercase()] = drawableId
            }
        }

        fun fallback(name: String, @DrawableRes id: Int) {
            map.putIfAbsent(name.lowercase(), id)
        }

        fallback("bin", R.drawable.ic_droidshell_bin)
        fallback("plugins", R.drawable.ic_droidshell_plugins)
        fallback("themes", R.drawable.ic_droidshell_themes)
        fallback("scripts", R.drawable.ic_droidshell_scripts)
        fallback("workspace", R.drawable.ic_droidshell_workspace)
        fallback("packages", R.drawable.ic_droidshell_packages)
        fallback("config", R.drawable.ic_droidshell_config)
        fallback("logs", R.drawable.ic_droidshell_logs)
        fallback("downloads", R.drawable.ic_folder_download)
        fallback("documents", R.drawable.ic_folder_documents)
        fallback("dcim", R.drawable.ic_folder_photos)

        nameToRes = map
    }

    @DrawableRes
    fun resolveFolderIcon(context: Context, folderName: String?): Int {
        if (folderName.isNullOrBlank()) return R.drawable.ic_folder_default
        ensureLoaded(context)
        return nameToRes?.get(folderName.trim().lowercase()) ?: R.drawable.ic_folder_default
    }
}
KOTLIN

echo "=== Writing FileManagerAdapter.kt ==="
cat > "$JAVA_DIR/FileManagerAdapter.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.core.widget.ImageViewCompat
import androidx.recyclerview.widget.RecyclerView

class FileManagerAdapter(
    private val context: Context,
    private val folders: List<String>,
    private val onClick: (String) -> Unit = {}
) : RecyclerView.Adapter<FileManagerAdapter.ViewHolder>() {

    private val theme = ThemeManager.getTheme(context)

    inner class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val icon: ImageView = view.findViewById(R.id.folderIcon)
        val title: TextView = view.findViewById(R.id.folderTitle)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val v = LayoutInflater.from(parent.context).inflate(R.layout.item_folder, parent, false)
        return ViewHolder(v)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val name = folders[position]
        holder.title.text = name
        holder.title.setTextColor(theme.folderTitleColor)

        val drawableId = IconResolver.resolveFolderIcon(context, name)
        holder.icon.setImageResource(drawableId)
        ImageViewCompat.setImageTintList(
            holder.icon,
            android.content.res.ColorStateList.valueOf(theme.iconTint)
        )

        holder.itemView.setOnClickListener { onClick(name) }
    }

    override fun getItemCount(): Int = folders.size
}
KOTLIN

echo "=== Writing SampleFolderFragment.kt ==="
cat > "$JAVA_DIR/SampleFolderFragment.kt" <<'KOTLIN'
package com.k1lllagt.droidshell

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView

class SampleFolderFragment : Fragment() {

    private val sampleFolders = listOf(
        "bin", "plugins", "themes", "scripts", "workspace",
        "packages", "config", "logs", "DCIM", "Downloads", "Documents"
    )

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val view = inflater.inflate(R.layout.fragment_folder_list, container, false)
        val rv = view.findViewById<RecyclerView>(R.id.folderRecyclerView)
        rv.layoutManager = LinearLayoutManager(requireContext())
        rv.adapter = FileManagerAdapter(requireContext(), sampleFolders) { folderName ->
            // TODO: navigate into folder, open detail, etc.
        }
        return view
    }
}
KOTLIN

echo "=== Writing activity_main.xml ==="
cat > "$LAYOUT_DIR/activity_main.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/mainContainer"
    android:layout_width="match_parent"
    android:layout_height="match_parent" />
XML

echo "=== Writing item_folder.xml ==="
cat > "$LAYOUT_DIR/item_folder.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="72dp"
    android:layout_margin="8dp"
    app:cardCornerRadius="12dp"
    app:cardUseCompatPadding="true">

    <androidx.constraintlayout.widget.ConstraintLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="12dp">

        <ImageView
            android:id="@+id/folderIcon"
            android:layout_width="40dp"
            android:layout_height="40dp"
            android:contentDescription="@string/folder_icon"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintBottom_toBottomOf="parent" />

        <TextView
            android:id="@+id/folderTitle"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:text="Folder"
            android:textAppearance="@style/TextAppearance.Material3.BodyLarge"
            app:layout_constraintStart_toEndOf="@id/folderIcon"
            app:layout_constraintTop_toTopOf="@id/folderIcon"
            app:layout_constraintBottom_toBottomOf="@id/folderIcon"
            app:layout_constraintEnd_toEndOf="parent"
            android:paddingStart="12dp"/>

    </androidx.constraintlayout.widget.ConstraintLayout>
</com.google.android.material.card.MaterialCardView>
XML

echo "=== Writing fragment_folder_list.xml ==="
cat > "$LAYOUT_DIR/fragment_folder_list.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/folderRecyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="4dp"/>
</androidx.coordinatorlayout.widget.CoordinatorLayout>
XML

echo "=== Writing droidshell_icon_map.json ==="
cat > "$RAW_DIR/droidshell_icon_map.json" <<'JSON'
{
  "bin": "ic_droidshell_bin",
  "binaries": "ic_droidshell_bin",
  "plugins": "ic_droidshell_plugins",
  "extensions": "ic_droidshell_plugins",
  "themes": "ic_droidshell_themes",
  "scripts": "ic_droidshell_scripts",
  "workspace": "ic_droidshell_workspace",
  "packages": "ic_droidshell_packages",
  "config": "ic_droidshell_config",
  "logs": "ic_droidshell_logs",
  "downloads": "ic_folder_download",
  "documents": "ic_folder_documents",
  "dcim": "ic_folder_photos"
}
JSON

echo "=== Writing droidshell_theme.json ==="
cat > "$RAW_DIR/droidshell_theme.json" <<'JSON'
{
  "accentColor": "#00FF7F",
  "backgroundColor": "#101010",
  "folderTitleColor": "#FFFFFF",
  "iconTint": "#00FF7F"
}
JSON

echo "=== Writing placeholder vector icons (overwrite via Vector Asset import) ==="
cat > "$DRAWABLE_DIR/ic_folder_default.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#90A4AE" android:pathData="M3,6h6l2,2h10v10H3z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_bin.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#071E1A" android:pathData="M2,4h20v16H2z"/>
  <path android:fillColor="#00FF7F" android:pathData="M6,8h12v8H6z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_plugins.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#0AB4FF" android:pathData="M4,10h16v10H4z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_themes.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FFB86B" android:pathData="M12,2a10,10 0 1 0 0,20a10,10 0 0 0 0,-20z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_scripts.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#0B3F00" android:pathData="M3,3h18v18H3z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_workspace.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FFD700" android:pathData="M2,6h20v12H2z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_packages.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#C0C0C0" android:pathData="M3,7l9,-4 9,4v10l-9,4-9,-4z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_config.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FF6B6B" android:pathData="M4,8h16v12H4z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_droidshell_logs.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FFFFFF" android:pathData="M4,4h16v16H4z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_folder_download.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#2196F3" android:pathData="M5,20h14v-2H5z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_folder_documents.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#4CAF50" android:pathData="M6,2h9l5,5v13H6z"/>
</vector>
XML

cat > "$DRAWABLE_DIR/ic_folder_photos.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp" android:viewportWidth="24"
    android:viewportHeight="24">
  <path android:fillColor="#FF7043" android:pathData="M4,6h16v12H4z"/>
</vector>
XML

echo
echo "=== How to use ==="
echo "1) Run this script from your project root: ./create_full_droidshell_stack.sh"
echo "2) Merge the AndroidManifest and build.gradle snippets manually."
echo "3) To open DroidShell from any Activity:"
echo "   DroidShellLauncher.open(this)"
echo "4) For Navigation Component, add SampleFolderFragment as a destination and navigate via:"
echo "   findNavController().navigate(R.id.droidShellFragment)"
echo "5) Treat getExternalFilesDir(null)/DroidShell as canonical; /sdcard/DroidShell is a best-effort mirror."
echo "6) Replace ic_droidshell_* placeholders using Android Studio Vector Asset import from your ds_*.svg files."

echo
echo "DroidShell full stack wiring complete."
