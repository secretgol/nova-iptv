import SwiftUI

public struct SettingsView: View {
    @ObservedObject private var prefs = PreferencesManager.shared
    @ObservedObject private var repository = IPTVRepository.shared
    @State private var showSetupSheet = false
    @State private var showReloadAlert = false

    public init() {}

    private var activeSourceTitle: String {
        switch prefs.activePlaylistType {
        case PreferencesManager.typeM3U:
            return "M3U / M3U8 Bağlantısı"
        case PreferencesManager.typeXtream:
            return "Xtream Codes Hesabı"
        default:
            return "Ücretsiz Test Kanalları"
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.07, blue: 0.10).ignoresSafeArea()

                List {
                    // Section 1: Active Playlist
                    Section(header: Text("AKTİF OYNATMA LİSTESİ").foregroundColor(.cyan)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(activeSourceTitle)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)

                            Text("\(repository.channels.count) Kanal • \(repository.categories.count) Kategori")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)

                            if prefs.activePlaylistType == PreferencesManager.typeM3U && !prefs.m3uUrl.isEmpty {
                                Text(prefs.m3uUrl)
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray.opacity(0.7))
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 4)

                        Button(action: { showSetupSheet = true }) {
                            HStack {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.cyan)
                                Text("Oynatma Listesini Değiştir")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }

                        Button(action: {
                            Task {
                                await repository.loadCurrentPlaylist()
                                showReloadAlert = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .foregroundColor(.green)
                                Text("Listeyi Yeniden Yükle")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .listRowBackground(Color(red: 0.10, green: 0.12, blue: 0.17))

                    // Section 2: Player & Streaming
                    Section(header: Text("YAYIN VE OYNATICI").foregroundColor(.cyan)) {
                        HStack {
                            Text("Oynatıcı Motoru")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Apple AVPlayer (Native HLS)")
                                .foregroundColor(.gray)
                                .font(.system(size: 13))
                        }

                        HStack {
                            Text("Resim İçinde Resim (PiP)")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Etkin")
                                .foregroundColor(.green)
                                .font(.system(size: 13, weight: .semibold))
                        }

                        HStack {
                            Text("AirPlay Desteği")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Etkin")
                                .foregroundColor(.green)
                                .font(.system(size: 13, weight: .semibold))
                        }

                        HStack {
                            Text("Özel TV User-Agent")
                                .foregroundColor(.white)
                            Spacer()
                            Text("IPTVSmarters/2.1.0")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        }
                    }
                    .listRowBackground(Color(red: 0.10, green: 0.12, blue: 0.17))

                    // Section 3: App Info
                    Section(header: Text("UYGULAMA HAKKINDA").foregroundColor(.cyan)) {
                        HStack {
                            Text("Uygulama")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Nova IPTV iOS")
                                .foregroundColor(.gray)
                        }

                        HStack {
                            Text("Sürüm")
                                .foregroundColor(.white)
                            Spacer()
                            Text("1.0.0 (Build 1)")
                                .foregroundColor(.gray)
                        }
                    }
                    .listRowBackground(Color(red: 0.10, green: 0.12, blue: 0.17))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Ayarlar")
            .sheet(isPresented: $showSetupSheet) {
                PlaylistSetupView()
            }
            .alert("Yenilendi", isPresented: $showReloadAlert) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text("Oynatma listesi başarıyla güncellendi.")
            }
        }
    }
}
