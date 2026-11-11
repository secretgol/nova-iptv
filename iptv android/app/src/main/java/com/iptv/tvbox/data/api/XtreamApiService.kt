package com.iptv.tvbox.data.api

import com.iptv.tvbox.data.model.XtreamAuthResponse
import com.iptv.tvbox.data.model.XtreamCategory
import com.iptv.tvbox.data.model.XtreamStreamItem
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Query

interface XtreamApiService {

    @GET("player_api.php")
    suspend fun authenticate(
        @Query("username") username: String,
        @Query("password") password: String
    ): Response<XtreamAuthResponse>

    @GET("player_api.php")
    suspend fun getLiveCategories(
        @Query("username") username: String,
        @Query("password") password: String,
        @Query("action") action: String = "get_live_categories"
    ): Response<List<XtreamCategory>>

    @GET("player_api.php")
    suspend fun getLiveStreams(
        @Query("username") username: String,
        @Query("password") password: String,
        @Query("action") action: String = "get_live_streams",
        @Query("category_id") categoryId: String? = null
    ): Response<List<XtreamStreamItem>>
}
