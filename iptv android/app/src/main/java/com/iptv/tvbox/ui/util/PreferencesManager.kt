package com.iptv.tvbox.ui.util

import android.content.Context
import android.content.SharedPreferences

class PreferencesManager(context: Context) {

    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    var activePlaylistType: String
        get() = prefs.getString(KEY_PLAYLIST_TYPE, TYPE_SAMPLE) ?: TYPE_SAMPLE
        set(value) = prefs.edit().putString(KEY_PLAYLIST_TYPE, value).apply()

    var m3uUrl: String
        get() = prefs.getString(KEY_M3U_URL, "") ?: ""
        set(value) = prefs.edit().putString(KEY_M3U_URL, value).apply()

    var xtreamServer: String
        get() = prefs.getString(KEY_XTREAM_SERVER, "") ?: ""
        set(value) = prefs.edit().putString(KEY_XTREAM_SERVER, value).apply()

    var xtreamUser: String
        get() = prefs.getString(KEY_XTREAM_USER, "") ?: ""
        set(value) = prefs.edit().putString(KEY_XTREAM_USER, value).apply()

    var xtreamPass: String
        get() = prefs.getString(KEY_XTREAM_PASS, "") ?: ""
        set(value) = prefs.edit().putString(KEY_XTREAM_PASS, value).apply()

    var lastChannelId: String?
        get() = prefs.getString(KEY_LAST_CHANNEL_ID, null)
        set(value) = prefs.edit().putString(KEY_LAST_CHANNEL_ID, value).apply()

    var aspectRatioIndex: Int
        get() = prefs.getInt(KEY_ASPECT_RATIO, 0)
        set(value) = prefs.edit().putInt(KEY_ASPECT_RATIO, value).apply()

    fun getFavoriteIds(): Set<String> {
        return prefs.getStringSet(KEY_FAVORITES, emptySet()) ?: emptySet()
    }

    fun isFavorite(channelId: String): Boolean {
        return getFavoriteIds().contains(channelId)
    }

    fun toggleFavorite(channelId: String): Boolean {
        val currentFavorites = getFavoriteIds().toMutableSet()
        val newState = if (currentFavorites.contains(channelId)) {
            currentFavorites.remove(channelId)
            false
        } else {
            currentFavorites.add(channelId)
            true
        }
        prefs.edit().putStringSet(KEY_FAVORITES, currentFavorites).apply()
        return newState
    }

    companion object {
        private const val PREFS_NAME = "nova_iptv_prefs"
        const val KEY_PLAYLIST_TYPE = "key_playlist_type"
        const val KEY_M3U_URL = "key_m3u_url"
        const val KEY_XTREAM_SERVER = "key_xtream_server"
        const val KEY_XTREAM_USER = "key_xtream_user"
        const val KEY_XTREAM_PASS = "key_xtream_pass"
        const val KEY_FAVORITES = "key_favorites"
        const val KEY_LAST_CHANNEL_ID = "key_last_channel_id"
        const val KEY_ASPECT_RATIO = "key_aspect_ratio"

        const val TYPE_SAMPLE = "sample"
        const val TYPE_M3U = "m3u"
        const val TYPE_XTREAM = "xtream"
    }
}
