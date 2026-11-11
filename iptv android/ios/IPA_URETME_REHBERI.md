# Nova IPTV iOS — GitHub Üzerinden .IPA Üretme Rehberi

Bu rehber, Windows bilgisayarınızda Mac veya Xcode **olmadan**, GitHub'ın ücretsiz macOS sunucularını kullanarak `.ipa` dosyası üretmenizi ve iPhone'unuza yüklemenizi adım adım anlatır.

---

## 📋 Ön Gereksinimler

- Ücretsiz bir **GitHub hesabı** ([github.com](https://github.com))
- iPhone'unuza yüklemek için ücretsiz bir **Apple ID** (zaten varsa yeterli)
- Windows bilgisayarınızda **Sideloadly** veya **AltStore** (ücretsiz)

> [!NOTE]
> GitHub Actions, her ücretsiz hesaba ayda **2.000 dakika** macOS derleme süresi verir.
> Bu proje yaklaşık 3-5 dakikada derlenir, yani aylık kotanızın çok küçük bir kısmını kullanır.

---

## 🚀 Adım Adım Rehber

### Adım 1: GitHub'da Yeni Repo Oluşturun

1. [github.com/new](https://github.com/new) adresine gidin.
2. **Repository name** alanına `nova-iptv` yazın.
3. **Private** (Gizli) seçin — kodunuz sadece size görünür olur.
4. **Create repository** butonuna basın.

### Adım 2: Proje Dosyalarını GitHub'a Yükleyin

GitHub reponuzun ana sayfasında **"uploading an existing file"** bağlantısına tıklayın ve bu klasördeki tüm dosyaları sürükleyip bırakın:

```
c:\Users\secre\OneDrive\Masaüstü\ai klasörü\iptv android\
```

Yüklenecek klasör ve dosyalar:
```
.github/          ← (workflows klasörü dahil — ÖNEMLİ!)
app/              ← Android kaynak kodları
ios/              ← iOS kaynak kodları
gradle/
build.gradle.kts
settings.gradle.kts
gradle.properties
gradlew
gradlew.bat
README.md
```

> [!IMPORTANT]
> `.github` klasörünü **mutlaka** yükleyin — bu klasör içindeki `workflows/ios-build.yml` dosyası
> otomatik derlemeyi tetikleyen dosyadır. Yüklenmezse derleme başlamaz.

**Commit changes** butonuna basın.

### Adım 3: GitHub Actions Derlemeyi Otomatik Başlatır

1. Reponuzun üst menüsünden **Actions** sekmesine tıklayın.
2. Sol tarafta **"iOS Nova IPTV - Build IPA"** iş akışını göreceksiniz.
3. Dosyaları yüklediğiniz anda derleme otomatik olarak başlar.
4. Sarı daire 🟡 → Derleniyor, Yeşil tik ✅ → Tamamlandı anlamına gelir.

> İlk sefer GitHub sizden Actions'ı etkinleştirmenizi isteyebilir.
> "I understand my workflows, go ahead and enable them" butonuna basın.

### Adım 4: .IPA Dosyasını İndirin

1. ✅ yeşil tik olan tamamlanmış derlemeye tıklayın.
2. Sayfanın **en altında** **Artifacts** bölümünü bulun.
3. **NovaIPTV-iOS-IPA** satırına tıklayın → `.ipa` dosyası otomatik indirilir.

```
İndirilen dosya: NovaIPTV-iOS-IPA.zip
Zip'in içinde:   NovaIPTV.ipa
```

### Adım 5: .IPA'yı iPhone'a Yükleme (Sideloading)

#### Yöntem A: Sideloadly ile (En Kolay - Windows)

1. [sideloadly.io](https://sideloadly.io/) adresinden **Sideloadly** programını indirip kurun.
2. iPhone'unuzu USB kablo ile bilgisayara bağlayın.
3. Sideloadly'i açın:
   - **IPA** alanına indirdiğiniz `NovaIPTV.ipa` dosyasını sürükleyin.
   - **Apple ID** alanına Apple hesabınızı girin.
   - **Start** butonuna basın.
4. Apple ID şifrenizi girin (2FA kodu gerekebilir).
5. iPhone'unuzda **Ayarlar → Genel → VPN ve Cihaz Yönetimi** yolunu izleyin.
6. Apple ID'nize ait profili bulun ve **"Güven"** seçeneğine dokunun.
7. 🎉 Nova IPTV uygulaması ana ekranınızda hazır!

#### Yöntem B: AltStore ile

1. [altstore.io](https://altstore.io/) adresinden AltServer'ı Windows'a kurun.
2. iPhone'unuzu bağlayın, AltServer üzerinden AltStore'u telefonunuza yükleyin.
3. iPhone'unuzdaki AltStore uygulamasını açın → **My Apps** → sol üstteki **+** butonu.
4. `NovaIPTV.ipa` dosyasını seçin → Yükleme başlar.

> [!WARNING]
> Ücretsiz Apple ID ile yüklenen uygulamalar **7 gün** sonra süresi dolar.
> Sideloadly veya AltStore ile her 7 günde bir yeniden imzalamanız gerekir.
> AltStore bunu arka planda otomatik yapabilir (bilgisayar açıkken ve telefon aynı Wi-Fi'daysa).

---

## 🔄 Manuel Tetikleme (İstediğiniz Zaman Yeniden Derleme)

Kod değişikliği yapmadan da yeni bir `.ipa` üretebilirsiniz:

1. GitHub reponuzda **Actions** sekmesine gidin.
2. Sol taraftaki **"iOS Nova IPTV - Build IPA"** iş akışını seçin.
3. Sağ üstteki **"Run workflow"** butonuna basın → **Run workflow**.
4. Derleme tamamlandığında Artifacts'ten yeni `.ipa`'yı indirin.

---

## ❓ Sık Sorulan Sorular

**S: Apple Developer hesabı (\$99/yıl) gerekli mi?**
H: Hayır. Bu yöntem ücretsiz Apple ID ile çalışır. Ancak 7 günde bir yeniden imzalama gerekir.

**S: Derleme hata veriyor, ne yapmalıyım?**
H: Actions sekmesinde kırmızı ❌ olan derlemeye tıklayın ve log'ları kontrol edin. En yaygın sorun `.github/workflows` klasörünün yüklenmemiş olmasıdır.

**S: App Store'a yükleyebilir miyim?**
H: Evet, ancak bunun için Apple Developer Program'a (\$99/yıl) üye olmanız ve uygulama inceleme sürecinden geçmeniz gerekir.
