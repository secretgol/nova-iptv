import Foundation

public struct Channel: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let logoUrl: String?
    public let streamUrl: String
    public let category: String
    public let epgId: String?
    public var channelNum: Int
    public var isFavorite: Bool

    public init(
        id: String,
        name: String,
        logoUrl: String? = nil,
        streamUrl: String,
        category: String = "Genel",
        epgId: String? = nil,
        channelNum: Int = 0,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.logoUrl = logoUrl
        self.streamUrl = streamUrl
        self.category = category
        self.epgId = epgId
        self.channelNum = channelNum
        self.isFavorite = isFavorite
    }
}
