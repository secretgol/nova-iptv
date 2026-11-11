import SwiftUI

public struct FavoritesView: View {
    @ObservedObject private var repository = IPTVRepository.shared
    @State private var selectedChannelForPlayback: Channel?

    private let columns = [
        GridItem(.adaptive(minimum: 155), spacing: 12)
    ]

    public init() {}

    private var favoriteChannels: [Channel] {
        repository.channels.filter { $0.isFavorite }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.07, blue: 0.10).ignoresSafeArea()

                if favoriteChannels.isEmpty {
                    emptyFavoritesView
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(favoriteChannels) { channel in
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
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Favoriler")
            .fullScreenCover(item: $selectedChannelForPlayback) { channel in
                let index = favoriteChannels.firstIndex(where: { $0.id == channel.id }) ?? 0
                IPTVPlayerView(playlist: favoriteChannels, initialIndex: index)
            }
        }
    }

    private var emptyFavoritesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.slash")
                .font(.system(size: 52))
                .foregroundColor(.gray.opacity(0.6))

            Text("Henüz Favori Kanalınız Yok")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Text("Kanalların üzerindeki yıldız simgesine dokunarak hızlı erişim için favorilerinize ekleyebilirsiniz.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
