#!/usr/bin/env bash
set -euo pipefail

# create_droidshell_android.sh
# Generates the entire com.k1lllagt.droidshell Android subsystem.

ROOT="$(pwd)"
APP="$ROOT/app"
SRC="$APP/src/main"
JAVA="$SRC/java/com/k1lllagt/droidshell"
RES="$SRC/res"
LAYOUT="$RES/layout"
DRAWABLE="$RES/drawable"
RAW="$RES/raw"

mkdir -p "$JAVA" "$LAYOUT" "$DRAWABLE" "$RAW"

echo "=== AndroidManifest additions (manual merge) ==="
cat <<'EOF'

<application
    android:name=".DroidShellApp"
    android:allowBackup="true"
    android:theme="@style/Theme.Material3.DayNight.NoActionBar">

    <activity
        android:name=".MainActivity"
        android:exported="true">
        <intent-filter>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent-filter>
    </activity>

    <activity android:name=".DroidShellActivity"/>
</application>

EOF

echo "=== Gradle dependency additions (manual merge) ==="
cat <<'EOF'

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.recyclerview:recyclerview:1.3.2")
    implementation("androidx.constraintlayout:constraintlayout:2.2.0")
    implementation("androidx.fragment:fragment-ktx:1.8.2")
}

EOF

#############################################
# CORE APP FILES
#############################################

cat > "$JAVA/DroidShellApp.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.app.Application
import java.io.File

class DroidShellApp : Application() {
    override fun onCreate() {
        super.onCreate()
        provision()
    }

    private fun provision() {
        val prefs = getSharedPreferences("ds_prefs", MODE_PRIVATE)
        if (prefs.getBoolean("done", false)) return

        val internal = File(getExternalFilesDir(null), "DroidShell")
        val public = File("/sdcard/DroidShell")
        val dirs = listOf("bin","plugins","themes","scripts","workspace","packages","config","logs")

        fun mk(root: File) {
            root.mkdirs()
            dirs.forEach {
                val d = File(root, it)
                d.mkdirs()
                File(d, "README.txt").writeText("DroidShell folder: $it\n")
            }
        }

        mk(internal)
        mk(public)

        prefs.edit().putBoolean("done", true).apply()
    }
}
EOF

cat > "$JAVA/MainActivity.kt" <<'EOF'
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
EOF

cat > "$JAVA/DroidShellActivity.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class DroidShellActivity : AppCompatActivity() {
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
EOF

cat > "$JAVA/DroidShellLauncher.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.content.Context
import android.content.Intent

object DroidShellLauncher {
    fun open(context: Context) {
        context.startActivity(Intent(context, DroidShellActivity::class.java))
    }
}
EOF

#############################################
# THEME + ICONS
#############################################

cat > "$JAVA/ThemeManager.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.content.Context
import android.graphics.Color
import androidx.annotation.ColorInt
import org.json.JSONObject

data class DroidShellTheme(
    @ColorInt val accent: Int,
    @ColorInt val bg: Int,
    @ColorInt val title: Int,
    @ColorInt val tint: Int
)

object ThemeManager {
    private var cache: DroidShellTheme? = null

    fun get(context: Context): DroidShellTheme {
        cache?.let { return it }
        val res = context.resources
        val id = res.getIdentifier("droidshell_theme","raw",context.packageName)
        val theme = if (id != 0) {
            val json = res.openRawResource(id).bufferedReader().readText()
            val o = JSONObject(json)
            DroidShellTheme(
                Color.parseColor(o.optString("accent","#00FF7F")),
                Color.parseColor(o.optString("background","#101010")),
                Color.parseColor(o.optString("title","#FFFFFF")),
                Color.parseColor(o.optString("tint","#00FF7F"))
            )
        } else {
            DroidShellTheme(Color.GREEN,Color.BLACK,Color.WHITE,Color.GREEN)
        }
        cache = theme
        return theme
    }
}
EOF

cat > "$JAVA/IconResolver.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.content.Context
import androidx.annotation.DrawableRes
import org.json.JSONObject

object IconResolver {
    private var map: Map<String,Int>? = null

    private fun load(context: Context) {
        if (map != null) return
        val res = context.resources
        val pkg = context.packageName
        val id = res.getIdentifier("droidshell_icon_map","raw",pkg)
        val m = mutableMapOf<String,Int>()

        if (id != 0) {
            val json = res.openRawResource(id).bufferedReader().readText()
            val o = JSONObject(json)
            o.keys().forEach {
                val d = res.getIdentifier(o.getString(it),"drawable",pkg)
                if (d != 0) m[it.lowercase()] = d
            }
        }

        fun fb(name:String,@DrawableRes d:Int){ m.putIfAbsent(name.lowercase(),d) }

        fb("bin",R.drawable.ic_droidshell_bin)
        fb("plugins",R.drawable.ic_droidshell_plugins)
        fb("themes",R.drawable.ic_droidshell_themes)
        fb("scripts",R.drawable.ic_droidshell_scripts)
        fb("workspace",R.drawable.ic_droidshell_workspace)
        fb("packages",R.drawable.ic_droidshell_packages)
        fb("config",R.drawable.ic_droidshell_config)
        fb("logs",R.drawable.ic_droidshell_logs)

        map = m
    }

    @DrawableRes
    fun folder(context: Context, name: String): Int {
        load(context)
        return map?.get(name.lowercase()) ?: R.drawable.ic_folder_default
    }
}
EOF

#############################################
# FILE MANAGER UI
#############################################

cat > "$JAVA/FileManagerAdapter.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.content.Context
import android.view.*
import android.widget.*
import androidx.core.widget.ImageViewCompat
import androidx.recyclerview.widget.RecyclerView

class FileManagerAdapter(
    private val ctx: Context,
    private val items: List<String>,
    private val onClick: (String)->Unit
) : RecyclerView.Adapter<FileManagerAdapter.VH>() {

    private val theme = ThemeManager.get(ctx)

    inner class VH(v:View):RecyclerView.ViewHolder(v){
        val icon:ImageView=v.findViewById(R.id.folderIcon)
        val title:TextView=v.findViewById(R.id.folderTitle)
    }

    override fun onCreateViewHolder(p:ViewGroup,v:Int)=
        VH(LayoutInflater.from(p.context).inflate(R.layout.item_folder,p,false))

    override fun onBindViewHolder(h:VH,i:Int){
        val name=items[i]
        h.title.text=name
        h.title.setTextColor(theme.title)
        h.icon.setImageResource(IconResolver.folder(ctx,name))
        ImageViewCompat.setImageTintList(h.icon,android.content.res.ColorStateList.valueOf(theme.tint))
        h.itemView.setOnClickListener{onClick(name)}
    }

    override fun getItemCount()=items.size
}
EOF

cat > "$JAVA/SampleFolderFragment.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.os.Bundle
import android.view.*
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.*

class SampleFolderFragment:Fragment(){
    private val folders=listOf("bin","plugins","themes","scripts","workspace","packages","config","logs")

    override fun onCreateView(i:LayoutInflater,c:ViewGroup?,s:Bundle?):View{
        val v=i.inflate(R.layout.fragment_folder_list,c,false)
        val rv=v.findViewById<RecyclerView>(R.id.folderRecyclerView)
        rv.layoutManager=LinearLayoutManager(requireContext())
        rv.adapter=FileManagerAdapter(requireContext(),folders){ f ->
            parentFragmentManager.beginTransaction()
                .replace(R.id.mainContainer,FolderDetailFragment.newInstance(f))
                .addToBackStack(null)
                .commit()
        }
        return v
    }
}
EOF

#############################################
# NEXT LAYER: WORKSPACE + IPC + SCRIPTS + PLUGINS + FOLDER DETAIL
#############################################

cat > "$JAVA/WorkspaceResolver.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.content.Context
import java.io.File

object WorkspaceResolver {
    fun roots(ctx:Context)=
        File(ctx.getExternalFilesDir(null),"DroidShell") to File("/sdcard/DroidShell")

    fun folder(ctx:Context,name:String):File{
        val (i,p)=roots(ctx)
        val a=File(i,name)
        val b=File(p,name)
        return when{
            a.exists()->a
            b.exists()->b
            else->a
        }
    }
}
EOF

cat > "$JAVA/DroidShellBridge.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.util.Log
import java.io.*

object DroidShellBridge {
    data class Result(val code:Int,val out:String,val err:String)

    fun exec(cmd:List<String>,dir:File?=null):Result{
        return try{
            val pb=ProcessBuilder(cmd)
            if(dir!=null)pb.directory(dir)
            val p=pb.start()
            val out=p.inputStream.bufferedReader().readText()
            val err=p.errorStream.bufferedReader().readText()
            Result(p.waitFor(),out,err)
        }catch(e:Exception){
            Log.e("DSBridge","exec fail",e)
            Result(-1,"",e.message?:"err")
        }
    }

    fun script(f:File,args:List<String> = emptyList())=
        exec(listOf(f.absolutePath)+args,f.parentFile)
}
EOF

cat > "$JAVA/ScriptRunner.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.content.Context
import java.io.File

object ScriptRunner {
    data class Run(val file:File,val code:Int,val out:String,val err:String)

    fun run(ctx:Context,path:String,args:List<String> = emptyList()):Run{
        val (i,p)=WorkspaceResolver.roots(ctx)
        val f=listOf(File(i,"scripts/$path"),File(p,"scripts/$path")).firstOrNull{it.exists()}
            ?: File(i,"scripts/$path")
        val r=DroidShellBridge.script(f,args)
        return Run(f,r.code,r.out,r.err)
    }
}
EOF

cat > "$JAVA/ScriptOutputFragment.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.os.Bundle
import android.view.*
import android.widget.TextView
import androidx.fragment.app.Fragment

class ScriptOutputFragment:Fragment(){
    companion object{
        fun new(title:String,out:String,err:String,code:Int)=ScriptOutputFragment().apply{
            arguments=Bundle().apply{
                putString("t",title)
                putString("o",out)
                putString("e",err)
                putInt("c",code)
            }
        }
    }

    override fun onCreateView(i:LayoutInflater,c:ViewGroup?,s:Bundle?):View{
        val v=i.inflate(R.layout.fragment_script_output,c,false)
        v.findViewById<TextView>(R.id.scriptTitle).text=requireArguments().getString("t")
        v.findViewById<TextView>(R.id.scriptStdout).text=requireArguments().getString("o")
        v.findViewById<TextView>(R.id.scriptStderr).text=requireArguments().getString("e")
        v.findViewById<TextView>(R.id.scriptExitCode).text="Exit: ${requireArguments().getInt("c")}"
        return v
    }
}
EOF

cat > "$JAVA/PluginDescriptor.kt" <<'EOF'
package com.k1lllagt.droidshell

import org.json.JSONObject
import java.io.File

data class PluginDescriptor(val id:String,val name:String,val ver:String,val desc:String?,val entry:File){
    companion object{
        fun load(dir:File):PluginDescriptor?{
            val m=File(dir,"manifest.json")
            if(!m.exists())return null
            val o=JSONObject(m.readText())
            val id=o.optString("id",dir.name)
            val n=o.optString("name",dir.name)
            val v=o.optString("version","0.0.0")
            val d=o.optString("description",null)
            val e=File(dir,o.optString("entry","plugin.sh"))
            if(!e.exists())return null
            return PluginDescriptor(id,n,v,d,e)
        }
    }
}
EOF

cat > "$JAVA/PluginLoader.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.content.Context
import java.io.File

object PluginLoader {
    fun list(ctx:Context):List<PluginDescriptor>{
        val (i,p)=WorkspaceResolver.roots(ctx)
        val dirs=listOf(File(i,"plugins"),File(p,"plugins"))
        val out=mutableListOf<PluginDescriptor>()
        dirs.forEach{root->
            root.listFiles{f->f.isDirectory}?.forEach{
                PluginDescriptor.load(it)?.let(out::add)
            }
        }
        return out.sortedBy{it.name.lowercase()}
    }

    fun run(ctx:Context,p:PluginDescriptor)=
        ScriptRunner.Run(p.entry, *DroidShellBridge.script(p.entry).let{arrayOf(it.code,it.out,it.err)})
}
EOF

cat > "$JAVA/PluginListFragment.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.os.Bundle
import android.view.*
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.*

class PluginListFragment:Fragment(){
    override fun onCreateView(i:LayoutInflater,c:ViewGroup?,s:Bundle?):View{
        val v=i.inflate(R.layout.fragment_plugin_list,c,false)
        val rv=v.findViewById<RecyclerView>(R.id.pluginRecyclerView)
        rv.layoutManager=LinearLayoutManager(requireContext())
        val list=PluginLoader.list(requireContext())
        rv.adapter=PluginListAdapter(list){ p ->
            val r=DroidShellBridge.script(p.entry)
            parentFragmentManager.beginTransaction()
                .replace(R.id.mainContainer,ScriptOutputFragment.new("Plugin: ${p.name}",r.out,r.err,r.code))
                .addToBackStack(null)
                .commit()
        }
        return v
    }
}
EOF

cat > "$JAVA/PluginListAdapter.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.view.*
import android.widget.*
import androidx.recyclerview.widget.RecyclerView

class PluginListAdapter(
    private val items:List<PluginDescriptor>,
    private val onClick:(PluginDescriptor)->Unit
):RecyclerView.Adapter<PluginListAdapter.VH>(){

    inner class VH(v:View):RecyclerView.ViewHolder(v){
        val name:TextView=v.findViewById(R.id.pluginName)
        val ver:TextView=v.findViewById(R.id.pluginVersion)
        val desc:TextView=v.findViewById(R.id.pluginDescription)
    }

    override fun onCreateViewHolder(p:ViewGroup,v:Int)=
        VH(LayoutInflater.from(p.context).inflate(R.layout.item_plugin,p,false))

    override fun onBindViewHolder(h:VH,i:Int){
        val p=items[i]
        h.name.text=p.name
        h.ver.text=p.ver
        h.desc.text=p.desc ?: p.id
        h.itemView.setOnClickListener{onClick(p)}
    }

    override fun getItemCount()=items.size
}
EOF

cat > "$JAVA/FolderDetailFragment.kt" <<'EOF'
package com.k1lllagt.droidshell

import android.os.Bundle
import android.view.*
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.*
import java.io.File

class FolderDetailFragment:Fragment(){
    companion object{
        fun newInstance(name:String)=FolderDetailFragment().apply{
            arguments=Bundle().apply{putString("f",name)}
        }
    }

    override fun onCreateView(i:LayoutInflater,c:ViewGroup?,s:Bundle?):View{
        val v=i.inflate(R.layout.fragment_folder_detail,c,false)
        val rv=v.findViewById<RecyclerView>(R.id.fileRecyclerView
