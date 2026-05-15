import AVFoundation
import AVKit
import SwiftUI

/// Looped hero video. Falls back to a soft radial gradient if the bundle
/// asset is missing (placeholder-friendly so the app runs end-to-end before
/// the designer drops real media in `Resources/Media/hero.mp4`).
///
/// Pauses on disappear / resumes on appear so the video and its audio bed
/// don't keep running while a downstream screen (camera, voice) is on top.
struct HeroVideoView: View {
    var bundleResource: String = "hero"
    var bundleExtension: String = "mp4"
    @State private var isPlaying: Bool = true

    var body: some View {
        if let url = Bundle.main.url(forResource: bundleResource, withExtension: bundleExtension) {
            LoopingVideo(url: url, isPlaying: isPlaying)
                .onAppear { isPlaying = true }
                .onDisappear { isPlaying = false }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            RadialGradient(
                colors: [Color.white, Color.semiOffWhite, Color.semiPurpleSoft.opacity(0.5)],
                center: .center,
                startRadius: 30,
                endRadius: 280
            )
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.semiInk.opacity(0.08))
                .frame(width: 240)
                .offset(y: 20)
        }
    }
}

private struct LoopingVideo: UIViewRepresentable {
    let url: URL
    let isPlaying: Bool

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.configure(with: url)
        view.setPlaying(isPlaying)
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        uiView.setPlaying(isPlaying)
    }

    static func dismantleUIView(_ uiView: PlayerContainerView, coordinator: ()) {
        uiView.stop()
    }
}

private final class PlayerContainerView: UIView {
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { nil }

    func configure(with url: URL) {
        // Allow the video's audio bed to play. `.ambient` + `mixWithOthers`
        // respects the user's silent switch and lets other apps' audio (music,
        // a call) blend through instead of being interrupted.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true, options: [])

        let item = AVPlayerItem(url: url)
        let queue = AVQueuePlayer(playerItem: item)
        queue.isMuted = false
        queue.actionAtItemEnd = .advance
        looper = AVPlayerLooper(player: queue, templateItem: item)
        let layer = AVPlayerLayer(player: queue)
        layer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(layer)
        self.playerLayer = layer
        self.player = queue
        queue.play()
    }

    func setPlaying(_ playing: Bool) {
        guard let player else { return }
        if playing {
            player.play()
        } else {
            player.pause()
        }
    }

    func stop() {
        player?.pause()
        player = nil
        looper = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}
