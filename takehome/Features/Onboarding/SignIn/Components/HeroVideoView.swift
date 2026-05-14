import AVFoundation
import AVKit
import SwiftUI

/// Looped hero video. Falls back to a soft radial gradient if the bundle
/// asset is missing (placeholder-friendly so the app runs end-to-end before
/// the designer drops real media in `Resources/Media/hero.mp4`).
struct HeroVideoView: View {
    var bundleResource: String = "hero"
    var bundleExtension: String = "mp4"

    var body: some View {
        if let url = Bundle.main.url(forResource: bundleResource, withExtension: bundleExtension) {
            LoopingVideo(url: url)
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

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.configure(with: url)
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {}

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
        let item = AVPlayerItem(url: url)
        let queue = AVQueuePlayer(playerItem: item)
        queue.isMuted = true
        queue.actionAtItemEnd = .advance
        looper = AVPlayerLooper(player: queue, templateItem: item)
        let layer = AVPlayerLayer(player: queue)
        layer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(layer)
        self.playerLayer = layer
        self.player = queue
        queue.play()
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
