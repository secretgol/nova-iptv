package com.iptv.tvbox.ui.util

import com.iptv.tvbox.data.model.Channel

object SamplePlaylists {

    fun getSampleChannels(): List<Channel> {
        val list = mutableListOf<Channel>()
        var index = 1

        fun add(name: String, category: String, url: String, logo: String) {
            list.add(
                Channel(
                    id = "sample_${index}",
                    name = name,
                    logoUrl = logo,
                    streamUrl = url,
                    category = category,
                    channelNum = index++
                )
            )
        }

        // --- TÜRKİYE ULUSAL & GENEL ---
        add(
            name = "TRT 1 HD",
            category = "Ulusal",
            url = "https://tv-trt1.medya.trt.com.tr/master.m3u8",
            logo = "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tvplus.com.tr/trt1.png"
        )
        add(
            name = "TRT 2 Kültür Sanat",
            category = "Ulusal",
            url = "https://tv-trt2.medya.trt.com.tr/master.m3u8",
            logo = "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tvplus.com.tr/trt2.png"
        )
        add(
            name = "TRT Türk",
            category = "Ulusal",
            url = "https://tv-trtturk.medya.trt.com.tr/master.m3u8",
            logo = "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tvplus.com.tr/trtturk.png"
        )
        add(
            name = "TRT Avaz",
            category = "Ulusal",
            url = "https://tv-trtavaz.medya.trt.com.tr/master.m3u8",
            logo = "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tvplus.com.tr/trtavaz.png"
        )

        // --- HABER ---
        add(
            name = "TRT Haber HD",
            category = "Haber",
            url = "https://tv-trthaber.medya.trt.com.tr/master.m3u8",
            logo = "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tvplus.com.tr/trthaber.png"
        )
        add(
            name = "Haber Global",
            category = "Haber",
            url = "https://haberglobal.daioncdn.net/haberglobal/haberglobal.m3u8",
            logo = "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tvplus.com.tr/haberglobal.png"
        )
        add(
            name = "TRT World HD",
            category = "Haber",
            url = "https://tv-trtworld.medya.trt.com.tr/master.m3u8",
            logo = "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tvplus.com.tr/trtworld.png"
        )
        add(
            name = "Euronews Türkçe",
            category = "Haber",
            url = "https://rakuten-euronews-7-tr.samsung.wurl.tv/playlist.m3u8",
            logo = "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tvplus.com.tr/euronews.png"
        )

        // --- SPOR ---
        add(
            name = "TRT Spor HD",
            category = "Spor",
            url = "https://tv-trtspor1.medya.trt.com.tr/master.m3u8",
            logo = "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tvplus.com.tr/trtspor.png"
        )
        add(
            name = "TRT Spor Yıldız",
            category = "Spor",
            url = "https://tv-trtspor2.medya.trt.com.tr/master.m3u8",
            logo = "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tvplus.com.tr/trtspor2.png"
        )
        add(
            name = "Red Bull TV",
            category = "Spor",
            url = "https://rbmn-live.akamaized.net/hls/live/590964/BoRB-AT/master.m3u8",
            logo = "https://i.imgur.com/8QjZ5eN.png"
        )

        // --- BELGESEL & YAŞAM ---
        add(
            name = "TRT Belgesel HD",
            category = "Belgesel",
            url = "https://tv-trtbelgesel.medya.trt.com.tr/master.m3u8",
            logo = "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tvplus.com.tr/trtbelgesel.png"
        )
        add(
            name = "NASA TV",
            category = "Belgesel",
            url = "https://ntv1.akamaized.net/hls/live/2014075/NASA-NTV1-HLS/master.m3u8",
            logo = "https://i.imgur.com/iZ2tZ4S.png"
        )

        // --- ÇOCUK & MÜZİK ---
        add(
            name = "TRT Çocuk HD",
            category = "Çocuk",
            url = "https://tv-trtcocuk.medya.trt.com.tr/master.m3u8",
            logo = "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tvplus.com.tr/trtcocuk.png"
        )
        add(
            name = "TRT Müzik",
            category = "Müzik",
            url = "https://tv-trtmuzik.medya.trt.com.tr/master.m3u8",
            logo = "https://raw.githubusercontent.com/iptv-org/epg/master/sites/tvplus.com.tr/trtmuzik.png"
        )

        // --- DÜNYA & ULUSLARARASI ---
        add(
            name = "Bloomberg TV (US)",
            category = "Dünya",
            url = "https://bloomberg.com/media-manifest/streams/us.m3u8",
            logo = "https://i.imgur.com/y3y3y3y.png"
        )
        add(
            name = "France 24 English",
            category = "Dünya",
            url = "https://stream.france24.com/hls/en/live.m3u8",
            logo = "https://i.imgur.com/france24.png"
        )
        add(
            name = "DW English News",
            category = "Dünya",
            url = "https://dwamdstream102.akamaized.net/hls/live/2015525/dwstream102/index.m3u8",
            logo = "https://i.imgur.com/dwlogo.png"
        )

        return list
    }
}
