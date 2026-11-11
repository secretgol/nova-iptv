import Foundation
import SwiftUI

public final class PreferencesManager: ObservableObject {
    public static let shared = PreferencesManager()

    private let defaults = UserDefaults.standard

    private let keyPlaylistType = "pref_playlist_type"
    private let keyM3uUrl = "pref_m3u_url"
    private let keyXtreamServer = "pref_xtream_server"
    private let keyXtreamUser = "pref_xtream_user"
    private let keyXtreamPass = "pref_xtream_pass"
    private let keyFavorites = "pref_favorites_set"
    private let keyLastChannel = "pref_last_channel_id"
    private let keyAspectRatio = "pref_aspect_ratio"

    public static let typeSample = "sample"
    public static let typeM3U = "m3u"
    public static let typeXtream = "xtream"

    @Published public var activePlaylistType: String {
        didSet { defaults.set(activePlaylistType, forKey: keyPlaylistType) }
    }

    @Published public var m3uUrl: String {
        didSet { defaults.set(m3uUrl, forKey: keyM3uUrl) }
    }

    @Published public var xtreamServer: String {
        didSet { defaults.set(xtreamServer, forKey: keyXtreamServer) }
    }

    @Published public var xtreamUser: String {
        didSet { defaults.set(xtreamUser, forKey: keyXtreamUser) }
    }

    @Published public var xtreamPass: String {
        didSet { defaults.set(xtreamPass, forKey: keyXtreamPass) }
    }

    @Published public var favoriteIds: Set<String> {
        didSet { defaults.set(Array(favoriteIds), forKey: keyFavorites) }
    }

    @Published public var lastChannelId: String? {
        didSet { defaults.set(lastChannelId, forKey: keyLastChannel) }
    }

    @Published public var isVideoFill: Bool {
        didSet { defaults.set(isVideoFill, forKey: keyAspectRatio) }
    }

    private init() {
        self.activePlaylistType = defaults.string(forKey: keyPlaylistType) ?? PreferencesManager.typeSample
        self.m3uUrl = defaults.string(forKey: keyM3uUrl) ?? ""
        self.xtreamServer = defaults.string(forKey: keyXtreamServer) ?? ""
        self.xtreamUser = defaults.string(forKey: keyXtreamUser) ?? ""
        self.xtreamPass = defaults.string(forKey: keyXtreamPass) ?? ""
        let favArray = defaults.stringArray(forKey: keyFavorites) ?? []
        self.favoriteIds = Set(favArray)
        self.lastChannelId = defaults.string(forKey: keyLastChannel)
        self.isVideoFill = defaults.bool(forKey: keyAspectRatio)
    }

    public func isFavorite(channelId: String) -> Bool {
        return favoriteIds.contains(channelId)
    }

    @discardableResult
    public func toggleFavorite(channelId: String) -> Bool {
        if favoriteIds.contains(channelId) {
            favoriteIds.remove(channelId)
            return false
        } else {
            favoriteIds.insert(channelId)
            return true
        }
    }
}
