package com.iptv.tvbox.ui

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.iptv.tvbox.R
import com.iptv.tvbox.databinding.ActivityPlaylistInputBinding
import com.iptv.tvbox.ui.util.FocusHelper
import com.iptv.tvbox.ui.util.PreferencesManager

class PlaylistSetupActivity : AppCompatActivity() {

    private lateinit var binding: ActivityPlaylistInputBinding
    private lateinit var prefs: PreferencesManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityPlaylistInputBinding.inflate(layoutInflater)
        setContentView(binding.root)

        prefs = PreferencesManager(this)

        setupFocus()
        setupListeners()
        populateExistingData()
    }

    private fun setupFocus() {
        FocusHelper.setupTvFocusAnimation(binding.btnBack, 1.05f)
        FocusHelper.setupTvFocusAnimation(binding.tabM3U, 1.05f)
        FocusHelper.setupTvFocusAnimation(binding.tabXtream, 1.05f)
        FocusHelper.setupTvFocusAnimation(binding.btnSaveM3U, 1.03f)
        FocusHelper.setupTvFocusAnimation(binding.btnSaveXtream, 1.03f)
        FocusHelper.setupTvFocusAnimation(binding.btnLoadDemoTurkey, 1.03f)
        FocusHelper.setupTvFocusAnimation(binding.btnLoadDemoWorld, 1.03f)

        binding.edtM3uUrl.requestFocus()
    }

    private fun setupListeners() {
        binding.btnBack.setOnClickListener {
            finish()
        }

        binding.tabM3U.setOnClickListener {
            showM3uSection()
        }

        binding.tabXtream.setOnClickListener {
            showXtreamSection()
        }

        binding.btnSaveM3U.setOnClickListener {
            val url = binding.edtM3uUrl.text.toString().trim()
            if (url.isBlank()) {
                Toast.makeText(this, "Lütfen geçerli bir M3U bağlantısı girin", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            prefs.activePlaylistType = PreferencesManager.TYPE_M3U
            prefs.m3uUrl = url
            Toast.makeText(this, "M3U listesi kaydedildi", Toast.LENGTH_SHORT).show()
            setResult(Activity.RESULT_OK)
            finish()
        }

        binding.btnSaveXtream.setOnClickListener {
            val server = binding.edtXtreamServer.text.toString().trim()
            val user = binding.edtXtreamUser.text.toString().trim()
            val pass = binding.edtXtreamPass.text.toString().trim()

            if (server.isBlank() || user.isBlank() || pass.isBlank()) {
                Toast.makeText(this, "Lütfen tüm Xtream alanlarını doldurun", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            prefs.activePlaylistType = PreferencesManager.TYPE_XTREAM
            prefs.xtreamServer = server
            prefs.xtreamUser = user
            prefs.xtreamPass = pass
            Toast.makeText(this, "Xtream hesap bilgileri kaydedildi", Toast.LENGTH_SHORT).show()
            setResult(Activity.RESULT_OK)
            finish()
        }

        binding.btnLoadDemoTurkey.setOnClickListener {
            prefs.activePlaylistType = PreferencesManager.TYPE_SAMPLE
            Toast.makeText(this, "Ücretsiz Türkiye kanalları yüklendi", Toast.LENGTH_SHORT).show()
            setResult(Activity.RESULT_OK)
            finish()
        }

        binding.btnLoadDemoWorld.setOnClickListener {
            prefs.activePlaylistType = PreferencesManager.TYPE_SAMPLE
            Toast.makeText(this, "Uluslararası test kanalları yüklendi", Toast.LENGTH_SHORT).show()
            setResult(Activity.RESULT_OK)
            finish()
        }
    }

    private fun showM3uSection() {
        binding.sectionM3U.visibility = View.VISIBLE
        binding.sectionXtream.visibility = View.GONE
        binding.tabM3U.setTextColor(getColor(R.color.white))
        binding.tabXtream.setTextColor(getColor(R.color.text_secondary))
        binding.edtM3uUrl.requestFocus()
    }

    private fun showXtreamSection() {
        binding.sectionM3U.visibility = View.GONE
        binding.sectionXtream.visibility = View.VISIBLE
        binding.tabM3U.setTextColor(getColor(R.color.text_secondary))
        binding.tabXtream.setTextColor(getColor(R.color.white))
        binding.edtXtreamServer.requestFocus()
    }

    private fun populateExistingData() {
        binding.edtM3uUrl.setText(prefs.m3uUrl)
        binding.edtXtreamServer.setText(prefs.xtreamServer)
        binding.edtXtreamUser.setText(prefs.xtreamUser)
        binding.edtXtreamPass.setText(prefs.xtreamPass)

        if (prefs.activePlaylistType == PreferencesManager.TYPE_XTREAM) {
            showXtreamSection()
        } else {
            showM3uSection()
        }
    }
}
