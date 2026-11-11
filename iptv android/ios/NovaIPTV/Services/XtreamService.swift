import Foundation

public final class XtreamService {
    public static let userAgent = "IPTVSmarters/2.1.0 (iOS; iPhone)"

    private let session: URLSession

    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 25
        config.timeoutIntervalForResource = 45
        config.httpAdditionalHeaders = [
            "User-Agent": Self.userAgent,
            "Accept": "*/*"
        ]
        self.session = URLSession(configuration: config)
    }

    public func authenticate(serverUrl: String, username: String, pass: String) async throws -> XtreamAuthResponse {
        guard let url = buildUrl(serverUrl: serverUrl, params: [
            "username": username,
            "password": pass
        ]) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(XtreamAuthResponse.self, from: data)
    }

    public func getLiveCategories(serverUrl: String, username: String, pass: String) async throws -> [XtreamCategory] {
        guard let url = buildUrl(serverUrl: serverUrl, params: [
            "username": username,
            "password": pass,
            "action": "get_live_categories"
        ]) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await session.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode([XtreamCategory].self, from: data)
    }

    public func getLiveStreams(serverUrl: String, username: String, pass: String, categoryId: String? = nil) async throws -> [XtreamStreamItem] {
        var params = [
            "username": username,
            "password": pass,
            "action": "get_live_streams"
        ]
        if let catId = categoryId {
            params["category_id"] = catId
        }

        guard let url = buildUrl(serverUrl: serverUrl, params: params) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await session.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode([XtreamStreamItem].self, from: data)
    }

    private func buildUrl(serverUrl: String, params: [String: String]) -> URL? {
        var clean = serverUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        if !clean.hasPrefix("http://") && !clean.hasPrefix("https://") {
            clean = "http://" + clean
        }
        if !clean.hasSuffix("/") {
            clean += "/"
        }
        clean += "player_api.php"

        var components = URLComponents(string: clean)
        components?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components?.url
    }
}
