package com.iptv.tvbox.ui

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.KeyEvent
import android.view.View
import android.widget.Toast
import androidx.annotation.OptIn
import androidx.appcompat.app.AppCompatActivity
import androidx.media3.common.util.UnstableApi
import androidx.recyclerview.widget.LinearLayoutManager
import com.iptv.tvbox.R
import com.iptv.tvbox.data.model.Channel
import com.iptv.tvbox.databinding.ActivityPlayerBinding
import com.iptv.tvbox.player.IPTVPlayerManager
import com.iptv.tvbox.ui.adapter.ChannelAdapter
import com.iptv.tvbox.ui.util.FocusHelper
import com.iptv.tvbox.ui.util.PreferencesManager

@OptIn(UnstableApi::class)
class PlayerActivity : AppCompatActivity(), IPTVPlayerManager.PlayerStateListener {

    private lateinit var binding: ActivityPlayerBinding
    private lateinit var playerManager: IPTVPlayerManager
    private lateinit var prefs: PreferencesManager

    private var channelList: ArrayList<Channel> = arrayListOf()
    private var currentIndex = 0
    private var isOsdVisible = true
    private val osdHandler = Handler(Looper.getMainLooper())
    private val hideOsdRunnable = Runnable { hideOsd() }

    private lateinit var quickDrawerAdapter: ChannelAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityPlayerBinding.inflate(layoutInflater)
        setContentView(binding.root)

        prefs = PreferencesManager(this)

        @Suppress("DEPRECATION")
        val passedList = intent.getSerializableExtra(EXTRA_CHANNEL_LIST) as? ArrayList<Channel>
        if (!passedList.isNullOrEmpty()) {
            channelList = passedList
        }
        currentIndex = intent.getIntExtra(EXTRA_START_INDEX, 0)

        initPlayer()
        setupQuickDrawer()
        setupControls()

        if (channelList.isNotEmpty() && currentIndex in channelList.indices) {
            playCurrentChannel()
        } else {
            Toast.makeText(this, "Oynatılacak kanal bulunamadı", Toast.LENGTH_SHORT).show()
            finish()
        }
    }

    private fun initPlayer() {
        playerManager = IPTVPlayerManager(this, binding.playerView, this)
    }

    private fun setupControls() {
        FocusHelper.setupTvFocusAnimation(binding.btnAspectRatio, 1.05f)
        FocusHelper.setupTvFocusAnimation(binding.btnPlayerFavorite, 1.05f)
        FocusHelper.setupTvFocusAnimation(binding.btnRetry, 1.05f)

        binding.btnAspectRatio.setOnClickListener {
            val name = playerManager.cycleAspectRatio()
            binding.btnAspectRatio.text = "Oran: $name"
            resetOsdTimer()
        }

        binding.btnPlayerFavorite.setOnClickListener {
            toggleCurrentFavorite()
            resetOsdTimer()
        }

        binding.btnRetry.setOnClickListener {
            binding.layoutError.visibility = View.GONE
            playerManager.retryCurrentChannel()
        }
    }

    private fun setupQuickDrawer() {
        quickDrawerAdapter = ChannelAdapter(
            onChannelClick = { selectedChannel ->
                val newIndex = channelList.indexOfFirst { it.id == selectedChannel.id }
                if (newIndex != -1) {
                    currentIndex = newIndex
                    playCurrentChannel()
                    closeQuickDrawer()
                }
            },
            onChannelLongClick = { selectedChannel ->
                val isFav = prefs.toggleFavorite(selectedChannel.id)
                selectedChannel.isFavorite = isFav
                quickDrawerAdapter.notifyDataSetChanged()
                Toast.makeText(
                    this,
                    if (isFav) R.string.added_to_favorites else R.string.removed_from_favorites,
                    Toast.LENGTH_SHORT
                ).show()
                true
            }
        )

        binding.rvQuickChannels.apply {
            layoutManager = LinearLayoutManager(this@PlayerActivity)
            adapter = quickDrawerAdapter
        }
        quickDrawerAdapter.submitList(channelList)
    }

    private fun playCurrentChannel() {
        val channel = channelList[currentIndex]
        prefs.lastChannelId = channel.id

        // Update OSD Top Info
        binding.txtPlayerChannelNumber.text = channel.channelNum.toString()
        binding.txtPlayerChannelName.text = channel.name
        binding.txtPlayerCategory.text = channel.category
        binding.txtPlayerStreamUrl.text = channel.streamUrl

        updateFavoriteButtonIcon(channel.isFavorite)
        binding.layoutError.visibility = View.GONE

        playerManager.playChannel(channel)
        showOsd()
    }

    private fun nextChannel() {
        if (channelList.isEmpty()) return
        currentIndex = (currentIndex + 1) % channelList.size
        playCurrentChannel()
    }

    private fun previousChannel() {
        if (channelList.isEmpty()) return
        currentIndex = if (currentIndex - 1 < 0) channelList.size - 1 else currentIndex - 1
        playCurrentChannel()
    }

    private fun toggleCurrentFavorite() {
        if (channelList.isEmpty()) return
        val channel = channelList[currentIndex]
        val isFav = prefs.toggleFavorite(channel.id)
        channel.isFavorite = isFav
        updateFavoriteButtonIcon(isFav)
        quickDrawerAdapter.notifyDataSetChanged()

        Toast.makeText(
            this,
            if (isFav) R.string.added_to_favorites else R.string.removed_from_favorites,
            Toast.LENGTH_SHORT
        ).show()
    }

    private fun updateFavoriteButtonIcon(isFavorite: Boolean) {
        if (isFavorite) {
            binding.btnPlayerFavorite.setImageResource(R.drawable.ic_favorite)
        } else {
            binding.btnPlayerFavorite.setImageResource(R.drawable.ic_favorite_border)
        }
    }

    private fun showOsd() {
        isOsdVisible = true
        binding.layoutOsdTop.visibility = View.VISIBLE
        binding.layoutOsdBottom.visibility = View.VISIBLE
        resetOsdTimer()
    }

    private fun hideOsd() {
        isOsdVisible = false
        binding.layoutOsdTop.visibility = View.GONE
        binding.layoutOsdBottom.visibility = View.GONE
    }

    private fun resetOsdTimer() {
        osdHandler.removeCallbacks(hideOsdRunnable)
        osdHandler.postDelayed(hideOsdRunnable, OSD_TIMEOUT_MS)
    }

    private fun openQuickDrawer() {
        binding.layoutQuickDrawer.visibility = View.VISIBLE
        binding.rvQuickChannels.requestFocus()
        binding.rvQuickChannels.scrollToPosition(currentIndex)
        osdHandler.removeCallbacks(hideOsdRunnable)
    }

    private fun closeQuickDrawer() {
        binding.layoutQuickDrawer.visibility = View.GONE
        showOsd()
    }

    // Android Box Remote Control Key Events
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        when (keyCode) {
            KeyEvent.KEYCODE_DPAD_UP, KeyEvent.KEYCODE_CHANNEL_UP -> {
                if (binding.layoutQuickDrawer.visibility == View.VISIBLE) {
                    return super.onKeyDown(keyCode, event)
                }
                previousChannel()
                return true
            }
            KeyEvent.KEYCODE_DPAD_DOWN, KeyEvent.KEYCODE_CHANNEL_DOWN -> {
                if (binding.layoutQuickDrawer.visibility == View.VISIBLE) {
                    return super.onKeyDown(keyCode, event)
                }
                nextChannel()
                return true
            }
            KeyEvent.KEYCODE_DPAD_CENTER, KeyEvent.KEYCODE_ENTER -> {
                if (binding.layoutQuickDrawer.visibility == View.VISIBLE) {
                    return super.onKeyDown(keyCode, event)
                }
                if (isOsdVisible) {
                    hideOsd()
                } else {
                    showOsd()
                }
                return true
            }
            KeyEvent.KEYCODE_DPAD_LEFT -> {
                if (binding.layoutQuickDrawer.visibility != View.VISIBLE) {
                    openQuickDrawer()
                    return true
                }
            }
            KeyEvent.KEYCODE_DPAD_RIGHT -> {
                if (binding.layoutQuickDrawer.visibility == View.VISIBLE) {
                    closeQuickDrawer()
                    return true
                } else {
                    val name = playerManager.cycleAspectRatio()
                    binding.btnAspectRatio.text = "Oran: $name"
                    showOsd()
                    return true
                }
            }
            KeyEvent.KEYCODE_PROG_BLUE -> {
                toggleCurrentFavorite()
                return true
            }
            KeyEvent.KEYCODE_PROG_YELLOW, KeyEvent.KEYCODE_MENU -> {
                val name = playerManager.cycleAspectRatio()
                binding.btnAspectRatio.text = "Oran: $name"
                showOsd()
                return true
            }
            KeyEvent.KEYCODE_BACK -> {
                if (binding.layoutQuickDrawer.visibility == View.VISIBLE) {
                    closeQuickDrawer()
                    return true
                }
            }
        }
        return super.onKeyDown(keyCode, event)
    }

    // PlayerStateListener Implementation
    override fun onBuffering(isBuffering: Boolean) {
        binding.progressBuffering.visibility = if (isBuffering) View.VISIBLE else View.GONE
    }

    override fun onPlaybackStarted() {
        binding.layoutError.visibility = View.GONE
    }

    override fun onError(errorMessage: String, isRecoverable: Boolean) {
        if (!isRecoverable) {
            binding.layoutError.visibility = View.VISIBLE
            binding.txtErrorMessage.text = errorMessage
            binding.btnRetry.requestFocus()
        } else {
            Toast.makeText(this, errorMessage, Toast.LENGTH_SHORT).show()
        }
    }

    override fun onStop() {
        super.onStop()
        playerManager.pause()
    }

    override fun onDestroy() {
        super.onDestroy()
        osdHandler.removeCallbacks(hideOsdRunnable)
        playerManager.release()
    }

    companion object {
        const val EXTRA_CHANNEL_LIST = "extra_channel_list"
        const val EXTRA_START_INDEX = "extra_start_index"
        private const val OSD_TIMEOUT_MS = 5000L
    }
}
