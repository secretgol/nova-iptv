import Foundation

public final class M3UParser {

    private static let tvgIdRegex = try? NSRegularExpression(pattern: "tvg-id=\"([^\"]*)\"", options: .caseInsensitive)
    private static let tvgNameRegex = try? NSRegularExpression(pattern: "tvg-name=\"([^\"]*)\"", options: .caseInsensitive)
    private static let tvgLogoRegex = try? NSRegularExpression(pattern: "tvg-logo=\"([^\"]*)\"", options: .caseInsensitive)
    private static let groupTitleRegex = try? NSRegularExpression(pattern: "group-title=\"([^\"]*)\"", options: .caseInsensitive)

    public static func parse(content: String) -> [Channel] {
        var channels: [Channel] = []

        var currentTvgId: String?
        var currentTvgName: String?
        var currentLogo: String?
        var currentGroup: String?
        var currentChannelName: String?
        var channelIndex = 1

        content.enumerateLines { line, _ in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }

            if trimmed.lowercased().hasPrefix("#extinf:") {
                currentTvgId = extractAttribute(line: trimmed, regex: tvgIdRegex)
                currentTvgName = extractAttribute(line: trimmed, regex: tvgNameRegex)
                currentLogo = extractAttribute(line: trimmed, regex: tvgLogoRegex)
                currentGroup = extractAttribute(line: trimmed, regex: groupTitleRegex)

                if let commaIndex = trimmed.lastIndex(of: ",") {
                    let namePart = String(trimmed[trimmed.index(after: commaIndex)...]).trimmingCharacters(in: .whitespaces)
                    currentChannelName = namePart.isEmpty ? (currentTvgName ?? "Kanal \(channelIndex)") : namePart
                } else {
                    currentChannelName = currentTvgName ?? "Kanal \(channelIndex)"
                }
            } else if !trimmed.hasPrefix("#") {
                if isValidStreamUrl(trimmed) {
                    let finalName = currentChannelName ?? currentTvgName ?? "Kanal \(channelIndex)"
                    let finalGroup = (currentGroup?.trimmingCharacters(in: .whitespaces).isEmpty == false) ? currentGroup! : "Genel"

                    let channel = Channel(
                        id: (currentTvgId?.isEmpty == false ? currentTvgId! : UUID().uuidString),
                        name: finalName,
                        logoUrl: (currentLogo?.isEmpty == false ? currentLogo : nil),
                        streamUrl: trimmed,
                        category: finalGroup,
                        epgId: currentTvgId,
                        channelNum: channelIndex
                    )
                    channels.append(channel)
                    channelIndex += 1
                }

                currentTvgId = nil
                currentTvgName = nil
                currentLogo = nil
                currentGroup = nil
                currentChannelName = nil
            }
        }

        return channels
    }

    private static func extractAttribute(line: String, regex: NSRegularExpression?) -> String? {
        guard let regex = regex else { return nil }
        let nsLine = line as NSString
        let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: nsLine.length))
        guard let range = match?.range(at: 1), range.location != NSNotFound else { return nil }
        return nsLine.substring(with: range).trimmingCharacters(in: .whitespaces)
    }

    private static func isValidStreamUrl(_ url: String) -> Bool {
        let lower = url.lowercased()
        return lower.hasPrefix("http://") ||
            lower.hasPrefix("https://") ||
            lower.hasPrefix("rtmp://") ||
            lower.hasPrefix("rtsp://")
    }
}
