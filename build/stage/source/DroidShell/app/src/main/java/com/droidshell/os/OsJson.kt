package com.droidshell.os

import org.json.JSONObject

data class OsRequest(
    val version: String,
    val id: String?,
    val command: String,
    val args: JSONObject
)

data class OsResponse(
    val version: String = "1.0",
    val id: String?,
    val status: String,
    val data: JSONObject = JSONObject(),
    val error: JSONObject? = null
)
