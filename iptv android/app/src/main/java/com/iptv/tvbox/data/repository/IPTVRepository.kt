package com.iptv.tvbox.data.repository

import com.iptv.tvbox.data.api.ApiClient
import com.iptv.tvbox.data.model.Category
import com.iptv.tvbox.data.model.Channel
import com.iptv.tvbox.data.parser.M3UParser
import com.iptv.tvbox.ui.util.PreferencesManager
import com.iptv.tvbox.ui.util.SamplePlaylists
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.Request
import java.io.IOException

class IPTVRepository(private val prefs: PreferencesManager) {

    private val allChannels = mutableListOf<Channel>()
    private val categories = mutableListOf<Category>()

    fun getLoadedChannels(): List<Channel> = allChannels

    fun getLoadedCategories(): List<Category> = categories

    suspend fun loadCurrentPlaylist(): Result<List<Channel>> = withContext(Dispatchers.IO) {
        try {
            val channels = when (prefs.activePlaylistType) {
                PreferencesManager.TYPE_M3U -> {
                    if (prefs.m3uUrl.isNotBlank()) {
                        loadFromM3uUrl(prefs.m3uUrl)
                    } else {
                        SamplePlaylists.getSampleChannels()
                    }
                }
                PreferencesManager.TYPE_XTREAM -> {
                    if (prefs.xtreamServer.isNotBlank()) {
                        loadFromXtream(prefs.xtreamServer, prefs.xtreamUser, prefs.xtreamPass)
                    } else {
                        SamplePlaylists.getSampleChannels()
                    }
                }
                else -> {
                    SamplePlaylists.getSampleChannels()
                }
            }

            // Sync favorite states
            val favoriteIds = prefs.getFavoriteIds()
            channels.forEach { ch ->
                ch.isFavorite = favoriteIds.contains(ch.id)
            }

            allChannels.clear()
            allChannels.addAll(channels)

            // Rebuild categories
            rebuildCategories()

            Result.success(allChannels)
        } catch (e: Exception) {
            e.printStackTrace()
            // Fallback to sample channels if online load fails
            if (allChannels.isEmpty()) {
                val sampleChannels = SamplePlaylists.getSampleChannels()
                allChannels.addAll(sampleChannels)
                rebuildCategories()
            }
            Result.failure(e)
        }
    }

    suspend fun loadFromM3uUrl(url: String): List<Channel> = withContext(Dispatchers.IO) {
        val request = Request.Builder()
            .url(url)
            .header("User-Agent", ApiClient.USER_AGENT)
            .build()

        val response = ApiClient.okHttpClient.newCall(request).execute()
        if (!response.isSuccessful) {
            throw IOException("Sunucudan yanıt alınamadı: HTTP ${response.code}")
        }

        val body = response.body ?: throw IOException("Boş yanıt döndü")
        body.byteStream().use { stream ->
            M3UParser.parse(stream)
        }
    }

    suspend fun loadFromXtream(
        serverUrl: String,
        username: String,
        pass: String
    ): List<Channel> = withContext(Dispatchers.IO) {
        val service = ApiClient.createXtreamService(serverUrl)

        // 1. Auth check
        val authResp = service.authenticate(username, pass)
        if (!authResp.isSuccessful || authResp.body()?.userInfo?.status != "Active") {
            // Some providers don't return Active in userInfo, proceed if HTTP 200
            if (!authResp.isSuccessful) {
                throw IOException("Xtream kimlik doğrulaması başarısız")
            }
        }

        // 2. Fetch categories
        val catResp = service.getLiveCategories(username, pass)
        val categoryMap = mutableMapOf<String, String>()
        if (catResp.isSuccessful) {
            catResp.body()?.forEach { cat ->
                categoryMap[cat.categoryId] = cat.categoryName
            }
        }

        // 3. Fetch live streams
        val streamsResp = service.getLiveStreams(username, pass)
        if (!streamsResp.isSuccessful) {
            throw IOException("Kanallar yüklenemedi: HTTP ${streamsResp.code()}")
        }

        val streams = streamsResp.body() ?: emptyList()
        val cleanServer = if (serverUrl.endsWith("/")) serverUrl.dropLast(1) else serverUrl

        var index = 1
        streams.map { item ->
            val catName = item.categoryId?.let { categoryMap[it] } ?: "Genel"
            val streamUrl = "$cleanServer/live/$username/$pass/${item.streamId}.m3u8"

            Channel(
                id = item.streamId.toString(),
                name = item.name,
                logoUrl = item.streamIcon,
                streamUrl = streamUrl,
                category = catName,
                epgId = item.epgChannelId,
                channelNum = item.num ?: index++
            )
        }
    }

    private fun rebuildCategories() {
        categories.clear()

        // "All Channels" category
        categories.add(
            Category(
                id = Category.ID_ALL,
                name = "Tüm Kanallar",
                count = allChannels.size,
                isSelected = true
            )
        )

        // "Favorites" category
        val favCount = allChannels.count { it.isFavorite }
        categories.add(
            Category(
                id = Category.ID_FAVORITES,
                name = "⭐ Favoriler",
                count = favCount,
                isSelected = false
            )
        )

        // Group by category name
        val grouped = allChannels.groupBy { it.category }
        grouped.forEach { (catName, channelList) ->
            if (catName.isNotBlank()) {
                categories.add(
                    Category(
                        id = catName,
                        name = catName,
                        count = channelList.size,
                        isSelected = false
                    )
                )
            }
        }
    }

    fun filterChannels(categoryId: String?, query: String? = null): List<Channel> {
        var result = when (categoryId) {
            Category.ID_ALL, null -> allChannels
            Category.ID_FAVORITES -> allChannels.filter { it.isFavorite }
            else -> allChannels.filter { it.category.equals(categoryId, ignoreCase = true) }
        }

        if (!query.isNullOrBlank()) {
            val q = query.trim().lowercase()
            result = result.filter {
                it.name.lowercase().contains(q) ||
                        it.channelNum.toString() == q ||
                        it.category.lowercase().contains(q)
            }
        }

        return result
    }

    fun toggleFavorite(channel: Channel): Boolean {
        val newState = prefs.toggleFavorite(channel.id)
        channel.isFavorite = newState

        // Update count in categories
        categories.find { it.id == Category.ID_FAVORITES }?.let { favCat ->
            favCat.count = allChannels.count { it.isFavorite }
        }

        return newState
    }
}
