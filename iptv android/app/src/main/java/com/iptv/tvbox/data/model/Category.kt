package com.iptv.tvbox.data.model

data class Category(
    val id: String,
    val name: String,
    var count: Int = 0,
    var isSelected: Boolean = false
) {
    companion object {
        const val ID_ALL = "all_channels"
        const val ID_FAVORITES = "favorite_channels"
    }
}
