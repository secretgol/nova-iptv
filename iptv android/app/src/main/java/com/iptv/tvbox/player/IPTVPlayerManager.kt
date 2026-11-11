package com.iptv.tvbox.player

import android.content.Context
import android.net.Uri
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.datasource.okhttp.OkHttpDataSource
import androidx.media3.exoplayer.DefaultLoadControl
import androidx.media3.exoplayer.DefaultRenderersFactory
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.hls.HlsMediaSource
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.exoplayer.source.MediaSource
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import androidx.media3.ui.AspectRatioFrameLayout
import androidx.media3.ui.PlayerView
import com.iptv.tvbox.data.api.ApiClient
import com.iptv.tvbox.data.model.Channel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@UnstableApi
class IPTVPlayerManager(
    private val context: Context,
    private val playerView: PlayerView,
    private val listener: PlayerStateListener
) {

    interface PlayerStateListener {
        fun onBuffering(isBuffering: Boolean)
        fun onPlaybackStarted()
        fun onError(errorMessage: String, isRecoverable: Boolean)
    }

    private var player: ExoPlayer? = null
    private var currentChannel: Channel? = null
    private var retryCount = 0
    private val maxRetries = 3
    private var retryJob: Job? = null
    private val scope = CoroutineScope(Dispatchers.Main)

    // Aspect ratio modes
    private val resizeModes = listOf(
        AspectRatioFrameLayout.RESIZE_MODE_FIT to "Orantılı (Fit)",
        AspectRatioFrameLayout.RESIZE_MODE_FILL to "Tam Ekran (Fill)",
        AspectRatioFrameLayout.RESIZE_MODE_ZOOM to "Yakınlaştır (Zoom)"
    )
    private var currentResizeModeIndex = 0

    init {
        initPlayer()
    }

    private fun initPlayer() {
        // 1. Customized Load Control for live IPTV streaming stability
        val loadControl = DefaultLoadControl.Builder()
            .setBufferDurationsMs(
                /* minBufferMs = */ 15_000,
                /* maxBufferMs = */ 50_000,
                /* bufferForPlaybackMs = */ 2_000,
                /* bufferForPlaybackAfterRebufferMs = */ 4_000
            )
            .setPrioritizeTimeOverSizeThresholds(true)
            .build()

        // 2. Renderers factory supporting hardware decode with software fallback for TV Boxes
        val renderersFactory = DefaultRenderersFactory(context).apply {
            setExtensionRendererMode(DefaultRenderersFactory.EXTENSION_RENDERER_MODE_PREFER)
            setEnableDecoderFallback(true)
        }

        // 3. OkHttp Data Source with custom User-Agent to prevent 403 Forbidden on IPTV servers
        val httpDataSourceFactory = OkHttpDataSource.Factory(ApiClient.okHttpClient)
            .setUserAgent(ApiClient.USER_AGENT)

        val dataSourceFactory = DefaultDataSource.Factory(context, httpDataSourceFactory)
        val mediaSourceFactory = DefaultMediaSourceFactory(dataSourceFactory)

        player = ExoPlayer.Builder(context, renderersFactory)
            .setMediaSourceFactory(mediaSourceFactory)
            .setLoadControl(loadControl)
            .setSeekBackIncrementMs(10_000)
            .setSeekForwardIncrementMs(10_000)
            .build().apply {
                playWhenReady = true
                videoScalingMode = C.VIDEO_SCALING_MODE_SCALE_TO_FIT
                addListener(createPlayerListener())
            }

        playerView.player = player
        applyResizeMode()
    }

    private fun createPlayerListener() = object : Player.Listener {
        override fun onPlaybackStateChanged(playbackState: Int) {
            when (playbackState) {
                Player.STATE_BUFFERING -> {
                    listener.onBuffering(true)
                }
                Player.STATE_READY -> {
                    retryCount = 0
                    listener.onBuffering(false)
                    listener.onPlaybackStarted()
                }
                Player.STATE_ENDED -> {
                    listener.onBuffering(false)
                }
                Player.STATE_IDLE -> {
                    // Idle
                }
            }
        }

        override fun onPlayerError(error: PlaybackException) {
            listener.onBuffering(false)
            val errorMsg = error.localizedMessage ?: "Bilinmeyen oynatma hatası"

            if (retryCount < maxRetries) {
                retryCount++
                listener.onError("Yayın bağlantısı koptu. Yeniden deneniyor ($retryCount/$maxRetries)…", true)
                retryJob?.cancel()
                retryJob = scope.launch {
                    delay(2000L * retryCount)
                    currentChannel?.let { playChannel(it) }
                }
            } else {
                listener.onError("Yayın açılamıyor ($errorMsg). Başka bir kanal seçebilirsiniz.", false)
            }
        }
    }

    fun playChannel(channel: Channel) {
        currentChannel = channel
        val streamUrl = channel.streamUrl.trim()

        val uri = Uri.parse(streamUrl)
        val mediaItem = buildMediaItem(uri)

        player?.let { p ->
            p.stop()
            p.setMediaItem(mediaItem)
            p.prepare()
            p.play()
        }
    }

    private fun buildMediaItem(uri: Uri): MediaItem {
        val uriStr = uri.toString().lowercase()
        val builder = MediaItem.Builder().setUri(uri)

        when {
            uriStr.contains(".m3u8") || uriStr.contains("type=m3u") -> {
                builder.setMimeType(MimeTypes.APPLICATION_M3U8)
            }
            uriStr.contains(".mpd") -> {
                builder.setMimeType(MimeTypes.APPLICATION_MPD)
            }
            uriStr.contains(".mp4") -> {
                builder.setMimeType(MimeTypes.APPLICATION_MP4)
            }
            uriStr.contains(".ts") -> {
                // MPEG-TS live stream
                builder.setMimeType(MimeTypes.VIDEO_MP2T)
            }
        }

        return builder.build()
    }

    fun cycleAspectRatio(): String {
        currentResizeModeIndex = (currentResizeModeIndex + 1) % resizeModes.size
        applyResizeMode()
        return resizeModes[currentResizeModeIndex].second
    }

    private fun applyResizeMode() {
        val mode = resizeModes[currentResizeModeIndex].first
        playerView.resizeMode = mode
    }

    fun getAspectRatioName(): String = resizeModes[currentResizeModeIndex].second

    fun retryCurrentChannel() {
        retryCount = 0
        currentChannel?.let { playChannel(it) }
    }

    fun release() {
        retryJob?.cancel()
        player?.release()
        player = null
    }

    fun isPlaying(): Boolean = player?.isPlaying == true

    fun pause() {
        player?.pause()
    }

    fun resume() {
        player?.play()
    }
}
