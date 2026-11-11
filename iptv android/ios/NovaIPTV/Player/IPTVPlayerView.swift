import SwiftUI
import AVKit
import AVFoundation

public struct IPTVPlayerView: View {
    @StateObject private var viewModel = PlayerViewModel()
    @Environment(\.dismiss) private var dismiss

    let playlist: [Channel]
    let initialIndex: Int

    public init(playlist: [Channel], initialIndex: Int) {
        self.playlist = playlist
        self.initialIndex = initialIndex
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Video Surface
            VideoSurfaceView(player: viewModel.player, isFill: viewModel.isFillMode)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.toggleControls()
                }
                .gesture(
                    DragGesture(minimumDistance: 40)
                        .onEnded { value in
                            if abs(value.translation.width) > abs(value.translation.height) {
                                if value.translation.width < -40 {
                                    // Swipe left -> Next channel
                                    viewModel.nextChannel()
                                } else if value.translation.width > 40 {
                                    // Swipe right -> Prev channel
                                    viewModel.previousChannel()
                                }
                            }
                        }
                )

            // Buffering Spinner
            if viewModel.isBuffering && viewModel.errorMessage == nil {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                    .scaleEffect(1.6)
            }

            // Error Overlay
            if let error = viewModel.errorMessage {
                VStack(spacing: 14) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)

                    Text(error)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    Button(action: { viewModel.retry() }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Tekrar Dene")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 10)
                        .background(Color.cyan)
                        .cornerRadius(20)
                    }
                }
                .padding(24)
                .background(Color(white: 0.12, opacity: 0.9))
                .cornerRadius(16)
            }

            // Controls Overlay
            if viewModel.showControls {
                VStack {
                    topBar
                    Spacer()
                    bottomBar
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.25)))
            }

            // Quick Channel Drawer
            if viewModel.showQuickDrawer {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { viewModel.showQuickDrawer = false }
                    }

                HStack {
                    QuickChannelDrawerView(
                        channels: playlist,
                        currentChannel: viewModel.currentChannel,
                        onSelect: { selected in
                            viewModel.selectChannel(channel: selected)
                            withAnimation { viewModel.showQuickDrawer = false }
                        }
                    )
                    .frame(width: 320)
                    .transition(.move(edge: .leading))

                    Spacer()
                }
            }
        }
        .statusBar(hidden: !viewModel.showControls)
        .onAppear {
            viewModel.setPlaylist(channels: playlist, startIndex: initialIndex)
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.white.opacity(0.85))
            }

            if let ch = viewModel.currentChannel {
                Text("\(ch.channelNum)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.cyan)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(ch.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text("CANLI")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(4)
                    }

                    Text(ch.category)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            // Aspect Ratio Toggle
            Button(action: { viewModel.toggleAspectRatio() }) {
                Image(systemName: viewModel.isFillMode ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Circle())
            }

            // AirPlay
            AirPlayPickerView()
                .frame(width: 34, height: 34)

            // Favorite Button
            Button(action: { viewModel.toggleFavorite() }) {
                Image(systemName: (viewModel.currentChannel?.isFavorite == true) ? "star.fill" : "star")
                    .font(.system(size: 18))
                    .foregroundColor((viewModel.currentChannel?.isFavorite == true) ? .yellow : .white)
                    .padding(8)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.85), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        HStack(spacing: 28) {
            Button(action: {
                withAnimation { viewModel.showQuickDrawer.toggle() }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "list.bullet")
                    Text("Kanallar")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.18))
                .cornerRadius(20)
            }

            Spacer()

            // Previous
            Button(action: { viewModel.previousChannel() }) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }

            // Play / Pause
            Button(action: { viewModel.togglePlayPause() }) {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 46))
                    .foregroundColor(.cyan)
            }

            // Next
            Button(action: { viewModel.nextChannel() }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }

            Spacer()

            // Current Time Clock
            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                Text(context.date, style: .time)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .background(
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

// MARK: - Video Surface Layer
private struct VideoSurfaceView: UIViewRepresentable {
    let player: AVPlayer
    let isFill: Bool

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = isFill ? .resizeAspectFill : .resizeAspect
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.player = player
        uiView.playerLayer.videoGravity = isFill ? .resizeAspectFill : .resizeAspect
    }
}

private class PlayerUIView: UIView {
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
}

// MARK: - AirPlay Route Picker
private struct AirPlayPickerView: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let routePicker = AVRoutePickerView()
        routePicker.tintColor = .white
        routePicker.activeTintColor = .cyan
        routePicker.backgroundColor = .clear
        return routePicker
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}

// MARK: - Quick Channel Drawer
private struct QuickChannelDrawerView: View {
    let channels: [Channel]
    let currentChannel: Channel?
    let onSelect: (Channel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("📺 Hızlı Kanal Listesi")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.cyan)
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 12)

            Divider().background(Color.white.opacity(0.15))

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(channels) { ch in
                            Button(action: { onSelect(ch) }) {
                                HStack(spacing: 12) {
                                    Text("\(ch.channelNum)")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(ch.id == currentChannel?.id ? .cyan : .gray)
                                        .frame(width: 32, alignment: .leading)

                                    Text(ch.name)
                                        .font(.system(size: 14, weight: ch.id == currentChannel?.id ? .bold : .regular))
                                        .foregroundColor(.white)
                                        .lineLimit(1)

                                    Spacer()

                                    if ch.isFavorite {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor(.yellow)
                                    }

                                    if ch.id == currentChannel?.id {
                                        Image(systemName: "waveform")
                                            .foregroundColor(.cyan)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(ch.id == currentChannel?.id ? Color.cyan.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                            }
                            .id(ch.id)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onAppear {
                    if let cur = currentChannel {
                        proxy.scrollTo(cur.id, anchor: .center)
                    }
                }
            }
        }
        .background(Color(red: 0.08, green: 0.10, blue: 0.14).opacity(0.95))
        .ignoresSafeArea(edges: .vertical)
    }
}
