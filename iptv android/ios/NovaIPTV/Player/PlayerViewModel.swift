import Foundation
import AVFoundation
import AVKit
import SwiftUI
import Combine

@MainActor
public final class PlayerViewModel: ObservableObject {
    @Published public private(set) var currentChannel: Channel?
    @Published public private(set) var isBuffering = false
    @Published public private(set) var isPlaying = false
    @Published public private(set) var errorMessage: String?
    @Published public var showControls = true
    @Published public var showQuickDrawer = false
    @Published public var isFillMode = false

    public let player = AVPlayer()

    private var channelList: [Channel] = []
    private var currentIndex: Int = 0
    private var retryCount = 0
    private let maxRetries = 3
    private var statusObserver: NSKeyValueObservation?
    private var timeControlObserver: NSKeyValueObservation?
    private var hideTimer: Task<Void, Never>?
    private let prefs = PreferencesManager.shared

    public init() {
        setupAudioSession()
        setupPlayerObservers()
        self.isFillMode = prefs.isVideoFill
    }

    deinit {
        statusObserver?.invalidate()
        timeControlObserver?.invalidate()
        hideTimer?.cancel()
        player.pause()
        player.replaceCurrentItem(with: nil)
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .moviePlayback)
            try session.setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }

    private func setupPlayerObservers() {
        timeControlObserver = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                switch player.timeControlStatus {
                case .waitingToPlayAtSpecifiedRate:
                    self.isBuffering = true
                case .playing:
                    self.isBuffering = false
                    self.isPlaying = true
                    self.errorMessage = nil
                    self.retryCount = 0
                case .paused:
                    self.isPlaying = false
                    self.isBuffering = false
                @unknown default:
                    break
                }
            }
        }
    }

    public func setPlaylist(channels: [Channel], startIndex: Int) {
        self.channelList = channels
        self.currentIndex = max(0, min(startIndex, channels.count - 1))
        if !channels.isEmpty {
            playCurrentChannel()
        }
    }

    public func playCurrentChannel() {
        guard !channelList.isEmpty, currentIndex < channelList.count else { return }
        let channel = channelList[currentIndex]
        self.currentChannel = channel
        self.prefs.lastChannelId = channel.id
        self.isBuffering = true
        self.errorMessage = nil

        guard let url = URL(string: channel.streamUrl.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            self.errorMessage = "Geçersiz yayın URL'si"
            self.isBuffering = false
            return
        }

        // Pass custom User-Agent to bypass server-side blocks
        let headers = ["User-Agent": XtreamService.userAgent]
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        let item = AVPlayerItem(asset: asset)

        // Observe player item errors
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.handlePlaybackFailure()
        }

        statusObserver?.invalidate()
        statusObserver = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if item.status == .failed {
                    self.handlePlaybackFailure()
                }
            }
        }

        player.replaceCurrentItem(with: item)
        player.play()

        resetControlsTimer()
    }

    private func handlePlaybackFailure() {
        isBuffering = false
        if retryCount < maxRetries {
            retryCount += 1
            errorMessage = "Yayın bağlantısı koptu. Yeniden bağlanılıyor (\(retryCount)/\(maxRetries))..."
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                self.playCurrentChannel()
            }
        } else {
            errorMessage = "Yayın açılamıyor. Sunucu çevrimdışı veya format desteklenmiyor."
        }
    }

    public func nextChannel() {
        guard !channelList.isEmpty else { return }
        currentIndex = (currentIndex + 1) % channelList.count
        retryCount = 0
        playCurrentChannel()
    }

    public func previousChannel() {
        guard !channelList.isEmpty else { return }
        currentIndex = (currentIndex - 1 + channelList.count) % channelList.count
        retryCount = 0
        playCurrentChannel()
    }

    public func selectChannel(at index: Int) {
        guard index >= 0 && index < channelList.count else { return }
        currentIndex = index
        retryCount = 0
        playCurrentChannel()
    }

    public func selectChannel(channel: Channel) {
        if let idx = channelList.firstIndex(where: { $0.id == channel.id }) {
            selectChannel(at: idx)
        }
    }

    public func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        resetControlsTimer()
    }

    public func toggleAspectRatio() {
        isFillMode.toggle()
        prefs.isVideoFill = isFillMode
        resetControlsTimer()
    }

    public func toggleFavorite() {
        guard let channel = currentChannel else { return }
        IPTVRepository.shared.toggleFavorite(channel: channel)
        if let idx = channelList.firstIndex(where: { $0.id == channel.id }) {
            channelList[idx].isFavorite.toggle()
            currentChannel = channelList[idx]
        }
        resetControlsTimer()
    }

    public func toggleControls() {
        showControls.toggle()
        if showControls {
            resetControlsTimer()
        } else {
            hideTimer?.cancel()
        }
    }

    public func resetControlsTimer() {
        hideTimer?.cancel()
        showControls = true
        hideTimer = Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            if !Task.isCancelled {
                self.showControls = false
            }
        }
    }

    public func retry() {
        retryCount = 0
        playCurrentChannel()
    }

    public func cleanup() {
        hideTimer?.cancel()
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
}
