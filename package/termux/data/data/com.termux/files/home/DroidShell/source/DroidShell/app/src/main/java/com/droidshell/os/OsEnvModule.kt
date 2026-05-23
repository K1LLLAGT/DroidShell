package com.droidshell.os

import android.content.Context
import android.os.Build
import org.json.JSONObject

class OsEnvModule(private val ctx: Context) {

    fun info(): JSONObject {
        return JSONObject()
            .put("device", Build.MODEL)
            .put("manufacturer", Build.MANUFACTURER)
            .put("apiLevel", Build.VERSION.SDK_INT)
            .put("sdkInt", Build.VERSION.SDK_INT)
            .put("os", "Android")
    }
}
