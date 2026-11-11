import SwiftUI

public struct CategoriesView: View {
    @ObservedObject private var repository = IPTVRepository.shared
    @State private var selectedCategory: Category?
    @State private var selectedChannelForPlayback: Channel?

    private let columns = [
        GridItem(.adaptive(minimum: 155), spacing: 12)
    ]

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.07, blue: 0.10).ignoresSafeArea()

                List {
                    ForEach(repository.categories) { category in
                        NavigationLink(value: category) {
                            HStack(spacing: 14) {
                                Image(systemName: iconForCategory(category.id))
                                    .font(.system(size: 18))
                                    .foregroundColor(.cyan)
                                    .frame(width: 28)

                                Text(category.name)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)

                                Spacer()

                                Text("\(category.count)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color(red: 0.10, green: 0.12, blue: 0.17))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Kategoriler")
            .navigationDestination(for: Category.self) { category in
                categoryDetailView(for: category)
            }
            .fullScreenCover(item: $selectedChannelForPlayback) { channel in
                let channels = repository.filterChannels(categoryId: selectedCategory?.id, query: nil)
                let index = channels.firstIndex(where: { $0.id == channel.id }) ?? 0
                IPTVPlayerView(playlist: channels, initialIndex: index)
            }
        }
    }

    private func categoryDetailView(for category: Category) -> some View {
        let channels = repository.filterChannels(categoryId: category.id, query: nil)

        return ZStack {
            Color(red: 0.05, green: 0.07, blue: 0.10).ignoresSafeArea()

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(channels) { channel in
                        ChannelCard(
                            channel: channel,
                            onSelect: {
                                selectedCategory = category
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
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func iconForCategory(_ id: String) -> String {
        switch id {
        case Category.allId:
            return "tv.fill"
        case Category.favoritesId:
            return "star.fill"
        default:
            let lower = id.lowercased()
            if lower.contains("spor") || lower.contains("sport") {
                return "sportscourt.fill"
            } else if lower.contains("haber") || lower.contains("news") {
                return "newspaper.fill"
            } else if lower.contains("sinema") || lower.contains("film") || lower.contains("movie") {
                return "film.fill"
            } else if lower.contains("dizi") || lower.contains("series") {
                return "play.tv.fill"
            } else if lower.contains("belgesel") || lower.contains("doc") {
                return "globe.americas.fill"
            } else if lower.contains("çocuk") || lower.contains("kid") {
                return "face.smiling.fill"
            } else if lower.contains("müzik") || lower.contains("music") {
                return "music.note"
            } else {
                return "folder.fill"
            }
        }
    }
}
