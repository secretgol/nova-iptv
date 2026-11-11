import SwiftUI

public struct PlaylistSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var prefs = PreferencesManager.shared
    @ObservedObject private var repository = IPTVRepository.shared

    @State private var selectedTab = 0 // 0: M3U, 1: Xtream
    @State private var m3uUrlInput = ""
    @State private var serverInput = ""
    @State private var usernameInput = ""
    @State private var passwordInput = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.07, blue: 0.10).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        // Source Switcher Picker
                        Picker("Kaynak Türü", selection: $selectedTab) {
                            Text("M3U / M3U8 URL").tag(0)
                            Text("Xtream Codes API").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        if selectedTab == 0 {
                            m3uFormView
                        } else {
                            xtreamFormView
                        }

                        Divider().background(Color.white.opacity(0.12))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)

                        demoSectionView
                    }
                }
            }
            .navigationTitle("Oynatma Listesi Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.gray)
                }
            }
            .alert("Bilgi", isPresented: $showingAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                m3uUrlInput = prefs.m3uUrl
                serverInput = prefs.xtreamServer
                usernameInput = prefs.xtreamUser
                passwordInput = prefs.xtreamPass
                selectedTab = (prefs.activePlaylistType == PreferencesManager.typeXtream) ? 1 : 0
            }
        }
    }

    // MARK: - M3U Form
    private var m3uFormView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("M3U / M3U8 Çalma Listesi Bağlantısı")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            TextField("https://sunucu.com/playlist.m3u", text: $m3uUrlInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.URL)
                .padding(14)
                .background(Color(red: 0.10, green: 0.13, blue: 0.18))
                .cornerRadius(10)
                .foregroundColor(.white)

            Button(action: saveM3u) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("M3U Listesini Yükle")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.cyan)
                .cornerRadius(12)
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Xtream Form
    private var xtreamFormView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sunucu Adresi (URL)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)

            TextField("http://sunucu.com:8080", text: $serverInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.URL)
                .padding(12)
                .background(Color(red: 0.10, green: 0.13, blue: 0.18))
                .cornerRadius(10)
                .foregroundColor(.white)

            Text("Kullanıcı Adı")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)

            TextField("Kullanıcı adı", text: $usernameInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding(12)
                .background(Color(red: 0.10, green: 0.13, blue: 0.18))
                .cornerRadius(10)
                .foregroundColor(.white)

            Text("Şifre")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)

            SecureField("Şifre", text: $passwordInput)
                .padding(12)
                .background(Color(red: 0.10, green: 0.13, blue: 0.18))
                .cornerRadius(10)
                .foregroundColor(.white)

            Button(action: saveXtream) {
                HStack {
                    Image(systemName: "lock.shield.fill")
                    Text("Xtream Hesabı ile Giriş Yap")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.cyan)
                .cornerRadius(12)
            }
            .padding(.top, 6)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Demo Presets
    private var demoSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hızlı Başlangıç (Ücretsiz Test Kanalları):")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)

            Button(action: loadDemoTurkey) {
                HStack {
                    Text("🇹🇷")
                        .font(.system(size: 20))
                    Text("Türkiye Ulusal & Haber Kanallarını Yükle")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13))
                }
                .foregroundColor(.white)
                .padding(14)
                .background(Color(red: 0.10, green: 0.13, blue: 0.18))
                .cornerRadius(10)
            }

            Button(action: loadDemoWorld) {
                HStack {
                    Text("🌍")
                        .font(.system(size: 20))
                    Text("Uluslararası Ücretsiz Haber & Spor Kanalları")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13))
                }
                .foregroundColor(.white)
                .padding(14)
                .background(Color(red: 0.10, green: 0.13, blue: 0.18))
                .cornerRadius(10)
            }
        }
        .padding(.horizontal, 20)
    }

    private func saveM3u() {
        let clean = m3uUrlInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else {
            alertMessage = "Lütfen geçerli bir M3U URL bağlantısı girin."
            showingAlert = true
            return
        }

        prefs.activePlaylistType = PreferencesManager.typeM3U
        prefs.m3uUrl = clean
        Task {
            await repository.loadCurrentPlaylist()
            dismiss()
        }
    }

    private func saveXtream() {
        let server = serverInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let user = usernameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = passwordInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !server.isEmpty, !user.isEmpty, !pass.isEmpty else {
            alertMessage = "Lütfen tüm Xtream alanlarını doldurun."
            showingAlert = true
            return
        }

        prefs.activePlaylistType = PreferencesManager.typeXtream
        prefs.xtreamServer = server
        prefs.xtreamUser = user
        prefs.xtreamPass = pass
        Task {
            await repository.loadCurrentPlaylist()
            dismiss()
        }
    }

    private func loadDemoTurkey() {
        prefs.activePlaylistType = PreferencesManager.typeSample
        Task {
            await repository.loadCurrentPlaylist()
            dismiss()
        }
    }

    private func loadDemoWorld() {
        prefs.activePlaylistType = PreferencesManager.typeSample
        Task {
            await repository.loadCurrentPlaylist()
            dismiss()
        }
    }
}
