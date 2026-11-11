package com.iptv.tvbox.data.model

import com.google.gson.annotations.SerializedName

data class XtreamAuthResponse(
    @SerializedName("user_info") val userInfo: XtreamUserInfo?,
    @SerializedName("server_info") val serverInfo: XtreamServerInfo?
)

data class XtreamUserInfo(
    val username: String?,
    val status: String?,
    val exp_date: String?,
    val is_trial: String?,
    val active_cons: String?,
    val max_connections: String?
)

data class XtreamServerInfo(
    val url: String?,
    val port: String?,
    val https_port: String?,
    val server_protocol: String?,
    val rtmp_port: String?,
    val timezone: String?
)

data class XtreamCategory(
    @SerializedName("category_id") val categoryId: String,
    @SerializedName("category_name") val categoryName: String,
    @SerializedName("parent_id") val parentId: Int? = 0
)

data class XtreamStreamItem(
    @SerializedName("num") val num: Int?,
    @SerializedName("name") val name: String,
    @SerializedName("stream_type") val streamType: String?,
    @SerializedName("stream_id") val streamId: Int,
    @SerializedName("stream_icon") val streamIcon: String?,
    @SerializedName("epg_channel_id") val epgChannelId: String?,
    @SerializedName("category_id") val categoryId: String?
)
