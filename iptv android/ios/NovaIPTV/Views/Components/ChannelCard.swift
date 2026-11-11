import SwiftUI

public struct ChannelCard: View {
    let channel: Channel
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void

    public init(
        channel: Channel,
        onSelect: @escaping () -> Void,
        onToggleFavorite: @escaping () -> Void
    ) {
        self.channel = channel
        self.onSelect = onSelect
        self.onToggleFavorite = onToggleFavorite
    }

    public var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                // Top row: Channel number & favorite star
                HStack {
                    Text("\(channel.channelNum)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.cyan.opacity(0.15))
                        .cornerRadius(4)

                    Spacer()

                    Button(action: onToggleFavorite) {
                        Image(systemName: channel.isFavorite ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundColor(channel.isFavorite ? .yellow : .gray.opacity(0.6))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }

                // Channel Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(white: 0.12))
                        .frame(height: 54)

                    if let logo = channel.logoUrl, let url = URL(string: logo) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 46)
                                    .padding(4)
                            case .failure:
                                fallbackLogo
                            case .empty:
                                ProgressView()
                                    .scaleEffect(0.7)
                            @unknown default:
                                fallbackLogo
                            }
                        }
                    } else {
                        fallbackLogo
                    }
                }

                // Channel Title
                Text(channel.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)

                // Category Subtitle
                Text(channel.category)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.10, green: 0.12, blue: 0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var fallbackLogo: some View {
        Image(systemName: "tv")
            .font(.system(size: 24))
            .foregroundColor(.cyan.opacity(0.8))
    }
}

public struct ScaleButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
