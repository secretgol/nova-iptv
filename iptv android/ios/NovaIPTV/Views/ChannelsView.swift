import SwiftUI

public struct ChannelsView: View {
    @ObservedObject private var repository = IPTVRepository.shared
    @ObservedObject private var prefs = PreferencesManager.shared

    @State private var selectedCategoryId: String = Category.allId
    @State private var searchText = ""
    @State private var selectedChannelForPlayback: Channel?
    @State private var showPlaylistSetup = false

    private let columns = [
        GridItem(.adaptive(minimum: 155), spacing: 12)
    ]

    public init() {}

    private var filteredChannels: [Channel] {
        repository.filterChannels(categoryId: selectedCategoryId, query: searchText)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.07, blue: 0.10).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Category Filter Pills
                    CategoryPillsView(
                        categories: repository.categories,
                        selectedCategoryId: $selectedCategoryId
                    )
                    .padding(.top, 4)
                    .padding(.bottom, 6)

                    if repository.isLoading {
                        Spacer()
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                                .scaleEffect(1.4)
                            Text("Yayınlar yükleniyor...")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else if filteredChannels.isEmpty {
                        emptyStateView
                    } else {
                        // Channel Grid
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(filteredChannels) { channel in
                                    ChannelCard(
                                        channel: channel,
                                        onSelect: {
                                            selectedChannelForPlayback = channel
                                        },
                                        onToggleFavorite: {
                                            repository.toggleFavorite(channel: channel)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .refreshable {
                            await repository.loadCurrentPlaylist()
                        }
                    }
                }
            }
            .navigationTitle("Nova IPTV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: "tv.fill")
                            .foregroundColor(.cyan)
                        Text("\(filteredChannels.count) Kanal")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showPlaylistSetup = true }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.cyan)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Kanal veya kategori ara...")
            .sheet(isPresented: $showPlaylistSetup) {
                PlaylistSetupView()
            }
            .fullScreenCover(item: $selectedChannelForPlayback) { channel in
                let index = filteredChannels.firstIndex(where: { $0.id == channel.id }) ?? 0
                IPTVPlayerView(playlist: filteredChannels, initialIndex: index)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tv.slash")
                .font(.system(size: 52))
                .foregroundColor(.gray.opacity(0.6))

            Text("Kanal Bulunamadı")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Text("Arama kriterlerinizi değiştirebilir veya yeni bir oynatma listesi ekleyebilirsiniz.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: { showPlaylistSetup = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Oynatma Listesi Yapılandır")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .background(Color.cyan)
                .cornerRadius(25)
            }
            .padding(.top, 8)

            Spacer()
        }
    }
}
