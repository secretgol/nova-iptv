import Foundation
import SwiftUI
import Combine

@MainActor
public final class IPTVRepository: ObservableObject {
    public static let shared = IPTVRepository()

    @Published public private(set) var channels: [Channel] = []
    @Published public private(set) var categories: [Category] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    private let prefs = PreferencesManager.shared
    private let xtreamService = XtreamService()
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Observe favorite changes to update channel models
        prefs.$favoriteIds
            .sink { [weak self] favIds in
                guard let self = self else { return }
                self.syncFavoriteState(with: favIds)
            }
            .store(in: &cancellables)
    }

    public func loadCurrentPlaylist() async {
        isLoading = true
        errorMessage = nil

        do {
            let loaded: [Channel]
            switch prefs.activePlaylistType {
            case PreferencesManager.typeM3U:
                if !prefs.m3uUrl.trimmingCharacters(in: .whitespaces).isEmpty {
                    loaded = try await loadFromM3uUrl(prefs.m3uUrl)
                } else {
                    loaded = SamplePlaylists.getSampleChannels()
                }
            case PreferencesManager.typeXtream:
                if !prefs.xtreamServer.trimmingCharacters(in: .whitespaces).isEmpty {
                    loaded = try await loadFromXtream(
                        server: prefs.xtreamServer,
                        user: prefs.xtreamUser,
                        pass: prefs.xtreamPass
                    )
                } else {
                    loaded = SamplePlaylists.getSampleChannels()
                }
            default:
                loaded = SamplePlaylists.getSampleChannels()
            }

            self.channels = loaded
            syncFavoriteState(with: prefs.favoriteIds)
            rebuildCategories()
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            if self.channels.isEmpty {
                self.channels = SamplePlaylists.getSampleChannels()
                syncFavoriteState(with: prefs.favoriteIds)
                rebuildCategories()
            }
            self.isLoading = false
        }
    }

    public func loadFromM3uUrl(_ urlString: String) async throws -> [Channel] {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue(XtreamService.userAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        guard let content = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            throw URLError(.cannotDecodeContentData)
        }

        return M3UParser.parse(content: content)
    }

    public func loadFromXtream(server: String, user: String, pass: String) async throws -> [Channel] {
        _ = try await xtreamService.authenticate(serverUrl: server, username: user, pass: pass)
        let catList = try await xtreamService.getLiveCategories(serverUrl: server, username: user, pass: pass)
        let categoryMap = Dictionary(uniqueKeysWithValues: catList.map { ($0.categoryId, $0.categoryName) })

        let streams = try await xtreamService.getLiveStreams(serverUrl: server, username: user, pass: pass)
        var cleanServer = server.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanServer.hasSuffix("/") {
            cleanServer.removeLast()
        }

        var result: [Channel] = []
        var index = 1

        for item in streams {
            let catName = item.categoryId.flatMap { categoryMap[$0] } ?? "Genel"
            let streamUrl = "\(cleanServer)/live/\(user)/\(pass)/\(item.streamId).m3u8"

            result.append(
                Channel(
                    id: String(item.streamId),
                    name: item.name,
                    logoUrl: item.streamIcon,
                    streamUrl: streamUrl,
                    category: catName,
                    epgId: item.epgChannelId,
                    channelNum: item.num ?? index,
                    isFavorite: false
                )
            )
            index += 1
        }

        return result
    }

    private func syncFavoriteState(with favoriteIds: Set<String>) {
        channels = channels.map { ch in
            var copy = ch
            copy.isFavorite = favoriteIds.contains(ch.id)
            return copy
        }
        rebuildCategories()
    }

    public func rebuildCategories() {
        var list: [Category] = []

        // All Channels
        list.append(Category(id: Category.allId, name: "Tüm Kanallar", count: channels.sizeOrCount))

        // Favorites
        let favCount = channels.filter { $0.isFavorite }.count
        list.append(Category(id: Category.favoritesId, name: "⭐ Favoriler", count: favCount))

        // Group by category
        let grouped = Dictionary(grouping: channels, by: { $0.category })
        for (catName, items) in grouped.sorted(by: { $0.key < $1.key }) {
            if !catName.isEmpty {
                list.append(Category(id: catName, name: catName, count: items.count))
            }
        }

        self.categories = list
    }

    public func filterChannels(categoryId: String?, query: String?) -> [Channel] {
        var result = channels

        if let catId = categoryId, catId != Category.allId {
            if catId == Category.favoritesId {
                result = result.filter { $0.isFavorite }
            } else {
                result = result.filter { $0.category.localizedCaseInsensitiveCompare(catId) == .orderedSame }
            }
        }

        if let q = query?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(q) ||
                $0.category.localizedCaseInsensitiveContains(q) ||
                String($0.channelNum) == q
            }
        }

        return result
    }

    public func toggleFavorite(channel: Channel) {
        let isFav = prefs.toggleFavorite(channelId: channel.id)
        if let idx = channels.firstIndex(where: { $0.id == channel.id }) {
            channels[idx].isFavorite = isFav
        }
        rebuildCategories()
    }
}

private extension Array {
    var sizeOrCount: Int { count }
}
