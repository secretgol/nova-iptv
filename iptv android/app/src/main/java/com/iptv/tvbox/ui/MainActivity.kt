package com.iptv.tvbox.ui

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.KeyEvent
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import com.iptv.tvbox.R
import com.iptv.tvbox.data.model.Category
import com.iptv.tvbox.data.model.Channel
import com.iptv.tvbox.data.repository.IPTVRepository
import com.iptv.tvbox.databinding.ActivityMainBinding
import com.iptv.tvbox.ui.adapter.CategoryAdapter
import com.iptv.tvbox.ui.adapter.ChannelAdapter
import com.iptv.tvbox.ui.util.FocusHelper
import com.iptv.tvbox.ui.util.PreferencesManager
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var prefs: PreferencesManager
    private lateinit var repository: IPTVRepository

    private lateinit var categoryAdapter: CategoryAdapter
    private lateinit var channelAdapter: ChannelAdapter

    private var activeCategoryId: String = Category.ID_ALL
    private var currentFilteredChannels: List<Channel> = emptyList()

    private val setupLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            loadPlaylist()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        prefs = PreferencesManager(this)
        repository = IPTVRepository(prefs)

        setupUI()
        setupAdapters()
        setupListeners()
        loadPlaylist()
    }

    private fun setupUI() {
        FocusHelper.setupTvFocusAnimation(binding.edtSearch, 1.05f)
        FocusHelper.setupTvFocusAnimation(binding.btnFavorites, 1.05f)
        FocusHelper.setupTvFocusAnimation(binding.btnSettings, 1.05f)
        FocusHelper.setupTvFocusAnimation(binding.btnEmptySetup, 1.05f)
    }

    private fun setupAdapters() {
        // Categories list (Horizontal)
        categoryAdapter = CategoryAdapter(emptyList()) { category ->
            activeCategoryId = category.id
            applyFilter()
        }
        binding.rvCategories.apply {
            layoutManager = LinearLayoutManager(this@MainActivity, LinearLayoutManager.HORIZONTAL, false)
            adapter = categoryAdapter
        }

        // Channels grid (5 Columns for TV)
        channelAdapter = ChannelAdapter(
            onChannelClick = { channel ->
                openPlayer(channel)
            },
            onChannelLongClick = { channel ->
                val isFav = repository.toggleFavorite(channel)
                channelAdapter.notifyDataSetChanged()
                categoryAdapter.updateCategories(repository.getLoadedCategories())
                Toast.makeText(
                    this,
                    if (isFav) R.string.added_to_favorites else R.string.removed_from_favorites,
                    Toast.LENGTH_SHORT
                ).show()
                true
            }
        )

        binding.rvChannels.apply {
            layoutManager = GridLayoutManager(this@MainActivity, 5)
            adapter = channelAdapter
        }
    }

    private fun setupListeners() {
        binding.btnSettings.setOnClickListener {
            openPlaylistSetup()
        }

        binding.btnEmptySetup.setOnClickListener {
            openPlaylistSetup()
        }

        binding.btnFavorites.setOnClickListener {
            activeCategoryId = Category.ID_FAVORITES
            categoryAdapter.selectCategoryById(Category.ID_FAVORITES)
            applyFilter()
        }

        binding.edtSearch.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                applyFilter(s?.toString())
            }
            override fun afterTextChanged(s: Editable?) {}
        })
    }

    private fun loadPlaylist() {
        binding.layoutLoading.visibility = View.VISIBLE
        binding.layoutEmpty.visibility = View.GONE
        binding.rvChannels.visibility = View.GONE

        // Update active source indicator
        val sourceTitle = when (prefs.activePlaylistType) {
            PreferencesManager.TYPE_M3U -> "M3U URL"
            PreferencesManager.TYPE_XTREAM -> "Xtream Codes"
            else -> "Ön Tanımlı Test Kanalları"
        }
        binding.txtActiveSource.text = "Aktif Kaynak: $sourceTitle"

        lifecycleScope.launch {
            val result = repository.loadCurrentPlaylist()
            binding.layoutLoading.visibility = View.GONE

            if (result.isSuccess) {
                val channels = result.getOrNull() ?: emptyList()
                if (channels.isEmpty()) {
                    showEmptyState()
                } else {
                    binding.rvChannels.visibility = View.VISIBLE
                    categoryAdapter.updateCategories(repository.getLoadedCategories())
                    applyFilter()
                    binding.rvChannels.requestFocus()
                }
            } else {
                Toast.makeText(
                    this@MainActivity,
                    "Liste yüklenemedi: ${result.exceptionOrNull()?.message}",
                    Toast.LENGTH_LONG
                ).show()
                showEmptyState()
            }
        }
    }

    private fun applyFilter(query: String? = binding.edtSearch.text.toString()) {
        currentFilteredChannels = repository.filterChannels(activeCategoryId, query)
        channelAdapter.submitList(currentFilteredChannels)

        binding.txtChannelCount.text = getString(R.string.channel_count, currentFilteredChannels.size)

        if (currentFilteredChannels.isEmpty()) {
            binding.layoutEmpty.visibility = View.VISIBLE
            binding.txtEmptyTitle.text = getString(R.string.no_channels)
        } else {
            binding.layoutEmpty.visibility = View.GONE
            binding.rvChannels.visibility = View.VISIBLE
        }
    }

    private fun showEmptyState() {
        binding.rvChannels.visibility = View.GONE
        binding.layoutEmpty.visibility = View.VISIBLE
        binding.txtEmptyTitle.text = "Henüz Kanal Yüklenmedi"
        binding.txtChannelCount.text = "0 Kanal"
        binding.btnEmptySetup.requestFocus()
    }

    private fun openPlayer(channel: Channel) {
        if (currentFilteredChannels.isEmpty()) return

        val startIndex = currentFilteredChannels.indexOfFirst { it.id == channel.id }
        val intent = Intent(this, PlayerActivity::class.java).apply {
            putExtra(PlayerActivity.EXTRA_CHANNEL_LIST, ArrayList(currentFilteredChannels))
            putExtra(PlayerActivity.EXTRA_START_INDEX, if (startIndex != -1) startIndex else 0)
        }
        startActivity(intent)
    }

    private fun openPlaylistSetup() {
        val intent = Intent(this, PlaylistSetupActivity::class.java)
        setupLauncher.launch(intent)
    }

    override fun onResume() {
        super.onResume()
        // Refresh favorite states in case changes were made in PlayerActivity
        if (repository.getLoadedChannels().isNotEmpty()) {
            categoryAdapter.updateCategories(repository.getLoadedCategories())
            applyFilter()
        }
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_PROG_BLUE) {
            // Blue button on remote toggles favorites
            binding.btnFavorites.performClick()
            return true
        }
        if (keyCode == KeyEvent.KEYCODE_MENU) {
            openPlaylistSetup()
            return true
        }
        return super.onKeyDown(keyCode, event)
    }
}
