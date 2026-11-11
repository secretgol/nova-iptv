package com.iptv.tvbox.data.model

import java.io.Serializable

data class Channel(
    val id: String,
    val name: String,
    val logoUrl: String? = null,
    val streamUrl: String,
    val category: String = "Genel",
    val epgId: String? = null,
    var channelNum: Int = 0,
    var isFavorite: Boolean = false
) : Serializable
