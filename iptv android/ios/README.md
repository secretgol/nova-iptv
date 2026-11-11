# Nova IPTV iOS - Native Apple SwiftUI IPTV Uygulaması

Bu proje, daha önce geliştirilen Android Box IPTV uygulamasının **Apple iOS (iPhone & iPad)** ekosistemine özel olarak sıfırdan uyarlanmış, modern ve performanslı yerel (native) **Swift / SwiftUI** versiyonudur.

---

## 📱 iOS Ekosistemine Özel Özellikler ve Kararlılık

1. **Apple AVFoundation & AVPlayer ile Akıcı Oynatma:**
   - Apple'ın yerel video oynatma motoru kullanılarak HLS (`.m3u8`), TS ve MP4 akışlarında minimum pil tüketimi ve 60 FPS akıcılık sağlanır.
   - **Resim İçinde Resim (Picture-in-Picture - PiP):** Diğer uygulamaları kullanırken veya ana ekrana döndüğünüzde canlı yayın küçük pencerede kesilmeden oynamaya devam eder.
   - **AirPlay 2 Desteği:** Tek dokunuşla Apple TV veya AirPlay uyumlu akıllı televizyonlara canlı yayını yansıtma.
   - **Arka Planda Ses Çalma:** Telefon kilitlendiğinde dahi yayının sesini dinlemeye devam edebilme (`UIBackgroundModes: audio`).

2. **Apple Güvenlik (ATS) ve IPTV Sunucu Engeli Aşma:**
   - Standart iOS uygulamaları güvensiz saydığı `http://` bağlantılarını engeller. Çoğu IPTV sağlayıcısı HTTP üzerinden çalıştığı için `Info.plist` üzerinde `NSAllowsArbitraryLoads = true` etkinleştirilmiştir.
   - IPTV sunucularının iOS Safari veya varsayılan Apple Player isteklerini reddetmesini (403 Forbidden) önlemek için tüm isteklere ve `AVURLAsset` oturumlarına özel `User-Agent: IPTVSmarters/2.1.0` tanımlanmıştır.

3. **M3U / M3U8 ve Xtream Codes API Desteği:**
   - Büyük çalma listelerini belleği yormadan asenkron ayrıştıran yüksek hızlı `M3UParser`.
   - Sunucu adresi, kullanıcı adı ve şifre ile çalışan yerel `XtreamService` API istemcisi.
   - İlk kurulumda hemen test edebilmeniz için yasal Türkiye ve dünya kanalları (TRT 1, TRT Spor, TRT Haber, TRT Belgesel, Euronews, NASA TV, Bloomberg vb.) hazır tanımlıdır.

4. **Kullanıcı Deneyimi:**
   - Tamamen OLED dostu karanlık tema.
   - Ekran formatı değiştirici (Orantılı Fit / Tam Ekran Fill).
   - Canlı yayını kesmeden ekrana gelen hızlı kanal çekmecesi.
   - Sağa/sola kaydırarak sonraki/önceki kanala geçme hareketleri (swipe gestures).
   - Favori yönetimi ve anlık kanal araması.

---

## 📂 iOS Proje Klasör Yapısı

```
ios/
├── NovaIPTV.xcodeproj/            # Doğrudan Xcode ile açılabilen proje dosyası
│   └── project.pbxproj
└── NovaIPTV/
    ├── App/
    │   ├── NovaIPTVApp.swift      # Uygulama giriş noktası ve UI teması
    │   └── Info.plist             # ATS HTTP izinleri & Arka plan izinleri
    ├── Models/
    │   ├── Channel.swift          # Kanal veri modeli
    │   ├── Category.swift         # Kategori modeli
    │   └── XtreamModels.swift     # Xtream API yanıt modelleri
    ├── Services/
    │   ├── M3UParser.swift        # Hızlı M3U satır ayrıştırıcı
    │   ├── XtreamService.swift    # Xtream Codes API istemcisi
    │   ├── IPTVRepository.swift   # Veri yönetimi, filtreleme ve önbellek
    │   ├── PreferencesManager.swift # UserDefaults ayar saklayıcı
    │   └── SamplePlaylists.swift  # Yasal test kanalları
    ├── Player/
    │   ├── PlayerViewModel.swift  # AVPlayer, arabellek ve hata kurtarma
    │   └── IPTVPlayerView.swift   # Tam ekran video & kontroller
    ├── Views/
    │   ├── MainTabView.swift      # Alt menü (Canlı TV, Kategoriler, Favoriler, Ayarlar)
    │   ├── ChannelsView.swift     # Kanal ızgarası & arama
    │   ├── CategoriesView.swift   # Kategori listesi
    │   ├── FavoritesView.swift    # Favori kanallar
    │   ├── SettingsView.swift     # Oynatma listesi yönetimi & sistem durumu
    │   ├── PlaylistSetupView.swift # M3U / Xtream giriş ekranı
    │   └── Components/
    │       ├── ChannelCard.swift  # Kanal kartı bileşeni
    │       └── CategoryPillsView.swift # Kategori filtre butonları
    └── Assets.xcassets/           # Uygulama ikonları ve tema renkleri
```

---

## 🚀 Nasıl Çalıştırılır ve iPhone'a Yüklenir?

### Yöntem 1: macOS ve Xcode İle (Resmi Yol)
1. Bu `ios` klasörünü bir Mac bilgisayara aktarın.
2. `NovaIPTV.xcodeproj` dosyasına çift tıklayarak **Xcode** ile açın.
3. iPhone'unuzu kablo ile bağlayın (veya Xcode Simülatörünü seçin).
4. Sol üstteki **Run (Oynat / ⌘R)** butonuna basarak uygulamayı doğrudan telefonunuza yükleyin.

### Yöntem 2: AltStore / Sideloadly İle (Mac Olmadan Windows Üzerinden)
1. GitHub Actions ([ios-build.yml](../.github/workflows/ios-build.yml)) üzerinden otomatik üretilen `NovaIPTV.app` veya `.ipa` arşivini indirin.
2. Windows bilgisayarınızda **Sideloadly** veya **AltStore** programını açın.
3. Apple ID'nizi girip `.ipa` dosyasını seçerek iPhone'unuza doğrudan yükleyin.
