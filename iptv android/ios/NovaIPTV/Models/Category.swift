import Foundation

public struct Category: Identifiable, Hashable {
    public let id: String
    public let name: String
    public var count: Int

    public init(id: String, name: String, count: Int = 0) {
        self.id = id
        self.name = name
        self.count = count
    }

    public static let allId = "all_channels"
    public static let favoritesId = "favorite_channels"
}
